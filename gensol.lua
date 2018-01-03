local function div(str)
	local _, _, tab, key, value = string.find(str, "(\t*)([^%s]+)%s+([^%s]+)%s*")
	if not key then
		_, _, tab, key = string.find(str, "(\t*)([^%s]+)%s*")
	end
	tab = tab or ""
	return #tab, key, value
end
local function newnode(file, row, dpt, key, val)
	local obj = {
		key = key,
		value = val,
		sub = {}
	}
	while row <= #file do
		local d, k, v = div(file[row])
		if d ~= dpt + 1 then
			break
		end
		obj.sub[#obj.sub + 1], row = newnode(file, row + 1, d, k, v)
	end
	return obj, row
end
local function createnode(node, prt, multi)
	local obj = {
		__key = node.key,
		__value = node.value
	}
	local nxt
	for k, v in pairs(node.sub) do
		nxt = createnode(v, obj, multi)
		if not multi[v.key] then
			obj[v.key] = nxt
		elseif obj[v.key] then
			obj[v.key][#obj[v.key] + 1] = nxt
		else
			obj[v.key] = { nxt }
		end
	end
	return setmetatable(obj, {
		__index = prt
	})
end
local function node_load(file, mt)
	local f = io.open(file, "r")
	if not f then
		return nil
	end
	local d = {}
	for l in f:lines() do
		d[#d + 1] = l
	end
	local n = newnode(d, 1, -1)
	f:close()
	n = createnode(n, nil, mt or {})
	return n
end
suffixs = {
	excutable = "",
	library = ".so",
	archive = ".a"
}
compilers = {}
compilers["c"] = "$(CC)"
compilers["c++"] = "$(CXX)"
expect_compiler = {
	c = "$(CC)",
	cpp = "$(CXX)",
	cc = "$(CXX)",
	cxx = "$(CXX)",
	C = "$(CXX)"
}
function getExt(str)
	local _, _, suf = string.find(str, ".*%.(%w+)")
	return suf
end
function expPath(str, src)
	if string.sub(str, 1, 1) == "@" then
		return src..string.sub(str, 2), string.sub(str, 2)
	elseif string.sub(str, 1, 1) == "!" then
		return ".output/"..string.sub(str, 2), string.sub(str, 2)
	else
		return str, str
	end
end
Makefile = io.open("Makefile", "w")
Makefile:write("PREFIX=/usr/local\n")
objs = ""
outs = ""
insts = ""
function main(src_dir, have_default)
	local node = node_load(src_dir.."solution", {
		target = true,
		link = true,
		depend = true,
		include = true,
		define = true,
		library = true,
		rpath = true,
		source = true,
		warning = true,
		inst_bin = true,
		inst_inc = true,
		inst_lib = true,
		inst_shr = true,
		subdir = true
	})
	if not node then
		print("Failed to open "..src_dir.."solution")
		os.exit(1)
	end
	for k, v in pairs(node.var or {}) do
		if k ~= "__key" and k ~= "__value" then
			Makefile:write(string.format("%s=%s\n", k, v.__value))
		end
	end
	if (have_default) then
		Makefile:write("default:")
		for _, target in pairs(node.target or {}) do
			if target.default and target.default.__value == "true" then
				Makefile:write(" "..target.__value)
			end
		end
		Makefile:write("\n")
	end
	for _, dir in pairs(node.subdir or {}) do
		local subdir = expPath(dir.__value, src_dir)
		if (string.sub(subdir, -1) ~= "/") then
			main(subdir.."/")
		else
			main(subdir)
		end
	end
	for _, target in pairs(node.target or {}) do
		local target_name = target.__value
		local objlst = ""
		if target.type.__value == "phony" then
			Makefile:write(target_name..":")
			for _, depend_target in ipairs(target.depend or {}) do
				Makefile:write(" "..depend_target.__value)
			end
			Makefile:write("\n.PHONY: "..target_name)
		else
			for _, source in ipairs(target.source or {}) do
				local src, obj = expPath(source.__value, src_dir)
				obj = "build."..target_name.."/"..obj..".o"
				objlst = objlst.." "..obj
				Makefile:write(string.format("%s: $(shell %s -MM %s", obj, expect_compiler[getExt(src)], src))
				if target.std then
					Makefile:write(" -std="..target.std.__value)
				end
				if target.bit then
					Makefile:write(" -m"..target.bit.__value)
				end
				for _, dir in ipairs(target.include or {}) do
					Makefile:write(" -I"..expPath(dir.__value, src_dir))
				end
				for _, mcr in ipairs(target.define or {}) do
					Makefile:write(" -D"..mcr.__value)
				end
				Makefile:write(" | tr '\\n' ' ' | tr '\\\\' ' ' | perl -pe 's/.*://')\n\t@mkdir -p `dirname $@`\n")
				Makefile:write("\t@echo \"Compile $<\"\n")
				Makefile:write(string.format("\t@%s -c -o $@ $<", expect_compiler[getExt(src)]))
				if target.type.__value == "library" then
					Makefile:write(" -fPIC")
				end
				if target.std then
					Makefile:write(" -std="..target.std.__value)
				end
				if target.bit then
					Makefile:write(" -m"..target.bit.__value)
				end
				for _, dir in ipairs(target.include or {}) do
					Makefile:write(" -I"..expPath(dir.__value, src_dir))
				end
				for _, mcr in ipairs(target.define or {}) do
					Makefile:write(" -D"..mcr.__value)
				end
				if target.debug and target.debug.__value == "true" then
					Makefile:write(" -g")
				end
				if target.optimize then
					Makefile:write(" -O"..target.optimize.__value)
				end
				for _, warn in ipairs(target.warning or {}) do
					Makefile:write(" -W"..warn.__value)
				end
				Makefile:write("\n")
			end
			target.lang = target.lang or { __value = "c++" }
			local outfile = target_name..suffixs[target.type.__value]
			local output = ".output/"..target_name.."/"..outfile
			outs = outs.." "..output
			objs = objs..objlst
			Makefile:write(string.format([[%s: %s
.PHONY: %s
%s:]], target_name, output, target_name, output))
			for _, depend_target in ipairs(target.depend or {}) do
				Makefile:write(" "..depend_target.__value)
			end
			Makefile:write(objlst.."\n\t@mkdir -p `dirname $@`\n\t@echo \"Link $@\"\n")
			if target.type.__value == "archive" then
				Makefile:write("\t@$(AR) rc $@"..objlst)
			else
				Makefile:write("\t@"..compilers[target.lang.__value].." -o $@")
				if target.type.__value == "library" then
					Makefile:write(" -shared")
				end
				if target.bit then
					Makefile:write(" -m"..target.bit.__value)
				end
				Makefile:write(objlst)
				for _, dir in ipairs(target.library or {}) do
					Makefile:write(" -L"..expPath(dir.__value, src_dir))
				end
				for _, lib in ipairs(target.link or {}) do
					Makefile:write(" -l"..lib.__value)
				end
				for _, path in ipairs(target.rpath or {}) do
					Makefile:write(" -Wl,--rpath="..path.__value)
				end
				if target.debug and target.debug.__value == "true" then
					Makefile:write(" -g")
				end
				if target.optimize then
					Makefile:write(" -O"..target.optimize.__value)
				end
			end
		end
		Makefile:write("\n")
		if target.install then
			insts = insts.." install."..target_name
			Makefile:write(string.format("install.%s: %s\n", target_name, target_name))
			local inst = target.install
			if inst.inst_bin then
				Makefile:write("\t@mkdir -p $(PREFIX)/bin\n")
				for _, file in ipairs(inst.inst_bin) do
					local p = expPath(file.__value, src_dir)
					Makefile:write(string.format([[
	@echo "Install %s"
	@install -m 0755 %s $(PREFIX)/bin/`basename %s`
]], p, p, p))
				end
			end
			if inst.inst_inc then
				Makefile:write("\t@mkdir -p $(PREFIX)/include\n")
				for _, file in ipairs(inst.inst_inc) do
					local p = expPath(file.__value, src_dir)
					Makefile:write(string.format([[
	@echo "Install %s"
	@install -m 0644 %s $(PREFIX)/include/`basename %s`
]], p, p, p))
				end
			end
			if inst.inst_lib then
				Makefile:write("\t@mkdir -p $(PREFIX)/lib\n")
				for _, file in ipairs(inst.inst_lib) do
					local p = expPath(file.__value, src_dir)
					Makefile:write(string.format([[
	@echo "Install %s"
	@install -m 0644 %s $(PREFIX)/lib/`basename %s`
]], p, p, p))
				end
			end
			if inst.inst_shr then
				Makefile:write("\t@mkdir -p $(PREFIX)/share/"..target_name.."\n")
				for _, file in ipairs(inst.inst_shr) do
					local p = expPath(file.__value, src_dir)
					Makefile:write(string.format([[
	@echo "Install %s"
	@install -m 0644 %s $(PREFIX)/share/%s/`basename %s`
]], p, p, target_name, p))
				end
			end
			Makefile:write(".PHONY: install."..target_name.."\n")
		end
	end
end
main(arg[1], ".output/")
Makefile:write([[
clean:
	@echo "Remove objects"
	@-rm -f]]..objs..[[

	@echo "Remove outputs"
	@-rm -f]]..outs..[[

.PHONY: clean
]])
Makefile:write("install:"..insts.."\n.PHONY: install\n")
Makefile:write([[
viewcompiler:
	@echo "c compiler: $(CC)"
	@echo "c++ compiler: $(CXX)"
	@echo "assembly compiler: $(AS)"
	@echo "archive linker: $(AR)"
.PHONY: viewcompiler
]])

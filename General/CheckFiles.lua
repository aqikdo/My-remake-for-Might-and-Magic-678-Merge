local strfind, strformat = string.find, string.format

local md5 = require "md5"
local app_path = AppPath:gsub("\\", "/")
local flist_file = "Scripts/Modules/FilesList.lua"

local ext_md5 = 'certutil.exe -hashfile "%s" MD5'
local use_external = true

local function GetChecksum(fname, binmode, external)
	local relname = fname:gsub("\\", "/"):replace(app_path, "")

	local f, cmdline
	if external then
		cmdline = strformat(ext_md5, relname)
		f = io.popen(cmdline)
	elseif binmode then
		f = io.open(fname, "rb")
	else
		f = io.open(fname, "r")
	end
	local t = f:read("*a")
	io.close(f)
	local chksum
	if external then
		chksum = t:split("\n")[2]
	else
		chksum = md5.sumhexa(t)
	end
	return relname, chksum
end

local function GetFilesSums()
	local res = {}
	local relname, chksum
	local start_time = os.date("%X")
	print("check started " .. start_time)
	--print("Process Scripts/*")
	for f0 in path.find("Scripts/*", true) do
		for fname in path.find(f0 .. "/*") do
			relname, checksum = GetChecksum(fname, true)
			table.insert(res, {name = relname, checksum = checksum})
		end
	end
	--print("Process Scripts/Structs/After/*")
	for fname in path.find("Scripts/Structs/After/*") do
		relname, checksum = GetChecksum(fname, true)
		table.insert(res, {name = relname, checksum = checksum})
	end
	--print("Process Data/*")
	for fname in path.find("Data/*") do
		if strfind(fname, "\\[^\\]+%.[^\\]+%.l[ow]d") then
			relname, checksum = GetChecksum(fname, true)
		else
			relname, checksum = GetChecksum(fname, true, use_external)
		end
		table.insert(res, {name = relname, checksum = checksum})
	end
	--print("Process Data/Additional UI/*")
	for fname in path.find("Data/Additional UI/*") do
		relname, checksum = GetChecksum(fname, true, use_external)
		table.insert(res, {name = relname, checksum = checksum})
	end
	--print("Process Data/Tables/*")
	for fname in path.find("Data/Tables/*") do
		relname, checksum = GetChecksum(fname, true)
		table.insert(res, {name = relname, checksum = checksum})
	end
	--print("Process DataFiles/*.txt")
	for fname in path.find("DataFiles/*.txt") do
		relname, checksum = GetChecksum(fname, true)
		table.insert(res, {name = relname, checksum = checksum})
	end
	--print("Process Anims/*")
	for fname in path.find("Anims/*") do
		relname, checksum = GetChecksum(fname, false, use_external)
		table.insert(res, {name = relname, checksum = checksum})
	end
	--print("Process ExeMods/*")
	for fname in path.find("ExeMods/*") do
		relname, checksum = GetChecksum(fname, true, use_external)
		table.insert(res, {name = relname, checksum = checksum})
	end
	--print("Process ExeMods/MMExtension/*")
	for fname in path.find("ExeMods/MMExtension/*") do
		relname, checksum = GetChecksum(fname, true, use_external)
		table.insert(res, {name = relname, checksum = checksum})
	end
	--print("Process mm8.exe")
	for fname in path.find("mm8.exe") do
		relname, checksum = GetChecksum(fname, true, use_external)
		table.insert(res, {name = relname, checksum = checksum})
	end
	--print("Process MM8patch.dll")
	for fname in path.find("MM8patch.dll") do
		relname, checksum = GetChecksum(fname, true, use_external)
		table.insert(res, {name = relname, checksum = checksum})
	end
	--print("Process mm8.ini")
	for fname in path.find("mm8.ini") do
		relname, checksum = GetChecksum(fname, true)
		table.insert(res, {name = relname, checksum = checksum})
	end
	local stop_time = os.date("%X")
	print("check finished " .. stop_time)
	print("-----------------------")
	return res
end

local ignore_files = {"Data/new.lod", "Data/lloyd*.pcx"}

function CheckFiles()
	local flist
	local fl, errstr = loadfile(flist_file)
	if not fl then
		print("Cannot load checksums: " .. errstr)
		flist = {}
	else
		flist = fl()
	end
	local ignore_flist = {}
	for _, mask in pairs(ignore_files) do
		for ignore_f in path.find(mask) do
			local relname = ignore_f:gsub("\\", "/"):replace(app_path, "")
			table.insert(ignore_flist, relname)
		end
	end
	fsums = GetFilesSums()
	for _, v in pairs(fsums) do
		if flist[v.name] then
			if flist[v.name][1] == 1 and flist[v.name][2] ~= v.checksum then
				print(v.name .. ": checksum mismatch: " .. v.checksum)
			end
			flist[v.name] = nil
		elseif not table.find(ignore_flist, v.name) then
			print("unknown file: " .. v.name)
		end
	end
	for k, v in pairs(flist) do
		if v[1] == 1 then
			print("missing file: " .. k)
		end
	end
end

-- Creates/updates checksum list
function UpdateFilesList()
	local fsums = GetFilesSums()
	local old
	local fl, errstr = loadfile(flist_file)
	if not fl then
		print("Cannot load checksums: " .. errstr)
		old = {}
	else
		old = fl()
	end
	fl = io.open(flist_file, "w")
	fl:write("-- local created = \"" .. os.date("%Y-%m-%d") .. "\"\n")
	fl:write("return {\n  [\"" .. flist_file .. "\"] = {0, \"\"},\n")
	local ignore_flist = {}
	for _, mask in pairs(ignore_files) do
		for ignore_f in path.find(mask) do
			local relname = ignore_f:gsub("\\", "/"):replace(app_path, "")
			table.insert(ignore_flist, relname)
		end
	end
	for _, v in pairs(fsums) do
		if v.name ~= flist_file and not table.find(ignore_flist, v.name) then
			local ftype
			if not old[v.name] then
				ftype = 1
				print("new: " .. v.name)
			else
				ftype = old[v.name][1]
				if v.checksum ~= old[v.name][2] then
					print("changed: " .. v.name)
				end
			end
			fl:write("  [\"" .. v.name .. "\"] = {" .. ftype .. ", \"" .. v.checksum .. "\"},\n")
		end
	end
	fl:write("}\n")
	io.close(fl)
end

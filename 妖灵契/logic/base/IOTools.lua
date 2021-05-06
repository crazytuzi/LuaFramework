module(..., package.seeall)

g_IOCache = {}
g_PersistentDataPath = C_api.ResourceManager.GetPersistentDataPath()
g_DataPath = UnityEngine.Application.dataPath

function WalkDir(sDir, fn)
	local function walk(s)
		local dirlist = System.IO.Directory.GetDirectories(s)
		for i = 0, dirlist.Length - 1 do
			walk(dirlist[i])
		end
		local filelist = System.IO.Directory.GetFiles(s)
		for i = 0, filelist.Length - 1 do
			local fileName = System.IO.Path.GetFileName(filelist[i])
			fn(s, fileName)
		end
	end
	walk(sDir)
end

function Move(srcPath, dstPath)
	C_api.IOHelper.Move(srcPath, dstPath)
end

function Copy(srcPath, dstPath)
	C_api.IOHelper.Copy(srcPath, dstPath)
end

function Delete(path)
	C_api.IOHelper.Delete(path)
end

function IsExist(path)
	return C_api.IOHelper.Exists(path)
end

-- IOTools.GetFiles(IOTools.GetAssetPath("/Lua"), "*.lua", false)
function GetFiles(sDir, sPattrn, bSub)
	if not IsExist(sDir) then
		return {}
	end
	local arr = nil
	if bSub then
		arr = System.IO.Directory.GetFiles(sDir, sPattrn, 1)
	else
		arr = System.IO.Directory.GetFiles(sDir, sPattrn, 0)
	end
	local list = {}
	for i=0, arr.Length - 1 do
		local s = string.gsub(arr[i], "\\", "/")
		table.insert(list, s)
	end
	return list
end

function GetFilterFiles(sDir, filter, bSub)
	if not IsExist(sDir) then
		return {}
	end
	local arr = nil
	if bSub then
		arr = System.IO.Directory.GetFiles(sDir, "*", 1)
	else
		arr = System.IO.Directory.GetFiles(sDir, "*", 0)
	end
	local list = {}
	for i=0, arr.Length - 1 do
		local s = string.gsub(arr[i], "\\", "/")
		if filter(s) then
			table.insert(list, s)
		end
	end
	return list
end

function GetDirectoryName(path)
	return System.IO.Path.GetDirectoryName(path)
end

function GetFileName(path, bWithoutExtension)
	local filename = string.gsub(path, "^.*/", "", 1)
	if bWithoutExtension then
		local filename, _ = string.gsub(filename, "%..*$", "", 1)
		return filename
	else
		return filename
	end
end

function GetExtension(path)
	return string.gsub(path, "^.-%.", "", 1)
end

function GetAssetPath(path)
	local path = path or ""
	return g_DataPath..path
end

function GetGameResPath(path)
	local path = path or ""
	return g_DataPath.."/GameRes"..path
end

function GetPersistentDataPath(path)
	local path = path or ""
	return g_PersistentDataPath..path
end

function CreateDirectory(path)
	System.IO.Directory.CreateDirectory(path)
end

function LoadByteFile(path)
	local handler = C_api.FileHandler.OpenByte(path)
	if not handler then
		return
	end
	local bytes = handler:ReadByte()
	handler:Close()
	return bytes
end

function SaveByteFile(path, bytes)
	local handler = C_api.FileHandler.CreateByte(path)
	handler:WriteByte(bytes)
	handler:Close()
end

function LoadStringByLua(path, mode, len)
	if IsExist(path) then
		local file = io.open(path, mode)
		if file then
			local s
			if len then
				s = file:read(len)
			else
				s = file:read("*a")
			end
			file:close()
			return s
		end
	end
end

function SaveTextFile(path, s)
	local handler = C_api.FileHandler.CreateText(path)
	handler:WriteText(s)
	handler:Close()
end

function LoadTextFile(path)
	local handler = C_api.FileHandler.OpenText(path)
	if not handler then
		return
	end
	local s = handler:ReadText()
	handler:Close()
	return s
end

function EncodeString(s)
	return ZZBase64.encode(s)
end

function DecodeString(s)
	return SafeDecode(s)
end

function LoadJsonFile(path, encrypt)
	local handler = C_api.FileHandler.OpenByte(path)
	if not handler then
		return
	end
	local s = handler:ReadByteToString()
	handler:Close()
	if encrypt then
		s = DecodeString(s)
	end
	local data = decodejson(s)
	return data
end

function SaveJsonFile(path, data, encrypt)
	local s = cjson.encode(data)
	if encrypt then
		s = EncodeString(s)
	end
	local handler = C_api.FileHandler.CreateByte(path)
	handler:WriteStringToByte(s)
	handler:Close()
end

--一个角色存一份
function GetRoleFilePath(filename)
	return GetPersistentDataPath(string.format("/role/%d%s", g_AttrCtrl.pid, filename))
end

function SetRoleData(k, v)
	local path = GetRoleFilePath("/roledata")
	local t = LoadJsonFile(path, true) or {}
	if t[k] ~= v then
		t[k] = v
		SaveJsonFile(path, t, true)
	end
end

function GetRoleData(k)
	local path = GetRoleFilePath("/roledata")
	local t = LoadJsonFile(path, true) or {}
	return t[k]
end

function GetAutoSkillData()
	local path = GetRoleFilePath("/autoskilldata")
	local t = LoadJsonFile(path, true) or {}
	return t
end

function SetLocalMagicData(kvDic)
	if kvDic == nil then
		return
	end
	local path = GetRoleFilePath("/autoskilldata")
	local t = LoadJsonFile(path, true) or {}
	local init = false
	for k,v in pairs(kvDic) do
		init =true
		t[k] = v
	end
	if init then
		SaveJsonFile(path, t, true)
	end
end

--一个客户端只存一份
function SetClientData(k, v)
	local oldVal = GetClientData(k)
	if not table.equal(oldVal, v) then
		local path = GetPersistentDataPath("/clientData")
		g_IOCache["clientdata"][k] = table.copy(v)
		SaveJsonFile(path, g_IOCache["clientdata"], true)
	end
end

function GetClientData(k)
	if not g_IOCache["clientdata"] then
		local path = GetPersistentDataPath("/clientData")
		g_IOCache["clientdata"] = LoadJsonFile(path, true) or {}
	end
	local v = g_IOCache["clientdata"][k]
	return table.copy(v)
end

function ReadNumber(sData, iLen)
	local iNumber = 0
	local iFactor = 1
	for i=iLen, 1, -1 do
		local iByte = string.byte(sData, i) or 0
		iNumber = iNumber + iByte * iFactor
		iFactor = iFactor * 256
	end
	return iNumber
end

LoadByteFile = safefunc(LoadByteFile)
SaveByteFile = safefunc(SaveByteFile)
LoadTextFile = safefunc(LoadTextFile, "")
SaveTextFile = safefunc(SaveTextFile)
SaveJsonFile = safefunc(SaveJsonFile)
LoadJsonFile = safefunc(LoadJsonFile, {})
SetClientData = safefunc(SetClientData)
GetClientData = safefunc(GetClientData, {})
SetRoleData = safefunc(SetRoleData)
GetRoleData = safefunc(GetRoleData, {})
GetAutoSkillData = safefunc(GetAutoSkillData)
SetLocalMagicData = safefunc(SetLocalMagicData)
SafeDecode = safefunc(ZZBase64.decode, {})
---
-- 所有工具类函数库
-- @type Util
Util = {}

---
-- 将一个代表8进制的字符串变成10进制数
-- @function [parent=#Util] octal2Decimal
-- @param #string data 八进制字符串，比如0700
-- @return #number 数字
function Util.octal2Decimal(data)
	local data = tostring(data)
	local aByte = string.byte('0', 1)
	local ret = 0
	for i = 1, data:len() do
		local b = data:byte(i)
		local d = b - aByte
		if d > 9 or d < 0 then
			Logger.fatal("invalid octal data:%s", data)
			return 0
		end
		ret = ret * 8 + d
	end

	return ret
end

---
-- 将px转变为pt
-- @function [parent=#Util] px2pt
-- @param #number px
-- @return #number pt
function Util.px2pt(px)
	return px * (72 / GameUtil:getDPI())
end

---
-- 将pt转换为px
-- @function [parent=#Util] pt2px
-- @param #number pt
-- @return #number px
function Util.pt2px(pt)
	return pt / (72 / GameUtil:getDPI())
end

---
-- 将px转换为dp
-- @function [parent=#Util] px2dp
-- @param #number px
-- @return #number dp
function Util.px2dp(px)
	return px * (160 / GameUtil:getDPI())
end

---
-- 将dp转换为px
-- @function [parent=#Util] dp2px
-- @param #number dp
-- @return #number px
function Util.dp2px(dp)
	return dp / (160 / GameUtil:getDPI())
end
---
-- 获取一个文件的checksum值
-- @function [parent=#Util] digestFile
-- @param #string filename 文件名
-- @param #number dtype 参数GameUtil
-- @param #boolean rawOutput 是否二进制输出
-- @return #string
function Util.digestFile(filename, dtype, rawOutput)
	local digest = CCCrypto:newDigest(dtype)
	if digest == nil then
		return ""
	end

	local file = io.open(filename, 'r')
	while true do
		local data = file:read(10240)
		if data == nil then
			break
		end
		digest:addBytes(data, data:len())
	end
	file:close()
	local ret = digest:getDigest(rawOutput)
	digest:release()
	return ret
end

---
-- 获取一个路径的父级目录
-- @function [parent=#Util] dirname
-- @param #string file 路径名称
-- @return #string
function Util.dirname(file)
	local index = file:reverse():find('/')
	if index ~= nil then
		return file:sub(0, file:len() - index + 1)
	else
		return file
	end
end

---
-- 删除一个目录
-- @function [parent=#Util] removeDir
-- @param #string dir
function Util.removeDir(dir)
	if not GameUtil:isDir(dir) then
		GameUtil:unlink(dir)
	else
		local files = GameUtil:readdir(dir)
		for i = 0, files:count() - 1 do
			Util.removeDir(dir .. '/' .. tolua.cast(files:objectAtIndex(i), "CCString"):getCString())
		end
		GameUtil:rmdir(dir)
	end
end

---
-- 把一个目录拷贝到另外一个地方
-- @function [parent=#Util] copyDir
-- @param #string sdir 源目录
-- @param #string tdir 目标目录
-- @param #boolean mv 是否移动
-- @return #boolean
function Util.copyDir(sdir, tdir, mv)
	if not GameUtil:isDir(sdir) then
		if mv then
			local ret = GameUtil:rename(sdir,tdir)
			if ret ~= 0 then
				Logger.warning("rename file:%s to %s failed", sdir, tdir)
			end

			return ret == 0
		else
			local sfile = io.open(sdir,"r")
			local tfile = io.open(tdir,"w")
			if sfile == nil or tfile == nil then
				Logger.warning("open file:[%s, %s] failed", sdir, tdir)
				return false
			end
			while true do
				local data = sfile:read(10240)
				if data == nil then
					break
				end
				tfile:write(data)
			end
			sfile:close()
			tfile:close()
			return true
		end
	else
		if 0 ~= GameUtil:access(tdir,GameUtil.EFOk) then
			local ret = GameUtil:mkdir(tdir,Util.octal2Decimal("0700"))
			if ret ~= 0 then
				Logger.warning("mkdir:%s failed", tdir)
				return false
			end
			Logger.trace("create dir:%s ok", tdir)
		end

		local files = GameUtil:readdir(sdir)
		for i = 0, files:count() - 1 do
			local file = tolua.cast(files:objectAtIndex(i), "CCString"):getCString()
			local tfile = tdir .. '/' .. file
			local sfile = sdir .. '/' .. file
			local ret = Util.copyDir(sfile, tfile, mv)
			if not ret then
				return ret
			end
		end
		return true
	end
end

---
-- 将两个table合成一个
-- @function [parent=#Util] mergeTable
-- @param #table t1
-- @param #table t2
-- @return #table 合成的新table，为t1 t2中较大的一个
function Util.mergeTable(t1, t2)
	local t = t1
	local a = t2
	local offset = #t1
	if #t1 < #t2 then
		t = t2
		a = t1
		offset = #t2
	end

	for i = 1, #a do
		t[offset + i] = a[i]
	end

	return t
end

---
-- 列出一个目录下的所有文件
-- @function [parent=#Util] listFiles
-- @param #string root
-- @return #table
function Util.listFiles(root)
	local ret = {}
	if not GameUtil:isDir(root) then
		ret[#ret + 1] = root
	else
		local children = GameUtil:readdir(root)
		children = Util.ccStringArrayToLua(children)
		for i = 1, #children do
			local files = Util.listFiles(root .. '/' .. children[i])
			ret = Util.mergeTable(ret, files)
		end
	end
	return ret
end
---
-- 检查一个变量是否为空，空的含义包括
-- nil
-- 空字符串
-- 数字0
-- false
-- 空数组
-- @function [parent=#Util] isEmpty
-- @param #string data
-- @return #boolean
function Util.isEmpty(data)
	if data == nil or data == "" or data == 0 or data == false then
		return true
	end

	if type(data) == "table" then
		for k, v in pairs(data) do
			return false
		end
		return true
	end

	return false
end

---
-- 将CCString类型的CCArray转成table
-- @function [parent=#Util] ccStringArrayToLua
-- @param CCArray#CCArray array
-- @return #table
function Util.ccStringArrayToLua(array)
	local ret = {}
	for i = 0, array:count() - 1 do
		ret[i + 1] = tolua.cast(array:objectAtIndex(i), "CCString"):getCString()
	end
	return ret
end

---
-- 将可变参数变成一个数组
-- @function [parent=#Util] getArgs
-- @param ...
-- @return #table
function Util.getArgs(...)
	local length = select('#', ...)
	local args = {}
	for i = 1, length do
		args[i] = select(i, ...)
	end
	return args
end

---
-- 将一个table转化成字符串
-- @function [parent=#Util] tableToString
-- @param #table t
-- @return #string
function Util.tableToString(t, level)
	local ret = ''
	if level == nil then
		level = 0
	end

	local function echoTabs(count)
		local s = ''
		for i = 1, count do
			s = s .. '\t'
		end
		return s
	end

	local dataType = type(t)
	if dataType == 'table' then
		ret = ret .. '{\n'
		for k, v in pairs(t) do
			ret = ret .. echoTabs(level + 1) .. '[' .. Util.tableToString(k) .. ']'
			ret = ret .. ' = '
			ret = ret .. Util.tableToString(v, level + 1)
			ret = ret .. ',\n'
		end
		ret = ret .. echoTabs(level) .. '}'
	elseif dataType == 'string' then
		return '"' .. t .. '"'
	elseif dataType == 'boolean' then
		return t and "true" or "false"
	else
		return t
	end
	return ret
end

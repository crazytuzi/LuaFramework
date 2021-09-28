--file.lua
--定义lua文件操作的方法

--打开文件：参数(文件名，打开模式)，返回文件句柄或nil
function openFile(filename,mode)
	local f = io.open(filename,mode)
	if f then
		return f
	else
		return nil
	end
end

--读取文件全部内容：参数(文件句柄)，返回一个string
function readAllFile(f)
	return f:read("*all")
end

--读取文件一行内容：参数(文件句柄)，返回一个string
function readLineFile(f)
	return f:read("*line")
end

--写文件内容：参数(文件句柄，字符串)
function writeFile(f,...)
	local arg = {...}
	f:write(unpack(arg))
end

--关闭文件,参数(文件句柄()
function closeFile(f)
	f:close()
end
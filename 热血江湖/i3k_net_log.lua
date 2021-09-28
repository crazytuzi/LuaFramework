local require = require;
i3k_net_log = i3k_class("i3k_net_log");

local MAX_FILE_LEN = 100000

function i3k_net_log:ctor()

end

function i3k_net_log:Clear()
	local fn = i3k_game_get_exe_path() .. "net_log.txt";
	local f = io.open(fn, "w");
	if f == nil then
		return false;
	end
	f:write(string.format(""));
	f:close();
	return true;
end

function i3k_net_log:getFileLen()
    local fileName = i3k_game_get_exe_path() .. "net_log.txt";
    local fh = io.open(fileName, "rb")
    if fh == nil then
        fh = io.open(fileName, "w");
        if fh == nil then
            return 0
        end
    end
    local len = assert(fh:seek("end"))
    fh:close()
    return len
end

function i3k_net_log:Add(typeName, ignoreTime)
    if not typeName then
        typeName = "nil"
    end
    local fileLen = self:getFileLen()
    if fileLen and fileLen > MAX_FILE_LEN then -- 大约100k文件
        self:Clear()
    end
    local time = os.date("%Y%m%d-%H:%M:%S",i3k_game_get_systime())
    local fn = i3k_game_get_exe_path() .. "net_log.txt";
	local f = io.open(fn, "a");
	if f == nil then
		return false;
	end
    if ignoreTime then
        f:write(string.format(typeName.."\n"));
    else
    f:write(string.format(time.." "..typeName.."\n"));
    end
	f:close();
	return true;
end

-------------------------------------

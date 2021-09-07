LocalSaveManager = LocalSaveManager or BaseClass(BaseManager)

function LocalSaveManager:__init()
    if LocalSaveManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    LocalSaveManager.Instance = self
    self.uid = nil
    self.currfile = nil
    -- self.uid = BaseUtils.Key(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
end


--I/O库为文件操作提供2个里一个输入库和一个输出库io.read()

--io.write() 该函数将所有参数按照顺序写到当前输出文件中

function LocalSaveManager:write()
  io.write('hello ', 'world')
end

--write()

--io.read() 读取当前文件的内容 "*all" "*line" "*number" number
--[[for count = 1,math.huge do
    local line = io.read("*line")  --如果不传参数，缺省值也是"*line"
    if line == nil then
        break
    end
    io.write(string.format("%6d  ",count),line,"\n")
end--]]

--读取指定文件
function LocalSaveManager:getFile(file_name, dir_path)
    local Path = ctx.ResourcesPath.."/chatLog/"..file_name
    if dir_path ~= nil then
        Path = dir_path.."/"..file_name
    end
    local f,err = io.open(Path, 'r')
    -- print(err)
    if f ~= nil then
        local string = f:read("*all")
        -- Log.Debug(string)
        f:close()
        local tb
        xpcall(function() tb = BaseUtils.unserialize(string) end,
            function() tb = {} self:writeFile(file_name, {}) print(debug.traceback()) end )

        self.currfile = tb
        return tb
    else
        self:writeFile(file_name, {}, dir_path)
        return nil
    end
end

-- local lines,rest = f:read(BUFSIZE,"*line")
-- 块读取文件
function LocalSaveManager:getFileLine(file_name)
    local Path = ctx.ResourcesPath.."/chatLog/"..file_name

    local BUFSIZE = 84012
    local f = assert(io.open(file_name, 'r'))
    local lines,rest = f:read(BUFSIZE, "*line")
    f:close()
    return lines , rest
end

--字符串写入
function LocalSaveManager:writeFile(file_name, data, dir_path)
    if file_name == nil then
        return
    end
    local string = BaseUtils.serialize(data)
    local Path = ctx.ResourcesPath.."/chatLog/"..file_name
    if dir_path ~= nil then
        Path = dir_path.."/"..file_name
    end
    local f, err = io.open(Path, 'w')
    if f ~= nil then
        f:write(string)
        f:close()
    else
        local _path = ctx.ResourcesPath.."/chatLog/"
        if dir_path ~= nil then
            _path = dir_path
        end
        if Application.platform == RuntimePlatform.WindowsPlayer then
            -- os.execute("mkdir \"" .. _path.."\"")
            Utils.CreateDirectoryStatic(_path)
        elseif Application.platform == RuntimePlatform.Android then
            if CSVersion.Version == "1.1.1" then
                -- 旧版本处理方法
                Utils():CreateDirectory(_path)
            else
                Utils.CreateDirectoryStatic(_path)
            end
        elseif Application.platform == RuntimePlatform.IPhonePlayer then
            if CSVersion.Version == "1.1.1" then
                -- 旧版本处理方法
                Utils():CreateDirectory(_path)
            else
                Utils.CreateDirectoryStatic(_path)
            end
        else
            os.execute("mkdir \"" .. _path.."\"")
        end
        local f2, err2 = io.open(Path, 'w')
        if f2 ~= nil then
            f2:write(string)
            f2:close()
        else
            print("创建失败".."mkdir " .. _path)
        end
    end
end

function LocalSaveManager:ClearAll()
    local _path = ctx.ResourcesPath.."/chatLog/"
    if Application.platform == RuntimePlatform.WindowsPlayer then
        -- os.remove (_path)
    elseif Application.platform == RuntimePlatform.Android then
        -- os.remove (_path)
    else
        -- os.remove (_path)
    end
end


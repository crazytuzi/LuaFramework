-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      新的边玩边下控制器，包含了下载模型和下载uI资源
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ResourcesLoadMgr = ResourcesLoadMgr or BaseClass()

local ccFileUtils = cc.FileUtils:getInstance() 

function ResourcesLoadMgr:getInstance()
    if not self.instance then
        self.instance = ResourcesLoadMgr.New()
    end
    return self.instance
end

--==============================--
--desc:初始化
--time:2018-04-23 11:56:29
--@return
--==============================--
function ResourcesLoadMgr:__init()
    self.res_info = {}                          -- 全部的下载列表
    self.resources_dir_list = {}                -- 以文件夹做key，储存当前文件夹内的所有资源
    self.download_list = {}                     -- 待下载列表
    self.error_list = {}                        -- 下载失败的路径
    self.callback_list = {}                     -- 针对ui资源的下载，这类的有下载回调的
    self.download_pro_num = 0
    self.is_startting = false                   -- 尚未开始下载
    self.resources_status_list = {}             -- 当前文件状态缓存,记录已经下载完成的或者已经在当前本地包中的正确资源
    self.is_in_download_list = {}               -- 正在下载队列中的资源
    self.in_add_task = true
    self.wait_downlist_dir_list = {}            -- 待下载的文件夹

    self.all_res_num = 0
    self.all_res_size = 0
    self.finish_num = 0
    self.finish_size = 0
    self.tag = ".shiraho"
    self.allow_print = false

    -- https://cdnres-sszg.shiyue.com 

    self.download_delay = 0.3
    if device.isWifiState() == false then
        self.download_delay = 0.5
    end

    if IS_REQUIRE_RES_GY then
        function OnFileDownloadRes(ret, outFileName)
            if ret ~= 0 then
            end
            self.last_down_status = ret
            self:printLog("========>download back path is", res, outFileName)
            self:onResourcesDownLoaded(outFileName)
            self.download_pro_num = self.download_pro_num - 1
        end

        function downloadProcess(nowsize, tmpfile)
        end
    end

    -- local res_path = "spine/E21012/action.png"
    -- message(string.format("%s  %s  %s", ccFileUtils:getFileSize(res_path), ccFileUtils:fullPathForFilename(res_path), ccFileUtils:isFileExist(res_path)))
end

--==============================--
--desc:校验所有资源
--time:2018-04-23 11:47:04
--@return
--==============================--
function ResourcesLoadMgr:downloadResAll()
    self.res_info = ALL_DOWNLOAD_RES_FILE[1]
    self.first_info_list = ALL_DOWNLOAD_RES_FILE[2]
    self:checkResoucesAll()
end

--==============================--
--desc:检测确实文件,这里判断如果这个文件带.shiraho后缀的话 直接删除掉吧.重新下载,这里有坑....
--time:2017-12-27 07:26:16
--@return
--==============================--
function ResourcesLoadMgr:checkResoucesAll()
    self.in_calc = true
    local index, once_num, sum_num = 1, 100
    local key_list = {}
    for k, v in pairs(self.res_info) do
        if v[3] ~= nil then
            if self.resources_dir_list[v[3]] == nil then
                self.resources_dir_list[v[3]] = {}
            end
            -- ['spine/H30003/show.png']={'spine/H30003/c5bef111e7510c1ce31f82ee1176ef0c.g',174890,'spine/H30003'},
            -- ['spine/H30003/show2.png']={'spine/H30003/6b27b009a8468bc75b1004d732c45892.g',104270,'spine/H30003'},
            -- 对所有资源按照文件夹重新归类
            table.insert(self.resources_dir_list[v[3]], {path = k, data = v})

            -- 登录的时候监测，如果该文件存在下载标识，直接删掉，如果文件存在，且大小异常，也直接删除掉
            local path_download = string.format("%s%s", k, self.tag)
            local to_name = string.format("res/%s", path_download)
            if ccFileUtils:isFileExist(path_download) == true then
                ccFileUtils:removeFile(string.format("%sassets/%s", ccFileUtils:getWritablePath(), to_name))
            elseif ccFileUtils:isFileExist(k) then
                local path_size = ccFileUtils:getFileSize(k)
                if path_size == 0 then
                    ccFileUtils:removeFile(string.format("%sassets/%s",ccFileUtils:getWritablePath(),string.format("res/%s", k)))
                end
            end
            table.insert(key_list, k)
        end
    end

    if next(key_list) then
        sum_num = #key_list
        GlobalTimeTicket:getInstance():add(function()
            for i = index, index + once_num - 1 do
                local path = key_list[i]
                local data = self.res_info[path]
                if data then
                    self:checkResouces(path)
                end
            end

            index = index + once_num
            if index >= sum_num then
                self.in_calc = false
                self.in_add_task = false
                self:downloadNext()
                GlobalEvent:getInstance():Fire(EventId.ON_SPINE_DOWNLOADED)
            end
        end, 2/display.DEFAULT_FPS, math.ceil(sum_num / once_num), "re_download_mgr_checkResoucesAll")
    end
end

--==============================--
--desc:监测资源是否存在，这里要做特殊处理，是不是UI资源，如果是UI资源，则有回调函数
--time:2018-04-23 12:24:17
--@resources_name:资源名称
--@is_priority:是否是优先下载的
--@callback:下载回调，这类的只针对优先下载资源处理，比如说打开窗体的uI需要资源
--@data:
--@return
--==============================--
function ResourcesLoadMgr:checkResouces(resources_name, is_priority, callback, data)
    if resources_name == nil or type(resources_name) ~= "string" then
        return
    end
    local img_dir = self:getDir(resources_name)
    if img_dir == "" then
        return
    end

    if self.download_list[img_dir] == nil then
        self.download_list[img_dir] = {}
        self:addDownloadList(img_dir)
    end

    -- 优先下载的不需要等进程，直接丢到里面去
    if is_priority == true then
        if callback ~= nil then
            self.callback_list[resources_name] = {callback = callback, data = data}
        end
        self:startDownloadFile(resources_name, true)
    end
end

--==============================--
--desc:资源下载完成，这里会做一堆判断比如说资源大小对不对等
--time:2017-12-27 07:46:56
--@outFileName:
--@return
--==============================--
function ResourcesLoadMgr:onResourcesDownLoaded(outFileName)
    local replace_str = string.format("%sassets/res/", ccFileUtils:getWritablePath())
    outFileName = string.sub(outFileName, string.len(replace_str) + 1)
    local file_size, delay_time, dir, status = 0, self.download_delay
    if string.find(outFileName, self.tag) then
        local resources_name = string.gsub(outFileName, self.tag, "")
        self.is_in_download_list[resources_name] = nil
        local args = Split(outFileName, "/")
        if #args == 0 then
            return
        end
        local old_name = args[#args]
        dir = self:getDir(outFileName)
        if dir and self.download_list[dir] then
            local real_name = string.gsub(old_name, self.tag, "")
            for _, info in pairs(self.download_list[dir]) do
                if info[3] == real_name then
                    status, file_size = self:checkResExist(info[1], nil, true)
                    info[2] = status
                    if status == "downloaded" then
                        self.resources_status_list[info[1]] = true -- 记录当前下载正确的资源，用于匹配优先下载
                        self.finish_num = self.finish_num + 1
                        self.finish_size = self.finish_size + file_size
                        if self:checkFinish(dir, info[1]) then
                            delay_time = self.download_delay * 2
                        end
                    end
                    break
                end
            end
        end
    end
    if string.find(dir, "spine") then  -- 只有是模型才需要把当前文件夹下面全部下载完成,否则不需要,按照优先下载去下
        self:downloadNext(dir)
    else
        self:downloadNext()
    end
end

--==============================--
--desc:
--time:2017-12-27 07:47:28
--@dir:
--@return
--==============================--
function ResourcesLoadMgr:downloadNext(dir)
    if self.in_add_task == true then
        return
    end -- 还在资源整理中
    if dir and self.download_list[dir] then
        for k, info in pairs(self.download_list[dir]) do
            if info[2] == "null" then
                self:startDownloadFile(info[1])
                return
            end
        end
    end

    -- 优先下载队列，只要当前没有需要下载的文件夹，就优先从有限下载队列中获取
    if self.first_info_list and next(self.first_info_list) ~= nil then
        local res_name = table.remove(self.first_info_list, 1) -- 从优先下载里面抽出一个来.这里可能有一个问题，已经下载完成，但是还没有重命名完成的时候，这个时候又监测了
        if not self.resources_status_list[res_name] then
            self:startDownloadFile(res_name, true)
            return
        end
    end

    -- 下载队列取出随意一个没有下载的资源
    if AUTO_DOWN_RES == true then
        for k, dir_res in pairs(self.download_list) do
            for k, info in pairs(dir_res) do
                if info[2] == "null" then
                    self:startDownloadFile(info[1])
                    return
                end
            end
        end
    end

    -- 这里表示暂时没有可下载的了。这时候关掉所有的线程
    self.is_startting = false
    cc.CCGameDownload:getInstance():stopThread()
end

--==============================--
--desc:开始下载路径，这里要做一个处理，如果是优先下载的，则不需要判断当前线程占用数，直接使用
--time:2018-04-23 07:44:17
--@path:
--@force:
--@return
--==============================--
function ResourcesLoadMgr:startDownloadFile(path, force)
    if self.resources_status_list[path] == true then
        return
    end

    if self.is_startting == false then
        cc.CCGameDownload:getInstance():startThread(RESOURCES_DOWNLOAD_PRO_MAX)
        self.is_startting = true
    end
    -- 如果边玩边下里面都没有这个资源直接跳出去吧
    if self.res_info[path] == nil then
        local temp_info = self.callback_list[path]
        if error_log_report and temp_info and temp_info.data then
            if CDN_ALL_RES_FILE == nil then
                CDN_ALL_RES_FILE = ""
            end
            local res_len = tableLen(self.res_info)  
            error_log_report(string.format("资源下载失败,主包内部不存在,cdn上面也不存在===============> 资源路径-%s, 资源类型-%s, 目标资源路径-%s, 下载缓存-%s, 总资源长度-%s, 堆栈-%s", temp_info.data.path, temp_info.data.type, path, CDN_ALL_RES_FILE, res_len, debug.traceback()))
        end 
        self:checkCallBack(path, true)
        return
    end

    -- 不是优先下载的，不直接丢去下载，这样保留2个线程用于下载优先的
    if force == true or self.download_pro_num <= RESOURCES_DOWNLOAD_PRO then
        if not IS_REQUIRE_RES_GY then
            return
        end
        if MAKELIFEBETTER or not GAME_INITED or self.in_add_task then
            return
        end
        -- 这里需要做一次判断，如果已经丢进去下载了，就不要再丢进去了
        if self.is_in_download_list[path] ~= nil then
            return
        end
        self.is_in_download_list[path] = path
        self.download_pro_num = self.download_pro_num + 1
        self.in_download = true
        local from_url = string.format("%s/%s", CDN_RES_GY_URL, self.res_info[path][1])
        local args = Split(path, "/")
        local replace_str = string.format("/%s", args[#args])
        local root_path = string.gsub(path, replace_str, "")
        local to_name = string.format("%sassets/res/%s%s", ccFileUtils:getWritablePath(), path, self.tag)
        local to_dir = string.format("%sassets/res/%s", ccFileUtils:getWritablePath(), root_path)
        self:mkdir(to_dir)
        self:printLog(string.format("==> download url---%s", from_url), to_name, to_dir)
        -- ccFileUtils:removeFile(string.format("%sassets/%s", ccFileUtils:getWritablePath(), to_name))
        ccFileUtils:removeFile(to_name)
        cc.CCGameDownload:getInstance():download(from_url, to_name, "OnFileDownloadRes")
    end
end

--==============================--
--desc:创建下载目录
--time:2018-04-23 08:10:31
--@path:
--@return
--==============================--
function ResourcesLoadMgr:mkdir(path)
    if not ccFileUtils:isDirectoryExist(path) then
        ccFileUtils:createDirectory(path)
    end
end

--==============================--
--desc:检验资源下载情况
--time:2018-04-23 02:13:18
--@path:
--@info:
--@isdownload:
--@return
--==============================--
function ResourcesLoadMgr:checkResExist(path, info, isdownload)
    info = info or self.res_info[path]
    local bool, status = false, "downloaded"
    local path_download = string.format("%s%s", path, self.tag)
    local to_name = string.format("res/%s", path_download)
    local path_size = 0
    bool = ccFileUtils:isFileExist(path_download)
    if bool then
        path_size = ccFileUtils:getFileSize(path_download)
        if path_size ~= info[2] or path_size == 0 then -- 如果下载回来的大小不对，直接删掉这个文件
            ccFileUtils:removeFile(string.format("%sassets/%s", ccFileUtils:getWritablePath(), to_name))
            self.error_list[path] = (self.error_list[path] or 0) + 1
            if self.error_list[path] < 3 then
                return "null", 0
            else
                if not resources_load_file_ then
                    resources_load_file_ = true
                    local from_url = string.format("%s/%s", CDN_RES_GY_URL, info[1])
                    if error_log_report then error_log_report(string.format("边玩边下下载失败,url:%s|status:%s|size:%s;%s:path:%s", from_url, self.last_down_status or -1, path_size, info[2],path_download)) end
                end
                return "error", 0
            end
        end
    end

    if bool == false then
        bool = ccFileUtils:isFileExist(path)
    elseif isdownload == true then
        status = "downloaded"
        path = path_download
    end

    if bool and ccFileUtils:isFileExist(path) then
        if isdownload == false or ccFileUtils:getFileSize(path) == info[2] then
            return status, info[2]
        else
            if path == path_download then
                ccFileUtils:removeFile(string.format("%sassets/%s", ccFileUtils:getWritablePath(), to_name))
            end
            self.error_list[path] = (self.error_list[path] or 0) + 1
            if self.error_list[path] < 3 then
                return "null", 0
            else
                if isdownload == true then -- 如果是下载回来的资源，并且都超过3次失败，也直接回调吧
                    self:checkCallBack(path, true)
                end
                if not resources_load_file_ then
                    resources_load_file_ = true
                    local from_url = string.format("%s/%s", CDN_RES_GY_URL, info[1])
                    if error_log_report then error_log_report(string.format("边玩边下下载失败2,url:%s|status:%s|size:%s;%s|path:%s", from_url, self.last_down_status or -1, ccFileUtils:getFileSize(path), info[2], path)) end
                end
                return "error", 0
            end
        end
    else
        return "null", 0
    end
end

--==============================--
--desc:检测资源是否下载完成,这里是检查整个目录是否下载完成的，所这里得需要改一下
--time:2017-07-14 02:16:10
--@dir_name:文件夹名字
--@file_name:文件名字，这个只在下载回调时候有，针对非spine类文件处理
--@return
--==============================--
function ResourcesLoadMgr:checkFinish(dir_name, file_name)
    if string.find(dir_name, "spine") then -- 如果是模型动作，则需要判断整个文件夹
        for k, info in pairs(self.download_list[dir_name]) do
            if info[2] ~= "downloaded" then
                return false
            end
        end
    end

    local _path = file_name or dir_name
    self:printLog(string.format("资源 [%s] 下载完毕", _path))
    if GlobalEvent then
        GlobalEvent:getInstance():Fire(EventId.ON_SPINE_DOWNLOADED)
    end
    if self.finish_size >= self.all_res_size then
        MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.download, true)
    end

    -- 重命名
    if file_name ~= nil and not string.find(dir_name, "spine") then
        self:printLog(string.format("重命名UI资源 [%s]", file_name))
        self:renameFile(file_name)
        _file_exist_list[file_name] = ccFileUtils:isFileExist(file_name)
        self:checkCallBack(file_name)
    else
        for k, info in pairs(self.download_list[dir_name]) do
            if info[2] == "downloaded" then
                self:printLog(string.format("重命名资源 [%s]", info[1]))
                self:renameFile(info[1])
                _file_exist_list[info[1]] = ccFileUtils:isFileExist(info[1])
            end
        end
    end
    return true
end

function ResourcesLoadMgr:checkCallBack(file_name, is_error)
    local data = self.callback_list[file_name]
    if data ~= nil then
        data.callback(data.data, is_error)
        self.callback_list[file_name] = nil -- 回调完了之后把回调函数清空
    end
end

--==============================--
--desc:对资源重命名
--time:2018-04-23 02:31:54
--@path:
--@return
--==============================--
function ResourcesLoadMgr:renameFile(path)
    local args = Split(path, "/")
    local replace_str = string.format("/%s", args[#args])
    local root_path = string.gsub(path, replace_str, "")

    local new_name = args[#args]
    local old_name = string.format("%s%s", new_name, self.tag)
    local root = string.format("%sassets/res/%s/", ccFileUtils:getWritablePath(), root_path)
    local new_path = string.format("%s%s", root, new_name)

    if ccFileUtils:isFileExist(new_path) then
        ccFileUtils:removeFile(new_path)
    end
    local ret = false
    ret = ccFileUtils:renameFile(root, old_name, new_name)
end

--==============================--
--desc:检查一个路径的完整性
--time:2018-04-23 02:09:51
--@path:
--@return
--==============================--
function ResourcesLoadMgr:checkDirFull(path)
    if not string.find(path, "spine") then
        return ccFileUtils:isFileExist(path)
    end
    local dir = self:getDir(path)
    if self.resources_dir_list[dir] == nil or next(self.resources_dir_list[dir]) == nil then
        return ccFileUtils:isFileExist(path)
    else
        for i, v in ipairs(self.resources_dir_list[dir]) do
            if v.path ~= nil then
                local path_size = ccFileUtils:getFileSize(v.path) 
                if path_size == 0 then 
                    return false
                end
            end
        end
        return true
    end
end

--==============================--
--desc:添加待下载资源
--time:2018-04-23 02:11:06
--@dir_name:
--@return
--==============================--
function ResourcesLoadMgr:addDownloadList(dir_name)
    local status, args, name
    local dir_list = self.resources_dir_list[dir_name]
    if dir_list ~= nil and next(dir_list) ~= nil then
        for i, v in ipairs(dir_list) do
            status = self:checkResExist(v.path, v.data, false)
            if status == "downloaded" then
                self.resources_status_list[v.path] = true
                self.finish_num = self.finish_num + 1
                self.finish_size = self.finish_size + (v.data[2] or 0)
            else
                args = Split(v.path, "/")
                name = args[#args]
                table.insert(self.download_list[dir_name], {v.path, status, name})
            end
            self.all_res_num = self.all_res_num + 1
            self.all_res_size = self.all_res_size + (v.data[2] or 0)
        end
    end

    if #self.download_list[dir_name] == 0 then
        self:checkFinish(dir_name)
    end
end

-- 获取当前下载数量
function ResourcesLoadMgr:getCurNum()
    return self.finish_size
end

-- 获取剩余数量
function ResourcesLoadMgr:getLeftNum()
    if self.in_calc then
        return 100000
    end
    return math.max(0, self.all_res_size - self.finish_size)
end

-- 获取剩余百分比
function ResourcesLoadMgr:getPercentage()
    if self.all_res_size == 0 then
        return 100
    else
        return 100 * self.finish_size / self.all_res_size
    end
end

-- 获取总的下载量
function ResourcesLoadMgr:getSumNum()
    if self.in_calc then
        return 1000000
    end
    return self.all_res_size
end

function ResourcesLoadMgr:printLog(...)
    if self.allow_print then
        local parmt = {...}
        print(unpack(parmt))
    end
end

--==============================--
--desc:根据资源路径获取资源文件路径
--time:2018-04-25 05:30:10
--@path:
--@return
--==============================--
function ResourcesLoadMgr:getDir(path)
    local img_dir = ""
    if path == nil then
        return img_dir
    end

    local resources_list = Split(path, "/")
    if resources_list == nil or next(resources_list) == nil then
        return img_dir
    end
    for i = 1, (#resources_list - 1) do
        if img_dir ~= "" then
            img_dir = img_dir .. "/"
        end
        img_dir = img_dir .. resources_list[i]
    end
    return img_dir
end

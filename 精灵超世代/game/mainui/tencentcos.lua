-- -----------------------------------
-- 腾讯云存储操作 COS
-- -----------------------------------
TencentCos = TencentCos or BaseClass(BaseController)

local ccfile = cc.FileUtils:getInstance()
function TencentCos:config()
    self.secretid = ""                                          -- 正式包这个服务端储存
    self.secretkey = ""                                         -- 正式包这个服务端储存
    self.url = "http://sszg-image-1256453865.picsh.myqcloud.com/"
    self.headUrl = "sszg_head/"

    self.had_init = false

    self.local_filetime_list = {}
    self.wait_download_list = {}   -- 待下载需要更新的连接

    self.is_in_download = false
    self.io_url_list = {}          -- 等待http下载的资源
end

-- 初始化存储桶
function TencentCos:initCos(secretid, secretkey)
    if not self.had_init then
        self.had_init = true
        self.secretid = secretid
        self.secretkey = secretkey
        PathTool.getPhotoPath()
        -- 本地缓存的时间戳
        self.local_filetime_list = SysEnv:getInstance():getTable(SysEnv.keys.custom_head_info)

        if CAN_USE_CAMERA then 
            -- 这里初始化的时候创建一下目录.
            callFunc("initUpload", self.secretid, 0, 0, self.secretkey)
        end
    end
end

function TencentCos:getSecretid()
    return self.secretid
end

-- 上传头像,
function TencentCos:upLoadHeadFile(res_id, localPath)
    if not CAN_USE_CAMERA then
        message(TI18N("请下载最新的安装包进行游戏体验,非常抱歉给你带来不好的游戏体验"))
    else
        if self.secretid == "" or self.secretkey == "" then
            message(TI18N("上传头像图片异常"))
        else
            -- 这边测试,先按照角色rid,和srv_id储存
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo == nil then return end
            local remote_path = string.format("%s%s.jpg", self.headUrl, res_id)
            callFunc("uploadImage", remote_path, 0, 0, localPath)
        end
    end
end

-- 删除存储桶里图片，用于从自定义设置会系统时候处理
function TencentCos:deleteHeadFile(free_res)
    local remote_path = string.format("%s%s.jpg", self.headUrl, free_res)
    callFunc("deleteImage", remote_path)
end

-- 下载头像成功之后的回调处理,这个时候可能之前存储的头像都没有了,cos下载回来存放的本地环境,有客户端自己决定
function TencentCos:downLoadHeadFileBack(path)
    path = PathTool.getHeadPath(path)
    local isFileExist = ccfile:isFileExist(path)
    if not isFileExist then return end

    -- 下载回来之后根据回调处理掉所有的缓存
    local func_list = self.wait_download_list[path]
    if func_list == nil or #func_list == 0 then return end
    -- 这个时候要先移除掉当前持有的内存数据
    display.removeImage(path)

    for i,handle_func in ipairs(func_list) do
        handle_func(path)
    end

    -- 写入一次本地缓存
    SysEnv:getInstance():set(SysEnv.keys.custom_head_info, self.local_filetime_list, true)
    self.wait_download_list[path] = nil
end

-- 使用http下载
function TencentCos:downLoadHeadFile(free_res, face_update_time, handle_func)
    if free_res == nil or free_res == "" or handle_func == nil then return end
    -- 文件在本地的完整路径
    local local_file = PathTool.getHeadPath(free_res)
    if self.wait_download_list and self.wait_download_list[local_file] ~= nil then --这种标识当前已经储存了,不要再处理了,直接储存回调
        table.insert(self.wait_download_list[local_file], handle_func)
    else
        -- 判断本地缓存的该自定义头像最后更新时间是否一直
        local donot_need_update = true
        local local_update_time = self.local_filetime_list[free_res] or 0
        if local_update_time < face_update_time then
            donot_need_update = false
            self.local_filetime_list[free_res] =  face_update_time
        end
        -- 如果本地存在,就不需要去下载了,并且最后更新时间是一致的
        if ccfile:isFileExist(local_file) and donot_need_update == true then
            handle_func(local_file)
        else
            -- 缓存回调
            if self.wait_download_list[local_file] == nil then
                self.wait_download_list[local_file] = {}
            end
            table.insert(self.wait_download_list[local_file], handle_func)
            -- 远程下载链接,开始下载
            local http_path = string.format("%s%s%s.jpg", self.url, self.headUrl, free_res)
            -- self:downloadImg(http_path, local_file)
            self:downloadImg(http_path, free_res)
        end
    end
end

-- 下载图片
function TencentCos:downloadImg(url, local_path)
    if self.is_in_download == true then
        table.insert(self.io_url_list, {url=url, local_path=local_path})
        return
    end
    self.is_in_download = true
    function OnFileDownloadResult(status, name)
        if status == 0 then
            self:downLoadHeadFileBack(local_path)
            delayOnce(function() 
                self.is_in_download = false
                if #self.io_url_list ~= 0 then
                    local url_object = table.remove(self.io_url_list, 1)
                    if url_object and url_object.url and url_object.local_path then
                        self:downloadImg(url_object.url, url_object.local_path)
                    end
                end
            end, 0.5)
        end
    end
    cc.FmodexManager:getInstance():downloadOtherFile(url, PathTool.getHeadSavePath(local_path))
end

--下载图片
-- function TencentCos:downloadImg(url, local_path)
--     if self.is_in_download == true then
--         table.insert(self.io_url_list, {url=url, local_path=local_path})
--         return
--     end
--     self.is_in_download = true
--     local xhr = cc.XMLHttpRequest:new()
--     xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
--     xhr:open("GET", url)
--     local function onReadyStateChanged()
--         self.is_in_download = false
--         if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
--             local response   = xhr.response
--             local strInfo = self:getStrData(response)
--             io.writefile(local_path, strInfo, "w+b")
--             delayOnce(function() 
--                 self:downLoadHeadFileBack(local_path)
--                 if #self.io_url_list ~= 0 then
--                     local url_object = table.remove(self.io_url_list, 1)
--                     if url_object and url_object.url and url_object.local_path then
--                         self:downloadImg(url_object.url, url_object.local_path)
--                     end
--                 end
--             end, 0.2)
--         end
--         xhr:unregisterScriptHandler()
--     end
--     xhr:registerScriptHandler(onReadyStateChanged)
--     xhr:send()
-- end

function TencentCos:getStrData(response)
    local totalSize = table.getn(response)
    local onePart = 1024*5
    local partData = ""
    local packTimes = math.floor(totalSize/onePart)
    for i=1,packTimes do
        local partUnPack = string.char(unpack(response,1+(i-1)*onePart , i*onePart) )
        partData = partData..partUnPack
    end
    local endUnpack = string.char(unpack(response , packTimes*onePart+1 , totalSize) )
    partData = partData..endUnpack
    return partData
end
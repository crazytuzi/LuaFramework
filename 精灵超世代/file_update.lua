local FileUpdate = class("FileUpdate")

function FileUpdate:ctor(configs)
    --add by chenbin:标记是否检测到新版本
    self.has_new_version = false
end

function FileUpdate:ver_load_start()
    -- 当主文件版本号变化的时候，
    local last_main_version = cc.UserDefault:getInstance():getIntegerForKey("lasted_main_version", 0)
    local current_version = cc.UserDefault:getInstance():getIntegerForKey("local_version", 0)
    if (last_main_version < BUILD_VERSION and current_version < NOW_VERSION) or __clear_ver_file then   --强更
    -- if last_main_version < BUILD_VERSION or __clear_ver_file then   --强更
        cc.UserDefault:getInstance():setIntegerForKey("lasted_main_version", BUILD_VERSION)
        cc.UserDefault:getInstance():setIntegerForKey("lasted_version", 0)
        cc.UserDefault:getInstance():setIntegerForKey("local_version", 0)
        cc.UserDefault:getInstance():setIntegerForKey("local_try_version", 0)
        cc.UserDefault:getInstance():flush()
        local path = string.format("%sassets/", cc.FileUtils:getInstance():getWritablePath())
        if cc.FileUtils:getInstance():isDirectoryExist(path) then
            cc.FileUtils:getInstance():removeDirectory(path)
        end
        path = string.format("%stryver/", cc.FileUtils:getInstance():getWritablePath())
        if cc.FileUtils:getInstance():isDirectoryExist(path) then
            cc.FileUtils:getInstance():removeDirectory(path)
        end
        path = string.format("%svoice/", cc.FileUtils:getInstance():getWritablePath())
        if cc.FileUtils:getInstance():isDirectoryExist(path) then
            cc.FileUtils:getInstance():removeDirectory(path)
        end
        local scene = cc.Scene:create()
        if cc.Director:getInstance():getRunningScene() then
            cc.Director:getInstance():replaceScene(scene)
        else
            cc.Director:getInstance():runWithScene(scene)
        end
        scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
            self:check_new_version()
        end)))
    else
        -- 走这里
        self:check_new_version()
    end
end

function FileUpdate:check_new_version()
    local function startCheck()
        -- 未定义
        if NEED_CALL_SDK_INIT then sdkCallFunc("sdkInit") end
        if not WAIT_SDK_INIT_SUC then
            --print("走这里 initConfig")
            self:initConfig()
        end
    end
     self:initUpdateScene(startCheck)
end

function FileUpdate:initUpdateScene(delay_func)
    require "util.pathtool"                     -- 路径的获取方法
    require "util.util"                         -- 通用工具转换方法
    require "game.login.view.version_view"      -- 版本界面
    require "game.login.view.login_fill_view"   -- 适配窗体
    require "common.common_function"            -- 公共函数
    require "common.common_define"              -- 公共常量
    require "base.baseclass"
    require "config.loading_desc_data"          -- 加载时候的描述文字
    require "util.cocos_tool"

    -- 创建创景节点
    local update_scene = cc.Scene:create()
    -- 因为存在可能是切换账号的时候,这时候要先替换scene,然后移除不需要的资源
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(update_scene)
        cc.SkeletonCache:getInstance():disposeAllCache()
        display.removeUnusedSpriteFrames()
        display.removeUnusedTextures()
    else
        cc.Director:getInstance():runWithScene(update_scene)
    end
    self.update_scene = update_scene

    -- 显示层的父节点
    local layout = ccui.Layout:create()
    local size = cc.size(SCREEN_WIDTH,SCREEN_HEIGHT)
    layout:setContentSize(size)
    layout:setPosition(display.center)
    layout:setAnchorPoint(cc.p(0.5, 0.5))
    update_scene:addChild(layout)
    showLayoutRect(layout, 255)

    -- 闪屏页
    if self:checkIsShowVedio() then
        -- 走这里
        self:showFirstVedio(layout, update_scene, delay_func)
    else
        self:showFirstPage(false, layout, update_scene, delay_func)
    end
end

function FileUpdate:checkIsShowVedio()
    if NEED_PLAY_FLASHVIDEO == true then
        return true
    end
    return false
end

-- 启动闪屏视频
function FileUpdate:showFirstVedio(layout, update_scene, callback)
    -- 删掉更新的视频,因为部分手机无法使用扩展路径里面的 所以可以直接干掉
    local assets_res = cc.FileUtils:getInstance():getWritablePath().."assets/res/resource/login/logo.mp4"
    if cc.FileUtils:getInstance():isFileExist(assets_res) then
        cc.FileUtils:getInstance():removeFile(assets_res)
    end

    --modified by chenbin
    if true then
        self:showFirstPage(false, layout, update_scene, callback)
        return
    end
    ----

    local base_res = "resource/login/logo.mp4"
    if not cc.FileUtils:getInstance():isFileExist(base_res) or ccexp.VideoPlayer == nil then
        -- print("走这里")
        self:showFirstPage(false, layout, update_scene, callback)
    else
        local function onVideoEventCallback(sender, eventType)
            if eventType == ccexp.VideoPlayerEvent.COMPLETED then
                sender:stop()
                sender:runAction(cc.RemoveSelf:create(true))
                self:showFirstPage(true, layout, update_scene, callback)
            end
        end
        local videoPlayer = ccexp.VideoPlayer:create()
        videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
        videoPlayer:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
        videoPlayer:setFullScreenEnabled(true)
        videoPlayer:setPosition(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
        videoPlayer:addEventListener(onVideoEventCallback)
        videoPlayer:setFileName(base_res)
        videoPlayer:play()
        layout:addChild(videoPlayer,998)
    end
end

-- 启动闪屏页
function FileUpdate:showFirstPage(force, layout, update_scene, callback)
    -- 加载页
    --modified by chenbin
    -- local cur_loading_png = PathTool.getLoadingRes()
    local cur_loading_png = ""
    if device.platform == "ios" or IS_APP_STORE_ENROLL then
        -- 审核专用图，开启热更时 IS_APP_STORE_ENROLL 还未定义
        -- 因此iOS必须用专用的图，后续热更此图
        cur_loading_png = "res/resource/login/login_bg_default_ios.png"
    else
        cur_loading_png = "res/resource/login/login_bg_default.png"
    end
    local bg = createSprite(cur_loading_png, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5, layout, cc.p(0.5,0.5), LOADTEXT_TYPE)
    bg:setScale(display.getMaxScale())

    -- 特殊处理--4.4
    if needMourning() then
        setChildUnEnabled(true, bg, cc.c4b(0xff,0xff,0xff,0xff))
    end

    -- 适配左右遮挡层
    local fill_view = FillView.new()
    fill_view:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layout:addChild(fill_view, 10)

    -- 加载进度以及版本号更新提示
    local version = VersionView.new()
    version:setPosition(SCREEN_WIDTH*0.5, display.getBottom(layout))
    version:setAnchorPoint(cc.p(0.5,0))
    layout:addChild(version, 1)
    update_scene.version_view = version

    -- 调用反馈
    callback()
end

-- 初始化配置,特殊渠道会在初始化sdk成功之后才回调初始配置
function FileUpdate:initConfig()
    if self.update_scene == nil then return end
    self.net_manager = cc.SmartSocket:getInstance()
    self.net_manager:Start() -- 不知道为什么域名解析需要调用一次这个

    local package_ver = cc.GameDevice:callFunc("package_version",'',0,0,'')
    self.update_scene.version_view:setVersionTips(TI18N("连接服务器进入游戏中..."))

    -- 前面已经加载本地的url_config，初始化了URL_PATH
    if URL_PATH then
        self:downLoadFinishFunc()
    else
        print("前往cdn下载url_config")
        self:down_load_url_by_fmodex(package_ver)
    end
end

-- 使用FmodexManager 下载 url_config
function FileUpdate:down_load_url_by_fmodex(package_ver)
    local url = string.format("%s?build_ver=%d&package_ver=%s&%d", URL_LUA_CONFIG, BUILD_VERSION, package_ver, os.time())
    function OnFileDownloadResult(status, name)
        print("OnFileDownloadResult__",status, name, cc.FileUtils:getInstance():getWritablePath())
        local filename = string.format("%sassets/src/%s", cc.FileUtils:getInstance():getWritablePath(), name)
        local file = assert(io.open(filename, "r"))
        local str = file:read("*all")
        file:close()
        local load_ok, load_msg = pcall(function() loadstring(str or "")() end)
        if load_ok and URL_PATH_ALL then
            --modified by chenbin:加载cdn上的url_config之后根据iOS提审状态设置搜索路径
            if IS_APP_STORE_ENROLL then
                setupSearchPaths()
                self:doRequireLSFiles_enroll()
            end
            URL_PATH = URL_PATH_ALL.get(PLATFORM_NAME)
            self:downLoadFinishFunc()
        else
            self.update_scene.version_view:setVersionTips(string.format(TI18N("连接服务器失败...[%s]"), status))
            self.update_scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(function()
                cc.FmodexManager:getInstance():downloadOtherFile(string.format("%s?build_ver=%d&package_ver=%s&%d", URL_LUA_CONFIG, BUILD_VERSION, package_ver, os.time()), "url_config.txt")
            end)))
            url_config_down_error = (url_config_down_error or 0) + 1
            if url_config_down_error == 10 then
                if error_log_report then error_log_report(string.format("下载url_config.lua失败,url:%s|status:%s", URL_LUA_CONFIG, status), filename) end
            end
        end
    end
    print("down_load_url_by_fmodex", url, "url_config.txt")
    cc.FmodexManager:getInstance():downloadOtherFile(url, "url_config.txt")
end

-- 下载url_config完成之后的处理
function FileUpdate:downLoadFinishFunc()
    if not log_advice then print("not log_advice") require('cli_log') end
    --if log_advice then print("fffffffffffffff") log_advice() end

    -- 特殊情况特殊处理
    if DIRECTTOONLOGIN == true then
        sdkOnLogin()
    else
        self:realDownLoadFinishFunc()
    end
end

function FileUpdate:realDownLoadFinishFunc()
    local is_win_mac = PLATFORM == cc.PLATFORM_OS_WINDOWS or PLATFORM == cc.PLATFORM_OS_MAC
    if is_win_mac then
        local ok, msg = pcall(function() require("../web_func") end)
        if ok == true then
            -- 走这里（没做任何事）
            if webFunc_urlConfigEnd then
                webFunc_urlConfigEnd()
            end
        end
    end
    if UPDATE_SKIP then
        self:update_finish()
        return
    end
    --modified by chenbin:web_func不再需要
    -- self:down_web_func()
    self:update_version()
end

-- 插更内容处理
function FileUpdate:down_web_func()
    local web_func_url = nil
    if cc.UserDefault:getInstance():getBoolForKey("is_enter_try_srv") then
        web_func_url = TRY_WEB_FUNC_FILE
    else
        web_func_url = WEB_FUNC_FILE
    end
    if web_func_url == nil then
        self:update_version()
        return
    end
    web_func_url = string.format("%s/inc_ver/web_func/%s.g", URL_PATH.update, web_func_url)

    function OnFileDownloadResult(status, name)
        local filename = string.format("%sassets/src/%s", cc.FileUtils:getInstance():getWritablePath(), name)
        local file = assert(io.open(filename, "r"))
        local str = file:read("*all")
        file:close()
        local load_ok, load_msg = pcall(function() loadstring(str or "")() end)
        if load_ok and webFunc_GameStart then
            if webFunc_urlConfigEnd then
                webFunc_urlConfigEnd()
            end
            self:update_version()
        else
            self.update_scene.version_view:setVersionTips(string.format(TI18N("连接服务器失败[%s]"), status))
            self.update_scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(function()
                cc.FmodexManager:getInstance():downloadOtherFile(web_func_url, "web_func.txt")
            end)))
            web_func_down_error = (web_func_down_error or 0) + 1
            if web_func_down_error == 10 then
                if error_log_report then error_log_report(string.format("下载web_func.lua失败,url:%s|status:%s", web_func_url, status), filename) end
            end
        end
    end
    self.update_scene.version_view:setVersionTips(TI18N("初始化依赖数据..."))
    print("down_web_func", web_func_url, "web_func.txt")
    cc.FmodexManager:getInstance():downloadOtherFile(web_func_url, "web_func.txt")
end

function FileUpdate:update_version()
    VER_UPDATE_ERR_NUM = 0
    if VER_MAINTAIN_MSG then -- 版本维护中
    elseif self:merge_version() then
        self:update_net_version()
    end
end

-- 合并版本
function FileUpdate:merge_version()
    local tryver = cc.UserDefault:getInstance():getIntegerForKey("local_try_version", 0)
    local ver = cc.UserDefault:getInstance():getIntegerForKey("local_version", 0)
    if ver >= tryver or not UPDATE_VERSION_MAX or tryver > UPDATE_VERSION_MAX or ver >= UPDATE_VERSION_MAX then
        return true
    end
    local file = cc.FileUtils:getInstance():getWritablePath().."tryver/assets/src/all_res_file.luac"
    local ALL_RES_FILE
    if cc.FileUtils:getInstance():isFileExist(file) then
        ALL_RES_FILE = dofile(file)
        if type(ALL_RES_FILE) ~= "table" then
        end
    end
    ALL_RES_FILE = ALL_RES_FILE or require "all_res_file"
    local all_file_num = #ALL_RES_FILE
    self.update_scene:scheduleUpdateWithPriorityLua(function(dt)
        local num1, num2 = 0, 0
        while(next(ALL_RES_FILE)) do
            if num1 > 50 or num2 > 5 then break end
            num1 = num1 + 1
            local file_name = table.remove(ALL_RES_FILE)
            local sfile = cc.FileUtils:getInstance():getWritablePath().."tryver/assets/"..file_name
            if cc.FileUtils:getInstance():isFileExist(sfile) then
                num2 = num2 + 1
                local tfile = cc.FileUtils:getInstance():getWritablePath().."assets/"..file_name
                local tpath = string.match(tfile, "(.+)/[^/]*$")
                cc.FileUtils:getInstance():createDirectory(tpath)
                cc.FileUtils:getInstance():renameFile(sfile, tfile)
            end
        end
        if not next(ALL_RES_FILE) then
            self.update_scene:unscheduleUpdate()
            self.update_scene.version_view:update(0, TI18N("(不消耗流量)版本合并中..."))
            cc.UserDefault:getInstance():setIntegerForKey("lasted_version", tryver)
            cc.UserDefault:getInstance():setIntegerForKey("local_version", tryver)
            cc.UserDefault:getInstance():flush()
            self:update_net_version()
        else
            self.update_scene.version_view:update(math.ceil(100 - #ALL_RES_FILE*100/all_file_num), TI18N("(不消耗流量)版本合并中..."))
        end
    end, 0)
    return false
end

function FileUpdate:get_version_info()
    -- 优先判断是否进入稳定服
    if cc.UserDefault:getInstance():getBoolForKey("is_enter_try_srv") then
        local current_version = cc.UserDefault:getInstance():getIntegerForKey("local_try_version", 0)
        local current_version1 = cc.UserDefault:getInstance():getIntegerForKey("local_version", 0)
        current_version = math.max(current_version, current_version1)
        return math.max(current_version, NOW_VERSION), UPDATE_TRY_VERSION_MAX or UPDATE_VERSION_MAX, true
    else
        local current_version = cc.UserDefault:getInstance():getIntegerForKey("local_version", 0)
        return math.max(current_version, NOW_VERSION), UPDATE_VERSION_MAX, false
    end
end

--==============================--
--desc:更新版本
--time:2017-11-29 11:07:23
--@return
--==============================--
function FileUpdate:update_net_version()
    local now_version = self:get_version_info()
    local min_zip_name = string.format("%s_min_%s", now_version, BUILD_VERSION)
    if UPDATE_MODE_BY_INC and not (VerPath and VerPath[min_zip_name]) then -- 没有使用小包情况 如果使用小包 第一次更新不能使用增量方式
        self:update_net_version_by_inc()
    else
        self:update_net_version_by_zip()
    end
end

--==============================--
--desc:使用压缩包方式更新版本
--time:2017-11-29 11:07:33
--@return
--==============================--
function FileUpdate:update_net_version_by_zip()
    print("FileUpdate:update_net_version_by_zip")

    local lasted_version = cc.UserDefault:getInstance():getIntegerForKey("laster_version", 0)
    if lasted_version ~= 0 then
        cc.UserDefault:getInstance():setIntegerForKey("local_version", lasted_version)
    end
    local base_version = cc.UserDefault:getInstance():getIntegerForKey("local_version")
    base_version = math.max(base_version, NOW_VERSION)
    cc.UserDefault:getInstance():setIntegerForKey("lasted_version", base_version)
    cc.UserDefault:getInstance():flush()

    local update_http_url = string.format("%s/zip/assets/", URL_PATH.update)
    
    --commited by chenbin
    --cdn上version.txt 所有平台可以使用同一个，且值可以一直为1，因为使用AssetsManager下载更新包前，会清空本地version值
    local update_version_url = string.format("%s/version.txt?ts=%s", URL_PATH.update, os.time())
    local current_version, target_version = self:get_version_info()

    local function onTargetVersion(version)
        local target_ver = tonumber(version)
        if target_ver then
            local sum, zip_name, min_zip_name = 0
            for i = current_version+1, target_ver do
                min_zip_name = string.format("%s_min_%s", i, BUILD_VERSION)
                zip_name = string.format("%s", i)
                -- 如果存在小包
                if VerPath and VerPath[min_zip_name] then
                    sum = sum + VerPath[min_zip_name].size
                elseif VerPath and VerPath[zip_name] then
                    sum = sum + VerPath[zip_name].size
                end
            end
            -- 目标版本大于当前版本,需要下载处理
            if target_ver > current_version then
                AUTO_SHOW_NOTICE = true --自动弹出更新公告
                self.has_new_version = true
                self:update_version_to(target_ver, current_version+1, target_ver-current_version, now_ver, update_version_url, update_http_url)
            else
                self:update_finish()
            end
        end
    end

    onTargetVersion(target_version)
end

--==============================--
--desc:使用增量方式更新版本
--time:2017-11-29 11:07:52
--@return
--==============================--
function FileUpdate:update_net_version_by_inc()
    local now_version, target_version, is_enter_try = self:get_version_info()
    if now_version >= target_version then -- 当前版本大于等于目标版本 不需要更新
        return self:update_finish()
    end
    AUTO_SHOW_NOTICE = true             --自动弹出更新公告
    inc_ver_download_list = {}          -- 未下载需要下截的文件
    inc_ver_download_all = {}           -- 所有需更新文件信息
    inc_ver_download_size = 0           -- 累计需下载大小
    inc_ver_downloading_files = {}      -- 正在下载
    inc_ver_download_num = 0            -- 累计需下截文件数量
    inc_ver_download_finish_size = 0    -- 累计已下载大小
    inc_ver_download_finish_num = 0     -- 累计已下载文件数量
    inc_ver_download_pro_num = 0        -- 当前下截进程数量
    inc_ver_download_speed = 0          -- 下载速度
    inc_ver_diff_temp_files = {}        -- 临时比对文件列表
    inc_ver_download_pro_max = INC_VER_DOWNLOAD_PRO_MAX or 1        -- 最大下载进程数量
    local tmp_path = cc.FileUtils:getInstance():getWritablePath() -- 增量版本预存下载文件目录 确保全部下载完成后再合并到正式目录
    local has_min_pack = (now_version == NOW_VERSION and min_inc_pack_name)
    local finish_func = function()
        inc_ver_diff_temp_files = nil
        if inc_ver_download_num == 0 then
            self:update_version_by_inc_merge() -- 没有需要下截的了，直接合并处理
        else
            self:update_version_by_inc_download_init()
        end
    end
    local check_first_min_pack = function() -- 检查首次需要下载的小包信息
        if has_min_pack then
            self:update_version_by_inc_diff(tmp_path, now_version, min_inc_pack_name, true, finish_func)
        else
            finish_func()
        end
    end
    if has_min_pack then -- 存在小包需要下载
        now_version = now_version + 1
        if now_version >= target_version then
            check_first_min_pack()
            return
        end
    end
    self:update_version_by_inc_diff(tmp_path, now_version, target_version, false, function()
        if is_enter_try and target_version > UPDATE_VERSION_MAX and UPDATE_VERSION_MAX > now_version then
            inc_ver_diff_temp_files = {} -- 临时比对文件列表
            self:update_version_by_inc_diff(tmp_path, now_version, UPDATE_VERSION_MAX, false, check_first_min_pack)
        else
            check_first_min_pack()
        end
    end)
end

function FileUpdate:update_version_by_inc_diff(tmp_path, now_ver, target_dir, is_min, callback)
    local inc_ver_url = string.format("%s/inc_ver/%s/inc_ver.lua", URL_PATH.update, target_dir)
    local inc_ver_md5_url = inc_ver_url
    if INC_VER_MD5_FILE == true then -- 使用md5缓存文件
        local md5_url = cc.CCGameLib:getInstance():md5str(string.match(URL_PATH.update, "update_[^/]+") .. "_inc_ver_" .. target_dir)
        inc_ver_md5_url = string.format("%s/inc_ver/%s/inc_ver_%s_%s.g", URL_PATH.update, target_dir, target_dir, md5_url)
    end
    function OnFileDownloadResult(status, name)
        if pcall(function() INC_VER_LIST = require("inc_ver") end) and INC_VER_LIST then
            for k, v in pairs(INC_VER_LIST) do
                if is_min then -- 小包资源
                    if inc_ver_diff_temp_files[k] == nil then
                        local file = string.format("inc_ver/%s/%s", target_dir, k)
                        local fullpath = string.format("%s/%s", tmp_path, file)
                        v.path = k
                        if cc.FileUtils:getInstance():isFileExist(fullpath) and cc.FileUtils:getInstance():getFileSize(fullpath) == v.size then -- 之前下载过了 不需要重新下截
                            v.status = 1
                        elseif inc_ver_download_all[file] == nil then
                            inc_ver_download_size = inc_ver_download_size + v.size
                            inc_ver_download_num = inc_ver_download_num + 1
                            table.insert(inc_ver_download_list, file)
                        end
                        inc_ver_download_all[file] = v
                    end
                elseif v.ver > now_ver then -- 该文件发生过变化，需要下载
                    inc_ver_diff_temp_files[k] = v
                    local file = string.format("inc_ver/%s/%s", v.ver, k)
                    local fullpath = string.format("%s/%s", tmp_path, file)
                    v.path = k
                    if cc.FileUtils:getInstance():isFileExist(fullpath) and cc.FileUtils:getInstance():getFileSize(fullpath) == v.size then -- 之前下载过了 不需要重新下截
                        v.status = 1
                    elseif inc_ver_download_all[file] == nil then
                        inc_ver_download_size = inc_ver_download_size + v.size
                        inc_ver_download_num = inc_ver_download_num + 1
                        table.insert(inc_ver_download_list, file)
                    end
                    inc_ver_download_all[file] = v
                end
            end
            package.loaded['inc_ver'] = nil
            INC_VER_LIST = nil
            VER_UPDATE_ERR_NUM = 0
            callback()
        else -- 下载失败 继续尝试
            self.update_scene.version_view:setVersionTips(string.format(TI18N("下载版本信息数据...[%s]"), status))
            VER_UPDATE_ERR_NUM = VER_UPDATE_ERR_NUM + 1
            if VER_UPDATE_ERR_NUM >= (VER_UPDATE_ERR_MAX or 50) then
                sdkAlert(string.format(TI18N("多次尝试下载文件失败，是否继续尝试(%s)？"), status), TI18N("确认"), function()
                    VER_UPDATE_ERR_NUM = 0
                    cc.FmodexManager:getInstance():downloadOtherFile(string.format("%s?%d", inc_ver_url, os.time()), "inc_ver.lua")
                end, "取消", sdkOnExit)
                local filepath = string.format("%sassets/src/inc_ver.lua", cc.FileUtils:getInstance():getWritablePath())
                if error_log_report then error_log_report(string.format("下载inc_ver.lua失败,url:%s|status:%s", inc_ver_url, status), filepath) end
            else
                self.update_scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
                    cc.FmodexManager:getInstance():downloadOtherFile(string.format("%s?%d", inc_ver_url, os.time()), "inc_ver.lua")
                end)))
            end
        end
    end
    cc.FileUtils:getInstance():removeFile(string.format("%sassets/src/inc_ver.lua", cc.FileUtils:getInstance():getWritablePath()))
    if INC_VER_MD5_FILE == true then -- 使用md5缓存文件
        cc.FmodexManager:getInstance():downloadOtherFile(inc_ver_md5_url, "inc_ver.lua")
    else
        cc.FmodexManager:getInstance():downloadOtherFile(string.format("%s?%s", inc_ver_url, os.time()), "inc_ver.lua")
    end
    self.update_scene.version_view:setVersionTips(TI18N("下载版本信息数据..."))
end

function FileUpdate:update_version_by_inc_download_init()
    local all_size_kb = inc_ver_download_size * 0.8 / 1024
    local all_size_mb = all_size_kb / 1024
    cc.CCGameDownload:getInstance():startThread(inc_ver_download_pro_max)
    inc_ver_download_pro_max = inc_ver_download_pro_max * 2
    local start_time = os.clock()
    inc_ver_download_start_time = os.time()
    local num = 0
    local writapath = cc.FileUtils:getInstance():getWritablePath() -- 增量版本预存下载文件目录 确保全部下载完成后再合并到正式目录
    self.update_scene:scheduleUpdateWithPriorityLua(function(dt)
        num = num + 1
        if num >= 30 then
            num = 0
            local ts = os.clock()
            local speed = inc_ver_download_speed / (ts - start_time) * 0.8 / 1024
            local mb_speed = ""
            if speed > 1024 then    -- 到mb
                mb_speed = string.format("%.2f", speed / 1024)
            end
            local now_all_size = inc_ver_download_finish_size
            for k, v in pairs(inc_ver_downloading_files) do
                now_all_size = now_all_size + v.now_size
            end
            local now_all_size_mb = now_all_size * 0.8 / 1024 / 1024
            local version_desc = nil
            if mb_speed ~= "" then
               version_desc = string.format(TI18N("资源下载中...[%sMB/s, %0.2fMB/%.2fMB]"), mb_speed, now_all_size_mb, all_size_mb)
            else
               version_desc = string.format(TI18N("资源下载中...[%.2fKB/s, %0.2fMB/%.2fMB]"), speed, now_all_size_mb, all_size_mb)
            end
            local per = math.max(0, math.floor(now_all_size * 100 / inc_ver_download_size))
            self.update_scene.version_view:update(per, version_desc)
            start_time = ts
            inc_ver_download_speed = 0
        end
    end, 0)
    self.update_scene.version_view:setVersionTips(TI18N("资源下载中..."))
    function downloadProcess(nowsize, tmpfile)
        if not inc_ver_downloading_files then return end
        local dfile = inc_ver_downloading_files[tmpfile]
        if dfile and dfile.now_size ~= nowsize then
            inc_ver_download_speed = inc_ver_download_speed + nowsize - dfile.now_size
            dfile.now_size = nowsize
        end
    end
    function OnDownloadIncVer(status, tmpfile)
        if not inc_ver_downloading_files then return end
        local dfile = inc_ver_downloading_files[tmpfile]
        if not dfile then return end
        local url = dfile.url
        local file = dfile.file
        local finfo = inc_ver_download_all[file]
        local fullpath = string.format("%s%s", writapath, tmpfile)
        if cc.FileUtils:getInstance():isFileExist(fullpath) and cc.FileUtils:getInstance():getFileSize(fullpath) == finfo.size then -- 下载完成
            inc_ver_download_pro_num = inc_ver_download_pro_num - 1
            inc_ver_downloading_files[tmpfile] = nil
            local new_path = string.format("%s%s", writapath, file)
            cc.FileUtils:getInstance():renameFile(fullpath, new_path)
            inc_ver_download_finish_num = inc_ver_download_finish_num + 1
            inc_ver_download_finish_size = inc_ver_download_finish_size + finfo.size
            finfo.status = 1
            VER_UPDATE_ERR_NUM = 0
            self:update_version_by_inc_download()
        else -- 下载失败 继续尝试
            VER_UPDATE_ERR_NUM = VER_UPDATE_ERR_NUM + 1
            dfile.now_size = 0
            if VER_UPDATE_ERR_NUM >= (VER_UPDATE_ERR_MAX or 50) then
                inc_ver_download_pro_num = inc_ver_download_pro_num - 1
                if show_alert_ui then return end
                if inc_ver_download_pro_num > 0 then return end
                show_alert_ui = true
                sdkAlert(string.format(TI18N("多次尝试下载文件失败，是否继续尝试(%s)？"), status), TI18N("确认"), function()
                    show_alert_ui = nil
                    VER_UPDATE_ERR_NUM = 0
                    cc.CCGameDownload:getInstance():download(string.format("%s?%s", url, os.time()), tmpfile, "OnDownloadIncVer")
                end, "取消", sdkOnExit)
                if error_log_report then error_log_report(string.format("下载失败,url:%s|status:%s|size:%s,%s", url, status, cc.FileUtils:getInstance():getFileSize(fullpath), finfo.size), fullpath) end
            else
                self.update_scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
                    cc.CCGameDownload:getInstance():download(string.format("%s", url), tmpfile, "OnDownloadIncVer")
                end)))
            end
        end
    end
    self:update_version_by_inc_download()
end

function FileUpdate:update_version_by_inc_download()
    if inc_ver_download_num <= inc_ver_download_finish_num then -- 下载完成了
        self.update_scene:unscheduleUpdate()
        cc.CCGameDownload:getInstance():stopThread()
        local use_time = os.time() - inc_ver_download_start_time
        self:update_version_by_inc_merge()
        return
    end
    if not next(inc_ver_download_list) and inc_ver_download_pro_num == 0 then
        for file, v in pairs(inc_ver_download_all) do
            if v.status ~= 1 then
                table.insert(inc_ver_download_list, file)
            end
        end
    end
    if inc_ver_download_pro_num >= inc_ver_download_pro_max or not next(inc_ver_download_list) then return end -- 下载进程达上限
    inc_ver_download_pro_num = inc_ver_download_pro_num + 1
    local file = table.remove(inc_ver_download_list)
    local finfo = inc_ver_download_all[file]
    local tmppath = string.match(file, "(.+)/[^/]*%.%w+$")
    local tmpfile = string.format("%s/%s.g", tmppath, finfo.file)
    local url = string.format("%s/%s", URL_PATH.update, tmpfile)
    local writapath = cc.FileUtils:getInstance():getWritablePath() -- 增量版本预存下载文件目录 确保全部下载完成后再合并到正式目录
    tmpfile = string.format("%s.g", file)
    inc_ver_downloading_files[tmpfile] = {file = file, now_size = 0, url = url}
    cc.FileUtils:getInstance():createDirectory(string.format("%s%s", writapath, tmppath))
	cc.CCGameDownload:getInstance():download(string.format("%s", url), tmpfile, "OnDownloadIncVer")
    self:update_version_by_inc_download()
end

function FileUpdate:update_version_by_inc_merge()
    all_merge_list = {}
    local all_file_num = 0
    for k, v in pairs(inc_ver_download_all) do
        table.insert(all_merge_list, {ver=v.ver, sfile = k, path=v.path})
        all_file_num = all_file_num + 1
    end
    table.sort(all_merge_list, function(a,b) return a.ver > b.ver end)
    inc_ver_download_list = nil -- 未下载需要下截的文件
    inc_ver_download_all = nil  -- 所有需更新文件信息
    inc_ver_downloading_files = nil -- 正在下载
    local now_version, target_version, is_enter_try = self:get_version_info()
    local save_path = cc.FileUtils:getInstance():getWritablePath()
    self.update_scene:scheduleUpdateWithPriorityLua(function(dt)
        local num = 0
        while(next(all_merge_list)) do
            if num > 10 then break end
            num = num + 1
            local finfo = table.remove(all_merge_list)
            local spath = save_path..finfo.sfile
            local tpath = string.format("%sassets/%s", save_path, finfo.path)
            if finfo.ver > UPDATE_VERSION_MAX then -- 超过正式服版本 放到体验服版本中
                tpath = string.format("%stryver/assets/%s", save_path, finfo.path)
            end
            cc.FileUtils:getInstance():createDirectory(string.match(tpath, "(.*)/[^/]*$"))
            cc.FileUtils:getInstance():renameFile(spath, tpath)
        end
        if not next(all_merge_list) then -- 合并处理完成
            self.update_scene:unscheduleUpdate()
            self.update_scene.version_view:update(100, TI18N("版本下载完成，更新替换中..."))
            cc.UserDefault:getInstance():setIntegerForKey("local_try_version", target_version)
            cc.UserDefault:getInstance():setIntegerForKey("lasted_version", math.min(UPDATE_VERSION_MAX, target_version))
            cc.UserDefault:getInstance():setIntegerForKey("local_version", math.min(UPDATE_VERSION_MAX, target_version))
            cc.UserDefault:getInstance():flush()
            cc.FileUtils:getInstance():removeDirectory(string.format("%sinc_ver", save_path))
            self:update_finish()
        else
            self.update_scene.version_view:update(math.ceil(100 - #all_merge_list*100/all_file_num), TI18N("版本下载完成，更新替换中..."))
        end
    end, 0)
end
--尝试下载一个更新zip包
function FileUpdate:update_version_to(target_ver, current_ver, diff_ver, now_ver, update_version_url, update_http_url)
    print("FileUpdate:update_version_to", target_ver, current_ver)
    if current_ver > UPDATE_VERSION_MAX then
        self:update_try_version_to(target_ver, current_ver, diff_ver, now_ver, update_version_url, update_http_url)
        return
    end
    local min_zip_name = string.format("%s_min_%s", current_ver, BUILD_VERSION)
    if min_inc_pack_name then
        min_zip_name = string.format("%s_%s", current_ver, min_inc_pack_name)
    end
    local zip_name = string.format("%s", current_ver)
    local add_ver,url_path_full = 1
    local to_next_ver = current_ver

    --modified by chenbin:目前只使用这种方式update
    if VerPath and VerPath[zip_name] and VerPath[zip_name].name then
        print("update path:", VerPath[zip_name].name)
        if VerPath.skip then
            self:update_version_to(target_ver, current_ver+1, diff_ver, now_ver, update_version_url, update_http_url)
            return
        end
        zip_name = VerPath[zip_name].name
        url_path_full = string.format("%s%s.zip",update_http_url,zip_name)
    else
        print("Error:update can't find zip:", update_http_url, zip_name)
    end
--[[
    if CDN_PATH_BASE and VerPath and VerPath[min_zip_name] and VerPath[min_zip_name].name then
        zip_name = VerPath[min_zip_name].name
        url_path_full = string.format("%s%s.zip", CDN_PATH_BASE, zip_name)
    elseif CDN_PATH_BASE and VER_UPDATE_ERR_NUM < 3 and VerMergePath and VerMergePath[zip_name] and VerMergePath[zip_name].name and VerMergePath[zip_name].addver and VerMergePath[zip_name].tover and VerMergePath[zip_name].tover <= UPDATE_VERSION_MAX then
        add_ver = math.max(VerMergePath[zip_name].addver, add_ver)
        to_next_ver = current_ver + add_ver - 1
        zip_name = VerMergePath[zip_name].name
        url_path_full = string.format("%s%s.zip", CDN_PATH_BASE, zip_name)
    elseif CDN_PATH_BASE and VerPath and VerPath[zip_name] and VerPath[zip_name].name then
        if VerPath.skip then
            self:update_version_to(target_ver, current_ver+1, diff_ver, now_ver, update_version_url, update_http_url)
            return
        end
        zip_name = VerPath[zip_name].name
        url_path_full = string.format("%s%s.zip",update_http_url,zip_name)
    else
        url_path_full = string.format("%s%s.zip", update_http_url, zip_name)
    end
]]

    local save_path = cc.FileUtils:getInstance():getWritablePath()
    if not cc.FileUtils:getInstance():isDirectoryExist(save_path) then
        cc.FileUtils:getInstance():createDirectory(save_path)
    end
    if DOWNLOADING_VER == true then return end
    DOWNLOADING_VER = true

    local ver_base2 = getVersionDesc()
    now_ver = diff_ver - (target_ver - current_ver)
    local version_desc = string.format(TI18N("更新总进度:%s/%s,目标版本:%s.%s"),now_ver, diff_ver, ver_base2, target_ver)
    self.update_scene.version_view:setVersionTips(version_desc)

    local onProgress = function(percent)
        local per = math.floor(percent*(1/(diff_ver or 1)) + (now_ver-1)/(diff_ver or 1) * 100)
        self.update_scene.version_view:update(math.max(0,per), version_desc)
    end

    local onError = function(errorCode)
        DOWNLOADING_VER = false
        if not tolua.isnull(asset_mgr) and asset_mgr:getReferenceCount() > 1 then
            asset_mgr:release()
        end
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            self:update_finish()
        else
            VER_UPDATE_ERR_NUM = VER_UPDATE_ERR_NUM + 1
            -- 可以添加bugly统计
            local path = string.format("%svoice/", cc.FileUtils:getInstance():getWritablePath())
            if cc.FileUtils:getInstance():isDirectoryExist(path) then
                cc.FileUtils:getInstance():removeDirectory(path)
            end
            if VER_UPDATE_ERR_NUM > 30 then
                 self.update_scene.version_view:setVersionTips(string.format(TI18N("下载版本包[%s]失败:[%s][%s],请检查网络/存储空间是否不足"), current_ver, errorCode, VER_UPDATE_ERR_NUM))
                return
            elseif VER_UPDATE_ERR_NUM > 2 then
                 self.update_scene.version_view:setVersionTips(string.format(TI18N("下载版本包[%s]失败:[%s][%s],请检查存储空间是否不足"), current_ver, errorCode, VER_UPDATE_ERR_NUM))
            else
                 self.update_scene.version_view:setVersionTips(string.format(TI18N("下载版本包[%s]失败:[%s]"), current_version, errorCode))
            end
            delayOnce(function()
                self:update_version_to(target_ver, current_ver, diff_ver, now_ver, update_version_url, update_http_url)
            end, 1)
        end
    end

    local onSuccess = function()
        DOWNLOADING_VER = nil
        cc.UserDefault:getInstance():setIntegerForKey("lasted_version", to_next_ver)
        cc.UserDefault:getInstance():setIntegerForKey("local_version", to_next_ver)
        local tryver = cc.UserDefault:getInstance():getIntegerForKey("local_try_version", 0)
        cc.UserDefault:getInstance():setIntegerForKey("local_try_version", math.max(to_next_ver, tryver))
        cc.UserDefault:getInstance():flush()
        if not tolua.isnull(asset_mgr) and asset_mgr:getReferenceCount() > 1 then
            asset_mgr:release()
        end
        VER_UPDATE_ERR_NUM = 0
        if not downVerZipSuccess or downVerZipSuccess(current_ver, target_ver) then
            self:update_version_to(target_ver, current_ver+add_ver, diff_ver, now_ver, update_version_url, update_http_url)
        end
    end

    --commited by chenbin
    --仅使用AssetsManager下载url_path_full，不参与版本管理，下载前清空AssetsManager本地version
    local asset_mgr = cc.AssetsManager:new(url_path_full, update_version_url, save_path)
    asset_mgr:deleteVersion()
    asset_mgr:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR)
    asset_mgr:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    asset_mgr:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS)
    asset_mgr:retain()
    asset_mgr:setConnectionTimeout(10)
    asset_mgr:update()
end

function FileUpdate:ver2num(ver)
    -- local ver1 = math.floor(MAIN_VERSION / 100)
    -- local ver2 = math.floor((MAIN_VERSION - ver1 * 100) / 10)
    -- return string.format("%s.%s", ver1, ver2), ver
end


function FileUpdate:update_try_version_to(target_ver, current_ver, diff_ver, now_ver, update_version_url, update_http_url)
    if current_ver > target_ver then
        self:update_finish()
        return
    end
    local min_zip_name = string.format("%s_min_%s", current_ver, BUILD_VERSION)
    local zip_name = string.format("%s", current_ver)
    local add_ver, url_path_full = 1
    local to_next_ver = current_ver
    if CDN_PATH_BASE and VerPath and VerPath[min_zip_name] and VerPath[min_zip_name].name then
        zip_name = VerPath[min_zip_name].name
        url_path_full = string.format("%s%s.zip", CDN_PATH_BASE, zip_name)
    elseif CDN_PATH_BASE and VER_UPDATE_ERR_NUM < 3 and VerMergePath and VerMergePath[zip_name] and VerMergePath[zip_name].name and VerMergePath[zip_name].addver and VerMergePath[zip_name].tover and VerMergePath[zip_name].tover <= target_ver then
        add_ver = math.max(VerMergePath[zip_name].addver,add_ver)
        to_next_ver = current_ver + add_ver - 1
        zip_name = VerMergePath[zip_name].name
        url_path_full = string.format("%s%s.zip", CDN_PATH_BASE, zip_name)
    elseif VER_UPDATE_ERR_NUM_USE_OTHER and VER_UPDATE_ERR_NUM > VER_UPDATE_ERR_NUM_USE_OTHER then
        url_path_full = string.format("%s%s.zip", update_http_url, zip_name)
    elseif CDN_PATH_BASE and VerPath and VerPath[zip_name] and VerPath[zip_name].name then
        if VerPath.skip then
            self:update_try_version_to(target_ver, current_ver, diff_ver, now_ver, update_version_url, update_http_url)
            return
        end
        zip_name = VerPath[zip_name].name
        url_path_full = string.format("%s%s.zip", CDN_PATH_BASE, zip_name)
    else
        url_path_full = string.format("%s%s.zip", update_http_url, zip_name)
    end

    local save_path = cc.FileUtils:getInstance():getWritablePath().."tryver/"
    if not cc.FileUtils:getInstance():isDirectoryExist(save_path) then
        cc.FileUtils:getInstance():createDirectory(save_path)
    end

    if DOWNLOADING_VER == true then return end
    DOWNLOADING_VER = false

    local ver_base2 = getVersionDesc()
    now_ver = diff_ver - (target_ver - current_ver)
    local version_desc = string.format(TI18N("更新总进度:%s/%s,目标版本:%s.%s"),now_ver, diff_ver, ver_base2, target_ver)
    self.update_scene.version_view:setVersionTips(version_desc)

    -- 更新加载进度条
    local function  onProgress(percent)
        local per = math.floor(percent*(1/(diff_ver or 1)) + (now_ver-1)/(diff_ver or 1)*100)
         self.update_scene.version_view:update(math.max(0,per), version_desc)
    end

    -- 加载失败判定,如果超过30次,则不在更新
    local function onError(errorCode)
        DOWNLOADING_VER = nil
        if not tolua.isnull(asset_mgr) and asset_mgr:getReferenceCount() > 1 then
            asset_mgr:release()
        end
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            self:update_finish()
        else
            VER_UPDATE_ERR_NUM = VER_UPDATE_ERR_NUM + 1
            -- 这里可以预留bugly处理
            local path = string.format("%svoice/",cc.FileUtils:getInstance():getWritablePath())
            if cc.FileUtils:getInstance():isDirectoryExist(path) then
                cc.FileUtils:getInstance():removeDirectory(path)
            end
            if VER_UPDATE_ERR_NUM > 30 then -- 防止无限下载
                 self.update_scene.version_view:setVersionTips(string.format(TI18N("下载版本包[%s]失败:[%s][%s],请检查网络/存储空间是否不足"), current_version, errorCode, VER_UPDATE_ERR_NUM))
                return
            elseif VER_UPDATE_ERR_NUM > 2 then
                 self.update_scene.version_view:setVersionTips(string.format(TI18N("下载版本包[%s]失败:[%s][%s],请检查存储空间是否不足"), current_version, errorCode, VER_UPDATE_ERR_NUM))
            else
                 self.update_scene.version_view:setVersionTips(string.format(TI18N("下载版本包[%s]失败:[%s]"), current_version, errorCode))
            end
            delayOnce(function()
                self:update_try_version_to(target_ver, current_ver, diff_ver, now_ver, update_version_url, update_http_url)
            end, 1)
        end
    end

    local function onSuccess()
        DOWNLOADING_VER = nil
        cc.UserDefault:getInstance():setIntegerForKey("local_try_version", to_next_ver)
        cc.UserDefault:getInstance():flush()
        if not tolua.isnull(asset_mgr) and asset_mgr:getReferenceCount() > 1 then
            asset_mgr:release()
        end
        VER_UPDATE_ERR_NUM = 0
        if not downVerZipSuccess or downVerZipSuccess(current_ver, target_ver) then
            self:update_try_version_to(target_ver, current_ver + add_ver, diff_ver, now_ver, update_version_url, update_http_url)
        end
    end

    local asset_mgr = cc.AssetsManager:new(url_path_full, update_version_url, save_path)
    asset_mgr:deleteVersion()
    asset_mgr:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
    asset_mgr:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    asset_mgr:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
    asset_mgr:retain()
    asset_mgr:setConnectionTimeout(10)
    asset_mgr:update()
end

--重新require多语言文件
function FileUpdate:doRequireLSFiles()
    cc.LocalizedString:destroyInstance()
    
    local lanCode = cc.Application:getInstance():getCurrentLanguageCode()
    local srcLS = string.format("config.auto_config_%s.localizedStringOutput_src@localizedStringOutput_src", lanCode)
    package.loaded[srcLS] = nil
    require(srcLS)
end

function FileUpdate:doRequireLSFiles_enroll()
    cc.LocalizedString:destroyInstance()
    local lanCode = cc.Application:getInstance():getCurrentLanguageCode()

    local srcLS_real = string.format("config.auto_config_%s.localizedStringOutput_src@localizedStringOutput_src", lanCode)
    package.loaded[srcLS_real] = nil
    Config["LocalizedstringoutputSrc"] = nil

    local srcLS = string.format("config.auto_config_%s.%s_localizedStringOutput_src@localizedStringOutput_src", lanCode, lanCode)
    package.loaded[srcLS] = nil
    require(srcLS)
end

-- 版本更新完成
function FileUpdate:update_finish()
    print("FileUpdate:update_finish")
    --if log_loading_start then log_loading_start() end
    for k,v in pairs(package.loaded) do --释放之前加载的模块
        package.loaded[k] = nil
    end

    cc.FileUtils:getInstance():purgeCachedEntries()     -- 清掉我们的缓存路径
    require "config.config"
    require "sys.module_include"

    --add by chenbin: 重新require多语言文件
    if self.has_new_version then
        self:doRequireLSFiles()
        self.has_new_version = false
    end

    for k,v in pairs(GameConfig) do
        table.insert(GameModule, v)
    end
    local plist_list = deepCopy(PLIST_LIST)

    local all_file_num = #GameModule + #plist_list
    local downplisting = false
    -- 这里有变化,需要把初始化需要加载的pvr.ccz也加载进去,后续增加,这类的pvr.ccz主要是通用窗体,以及物品列表
    local start_time = os.clock()
    local isWin = PLATFORM == cc.PLATFORM_OS_WINDOWS or PLATFORM == cc.PLATFORM_OS_MAC
    local function finish_callback()
         --print("走这里 finish_callback")
        if #GameModule > 0 or #plist_list > 0 then return end
        self.update_scene.version_view:setTips(TI18N("初始化..."))
        local num = self:initInstance()
    end
    local function plist_callback(dataFilename, imageFilename) -- 加载一个plist完成
        downplisting = false
        ResourcesCacheMgr:getInstance():increaseReferenceCount(imageFilename, ResourcesType.plist)  -- 这几个资源优先存放到里面去
    end

    local function loadLuaFile(dt)
        -- 每次加载4个
        local num = 10
        for i=1,math.min(num, #GameModule) do
            local file_name = table.remove(GameModule, 1)
            local load_ok, load_msg = pcall(function()
                require(file_name)
            end)
            -- game.chat.chat_help 加载失败（已修改）
            -- print(file_name, load_ok)
            if not load_ok then
                print("Error:loading Failed with file->", file_name)
                print(load_msg)
                if DEBUG or isWin then
                    self.update_scene:unscheduleUpdate()
                    break
                end
            end
        end
        if #GameModule == 0 then
            if #plist_list == 0 and downplisting == false then -- 这种表示全部加载完全
                self.update_scene:unscheduleUpdate()

                if self.time_ticket then
                    GlobalTimeTicket:getInstance():remove(self.time_ticket)
                    self.time_ticket = nil
                end
                finish_callback()
            else
                -- 如果还没有加载返回,不加载,等待中
                if downplisting == false then
                    if self.time_ticket then
                        GlobalTimeTicket:getInstance():remove(self.time_ticket)
                        self.time_ticket = nil
                    end

                    local plist_file = table.remove(plist_list, 1)
                    local plist = string.format("%s.plist", plist_file)
                    local prvCcz = string.format("%s.png", plist_file)

                    if not cc.FileUtils:getInstance():isFileExist(plist) or not cc.FileUtils:getInstance():isFileExist(prvCcz) then
                        downplisting = false
                        if DEBUG or isWin then
                            self.update_scene:unscheduleUpdate()
                        end
                    else
                        downplisting = true
                        display.loadSpriteFrames(plist, prvCcz, plist_callback)

                        -- 这里做一个超时,如果2秒没返回,就修改
                        self.time_ticket = GlobalTimeTicket:getInstance():add(function()
                            downplisting = false
                        end, 2, 1)
                    end
                end
            end
        end
        self.update_scene.version_view:update(math.ceil(95 - (#GameModule+#plist_list)*95/all_file_num), TI18N("初始化数据中..."))
    end

    local function su(dt)
        loadLuaFile(dt)
    end
    self.update_scene:scheduleUpdateWithPriorityLua(su, 0)
end

-- 处理游戏实例化单项
function FileUpdate:initInstance()
    if webFunc_initInstanceStart then webFunc_initInstanceStart() end
    if self.net_manager then
        self.net_manager:Stop()
        self.net_manager:DeleteMe()
        self.net_manager = nil
    end
    local num = 0
    local time_1 = os.clock()
    local _g_num = 0
    local list = {}
    for key, ctrl in pairs(_G) do
        _g_num = _g_num + 1
        if type(ctrl) == "table"  and ctrl["getInstance"]  and string.find(key, "Base") == nil
            and string.find(key, "GlobalKeybordEvent") == nil
            and string.find(key, "GlobalTimeTicket") == nil then
            table.insert(list, {ctrl=ctrl, key=key})
            num = num + 1
        end
    end
    local function instance_finish()
        if webFunc_initInstanceEnd then webFunc_initInstanceEnd() end
        local ok, msg = pcall(function() require("game_start") end)
        if ok == true then
            if log_loading_end then log_loading_end() end
            beginGame()
        end
    end

    local list_len = #list
    self.update_scene:scheduleUpdateWithPriorityLua(function(dt)
        if #list == 0 then -- 加载完成后下一帧再调出登录界面
            self.update_scene:unscheduleUpdate()
            instance_finish()
        end
        local one_time = 4
        for i=1,math.min(one_time, #list) do
            local obj = table.remove(list, 1)
            local ctrl = obj.ctrl
            ctrl["getInstance"](ctrl)
        end
        self.update_scene.version_view:update(math.ceil(100 - (#list)*5/list_len), TI18N("连接服务器进入游戏中..."))
    end, 0)
    return num
end

return FileUpdate

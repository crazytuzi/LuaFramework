-- --------------------------------------------------------------------
-- 游戏主入口
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

function beginGame()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(ViewManager:getInstance():getMainScene())
    else
        cc.Director:getInstance():runWithScene(ViewManager:getInstance():getMainScene())
    end
    -- 创建一个适配窗体在这里
    LoginController:getInstance():createFillView()
    LoginController:getInstance():openView(LoginController.type.user_input) -- 打开输入面板
    GAME_INITED = true
    _is_game_restart = false
    if webFunc_GameStart then webFunc_GameStart() end -- 网络动态函数调用 
    
    -- 提审服就不需要下载边玩边下了
    if not MAKELIFEBETTER and IS_REQUIRE_RES_GY == true then
        if NEW_CDN_RES_GY == true then -- 新版本边玩边下
            doCdnResFileDownload()
        else
            function OnFileDownloadResult(state, name)
                if pcall(function() ALL_DOWNLOAD_RES_FILE = require("allres") end) then
                    if ALL_DOWNLOAD_RES_FILE then
                        ResourcesLoadMgr:getInstance():downloadResAll()
                    end
                end
            end
            cc.FmodexManager:getInstance():downloadOtherFile(string.format("%s/allres.lua?%s", CDN_RES_GY_URL, os.time()), "allres.lua")
        end
    end
end

-- 下载边玩边下文件信息
function doCdnResFileDownload()
    if SAVE_RES_FILE_LOCAL then
        -- if pcall(function() ALL_DOWNLOAD_RES_FILE = require("allres") end) then
        if pcall(function() ALL_DOWNLOAD_RES_FILE = require("localallres") end) then
            if ALL_DOWNLOAD_RES_FILE and type(ALL_DOWNLOAD_RES_FILE) == "table" and #ALL_DOWNLOAD_RES_FILE > 1 then -- 本地有文件 不再重新下载
                game_print("边玩边下信息文件已存在本地，直接启动下载")
                ResourcesLoadMgr:getInstance():downloadResAll()
                return
            end
        end
    end
    game_print("开始下载边玩边下文件allres_file.lua")
    VER_UPDATE_ERR_NUM = 0
    function OnFileDownloadResult(state, name)
        local err_retry = function()
            VER_UPDATE_ERR_NUM = VER_UPDATE_ERR_NUM + 1
            if VER_UPDATE_ERR_NUM < 10 then
                cc.FmodexManager:getInstance():downloadOtherFile(string.format("%s/allres_file.lua?%s", CDN_RES_GY_URL, os.time()), "allres_file.lua")
            end
        end
        xpcall(function() 
            package.loaded["allres_file"] = nil
            CDN_ALL_RES_FILE = require("allres_file") 
            if CDN_ALL_RES_FILE and CDN_ALL_RES_FILE ~= "" then
                doCdnResDownload()
            else
                err_retry()
            end
        end, err_retry)
    end
    cc.FmodexManager:getInstance():downloadOtherFile(string.format("%s/allres_file.lua?%s", CDN_RES_GY_URL, os.time()), "allres_file.lua")
end

function doCdnResDownload()
    VER_UPDATE_ERR_NUM = 0
    game_print("开始下载边玩边下信息文件")
    function OnFileDownloadResult(state, name)
        package.loaded["allres"] = nil
        local err_retry = function()
            VER_UPDATE_ERR_NUM = VER_UPDATE_ERR_NUM + 1
            if VER_UPDATE_ERR_NUM < 10 then
                cc.FmodexManager:getInstance():downloadOtherFile(string.format("%s/%s", CDN_RES_GY_URL, CDN_ALL_RES_FILE), "allres.lua")
            end
        end
        xpcall(function() 
            ALL_DOWNLOAD_RES_FILE = require("allres") 
            if ALL_DOWNLOAD_RES_FILE and type(ALL_DOWNLOAD_RES_FILE) == "table" and #ALL_DOWNLOAD_RES_FILE > 1 then --
                game_print("启动下载边玩边下处理")
                ResourcesLoadMgr:getInstance():downloadResAll()
            else
                err_retry()
            end
        end, err_retry)
    end
    cc.FmodexManager:getInstance():downloadOtherFile(string.format("%s/%s", CDN_RES_GY_URL, CDN_ALL_RES_FILE), "allres.lua")
end

--==============================--
--desc:切换到后台
--time:2018-07-26 12:24:11
--@return 
--==============================--
function OnEnterBackground()
    __enter_background_ts__ = os.time()
    if BattleController then
        BattleController:getInstance():csEnterBackGround(true)
    end
end

--==============================--
--desc:从后台切换到前台
--time:2018-07-26 12:24:18
--@return 
--==============================--
function OnEnterForeground()
    if BattleController then
        BattleController:getInstance():csEnterBackGround(false)
    end
    if __enter_background_ts__ then
        local time_diff = math.max(0, os.time() - __enter_background_ts__)
        if time_diff > 3600 then 
            sdkOnSwitchAccount()
        end
        __enter_background_ts__ = nil
    end
end

function restart(callback)
    AudioManager:getInstance():DeleteMe()
    BattleController:getInstance():DeleteMe()
    LoginController:getInstance():DeleteMe()
    MainSceneController:getInstance():DeleteMe()
    MainuiController:getInstance():DeleteMe()
    RenderMgr:getInstance():stop()
    GlobalTimeTicket:getInstance():stop()
    GameNet:getInstance():DeleteMe()
    ViewManager:getInstance():DeleteMe()
    GlobalEvent:getInstance():UnBindAll() 

    -- 移除掉当前本地持有的图集
    ResourcesCacheMgr:getInstance():cleanAllTexture()
    for key, v in pairs(package.loaded) do              -- 释放之前的一些加载模块
        package.loaded[key] = nil
    end
    local base = _G["base"]
    for k, v in pairs(_G) do                            -- 清除所有全局变量
        if k ~= "base" and k ~= "_G" then 
            if type(v) ~= "function" then
                if type(k) == "string" and (string.find(k, "print")) then
                else
                    if not base[k] then 
                        if type(v) == "table" and not v.__index then
                            if v.is_base or k == "Config" then 
                                _G[k] = nil 
                            else
                                freeConfig(_G, k)
                            end
                        else
                            _G[k] = nil 
                        end
                    end
                end
            end
        end
    end
    clearSuperClass()       -- 清除父类虚表，这个坑啊
    collectgarbage("collect")
    _is_game_restart = true
    if type(callback) == 'function' then callback() end

    local status, msg = xpcall(main, __G__TRACKBACK__)
    if not status then

    end
end

function uploadFile(realname, name, time)
    local path = PathTool.getVoicePath(realname)
    local str = readBinaryFile(path)
    if type(str) ~= "string" or string.len(str) < 1000 then
        cc.FileUtils:getInstance():removeFile(path)
        GlobalEvent:getInstance():Fire(EventId.ON_VOICE_UPLOAD_RESULT, {false, filename, string.len(str)})
    else
        if AUDIO_RECORD_TYPE == 10 then
            if callSpeexEncode() ~= 0 then -- 压缩语音文件
                return
            end
            str = readBinaryFile(PathTool.getVoicePath(AUDIO_WAV_FILE_ENCODE_OUT))
        end
        ChatController:getInstance():sender12725(name, str, time)
    end
end

function freeConfig(parent, key)
    if type(parent[key]) == "table" then 
        for k, v in pairs(parent[key]) do 
            freeConfig(parent[key], k)
        end
    end    
    parent[key] = nil
end

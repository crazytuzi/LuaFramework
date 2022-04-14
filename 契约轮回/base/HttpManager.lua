--
-- Author: LaoY
-- Date: 2018-07-12 10:04:31
--

HttpManager = HttpManager or class("HttpManager", BaseManager)

StreamAssetPath = Util.DataPath

local HttpManager = HttpManager
local string_format = string.format
-- local json = require "json"


local cacheStreamAssetState = {
    ["logo.png"] = true,
}
local cacheStreamAssetList = {

}

function HttpManager:ctor()
    HttpManager.Instance = self
end

function HttpManager:dctor()
end

function HttpManager:GetInstance()
    if not HttpManager.Instance then
        HttpManager()
    end
    return HttpManager.Instance
end

-- 读取包里的资源
function HttpManager:LoadABImageByCallBack(abName, assetName, call_back)
    print2(abName);
    --判断是否在下载列表
    --直接拿CDN地址下载
    --luaresManager:IsInDownLoadList(abName)--//abName == StreamingAssets/后的
    --self:AddDownLoadList(cls, abName, call_back, load_level)
    --HttpManager:GetInstance():LoadABImageByCallBack("icon_big_bg_loading.unity3d", "loading", call_back)
    print2("渠道号" .. tostring(PlatformManager:GetInstance():GetChannelID()));
    local url = StreamAssetPath .. "asset/" .. tostring(PlatformManager:GetInstance():GetChannelID()) .. "/" .. abName;
    print2(url);
    local is_exists = io.exists(url)

    if not is_exists then
        url = StreamAssetPath .. "asset/" .. abName;
    else
        if not url:find("file:///") then
            url = "file:///" .. url
        end
    end
    print2("二次" .. url);
    is_exists = io.exists(url)
    print2(is_exists);
    if not is_exists then
        url = Util.AppContentPath() .. "asset/" .. abName;
    else
        if not url:find("file:///") then
            url = "file:///" .. url
        end
    end
    print2("最后的URL : " .. url);
    self:LoadABTexture(url, assetName, call_back)
end


-- 暂时没用
function HttpManager:LoadSteamAssetImageByCallBackD(fileName, call_back)
    local function callback(texture)
        if not texture or tostring(texture) == "null" then
            if call_back then
                call_back(nil)
            end
            return
        end
        vec2 = vec2 or Vector2(0.5, 0.5)
        local sprite = UnityEngine.Sprite.Create(texture, UnityEngine.Rect(0, 0, texture.width, texture.height), vec2)
        if call_back then
            call_back(sprite)
        end
    end
    local url = fileName

    --local is_exists = io.exists(url)
    --if not is_exists then
    --    url = Util.AppContentPath() .. "image/" .. fileName
    --else
    --    if not url:find("file:///") then
    --        url = "file:///" .. url
    --    end
    --end
    --DebugLog('--LaoY HttpManager.lua,line 55--',is_exists,url)

    self:LoadTexture(url, callback)
end

--[[
    @author LaoY
    @des    读取包里的资源
            注意注意 call_back 的传参必须要要销毁
                sprite
                texture
--]]
function HttpManager:LoadSteamAssetImageByCallBack(fileName, call_back)
    local function callback(texture)
        if not texture or tostring(texture) == "null" then
            if call_back then
                call_back(nil)
            end
            return
        end
        vec2 = vec2 or Vector2(0.5, 0.5)
        local sprite = UnityEngine.Sprite.Create(texture, UnityEngine.Rect(0, 0, texture.width, texture.height), vec2)
        if call_back then
            call_back(sprite,texture)
        end
    end
    local url = StreamAssetPath .. "image/" .. fileName
    
    local pathPrefix = "file:///"
    if PlatformManager:GetInstance():IsIos() then
        pathPrefix = "file://"
    end
    
    local is_exists = io.exists(url)
    DebugLog('--LaoY HttpManager.lua,line 111--', is_exists, url)

    if not is_exists then
        url = Util.AppContentPath() .. "image/" .. fileName
    else
        if PlatformManager:GetInstance():IsAndroid() then
            if not url:find(pathPrefix) then
                url = pathPrefix .. url
            end
        end
    end
    
    if PlatformManager:GetInstance():IsIos() then
        if not url:find(pathPrefix) then
            url = pathPrefix .. url
        end
    end
    
    DebugLog('--LaoY HttpManager.lua,line 222--', is_exists, url)

    self:LoadTexture(url, callback)
end

--[[
	@author LaoY
	@des	
	@param1 out_time 			超时时间
	@param2 out_time_count 		超时次数
--]]
function HttpManager:ResponseGetText(url, call_back, out_time, out_time_count)
    out_time = out_time or 2
    out_time_count = out_time_count or 8
    local co
    local count = 1
    local time_id
    local stopTime
    local function func()
        local www = WWW(url)
        coroutine.www(www, co)
        if #www.text > 0 then
            if call_back then
                call_back(www.text)
            end
            stopTime()
        end
        co = nil
    end

    stopTime = function()
        if time_id then
            GlobalSchedule:Stop(time_id)
            time_id = nil
        end
    end
    local function step()
        if not co then
            co = coroutine.start(func)
            count = count + 1
            if count > out_time_count then
                logError('--HttpManager:ResponseGet Http链接 超时--', url)
                stopTime()
            end
        end
    end
    time_id = GlobalSchedule:Start(step, out_time)
    co = coroutine.start(func)
    step()
end

--function HttpManager:HttpGetRequest(url, call_back)
--	local function callback(text)
--		DebugLog("Response Http Get Notice:" .. Time.realtimeSinceStartup)
--		local t = json.decode(text)
--		if call_back then
--			call_back(t)
--		end
--	end
--	SceneSwitch.Instance:AddHttpGetReq(url, callback)
--end

function HttpManager:ResponseGet(url, call_back, out_time, out_time_count)
    local function callback(text)
        DebugLog("Response WWW Get Notice: " .. Time.realtimeSinceStartup)
        local t = json.decode(text)
        if call_back then
            call_back(t)
        end
    end
    self:ResponseGetText(url, callback, out_time, out_time_count)
end

--[[
    @author LaoY
    @des    注意注意 call_back 的传参必须要要销毁
                sprite
                texture
--]]
function HttpManager:LoadSprite(url, vec2, call_back)
    local function callback(texture)
        if not texture or tostring(texture) == "null" then
            if call_back then
                call_back(nil)
            end
            return
        end
        vec2 = vec2 or Vector2(0.5, 0.5)
        local sprite = UnityEngine.Sprite.Create(texture, UnityEngine.Rect(0, 0, texture.width, texture.height), vec2)
        if call_back then
            call_back(sprite,texture)
        end
    end
    
    local pathPrefix = "file:///"
    
    if PlatformManager:GetInstance():IsIos() then
        pathPrefix = "file://"
    end
    
    if not url:find(pathPrefix) then
        url = pathPrefix .. url
    end
    Yzprint('--LaoY HttpManager.lua,line 106--', url)
    self:LoadTexture(url, callback)
end

function HttpManager:LoadTexture(url, call_back)
    local co
    local function func()
        local www = WWW(url)
        coroutine.www(www, co)
        if call_back then
            local error = www.error
            if error and #error > 0 then
                call_back(nil)
            else
                call_back(www.texture)
            end
        end

        www:Dispose()
        www = nil
    end
    co = coroutine.start(func)
end
function HttpManager:LoadABTexture(url, assetName, call_back)
    local co
    local function func()
        local www = WWW(url)
        coroutine.www(www, co)
        if call_back then
            local error = www.error
            if error and #error > 0 then
                call_back(nil)
            else
                local ab = www.assetBundle;
                local sprite = ab:LoadAsset(assetName, typeof(UnityEngine.Sprite))
                call_back(sprite);
                ab:Unload(false);
                www:Dispose();
            end
        end
    end
    co = coroutine.start(func)
end

-- local form = WWWForm()
-- form:AddField("uid",1)
-- form:AddField("platform","xwtest")
-- httpMgr:ResponsePost(url,call_back,form)
-- public void AddBinaryData(string fieldName, byte[] contents);
-- public void AddBinaryData(string fieldName, byte[] contents, string fileName);
-- public void AddBinaryData(string fieldName, byte[] contents, [DefaultValue("null")] string fileName, [DefaultValue("null")] string mimeType);
function HttpManager:ResponsePost(url, call_back, form, out_time, out_time_count)
    out_time = out_time or 2
    out_time_count = out_time_count or 100
    local co
    local count = 1
    local time_id
    local stopTime
    local function func()
        local www = WWW(url, form)
        coroutine.www(www, co)
        if #www.text > 0 then
            if call_back then
                local t = json.decode(www.text)
                call_back(t)
            end
            stopTime()
        end
        co = nil
    end

    stopTime = function()
        if time_id then
            GlobalSchedule:Stop(time_id)
            time_id = nil
        end
    end
    local function step()
        if not co then
            co = coroutine.start(func)
            count = count + 1
            if count > out_time_count then
                logError('--HttpManager:ResponseGet Http链接 超时--', url)
                stopTime()
            end
        end
    end
    time_id = GlobalSchedule:Start(step, out_time)
    co = coroutine.start(func)
    step()
end

-- 验证
function HttpManager:GetVerify(uid, platform)
    local url = "http://192.168.31.100/website/verify.php?uid=%s&platform=%s"
    uid = uid or 1
    platform = platform or "xwtest"
    url = string_format(url, uid, platform)

    local function call_back(response)
        local t = json.decode(response)
        if not t then
            return
        end
        print('--LaoY HttpManager.lua,line 67--')
        dump(t, "t")
    end
    self:ResponseGet(url, call_back)
end

-- 选服务器
function HttpManager:SelectServer(uid, platform, server_index)
    local url = "http://192.168.31.100/website/selectserver.php?uid=%s&platform=%s&server_index=%s"
    uid = uid or 1
    platform = platform or "xwtest"
    server_index = server_index or 1
    url = string_format(url, uid, platform, server_index)
    local function call_back(response)
        local t = json.decode(response)
        if not t then
            return
        end
        print('--LaoY HttpManager.lua,line 83-- data=')
        dump(t, "t")
    end
    self:ResponseGet(url, call_back)
end

function HttpManager.OpenUrl(url)
    Application.OpenURL (url)
end
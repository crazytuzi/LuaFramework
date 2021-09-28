require "cocos.init"
require "src/login/LoginUtils"

g_adChannel = 1000
-- for CCLuaEngine traceback

local videoPlayer = nil
local isVideoPlaying = false

g_crashLogMd5Table = {}

function __G__TRACKBACK__(msg)

    release_print("----------------------------------------")
    release_print("LUA ERROR: ", msg)
    release_print(debug.traceback())
    
    if cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS then
        -- 发送异常日志
        local clientversion = cc.UserDefault:getInstance():getStringForKey("current-version-code", "0.0.0.0")
        local log = "[" .. clientversion .. "]" .. tostring(msg) .. "\n" .. string.format(debug.traceback())
        local md5Value = getMd5HexStr(log)
        if g_crashLogMd5Table[md5Value] == nil then
            g_crashLogMd5Table[md5Value] = 1

            local xhr = cc.XMLHttpRequest:new()
            xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
            xhr:open("POST", "http://222.73.2.116/report_cqsjsy_android.php")
            local function onReadyStateChange()
                --dump(xhr.response)
            end
            xhr:registerScriptHandler(onReadyStateChange)
            xhr:send(log)
        end      
    elseif GetIniLoader and GetIniLoader():GetPrivateBool("Main", "DebugError") ~= false then
    	local log = tostring(msg) .."\n".. string.format(debug.traceback())
    	DebugError(log)
    end

    print("----------------------------------------")
    local pFile =  io.open("logfile.log","a")
    if pFile then
        pFile:write("----------------------------------------\n")
        pFile:write(os.date())
        pFile:write("\nLUA ERROR: " .. tostring(msg) .. "\n")
        pFile:write(string.format(debug.traceback()))
        pFile:write("\n----------------------------------------\n")
        pFile:close()
    end 
end

local onSplashEnd = function()

	 --语聊初始化
    release_print("yuexiaojun VoiceApollo:ApolloVoiceInit")
    VoiceApollo:ApolloVoiceInit()
    
    isVideoPlaying = false

	if videoPlayer then
		videoPlayer:removeFromParent()
	end

	local target = cc.Application:getInstance():getTargetPlatform()
		if target == cc.PLATFORM_OS_ANDROID then
		local args = {false}
		local sigs = "(Z)V"
		local luaj = require "kuniu/cocos/cocos2d/luaj"
	    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "setVideoStatus", args, sigs)
	end

	local json = require("json")
	local path = cc.FileUtils:getInstance():fullPathForFilename("adChannel.png")
    local channel_data = nil
    if path then
        channel_data = cc.FileUtils:getInstance():getStringFromFile(path) 
        if channel_data then
            g_Channel_tab = json.decode(channel_data)  
            g_adChannel = tonumber(g_Channel_tab.adChannel)
        end 
        --[[
        if g_adChannel  == -2 then
        	g_adChannel = 1000
        	g_Channel_tab.adChannel = 1000
        	g_Channel_tab.version_channel = "alpha"
        end 
        ]]   
    end
    
    print(getDownloadDir())
    local LoginScene = require("src/login/LoginScene")
    LoginScene.VERSION = LoginUtils.getLocalRecordByKey(2, "current-version-code")
    if #LoginScene.VERSION == 0 then
        LoginScene.VERSION = cc.FileUtils:getInstance():getStringFromFile("version.txt") 

        if #LoginScene.VERSION == 0 then
        	LoginScene.VERSION = "0.0.0"
        end

        LoginUtils.setLocalRecordByKey(2, "current-version-code", LoginScene.VERSION)
    end
    
    if isWindows() then
        LoginScene.VERSION = "10.0.0.0"
    end

    local scene = LoginScene.new()
    if cc.Director:getInstance():getRunningScene() then
		cc.Director:getInstance():replaceScene(scene)
	else
		cc.Director:getInstance():runWithScene(scene)
	end

	local function onKeyReleased(keyCode, event)
        if keyCode == cc.KeyCode.KEY_BACK then
            local target = cc.Application:getInstance():getTargetPlatform()
            -- if target == cc.PLATFORM_OS_ANDROID then
            --     local luaj = require "kuniu/cocos/cocos2d/luaj"
            --     luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "onKeyBackDown")
            -- end

            if target == cc.PLATFORM_OS_ANDROID then
	            local function gameQuit()
	            	if _OnGameAppEvent ~= nil then
	            		_OnGameAppEvent("1")
	            	else
	            		cc.Director:getInstance():endToLua()
	            	end
	            end

	            local runScene = cc.Director:getInstance():getRunningScene()
				if runScene then
					local quitWnd = runScene:getChildByName("GameQuit")
					if quitWnd then
						quitWnd:removeFromParent()
					else
						local msg = LoginUtils.MessageBoxYesNo("提示", "是否要退出游戏？", gameQuit, nil)
			            msg:setLocalZOrder(60000)
			            msg:setName("GameQuit")
					end
				end
			end
            
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:addEventListenerWithFixedPriority(listener, 1)

end

_G_ChangeVideoStatus = function(str)
	if videoPlayer ~= nil then
		if str == "pause" then
			videoPlayer:pause()
		end
	end
end

_G_voiceBtnEvent = function(str)
	require("src/layers/chat/Microphone"):onVoiceLock(str)
end

local function playVideo()
	isVideoPlaying = true
	local target = cc.Application:getInstance():getTargetPlatform()

	if target == cc.PLATFORM_OS_WINDOWS then
		onSplashEnd()
	else
		if target == cc.PLATFORM_OS_ANDROID then
			local args = {true}
			local sigs = "(Z)V"
			local luaj = require "kuniu/cocos/cocos2d/luaj"
		    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "setVideoStatus", args, sigs)
		end
		local Director = cc.Director:getInstance()
		local scene = Director:getRunningScene()
		if not scene then
			scene = cc.Scene:create()
			Director:runWithScene(scene)
		end
		local csize = scene:getContentSize()
		videoPlayer = ccexp.VideoPlayer:create()
		videoPlayer:setKeepAspectRatioEnabled(true)
	    videoPlayer:setPosition(cc.p(csize.width/2,csize.height/2))
	    videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
	    if csize.width == 960 then
	    	videoPlayer:setContentSize(cc.size(csize.width,csize.height))
	    else
	    	videoPlayer:setContentSize(csize)
	    end
	    scene:addChild(videoPlayer)

        local function onSplashEnd_delay()
            if target == cc.PLATFORM_OS_ANDROID then
                onSplashEnd()
            else
                performWithDelay(scene, onSplashEnd, 0.01)
            end
        end

	    local function onVideoEventCallback(sener, eventType)
	        if eventType == ccexp.VideoPlayerEvent.PLAYING then
	        		
	       	elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
	       		if target == cc.PLATFORM_OS_ANDROID then
	        		onSplashEnd()
	        	end
	        elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
  				onSplashEnd_delay()
	       	elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
	       		onSplashEnd_delay()
	       	end
	   	end
	    videoPlayer:addEventListener(onVideoEventCallback)

	    if target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
	    	local function onTouchVideoCallback(sender)
	    		onSplashEnd()
	    	end
	    	local listener = cc.EventListenerTouchOneByOne:create()
    		listener:setSwallowTouches(true)
    		listener:registerScriptHandler(onTouchVideoCallback,cc.Handler.EVENT_TOUCH_BEGAN)
    		local dispatcher = cc.Director:getInstance():getEventDispatcher()
    		dispatcher:addEventListenerWithSceneGraphPriority(listener, scene)
	    end

        local videoFullPath = cc.FileUtils:getInstance():fullPathForFilename("kuniu/video/gameVideo.mp4")
        videoPlayer:setFileName(videoFullPath)   
        videoPlayer:play()
        --videoPlayer:seekTo(5)
  		--onSplashEnd()
    end
end



local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    
    math.randomseed(os.time())

    --测试用
   	--cc.FileUtils:getInstance():addSearchPath("kuniu_andriod", true)

	-- 增加闪屏功能	
	--[[
	local Director = cc.Director:getInstance()
	local TextureCache = Director:getTextureCache()
	local splash_pic_base_name = "splash_screen"
	local texture = TextureCache:addImage(splash_pic_base_name .. ".jpg")

	if texture then
		local scene = cc.Scene:create()
		local csize = scene:getContentSize()
		local bg = cc.Sprite:createWithTexture(texture)
		bg:setTag(1)
		bg:setPosition(csize.width/2, csize.height/2)
		bg.next = 1
		-- 限时最多限时三张图片
		bg.limit = 3
		local DelayTime = cc.DelayTime:create(1.5)
		local CallFunc = cc.CallFunc:create(function(node)
			local limit = bg.limit
			bg.limit = limit - 1
			local next_pic = splash_pic_base_name .. node.next .. ".jpg"
			local texture = TextureCache:addImage(next_pic)
			node.next = node.next + 1
			if texture and limit > 0 then
				bg:setTexture(next_pic)
			else
				bg:removeFromParent()
				playVideo()
			end
		end)
		local Sequence = cc.Sequence:create(DelayTime, CallFunc)
		local Repeat = cc.Repeat:create(Sequence, bg.limit)
		bg:runAction(Repeat)
		scene:addChild(bg)
		
		if Director:getRunningScene() then
			Director:replaceScene(scene)
		else
			Director:runWithScene(scene)
		end
	else
		playVideo()
	end]]
	
	onSplashEnd()
end

_G_SkipVideoFunction = function()
	if isVideoPlaying and videoPlayer then
		performWithDelay(videoPlayer, onSplashEnd, 0.01)
	end
end


Device_target = cc.Application:getInstance():getTargetPlatform()
function isIOS()
    return (Device_target == cc.PLATFORM_OS_IPHONE or Device_target == cc.PLATFORM_OS_IPAD)
end

function isAndroid()
    return (Device_target == cc.PLATFORM_OS_ANDROID)
end

function isWindows()
    return (Device_target == cc.PLATFORM_OS_WINDOWS)
end

function doString(str)
	if str then
		local func, msg = loadstring(str)
		if type(func) == "function" then
            func()
        elseif msg then
        	print(msg)
        end
	end
end

-- socket 轮寻开关
GameSocketLunXun = false

if LoginUtils.isTestMode() and not isWindows() then
    cc.Director:getInstance():getConsole():listenOnTCP(1234)
end

xpcall(main, __G__TRACKBACK__)

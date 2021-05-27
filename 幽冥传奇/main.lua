socket = require("socket")
mine = require "mime"
cjson = require("cjson.safe")

HIGH_TIME_NOW = 0
PLATFORM = 0										-- 平台
IS_IOS_OR_ANDROID = false							-- 是否是IOS或者安卓
NOW_TIME = 1										-- 当前时间，从程序启动开始算
IS_ON_CROSSSERVER = false							-- 是否跨服中

GLOBAL_CONFIG = {}									-- 全局配置
AGENT_PATH = ""										-- 平台路径
IS_AUDIT_VERSION = false							-- 是否审核版本

function Sleep(n)
	socket.select(nil, nil, n)
end

function LUA_CALLBACK(object, func)
	return function(...)
		return func(object, ...)
	end
end

-- 初始化搜索路径，is_need_update_path:是否需要update路径
function InitSearchPath(is_need_update_path)
	local data_path = UtilEx:getDataPath()
	local search_paths = {}

	table.insert(search_paths, data_path .. "main/data")
	if PLATFORM == cc.PLATFORM_OS_ANDROID then
		table.insert(search_paths, "data")
	elseif PLATFORM == cc.PLATFORM_OS_IPHONE or PLATFORM == cc.PLATFORM_OS_IPAD or PLATFORM == cc.PLATFORM_OS_MAC then
		table.insert(search_paths, "data")
	else
		table.insert(search_paths, "../assets")
	end

	if is_need_update_path then
		table.insert(search_paths, data_path .. "main")
		if PLATFORM == cc.PLATFORM_OS_ANDROID then
		elseif PLATFORM == cc.PLATFORM_OS_IPHONE or PLATFORM == cc.PLATFORM_OS_IPAD or PLATFORM == cc.PLATFORM_OS_MAC then
		else
			table.insert(search_paths, "../../version")
		end
	end

	----设置windows下使用的配置路径
	-- if PLATFORM == cc.PLATFORM_OS_WINDOWS then
		-- table.insert(search_paths, "../")
	-- end

	cc.FileUtils:getInstance():setSearchPaths(search_paths)

end

-- 程序入口
function Start()
	require("scripts/cocos2d/Cocos2d")
	require("scripts/cocos2d/Cocos2dConstants")
	require("scripts/cocos2d/OpenglConstants")
	require("scripts/cocos2d/GuiConstants")
	require("scripts/preload/http_client")

	PLATFORM = cc.Application:getInstance():getTargetPlatform()
	IS_IOS_OR_ANDROID = (cc.PLATFORM_OS_ANDROID == PLATFORM or cc.PLATFORM_OS_IPHONE == PLATFORM or cc.PLATFORM_OS_IPAD == PLATFORM)

	InitSearchPath(true)

	if cc.PLATFORM_OS_ANDROID == PLATFORM then
		require("scripts/platform/android/platform_adapter")
	elseif cc.PLATFORM_OS_IPHONE == PLATFORM then
		require("scripts/platform/iphone/platform_adapter")
	elseif cc.PLATFORM_OS_IPAD == PLATFORM then
		require("scripts/platform/ipad/platform_adapter")
	elseif cc.PLATFORM_OS_WINDOWS == PLATFORM then
		require("scripts/platform/windows/platform_adapter")
	elseif cc.PLATFORM_OS_MAC == PLATFORM then
		require("scripts/platform/mac/platform_adapter")
	else
		require("scripts/platform/platform_adapter")
	end

	require("scripts/preload/global_config")

	-- init director
	local director = cc.Director:getInstance()
	director:setDisplayStats(false)					-- 是否显示左下状态文字
	director:setAnimationInterval(1.0 / 60)			-- 设置帧间隔

	local design_height = 768
	local design_width = 1380
	local resolution_policy = cc.ResolutionPolicy.FIXED_HEIGHT
	local glview = director:getOpenGLView()
	if nil == glview then
		glview = cc.GLView:createWithRect("cq20", cc.rect(0, 0, design_width, design_height))
		director:setOpenGLView(glview)
	end

	-- table.sort(table[,comp])
	 -- glview:setFrameSize(1792 / 2, 828 / 2)
	
	local frame_size = glview:getFrameSize()

	--宽高比较大的时候  x轴上的ui x坐标将缩小 将会挤在一起 此时需调整x轴上的缩放；
	--@解决方案为FIXED_HEIGHT时 仅改变design_height 即可调整x轴方向上的缩放
	--@当设计分辨率改变时 根据该分辨率设计的图片的高度需要修改为896 以填满多出的部分 
	if cc.PLATFORM_OS_IPAD == PLATFORM then
		design_height = 896
	else
		if frame_size.height >= 768 and frame_size.width / frame_size.height <= 4/3 then
			design_height = 896
		end
	end

	--宽高比较为特殊时 展示全部 不做特殊处理 等比填满屏幕的一个方向 有黑边 
	if frame_size.width / frame_size.height <= 1 then
		resolution_policy = cc.ResolutionPolicy.SHOW_ALL
	end

	glview:setDesignResolutionSize(design_width, design_height, resolution_policy)
	local size = director:getWinSize()
	AdapterToLua:GetGameScene():SetViewRect(cc.rect(0, 0, size.width, size.height))

	AdapterToLua:getInstance():setUpdateHandler(Update)
	AdapterToLua:getInstance():setStopHandler(Stop)

	-- start prober
	require("scripts/preload/prober_ctrl")
	MainProber:Start()

	local login_times = AdapterToLua:getInstance():getDataCache("LOGIN_TIMES")
	if "" == login_times then
		login_times = 1
	else
		login_times = tostring(tonumber(login_times) + 1)
	end
	AdapterToLua:getInstance():setDataCache("LOGIN_TIMES", login_times)

	MainProber:Step(MainProber.STEP_LUA_BEG or 30, GLOBAL_CONFIG.assets_info.version)

	function start_func()
		-- start loader
		require("scripts/preload/loader_ctrl")
		MainLoader:Start()
	end

	local img_logo_path_name = "agentres/landscape_1.png"
	local img_logo_2_path_name = "agentres/landscape_2.png"

	local loyout_logo_bg_2 = nil

	if not cc.FileUtils:getInstance():isFileExist(img_logo_path_name) then
		img_logo_path_name = nil
	end

	if not cc.FileUtils:getInstance():isFileExist(img_logo_2_path_name) then
		img_logo_2_path_name = nil
	end

	if img_logo_path_name then

		local loyout_logo_bg = XLayout:create(size.width, size.height)
		loyout_logo_bg:setBackGroundColor(cc.c3b(0x00, 0x00, 0x00))
		AdapterToLua:GetGameScene():addChildToRenderGroup(loyout_logo_bg, GRQ_UI_UP)

		local img_logo = XImage:create(img_logo_path_name, false)
		img_logo:setPosition(size.width / 2, size.height / 2)
		loyout_logo_bg:addChild(img_logo)

		img_logo:setScaleX(size.width / img_logo:getContentSize().width)
		img_logo:setScaleY(size.height / img_logo:getContentSize().height)

		if img_logo_2_path_name ~= nil then
			loyout_logo_bg_2 = XLayout:create(size.width, size.height)
			loyout_logo_bg_2:setBackGroundColor(cc.c3b(0x00, 0x00, 0x00))
			AdapterToLua:GetGameScene():addChildToRenderGroup(loyout_logo_bg_2, GRQ_UI_UP)

			local img_logo_2 = XImage:create(img_logo_2_path_name, false)
			img_logo_2:setPosition(size.width / 2, size.height / 2)
			loyout_logo_bg_2:addChild(img_logo_2)
			loyout_logo_bg_2:setOpacity(0)

			img_logo_2:setScaleX(size.width / img_logo_2:getContentSize().width)
			img_logo_2:setScaleY(size.height / img_logo_2:getContentSize().height)
		end

		function logo_fun(times)
			local delay = cc.DelayTime:create(1.5)
			local fade_out = cc.FadeOut:create(0.3)
			local call_back = cc.CallFunc:create(function()
				if times == 1 then
					if loyout_logo_bg_2 ~= nil then
						local delay_2 = cc.DelayTime:create(1.5)
						local fade_int_2 = cc.FadeIn:create(0.3)
						local call_back_2 = cc.CallFunc:create(function()
							logo_fun(2)
							end)

						local action_2 = cc.Sequence:create(delay_2, fade_int_2, call_back_2)
						loyout_logo_bg_2:runAction(action_2)
					else
						loyout_logo_bg:removeFromParent()
						start_func()
					end
				elseif times == 2 and loyout_logo_bg_2 ~= nil then
					loyout_logo_bg_2:removeFromParent()
					start_func()
				else
					start_func()
				end
			end)

			local action = cc.Sequence:create(delay, fade_out, call_back)
			if times == 1 then
				loyout_logo_bg:runAction(action)
			else
				loyout_logo_bg_2:runAction(action)
			end
		end	
		logo_fun(1)
	else
		start_func()
	end
	
end

function Update(dt)
	HIGH_TIME_NOW = XCommon:getHighPrecisionTime()
	NOW_TIME = NOW_TIME + dt
	
	if nil ~= HttpClient then
		HttpClient:Update(dt)
	end

	if nil ~= MainLoader then
		MainLoader:Update(dt)
	end

	if nil ~= MainProber then
		MainProber:Update(dt)
	end
end

function Stop()
	if nil ~= MainLoader then
		MainLoader:Stop()
		MainLoader = nil
	end

	if nil ~= HttpClient then
		HttpClient:Stop()
		HttpClient = nil
	end

	if nil ~= MainProber then
		MainProber:Stop()
		MainProber = nil
	end
end

-- 进入后台
function EnterBackground()
	print("EnterBackground function!")
	cc.Director:getInstance():stopAnimation()
	cc.SimpleAudioEngine:getInstance():pauseMusic()

	if nil ~= MainLoader then
		MainLoader:EnterBackground()
	end
end

-- 进入前台
function EnterForeground()
	print("EnterForeground function!")
	cc.Director:getInstance():startAnimation()
	cc.SimpleAudioEngine:getInstance():resumeMusic()

	if nil ~= MainLoader then
		MainLoader:EnterForeground()
	end
end

-- 网络状态改变
function NetStateChanged(net_state)
	print("NetStateChanged " .. net_state)

	if nil ~= MainLoader then
		MainLoader:NetStateChanged(net_state)
	end
	return true
end

-- 全局配置变更
function GlobalConfigChanged()
	if nil ~= MainProber then
		MainProber:GlobalConfigChanged()
	end
	
	if nil ~= MainLoader then
		MainLoader:GlobalConfigChanged()
	end
end

-- 内存警告
function MemoryWarning()
	if nil ~= ClientCmdCtrl and nil ~= ClientCmdCtrl.Instance then
		ClientCmdCtrl.Instance:ClearMemory(false)
	end

	if nil ~= MainProber then
		MainProber:Warn(MainProber.EVENT_MEMORY_WARN)
	end
end

function __G__TRACKBACK__(msg)
	local log = debug.traceback() .. "\n[LUA-ERROR] " .. msg
	if nil ~= MainProber then
		MainProber:Error(log)
	else
		print(log)
	end

	return msg
end

math.randomseed(os.time())

local status, msg = xpcall(Start, __G__TRACKBACK__)

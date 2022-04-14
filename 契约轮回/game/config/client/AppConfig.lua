--
-- @Author: LaoY
-- @Date:   2019-01-14 14:51:30
-- 客户端配置 后续把镜头等参数挪进来

-- cnd http://192.168.31.190/update/		-- 本地
-- cnd http://39.108.239.119/update/		-- 外服
-- cnd http://xw.xwangame.com/update/		-- 外服 cdn
-- cnd http://cdn.xwangame.com/update/		-- 外服 cdn, modify 2019-07-22
-- cnd http://39.108.239.119/banhao/		-- 版号服
AppConfig = {
	-- 聊天框输入点击左下角，显示操作按钮
	Filter = true,		--	跑包
	FilterScene = {		-- 包里包含的场景
	},

	pack_name = "xw",
	Debug = true,					-- 调试状态
	CheckUnUseAssetFrameCount = 5,  -- 检查不用资源的间隔，单位帧。ps:2就是2帧检查一次
	coroutine_count = 8,			-- 同时加载资源协程数量
	IsSilentDownLoad = false,		-- 是否静默下载
	scene_camera_size = 4.05, 		-- 场景摄像机大小
	is_unload_imm = true,			-- 是否立刻卸载 abName (单个资源打成ab包的可以这么处理)
	isOutServer = false,

	JavaPath = nil,
	-- 开发服才有效
	QuickEnterGame = false, 		-- 快速进入游戏

	IsSupportGPU = false,			-- 是否支持gpu资源，用于怪物

	-- YunYingUrl = "",  			-- 运营配置PHP
	HotUpdateConfigCDN = "", 		-- 热更cdn				
	OpenHotUpdateLv = 125,			-- 开启热更的等级

	Url = "http://admin.xwangame.com/", --"http://39.108.239.119/",
	GameStart = false,
	EnterGameCount 	= 0,

	DebugRef = false,

	autoGenerateAccount = true,		-- 自动生成账号
	saveAccount = true,				-- 记录账号
	region = 1,						-- 1国内 2繁体 3泰文 4游境相关渠道 5.英文 6.韩文 8.越南 9.eco 10.eco quick
	engineVersion = 1,
	--[[	

		1.引擎代码版本号 2019.11.1之前 全部算是 1.0
		2.
			** 下载相关改为Httpclien,加上限速相关
			** quality相关设置
			** ScreenOrientation屏幕旋转相关
		3.
			**修改判断是否在下载列表接口BUG，A依赖B，B依赖A，造成无限递归的BUG
			**添加调试信息，是否用gm、显示内存等信息、写部分日志、默认选中服的index、调试协议号
			
		4.
			** 添加Android内存获取接口
			** 添加config.json 字段，debugMem
			** 断点续传，加上ReadWriteTimeOut
		
		5.
			** 添加优化相关接口，Animation Animator相关修改
			** Astar相关修改
			 
		6.
			** 导出Empty4Raycast、MaterialPropertyBlock

		7.
			** 新加日志控制系统		
			** 初始化SDk相关的控制
			
		8.
			** 热更资源，update_files.json刷新问题
			*
		9.
			** 添加iosver
			*
		10.
			** 更换json库，下载相关添加

		11
			** 添加创建文件的接口 bytes
			*
		
		12  跳过

		13
			** c#用的文字，全部改成配置
	]]
}

-- 初始化配置
local function InitConfig()
    local data = AppConst.appConfig:ToJson();
    local appConfig = json.decode(data);

    for k,v in pairs(appConfig) do
    	AppConfig[k] = v
    end

	if AppConfig.isOutServer then
		AppConfig.Debug = false
		AppConfig.QuickEnterGame = false
	end

	AppConfig.YunYingUrl = appConfig.cdn_url .. "release/hot/db_yunying.lua"
	AppConfig.HotUpdateConfigCDN = appConfig.cdn_url .. "release/hot/"

	if AppConfig.pack_name == "xw" then
		AppConfig.pack_name = "xingwan"
	end

	-- AppConfig.DebugRef = AppConst.DebugRef
	-- AppConfig.DebugRef = false

	AppConfig.IsSupportGPU = Util.IsSupportGPU()
	AppConfig.IsSupportGPU = false

	print("===AppConfig.IsSupportGPU = " .. tostring(AppConfig.IsSupportGPU))

	if AppConfig.Filter then
		-- todo
		resMgr:SetFilterFlag(true)
		for k,v in pairs(AppConfig.FilterScene or {}) do
			resMgr:AddFilterScene(v)
		end
	end

	if AppConfig.engineVersion and AppConfig.engineVersion > 1 then
		Screen = UnityEngine.Screen
		Screen.orientation = UnityEngine.ScreenOrientation.AutoRotation;
		Screen.autorotateToLandscapeLeft = true;
		Screen.autorotateToLandscapeRight = true;
		Screen.autorotateToPortrait = false;
		Screen.autorotateToPortraitUpsideDown = false;
	end

	-- if AppConfig.region == 1 or AppConfig.region == 4 then
	-- 	AppConfig.Url = "http://admin.xwangame.com/"--"http://39.108.239.119/",
	-- elseif AppConfig.region == 2 then
	-- 	AppConfig.Url = "http://admin.tanwan.xwangame.com"--"http://39.108.239.119/",
	-- elseif AppConfig.region == 3 then
	-- 	AppConfig.Url = "http://admin.twxw.xwangame.com/"--"http://39.108.239.119/",
	-- elseif AppConfig.region == 5 then
	-- 	AppConfig.Url = "http://admin.twen.xwangame.com/"--"http://39.108.239.119/",
	-- elseif AppConfig.region == 9 or AppConfig.region == 10 then
	-- 	if sdkMgr.platform == 3 then
	-- 		AppConfig.Url = "http://admin.jhgw.xwangame.com/"
	-- 	else
	-- 		AppConfig.Url = "http://admin.jhyg.xwangame.com/"
	-- 	end
	-- elseif AppConfig.region == 11 then
	-- 	AppConfig.Url = "http://admin.jh.xwangame.com/"
	-- elseif AppConfig.region == 12 then
	-- 	AppConfig.Url = "http://admin.xwen.xwangame.com:10000/"
	-- end
	AppConfig.Url = "http://admin.fate.xwangame.com/"
end
InitConfig()

local is_can_hot_update = false
function InitHotUpdateState()
	is_can_hot_update = UnityEngine.PlayerPrefs.GetInt(AppConst.HotUpdateKey,0) ~= 0
	AppConfig.IsSilentDownLoad = is_can_hot_update
end
InitHotUpdateState()

-- 刷新热更状态
function RefreshHotUpdateState(lv)
	local cur_state = lv >= AppConfig.OpenHotUpdateLv
	RefreshNecessaryState(lv)
	if cur_state == is_can_hot_update then
		return
	end
	local state_int = cur_state and 1 or 0
	UnityEngine.PlayerPrefs.SetInt(AppConst.HotUpdateKey,state_int)
	InitHotUpdateState()
end

local is_can_update_necessary = false
function RefreshNecessaryState(lv)
	local cur_state = lv >= 5
	if cur_state == is_can_update_necessary then
		return
	end
	is_can_update_necessary = cur_state
	silenceMgr.is_can_down_necessary = cur_state
end


function IsIOSExamine()
	if AppConfig.timeline and os.time() <= AppConfig.timeline then
		return true
	end
	return false
end
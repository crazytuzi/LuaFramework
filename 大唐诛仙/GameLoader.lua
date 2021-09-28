--管理器--
GameLoader = {}
local this = GameLoader

--初始化完成，发送链接服务器信息--
function GameLoader.Init()
	collectgarbage("collect")
	collectgarbage("setpause", 100) 
	collectgarbage("setstepmul", 5000)
	math.randomseed(os.clock()*math.random(1000000, 99999999)*1000000)
	-- 预处理 -->>
		Util = LuaFramework.Util
		AppConst = LuaFramework.AppConst
		LuaHelper = LuaFramework.LuaHelper
		ByteBuffer = LuaFramework.ByteBuffer
		resMgr = LuaHelper.GetResManager()
		gameMgr = LuaHelper.GetGameManager()
		loaderMgr = LuaHelper.GetLoaderManager()
		
		print("游戏版本：", gameMgr.gameVersion)

		print("========初始化声音管理器")
		soundMgr = LuaHelper.GetSoundManager()
		print("========初始化声音管理器")
		networkMgr = LuaFramework.NetworkManager.Instance
		layerMgr = LayersMgr.Instance
		payMgr = PayMgr.Instance
		sdkToIOS = SdkToIOS.Instance
		Application = UnityEngine.Application
		WWW = UnityEngine.WWW
		GameObject = UnityEngine.GameObject
		KeyCode = UnityEngine.KeyCode
		NavMeshPathStatus = UnityEngine.NavMeshPathStatus
		Input = UnityEngine.Input
		SceneManager = UnityEngine.SceneManagement.SceneManager
		CSharpDispatcher = GlobalDispatcher.GetInstance() -- 这里转为 CSharpDispatcher
		UBBParserExtension = UBBParserExtension.GetInstance() -- 表情签标解析
		Camera = UnityEngine.Camera
		DeviceInfo = DeviceInfo.Instance
	-- 预处理 ---------------------------------------------------------------------<<<
	-- 公共UI资源加载
	if not resMgr:AddUIAB("common") then print("common assets miss!!") return end

	require("SKGame/init")
	require("Common/BehaviourMgr")

	-- 开启调试模式
	if GameConst.Debug then
		DebugMgr:GetInstance()
	end
	BehaviourMgr.Init()

	soundMgr:RegistEffAudio()
	local volume = DataMgr.ReadData("bgVolume", 1.0)
	soundMgr:SetBgVolume(volume)


	newGuildLayer = GComponent.New() -- 顶级层，比popup还高，不要乱用，仅用于引导及锁屏处理
	newGuildLayer.displayObject.gameObject.name = "newGuildLayer"
	newGuildLayer:SetScale(GameConst.scaleX, GameConst.scaleY)
	Stage.inst:AddChild(newGuildLayer.displayObject)
	newGuildLayer.opaque = false -- 穿透

	bottomLayer = GComponent.New()
	bottomLayer.fairyBatching = true
	layerMgr:AddToUILayer(bottomLayer)
	EffectMgr.PlayBGSound("721001")
	this.LoadPreAssets()
end

function GameLoader.LoadResFinish()

	CSharpDispatcher:AddEventListener("IOSCallLoginCallBack", function (context)
		print("@lua>>>>IOSCallLoginCallBack")
		LoginController:GetInstance():ReqLoginAccount(context.data)
	end);
	CSharpDispatcher:AddEventListener("IOSCallLogoutCallBack", function (context)
		print("@lua>>>>IOSCallLogoutCallBack")
	end);
	CSharpDispatcher:AddEventListener("IOSCallPayResultCallBack", function (context)
		print("@lua>>>>",context.data)
	end);
	CSharpDispatcher:AddEventListener("IOSCallPayClosedCallBack", function (context)
		print("@lua>>>>IOSCallPayClosedCallBack")
	end);

	GgController:GetInstance()
	LoginController:GetInstance() -- 登录
	MainUIController:GetInstance()
	SceneController:GetInstance()
	ServerSelectController:GetInstance()
end

-- 预载资源例子
local preLoadCount = 0
local OnlyOnceAssets = {"11001", "11002", "12001", "12002", "13001", "13002"}
local unloadPreAssetsHandler = nil
function GameLoader.LoadPreAssets()
	-- Util.GetAllEffectName(function (content) end)-- 获取要在预加载的特效，在场景第一次加载时处理
	if not unloadPreAssetsHandler then
		local function unloadPreAssets()
			GlobalDispatcher:RemoveEventListener(unloadPreAssetsHandler) -- 卸载资源例子
			unloadPreAssetsHandler = nil
			for _,v in ipairs(OnlyOnceAssets) do
				UnLoadEffect(v, false)
			end
			OnlyOnceAssets = nil
		end
		unloadPreAssetsHandler = GlobalDispatcher:AddEventListener(EventName.FIRST_ENTER_SCENE, unloadPreAssets)
	end
	local list = {{"11001",1}, {"11002",1}, {"12001",1}, {"12002",1}, {"13001",1}, {"13001",1},
					{"1001",0}, {"1002",0}, {"1003",0},
					{"1011",0}, {"1012",0}, {"1014",0},
					{"1023",0}, {"1033",0}}
	preLoadCount = #list
	this._LoadPreData(list, 1)
end
function GameLoader._LoadPreData(list, i)
	local item = table.remove(list, 1)
	if item[2] == 1 then
		LoadEffect(item[1], function ( o )
			if #list ~= 0 then
				CSharpDispatcher:DispatchEvent("LOADER_PROGRESS", "初始化游戏角色特效中，请稍等...|"..math.floor((i/preLoadCount)*100))
				this._LoadPreData(list, i+1)
			end
		end)
	elseif item[2] == 0 then
		LoadPlayer(item[1], function ( o )
			if #list ~= 0 then
				CSharpDispatcher:DispatchEvent("LOADER_PROGRESS", "初始化游戏角色特效中，请稍等...|"..math.floor((i/preLoadCount)*100))
				this._LoadPreData(list, i+1)
			else
				CSharpDispatcher:DispatchEvent(EventName.LOADER_ALL_COMPLETED) -- 资源及lua 更新初始化完成
				this.LoadResFinish()
			end
		end)
	end
end

function GameLoader.LinkLoginSvr()
	local srvData = LoginModel:GetInstance():GetLastServer()
	if not TableIsEmpty(srvData) then
		if srvData.gameHost and srvData.gameHost ~= "" then
			Network.LinkServer(srvData.gameHost, tonumber(srvData.gamePort))
		else
			UIMgr.Win_FloatTip("选择服务器有误!")
			return
		end
	end
end

GameLoader.LostFoucusTime = 300
GameLoader.currentLostFoucus = os.time()
GameLoader.Focus = false
function GameLoader.OnApplicationFocus(focus)
	if focus then
		if (os.time() - this.currentLostFoucus) > this.LostFoucusTime then
			if Network.IsConneted() then
				Network.BreakSocket()
			else
				Network.OnDisconnect()
			end
		end
	else
		this.currentLostFoucus = os.time()
	end
	GameLoader.Focus = focus
end

--销毁--
function GameLoader.OnDestroy()
	log('App OnDestroy--->>>')
	Network.CloseSocket()
end


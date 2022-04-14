
require "Common.RequireFirst"
-- require "Common.functions"

define = {}
function define.new()
	local t = {}
	setmetatable(t,{__index = define})
	t:ctor()
	return t
end
--local LuaClickListener = LuaFramework.LuaClickListener
----设置GameObject Active
--local function SetGameObjectActive(obj, bool)
--    if obj and obj.gameObject then
--        bool = bool and true or false;
--        obj.gameObject:SetActive(bool);
--    end
--end
--
--local function AddClickEvent(target, call_back)
--    if target then
--        LuaClickListener.Get(target).onClick = call_back
--    end
--end
--
--local function GetChild(transform, childName)
--    if transform then
--        return transform.transform:Find(childName);
--    end
--end

function define:ctor()

	local timeTab = {}
	local index = 0

	-- 这两句话有可能造成卡顿
	collectgarbage("setpause", 110)
    collectgarbage("setstepmul", 200)

    -- 后面改为CPU空闲时 单步回收
    -- collectgarbage("collect")

    Application = UnityEngine.Application
    SystemInfo = UnityEngine.SystemInfo
	RuntimePlatform = UnityEngine.RuntimePlatform
	PlayerPrefs = UnityEngine.PlayerPrefs;
	AudioSource = UnityEngine.AudioSource;
	MaterialPropertyBlock = UnityEngine.MaterialPropertyBlock;

	Util = LuaFramework.Util;
	AppConst = LuaFramework.AppConst;
	LuaHelper = LuaFramework.LuaHelper;
	ByteBuffer = LuaFramework.ByteBuffer;
	UIHelp = LuaFramework.UIHelp;

    json = require "cjson.safe"

    mapMgr = LuaHelper.GetMapManager();
	

	resMgr = LuaHelper.GetResManager();
	panelMgr = LuaHelper.GetPanelManager();
	networkMgr = LuaHelper.GetNetManager();
	gameMgr = LuaHelper.GetGameManager();

	sdkMgr 		= LuaHelper.GetSDKManager();
	voiceMgr 	= LuaHelper.GetVoiceManager();
	tdMgr 		= LuaHelper.GetTalkingDataManager();
	silenceMgr 	= LuaHelper.GetSilenceManager();
	aliyunOssMgr = LuaHelper.GetOssManager();

	Shader = UnityEngine.Shader
	Screen = UnityEngine.Screen
	Input = UnityEngine.Input
	KeyCode = UnityEngine.KeyCode
	WWW = UnityEngine.WWW;
	WWWForm = UnityEngine.WWWForm
	GameObject = UnityEngine.GameObject;
	TextAnchor = UnityEngine.TextAnchor;
	RenderTexture = UnityEngine.RenderTexture

    Material = UnityEngine.Material;
	SystemInfo = UnityEngine.SystemInfo;
	RectTransformUtility = UnityEngine.RectTransformUtility;

    Application.targetFrameRate = 60

	self:Init()

	-- lua基础模块
	require "base.RequireBase"
	require("game.config.client.AppConfig")

	if AppConfig.Debug then
		gameMgr:ShowLogFile()
	end
	
	--资源后缀名
	AssetsBundleExtName = ".unity3d"

	if AppConfig.isMJPackage then
		--马甲包
		AssetsBundleExtName = ".u3d"
	end
	
	require "Common.RequireCommon"

	-- 是否开启 log显示
	if AppConfig.engineVersion >= 7 then
		if gameMgr.EnableLog then
			gameMgr:EnableLog(AppConfig.printLog == true)
		end
	end
	
	-- if AppConfig.Debug then
	-- 	gameMgr:HideReporter(true);
	-- else
	-- 	local go = GameObject.Find("Reporter");
	-- 	if go then
	-- 		destroy(go)
	-- 	end
	-- end

	if not AppConfig.reportEnable then
		local go = GameObject.Find("Reporter");
		if go then
			destroy(go)
		end
	end

	logWarn('lua内存===>1',GetLuaMemory())
	require "proto.require_pb" 

	require "Common.LuaMemManager"
	LuaMemManager()

	-- logWarn('lua内存===>2',GetLuaMemory())
	-- lua基础模块
	require "game/config/RequireConfig" 
	-- logWarn('lua内存===>3',GetLuaMemory())
	
	require("common/PoolManager")
	PoolManager()
	poolMgr = PoolManager:GetInstance()

	-- 设置随机种子
	math.newrandomseed()
	-- lua层初始化在后面添加
	-- for k,v in pairs(Constant.GlobalControll) do
	-- 	require (v)
	-- end
	-- CtrlManager()

	CtrlManager.Start()
	
	--功能跳转链接
	-- require('Common.LinkConfig')

	if LuaMemManager then
		LuaMemManager:GetInstance():GC()
	end
	
	--应该放在热更后请求登录
	-- NetManager:GetInstance():StartConnect()

	-- GlobalEvent:Brocast(EventName.HotUpdateSuccess)

	lua_panelMgr:OpenPanel(PreLoadingPanel)

	-- local function call_back()
	-- 	Yzprint('--LaoY define.lua,line 73--=')
	-- end
	-- Dialog.ShowTwo("提示","hello world","确定",call_back,nil,"取消")
	-- GlobalEvent:Brocast(MainEvent.OpenRocker)
	-- self:Test()

	-- BaseMessage(1,2,3)
	-- self:Test()
	-- self:TestMemory()

	-- local function call_back(t)
	-- 	local str = t
	-- 	str = string.gsub(str,"Config = Config or {}","")
	-- 	str = string.gsub(str,"Config.db_yunying = ","")
	-- 	local tab = LuaString2Table(str)
	-- end
	-- HttpManager:GetInstance():ResponseGetText(AppConfig.YunYingUrl, call_back)

	-- LoginModel:GetInstance():HotUdpateConfig("db_yunying")

	-- 状态机测试
	-- self:TestMachine()

	-- local last_time = Time.time
	-- local function step()
	-- 	Yzprint('--LaoY define.lua,line 135--',Time.time - last_time)
	-- 	last_time = Time.time
	-- end
	-- self.time_id = GlobalSchedule:Start(step,5.0)
end

function define:TestMemory()
	local count = 10000

	logWarn('测试map内存')

	collectgarbage("collect")
	logWarn('map lua内存===>',GetLuaMemory())
	self.list = {}
	local start_memory = GetLuaMemory()
	for i=1,count do
		local pb_object = pb_1502_magiccard_pb.m_magic_card_list_toc()
		-- append
		for j=1,2 do
			local t = pb_object.cards:add()
			t.key = j
			-- t.value = pb_comm_pb.p_item()
			t.value.uid = j
			t.value.id = j
			t.value.num = j
			t.value.bag = j
			t.value.bind = false
			t.value.etime = 100
			t.value.gender = 1
			t.value.score = 1000
		end
		self.list[i] = pb_object
	end
	collectgarbage("collect")
	local end_memory = GetLuaMemory()
	logWarn("===============>",end_memory - start_memory)
	dump(self.list[1],"tab")


	collectgarbage("collect")
	logWarn('map转table lua内存===>',GetLuaMemory())
	self.list_2 = {}
	local start_memory = GetLuaMemory()
	for i=1,count do
		local pb_object = pb_1502_magiccard_pb.m_magic_card_list_toc()
		-- append
		for j=1,2 do
			local t = pb_object.cards:add()
			t.key = j
			-- t.value = pb_comm_pb.p_item()
			t.value.uid = j
			t.value.id = j
			t.value.num = j
			t.value.bag = j
			t.value.bind = false
			t.value.etime = 100
			t.value.gender = 1
			t.value.score = 1000
		end
		self.list_2[i] = ProtoStruct2Lua(pb_object)
	end
	collectgarbage("collect")
	local end_memory = GetLuaMemory()
	logWarn("===============>",end_memory - start_memory)
	-- dump(self.list_2[1],"tab")
end

function define:Test()
	-- repeated test
	-- for i=1,10 do
	-- 	pb.list:append(i)
	-- end

	-- map test
	-- local pb_object = pb_1107_mount_pb.m_mount_info_toc()
	-- -- append
	-- for i=1,2 do
	-- 	local t = pb_object.train:add()
	-- 	t.key = i
	-- 	t.value = i
	-- end
	-- -- pb_object:SerializeToString()

	-- local tab = ProtoStruct2Lua(pb_object)
	-- print('--LaoY define.lua,line 98--')
	-- dump(tab,"tab")

	local pb_object = pb_1502_magiccard_pb.m_magic_card_list_toc()
	-- append
	for i=1,2 do
		local t = pb_object.cards:add()
		t.key = i
		-- t.value = pb_comm_pb.p_item()
		t.value.uid = i
		t.value.id = i
		t.value.num = i
		t.value.bag = i
		t.value.bind = false
		t.value.etime = 100
		t.value.gender = 1
		t.value.score = 1000
	end
	-- pb_object:SerializeToString()

	local tab = ProtoStruct2Lua(pb_object)
	print('--LaoY define.lua,line 98--',tab.cards[1].uid)
	dump(tab,"tab")

end

function define:Init()
	--设置屏幕自动旋转， 并置支持的方向
	
	-- Screen = UnityEngine.Screen
	-- Screen.orientation = UnityEngine.ScreenOrientation.AutoRotation;
	-- Screen.autorotateToLandscapeLeft = true;
	-- Screen.autorotateToLandscapeRight = true;
	-- Screen.autorotateToPortrait = false;
	-- Screen.autorotateToPortraitUpsideDown = false;

	-- 设计分辨率
	DesignResolutionWidth 	= 1280
	DesignResolutionHeight 	= 720
	-- 实际分辨率
	DeviceResolutionWidth 	= UnityEngine.Screen.width
	DeviceResolutionHeight 	= UnityEngine.Screen.height

	-- 缩放比例
	g_standardScale_w = DeviceResolutionWidth/DesignResolutionWidth
	g_standardScale_h = DeviceResolutionHeight/DesignResolutionHeight
	g_standardScale = math.min(g_standardScale_w,g_standardScale_h)
	g_is_standardscale_h = g_standardScale_h == g_standardScale

	ScreenWidth = DeviceResolutionWidth / g_standardScale
	ScreenHeight = DeviceResolutionHeight / g_standardScale

	-- if Application.platform == RuntimePlatform.Android or Application.platform == RuntimePlatform.IPhonePlayer then
		-- ResolutionWidth = ScreenWidth * GameSettingManager.Resolution[level]
		-- ResolutionHeight = ScreenHeight * GameSettingManager.Resolution[level]	
		-- UnityEngine.Screen.SetResolution(ResolutionWidth, ResolutionHeight, true)
		-- g_standardScale = math.min(ResolutionWidth / OriginalScreenWidth,ResolutionHeight / OriginalScreenHeight)
		-- ScreenWidth = ResolutionWidth / g_standardScale
		-- ScreenHeight = ResolutionHeight / g_standardScale
	-- end

end

function define:TestScene()
	SceneControler.Instance:EnterScene(1002,Vector3(0,0,0))
end

function define:TestJson()
	local str = [[ {"status":0,"uid":"1","last_server":{"index":2,"server_id":1000001,"name":"\u6d4b\u8bd5\u670d","host":"192.168.31.133","port":9310,"status":0,"start_time":"2018-07-08 00:00:00"}} ]]
	-- local json = require "cjson"
	local json = require "cjson.safe"

	local start_time = os.clock()
	local count = 1000000
	for i=1,count do
		json.decode(str)
	end

	local end_time = os.clock()
	print('--LaoY define.lua,line 89-- data=',end_time - start_time)
end

function define:TestPost()
	local json = require "cjson"
	local function call_back(response)
		local t = json.decode(response)
		print('--LaoY define.lua,line 87-- data=',data)
		dump(t)
	end
	local url = "http://192.168.31.100/website/verify.php"
	local form = WWWForm()
	form:AddField("uid",1)
	form:AddField("platform","xwtest")
	httpMgr:ResponsePost(url,call_back,form)

	print('--LaoY define.lua,line 105--=')
end

function define:TestHttp()
	-- httpMgr:GetVerify(1,"xwtest")
	httpMgr:SelectServer(1,"xwtest")
end

function define:TestMachine()
	-- local machine = Machine()

	-- local function change_start_call_back(state_name,groove)
	-- 	print('--LaoY define.lua,line 58-- data=',state_name,groove)
	-- end

	-- local function change_finish_call_back(state_name,groove)
	-- 	print('--LaoY define.lua,line 62-- data=',state_name,groove)
	-- end
	-- machine:SetCallBack(change_start_call_back,change_finish_call_back)

	-- local machine_state
	-- machine_state = machine:CreateState("test1")
	-- local function onEnter(state_name)
	-- 	print(string.format("-----machine %s func onEnter call ----",state_name))
	-- end
	-- local function Update(state_name,delta_time)
	-- 	print(string.format("---machine %s func Update call,delta_time =%s",state_name,delta_time))
	-- end
	-- local function OnExit(state_name)
	-- 	print(string.format("---machine %s func OnExit call ----",state_name))
	-- end
	-- machine_state:SetCallBack(onEnter,Update,OnExit)

	-- machine_state = machine:CreateState("test2")
	-- machine_state:SetCallBack(onEnter,Update,OnExit)

	-- machine:ChangeState("test1")
	-- machine:ChangeState("test2")

	local machine = Machine()
	local start_index = 10
	local end_index = 7
	for i=start_index,end_index,-1 do
		local machine_state = machine:CreateState("test" .. i)
		local function onEnter(state_name)
			print(string.format("-----machine %s func onEnter call ----",state_name))
		end
		local function Update(state_name,delta_time)
			-- print(string.format("---machine %s func Update call,delta_time =%s",state_name,delta_time))
		end
		local function OnExit(state_name)
			print(string.format("---machine %s func OnExit call ----",state_name))
			local next_index = (i - 1)
			if next_index > end_index then
				machine:ChangeState("test" .. next_index)
			end
		end
		machine_state:SetCallBack(onEnter,Update,OnExit)
	end

	machine:ChangeState("test10")
	machine:ChangeState("test9")

	-- GlobalSchedule:Start(handler(machine, machine.OnExit), 0.5)
end
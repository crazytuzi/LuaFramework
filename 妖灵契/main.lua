main = {}
main.g_AppType  = "dev" --dev, banshu, release, bussiness, shenhe
main.g_SdkLogin = 0 --是否开启Sdk登录, 1开启 0关闭
main.g_TestType = 0 --1.战斗测试
main.g_IsInitDone = false
main.g_DllVer = 0 --Dll版本号, 启动脚本时初始化
main.g_ProtoVer = 96 -- 协议版本号

--C#回调 
function main.start()
	main.InitEnv()
	local function check()
		if g_ResCtrl:IsInitDone() and CNotifyView:GetView() 
		and CBottomView:GetView()then
			main.StartGame()
		else
			return true
		end
	end
	Utils.AddTimer(check, 0, 0)
end

function main.update(dt)
	local iUnScaleTime = (dt / UnityEngine.Time.timeScale)
	UnityEngine.Time:SetDeltaTime(dt, iUnScaleTime)
	g_TimerCtrl:Update()
	if main.g_IsInitDone then
		g_NetCtrl:Update()
		g_ActionCtrl:Update(dt)
		g_MagicCtrl:Update(dt)
		g_ResCtrl:Update(iUnScaleTime)
		g_WarCtrl:Update(iUnScaleTime)
		g_SysSettingCtrl:Update()
	end
	g_BatchCallCtrl:BatchCall()
	UnityEngine.Time:SetFrameCount()
end

function main.lateupdate(dt)
	g_TimerCtrl:LateUpdate()
	if main.g_IsInitDone then
		g_ActionCtrl:LateUpdate(dt)
	end
end

function main.RequireModule()
	require "logic.logic"
	require "net.net"
	if Utils.IsEditor() then
		require "logic.editor.editor"
	end
end

function main.CheckDll()
	if main.g_DllVer >= 10 then
		classtype.ChainEffect = typeof(C_api.ChainEffect)
		main.OldChainEffect = CChainEffect
		CChainEffect = CChainEffectExt
	end
end

function main.InitEnv()
	main.g_DllVer = select(2, C_api.Utils.GetResVersion())
	main.RequireModule()
	require "logic.createctrl"
	if Utils.IsDevUser() then
		CGmFunc.LocalUpdate()
	end
	main.CheckDll()
	if C_api.Utils.GetUpdateMode() == enum.UpdateMode.Update then
		Utils.UpdateLogLevel()
	end
	if Utils.IsPC() then
		main.g_SdkLogin = 0
	end
	main.GenSkipCGFile()
	main.CheckReleaseUrl()
	main.CheckUpdateData()
	-- UnityEngine.Time:SetTimeScale(2)
	UnityEngine.Time.maximumDeltaTime = 60
	UnityEngine.Random.InitState(os.time()) --随机数
	C_api.Utils.SetGlobalEventHanlder(main.call)
	protobuf.registerProto("proto/proto.pb")
	main.AdjustFrameRate()
	UITools.SetLabelEffectFactor(0.7)
	g_ResCtrl:InitLoad() --预加载资源
	g_EasyTouchCtrl:InitCtrl()
	g_UITouchCtrl:InitCtrl()
	g_SpeechCtrl:InitCtrl()
	g_ApplicationCtrl:InitCtrl()
	CNotifyView:ShowView()
	CBottomView:ShowView()
	main.g_IsInitDone = true
end

function main.CheckUpdateData()
	local lChecked = IOTools.GetClientData("data_checked_list") or {}
	local _, _, _, v = C_api.Utils.GetResVersion()
	if not table.index(lChecked, v) then
		table.insert(lChecked, v)
		IOTools.SetClientData("data_checked_list", lChecked)
		IOTools.Delete(IOTools.GetPersistentDataPath("/data"))
	end
end

function main.GenSkipCGFile()
	-- if C_api.CGPlayer.IsSkipCG() then
		local path = IOTools.GetPersistentDataPath("/skip_cg")
		if not IOTools.IsExist(path) then
			IOTools.SaveTextFile(path, "")
		end
	-- end 
end

function main.CheckReleaseUrl()
	if main.g_AppType  == "dev" then
		define.Url.Release = define.Url.Dev
	else
		if g_SdkCtrl:GetChannelId() == "kaopu" then
			define.Url.Release = "http://cbtn1.cilugame.com"
		else
			if Utils.IsIOS() then
				local dData = g_ApplicationCtrl:GetGameSettingData()
				if define.Url.IOS_Release then
					define.Url.Release = define.Url.IOS_Release
				end
			elseif Utils.IsAndroid() then
				if define.Url.Andriod_Release then
					define.Url.Release = define.Url.Andriod_Release
				end
			end
		end
	end
end

function main.ProcessScene()
	local sScveneName = Utils.GetActiveSceneName()
	if sScveneName == "editorMagic" then
		CEditorMagicView:ShowView()
		return true
	elseif sScveneName == "editorBuff" then
		CEditorBuffView:ShowView()
		return true
	elseif sScveneName == "editorAnim" then
		CEditorAnimView:ShowView()
		return true
	elseif sScveneName == "editorCamera" then
		CEditorCameraView:ShowView()
		return true
	elseif sScveneName == "editorLineup" then
		CEditorLineupView:ShowView()
		return true
	elseif sScveneName == "editorTable" then
		CEditorTableView:ShowView()
		return true
	elseif sScveneName == "editorHouse" then
		-- CEditorHouseView:ShowView()
		return true
	end
	return false
end

function main.AdjustFrameRate()
	if Utils.IsWin() then
		UnityEngine.Application.targetFrameRate = 30
	else
		UnityEngine.Application.targetFrameRate = 30
	end
	Utils.g_FrameTime = 1 / UnityEngine.Application.targetFrameRate
end

function main.ChangeFrameRate(iRate)
	UnityEngine.Application.targetFrameRate = iRate
	Utils.g_FrameTime = 1 / UnityEngine.Application.targetFrameRate
end

function main.StartGame()
	if Utils.IsEditor() then
		DataTools.RefreshData()
	end
	UnityEngine.QualitySettings.antiAliasing = 2
	
	g_HudCtrl:InitRoot()
	g_ResCtrl:LoadOnStart()
	g_ServerCtrl:InitServer()
	if main.ProcessScene() then
		g_CameraCtrl:InitCtrl()
		C_api.Utils.HideGameLoading()
		return
	elseif main.g_TestType ~= 0 then
		g_CameraCtrl:InitCtrl()
		C_api.Utils.HideGameLoading()
		main.ProcessTest(main.g_TestType)
		return
	end
	CLoginView:ShowView()
	-- CGmFunc.OpenHouseMode()
end

function main.ResetGame(lExceptViews)
	printc("重置游戏")
	printtrace()
	main.ChangeFrameRate(30)
	UnityEngine.Time:SetTimeScale(1)
	g_WarCtrl:End()
	g_AttrCtrl:ResetAll()
	g_CreateRoleCtrl:EndCreateRole()
	g_MapCtrl:Clear(false)
	g_TimeCtrl:StopBeat()
	g_ActivityCtrl:DCResetCtrl()

	local oCtrlList = {"g_ResCtrl", "g_ItemCtrl", "g_PartnerCtrl", "g_EquipFubenCtrl", "g_MapCtrl", 
	"g_TeamCtrl", "g_AnLeiCtrl", "g_ActivityCtrl", "g_NotifyCtrl", "g_TeachCtrl", "g_OrgCtrl", 
	"g_NpcShopCtrl", "g_TaskCtrl", "g_ScheduleCtrl", "g_HouseCtrl", "g_ArenaCtrl", "g_SkillCtrl", 
	"g_TalkCtrl", "g_LinkInfoCtrl", "g_FriendCtrl", "g_ChatCtrl", "g_DialogueAniCtrl", "g_EqualArenaCtrl",
	"g_PowerGuideCtrl", "g_TravelCtrl", "g_AchieveCtrl", "g_GuideCtrl", "g_FieldBossCtrl", "g_MapBookCtrl",
	"g_WelfareCtrl", "g_OnlineGiftCtrl", "g_PlayerBuffCtrl", "g_ChapterFuBenCtrl", "g_SceneExamCtrl", "g_MonsterAtkCityCtrl",
	"g_RankCtrl", "g_TeamPvpCtrl", "g_ConvoyCtrl", "g_TitleCtrl", "g_TreasureCtrl", "g_ChoukaCtrl", "g_WindowTipCtrl",
	"g_OrgWarCtrl", "g_HuntPartnerSoulCtrl", "g_MarryCtrl", "g_ClubArenaCtrl", "g_GradeGiftCtrl"}
	for _, ctrlName in ipairs(oCtrlList) do
		local oCtrl = _G[ctrlName]
		if oCtrl and oCtrl.ResetCtrl then
			oCtrl:ResetCtrl()
		end
	end
	lExceptViews = lExceptViews or {}
	g_ViewCtrl:CloseAll(lExceptViews)
	g_ResCtrl:GC(true)
end

function main.ProcessTest(iType)
	if iType == 1 then
		warsimulate.Test()
		--g_MapCtrl:Load(6000)
	elseif iType == 2 then
		g_ShowWarCtrl:LoadShowWar("Boss")
	elseif iType == 3 then
		CConnectView:ShowView()
	elseif iType == 4 then
		CSysSettingView:ShowView()
	elseif iType == 5 then
		CPartnerMainView:ShowView()
	elseif iType == 6 then
		g_MapCtrl:Load(6000, 1)
		g_HouseCtrl:EnterHouse()
	elseif iType == 7 then
		CItemBagMainView:ShowView()
	elseif iType == 99 then
	end
end


function main.Test()
	local mri = require("memory.MemoryReferenceInfo")
	mri.m_cConfig.m_bAllMemoryRefFileAddTime = false
	collectgarbage("collect")
	print(collectgarbage("count"))
	
	mri.m_cMethods.DumpMemorySnapshot("./mem", "1-Before", -1)
end


function main.Test2()
	print(22222222222)
	local mri = require("memory.MemoryReferenceInfo")
	mri.m_cConfig.m_bAllMemoryRefFileAddTime = false



	collectgarbage("collect")
	print(collectgarbage("count"))

	mri.m_cMethods.DumpMemorySnapshot("./mem", "2-After", -1)

	collectgarbage("collect")
	mri.m_cMethods.DumpMemorySnapshotComparedFile("./mem", "Compared", -1, "./mem/LuaMemRefInfo-All-[1-Before].txt", "./mem/LuaMemRefInfo-All-[2-After].txt")


end

function main.Test3()
	collectgarbage("collect")
	print(collectgarbage("count"))
end

function main.call(id, ...)
	return g_DelegateCtrl:CallDelegate(id, ...)
end

return main

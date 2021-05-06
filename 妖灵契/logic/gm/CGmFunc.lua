module(..., package.seeall)
function testwalk()
local oHero = g_MapCtrl:GetHero()
	local pos = oHero:GetPos()
	local x = pos.x
	oHero:WalkTo(x+1, pos.y, function() 
			oHero:WalkTo(x-1, pos.y, function() 
					oHero:WalkTo(x+1, pos.y)
				end)
		end)
end

function demitest()
	define.DemiFrame.GameID = define.DemiFrame.TestGameID
	define.DemiFrame.NormalUrl = define.DemiFrame.TestUrl
	g_NotifyCtrl:FloatMsg("切换到demi测试环境")
end
-- 17 3611
function cutrecord(iStart, iEnd)
	iStart = tonumber(iStart)
	iEnd = tonumber(iEnd)
	local list = IOTools.GetFilterFiles(IOTools.GetAssetPath("/Other/warbug/"), function(s) return string.find(s, "%.meta$") == nil end, true)
	local list1 = IOTools.GetFilterFiles(g_NetCtrl:GetRecordFilePath(""), function(s) return string.find(s, "%.meta$") == nil end, true)
	talbe.extend(list, list1)
	local function wrapFunc(v)
		return IOTools.GetFileName(v, false)
	end
	local function selFunc(v)
		local dRecord = g_NetCtrl:LoadRecordsFromLocal(v)
		g_NetCtrl:CutRecord(dRecord, iStart, iEnd)
	end

	CMiscSelectView:ShowView(function(oView)
			oView:SetData(list, selFunc, wrapFunc)
		end)
end

function rpcfile(pid)
	local pid = tonumber(pid)
	if pid then
		local path = IOTools.GetPersistentDataPath("/testcode.lua")
		if IOTools.IsExist(path) then
			local s = IOTools.LoadTextFile(path)
			if s then
				netother.C2GSGMRequire(pid, s)
				CGmConsoleView:ShowView()
				return
			end
		end
		g_NotifyCtrl:FloatMsg("没有找到文件:"..path)
		
	else
		g_NotifyCtrl:FloatMsg("参数错误")
	end
end

function testspeed(i)
	UnityEngine.Time:SetTimeScale(tonumber(i))
	define.War.SpeedFactor = 0.7*i
end

function wardebug()
	if g_WarCtrl:IsWar() then
		local action = g_WarCtrl.m_MainActionList[1]
		local sAction = ""
		local varargs = {}
		local vararglen = 1
		if action then
			local func, args, arglen = unpack(action, 1, 3)
			local info = debug.getinfo(func)
			sAction = sAction.." info.linedefined:"..tostring(info.linedefined)
			sAction = sAction.." info.short_src:"..tostring(info.short_src)
			varargs = args
			vararglen = arglen
		end
		printerror(
			"g_WarCtrl.m_ActionFlag:", g_WarCtrl.m_ActionFlag,
			"g_MagicCtrl:IsExcuteMagic():", g_MagicCtrl:IsExcuteMagic(),
			"g_WarCtrl:IsAllExcuteFinish():", g_WarCtrl:IsAllExcuteFinish(),
			sAction, unpack(varargs, 1, vararglen)
		)
		g_NotifyCtrl:FloatMsg("wardebug 已打印")
	else
		g_NotifyCtrl:FloatMsg("wardebug fail")
	end
end

function testphonex()
	g_ApplicationCtrl:PhoneXProcess()
end

function testpath()
	local oHero = g_MapCtrl:GetHero()
	local MapTable = data.patroldata.DATA
	g_MapCtrl.m_Mydata = {}
	g_MapCtrl.m_MydataTempMap = nil
	g_MapCtrl.m_IsInGetPartolData = false

	local update = function ()
		if table.count(g_MapCtrl.m_Mydata) == table.count(MapTable) then
			printc(">>>路径生成完毕")
			g_NotifyCtrl:FloatMsg(">>>路径生成完毕")			
			
			local t = {}
			for k,v in pairs(g_MapCtrl.m_Mydata) do
				t[k] = t[k] or {}
				for _k, _v in pairs(v) do
					local info = string.split(_k, ",")
					if info and #info == 4 then
						local str1 = string.format("%d,%d", tonumber(info[1]), tonumber(info[2]))
						t[k][str1] = t[k][str1] or {}
						local str2 = string.format("%d,%d", tonumber(info[3]), tonumber(info[4]))
						local temp = {}
						for __i , __v in ipairs(_v) do
							table.insert(temp, {x = math.floor(__v.x * 1000), y = math.floor(__v.y * 1000) })
						end
						t[k][str1][str2] = temp
					end
				end
			end
			table.print(t)
			local s = "module(...)\n--anleipartol editor build\n"..table.dump(t, "DATA")
			IOTools.SaveTextFile(IOTools.GetAssetPath("/Lua/logic/dialogue/dialogueanifile/AnLeiPartolData.lua"), s)	
			g_MapCtrl.m_IsInGetPartolData = nil
			return false
		end
		for k,v in pairs(MapTable) do
			if g_MapCtrl.m_IsInGetPartolData == false and g_MapCtrl.m_MydataTempMap == nil and g_MapCtrl.m_Mydata[k] == nil then
				printc(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>正在生成 ", k)
				g_MapCtrl.m_MydataTempMap = k
				g_MapCtrl.m_IsInGetPartolData = true
				if k * 100 ~= g_MapCtrl:GetMapID() then
					netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, k * 100)
				else
					g_MapCtrl:GetPartolData()
				end			
			end			
		end
		return true
	end

	Utils.AddTimer(update, 0.2, 0.2)
end

function testboss()
	g_ShowWarCtrl:LoadShowWar("Boss")
end

function SaveGuideConfigData()
	local t = {} 
	local iType = 1			--引导大类
	local idx = 1			--每个大类引导编号

	--基本引导类型
	local data1 = {"grade", "war", "view", "custom"}
	local d = data.guidedata.Trigger_Check
	for i,v in ipairs(data1) do 
		local temp = d[v]
		for _k, _v in ipairs(temp) do
			--每一个引导的结束，都是99,间隔100
			local guidedata = data.guidedata[_v] 
			if guidedata then
				local del_table = {}
				if guidedata.guide_list and #guidedata.guide_list > 0 then					
					for __i = 0 , #guidedata.guide_list do
						local server_key = iType * 1000000 + idx * 100 + __i
						table.insert(del_table, server_key)
						table.insert(t, {server_key = server_key,  key = string.format("N1Guide_%s_%d", _v, __i), del_key = {}})
					end
				end
				if #del_table > 2 then
					local temp = {}
					temp[1] = del_table[1]
					temp[2] = del_table[#del_table]
					del_table = temp
				end				
				table.insert(t, {server_key = iType * 1000000 + idx * 1000 + 99,  key = string.format("N1Guide_%s", _v), del_key = del_table, main = true,})
			end	
			idx = idx + 1		
		end
		iType = iType + 1
		idx = 1
	end

	--触发型引导类型
	local other1 = data.guidedata.Tips_Trigger
	for k, v in ipairs(other1) do
		--每一个引导的结束，都是99,间隔100
		local guidedata = data.guidedata[v] 
		if guidedata then
			local del_table = {}
			if guidedata.guide_list and #guidedata.guide_list > 0 then				
				for _i = 0 , #guidedata.guide_list do
					local server_key = iType * 1000000 + idx * 100 + _i
					table.insert(del_table, server_key)
					table.insert(t, {server_key = server_key,  key = string.format("N1Guide_%s_%d",v, _i), del_key = {}})
				end		
			end
			if #del_table > 2 then
				local temp = {}
				temp[1] = del_table[1]
				temp[2] = del_table[#del_table]
				del_table = temp
			end				
			table.insert(t, {server_key = iType * 1000000 + idx * 1000 + 99,  key = string.format("N1Guide_%s", v), del_key = del_table, main = true,})
		end	
		idx = idx + 1	
	end
	iType = iType + 1
	idx = 1

	--任务标记引导类型
	local other2 = data.guidedata.Task_Guide
	for i,v in ipairs(other2) do
		--每一个引导的结束，是任务Id
		table.insert(t, {server_key = iType * 1000000 + v, key = string.format("N1Guide_Complete_Task_%d", v), del_key = {}, main = true,})
	end
	iType = iType + 1
	idx = 1

	--其他引导类型
	local other3 = data.guidedata.Other_Guide
	for k, v in ipairs(other3) do		
		--每一个引导的结束，是1，间隔是10
		table.insert(t, {server_key = iType * 1000000 + idx * 10 + 1,  key = string.format("N1Guide_%s", v), del_key = {}, main = true,})
		idx = idx + 1
	end
	iType = iType + 1
	idx = 1

	--key to value
	local t1 = {}
	for i, v in ipairs(t) do
		t1[v.server_key] = {value = v.key, del_key = v.del_key} 
	end
	--value to key
	local t2 = {}
	for i, v in ipairs(t) do
		t2[v.key] = {key = v.server_key, del_key = v.del_key} 		
	end	
	local s1 = "module(...)\n-- guidance editor build\n"..table.dump(t1, "KeyToValue").."\n"..table.dump(t2, "ValueToKey").."\n"..table.dump(t, "DATA")
	IOTools.SaveTextFile(IOTools.GetAssetPath("/Lua/logic/data/guideconfigdata.lua"), s1)
	local s2 = "-- guidance editor build\n"..table.dump(t1, "KeyToValue").."\n"..table.dump(t2, "ValueToKey").."\n"..table.dump(t, "DATA").."\n".."return KeyToValue"
	IOTools.SaveTextFile(IOTools.GetAssetPath("/Lua/logic/data/client_guideconfigdata.lua"), s2)	
end

function PowerGuideDebug(self )
	g_PowerGuideCtrl.m_Debug = not g_PowerGuideCtrl.m_Debug
end

function testjson(...)
	str = table.concat({...}, " ")
	printc(str)
	table.print(decodejson(str), "json解析:")
end

function test11()
	CPushSettingView:ShowView()
end

function timescale()
	g_NotifyCtrl:FloatMsg("速度:"..tostring(UnityEngine.Time.timeScale))
end

function warprepare()
	warsimulate.testpartner()
	warsimulate.Start(1, 130, 2000)
	warsimulate.Prepare()
end

function testshare()
	local rt = Utils.ScreenShoot(g_CameraCtrl:GetUICamera(), 1334, 750)
	local texture2D = UITools.GetRTPixels(rt)
	local path = IOTools.GetPersistentDataPath("/test.jpg")
	IOTools.SaveByteFile(path, texture2D:EncodeToJPG())
	g_NotifyCtrl:FloatMsg("测试分享")
	g_ShareCtrl:ShareImage(path, "", function (platid)
		printc("testshare:", platid)
	end)
end

function testandroid1()
	g_AndroidCtrl:StartYsdkVip()
	g_NotifyCtrl:FloatMsg("StartYsdkVip")
end

function testandroid2()
	g_AndroidCtrl:StartYsdkBbs()
	g_NotifyCtrl:FloatMsg("StartYsdkBbs")
end

function testandroid3()
	print("testandroid3?????????????", g_AndroidCtrl:GetLoginType())
	g_NotifyCtrl:FloatMsg("GetLoginType")
end

function testandroid4()
	print("testandroid4?????????????", g_AndroidCtrl:IsNotSupported())
	g_NotifyCtrl:FloatMsg("IsNotSupported")
end

function uploadwar()
	if not g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗中才能使用")
		return
	end
	local windowInputInfo = {
		des             = "请描述战斗遇到的异常",
		title           = "反馈bug",
		inputLimit      = 960,
		okCallback      = function(oInput)
			local sInput = oInput:GetText()
			local sTime = os.date("%y_%m_%d(%H_%M_%S)",g_TimeCtrl:GetTimeS())
			local sKey = string.format("war_pid%d_%s_%s", g_AttrCtrl.pid, sTime, sInput)
			g_NetCtrl:SaveRecordsToServer(sKey, {side=g_WarCtrl:GetAllyCamp()})
		end,
		isclose = true,
	}
	g_WindowTipCtrl:SetWindowInput(windowInputInfo)
end

function remoteuploadwar(pid)
	pid = tonumber(pid)
	if pid then
		netother.C2GSGMRequire(pid, "rpcfunc.uploadwar()")
	else
		g_NotifyCtrl:FloatMsg("请输入玩家id")
	end
	
end

function testpay()
	if Utils.IsAndroid() then
		CAndroidShopView:ShowView()
	else
		CIOSShopView:ShowView()
	end
	-- CAndroidShopView:ShowView()
end

function DumpLuaDataFile()
	C_api.Utils.DumpLuaDataFile()
end

function test1()
	for i=1, 1 do
		g_NotifyCtrl:FloatMsg("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"..tostring(i))
	end
end

function server()
	local path = IOTools.GetPersistentDataPath("/server_list.json")
	IOTools.SaveJsonFile(path, g_ServerCtrl.g_DevServer)
end

function forcesaverecord()
	g_NetCtrl:SaveRecordsToLocal("war"..os.date("%y_%m_%d(%H_%M_%S)", g_TimeCtrl:GetTimeS()), {side=g_WarCtrl:GetAllyCamp()})
end

function reconnect()
	-- g_MapCtrl:Load(1010, Vector3.New(10, 10, 10))
	-- Utils.AddTimer(function() g_MapCtrl:Load(2080, Vector3.New(12, 12, 12)) end, 0, 0)
	-- Utils.AddTimer(function() g_MapCtrl:Load(1010, Vector3.New(12, 12, 12)) end, 0, 0)
	-- Utils.AddTimer(function() g_MapCtrl:Load(2080, Vector3.New(12, 12, 12)) end, 0, 0)
	-- Utils.AddTimer(function() g_MapCtrl:Load(1010, Vector3.New(12, 12, 12)) end, 0, 0)
	-- Utils.AddTimer(function() g_MapCtrl:Load(2080, Vector3.New(12, 12, 12)) end, 0, 0)
	g_LoginCtrl:Reconnect()
end

function banguide()
	-- CGuideCtrl.LoginInit = function() end
	g_NotifyCtrl:FloatMsg("停止新手引导")
	IOTools.SetClientData("banguide", true)
end

function openlog()
	IOTools.SetClientData("logflag", 1)
	Utils.UpdateLogLevel()
	g_NotifyCtrl:FloatMsg("开启log")
end

function closelog()
	IOTools.SetClientData("logflag", 0)
	Utils.UpdateLogLevel()
	g_NotifyCtrl:FloatMsg("关闭log")
end

function setSubChannel(str)
	IOTools.SetClientData("SDKSubChannel", str)
end

function setGameType(str)
	IOTools.SetClientData("TestGameType", str)
end

function setChannel(str)
	IOTools.SetClientData("SDKChannel", str)
end

function showitem(sid, virtual)
	sid = sid or 405
	virtual = virtual or 0
	local item_list = {
			[1] = {
				amount = 1,
				sid = tonumber(sid),
				virtual = tonumber(virtual),
			}
		}
	g_WindowTipCtrl:SetWindowAllItemRewardList(item_list)
end

function openguide()
	-- CGuideCtrl.LoginInit = function() end
	g_NotifyCtrl:FloatMsg("开启新手引导")
	IOTools.SetClientData("banguide", false)
end

function testguide1()
	CGuideView:ShowView(function(oView)
		oView.m_EventWidget:SetActive(false)
		oView.m_FocusBox.m_Collider:SetActive(false)
			-- oView.m_FocusBox.m_Mat:SetVector("_SkipRange", Vector4.New(0.5, 0.5, 0.2, 0.2))
		end)
end

function code(content)
	local  f = loadstring(content)
end

function testguide2()
	CGuideView:ShowView(function(oView)
		-- oView.m_EventWidget:SetActive(false)
		-- oView.m_FocusBox.m_Collider:SetActive(false)normalupdate
			oView.m_FocusBox.m_Mat:SetVector("_SkipRange", Vector4.New(0.5, 0.5, 0.1, 0.1))
			oView.m_FocusBox:SimulateOnEnable()
		end)
end


function testupdate()
	g_NotifyCtrl:FloatMsg("测试更新模式, 请重启")
	IOTools.SaveTextFile(IOTools.GetPersistentDataPath("/testupdate"), "")
end

function normalupdate()
	g_NotifyCtrl:FloatMsg("正常更新模式, 请重启")
	IOTools.Delete(IOTools.GetPersistentDataPath("/testupdate"))
end

function pfmeditor()
	require "logic.editor.editor"
	g_ViewCtrl:CloseAll()
	main.ResetGame()
	CEditorMagicView:ShowView()
end

function MapCameraSize(i)
	local i = tonumber(i)
	if i then
		g_CameraCtrl:SetMapCameraSize(i)
	end
end

function testview()
	--g_ResCtrl:LoadCloneAsync("Model/Character/130/Prefabs/model130.prefab", function(oClone, path)  printc(">>>>>>>>", oClone, path)end)
	CTestView:ShowView()
end

function record()
	-- g_NetCtrl:PlayRecord("war17_05_05-14-27-41")
	local list = IOTools.GetFilterFiles(IOTools.GetAssetPath("/Other/warbug/"), function(s) return string.find(s, "%.meta$") == nil end, true)
	local list1 = IOTools.GetFilterFiles(g_NetCtrl:GetRecordFilePath(""), function(s) return string.find(s, "%.meta$") == nil end, true)
	table.extend(list, list1)
	local function wrapFunc(v)
		return IOTools.GetFileName(v, false)
	end
	local function selFunc(v)
		g_NetCtrl:PlayRecord(v)
	end

	CMiscSelectView:ShowView(function(oView)
			oView:SetData(list, selFunc, wrapFunc)
		end)
end

function console()
	CGmConsoleView:ShowView(function(oView)
			oView:ShowPrint()
		end)
end

function testgc1()
	main.cnt = 0
	collectgarbage("collect")
	local i1= main.Test2()
	local function t()
		local cls = CItemBagMainView
		if cls:GetView() then
			cls:CloseView()
			collectgarbage("collect")
		else
			cls:ShowView()
		end
		main.cnt = main.cnt +1
		if main.cnt < 400 then
			return true
		else
			g_ItemCtrl:Clear()
			g_AttrCtrl:Clear()
			g_UITouchCtrl:Clear()
			g_DelegateCtrl:Clear()
			g_ViewCtrl:Clear()
			-- table.print(g_ViewCtrl)
			local i2 = main.Test2()
			printerror("-->Add", i2-i1)
			return false
		end
	end

	Utils.AddTimer(t, 0.03, 0.1)
end

function testgc2()
	collectgarbage("collect")
	collectgarbage("collect")
	local i = collectgarbage("count")
	printc('内存为' .. i, table.count(g_DelegateCtrl.m_Delgates))
	return i
end

function gc()
	CGmView:CloseView()
	local count1 = collectgarbage("count")
	g_ResCtrl:UnloadAtlas(false)
	local time1 = g_TimeCtrl:GetTimeMS()
	g_ResCtrl:CheckManagedAssets(function(oAssetInfo) oAssetInfo:SetNextScneneRelease(false) end)
	collectgarbage()
	g_ResCtrl:GCFinish()
	local count2 = collectgarbage("count")
	g_NotifyCtrl:FloatMsg(string.format("时间: %d, 回收前%d, 回收后%d", g_TimeCtrl:GetTimeMS()-time1, count1, count2))
end

function gcarg(mul, pause)
	mul = tonumber(mul)
	pause = tonumber(pause)
	printerror("设置", mul, pause)
	if mul then
		collectgarbage("setstepmul", mul)
	end
	if pause then
		collectgarbage("setpause", pause)
	end
end

function luamem()
	print(collectgarbage("count"))
end

function testgc()
	-- local time = g_TimeCtrl:GetTimeMS()
	-- print("回收前:" , collectgarbage("count"))
	-- local i = 3000
	-- while collectgarbage("step", i) == false do
	-- 	i = i+1
	-- 	print("回收后:" , collectgarbage("count"), collectgarbage("step", 0)collectgarbage("count"), i)
		
	-- end
	-- print("回收后:" , collectgarbage("count"), i)
end

function testhouse()
	local t = {type=1, lock_status=1, level=2, secs = 0}
	nethouse.GS2CFurnitureInfo({furniture_info=t})
end

function maptime()
	g_MapCtrl.m_FloatTime = true
end

function parresult()
	netpartner.GS2CDrawCardResult({type=1, partner_list={1000,1001,1002}})
end

function sendbig()
	nettest.C2GSTestBigPacket(string.rep("A", 1024*1024))
end

function test()
	g_AttrCtrl:SchoolChange()
end

function map(id)
	id = tonumber(id) or 5000
	-- light = tonumber(light) or 1
	clientlogin()
	if id == 6000 then
		g_HouseCtrl:EnterHouse()
	elseif id == 6100 then
		warsimulate.Start(1, 140)
		return
	end
	g_MapCtrl:Load(id, {x=0,y=0,z=0})
end

function teamfollow(cnt)
	local oHero = g_MapCtrl:GetHero()
	local pos = oHero:GetPos()
	local list = {g_AttrCtrl.pid}
	cnt = cnt and tonumber(cnt) or 1
	for i=1, cnt do
		local dPlayer = {
			eid = 10000+i,
			pid = 10000+i,
			pos_info = {x=pos.x+i, y = pos.y+i},
			block = {
				mask = 3,
				name = "Player"..tostring(i),
				model_info = {shape=140, weapon=2000},
			}
		}
		g_MapCtrl:AddPlayer(dPlayer.pid, dPlayer)
		table.insert(list, dPlayer.pid)
	end
	netscene.GS2CSceneCreateTeam({scene_id=g_MapCtrl:GetSceneID(), team_id=1, pid_list=list})
	netscene.GS2CSceneCreateTeam({scene_id=g_MapCtrl:GetSceneID(), team_id=1, pid_list=list})
	-- g_MapCtrl:DelWalker(10000+1)
	-- local i = 2
	-- local dPlayer = {
	-- 	eid = 10000+i,
	-- 	pid = 10000+1,
	-- 	pos_info = {x=pos.x+i, y = pos.y+i},
	-- 	block = {
	-- 		mask = 3,
	-- 		name = "Player"..tostring(1),
	-- 		model_info = {},
	-- 	}
	-- }
	-- g_MapCtrl:AddPlayer(dPlayer.pid, dPlayer)
end

function testspeech()
	CSpeechCtrl.g_TestSpeech = true
end

function playerspeech(iMax)
	iMax = tonumber(iMax) or 1
		for i =1, iMax do
		local dMsg = {
			channel = 1,
			text = LinkTools.GenerateSpeechLink("testplayerspeech"..tostring(i), "别人发的语音"),
			role_info = {
				pid = 999888,
				grade = 50,
				name = "deep",
				shape = 140,
			},
		}
		g_ChatCtrl:AddMsg(dMsg)
	end
end

function testprofiler(cnt)
	local oHero = g_MapCtrl:GetHero()
	local pos = oHero:GetPos()
	local list = {g_AttrCtrl.pid}
	cnt = cnt and tonumber(cnt) or 20
	for i=1, cnt do
		local dPlayer = {
			eid = 10000+i,
			pid = 10000+i,
			pos_info = {x=pos.x, y = pos.y},
			block = {
				mask = 3,
				name = "Player"..tostring(i),
				model_info = {shape = 3120+i%23},
			}
		}
		g_MapCtrl:AddPlayer(dPlayer.pid, dPlayer)
		table.insert(list, dPlayer.pid)
	end
end

function testchat(sText)
	local dMsg = {
		channel = 1,
		text = sText,
		role_info = {
			pid = g_AttrCtrl.pid,
			grade = 50,
			name = "deep",
			shape = 140,
		},
	}
	g_ChatCtrl:AddMsg(dMsg)
end

function shape(sShape)
	local oHero = g_MapCtrl.m_Hero
	oHero:ChangeShape(tonumber(sShape))
end

function weapon(sWeapon)
	local oActor = g_MapCtrl.m_Hero.m_Actor
	local desc = oActor.m_CurDesc
	desc.weapon = tonumber(sWeapon)
	oActor:ChangeShape(oActor:GetShape(), desc)
end

-- function weapon(i)
-- 	i = tonumber(i) or nil
-- 	local oHero = g_MapCtrl:GetHero()
-- 	if oHero then
-- 		local model_info = table.copy(oHero.m_Actor.m_CurDesc)
-- 		model_info.weapon=i
-- 		oHero:ChangeShape(model_info.shape, model_info)
-- 	end
-- end

function horse(i)
	i = tonumber(i) or nil
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		local model_info = table.copy(oHero.m_Actor.m_CurDesc)
		model_info.horse=i
		oHero:ChangeShape(model_info.shape, model_info)
	end
end

function clientlogin()
	g_AttrCtrl:UpdateAttr({pid = 10000, name="一个人", model_info ={shape=140, weapon=nil, horse=nil}})
	g_MapCtrl:ShowScene(1, 101000, "单机")
	g_MapCtrl:EnterScene(1, {x=10, y = 10})

	CLoginView:CloseView()
	CMainMenuView:ShowView()
	CGmView:CloseView()
	g_AttrCtrl:LoginInit()
end

function printsyncpos()
	data.netdata.BAN["print"]["scene"] = {}
end

function xunluo()
	local oHero = g_MapCtrl:GetHero()
	oHero:StartPatrol()
end

function recteffect()
	local oView = CLoginView:GetView()
	if oView then
		oView.m_AccountPart.m_LoginBtn:AddEffect("Rect")
	end
end

function ShowWalkerView()
	CModelActionView:ShowView()
end

function Beat(i)
	g_TimeCtrl.m_BeatDelta = tonumber(i) or 5
end

function LocalUpdate()
	local path = IOTools.GetPersistentDataPath("/localcode.lua")
	if IOTools.IsExist(path) then
		local s = IOTools.LoadTextFile(path)
		if s then
			loadstring(s)()
			g_NotifyCtrl:FloatMsg("本地更新完成")
		else
			g_NotifyCtrl:FloatMsg("本地更新失败")
		end
	end
end

function printgc()
	function CResCtrl.GC(self, bAllGC)
		if self.m_ReleaseAssetCnt >= data.resdata.GcAssetReleaseCnt then
			self.m_LastGCTime = g_TimeCtrl:GetTimeS()
			LinkTools.ClearAllLinkCache()
			self:CheckManagedAssets(function(oAssetInfo) oAssetInfo:SetNextScneneRelease(false) end)
			self.m_AllGC = self.m_OpenAllGC and bAllGC
			self.m_GCSteping = true
			print("res gc step start!")
		else
			printc("res gc skip! m_ReleaseAssetCnt:", self.m_ReleaseAssetCnt)
		end
	end
	function CResCtrl.UnloadAtlas(self)
		self.m_UnloadAtlasCounter = define.View.AtlasCount
		Utils.DebugCall(function() C_api.ResourceManager.UnloadAtlas() end, "UnloadAtlas")
	end
	function CResCtrl.GCStep(self)
		if self.m_GCSteping then
			if self.m_AllGC then
				Utils.DebugCall(function()
					collectgarbage()
					self.m_GCSteping = false
					self.m_AllGC = false
					self:GCFinish()
				end, "res gc collectgarbage!")
			else
				Utils.DebugCall(function()
					local b = collectgarbage("step", data.resdata.GCStep)
					if b then
						self.m_GCSteping = false
						self:GCFinish()
					end
				end, "res gc step!")
			end
		end
	end
	function CMapCtrl.LoadMap2d(self, map2d, resid, pos)
		local mapobj
		Utils.DebugCall(function() mapobj = map2d:Load(resid, pos) end, "LoadMap2d!")
		return mapobj
	end

	function CNotifyView.ProcessFloatMsgList(self)
		DOTween.DOKill(self.m_FloatTable.m_Transform, true)
		if self.m_AnimFloatBox then
			DOTween.DOKill(self.m_AnimFloatBox.m_Transform, true)
		end
		for i, sText in ipairs(self.m_MsgList) do
			local oBox = self.m_FloatBoxClone:Clone()
			oBox:SetText(string.getstringdark(sText))
			oBox:SetTimer(5, callback(self, "OnTimerUp"))
			if i == #self.m_MsgList then
				self:AddBoxWithAnim(oBox)
			else
				oBox:SetActive(true)
				oBox:ResizeBg()
				self.m_FloatTable:SetLocalPos(Vector3.zero)
				self.m_FloatTable:AddChild(oBox)
				oBox:SetAsFirstSibling()
			end
		end
		self.m_MsgList = {}
	end
end

function updatecode()
	local s = require "logic.updatecode"
	local mt = getmetatable(_G)
	setmetatable(_G, {})
	loadstring(s)()
	setmetatable(_G, mt)
	g_NotifyCtrl:FloatMsg("测试更新完成"..tostring(#s))
end

function ShowServerTime()
	local oView = CNotifyView:GetView()
	if oView then
		oView:SwitchServerTime(true)
	end
end

function LuaReplace()
	local filelist = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic"), "*.lua", true)
	for i, fielname in ipairs(filelist) do
		local newname = string.gsub(fielname, "Page", "TEMP000")
		if newname ~= fielname then
			IOTools.Move(fielname, newname)
		end
	end
	local filelist = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic"), "*.lua", true)
	for i, fielname in ipairs(filelist) do
		local newname = string.gsub(fielname, "Partner", "TEMP001")
		newname = string.gsub(newname, "Part", "Page")
		if newname ~= fielname then
			IOTools.Move(fielname, newname)
		end
	end
	local filelist = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic"), "*.lua", true)
	for i, fielname in ipairs(filelist) do
		local newname = string.gsub(fielname, "TEMP000", "Part")
		newname = string.gsub(newname, "TEMP001", "Partner")
		if newname ~= fielname then
			IOTools.Move(fielname, newname)
		end
	end

	local filelist = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic"), "*.lua", true)
	for i, fielname in ipairs(filelist) do
		local s = IOTools.LoadTextFile(fielname)
		s = string.gsub(s, "Page","TEMP000")
		s = string.gsub(s, "Partner","TEMP001")
		s = string.gsub(s, "Part","Page")
		s = string.gsub(s, "TEMP000","Part")
		s = string.gsub(s, "TEMP001","Partner")
		IOTools.SaveTextFile(fielname, s)
	end
end

function UpdateMagicFile()
	local patlist = {}
	local idx = 0
	CEditorMagicView:ShowView()
	CEditorMagicBuildCmdView:ShowView()
	local nilfunc = function()end
	CEditorMagicView.RefreshWar = nilfunc
	CEditorComplexArgBox.GetChangeFunc = nilfunc
	CEditorNormalArgBox.SetValueChangeFunc = nilfunc
	CEditorMagicBuildCmdView.OnConfirm= function(o)
		local dCmd = o:GetCmdData()
		if o.m_ConfirmCallback then
			o.m_ConfirmCallback(o.m_Idx, dCmd)
		end
	end
	local function update()
		local oView = CEditorMagicView:GetView()
		local oBuildCmdView = CEditorMagicBuildCmdView:GetView()
		if oView and oBuildCmdView then
			local paths = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic/magic/magicfile"), "*.lua", false)
			oBuildCmdView:SetConfirmCB(callback(oView.m_CmdListBox, "OnCmdViewConfirm"))
			-- paths = {"D:/workspaces/N1/client/trunk/Assets/Lua/logic/magic/magicfile/magic_0_1.lua"}
			for i, path in ipairs(paths) do
				if not table.index(patlist, path) then			
					oView:LoadMagicFile(path)
					local list = oView.m_LoadData.cmds
					--单独插入一条指令
					--table.insert(list,{args={alive_time=0.5,},func_name=[[Name]],start_time=0,})
					if list then
						for idx, dData in ipairs(list) do
							oBuildCmdView.m_AllData = {}
							oBuildCmdView.m_OldStartTime = 0
							oBuildCmdView.m_CurCmdName = nil
							oBuildCmdView.m_ArgsTable:Clear()
							oBuildCmdView:SetCmdIdxAndData(idx, dData)
							oBuildCmdView:OnConfirm()
						end
						oView:OnSaveFile()
					end
					table.insert(patlist, path)
					idx = idx + 1
					print(idx)
					return true
				end
			end
			printc("Done")
			return false
		else
			return true
		end
	end
	Utils.AddTimer(update, 0, 0)
end

function FloatTimeFile()
	local paths = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic/magic/magicfile"), "*.lua", false)
	local dMap = {}
	for _, path in ipairs(paths) do
		local _, magic, index = unpack(string.split(path, "_"))
		index = unpack(string.split(index, "."))
		local s = string.format("magic_%s_%s", magic, index)
		local d = require("logic.magic.magicfile."..s)
		-- printc(d.magic_anim_start_time)
		if d.DATA.magic_anim_end_time then
			dMap[tonumber(magic)] = {}
			for k, path in ipairs(paths) do
				local _, magic2, index2 = unpack(string.split(path, "_"))
				index2 = unpack(string.split(index2, "."))
				local s2 = string.format("magic_%s_%s", magic2, index2)
				local d2 = require("logic.magic.magicfile."..s)
				if d2.DATA.magic_anim_start_time then
					local iVal = -d2.DATA.magic_anim_start_time
					if iVal < 0 then
						printc(path)
						dMap[tonumber(magic)][tonumber(magic2)] = iVal
					end
				end
			end
		end
	end
	local path = IOTools.GetAssetPath("/floattime.lua")
	local s = "module(...)\n--magic editor build\n"..table.dump(dMap, "DATA")
	IOTools.SaveTextFile(path, s)
	g_NotifyCtrl:FloatMsg("保存成功  "..path)
	printc("保存成功  "..path)
end


function changeAttrMainLayer(t1, t2)
	CItemPartnerEquipSoulSelectView:ShowView(function (oView)
		-- body
	end)
	--g_GuideCtrl:StartTipsGuide("Tips_HBSX")
	--g_DialogueAniCtrl:FindMapPath({x = 16, y = 30}, {x = 17, y = 28} )
	-- local t = tonumber(t)
	-- printc(">>>>> t ", t)
	-- g_DialogueAniCtrl:SaveLayerAniData(t)
	

	--g_TaskCtrl:DoNextRoundShimenTask()
	-- local oHero = g_MapCtrl:GetHero()

	-- if oHero then
	-- 	oHero:SetTaskChatHud(true, {"1111", "2222"})
	-- end
	
	-- g_AttrCtrl.m_SSId = g_AttrCtrl.m_SSId or 10021 
	-- g_AttrCtrl.m_SSId = g_AttrCtrl.m_SSId + 1

	-- CItemQuickUseView:ShowView(function (oView )
	-- 	oView:SetItem(CItem.NewBySid(g_AttrCtrl.m_SSId))
	-- 	oView:SetActive(false)
	-- 	oView:CloseView()
	-- end)

	-- g_AttrCtrl.m_SSId = g_AttrCtrl.m_SSId + 1

	-- CItemQuickUseView:ShowView(function (oView )
	-- 	oView:SetItem(CItem.NewBySid(g_AttrCtrl.m_SSId))
	-- end)
	-- CAnLeiRewardListView:ShowView(function (oView)
	-- 	oView:SetContent({[1]={sid = 20301, amount = 1}, [2]={sid = 21011, amount = 100}
	-- 		,[3]={sid = 10020, amount = 100}}, 5550, 10)
	-- end)
	--16021
	--g_NotifyCtrl:ShowPowerChange(11111101, 1022220)
	-- local cb = function ( )	
	-- 	g_NotifyCtrl:ShowPowerChange(101, 100)
	-- end
	-- Utils.AddTimer(cb, 0, 0.5)

	-- CTaskSlipMoveView:ShowView(function (oView)

	-- 	oView:SetData(10001, 1)
	-- end)

	--g_GuideCtrl:StartTipsGuide("Tips_Brach_CHYL")
	--g_ShowWarCtrl:LoadShowWar("Boss")
	--g_EquipFubenCtrl:ShowMapGuideEffect()
	
	--g_AudioCtrl:SetVolumeFade(0)

	-- local oHero = g_MapCtrl:GetHero()
	-- if oHero then
	-- 	oHero:SetSocialEmoji(1)		
	-- end
	-- g_WindowTipCtrl:SetWindowTaskProgress(10008)
	-- CGmView:CloseView()
	--g_ActivityCtrl:MingLeiCreateGuideNpc()
	--g_GuideCtrl.m_Flags["Complete_Task_10012"] = true
	--g_GuideCtrl:TriggerCheck("custom")


	--g_GuideCtrl:StartTipsGuide("Tips_YueJian")
	-- g_GuideCtrl:StartTipsGuide("Tips_Org")
	-- g_GuideCtrl:StartTipsGuide("Tips_Pata")
	-- CDailyCultivateMainView:ShowView(function (oView)

	-- end)

	-- printc(" AddTraceNpc ")
	-- table.print(CTraceNpc.ych_trace_npc)
	-- table.print(CTraceNpc.ych_trace_npc.pos_info)
	-- g_MapCtrl:AddTraceNpc(CTraceNpc.ych_trace_npc)


	--local oHero = g_MapCtrl:GetHero()
	--oHero:WalkTo(24.5 , 19.7)


	-- printc("  a  star path ................ ")	
	-- local t = g_MapCtrl:GetMapAToMapBPath(101000, 204000)
	-- table.print(t)	
	-- local oHero = g_MapCtrl:GetHero()

	-- if oHero and #t > 1 then
	-- 	local function switchMap()		
	-- 		netscene.C2GSTransfer(g_MapCtrl:GetSceneID(), oHero.m_Eid, t[1].transferId)
	-- 		--netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, t[2].map_id)
	-- 	end
	-- 	--oHero:WalkTo(43, 2, switchMap)
	-- 	--oHero:WalkTo(t[1].x, t[1].y, switchMap)
	-- end
	--netitem.C2GSUseFuWenPlan(1)
	--CForgeFuwenTipsView:ShowView()
	--g_AchieveCtrl:C2GSAchieveMain()
	--CDialogueAniView:ShowView()
	--CPowerGuideMainView:ShowView()

	-- if g_AttrCtrl.m_AttrMainLayer == nil then
	-- 	g_AttrCtrl.m_AttrMainLayer = 1
	-- else
	-- 	g_AttrCtrl.m_AttrMainLayer = nil
	-- end

		-- local t = {sid = 10021, amount = 100}
		-- g_ItemCtrl.m_ych_list = {}
		-- table.insert(g_ItemCtrl.m_ych_list, t)
		-- table.insert(g_ItemCtrl.m_ych_list, t)
		-- table.insert(g_ItemCtrl.m_ych_list, t)
		-- t = {sid = 20301, amount = 100}
		-- table.insert(g_ItemCtrl.m_ych_list, t)
		-- t = {sid = 21011, amount = 100}
		-- table.insert(g_ItemCtrl.m_ych_list, t)
		-- table.insert(g_ItemCtrl.m_ych_list, t)
		-- t = {sid = 1004, amount = 1, virtual = 1025}
		-- table.insert(g_ItemCtrl.m_ych_list, t)


	--local offset = {-0.1, 0, 0.1, 0.2}
	--local z = table.randomvalue(offset)
-- 	printc(" zzz ", z)
-- printc("  >>>>>>>>>>>>>>>>   ",  CMainMenuView:GetView().m_LT.m_TopGrid:GetLocalPos())
 	--g_WindowTipCtrl:SetWindowAllItemRewardList(g_ItemCtrl.m_ych_list)

	--printc(" changeAttrMainLayer  >>>>>>>>>>> ", g_AttrCtrl.m_AttrMainLayer )
end

function TestGuide(arg)
	printc(" TestGuide ", arg)
	if arg ~= "" then
		local cb = function ( )
			local d = data.guidedata.Trigger_Check
			d.grade = {}
			d.view = {}
			d.war = {}
			d.custom = {}
			g_GuideCtrl.m_Flags = {}
			CGmView:CloseView()
			if g_GuideCtrl.m_Flags then
				g_GuideCtrl.m_Flags["welcome_one"] = true
				g_GuideCtrl.m_Flags["welcome_two"] = true
				g_GuideCtrl.m_Flags["welcome_three_end"] = true
			end
		
			if arg == "fwcd1" then -- 符文穿戴1
				d.grade	= {"Partner_FWCD_One_MainMenu"}
				d.view = {"Partner_FWCD_One_PartnerMain",}				
				g_GuideCtrl:TriggerAll()
			-- elseif arg == "fwcd2" then-- 符文穿戴2
			-- 	d.grade = {"Partner_FWCD_Two_MainMenu"}
			-- 	d.view = {"Partner_FWCD_Two_PartnerMain"}
			-- 	g_GuideCtrl:ReqCustomGuideFinish("War2")
			-- 	g_GuideCtrl:TriggerAll()
			elseif arg == "fwqh" then-- 符文强化
				d.view = {"Partner_FWQH_MainMenu", "Partner_FWQH_PartnerMain"}
				g_GuideCtrl:ReqCustomGuideFinish("Complete_Task_ChaterFb_1_4")
				g_GuideCtrl:TriggerAll()	
			elseif arg == "招募" or arg == "zm" then --马面面招募
				d.grade = {"Open_ZhaoMu"}
				d.view = {"DrawCard", "DrawCardLineUp_MainMenu", "DrawCardLineUp_PartnerMain", "Partner_FWCD_Two_PartnerMain"}				
				g_GuideCtrl:TriggerAll()	
			elseif arg == "招募2" or arg == "zm2" then 	--蛇姬招募
				d.grade = {"Open_ZhaoMu_Two"}
				d.view = {"DrawCard_Two", "DrawCardLineUp_Two_MainMenu", "DrawCardLineUp_Two_PartnerMain"}				
				g_GuideCtrl:TriggerAll()	
			elseif arg == "招募3" or arg == "zm3" then --阿坊招募
				d.grade = {"Open_ZhaoMu_Three"}
				d.view = {"DrawCard_Three", "DrawCardLineUp_Three_PartnerMain", "Partner_HBPY_MainMenu", "Partner_HPPY_PartnerMain", }											
				g_GuideCtrl:TriggerAll()					
			elseif arg == "jn" then--流派切换
				d.view = {"Skill"}
				g_GuideCtrl:StartTipsGuide("Tips_Skill")	
				g_GuideCtrl:TriggerAll()	
			elseif arg == "jn3" then--技能3升级
				d.grade = { "Open_Skill_Three" }
				d.view = {"Skill_Three"}
				g_GuideCtrl:TriggerAll()	
			elseif arg == "jn4" then--技能4升级
				d.grade = { "Open_Skill_Four" }
				d.view = {"Skill_Four"}
				g_GuideCtrl:TriggerAll()					
			elseif arg == "dt" then-- 切地图
				d.view = {"MapSwitchMainmenu", "MapSwitchMapView"}
				g_GuideCtrl:ReqCustomGuideFinish("Complete_Task_10033")	
				g_GuideCtrl:ReqCustomGuideFinish("Forge_Strength_View")					
				g_GuideCtrl:TriggerAll()
			elseif arg == "sm" then--师门
				d.grade = {"Open_Shimen"}
				d.view = {"Dialogue_Shimen"}
				g_GuideCtrl:TriggerAll()
			elseif arg == "宅邸" or arg == "zd" then --宅邸
				d.grade = {"Open_House"}
				d.view = {"HouseView", "HouseTwoView", "HouseTeaartView"}
				g_GuideCtrl:TriggerAll()
			elseif arg == "猎灵御灵" or arg == "llyl" then
				d.view = {"HuntPartnerSoulView", "Open_Yuling", "Yuling_PartnerMain"}
				g_GuideCtrl:StartTipsGuide("Tips_HuntPartnerSoulView")
				g_GuideCtrl:TriggerAll()	--猎灵+御灵
			elseif arg == "bjzd" then	--便捷组队
				d.view = {"TeamMainView_HandyBuild"}				
				g_GuideCtrl:ReqCustomGuideFinish("Refresh_Minglei")				
				g_GuideCtrl:ResetTargetGuide({"TeamMainView_HandyBuild", "Tips_TeamHandyBuild"})		
				g_GuideCtrl:TriggerTeamHandyBuildGuide()
			elseif arg == "cj" then	--成就
				d.view = {"Open_Achieve"}						
				g_GuideCtrl:TriggerTeamHandyBuildGuide()
			elseif arg == "ll" then--历练
				d.grade = {"Open_Lilian"}
				g_GuideCtrl:TriggerAll()		
			elseif arg == "公会" or arg == "gh" then
				d.grade = {"Open_Org"}
				g_GuideCtrl:TriggerAll()
			elseif arg == "埋骨之地" or arg == "mgzd" then
				d.grade = {"Open_Equipfuben"}
				g_GuideCtrl:TriggerAll()
			elseif arg == "jjc" then --竞技场
				d.grade = {"Open_Arena"}	
				d.view = {"ClubArenaView"}			
				g_GuideCtrl:TriggerAll()
			elseif arg == "喵萌茶会" or arg == "mmch" then
				d.grade = {"Open_MingLei"}
				g_GuideCtrl:TriggerAll()
			elseif arg == "探索" or arg == "ts" then --探索
				d.grade = {"Open_Trapmine"}
				g_GuideCtrl:TriggerAll()
			elseif arg == "yklf" then	--异空流放
				d.grade = {"Open_Pefuben"}										
				g_GuideCtrl:TriggerAll()
			elseif arg == "hs" then	--护送任务
				d.grade = {"Open_Convoy"}	
				g_GuideCtrl:TriggerAll()		
			elseif arg == "yl" then	--游历
				d.grade = {"Open_Travel"}	
				g_GuideCtrl:TriggerAll()			
			elseif arg == "pt" then--地牢
				d.grade = {"Open_Pata"}					
				g_GuideCtrl:TriggerAll()				
			elseif arg == "图鉴" or arg == "tj" then --图鉴
				d.grade = {"Open_MapBook"}
				g_GuideCtrl:TriggerAll()		
			elseif arg == "装备" or arg == "zb" then  --装备打造
				d.grade = {"Open_Forge"}
				g_GuideCtrl:TriggerAll()	
			elseif arg == "梦魇副本" or arg == "myfb" then  --梦魇副本
				d.grade = {"Open_YJFuben"}
				g_GuideCtrl:TriggerAll()	
			elseif arg == "公平比武" or arg == "gpbw" then  --公平比武
				d.grade = {"Open_EqualArena"}
				g_GuideCtrl:TriggerAll()			
			elseif arg == "人形讨伐" or arg == "rxtf" then  --人形讨伐
				d.grade = {"Open_FieldBoss"}
				g_GuideCtrl:TriggerAll()						
			elseif arg == "七天登录" or arg == "qtdl" then --七天登录
				g_GuideCtrl:StartTipsGuide("Tips_LoginSevenDay")

			elseif arg == "伙伴升星" or arg == "hbsx" then --伙伴升星
				d.view = {"Partner_HBSX_MainMenu", "Partner_HBSX_PartnerMain"}

				
			end
		end

		Utils.AddTimer(cb, 0, 1)
	end
end

function FinishTargeGuide(arg)
	local IsExist = false
	if g_GuideCtrl.m_Flags then
		local d = data.guidedata.Trigger_Check
		for k,v in pairs(d) do
			for _k, _v in pairs(v) do
				if _v == arg then
					IsExist = true
				end					
			end
		end
	end
	printc(" FinishTargeGuide ", arg, IsExist)
	if IsExist then
		g_GuideCtrl.m_Flags[arg] = true
		g_GuideCtrl:CtrlCC2GSFinishGuidance({[1]=arg})
		local cb = function ()
			print("刷新新手引导")
			g_GuideCtrl:TriggerAll()
		end
		Utils.AddTimer(cb, 0, 1)
	end
	
end

function PassGuide()
	g_GuideCtrl:FinishAllGuide()
end

function PassStart()
	g_GuideCtrl:JumpStart()
end

function DelTargerGuide(...)
	local t = {...}
	local del = {}
	table.print(t)
	if t and next(t) then
		for k, v in pairs(t) do
			local key = tostring(v)
			if key and key ~= "" and g_GuideCtrl.m_Flags then
				if g_GuideCtrl.m_Flags[key] ~= nil then
					g_GuideCtrl.m_Flags[key] = nil
					table.insert(del, key)
				end								
			end
		end
	end
	if next(del) then
		g_GuideCtrl:CtrlC2GSClearGuidance(del)	
	end
end

function ToggleGuideLog()
	if CGuideCtrl.LogToggle == 1 then
		CGuideCtrl.LogToggle = 0
	else
		CGuideCtrl.LogToggle = 1
	end
end

function PrintGuideData(arg)
	arg = arg or 1
	arg = tonumber(arg)
	if arg == 1 then
		printc(" g_GuideCtrl.m_Flags >>>>")
		table.print(g_GuideCtrl.m_Flags)
		
	elseif arg == 2 then
		printc(" g_GuideCtrl.m_TipsGuideFlags >>>>")
		table.print(g_GuideCtrl.m_TipsGuideFlags) 

	elseif arg == 3 then
		if g_GuideCtrl.m_UpdateInfo then
			printc(" g_GuideCtrl.m_UpdateInfo >>>> ")
			table.print(g_GuideCtrl.m_UpdateInfo.guide_type)
			table.print(g_GuideCtrl.m_UpdateInfo.continue_condition)
			table.print(g_GuideCtrl.m_UpdateInfo.cur_idx)
		end	
	end
end


function AddMyExp(arg)
	if arg == nil then
		arg = math.floor(g_AttrCtrl:GetUpgradeExp()) - math.floor(g_AttrCtrl:GetCurGradeExp())
	end
	local str = string.format("rewardexp %d %d", g_AttrCtrl.pid, tonumber(arg))
	netother.C2GSGMCmd(str)
	CGmView:CloseView()
end

function HideGmBtn()
 	local oView = CNotifyView:GetView()
 	if oView and oView.m_OrderBtn then
 		oView.m_OrderBtn:SetActive(false)
 	end
end

function VisibleExpLabel()
	local oView = CNotifyView:GetView()
 	if oView and oView.m_ExpBox and oView.m_ExpBox.m_ExpGroup then
 		local b = not oView.m_ExpBox.m_ExpGroup:GetActive() 	
 		oView.m_ExpBox.m_ExpGroup:SetActive(b)
 	end
end

function DialogueNpcAnimationEdit()	
	local oView = CGmView:GetView()
	if oView then
		oView:CloseView()
	end
	CEditorDialogueNpcAnimView:ShowView()
	oView = CNotifyView:GetView()
 	if oView and oView.m_OrderBtn then
 		oView.m_OrderBtn:SetActive(false)
 	end
end

function DialogueLayerAniNaviEdit()	
	CDialogueLayerAniView:ShowView(function (oView)
		oView:ShowPathConfigBox()
	end)
end

function OepnTaskFindpath()
	g_TaskCtrl.m_CanAutoTask = true
end

function ForceStopFindpath()
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		oHero:StopWalk()
	end
end

function ShowTerra()
	local oView = CMainMenuView:GetView()
	oView.m_RT.m_TerrwarBox:SetActive(true)
end

function checkmaskword(word)
	if word then
		if g_MaskWordCtrl:IsContainMaskWord(word) then
			g_NotifyCtrl:FloatMsg("名字中包含屏蔽字")
		end
		if not string.isIllegal(word) then
			g_NotifyCtrl:FloatMsg("含有特殊字符，请重新输入")
		end
		return
	end
	local firstlist = data.randomnamedata.FIRST
	local malelist = data.randomnamedata.MALE
	local femalelist = data.randomnamedata.FEMALE
	local sFirst = "--------------firstname：".."\n"
	local sMid = "--------------midname：".."\n"
	local sMale = "--------------malename：".."\n"
	local sFemale = "--------------femalename：".."\n"
	local sOther = "---------------拼起来是屏蔽字：".."\n"
	local function check(str1, str2)
		local str1 = str1
		local str2 = g_MaskWordCtrl:ReplaceMaskWord(str1)

		local lSplit1 = string.split(str2, "***")
		for i=1, #lSplit1 do
			local s = lSplit1[i]
			if s ~= "***" then
				str1 = string.gsub(str1, s, "")
			end
		end
		str1 = string.format("<color=#ffeb04>%s</color>", str1)
		return str1
	end
	for i,v in ipairs(firstlist) do
		if g_MaskWordCtrl:IsContainMaskWord(v.first) then
			sFirst = sFirst..v.first.."-------------------->>>"..check(v.first).."\n"
		end
		for k, m in ipairs(v.mid) do
			if g_MaskWordCtrl:IsContainMaskWord(m) then
				sMid = sMid .. m.."-------------------->>>"..check(m).."\n"
			end
			if g_MaskWordCtrl:IsContainMaskWord(v.first..m) then
				sOther = sOther .."First:"..v.first.."，Mid:"..m.."-------------------->>>"..check(v.first..m).."\n"
			end
		end
	end
	for i,v in ipairs(malelist) do
		if g_MaskWordCtrl:IsContainMaskWord(v) then
			sMale = sMale..v.."-------------------->>>"..check(v).."\n"
		end
	end
	for i,v in ipairs(femalelist) do
		if g_MaskWordCtrl:IsContainMaskWord(v) then
			sFemale = sFemale..v.."-------------------->>>"..check(v).."\n"
		end
	end

	print(sFirst)
	print(sMid)
	print(sMale)
	print(sFemale)
	print(sOther)
end

IDX = 0
function randomname(i)
	local oMaskTree = g_MaskWordCtrl:GetMaskWordTree()
	local function getone()
		local sName = ""
		local len = #oMaskTree:GetCharList(sName)
		local first,mid,last= "", "", ""
		local firstdata, randomvalue 
		while (len < 2) or (len > 6) or sName == oldName do
			oldName = sName
			math.randomseed(os.time() + IDX)
			math.random()
			IDX = IDX + 1
			firstdata = data.randomnamedata.FIRST[math.random(1, #data.randomnamedata.FIRST)]
			first = firstdata.first
			
			math.randomseed(os.time() + IDX)
			math.random()
			IDX = IDX + 1
			randomvalue = math.random(1, 100)
			mid = ""
			if randomvalue <= 70 and firstdata.mid then
				randomvalue = math.random(1, #firstdata.mid)
				mid = firstdata.mid[randomvalue] or ""
			end

			math.randomseed(os.time() + IDX) 
			math.random()
			IDX = IDX + 1
			last = ""
			if math.random(1, 100) <= 50 then
				last = data.randomnamedata.MALE[math.random(1, #data.randomnamedata.MALE)]
			else
				last = data.randomnamedata.FEMALE[math.random(1, #data.randomnamedata.FEMALE)]
			end
			sName = first..mid..last
			len = #oMaskTree:GetCharList(sName)
		end
		sName = string.gsub(sName, "^%s*(.-)%s*$", "%1")
		return sName
	end
	local names = {}
	local more = {}
	local sName = ""
	for i=1,tonumber(i) do
		sName = getone()
		if names[sName] then
			if not more[sName] then
				more[sName] = 1
			end
			more[sName] = more[sName] + 1
		else
			names[sName] = true
		end
	end
	for k,v in pairs(more) do
		printc(k, v)
	end
end

function testtime()
	local oWatch = g_TimeCtrl:StartWatch()
	for i=1, 111111*2 do
		local ins = CMapCtrl.New()
		type(ins.Clear)
		type(ins.InitValue)
		ins.a = 1
		type(ins.a)
		ins.b = 2
		type(ins.b)
	end
	local iElapsedMS = g_TimeCtrl:StopWatch(oWatch)
	printc("testtime", iElapsedMS)
end

function printitem(key) 
	local resultList = {}
	for _, block in pairs(data.itemdata) do
		if type(block) == "table" then
			for itemid, oItem in pairs(block) do
				local name = oItem.name
				if name == nil then
				
				elseif name == key then
					table.insert(resultList, string.format("%d %s", itemid, name))
					break
				elseif string.findstr(name, key) then
					table.insert(resultList, string.format("%d %s", itemid, name))
				end
			end
		end
	end
	local str = "没找你要的"
	if #resultList > 0 then
		str = table.concat(resultList, "\n")
	end
	local dMsg = {
		channel = 102,
		text = str,
	}
	g_ChatCtrl:AddMsg(dMsg)

end

function MonsterPath(x1, y1, x2, y2, speed)
	x1 = x1 and tonumber(x1)
	y1 = y1 and tonumber(y1)
	x2 = x2 and tonumber(x2)
	y2 = y2 and tonumber(y2)
	speed = speed and tonumber(speed)
	g_MonsterAtkCityCtrl:TestDaoBiao(x1,y1,x2,y2,speed)
end

function reload(str)
	local moduleList = string.split(str, ",")
	local packList = package.loaded
	local wholePathList = {}
	for key, obj in pairs(packList) do
		for _, moduleName in ipairs(moduleList) do
			if string.find(key, moduleName) then
				table.insert(wholePathList, {moduleName, key})
			end
		end
		if #wholePathList == #moduleList then
			break
		end
	end
	for _, moduleName in ipairs(moduleList) do
		if string.endswith(moduleName, "View") then
			local oView = _G[moduleName]
			if oView and oView.CloseView then
				oView:CloseView()
			end
		end
	end
	for _, dWhole in ipairs(wholePathList) do
		local moduleName = dWhole[1]
		local path = dWhole[2]
		_G[moduleName] = reimport(path)
	end
end

function banupdatecode(i)
	i = tonumber(i)
	if i == 1 then
		IOTools.SetClientData("banupdatecode", false)
		g_NotifyCtrl:FloatMsg("开启在线更新")
	else
		IOTools.SetClientData("banupdatecode", true)
		g_NotifyCtrl:FloatMsg("关闭在线更新")
	end
end

function testnpc(bShow)
	if bShow then
		function CWalker.SetCheckInScreen(self, b)
		end
	else
		function CWalker.SetCheckInScreen(self, b)
			self.m_CheckInScreen = b
			self.m_IsInScreen = not b
			self:CheckVisibleEvent()
		end
	end
end

function testpartner(bShow)
	CPartnerMainView:CloseView()
	if bShow then
		_G["CPartnerMainView"] = reimport("logic.partner.CPartnerMainNewView")
	else
		_G["CPartnerMainView"] = reimport("logic.partner.CPartnerMainView")
	end
end

function debugtimer()
	local nilfunc = function() end
	_G.table.print = nilfunc
	_G.printc = nilfunc
	_G.print = nilfunc
	_G.printtrace = nilfunc
	C_api.Utils.SetLogLevel(1)
	Utils.g_IsLog = false
	Utils.UpdateLogLevel = nilfunc
	local tinsert = table.insert
	local tremove = table.remove
	local ipairs = ipairs
	setmetatable(_G, {})
	_G["cbinfos"] = {}
	--用lua的闭包实现回调
	_G["callback"] = function (luaobj, funcname, ...)
		assert(luaobj[funcname], "callback error!not defind funcname:"..funcname)
		local args = {...}
		local len1 = select("#", ...)
		local id = weakref(luaobj)
		local function f(...)
			local real = getrefobj(id)
			if not real then
				return false
			end
			local len2 = select("#", ...)
			for i=1, len2 do
				args[len1 + i] = select(i, ...)
			end
			return real[funcname](real, unpack(args, 1, len1+len2))
		end
		_G.cbinfos[f] = string.format("%s_%s", luaobj.classname, funcname)
		return f
	end
	if Utils.IsEditor() then
		g_TimerCtrl.m_CostPerFrame = 12 --ms
	else
		g_TimerCtrl.m_CostPerFrame = 3 --ms
	end
	function CTimerCtrl.UpdateList(self, list)
		if not next(list) then
			return
		end
		local lDel = {}
		local iFrameCount = UnityEngine.Time.frameCount
		local iUnscaledTime = UnityEngine.Time.unscaledTime
		local iTime = UnityEngine.Time.time
		for i, id in ipairs(list) do
			local v = self.m_TimerDict[id]
			if v then 
				local oWatch = g_TimeCtrl:StartWatch()
				local iElapsed = v.unsacled and iUnscaledTime or iTime
				if v.add_frame ~= iFrameCount and (iElapsed - v.next_call_time) >= -0.005 then
					local callDelta = iElapsed - v.last_call_time
					local sucess, ret = xxpcall(v.cbfunc, callDelta)
					if sucess and ret == true then
						v.last_call_time = iElapsed
						v.next_call_time = iElapsed + v.delta
					else
						tinsert(lDel, i)
						self.m_TimerDict[id] = nil
					end
				end
				local iCost = g_TimeCtrl:StopWatch(oWatch)
				if iCost > self.m_CostPerFrame then
					local info = _G.cbinfos[v.cbfunc]
					if not info then
						local t = debug.getinfo(v.cbfunc)
						if t then
							info = " info.short_src:"..tostring(t.short_src)..
							" info.linedefined:"..tostring(t.linedefined)
						end
					end
					local s = string.format("func:%s, 耗时:%d ms", info, iCost)
					printerror(s)
					if not Utils.IsEditor() then
						g_NotifyCtrl:FloatMsg(s)
					end
					
				end
			else
				tinsert(lDel, i)
			end

		end
		for j=#lDel, 1, -1 do
			tremove(list, lDel[j])
		end
	end

end

function OpenHouseMode()
	IOTools.SetClientData("IsHouseOnly", true)
end

function CloseHouseMode()
	IOTools.SetClientData("IsHouseOnly", false)
end


function ToggleFuliTest()
	if data.globalcontroldata.GLOBAL_CONTROL.test_fuli.open_grade == 999 then
		data.globalcontroldata.GLOBAL_CONTROL.test_fuli.open_grade = 4 
		data.welfaredata.WelfareControl[1].open = 1
		
	else
		data.globalcontroldata.GLOBAL_CONTROL.test_fuli.open_grade = 999	
		data.welfaredata.WelfareControl[1].open = 0
	end
	local oView = CMainMenuView:GetView()
	if oView.m_RT then
		oView.m_RT:RefreshButton()
	end
end


function SetShenHeCreateRole(i)
	i = tonumber(i)
	IOTools.SetClientData("shenhecreaterole", i==1)
end

function testcsurl()
	define.Url.Release = "http://testn1.cilugame.com"
end

function atlasmode(i)
	i = tonumber(i)
	printc("atlasmode>>>>>>>>>>>>", i)
	C_api.Utils.SetAtlastReplaceMode(i)
end

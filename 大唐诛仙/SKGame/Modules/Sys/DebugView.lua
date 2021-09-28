DebugView =BaseClass(LuaController)

function DebugView:__init()
	self.root = BaseWindow.New("Sys" , "DebugWindow", false)
	self.type = 0
	self.inited = false
end

-- window类UI 第一次弹出后才初始化完成
function DebugView:Config()
	self.inited = true
	self.panel = self.root.panel
	self.btnDebug = self.panel:GetChildAt(5)
	self.contentArea = self.root.contentArea
	-- self.panel.draggable = true
	self.dragArea = self.panel:GetChild("dragArea")
	-- self.dragArea.draggable = true
	self.content = self.contentArea:GetChild("txtContent")
	self.inputMsg = self.panel:GetChild("inputMsg")
	self.btnLuaChange = self.panel:GetChild("btnLuaChange")
	self.container = self.panel:GetChild("container")

	local changeBgSound = function ( volume )
		if volume < 0 then
			volume = 0
		elseif volume > 0.5 then
			volume = 0.5
		end
		soundMgr:SetBgVolume(volume)
		DataMgr.WriteData("bgVolume",volume)
	end
	self.btnStopAudio = self.panel:GetChild("btnStopAudio")
	self.btnStopAudio.onClick:Add(function ( e ) changeBgSound(0) end)
	self.btnAddSound = self.panel:GetChild("btnAddSound")
	self.btnAddSound.onClick:Add(function ( e ) changeBgSound(soundMgr.bgAudioVolume+0.01) end)
	self.btnSubSound = self.panel:GetChild("btnSubSound")
	self.btnSubSound.onClick:Add(function ( e ) changeBgSound(soundMgr.bgAudioVolume-0.01) end)

	local debugBtns = {}
	local c, r = 0, 0
	local offX, offH = 108, 46
	local labels = {"发送物品", "升级", "切换场景", "增加经验", 
					"完成当前任务", "接收任务", "增加金币", "增加钻石",
					"设置攻击力", "设置移速", "增加怪物", "设置MaxHP",
					"开启技能","进入大荒塔层数","增减天梯分数","完成指定环任务",
					"充值对应商品编号","添加buff","增加建设度与资金","增加贡献"}
	for i=1, 100 do
		local btn = UIPackage.CreateObject("Sys","BtnDebug")
		self.container:AddChild(btn)
		btn:SetXY(((i-1)%2)*offX, math.floor((i-1)/2)*offH)
		btn.data = i
		btn.text = i..(labels[i] or "[待定]")
		btn.onClick:Add(function ( e ) 
			self:GMCMD(e.sender.data)
		end)
	end

	local soundeff = {
		{r="audio/skill_100001.unity3d", id="skill_100001"},
		{r="audio/skill_100014.unity3d", id="skill_100014"},
		{r="audio/skill_200003.unity3d", id="skill_200003"},
		{r="audio/skill_100012.unity3d", id="skill_100012"},
		{r="audio/skill_100003.unity3d", id="skill_100003"},
		{r="audio/skill_100003.unity3d", id="w3"}
	}

	self.btnSkillSound = self.panel:GetChild("btnSkillSound")
	self.btnSkillSound.onClick:Add(function ( e )
		local sound = soundeff[math.random(1, #soundeff)]
		EffectMgr.PlaySound(sound.id)
	end)
	
	self.btnLuaChange.onClick:Add(function ( e )
		local modules = {}
		for k, v in pairs(package.loaded) do -- 释放之前的一些加载模块
			if v and string.find(k, "SKGame.Modules") then
				table.insert(modules, k)
				package.loaded[k] = nil
			end
		end
		local url
		for i=1,#modules do
			url = modules[i]
			require(url)
		end
		for key, ctrl in pairs(_G) do
			if type(ctrl) == "table" 
				and string.find(key,"Controller") 
				and key ~= "EffectController" 
				and key ~= "CameraController"
				and key ~= "Controller"
				and ctrl.GetInstance then
				ctrl["GetInstance"](ctrl)
			end
		end
	end)

	self.btnDebug.onClick:Add(function ( e )
		self:ExecCMD()
	end)
	Stage.inst.onKeyDown:Add(DebugView.OnKeyDown)
end

function DebugView:ExecCMD()
	local msg = self.inputMsg.text
	if string.trim(msg) == "" then return end
	local uiSign, e = string.find(msg, "#")
	local cmdSign, e = string.find(msg, "@")

	if uiSign == 1 then -- "#"
		self.type = 1
	elseif cmdSign == 1 then -- "@"
		self.type = 2
	else
		self.type = 0
	end
	self:ManagerMsg()
end

--[[消息处理
	普通：执行的是lua字符串 loadstring(funcStr)()
	UI: 先加入 #pkgName_panelName 将UI弹出来的
	CMD：协议调试 @cmd_{key1=v1, key2=v2, ...}
--]]
function DebugView:ManagerMsg()
	local msg = self.inputMsg.text
	local result = ""
	if self.type ~= 0 then -- #@
		cmd = string.sub(msg, 2)
		if self.type == 1 then -- #
			result = self:ManagerUI(cmd)
		else -- @
			result = self:ManagerCMD(cmd)
			if result == "cmd" then
				self:AppendContent("调试:"..cmd)
				return
			end
		end
	else
		local s, e = string.find(msg, "return ")
		if s ~= 1 then
			result = loadstring("return ".. msg)()
			result = result or cmd
		else
			result = loadstring(msg)()
			result = result or cmd
		end
	end

	if result == nil then
		return
	end
	if type(result) == "table" then
		result = "table =======>" .. _printt(result)
	elseif type(result) == "function" or type(result) == "boolean" or type(result) == "userdata" then
		return
	end

	self:AppendContent("调试:"..result)
end

function DebugView:AppendContent( result )
	if not self.content then return end
	self.content.text = result .. "\n" .. self.content.text
	if #self.content.text > 5000 then
		self.content.text = string.sub(self.content.text, 0, 6000)
	end
end

function DebugView:ManagerUI( cmd )
	return cmd
end

DebugView.start = false
DebugView.aaa = 99999
function DebugView:ManagerCMD( cmd )
	if cmd == "aa" then
		local data = {}
		data.playerId = 1001
		data.xy = {100, 100}
		data.funcIds = {PlayerFunBtn.Type.CheckPlayerInfo, PlayerFunBtn.Type.InviteTeam, PlayerFunBtn.Type.KickOffTeam, 
		PlayerFunBtn.Type.KickOffTeam, PlayerFunBtn.Type.KickOffTeam}

		GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
	end

	if cmd == "tttt" then
		SceneController:GetInstance():GetScene():GetMainPlayer().autoFight:Stop()
	end

	if cmd == "qwe" then
		local player = SceneController:GetInstance():GetScene():GetMainPlayer()
		local changeData = {}
		DebugView.aaa = DebugView.aaa + 6000
		changeData.target = player
		changeData.dmg = DebugView.aaa
		changeData.pos = player:GetPosition()
		changeData.pos = player:GetPosition()
		changeData.isCrit = false
		changeData.isMiss = false
		changeData.source = player

		GlobalDispatcher:DispatchEvent(EventName.BATTLE_PLAYER_HP_CHAGNGE, changeData)
	end

	--buf测试 @buf_bufId
	local cmdInfo = StringSplit(cmd, "_")
	if cmdInfo[1] == "buf" then
		local player = SceneController:GetInstance():GetScene():GetMainPlayer()
		player.buffManager:AddBuffById(tonumber(cmdInfo[2]))
	end

	if cmd == "0" then
		-- local role = SceneModel:GetInstance():GetMainPlayer()
		local player = SceneController:GetInstance():GetScene():GetMainPlayer()
		-- GlobalDispatcher:DispatchEvent(EventName.OPENVIEW, {id="TiantiPanel", v=1})
		local monster = SceneController:GetInstance():GetScene().monList[1]

		EffectMgr.HitColor( player, Color.New(2.5,2.5,2.5), 1)
		-- EffectMgr.HitColor( monster, Color.New(2.5,2.5,2.5), 1)

		-- Util.ClearMemory()
		-- SoulMgr.Play(player.vo.guid, "run")
		-- local t = {"skill_01", "run", "stand"}
		-- local a = t[math.random(1,3)]
		-- local b = t[math.random(1,3)]
		-- SoulMgr.CrossPlay(player.vo.guid, a)
		-- print(SoulMgr.IsNameAndLoop(player.vo.guid, "stand"))
		-- print(SoulMgr.GetCurStateInfo(player.vo.guid))

		-- MapUtil.ResetLinkMap()
		-- local list = {}
		-- local fs = 2010
		-- local es = 1001
		-- if not MapUtil.LinkMap(list, fs, es, true, nil) then
		--	 print("找不到路径", #list)
		-- end
		-- for i, path in ipairs(list) do
		--	 local ss = fs
		--	 for i, v in ipairs(path) do
		--		 ss = ss .. " -> " .. "("..(v[1] or "**")..",".. (v[2] or "??")..")"
		--	 end
		--	 local s = string.format("第%s条：%s", i, ss)
		--	 print(s)
		-- end
		-- local path = MapUtil.GetShortLinkMapPath(list)
		-- local ss = fs
		-- for i, v in ipairs(path) do
		--	 ss = ss .. " -> " .. "("..(v[1] or "**")..",".. (v[2] or "??")..")"
		-- end
		-- local s = string.format("第%s条：%s", x, ss)
		-- print(s)
		
		-- ZDCtrl:GetInstance():Open()

		RenderMgr.AddInterval(function (  )
			print("111")
		end, "key22222", 2, 20, function (  )
			print("finish")
		end)

		return
	end

	if cmd == "1" then
		resMgr:AddUIAB("Pay")
		local checkPanel = PayCheckPanel.New()
		UIMgr.ShowCenterPopup(checkPanel, function()  end)
		-- local img = UIPackage.CreateObject("Common", "CustomIcon")
		-- img.icon = "icon/common/t5hd22"
		-- layerMgr:GetUILayer():AddChild(img)
		-- img:SetSize(300, 300)
		-- img:SetXY(300, 300)
		-- local loader1 = img:GetChild("icon")
		-- loader1:AddOnLoadEvent()
		-- loader1.onLoad:Add(function ()
		-- 	Util.SetGSpriteScaleModel(loader1, 1, 30, 30, 30, 30)
		-- end)
		-- local img = UIPackage.CreateObject("Common", "CustomIcon")
		-- img.icon = "icon/common/t5hd22"
		-- layerMgr:GetUILayer():AddChild(img)
		-- img:SetSize(300, 300)
		-- img:SetXY(610, 300)
		-- local loader = img:GetChild("icon")
		-- loader:AddOnLoadEvent()
		-- loader.onLoad:Add(function ()
		-- 	Util.SetGSpriteScaleModel(loader, 0, 30, 30, 30, 30)
		-- end)
		-- for i=#self.logoList,1,-1 do
		-- 	local logo = table.remove(self.logoList, i)
		-- 	layerMgr:GetUILayer():RemoveChild(logo)
		-- end
		-- GlobalDispatcher:DispatchEvent(EventName.SCENE_LOAD_FINISH, SceneModel:GetInstance().sceneId)
		-- local player = SceneController:GetInstance():GetScene():GetMainPlayer()
		-- activtyGameObject( player.gameObject, true )
		-- SoulMgr.CrossPlay(player.vo.guid, "skill_01", 0)

		-- UIMgr.Win_Confirm("注意", "您的账号在别处登录\n请重新登录游戏！", "重新登录", "退出游戏", 
		-- function()
		-- 	if Network.isConnetced then -- 这里处理有点问题的，东西没重置好@@@后期得改动
		-- 		Network.CloseSocket()
		-- 	end
		-- 	LoginController:GetInstance():OpenLoginPanel()
		-- end,
		-- function()
		-- 	UnityEngine.Application.Quit()
		-- end)
		return
	end
	if cmd == "2" then
		print("@2")
		-- TaskModel:GetInstance():SetAutoFight( true )
		-- TaskModel:GetInstance():AutoFight()

		AutoFightMgr.SetAuto(true)

		-- local player = SceneController:GetInstance():GetScene():GetMainPlayer()
		-- -- SoulMgr.CrossPlay(player.vo.guid, "run")
		-- local t = {"skill_01", "run", "stand"}
		-- local act = t[math.random(1,3)]
		-- if not SoulMgr.IsNameAndLoop(player.vo.guid, act) then
		-- 	SoulMgr.CrossPlay(player.vo.guid, act)
		-- end
	end
	if cmd == "num1" then
		local bar = NumberBar.New()
		bar:AddTo(self.contentArea)
		bar:SetMax(999)
		bar:SetStep(1)
		bar:SetTypeCallback(function ( v ) print(v) end)
		-- NumberBarType.Show(function ( i )
		-- 	print(i)
		-- end)
	end
	if cmd == "3" then
		local start = 1001--2002--2115--2010--2003--1001--321--2114
		local target = 2002--2001--2003--2005--1001--321
		local result = MapUtil.GetScenePath(start, target)
		if result then
			print("找到路径：", #MapUtil.pathes)
			for i=1, #MapUtil.pathes do
				local ss = start.."=>"
				local path = MapUtil.pathes[i]
				for j=#path,1,-1 do
					local v = path[j]
					ss = ss .. " -> " ..v.id.." ["..v.toMapId.."]"
				end
				print(string.format("第%s条：%s", i, ss))
			end
		else
			print("找不到路径", start, target)
		end
	end

	if cmd == "4" then
		self:AppendContent("当前总lua占内存：", collectgarbage("count").." kb")
	end
	if cmd == "5" then
		collectgarbage("collect") -- 垃圾回收
	end
	if cmd == "6" then
	end
	if cmd == "7" then
	end
	if cmd == "8" then
		--任务 32042 等级 50 打开所有图标
		return
	end

	if cmd == "10" then
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_BOTTOM_CLOSE)--主UI下方按钮关闭
	end
	if cmd == "11" then
		local player = SceneController:GetInstance():GetScene():GetMainPlayer()
		player.vo.hp = player.vo.hp - 20
		GlobalDispatcher:DispatchEvent(EventName.BATTLE_PLAYER_HP_CHAGNGE, {player, 100, player.transform.position, true})
		local monList = SceneController:GetInstance():GetScene().monList
		local monster = monList[1]
		monster.vo.hp = monster.vo.hp - 20
		GlobalDispatcher:DispatchEvent(EventName.BATTLE_MONSTOR_HP_CHAGNGE, {monster, 20, monster.transform.position, false})
	end
	if cmd == "12" then
		local monList = SceneController:GetInstance():GetScene().monList
		local monster = monList[1]
		monster.vo.hp = monster.vo.hp - 20
		GlobalDispatcher:DispatchEvent(EventName.BATTLE_MONSTOR_HP_CHAGNGE, monster)--技能按钮打开
	end
	
	if cmd == "程序" then
		local player = SceneController:GetInstance():GetScene():GetMainPlayer()
		player:GetAnimator():SetSpeed(1.5)
		player.moveSpeed = 10
		player:ShowCanying( true )
	end
	if cmd == "美术" then
		local player = SceneController:GetInstance():GetScene():GetMainPlayer()
		player.moveSpeed = 5
		player:ShowCanying( not self.openCaning )
	end
	if cmd == "策划" then
		local player = SceneController:GetInstance():GetScene():GetMainPlayer()
		player:GetAnimator():SetSpeed(0.3)
		player.moveSpeed = 1.6
		player:ShowCanying( false )
	end

	if cmd == "111" then
		local findTarget = Vector3.New(5.9, 0, 14.7)
		local findType = FindType.POSITION
		local sceneId = 1002
		local param
		SceneModel:GetInstance():CrossPath( findTarget, findType, sceneId, param )
	end
	if cmd == "112" then
		local findTarget = 1100
		local findType = FindType.NPC
		local sceneId = nil
		local param
		SceneModel:GetInstance():CrossPath( findTarget, findType, sceneId, param )
	end
	
	if cmd == "20" then --回到主城
		local scene = SceneController:GetInstance():GetScene()
		scene.cameraController_cfg.isDebug = not scene.cameraController_cfg.isDebug
		scene.cameraCtrl:SetCameraTest(scene.cameraController_cfg.isDebug)
	end
	if cmd == "21" then
		local scene = SceneController:GetInstance():GetScene()
		scene.cameraController_cfg.isDebug = not scene.cameraController_cfg.isDebug
		scene.cameraCtrl:UpdateCamera()
	end
	if cmd == "skill" then
		local player = SceneController:GetInstance():GetScene():GetMainPlayer()
		local msg = ReqAttackPlayerMessage.New()
		msg.fightType = 21101
		msg.fightDirection = 0
		msg.fightTarget = player.id
		LoginController:GetInstance():SendMsg(msg)
	end

	if cmd == "clear" then
		UnityEngine.PlayerPrefs.DeleteAll()
	end

	--[[ @cmd-pbName-C_xxxx-attr1:s:value1-attr2:s:value2-attr3:s:value3-...
		如： test 中的GM测试协议
		@cmd-test_pb-C_xxxx-attr:T:value-attr:T:value-attr:T:value-...
		attr 表示字段名
		T 表示类型 数值：i,h,b,l, 字符串：s, B:Boolean
		value 值
	--]]
	local s, e = string.find(cmd, "cmd")
	if s == 1 then
		local tv = nil
		local info = StringSplit(cmd, "-")
		for i=1,#info do
			print(i, info[i])
		end
		if #info < 3 or not _G[info[2]][info[3]] then return cmd end
		local msg = _G[info[2]][info[3]]()
		if #info >= 4 then
			for i=4,#info do
				tv = StringSplit(info[i], ":")
				if #tv ~= 3 then 
					self:AppendContent("错误的协议字段:"..info[i])
					return
				end
				if tv[2] == "s" then
					msg[tv[1]] = tv[3]
				elseif tv[2] == "B" then
					msg[tv[1]] = tv[3]=="true"
				else
					msg[tv[1]] = tonumber(tv[3])
				end
			end
		end
		self:SendMsg(info[3], msg)
	end
	return cmd
end

-- 多个参数使用 - 作为连接
function DebugView:GMCMD( id )
	local content = string.trim(self.inputMsg.text)
	local result = {}
	if content ~= "" then
		if string.find(content, '-') ~= 1 then
			result = StringSplit(content, "-")
		else
			result = {content}
		end
	end
	local msg = test_pb.C_Test()
	msg.type = id
	if id == 1 and tonumber(result[1]) and not result[2] then
		result[2] = 1
	end
	if next(result) then
		if result[1] and tonumber(result[1]) then
			msg.param1 = tonumber(result[1])
		end
		if result[2] and tonumber(result[2]) then
			msg.param2 = tonumber(result[2])
		end
	end
	self:AppendContent("调用GM命令按钮->类型:"..msg.type.." 参数1:"..(msg.param1).."  参数2:"..(msg.param2))
	self:SendMsg("C_Test", msg)
end

--
	function DebugView:DrawLine1(v1, v2)
		DrawUtils.DrawLine(v1, v2, Color.black) -- green)
	end
	function DebugView:DrawLine2(v1, v2)
		DrawUtils.DrawLine(v1, v2, Color.green)
	end
	function DebugView:DrawLine3(v1, v2)
	   	DrawUtils.DrawLine(v1, v2, Color.black)
	end
	function DebugView:DrawLine4(v1, v2)
		DrawUtils.DrawLine(v1, v2, Color.blue)
	end
	function DebugView:DrawLine5(v1, v2)
		DrawUtils.DrawLine(v1, v2, Color.red)
	end

	function DebugView:DrawRectLine(x, y, height, state)
		local ax, bx = x*0.5, (x+1)*0.5
		local ay, by = y*0.5, (y+1)*0.5
		local a = Vector3.New(ax, height, ay)
		local b = Vector3.New(bx, height, ay)
		local c = Vector3.New(ax, height, by)
		local d = Vector3.New(bx, height, by)

		-- self:DrawLine1(a, b)
		-- self:DrawLine1(a, c)
		-- self:DrawLine1(d, c)
		-- self:DrawLine1(d, b)
		if state == 0 then
			-- self:DrawLine2(a, d)
			--self:DrawLine2(c, b)
		elseif state == 1 then
			-- self:DrawLine3(a, d)
			-- self:DrawLine3(c, b)
		else
			self:DrawLine4(a, d)
			self:DrawLine4(c, b)
		end
	end
	DebugView.AttackBlock = {}
	function DebugView:Update()
		if not DebugView.start then return end
		local block = DebugView.block -- Astar.block
		for i=1, #block do
			local len = #block[i]
			for j=1, len do
				self:DrawRectLine((i-1), (j-1), 0.1, DebugView.AttackBlock[i.."_"..j] or Astar.block[i][j])
			end
		end
	end

function DebugView:Open()
	self.root:Show()
	if self.inited then return end
	local t = Timer.New(function ()
		self:Config()
	end, 0.5, 0)	
	t:Start()
end

function DebugView:Close()
	self.root:Hide()
end

function DebugView:__delete()
	self.inited = false
	if self.root then
		self.root:Dispose()
	end
	self.root = nil
end

function DebugView.OnKeyDown( context )
	 if LoginController:GetInstance().model.isLogined then
		local player = SceneController:GetInstance():GetScene():GetMainPlayer()

		-- if GameConst.JumpBySpaceKey and context.inputEvent.keyCode == KeyCode.Space and player and not player.isJumping then

		-- 	player:GetAnimator():StopTimerByAction( "run" )
		-- 	local result = player.transform.forward*5+player.transform.position
		-- 	player:ShowCanying( true )
		-- 	player.isJumping = true
		-- 	local t = TweenUtils.DoJump(player.transform, Vector3.New(result.x, result.y+3, result.z), 0.5, 1, 1)
		-- 	TweenUtils.OnTweenCompleted(t, function ()
		-- 		player:ShowCanying( false )
		-- 		player.isJumping = false
		-- 		player:GetAnimator():StopTimerByAction( "idle" )
		-- 	end)

		-- end

		if context.inputEvent.keyCode == KeyCode.K and player and not player.K then
			player.K = true
			-- local t = TweenUtils.DOShakePosition(Camera.main.transform, 0.5, 1, 10, 90, false)
			-- TweenUtils.OnTweenCompleted(t, function ()
			--	 player.K = false
			-- end)
			local t = TweenUtils.DOShakePosition(Camera.main.transform, 0.5, Vector3.New(0.6, 0.6, 0), 40, 90, false)
			TweenUtils.OnTweenCompleted(t, function ()
				player.K = false
			end)
		end

		if context.inputEvent.keyCode == KeyCode.J and player and not player.J then
			player.J = true
			local t = TweenUtils.DOShakeRotation(Camera.main.transform, 0.5, 10, 10, 90)
			TweenUtils.OnTweenCompleted(t, function ()
				player.J = false
			end)
		end

		if context.inputEvent.keyCode == KeyCode.L and player and not player.L then
			player.L = true
			local t = TweenUtils.DOShakeScale(player.transform, 0.5, 1, 15, 60)
			TweenUtils.OnTweenCompleted(t, function ()
				player.L = false
			end)
		end

		if context.inputEvent.keyCode == KeyCode.U and player and not player.U then
			player.U = true
			 local result = player.transform.position
			local t = TweenUtils.DOPunchPosition(player.transform,
				Vector3.New(1, 0, 1), 1, 5, 1)
			TweenUtils.OnTweenCompleted(t, function ()
				player.U = false
			end)
		end

		if context.inputEvent.keyCode == KeyCode.I and player and not player.I then
			player.I = true
			 local result = player.transform.position
			local t = TweenUtils.DOPunchRotation(player.transform,
				Vector3.New(0, 60, 0), 1, 5, 1)
			TweenUtils.OnTweenCompleted(t, function ()
				player.I = false
			end)
		end

		if context.inputEvent.keyCode == KeyCode.O and player and not player.O then
			player.O = true
			local result = player.transform.position
			local t = TweenUtils.DOPunchScale(player.transform,
				Vector3.New(1, 1, 1), 1, 5, 1)
			TweenUtils.OnTweenCompleted(t, function ()
				player.O = false
			end)
		end
	end
end


SceneView =BaseClass()
SceneView.modelDisappearDistance = 6
SceneView.headUIDisappearDistance = 10
local playerMap = {"1001", "1002", "1003", "1011", "1012", "1014", "1023", "1033" }
-- 场景视图
function SceneView:__init()
	self.isDestroyed = false
	self.isRendering = false -- update

	self.ctrl = SceneController:GetInstance()
	self.model = self.ctrl.model
	self.sceneId = self.model.sceneId
	self.mapResId = self.model.mapResId

	self.mainPlayer = nil -- 主角玩家
	self.cameraCtrl = nil -- 主摄像头控制器
	self.outDoorCameraCtrl = nil -- 野外摄像头控制器
	self.lookMon = false

	self.playerList = {} -- 玩家列表
	self.npcList = {} -- npc列表
	self.monList = {} -- 怪物列表--已经激活的怪物
	self.summonThingList = {} -- 怪物列表--已经激活的怪物
	self.mixtureList = {} --怪物和玩家列表
	-- self.scene_active_mon_list_ = {} --场景中所有的已经激活的怪物
	self.effectList = {} -- 特效列表
	self.dropList = {} -- 掉落列表
	
	self.doorList = {} -- 传送门
	self.flyEffectList = {}	--飞行特效列表
	self.sourceEffectList = {}
	self.persistEffectList = {}	-- 持续性特效列表
	self.warningList = {} --预警列表
	self.cameraController_cfg = GetLocalData( "Map/SceneCfg/CfgCameraContoller" )  --摄像机配置表
	self.cameraOut_cfg = GetLocalData( "Map/SceneCfg/CfgCameraOut" )  --野外摄像机

	self.reqCMD = Time.time -- 主角临近一些对象的请求时间

	self:Layout(self.mapResId)

	self.loadFinish = false -- 加载成功
	self.cameraFocusTemp = nil --相机临时聚焦物体
	self.curFocusMon = nil --相机当前聚焦的怪物
	self.frame = 0 --监控帧数

	self.collectList = {}
	self.collectItemPanel = nil
	self.isOpenCollectUI = false
	self.isCollecting = false
	self.curCollectObj = nil
	self.skillPreview = nil
	self.mapNameTips = nil

	self.npcBehaviorMgr = NPCBehaviorMgr:GetInstance()

	self.isPickuping = false
	self.curPickupObj = nil
	self.pickupItemPanel = nil

	-- 在场同步人数限制
	self.maxPlayerNum = SceneConst.MaxPlayerOnNewer
	Stage.inst.onTouchBegin:Add(SceneView.OnclickRay, self)         -------------------
end

function SceneView:InitEvent()
	self.handler1  = GlobalDispatcher:AddEventListener(EventName.PLAYER_ADDED, function (data) self:PlayerAddedHandle(data) end)
	self.handler2  = GlobalDispatcher:AddEventListener(EventName.MONSTER_ADDED, function (data) self:MonsterAddedHandle(data) end)
	self.handler3  = GlobalDispatcher:AddEventListener(EventName.NPC_ADDED, function (data) self:NpcAddedHandle(data) end)
	self.handler4  = GlobalDispatcher:AddEventListener(EventName.DOOR_ADDED, function (data) self:DoorAddedHandle(data) end)
	self.handler5  = GlobalDispatcher:AddEventListener(EventName.DROP_ADDED, function (data) self:DropAddedHandle(data) end)
	self.handler6  = GlobalDispatcher:AddEventListener(EventName.WIGSKILL_ADDED, function (data) self:WigSkillAddedHandle(data) end)

	self.handler7  = GlobalDispatcher:AddEventListener(EventName.JOYSTICK_MOVE, function (data) self:MoveJoystick(data) end)
	self.handler8  = GlobalDispatcher:AddEventListener(EventName.JOYSTICK_END, function ()
		-- TaskModel:GetInstance():BreakAuto()
		self.preAngle = nil
		self.isMoveByJoystick = false
		self:StopJoystick()
	end)

	self.handler9  = GlobalDispatcher:AddEventListener(EventName.OBJECT_ONCLICK, function (data) self:OnObjectClick(data) end)
	------------
	self.handler99  = GlobalDispatcher:AddEventListener(EventName.AllOBJECT_ONCLICK, function (data) self:OnAllObjectClick(data) end)
	------------
	self.handler10 = GlobalDispatcher:AddEventListener(EventName.GOTOFIGHT, function (data) self:GotoFightHandle(data) end)

	self.handler11 = GlobalDispatcher:AddEventListener(EventName.PAUSE_GAME,function (data) self:PauseGame(data) end)  --暂停游戏
	self.handler12 = GlobalDispatcher:AddEventListener(EventName.CONTINUE_GAME,function (data) self:ContinueGame(data) end)  --继续游戏
	self.handler13 = GlobalDispatcher:AddEventListener(EventName.Shake, function (data) self:DoShake(data) end) --震屏
	self.handler14 = GlobalDispatcher:AddEventListener(EventName.SkillUpgrade, function (data) self:SkillUpgradeHandler(data) end) --技能升级
	
	self.handler16 = GlobalDispatcher:AddEventListener(EventName.RemoveCollectItem, function (data) self:HandleRemoveCollect(data) end) --采集view层的相关事件监听
	self.handler17 = GlobalDispatcher:AddEventListener(EventName.AddCollectItem, function (data) self:AddCollect(data) end)
	self.handler18 = GlobalDispatcher:AddEventListener(EventName.StartCollect, function (data) self:StartCollectHandle(data) end)

	self.handler19 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_WALKING, function () self:HandlePlayerWalk() self:HandleRoleStopWalk() end)
	self.handler20 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_DIE, function () self:HandleMainRoleDie() end)
	self.handler21 = GlobalDispatcher:AddEventListener(EventName.AddCollectItemList, function (data) self:HandleAddCollectItemList(data) end)
	self.handler22 = GlobalDispatcher:AddEventListener(EventName.RemoveCollectItemList, function (data) self:HandleRemoveCollectItemList(data) end)
	self.handler23 = GlobalDispatcher:AddEventListener(EventName.EndCollect, function (data) self:HandleEndCollect(data) end)

	self.handler25 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_STOPWALK, function ()
		self:HandleStopMove()
		self:HandleRoleStopWalk()
	end)

	self.handler27 = GlobalDispatcher:AddEventListener(EventName.ChangeStyleSuccess, function (data) self:HandleChangeStyle(data) end)
	self.handler28  = GlobalDispatcher:AddEventListener(EventName.SummonThing_ADDED, function (data) self:SummonThingAddedHandle(data) end)
	self.hanlder29 = GlobalDispatcher:AddEventListener(EventName.StopCollect , function () self:HandleStopCollect() end)
	self.handler30 = GlobalDispatcher:AddEventListener(EventName.TeamListChange, function (data) self:RefreshTeamFlags(data) end)
	self.handler31 = GlobalDispatcher:AddEventListener(EventName.PLAYER_TITLE, function (data) self:RefreshPlayerTitile(data) end)
end

-- 刷头顶队伍标志
function SceneView:RefreshTeamFlags(data)
	if self.playerList then
		for i = 1, #self.playerList do
			local player = self.playerList[i]
			if player and player.head then
				player.head:AddTeamLeaderSign(data)
			end
		end
	end
end

-- 刷新称谓
function SceneView:RefreshPlayerTitile( data )
	if self.playerList then
		for i = 1, #self.playerList do
			local player = self.playerList[i]
			if player and player.head and player.guid == data.guid then
				player.head:UpdateFamilyName(player.head:GetFamilyTitle(data))
			end
		end
	end
end

function SceneView:RemoveEvent()
	GlobalDispatcher:RemoveEventListener(self.handler1 )
	GlobalDispatcher:RemoveEventListener(self.handler2 )
	GlobalDispatcher:RemoveEventListener(self.handler3 )
	GlobalDispatcher:RemoveEventListener(self.handler4 )
	GlobalDispatcher:RemoveEventListener(self.handler5 )
	GlobalDispatcher:RemoveEventListener(self.handler6 )

	GlobalDispatcher:RemoveEventListener(self.handler7 )
	GlobalDispatcher:RemoveEventListener(self.handler8 )

	GlobalDispatcher:RemoveEventListener(self.handler9 )
	
	GlobalDispatcher:RemoveEventListener(self.handler99)
	
	GlobalDispatcher:RemoveEventListener(self.handler10)

	GlobalDispatcher:RemoveEventListener(self.handler11)
	GlobalDispatcher:RemoveEventListener(self.handler12)
	GlobalDispatcher:RemoveEventListener(self.handler13)
	GlobalDispatcher:RemoveEventListener(self.handler14)

	--采集view层的相关事件监听
	GlobalDispatcher:RemoveEventListener(self.handler16)
	GlobalDispatcher:RemoveEventListener(self.handler17)
	GlobalDispatcher:RemoveEventListener(self.handler18)

	GlobalDispatcher:RemoveEventListener(self.handler19)
	GlobalDispatcher:RemoveEventListener(self.handler20)
	GlobalDispatcher:RemoveEventListener(self.handler21)
	GlobalDispatcher:RemoveEventListener(self.handler22)
	GlobalDispatcher:RemoveEventListener(self.handler23)
	GlobalDispatcher:RemoveEventListener(self.handler25)

	GlobalDispatcher:RemoveEventListener(self.handler27)
	GlobalDispatcher:RemoveEventListener(self.handler28)
	GlobalDispatcher:RemoveEventListener(self.hanlder29)
	GlobalDispatcher:RemoveEventListener(self.handler30)
	GlobalDispatcher:RemoveEventListener(self.handler31)
	GlobalDispatcher:RemoveEventListener(self.mainRoleAddedHandle)

end

-- 开启
function SceneView:Start()
	RenderMgr.Add(function () self:Update() end, "SceneRender")
end

function SceneView:Pause()
	RenderMgr.Realse("SceneRender")
end

function SceneView:ReStart()
	self:Start()
end
-------------------------------------------------------------------------------------------- 逻辑
function SceneView:_RenderObj( list )
	for i=1,#list do
		local obj = list[i]
		if obj then obj:Update() end 
	end
end

function SceneView:Update() -- 更新
	if self.isDestroyed or self.isClearing then return end
	self:_RenderObj(self.playerList)
	self:_RenderObj(self.monList)
	self:_RenderObj(self.summonThingList)
	self:_RenderObj(self.flyEffectList)

	self:_RenderObj(self.warningList)
	self:_RenderObj(self.sourceEffectList)
	self:_RenderObj(self.persistEffectList)
	local dt = Time.deltaTime
	TimeTool.SetServerTime( TimeTool.GetCurTime() + math.floor(dt*1000), false )
	self:SkillPreviewUpdate() --施法表现更新
	if self.frame % 17 == 0 then

		self:_RenderObj(self.npcList)
	elseif self.frame % 300 == 0 then
		if self.mainPlayer then self.mainPlayer:DoAsyncPos() end
	end
	self.frame = self.frame + 1

	if self.cameraCtrl ~= nil then
		self.cameraCtrl:pupdate()
	end
	EffectRenderObjManager.Instance():Update(dt)
end

function SceneView:OnObjectClick( obj )
	if not obj then return end
	if obj.guid and obj.type == PuppetVo.Type.PLAYER then --选中界面
		local js = CustomJoystick.mainJoystick
		local PType = PlayerFunBtn.Type
		if (js and js.joystick_touch.shape == Stage.inst.touchTarget) then return end
		local data = {}
		data.playerId = obj.vo.playerId
		data.funcIds = {PType.CheckPlayerInfo,
						 PType.AddFriend,
						 PType.Chat,
						 PType.InviteTeam,
						 PType.EnterTeam,
						 PType.EnterFamily}

		GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
	end

	if obj.guid and obj.type == PuppetVo.Type.NPC then
		if self.npcBehaviorMgr then
			self.npcBehaviorMgr:Behavior(obj)
		end
		
	end
	if obj.guid and  obj.type == PuppetVo.Type.Collect and self.isCollecting == false then
		self.curCollectObj = obj
		local pos = obj.transform.position
		local targetPos = Vector3.New(pos.x or 0, pos.y or 0, pos.z or 0)
		local mainPlayerPos = self:GetMainPlayerPos()

		if MapUtil.IsNearV3DistanceByXZ(mainPlayerPos , targetPos , math.sqrt((SceneConst.CollectDistance ^ 2) * 2)) then
			self:HandleStopMove()
		else
			targetPos.z = targetPos.z + SceneConst.CollectDistance
			self:GetMainPlayer():MoveToPositionByAgent(targetPos)
		end
	end

	if obj.guid and obj.type == PuppetVo.Type.DropItem and obj.vo.goodsType == GoodsVo.GoodType.box and self.isPickuping == false then
		local vop = obj.vo.dropPosition
		local targetPos = Vector3.New(vop.x or 0, vop.y or 0, vop.z + SceneConst.PickupDistance)
		self:GetMainPlayer():MoveToPositionByAgent(targetPos)
		self.curPickupObj = obj
	end


end

function SceneView:OnclickRay(e)
	local js = CustomJoystick.mainJoystick
	local mainUI = MainUIController:GetInstance():GetMainUI()
	local stage = Stage.inst
	local tpos = stage.touchPosition
	if ((js and js.joystick_touch.shape == stage.touchTarget) or (mainUI and mainUI.displayObject == stage.touchTarget)) then
		local hit = RaycastHit.New()
		local ray = Camera.main:ScreenPointToRay(Vector2.New(tpos.x, UnityEngine.Screen.height-tpos.y))

		local hitInfo = {}
		local infoList = {}
		local dropinfo = {}
		local hitInfo = UnityEngine.Physics.RaycastAll(ray)

		if hitInfo and hitInfo.Length >= 1 then
			for i=0,hitInfo.Length-1 do
				local isFind = 0
				if self.npcList then
			 		for k,v in ipairs(self.npcList) do
			 			if v.transform == hitInfo[i].transform then
			 				table.insert(infoList, v)
			 				isFind = 1
			 				break
			 			end
			 		end
			 	end
			 	if isFind == 0 then
			 		if self.playerList then
				 		for k,v in ipairs(self.playerList) do
				 			if v.transform == hitInfo[i].transform and v.transform ~= self.mainPlayerTransform then
				 				table.insert(infoList, v)
				 				break
				 			end
				 		end
				 	end
				end
			 	if isFind == 0 then
			 		if self.collectList then
				 		for k,v in ipairs(self.collectList) do
				 			if v.transform == hitInfo[i].transform then
				 				table.insert(infoList, v)
				 				isFind = 1
				 				break
				 			end
				 		end
				 	end
			 	end
				if self.dropList then
				 	for k,v in ipairs(self.dropList) do
				 		if v.transform == hitInfo[i].transform then
				 			table.insert(dropinfo, v)
				 			break
				 		end
				 	end
				end
		 	end 
		end
		if #infoList > 5 then
			for i=  #infoList, 6, -1 do
				table.remove(infoList, i)
			end
		end
		
		if dropinfo and #dropinfo > 0 then
			for i,v in ipairs(dropinfo) do
				if v.guid and v.type == PuppetVo.Type.DropItem and v.vo.goodsType == GoodsVo.GoodType.box and self.isPickuping == false then
					self:GetMainPlayer():MoveToPositionByAgent(Vector3.New(v.vo.dropPosition.x or 0, v.vo.dropPosition.y or 0, v.vo.dropPosition.z + SceneConst.PickupDistance))
					self.curPickupObj = v
				end
			end
		end

		if #infoList > 1 and infoList[1] then
		 	GlobalDispatcher:DispatchEvent(EventName.AllOBJECT_ONCLICK, infoList)
		else
			GlobalDispatcher:DispatchEvent(EventName.OBJECT_ONCLICK, infoList[1]) -- 返回场景对象
		end
	end


end

-----------点击所有场景对象
function SceneView:OnAllObjectClick(allObj)
	local clickChoose = ClickChoose.New()
	clickChoose:SetData(allObj)
	UIMgr.ShowPopupToPos(clickChoose, 960, 170, function()  end)
end	
-----------点击所有场景对象


function SceneView:GotoFightHandle( battleVo ) -- 主角发起技能前往战斗
	if not self.mainPlayer or not battleVo then return end
	BattleManager.New(battleVo, self.mainPlayer, self)
end

function SceneView:AddSceneObj()
	local v = table.remove(self.model.cacheSceneObjList)
	local t = v[2]
	local vo = v[1]
	if vo then
		if t == "role" then
			self:AddPlayer(vo)
		elseif t == "mon" then
			self:AddMon(vo)
		elseif t == "drop" then
			self:AddDrop(vo)
		elseif t == "npc" then
			self:AddNpc(vo)
		elseif t == "door" then
			self:AddDoor(vo)
		elseif t == "summon" then
			self:AddSummonThing(vo)
		end
	end
end

function SceneView:PlayerAddedHandle(data)
	self:AddSceneObj()
end
function SceneView:SummonThingAddedHandle(data)
	self:AddSceneObj()
end
function SceneView:MonsterAddedHandle(data)
	self:AddSceneObj()
end
function SceneView:NpcAddedHandle(data)
	self:AddSceneObj()
end
function SceneView:DoorAddedHandle(data)
	self:AddSceneObj()
end
function SceneView:DropAddedHandle(data)
	self:AddSceneObj()
end
function SceneView:WigSkillAddedHandle(data)
	local vo = self.model:GetWigSkill(data)
	if vo then self:AddPersistEffectByVo(vo) end
end

--------------------------技能-------------------------
function SceneView:SkillUpgradeHandler(data)
	if self.mainPlayer and data then
		local oldSkill = data.oldSkillId
		local newSkill = data.newSkillId
		self.mainPlayer.skillManager:UpdateSkill(oldSkill, newSkill)
		GlobalDispatcher:DispatchEvent(EventName.ResetSkillManagerComplete, {oldSkillId = oldSkill, newSkillId = newSkill})
	end
end
--
-------------------------------------------- 场景加载
	function SceneView:Layout(sceneId)
		local resId = tostring(sceneId)
		if resId == 0 then
			error("场景配置资源不存在 ")
		end
		SceneLoader.Show(true, false, 10, 100)
		PoolMgr.Init()

		-- 预加载怪物到对象池里面
		local monMap = self.model:GetCurAllMonResMap()
		for k,_ in pairs(monMap) do
			LoadMonster(k, function ( prefab )
				if self.isDestroyed then return end
				PoolMgr.PreAdd(PoolMgr.MonsterType, k)
			end)
		end
		
		for i=1, #playerMap do
			LoadPlayer(playerMap[i], function ( prefab )
				if self.isDestroyed then return end
				PoolMgr.PreAdd(PoolMgr.PlayerType, playerMap[i])
			end)
		end

		loaderMgr:LoadScene(resId,
			function (s)
				if self.isDestroyed then return end
				print("场景加载完成=>" ..s.." ".. self.model:GetSceneId())
				if not Camera.main  then
					LoadCam("maincamera", function ( o )
						if  o == nil then error("not camera!") return end
						local cam = GameObject.Instantiate(o)
						cam.name = "MainCamera"
						Camera.main.fieldOfView = 52
						self:LoadSceneCompleted()
					end)
				else
					self:LoadSceneCompleted()
					if self.model:GetSceneId() ~= 1001 then
						Camera.main.fieldOfView = 52
					end
				end
			end,
			function ( v )
				if self.isDestroyed then return end
				-- print("场景加载进度=>".. v)
				SceneLoader.SetProgress(math.max(1, math.floor(v*100)), 100)
			end,
		resId == "1004" or resId== "1001" or resId== "3004");

	end

	-- 加载必需的资源
	function SceneView:PreLoadAssets(res, cur, total)
		LoadEffect(res, function (o)
			if GameLoader.PreLoadAssets and #GameLoader.PreLoadAssets ~= 0 then
				self:PreLoadAssets(table.remove(GameLoader.PreLoadAssets, 1), cur+1, total)
				SceneLoader.SetProgress(cur, total)
			else
				GameLoader.PreLoadAssets = nil
			end
		end)
	end

	-- 摄像机配置表
	function SceneView:LoadSceneCompleted()
		self.lookMon = false
		self:InitEvent()
		self:LoadCamera() -- 加载相机
		GlobalDispatcher:DispatchEvent(EventName.SCENE_LOAD_FINISH, self.sceneId)
		self.loadFinish = true
		GlobalDispatcher:DispatchEvent(EventName.CAMERA_READY)
		self:Start()
		-- self.model.headerId = self.model:GetMainPlayer().playerId -- 测试
		SceneController:GetInstance():ReqShixiang()

		DelayCall(function ()
			SceneLoader.Show(false)	
		end, 2)
	end
	
	function SceneView:SkillPreviewInit()
		if self.skillPreview then
			self.skillPreview:Destroy()
			self.skillPreview = nil
		end
		self.skillPreview = SkillPreview.New()
	end

	function SceneView:SkillPreviewUpdate()
		if self.skillPreview then
			self.skillPreview:Update()
		end
	end

	function SceneView:CheckAutoFight()
		if self.model:IsTower() then
			if TowerModel:GetInstance().autoAttack then
				self:GetMainPlayer().autoFight:Start(false)
			end
		elseif self.model:IsTianti() then
			self:StopAutoFight(false)
		end
	end

	function SceneView:PkModelMapping()
		local mapPk = self.model:GetPkModel()
		local pkModel = self.mainPlayer.vo.pkModel
		local isTower = self.model:IsTower()
		if mapPk == 3 and pkModel == PkModel.Type.Peace and (not isTower) then --pk地图 模式切换
			UIMgr.Win_FloatTip("该区域为对战地图，建议将PK模式切换为全体")
			--GlobalDispatcher:DispatchEvent(EventName.PkModelChange, {PkModel.Type.All})
		end
	end

	function SceneView:LoadCamera()
		if not self.model then return end
		self.cameraCtrl = nil
		self.outDoorCameraCtrl = nil
		local sceneId = tostring(self.sceneId)
		local cam = Camera.main
		if self.model:IsOutdoor() or self.model:IsMain() or self.sceneId > 5000 then --野外
			self.outDoorCameraCtrl = cam.gameObject:AddComponent(typeof(NormalCameraController))
			self:UpdatOutDoorCameraBySceneId(sceneId)
			cam.farClipPlane = 200
			return
		end

		self.cameraCtrl = Camera.main.gameObject:AddComponent(typeof(CameraController))
		cam.farClipPlane = 80

		-- 临时把第一只默认出生点{x,y,z}作为摄像机的观察点
		if sceneId and self.cameraController_cfg[sceneId] then
			self:UpdateCameraById(sceneId)
		else -- 大荒塔|副本
			self.cameraFocusTemp = GameObject.New()
			self.cameraFocusTemp.name = "cameraFocusTemp"
			local towerData = TowerModel:GetInstance():GetTowerDataByMapId(sceneId)
			local pos = Vector3.New(0, 0, 0)
			if towerData then --大荒塔聚焦出生点
				pos = Vector3.New(towerData.refPoint[1] *0.01, towerData.refPoint[2] *0.01, towerData.refPoint[3] *0.01)
			elseif next(self.model.info.monsterSpawn) then  --副本聚焦出生点
				posData = self.model.info.monsterSpawn[next(self.model.info.monsterSpawn)].location
				pos = Vector3.New(posData[1], posData[2], posData[3])
			end
			self.cameraFocusTemp.transform.position = pos
			self:UpdateCameraById("CameraEmnu")
			self.lookMon = true
		end

		if self.cameraCtrl then
			self.cameraCtrl:SetCameraTest(self.cameraController_cfg.isDebug)
		end
	end

	-- 更新指定id的摄像机参数
	function SceneView:UpdateCameraById(id)
		local cfg = self.cameraController_cfg[id]
		if cfg then
			SceneView.modelDisappearDistance = cfg.modelDisappearDistance
			SceneView.headUIDisappearDistance = cfg.headUIDisappearDistance
			self:_SetCameraPara( cfg )
		end
	end

	--设置野外相机参数
	function SceneView:UpdatOutDoorCameraBySceneId(sceneId)
		local cfg = self.cameraOut_cfg[tostring(sceneId)] 
		if cfg then
			self.outDoorCameraCtrl.upFloat = cfg.upFloat or 6.5
			self.outDoorCameraCtrl.backFloat = cfg.backFloat or 9.3
			self.outDoorCameraCtrl.speed = cfg.speed or 6.0
			self.outDoorCameraCtrl:SetRot(cfg.rotAngle or 165)
		else
			self.outDoorCameraCtrl.upFloat = 6.5
			self.outDoorCameraCtrl.backFloat = 9.3
			self.outDoorCameraCtrl.speed = 6.0
			self.outDoorCameraCtrl:SetRot(165)
		end
	end

	function SceneView:_SetCameraPara( cfg )
		if self.cameraCtrl == nil then return end
		self.cameraCtrl:SetCameraOffset(Vector3.New(cfg.cameraPosX, cfg.cameraPosY, cfg.cameraPosZ), cfg.fAngleX, cfg.fAngleY, cfg.fDis, cfg.InnerRing, 
		cfg.OuterRing, cfg.rotX_paraI, cfg.rotX_paraII, cfg.rotXMax, cfg.scaleMinimum, 
		cfg.cameraScale_paraI, cfg.cameraScale_paraII, cfg.fTweenTime, cfg.cTween_paraI, 
		cfg.cTween_paraII, cfg.fNearDis, cfg.wQDefaultDis, cfg.nQDefaultDis, cfg.wQMaxDis,
		cfg.ctweenTime )
	end

	-- 照相机追随的目标
	function SceneView:SetCameraCtrlTarget( transform )
		if self.cameraCtrl then 
			self.cameraCtrl.followTarget = transform
			return 
		end

		if self.outDoorCameraCtrl then 
			self.outDoorCameraCtrl:SetFollowTarget(transform)
			return 
		end
	end
	-- lua中设置摄像机转角
	function SceneView:SetRot( v )
		if self.outDoorCameraCtrl then
			self.outDoorCameraCtrl:SetRot(v)
		end
	end

------------------------------------------------手柄
	function SceneView:MoveJoystick(angle)
		self.preAngle = angle
		self.isMoveByJoystick = true
		if self.lockRoleMove then return end
		if angle and self.mainPlayer then
			local mainPlayer = self.mainPlayer
			if mainPlayer:IsLock() or mainPlayer:IsDie() then return end
			local animatorMgr = mainPlayer:GetAnimator() 
			mainPlayer.isAutoWalk = false
			mainPlayer:RestoreInput()
			mainPlayer:MoveByAngle(angle)
			if animatorMgr and animatorMgr.curAction == "idle" then
				mainPlayer:PlayAction("run")
				ZDModel:GetInstance():SetFollow(false)-- 取消跟随队长
			end
			mainPlayer:StopWorldNavigation()
			GlobalDispatcher:DispatchEvent(EventName.AUTO_FIGHT,false)  --终止挂机，通知挂机图标切回非挂机状态
			TaskModel:GetInstance():BreakAuto()
		end
	end

	function SceneView:StopJoystick()
		if self.mainPlayer then
			if self.mainPlayer:IsLock() or self.mainPlayer:IsDie() then return end
			self.mainPlayer:StopMove()
			self.model:CleanPathingFlag()
			WorldMapConst.AutoWalkPath = nil
		end
	end

	function SceneView:LockRoleMove()
		self.lockRoleMove = true
		self:StopJoystick()
	end

	function SceneView:RealseRoleMove()
		self.lockRoleMove = false
		if self.isMoveByJoystick then
			self:MoveJoystick(self.preAngle)
		end
	end
------------------------------------------------混合列表
	--获取队员
	function SceneView:GetTeammember(fighterId)
		local result = {}
		local fighter = self:GetLivingThing(fighterId)
		local teamModel = ZDModel:GetInstance()
		if fighter and self.mixtureList and #self.mixtureList > 0 then
			local canAttack = false
			for i = 1, #self.mixtureList do
				local obj = self.mixtureList[i]
				if not obj:IsDie() then
					canAttack = false
					if teamModel:IsTeamMate(obj.vo.playerId) then
						canAttack = true --包含队友
					end
					if canAttack then
						table.insert(result, obj)
					end
				end
			end
		end
		return result
	end

	--获取敌人
	function SceneView:GetEnemies(fighterId)
		local result = {}
		local fighter = self:GetLivingThing(fighterId)
		local teamModel = ZDModel:GetInstance()
		if fighter and self.mixtureList and #self.mixtureList > 0 then
			local canAttack = false
			for i = 1, #self.mixtureList do
				local obj = self.mixtureList[i]
				if not obj:IsDie() and obj.guid ~= fighterId then
					canAttack = true
					if fighter:IsMonster() and obj:IsMonster() then 
						canAttack = false --怪物不可以攻击怪物
					elseif fighter:IsSummonThing() and fighter.owner and fighter.owner.guid == obj.guid then 
						canAttack = false --召唤物不能攻击主人
					elseif fighter:IsHuman() and obj:IsSummonThing() and obj.owner and obj.owner.guid == fighterId then
						canAttack = false --主人不能攻击自己的召唤物
					elseif fighter:IsHuman() and teamModel:IsTeamMate(obj.vo.playerId) then
						canAttack = false --不包含队友
					end
					if canAttack then
						table.insert(result, obj)
					end
				end
			end
		end
		return result
	end

	--获取友方单位
	function SceneView:GetFriends(fighterId, includeSelf)
		local result = {}
		local fighter = self:GetLivingThing(fighterId)
		local teamModel = ZDModel:GetInstance()
		if fighter and self.mixtureList and #self.mixtureList > 0 then
			local canAttack = false
			for i = 1, #self.mixtureList do
				local obj = self.mixtureList[i]
				if not obj:IsDie() then
					canAttack = false
					if includeSelf and fighter.guid == obj.guid then
						canAttack = true --包含自己
					elseif teamModel:IsTeamMate(obj.vo.playerId) then
						canAttack = true --包含队友
					elseif fighter:IsSummonThing() and fighter.owner and fighter.owner.guid == obj.guid then 
						canAttack = true --召唤物的主人
					elseif fighter:IsHuman() and obj:IsSummonThing() and obj.owner and obj.owner.guid == fighterId then
						canAttack = true --自己的召唤物
					end
					if canAttack then
						table.insert(result, obj)
					end
				end
			end
		end
		return result
	end
	
	--混合列表
	function SceneView:GetMixtureList()
		return self.mixtureList
	end

	function SceneView:AddToMixtureList(sceneObj)
		table.insert(self.mixtureList, sceneObj)
	end

	function SceneView:RemoeFromMixtureList(guid)
		for i = 1, #self.mixtureList do
			if self.mixtureList[i].guid == guid then
			   table.remove(self.mixtureList, i)
			   break
			end
		end
	end	
--

------------------------------------------------玩家
	function SceneView:AddPlayer( vo )
		if self.isDestroyed or vo == nil or not self.model:GetPlayer( vo.guid ) or self:IsExistPlayer(vo.guid) or #self.playerList > self.maxPlayerNum then return end
		local player = Player.New(vo)
		table.insert(self.playerList, player)
		self:AddToMixtureList(player)
		vo.mId = vo.dressStyle
		PoolMgr.Add(PoolMgr.PlayerType, vo.dressStyle, function ( go )
			if self.isDestroyed then return end
			if ToLuaIsNull(go) or not self.model:GetPlayer( vo.guid ) then return end
			local tf = go.transform

			local gx, gy = MapUtil.LocalToGrid(vo.position)
			if vo.isMainRole and Astar.block ~= nil and Astar.isBlock(gx, gy) then
				local block = Astar.block
				for j=1,#block do
					for i=#block[1],1,-1 do
						if block[j][i] == 0 then
							local v = {x=i,y=j}
							local px, py = MapUtil.GridToLocal( v )
							vo.position.x = px
							vo.position.z = py
							break
						end
					end
				end
				block=nil
			end

			Util.SetLocalPosition(tf, vo.position.x or 0 , vo.position.y or 0 , vo.position.z or 0)
			Util.SetLocalRot(tf, vo.direction.x or 0 , vo.direction.y or 0 , vo.direction.z or 0)
			go.layer = LayerMask.NameToLayer("Character")
			player:SetGameObject( go )
			if vo.isMainRole then
				go.name = "MainPlayer_"..vo.guid
				self.mainPlayerTransform = tf
				self.mainPlayer = player
				self:SetCameraCtrlTarget(tf)
			
				GlobalDispatcher:DispatchEvent(EventName.CROSS_PATH)
				GlobalDispatcher:DispatchEvent(EventName.MAIN_ROLE_ADDED, player)
				self:MainRoleAddedHandler()

				if (self.model:IsTower() or self.model:IsCopy()) and self.cameraFocusTemp then --副本或者大荒塔主角朝向boss出生点
					self.mainPlayer:SetDirByTargetRightNow(self.cameraFocusTemp.transform.position)
				end
				self.ctrl:__ReqRoundElement()
			else
				go.name = "P_"..vo.guid.."_"..vo.dressStyle
			end
			GlobalDispatcher:DispatchEvent(EventName.SCENE_PLAYER_ADDED, vo.guid)				-- x玩家进场
		end)
	end
 	
	function SceneView:RemovePlayer( guid )
		self:RemoeFromMixtureList(guid)
		local idx = self:IsExistPlayer(guid)
		if not idx then return end
		local player = table.remove(self.playerList, idx)
		player:Destroy()
		player = nil
	end
	
	function SceneView:IsExistPlayer( guid )
		if self.playerList == nil then return nil end
		for i, p in ipairs(self.playerList) do
			if p.guid == guid then
				return i
			end
		end
		return nil
	end

	-- 获得主角
	function SceneView:GetMainPlayer()
		return self.mainPlayer
	end

	-- 设置主角
	function SceneView:SetMainPlayer(obj)
		self.mainPlayer = obj
	end

	function SceneView:GetPlayer(guid)
		local idx = self:IsExistPlayer(guid)
		if not idx then return nil end
		return self.playerList[idx]
	end

	function SceneView:MainRoleAddedHandler()
		self:SkillPreviewInit()
		self:CheckAutoFight()
		self:PkModelMapping()
		ClanCtrl:GetInstance():C_GetGuild()--帮派信息
	end

	---------------------------自动战斗------------------------------------
	function SceneView:StartAutoFight(showTips)
		local mainPlayer = self:GetMainPlayer()
		if mainPlayer and mainPlayer.autoFight then
			mainPlayer.autoFight:Start(showTips)
		end
	end

	function SceneView:StopAutoFight(showTips)
		local mainPlayer = self:GetMainPlayer()
		if mainPlayer and mainPlayer.autoFight then
			mainPlayer.autoFight:Stop(showTips)
		end
	end

	function SceneView:GetAutoFightCtr()
		local mainPlayer = self:GetMainPlayer()
		if mainPlayer and mainPlayer.autoFight then
			return mainPlayer.autoFight
		end
	end

	--	

	---------------------------寻路-----------------主角-------------------
		-- 瞬间移动（不用a星）
		function SceneView:Moveto( vec3, player )
			if not player or vec3 == nil then return end
			player:SetPosition( vec3 )
		end
		
		-- 自由移动（不用a星）
		function SceneView:FreeMove( vec3, player )
			if not player or vec3 == nil then return end
			player:DoMove(vec3)
		end
		-- vec3 auto move
		function SceneView:AutoMove( vec3 )
			if not self.mainPlayer then return end
			self.mainPlayer.isAutoWalk = true
			print("自动寻路改掉了，这里没处理。。")
		end
		--引导触发判断
		--@param param 触发目标id字符串，如:N_96590993888507_1101
		--@param state 触发状态 true:触发 false:结束触发
		function SceneView:JudgeGuideState(param,state)
			local npcId = tonumber(StringSplit(param, '_')[3])
			if npcId == 1100 then --入侵
				-- if state then
				-- 	IntrudeController:GetInstance():Open()
				-- else 
				-- 	IntrudeController:GetInstance():Close()
				-- end
			elseif npcId == 1101 then --副本
				-- if state then
				-- 	MapSelectUIController:GetInstance():OpenPanel()
				-- else 
				-- 	MapSelectUIController:GetInstance():ClosePanel()
				-- end
			end
		end
--

function SceneView:GetLivingThing(guid)
	return self:GetPlayer(guid) or self:GetMon(guid) or self:GetSummonThing( guid ) or self:GetNpc(guid)
end

function SceneView:GetThing(guid)
	return self:GetPlayer(guid) or self:GetMon(guid) or self:GetSummonThing( guid ) or self:GetPersistEffect(guid) or self:GetNpc(guid)
end

------------------------------------------------召唤物
	function SceneView:AddSummonThing( vo )
		if self.isDestroyed then return end
		if vo == nil then return end
		local guid = vo.guid
		if not self.model:GetSummonThing(guid) or self:IsExistSummonThing(guid) then return end
		local summonThing = SummonThing.New(vo)
		vo.mId = vo.dressStyle
		PoolMgr.Add(PoolMgr.MonsterType, vo.dressStyle, function ( go )
			if self.isDestroyed or ToLuaIsNull(go) or not self.model:GetSummonThing(guid) or self:IsExistSummonThing(guid)~=nil then return end
			go.name = "Summon_"..guid.."_"..vo.eid
			summonThing:SetGameObject(go)
			summonThing:SetDieHandler(function() self:MonsterDeadCallBack() end )  --死亡回调
			GlobalDispatcher:DispatchEvent(EventName.SCENE_SummonThing_ADDED, summonThing.transform)				-- x玩家进场
			table.insert(self.summonThingList, summonThing)
			self:AddToMixtureList(summonThing)
		end)

	end

	function SceneView:RemoveSummonThing( guid )
		self:RemoeFromMixtureList(guid)
		local idx = self:IsExistSummonThing(guid)
		if not idx then return end
		local summonThing = table.remove(self.summonThingList, idx)
		summonThing:Destroy()
		summonThing = nil
	end

	function SceneView:IsExistSummonThing( guid )
		if self.summonThingList == nil then return nil end
		local vo = nil
		for i, p in ipairs(self.summonThingList) do
			if p.vo.guid == guid then
				return i
			end
		end
		return nil
	end

	function SceneView:GetSummonThing( id )
		local idx = self:IsExistSummonThing(id)
		if not idx then return nil end
		return self.summonThingList[idx]
	end
--

------------------------------------------------怪物
	function SceneView:AddMon( vo )
		if self.isDestroyed then return end
		if vo == nil or not self.model:GetMon(vo.guid) or self:IsExistMon(vo.guid) then return end
		local mon = Monster.New(vo)
		vo.mId = vo.dressStyle
		PoolMgr.Add(PoolMgr.MonsterType, vo.dressStyle, function ( gameObject )
			if self.isDestroyed or ToLuaIsNull(gameObject) or not self.model:GetMon( vo.guid ) or self:IsExistMon(vo.guid)~=nil then return end
			gameObject.name = "M_"..vo.guid
			mon:SetGameObject( gameObject )
			mon:SetDieHandler(function() self:MonsterDeadCallBack() end )  --死亡回调
			if mon.head then
				mon.head.hpBar:SetVisible(false)
				mon.head.showState = false
			end
			GlobalDispatcher:DispatchEvent(EventName.SCENE_MONSTER_ADDED, mon.transform)				-- x玩家进场
			if mon.monsterType ==  MonsterVo.Type.Boss then
				GlobalDispatcher:DispatchEvent(EventName.BOSS_ENTER,mon.vo)
				if (self.model:IsTower() or self.model:IsCopy()) and self.mainPlayer then --副本或者大荒塔boss朝向角色
					mon:SetDirByTargetRightNow(self.mainPlayerTransform.position)
				end
				if self.model:IsCopy() and self.cameraCtrl then --副本聚焦boss
					self.cameraCtrl.boss = gameObject.transform
				end
			end
			if mon.monsterType == MonsterVo.Type.Elite then
				if self.cameraCtrl and self.cameraCtrl.boss == nil and self.model:IsCopy() then --副本没有聚焦boss，则聚焦精英
					self.cameraCtrl.boss = gameObject.transform
				end
			end
			table.insert(self.monList,mon)
			self:AddToMixtureList(mon)
		end)
	end

	function SceneView:GetCurFocusMonster()
		return self.curFocusMon
	end

	function SceneView:FocusTemp()
		if self.cameraCtrl == nil then return end
		--聚焦其他boss
		for i = 1, #self.monList do
			local mon = self.monList[i]
			if not mon:IsDie() and mon.monsterType == MonsterVo.Type.Boss then
				self.cameraCtrl.boss = mon.transform
				return
			end
		end
		--聚焦其他精英怪
		for i = 1, #self.monList do
			local mon = self.monList[i]
			if not mon:IsDie() and mon.monsterType == MonsterVo.Type.Elite then
				self.cameraCtrl.boss = mon.transform
				return
			end
		end
		if self.model:IsCopy() and self.lookMon then 
			self.cameraCtrl.boss = self.cameraFocusTemp.transform
		end
	end

	function SceneView:RemoveMon( guid )
		self:RemoeFromMixtureList(guid)
		local idx = self:IsExistMon(guid)
		if not idx then return end
		local mon = table.remove(self.monList, idx)
		if mon.monsterType ==  MonsterVo.Type.Boss then
			GlobalDispatcher:DispatchEvent(EventName.BOSS_OUTTER, mon.vo)
		else
			if mon.head then
				mon.head.showState = false
				mon.head.hpBar:SetVisible(false)
			end
		end
		
		mon:Destroy()
		mon = nil
	end

	function SceneView:IsExistMon( guid )
		if self.monList == nil then return nil end
		local vo = nil
		for i, p in ipairs(self.monList) do
			if p.vo.guid == guid then
				return i
			end
		end
		return nil
	end

	function SceneView:GetMon( id )
		local idx = self:IsExistMon(id)
		if not idx then return nil end
		return self.monList[idx]
	end
--

----------飞行特效-------
	function SceneView:AddFlyEfffect(flyEff)
		table.insert(self.flyEffectList, flyEff) 
	end

	function SceneView:RemoveFlyEffect( id )
		for i = 1, #self.flyEffectList do
			if self.flyEffectList[i].flyId == id then
				local flyEffect = table.remove(self.flyEffectList, i)
				destroyImmediate(flyEffect.gameObject)
				break
			end
		end
	end
--

----------伤害源特效-------
	function SceneView:AddSourceEfffect(sourceEff)
		table.insert(self.sourceEffectList, sourceEff) 
	end

	function SceneView:RemoveSourceEffect( id )
		for i = 1, #self.sourceEffectList do
			if self.sourceEffectList[i].id == id then
				local sourceEffect = table.remove(self.sourceEffectList, i)
				destroyImmediate(sourceEffect.gameObject)
				break
			end
		end
	end
--

----------持续性特效-------
	function SceneView:AddPersistEffectByVo(persistEffectVo)
		local persistEffect = PersistEffect.New(persistEffectVo.skillId, persistEffectVo.guid, persistEffectVo.releasePoint, persistEffectVo.leftTime, persistEffectVo.wigId)
		self:AddPersistEffect(persistEffect)
	end
	function SceneView:AddPersistEffect(persistEffect)
		table.insert(self.persistEffectList, persistEffect) 
	end
	function SceneView:RemoveWigSkill(guid)
		for i = 1, #self.persistEffectList do
			if self.persistEffectList[i] and (self.persistEffectList[i].guid == guid) then
				local persistEffect = table.remove(self.persistEffectList, i)
				destroyImmediate(persistEffect.gameObject)
			end
		end
	end
	function SceneView:GetPersistEffect(guid)
		if self.persistEffectList == nil or guid == nil then return nil end
		local vo = nil
		for k, v in ipairs(self.persistEffectList) do
			if v.guid == guid then
				return v
			end
		end
		return nil		
	end

	function SceneView:GetWarnByIndex( index )
		if #self.warningList > 0 and self.warningList[index] then
			return self.warningList[index]
		end
		return nil
	end

	function SceneView:AddWarningEffect( warningEff )
		table.insert(self.warningList, warningEff)  
	end

	function SceneView:RemoveWarn( id )
		for i = 1, #self.warningList do
			if self.warningList[i].warningId == id then
				local warning = table.remove(self.warningList, i)
				destroyImmediate(warning.gameObject)
				break
			end
		end
   end
	--暂停游戏
	function SceneView:PauseGame()
		--遍历是否有怪物需要暂停
		if self.summonThingList then
			for k,v in pairs(self.summonThingList) do
				local mon_ani_mgr = v.animatorMgr
				if mon_ani_mgr then
					mon_ani_mgr:Pause()
				end
			end
		end
		if self.monList then
			for k,v in pairs(self.monList) do
				local mon_ani_mgr = v.animatorMgr
				if mon_ani_mgr then
					mon_ani_mgr:Pause()
				end
			end
		end
		--遍历角色是否需要暂停
		if self.playerList then
			for k,v in pairs(self.playerList) do
				local player_ani_mgr = v.animatorMgr
				if player_ani_mgr then
					player_ani_mgr:Pause()
				end
			end
		end
		self:Pause()
	end
	function SceneView:ContinueGame()
			--遍历是否有怪物需要暂停
		if self.summonThingList then
			for k,v in pairs(self.summonThingList) do
				local mon_ani_mgr = v.animatorMgr
				if mon_ani_mgr then
					mon_ani_mgr:Continue()
				end
			end
		end
		if self.monList then
			for k,v in pairs(self.monList) do
				local mon_ani_mgr = v.animatorMgr
				if mon_ani_mgr then
					mon_ani_mgr:Continue()
				end
			end
		end
		--遍历角色是否需要暂停
		if self.playerList then
			for k,v in pairs(self.playerList) do
				local player_ani_mgr = v.animatorMgr
				if player_ani_mgr then
					player_ani_mgr:Continue()
				end
			end
		end
		self:ReStart()
	end
------------------------------------------------npc
	function SceneView:AddNpc( vo )
		if self.isDestroyed then return end
		if vo == nil or not self.model:GetNpc( vo.eid ) or self:IsExistNpc(vo.eid) then return end
		vo.dressStyle = vo.dressStyle or ""
		local npc = Npc.New(vo)
		local addObj = function ( go )
			if self.isDestroyed or not self.model:GetNpc( vo.eid )or self:IsExistNpc(vo.eid)~=nil then return end
			go.name = "N_"..vo.eid.."_"..vo.dressStyle
			npc:SetGameObject( go )
			table.insert(self.npcList, npc)
			GlobalDispatcher:DispatchEvent(EventName.NPC_ENTERSCENE, npc)
		end
		if vo.dressStyle == "" then
			local go = GameObject.New()
			addObj(go)
		else
			vo.mId = vo.dressStyle
			LoadNPC(vo.dressStyle, function ( o ) 
				if o == nil then return end
				local go = GameObject.Instantiate(o)
				addObj(go)
			end)
		end
	end

	function SceneView:RemoveNpc( eid )
		local idx = self:IsExistNpc(eid)
		if not idx then return end
		local npc = table.remove(self.npcList, idx)
		npc:Destroy()
		npc = nil
	end

	function SceneView:IsExistNpc( eid )
		if self.npcList == nil then return nil end
		local vo = nil
		for i, p in ipairs(self.npcList) do
			vo = p.vo
			if vo and vo.eid == eid then
				return i
			end
		end
		return nil
	end
	function SceneView:GetNpc( eid )
		local idx = self:IsExistNpc(eid)
		if not idx then return nil end
		return self.npcList[idx]
	end
	
-------------------------采集-------------------------------------
	function SceneView:AddCollect(vo)
		if self.isDestroyed then return end
		if vo == nil or TableIsEmpty(self.model:GetCollectById(vo.playerCollectId)) or self:IsExistCollect(vo.playerCollectId) then
			return
		end

		if vo.modelId ~= "" and vo.modelId ~= 0 then
			local collect = Collect.New(vo)

			LoadCollect(vo.modelId, function(prefab)
				if self.isDestroyed or TableIsEmpty(self.model:GetCollectById(vo.playerCollectId)) or self:IsExistCollect(vo.playerCollectId) then
					return
				end
				if prefab == nil then return end
				local collectGo = GameObject.Instantiate(prefab)
				
				collectGo.name = string.format("collect_%s_%s", vo.playerCollectId, vo.modelId)
				collect:SetGameObject(collectGo)

				table.insert(self.collectList, collect)
			end)
		end
	end
	function SceneView:HandleAddCollectItemList(voList)
		if voList then
			for index = 1, #voList do
				self:AddCollect(voList[index])
			end
		end
	end
	function SceneView:RemoveCollect(playerCollectId)
		if playerCollectId then
			local collectObj, collectIndex = self:GetCollect(playerCollectId)
			if collectObj ~= nil and collectIndex ~= -1 and self.collectList[collectIndex] ~= nil then
				self.collectList[collectIndex]:Destroy()
				table.remove(self.collectList, collectIndex)
			end
		end
	end
	function SceneView:HandleRemoveCollect(playerCollectId)
		self:RemoveCollect(playerCollectId)
	end
	function SceneView:HandleRemoveCollectItemList(playerCollectIdList)
		if playerCollectIdList then
			for index = 1, #playerCollectIdList do
				self:RemoveCollect(playerCollectIdList[index])
			end
		end
	end
	function SceneView:HandleEndCollect(isSucc)
		if isSucc == true then
			self:SetCollectState(false)
			if self.collectItemPanel ~= nil then
				
				self.collectItemPanel:Destroy()
				self.collectItemPanel = nil
				self.isOpenCollectUI = false
			end

			local mainPlayerObj = self:GetMainPlayer()
			if mainPlayerObj then
				mainPlayerObj:DoStand()
				mainPlayerObj:ShowWeapon()	
			end
		end
	end
	function SceneView:HandleStopMove()
		local cur = self.curCollectObj
		if cur ~= nil and cur.vo ~= nil and self.isCollecting == false then
			local mainPlayerPos = self:GetMainPlayerPos()
			if MapUtil.IsNearV3DistanceByXZ(mainPlayerPos, cur.transform.position, math.sqrt((SceneConst.CollectDistance ^ 2) * 2)) then
				self:LookAtCollectItem()
				self.ctrl:C_StartCollect(cur.vo.playerCollectId)

				self.isCollecting = true
				self.curCollectObj = nil
			end
		end
		cur = self.curPickupObj
		if cur ~= nil and cur.vo ~= nil and self.isPickuping == false then
			local mainPlayerPos = self:GetMainPlayerPos()
			if MapUtil.IsNearV3DistanceByXZ(mainPlayerPos, cur.vo.dropPosition, math.sqrt((SceneConst.PickupDistance ^ 2) * 2)) then
				self:LookAtPickupItem()
				
				CollectModel:GetInstance():SetCollectData("执行中...", 2)
				GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity)
				self.ctrl:GetScene():StopAutoFight(false)
				self.pickupItemPanel =  CollectView:GetInstance():OpenLoadingCollectItemPanel()
				self.isPickuping = true
				self.isOpenPickupUI = true
				self.pickupItemPanel:SetEndFun(function ()
					if cur and cur.vo then
						self.ctrl:C_Pickup(cur.vo.eid)
					end
					
					self.isPickuping = false
					self.curPickupObj = nil
					if self.pickupItemPanel ~= nil then
						self.pickupItemPanel:Destroy()
						self.pickupItemPanel = nil
						self.isOpenPickupUI = false
					end
						
				end)
			end
		end
	end
	local dropSends = {}
	function SceneView:HandleRoleStopWalk()
		if self.mainPlayer then
			dropSends={}
			self:PickupThing()
			ZDModel:GetInstance():StopFollowIfReach(self.mainPlayer)
		end
	end

	function SceneView:PickupThing()
		if #dropSends ~= 0 then
			self.ctrl:C_Pickup(table.remove(dropSends,1))
		else
			local pos = self.mainPlayer:GetPosition()
			if self.dropList then
				for _, drop in pairs(self.dropList) do
					if drop then
						local vo = drop:GetVo()
						if vo and vo.dropPosition and vo.eid and vo.goodsType ~= GoodsVo.GoodType.box then
							local dist = Vector3.DistanceEx(pos, vo.dropPosition)
							if dist < 2.42 then
								table.insert(dropSends, vo.eid)
							end
						end
					end
				end
				if #dropSends ~= 0 then
					self.ctrl:C_Pickup(table.remove(dropSends,1))
				end
			end
		end
	end

	function SceneView:LookAtCollectItem()
		local cur = self.curCollectObj
		if self.mainPlayer and cur ~= nil then
			local tf = cur.transform
			local tfPos = tf.position
			local lookVect3 = Vector3.New(tfPos.x, tfPos.y, tfPos.z - SceneConst.CollectDistance)
			self.mainPlayerTransform:LookAt(lookVect3)
		end
	end
	function SceneView:LookAtPickupItem()
		local cur = self.curPickupObj
		if self.mainPlayer and cur ~= nil then
			local main = self.mainPlayerTransform
			local lookVect3 = Vector3.New(cur.vo.dropPosition.x , main.position.y, cur.vo.dropPosition.z - SceneConst.PickupDistance)
			main:LookAt(lookVect3)
		end
	end
	function SceneView:IsExistCollect(playerCollectId)
		local rtnIsExist = false
		if playerCollectId then
			local collectObj, collectIndex = self:GetCollect(playerCollectId)
			if collectObj ~= nil and collectIndex ~= -1 then
				rtnIsExist = true
			end
		end
		return rtnIsExist
	end
	function SceneView:GetCollect(playerCollectId)
		local rtnCollectObj = nil
		local rtnCollectIndex = -1
		if playerCollectId then
			for index = 1, #self.collectList do
				if self.collectList[index].vo.playerCollectId == playerCollectId then
					rtnCollectObj = {}
					rtnCollectObj = self.collectList[index]
					rtnCollectIndex = index
					break
				end
			end
		end
		return rtnCollectObj, rtnCollectIndex
	end
	function SceneView:StartCollectHandle(playerCollectId)
		if playerCollectId ~= nil and self:IsExistCollect(playerCollectId) == true then
			local collectVo = self.model:GetCollectById(playerCollectId)
			local collectObj, collectIndex = self:GetCollect(playerCollectId)
			if not TableIsEmpty(collectVo) then
				local collectType = collectVo:GetCollectType()
				if collectType ~= SceneConst.CollectType.Task and collectType ~= SceneConst.CollectType.None then
					CollectModel:GetInstance():SetCollectVo(collectVo)
					local collectTime = collectVo:GetCollectTime()
					CollectModel:GetInstance():SetCollectData(string.format("执行中..."), (collectTime * 0.001) or 0)

					if self.mainPlayer then
						if collectObj and not ToLuaIsNull(collectObj.transform) then self.mainPlayer.gameObject.transform:LookAt(collectVo.position, Vector3.up) end
						self.mainPlayer:HideWeapon()
						self.mainPlayer:GetAnimator():PlayByTime("collecting", collectTime * 0.001, function()
							self.mainPlayer:DoStand()
							self.mainPlayer:ShowWeapon()
						end)
					end
					GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity)
					self.ctrl:GetScene():StopAutoFight(false)
					self.collectItemPanel =  CollectView:GetInstance():OpenLoadingCollectItemPanel()
					self.isOpenCollectUI = true
				end
			end
		end
	end
	function SceneView:HandlePlayerWalk()
		
		if self.collectItemPanel ~= nil and self.isOpenCollectUI == true then
			self:CloseCollectLoadingPanel()
		end

		if self.pickupItemPanel ~= nil and self.isOpenPickupUI == true then
			self:ClosePickupItemPanel()
		end
	end
	function SceneView:CloseCollectLoadingPanel()
		
		if self.collectItemPanel ~= nil then
			self.isCollecting = false

			local collectVo = CollectModel:GetInstance():GetCollectVo()
			if not TableIsEmpty(collectVo) then
				if collectVo:GetCollectType() == SceneConst.CollectType.Advanced or collectVo:GetCollectType() == SceneConst.CollectType.General or collectVo:GetCollectType() == SceneConst.CollectType.Task  then
					self.collectItemPanel:EndCollect()  --意外打断的时候，需要向客户端发结束请求
				end
			end
			self.collectItemPanel:Destroy()
		
			self.collectItemPanel = nil
			

			self.isOpenCollectUI = false

			UIMgr.Win_FloatTip("采集中断")

			local mainPlayerObj = self:GetMainPlayer()
			if mainPlayerObj then
				mainPlayerObj:DoStand()
				mainPlayerObj:ShowWeapon()	
			end
		end
	end

	function SceneView:HandleStopCollect()
		if self.collectItemPanel ~= nil and self.isOpenCollectUI == true then
			self:CloseCollectLoadingPanel()
		end
	end

	function SceneView:ClosePickupItemPanel()
		if self.pickupItemPanel ~= nil then
			if self.pickupItemPanel ~= nil then
				self.pickupItemPanel:Destroy()
				self.pickupItemPanel = nil
			end
			self.isPickuping = false
			self.isOpenPickupUI = false
			self.curPickupObj = nil
			UIMgr.Win_FloatTip("拾取中断")		
		end
	end

	function SceneView:SetCollectState(bl)
		if bl ~= nil then
			self.isCollecting = bl
		end
	end
	function SceneView:HandleChangeStyle()
		self:SkillPreviewInit()
	end
	function SceneView:HandleMainRoleDie()
		if self.collectItemPanel ~= nil and self.isOpenCollectUI == true then
			self:CloseCollectLoadingPanel()
		end
		ZDModel:GetInstance():SetFollow(false)-- 取消跟随队长
	end
--------------------------传送门----------------------------------
	function SceneView:AddDoor( vo )

		if self.isDestroyed then return end
		if vo == nil or not self.model:GetDoor( vo.eid ) or self:IsExistDoor(vo.eid) then return end
		local door = Door.New(vo)
		table.insert(self.doorList,door)
	end
	function SceneView:RemoveDoor( eid )
		local idx = self:IsExistDoor(eid)
		if not idx then return end
		local door = table.remove(self.doorList, idx)
		door:Destroy()
		door = nil
	end
	function SceneView:IsExistDoor( eid )	
		if self.doorList == nil then return nil end
		local vo = nil
		for i, p in ipairs(self.doorList) do
			vo = p.vo
			if vo and vo.eid == eid then
				return i
			end
		end
		return nil
	end
	function SceneView:GetDoor( eid )
		local idx = self:IsExistDoor(eid)
		if not idx then return nil end
		return self.doorList[idx]
	end
--
--------------------------掉落----------------------------------
	function SceneView:AddDrop(vo)
		if self.isDestroyed then return end
		if vo == nil or self:IsExistDrop(vo.eid) or not self.model:GetDrop(vo.eid) then return end
		local drop = DropItem.New(vo)
		drop:SetItemShow()
		table.insert(self.dropList, drop)
	end
	function SceneView:RemoveDrop(eid)
		local idx = self:IsExistDrop(eid)
		if not idx then return end
		local drop = table.remove(self.dropList, idx)
		drop:Destroy()
		drop = nil
	end
	function SceneView:IsExistDrop(eid)	
		if self.dropList == nil then return nil end
		for i, v in ipairs(self.dropList) do
			if v.vo and v.vo.eid == eid then
				return i
			end
		end
		return nil
	end
	function SceneView:GetDrop(eid)
		local idx = self:IsExistDrop(eid)
		if not idx then return nil end
		return self.dropList[idx]
	end
--


------------------------------------------------主摄像机控制器
	--震屏
	function SceneView:DoShake(data) 
		if self.outDoorCameraCtrl then
			if data and data.param1 then
				self.outDoorCameraCtrl:SetDuration(data.param1)
			end
			self.outDoorCameraCtrl:shake()
		end
	end

	-------------------------------------------------------------------------
function SceneView:ChangeNPCHeadStateUI()
	for index = 1, #self.npcList do
		local curNpc = self.npcList[index]
		if curNpc and curNpc.vo then
			local vo = curNpc.vo
			if vo and vo.eid then
				if not TableIsEmpty(TaskModel:GetInstance():GetTaskListBySubmitNPC(vo.eid)) then
					curNpc:SetHeadStateUI(2) --如果该npc有交付任务，则显示感叹号
				else
					curNpc:SetHeadStateUI(0) --不显示任何状态
				end
			end
		end
	end
end


-- 取得玩家的当前位置信息
function SceneView:GetMainPlayerPos()
	if self.mainPlayer then
		return self.mainPlayer:GetPosition()
	end
	return Vector3.Zero
end

function SceneView:Clear()
	self.preAngle = nil
	self.lockRoleMove = false
	self.isMoveByJoystick = false
	dropSends = {}
	BaseView.CloseAll()
	self.isClearing = true
	if self.playerList then
		for i= #self.playerList,1,-1 do
			self.playerList[i]:Destroy()
			self.playerList[i] = nil
		end
	end
	if self.npcList then
		for i=#self.npcList,1,-1 do
			self.npcList[i]:Destroy()
			self.npcList[i] = nil
		end
	end
	if self.summonThingList then
		for i=#self.summonThingList,1,-1 do
			self.summonThingList[i]:Destroy()
			self.summonThingList[i] = nil
		end
	end
	if self.monList then
		for i=#self.monList,1,-1 do
			self.monList[i]:Destroy()
			self.monList[i] = nil
		end
	end
	if self.effectList then
		for i=#self.effectList,1,-1 do
			self.effectList[i]:Destroy()
			self.effectList[i]=nil
		end
	end
	if self.dropList then
		for i=#self.dropList,1,-1 do
			self.dropList[i]:Destroy()
			self.dropList[i]=nil
		end
	end
	if self.doorList then
		for i=#self.doorList,1, -1 do
			self.doorList[i]:Destroy()
			self.doorList[i]=nil
		end
	end

	if self.flyEffectList then
		for i=#self.flyEffectList,1,-1 do
			self.flyEffectList[i]:Destroy()
			self.flyEffectList[i]=nil
		end
	end

	if self.sourceEffectList then
		for i=#self.sourceEffectList,1,-1 do
			self.sourceEffectList[i]:Destroy()
			self.sourceEffectList[i]=nil
		end
	end

	if self.persistEffectList then
		for i=#self.persistEffectList,1,-1 do
			self.persistEffectList[i]:Destroy()
			self.persistEffectList[i]=nil
		end
	end

	if self.warningList then
		for i = 1, #self.warningList do
			self.warningList[i]:Destroy()
			self.warningList[i]=nil
		end
	end
	EffectMgr.ClearFollowMap()

	self.playerList = {}
	self.npcList = {}
	self.monList = {}
	self.summonThingList = {}
	self.effectList = {}
	self.dropList = {}
	self.doorList = {}
	self.flyEffectList = {}
	self.sourceEffectList = {}
	self.persistEffectList = {}
	self.warningList = {}
	self.skillPreview = nil
	self.mixtureList = {}
	if self.mapNameTips then
		self.mapNameTips:Destroy()
		self.mapNameTips = nil
	end
	PoolMgr.ClearAll()
	self.isClearing = false
end

function SceneView:__delete()
	self.isDestroyed = true
	RenderMgr.Realse("LayoutScene")
	RenderMgr.Realse("SceneRender")
	--UIMgr.DestroyAllPopup()--销毁所有的popup
	
	if self:GetMainPlayer() then
		if self:GetMainPlayer().autoFight  then
			self:GetMainPlayer().autoFight:Stop()
		end
		self.mainPlayer:Destroy()
	end
	self.mainPlayer = nil
	if CommonController:GetInstance().popupRoot then
		CommonController:GetInstance().popupRoot:ClearPopupList()
	end

	if self.pickupItemPanel ~= nil then
		self.pickupItemPanel:Destroy()
		self.pickupItemPanel = nil
	end
	self.isPickuping = false
	self.isOpenPickupUI = false
	self.curPickupObj = nil

	if self.collectItemPanel ~= nil then
		self.collectItemPanel:Destroy()
		self.collectItemPanel = nil
	end
	self.isCollecting = false
	self.isOpenCollectUI = false
	self.curCollectObj = nil

	self.loadFinish = false
	self.isAddSceneObj = false
	-- CoUpdateBeat:Remove(self.Update, self)
	self:Clear()
	UIMgr.DestroyAllPopup()--销毁所有的popup

	self:RemoveEvent()
	self.ctrl = nil
	self.model = nil
	self.npcList = nil
	self.monList = nil
	self.summonThingList = nil
	self.effectList = nil
	self.playerList = nil
	self.dropList = nil
	self.doorList = nil
	self.dahuangta = false
	self.curFocusMon = nil
	self.cameraFocusTemp = nil
	self.cameraCtrl = nil
	self.outDoorCameraCtrl = nil
	self.mixtureList = nil
end
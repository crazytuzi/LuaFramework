RegistModules("Map/SceneConst")

RegistModules("Map/HeadUI/HeadUIMgr")

RegistModules("Map/Vo/PuppetVo")
RegistModules("Map/Vo/MonsterVo")
RegistModules("Map/Vo/DoorVo")
RegistModules("Map/Vo/NpcVo")
RegistModules("Map/Vo/RoleVo")
RegistModules("Map/Vo/PersistEffectVo")
RegistModules("Map/Vo/BuffVo")
RegistModules("Map/Vo/SummonThingVo")

RegistModules("Map/Astar")
RegistModules("Map/Navigation/AgentDriver")

--------------skill---------------------------
RegistModules("Map/Skill/SkillPrompt/SpBase")
RegistModules("Map/Skill/SkillPrompt/SpPointToRangeSectorBase")
RegistModules("Map/Skill/SkillPrompt/SpArrowSmall")
RegistModules("Map/Skill/SkillPrompt/SpArrowBig")
RegistModules("Map/Skill/SkillPrompt/SpGroundAttack")
RegistModules("Map/Skill/SkillPrompt/SpPointToRangeSector60")
RegistModules("Map/Skill/SkillPrompt/SpPointToRangeSector90")
RegistModules("Map/Skill/SkillPrompt/SpPointToRangeSector180")
RegistModules("Map/Skill/SkillPrompt/SpPointToCenterSector90")
RegistModules("Map/Skill/SkillPrompt/SpRangeSector60")
RegistModules("Map/Skill/SkillPrompt/SpRangeSector90")
RegistModules("Map/Skill/SkillPrompt/SpRangeSector180")
RegistModules("Map/Skill/SkillPrompt/SpRangeSector360")
RegistModules("Map/SkillPreview")

RegistModules("Map/Manager/MainPlayerSkillMgr")
RegistModules("Map/Manager/SkillManager")
RegistModules("Map/Skill/Skill")
RegistModules("Property/PropertyConst")

-----------------------------------------
RegistModules("Map/Manager/AutoFightMgr")

RegistModules("Map/Obj/Thing")
RegistModules("Map/Obj/LivingThing")
RegistModules("Map/Obj/Door")
RegistModules("Map/Obj/Npc")
RegistModules("Map/Obj/Monster")
RegistModules("Map/Obj/Player")
RegistModules("Map/Obj/SummonThing")
RegistModules("Map/Obj/FlyEffect")
RegistModules("Map/Obj/SourceEffect")
RegistModules("Map/Obj/PersistEffect")
RegistModules("Map/Obj/WarningEffect")

RegistModules("Map/SceneLoader")
RegistModules("Map/SceneView")
RegistModules("Map/SceneModel")
RegistModules("Map/Vo/FightVo")
RegistModules("Map/Vo/SkillVo")

RegistModules("Map/Buff/Buff")

RegistModules("Map/Manager/FightSoundMgr")
RegistModules("Map/Manager/BattleManager")
-- RegistModules("Map/Manager/TriggerManager")
RegistModules("Map/Manager/AnimatorMgr")
RegistModules("Map/Buff/BuffManager")

---------------DropList-----------------------
RegistModules("Map/Vo/DropItemVo")
RegistModules("Map/ItemDrop/DropItem")

-------------物品采集-------------------------
RegistModules("Map/Vo/CollectVo")
RegistModules("Map/Obj/Collect")

RegistModules("Map/Collect/View/LoadingBackToCityPanel")

RegistModules("Map/Collect/View/LoadingCollectItem")
RegistModules("Map/Collect/View/LoadingBackToCity")

RegistModules("Map/Collect/View/ProgressBarBackToCity")
RegistModules("Map/Collect/View/ProgressBarCollect")

RegistModules("Map/Collect/CollectObject")
RegistModules("Map/Collect/CollectView")
RegistModules("Map/Collect/CollectModel")

RegistModules("Map/Manager/NPCBehaviorMgr")
-------++++++++++++++++++++++++++++++++++++++++++++++
RegistModules("Main/View/ClickChoose")

-------++++++++++++++++++++++++++++++++++++++++++++++

SceneController =BaseClass(LuaController)
function SceneController:__init()
	self.view = nil
	self.model = SceneModel:GetInstance()
	self:InitEvent()
	self:RegistProto()
	self.isLogin = true   --第一次登录
	self.curSceneId = nil -- 当前所在场景id
end

function SceneController:InitEvent()
	self.handler2=GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function ()
		self:LoadFinish()
	end)
	
	--战斗
	self.handler3=GlobalDispatcher:AddEventListener(EventName.PlayerAttack, function (data)
		self:ReqSkillHandler(data)
	end)
	self.handler4=GlobalDispatcher:AddEventListener(EventName.Hit, function (data)
		self:ReqHitHandler(data)
	end)

	-- 元素
	self.handler5=GlobalDispatcher:AddEventListener(EventName.MONSTER_DEAD,function (data)
		self:RemoveMonster(data)
	end)
	self.handler51=GlobalDispatcher:AddEventListener(EventName.SummonThing_DEAD,function (data)
		self:RemoveSummonThing(data)
	end)
	self.handler6=GlobalDispatcher:AddEventListener(EventName.ReqUpdatePosition, function (data)
		self:OnReqUpdatePositionHandler(data)
	end)
	self.handler7=GlobalDispatcher:AddEventListener(EventName.PkModelChange, function (data)
		self:ReqChangePkModelHandler(data)
	end)

	--调息
	self.handler8=GlobalDispatcher:AddEventListener(EventName.ReqPranayama, function (data)
		self:ReqPranayamaHandler(data)
	end)
	self.handler9=GlobalDispatcher:AddEventListener(EventName.ReqUnPranayama, function (data)
		self:ReqUnPranayamaHandler(data)
	end)
	self.handler10=GlobalDispatcher:AddEventListener(EventName.BuffRemove, function (data)
		self:OnBuffRemoveHandler(data)
	end)
	self.handler11 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then
			self.model:Reset()
		end
	end)
end

-- 协议注册
function SceneController:RegistProto()
	self:RegistProtocal("S_AddPlayerPuppets") -- 添加角色列表
	self:RegistProtocal("S_AddWigSkillInfos") -- 添加地效列表
	self:RegistProtocal("S_RemoveWigSkillInfos") -- 移除地效列表
	self:RegistProtocal("S_UpdatePosition") -- 更新最新位置
	self:RegistProtocal("S_GetSceneElementList") -- 获取区域元素列表
	self:RegistProtocal("S_RemovePuppets") -- 移除玩家或怪物列表
	self:RegistProtocal("S_EnterScene") -- 进入场景#
	self:RegistProtocal("S_AddMonsterPuppets") -- 添加怪物列表#
	self:RegistProtocal("S_AddDropItemInfos") -- 添加掉落列表#
	self:RegistProtocal("S_AddBeckonPuppets") -- 添加召唤物列表#
	self:RegistProtocal("S_Pickup") --拾取并保存好物品
	self:RegistProtocal("S_RemoveDropItemInfos") -- 移除掉落列表#
	self:RegistProtocal("S_SynPosition") -- 同步位置状态#
	
	
	-- 战斗
	self:RegistProtocal("S_SynSkill") --角色请求使用技能
	self:RegistProtocal("S_SkillResult") -- 对象受击
	self:RegistProtocal("S_Revive")  ---复活
	-- 更新
	self:RegistProtocal("S_SynPlayerProperty") -- 更新玩家属性（金币钻石类都属于属性）
	--采集相关协议
	self:RegistProtocal("S_StartCollect") -- 开始采集
	self:RegistProtocal("S_EndCollect") -- 结束采集
	self:RegistProtocal("S_AddCollectItemInfos") -- 添加采集物列表#
	self:RegistProtocal("S_RemoveCollectItemInfos") -- 移除采集物列表#

	self:RegistProtocal("S_SynBuff") -- 同步buff

	self:RegistProtocal("S_SynPlayerTitle") -- 同步玩家称谓
	self:RegistProtocal("S_SynMonsterState") --同步Boss存活状态

	self:RegistProtocal("S_TransferNotice") --传送通知
end
-- 响应
	function SceneController:S_TransferNotice(buff)--传送通知
		print("传送通知")
		if self.model:IsOutdoor() or self.model:IsMain() then
			local msg = self:ParseMsg(scene_pb.S_TransferNotice(), buff)
			GlobalDispatcher:Fire(EventName.TRANSFERNOTICE, msg)
		end
	end

	function SceneController:S_SynMonsterState(buff)--同步Boss存活状态
		local msg = self:ParseMsg(scene_pb.S_SynMonsterState(), buff)
		local worldModel = WorldMapModel:GetInstance()
		worldModel.bossState = {}
		SerialiseProtobufList(msg.monsterStates, function ( item ) table.insert(worldModel.bossState, item ) end)
		worldModel:DispatchEvent(WorldMapConst.BossStateChange)
	end

	-- 添加角色列表
	function SceneController:S_AddPlayerPuppets(buff)
		local msg = self:ParseMsg(scene_pb.S_AddPlayerPuppets(),buff)
		SerialiseProtobufList(msg.listPlayerPuppets, function (vo) self:AddPlayer(vo) end) -- 场景玩家列表
	end
	-- 添加怪物列表
	function SceneController:S_AddMonsterPuppets(buff)
		local msg = self:ParseMsg(scene_pb.S_AddMonsterPuppets(),buff)
		SerialiseProtobufList(msg.listMonsterPuppets, function (vo) self:AddMon(vo) end) -- 场景怪物列表
	end
	-- 添加召唤物
	function SceneController:S_AddBeckonPuppets(buff)
		local msg = self:ParseMsg(scene_pb.S_AddBeckonPuppets(),buff)
		SerialiseProtobufList(msg.listBeckonPuppets, function (vo) self:AddSummonThing(vo) end) -- 场景召唤物列表
	end
	-- 添加掉落列表
	function SceneController:S_AddDropItemInfos(buff)
		local msg = self:ParseMsg(scene_pb.S_AddDropItemInfos(),buff)
		SerialiseProtobufList(msg.listDropItemInfos, function (vo) self:AddDrop(vo) end) -- 场景掉落列表
	end
	-- 添加地效列表
	function SceneController:S_AddWigSkillInfos(buff)
		local msg = self:ParseMsg(scene_pb.S_AddWigSkillInfos(),buff)
		SerialiseProtobufList(msg.listWigSkillInfos, function (vo) self:AddWigSkill(vo) end) -- 地效持续技能列表
	end
	-- 移除玩家或怪物列表
	function SceneController:S_RemovePuppets( buff )
		local msg = self:ParseMsg(scene_pb.S_RemovePuppets(),buff)
		SerialiseProtobufList(msg.guids, function (guid)
			if self.model:IsMainPlayer( guid ) then return end
			self.model:RemovePlayer(guid) 
			self.model:RemoveMon({guid, 1})
			self.model:RemoveSummonThing({guid, 1})
		end)
	end
	-- 移除地效列表
	function SceneController:S_RemoveWigSkillInfos(buff)
		local msg = self:ParseMsg(scene_pb.S_RemoveWigSkillInfos(),buff)
		-- msg.wigIds -- 地效唯一编号
	end
	-- 更新最新位置
	function SceneController:S_UpdatePosition(buff)
		local msg = self:ParseMsg(scene_pb.S_UpdatePosition(),buff)
		local vo = {}
		vo.guid = msg.guid
		vo.position = SceneModel.Vector3MsgToLocation(msg.position)
		vo.direction = Vector3.New(0,msg.direction,0)
		local obj = self.model:GetPlayer(msg.guid)
		if obj then
			obj:UpateVo(vo)
			return
		end
		obj = self.model:GetMon(msg.guid)
		if obj then
			obj:UpdateVo(vo)
		end
	end
	-- 同步位置状态
	function SceneController:S_SynPosition(buff)
		local msg = self:ParseMsg(scene_pb.S_SynPosition(),buff)
		local vo = {}
		vo.guid = msg.guid
		vo.state = msg.state
		vo.position = SceneModel.Vector3MsgToLocation(msg.position)
		vo.direction = Vector3.New(0,msg.direction,0)

		local scene = self:GetScene()
		local thing = nil
		if scene then
			thing = scene:GetLivingThing(vo.guid)
		end
		if thing and thing:GetDizzyState() then
			return
		end

		local obj = self.model:GetPlayer(msg.guid)
		if obj then
			if self.model:IsMainPlayer(msg.guid) then return end
			obj:UpateVo(vo)
			return
		end
		obj = self.model:GetMon(msg.guid)
		if obj then
			obj.newPos = vo.position -- 由于怪物放技能要停止移动， so记录最后一个移动目标点，放完技能再次移动
			obj:UpdateVo(vo)
		end
		obj = self.model:GetSummonThing(msg.guid)
		if obj then
			obj:UpdateVo(vo)
		end
	end
	-- 拾取物品成功
	function SceneController:S_Pickup(buff)
		local model = self.model
		local msg = self:ParseMsg(scene_pb.S_Pickup(),buff)
		model:RemoveDrop(msg.dropId)

		local view = self.view
		if view then view:PickupThing() end
	end
	-- 获取区域元素列表
	function SceneController:S_GetSceneElementList(buff)
		local msg = self:ParseMsg(scene_pb.S_GetSceneElementList(),buff)
		SerialiseProtobufList(msg.listPlayerPuppets, function (vo) self:AddPlayer(vo) end) -- 场景玩家列表
		SerialiseProtobufList(msg.listMonsterPuppets, function (vo) self:AddMon(vo) end) -- 场景怪物列表
		SerialiseProtobufList(msg.listDropItemInfos, function (vo) self:AddDrop(vo) end) -- 场景掉落列表
		SerialiseProtobufList(msg.listWigSkillInfos, function (vo) self:AddWigSkill(vo) end) -- 地效持续技能列表
		SerialiseProtobufList(msg.listCollectItemInfos, function (vo) self:AddCollect(vo) end) -- 采集列表
		SerialiseProtobufList(msg.listBeckonPuppets, function (vo) self:AddSummonThing(vo) end) -- 召唤物列表
		-- 本地处理
		local info = self.model:GetSceneCfg(self.model.sceneId)
		-- 添加传送门
		for k,v in pairs(info.transfer) do
			local cfg = DoorVo.GetCfg( v.id )
			if cfg and cfg.type == 1 then
				local vo = {}
				vo.position = Vector3.New(v.location[1],v.location[2],v.location[3])
				vo.direction = Vector3.New(v.rotation[1],v.rotation[2],v.rotation[3])
				vo.eid = v.id
				vo.guid = v.id
				vo.toScene = v.toScene or -1
				vo.name = cfg.name
				vo.toLocation = v.toLocation or {0, 0, 0}
				self.model:AddDoor(vo)
			end
		end
		-- 添加npc
		for k,v in pairs(info.npcs) do
			local vo = NpcVo.GetCfg( v.id )
			if vo then
				vo.eid = v.id
				vo.guid = v.id
				vo.position = Vector3.New(v.location[1],v.location[2],v.location[3])
				vo.direction = Vector3.New(v.rotation[1],v.rotation[2],v.rotation[3])
				self.model:AddNpc(vo)
			end
		end
	end
	-- 进入场景(主角会先给过来)
	function SceneController:S_EnterScene(buff)
		local msg = self:ParseMsg(scene_pb.S_EnterScene(),buff)
		local v = SceneModel.PlayerPuppetMsgToPlayerVo(msg.playerPuppet) -- 主角
		local character = LoginModel:GetInstance():GetLoginRole() -- 玩家登录信息
		local vo = RoleVo.New()
		vo:UpateVo( character )
		vo:InitVo(v, true)
		self.model:Clear()
		self.model:AddMainRole(vo)
		if vo.teamId == 0 and ZDModel then
			ZDModel:GetInstance():ClearMine() -- 重置队伍信息
		end

		self.sceneSpawnPos = vo.position
		self.model.endSceneTime = msg.endTime
		LoginModel:GetInstance():SetRoleSelectPanelOpenFlag(false)
		if not self.isLogin then
			self:ChangeScene(msg.mapId)
		else
			GlobalDispatcher:DispatchEvent(EventName.FIRST_ENTER_SCENE, msg.mapId)
			self:FirstEnter( msg.mapId )
			self.isLogin = false
		end
		self.model.headerId = msg.headerId --守城都护玩家编号（主城展示npc用）
		self.model.isHasReqShixiang = false -- 是否已经请求了石像
	end
	-- 请求石像数据
	function SceneController:ReqShixiang()
		local model = self.model
		if model:IsMain() and model.headerId ~= 0 and not model.isHasReqShixiang then
			PlayerInfoController:GetInstance():ReqCheckOtherPlayerInfo(model.headerId)
		end
	end
	--复活通用接口
	function SceneController:S_Revive(buff)
		local msg = self:ParseMsg(battle_pb.S_Revive(),buff)
		if msg then
			local vo = {}
			vo.guid  = msg.guid 
			vo.hp = msg.hp
			vo.hpMax = msg.hpMax
			vo.mp = msg.mp
			vo.mpMax = msg.mpMax
			vo.relifeType = msg.type
			vo.position = SceneModel.Vector3MsgToLocation(msg.revivePosition)
			vo.state = 3 --走击飞击退，直接设置位置
			self.model:UpdatePlayer(vo) 
		end
	end
	-- 更新怪物玩家属性
	function SceneController:S_SynPlayerProperty(buff )
	 	local msg = self:ParseMsg(player_pb.S_SynPlayerProperty(),buff)
		local vo = {}
		vo.guid =  msg.guid
		if self.model:GetPlayer(msg.guid ) then
			SerialiseProtobufList(msg.playerPropertyMsg, function (item)
					local cfg = RoleVo.GetPropDefine(item.propertyId)
					if cfg then
						local propType = StringFormat("{0}",cfg.type)
						vo[propType] = item.propertyValue
						GlobalDispatcher:DispatchEvent(EventName.SyncPlayerAttr, item)
					end
				end)
			self.model:UpdatePlayer(vo) 
		end
		if self.model:GetMon(msg.guid) then
			SerialiseProtobufList(msg.playerPropertyMsg, function (item)
				local cfg = RoleVo.GetPropDefine(item.propertyId)
				if cfg then
					local propType = StringFormat("{0}",cfg.type)
					vo[propType] = item.propertyValue
				end
			end)
			self.model:UpdateMon(vo)
		end
		if self.model:GetSummonThing(msg.guid) then
			SerialiseProtobufList(msg.playerPropertyMsg, function (item)
				local cfg = RoleVo.GetPropDefine(item.propertyId)
				if cfg then
					local propType = StringFormat("{0}",cfg.type)
					vo[propType] = item.propertyValue
				end
			end)
			self.model:UpdateSummon(vo)
		end
	 end 

	-- 更新玩家称谓
	function SceneController:S_SynPlayerTitle( buff )
		self.model:SetTitle(self:ParseMsg(player_pb.S_SynPlayerTitle(), buff))
	end

	-- 技能广播
	function SceneController:S_SynSkill(buff)
		local msg = self:ParseMsg(battle_pb.S_SynSkill(),buff)
		local scene = self:GetScene()
		if scene == nil then return end
		local fighter = scene:GetLivingThing(msg.guid)
		local target = scene:GetLivingThing(msg.targetId)
		if fighter then
			if fighter.head then -- 显示血条
				fighter.head.showState = true
			end
			local vo = {}
			vo.msg = msg
			vo.fighter = fighter
			vo.target = target
			vo.fightType = msg.skillId
			vo.fightDirection = msg.direction*0.01
			vo.targetPoint = SceneModel.Vector3MsgToLocation(msg.targetPoint)
			if fighter and not ToLuaIsNull(fighter.transform) and fighter:IsMonster() and target and not ToLuaIsNull(target.transform) then --客户端计算怪物攻击转向
				if target.head then -- 显示血条
					target.head.showState = true
				end
				local fightRot = MapUtil.GetRotation(fighter.transform.position, target.transform.position)
				vo.fightDirection = fightRot and fightRot.eulerAngles.y or 0
			end
			fighter:ToFight(vo) 
		end 
	end

	function SceneController:GetKillPlayerData(fighter)
		local fighterName = nil
		local isPlayerKill = false
		if fighter then
			if fighter:IsHuman() then
				fighterName = fighter.name
				isPlayerKill = true
			elseif (fighter:IsSummonThing() and fighter:GetOwnerPlayer() and fighter:GetOwnerPlayer().name) then
				fighterName = fighter:GetOwnerPlayer().name
				isPlayerKill = true
			end
		end
		return { fighterName, isPlayerKill }
	end

	-- 受击广播
	function SceneController:S_SkillResult(buff)
		local msg = self:ParseMsg(battle_pb.S_SkillResult(),buff)
		local scene = self:GetScene()
		if scene == nil then return end
		local fighter = scene:GetLivingThing(msg.guid)
		local PersistEffectObj = scene:GetPersistEffect(msg.wigId)
		local accountModelId = msg.accountModelId
		local accountModel = SkillManager.GetModelVoById(accountModelId)
		local skillvo = SkillManager.GetStaticSkillVo(msg.skillId)
		local mainPlayer = scene:GetMainPlayer()
		local teamModel = ZDModel:GetInstance()
		local targets = {}
		if fighter and fighter.head then -- 显示血条
			fighter.head.showState = true
		end
		local isMainPlayerAttack = false
		if fighter and mainPlayer and mainPlayer.guid == fighter.guid then
			isMainPlayerAttack = true
		end
		
		self:BuffMsgHandler(msg.buffList)
		
		local multyHitFunc = function()
			if isMainPlayerAttack and skillvo and skillvo.eSkillTargetCate == 4 then
				fighter:MultyHitPlay()
			end
		end
		
		local killPlayerData = self:GetKillPlayerData(fighter)
		if PersistEffectObj then
			SerialiseProtobufList(msg.skillEffect, function(item)
				local target = scene:GetLivingThing(item.targetId)
				if target then
					target.hatredTarget = fighter --仇恨目标  暂时这样写
					if (item.fightResult == 0 and item.dmg ~= 0 ) or item.fightResult == 1 or item.fightResult == 2 then
						local changeData = {}
						changeData.target = target
						changeData.dmg = item.dmg * -1
						changeData.pos = target:GetPosition()
						changeData.isCrit = item.fightResult == 2
						changeData.isMiss = item.fightResult == 1
						changeData.source = fighter
						multyHitFunc()
						DelayCall(function() 
							local player = mainPlayer
							if fighter and fighter.vo and scene and player and teamModel then
								local fighterPlayer = fighter:GetOwnerPlayer()
								local targetPlayer = target:GetOwnerPlayer()
								local fvo, tvo
								if fighterPlayer then fvo = fighterPlayer.vo end
								if targetPlayer then tvo = targetPlayer.vo end
								if target:IsHuman() and target.vo then
									if fighter.guid == player.guid or teamModel:IsTeamMate(fighter.vo.playerId) or 
									   target.guid == player.guid or (target.vo and teamModel:IsTeamMate(target.vo.playerId)) or 
									   (fighter:IsSummonThing() and fighterPlayer and (fighterPlayer.guid == player.guid or (fvo and teamModel:IsTeamMate(fvo.playerId)))) then
										GlobalDispatcher:DispatchEvent(EventName.BATTLE_PLAYER_HP_CHAGNGE, changeData)
									end
								elseif target:IsSummonThing() then
									if fighter.guid == player.guid or teamModel:IsTeamMate(fighter.vo.playerId) or 
									   (targetPlayer and (targetPlayer.guid == player.guid or (tvo and teamModel:IsTeamMate(tvo.playerId)))) then
										GlobalDispatcher:DispatchEvent(EventName.BATTLE_MONSTOR_HP_CHAGNGE, changeData)
									end
								elseif target:IsMonster() then
									if target.head then -- 显示血条
										target.head.showState = true
									end
									if item.dmg < 0 or
									(fighter:IsHuman() and fighter.guid == player.guid or teamModel:IsTeamMate(fighter.vo.playerId)) or 
									(fighter:IsSummonThing() and fighterPlayer and (fighterPlayer.guid == player.guid or (tvo and fvo and teamModel:IsTeamMate(fvo.playerId))) ) then
										GlobalDispatcher:DispatchEvent(EventName.BATTLE_MONSTOR_HP_CHAGNGE, changeData)
									end
								end
							end

							if target.vo then
								local oldHp = target.vo.hp
								if oldHp > 0 then
									local newHp = oldHp - item.dmg 
									newHp = math.min(target.vo.hpMax, newHp)
									target.vo:SetValue("hp", newHp, oldHp, killPlayerData)
								end
							end

						end, accountModel.n32WordDelay *0.001)
					end
					target:ToHit(fighter, msg.skillId, accountModel, item.dmg)
				end
			end)
		elseif fighter then
			--如果攻击者是自己 受击者也是自己 就返回 因为是给自己加buff
			if self.model:IsMainPlayer(msg.guid ) and self.model:IsMainPlayer(msg.targetId ) then return end
			SerialiseProtobufList(msg.skillEffect, function(item)
				local target = scene:GetLivingThing(item.targetId)
				if target then
					if isMainPlayerAttack and skillvo.eSkillTargetCate == 4 then
						table.insert(targets, target)	
					end
					--仇恨目标  暂时这样写
					target.hatredTarget = fighter
					if fighter.head then -- 显示血条
						fighter.head.showState = true
					end
					if (item.fightResult == 0 and item.dmg ~= 0 ) or item.fightResult == 1 or item.fightResult == 2 then
						local changeData = {}
						changeData.target = target
						changeData.dmg = item.dmg * -1
						changeData.pos = target:GetPosition()
						changeData.isCrit = item.fightResult == 2
						changeData.isMiss = item.fightResult == 1
						changeData.source = fighter
						multyHitFunc()
						DelayCall(function() 
							local player = mainPlayer
							if fighter and fighter.vo and scene and player and teamModel then
								local fighterPlayer = fighter:GetOwnerPlayer()
								local targetPlayer = target:GetOwnerPlayer()
								local fvo, tvo
								if fighterPlayer then fvo = fighterPlayer.vo end
								if targetPlayer then tvo = targetPlayer.vo end
								if target:IsHuman() and target.vo then
									if fighter.guid == player.guid or teamModel:IsTeamMate(fighter.vo.playerId) or 
									   target.guid == player.guid or teamModel:IsTeamMate(target.vo.playerId) or 
									   (fighter:IsSummonThing() and fighterPlayer and fvo and (fighterPlayer.guid == player.guid or teamModel:IsTeamMate(fvo.playerId))) then
										GlobalDispatcher:DispatchEvent(EventName.BATTLE_PLAYER_HP_CHAGNGE, changeData)
									end
								elseif target:IsSummonThing() then
									if fighter.guid == player.guid or teamModel:IsTeamMate(fighter.vo.playerId) or 
									   --攻击者视角
									   (fighter:IsSummonThing() and fighterPlayer and fvo and (fighterPlayer.guid == player.guid or teamModel:IsTeamMate(fvo.playerId))) or
									   --受击者视角
									   (targetPlayer and tvo and (targetPlayer.guid == player.guid or teamModel:IsTeamMate(tvo.playerId))) then
										GlobalDispatcher:DispatchEvent(EventName.BATTLE_MONSTOR_HP_CHAGNGE, changeData)
									end
								elseif target:IsMonster() then
									if target.head then -- 显示血条
										target.head.showState = true
									end
									if item.dmg < 0 or
									(fighter:IsHuman() and fighter.guid == player.guid or teamModel:IsTeamMate(fighter.vo.playerId)) or 
									(fighter:IsSummonThing() and fighterPlayer and fvo and (fighterPlayer.guid == player.guid or teamModel:IsTeamMate(fvo.playerId)) ) then
										GlobalDispatcher:DispatchEvent(EventName.BATTLE_MONSTOR_HP_CHAGNGE, changeData)
									end
								end
							end

							if target.vo then
								local oldHp = target.vo.hp
								if oldHp > 0 then
									local newHp = item.hp
									target.vo:SetValue("hp", newHp, oldHp, killPlayerData)
								end
							end
						end, (accountModel.n32WordDelay or 0) * 0.001)
					end
					target:ToHit(fighter, msg.skillId, accountModel, item.dmg)
				end
			end)
		end

		if isMainPlayerAttack then
			local msg = {}
			msg.targets = targets
			msg.fighter = fighter
			GlobalDispatcher:DispatchEvent(EventName.SummonAttack, msg)
		end
	end

	function SceneController:S_StartCollect(buff)
		local msg = self:ParseMsg(collect_pb.S_StartCollect(),buff)
		if msg.state == 0 then
			GlobalDispatcher:DispatchEvent(EventName.StartCollect, msg.playerCollectId)
		else
			local tipsContent = GetCfgData("game_exception"):Get(msg.state)
			if not TableIsEmpty(tipsContent) and tipsContent.exceptionMsg then
				UIMgr.Win_FloatTip(tipsContent.exceptionMsg)
			end
			if self.view then
				self.view:SetCollectState(false)
			end
		end
	end
	function SceneController:S_EndCollect(buff)
		local msg = self:ParseMsg(collect_pb.S_EndCollect(),buff)
		if msg.playerCollectId ~= 0 then
			--UIMgr.Win_FloatTip("采集成功")
			self.model:EndCollectById(msg.playerCollectId)
			GlobalDispatcher:DispatchEvent(EventName.EndCollect, true)
		end
	end

	function SceneController:S_AddCollectItemInfos(buff)
		local msg = self:ParseMsg(scene_pb.S_AddCollectItemInfos(),buff)
		SerialiseProtobufList(msg.listCollectItemInfos, function (vo) self:AddCollect(vo) end) -- 采集列表
	end

	function SceneController:S_RemoveCollectItemInfos(buff)
		local msg = self:ParseMsg(scene_pb.S_RemoveCollectItemInfos(),buff)
		self.model:RemoveCollectList(msg.playerCollectIds)
	end

	-- 移除掉落物品(超时)
	function SceneController:S_RemoveDropItemInfos(buff)
		local msg = self:ParseMsg(scene_pb.S_RemoveDropItemInfos(),buff)
		SerialiseProtobufList(msg.dropIds, function (eid)
			self.model:RemoveDrop(eid)
		end )
	end

	function SceneController:S_SynBuff(buff)
		local msg = self:ParseMsg(buff_pb.S_SynBuff(),buff)
		self:BuffMsgHandler(msg.buffList)
	end

-- 请求
	-- 进入场景
	function SceneController:C_EnterScene(mapId ,transferId)
		local msg = scene_pb.C_EnterScene()
		msg.mapId = mapId
		if transferId ~= nil then
			msg.transferId = transferId
		end
		self:SendMsg("C_EnterScene", msg)
		GlobalDispatcher:DispatchEvent(EventName.REQ_CHANGE_SCENE)
	end
	-- 获取区域元素列表
	function SceneController:C_GetSceneElementList()

		self:SendEmptyMsg(scene_pb, "C_GetSceneElementList")
	end
	-- 检测残留单位（怪物、召唤兽）
	function SceneController:C_CheckPuppets()
		local scene = self:GetScene()
		if scene == nil or scene.isDestroyed or scene.isClearing then return end
		local guids = {}
		if scene.summonThingList then
			for i=#scene.summonThingList,1,-1 do
				local v = scene.summonThingList[i]
				if v and v.vo and v.vo.guid and (not v.vo.die) then
					table.insert(guids, v.vo.guid)
				end
			end
		end
		if scene.monList then
			for i=#scene.monList,1,-1 do
				local v = scene.monList[i]
				if v and v.vo and v.vo.guid and (not v.vo.die)  then
					table.insert(guids, v.vo.guid)
				end
			end
		end

		if #guids == 0 then return end
		local msg = scene_pb.C_CheckPuppets()
		for i=1,#guids do
			msg.guids:append(guids[i])
		end
		self:SendMsg("C_CheckPuppets", msg)
	end
	-- 同步位置状态
	function SceneController:C_SynPosition(guid, state,p,direction)
		local msg = scene_pb.C_SynPosition()
		msg.guid = guid
		msg.state = state
		msg.position.x = Mathf.Round(math.max(p.x, 0.01)*100)
		msg.position.y = Mathf.Round(math.max(p.y, 0.01)*100)
		msg.position.z = Mathf.Round(math.max(p.z, 0.01)*100)
		local y = math.floor(direction.y)
		msg.direction = y
		self:SendMsg("C_SynPosition", msg)
	end
	-- 更新最新位置
	function SceneController:C_UpdatePosition(guid, p, direction)
		local msg = scene_pb.C_UpdatePosition()
		msg.guid = guid
		msg.position.x = Mathf.Round(math.max(p.x, 0.01)*100)
		msg.position.y = Mathf.Round(math.max(p.y, 0.01)*100)
		msg.position.z = Mathf.Round(math.max(p.z, 0.01)*100)
		local y = math.floor(direction.y)
		msg.direction = y
		self:SendMsg("C_UpdatePosition", msg)
	end
	function SceneController:C_Transfer(toMapId ,toPosition) -- 传送
		local msg = scene_pb.C_Transfer()
		msg.toMapId = toMapId
		msg.toPosition.x = toPosition.x
		msg.toPosition.y = toPosition.y
		msg.toPosition.z = toPosition.z
		self:SendMsg("C_Transfer", msg)
	end
	 -- 拾取物品
	function SceneController:C_Pickup(id)
		if id == nil then logWarn(" 拾取物品出错 ") return end
		local msg = scene_pb.C_Pickup()
		msg.dropId = id
		self:SendMsg("C_Pickup", msg)
	end
	-- 后端检测采集物品操作的合法性，如果合法，则会发该回报，否则，则发异常处理回包 开始进行采集
	function SceneController:C_StartCollect(playerCollectId)
		if playerCollectId then
			local pkg = collect_pb.C_StartCollect()
			pkg.playerCollectId = playerCollectId
			self:SendMsg("C_StartCollect", pkg)
		end
	end
	function SceneController:C_EndCollect(playerCollectId)
		if playerCollectId then
			local pkg = collect_pb.C_InterruptCollect()
			pkg.playerCollectId = playerCollectId
			self:SendMsg("C_InterruptCollect", pkg)
		end
	end

    --同步Boss存活状态+++++++++
    function SceneController:C_SynMonsterState()
    	self:SendEmptyMsg(scene_pb, "C_SynMonsterState")
    end

-- 处理
	--处理buff
	function SceneController:BuffMsgHandler(vo)
		--资源的加载是异步的，但协议的处理先后是同步的
		--收到服务端更新buff数据，保存在Model层：
		--1.通过事件通知主角、怪物、召唤兽更新buff数据，进行表现;
		--2.如果事件到了，view层没有初始化好，没有收到事件。直接从model取属于自己的buff数据，进行表现。
		self.model:BuffMsgListToDic(vo)
		GlobalDispatcher:DispatchEvent(EventName.BuffDataUpdate, true)
	end
	-- 添加玩家
	function SceneController:AddPlayer(vo)
		local vo = SceneModel.PlayerPuppetMsgToPlayerVo(vo)
		self.model:AddPlayer(vo)
	end
	-- 添加怪物
	function SceneController:AddMon(vo)
		local vo = SceneModel.MonsterPuppetMsgToMonsterVo(vo)
		self.model:AddMon(vo)
	end
	-- 添加召唤物
	function SceneController:AddSummonThing(vo)
		local vo = SceneModel.MonsterPuppetMsgToSummonThing(vo)
		self.model:AddSummonThing(vo)
	end
	-- 添加掉落
	function SceneController:AddDrop(vo)
		self.model:AddDrop(vo)
	end
	-- 地效持续技能列表
	function SceneController:AddWigSkill(vo)
		local vo = SceneModel.WigSkillInfoMsgToWigSkillVo(vo)
		self.model:AddWigSkill(vo)
	end
	-- 采集列表
	function SceneController:AddCollect(vo)
		local vo = SceneModel.CollectItemInfoMsgToCollectVo(vo)
		self.model:AddCollect(vo)
	end

	-- 完成场景资源加载
	function SceneController:LoadFinish()
		self.curSceneId = self.model.sceneId
		if self.model.mainPlayer then
			if self.sceneSpawnPos then
				self.model.mainPlayer.position = self.sceneSpawnPos
			end
			self.view:AddPlayer(self.model.mainPlayer)
		end

		if LoginController:GetInstance().kickState then
			LoginController:GetInstance():UserExitGame()
		end
	end
	function SceneController:__ReqRoundElement()
		-- DelayCall(function ()
		-- 	if self:GetScene() then
		-- 		if self:GetScene():GetMainPlayer() then
		self:C_GetSceneElementList()
	-- 			else
	-- 				step = step + 1
	-- 				if step < 10 then
	-- 					self:__ReqRoundElement(step)
	-- 				end
	-- 			end
	-- 		end
	-- 	end, 0.1)
	end

	-- 请求调息
	function SceneController:ReqPranayamaHandler(data)
		local msg = buff_pb.C_AutoAddHpMp()
		self:SendMsg("C_AutoAddHpMp", msg)
	end
	-- 请求打断调息
	function SceneController:ReqUnPranayamaHandler(data)
		local msg = buff_pb.C_BreakAddHpMp()
		self:SendMsg("C_BreakAddHpMp", msg)
	end
	-- 请求PK模式切换
	function SceneController:ReqChangePkModelHandler(data)
		local msg = battle_pb.C_ChangePkModel()
		msg.pkModel = data[1]
		self:SendMsg("C_ChangePkModel", msg)
	end
	-- 请求使用技能
	function SceneController:ReqSkillHandler(data)
		local skillVo = SkillModel:GetInstance():GetSkillVo(data.fightType)
		if skillVo then
			local lockCD = skillVo.lockCD
			local scene = self:GetScene()
			if scene and lockCD ~= 0 then
				scene:LockRoleMove()
			end
			RenderMgr.Delay(function ()
				local scene = self:GetScene()
				if scene then
					scene:RealseRoleMove()
				end
			end, lockCD*0.001, "role_skill_lock_cd")
		end

		local msg = battle_pb.C_SynSkill()
		msg.guid = data.guid
		msg.skillId = data.fightType
		msg.type = data.type
		msg.targetId = data.fightTarget
		msg.direction = math.floor(data.fightDirection*100)
		if data.targetPoint then
			msg.targetPoint.x = Mathf.Round(data.targetPoint.x*100) --tonumber(string.format("%.2f", data.targetPoint.x))*100
			msg.targetPoint.y = Mathf.Round(data.targetPoint.y*100) --tonumber(string.format("%.2f", data.targetPoint.y))*100
			msg.targetPoint.z = Mathf.Round(data.targetPoint.z*100) --tonumber(string.format("%.2f", data.targetPoint.z))*100
		end
		--if not self:IsMainPlayerDizzy() then
			self:SendMsg("C_SynSkill", msg)
		--end
	end
	
	-- 受击请求
	function SceneController:ReqHitHandler(data)
		local figther = data.figther
		local msg = battle_pb.C_SkillResult()
		msg.guid = data.guid
		msg.skillId = data.skillId

		for i=1, #data.targetIds do
			msg.targetIds:append(data.targetIds[i])
		end
		msg.accountModelId = data.accountModelId
		msg.wigId = data.wigId or 0
		
		if figther then 
			if ((figther:IsHuman() and self.model:IsMainPlayer(data.guid)) or 
			   (figther:IsSummonThing() and figther.owner and figther.owner.guid == self:GetScene():GetMainPlayer().guid)) then
				--if not self:IsMainPlayerDizzy() then
					self:SendMsg("C_SkillResult", msg)
				--end
			elseif figther:IsMonster() then --怪物攻击，受击同步交给其中一个玩家
				if data.permissionGuid and data.permissionGuid == self.model.mainPlayer.guid then
					self:SendMsg("C_SkillResult", msg)
				end
			end
		end
	end
	-- 更新位置
	function SceneController:OnReqUpdatePositionHandler(data)
		self:C_UpdatePosition(data.guid, data.position, data.direction)
	end
	-- (前端延迟死亡) 移除怪物
	function SceneController:RemoveMonster(data)
		if data then self.model:RemoveMon(data) end
	end
	-- (前端延迟死亡) 移除召唤物
	function SceneController:RemoveSummonThing(data)
		if data then self.model:RemoveSummonThing(data) end
	end
	-- 进入场景(第一次)
	function SceneController:FirstEnter( sceneId )
		resMgr:AddUIAB("Map") --加载Map相关的UI资源包
		if sceneId == nil or self.curSceneId == sceneId then logWarn("你已经在当前场景上") return end
		self:ChangeScene(sceneId)
	end
	-- 切换地图
	function SceneController:ChangeScene( sceneId )
		if not self.model:IsWayFinding() then
			GlobalDispatcher:DispatchEvent(EventName.Player_AutoRunEnd)
		end
		if sceneId == nil or sceneId == 0 then print("切换地图失败!") return end
		self.model:SetSceneId( sceneId )
		
		GlobalDispatcher:DispatchEvent(EventName.UNLOAD_SCENE)
		if CustomJoystick and CustomJoystick.mainJoystick then
			CustomJoystick.mainJoystick:EndDrag()
		end
		if self.view ~= nil then
			self.view:Destroy()
			self.view = nil
		end
		self:CreateSceneView()
	end
	-- 场景视图初始化
	function SceneController:CreateSceneView()
		self.view = SceneView.New()
		-- 限制同在场人数
		if self.model:IsInNewBeeScene() then
			self.view.maxPlayerNum = SceneConst.MaxPlayerOnNewer
		else
			self.view.maxPlayerNum = SceneConst.MaxPlayerOnNormal
		end
		self.model:RegistView(self.view)
		GlobalDispatcher:DispatchEvent(EventName.LOADING_SCENE, sceneId)
		EffectMgr.PlaySound("731008")
	end
	-- 获取场景视图
	function SceneController:GetScene()
		return self.view
	end
	--发消息申请复活
	function SceneController:RequireRevive( reType )
		local msg = battle_pb.C_Revive()
		msg.type = reType  --复活类型
		self:SendMsg("C_Revive",msg)
	end

	--获取 View层的MainPlayer
	function SceneController:GetMainPlayer()
		local scene = self:GetScene()
		if scene then
			return scene:GetMainPlayer()
		end
		return nil
	end

-- 父类中的单例重构
function SceneController:GetInstance()
	if SceneController.inst == nil then
		SceneController.inst = SceneController.New()
	end
	return SceneController.inst
end
function SceneController:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	GlobalDispatcher:RemoveEventListener(self.handler5)
	GlobalDispatcher:RemoveEventListener(self.handler6)
	GlobalDispatcher:RemoveEventListener(self.handler7)
	GlobalDispatcher:RemoveEventListener(self.handler8)
	GlobalDispatcher:RemoveEventListener(self.handler9)
	GlobalDispatcher:RemoveEventListener(self.handler51)
	GlobalDispatcher:RemoveEventListener(self.handler10)
	GlobalDispatcher:RemoveEventListener(self.handler11)
	if self.model then self.model:Destroy() end
	if self.view then self.view:Destroy() end
	self.model = nil
	self.view = nil
	self.isLogin = true
	SceneController.inst = nil
end

function SceneController:OnBuffRemoveHandler(data)
	if self.model then
		self.model:RemoveBuff(data)
	end
end

function SceneController:IsMainPlayerDizzy()
	local scene = self:GetScene()
	if scene then
		local mainPlayer = scene:GetMainPlayer()
		if mainPlayer and mainPlayer:GetDizzyState() then
			return true
		end
	end
	return false
end
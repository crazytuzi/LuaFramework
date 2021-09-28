-- 玩家
Player =BaseClass(LivingThing)

function Player:__init( vo )
	self.type = PuppetVo.Type.PLAYER
	self.canying = nil 				-- 残影
	self.career = 0 				-- 职业
	self.setComplete = false
	self.weapon = nil  				--武器
	
	self.wingEntity = nil  				--翅膀
	self.wingEntityIsInited = true 		--判断翅膀是否完成实例化，因为异步加载
	
	self.isSelfControlMove = false -- 是否自己控制行走
	self.keyDir = Vector3.zero
	self.walkDir = Vector3.zero -- 以方向行走
	self.isLeveUping = false
	self.autoFight = nil
	self.reLifeEftId = 0
	self:SetVo(vo)
	self.camera = Camera.main
	self.cameraTf = self.camera.transform
	
	self.pranayamaChecking = false --是否调息检测中
	self.isPranayamaing = false --是否调息中
	self.MaxPranayamaCheckTime = 5 --最大调息检测时长
	self.curPranayamaCheckLeftTime = 5 --调息检测剩余时长

	self.oldPos = self.vo.position
	self.isMainRole = vo.isMainRole
	self.lastCollider = nil
	if self.isMainRole then
		self.bit = require "bit" -- 位处理
		self.interval = 0.3 --间隔s同步一次
		self.stepCheck = 0 -- 检测是否有僵尸怪
		self.codeMap = {}
		self.keyMap = { KeyCode.W, KeyCode.A, KeyCode.S, KeyCode.D }
		self:RestoreInput()
		self.skillManager = nil
		self.normalSkillIdList = {}
		self.skillIDlist = {}
		self:InitSkillManager()
	end
	self:InitEvent()
end

function Player:UnloadPlayer()
	if self.vo and self.vo.dressStyle then
		UnLoadPlayer(self.vo.dressStyle , false)
	end
end

-- 清除
function Player:__delete()
	self:UnloadPlayer()
	self.lastCollider = nil
	self.canying = nil 				-- 残影
	self.codeMap = nil
	self.keyMap = nil
	self.keyDir = nil
	self.walkDir = nil
	self.oldPos = nil

	EffectMgr.RealseEffect(self.effectId)
	if self.autoFight then 
		self.autoFight:Destroy()
		self.autoFight = nil
	end
	self.normalSkillIdList = nil
	self.skillIDlist = nil
	if self.skillManager then
		self.skillManager:Destroy()
		self.skillManager = nil
	end
	if self.vo then
		self.vo:RemoveEventListener(self.handler)
	end
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	GlobalDispatcher:RemoveEventListener(self.handler5)
	
	if self.weapon then
		if self.weaponStyle then
			UnLoadWeapon(self.weaponStyle , false)
		end
		destroyImmediate(self.weapon)
		self.weapon = nil
	end
	if self.weaponEft then 
		destroyImmediate(self.weaponEft)
		self.weaponEft = nil
	end
	if self.wingEntity then 
		destroyImmediate(self.wingEntity) 
		self.wingEntity = nil
	end
	EffectMgr.RealseEffect(self.reLifeEftId)
	EffectMgr.RealseEffect(self.redEffectId)
	EffectMgr.RealseEffect(self.blueEffectId)
	self.setComplete = false

end

-- 主角技能Manager
function Player:InitSkillManager()
	if self.isMainRole then
		self.normalSkillIdList = SkillModel:GetInstance():GetSkillByType(1)
		self.skillIDlist = SkillModel:GetInstance():GetSkillByType(2)
		self.skillManager = MainPlayerSkillMgr.New()
		self.skillManager:Init(self)
		self.skillManager:Reset()
	end
end

function Player:InitEvent()
	local vo = self.vo
	local onUpdateHandle = function (k, v, old, dataTab)
		if vo then
			if k == "position" then
				if not ToLuaIsNull(self.transform) and vo.die ~= true then
					local targetPos = v
					if vo.state == 3 then  --被击飞或者击退就直接设置位置
						self.transform.position = targetPos
					else
						self:MoveToPositionByAgent(targetPos)
					end
				end
			elseif k == "exp" then
				self:AddLevel( v, vo.level)
				local delta = v - old
				local str = ""
				if not self.sceneModel:IsTower() and self.isMainRole then
					if delta>0 then
						str = StringFormat("[img=32,32]{2}[/img]   [color=#3dc476]{0}[/color] + {1}", GoodsVo.GoodTypeKeyToName[k], delta, "Icon/Goods/"..k)
					end
					Message:GetInstance():TipsMsg(str)
				end
			elseif k == "direction" then
				if not ToLuaIsNull(self.transform) then
					local targetDir = v
					if vo.state == 3 then
						self.transform.rotation = targetDir
					end
				end
			elseif k == "gold" or k == "diamond" or k == "bindDiamond" or k == "stone" then
				local delta = v - old
				local str = ""
				if not self.sceneModel:IsTower() and self.isMainRole then
					if delta>0 then
						str = StringFormat("[img=32,32]{2}[/img]   [color=#3dc476]{0}[/color] + {1}", GoodsVo.GoodTypeKeyToName[k], delta, "Icon/Goods/"..k)
					else
						str = StringFormat("[img=32,32]{2}[/img]   [color=#3dc476]{0}[/color] {1}", GoodsVo.GoodTypeKeyToName[k], delta, "Icon/Goods/"..k)
					end

					if delta<0 and k == "diamond" then
						local total = ConsumModel:GetInstance():GetTotalRecharge()
						total = total + math.abs(delta)
						ConsumModel:GetInstance():SetTotalRecharge(total)
						ConsumModel:GetInstance():DispatchEvent(ConsumConst.RefreshPanel)
					end

					EffectMgr.PlaySound("731009")
					Message:GetInstance():TipsMsg(str)
				end
			elseif k =="weaponStyle" then
				self:TakeOnWeapon()
			elseif k =="level" then
				self:LoadUpLevelEffect("30007", nil)
			elseif k == "moveSpeed" then
				if self.agentDriver then
					self.agentDriver:SetMoveSpeed(v)
				end
			elseif k == "wingStyle" then
				self:SetWing(v)
			elseif k == "dressStyle" then
				self:ChangeDressStyle(v)
			elseif k == "die" then
				if v then
					vo.hp = 0
					vo.die = true
					self:DieShow(dataTab)
					self:ToDie()
				else
					self:ToRelife()
				end
			elseif k == "bagGrid" then
				if self.isMainRole then
					PkgModel:GetInstance():SetBagGrid(v)
				end

			elseif k == "relifeType" then
				self:PlayReLifeEft(v)
			elseif k == "teamId" then
				if self.isMainRole then
					GlobalDispatcher:Fire(EventName.TeamListChange, v)
				end
			elseif k == "pkModel" then
				if self.isMainRole then
					local autoFight = self.sceneCtrl:GetScene():GetAutoFightCtr()
					if autoFight then
						autoFight:ClearTarget()
					end
				end
			end
		end
	end
	self.handler = vo:AddEventListener(SceneConst.OBJ_UPDATE, onUpdateHandle) -- 属性更新变化事件
	if self.isMainRole then 
		self.handler1=GlobalDispatcher:AddEventListener(EventName.Player_MoveToTarget,function ( data ) self:MoveToPos(data) end)
		self.handler2=GlobalDispatcher:AddEventListener(EventName.Player_StopWorldNavigation,function ( data ) self:StopWorldNavigation(data) end)

		self.handler3 = GlobalDispatcher:AddEventListener(EventName.USE_BLUE_MEDICINE, function ( data ) self:PlayBlueMedicineEft(data) end)
		self.handler4 = GlobalDispatcher:AddEventListener(EventName.USE_RED_MEDICINE, function ( data ) self:PlayRedMedicineEft(data) end)
		self.handler5 =  GlobalDispatcher:AddEventListener(EventName.SyncPlayerAttr, function(data)
			self:HandleSyncPlayerAttr(data)
		end)
	end
end

function Player:HandleSyncPlayerAttr(data)
	--maxHp or maxMp change
	if data.propertyId == 1 or data.propertyId == 3 then
		self.pranayamaChecking = true
		self.curPranayamaCheckLeftTime = self.MaxPranayamaCheckTime
	end
end

function Player:PlayRedMedicineEft()
	EffectMgr.RealseEffect(self.redEffectId)
	self.redEffectId = EffectMgr.BindTo("kehongyao", self.gameObject, nil, nil, true, nil, callback)
end

function Player:PlayBlueMedicineEft()
	EffectMgr.RealseEffect(self.blueEffectId)
	self.blueEffectId = EffectMgr.BindTo("kelanyao", self.gameObject, nil, nil, true, nil, callback)
end

--复活类型(1.免费 2.道具复活 3.钻石复活)
function Player:PlayReLifeEft(reLifeType)
	if reLifeType == 2 or reLifeType == 3 then
		self:SetBuff()
		EffectMgr.RealseEffect(self.reLifeEftId)
		local callback = function (id)
			local effect = EffectMgr.GetEffectById(id).transform
			effect.localPosition =Vector3.New(0, 0, 0)
			effect.localScale = Vector3.New(1,1,1)
		end
		self.reLifeEftId = EffectMgr.AddToPos("30015", self.transform.position, nil, nil, true)
	end
end

function Player:LoadUpLevelEffect(res, loadCB)
	if not res then return end
	if self.isLeveUping then return end
	self.isLeveUping = true
	EffectMgr.RealseEffect(self.effectId)
	local mainPlayer = self
	if mainPlayer then
		local callback = function (id)
			local effect = EffectMgr.GetEffectById(id).transform
			effect.localPosition =Vector3.New(0,-0.28,0)
			effect.localScale = Vector3.New(1,1,1)
			if loadCB then loadCB() end
		end
		local destroyCallback = function ()
			self.isLeveUping = false
		end
		self.effectId = EffectMgr.BindTo(res, self.gameObject,1,nil,nil,nil,callback,nil,1,destroyCallback,nil)
	end
	EffectMgr.PlaySound("731007")
	
end

--刷新玩家位置
function Player:MoveToPos( data )
	if data == nil then return end 
	local pos = data[1]
	pos  = Vector3.New(pos[1],pos[2],pos[3])
	local y = pos.y
	local pos1 = Vector3.New(self:GetPosition().x,0,self:GetPosition().z)
	local pos2 = Vector3.New(pos.x,0,pos.z)
	local pos3 = pos2 - pos1
	local dis = pos3.magnitude
	--归一
	dis = dis- 0.5
	local pos4 = pos3.normalized
	local pos5 = Vector3.New(pos4.x*dis,0,pos4.z*dis)
	local pos6 = pos5 + Vector3.New(self:GetPosition().x,0,self:GetPosition().z)
	local pos7 = Vector3.New(pos6.x,y,pos6.z)
	self:MoveToPositionByAgent(pos7)
	--开始寻路了
	GlobalDispatcher:DispatchEvent(EventName.Player_AutoRun)
end

--判断玩家的经验是否是升了好几级
function Player:AddLevel( exp, level)
	local vo = self.vo
	if not vo then return end
	local lv_need_exp = vo:GetPropertyVo( self.career, level ).needexp
	local new_exp = exp - lv_need_exp
	if new_exp >= 0 then
		if vo.level < 100 then
			local cfgAttr = vo:GetPropertyVo( self.career, vo.level)
			local cur_hp = vo.hp or 0 --玩家当前血量
			local cur_max_hp = cfgAttr.hp or 0
			local cur_mp = vo.mp or 0  --玩家当前魔法量
			vo:SetValue("level",level + 1,level) -- 根据等级获取到玩家在配置表中的信息
			local cfg = vo:GetPropertyVo( self.career, vo.level)
			if cur_hp < cur_max_hp then
				vo:SetValue("hp",cfg.hp,cur_hp)
			else
				vo:SetValue("hp",cfg.hp,cfg.hp)
			end
			vo:SetValue("maxhp",cfg.hp,cfg.hp)
			vo:SetValue("mp",cfg.mp,cfg.mp)
			vo:SetValue("maxmp",cfg.mp,cfg.mp)
			vo:SetValue("p_attack",cfg.p_attack,cfg.p_attack)
			vo:SetValue("m_attack",cfg.m_attack,cfg.m_attack)
			vo:SetValue("p_damage",cfg.p_damage,cfg.p_damage)
			vo:SetValue("m_damage",cfg.m_damage,cfg.m_damage)
			vo:SetValue("crt",cfg.crt,cfg.crt)
			vo:SetValue("attackSpeed",cfg.attackSpeed,cfg.attackSpeed)
			vo:SetValue("moveSpeed",cfg.moveSpeed,cfg.moveSpeed)
			self:AddLevel(new_exp,level + 1)
		else
			vo:SetValue("exp",lv_need_exp)
			return
		end
	end
	if new_exp < 0 then
		vo:SetValue("exp",exp)		
	end
	return 
end

function Player:SetVo(vo)
	LivingThing.SetVo(self, vo)
	self.career = vo.career
end
function Player:SetGameObject( gameObject )
	if not self.vo then return end
	LivingThing.SetGameObject(self, gameObject)
	self:TakeOnWeapon()
	local wingStyle = self.vo.wingStyle
	if wingStyle ~= nil and wingStyle ~= 0 then
		self:SetWing(wingStyle)
	end

	if self.isMainRole then
		self.autoFight = AutoFightMgr.New(self)
	end

	if self.isMainRole then
		self:CrossSceneWalk()
	end

	self.setComplete = true
	self:DieShow()
end

function Player:DieShow(dataTab)
	if self.setComplete and self.isMainRole and self.vo then
		if self.vo.die then
			CommonController:GetInstance():DestroyReturnCDBar()
			GlobalDispatcher:DispatchEvent(EventName.MAINROLE_DIE)
			local sceneModel = self.sceneModel
			local mapId = sceneModel.sceneId
			local cfgData = GetCfgData("mapManger"):Get(mapId)
			if cfgData and cfgData.relive ~= 3 then --大荒塔不复活
				DelayCall(function()
					BaseView.CloseAll()
					UIMgr.HidePopup()
					local reLifeBtnPanel = nil
					if (not sceneModel:IsMain()) and (not sceneModel:IsTianti()) then
						if cfgData.relive == 1 then --回城复活
							reLifeBtnPanel = ReLifeBtnPanel.New()
							reLifeBtnPanel:RefreshUI(dataTab)
							UIMgr.ShowCenterPopup(reLifeBtnPanel, function()  end)
						elseif cfgData.relive == 2 then --消耗物品复活
							UIMgr.ShowCenterPopup(ReLifePanel.New(), function()  end)
						elseif cfgData.relive == 5 then -- 城战复活
							WarRelifePane.Show(ClanConst.relifeContent, "自动复活", "复活", nil, 6)
						else
							reLifeBtnPanel = ReLifeBtnPanel.New()
							reLifeBtnPanel:RefreshUI(dataTab)
							UIMgr.ShowCenterPopup(reLifeBtnPanel, function()  end)
						end
					end
				end, 1.2)
			end
		end
	end
end

function Player:StopWorldNavigation()
	self.sceneModel.worldMapId = 0
	self.sceneModel.targetPos = nil
end

--世界地图寻路
--MapId 目标地图，
-- targetPos 到达目标地图上的目标点 isFull 是否全程场景寻路， isOnMap 是否在地图上操作默认不填
function Player:SetWorldNavigation(mapId, targetPos, isFull, isOnMap)
	GlobalDispatcher:DispatchEvent(EventName.Player_AutoRunEnd)
	CommonController:GetInstance():DestroyReturnCDBar()
	if not self:TestTargetScene(mapId, targetPos) then
		local sceneModel = self.sceneModel
		if not WorldMapConst then return end
		local isCrossMainCity = WorldMapConst.GetPath(sceneModel.sceneId, mapId, isFull)
		if isCrossMainCity and not isOnMap and not isFull then 
			self:StopMove()
			sceneModel.worldMapId = mapId
			sceneModel.targetPos = targetPos
			GlobalDispatcher:DispatchEvent(EventName.StopCollect)
			GlobalDispatcher:DispatchEvent(EventName.StartReturnMainCity)
			return
		end
		self:CrossSceneWalk()
	end
end

--寻路到怪物点
function Player:FindToMonsterPos(mapId, refershId)
	local pos = self.sceneModel:GetMonsterRefershPos(mapId, refershId)
	if pos then
		self:SetWorldNavigation(mapId, pos, true)
	else

	end
end

--寻路到NPC
function Player:FindToNPCPos(npcId)
	local mapId, pos = self.sceneModel:GetNPCPos(npcId)
	if mapId and pos then
		self:SetWorldNavigation(mapId, pos, true)
	end
end

function Player:NoticeAutoWalk()
	if self.autoFight and not self.autoFight:IsAutoFighting() then -- 主角非自动战斗状态，才抛自动寻路事件
		GlobalDispatcher:DispatchEvent(EventName.Player_AutoRun)
	end
end
function Player:TestTargetScene(mapId, targetPos)
	local sceneModel = self.sceneModel
	sceneModel.worldMapId = mapId
	sceneModel.targetPos = targetPos
	local curMapId = sceneModel.sceneId
	if curMapId == mapId then 
		if targetPos then
			if MapUtil.IsNearV3DistanceByXZ( targetPos, self:GetPosition(), 1.5) then
				sceneModel.worldMapId = 0
				sceneModel.targetPos = nil
				self:MoveToPositionByAgent(targetPos)
				return true
			end
			self:NoticeAutoWalk()
			self:MoveToPositionByAgent(targetPos)
		else
			self:MoveToPositionByAgent(self:GetPosition())
		end
		sceneModel.worldMapId = 0
		sceneModel.targetPos = nil
		return true
	end
	return false
end
function Player:CrossSceneWalk()
	local sceneModel = self.sceneModel
	local mapId = sceneModel.worldMapId
	local targetPos = sceneModel.targetPos
	local curMapId = sceneModel.sceneId
	if not self:TestTargetScene(mapId, targetPos) then
		if not WorldMapConst then return end
		if not WorldMapConst.AutoWalkPath then return end
		local path = WorldMapConst.AutoWalkPath
		if #path ~= 0 then
			local door = table.remove(path, #path)
			local tranId = door.id
			if not tranId then return end
			local mapCfg = GetLocalData( "Map/SceneCfg/"..curMapId )
			if mapCfg then
				if mapCfg.transfer then 
					if mapCfg.transfer[tranId] then 
						local tranPos = mapCfg.transfer[tranId].location
						if tranPos then 
							local pos = Vector3.New(tranPos[1],tranPos[2],tranPos[3])
							self:NoticeAutoWalk()
							self:MoveToPositionByAgent(pos)
						end
					end
				end
			end
		else
			self:TestTargetScene()
		end
	end
end

--玩家死亡
function Player:ToDie()
	LivingThing.ToDie(self)
	self:StopMove()
	--停止挂机
	GlobalDispatcher:DispatchEvent(EventName.AUTO_FIGHT,false)
	local model = self.sceneModel
	if model and self.vo then 
		local ceng_shu = math.max(1,self.vo.cengShu - 2)
		self.vo.cengShu = ceng_shu
		model:GetMainPlayer().is_reset_hp_or_mp_ = true
	end
end

function Player:ShowCanying( bool ) -- 残影
	if self.canying == nil then
		self.canying = self.gameObject:AddComponent(typeof(CanYing))
		self.canying.interval = 0.1
		self.canying.lifeCycle = 0.3
	end
	self.openCaning = bool
	self.canying.enabled = bool
end

function Player:Update()
	if not self:GetGameObject() then return end

	if self.autoFight and self.autoFight.isReady then 
		self.autoFight:Update()
	end

	local tf = self.transform
	if self.isMainRole then
		self:PranayamaCheck()
		local curPos = tf.position
		local pos = Vector3.New(curPos.x, curPos.y+1, curPos.z)
		local f, f_ray = self:HitDistance(0.5, pos, Vector3.New(0, 0, 1), false) -- 前
		if f and f_ray then
			local collider = f_ray.collider
			if self.lastCollider ~= collider and collider:CompareTag("Trigger") then 
				if not ToLuaIsNull(collider) and not ToLuaIsNull(collider.gameObject:GetComponent("SceneObjTrigger")) then-- print("hit----------------", f_ray.collider.name)
					local yA = collider.gameObject:GetComponent("SceneObjTrigger").cameraYAngle
					self.sceneCtrl:GetScene():SetRot(yA)
				end
				self.lastCollider = collider
			end
		else
			if not ToLuaIsNull(self.lastCollider) then --print("leave----------------", self.lastCollider.name)
				self.lastCollider = nil
			end
		end
	end
	if self.isMainRole and GameConst.Debug then --自己才会走按键处理
		if Input.GetKeyDown (KeyCode.A) and not self.codeMap[KeyCode.A] then
			self:UpdateInput(KeyCode.A, true)
		end
		if Input.GetKeyDown (KeyCode.D) and not self.codeMap[KeyCode.D] then
			self:UpdateInput(KeyCode.D, true)
		end
		if Input.GetKeyDown (KeyCode.W) and not self.codeMap[KeyCode.W] then
			self:UpdateInput(KeyCode.W, true)
		end
		if Input.GetKeyDown (KeyCode.S) and not self.codeMap[KeyCode.S] then
			self:UpdateInput(KeyCode.S, true)
		end
		if Input.GetKeyUp (KeyCode.A) then
			self:UpdateInput(KeyCode.A, false)
		end
		if Input.GetKeyUp (KeyCode.D) then
			self:UpdateInput(KeyCode.D, false)
		end
		if Input.GetKeyUp (KeyCode.W) then
			self:UpdateInput(KeyCode.W, false)
		end
		if Input.GetKeyUp (KeyCode.S) then
			self:UpdateInput(KeyCode.S, false)
		end
	end
	
	LivingThing.Update(self, Time.deltaTime)
end

	function Player:MoveByAngle( angle )
		if not angle then return end
		local y_angle = angle + self.cameraTf.localRotation.eulerAngles.y
		local rot = Quaternion.Euler(0, y_angle, 0)
		local mat = UnityEngine.Matrix4x4.New()
		mat:SetTRS(Vector3.zero, rot, Vector3.one)
		local dir = mat:GetColumn(2).normalized
		if self.isMainRole then -- (主角自已移动)不让服务器通知移动
			self:MoveByDir( dir )
		end
	end

-- 键盘移动
	--清除按键事件
	function Player:RestoreInput()
		for i = 1, #self.keyMap do
			self.codeMap[self.keyMap[i]] = false
		end
	end
	-- 重置键位
	function Player:UpdateInput(key, boo)
		self:ClearFollowTarget()
		self.codeMap[key] = boo
		GlobalDispatcher:DispatchEvent(EventName.Player_StopWorldNavigation)
		GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity) -- 停止回城动作
		GlobalDispatcher:DispatchEvent(EventName.KEYCODE_MOVE)
		local keyState = 0
		for i = 1, #self.keyMap do
			if self.codeMap[ self.keyMap[i]] then
				keyState = self.bit.bor(keyState, self.bit.lshift(1, i))
			end
		end
		if keyState > 0 then
			self.isSelfControlMove = true
			local rot = Quaternion.Euler(0, self:GetDirBy3Dworld(keyState), 0)
			local mat = UnityEngine.Matrix4x4.New()
			mat:SetTRS(Vector3.zero, rot, Vector3.one)
			local dir = mat:GetColumn(2).normalized
			if self.keyDir.x ~= dir.x or self.keyDir.z ~= dir.z then
				self.keyDir = dir

			end
			self:MoveByDir(dir)
		else
			if self.isSelfControlMove then
		  		self.isSelfControlMove = false
		  		self:StopMove()
			end
			self.keyDir = Vector3.zero
		end

	end
	-- 键盘操作的移动方向
	function Player:GetDirBy3Dworld(keyState)
		local moveDir = 0
		if keyState == 2 then
			moveDir = 0
		elseif keyState == 8 then
			moveDir = 180
		elseif keyState == 4 then
			moveDir = 270
		elseif keyState == 16 then
			moveDir = 90
		elseif keyState == 6 then
			moveDir = 315
		elseif keyState == 18 then
			moveDir = 45
		elseif keyState == 12 then
			moveDir = 225
		elseif keyState == 24 then
			moveDir = 135
		end

		moveDir = moveDir + self.cameraTf.localRotation.eulerAngles.y
		return moveDir
	end

	function Player:DoStand(force) -- 站立
		self.walkDir = nil
		self.tempDir = false
		self.walkTarget = nil
		LivingThing.DoStand(self, force)
	end

	function Player:DoRun() -- 跑动
		LivingThing.DoRun(self)
		if self.isMainRole then
			self.interval = self.interval - Time.deltaTime
			if self.interval <= 0 then
				self:DoAsyncPos()
				self.oldPos = self:GetPosition()
				self.interval = 0.08
				if self.stepCheck % 10 == 0 then
					self.stepCheck = 0
					self.sceneCtrl:C_CheckPuppets()
				end
				self.stepCheck = self.stepCheck + 1
			end
			if self.oldPos then
				GlobalDispatcher:DispatchEvent(EventName.MAINROLE_WALKING, self.oldPos)
			end
		end
		GlobalDispatcher:DispatchEvent(EventName.WALKING)
	end

	function Player:DoAsyncPos()
		if self.isMainRole then
			self.sceneCtrl:C_SynPosition(self.guid, 1,self:GetPosition(),self:GetEulerAngles())
		end
	end

	function Player:PlayAction(action, normalizedTime, cb, force)
		if self.canying then
			self.canying.enabled = not(action == "idle" or action == "die") and self.openCaning
		end
		LivingThing.PlayAction(self, action, normalizedTime, cb, force)
		if action == "idle" then
			self.pranayamaChecking = true
			self.curPranayamaCheckLeftTime = self.MaxPranayamaCheckTime
		else
			self.pranayamaChecking = false
			self:UnPranayama()
		end
	end
	
	function Player:AsyncStop()
		if self.isMainRole then
			self:DoAsyncPos()
			GlobalDispatcher:DispatchEvent(EventName.MAINROLE_STOPWALK)
			local tm = TaskModel:GetInstance()
			if tm.isAuto then
				tm:AutoFight()
			end
		end
	end

	--调息检测
	function Player:PranayamaCheck()
		if self.pranayamaChecking then
			self.curPranayamaCheckLeftTime = self.curPranayamaCheckLeftTime - Time.deltaTime
			if self.curPranayamaCheckLeftTime <= 0 then
				self:Pranayama()
			end
		end
	end

	--打断调息
	function Player:UnPranayama()
		if self.isPranayamaing then
			self.isPranayamaing = false
			self.pranayamaChecking = false
			GlobalDispatcher:DispatchEvent(EventName.ReqUnPranayama)
		end
	end

	function Player:CheckNeedPranayama(vo)
		if not vo then return false end
		return vo.hp < vo.hpMax or vo.mp < vo.mpMaxPanel
	end

	--进入调息
	function Player:Pranayama()
		if (not self.isPranayamaing) or self:CheckNeedPranayama(self.vo) then
			self.isPranayamaing = true
			self.pranayamaChecking = false
			if self:CheckNeedPranayama(self.vo) then
				GlobalDispatcher:DispatchEvent(EventName.ReqPranayama)
			end
		end
	end

--穿上装备 
function Player:TakeOnWeapon()
	local weaponRoot = self:GetWeapon01()
	if weaponRoot == nil then return end
	--设置武器位置 --删除掉武器root下的子gameobject--因为需要反射，就直接指定删除
	local we = self.weapon
	if we then destroyImmediate(we) end
	self.weapon = nil
	local weaponStyle = self:GetWeaponStyle()

	if not pcall(function ()
		if not weaponStyle then print("加载武器有问题") return end
		LoadWeapon(weaponStyle, function ( o )
			if o == nil or not self.vo then return end 
			we = GameObject.Instantiate(o)
			if ToLuaIsNull(weaponRoot) then
				destroyImmediate(we)
				return
			end
			local tf = we.transform
			we.name = StringFormat("{0}",weaponStyle)
			self.weapon = we
			tf.parent = weaponRoot
			tf.localPosition = Vector3.zero
			tf.localRotation = Quaternion.identity
			tf.localScale = Vector3.one

			if self:GetWeaponRare() == 4 or self:GetWeaponRare() == 5 then
				self:SetWeaponLight(weaponRoot)
			else
				if self.weaponEft then destroyImmediate(self.weaponEft) end
				self.weaponEft = nil
			end
		end)
	end) then
		print("加载武器有问题"..weaponStyle)
	end
end

--高级武器特效，只有品质为4、5的武器需要加载
function Player:SetWeaponLight(bone)
	local weaponEftId = self:GetWeaponEftId()
	local weEf = self.weaponEft
	if weEf then destroyImmediate(weEf) end
	self.weaponEft = nil
	if weaponEftId and weaponEftId ~= 0 then
		EffectMgr.LoadEffect(weaponEftId, function(eft)
				if ToLuaIsNull(eft) then return end
			 	if ToLuaIsNull(bone) then
			 		destroyImmediate(eft) 
			 		return
			 	end
			 	eft.name = "weaponEft"
			 	local tf = eft.transform
			 	tf.parent = bone
				tf.localPosition = Vector3.zero
				tf.localRotation = Quaternion.identity
				tf.localScale = Vector3.one
			 	self.weaponEft = eft
		end)
	end
end

--穿上翅膀
function Player:SetWing(wingStyle)
	local we = self.wingEntity
	if wingStyle == 0 then --卸下翅膀
		if not ToLuaIsNull(we) then 
			destroyImmediate(we) 
		end
		self.wingEntity = nil
		return
	end
	local wingRoot = self:GetWing()
	if wingRoot == nil then return end
	--设置武器位置 --删除掉武器root下的子gameobject--因为需要反射，就直接指定删除
	if not ToLuaIsNull(we) then 
		destroyImmediate(we) 
	end
	self.wingEntity = nil
	if not self.wingEntityIsInited then return end  --如果上一把武器没实例化完成是不允许加载的
	
	self.wingEntityIsInited = false
	if not pcall(function ()
		self.vo.wingStyle = wingStyle
		LoadWing(wingStyle, function ( o )
			if ToLuaIsNull(o) or ToLuaIsNull(wingRoot) then 
				self.wingEntityIsInited = true
				return 
			end 
			we = GameObject.Instantiate(o)
			if ToLuaIsNull(wingRoot) then
				destroyImmediate(we)
				return
			end
			local tf = we.transform
			we.name = StringFormat("{0}", wingStyle)
			tf.parent = wingRoot
			tf.localPosition = Vector3.zero
			tf.localRotation = Quaternion.identity
			tf.localScale = Vector3.one
			self.wingEntityIsInited = true
			self.wingEntity = we
		end)
	end) then
		print(StringFormat("加载翅膀有问题{0}",wingStyle))
	end
end

function Player:ChangeDressStyle(dressStyle)
	local scene = self.sceneCtrl:GetScene()
	if not scene or scene.isDestroyed then return end
	local vo = self.vo
	if vo and vo.isMainRole then
		scene:StopAutoFight(true)
	end
	
	LoadPlayer(dressStyle, function ( o )
		if ToLuaIsNull(o) then  return end
		if not ToLuaIsNull(self.gameObject) then
			self:UnloadPlayer()
			destroyImmediate(self.gameObject) 
		end
		if vo then
			vo.dressStyle = dressStyle
			local gameObject = GameObject.Instantiate(o , vo.position or Vector3.New( 0 , 0 , 0) , Quaternion.Euler(vo.direction.x or 0 , self.vo.direction.y or 0 , self.vo.direction.z or 0))
			gameObject.layer = LayerMask.NameToLayer("Character")
			if vo.isMainRole then
				gameObject.name = "MainPlayer_".. vo.guid
				self:SetGameObject( gameObject )
				scene:SetMainPlayer(self)
				scene:SetCameraCtrlTarget(self.transform)
			else
				gameObject.name = "P_".. vo.guid.."_"..dressStyle
				self:SetGameObject( gameObject )
			end

			--武器
			-- local weaponStyle = vo.weaponStyle
			-- if weaponStyle == nil or weaponStyle == 0 then 
			-- 	weaponStyle = LoginConst.DefaultWeapon[vo.career]
			-- end
			-- local weaponRoot = self:GetWeapon01()
			-- vo.weaponStyle = weaponStyle
			-- self:TakeOnWeapon(weaponRoot, weaponStyle)

			--翅膀
			local wingStyle = vo.wingStyle
			if wingStyle ~= nil and wingStyle ~= 0 then
				self:SetWing(wingStyle)
			end
		end
		if self.buffManager then
			self.buffManager:Refesh(self)
		end
		if self.isMainRole then
			GlobalDispatcher:DispatchEvent(EventName.ChangeStyleSuccess)
		end

		local go = GameObject.Find("FS_ShadowManager")
		if not ToLuaIsNull(go) then destroyImmediate(go) end
	end)
end

function Player:GetWeaponStyle()
	local cfg = GetCfgData("equipment"):Get(self.vo.weaponStyle)
	if cfg then
		return cfg.weaponStyle
	end

	local roleDefaultVal = GetCfgData("newroleDefaultvalue"):Get(self.vo.career)
	if roleDefaultVal then
		local cfg = GetCfgData("equipment"):Get(roleDefaultVal.weaponStyle)
		if cfg then
			return cfg.weaponStyle
		end	
	end

	return nil
end

function Player:GetWeaponEftId()
	local cfg = GetCfgData("equipment"):Get(self.vo.weaponStyle)
	if cfg then
		return cfg.effect
	end
	return nil
end

function Player:GetWeaponRare()
	local cfg = GetCfgData("equipment"):Get(self.vo.weaponStyle)
	if cfg then
		return cfg.rare
	end
	return nil
end


function Player:IsWayFinding()
	return self.isMainRole and (self.sceneModel.worldMapId ~= nil or self.sceneModel.targetPos ~= nil)
end
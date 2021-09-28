--自动战斗
--逻辑：
--1. 选当前血量占自身总血量比例最小的怪进行攻击
--2. 优先选择非普工的技能进行释放，在非普攻的技能优先选择CD长的进行释放
--3. 如果当前选中了普攻，需要触发三连击（未做）
--4. 普通攻击前两招不进行位置同步

AutoFightMgr =BaseClass()

function AutoFightMgr:__init( player )
	self.isReady = false
	self.curSkillBtn = nil
	self.target = nil
	self.normalSill = nil
	self.specialSkill = nil
	self.player = player
	self.fightDistance = 0
	self.skillType = 0
	
	self.findDistance = 50
	self.cfg = GetCfgData("constant"):Get(30)
	if self.cfg then
		self.findDistance = self.cfg.value
	end
	if SceneModel:GetInstance():IsCopy() then
		self.findDistance = 50
	end
	
	local cfg = GetCfgData("constant"):Get(33)
	self.cfgInternal = 0
	if cfg then
		self.cfgInternal = cfg.value
	end
	self.internal = 0
	self.isInternalCD = false
	self.sysPosInterval = 0

	self.attacked = false
	self.normalAttackLeaveTime = -1
	self.isMovingTotarget = false
	self.skillList = {}

	self.lastAttackTime = 0
	self.lastAttackOffTime = 8
end

function AutoFightMgr:__delete()
	self:Stop(false)
	self.curSkillBtn = nil
	self.target = nil
	self.normalSill = nil
	self.specialSkill = nil
	self.player = nil
	self.skillList = nil
end

function AutoFightMgr:AddEvents()
	self.handler = GlobalDispatcher:AddEventListener(EventName.SkillBtnResetComplete, function( data ) self:SetAutoSkills() end)
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.SkillUseEnd, function( data ) self:EventAttack() end)
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_DIE, function () self:HandleMainRoleDie() end)
	self.handler4 = GlobalDispatcher:AddEventListener(EventName.PkModelChange , function(data) self:HandlePkModelChange(data) end)
end

function AutoFightMgr:RemoveEvents()
	GlobalDispatcher:RemoveEventListener(self.handler)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
end

function AutoFightMgr:Start(showTips)
	CommonController:GetInstance():DestroyReturnCDBar()
	GlobalDispatcher:DispatchEvent(EventName.StopCollect)
	local messageInst = Message:GetInstance()
	if self.player:IsDying() or self.player:IsDie() then
		messageInst:TipsMsg("角色死亡, 挂机失败...")
		return
	end
	if self.isReady then return end
	self:AddEvents()
	self:SetAutoSkills()
	GlobalDispatcher:DispatchEvent(EventName.AutoFightStart)
	GlobalDispatcher:DispatchEvent(EventName.AUTO_HPMP, true)
	self.player:StopMove() --自动挂机停止任务寻路
	if showTips then messageInst:TipsMsg("开始自动挂机...") end
	self.curSkillBtn = nil
	self.isMovingTotarget = false
	self.normalAttackLeaveTime = -1
	self.isInternalCD = false
	self.skillList = {}
	self.lastAttackTime = Time.time
	self:Attack()
end
function AutoFightMgr:Stop(showTips)
	if self.isReady then
		self:RemoveEvents()
		self.isReady = false
		self.target = nil
		self.attacked = false
		self.curSkillBtn = nil
		self.curCd = nil
		GlobalDispatcher:DispatchEvent(EventName.AutoFightEnd)
		if showTips then
			GlobalDispatcher:DispatchEvent(EventName.AUTO_HPMP, false)
			Message:GetInstance():TipsMsg("停止自动挂机...")
		end
	end
end
function AutoFightMgr:Auto(bool)
	if bool then
		self:Start(false)
	else
		self:Stop(false)
	end
end
function AutoFightMgr.SetAuto(bool)
	local scene = SceneController:GetInstance():GetScene()
	if scene and scene:GetAutoFightCtr() then
		scene:GetAutoFightCtr():Auto(bool)
	end
end

function AutoFightMgr:ResetInternal()
	self.internal = 0.3
end

function AutoFightMgr:IsAutoFighting()
	return self.isReady
end

function AutoFightMgr:SetAutoSkills()
	self.isReady = false
	local view = MainUIController:GetInstance().view
	if view then
		local panel = view.mainPanel
		local ui = nil
		if panel then
			ui = panel.fightControllerUI
		end
		if ui and ui.btnSkillView and
		   	ui.btnSkillView.slotSkillList then
			local skillBtns = ui.btnSkillView:GetStudySkillBtn()
			self.normalSill = {}
			self.specialSkill = {}
			if #skillBtns > 0 then
				for k, v in pairs(skillBtns) do
					if v:IsNormalSkill() then
						table.insert(self.normalSill, v)
					else
						table.insert(self.specialSkill, v)
					end
				end
			end
		end
		self.isReady = true
	end
end

function AutoFightMgr:EventAttack()
	self.isInternalCD = true
	self.sysPosInterval = 0
	self:ResetInternal()
end

function AutoFightMgr:Attack() --切换技能
	if self.normalAttackLeaveTime > 0 then
		table.insert(self.skillList, self.normalSill[1])
	else
		table.insert(self.skillList, self:GetReadySkill())
	end
end

function AutoFightMgr:ExcuteAttack()
	if not self.isReady then return end
	if self.curSkillBtn then
		self.curSkillBtn:UseSkill(false, true)
		self.lastAttackTime = Time.time
		if self.curSkillBtn and self.curSkillBtn:IsNormalSkill() then
			if self.normalAttackLeaveTime == -1 then
				self.normalAttackLeaveTime = 2
			else
				self.normalAttackLeaveTime = self.normalAttackLeaveTime - 1
			end
		else
			self.normalAttackLeaveTime = -1
		end
		self.isMovingTotarget = false
		self.curSkillBtn = nil
	end
end

function AutoFightMgr:ClearTarget()
	self.target = nil
end

function AutoFightMgr:Update()
	if not self.isReady then return end

	if self:TargetFilter() then
	  self.target = nil 
	  return 
	end

	if Time.time - self.lastAttackTime > self.lastAttackOffTime then
		self.lastAttackTime = Time.time
		self.curSkillBtn = nil
		self.isMovingTotarget = false
		self.normalAttackLeaveTime = -1
		self.isInternalCD = false
		self.skillList = {}
		self:Attack()
		return
	end
	if self.isInternalCD then
		if self.normalAttackLeaveTime == -1 or self.normalAttackLeaveTime == 0 then
			self.sysPosInterval = self.sysPosInterval - Time.deltaTime
			if self.sysPosInterval <= 0 then
				self.player:AsyncStop() 
				self.sysPosInterval = 0.3
			end

			if self.internal > 0 then
				self.internal = self.internal - Time.deltaTime
				return
			else
				self.isInternalCD = false
				self:Attack()
			end
		else
			self.isInternalCD = false
			self:Attack()
		end
		return
	end

	if self.curSkillBtn == nil and #self.skillList > 0 then
		self.curSkillBtn = table.remove(self.skillList, 1)
		if self.curSkillBtn:Skill() and self.curSkillBtn:Skill():GetSkillVo() then
			self.fightDistance = self.curSkillBtn:Skill():GetSkillVo().fReleaseDist * 0.01
		end
		self.skillType = self.curSkillBtn.type
	end
	if self.target == nil or self.target:IsDie() then
		self.target = BattleManager.FindAttackTarget(self.skillType, self.findDistance, true)
	end

	if self.curSkillBtn ~= nil and self.target ~= nil and not ToLuaIsNull(self.target.transform) then
		if Vector3.Distance(self.target.transform.position, self.player.transform.position) <= self.fightDistance then
			if not self.isMovingTotarget then
				self:ExcuteAttack()
			end
		else
			if not self.player:IsInWakingUpAction() then
				self.isMovingTotarget = true
				self.player.agentDriver:MoveToTarget(self.target, nil, nil, nil, self.fightDistance, function()
					self:ExcuteAttack()
				end)
			end
		end
	end
end

function AutoFightMgr:GetReadySkill()
	local readyList = {}
	for k, v in pairs(self.specialSkill) do
		if not v:IsCDing() and self.player and self.player.vo and self.player.vo.mp >= v:GetMpCost() then
			table.insert(readyList, v)
		end
	end
	if #readyList < 1 then
		return self.normalSill[1]
	end
	local index = Mathf.Random(1, #readyList)
	return readyList[index]
end

function AutoFightMgr:HandleMainRoleDie()
	self:Stop(false)
end


function AutoFightMgr:TargetFilter()
	local rtn = false
	local target = self.target
	local zd = ZDModel:GetInstance()
	if target then
		local owner = target:GetOwnerPlayer()
		if (target:IsHuman() and target.vo and zd:IsTeamMate(target.vo.playerId)) or
				(target:IsSummonThing() and owner and owner.vo and zd:IsTeamMate(owner.vo.playerId)) then
				rtn = true
		end
	end
	return rtn
end

--PK模式 1:和平 2:善恶 3:组队 4:氏族 5:全体 
function AutoFightMgr:HandlePkModelChange(data)
	if self.target and self.target:IsHuman() and #data >= 1 and  data[1] == 1 then
		self:ClearTarget()		
	end
end
Buff =BaseClass()

Buff.Phases = 
{
	Create = 1, --创建
	Doing = 2,  --效果执行中
	Remove = 3, --移除
}

function Buff:__init(holder, manager, buffVo)

	self.holder = holder
	self.manager = manager
	self.vo = buffVo
	self.guid = self.vo.id
	self.cfgData = BuffManager.GetBuffVo(buffVo.buffId)
	self.phases = 0

	self.interval = 0
	self.lastEftTime = 0
	self.liftTime = 0
	self.isForever = false
	self.scaleFactor = 1
	self.destroy = false

	if not self.cfgData then
		logWarn("buff 【"..buffVo.buffId.."】未找到配置数据")
		return
	end

	self.CreateFunc = nil
	self.DoingFunc = nil
	self.RemoveFunc = nil
	self:MappingFunc()

	self.eftIdList = {}

	self.canUpdate = true
	self.phases = 1 --buff流程开始执行
end

function Buff:UpdateVo(buffVo)
	self.vo = buffVo
	local sceneModel = SceneModel:GetInstance()
	local fighter = sceneModel:GetLivingThing(buffVo.attackGuid)
	local teamModel = ZDModel:GetInstance()
	local holder = self.holder
	if buffVo.endTime == 0 then
		self:_Remove()
	else
		self.liftTime =	(buffVo.endTime - TimeTool.GetCurTime()) / 1000
		if buffVo.hpShow ~= 0 and holder.vo and holder.vo.hpMax ~= holder.vo.hp then
			local changeData = {}
			changeData.target = holder
			changeData.dmg = buffVo.hpShow
			changeData.pos = holder:GetPosition()
			changeData.source = holder

			if fighter and holder.vo and holder then
				if holder:IsHuman() then
					if sceneModel:IsMainPlayer(fighter.guid) or 
						teamModel:IsTeamMate(fighter.playerId) or 
						sceneModel:IsMainPlayer(holder.guid) or 
						teamModel:IsTeamMate(holder.vo.playerId) or 
					   (fighter:IsSummonThing() and fighter:GetOwnerPlayer() and (sceneModel:IsMainPlayer(fighter:GetOwnerPlayer().guid) or teamModel:IsTeamMate(fighter:GetOwnerPlayer().playerId))) then
							GlobalDispatcher:DispatchEvent(EventName.BATTLE_PLAYER_HP_CHAGNGE, changeData)
					end
				elseif holder:IsMonster() then
					if changeData.dmg > 0 or 
						(fighter:IsHuman() and sceneModel:IsMainPlayer(fighter.guid) or teamModel:IsTeamMate(fighter.playerId)) or 
						(fighter:IsSummonThing() and fighter:GetOwnerPlayer() and (sceneModel:IsMainPlayer(fighter:GetOwnerPlayer().guid) or teamModel:IsTeamMate(fighter:GetOwnerPlayer().playerId))) then
							GlobalDispatcher:DispatchEvent(EventName.BATTLE_MONSTOR_HP_CHAGNGE, changeData)
					end
				elseif holder:IsSummonThing() then
					if sceneModel:IsMainPlayer(fighter.guid) or 
						teamModel:IsTeamMate(fighter.playerId) or 
						(holder:GetOwnerPlayer() and (sceneModel:IsMainPlayer(holder:GetOwnerPlayer().guid) or (holder:GetOwnerPlayer().vo ~= nil and teamModel:IsTeamMate(holder:GetOwnerPlayer().vo.playerId)))) then
							GlobalDispatcher:DispatchEvent(EventName.BATTLE_MONSTOR_HP_CHAGNGE, changeData)
					end	
				end
				GlobalDispatcher:DispatchEvent(EventName.BuffRemove, {playerGuid = holder.guid, buffGuid = buffVo.id})
			end
		end
	end
end

--buf结构
function Buff:Buff_Struct()
	if self.phases == Buff.Phases.Create then
		self:_Create()
	elseif self.phases == Buff.Phases.Doing then
		self:_Doing()
	elseif self.phases == Buff.Phases.Remove then
		self:_Remove()
	end
end

function Buff:_Create() 
	self.interval = self.cfgData.periodTime / 1000
	self.liftTime =	(self.vo.endTime - TimeTool.GetCurTime()) / 1000
	if self.liftTime  < 0 then
		self.isForever = true
	else
		self.isForever = false
	end
	if self.CreateFunc then
		self.CreateFunc(self)
	end
	self:_EftHandler()
	self.phases = Buff.Phases.Doing
end

function Buff:_Doing() 
	self.liftTime = self.liftTime - Time.deltaTime
	if self.liftTime < 0 and not self.isForever then
		self.phases = Buff.Phases.Remove
	else
		if Time.time - self.lastEftTime > self.interval and self.DoingFunc then
			self.DoingFunc(self)
			self.lastEftTime = Time.time
		end
	end
end

function Buff:_Remove() 
	if self.RemoveFunc then
		self.RemoveFunc(self)
	end
	self.manager:RemoveBuff(self.vo.id)
end

function Buff:MappingFunc()
	local mappingCreate1 = "Create_"..self.cfgData.groupId.."_"..self.cfgData.buffId
	local mappingCreate2 = "Create_"..self.cfgData.groupId.."_X"
	self.CreateFunc = nil
	if self[mappingCreate1] then
		self.CreateFunc = self[mappingCreate1]
	elseif self[mappingCreate2] then
		self.CreateFunc = self[mappingCreate2]
	else
		logWarn("buff 【"..self.vo.buffId.."】未实现对应的创建接口")
	end

	local mappingDoing1 = "Doing_"..self.cfgData.groupId.."_"..self.cfgData.buffId
	local mappingDoing2 = "Doing_"..self.cfgData.groupId.."_X"
	self.DoingFunc = nil
	if self[mappingDoing1] then
		self.DoingFunc = self[mappingDoing1]
	elseif self[mappingDoing2] then
		self.DoingFunc = self[mappingDoing2]
	end

	local mappingRemove1 = "Remove_"..self.cfgData.groupId.."_"..self.cfgData.buffId
	local mappingRemove2 = "Remove_"..self.cfgData.groupId.."_X"
	self.RemoveFunc = nil
	if self[mappingRemove1] then
		self.RemoveFunc = self[mappingRemove1]
	elseif self[mappingRemove2] then
		self.RemoveFunc = self[mappingRemove2]
	end
end

function Buff:Refesh(holder)
	self.holder = holder
	for i = 1, #self.eftIdList do
		local eftObj = EffectMgr.GetEffectById(self.eftIdList[i])
		if eftObj then
			EffectMgr.RealseEffect(self.eftIdList[i])
		end
	end
	self:_EftHandler()
end

--特效处理
function Buff:_EftHandler()
	if #self.cfgData.effectId > 0 then
		local eftIds = EffectMgr.CreateBuffEffect(self.cfgData.effectId[1], self.holder, self.liftTime, self.scaleFactor, function(eid)
			if self.destroy then
				EffectMgr.RealseEffect(eid)
			end
		end)
		for i = 1, #eftIds do
			table.insert(self.eftIdList, eftIds[i])
		end
	end
end

--加速
	function Buff:Create_1_X() end
--减速
	function Buff:Create_2_X() end
--加攻
	function Buff:Create_3_X() end
--减攻
	function Buff:Create_4_X() end
--持续加血
	function Buff:Create_5_X() end
--持续减血
	function Buff:Create_6_X() end
--法伤持续加血
	function Buff:Create_7_X() end
--法伤持续减血
	function Buff:Create_8_X() end
--持续加蓝
	function Buff:Create_9_X() end
--持续减蓝
	function Buff:Create_10_X() end
--变大
	function Buff:Create_11_X() end
--变小
	function Buff:Create_12_X() end
--定身
	function Buff:Create_13_X() end
--眩晕
	function Buff:Create_14_X() end
--隐身
	function Buff:Create_15_X() end
--净化
	function Buff:Create_16_X() end
--驱散
	function Buff:Create_17_X() end
--大荒塔变大1
	function Buff:Create_18_26()
		self.scaleFactor = self.cfgData.effectPro[1][1] * 0.01
		self.holder.transform.localScale = Vector3.New(self.scaleFactor, self.scaleFactor, self.scaleFactor)
	end
--大荒塔变大2
	function Buff:Create_19_27()
		self.scaleFactor = self.cfgData.effectPro[1][1] * 0.01
		self.holder.transform.localScale = Vector3.New(self.scaleFactor, self.scaleFactor, self.scaleFactor)
	end
--大荒塔变大3
	function Buff:Create_20_28()
		self.scaleFactor = self.cfgData.effectPro[1][1] * 0.01
		self.holder.transform.localScale = Vector3.New(self.scaleFactor, self.scaleFactor, self.scaleFactor)
	end
--魔法盾
	-- function Buff:Create_101_X()
	-- end
--夔牛护盾
	function Buff:Create_1001_X()
	end

-- add by wuqi 17/12/07 眩晕buff创建和销毁时调用函数
	function Buff:Create_101_X()
		-- if self.holder then
		-- 	self.holder:UpdateDizzyState(true)
		-- end
	end

	function Buff:Remove_101_X()
		-- if self.holder then
		-- 	self.holder:UpdateDizzyState(false)
		-- end
	end

function Buff:Update()
	if not self.canUpdate then return end
	self:Buff_Struct()
end

function Buff:__delete()
	self.destroy = true
	for i = 1, #self.eftIdList do
		local eftObj = EffectMgr.GetEffectById(self.eftIdList[i])
		if eftObj then
			EffectMgr.RealseEffect(self.eftIdList[i])
		end
	end

	self.eftIdList = nil
	self.canUpdate = false
	self.CreateFunc = nil
	self.DoingFunc = nil
	self.RemoveFunc = nil
end
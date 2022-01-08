--
-- Author: Zippo
-- Date: 2013-12-05 17:34:00
--

local mapLayer  = require("lua.logic.fight.MapLayer")
local fightRoleMgr  = require("lua.logic.fight.FightRoleManager")
local fightRoundMgr  = require("lua.logic.fight.FightRoundManager")

local FightRole = class("FightRole")

local EFFECT_ZORDER = 100
local FIGHT_TEXT_ZORDER = 300
	
function FightRole:ctor(roleInfo)
	self.extAnger = 0 			--策划要求额外怒气
	local nPosIndex = roleInfo.posindex
	local bEnemyRole = false
	if nPosIndex >= 9 then
		bEnemyRole = true
	end
	self.manualActionNum = 0
	local bNpc = false
	if roleInfo.typeid == 2 then
		bNpc = true
	end

	local roleTableData = nil
	self.soundRoleId = roleInfo.roleId
	if bNpc then
		roleTableData = NPCData:objectByID(roleInfo.roleId)
		self.soundRoleId = roleTableData.role_id
	else
		roleTableData = RoleData:objectByID(roleInfo.roleId)
	end

	if roleTableData == nil then
		print("role configure not found : ",roleInfo.typeid,roleInfo.roleId)
	end

	local armatureID = roleTableData.image
	if ModelManager:existResourceFile(1, armatureID) then
		ModelManager:addResourceFromFile(1, armatureID, 1)
	else
		print(resPath.."not find")
		if bEnemyRole then
			armatureID = 10040
		else
			armatureID = 10006
		end
		ModelManager:addResourceFromFile(1, armatureID, 1)
	end
	local armature = ModelManager:createResource(1, armatureID)
	if armature == nil then
		assert(false, "armature"..armatureID.."create error")
		return
	end
	--]--

	self.boundingBox = armature:boundingBox()

	if bEnemyRole then
		GameResourceManager:addEnemy( roleInfo.roleId , armature )
	else
		GameResourceManager:addRole( roleInfo.roleId , armature )
	end

	self.armatureID = armatureID
	self.armature = armature
	self.armature:setPosition(ccp(0,0))

	self.rolePanel = TFPanel:create()
	self.rolePanel:setSize(self.armature:getContentSize())
	self.rolePanel:addChild(self.armature)

	self.originPos = mapLayer.GetPosByIndex(nPosIndex)
	self:setPosition(self.originPos)
	self.animSpeed = FightManager.fightSpeed

	ModelManager:setAnimationFps(armature, FightManager.fightSpeed * GameConfig.FPS)

	self.isAbnormal = false
	-- self:checkAddOn(armature)

	-- self.armatureTime = os.clock()
	-- self.badTime = 0
	-- self.m_nCurFrame = 0
	-- self.isAbnormal = false  -- 是否cd有异常 

	-- -- ModelManager:addListener(armature, "ANIMATION_UPDATE", function(test1,test2,frame)
	-- armature:addMEListener(TFARMATURE_UPDATE, function(test1,test2,frame)
	-- 		-- print("test------------------------------>", test1, test2, frame)
	-- 		local temp = frame - self.m_nCurFrame
	-- 		if self.m_nCurFrame ~= 0 and temp > 0 then
	-- 			local temp_time = os.clock() - self.armatureTime
	-- 			-- temp_time = temp_time * 10
	-- 			-- print("temp_time = ",temp_time)
	-- 			if temp_time > temp*1/(self.animSpeed*GameConfig.ANIM_FPS/2) then
	-- 				self.badTime = self.badTime + 1
	-- 			else
	-- 				self.badTime = 0
	-- 			end
	-- 			if self.badTime >= 3 then
	-- 				self.isAbnormal = true;
	-- 				-- CommonManager:showFightPluginErrorLayer()
	-- 				-- TFDirector:pause()
	-- 				-- toastMessage("使用非法外挂")
	-- 				-- AlertManager:changeSceneForce(SceneType.LOGIN)
	-- 			end
	-- 		end
	-- 		self.m_nCurFrame = frame
	-- 		self.armatureTime = os.clock()
	-- 	end)

	if bEnemyRole then
		armature:setRotationY(180)
	end

	self.logicInfo = roleInfo
	self.logicInfo.bEnemyRole = bEnemyRole
	self.currHp = roleInfo.maxhp
	self.logicInfo.maxhp = self.logicInfo.attr[1]

	self.immuneAttribute = {}
	if self.logicInfo.immune ~= nil then
		self.immuneAttribute = GetAttrByString(self.logicInfo.immune)
		print("self.logicInfo.immune",self.logicInfo.immune)
	end
	self.effectExtraAttribute = {}
	if self.logicInfo.effectActive ~= nil then
		self.effectExtraAttribute = GetAttrByString(self.logicInfo.effectActive)
		print("self.logicInfo.effectActive",self.logicInfo.effectActive)
	end
	self.beEffectExtraAttribute = {}
	if self.logicInfo.effectPassive ~= nil then
		self.beEffectExtraAttribute = GetAttrByString(self.logicInfo.effectPassive)
		print("self.logicInfo.effectPassive",self.logicInfo.effectPassive)
	end

	self.headPath = "icon/head/"..roleTableData.image..".png"
	self.skillID = roleInfo.spellId
	self.skillCD = 0
	self.passiveSkill = roleInfo.passiveskill or {}
	

	self.normalAttackSkillID = roleTableData.normal_attack
	self.haveAttack = false
	self.buffList = TFArray:new()
	self.bodyEffectList = {}
	self.bufferIconList = {}

	if self.logicInfo.name == nil then
		self.logicInfo.name = roleTableData.name
	end
	print(self.logicInfo.name .."属性: ",displayAttributeString(self.logicInfo.attr))

	self.profession = 1
	self.sex = 1
	if bNpc then
		local npcInfo = RoleData:objectByID(roleTableData.role_id)
		if npcInfo ~= nil then
			self.sex = npcInfo.sex
			self.profession = npcInfo.outline
		end
	else
		self.sex = roleTableData.sex
		self.profession = roleTableData.outline
	end
	
	self:UpdateZOrder()
	self:PlayStandAnim()

	self:CreateHpLabel()
	self:CreateShadowImg()
	self:CreateHalo()
	if roleInfo.isboss and roleInfo.isboss == true then
		-- self:AddBossEffect("fight_boss", false)
		self:AddBossEffect("fight_boss2", true)
	end

	self:initExtAnger()
end

function FightRole:checkAddOn(model)
	self.armatureTime = os.clock()
	self.badTime = 0
	self.m_nCurFrame = 0
	self.isAbnormal = false  -- 是否cd有异常

	if model.type == 1 then
		model:addMEListener(TFSKELETON_UPDATE, function(test1,test2,frame)
			local temp = frame - self.m_nCurFrame
			if self.m_nCurFrame ~= 0 and temp > 0 then
				local temp_time = os.clock() - self.armatureTime
				local diff = temp_time * self.animSpeed - temp
				if diff < 0 and temp / (temp_time * self.animSpeed) > 1.5 then
					self.badTime = self.badTime + 1
				else
					self.badTime = 0
				end

				if self.badTime >= 3 then
					self.isAbnormal = true;
					-- CommonManager:showFightPluginErrorLayer()
					-- TFDirector:pause()
					-- toastMessage("使用非法外挂")
					-- AlertManager:changeSceneForce(SceneType.LOGIN)
				end
			end
			self.m_nCurFrame = frame
			self.armatureTime = os.clock()
		end)
	else
		model:addMEListener(TFARMATURE_UPDATE, function(test1,test2,frame)
			local temp = frame - self.m_nCurFrame
			if self.m_nCurFrame ~= 0 and temp > 0 then
				local temp_time = os.clock() - self.armatureTime
				if temp_time > temp*1/(self.animSpeed*GameConfig.ANIM_FPS/2) then
					self.badTime = self.badTime + 1
				else
					self.badTime = 0
				end
				if self.badTime >= 3 then
					self.isAbnormal = true;
					-- CommonManager:showFightPluginErrorLayer()
					-- TFDirector:pause()
					-- toastMessage("使用非法外挂")
					-- AlertManager:changeSceneForce(SceneType.LOGIN)
				end
			end
			self.m_nCurFrame = frame
			self.armatureTime = os.clock()
		end)
	end
end

function FightRole:addManualActionNum()
	self.manualActionNum = self.manualActionNum + 1
end
function FightRole:initExtAnger()
	if FightManager.fightBeginInfo.fighttype == 16 and self.logicInfo.bEnemyRole == false then
		local climbOptionList = NorthClimbManager:getNowFloorOption()
		for i=1,#climbOptionList do
			local battleInfo = BattleLimitedData:objectByID(climbOptionList[i])
			if battleInfo.type == 4 then
				self.extAnger = self.extAnger + battleInfo.value
			end
		end
	end
end
function FightRole:dispose()
	TFDirector:killAllTween(self.rolePanel)
end


function FightRole:setScale(scale)
	self.rolePanel:setScale(scale)
end

function FightRole:CreateShadowImg()
	local shadowImg = TFImage:create("ui_new/fight/shadow.png")
	shadowImg:setZOrder(-1001)
	shadowImg:setAnchorPoint(ccp(0.5, 0.5))
	shadowImg:setScale(2.0)
	self.shadowImg = shadowImg
	self.rolePanel:addChild(shadowImg)
end

function FightRole:CreateHpLabel()
	if FightManager.fightBeginInfo.bSkillShowFight then
		return
	end

	local hpLabel = TFLoadingBar:create()
	if self.logicInfo.bEnemyRole then
		if self.logicInfo.isboss and self.logicInfo.isboss == true then
			hpLabel:setTexture("ui_new/fight/enemybloodboss.png")
		else
			hpLabel:setTexture("ui_new/fight/enemyblood.png")
		end
	else
		hpLabel:setTexture("ui_new/fight/blood.png")
	end
	hpLabel:setPosition(ccp(0, 0))
	hpLabel:setPercent(self.currHp/self.logicInfo.maxhp*100)
	self.hpLabel = hpLabel

	local hpBackground = TFImage:create()
	if self.logicInfo.isboss and self.logicInfo.isboss == true then
		hpBackground:setTexture("ui_new/fight/bloodboss_bg.png")
	else
		hpBackground:setTexture("ui_new/fight/blood_bg.png")
	end
	hpBackground:setZOrder(100)
	hpBackground:addChild(hpLabel)
	self.hpBackground = hpBackground

	hpBackground:setPosition(ccp(0,300))

	local professionImg = TFImage:create("ui_new/fight/zhiye_"..self.profession..".png")
	if professionImg ~= nil then
		professionImg:setPosition(ccp(-55, 7))
		hpBackground:addChild(professionImg)
	end

	hpBackground:setScale(1/self.rolePanel:getScale())
	self.rolePanel:addChild(hpBackground)
end

function FightRole:SetHpBarVisible(bVisible)
	if self.hpBackground ~= nil then
		self.hpBackground:setVisible(bVisible)
	end

	self.shadowImg:setVisible(bVisible)
end

function FightRole:CreateHalo()
	self.haloAttr = {}
	self.haloImmuneAttr = {}
	self.haloEffectExtraAttr = {}
	self.haloBeEffectExtraAttr = {}

	local passiveSkillNum = #self.passiveSkill
	for i=1,passiveSkillNum do
		local skillInfo = SkillLevelData:objectByID(self.passiveSkill[i])
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.passiveSkill[i])
		if skillInfo ~= nil and skillBaseInfo ~= nil then
			if skillBaseInfo.type == 5 or skillBaseInfo.type == 6 then
				self:AddBodyEffect(50, true, true)
				self.haloType = skillBaseInfo.type
				-- local attrAdd = GetAttrByString(skillInfo.attr_add)
				for i=1,17 do
					self.haloAttr[i] = self.haloAttr[i] or 0
					if skillInfo.attr_add[i+17] ~= nil and i <= EnumAttributeType.PoisonResistance then
						self.haloAttr[i+17] = self.haloAttr[i+17] or 0
						self.haloAttr[i+17] =  skillInfo.attr_add[i+17] + self.haloAttr[i+17]
					end

					if skillInfo.attr_add[i] ~= nil then
						self.haloAttr[i] = self.haloAttr[i] + skillInfo.attr_add[i]
					end
				end

				for k,v in pairs(skillInfo.immune) do
					self.haloImmuneAttr[k] = self.haloImmuneAttr[k] or 0
					self.haloImmuneAttr[k] = self.haloImmuneAttr[k] + v
				end
				for k,v in pairs(skillInfo.effect_extra) do
					self.haloEffectExtraAttr[k] = self.haloEffectExtraAttr[k] or 0
					self.haloEffectExtraAttr[k] = self.haloEffectExtraAttr[k] + v
				end
				for k,v in pairs(skillInfo.be_effect_extra) do
					self.haloBeEffectExtraAttr[k] = self.haloBeEffectExtraAttr[k] or 0
					self.haloBeEffectExtraAttr[k] = self.haloBeEffectExtraAttr[k] + v
				end

			end
		end
	end
end

--[[
验证状态是否为异常状态
]]
function FightRole:CalculateBufferTriggerRate(targetRole,levelInfo,baseInfo)
	if levelInfo == nil then
		return
	end
	if not baseInfo then
		baseInfo = SkillBaseData:objectByID( levelInfo.id)
	end
	local bufferInfo = SkillBufferData:objectByID(levelInfo.buff_id)
	local bufRateSuppress = 0
	if bufferInfo and bufferInfo.good_buff == 0 then
		if FightManager.fightBeginInfo.fighttype == 5 then
			bufRateSuppress = ClimbManager:getBufRateSuppress( self.logicInfo.bEnemyRole,targetRole.logicInfo.bEnemyRole )*100
			print("无量山战力压制 buff增加几率 = ",bufRateSuppress)
		elseif FightManager.fightBeginInfo.fighttype == 16 then
			bufRateSuppress = NorthClimbManager:getBufRateSuppress( self.logicInfo.bEnemyRole,targetRole.logicInfo.bEnemyRole )*100
			print("无量山战力压制 buff增加几率 = ",bufRateSuppress)
		end
	end

	if baseInfo.buff_rate_addition and baseInfo.buff_rate_addition ~= "" then
		local addition_list = stringToNumberTable(baseInfo.buff_rate_addition,"_")
		if targetRole:GetBuffByType(addition_list[1]) then
			bufRateSuppress = addition_list[2] + bufRateSuppress
			print("针对特殊buff加成  = ",bufRateSuppress)
		end
	end

	local formula = baseInfo.buff_formula
	if formula == nil or formula == 0 then
		local result = levelInfo.buff_rate + bufRateSuppress
			print(" buff几率 = ",result)
		return result
	else
		--[[
		角色技能：封印技能添加受技能等级影响的命中率计算规则。
		封印技能命中率 = （1-（目标等级- 技能等级）* 0.1） * 基础命中率（表格配置） 
		其中：7≥(目标等级 - 技能等级）≥-20
		命中率：从 30%-100% 之间波动
		]]
		local tmp = (targetRole.logicInfo.level - levelInfo.level)
		tmp = math.min(7,tmp)
		tmp = math.max(-20,tmp)
		local result =(1 -  tmp * 0.1) * levelInfo.buff_rate + bufRateSuppress
			print(" buff几率 = ",result)
		return result
	end
end

--[[
验证状态是否为异常状态
]]
function FightRole:CalculateExtraBufferTriggerRate(targetRole,levelInfo,baseInfo)
	if levelInfo == nil then
		return
	end
	if not baseInfo then
		baseInfo = SkillBaseData:objectByID( levelInfo.id)
	end
	local bufferInfo = SkillBufferData:objectByID(levelInfo.extra_buffid)
	
	local bufRateSuppress = 0
	if bufferInfo and bufferInfo.good_buff == 0 then
		if FightManager.fightBeginInfo.fighttype == 5 then
			bufRateSuppress = ClimbManager:getBufRateSuppress( self.logicInfo.bEnemyRole,targetRole.logicInfo.bEnemyRole )*100
			print("无量山战力压制 buff增加几率 = ",bufRateSuppress)
		elseif FightManager.fightBeginInfo.fighttype == 16 then
			bufRateSuppress = NorthClimbManager:getBufRateSuppress( self.logicInfo.bEnemyRole,targetRole.logicInfo.bEnemyRole )*100
			print("无量山战力压制 buff增加几率 = ",bufRateSuppress)
		end
	end

	-- if baseInfo.buff_rate_addition and baseInfo.buff_rate_addition ~= "" then
	-- 	local addition_list = stringToNumberTable(baseInfo.buff_rate_addition,"_")
	-- 	if targetRole:GetBuffByType(addition_list[1]) then
	-- 		bufRateSuppress = addition_list[2] + bufRateSuppress
	-- 		print("针对特殊buff加成  = ",bufRateSuppress)
	-- 	end
	-- end

	local formula = baseInfo.extra_buff_formula
	if formula == nil or formula == 0 then
		local result = levelInfo.extra_buff_rate + bufRateSuppress
			print(" buff几率 = ",result)
		return result
	else
		--[[
		角色技能：封印技能添加受技能等级影响的命中率计算规则。
		封印技能命中率 = （1-（目标等级- 技能等级）* 0.1） * 基础命中率（表格配置） 
		其中：7≥(目标等级 - 技能等级）≥-20
		命中率：从 30%-100% 之间波动
		]]
		local tmp = (targetRole.logicInfo.level - levelInfo.level)
		tmp = math.min(7,tmp)
		tmp = math.max(-20,tmp)
		local result =(1 -  tmp * 0.1) * levelInfo.extra_buff_rate + bufRateSuppress
			print(" buff几率 = ",result)
		return result
	end
end


function FightRole:GetTriggerExtraBufferID(skillID, targetRole)
	if self:GetBuffByType(10) ~= nil then
		return 0,0
	end
	-- if FightManager.fightBeginInfo.bSkillShowFight then
	-- 	return 0 ,0
	-- end
	if skillID.skillId <= 0 then
		return 0,0
	end

	local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(skillID)
	if skillBaseInfo ~= nil and skillBaseInfo.target_sex == 1 then
		if self.sex == targetRole.sex then
			return 0 ,0
		end
	end

	local skillInfo = SkillLevelData:objectByID(skillID)
	local random = math.random(1, 10000)

	local rate = self:CalculateExtraBufferTriggerRate(targetRole,skillInfo,skillBaseInfo)

	-- print("-----------------------触发额外buff ,random = "..random.." rate = "..rate)
	if skillInfo ~= nil and skillInfo.extra_buffid > 0 and random <= rate then
		-- if targetRole.immuneAttribute then
		local bufferInfo = SkillBufferData:objectByID(skillInfo.extra_buffid)
		local immune = targetRole:getEffectExtraAttrNum(EnumFightAttributeType.Immune,bufferInfo.type)
		if immune ~= nil and immune > 0 then
			local _random = math.random(1, 10000)
			if _random <= immune then
				targetRole:ShowEffectName("mianyi")
				return 0 ,0
			end
		end
		-- end
		return skillInfo.extra_buffid , skillInfo.level
	else
		return 0 ,0
	end
end


function FightRole:GetTriggerBufferID(skillID, targetRole)
	if self:GetBuffByType(10) ~= nil then
		return 0,0
	end
	if skillID.skillId > 0 then
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(skillID)
		if skillBaseInfo ~= nil and skillBaseInfo.target_sex == 1 then
			if self.sex == targetRole.sex then
				return 0 ,0
			end
		end

		local skillInfo = SkillLevelData:objectByID(skillID)
		local random = math.random(1, 10000)
		if FightManager.fightBeginInfo.bSkillShowFight then
			random = 0
		end

		local rate = self:CalculateBufferTriggerRate(targetRole,skillInfo,skillBaseInfo)

		if skillInfo ~= nil and skillInfo.buff_id > 0 and random <= rate then
			-- if targetRole.immuneAttribute then
			local bufferInfo = SkillBufferData:objectByID(skillInfo.buff_id)
			local immune = targetRole:getEffectExtraAttrNum(EnumFightAttributeType.Immune,bufferInfo.type)
			if bufferInfo.good_buff == 0 and immune ~= nil and immune > 0 then
				local _random = math.random(1, 10000)
				if _random <= immune then
					targetRole:ShowEffectName("mianyi")
					return 0 ,0
				end
			end
			-- end
			return skillInfo.buff_id , skillInfo.level
		else
			return 0 ,0
		end
	else
		local passiveSkillNum = #self.passiveSkill
		for i=1,passiveSkillNum do
			if self.passiveSkill[i].skillId ~= 0 then
				local bValidTarget = true
				local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.passiveSkill[i])
				print("self.passiveSkill[i] --触发,  == " ,self.passiveSkill[i])
				if skillBaseInfo.hidden_skill == 1 or skillBaseInfo.hidden_skill == 2  then
					bValidTarget = false
				end
				if skillBaseInfo.effect == 23 then
					bValidTarget = false
				end
				if skillBaseInfo ~= nil and skillBaseInfo.target_sex == 1 then
					if self.sex == targetRole.sex then
						bValidTarget = false
					end
				end

				if bValidTarget then
					local skillInfo = SkillLevelData:objectByID(self.passiveSkill[i])
					local random = math.random(1, 10000)
					local rate = self:CalculateBufferTriggerRate(targetRole,skillInfo,skillBaseInfo)
					print("使用技能 "..skillBaseInfo.name.."触发buff  id == "..skillInfo.buff_id)
					print("random ==  "..random.." ,rate == "..rate)
					if skillInfo ~= nil and skillInfo.buff_id > 0 and random <= rate then
						-- if targetRole.immuneAttribute then
						local bufferInfo = SkillBufferData:objectByID(skillInfo.buff_id)
						local immune = targetRole:getEffectExtraAttrNum(EnumFightAttributeType.Immune,bufferInfo.type)
						-- print("targetRole.immuneAttribute[bufferInfo.type] = ",bufferInfo.type,immune)
						if bufferInfo.good_buff == 0 and immune ~= nil and immune > 0 then
							local _random = math.random(1, 10000)
							if _random <= immune then
								targetRole:ShowEffectName("mianyi")
								return 0 ,0
							end
						end
						-- end
						return skillInfo.buff_id ,skillInfo.level
					end
				end
			end
		end
		return 0 ,0
	end
end

--是否触发被动效果：反弹5 反击6 化解7 复活9 免疫12 移魂13
function FightRole:TriggerPassiveEffect(passiveEffect, effectValue)	
	if passiveEffect == 5 then
		local fantanBuff = self:GetBuffByType(19)
		if fantanBuff ~= nil then
			effectValue.value = fantanBuff.config.value
			return true
		end
	end
	if passiveEffect == 6 then
		if self:GetBuffByType(10) ~= nil then
			return false
		end
		if FightManager:GetCurrAction() ~= nil and FightManager:GetCurrAction().actionInfo.bBackAttack then
			return false
		end
	end

	if passiveEffect == 9 then
	end
	local passiveSkillNum = #self.passiveSkill
	for i=1,passiveSkillNum do
		local skillInfo = SkillLevelData:objectByID(self.passiveSkill[i])
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.passiveSkill[i])
		if skillInfo ~= nil and skillBaseInfo ~= nil and skillBaseInfo.type == 7 and skillBaseInfo.effect == passiveEffect then
			local random = math.random(1, 10000)
			if random <= skillInfo.effect_rate then
				if effectValue ~= nil then
					effectValue.value = skillInfo.effect_value
				end

				local bTrigger = true
				if skillInfo.trigger_hp > 0 and self.currHp/self.logicInfo.maxhp > skillInfo.trigger_hp/100 then
					bTrigger = false
				else
					if passiveEffect == 13 then
						effectValue.value = skillInfo.attr_add
					end
				end

				if bTrigger then
					print(self.logicInfo.name.."TriggerPassiveEffect:"..passiveEffect)
					return true
				end
			end
		end
	end

	return false
end



--是否触发被动效果：闪避1，被击打2
function FightRole:TriggerBeHurtUseSkill(hurtType, effectValue)	
	print("------------TriggerBeHurtUseSkill------")
	if FightManager:GetCurrAction() ~= nil and FightManager:GetCurrAction().actionInfo.bBackAttack then
		return false
	end

	local passiveSkillNum = #self.passiveSkill
	for i=1,passiveSkillNum do
		local skillInfo = SkillLevelData:objectByID(self.passiveSkill[i])
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.passiveSkill[i])
		if skillInfo ~= nil and skillBaseInfo ~= nil and skillBaseInfo.type == 7 and skillBaseInfo.trigger_hurtType == hurtType then
			local random = math.random(1, 10000)
			if random <= skillInfo.triggerSkill_rate then
				effectValue.skillId = skillInfo.triggerSkill
				effectValue.level = skillInfo.level
				-- effectValue = {skillId = skillInfo.triggerSkill,level = skillInfo.level}
				print("触发 技能 ",effectValue)
				return true
			end
		end
	end

	return false
end

function FightRole:getSkillByEffect( effect )
	local passiveSkillNum = #self.passiveSkill
	for i=1,passiveSkillNum do
		local skillInfo = SkillLevelData:objectByID(self.passiveSkill[i])
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.passiveSkill[i])
		if skillInfo ~= nil and skillBaseInfo ~= nil and skillBaseInfo.type == 7 and skillBaseInfo.effect == effect then
			return self.passiveSkill[i]
		end
	end
	return {skillId = 0,level = 0}
end


--是否触发无概率的主动效果：吸怒1 减敌怒2 增己怒3 吸血4 侧击8 净化10 致死11 重击14
function FightRole:TriggerNoRateActiveEffect(skillID, activeEffect, effectValue)
	if self:GetBuffByType(10) ~= nil then
		return false
	end
	if skillID.skillId > 0 then
		local skillInfo = SkillLevelData:objectByID(skillID)
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(skillID)
		if skillInfo ~= nil and skillBaseInfo ~= nil and skillBaseInfo.effect == activeEffect then
			if effectValue ~= nil then
				effectValue.value = skillInfo.effect_value
			end
			print(self.logicInfo.name.."TriggerActiveEffect:"..activeEffect)
			return true
		end
	end
	return false
end
--是否触发主动效果：吸怒1 减敌怒2 增己怒3 吸血4 侧击8 净化10 致死11 重击14
function FightRole:TriggerActiveEffect(skillID, activeEffect, effectValue)
	if self:GetBuffByType(10) ~= nil then
		return false
	end
	if skillID.skillId > 0 then
		local skillInfo = SkillLevelData:objectByID(skillID)
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(skillID)
		if skillInfo ~= nil and skillBaseInfo ~= nil and skillBaseInfo.effect == activeEffect then
			local random = math.random(1, 10000)
			if random <= skillInfo.effect_rate then
				if effectValue ~= nil then
					effectValue.value = skillInfo.effect_value
				end
				print(self.logicInfo.name.."TriggerActiveEffect:"..activeEffect)
				return true
			else
				return false
			end
		end
	else
		local passiveSkillNum = #self.passiveSkill
		for i=1,passiveSkillNum do
			local skillInfo = SkillLevelData:objectByID(self.passiveSkill[i])
			local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.passiveSkill[i])
			if skillInfo ~= nil and skillBaseInfo ~= nil and skillBaseInfo.type == 7 and skillBaseInfo.hidden_skill ~= 1 and skillBaseInfo.effect == activeEffect then
				local random = math.random(1, 10000)
				print("主动效果 random == "..random.."  ,skillInfo.effect_rate =="..skillInfo.effect_rate )
				if random <= skillInfo.effect_rate then
					if effectValue ~= nil then
						effectValue.value = skillInfo.effect_value
					end
					print(self.logicInfo.name.."TriggerActiveEffect:"..activeEffect)
					return true
				end
			end
		end
	end
	return false
end


--是否触发主动效果：吸怒1 减敌怒2 增己怒3 吸血4 侧击8 净化10 致死11 重击14
function FightRole:SkillTriggerActiveEffect(skillID, activeEffect, effectValue)
	if self:GetBuffByType(10) ~= nil then
		return false
	end
	if skillID.skillId > 0 then
		local skillInfo = SkillLevelData:objectByID(skillID)
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(skillID)
		if skillInfo ~= nil and skillBaseInfo ~= nil and skillBaseInfo.effect == activeEffect then
			local random = math.random(1, 10000)
			if random <= skillInfo.effect_rate then
				if effectValue ~= nil then
					effectValue.value = skillInfo.effect_value
				end
				return true
			else
				return false
			end
		end
	end
	return false
end

--是否对中buff目标伤害加成
function FightRole:TriggerBuffHurt(targetRole, skillID, effectValue)
	if self:GetBuffByType(10) ~= nil then
		return 0
	end
	if skillID.skillId > 0 then
		local skillInfo = SkillLevelData:objectByID(skillID)
		if skillInfo ~= nil and skillInfo.buff_hurt > 0 then
			if targetRole:GetBuffByType(skillInfo.buff_hurt) ~= nil then
				if effectValue ~= nil then
					effectValue.value = skillInfo.effect_value
				end
				return skillInfo.buff_hurt
			else
				return 0
			end
		end
	else
		local passiveSkillNum = #self.passiveSkill
		for i=1,passiveSkillNum do
			local skillInfo = SkillLevelData:objectByID(self.passiveSkill[i])
			if skillInfo ~= nil and skillInfo.effect ~= 6 and skillInfo.buff_hurt > 0 then
				if  targetRole:GetBuffByType(skillInfo.buff_hurt) ~= nil then
					if effectValue ~= nil then
						effectValue.value = skillInfo.effect_value
					end
					return skillInfo.buff_hurt
				else
					return 0
				end
			end
		end
	end
	return 0
end

--是否对中buff目标伤害加成
function FightRole:TriggerBuffHurtBackAttack(targetRole, effectValue)
	if self:GetBuffByType(10) ~= nil then
		return 0
	end
	
	local passiveSkillNum = #self.passiveSkill
	for i=1,passiveSkillNum do
		local skillInfo = SkillLevelData:objectByID(self.passiveSkill[i])
		if skillInfo ~= nil and skillInfo.buff_hurt > 0 then
			if  targetRole:GetBuffByType(skillInfo.buff_hurt) ~= nil then
				if effectValue ~= nil then
					effectValue.value = skillInfo.effect_value
				end
				return skillInfo.buff_hurt
			else
				return 0
			end
		end
	end
	return 0
end

function FightRole:GetAttrNum(attrIndex)
	local attrNum = self.logicInfo.attr[attrIndex]
	if attrNum == nil then
		return 0
	end

	attrNum = attrNum + fightRoleMgr:GetTotalHaloAttrAdd(self.logicInfo.bEnemyRole, attrIndex)
	local attrPercent = 0
	if attrIndex < EnumAttributeType.PoisonResistance then
		attrPercent = fightRoleMgr:GetTotalHaloAttrAdd(self.logicInfo.bEnemyRole, attrIndex+17)
	end
	attrNum = math.max(0, attrNum)

	local percent = attrPercent/100
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buff = self.buffList:objectAt(i)
		if buff.bValid and buff.config.attr_change ~= "0" and buff.config.attr_change ~= "" then
			local valueInfo = GetAttrByString(buff.config.attr_change)

			local fightEffectValue = 0
			if buff.config.good_buff == 1 then
				fightEffectValue = buff.fromTarget:getEffectExtraAttrNum(EnumFightAttributeType.Effect_extra,EnumFightEffectType.FightEffectType_GoodAttr) +
					self:getEffectExtraAttrNum(EnumFightAttributeType.Be_effect_extra,EnumFightEffectType.FightEffectType_GoodAttr)
			else
				fightEffectValue = buff.fromTarget:getEffectExtraAttrNum(EnumFightAttributeType.Effect_extra,EnumFightEffectType.FightEffectType_BadAttr) +
					self:getEffectExtraAttrNum(EnumFightAttributeType.Be_effect_extra,EnumFightEffectType.FightEffectType_BadAttr)
			end
			fightEffectValue = fightEffectValue/10000+1
			fightEffectValue = math.max(0,fightEffectValue)

			if valueInfo[17+attrIndex] ~= nil then
				percent = valueInfo[17+attrIndex] *fightEffectValue + percent
			end

			if valueInfo[attrIndex] ~= nil then
				attrNum = attrNum + valueInfo[attrIndex] *fightEffectValue
			end
		end
	end
	if percent ~= 0 then
		print(self.logicInfo.name.."属性"..AttributeTypeStr[attrIndex].."固定值 ="..attrNum..", 百分比*100为.."..percent)
	end
	attrNum = attrNum + math.floor(attrNum * percent / 100)

	if self.passiveSkillAttrAdd ~= nil then
		local valueInfo = self.passiveSkillAttrAdd--GetAttrByString(self.passiveSkillAttrAdd)
		if valueInfo[17+attrIndex] ~= nil then
			attrNum = attrNum + math.floor(attrNum * valueInfo[17+attrIndex] / 10000)
		end

		if valueInfo[attrIndex] ~= nil then
			attrNum = attrNum + valueInfo[attrIndex]
		end
	end

	attrNum = math.max(0, attrNum)
	return attrNum
end

function FightRole:getEffectExtraAttrNum(AttrType, attrIndex)
	local attrNum = 0
	if AttrType == EnumFightAttributeType.Immune then
		attrNum = self.immuneAttribute[attrIndex] or 0
	elseif AttrType == EnumFightAttributeType.Effect_extra then
		attrNum = self.effectExtraAttribute[attrIndex] or 0
	elseif AttrType == EnumFightAttributeType.Be_effect_extra then
		attrNum = self.beEffectExtraAttribute[attrIndex] or 0
	end
	attrNum = attrNum + fightRoleMgr:GetTotalHaloEffectAttrAdd(AttrType,self.logicInfo.bEnemyRole, attrIndex)

	-- attrNum = math.max(0, attrNum)

	local percent = 0
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buff = self.buffList:objectAt(i)
		if buff.bValid then
			local buff_addEffect = {}
			-- print("buff.config = ",buff.config)
			if AttrType == EnumFightAttributeType.Immune then
				buff_addEffect = buff.config.immune
			elseif AttrType == EnumFightAttributeType.Effect_extra then
				buff_addEffect = buff.config.effect_extra
			elseif AttrType == EnumFightAttributeType.Be_effect_extra then
				buff_addEffect = buff.config.be_effect_extra
			end
			if buff_addEffect[attrIndex] ~= nil then
				attrNum = attrNum + buff_addEffect[attrIndex]
			end
		end
	end
	return attrNum
end

function FightRole:GetSkillAnger()
	local skillInfo = BaseDataManager:GetSkillBaseInfo(self.skillID)
	if skillInfo ~= nil then
		return skillInfo.trigger_anger  + self.extAnger
	else
		return 0
	end 
end

--主动技能类型：1 攻击 2治疗 3净化
function FightRole:GetActiveSkillType()
	local skillInfo = BaseDataManager:GetSkillBaseInfo(self.skillID)
	if skillInfo ~= nil then
		return skillInfo.type
	else
		return 0
	end 
end

--主动技能目标类型：1 单体 2全屏 3横排贯穿 4竖排穿刺
function FightRole:GetActiveSkillTargetType()
	local skillInfo = BaseDataManager:GetSkillBaseInfo(self.skillID)
	if skillInfo ~= nil then
		return skillInfo.target_type
	else
		return 0
	end 
end

function FightRole:CanReleaseManualSkill()
	if self:IsLive() == false or self.skillID.skillId == 0 then
		return false
	end

	if fightRoundMgr:IsRoleHaveManualAction(self) then
		return false
	end

	if self:HaveForbidManualSkillBuff() then
		return false
	end

	if self.skillCD > 0 then
		return false
	end

	local skillAnger = self:GetSkillAnger()
	local totalAnger = fightRoleMgr.selfAnger
	if self.logicInfo.bEnemyRole then
		totalAnger = fightRoleMgr.enemyAnger
	end
	if totalAnger < skillAnger then
		return false
	end

	return true
end

function FightRole:GetSkillCD()
	local skillInfo = BaseDataManager:GetSkillBaseInfo(self.skillID)
	if skillInfo ~= nil and skillInfo.cool_time ~= nil then
		return skillInfo.cool_time
	else
		return 10000
	end 
end

function FightRole:GetNormalSkill()
	local passiveSkillNum = #self.passiveSkill
	for i=1,passiveSkillNum do
		local skillId = self.passiveSkill[i]
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(skillId)
		if skillBaseInfo ~= nil and skillBaseInfo.hidden_skill == 1 then --暗器类技能
			local random = math.random(1, 10000)
			if random <= skillBaseInfo.trigger_rate then
				return skillId
			end
		end
	end

	return {skillId = 0,level = 0}
end
function FightRole:getPermanentBufSkill()
	local passiveSkillNum = #self.passiveSkill
	for i=1,passiveSkillNum do
		local skillId = self.passiveSkill[i]
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(skillId)
		if skillBaseInfo ~= nil and skillBaseInfo.hidden_skill == 2 then --开场buf
			return skillBaseInfo
		end
	end

	return nil
end

function FightRole:AddCommonAnger(num)
	if self:GetBuffByType(16) ~= nil then
		fightRoleMgr:AddAnger(self.logicInfo.bEnemyRole, 0)
		return
	end

	if num == nil or num == 0 then
		return
	end

	fightRoleMgr:AddAnger(self.logicInfo.bEnemyRole, num)
end

function FightRole:setPosition(pos)
	self.rolePanel:setPosition(pos)
end

function FightRole:getPosition()
	return self.rolePanel:getPosition()
end

function FightRole:IsLive()
	return self.currHp > 0
end

function FightRole:GetRowIndex()
	local posIndex = self.logicInfo.posindex
	if posIndex >= 9 then
		posIndex = posIndex - 9
	end

	return math.floor(posIndex/3)
end

function FightRole:GetColumnIndex()
	local posIndex = self.logicInfo.posindex
	if posIndex >= 9 then
		posIndex = posIndex - 9
	end

	return posIndex%3
end

function FightRole:OnActionStart()
	if self:IsLive() then
		if self.hitBackTween then
			TFDirector:killTween(self.hitBackTween)
			self.hitBackTween = nil
		end

		--目标原地被反击
		if FightManager:GetCurrAction().actionInfo.bBackAttack then
			local targetRole = FightManager:GetCurrAction():GetTargetRole(1)
			if targetRole == self then
				print("target role is myself. return....")
				return
			end
		end

		self:setPosition(self.originPos)
		self:UpdateZOrder()

		-- self:permanentBufSkill()
	end
end

function FightRole:OnAddPermanentBuf()
	local permanentBufSkill = self:getPermanentBufSkill()
	if self:IsLive() and permanentBufSkill then
		local buff_id = permanentBufSkill.buff_id
		local bufferInfo = SkillLevelData:findBuffInfo( buff_id , permanentBufSkill.level )
		if bufferInfo then
			if self:GetBuffByType(bufferInfo.type) == nil then
				if self:AddBuff(self,buff_id , permanentBufSkill.level,0) then
					fightRoundMgr:AddPermanentBuf(self,self,{skillid = permanentBufSkill.id, level = permanentBufSkill.level},buff_id,0)
				end
			end
		end
	end

	if FightManager.isReplayFight == false then
		local buSiBuXiu = self:GetBuffByType(33)
		if buSiBuXiu then
			local bufferInfo = SkillBufferData:objectByID(tonumber(buSiBuXiu.config.value))
			fightRoundMgr:hasOrGiveBuff(buSiBuXiu.config.id,bufferInfo ,self )
		end
	end
end

function FightRole:SetSpeed(speed)
	self.animSpeed = speed
	-- modify by jin 20170307 --[
	-- self.armature:setAnimationFps(speed * GameConfig.ANIM_FPS)
	ModelManager:setAnimationFps(self.armature, speed * GameConfig.FPS)
	--]--
	
	for k,effect in pairs(self.bodyEffectList) do
		if effect ~= nil then
			-- modify by jin 20170307 --[
			-- effect:setAnimationFps(speed * GameConfig.ANIM_FPS)
			ModelManager:setAnimationFps(effect, speed * GameConfig.FPS)
			--]--
		end
	end
end

function FightRole:UpdateZOrder()
	local rolePos = self:getPosition()
	self.rolePanel:setZOrder(-rolePos.y)

	local scale = mapLayer.GetScaleByYPos(rolePos.y)

	if FightManager.fightBeginInfo and FightManager.fightBeginInfo.fighttype == 10 and self.logicInfo.bEnemyRole then
		scale = scale * 1.3
	end
	self:setScale(scale)
end

function FightRole:MoveToRole(targetRole, distance, beforeMoveAnim,moveType)
	if not targetRole then
		return
	end

	distance = distance or 30

	local targetPos = targetRole:getPosition()
	-- local targetBoxWidth = targetRole.armature:boundingBox().size.width
	local targetBoxWidth = targetRole.boundingBox.size.width
	local targetPosX = nil
	local minScale, maxScale = mapLayer.GetScaleRange()
	local scaleFaction = targetRole.rolePanel:getScale() / maxScale
	if self.logicInfo.bEnemyRole then
		-- targetPosX = targetPos.x + math.floor(targetBoxWidth/2+distance) * scaleFaction
		targetPosX = targetPos.x + distance * scaleFaction
	else
		-- targetPosX = targetPos.x - math.floor(targetBoxWidth/2+distance) * scaleFaction
		targetPosX = targetPos.x - distance * scaleFaction
	end
	local targetPosY = targetPos.y - 1

	if beforeMoveAnim ~= nil and self:HaveAnim(beforeMoveAnim) then
		ModelManager:playWithNameAndIndex(self.armature, beforeMoveAnim, -1, 0, -1, -1)

		if self.bossEffect then
			self.bossEffect:setVisible(false)
		end
		if self.bossBehindEffect then
			self.bossBehindEffect:setVisible(false)
		end

		ModelManager:addListener(self.armature, "ANIMATION_COMPLETE", function() 
			ModelManager:removeListener(self.armature, "ANIMATION_COMPLETE")
			self:MoveToPosition(targetPosX, targetPosY,moveType)
		end)
	else
		self:MoveToPosition(targetPosX, targetPosY,moveType)
	end
end

function FightRole:MoveToPosition(targetPosX, targetPosY,moveType)
	self.attackAnimEnd = true
	-- modify by zr 20170605 --[
	-- ModelManager:playWithNameAndIndex(self.armature, "move", -1, 1, -1, -1)
	local mType = moveType
	if mType == 0 or mType == nil then
		ModelManager:playWithNameAndIndex(self.armature, "move", -1, 1, -1, -1)
	elseif mType == 1 then
		ModelManager:playWithNameAndIndex(self.armature, "move", -1, 1, -1, -1)
		self:SetHpBarVisible(false)
	else
		ModelManager:playWithNameAndIndex(self.armature, "move", -1, 1, -1, -1)
	end
	--]--

	-- modify by jin 20170307 --[
	-- self.armature:play("move")
	--ModelManager:playWithNameAndIndex(self.armature, "move", -1, 1, -1, -1)
	--]--

	if self.bossEffect then
		self.bossEffect:setVisible(false)
	end
	if self.bossBehindEffect then
		self.bossBehindEffect:setVisible(false)
	end

	if self.hitBackTween then
		TFDirector:killTween(self.hitBackTween)
		self.hitBackTween = nil
	end

	local moveTween = 
	{
		target = self.rolePanel,
		{
			ease = {type=TFEaseType.EASE_IN_OUT, rate=3},
			duration = 0.5 / FightManager.fightSpeed,
			x = targetPosX,
			y = targetPosY,

			onUpdate = function ()
				self:UpdateZOrder()
			end,
		
			onComplete = function ()
				self:UpdateZOrder()
				self:OnReachTarget()
			end,
		},
	}
	TFDirector:toTween(moveTween)
end

function FightRole:OnReachTarget()
	FightManager:GetCurrAction():ShowAttackAnim()
end

function FightRole:ReturnBack()
	TFDirector:currentScene():ZoomOut()
	
	if self.armature == nil then
		return
	end

	if not self:IsLive() then
		FightManager:OnActionEnd()
	end

	local currPos = self:getPosition()
	local eq = (self.originPos.x == currPos.x and self.originPos.y == currPos.y)
	if eq or FightManager:HaveBackAttackAction() then
		self:PlayStandAnim()
		FightManager:OnActionEnd()
		return
	end

	local pathType = 0
	local randNum = math.random(0, 100)
	if math.abs(currPos.y - self.originPos.y) < 10 and randNum < 30 then
		pathType = 1
	end

	if self.hitBackTween then
		TFDirector:killTween(self.hitBackTween)
		self.hitBackTween = nil
	end

	self.attackAnimEnd = true

    -- modify by jin 20170307 --[
    -- self.armature:play("back")
	ModelManager:playWithNameAndIndex(self.armature, "back", -1, 1, -1, -1)
	--]--

	if self.bossEffect then
		self.bossEffect:setVisible(false)
	end
	if self.bossBehindEffect then
		self.bossBehindEffect:setVisible(false)
	end

	local currAction = FightManager:GetCurrAction()
	local returnTime = 0.3
	if currAction ~= nil and currAction.bEnemyAllDie then
		returnTime = returnTime * 3
	end

	if pathType == 0 then
		local returnBackLine = 
		{
			target = self.rolePanel,
			{
				ease = {type=TFEaseType.EASE_OUT, rate=2},
				duration = returnTime / FightManager.fightSpeed,
				x = self.originPos.x,
				y = self.originPos.y,

				onUpdate = function ()
					self:UpdateZOrder()
				end,

				onComplete = function ()
					self:UpdateZOrder()
					self:PlayStandAnim()
					FightManager:OnActionEnd()
				end,
			},
		}
		TFDirector:toTween(returnBackLine)
	else
		local middlePosX = (self:getPosition().x + self.originPos.x)/2
		local dist = math.abs(self:getPosition().x - self.originPos.x)
		local middlePosY = (self:getPosition().y + self.originPos.y)/2 + dist/2

		returnBackBezier = 
		{
			target = self.rolePanel,
			{
				duration = returnTime / FightManager.fightSpeed,
				bezier =
				{
					{
						x = middlePosX,
						y = middlePosY,
					},
					{
						x = middlePosX,
						y = middlePosY,
					},
					{
						x = self.originPos.x,
						y = self.originPos.y,
					},
				},
				
				onUpdate = function ()
					self:UpdateZOrder()
				end,

				onComplete = function ()
					self.shadowImg:setVisible(true)
					self:PlayStandAnim()
					FightManager:OnActionEnd()
				end,
			},
		}
		self.shadowImg:setVisible(false)
		TFDirector:toTween(returnBackBezier)
	end
end

--在自己身上添加特效
function FightRole:AddBodyEffect(nEffectID, bLoop, bBehindBody, nPosOffsetX, nPosOffsetY)
	if self.armature == nil then
		return
	end

	if self.bodyEffectList[nEffectID] ~= nil then
		return
	end

	-- modify by jin 20170307 --[
	-- local resPath = "effect/"..nEffectID..".xml"
	-- if not TFFileUtil:existFile(resPath) then
	-- 	return
	-- end

	-- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

	-- -- if self.logicInfo.bEnemyRole then
	-- -- 	GameResourceManager:addEnemyEffect( self.logicInfo.roleId , nEffectID , resPath )
	-- -- else
	-- -- 	GameResourceManager:addRoleEffect( self.logicInfo.roleId , nEffectID , resPath )
	-- -- end

	-- local bodyEffect = TFArmature:create(nEffectID.."_anim")
	-- if bodyEffect == nil then
	-- 	return
	-- end
	if not ModelManager:existResourceFile(2, nEffectID) then
		return
	end
	ModelManager:addResourceFromFile(2, nEffectID, 1)
	local bodyEffect = ModelManager:createResource(2, nEffectID)
	if bodyEffect == nil then
		return
	end
	--]--

	nPosOffsetX = nPosOffsetX or 0
	nPosOffsetY = nPosOffsetY or 0
	bodyEffect:setPosition(ccp(nPosOffsetX, nPosOffsetY))

	-- modify by jin 20170307 --[
	-- bodyEffect:setAnimationFps(GameConfig.ANIM_FPS)
	ModelManager:setAnimationFps(bodyEffect, GameConfig.FPS)
	--]--
	-- bodyEffect:setAnimationFps(FightManager.fightSpeed * GameConfig.ANIM_FPS)

	if bBehindBody then
		local roleZOrder = self.armature:getZOrder()
		bodyEffect:setZOrder(roleZOrder-1)
	else
		bodyEffect:setZOrder(200)
	end

	self.rolePanel:addChild(bodyEffect)

	local movNames = bodyEffect:getMovementNameStrings()
	local moveList = string.split(movNames, ";")
	local len = #moveList
	if moveList[len] == "" then len = len - 1 end
	if len <= 1 then
		if bLoop then
			-- modify by jin 20170307 --[
			-- bodyEffect:playByIndex(0, -1, -1, 1)
			ModelManager:playWithNameAndIndex(bodyEffect, "", 0, 1, -1, -1)
			--]--
		else
			-- modify by jin 20170307 --[
			-- bodyEffect:playByIndex(0, -1, -1, 0)
			-- bodyEffect:addMEListener(TFARMATURE_COMPLETE,
			-- function()
			-- 	bodyEffect:removeMEListener(TFARMATURE_COMPLETE) 
			-- 	self:RemoveBodyEffect(nEffectID)
			-- end)
			ModelManager:playWithNameAndIndex(bodyEffect, "", 0, 0, -1, -1)
			ModelManager:addListener(bodyEffect, "ANIMATION_COMPLETE", function() 
				ModelManager:removeListener(bodyEffect, "ANIMATION_COMPLETE")
				self:RemoveBodyEffect(nEffectID)
			end)
			--]--
		end
	else
		-- modify by jin 20170307 --[
		-- bodyEffect:playByIndex(0, -1, -1, 0)
		-- bodyEffect:addMEListener(TFARMATURE_COMPLETE,
		-- 	function()
		-- 		bodyEffect:removeMEListener(TFARMATURE_COMPLETE) 
		-- 		bodyEffect:playByIndex(1, -1, -1, 1)
		-- 	end)
		ModelManager:playWithNameAndIndex(bodyEffect, "", 0, 0, -1, -1)
		ModelManager:addListener(bodyEffect, "ANIMATION_COMPLETE", function() 
			ModelManager:removeListener(bodyEffect, "ANIMATION_COMPLETE")
			ModelManager:playWithNameAndIndex(bodyEffect, "", 1, 1, -1, -1)
		end)
		--]--
	end

	self.bodyEffectList[nEffectID] = bodyEffect
end

function FightRole:RemoveBodyEffect(nEffectID)
	local effect = self.bodyEffectList[nEffectID]
	if effect ~= nil then
		self.rolePanel:removeChild(effect)
		self.bodyEffectList[nEffectID] = nil
	end
end

function FightRole:RemoveAllBodyEffect(nEffectID)
	for k,effect in pairs(self.bodyEffectList) do
		if effect ~= nil then
			self.rolePanel:removeChild(effect)
		end
	end
	self.bodyEffectList = {}
end

function FightRole:PlaySkillEffect(nEffectID, effectType, nPosOffsetX, nPosOffsetY, effectScale,targetRole, flyEffRotate)
	if self.armature == nil then
		return
	end

	-- modify by jin 20170307 --[
	-- local resPath = "effect/"..nEffectID..".xml"
	-- if not TFFileUtil:existFile(resPath) then
	-- 	return
	-- end

	-- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

	-- local skillEff = TFArmature:create(nEffectID.."_anim")
	-- if skillEff == nil then
	-- 	return
	-- end
	if not ModelManager:existResourceFile(2, nEffectID) then
		return
	end
	ModelManager:addResourceFromFile(2, nEffectID, 1)
	local skillEff = ModelManager:createResource(2, nEffectID)
	if skillEff == nil then
		return
	end
	--]--

	if self.logicInfo.bEnemyRole then
		GameResourceManager:addEnemyEffect( self.logicInfo.roleId , nEffectID , skillEff )
	else
		GameResourceManager:addRoleEffect( self.logicInfo.roleId , nEffectID , skillEff )
	end

	nPosOffsetX = nPosOffsetX or 0
	nPosOffsetY = nPosOffsetY or 0

	effectType = effectType or 0
	local effPosX = 0
	local effPosY = 0
	if effectType == 1 or effectType == 8 or effectType == 11 then
		effPosX = GameConfig.WS.width/2
		effPosY = GameConfig.WS.height/2
	elseif effectType == 6 or effectType == 9 then
		local pos = 4
		if self.logicInfo.bEnemyRole then
			pos = 13
		end
		local rolePos = mapLayer.GetPosByIndex(pos)
		effPosX = rolePos.x
		effPosY = rolePos.y
	elseif effectType == 7 or effectType == 10 then
		local pos = 13
		if self.logicInfo.bEnemyRole then
			pos = 4
		end
		local rolePos = mapLayer.GetPosByIndex(pos)
		effPosX = rolePos.x
		effPosY = rolePos.y
	elseif effectType > 1 and effectType <= 4 then
		local rolePos = self:getPosition()
		effPosX = rolePos.x
		effPosY = rolePos.y
	elseif effectType == 12 then
		local rolePos = self:getPosition()
		effPosX = rolePos.x
		effPosY = rolePos.y
	end

	effPosY = effPosY + nPosOffsetY
	if not self.logicInfo.bEnemyRole then
		effPosX = effPosX + nPosOffsetX
	else
		effPosX = effPosX - nPosOffsetX
	end

	skillEff:setPosition(ccp(effPosX, effPosY))

	-- modify by jin 20170307 --[
	-- skillEff:setAnimationFps(self.animSpeed * GameConfig.ANIM_FPS)
	ModelManager:setAnimationFps(skillEff, self.animSpeed * GameConfig.FPS)
	--]--

	if effectScale == nil then effectScale = 1 end
	skillEff:setScale(effectScale)
	if self.logicInfo.bEnemyRole then
		skillEff:setRotationY(180)
	end

	if effectType == 0  then
		self.rolePanel:addChild(skillEff)
	elseif effectType == 5 then
		skillEff:setZOrder(-1000)
		self.rolePanel:addChild(skillEff)
	elseif effectType == 6 or effectType == 7 or effectType == 12 then
		-- skillEff:setZOrder(-1000)
		fightRoleMgr.roleLayer:addChild(skillEff)
	elseif effectType == 8  or effectType == 9 or effectType == 10 then
		skillEff:setZOrder(EFFECT_ZORDER)
		fightRoleMgr.roleLayer:addChild(skillEff)
	elseif effectType == 11 then
		skillEff:setZOrder(-1000)
		fightRoleMgr.roleLayer:addChild(skillEff)
	else
		local roleZOrder = self.armature:getZOrder()
		skillEff:setZOrder(EFFECT_ZORDER + roleZOrder)
		fightRoleMgr.roleLayer:addChild(skillEff)
	end

	if effectType ~= 0 and effectType ~= 5 and effectType ~= 12 then
		local scale = mapLayer.GetScaleByYPos(effPosY)
		skillEff:setScale(scale)
	end

	if effectType == 0 or effectType == 1 or effectType == 2 or effectType == 5 or effectType == 6 or effectType == 7 or effectType == 8 or effectType == 9 or effectType == 10 or effectType == 11 or effectType == 12 then
		ModelManager:playWithNameAndIndex(skillEff, "", 0, 0, -1, -1)
		ModelManager:addListener(skillEff, "ANIMATION_COMPLETE", function() 
			ModelManager:removeListener(skillEff, "ANIMATION_COMPLETE")
			if effectType == 0 or  effectType == 12 then
				self.rolePanel:removeChild(skillEff)
			else
				fightRoleMgr.roleLayer:removeChild(skillEff)
			end
		end)
		--]--
	else -- 飞行特效 循环播放
		ModelManager:playWithNameAndIndex(skillEff, "", 0, 1, -1, -1)
		self:MoveSkillEffect(skillEff, effectType, targetRole, flyEffRotate)
	end
end

function FightRole:PlayTextEffect(text, pos)
	if self.armature == nil then
		return
	end

	-- modify by jin 20170307 --[
	-- local resPath = "effect/"..text..".xml"
	-- if not TFFileUtil:existFile(resPath) then
	-- 	return
	-- end

	-- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

	-- local textEff = TFArmature:create(text.."_anim")
	-- if textEff == nil then
	-- 	assert(false, "effect/"..text..".xml not find")
	-- 	return
	-- end
	if not ModelManager:existResourceFile(2, text) then
		return
	end
	ModelManager:addResourceFromFile(2, text, 1)
	local textEff = ModelManager:createResource(2, text)
	if textEff == nil then
		assert(false, "effect/"..text..".xml not find")
		return
	end
	--]--

	if self.logicInfo.bEnemyRole then
		GameResourceManager:addEnemyEffect( self.logicInfo.roleId , text , textEff )
	else
		GameResourceManager:addRoleEffect( self.logicInfo.roleId , text , textEff )
	end


	local roleZOrder = self.armature:getZOrder()
	textEff:setZOrder(FIGHT_TEXT_ZORDER)

	textEff:setPosition(pos)

	
	-- modify by jin 20170307 --[
	-- textEff:setAnimationFps(FightManager.fightSpeed * GameConfig.ANIM_FPS)
	ModelManager:setAnimationFps(textEff, self.animSpeed * GameConfig.FPS)
	--]--

	-- modify by jin 20170307 --[
	-- textEff:playByIndex(0)
	ModelManager:playWithNameAndIndex(textEff, "", 0, 0, -1, -1)
	--]--
	
	TFDirector:currentScene().fightUiLayer.ui:addChild(textEff)

	-- modify by jin 20170307 --[
	-- textEff:addMEListener(TFARMATURE_COMPLETE,
	-- function() 
	-- 	textEff:removeMEListener(TFARMATURE_COMPLETE)
	-- 	TFDirector:currentScene().fightUiLayer.ui:removeChild(textEff)
	-- end)
	ModelManager:addListener(textEff, "ANIMATION_COMPLETE", function() 
		ModelManager:removeListener(textEff, "ANIMATION_COMPLETE")
		TFDirector:currentScene().fightUiLayer.ui:removeChild(textEff)
	end)
	--]--
end

function FightRole:PlaySkillNameEffect()
	if self.armature == nil then
		return
	end

	-- modify by jin 20170307 --[
	-- TFResourceHelper:instance():addArmatureFromJsonFile("effect/light.xml")
	-- local lightEff = TFArmature:create("light_anim")
	-- if lightEff == nil then
	-- 	return
	-- end
	ModelManager:addResourceFromFile(2, "light", 1)
	local lightEff = ModelManager:createResource(2, "light")
	if lightEff == nil then
		return
	end
	--]--

	lightEff:setZOrder(EFFECT_ZORDER + 102)

	local rolePos = self:getPosition()
	local effPosX = rolePos.x
	local effPosY = rolePos.y
	lightEff:setPosition(ccp(effPosX, effPosY-50))

	-- modify by jin 20170307 --[
	-- lightEff:setAnimationFps(FightManager.fightSpeed * GameConfig.ANIM_FPS)
	ModelManager:setAnimationFps(lightEff, self.animSpeed * GameConfig.FPS)
	--]--

	-- modify by jin 20170307 --[
	-- lightEff:playByIndex(0)
	ModelManager:playWithNameAndIndex(lightEff, "", 0, 0, -1, -1)
	--]--

	fightRoleMgr.roleLayer:addChild(lightEff)

	-- modify by jin 20170307 --[
	-- lightEff:addMEListener(TFARMATURE_COMPLETE,
	-- function() 
	-- 	lightEff:removeMEListener(TFARMATURE_COMPLETE)
	-- 	fightRoleMgr.roleLayer:removeChild(lightEff)
	-- 	FightManager:GetCurrAction():BeginAttack()
	-- end)
	ModelManager:addListener(lightEff, "ANIMATION_COMPLETE", function() 
		ModelManager:removeListener(lightEff, "ANIMATION_COMPLETE")
		fightRoleMgr.roleLayer:removeChild(lightEff)
		FightManager:GetCurrAction():BeginAttack()
	end)
	--]--
end

function FightRole:IsSameRow(targetRole)
	if math.abs(self.originPos.y - targetRole.originPos.y) < 10 then
		return true
	else
		return false
	end
end

function FightRole:MoveSkillEffect(skillEffect, effectType, targetRole, flyEffRotate)
	if targetRole == nil then
		assert(false)
		return
	end

	if self.logicInfo.bEnemyRole then
		skillEffect:setRotationY(180)
	end

	local movePath = 
	{
		target = skillEffect,
		{
			duration = 0.3 / FightManager.fightSpeed,
			x = targetRole.originPos.x,
			y = targetRole.originPos.y,

			onUpdate = function ()
				local scale = mapLayer.GetScaleByYPos(skillEffect:getPositionY())
				skillEffect:setScale(scale)
			end,

			onComplete = function ()
				fightRoleMgr.roleLayer:removeChild(skillEffect)
			end,
		},
	}

	TFDirector:toTween(movePath)
end

function FightRole:HaveAnim(animName)
	animName = animName..";"
	local movNames = self.armature:getMovementNameStrings()
	movNames = movNames..";"
	if string.find(movNames, animName) then
		return true
	else
		return false
	end
end

function FightRole:PlayAttackAnim(bNormalAttack, animName)
	if self.armature == nil then
		return
	end

	local currAction = FightManager:GetCurrAction()
	if currAction.skillDisplayInfo.attackAnimMove then
		self:SetHpBarVisible(false)
	end

	if self.logicInfo.bEnemyRole == false and currAction.actionInfo.skillid.skillId > 0 and currAction.skillDisplayInfo.remote == 0 then
		TFDirector:currentScene():ZoomIn(self)
	end

	self.attackAnimEnd = false
	self.needReturnBack = false

	if animName ~= nil and self:HaveAnim(animName) then
		-- modify by jin 20170307 --[
	    -- self.armature:play(animName, -1, -1, 0)
		ModelManager:playWithNameAndIndex(self.armature, animName, -1, 0, -1, -1)
		--]--
		
		if self.bossEffect then
			self.bossEffect:setVisible(false)
		end
		if self.bossBehindEffect then
			self.bossBehindEffect:setVisible(false)
		end
	else
		if bNormalAttack then
			-- modify by jin 20170307 --[
		    -- self.armature:play("attack", -1, -1, 0)
			ModelManager:playWithNameAndIndex(self.armature, "attack", -1, 0, -1, -1)
			--]--
			if self.bossEffect then
				self.bossEffect:setVisible(false)
			end
			if self.bossBehindEffect then
				self.bossBehindEffect:setVisible(false)
			end
		else
			-- modify by jin 20170307 --[
		    -- self.armature:play("skill", -1, -1, 0)
			ModelManager:playWithNameAndIndex(self.armature, "skill", -1, 0, -1, -1)
			--]--
			if self.bossEffect then
				self.bossEffect:setVisible(false)
			end
			if self.bossBehindEffect then
				self.bossBehindEffect:setVisible(false)
			end
		end
	end

	-- modify by jin 20170307 --[
	-- self.armature:addMEListener(TFARMATURE_COMPLETE, function()
	-- 	self.armature:removeMEListener(TFARMATURE_COMPLETE)
	-- 	if not self.attackAnimEnd then
	-- 		self.attackAnimEnd = true
	-- 		if self.needReturnBack then
	-- 			self:ReturnBack()
	-- 		else
	-- 			self:PlayStandAnim()
	-- 		end
	-- 		self:SetHpBarVisible(true)
	-- 	end
	-- end)
	ModelManager:addListener(self.armature, "ANIMATION_COMPLETE", function() 
		ModelManager:removeListener(self.armature, "ANIMATION_COMPLETE")
		if not self.attackAnimEnd then
			self.attackAnimEnd = true
			if self.needReturnBack then
				self:ReturnBack()
			else
				self:PlayStandAnim()
			end
			self:SetHpBarVisible(true)
		end
	end)
	--]--
end

function FightRole:PlayStandAnim()
	if self.armature == nil then
		return
	end

	self.attackAnimEnd = true

	-- modify by jin 20170307 --[
	-- self.armature:play("stand", -1, -1, 1)
	ModelManager:playWithNameAndIndex(self.armature, "stand", -1, 1, -1, -1)
	--]--

   
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffer = self.buffList:objectAt(i)
		if buffer.bValid and buffer.config.stand_display and buffer.config.stand_display ~= "" then
			-- modify by jin 20170307 --[
			-- self.armature:play(buffer.config.stand_display, -1, -1, 1)
			ModelManager:playWithNameAndIndex(self.armature, buffer.config.stand_display, -1, 1, -1, -1)
	        --]--
		end
	end

	if self.bossEffect then
		self.bossEffect:setVisible(true)
	end
	if self.bossBehindEffect then
		self.bossBehindEffect:setVisible(true)
	end

	if self:HaveForbidAttackBuff() then
		self.armature:stop()
	end

	-- modify by jin 20170307 --[
	-- self.armature:removeMEListener(TFARMATURE_COMPLETE)
	ModelManager:removeListener(self.armature, "ANIMATION_COMPLETE")
	--]--
end

function FightRole:PlayHitAnim(bLastHit)
	if self.armature == nil then
		return
	end 

	self.attackAnimEnd = true

	-- modify by jin 20170307 --[
	-- self.armature:play("hit", -1, -1, 0)
	ModelManager:playWithNameAndIndex(self.armature, "hit", -1, 0, -1, -1)
	self.armature:resume()
	--]--

	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffer = self.buffList:objectAt(i)
		if buffer.bValid and buffer.config.behit_display and buffer.config.behit_display ~= "" then
			-- modify by jin 20170307 --[
			-- self.armature:play(buffer.config.behit_display, -1, -1, 0)
			ModelManager:playWithNameAndIndex(self.armature, buffer.config.behit_display, -1, 0, -1, -1)
			--]--
		end
	end

	if self.bossEffect then
		self.bossEffect:setVisible(false)
	end
	if self.bossBehindEffect then
		self.bossBehindEffect:setVisible(false)
	end

	if bLastHit then
		self:DoHitBackAction()
	end

	self.armature:setColor(ccc3(100, 0, 0))

	-- modify by jin 20170307 --[
	-- self.armature:addMEListener(TFARMATURE_COMPLETE, function() 
	-- 	self.armature:removeMEListener(TFARMATURE_COMPLETE)
	-- 	if self:IsLive() then
	-- 		self:PlayStandAnim()
	-- 		self.armature:setColor(ccc3(255, 255, 255))
	-- 	else
	-- 		if bLastHit then
	-- 			self:Die()
	-- 		end
	-- 	end

	-- 	local currAction = FightManager:GetCurrAction()
	-- 	if currAction ~= nil and bLastHit then
	-- 		currAction:OnRoleHitAnimComplete()
	-- 	end
	-- end)
	ModelManager:addListener(self.armature, "ANIMATION_COMPLETE", function() 
		ModelManager:removeListener(self.armature, "ANIMATION_COMPLETE")
		if self:IsLive() then
			self:PlayStandAnim()
			self.armature:setColor(ccc3(255, 255, 255))
		else
			if bLastHit then
				self:Die()
			end
		end

		local currAction = FightManager:GetCurrAction()
		if currAction ~= nil and bLastHit then
			currAction:OnRoleHitAnimComplete()
		end
	end)
	--]--
end

function FightRole:DoHitBackAction()
	if self.armature == nil then
		return
	end

	if self.hitBackTween then
		TFDirector:killTween(self.hitBackTween)
		self.hitBackTween = nil
	end

	local originPos = self:getPosition()
	local movePos = {}
	if self.logicInfo.bEnemyRole then
		movePos.x = originPos.x + 30
	else
		movePos.x = originPos.x - 30
	end

	if self:IsLive() then
		self.hitBackTween = 
		{
			target = self.rolePanel,
			{
				duration = 0.2 / FightManager.fightSpeed,
				x = movePos.x,
				y = movePos.y,
			},
			{
				delay = 0.5 / FightManager.fightSpeed,
				duration = 0.1,
				x = originPos.x,
				y = originPos.y,

				onComplete = function ()
					self.hitBackTween = nil
				end
			},
		}
	else
		self.hitBackTween = 
		{
			target = self.rolePanel,
			{
				duration = 0.2 / FightManager.fightSpeed,
				x = movePos.x,
				y = movePos.y,

				onComplete = function ()
					self.hitBackTween = nil
				end
			},
		}
	end

	TFDirector:toTween(self.hitBackTween)
end

function FightRole:DoAvoidAction()
	if self.armature == nil then
		return
	end

	local originPos = self:getPosition()
	local movePos = {}
	if self.logicInfo.bEnemyRole then
		movePos.x = originPos.x + 70
		movePos.y = originPos.y + 50
	else
		movePos.x = originPos.x - 70
		movePos.y = originPos.y + 50
	end

	local avoid = 
	{
		target = self.rolePanel,
		{
			duration = 0.1 / FightManager.fightSpeed,
			x = movePos.x,
			y = movePos.y,
		},
		{ 
   			duration = 0,
   			delay = 0.7 / FightManager.fightSpeed,

   			onComplete = function ()
				self:setPosition(originPos)
			end	
		},
	}
	TFDirector:toTween(avoid)
end

function FightRole:Die()
	if self.armature == nil then
		return
	end
	fightRoleMgr:refreshMaxHp()
	TFDirector:currentScene().fightUiLayer:OnFightRoleDie(self)

	self:RemoveAllBuff()

	self:RemoveAllBodyEffect()

	local currAction = FightManager:GetCurrAction()
	if currAction ~= nil and currAction.bEnemyAllDie and self.logicInfo.bEnemyRole then
		-- if currAction.skillDisplayInfo.remote == 0 then
		-- 	TFDirector:currentScene():ZoomIn(currAction.attackerRole)
		-- end
		fightRoleMgr:SetAllRoleSpeed(0.5)
		self:PlayDieBezier()
	else
		local dieEffect = 
		{
			target = self.rolePanel,
			{
				duration = 1 / FightManager.fightSpeed,
				alpha = 0,
			
				onComplete = function()
					if not self:IsLive() then
						self.rolePanel:setVisible(false)
					else
						self.rolePanel:setOpacity(255)
					end
				end
			}
		}
		TFDirector:toTween(dieEffect)
	end
end

function FightRole:PlayDieBezier()
	local middlePosX = self:getPosition().x + 200
	local middlePosY = self:getPosition().y + 200
	local endPosX = self:getPosition().x + 400
	local endPosY = self:getPosition().y

	local dieBezier = 
	{
		target = self.rolePanel,
		{
			duration = 1,
			bezier = 
			{
				{
					x = middlePosX,
					y = middlePosY,
				},
				{
					x = middlePosX,
					y = middlePosY,
				},
				{
					x = endPosX,
					y = endPosY,
				},
			},

			rotate = 90,

			onComplete = function ()
				self.rolePanel:setVisible(false)
				TFDirector:currentScene().fightUiLayer:PlayFightEndEffect()
			end,
		},
	}
	self:SetHpBarVisible()
	TFDirector:toTween(dieBezier)
end

function FightRole:ReLive(reliveHp)
	if self.haveRelive then
		return false
	end

	self:RemoveAllBuff()

	self.haveRelive = true
	self:AddBodyEffect("fuhuo", false)
	self:ShowEffectName("fuhuo")
	self:SetHp(reliveHp)

	TFDirector:currentScene().fightUiLayer:OnFightRoleReLive(self)
	return true
end

function FightRole:CreateDamageNumFont(text, number)
	local damageFont = TFLabelBMFont:create()
	damageFont:setAnchorPoint(ccp(0.5, 0.5))
	damageFont:setZOrder(FIGHT_TEXT_ZORDER + self.logicInfo.posindex)

	if number < 0 then
		if text == "baoji" then --暴击
			damageFont:setFntFile("font/bigDamage.fnt")	
		else
			damageFont:setFntFile("font/damage.fnt")	
		end
	else
		damageFont:setFntFile("font/addHp.fnt")
	end	

	return damageFont
end

function FightRole:CreateAngerNumFont(angerNum)
	local angerNumFont = TFLabelBMFont:create()
	angerNumFont:setAnchorPoint(ccp(0.5, 0.5))
	angerNumFont:setZOrder(FIGHT_TEXT_ZORDER + self.logicInfo.posindex)

	if angerNum > 0 then
		angerNumFont:setFntFile("font/addAnger.fnt")	
	else
		angerNumFont:setFntFile("font/subAnger.fnt")	
	end

	return angerNumFont
end

function FightRole:SetHp(currHp, bTestDie)
	if self.currHp > currHp then
		if self.logicInfo.bEnemyRole then
			if fightRoleMgr:IsSelfAllDie() then
				return
			end
		else
			if fightRoleMgr:IsEnemyAllDie() then
				return
			end
		end
	end
	self.currHp = currHp
	self.currHp = math.max(self.currHp, 0)
	self.currHp = math.min(self.currHp, self.logicInfo.maxhp)

	print(self.logicInfo.name.." 剩余血量 "..self.currHp..",  总血量"..self.logicInfo.maxhp)
	if self.hpLabel ~= nil then
		self.hpLabel:setPercent(self.currHp*100 / self.logicInfo.maxhp)
	end

	if bTestDie == nil then
		bTestDie = true
	end

	if bTestDie and self.currHp <= 0 then
		self:Die()
	end

	self:OnHpChange()
end

function FightRole:OnHpChange()
	if not self:IsLive() then
		return
	end

	local effectValue = {}
	if self.passiveSkillAttrAdd == nil and self:TriggerPassiveEffect(13, effectValue) then
		self.passiveSkillAttrAdd = effectValue.value
		self:ShowEffectName("xihundafa")
		self:AddBodyEffect("yihun", true)
		print(self.logicInfo.name.."触发移魂:",self.passiveSkillAttrAdd)
	elseif self.passiveSkillAttrAdd ~= nil and not self:TriggerPassiveEffect(13, effectValue) then
		self.passiveSkillAttrAdd = nil
		self:RemoveBodyEffect("yihun")
		print(self.logicInfo.name.."移除移魂")
	end
end

function FightRole:ShowFightText(text, number, bAngerNum, bTestDie, bBezier)
	if self.armature == nil then
		return
	end

	if FightManager.fightBeginInfo and FightManager.fightBeginInfo.bSkillShowFight then
		return
	end

	local headPosX = self:getPosition().x
	local headPosY = self:getPosition().y + 200

	if text ~= "" then
		local textPosX = headPosX
		if number ~= 0 then
			textPosX = headPosX - 100
		end
		self:PlayTextEffect(text, ccp(textPosX, headPosY))
	end

	if number == 0 then
		return
	end

	-- number = math.max(-1,number)
	local currHp = self.currHp + number
	if self:GetBuffByType(56) then
		currHp = math.max(currHp,1)
	end
	self:SetHp(currHp, bTestDie)

	local fightTextLabel = nil
	if bAngerNum then
		fightTextLabel = self:CreateAngerNumFont(number)
	else
		fightTextLabel = self:CreateDamageNumFont(text, number)
	end

	fightTextLabel:setPosition(ccp(headPosX, headPosY))

	if bAngerNum then
		number = math.abs(number)
		local text = "d".."-"..number
		fightTextLabel:setText(text)
	else
		if number > 0 then
			fightTextLabel:setText("-"..number)
		else
			number = math.abs(number)
			if text == "baoji" then
				fightTextLabel:setText(number.."d")
			else
				fightTextLabel:setText(number)
			end
		end
	end

	local roleLayer = TFDirector:currentScene().roleLayer
	roleLayer:addChild(fightTextLabel)

	local pos = fightTextLabel:getPosition()
	local textTween = nil 
	if not bBezier then
		fightTextLabel:setScale(0)
		fightTextLabel:setAlpha(0.5)
		textTween = 
		{
			target = fightTextLabel,
			{
				ease = {type=TFEaseType.EASE_IN, rate=2},
				duration = 0.2 / FightManager.fightSpeed,
				alpha = 1,
				scale = 1,
				x = headPosX,
				y = headPosY + 40,
			},
			{
				delay = 0.2 / FightManager.fightSpeed,
				duration = 0.4 / FightManager.fightSpeed,
				x = headPosX,
				y = headPosY + 110,
				alpha = 0,

				onComplete = function ()
					roleLayer:removeChild(fightTextLabel)
				end
			},
		}
	else
		local offsetX = -50
		if self.logicInfo.bEnemyRole then
			offsetX = 50
		end
		textTween = 
		{
			target = fightTextLabel,
			{
				ease = {type=TFEaseType.EASE_IN_OUT, rate=2},
				duration = 0.8 / FightManager.fightSpeed,
				bezier = 
				{
					{	x = headPosX + offsetX,
						y = headPosY + 90,
					},
					{
						x = headPosX + offsetX,
						y = headPosY + 70,
					},
					{
						x = headPosX + 2*offsetX,
						y = headPosY - 100,
					},
				},
				alpha = 0.6,

				onComplete = function ()
					roleLayer:removeChild(fightTextLabel)
				end
			},
		}
	end

	TFDirector:toTween(textTween)
end

--状态类型：1中毒 2灼烧 3破绽 4虚弱 5重伤 6迟缓 7失明 8神力 9防守 10混乱 11散功 12点穴 13击晕 14冻结 15昏睡
--			16束手 17回血 18挑衅 19反弹 25赏善 26罚恶 27斗转星移 28护体(受击给攻击方加buff) 30 血刀大法
--			32 免伤 
function FightRole:GetBuffByType(buffType)
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffer = self.buffList:objectAt(i)
		if buffer.bValid and buffer.config.type == buffType then
			return buffer
		end
	end
	return nil
end

function FightRole:HaveForbidAttackBuff()
	local forbidAttackBuff = {12, 13, 14, 15}
	for i=1,#forbidAttackBuff do
		if self:GetBuffByType(forbidAttackBuff[i]) ~= nil then
			return true
		end
	end
	return false
end

function FightRole:removeForbidAttackBuff()
	local forbidAttackBuff = {12, 13, 14, 15}
	for i=1,#forbidAttackBuff do
		if self:GetBuffByType(forbidAttackBuff[i]) ~= nil then
			self:RemoveBuffByType(forbidAttackBuff[i])
		end
	end
end


function FightRole:HaveForbidBackAttackBuff()
	local forbidAttackBuff = {12, 13, 14}
	for i=1,#forbidAttackBuff do
		if self:GetBuffByType(forbidAttackBuff[i]) ~= nil then
			return true
		end
	end
	return false
end

function FightRole:HaveForbidManualSkillBuff()
	local forbidSkillBuff = {10, 11, 12, 13, 14, 15}
	for i=1,#forbidSkillBuff do
		if self:GetBuffByType(forbidSkillBuff[i]) ~= nil then
			return true
		end
	end
	return false
end

function FightRole:TestReleaseManualSkill()
	if self:HaveForbidManualSkillBuff() then
		TFDirector:currentScene().fightUiLayer:ForbidSkill(self, true)
	else
		TFDirector:currentScene().fightUiLayer:ForbidSkill(self, false)
	end
end

function FightRole:TestDieBuff()
	if self:GetBuffByType(25) ~= nil and self:GetBuffByType(26) ~= nil then
		self:RemoveBuffByType(25)
		self:RemoveBuffByType(26)
		if self:GetBuffByType(56) then
			self:SetHp(1)
		else
	  		self:SetHp(0)
	  	end
	end
end

function FightRole:AddBuff(fromTarget,buffID, level , hurt)
	local config =  SkillLevelData:getBuffInfo(buffID,level)
	if config == nil then
		assert(false, buffID..":buffer not find")
		return false
	end
	if config.is_replace == 0 then
		local has_buff = self:GetBuffByType(config.type)
		if has_buff ~= nil then
			return false
		end
	end

	if config.is_repeat == 0 then
		self:RemoveBuffByType(config.type)
	end

	local buffInfo = {}
	buffInfo.config = config
	buffInfo.lastNum = 0
	buffInfo.bValid = true
	buffInfo.hurt = hurt
	buffInfo.fromTarget = fromTarget
	self.buffList:pushBack(buffInfo)

	self:AddBuffIcon(buffID, config.icon_id)

	local under_show = config.under_show ~= 0
	if config.effect_loop == 1 then
		self:AddBodyEffect(config.effect_id, true , under_show)

	else
		self:AddBodyEffect(config.effect_id, false , under_show)
	end

	if config.type > 2 then
		self:ShowBufferName(config.type)
	end

	--挑衅buff
	if config.type == 18 then
		self.defianceTarget = FightManager:GetCurrAction().attackerRole
	end

	self:TestReleaseManualSkill()
	self:TestDieBuff()
	return true
end

function FightRole:AddBuffIcon(buffId, iconId)
	local iconImg = TFImage:create("icon/buffer/"..iconId..".png")
	if iconImg ~= nil and self.bufferIconList[buffId] == nil and self.hpBackground ~= nil then
		self.hpBackground:addChild(iconImg)
		self.bufferIconList[buffId] = iconImg
		self:SetBuffIconPos()
	end
end

function FightRole:SetBuffIconPos()
	local iconNum = 0
	for k,bufferIcon in pairs(self.bufferIconList) do
		if bufferIcon ~= nil then
			iconNum = iconNum + 1
			bufferIcon:setPosition(ccp(24*iconNum-50, 22))
		end
	end
end

function FightRole:ShowBufferName(buffType)
	local nameImg = TFImage:create("icon/buffer/name_"..buffType..".png")
	if nameImg ~= nil then
		self:MoveNameImage(nameImg)
	end
end

function FightRole:ShowEffectName(name)
	local nameImg = TFImage:create("icon/effect/"..name..".png")
	if nameImg ~= nil then
		self:MoveNameImage(nameImg)
	end
end

function FightRole:MoveNameImage(nameImg)
	if nameImg == nil then
		return
	end
	
	local posX = self:getPosition().x
	local posY = self:getPosition().y + 150
	nameImg:setPosition(ccp(posX, posY))

	local uiLayer = TFDirector:currentScene().fightUiLayer.ui
	uiLayer:addChild(nameImg)

	local pos = nameImg:getPosition()
	local nameImgTween = 
	{
		target = nameImg,
		{
			duration = 0.7 / FightManager.fightSpeed,
			x = pos.x,
			y = pos.y + 70,
			alpha = 0.3,
		
			onComplete = function ()
				nameImgTween = nil
				uiLayer:removeChild(nameImg)
			end
		},
	}

	TFDirector:toTween(nameImgTween)
end

function FightRole:HaveBuff(buffId)
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid and buffInfo.config.id == buffId then 
			return true
		end
	end

	return false
end

function FightRole:HaveFrozenBuff()
	return self:GetBuffByType(14) ~= nil
end

--斗转星移buff
function FightRole:HaveDzxyBuff()
	return self:GetBuffByType(27) ~= nil
end
--斗转星移buff
function FightRole:canTriggerDzxy()
	print("self.immuneAttribute",self.immuneAttribute)
	if self.immuneAttribute and self.immuneAttribute[27] ~= nil then
		return false
	end
	return true
end

function FightRole:HaveBadBuff()
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid and buffInfo.config.good_buff == 0 then 
			return true
		end
	end

	return false
end

function FightRole:RemoveFrozenBuff()
	self:RemoveBuffByType(14)
end

function FightRole:RemoveBuffIcon(buffId)
	if self:HaveBuff(buffId) then
		return
	end

	local bufferIcon = self.bufferIconList[buffId]
	if bufferIcon ~= nil then
		bufferIcon:removeFromParent()
		self.bufferIconList[buffId] = nil
		self:SetBuffIconPos()
	end
end

function FightRole:RemoveBuffByIndex(buffIndex)
	local buffInfo = self.buffList:objectAt(buffIndex)
	if buffInfo.bValid then
		buffInfo.bValid = false

		local needRemoveEffect = true
		local needRemoveIcon = true
		local bufferNum = self.buffList:length()
		for i=1,bufferNum do
			local _buffInfo = self.buffList:objectAt(i)
			if _buffInfo.bValid and _buffInfo.config.effect_id == buffInfo.config.effect_id then 
				needRemoveEffect = false
			end
			if _buffInfo.bValid and _buffInfo.config.id == buffInfo.config.id then 
				needRemoveIcon = false
			end
		end
		if needRemoveEffect then
			self:RemoveBodyEffect(buffInfo.config.effect_id)
		end
		if needRemoveIcon then
			self:RemoveBuffIcon(buffInfo.config.id)
		end
		-- if buffInfo.config.type == 54 then
		-- 	self:PlayStandAnim()
		-- end
	end

	if not self:HaveForbidAttackBuff() then
		self.armature:resume()
	end

	self:TestReleaseManualSkill()
end

function FightRole:RemoveBuffByType(bufferType)
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid and buffInfo.config.type == bufferType then 
			self:RemoveBuffByIndex(i)
		end
	end
end

function FightRole:RemoveAllBuff()
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid then 
			self:RemoveBuffByIndex(i)
		end
	end
end

function FightRole:CleanBuff(attackerRole)
	self:AddBodyEffect("jinghua", false)
	local cleanGood = true
	if fightRoleMgr:IsSameSide({attackerRole, self}) then
		cleanGood = false
	end

	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid then
			if cleanGood and buffInfo.config.good_buff == 1 then
				self:RemoveBuffByIndex(i)
			elseif cleanGood == false and buffInfo.config.good_buff == 0 then
				self:RemoveBuffByIndex(i)
			end
		end
	end

	if cleanGood then
		self:ShowEffectName("qusan")
	else
		self:ShowEffectName("jinghua")
	end
end

function FightRole:OnRoundChange()
	local hpChange = 0
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid and buffInfo.config.last_type == 1 then
			hpChange = hpChange + self:ShowHpChangeBuff(buffInfo)


			buffInfo.lastNum = buffInfo.lastNum + 1
			if FightManager.isReplayFight == false then
				--持续次数触发buff
				if buffInfo.config.buff_formula == 3 then
					if buffInfo.lastNum >= buffInfo.config.buff_rate then
						local new_buff_id = tonumber(buffInfo.config.value)
						local new_buff = SkillBufferData:objectByID(new_buff_id)
						if new_buff then
							if self:AddBuff(buffInfo.fromTarget , new_buff_id,buffInfo.config.level,0) then
								fightRoundMgr:AddPermanentBuf(self,self,{skillid = 0, level = 0},new_buff_id,buffInfo.config.id)
							end
						end
					end
				end
			end


			if buffInfo.lastNum >= buffInfo.config.last_num then
				self:RemoveBuffByIndex(i)
			end
		end
	end
	if hpChange ~= 0 then
		self:ShowFightText("", hpChange)
	end
	-- self:permanentBufSkill()
end

function FightRole:OnActionEnd()
	local hpChange = 0
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid and buffInfo.config.last_type == 2 then
			hpChange = hpChange + self:ShowHpChangeBuff(buffInfo)

			buffInfo.lastNum = buffInfo.lastNum + 1



			if FightManager.isReplayFight == false then
				--持续次数触发buff
				if buffInfo.config.buff_formula == 3 then
					if buffInfo.lastNum >= buffInfo.config.buff_rate then
						local new_buff_id = tonumber(buffInfo.config.value)
						local new_buff = SkillBufferData:objectByID(new_buff_id)
						if new_buff then
							if self:AddBuff(buffInfo.fromTarget ,new_buff_id,buffInfo.config.level,0) then
								fightRoundMgr:AddPermanentBuf(self,self,{skillid = 0, level = 0},new_buff_id,buffInfo.config.id)
							end
						end
					end
				end
			end

			if buffInfo.lastNum >= buffInfo.config.last_num then
				self:RemoveBuffByIndex(i)
			end
		end
	end
	
	if hpChange ~= 0 then
		self:ShowFightText("",hpChange)
	end
	-- self:permanentBufSkill()

	local buSiBuXiu_2 = self:GetBuffByType(34)
	if buSiBuXiu_2 and fightRoundMgr:hasBuffByType(33 ,self.logicInfo.bEnemyRole ) ==false then
		self:RemoveBuffByType(34)
	end

	self:repeatBufTrigger()

end

function FightRole:repeatBufTrigger()
	local bufferNum = self.buffList:length()
	local formula_list = {}
	for i=bufferNum,1,-1 do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid then -- and (buffInfo.config.last_type == 2 or buffInfo.config.last_type == 1) then
			--叠加次数触发buff
			if buffInfo.config.buff_formula == 2 then
				local canTrigger = true
				for k,v in pairs(formula_list) do
					if v == buffInfo.config.type then
						canTrigger = false
					end
				end
				if canTrigger then
					local repeat_time = self:getRepeatBuffTriggerTime( buffInfo )
					formula_list[#formula_list+1] = buffInfo.config.type
					if repeat_time >= buffInfo.config.buff_rate then
						local new_buff_id = tonumber(buffInfo.config.value)
						local new_buff = SkillBufferData:objectByID(new_buff_id)
						if new_buff then
							if self:AddBuff(buffInfo.fromTarget,new_buff_id,buffInfo.config.level,0) then
								fightRoundMgr:AddPermanentBuf(self,self,{skillid = 0, level = 0},new_buff_id,buffInfo.config.id)
							end
						end
						self:RemoveBuffByType(buffInfo.config.type)
					end
				end
			end
		end
	end
end


function FightRole:getRepeatBuffTriggerTime( buffInfo )
	local bufferNum = self.buffList:length()
	local repeat_time = 0
	for j=bufferNum,1,-1 do
		local like_buffInfo = self.buffList:objectAt(j)
		if like_buffInfo.bValid and like_buffInfo.config.type == buffInfo.config.type then
			repeat_time = repeat_time + 1
		end
	end
	return repeat_time
end

function FightRole:OnBuffTrigger()
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid and buffInfo.config.last_type == 3 then
			buffInfo.lastNum = buffInfo.lastNum + 1
			if buffInfo.lastNum >= buffInfo.config.last_num then
				self:RemoveBuffByIndex(i)
			end
		end
	end
end
function FightRole:OnAttackBuffTrigger()
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid and buffInfo.config.last_type == 4 then
			buffInfo.lastNum = buffInfo.lastNum + 1
			if buffInfo.lastNum >= buffInfo.config.last_num then
				self:RemoveBuffByIndex(i)
			end
		end
	end
end

function FightRole:ShowHpChangeBuff(buffInfo)
	if not self:IsLive() then
		return 0
	end

	local number = 0
	local valueInfo = GetAttrByString(buffInfo.config.value)

	if buffInfo.config.type == 50 then 	--流血
		local add_value = stringToNumberTable(buffInfo.config.params,"_")
		local times = buffInfo.lastNum
		for k,v in pairs(valueInfo) do
			valueInfo[k] = v + add_value[1] + add_value[2]*times
		end
	end
	for i=2,17 do
		if valueInfo[i] then
			number = number + math.floor(self:GetAttrNum(i) * valueInfo[i] / 100)
		end
	end

	if valueInfo[18] ~= nil then
		number = number + math.floor(self.logicInfo.maxhp * valueInfo[18] / 100)
	elseif valueInfo[30] ~= nil then
		number = number + math.floor(self.currHp * valueInfo[30] / 100)
	elseif valueInfo[31] ~= nil then
		local hurt = buffInfo.hurt or 0
		number = number + math.floor(hurt * valueInfo[31] / 100)
	end

	if valueInfo[1] ~= nil then
		number = number + valueInfo[1]
	end

	--类型伤害修正
	local fightEffectValue = buffInfo.fromTarget:getEffectExtraAttrNum(EnumFightAttributeType.Effect_extra,buffInfo.config.type) +
			self:getEffectExtraAttrNum(EnumFightAttributeType.Be_effect_extra,buffInfo.config.type)



	local fightDotEffectValue = 0
	local fightBonusEffectValue = 0
	if number < 0 then
			--dot伤害修正
		fightDotEffectValue = buffInfo.fromTarget:getEffectExtraAttrNum(EnumFightAttributeType.Effect_extra,EnumFightEffectType.FightEffectType_DotHurt) +
				self:getEffectExtraAttrNum(EnumFightAttributeType.Be_effect_extra,EnumFightEffectType.FightEffectType_DotHurt)

	elseif number > 0 then
		--治疗dot修正
		fightBonusEffectValue = buffInfo.fromTarget:getEffectExtraAttrNum(EnumFightAttributeType.Effect_extra,EnumFightEffectType.FightEffectType_BonusHealing) +
				self:getEffectExtraAttrNum(EnumFightAttributeType.Be_effect_extra,EnumFightEffectType.FightEffectType_BonusHealing)
	end
	fightEffectValue = fightEffectValue + fightDotEffectValue + fightBonusEffectValue
	fightEffectValue = math.max(0,fightEffectValue/10000+1)
	number = number * fightEffectValue
	number = math.floor(number)

	if number == 0 then
		return 0
	end

	--是否复活
	if self.currHp + number <= 0 then
		local effectValue = {}
		if self:HaveReliveSkill(effectValue) then
			-- self:ShowFightText("", number, false, false)
			effectValue.value = math.min(100, effectValue.value)
			local reliveHp = math.floor(self.logicInfo.maxhp * effectValue.value / 100)
			self:ReLive(reliveHp)
		else
		-- self:ShowFightText("", number)
		end
	else
		-- self:ShowFightText("", number)
	end
	-- print("buffInfo.config.type = ",buffInfo.config.type)
	if buffInfo.config.type == 1 then
		self:ShowBufferName(1)
		print(self.logicInfo.name.."中毒扣血："..number.."当前血量："..self.currHp)
	elseif buffInfo.config.type == 2 then
		self:ShowBufferName(2)
		print(self.logicInfo.name.."灼烧扣血："..number.."当前血量："..self.currHp)
	elseif buffInfo.config.type == 50 then
		self:ShowBufferName(50)
		print(self.logicInfo.name.."流血扣血："..number.."当前血量："..self.currHp)
	end

	fightRoleMgr:addHurtReport(buffInfo.fromTarget.logicInfo.posindex,  number)
	return number
end

function FightRole:HaveReliveSkill(effectValue)
	if self.haveRelive then
		return false
	end
	local passiveSkillNum = #self.passiveSkill
	for i=1,passiveSkillNum do
		local skillInfo = SkillLevelData:objectByID(self.passiveSkill[i])
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.passiveSkill[i])
		if skillInfo ~= nil and skillInfo.effect_rate == 10000 and skillBaseInfo ~= nil and skillBaseInfo.effect == 9 then
			effectValue.value = skillInfo.effect_value
			return true
		end
	end

	return false
end



--在自己身上添加特效
function FightRole:AddBossEffect(nEffectID, bBehindBody)
	if self.armature == nil then
		return
	end

	if self.logicInfo.isboss == nil or self.logicInfo.isboss ~= true then
		return
	end

	if self.bossEffect ~= nil then
		return
	end

	-- modify by jin 20170307 --[
	-- local resPath = "effect/"..nEffectID..".xml"
	-- if not TFFileUtil:existFile(resPath) then
	-- 	return
	-- end

	-- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

	-- local bodyEffect = TFArmature:create(nEffectID.."_anim")
	-- if bodyEffect == nil then
	-- 	return
	-- end

	if not ModelManager:existResourceFile(2, nEffectID) then
		return
	end
	ModelManager:addResourceFromFile(2, nEffectID, 1)
	local bodyEffect = ModelManager:createResource(2, nEffectID)
	if bodyEffect == nil then
		return
	end
	--]--

	local nPosOffsetX = 0
	local nPosOffsetY = 0
	bodyEffect:setPosition(ccp(nPosOffsetX, nPosOffsetY))

	-- modify by jin 20170307 --[
	-- bodyEffect:setAnimationFps(FightManager.fightSpeed * GameConfig.ANIM_FPS)
	ModelManager:setAnimationFps(bodyEffect, self.animSpeed * GameConfig.FPS)
	--]--

	-- bodyEffect:setScale(2)
	if bBehindBody then
		local roleZOrder = self.armature:getZOrder()
		bodyEffect:setZOrder(roleZOrder-1)
		self.bossBehindEffect = bodyEffect
	else
		bodyEffect:setZOrder(200)
		self.bossEffect = bodyEffect
	end
	self.rolePanel:addChild(bodyEffect)

	ModelManager:playWithNameAndIndex(bodyEffect, "", 0, 1, -1, -1)
end

--------------add by wk.dai--------------------
--[[
判断当前角色是否还活着
return 如果角色或者返回true
]]
function FightRole:IsAlive()
	return self.currHp > 0
end

--[[
判断角色是否为有效攻击目标
@return 如果角色为可攻击目标返回true，否则返回false
]]
function FightRole:IsValidTarget()
	if not self:IsAlive() then
		return false
	end

	if self:HaveFrozenBuff() then
		return false
	end

	return true
end


return FightRole
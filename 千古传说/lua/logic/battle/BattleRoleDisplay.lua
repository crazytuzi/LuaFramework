--
-- Author: Zippo
-- Date: 2013-12-05 17:34:00
--

local mapLayer  = require("lua.logic.battle.BattleMapLayer")
local battleRoleMgr  = require("lua.logic.battle.BattleRoleManager")
-- local fightRoundMgr  = require("lua.logic.battle.FightRoundManager")

local BattleRoleDisplay = class("BattleRoleDisplay")

local EFFECT_ZORDER = 100
local FIGHT_TEXT_ZORDER = 300
	
function BattleRoleDisplay:ctor(roleInfo)
	local nPosIndex = roleInfo.posindex
	local bEnemyRole = false
	if nPosIndex >= 9 then
		bEnemyRole = true
	end

	local bNpc = false
	if roleInfo.typeid == 2 then
		bNpc = true
	end

	local roleTableData = nil
	if bNpc then
		roleTableData = NPCData:objectByID(roleInfo.roleId)
	else
		roleTableData = RoleData:objectByID(roleInfo.roleId)
	end

	if roleTableData == nil then
		print("role configure not found : ",roleInfo.typeid,roleInfo.roleId)
	end

	local armatureID = roleTableData.image
	local resPath = "armature/"..armatureID..".xml"
	if TFFileUtil:existFile(resPath) then
		TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
	else
		print(resPath.."not find")
		if bEnemyRole then
			armatureID = 10040
		else
			armatureID = 10006
		end
		TFResourceHelper:instance():addArmatureFromJsonFile("armature/"..armatureID..".xml")
	end

	-- print("load armature : armature/"..armatureID..".xml")

	local armature = TFArmature:create(armatureID.."_anim")
	if armature == nil then
		assert(false, "armature"..armatureID.."create error")
		return
	end

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
	self:setPosition(clone(self.originPos))

	armature:setAnimationFps(FightManager.fightSpeed * GameConfig.ANIM_FPS)

	if bEnemyRole then
		armature:setRotationY(180)
	end

	self.logicInfo = roleInfo
	self.logicInfo.bEnemyRole = bEnemyRole
	self.currHp = roleInfo.maxhp
	self.logicInfo.maxhp = self.logicInfo.attr[1]

	self.passiveSkill = roleInfo.passiveskill or {}

	self.headPath = "icon/head/"..roleTableData.image..".png"

	self.animSpeed = FightManager.fightSpeed

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
		self:AddBossEffect("fight_boss")
	end
end

function BattleRoleDisplay:dispose()
	TFDirector:killAllTween(self.rolePanel)
end


function BattleRoleDisplay:setScale( scale )
	self.rolePanel:setScale(scale)
end
function BattleRoleDisplay:CreateShadowImg()
	local shadowImg = TFImage:create("ui_new/fight/shadow.png")
	shadowImg:setZOrder(-1001)
	shadowImg:setAnchorPoint(ccp(0.5, 0.5))
	self.shadowImg = shadowImg
	self.rolePanel:addChild(shadowImg)
end

function BattleRoleDisplay:CreateHpLabel()
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

	hpBackground:setPosition(ccp(0,180))

	local professionImg = TFImage:create("ui_new/fight/zhiye_"..self.profession..".png")
	if professionImg ~= nil then
		professionImg:setPosition(ccp(-55, 7))
		hpBackground:addChild(professionImg)
	end

	self.rolePanel:addChild(hpBackground)
end

function BattleRoleDisplay:SetHpBarVisible(bVisible)
	if self.hpBackground ~= nil then
		self.hpBackground:setVisible(bVisible)
	end

	self.shadowImg:setVisible(bVisible)
end



function BattleRoleDisplay:AddCommonAnger(num)
	if self:GetBuffByType(16) ~= nil then
		return
	end

	if num == nil or num == 0 then
		return
	end

	battleRoleMgr:AddAnger(self.logicInfo.bEnemyRole, num)
end

function BattleRoleDisplay:setPosition(pos)
	self.rolePanel:setPosition(pos)
end

function BattleRoleDisplay:getPosition()
	return self.rolePanel:getPosition()
end

function BattleRoleDisplay:GetRowIndex()
	local posIndex = self.logicInfo.posindex
	if posIndex >= 9 then
		posIndex = posIndex - 9
	end

	return math.floor(posIndex/3)
end

function BattleRoleDisplay:GetColumnIndex()
	local posIndex = self.logicInfo.posindex
	if posIndex >= 9 then
		posIndex = posIndex - 9
	end

	return posIndex%3
end

function BattleRoleDisplay:OnActionStart()
	if self:IsLive() then
		if self.hitBackTween then
			TFDirector:killTween(self.hitBackTween)
			self.hitBackTween = nil
		end

		--目标原地被反击
		if FightManager:GetCurrAction().actionInfo.type == 2 then
			local targetRole = FightManager:GetCurrAction():GetTargetRole(1)
			if targetRole == self then
				print("target role is myself. return....")
				return
			end
		end

		self:setPosition(clone(self.originPos))
		self:UpdateZOrder()

	end
end
function BattleRoleDisplay:SetSpeed(speed)
	self.animSpeed = speed
	self.armature:setAnimationFps(speed * GameConfig.ANIM_FPS)

	for k,effect in pairs(self.bodyEffectList) do
		if effect ~= nil then
			effect:setAnimationFps(speed * GameConfig.ANIM_FPS)
		end
	end
end

function BattleRoleDisplay:UpdateZOrder()
	local rolePos = self:getPosition()
	self.rolePanel:setZOrder(-rolePos.y)
end

function BattleRoleDisplay:MoveToRole(targetRole, distance, beforeMoveAnim)
	if not targetRole then
		return
	end

	distance = distance or 30

	local targetPos = targetRole:getPosition()
	local targetBoxWidth = targetRole.armature:boundingBox().size.width
	local targetPosX = nil
	if self.logicInfo.bEnemyRole then
		targetPosX = targetPos.x + math.floor(targetBoxWidth/2+distance)
	else
		targetPosX = targetPos.x - math.floor(targetBoxWidth/2+distance)
	end

	local targetPosY = targetPos.y - 1

	if beforeMoveAnim ~= nil and self:HaveAnim(beforeMoveAnim) then
		self.armature:play(beforeMoveAnim, -1, -1, 0)
		if self.bossEffect then
			self.bossEffect:setVisible(false)
		end
		self.armature:addMEListener(TFARMATURE_COMPLETE, 
		function()
			self.armature:removeMEListener(TFARMATURE_COMPLETE)
			self:MoveToPosition(targetPosX, targetPosY)
		end)
	else
		self:MoveToPosition(targetPosX, targetPosY)
	end
end

function BattleRoleDisplay:MoveToPosition(targetPosX, targetPosY)
	self.attackAnimEnd = true

	self.armature:play("move")
	if self.bossEffect then
		self.bossEffect:setVisible(false)
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

function BattleRoleDisplay:OnReachTarget()
	FightManager:GetCurrAction():ShowAttackAnim()
end
function BattleRoleDisplay:isNeedBack()
	local currPos = self:getPosition()
	local eq = (self.originPos.x == currPos.x and self.originPos.y == currPos.y)
	return not eq
end

function BattleRoleDisplay:ReturnBack()
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

	self.armature:play("back")
	if self.bossEffect then
		self.bossEffect:setVisible(false)
	end

	if pathType == 0 then
		local returnBackLine = 
		{
			target = self.rolePanel,
			{
				ease = {type=TFEaseType.EASE_OUT, rate=2},
				duration = 0.3 / FightManager.fightSpeed,
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
				duration = 0.3 / FightManager.fightSpeed,
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
function BattleRoleDisplay:_ReturnBack()
	if self.armature == nil then
		return
	end

	if not self:IsLive() then
		return
	end

	local currPos = self:getPosition()
	local eq = (self.originPos.x == currPos.x and self.originPos.y == currPos.y)
	if eq then
		self:PlayStandAnim()
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

	self.armature:play("back")
	if self.bossEffect then
		self.bossEffect:setVisible(false)
	end

	if pathType == 0 then
		local returnBackLine = 
		{
			target = self.rolePanel,
			{
				ease = {type=TFEaseType.EASE_OUT, rate=2},
				duration = 0.3 / FightManager.fightSpeed,
				x = self.originPos.x,
				y = self.originPos.y,

				onUpdate = function ()
					self:UpdateZOrder()
				end,

				onComplete = function ()
					self:UpdateZOrder()
					self:PlayStandAnim()
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
				duration = 0.3 / FightManager.fightSpeed,
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
				end,
			},
		}
		self.shadowImg:setVisible(false)
		TFDirector:toTween(returnBackBezier)
	end
end

--在自己身上添加特效
function BattleRoleDisplay:AddBodyEffect(nEffectID, bLoop, bBehindBody, nPosOffsetX, nPosOffsetY)
	if self.armature == nil then
		return
	end

	if self.bodyEffectList[nEffectID] ~= nil then
		return
	end

	local resPath = "effect/"..nEffectID..".xml"
	if not TFFileUtil:existFile(resPath) then
		return
	end

	TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

	-- if self.logicInfo.bEnemyRole then
	-- 	GameResourceManager:addEnemyEffect( self.logicInfo.roleId , nEffectID , resPath )
	-- else
	-- 	GameResourceManager:addRoleEffect( self.logicInfo.roleId , nEffectID , resPath )
	-- end

	local bodyEffect = TFArmature:create(nEffectID.."_anim")
	if bodyEffect == nil then
		return
	end

	nPosOffsetX = nPosOffsetX or 0
	nPosOffsetY = nPosOffsetY or 0
	bodyEffect:setPosition(ccp(nPosOffsetX, nPosOffsetY))

	bodyEffect:setAnimationFps(GameConfig.ANIM_FPS)
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

	if #moveList <= 1 then
		if bLoop then
			bodyEffect:playByIndex(0, -1, -1, 1)
		else
			bodyEffect:playByIndex(0, -1, -1, 0)
			bodyEffect:addMEListener(TFARMATURE_COMPLETE,
			function()
				bodyEffect:removeMEListener(TFARMATURE_COMPLETE) 
				self:RemoveBodyEffect(nEffectID)
			end)
		end
	else
		bodyEffect:playByIndex(0, -1, -1, 0)
		bodyEffect:addMEListener(TFARMATURE_COMPLETE,
			function()
				bodyEffect:removeMEListener(TFARMATURE_COMPLETE) 
				bodyEffect:playByIndex(1, -1, -1, 1)
			end)
	end

	self.bodyEffectList[nEffectID] = bodyEffect
end

function BattleRoleDisplay:RemoveBodyEffect(nEffectID)
	local effect = self.bodyEffectList[nEffectID]
	if effect ~= nil then
		self.rolePanel:removeChild(effect)
		self.bodyEffectList[nEffectID] = nil
	end
end

function BattleRoleDisplay:RemoveAllBodyEffect(nEffectID)
	for k,effect in pairs(self.bodyEffectList) do
		if effect ~= nil then
			self.rolePanel:removeChild(effect)
		end
	end
	self.bodyEffectList = {}
end

function BattleRoleDisplay:PlaySkillEffect(nEffectID, effectType, nPosOffsetX, nPosOffsetY, effectScale ,targetRole, flyEffRotate)
	if self.armature == nil then
		return
	end

	local resPath = "effect/"..nEffectID..".xml"
	if not TFFileUtil:existFile(resPath) then
		return
	end

	TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

	

	local skillEff = TFArmature:create(nEffectID.."_anim")
	if skillEff == nil then
		return
	end

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
	if effectType == 1 or effectType == 8 then
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
	end

	effPosY = effPosY + nPosOffsetY
	if not self.logicInfo.bEnemyRole then
		effPosX = effPosX + nPosOffsetX
	else
		effPosX = effPosX - nPosOffsetX
	end

	skillEff:setPosition(ccp(effPosX, effPosY))

	skillEff:setAnimationFps(self.animSpeed * GameConfig.ANIM_FPS)

	if self.logicInfo.bEnemyRole then
		skillEff:setRotationY(180)
	end

	if effectScale == nil then
		effectScale = 1
	end
	skillEff:setScale(effectScale)

	if effectType == 0 then
		self.rolePanel:addChild(skillEff)
	elseif effectType == 5 then
		skillEff:setZOrder(-1000)
		self.rolePanel:addChild(skillEff)
	elseif effectType == 6 or effectType == 7 then
		skillEff:setZOrder(-1000)
		battleRoleMgr.roleLayer:addChild(skillEff)
	elseif effectType == 8 or effectType == 9 or effectType == 10 then
		skillEff:setZOrder(EFFECT_ZORDER)
		battleRoleMgr.roleLayer:addChild(skillEff)
	else
		local roleZOrder = self.armature:getZOrder()
		skillEff:setZOrder(EFFECT_ZORDER + roleZOrder)
		battleRoleMgr.roleLayer:addChild(skillEff)
	end

	if effectType == 0 or effectType == 1 or effectType == 2 or effectType == 5 or effectType == 6 or effectType == 7 or effectType == 8 or effectType == 9 or effectType == 10 then
		skillEff:playByIndex(0, -1, -1, 0)
		skillEff:addMEListener(TFARMATURE_COMPLETE,
		function()
			skillEff:removeMEListener(TFARMATURE_COMPLETE)
			if effectType == 0 then
				self.rolePanel:removeChild(skillEff)
			else
				battleRoleMgr.roleLayer:removeChild(skillEff)
			end
		end)
	else -- 飞行特效 循环播放
		skillEff:playByIndex(0, -1, -1, 1)
		self:MoveSkillEffect(skillEff, effectType, targetRole, flyEffRotate)
	end
end

function BattleRoleDisplay:PlayTextEffect(text, pos)
	if self.armature == nil then
		return
	end

	local resPath = "effect/"..text..".xml"
	if not TFFileUtil:existFile(resPath) then
		return
	end

	TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

	
	local textEff = TFArmature:create(text.."_anim")
	if textEff == nil then
		assert(false, "effect/"..text..".xml not find")
		return
	end

	if self.logicInfo.bEnemyRole then
		GameResourceManager:addEnemyEffect( self.logicInfo.roleId , text , textEff )
	else
		GameResourceManager:addRoleEffect( self.logicInfo.roleId , text , textEff )
	end


	local roleZOrder = self.armature:getZOrder()
	textEff:setZOrder(FIGHT_TEXT_ZORDER)

	textEff:setPosition(pos)

	textEff:setAnimationFps(FightManager.fightSpeed * GameConfig.ANIM_FPS)

	textEff:playByIndex(0)

	TFDirector:currentScene().fightUiLayer.ui:addChild(textEff)
	textEff:addMEListener(TFARMATURE_COMPLETE,
	function() 
		textEff:removeMEListener(TFARMATURE_COMPLETE)
		TFDirector:currentScene().fightUiLayer.ui:removeChild(textEff)
	end)
end

function BattleRoleDisplay:PlaySkillNameEffect()
	if self.armature == nil then
		return
	end

	TFResourceHelper:instance():addArmatureFromJsonFile("effect/light.xml")

	local lightEff = TFArmature:create("light_anim")
	if lightEff == nil then
		return
	end

	lightEff:setZOrder(EFFECT_ZORDER + 102)

	local rolePos = self:getPosition()
	local effPosX = rolePos.x
	local effPosY = rolePos.y
	lightEff:setPosition(ccp(effPosX, effPosY-50))

	lightEff:setAnimationFps(FightManager.fightSpeed * GameConfig.ANIM_FPS)

	lightEff:playByIndex(0)

	battleRoleMgr.roleLayer:addChild(lightEff)
	lightEff:addMEListener(TFARMATURE_COMPLETE,
	function() 
		lightEff:removeMEListener(TFARMATURE_COMPLETE)
		battleRoleMgr.roleLayer:removeChild(lightEff)
		if FightManager:GetCurrAction() then
			FightManager:GetCurrAction():BeginAttack()
		end
	end)
end

function BattleRoleDisplay:IsSameRow(targetRole)
	if math.abs(self.originPos.y - targetRole.originPos.y) < 10 then
		return true
	else
		return false
	end
end

function BattleRoleDisplay:MoveSkillEffect(skillEffect, effectType, targetRole, flyEffRotate)
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

			onComplete = function ()
				battleRoleMgr.roleLayer:removeChild(skillEffect)
			end,
		},
	}

	TFDirector:toTween(movePath)
end

function BattleRoleDisplay:HaveAnim(animName)
	animName = animName..";"
	local movNames = self.armature:getMovementNameStrings()
	movNames = movNames..";"
	if string.find(movNames, animName) then
		return true
	else
		return false
	end
end

function BattleRoleDisplay:PlayAttackAnim(bNormalAttack, animName)
	if self.armature == nil then
		return
	end

	local currAction = FightManager:GetCurrAction()
	if currAction.skillDisplayInfo.attackAnimMove then
		self:SetHpBarVisible(false)
	end

	if self.logicInfo.bEnemyRole == false and currAction.actionInfo.skill and currAction.actionInfo.skill[1].skillId > 0 and currAction.skillDisplayInfo.remote == 0 then
		TFDirector:currentScene():ZoomIn(self)
	end

	self.attackAnimEnd = false
	self.needReturnBack = false

	if animName ~= nil and self:HaveAnim(animName) then
		self.armature:play(animName, -1, -1, 0)
		if self.bossEffect then
			self.bossEffect:setVisible(false)
		end
	else
		if bNormalAttack then
			self.armature:play("attack", -1, -1, 0)
			if self.bossEffect then
				self.bossEffect:setVisible(false)
			end
		else
			self.armature:play("skill", -1, -1, 0)
			if self.bossEffect then
				self.bossEffect:setVisible(false)
			end
		end
	end

	self.armature:addMEListener(TFARMATURE_COMPLETE, function()
		self.armature:removeMEListener(TFARMATURE_COMPLETE)
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
end

function BattleRoleDisplay:PlayStandAnim()
	if self.armature == nil then
		return
	end

	self.attackAnimEnd = true

	self.armature:play("stand", -1, -1, 1)
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffer = self.buffList:objectAt(i)
		if buffer.bValid and buffer.config.stand_display and buffer.config.stand_display ~= "" then
			self.armature:play(buffer.config.stand_display, -1, -1, 1)
		end
	end
	if self.bossEffect then
		self.bossEffect:setVisible(true)
	end

	if self:HaveForbidAttackBuff() then
		self.armature:stop()
	end

	self.armature:removeMEListener(TFARMATURE_COMPLETE)
end

function BattleRoleDisplay:PlayHitAnim(bLastHit)
	if self.armature == nil then
		return
	end 

	self.attackAnimEnd = true

	self.armature:play("hit", -1, -1, 0)

	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffer = self.buffList:objectAt(i)
		if buffer.bValid and buffer.config.behit_display and buffer.config.behit_display ~= "" then
			self.armature:play(buffer.config.behit_display, -1, -1, 0)
		end
	end


	if self.bossEffect then
		self.bossEffect:setVisible(false)
	end

	if bLastHit then
		self:DoHitBackAction()
	end

	self.armature:setColor(ccc3(100, 0, 0))

	self.armature:addMEListener(TFARMATURE_COMPLETE, function() 
		self.armature:removeMEListener(TFARMATURE_COMPLETE)
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
end

function BattleRoleDisplay:DoHitBackAction()
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

function BattleRoleDisplay:DoAvoidAction()
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

function BattleRoleDisplay:Die()
	if self.armature == nil then
		return
	end
	battleRoleMgr:refreshMaxHp()
	TFDirector:currentScene().fightUiLayer:OnFightRoleDie(self)

	self:RemoveAllBuff()

	self:RemoveAllBodyEffect()

	local currAction = FightManager:GetCurrAction()
	if currAction ~= nil and currAction.bEnemyAllDie and self.logicInfo.bEnemyRole then
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

function BattleRoleDisplay:PlayDieBezier()
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
			end,
		},
	}
	self:SetHpBarVisible()
	TFDirector:toTween(dieBezier)
end

function BattleRoleDisplay:ReLive(reliveHp)
	-- if self.haveRelive then
	-- 	return false
	-- end

	self:RemoveAllBuff()

	-- self.haveRelive = true
	self:AddBodyEffect("fuhuo", false)
	self:ShowEffectName("fuhuo")
	self:SetHp(reliveHp)

	TFDirector:currentScene().fightUiLayer:OnFightRoleReLive(self)
	return true
end

function BattleRoleDisplay:CreateDamageNumFont(text, number)
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

function BattleRoleDisplay:CreateAngerNumFont(angerNum)
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

function BattleRoleDisplay:SetHp(currHp, bTestDie)
	self.currHp = currHp
	self.currHp = math.max(self.currHp, 0)
	self.currHp = math.min(self.currHp, self.logicInfo.maxhp)


	if self.hpLabel ~= nil then
		self.hpLabel:setPercent(self.currHp*100 / self.logicInfo.maxhp)
	end

	if bTestDie == nil then
		bTestDie = true
	end

	if bTestDie and self.currHp <= 0 then
		self:Die()
	end


end


function BattleRoleDisplay:ShowFightText(text, number, bAngerNum, bTestDie, bBezier)
	if self.armature == nil then
		return
	end

	if FightManager.fightBeginInfo.bSkillShowFight then
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
function BattleRoleDisplay:GetBuffByType(buffType)
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffer = self.buffList:objectAt(i)
		if buffer.bValid and buffer.config.type == buffType then
			return buffer
		end
	end
	return nil
end

function BattleRoleDisplay:HaveForbidAttackBuff()
	local forbidAttackBuff = {12, 13, 14, 15}
	for i=1,#forbidAttackBuff do
		if self:GetBuffByType(forbidAttackBuff[i]) ~= nil then
			return true
		end
	end
	return false
end

function BattleRoleDisplay:HaveForbidBackAttackBuff()
	local forbidAttackBuff = {12, 13, 14}
	for i=1,#forbidAttackBuff do
		if self:GetBuffByType(forbidAttackBuff[i]) ~= nil then
			return true
		end
	end
	return false
end

function BattleRoleDisplay:HaveForbidManualSkillBuff()
	local forbidSkillBuff = {10, 11, 12, 13, 14, 15}
	for i=1,#forbidSkillBuff do
		if self:GetBuffByType(forbidSkillBuff[i]) ~= nil then
			return true
		end
	end
	return false
end

function BattleRoleDisplay:TestReleaseManualSkill()
	if self:HaveForbidManualSkillBuff() then
		TFDirector:currentScene().fightUiLayer:ForbidSkill(self, true)
	else
		TFDirector:currentScene().fightUiLayer:ForbidSkill(self, false)
	end
end


function BattleRoleDisplay:AddBuff(buffID, level , hurt)
	local config =  SkillLevelData:getBuffInfo(buffID,level)
	if config == nil then
		assert(false, buffID..":buffer not find")
		return
	end

	if config.is_repeat == 0 then
		self:RemoveBuffByType(config.type)
	end

	local buffInfo = {}
	buffInfo.config = config
	buffInfo.lastNum = 0
	buffInfo.bValid = true
	buffInfo.hurt = hurt

	self.buffList:pushBack(buffInfo)

	self:AddBuffIcon(buffID, config.icon_id)

	if config.effect_loop == 1 then
		self:AddBodyEffect(config.effect_id, true)
	else
		self:AddBodyEffect(config.effect_id, false)
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
end

function BattleRoleDisplay:AddBuffIcon(buffId, iconId)
	local iconImg = TFImage:create("icon/buffer/"..iconId..".png")
	if iconImg ~= nil and self.bufferIconList[buffId] == nil and self.hpBackground ~= nil then
		self.hpBackground:addChild(iconImg)
		self.bufferIconList[buffId] = iconImg
		self:SetBuffIconPos()
	end
end

function BattleRoleDisplay:SetBuffIconPos()
	local iconNum = 0
	for k,bufferIcon in pairs(self.bufferIconList) do
		if bufferIcon ~= nil then
			iconNum = iconNum + 1
			bufferIcon:setPosition(ccp(24*iconNum-50, 22))
		end
	end
end

function BattleRoleDisplay:ShowBufferName(buffType)
	local nameImg = TFImage:create("icon/buffer/name_"..buffType..".png")
	if nameImg ~= nil then
		self:MoveNameImage(nameImg)
	end
end

function BattleRoleDisplay:ShowEffectName(name)
	local nameImg = TFImage:create("icon/effect/"..name..".png")
	if nameImg ~= nil then
		self:MoveNameImage(nameImg)
	end
end

function BattleRoleDisplay:MoveNameImage(nameImg)
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

function BattleRoleDisplay:HaveBuff(buffId)
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid and buffInfo.config.id == buffId then 
			return true
		end
	end

	return false
end

function BattleRoleDisplay:HaveFrozenBuff()
	return self:GetBuffByType(14) ~= nil
end

--斗转星移buff
function BattleRoleDisplay:HaveDzxyBuff()
	return self:GetBuffByType(27) ~= nil
end
--斗转星移buff
function BattleRoleDisplay:canTriggerDzxy()
	print("self.stateAttr",self.stateAttr)
	if self.stateAttr and self.stateAttr[27] ~= nil then
		return false
	end
	return true
end

function BattleRoleDisplay:HaveBadBuff()
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid and buffInfo.config.good_buff == 0 then 
			return true
		end
	end

	return false
end

function BattleRoleDisplay:RemoveFrozenBuff()
	self:RemoveBuffByType(14)
end

function BattleRoleDisplay:RemoveBuffIcon(buffId)
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

function BattleRoleDisplay:RemoveBuffByIndex(buffIndex)
	local buffInfo = self.buffList:objectAt(buffIndex)
	if buffInfo.bValid then
		buffInfo.bValid = false
		self:RemoveBodyEffect(buffInfo.config.effect_id)
		self:RemoveBuffIcon(buffInfo.config.id)
	end

	if not self:HaveForbidAttackBuff() then
		self.armature:resume()
	end

	self:TestReleaseManualSkill()
end

function BattleRoleDisplay:RemoveBuffByType(bufferType)
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid and buffInfo.config.type == bufferType then 
			self:RemoveBuffByIndex(i)
		end
	end
end
function BattleRoleDisplay:RemoveBuffById(bufferid)
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid and buffInfo.config.id == bufferid then 
			self:RemoveBuffByIndex(i)
		end
	end
end

function BattleRoleDisplay:RemoveAllBuff()
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buffInfo = self.buffList:objectAt(i)
		if buffInfo.bValid then 
			self:RemoveBuffByIndex(i)
		end
	end
end

function BattleRoleDisplay:CleanBuff(attackerRole)
	self:AddBodyEffect("jinghua", false)
	local cleanGood = true
	if battleRoleMgr:IsSameSide({attackerRole, self}) then
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

function BattleRoleDisplay:OnRoundChange()
	
end

function BattleRoleDisplay:OnActionEnd()
	

end

function BattleRoleDisplay:ShowHpChangeBuff(stateCycleEffect)
	-- self:ShowFightText("", stateCycleEffect.effectValue)
	local buffInfo = SkillBufferData:objectByID(stateCycleEffect.stateId)
	if buffInfo == nil then
		return stateCycleEffect.effectValue
	end
	if buffInfo.type == 1 then
		self:ShowBufferName(1)
		print(self.logicInfo.name.."中毒扣血："..stateCycleEffect.effectValue.."当前血量："..self.currHp)
	elseif buffInfo.type == 2 then
		self:ShowBufferName(2)
		print(self.logicInfo.name.."灼烧扣血："..stateCycleEffect.effectValue.."当前血量："..self.currHp)
	elseif buffInfo.type == 50 then
		self:ShowBufferName(50)
		print(self.logicInfo.name.."流血扣血："..stateCycleEffect.effectValue.."当前血量："..self.currHp)
	end
	return stateCycleEffect.effectValue
end


--在自己身上添加特效
function BattleRoleDisplay:AddBossEffect(nEffectID)
	if self.armature == nil then
		return
	end
	if self.logicInfo.isboss  ==nil or self.logicInfo.isboss ~= true then
		return
	end

	if self.bossEffect ~= nil then
		return
	end

	local resPath = "effect/"..nEffectID..".xml"
	if not TFFileUtil:existFile(resPath) then
		return
	end

	TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

	local bodyEffect = TFArmature:create(nEffectID.."_anim")
	if bodyEffect == nil then
		return
	end

	local nPosOffsetX = 0
	local nPosOffsetY = 0
	bodyEffect:setPosition(ccp(nPosOffsetX, nPosOffsetY))

	bodyEffect:setAnimationFps(FightManager.fightSpeed * GameConfig.ANIM_FPS)
	-- bodyEffect:setScale(2)
	if bBehindBody then
		local roleZOrder = self.armature:getZOrder()
		bodyEffect:setZOrder(roleZOrder-1)
	else
		bodyEffect:setZOrder(200)
	end
	self.rolePanel:addChild(bodyEffect)
	bodyEffect:playByIndex(0, -1, -1, 1)
	self.bossEffect = bodyEffect
end

--------------add by wk.dai--------------------
--[[
判断当前角色是否还活着
return 如果角色或者返回true
]]
function BattleRoleDisplay:IsAlive()
	return self.currHp > 0
end


function BattleRoleDisplay:IsLive()
	return self.currHp > 0
end
--[[
判断角色是否为有效攻击目标
@return 如果角色为可攻击目标返回true，否则返回false
]]
function BattleRoleDisplay:IsValidTarget()
	if not self:IsAlive() then
		return false
	end

	if self:HaveFrozenBuff() then
		return false
	end

	return true
end


function BattleRoleDisplay:CreateHalo()
	self.haloAttr = {}

	local passiveSkillNum = #self.passiveSkill
	for i=1,passiveSkillNum do
		local skillInfo = SkillLevelData:objectByID(self.passiveSkill[i])
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.passiveSkill[i])
		if skillInfo ~= nil and skillBaseInfo ~= nil then
			if skillBaseInfo.type == 5 or skillBaseInfo.type == 6 then
				self:AddBodyEffect(50, true, true)
				self.haloType = skillBaseInfo.type
				for i=1,17 do
					self.haloAttr[i] = self.haloAttr[i] or 0
					if skillInfo.attr_add[i+17] ~= nil and i <= EnumAttributeType.PoisonResistance then
						self.haloAttr[i] = math.floor(self.haloAttr[i] * skillInfo.attr_add[i+17] / 100)
					end

					if skillInfo.attr_add[i] ~= nil then
						self.haloAttr[i] = self.haloAttr[i] + skillInfo.attr_add[i]
					end
				end
				if skillInfo.attr_add[EnumAttributeType.BonusHealing] ~= nil then
					self.haloAttr[EnumAttributeType.BonusHealing] = self.haloAttr[EnumAttributeType.BonusHealing] or 0
					self.haloAttr[EnumAttributeType.BonusHealing] = self.haloAttr[EnumAttributeType.BonusHealing] + skillInfo.attr_add[EnumAttributeType.BonusHealing]
				end
			end
		end
	end
end


function BattleRoleDisplay:GetAttrNum(attrIndex)
	local attrNum = self.logicInfo.attr[attrIndex]
	if attrNum == nil then
		return 0
	end

	attrNum = attrNum + battleRoleMgr:GetTotalHaloAttrAdd(self.logicInfo.bEnemyRole, attrIndex)
	attrNum = math.max(0, attrNum)

	local percent = 0
	local bufferNum = self.buffList:length()
	for i=1,bufferNum do
		local buff = self.buffList:objectAt(i)
		if buff.bValid and buff.config.attr_change ~= "0" and buff.config.attr_change ~= "" then
			local valueInfo = GetAttrByString(buff.config.attr_change)

			if valueInfo[17+attrIndex] ~= nil then
				percent = valueInfo[17+attrIndex] + percent
			end

			if valueInfo[attrIndex] ~= nil then
				attrNum = attrNum + valueInfo[attrIndex]
			end
		end
	end

	attrNum = attrNum + math.floor(attrNum * percent / 100)

	if self.passiveSkillAttrAdd ~= nil then
		local valueInfo = self.passiveSkillAttrAdd--GetAttrByString(self.passiveSkillAttrAdd)
		if valueInfo[17+attrIndex] ~= nil then
			attrNum = attrNum + math.floor(attrNum * valueInfo[17+attrIndex] / 100)
		end

		if valueInfo[attrIndex] ~= nil then
			attrNum = attrNum + valueInfo[attrIndex]
		end
	end

	attrNum = math.max(0, attrNum)
	return attrNum
end

function BattleRoleDisplay:TestDieBuff()
	if self:GetBuffByType(25) ~= nil and self:GetBuffByType(26) ~= nil then
	  	self:SetHp(0)
	end
end

return BattleRoleDisplay
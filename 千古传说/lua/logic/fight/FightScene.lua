--
-- Author: Zippo
-- Date: 2013-12-03 12:11:16
--
local fightAI = require("lua.logic.fight.FightAI")

local FightScene = class("FightScene", BaseScene)

function FightScene:ctor(...)
	self.super.ctor(self, ...)
end

function FightScene:onEnter()
	me.ArmatureDataManager:removeUnusedArmatureInfo()
	CCDirector:sharedDirector():purgeCachedData()
	if FightManager.fightBeginInfo and FightManager.fightBeginInfo.bGuideFight == true then
		self:createFightLayer()
		return
	end
	if self.loadingLayer == nil then
		self.loadingLayer = require("lua.logic.main.FightLoadingLayer"):new()
		self.loadingLayer:setZOrder(200)
		self.loadingLayer.toScene = TFDirector:currentScene()
		self:addLayer(self.loadingLayer)
		-- AlertManager:show()
	end
	if FightManager.fightBeginInfo == nil then
		return
	end
	local length = #FightManager.fightBeginInfo.rolelist
	local index = 1
	self.loadingLayer:setData(math.ceil(1500/length+1),length+1,function ()
			self:removeLayer(self.loadingLayer,true)
			self.loadingLayer = nil
			self:createFightLayer()
			PlayerGuideManager:doGuide()
	end,function ()
		if index > length then
			return
		end
		self:creatRoleAnimal(FightManager.fightBeginInfo.rolelist[index])
		index = index + 1
	end)
end

function FightScene:creatRoleAnimal(roleInfo)
	if roleInfo == nil then
		return
	end
	local bEnemyRole = false
	if roleInfo.posindex >= 9 then
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

	-- modify by jin 20170307 --[
	-- local resPath = "armature/"..armatureID..".xml"
	-- if TFFileUtil:existFile(resPath) then
	-- 	TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
	-- else
	-- 	print(resPath.."not find")
	-- 	if bEnemyRole then
	-- 		armatureID = 10040
	-- 	else
	-- 		armatureID = 10006
	-- 	end
	-- 	TFResourceHelper:instance():addArmatureFromJsonFile("armature/"..armatureID..".xml")
	-- end
	-- local armature = TFArmature:create(armatureID.."_anim")
	-- if armature == nil then
	-- 	assert(false, "armature"..armatureID.."create error")
	-- 	return
	-- end
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

	if bEnemyRole then
		GameResourceManager:addEnemy( roleInfo.roleId , armature )
	else
		GameResourceManager:addRole( roleInfo.roleId , armature )
	end
	if self.loadingLayer then
		self.loadingLayer:addChild(armature)
	end
	self:creatRoleSkillEffect(roleTableData,{skillId = 0,level = 0},bEnemyRole)
	if roleInfo.spellId then
		self:creatRoleSkillEffect(roleTableData,roleInfo.spellId,bEnemyRole)
	end
	if roleInfo.passiveskill then
		for k,v in pairs(roleInfo.passiveskill) do
			self:creatRoleSkillEffect(roleTableData,v,bEnemyRole)
		end
	end
end

function FightScene:creatRoleSkillEffect(roleTableData,skillid,bEnemyRole)
	local skillDisplayID = 0
	local bNormalAttack = false
	if skillid.skillId == 0 then -- 普通攻击
		skillDisplayID = roleTableData.normal_attack
		bNormalAttack = true
	end

	local skillInfo = BaseDataManager:GetSkillBaseInfo(skillid)
	if skillInfo ~= nil then
		skillDisplayID = skillInfo.display_id
	end

	local skillDisplayInfo = SkillDisplayData:objectByID(skillDisplayID)
	if skillDisplayInfo == nil then
		local armatureID = roleTableData.image
		if bNormalAttack then
			skillDisplayInfo = SkillDisplayData:objectByID(armatureID-10000)
		else
			skillDisplayInfo = SkillDisplayData:objectByID((armatureID-10000)*100+1)
		end

		if skillDisplayInfo == nil then
			skillDisplayInfo = SkillDisplayData:objectByID(9999)
		end
	end

	local xuliEffID = skillDisplayInfo.xuliEff
	if xuliEffID ~= nil and xuliEffID ~= 0 then
		self:creatSKillEffectByID( xuliEffID ,roleTableData.id ,bEnemyRole )
	end
	local attackEff_list = skillDisplayInfo.attackEff
	if attackEff_list ~= nil and #attackEff_list ~= 0 then
		for k,v in pairs(attackEff_list) do
			self:creatSKillEffectByID( v ,roleTableData.id ,bEnemyRole )
		end
	end
	local hitEff_list = skillDisplayInfo.hitEff
	if hitEff_list ~= nil and #hitEff_list ~= 0 then
		for k,v in pairs(hitEff_list) do
			self:creatSKillEffectByID( v ,roleTableData.id ,bEnemyRole )
		end
	end
end

function FightScene:creatSKillEffectByID( nEffectID ,roleId,bEnemyRole )
	-- modify by jin 20170307 --[
	-- local resPath = "effect/"..nEffectID..".xml"
	-- if not TFFileUtil:existFile(resPath) then
	-- 	return
	-- end
	-- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
	-- local skillEff = TFArmature:create(nEffectID.."_anim")
	if not ModelManager:existResourceFile(2, nEffectID) then
		return
	end
	ModelManager:addResourceFromFile(2, nEffectID, 1)
	local skillEff = ModelManager:createResource(2, nEffectID)
	--]--

	if skillEff == nil then
		return
	end

	if bEnemyRole then
		GameResourceManager:addEnemyEffect(roleId , nEffectID , skillEff )
	else
		GameResourceManager:addRoleEffect(roleId , nEffectID , skillEff )
	end
	if self.loadingLayer then
		self.loadingLayer:addChild(skillEff)
	end
end


function FightScene:createFightLayer()
	if self.mapLayer == nil then
		self.mapLayer  = require("lua.logic.fight.MapLayer"):new()
		self.roleLayer = require("lua.logic.fight.RoleLayer"):new()
		self.fightUiLayer = require("lua.logic.fight.FightUiLayer"):new()
		-- self.fightPauseLayer = require("lua.logic.fight.fightPauseLayer"):new()

		self.roleLayer:setZOrder(100)
		self.mapLayer:addChild(self.roleLayer)
		self:addLayer(self.mapLayer)
		self.fightUiLayer.logic = self
		self:addLayer(self.fightUiLayer)
		-- self:addLayer(self.fightPauseLayer)
		self:addPauseLayer()
		self.fightPauseLayer:setVisible(false)
		self.fightPauseLayer.logic = self
	end

	if FightManager:NeedShowText(true) then 
		local beginTextShowEndCallBack = function(event)
			if FightManager.fightBeginInfo and FightManager.fightBeginInfo.index then
				TFDirector:currentScene():PlayBeginMoreEffect(FightManager.fightBeginInfo.index)
			else
				TFDirector:currentScene():PlayBeginEffect()
			end
			-- TFDirector:currentScene():PlayBgMusic()
			TFDirector:removeMEGlobalListener("MissionTipLayer.EVENT_SHOW_BEGINTIP_COM")
			PlayerGuideManager:doGuide()
		end
		TFDirector:removeMEGlobalListener("MissionTipLayer.EVENT_SHOW_BEGINTIP_COM")
		TFDirector:addMEGlobalListener("MissionTipLayer.EVENT_SHOW_BEGINTIP_COM",  beginTextShowEndCallBack)
		self:PlayBgMusic()
		if FightManager.fightBeginInfo.bGuideFight then
			local guideInfo = PlayerGuideManager:GetGuideFightInfo()
			MissionManager:showBeginTipForMission(guideInfo.mission_id)
		else
			if FightManager.fightBeginInfo.fighttype == 1 then
				MissionManager:showBeginTip()
			elseif FightManager.fightBeginInfo.fighttype == 17 then
				FactionManager:showTip(11)
			end
		end
    else
		self.timerID = TFDirector:addTimer(100, 1, nil, 
		function() 
			if FightManager.fightBeginInfo.bSkillShowFight then
				FightManager:OnEnterFightScene()
			else
				if FightManager.fightBeginInfo and FightManager.fightBeginInfo.index then
					self:PlayBeginMoreEffect(FightManager.fightBeginInfo.index)
				else
					self:PlayBeginEffect()
				end
				-- self:PlayBeginEffect()
				self:PlayBgMusic()
			end
			TFDirector:removeTimer(self.timerID)
			self.timerID = nil
		end)
	end
end

function FightScene:PlayBgMusic()
	local fightType = FightManager.fightBeginInfo.fighttype
	if fightType == 1 then
		local currMissionID = MissionManager.attackMissionId
		if MissionManager.missionList ~= nil then
			local missionInfo = MissionManager.missionList:objectByID(currMissionID)
			if missionInfo ~= nil and missionInfo.type ~= MissionManager.TYPE_COMMON then
				TFAudio.playMusic("sound/bgmusic/fight_boss.mp3", true)
			else
				TFAudio.playMusic("sound/bgmusic/fight.mp3", true)
			end
		end
	else
		TFAudio.playMusic("sound/bgmusic/fight.mp3", true)
	end
end

function FightScene:PlayBeginEffect()
	TFAudio.playEffect("sound/effect/fight_begin.mp3", false)

	-- TFResourceHelper:instance():addArmatureFromJsonFile("effect/fightbegin.xml")
	-- local fightBeginEff = TFArmature:create("fightbegin_anim")
	-- fightBeginEff:setAnimationFps(GameConfig.ANIM_FPS)
	-- fightBeginEff:playByIndex(0, -1, -1, 0)
	ModelManager:addResourceFromFile(2, "fightbegin", 1)
	local fightBeginEff = ModelManager:createResource(2, "fightbegin")
	ModelManager:playWithNameAndIndex(fightBeginEff, "", 0, 0, -1, -1)
	-- fightBeginEff:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2+100))
	fightBeginEff:setPosition(ccp(0, 0))

	-- fightBeginEff:addMEListener(TFARMATURE_COMPLETE,
	-- function() 
	-- 	fightBeginEff:removeFromParent()
	-- 	FightManager:OnEnterFightScene()
	-- end)
	ModelManager:addListener(fightBeginEff, "ANIMATION_COMPLETE", function() 
		ModelManager:removeListener(fightBeginEff, "ANIMATION_COMPLETE")
		fightBeginEff:removeFromParent()
		FightManager:OnEnterFightScene()
	end)

	self:addChild(fightBeginEff)
	fightAI:Start()
end

function FightScene:PlayBeginMoreEffect(index)
	TFAudio.playEffect("sound/effect/fight_begin.mp3", false)

	TFResourceHelper:instance():addArmatureFromJsonFile("effect/fight_begin_more.xml")
	local fightBeginEff = TFArmature:create("fight_begin_more_anim")
	fightBeginEff:setAnimationFps(GameConfig.ANIM_FPS)
	fightBeginEff:playByIndex(index - 1, -1, -1, 0)
	fightBeginEff:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2+100))

	fightBeginEff:addMEListener(TFARMATURE_COMPLETE,
	function() 
		fightBeginEff:removeFromParent()
		FightManager:OnEnterFightScene()
	end)

	self:addChild(fightBeginEff)
	fightAI:Start()
end

function FightScene:clickPause( ... )
	-- FightManager:pause()
	-- fightAI:pause()
end

function FightScene:ZoomIn(attackRole)
	local zoomScale = 1.3
	local attackRolePos = attackRole:getPosition()

	local moveX = (attackRolePos.x - GameConfig.WS.width/2 + 300) * zoomScale
	local moveY = (attackRolePos.y - GameConfig.WS.height/2 + 125) * zoomScale
	moveX = math.max(0, moveX)
	moveY = math.max(0, moveY)

	moveX = math.min((zoomScale-1)*GameConfig.WS.width, moveX)

	self.mapLayer:ZoomIn(zoomScale, -moveX, -moveY)
end

function FightScene:ZoomOut()
	self.mapLayer:ZoomOut()
end

function FightScene:onExit()
	-- TFAudio.stopMusic()
	self.super.onExit(self)
	if self.timerID then
		TFDirector:removeTimer(self.timerID)
		self.timerID = nil
	end
end

function FightScene:addPauseLayer( ... )
	local blockUI = TFPanel:create();
	blockUI:setSize(GameConfig.WS);
	blockUI:setTouchEnabled(true); 

	blockUI:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID);
	blockUI:setBackGroundColorOpacity(200);
	blockUI:setBackGroundColor(ccc3(  0,   0,   0));
	self:addLayer(blockUI);
	self.fightPauseLayer= blockUI
	local fightPauseLayer = require("lua.logic.fight.fightPauseLayer"):new()
	fightPauseLayer.logic = self
	blockUI:addChild(fightPauseLayer)
end

return FightScene
--
-- Author: Zippo
-- Date: 2013-12-03 12:15:12
--

local fightRoundMgr  = require("lua.logic.fight.FightRoundManager")
local fightRoleMgr  = require("lua.logic.fight.FightRoleManager")
local tFightConditionFunctions  = require("lua.logic.fight.FightTriggerFunction")



local tTriggerCondition = {
	[2]	 = tFightConditionFunctions.getRoundComplete,									--回合数
	[3]	 = tFightConditionFunctions.getLiveNum,								--存活数
	[5]	 = tFightConditionFunctions.getHpPercent,								--血上限
	[6]	 = tFightConditionFunctions.getUseSKillNum,								--技能个数
}


local FightUiLayer = class("FightUiLayer", BaseLayer)

function FightUiLayer:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.fight.FightUiLayer")
    self:CreateSkillNamePanel()
end

function FightUiLayer:initUI(ui)
	self.super.initUI(self,ui)
	self.ui = ui

	self.breakBtn = TFDirector:getChildByPath(ui, 'breakBtn')
	self.stopBtn = TFDirector:getChildByPath(ui, 'Btn_stop')
	self.stopBtn.logic = self
	self.roleListBg = TFDirector:getChildByPath(ui, 'roleListBg')

	self.roundNumLable = TFDirector:getChildByPath(ui, 'roundNumber')
	self:SetCurrRoundNum(1)

	self.speedBtn = TFDirector:getChildByPath(ui, 'speedBtn')
	if FightManager.fightSpeed == 1 then
		self.speedBtn:setTextureNormal("ui_new/fight/speedbtn.png")
	else
		self.speedBtn:setTextureNormal("ui_new/fight/speedbtn_h.png")
	end
	self.autoBtn = TFDirector:getChildByPath(ui, 'autoBtn')
	if not FightManager.isAutoFight then
		self.autoBtn:setTextureNormal("ui_new/fight/autobtn.png")
	else
		self.autoBtn:setTextureNormal("ui_new/fight/autobtn_h.png")
	end
	if FightManager.isReplayFight then
		self.autoBtn:setVisible(false)
	end

	self.chatBtn = TFDirector:getChildByPath(ui, 'chatBtn')
	self.chatBtn:setVisible(false)

	self.roleListBg = TFDirector:getChildByPath(ui, 'roleListBg')
	self.panel_conditions = TFDirector:getChildByPath(ui, 'Panel_Content')

	self.orderIcon = {}

	self.skillLoadingBar = {}
	self.roleIcon = {}

	local roleList = fightRoleMgr:GetAllLiveRole(false)
	local function sortFun(role1, role2)
		local cardRole1 = CardRoleManager:getRoleById(role1.logicInfo.roleId)
		local cardRole2 = CardRoleManager:getRoleById(role2.logicInfo.roleId)
		if cardRole1 == nil or cardRole2 == nil then
			return true
		end

		if cardRole1.quality > cardRole2.quality then
			return false
		elseif cardRole1.quality == cardRole2.quality then
			if cardRole1.id < cardRole2.id then
	        	return false
		    else
		        return true
		    end
		else
			return true
		end
	end
	roleList:sort(sortFun)

	for i=1,7 do
		local roleSkillPanel = TFDirector:getChildByPath(ui, 'roleskill'..i)
		if roleSkillPanel == nil then
			break
		end

		if FightManager.isReplayFight or FightManager.fightBeginInfo.bSkillShowFight then
			roleSkillPanel:setVisible(false)
		end

		local fightRole = roleList:objectAt(i)
		if fightRole == nil then
			roleSkillPanel:setVisible(false)
		else
			local angerNum = TFDirector:getChildByPath(roleSkillPanel, 'angerLabel')
			angerNum:setText(fightRole:GetSkillAnger())

			self.roleIcon[i] = TFDirector:getChildByPath(roleSkillPanel, 'roleicon')

			-- local rolePanel = roleIcon:getParent()
			-- local pos = rolePanel:getPosition()

			self.roleIcon[i].pos_y = roleSkillPanel:getPositionY()

			local bNpc = false
			if fightRole.logicInfo.typeid == 2 then
				bNpc = true
			end
			local cardRole = nil
			local quality = 1
			if bNpc then
				local npcInstance = NPCData:objectByID(fightRole.logicInfo.roleId)
				cardRole = RoleData:objectByID(npcInstance.role_id)
				quality = cardRole.quality
			else
				cardRole = RoleData:objectByID(fightRole.logicInfo.roleId)
				quality = cardRole.quality
				if fightRole.logicInfo.roleId == MainPlayer.profession then
					quality = CardRoleManager:getRoleById(MainPlayer.profession).quality
				end
			end
			if cardRole ~= nil then
				roleSkillPanel:setTexture("ui_new/fight/roleBg"..quality..".png")
				-- -- 根据武学等级显示
				-- local cardRoleTmp = CardRoleManager:getRoleById(cardRole.id)
				-- local martialLevel = 1
				-- if cardRoleTmp then
				-- 	martialLevel = cardRoleTmp.martialLevel
				-- 	roleSkillPanel:setTexture(GetFightRoleBgByWuXueLevel(martialLevel))
				-- end

				self.roleIcon[i]:setRotationY(180)
				self.roleIcon[i]:setTexture(cardRole:getIconPath())
				self.roleIcon[i].needAnger = fightRole:GetSkillAnger()
				self.roleIcon[i].fightRole = fightRole
				self.roleIcon[i]:setTouchEnabled(true)
				self.roleIcon[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(function() self:roleIconClickHandle(self.roleIcon[i], i) end))

				local professionImg = TFImage:create("ui_new/fight/zhiye_"..cardRole.outline..".png")
				if professionImg ~= nil then
					professionImg:setZOrder(10000)
					professionImg:setPosition(ccp(-40, 40))
					roleSkillPanel:addChild(professionImg)
				end
			else
				assert(false)
			end

			self.skillLoadingBar[i] = TFDirector:getChildByPath(roleSkillPanel, 'loadingBar')
			self.skillLoadingBar[i]:setDirection(TFLOADINGBAR_CIRCLE_RIGHT)
			self.skillLoadingBar[i]:setPercent(0)
			self.skillLoadingBar[i]:setVisible(true)
		end
	end

	self.angerLoadingBar = TFDirector:getChildByPath(ui, 'angerLoadingBar')
	self.angerNB = TFDirector:getChildByPath(ui, 'angerNB')
	local currPercent = math.floor(100*fightRoleMgr.selfAnger/fightRoleMgr.fullAnger)
	self.angerLoadingBar:setPercent(currPercent)
	self.angerNB:setText(fightRoleMgr.selfAnger)

	self.angerBarBg = TFDirector:getChildByPath(ui, 'angerBarBg')
	if FightManager.isReplayFight then
		self.angerBarBg:setVisible(false)
	else
		ModelManager:addResourceFromFile(2, "huo", 1)
		local fireEffect = ModelManager:createResource(2, "huo")


		-- TFResourceHelper:instance():addArmatureFromJsonFile("effect/huo.xml")
		-- local fireEffect = TFArmature:create("huo_anim")
		if fireEffect ~= nil then
			-- fireEffect:setAnimationFps(GameConfig.ANIM_FPS)
			-- fireEffect:playByIndex(0, -1, -1, 1)
			ModelManager:playWithNameAndIndex(fireEffect, "", 0, 1, -1, -1)
			fireEffect:setPosition(ccp(-15, -14))
			-- fireEffect:setScale(0.6)
			self.fireEffect = fireEffect
			self.angerLoadingBar:addChild(fireEffect)
		end
		self:RefreshAngerBar()
	end

	if FightManager.isReplayFight or FightManager.fightBeginInfo.bSkillShowFight then
	else
		self.updateAngerTimerID = TFDirector:addTimer(40, -1, nil, 
		function(time)
			self:UpdateAngerPercent()
			local _tempTime = math.min(100,time*1000)
			self:UpdateCDPercent(_tempTime)
		end)

		self.updateOrderTimerID = TFDirector:addTimer(400, -1, nil, 
		function() 
			self:UpdateOrderIcon()
		end)
	end

	if FightManager.fightBeginInfo.bGuideFight then
		self.autoBtn:setVisible(false)
		self.speedBtn:setVisible(false)
		-- self.chatBtn:setVisible(false)
	end

	if FightManager.fightBeginInfo.bSkillShowFight then
		self.autoBtn:setVisible(false)
		self.speedBtn:setVisible(false)
		-- self.chatBtn:setVisible(false)
		self.roleListBg:setVisible(false)
		self.angerBarBg:setVisible(false)

		self.skillShowReplayBtn = TFDirector:getChildByPath(ui, 'replayBtn')
	    self.skillShowReplayBtn:addMEListener(TFWIDGET_CLICK, 
	    audioClickfun(function()
	        FightManager:ReplaySkillShow()
	        self.skillShowReplayBtn:setVisible(false)
	    end),1)

	    self.skillShowReturnBtn = TFDirector:getChildByPath(ui, 'returnBtn')
	    self.skillShowReturnBtn:addMEListener(TFWIDGET_CLICK, 
	    audioClickfun(function()
	        FightManager:LeaveFight()
	    end),1)
	end
end

function FightUiLayer:registerEvents()	
	self.super.registerEvents(self)

	self.breakBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.breakClickHandle))
	self.stopBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.stopClickHandle))
	self.speedBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.speedBtnClickHandle))
	self.autoBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.autoBtnClickHandle))
	self.chatBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.chatBtnClickHandle),1)

	if FightManager.isReplayFight then
		self.breakBtn:setVisible(true)
		self.breakBtn:setPosition(self.autoBtn:getPosition())
	else
		--self.ui:setTouchEnabled(true)
		--self.ui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.uiClickHandle))
	end

	if FightManager:isNeedPause() then
		self.stopBtn:setVisible(true)
	else
		self.stopBtn:setVisible(false)
	end

	if FightManager.fightBeginInfo.fighttype == 16 then
		self.panel_conditions:setVisible(true)
		self:showConditionInfo()
		self.conditionsTimer = TFDirector:addTimer(1000,-1,nil,function ()
			self:showConditionInfo()
		end)
	else
		self.panel_conditions:setVisible(false)
	end

	self.reConnectCallBack = 
	function(event)
	 	FightManager:OnReConnect()
	end
	TFDirector:addMEGlobalListener(MainPlayer.RE_CONNECT_COMPLETE,  self.reConnectCallBack)
end

function FightUiLayer:showConditionInfo()
	local floorOptionNow = NorthClimbManager:getNowFloorOption()
	local index = 1
	for i=1,2 do
		local img_di = TFDirector:getChildByPath(self.panel_conditions, "img_di"..index)
		if floorOptionNow[i] == nil then
			-- img_di:setVisible(false)
		else
			local battleInfo = BattleLimitedData:objectByID(floorOptionNow[i])
			if battleInfo.isshow ~= 0 then
				local txt_neirong = TFDirector:getChildByPath(img_di, "txt_neirong")
				local img_gantan = TFDirector:getChildByPath(img_di, "img_gantan")
				img_di:setVisible(true)
				txt_neirong:setText(battleInfo:getDescribe())
				img_gantan:setVisible(false)
				local show_state = false
				if battleInfo.isshow == 1 then
					show_state = not TFFunction.call(tTriggerCondition[battleInfo.type], nil, battleInfo)
					img_gantan:setTexture("ui_new/fight/img_gantan.png")
				elseif battleInfo.isshow == 2 then
					show_state = not TFFunction.call(tTriggerCondition[battleInfo.type], nil, battleInfo)
					img_gantan:setTexture("ui_new/fight/img_x.png")
				end
				if show_state then
					img_gantan:setVisible(true)
				end
				index = index + 1
			end
		end
	end
	for j = index,2 do
		local img_di = TFDirector:getChildByPath(self.panel_conditions, "img_di"..j)
		img_di:setVisible(false)
	end
end

function FightUiLayer:removeUI()
	if self.skillNamePanel ~= nil then
		TFDirector:clearAllTween(self.skillNamePanel)
	end
	TFDirector:removeTimer(self.updateAngerTimerID)
	TFDirector:removeTimer(self.updateOrderTimerID)
	TFDirector:removeMEGlobalListener(MainPlayer.RE_CONNECT_COMPLETE,  self.reConnectCallBack)

	if self.moveTween then
		TFDirector:removeTimer(self.moveTween)
		self.moveTween = nil
	end

	if self.conditionsTimer then
		TFDirector:removeTimer(self.conditionsTimer)
		self.conditionsTimer = nil
	end

	self.super.removeUI(self)

	FightManager:CleanFight()
end

function FightUiLayer.breakClickHandle(btn)
	FightManager:BreakFight()
	btn:setVisible(false)
end
function FightUiLayer.stopClickHandle(btn)
	TFDirector:pause()
	btn.logic.logic.fightPauseLayer:setVisible(true)
end

function FightUiLayer.speedBtnClickHandle(btn)
	local teamLev = MainPlayer:getLevel()
    local openLev = 5
    if teamLev < openLev then
        -- toastMessage("团队等级达到"..openLev.."级开启")

        toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
        return
    end

	FightManager:SwitchDoubleSpeed()

	if FightManager.fightSpeed == 1 then
		btn:setTextureNormal("ui_new/fight/speedbtn.png")
	else
		btn:setTextureNormal("ui_new/fight/speedbtn_h.png")
	end
end

function FightUiLayer.autoBtnClickHandle(btn)
	local vipLev = MainPlayer:getVipLevel()
    local openVipLev = ConstantData:getValue("Mission.AutomaticBattle.VIPLevel")
	local teamLev = MainPlayer:getLevel()
	local openTeamLev = ConstantData:getValue("Mission.AutomaticBattle.Level")
    if vipLev < openVipLev and teamLev < openTeamLev then
		-- toastMessage("VIP等级"..openVipLev.."级或团队等级"..openTeamLev.."级开启")

        toastMessage(stringUtils.format(localizable.fight_FightUiLayer_auto_open, openVipLev, openTeamLev))
		return
    end

	FightManager:SwitchAutoFight()

	if not FightManager.isAutoFight then
		btn:setTextureNormal("ui_new/fight/autobtn.png")
	else
		btn:setTextureNormal("ui_new/fight/autobtn_h.png")
	end
end

function FightUiLayer.chatBtnClickHandle(btn)
	local layer  = require("lua.logic.chat.ChatMainLayer"):new()
	layer.toScene = TFDirector:currentScene()
    AlertManager:addLayer(layer)
    AlertManager:show()
end

function FightUiLayer.uiClickHandle(ui)
	if FightManager.isFighting then
		local breakBtn = TFDirector:getChildByPath(ui, 'breakBtn')
		if breakBtn:isVisible() then
			breakBtn:setVisible(false)
		else
			breakBtn:setVisible(true)
		end
	end
end

function FightUiLayer:SetCurrRoundNum(nCurrRoundNum)
	nCurrRoundNum = math.min(nCurrRoundNum , FightManager.maxRoundNum)
	FightManager.nCurrRoundNum = nCurrRoundNum
	self.roundNumLable:setText(nCurrRoundNum.."/"..FightManager.maxRoundNum)
end

function FightUiLayer:ForbidSkill(fightRole, bForbid)
	local roleNum = #self.roleIcon
	for i=1,roleNum do
		local roleIcon = self.roleIcon[i]
		if roleIcon.fightRole == fightRole then
			local roleSkillPanel = TFDirector:getChildByPath(self.ui, 'roleskill'..i)
			if roleSkillPanel ~= nil then
				local forbidImg = TFDirector:getChildByPath(roleSkillPanel, 'forbidImg')
				forbidImg:setVisible(bForbid)
				roleIcon.forbidSkill = bForbid
				if bForbid then
					self:RemoveClickEffect(roleIcon)
					self:SetRoleSkillEnable(i, false)
				end
				break
			end
		end
	end
end

function FightUiLayer:ReleaseSkillByAI(fightRole)
	local roleNum = #self.roleIcon
	for i=1,roleNum do
		local roleIcon = self.roleIcon[i]
		if roleIcon.fightRole == fightRole then
			self:SetRoleSkillEnable(i, false)
			self:AddClickEffect(roleIcon)
			return
		end
	end
end

function FightUiLayer:roleIconClickHandle(roleIcon, clickRoleIndex)
	if FightManager.isReplayFight then
		return
	end

	if roleIcon.forbidSkill then
		return
	end

	if roleIcon.clickEffect ~= nil then
		return
	end

	if not self:IsHightLightEffVisible(clickRoleIndex) then
		return
	end

	if fightRoundMgr:AddManualAction(roleIcon.fightRole, true) then
		self:SetRoleSkillEnable(clickRoleIndex, false)
		self:AddClickEffect(roleIcon)
	end
end

function FightUiLayer:AddClickEffect(roleIcon)
	if roleIcon.clickEffect ~= nil then
		return
	end

	TFResourceHelper:instance():addArmatureFromJsonFile("effect/skillclick.xml")
	local clickEffect = TFArmature:create("skillclick_anim")
	if clickEffect == nil then
		return
	end

	clickEffect:setZOrder(1000)
	clickEffect:setAnimationFps(GameConfig.ANIM_FPS)
	clickEffect:playByIndex(0, -1, -1, 1)
	clickEffect:setPosition(ccp(67, 67))
	clickEffect:setScale(1.25)
	clickEffect:setRotationY(180)
	roleIcon.clickEffect = clickEffect

	roleIcon:addChild(clickEffect)
end

function FightUiLayer:RemoveClickEffect(roleIcon)
	if roleIcon.clickEffect ~= nil then
		roleIcon.clickEffect:removeFromParent()
		roleIcon.clickEffect = nil
	end
end

function FightUiLayer:AddAngerEffect(angerEffect)
	-- TFResourceHelper:instance():addArmatureFromJsonFile("effect/angereff.xml")
	-- local effect = TFArmature:create("angereff_anim")
	-- if effect == nil then
	-- 	return
	-- end

	-- effect:setZOrder(100)
	-- effect:setAnimationFps(GameConfig.ANIM_FPS)
	-- effect:playByIndex(angerEffect, -1, -1, 0)
	-- effect:setPosition(ccp(450, 0))

	-- if angerEffect == 1 then
	-- 	self.angerLoadingBar:setTexture("ui_new/fight/anger1.png")
	-- else
	-- 	self.angerLoadingBar:setTexture("ui_new/fight/anger2.png")
	-- end

	-- effect:addMEListener(TFARMATURE_COMPLETE, function()
	-- 	self.angerLoadingBar:setTexture("ui_new/fight/anger.png")
	-- end)

	-- self.angerBarBg:addChild(effect)
end

function FightUiLayer:GetSkillIndex(rolePos)
	local roleNum = #self.roleIcon
	for i=1,roleNum do
		local roleIcon = self.roleIcon[i]
		if roleIcon.fightRole ~= nil and roleIcon.fightRole.logicInfo.posindex == rolePos then
			return i
		end
	end

	return nil
end

function FightUiLayer:OnExecuteManualAction(rolePos)
	local skillIndex = self:GetSkillIndex(rolePos)
	if skillIndex == nil then
		assert(false)
		return
	end

	self:SetRoleSkillEnable(skillIndex, false)

	local roleIcon = self.roleIcon[skillIndex]
	self:RemoveClickEffect(roleIcon)
end

function FightUiLayer:UpdateCDPercent(updateTime)
	local roleNum = #self.roleIcon
	for i=1,roleNum do
		local fightRole = self.roleIcon[i].fightRole
		if fightRole.skillCD > 0 then
			fightRole.skillCD = fightRole.skillCD - updateTime * FightManager.fightSpeed
			if fightRole.skillCD < 0 then
				fightRole.skillCD = 0
			end

			local totalCD = fightRole:GetSkillCD()
			self.skillLoadingBar[i]:setPercent(fightRole.skillCD/totalCD*100)

			if fightRole.skillCD <= 0 then
				if fightRoleMgr.selfAnger >= self.roleIcon[i].needAnger then
					self:SetRoleSkillEnable(i, true)
				else
					self:SetRoleSkillEnable(i, false)
				end
			end
		end
	end
end

function FightUiLayer:SetHightLightEffVisible(index, bVisible)
	local roleSkillPanel = TFDirector:getChildByPath(self.ui, 'roleskill'..index)
	if roleSkillPanel == nil then
		return
	end

	if bVisible then
		if roleSkillPanel.highlightEff == nil then
			TFResourceHelper:instance():addArmatureFromJsonFile("effect/skillhighlight.xml")
			local highlightEff = TFArmature:create("skillhighlight_anim")
			if highlightEff == nil then
				return
			end
			highlightEff:setZOrder(-1)
			highlightEff:setAnimationFps(GameConfig.ANIM_FPS)
			highlightEff:playByIndex(0, -1, -1, 1)
			highlightEff:setPosition(ccp(55, 55))
			roleSkillPanel.highlightEff = highlightEff
			roleSkillPanel:addChild(highlightEff)

			TFResourceHelper:instance():addArmatureFromJsonFile("effect/skillready.xml")
			local readyEffect = TFArmature:create("skillready_anim")
			if readyEffect == nil then
				return
			end
			readyEffect:setZOrder(1000)
			readyEffect:setAnimationFps(GameConfig.ANIM_FPS)
			readyEffect:playByIndex(0, -1, -1, 0)
			readyEffect:setPosition(ccp(55, 55))
			roleSkillPanel.readyEffect = readyEffect
			roleSkillPanel:addChild(readyEffect)
		end
	else
		if roleSkillPanel.highlightEff ~= nil then
			roleSkillPanel.highlightEff:removeFromParent()
			roleSkillPanel.highlightEff = nil
		end

		if roleSkillPanel.readyEffect ~= nil then
			roleSkillPanel.readyEffect:removeFromParent()
			roleSkillPanel.readyEffect = nil
		end
	end
end

function FightUiLayer:IsHightLightEffVisible(index)
	local roleSkillPanel = TFDirector:getChildByPath(self.ui, 'roleskill'..index)
	if roleSkillPanel ~= nil and roleSkillPanel.highlightEff ~= nil then
		return true
	else
		return false
	end
end

function FightUiLayer:MoveSkillIconUp(roleIcon, bMoveUp)
	if bMoveUp and roleIcon.bMoveUp ~= true then
		roleIcon.bMoveUp = true
		local rolePanel = roleIcon:getParent()
		local pos = rolePanel:getPosition()
		TFDirector:killAllTween(rolePanel)
		local moveTween = 
		{
			target = rolePanel,
			{
				duration = 0.3,
				x = pos.x,
				y = roleIcon.pos_y+10,
			},
		}
		TFDirector:toTween(moveTween)

	elseif bMoveUp == false and roleIcon.bMoveUp then
		roleIcon.bMoveUp = false
		local rolePanel = roleIcon:getParent()
		local pos = rolePanel:getPosition()
		TFDirector:killAllTween(rolePanel)
		local moveTween = 
		{
			target = rolePanel,
			{
				duration = 0.3,
				x = pos.x,
				y = roleIcon.pos_y,
			},
		}
		TFDirector:toTween(moveTween)
	end
end

function FightUiLayer:SetGuideRoleSkillEnable(index)
	local roleIcon = self.roleIcon[index]
	if roleIcon ~= nil then
		self:SetHightLightEffVisible(index, true)
		self:MoveSkillIconUp(roleIcon, true)
	end
end

function FightUiLayer:SetRoleSkillEnable(index, bEnable)
	local roleIcon = self.roleIcon[index]

	if bEnable then
		if roleIcon.clickEffect ~= nil then
			return
		end
		if roleIcon.forbidSkill then
			return
		end
		if FightManager.fightBeginInfo.bGuideFight then
			return
		end 
		if self:IsHightLightEffVisible(index) then
			return
		end
	end

	local roleSkillPanel = TFDirector:getChildByPath(self.ui, 'roleskill'..index)
	if roleIcon ~= nil then
		if bEnable and roleIcon.fightRole:IsLive() then
			self:SetHightLightEffVisible(index, true)
			self:MoveSkillIconUp(roleIcon, true)
		else
			self:SetHightLightEffVisible(index, false)
			self:MoveSkillIconUp(roleIcon, false)
		end
	end
end

function FightUiLayer:OnFightRoleDie(fightRole)
	local roleNum = #self.roleIcon
	for i=1,roleNum do
		local roleIcon = self.roleIcon[i]
		if roleIcon.fightRole == fightRole then
			local roleSkillPanel = TFDirector:getChildByPath(self.ui, 'roleskill'..i)
			roleSkillPanel:setGrayEnabled(true)
			self:RemoveClickEffect(roleIcon)
			self:SetRoleSkillEnable(i, false)
			self.skillLoadingBar[i]:setVisible(false)
			break
		end
	end
end

function FightUiLayer:OnFightRoleReLive(fightRole)
	local roleNum = #self.roleIcon
	for i=1,roleNum do
		local roleIcon = self.roleIcon[i]
		if roleIcon.fightRole == fightRole then
			local roleSkillPanel = TFDirector:getChildByPath(self.ui, 'roleskill'..i)
			roleSkillPanel:setGrayEnabled(false)
			self.skillLoadingBar[i]:setVisible(true)
			break
		end
	end
end

function FightUiLayer:UpdateAngerPercent()
	local currNum = tonumber(self.angerNB:getText())
	local endNum = fightRoleMgr.selfAnger

	local currPercent = self.angerLoadingBar:getPercent()

	if endNum > currNum then
		currNum = currNum + 5
	elseif endNum < currNum then
		currNum = currNum - 10
	end

	self.angerLoadingBar:setPercent(100*currNum/fightRoleMgr.fullAnger)
	self.angerNB:setText(currNum)
	-- local endPercent = math.floor(100*fightRoleMgr.selfAnger/fightRoleMgr.fullAnger)
	-- if endPercent > currPercent then
	-- 	self.angerLoadingBar:setPercent(currPercent + 1)
	-- elseif endPercent < currPercent then
	-- 	self.angerLoadingBar:setPercent(currPercent - 5)
	-- end

	-- self.angerNB:setText(self.angerLoadingBar:getPercent()*fightRoleMgr.fullAnger/100)

	local width = self.angerLoadingBar:getSize().width
	local posX = math.floor(width * currPercent / 100) - width/2 + 5
	-- self.fireEffect:setPosition(ccp(posX, 35))
end

function FightUiLayer:RefreshAngerBar()
	local roleNum = #self.roleIcon
	for i=1,roleNum do
		local roleIcon = self.roleIcon[i]
		if roleIcon.fightRole.skillCD <= 0 then
			if fightRoleMgr.selfAnger >= roleIcon.needAnger then
				self:SetRoleSkillEnable(i, true)
			else
				self:SetRoleSkillEnable(i, false)
			end
		else
			self:SetRoleSkillEnable(i, false)
		end

		local roleSkillPanel = TFDirector:getChildByPath(self.ui, 'roleskill'..i)
		local angerNumLabel = TFDirector:getChildByPath(roleSkillPanel, 'angerLabel')
		if fightRoleMgr.selfAnger >= roleIcon.needAnger then
			angerNumLabel:setFntFile("font/num_25y.fnt")
		else
			angerNumLabel:setFntFile("font/num_25.fnt")
		end
	end
end

function FightUiLayer:GetOrderIndex(fightRole, orderList)
	for i=1,#orderList do
		if fightRole == orderList[i] then
			return i
		end
	end

	return 0
end

function FightUiLayer:UpdateOrderIcon()
	if fightRoundMgr.nCurrRoundIndex == 0 then
		return
	end
	
	local orderList = fightRoundMgr:GetAttackOrder()

	for i=1,5 do
		local iconInfo = self.orderIcon[i]
		if iconInfo ~= nil then
			iconInfo.bNeedRemove = true
		end
	end

	for i=1,#orderList do
		self:MoveAttackIcon(orderList[i], i)
	end

	for i=1,5 do
		local iconInfo = self.orderIcon[i]
		if iconInfo ~= nil and iconInfo.bNeedRemove then
			iconInfo.attackIcon:removeFromParent()
			self.orderIcon[i] = nil
		end
	end
end

function FightUiLayer:MoveAttackIcon(orderInfo, orderIndex)
	local attackIconInfo = self:GetAttackIcon(orderInfo)
	if attackIconInfo == nil then
		local attackIcon = self:CreateAttackIcon(orderInfo.fightRole, orderInfo.bManualAction)
		local attackIconPos = self:GetIconPos(orderIndex)
		if orderInfo.bManualAction then
			local rolePos = orderInfo.fightRole:getPosition()
			attackIcon:setPosition(ccp(rolePos.x, rolePos.y+100))
		else
			attackIcon:setPosition(ccp(attackIconPos.x, attackIconPos.y-30))
		end

		local moveTween = 
		{
			target = attackIcon,
			{
				duration = 0.3,
				x = attackIconPos.x,
				y = attackIconPos.y,

				onComplete = function ()
					for i=1,5 do
						local iconInfo = self.orderIcon[i]
						if iconInfo == nil then
							self.orderIcon[i] = {}
							self.orderIcon[i].fightRole = orderInfo.fightRole
							self.orderIcon[i].bManualAction = orderInfo.bManualAction
							self.orderIcon[i].attackIcon = attackIcon
							self.orderIcon[i].orderIndex = orderIndex
							break
						end
					end	
				end
			},
		}
		TFDirector:toTween(moveTween)
	else
		attackIconInfo.bNeedRemove = false
		if attackIconInfo.orderIndex ~= orderIndex then
			local attackIcon = attackIconInfo.attackIcon
			local attackIconPos = self:GetIconPos(orderIndex)
			local moveTween = 
			{
				target = attackIcon,
				{
					duration = 0.3,
					x = attackIconPos.x,
					y = attackIconPos.y,

					onComplete = function ()
						attackIconInfo.orderIndex = orderIndex
					end
				},
			}
			TFDirector:toTween(moveTween)
		end
	end
end

function FightUiLayer:GetAttackIcon(orderInfo)
	for i=1,5 do
		local iconInfo = self.orderIcon[i]
		if iconInfo ~= nil and iconInfo.fightRole == orderInfo.fightRole and 
		   iconInfo.bManualAction == orderInfo.bManualAction then
			return iconInfo
		end
	end
end

function FightUiLayer:CreateAttackIcon(fightRole, bManualAction)
	local headImg = nil
	if fightRole.logicInfo.bEnemyRole then
		headImg = TFImage:create("ui_new/fight/enemyhead.png")
	else
		headImg = TFImage:create("ui_new/fight/head.png")
	end

	local headIcon = TFImage:create(fightRole.headPath)
	if headIcon ~= nil then
		headIcon:setScale(0.28)
		headIcon:setPosition(ccp(0, 3))
		headImg:addChild(headIcon)
	end

	if bManualAction then
		local skillImg = TFImage:create("ui_new/fight/skillicon.png")
		skillImg:setPosition(ccp(0, -38))
		headImg:addChild(skillImg)
	end

	headImg:setZOrder(1000)

	self:addChild(headImg)
	
	fightRole.headImg = headImg

	return headImg
end

function FightUiLayer:GetIconPos(orderIndex)
	local roleListBgPos = self.roleListBg:getPosition()

	local firstPosX = roleListBgPos.x + 450
	if orderIndex >= 1 and orderIndex <= 5 then
		return ccp(firstPosX-(orderIndex-1)*60, roleListBgPos.y + 10)
	end

	return ccp(0, 0)
end

function FightUiLayer:CreateSkillNamePanel()
	local nameBgImg = TFImage:create("ui_new/fight/skillname_bg.png")
	local nameLabel = TFLabelBMFont:create()
	nameLabel:setAnchorPoint(ccp(0.5, 0.5))
	nameLabel:setPosition(ccp(0, 10))
	nameLabel:setFntFile("font/skill.fnt")
	nameBgImg:addChild(nameLabel)
	nameBgImg:setZOrder(1000)
	nameBgImg:setPosition(ccp(GameConfig.WS.width/2 , 500))
	self.ui:addChild(nameBgImg)
	self.skillNamePanel = nameBgImg
	self.skillNameLabel = nameLabel
	self.skillNamePanel:setVisible(false)
end

function FightUiLayer:ShowSkillName(skillName, bEnemy)
	if self.skillNamePanel == nil then
		return
	end

	self.skillNameLabel:setText(skillName)

	if self.moveTween then
		TFDirector:removeTimer(self.moveTween)
		-- TFDirector:killTween(self.moveTween)
		self.moveTween = nil
	end
	-- self.skillNamePanel:setPosition(ccp(GameConfig.WS.width/2 , 500))
	--local 500 = 500
	self.skillNamePanel:setVisible(true)
	-- local endPos = GameConfig.WS.width
	-- if bEnemy then
	-- 	self.skillNamePanel:setPosition(ccp(GameConfig.WS.width, 500))
	-- 	endPos = 0
	-- else
	-- 	self.skillNamePanel:setPosition(ccp(0, 500))
	-- end


	self.moveTween =TFDirector:addTimer(1600, 1, nil, 
		function() 
			self.skillNamePanel:setVisible(false)
		end)

	-- local x_length = (endPos - GameConfig.WS.width/2)/4
	-- local moveTween =
	-- {
	-- 	target = self.skillNamePanel,
	-- 	{
	-- 		duration = 0.2,
	-- 		onComplete = function ()
	-- 			self.skillNamePanel:setPosition(ccp(GameConfig.WS.width/2 , 500))
	-- 		end
	-- 	},
	-- 	{
	-- 		delay = 0.8,
	-- 		duration = 0.2,
	-- 		onComplete = function ()
	-- 			self.skillNamePanel:setPosition(ccp(endPos , 500))
	-- 			self.skillNamePanel:setVisible(false)
	-- 		end
	-- 	},
	-- }
	-- TFDirector:toTween(moveTween)


	-- self.moveTween = moveTween
end

function FightUiLayer:OnSkillShowEnd()
	self.skillShowReplayBtn:setVisible(true)
	self.skillShowReturnBtn:setVisible(true)
end

function FightUiLayer:PlayFightEndEffect()
	if self.ui:getChildByTag(100) ~= nil then
		return
	end

	ModelManager:addResourceFromFile(2, "fightend", 1)
	local fightEndEff = ModelManager:createResource(2, "fightend")
	if fightEndEff == nil then
		return
	end

	fightEndEff:setZOrder(100)
	fightEndEff:setTag(100)
	-- fightEndEff:setAnimationFps(GameConfig.ANIM_FPS)
	-- fightEndEff:playByIndex(0, -1, -1, 0)
	ModelManager:playWithNameAndIndex(fightEndEff, "", 0, 0, -1, -1)
	fightEndEff:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2))

	self.ui:addChild(fightEndEff)
end

function FightUiLayer:PlayOverTimeEffect()
	ModelManager:addResourceFromFile(2, "fightchaoshi", 1)
	local effect = ModelManager:createResource(2, "fightchaoshi")
	if effect == nil then
		return
	end

	effect:setZOrder(100)
	-- effect:setAnimationFps(GameConfig.ANIM_FPS)
	-- effect:playByIndex(0, -1, -1, 0)
	ModelManager:playWithNameAndIndex(effect, "", 0, 0, -1, -1)
	effect:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2))

	self.ui:addChild(effect)

	ModelManager:addListener(effect, "ANIMATION_COMPLETE", function()
		FightManager:EndFight(false)
	end)

	-- effect:addMEListener(TFARMATURE_COMPLETE,
	-- function()
	-- 	FightManager:EndFight(false)
	-- end)
end

return FightUiLayer
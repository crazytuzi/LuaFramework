--
-- Author: Zippo
-- Date: 2013-12-03 12:15:12
--

local battleReplayMgr  = require("lua.logic.battle.BattleReplayManager")
local fightRoleMgr  = require("lua.logic.fight.FightRoleManager")

local BattleUiLayer = class("BattleUiLayer", BaseLayer)

function BattleUiLayer:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.fight.FightUiLayer")
    self:CreateSkillNamePanel()
end

function BattleUiLayer:initUI(ui)
	self.super.initUI(self,ui)
	self.ui = ui

	self.breakBtn = TFDirector:getChildByPath(ui, 'breakBtn')
	self.stopBtn = TFDirector:getChildByPath(ui, 'Btn_stop')
	self.stopBtn:setVisible(false)
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
	self.autoBtn:setVisible(false)

	self.chatBtn = TFDirector:getChildByPath(ui, 'chatBtn')
	self.chatBtn:setVisible(false)


	self.skillPanel = TFDirector:getChildByPath(ui, 'skillPanel')
	self.skillPanel:setVisible(false)

	self.angerBarBg = TFDirector:getChildByPath(ui, 'angerBarBg')
	self.angerBarBg:setVisible(false)

	self.orderIcon = {}

	self.updateOrderTimerID = TFDirector:addTimer(400, -1, nil, 
		function()
			self:UpdateOrderIcon()
		end)

	self.panel_conditions = TFDirector:getChildByPath(ui, 'Panel_Content')
	self.panel_conditions:setVisible(false)
end

function BattleUiLayer:registerEvents()	
	self.super.registerEvents(self)

	self.breakBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.breakClickHandle))
	self.speedBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.speedBtnClickHandle))

	self.breakBtn:setVisible(true)
	self.breakBtn:setPosition(self.autoBtn:getPosition())
	
end

function BattleUiLayer:removeUI()
	TFDirector:removeTimer(self.updateOrderTimerID)

	if self.moveTween then
		TFDirector:removeTimer(self.moveTween)
		self.moveTween = nil
	end

	self.super.removeUI(self)

	FightManager:CleanBattle()
end

function BattleUiLayer.breakClickHandle(btn)
	FightManager:BreakFight()
	btn:setVisible(false)
end

function BattleUiLayer.speedBtnClickHandle(btn)
	local teamLev = MainPlayer:getLevel()
    local openLev = 5
    if teamLev < openLev then
        toastMessage(stringUtils.format(localizable.common_function_openlevel,openLev))
        return
    end

	FightManager:SwitchDoubleSpeed()

	if FightManager.fightSpeed == 1 then
		btn:setTextureNormal("ui_new/fight/speedbtn.png")
	else
		btn:setTextureNormal("ui_new/fight/speedbtn_h.png")
	end
end


function BattleUiLayer.uiClickHandle(ui)
	if FightManager.isFighting then
		local breakBtn = TFDirector:getChildByPath(ui, 'breakBtn')
		if breakBtn:isVisible() then
			breakBtn:setVisible(false)
		else
			breakBtn:setVisible(true)
		end
	end
end

function BattleUiLayer:SetCurrRoundNum(nCurrRoundNum)
	nCurrRoundNum = math.min(nCurrRoundNum , FightManager.maxRoundNum)
	self.roundNumLable:setText(nCurrRoundNum.."/"..FightManager.maxRoundNum)
end

function BattleUiLayer:ForbidSkill(fightRole, bForbid)
	
end

function BattleUiLayer:ReleaseSkillByAI(fightRole)
	
end




function BattleUiLayer:AddAngerEffect(angerEffect)

end


function BattleUiLayer:OnExecuteManualAction(rolePos)

end

function BattleUiLayer:UpdateCDPercent(updateTime)

end

function BattleUiLayer:SetHightLightEffVisible(index, bVisible)
	
end

function BattleUiLayer:IsHightLightEffVisible(index)

end

function BattleUiLayer:MoveSkillIconUp(roleIcon, bMoveUp)

end

function BattleUiLayer:SetGuideRoleSkillEnable(index)

end

function BattleUiLayer:SetRoleSkillEnable(index, bEnable)
end

function BattleUiLayer:OnFightRoleDie(fightRole)
end

function BattleUiLayer:OnFightRoleReLive(fightRole)
end

function BattleUiLayer:UpdateAngerPercent()
end

function BattleUiLayer:RefreshAngerBar()
end

function BattleUiLayer:GetOrderIndex(fightRole, orderList)
	for i=1,#orderList do
		if fightRole == orderList[i] then
			return i
		end
	end

	return 0
end

function BattleUiLayer:UpdateOrderIcon()
	if FightManager:getBattleRoundIndex() == 0 then
		return
	end
	
	local orderList = FightManager:GetAttackOrder()

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

function BattleUiLayer:MoveAttackIcon(orderInfo, orderIndex)
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

function BattleUiLayer:GetAttackIcon(orderInfo)
	for i=1,5 do
		local iconInfo = self.orderIcon[i]
		if iconInfo ~= nil and iconInfo.fightRole == orderInfo.fightRole and 
		   iconInfo.bManualAction == orderInfo.bManualAction then
			return iconInfo
		end
	end
end

function BattleUiLayer:CreateAttackIcon(fightRole, bManualAction)
	local headImg = nil
	if fightRole.logicInfo.bEnemyRole then
		headImg = TFImage:create("ui_new/fight/enemyhead.png")
	else
		headImg = TFImage:create("ui_new/fight/head.png")
	end

	local headIcon = TFImage:create(fightRole.headPath)
	if headIcon ~= nil then
		headIcon:setScale(0.5)
		headIcon:setPosition(ccp(0, -5))
		headImg:addChild(headIcon)
	end

	if bManualAction then
		local skillImg = TFImage:create("ui_new/fight/skillicon.png")
		skillImg:setPosition(ccp(0, 30))
		headImg:addChild(skillImg)
	end

	headImg:setZOrder(1000)

	self:addChild(headImg)
	
	fightRole.headImg = headImg

	return headImg
end

function BattleUiLayer:GetIconPos(orderIndex)
	local roleListBgPos = self.roleListBg:getPosition()

	local firstPosX = roleListBgPos.x + 420
	if orderIndex >= 1 and orderIndex <= 5 then
		return ccp(firstPosX-(orderIndex-1)*60, roleListBgPos.y-30)
	end

	return ccp(0, 0)
end

function BattleUiLayer:CreateSkillNamePanel()
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

function BattleUiLayer:ShowSkillName(skillName, bEnemy)
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

function BattleUiLayer:OnSkillShowEnd()
	self.skillShowReplayBtn:setVisible(true)
	self.skillShowReturnBtn:setVisible(true)
end

function BattleUiLayer:PlayFightEndEffect()
	if self.ui:getChildByTag(100) ~= nil then
		return
	end
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/fightend.xml")
	local fightEndEff = TFArmature:create("fightend_anim")
	if fightEndEff == nil then
		return
	end

	fightEndEff:setZOrder(100)
	fightEndEff:setTag(100)
	fightEndEff:setAnimationFps(GameConfig.ANIM_FPS)
	fightEndEff:playByIndex(0, -1, -1, 0)
	fightEndEff:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2))

	self.ui:addChild(fightEndEff)
end

function BattleUiLayer:PlayOverTimeEffect()
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/fightchaoshi.xml")
	local effect = TFArmature:create("fightchaoshi_anim")
	if effect == nil then
		return
	end

	effect:setZOrder(100)
	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(0, -1, -1, 0)
	effect:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2))

	self.ui:addChild(effect)

	effect:addMEListener(TFARMATURE_COMPLETE,
	function()
		FightManager:EndFight(false)
	end)
end

return BattleUiLayer
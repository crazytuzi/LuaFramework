--
-- Author: Kumo.Wang
-- 宗门红包称号奖励界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogRedpacketAchievementRewardTitle = class("QUIDialogRedpacketAchievementRewardTitle", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")

local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogRedpacketAchievementRewardTitle:ctor(options)
	local ccbFile = "ccb/Dialog_Society_Redpacket_Reward_Title.ccbi"
	local callBacks = {}
	QUIDialogRedpacketAchievementRewardTitle.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true --是否动画显示
    -- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    -- page.topBar:setAllSound(false)

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

    self:_reset()

    local config = options.config
    if config.head_default then
    	local path = remote.redpacket:getHeadTitlePathById(config.head_default)
    	if path then
	    	local sprite = CCSprite:create(path)
	    	if sprite then
	    		self._ccbOwner.node_title_img:addChild(sprite)
	    		self._ccbOwner.node_title_img:setVisible(true)
	    	end
		end
    end
	local index = 1
	local achievePropDic = remote.redpacket:getAchieveDoneAchievementProps(config.type, config.id)
	local keyList = remote.redpacket.unionRedpacketAchievePropKeyDic[config.type]
	for _, key in ipairs(keyList) do
        if achievePropDic[key] then
           	---------- achievePropDic[key] = {name = QActorProp._field[key].name, num = tonumber(config[key])} -----------
            local tfTitle = self._ccbOwner["tf_name_"..index]
			local tfValue = self._ccbOwner["tf_prop_"..index]
			if tfTitle then
				tfTitle:setString(achievePropDic[key].name..":")
				tfTitle:setVisible(true)
			end
			if tfValue then
				local numStr = achievePropDic[key].num
                if achievePropDic[key].isPercent then
                    numStr = (achievePropDic[key].num * 100).."%"
                end
				tfValue:setString("+"..numStr)
				tfValue:setVisible(true)
			end
			index = index + 1
        end
    end
end

function QUIDialogRedpacketAchievementRewardTitle:_reset()
	self._ccbOwner.node_title_img:removeAllChildren()
	local index = 1
	while true do
		local tfName = self._ccbOwner["tf_name_"..index]
		local tfProp = self._ccbOwner["tf_prop_"..index]
		if tfName then
			tfName:setVisible(false)
		end
		if tfProp then
			tfProp:setVisible(false)
		end
		if tfName or tfProp then
			index = index + 1
		else
			break
		end
	end
end

function QUIDialogRedpacketAchievementRewardTitle:viewDidAppear()
	QUIDialogRedpacketAchievementRewardTitle.super.viewDidAppear(self)
end 

function QUIDialogRedpacketAchievementRewardTitle:viewWillDisappear()
	QUIDialogRedpacketAchievementRewardTitle.super.viewWillDisappear(self)
end 

function QUIDialogRedpacketAchievementRewardTitle:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogRedpacketAchievementRewardTitle:_onTriggerClose()
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogRedpacketAchievementRewardTitle:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogRedpacketAchievementRewardTitle

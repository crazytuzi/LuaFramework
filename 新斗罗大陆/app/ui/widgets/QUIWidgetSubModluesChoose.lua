--
-- Kumo.Wang
-- 功能模块——子模块选择界面Cell
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSubModluesChoose = class("QUIWidgetSubModluesChoose", QUIWidget)

local QUIWidgetIconAniTips = import(".widgets.QUIWidgetIconAniTips")

function QUIWidgetSubModluesChoose:ctor(options)
	local ccbFile = "ccb/Widget_SubModules_Choose.ccbi"
  	local callBacks = {}
	QUIWidgetSubModluesChoose.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSubModluesChoose:onEnter()
	QUIWidgetSubModluesChoose.super.onEnter(self)
end

function QUIWidgetSubModluesChoose:onExit()
	QUIWidgetSubModluesChoose.super.onExit(self)
end

function QUIWidgetSubModluesChoose:_reset()
	self._ccbOwner.node_module:removeAllChildren()
	self._ccbOwner.node_fighting_tips:removeAllChildren()
end

function QUIWidgetSubModluesChoose:setInfo(info)
	self.info = info
	if q.isEmpty(self.info) then return end

	local iconClassName = self.info.iconClassName
	if iconClassName then
    	local iconClass = import(app.packageRoot .. ".ui.widgets." .. iconClassName)
    	self.icon = iconClass.new()
    end

    if self.icon then
    	self._ccbOwner.node_module:addChild(self.icon)
    	local size = self.icon:getContentSize()
    	self._ccbOwner.node_module:setPosition(ccp(math.ceil(size.width/2), - math.ceil(size.height/2)))
    	self._ccbOwner.node_fighting_tips:setPosition(ccp(math.ceil(size.width/4), - math.ceil(size.height/4)))
    	self._ccbOwner.btn_click:setPosition(ccp(math.ceil(size.width/2), - math.ceil(size.height/2)))

        -- 这里刀剑和押注不会同时存在
        if self.info.fightTipsFunc and self.info.fightTipsFunc(true) then
            local arenaFightTips = QUIWidgetIconAniTips.new()
            arenaFightTips:setInfo(1, 4, "", "down")
            self._ccbOwner.node_fighting_tips:addChild(arenaFightTips)
        elseif self.info.stakeTipsFunc and self.info.stakeTipsFunc() then
            local arenaStakeTips = QUIWidgetIconAniTips.new()
            arenaStakeTips:setInfo(1, 11, "", "down")
            self._ccbOwner.node_fighting_tips:addChild(arenaStakeTips)
        end

        if self.icon.getRedTipsImg then
            local spRedTips = self.icon:getRedTipsImg()
            if spRedTips then
                if self.info.redTipsFunc then
                    spRedTips:setVisible(self.info.redTipsFunc())
                else
                    spRedTips:setVisible(false)
                end
            end
        end
    end
end

function QUIWidgetSubModluesChoose:getBtnImg()
	if self.icon and self.icon.getBtnImg then
    	return self.icon:getBtnImg()
    end
end

function QUIWidgetSubModluesChoose:getContentSize()
    if self.icon and self.icon.getContentSize then
        return self.icon:getContentSize()
    end
end

function QUIWidgetSubModluesChoose:getInfo()
    return self.info
end

return QUIWidgetSubModluesChoose
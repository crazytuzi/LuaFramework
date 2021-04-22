
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstonesBaseBox = class("QUIWidgetGemstonesBaseBox", QUIWidget)

function QUIWidgetGemstonesBaseBox:ctor(ccbFile, callBacks, options)
	QUIWidgetGemstonesBaseBox.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
end

--设置突破小红点显示
function QUIWidgetGemstonesBaseBox:setBreakTips(b)
end

--设置强化小红点显示
function QUIWidgetGemstonesBaseBox:setStrengthTips(b)
end

--设置信息小红点显示
function QUIWidgetGemstonesBaseBox:setDetailTips(b)
end

--设置升星小红点
function QUIWidgetGemstonesBaseBox:setGradeTips(b)
end

--设置小红点显示
function QUIWidgetGemstonesBaseBox:setTips(b)
end

--设置吸收小红点显示
function QUIWidgetGemstonesBaseBox:setInheritTips(b)
end

--设置融合小红点显示
function QUIWidgetGemstonesBaseBox:setMixTips(b)
end

--设置精炼小红点显示
function QUIWidgetGemstonesBaseBox:setRefineTips(b)
end

--设置宝石信息
function QUIWidgetGemstonesBaseBox:setGemstoneInfo(gemstone)
end

--设置套装光效
function QUIWidgetGemstonesBaseBox:showSuitEffect()
	-- body
end

--根据状态显示
function QUIWidgetGemstonesBaseBox:setState(state)
end

--重置
function QUIWidgetGemstonesBaseBox:resetAll()
end

--设置为外附魂骨边框
function QUIWidgetGemstonesBaseBox:setIsSpar()
end
return QUIWidgetGemstonesBaseBox
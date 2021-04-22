local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEquipmentBaseBox = class("QUIWidgetEquipmentBaseBox", QUIWidget)

function QUIWidgetEquipmentBaseBox:ctor(ccbFile, callBacks, options)
	QUIWidgetEquipmentBaseBox.super.ctor(self, ccbFile, callBacks, options)
end

--设置装备类型
function QUIWidgetEquipmentBaseBox:setType(type)
end

--获取装备类型
function QUIWidgetEquipmentBaseBox:getType()
	return self._type
end

function QUIWidgetEquipmentBaseBox:showEnchantIcon(visible, level)
end

function QUIWidgetEquipmentBaseBox:showStrengthenLevelIcon(state, actorId) 
end

function QUIWidgetEquipmentBaseBox:setStrengthenNode(b)
end

function QUIWidgetEquipmentBaseBox:setEnchantNode(b)
end

--获取装备ID
function QUIWidgetEquipmentBaseBox:getItemId()
end

function QUIWidgetEquipmentBaseBox:setEquipmentInfo(itemInfo, equipInfo)
end

function QUIWidgetEquipmentBaseBox:setColor(index)
end

function QUIWidgetEquipmentBaseBox:showState(isGreen, isComposite)
end

function QUIWidgetEquipmentBaseBox:showDrop(isCanDrop)
end

function QUIWidgetEquipmentBaseBox:setEvolution(breakthrough)
end

--设置是否可以突破
function QUIWidgetEquipmentBaseBox:showCanEvolution(b, isLevel)
end

--设置是否可以觉醒
function QUIWidgetEquipmentBaseBox:showCanEnchant(b)
end

--设置是否可以收集 就是掉落
function QUIWidgetEquipmentBaseBox:showCanDrop(b)
end

--设置是否可以挑战 可以收集 但是未通关
function QUIWidgetEquipmentBaseBox:showCanChallenge(b)
end

--设置是否可以强化
function QUIWidgetEquipmentBaseBox:showCanStrengthen(b)
end

--设置是否解锁
function QUIWidgetEquipmentBaseBox:setIsLock(b)
end

--没有装备
function QUIWidgetEquipmentBaseBox:showNoEquip(b)
end

--设置选中
function QUIWidgetEquipmentBaseBox:setSelect(b)
end

--设置是否显示加号
function QUIWidgetEquipmentBaseBox:setPlus(b)
end

--设置是否动画
function QUIWidgetEquipmentBaseBox:setEffect(b)
end

--设置是否显示可强化动画
function QUIWidgetEquipmentBaseBox:setStrengthenEffect(b)
end

--全部置空
function QUIWidgetEquipmentBaseBox:resetAll()
end

function QUIWidgetEquipmentBaseBox:resetEffect()
end

function QUIWidgetEquipmentBaseBox:onEnter()
end

function QUIWidgetEquipmentBaseBox:unlockHandler(event)
end

function QUIWidgetEquipmentBaseBox:onExit()
end

--显示特效
function QUIWidgetEquipmentBaseBox:playPropEffect(value)
end

function QUIWidgetEquipmentBaseBox:_playPropEffect()
end

function QUIWidgetEquipmentBaseBox:_onTriggerTouch()
end

return QUIWidgetEquipmentBaseBox
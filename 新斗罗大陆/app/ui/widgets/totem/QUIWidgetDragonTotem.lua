
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetDragonTotem = class("QUIWidgetDragonTotem", QUIWidget)

local QActorProp = import("....models.QActorProp")

QUIWidgetDragonTotem.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetDragonTotem:ctor(options)
	local ccbFile = "ccb/Widget_Weever2.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
	QUIWidgetDragonTotem.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetDragonTotem:onEnter()
	QUIWidgetDragonTotem.super.onEnter(self)
    self._itemProxy = cc.EventProxy.new(remote.items)
    self._itemProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, function ()
		self._ccbOwner.node_tip:setVisible(remote.dragonTotem:checkTotemTipsById(self._index))
    end)
end

function QUIWidgetDragonTotem:onExit()
	QUIWidgetDragonTotem.super.onExit(self)
	self._itemProxy:removeAllEventListeners()
end

function QUIWidgetDragonTotem:resetAll()
	-- for i=1,6 do
	-- 	self._ccbOwner["sp"..i]:setVisible(false)
	-- end
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:setVisible(true)
end

function QUIWidgetDragonTotem:setIndex(index)
	self._index = index
	self:resetAll()

	-- self._ccbOwner["sp"..index]:setVisible(true)
	local path = remote.dragonTotem:getDragonIconById(index)
	local sp = CCSprite:create(path)
	if sp then
		self._ccbOwner.node_icon:addChild(sp)
	end
	
	local info = remote.dragonTotem:getDragonInfoById(self._index)
	local gradeLevel = 1
	if info ~= nil then
		gradeLevel = info.grade or 1
	end
	self._ccbOwner.tf_level:setString("Lv."..gradeLevel)
	local config = remote.dragonTotem:getConfigByIdAndLevel(self._index, gradeLevel)
	if config ~= nil then
		self._ccbOwner.tf_name:setString(config.name_dragon_stone)
		local prop = nil
		for _,v in ipairs(QActorProp._uiFields) do
			if config[v.fieldName] ~= nil then
				prop = v
				break
			end
		end
		if prop ~= nil then
			local value = config[prop.fieldName]
			if prop.handlerFun ~= nil then
				value = prop.handlerFun(value)
			end
			self._ccbOwner.tf_prop:setString(prop.name.."+"..value)
		else
			self._ccbOwner.tf_prop:setString("")
		end
	end
	self._ccbOwner.node_tip:setVisible(remote.dragonTotem:checkTotemTipsById(self._index))
end

function QUIWidgetDragonTotem:_onTriggerClick(event)
    app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIWidgetDragonTotem.EVENT_CLICK, index = self._index})
end

return QUIWidgetDragonTotem
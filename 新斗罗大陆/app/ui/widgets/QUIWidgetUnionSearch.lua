--
-- Author: Your Name
-- Date: 2015-07-27 16:43:00
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetUnionSearch = class("QUIWidgetUnionSearch", QUIWidget)

local QUIWidgetUnionBar = import("..widgets.QUIWidgetUnionBar")

QUIWidgetUnionSearch.NO_INPUT_ERROR = "请输入宗门名称或ID"
QUIWidgetUnionSearch.DEFAULT_PROMPT = "请输入宗门名称或ID"

function QUIWidgetUnionSearch:ctor(options)
	local ccbFile = "ccb/Widget_society_union_search.ccbi"
  	local callBacks = {
      {ccbCallbackName = "onTriggerFound", callback = handler(self, QUIWidgetUnionSearch._onTriggerSearch)},
  	}

	QUIWidgetUnionSearch.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	-- add input box
    self._unionName = ui.newEditBox({image = "ui/none.png", listener = handler(self, self.onEdit), size = CCSize(230, 48)})
    self._unionName:setFont(global.font_default, 26)
    self._unionName:setMaxLength(6)
    self._unionName:setPlaceHolder(QUIWidgetUnionSearch.DEFAULT_PROMPT)
    self._ccbOwner.canNotFind:setVisible(false)

    self._ccbOwner.name:addChild(self._unionName)
end

function QUIWidgetUnionSearch:onEdit(event, editbox)
    if event == "began" then

    elseif event == "changed" then

    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
    end
end

function QUIWidgetUnionSearch:_onTriggerSearch(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_found) == false then return end
    if event ~= nil then
        app.sound:playSound("common_common")
    end
	local newName = self._unionName:getText()
	if self:_invalidNames(newName) then
		app.tip:floatTip(QUIWidgetUnionSearch.NO_INPUT_ERROR)
		return
	end

	remote.union:unionSearchRequest(newName, function(data)
		if data.consortia then
      self._ccbOwner.canNotFind:setVisible(false)
      self._ccbOwner.foundUnion:removeAllChildren()
			local foundUnion = QUIWidgetUnionBar.new(data.consortia)
			self._ccbOwner.foundUnion:addChild(foundUnion)
		end
	end,function ( ... )
    -- body
      self._ccbOwner.foundUnion:removeAllChildren()
      self._ccbOwner.canNotFind:setVisible(true)
     

  end)
end

function QUIWidgetUnionSearch:_invalidNames(newName)
	return newName == "" or newName == QUIWidgetUnionSearch.DEFAULT_PROMPT 
end


return QUIWidgetUnionSearch
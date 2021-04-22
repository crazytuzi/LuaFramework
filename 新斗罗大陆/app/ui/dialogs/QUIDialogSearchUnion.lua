-- @Author: liaoxianbo
-- @Date:   2020-09-14 16:30:32
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-24 18:40:17
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSearchUnion = class("QUIDialogSearchUnion", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetUnionBar = import("..widgets.QUIWidgetUnionBar")

QUIDialogSearchUnion.NO_INPUT_ERROR = "请输入宗门名称或ID"
QUIDialogSearchUnion.DEFAULT_PROMPT = "请输入宗门名称或ID"

function QUIDialogSearchUnion:ctor(options)
	local ccbFile = "ccb/Dialog_union_search_new.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSearch", callback = handler(self, self._onTriggerSearch)},	
    }
    QUIDialogSearchUnion.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_found)
	self._ccbOwner.frame_tf_title:setString("查找宗门")
	self._ccbOwner.name:setString("")

    -- self._callBack = options.callBack

    -- self._unionName = ui.newEditBox({image = "ui/none.png", listener = handler(self, self.onEdit), size = CCSize(440, 50)})
    -- self._unionName:setFont(global.font_default, 26)
    -- self._unionName:setMaxLength(6)
    -- self._unionName:setPlaceHolder(QUIDialogSearchUnion.DEFAULT_PROMPT)

    -- self._ccbOwner.name:addChild(self._unionName)

    self._unionName = ui.newEditBox({image = "ui/none.png", listener = handler(self, self.onEdit), size = CCSize(230, 48)})
    self._unionName:setFont(global.font_default, 26)
    self._unionName:setMaxLength(6)
    self._unionName:setPlaceHolder(QUIDialogSearchUnion.DEFAULT_PROMPT)
    self._ccbOwner.canNotFind:setVisible(false)

    self._ccbOwner.name:addChild(self._unionName)

end

function QUIDialogSearchUnion:viewDidAppear()
	QUIDialogSearchUnion.super.viewDidAppear(self)

	self:addBackEvent(false)
end

function QUIDialogSearchUnion:viewWillDisappear()
  	QUIDialogSearchUnion.super.viewWillDisappear(self)

	self:removeBackEvent()
end


function QUIDialogSearchUnion:onEdit(event, editbox)
    if event == "began" then

    elseif event == "changed" then

    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
    end
end

function QUIDialogSearchUnion:_onTriggerSearch(event) 
    if event ~= nil then
        app.sound:playSound("common_common")
    end
	local newName = self._unionName:getText()
	if self:_invalidNames(newName) then
		app.tip:floatTip(QUIDialogSearchUnion.NO_INPUT_ERROR)
		return
	end
	-- print("newName=",newName)
	-- remote.union:unionSearchRequest(newName, function(data)
	-- 	if data.consortia then
	-- 		self._searchData = data.consortia
	-- 		self._searchData.isSearch = true
	-- 	end
	-- 	if self:safeCheck() then
	-- 		self:playEffectOut()
	-- 	end
	-- end,function()
 --    	app.tip:floatTip("未找到对应宗门,请使用宗门名或宗门ID进行查找")
 --  end)
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

function QUIDialogSearchUnion:_invalidNames(newName)
	return newName == "" or newName == QUIDialogSearchUnion.DEFAULT_PROMPT 
end

-- function QUIDialogSearchUnion:_backClickHandler()
--     self:_onTriggerClose()
-- end

function QUIDialogSearchUnion:_onTriggerClose(event)
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSearchUnion:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSearchUnion

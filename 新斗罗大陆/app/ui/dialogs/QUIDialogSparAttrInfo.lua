-- 外骨属性详情界面
-- Author: Qinsiyang
-- 
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSparAttrInfo = class("QUIDialogSparAttrInfo", QUIDialog)

function QUIDialogSparAttrInfo:ctor(options)
	local ccbFile = "ccb/Dialog_Spar_AttrInfo.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSparAttrInfo.super.ctor(self, ccbFile, callBacks, options)
    self._popCurrentDialog = options.popCurrentDialog or true
    self._actorProp = options.actor_prop
	self._subtitle = options.subtitle or "属性详情" 
    self._propDesc = options.propDesc

end

function QUIDialogSparAttrInfo:viewDidAppear()
	QUIDialogSparAttrInfo.super.viewDidAppear(self)
    if self._propDesc then
        self:setInfoOnlyDescProp()
    else
        self:setInfo()
    end
end

function QUIDialogSparAttrInfo:viewWillDisappear()
	QUIDialogSparAttrInfo.super.viewWillDisappear(self)

end

function QUIDialogSparAttrInfo:setInfoOnlyDescProp()
    self._ccbOwner.frame_tf_title:setString(self._subtitle)
    for i=1,8 do
        self._ccbOwner["tf_attr_name_"..i]:setVisible(false)
        self._ccbOwner["tf_attr_num_"..i]:setVisible(false)

        local prop = self._propDesc[i]
        if prop then
            self._ccbOwner["tf_attr_name_"..i]:setVisible(true)
            self._ccbOwner["tf_attr_num_"..i]:setVisible(true)
            self._ccbOwner["tf_attr_name_"..i]:setString(prop.name)
            self._ccbOwner["tf_attr_num_"..i]:setString("+"..prop.value)
        end
    end
end


function QUIDialogSparAttrInfo:setInfo()

    local proplist = remote.spar:setPropInfo(self._actorProp)
    self._ccbOwner.frame_tf_title:setString(self._subtitle)
    for i=1,8 do
        self._ccbOwner["tf_attr_name_"..i]:setVisible(false)
        self._ccbOwner["tf_attr_num_"..i]:setVisible(false)

        local prop = proplist[i]
        if prop then
        	self._ccbOwner["tf_attr_name_"..i]:setVisible(true)
        	self._ccbOwner["tf_attr_num_"..i]:setVisible(true)
        	self._ccbOwner["tf_attr_name_"..i]:setString(prop.name)
        	self._ccbOwner["tf_attr_num_"..i]:setString(prop.value)
        end
    end
end
-- function QUIDialogSparAttrInfo:_onTriggerClose(event)
-- 	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
-- 	if event ~= nil then 
-- 		app.sound:playSound("common_cancel")
-- 	end
--     self:popSelf()
--     if self._backCallback then
--     	self._backCallback()
--     end
-- end

function QUIDialogSparAttrInfo:_backClickHandler()
    app.sound:playSound("common_cancel")
    if self._backCallback then
        self._backCallback()
    end    
    self:playEffectOut()
end

function QUIDialogSparAttrInfo:onTriggerBackHandler()
    self:playEffectOut()
    if self._backCallback then
    	self._backCallback()
    end
end

return QUIDialogSparAttrInfo
-- @Author: liaoxianbo
-- @Date:   2020-02-27 14:47:39
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-07 14:07:16
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritAllOccultProp = class("QUIDialogSoulSpiritAllOccultProp", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIDialogSoulSpiritAllOccultProp:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_allProp.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSoulSpiritAllOccultProp.super.ctor(self, ccbFile, callBacks, options)
    -- self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_close)
	
    if options then
    	self._callBack = options.callBack
    end
    self._ccbOwner.frame_tf_title:setString("魂灵秘术属性")
    local activiteFireNum = remote.soulSpirit:getActiviteFireNum() 
    self._ccbOwner.tf_prop_desc:setString(string.format("当前已经激活了%d魂火",activiteFireNum))

    self:initDataProp()
end
function QUIDialogSoulSpiritAllOccultProp:initDataProp( )
	local soulFirePropList = remote.soulSpirit:getSoulFirePropList()
    self._offsertY = 0
    for i = 1, 16 do
        if soulFirePropList[i] ~= nil then
            self._ccbOwner["tf_occult_prop_name"..i]:setString((soulFirePropList[i].name or ""))
            self._ccbOwner["tf_occult_prop_value"..i]:setString("+"..(soulFirePropList[i].value or "0"))
            if i%2 ~= 0 then
                self._offsertY = self._offsertY + 30
            end
        else
            self._ccbOwner["tf_occult_prop_name"..i]:setString("")
            self._ccbOwner["tf_occult_prop_value"..i]:setString("")
        end
    end
    
    if remote.soulSpirit:getOneTeamTwoSoulSprit() then
    	self._ccbOwner.tf_occult_value1:setString("+1")
    else
        self._ccbOwner.tf_occult_name1:setVisible(false)
    	self._ccbOwner.tf_occult_value1:setString("")
    end

    if remote.soulSpirit:getTwoTeamTwoSoulSprit() then
    	self._ccbOwner.tf_occult_value2:setString("+1")
    else 
        self._ccbOwner.tf_occult_name2:setVisible(false)
        self._ccbOwner.tf_occult_value2:setString("")
    end
    if remote.soulSpirit:getThreeTeamTwoSoulSprit() then
        self._ccbOwner.tf_occult_value3:setString("+1")
    else 
        self._ccbOwner.tf_occult_name3:setVisible(false)
        self._ccbOwner.tf_occult_value3:setString("")
    end

    self._ccbOwner.node_shangzheng:setPositionY(-self._offsertY)
end


function QUIDialogSoulSpiritAllOccultProp:viewDidAppear()
	QUIDialogSoulSpiritAllOccultProp.super.viewDidAppear(self)

	self:addBackEvent(false)
end

function QUIDialogSoulSpiritAllOccultProp:viewWillDisappear()
  	QUIDialogSoulSpiritAllOccultProp.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogSoulSpiritAllOccultProp:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulSpiritAllOccultProp:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulSpiritAllOccultProp:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulSpiritAllOccultProp

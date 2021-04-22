-- @Author: liaoxianbo
-- @Date:   2020-03-01 18:00:06
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-06 23:40:27
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulFireLightSuccess = class("QUIDialogSoulFireLightSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogSoulFireLightSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_SoulFire_dianliang.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
    }
    QUIDialogSoulFireLightSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	app.sound:playSound("task_complete")

    self._treeType = options.treeType
    self._bigPoint = options.bigPoint
    self._childPoint = options.childPoint
    self._callback = options.callback
	self._successTip = options.successTip

    self._isSelected = false
    
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	print("self._treeType,self._bigPoint,self._childPoint",self._treeType,self._bigPoint,self._childPoint)
	self._childSoulFireInfo = db:getChildSoulFireInfo(self._treeType,self._bigPoint,self._childPoint)

	-- self._ccbOwner.tf_mount_name:setString(self._childSoulFireInfo.cell_name)


    self._ccbOwner.tf_name:setString(self._childSoulFireInfo.cell_name)
    self._ccbOwner.tf_name1:setString(self._childSoulFireInfo.cell_name)
    -- self._ccbOwner.tf_name2:setString(self._childSoulFireInfo.cell_name)

    self._ccbOwner.tf_prop:setString(self._childSoulFireInfo.cell_desc or "")

    -- local propDic  = remote.soulSpirit:getPropDicByConfig(self._childSoulFireInfo)
    -- for key, value in pairs(propDic) do
    --     if value > 0 then
    --         local name = QActorProp._field[key].uiName or QActorProp._field[key].name
    --         local isPercent = QActorProp._field[key].isPercent
    --         local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
    --         self._ccbOwner.tf_prop:setString("全队魂灵护佑"..name.."+"..str)
    --         break
    --     end
    -- end

	self._ccbOwner.node_select:setVisible(false)
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())
    self:showSelectState()

	self._playOver = false
	scheduler.performWithDelayGlobal(function ()
		self._playOver = true
	end, 2)
end

function QUIDialogSoulFireLightSuccess:viewDidAppear()
	QUIDialogSoulFireLightSuccess.super.viewDidAppear(self)

	self:addBackEvent(false)
end

function QUIDialogSoulFireLightSuccess:viewWillDisappear()
  	QUIDialogSoulFireLightSuccess.super.viewWillDisappear(self)

	self:removeBackEvent()
end


function QUIDialogSoulFireLightSuccess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not self._isSelected)
end

function QUIDialogSoulFireLightSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogSoulFireLightSuccess:_backClickHandler()
	if self._playOver == true then
		self:playEffectOut()
	end
end

function QUIDialogSoulFireLightSuccess:viewAnimationOutHandler()
	local callback = self._callback

	if self._isSelected then
        app.master:setMasterShowState(self._successTip)
    end

	self:popSelf()

	if callback ~= nil then
		callback()
	end
	
end

return QUIDialogSoulFireLightSuccess

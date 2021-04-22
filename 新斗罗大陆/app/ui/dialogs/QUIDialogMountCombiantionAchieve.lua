-- @Author: xurui
-- @Date:   2016-10-10 16:39:28
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 16:33:57
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountCombiantionAchieve = class("QUIDialogMountCombiantionAchieve", QUIDialog)

local QUIWidgetMountBox = import("..widgets.mount.QUIWidgetMountBox")
local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogMountCombiantionAchieve:ctor(options)
	local ccbFile = "ccb/Dialog_Weapon_baijiejihuo_12.ccbi"
	local callBacks = {}
	QUIDialogMountCombiantionAchieve.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	if options then
		self._combinationInfo = options.combinationInfo
		self._callBack = options.callBack
		self._combniationMount = options.combniationMount
	end
	self._animationIsDone = false
	self:setCombinationInfo()
	
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	scheduler.performWithDelayGlobal(function()
			app.sound:playSound("common_end")
		end, 10/30)	

	scheduler.performWithDelayGlobal(function()
			self._animationIsDone = true
		end, 2+1/3)	
end

function QUIDialogMountCombiantionAchieve:viewDidAppear()
	QUIDialogMountCombiantionAchieve.super.viewDidAppear(self)
end

function QUIDialogMountCombiantionAchieve:viewWillDisappear()
	QUIDialogMountCombiantionAchieve.super.viewWillDisappear(self)
end
function QUIDialogMountCombiantionAchieve:setCombinationInfo()
	self._ccbOwner.tf_name1:setString(self._combinationInfo.name)
	self._ccbOwner.tf_name2:setString(self._combinationInfo.name)
	self._ccbOwner.tf_name3:setString(self._combinationInfo.name)

	local mountIds = string.split(self._combinationInfo.condition, ";")
	local haveNum = 1
	for i = 1, 2 do
		if mountIds[i] then
			self:_createHeroHead(i, tonumber(mountIds[i]))
		else
			self._ccbOwner["node"..i]:setVisible(false)
			self._ccbOwner.sp_plus:setVisible(false)
		end
	end

	local propInfo = self:calculateCombinationProp(self._combinationInfo)
	self._ccbOwner.tf_prop:setString((propInfo[1] or "").."   "..(propInfo[2] or ""))
	self._ccbOwner.tf_prop1:setString((propInfo[3] or "").."   "..(propInfo[4] or ""))
end

function QUIDialogMountCombiantionAchieve:_createHeroHead(index, mountId)
	local heroHead = QUIWidgetMountBox.new()
	local mountInfo = remote.mount:getMountById(mountId)
    heroHead:setMountInfo(mountInfo)

    local heroInfo = db:getCharacterByID(mountId)
	if self._combniationMount == mountId then
		heroHead:setHighlightedSelectState(true)
	end

    self._ccbOwner["node_hero_"..index]:addChild(heroHead)
    self._ccbOwner["hero_name_"..index]:setString(heroInfo.name or "")

    makeNodeCascadeOpacityEnabled(self._ccbOwner["node"..index], true)
    self._ccbOwner["node"..index]:setOpacity(0)

	scheduler.performWithDelayGlobal(function()
			self._ccbOwner["node"..index]:runAction(CCFadeIn:create(1/6))
		end, 17/30)	
end

function QUIDialogMountCombiantionAchieve:calculateCombinationProp(combination)
	local propInfo = {}
	local index = 1
	for name,filed in pairs(QActorProp._field) do
		if combination[name] and combination[name] > 0 then
			local value = combination[name]
			if filed.isPercent then
				value = (value*100).."%"
			end
			propInfo[index] = filed.name.." +"..value
			index = index + 1
		end
	end
	return propInfo
end

function QUIDialogMountCombiantionAchieve:_backClickHandler()
	if not self._animationIsDone then return end

    local callBack = self._callBack
    app:getNavigationManager():popViewController(self:getOptions().layerIndex, QNavigationController.POP_TOP_CONTROLLER)

    if callBack ~= nil then
        callBack()
    end
end

return QUIDialogMountCombiantionAchieve
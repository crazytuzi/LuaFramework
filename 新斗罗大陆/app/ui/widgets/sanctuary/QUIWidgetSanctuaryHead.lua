--
-- zxs
-- 精英赛头像
--

local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSanctuaryHead = class("QUIWidgetSanctuaryHead", QUIWidget)
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")
local QUIViewController = import("....ui.QUIViewController")

function QUIWidgetSanctuaryHead:ctor(options)
	local ccbFile = "ccb/Widget_Sanctuary_head.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetSanctuaryHead.super.ctor(self,ccbFile,callBacks,options)
	self._ccbOwner.sp_bg:setVisible(false)
end

function QUIWidgetSanctuaryHead:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_bg, self._glLayerIndex)
	if self._avatar then
		self._glLayerIndex = self._avatar:initGLLayer(self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_nickname, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_win, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_lose, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_top, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_click, self._glLayerIndex)
	
	return self._glLayerIndex
end

function QUIWidgetSanctuaryHead:resetAll()
	self._ccbOwner.tf_nickname:setVisible(false)
	self._ccbOwner.node_self:setVisible(false)
    self._ccbOwner.node_win:setVisible(false)
    self._ccbOwner.node_lose:setVisible(false)
    self._ccbOwner.node_top:setVisible(false)
    self._ccbOwner.node_headPicture:removeAllChildren()
	makeNodeFromGrayToNormal(self._ccbOwner.node_headPicture)
end

function QUIWidgetSanctuaryHead:setInfo(info, isFail, isClipping)
	self:resetAll()

	self._info = info
	if self._info.fighter == nil then
		return
	end

	self._avatar = QUIWidgetAvatar.new()
	if isClipping then
		self._avatar:setSpecialInfo(info.fighter.avatar)
	else
		self._avatar:setInfo(info.fighter.avatar)
	end
	self._avatar:setSilvesArenaPeak(info.fighter.championCount)
    self._ccbOwner.node_headPicture:addChild(self._avatar)

	self._ccbOwner.tf_nickname:setVisible(true)
	self._ccbOwner.tf_nickname:setString(info.fighter.name or "")


	local fontColor = EQUIPMENT_COLOR[6]
    if self._info.fighter.userId == remote.user.userId then
		self._ccbOwner.node_self:setVisible(true)
		fontColor = EQUIPMENT_COLOR[7]
	else
		self._ccbOwner.node_self:setVisible(false)
		fontColor = EQUIPMENT_COLOR[6]
	end
	
	self._ccbOwner.tf_nickname:setColor(fontColor)
	self._ccbOwner.tf_nickname = setShadowByFontColor(self._ccbOwner.tf_nickname, fontColor)

	if isFail ~= nil then
    	self._ccbOwner.node_win:setVisible(not isFail)
    	self._ccbOwner.node_lose:setVisible(isFail)
    	if isFail then
			makeNodeFromNormalToGray(self._ccbOwner.node_headPicture)
		end
    end
end

function QUIWidgetSanctuaryHead:setIsTopForce(isTop)
    --self._ccbOwner.node_top:setVisible(isTop)
end

function QUIWidgetSanctuaryHead:setHeadFlipX()
	local scaleX = self._avatar:getScaleX()
	return self._avatar:setScaleX(-scaleX)
end

function QUIWidgetSanctuaryHead:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSanctuaryHead:_onTriggerClick()
	if self._info == nil or self._info.fighter == nil then return end

	remote.sanctuary:sanctuaryWarQueryFighterRequest(self._info.fighter.userId, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = fighterInfo.sanctuaryWarScore or 0, forceTitle = "战力：", isPVP = true}}, {isPopCurrentDialog = false})
		end
	end)
end

return QUIWidgetSanctuaryHead
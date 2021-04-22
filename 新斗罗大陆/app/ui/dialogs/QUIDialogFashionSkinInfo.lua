--
-- Kumo.Wang
-- 時裝衣櫃皮肤信息界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFashionSkinInfo = class("QUIDialogFashionSkinInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QActorProp = import("...models.QActorProp")

function QUIDialogFashionSkinInfo:ctor(options) 
 	local ccbFile = "ccb/Dialog_Fashion_SkinInfo.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogFashionSkinInfo.super.ctor(self, ccbFile, callBacks, options)

	if options then
		self._info = options.info
	end

	if self._info then
		local fontColor = remote.fashion:getHeadColorByQuality(self._info.quality)
		if fontColor then
			self._ccbOwner.frame_tf_title:setColor(fontColor)
			self._ccbOwner.frame_tf_title = setShadowByFontColor(self._ccbOwner.frame_tf_title, fontColor)
		end
		local character = db:getCharacterByID(self._info.character_id)
		if character then
			self._ccbOwner.frame_tf_title:setString(self._info.skins_name.."·"..character.name)
		else
			self._ccbOwner.frame_tf_title:setString(self._info.skins_name)
		end
		local tfWidth = self._ccbOwner.frame_tf_title:getContentSize().width
		local totalTfWidth = 225
		local scale = 1
		if tfWidth > totalTfWidth then
			scale = totalTfWidth / tfWidth
		end
		self._ccbOwner.frame_tf_title:setScale(scale)

		self._ccbOwner.node_avatar:removeAllChildren()
		local avatar = QUIWidgetActorDisplay.new(self._info.character_id, {heroInfo = {skinId = self._info.skins_id}})
	    self._ccbOwner.node_avatar:addChild(avatar)
	    avatar:setScaleX(-1)
	    avatar:setScaleY(1)
	    -- avatar:setPositionY(-100)

    	local propFields = QActorProp:getPropFields()
    	local textTbl = {}
    	local index = 0
	    for key, value in pairs(self._info) do
	 		if propFields[key] then
	 			index = index + 1
	 			local tblKey = 1
	 			if index < 3 then
	 				-- left
	 				tblKey = 1
	 			else
	 				-- right
	 				tblKey = 2
	 			end
	 			if not textTbl[tblKey] then
 					textTbl[tblKey] = {}
 				end

	 			if #textTbl[tblKey] ~= 0 then
	 				table.insert(textTbl[tblKey], {oType = "wrap"})
	 			end
	 			local nameStr = propFields[key].uiName or propFields[key].name
	 			local num = tonumber(value)
	 			if propFields[key].isPercent then
	 				num = (num * 100).."%"
	 			end
	 			table.insert(textTbl[tblKey], {oType = "font", content = nameStr.."：+ "..num, size = 20, color = COLORS.k})
	 		end
	    end

	    self._ccbOwner.node_rtf_left:removeAllChildren()
		local rtfLeft = QRichText.new(nil, 190)
	    rtfLeft:setAnchorPoint(ccp(0, 0.5))
	    self._ccbOwner.node_rtf_left:addChild(rtfLeft)
		self._ccbOwner.node_rtf_left:setVisible(true)
		rtfLeft:setString(textTbl[1])

		self._ccbOwner.node_rtf_right:removeAllChildren()
		local rtfRight = QRichText.new(nil, 190)
	    rtfRight:setAnchorPoint(ccp(0, 0.5))
	    self._ccbOwner.node_rtf_right:addChild(rtfRight)
		self._ccbOwner.node_rtf_right:setVisible(true)
		rtfRight:setString(textTbl[2])
	end
end

function QUIDialogFashionSkinInfo:viewDidAppear()
	QUIDialogFashionSkinInfo.super.viewDidAppear(self)
end

function QUIDialogFashionSkinInfo:viewWillDisappear()
	QUIDialogFashionSkinInfo.super.viewWillDisappear(self)
end

function QUIDialogFashionSkinInfo:_onTriggerClose(event) 
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    if event then
    	app.sound:playSound("common_cancel")
    end
	self:playEffectOut()
end

function QUIDialogFashionSkinInfo:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogFashionSkinInfo:viewAnimationOutHandler()
    self:popSelf()
end

return QUIDialogFashionSkinInfo
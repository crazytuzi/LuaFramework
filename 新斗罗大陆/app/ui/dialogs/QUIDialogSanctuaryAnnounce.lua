-- 
-- zxs
-- 精英赛通告
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSanctuaryAnnounce = class("QUIDialogSanctuaryAnnounce", QUIDialog)
local QRichText = import("...utils.QRichText")
local QListView = import("...views.QListView")
local QUIWidgetSanctuaryHead = import("..widgets.sanctuary.QUIWidgetSanctuaryHead")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetSanctuaryAvatar = import("..widgets.sanctuary.QUIWidgetSanctuaryAvatar")

function QUIDialogSanctuaryAnnounce:ctor(options)
	local ccbFile = "ccb/Dialog_Sanctuary_rank.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSanctuaryAnnounce.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	-- 预备显示多个
	self._fighters = {}

	if options.isResult then
		self:setResultInfo()
	else
		self:initListView()
		self:setNextInfo()
	end

	self._ccbOwner.frame_tf_title:setString("全大陆通告")
	self._ccbOwner.node_right_center:setVisible(false)
	q.setButtonEnableShadow(self._ccbOwner.btn_close)
end

function QUIDialogSanctuaryAnnounce:viewDidAppear()
	QUIDialogSanctuaryAnnounce.super.viewDidAppear(self)
end

function QUIDialogSanctuaryAnnounce:viewWillDisappear()
	QUIDialogSanctuaryAnnounce.super.viewWillDisappear(self)
end

function QUIDialogSanctuaryAnnounce:setResultInfo()
	self._ccbOwner.node_win:setVisible(true)
	self._ccbOwner.node_next:setVisible(false)

	for i = 1, 3 do
		local fighter = QUIWidgetSanctuaryAvatar.new()
		self._ccbOwner["node_avatar"..i]:addChild(fighter)
		table.insert(self._fighters, fighter)
		fighter:setVisible(false)
		fighter:setAvatarScaleX(-1)
		self._ccbOwner["tf_name"..i]:setVisible(false)
		self._ccbOwner["tf_server"..i]:setVisible(false)
	end

	self:updateGloryInfo()
end

--显示荣耀墙
function QUIDialogSanctuaryAnnounce:updateGloryInfo()
	local gloryData = remote.sanctuary:getGloryData() or {}
	for index, fighter in ipairs(self._fighters) do
		if gloryData[index] then
			fighter:setInfo(gloryData[index])
			fighter:setVisible(true)
			fighter:setShowInfo(false)

			local info = gloryData[index]
			self._ccbOwner["tf_name"..index]:setVisible(true)
			self._ccbOwner["tf_name"..index]:setString(info.name)
			self._ccbOwner["tf_server"..index]:setVisible(true)
			self._ccbOwner["tf_server"..index]:setString(info.game_area_name)
		end
	end
	if gloryData[1] then
		local firstPlayer = gloryData[1]
		local seasonNO = remote.sanctuary:getCurrentSeasonNo() or 1
		local richText = QRichText.new({
				{oType = "font", content = "恭喜来自", size = 22, color = GAME_COLOR_SHADOW.normal},
		        {oType = "font", content = firstPlayer.game_area_name, size = 22, color = GAME_COLOR_SHADOW.stress},
		        {oType = "font", content = "服的", size = 22, color = GAME_COLOR_SHADOW.normal},
		    	{oType = "font", content = firstPlayer.name,size = 22, color = GAME_COLOR_SHADOW.stress},
		        {oType = "font", content = "玩家获得了第", size = 22, color = GAME_COLOR_SHADOW.normal},
		    	{oType = "font", content = tostring(seasonNO), size = 22, color = GAME_COLOR_SHADOW.stress},
		        {oType = "font", content = "届全大陆精英赛", size = 22, color = GAME_COLOR_SHADOW.normal},
		    	{oType = "font", content = "冠军", size = 22, color = GAME_COLOR_SHADOW.stress},
		    }, 1100, {autoCenter = true})
		richText:setAnchorPoint(ccp(0.5, 0.5))
	    self._ccbOwner.node_win_desc:addChild(richText)
	end
end

function QUIDialogSanctuaryAnnounce:setNextInfo()
	self._ccbOwner.node_win:setVisible(false)
	self._ccbOwner.node_next:setVisible(true)

	local avatar = QUIWidgetActorDisplay.new(1027)
	self._ccbOwner.node_boss:addChild(avatar)
	self._ccbOwner.node_boss:setScaleX(-1.5)
	self._ccbOwner.node_boss:setScaleY(1.5)

	local richText = QRichText.new({}, 370)
	richText:setAnchorPoint(ccp(0, 0.5))
    self._ccbOwner.node_desc:addChild(richText)

	local state = remote.sanctuary:getState()
	if state == remote.sanctuary.STATE_AUDITION_2_END then
		richText:setString({
	        {oType = "font", content = "64", size = 22, color = GAME_COLOR_LIGHT.stress},
	        {oType = "font", content = "强已经诞生！以下选手都是斗罗大陆上的精英魂师，让我们为他们欢呼！64进8将在", size = 22, color = GAME_COLOR_LIGHT.normal},
	    	{oType = "font", content = "周四19:30", size = 22, color = GAME_COLOR_LIGHT.stress},
	        {oType = "font", content = "准时开战", size = 22, color = GAME_COLOR_LIGHT.normal},
	    })
	elseif state >= remote.sanctuary.STATE_KNOCKOUT_8_OUT and state <= remote.sanctuary.STATE_BETS_8 then
		richText:setString({
			{oType = "font", content = "精英中的精英，", size = 22, color = GAME_COLOR_LIGHT.normal},
	        {oType = "font", content = "8强",size = 22, color = GAME_COLOR_LIGHT.stress},
	        {oType = "font", content = "魂师诞生！他们用自己的实力获得了无数的荣耀和掌声~", size = 22, color = GAME_COLOR_LIGHT.normal},
	    	{oType = "font", content = "8强",size = 22, color = GAME_COLOR_LIGHT.stress},
	        {oType = "font", content = "比赛将在今晚", size = 22, color = GAME_COLOR_LIGHT.normal},
	    	{oType = "font", content = "19:30",size = 22, color = GAME_COLOR_LIGHT.stress},
	        {oType = "font", content = "准时开战，快来见证王者的诞生吧~", size = 22, color = GAME_COLOR_LIGHT.normal},
	    })
	end
end

function QUIDialogSanctuaryAnnounce:initListView()
	self._data = remote.sanctuary:getPositionList()
	-- body
	if not self._listView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	item = QUIWidgetSanctuaryHead.new()
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()
	            info.offsetPos = ccp(0, -60)
	            return isCacheNode
	        end,
	        curOriginOffset = 80,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	isVertical = false,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogSanctuaryAnnounce:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogSanctuaryAnnounce:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogSanctuaryAnnounce
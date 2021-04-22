--
-- zxs
-- 公告
-- 

local QUIDialog = import(".QUIDialog")
local QUIDialogAnnouncement = class("QUIDialogAnnouncement", QUIDialog)
local QListView = import("...views.QListView")
local QScrollView = import("...views.QScrollView")
local QLogFile = import("...utils.QLogFile")
local QUIWidgetAnnouncement = import("..widgets.QUIWidgetAnnouncement")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")

function QUIDialogAnnouncement:ctor(options)
	local ccbFile = "ccb/Dialog_Announcement.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)}
	}
	QUIDialogAnnouncement.super.ctor(self, ccbFile, callBacks, options)

    self.confirmCallBack = options.confirmCallBack
    self.isAnimation = false --是否动画显示

    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    q.setButtonEnableShadow(self._ccbOwner.btn_zhidao)
    --埋点 弹出游戏公告
    remote:triggerBeforeStartGameBuriedPoint("10043")

    self:initListData()
end

function QUIDialogAnnouncement:_onTriggerClose()
  	app.sound:playSound("common_close")
    remote:triggerBeforeStartGameBuriedPoint("10044")
	self:playEffectOut()
end

function QUIDialogAnnouncement:viewAnimationInHandler()
    self:initListView()
    self:initScrollView()
	self:showInfo(1)
end

function QUIDialogAnnouncement:initListData()
	self._data = {}
    local announcements = app:getAnnouncement()

    self._selectTap = 1
    -- local announcements = {
    -- 	{id = 1,title = "实名认证",type = 2,content = "##0x865537《新斗罗大陆》将于##0xDE44002020年2月7日6时（星期五）##0x865537进行版本更新维护，本次维护预计3小时，如遇特殊情况延迟开服，每延迟1小时额外补偿##0xDE4400300钻##0x865537。##0x865537同时小舞还要万分感谢##0xDE4400只有影子、天作之合、不吃柠檬##0x865537等热心的魂师大人们提出宝贵建议，相信只要大家共同努力，游戏会越来越好玩！$T更新福利: ##0xDE4400【第一日】##0x865537钻石500+项链突破石*150+项链强化粉尘(橙)*100；##0xDE4400【第二日】##0x865537钻石300+项链3选1礼盒*30+奥斯卡特级香肠*2；##0xDE4400【第三日】##0x865537钻石300+武魂玉*5000+金魂币20万。$T版本福利:##0xDE4400【冰天雪女加入传灵商店】传灵商店##0x865537中新增##0xDE4400冰天雪女##0x865537碎片，魂师大人们有更多选择啦！##0xDE4400【VIP16周礼包调整】天龙马碎片##0x865537调整为##0xDE4400S魂灵碎片2选1##0x865537宝箱，新增##0xDE4400冰天雪女##0x865537碎片供大家选择！$T版本亮点:##0xDE4400【新SS暗器·鬼见愁】##0x865537神秘又强大的定装魂导炮弹，精妙的机身周围散发着淡淡光晕，光是看到就令人心生恐惧，故得名“鬼见愁”。##0xDE4400【SS魂师皮肤属性调整】##0x865537SS魂师的高级皮肤属性——全队攻击生命双防+##0xDE44007.0%##0x865537提升至##0xDE44008.0%##0x865537。目前已上线的##0xDE4400玩转平安夜·战神戴沐白##0x865537和##0xDE4400新春艺神·凤凰马红俊##0x865537这两个皮肤的属性均会在本次更新后得到提升，后续更新的SS魂师的高级皮肤属性也会根据全新属性加成。"},
    -- 	{title = "实名认证",type = 1},
    -- 	{title = "实名认证",type = 1},
    -- 	{title = "实名认证",type = 1},
    -- 	{title = "实名认证",type = 1},
    -- 	{title = "实名认证",type = 1},
    -- }
    for i, v in pairs(announcements or {}) do
    	self._data[#self._data+1] = v
	end
	-- table.sort(self._data, function(a, b)
	-- 		return a.id < b.id
	-- 	end)
end

function QUIDialogAnnouncement:initListView()
	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
                local itemData = self._data[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetAnnouncement.new()
	                item:addEventListener(QUIWidgetAnnouncement.TITLE_BUTTON_CLICK, handler(self, self._onTriggerClick))
	                isCacheNode = false
	            end
	            info.item = item
	            info.size = item:getContentSize()
	            item:setInfo(itemData)
				item:setSelect(self._selectTap == index)

	            list:registerBtnHandler(index, "sp_button", "_onTriggerClick")

	            return isCacheNode
	        end,
	        spaceY = 4,
	        enableShadow = true,
	        -- topShadow = self._ccbOwner.top_shadow1,
        	-- bottomShadow = self._ccbOwner.bottom_shadow1,
	        ignoreCanDrag = true,
	        totalNumber = #self._data,
	    }
    	self._listView = QListView.new(self._ccbOwner.bt_sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogAnnouncement:initScrollView()
	self._sheetSize = self._ccbOwner.desc_sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.desc_sheet, self._sheetSize, {sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)

	self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._scrollViewMoveState))
	self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._scrollViewMoveState))
end

function QUIDialogAnnouncement:_scrollViewMoveState(event)
	if event.name == QScrollView.GESTURE_MOVING then
		self._isMoving = true
	elseif event.name == QScrollView.GESTURE_BEGAN then
		self._isMoving = false
	end
end

function QUIDialogAnnouncement:_onTriggerClick(event)
	if not event.idIndex or self._idIndex == event.idIndex then
		return
	end

	local index = 1
	for i = 1, #self._data do
		if self._data[i].id == event.idIndex then
			index = i
   	 		self._selectTap = index
   	 		break
		end
	end
	self:showInfo(index)
end

function QUIDialogAnnouncement:showInfo(index)
	self._scrollView:clear()
	local info = self._data[index]
	if not info then
		self._ccbOwner.loadingLabel:setVisible(true)
		return
	end

	self._idIndex = info.id
	if self._listView then
		self._listView:reload({totalNumber = #self._data})
	end

	self._ccbOwner.loadingLabel:setVisible(false)

	local content = info.content or ""
	local data = {}
    table.insert(data, {oType = "title", info = {}, title = info.subtitle or ""})
   	
   	local strArr  = string.split(content, "\n") or {}
	for k, v in pairs(strArr) do
		if v and v ~= "" then
			local index1 = string.find(v, "$T")
			if index1 then
				local index2 = string.find(v, ":") or string.len(v)
				local subTitle = string.sub(v, index1+2, index2-1) 
				local content = string.sub(v, index2+1, string.len(v)) 
				table.insert(data, {oType = "subTitle", info = {}, title = subTitle})
				table.insert(data, {oType = "describe", info = {widthLimit = 620, offsetX = 8, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 22, lineSpace = 5}, title = content})
			else
				table.insert(data, {oType = "describe", info = {widthLimit = 620, offsetX = 8, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 22, lineSpace = 5}, title = v})
			end
			table.insert(data,{oType = "empty", height = 10})
		end
	end
 
	local totalHeight = 0
	for i, itemData in pairs(data) do
		local item
		if itemData.oType == "describe" then
            item = QUIWidgetHelpDescribe.new()
            item:setInfo(itemData.info, itemData.title)
        elseif itemData.oType == "title" then
            item = self:getTitleNode(itemData.title)
        elseif itemData.oType == "subTitle" then
            item = self:getSubTitleNode(itemData.title)
    	elseif itemData.oType == "empty" then
    		item = QUIWidgetQlistviewItem.new() 
    		item:setContentSize(CCSizeMake(0, itemData.height))
        end
        if item then
	        local height = item:getContentSize().height
	        item:setPositionY(-totalHeight)
	        self._scrollView:addItemBox(item)
	        totalHeight = totalHeight+height
	    end
	end

	self._scrollView:setRect(0, -totalHeight, 0, self._sheetSize.width)
end

function QUIDialogAnnouncement:getTitleNode(title)
	local owner = {}
	local node = CCBuilderReaderLoad("ccb/Widget_ann_title.ccbi", CCBProxy:create(), owner)
	function node:getContentSize()
		return owner.size:getContentSize() 
	end
	function node:setInfo(title)
		owner.tf_name:setString(title) 
	end
	owner.tf_name:setString(title)

	return node
end

function QUIDialogAnnouncement:getSubTitleNode(title)
	local owner = {}
	local node = CCBuilderReaderLoad("ccb/Widget_ann_title2.ccbi", CCBProxy:create(), owner)
	function node:getContentSize()
		return owner.size:getContentSize() 
	end
	function node:setInfo(title)
		owner.tf_name:setString(title) 
		local length = q.wordLen(title, 22, 22)
		owner.sp_title1:setPositionX(-length/2-5)
		owner.sp_title2:setPositionX(length/2+5)
	end
	node:setInfo(title)
    
	return node
end

function QUIDialogAnnouncement:viewAnimationOutHandler()
	if self.confirmCallBack ~= nil then
		self.confirmCallBack()
	end
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogAnnouncement:viewDidAppear()
    QUIDialogAnnouncement.super.viewDidAppear(self) 
    app:registerBackButtonHandler(function ( )
    	self:_onTriggerClose()
    	return true
    end)
end

function QUIDialogAnnouncement:viewWillDisappear()
    QUIDialogAnnouncement.super.viewWillDisappear(self)
   	app:unRegisterBackButtonHandler()
end

return QUIDialogAnnouncement
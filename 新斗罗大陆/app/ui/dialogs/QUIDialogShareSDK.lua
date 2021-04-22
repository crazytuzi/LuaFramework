-- @Author: liaoxianbo
-- @Date:   2020-07-15 18:26:05
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-09 10:45:20
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogShareSDK = class("QUIDialogShareSDK", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidget = import("..widgets.QUIWidget")

function QUIDialogShareSDK:ctor(options)
	local ccbFile = "ccb/Dialog_Share_Image.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerShareQQ", callback = handler(self, self._onTriggerShareQQ)},
		{ccbCallbackName = "onTriggerShareWX", callback = handler(self, self._onTriggerShareWX)},
		{ccbCallbackName = "onTriggerSharePyq", callback = handler(self, self._onTriggerSharePyq)},
		{ccbCallbackName = "onTriggerShareWB", callback = handler(self, self._onTriggerShareWB)},
		{ccbCallbackName = "onTriggerSharefacebook", callback = handler(self, self._onTriggerSharefacebook)},
    }
    QUIDialogShareSDK.super.ctor(self, ccbFile, callBacks, options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	AdaptationUIBgSize(self._ccbOwner.sp_bg)
	self._ccbOwner.sp_down_bg:setContentSize(CCSize(display.width, 217))

	q.setButtonEnableShadow(self._ccbOwner.btn_qq)
	q.setButtonEnableShadow(self._ccbOwner.btn_wx)
	q.setButtonEnableShadow(self._ccbOwner.btn_wb)
	q.setButtonEnableShadow(self._ccbOwner.btn_pyq)
	q.setButtonEnableShadow(self._ccbOwner.btn_facebook)
	-- remote.user:addPropNumForKey("todayShareCount")
	self._shareInfo = options.shareInfo
	
	self._isShareIng = false
	if display.width / display.height == 4 / 3 then
		self._ccbOwner.node_logo:setPositionY(-200)
	end

	self:initView()
end

function QUIDialogShareSDK:resetAll( )
	self._ccbOwner.sp_bg:setVisible(false)

	self._ccbOwner.node_hero_card:removeAllChildren()
	-- app:cleanTextureCache()
end
function QUIDialogShareSDK:viewDidAppear()
	QUIDialogShareSDK.super.viewDidAppear(self)

	-- self:addBackEvent(false)
end

function QUIDialogShareSDK:viewWillDisappear()
  	QUIDialogShareSDK.super.viewWillDisappear(self)

	-- self:removeBackEvent()
end

function QUIDialogShareSDK:updateHeroBg( )
	local actordID = self._shareInfo.conditions
	local actorInfo = db:getCharacterByID(actordID)
	self._ccbOwner.sp_bg:setVisible(true)
	if actorInfo and actorInfo.chouka_show2 then

        local widget = QUIWidget.new(actorInfo.chouka_show2)
        widget:setPosition(-display.ui_width/2, -display.ui_height/2)
        if nil ~= widget._ccbOwner.sp_ad then
            widget._ccbOwner.sp_ad:setVisible(false)
        end
        self._ccbOwner.node_hero_card:addChild(widget)	
	    local right_frame = actorInfo.right_frame or ""
	    local left_frame =  actorInfo.left_frame or ""
        if right_frame ~="" and left_frame ~="" then
            local spRightFrame = CCSprite:create(right_frame)
            spRightFrame:setAnchorPoint(ccp(0, 0.5))
            spRightFrame:setPositionX( UI_VIEW_MIN_WIDTH * 0.5 - 2)
            self._ccbOwner.node_hero_card:addChild(spRightFrame)

            local spLeftFrame = CCSprite:create(left_frame)
            spLeftFrame:setAnchorPoint(ccp(1, 0.5))
            spLeftFrame:setPositionX( - UI_VIEW_MIN_WIDTH * 0.5)
            self._ccbOwner.node_hero_card:addChild(spLeftFrame)
        end         
	end
end

function QUIDialogShareSDK:updateSkinBg( )
	local skinId = self._shareInfo.conditions
	local skinInfo = remote.heroSkin:getSkinConfigDictBySkinId(skinId)

	if skinInfo and skinInfo.skins_ccb then
        local widget = QUIWidget.new(skinInfo.skins_ccb)
        widget:setPosition(-display.ui_width/2, -display.ui_height/2)
        if nil ~= widget._ccbOwner.sp_ad then
            widget._ccbOwner.sp_ad:setVisible(false)
        end
        self._ccbOwner.node_hero_card:addChild(widget)
	    local right_frame = skinInfo.right_frame or ""
	    local left_frame =  skinInfo.left_frame or ""
        if right_frame ~="" and left_frame ~="" then
            local spRightFrame = CCSprite:create(right_frame)
            spRightFrame:setAnchorPoint(ccp(0, 0.5))
            spRightFrame:setPositionX( UI_VIEW_MIN_WIDTH * 0.5 - 2)
            self._ccbOwner.node_hero_card:addChild(spRightFrame)

            local spLeftFrame = CCSprite:create(left_frame)
            spLeftFrame:setAnchorPoint(ccp(1, 0.5))
            spLeftFrame:setPositionX( - UI_VIEW_MIN_WIDTH * 0.5)
            self._ccbOwner.node_hero_card:addChild(spLeftFrame)
        end        
	end
end

function QUIDialogShareSDK:updateSkinTiredBg( )
	local combinationDataList = remote.fashion:getCombinationDataList()
	local itemData = nil
	for _, v in ipairs(combinationDataList) do
		if v.id == self._shareInfo.conditions then
			itemData = v
			break
		end
	end
	self:_updatePicture(itemData)
end

-- "skin_display_2": "2;62;100;0;1;1;0",
function QUIDialogShareSDK:_updatePicture(itemData)
	if not itemData then return end
	
	if itemData.sp_bg then
		local sprite = CCSprite:create(itemData.sp_bg)
		if sprite then
			self._ccbOwner.node_hero_card:addChild(sprite)
		end
	end

	local index = 1
	local figureList = {}
	while true do
		local str = itemData["skin_display_"..index]
		if str then
			local tbl = string.split(str, ";")
			local widgetTbl = {}
			for i = 8, #tbl, 1 do
				table.insert(widgetTbl, tbl[i])
			end
			table.insert(figureList, {index = tonumber(tbl[1]), skinId = tbl[2], x = tonumber(tbl[3]), y = tonumber(tbl[4]), scale = tonumber(tbl[5]), isturn = tonumber(tbl[6]), rotation = tonumber(tbl[7]), widgets = widgetTbl})
			index = index + 1
		else
			break
		end
	end
	table.sort(figureList, function(a, b)
		if tonumber(a.skinId) and not tonumber(b.skinId) then
			return true
		elseif not tonumber(a.skinId) and tonumber(b.skinId) then
			return false
		else
			return a.index < b.index
		end
	end)
	local isAllActivity = true
	if #figureList > 0 then
		local grayWidgets = {}
		for _, info in ipairs(figureList) do
			local skinId = info.skinId
			local path = ""
			local isActivity = true
			if tonumber(skinId) then
				-- 主体人物
				skinId = tonumber(skinId)
				local skinConfig = remote.fashion:getSkinConfigDataBySkinId(skinId)
				if skinConfig then
					path = skinConfig.combination_card or skinConfig.fightEnd_card

					if not remote.fashion:checkSkinActivityBySkinId(skinId) then
						isAllActivity = false
						isActivity = false
						for _, widget in ipairs(info.widgets) do
							table.insert(grayWidgets, widget)
						end
					end
				end
			else
				-- 主体人物的挂件
				skinId = tostring(skinId)
				path = itemData[skinId]
				for _, widget in ipairs(grayWidgets) do
					if widget == skinId then
						isAllActivity = false
						isActivity = false
						break
					end
				end
			end

			if path and path ~= "" then
				print("path = ", path)
				local sprite = CCSprite:create(path)
				if sprite then
					local z = #figureList - info.index + 1
					self._ccbOwner.node_hero_card:addChild(sprite, z)

					sprite:setPositionX(info.x)
					sprite:setPositionY(info.y)
					sprite:setScaleX(info.isturn * info.scale)
					sprite:setScaleY(info.scale)
					sprite:setRotation(info.rotation)
				end
			end
		end
	end

	-- if itemData.sp_fg and isAllActivity then
	if itemData.sp_fg then
		local sprite = CCSprite:create(itemData.sp_fg)
		if sprite then
			self._ccbOwner.node_hero_card:addChild(sprite, #figureList + 1)
		end
	end
end

function QUIDialogShareSDK:initView()
	if q.isEmpty(self._shareInfo) then 
		return
	end
	self:resetAll()
	
	if self._shareInfo.type == remote.shareSDK.COLLECT then
		self._ccbOwner.sp_bg:setVisible(true)
		if self._shareInfo.icon_chart then
			QSetDisplayFrameByPath(self._ccbOwner.sp_bg,self._shareInfo.icon_chart)
		end
	elseif self._shareInfo.type == remote.shareSDK.HERO then
		self:updateHeroBg()
	elseif self._shareInfo.type == remote.shareSDK.SKIN then
		self:updateSkinBg()
	elseif self._shareInfo.type == remote.shareSDK.SKINTIRED then
		self:updateSkinTiredBg()
	end

	if self._shareInfo.icon_word then
		QSetDisplayFrameByPath(self._ccbOwner.sp_word,self._shareInfo.icon_word)
	end

	self._ccbOwner.node_head:removeAllChildren()
	local avatar = QUIWidgetAvatar.new(remote.user.avatar)
	avatar:setSilvesArenaPeak(remote.user.championCount)
	self._ccbOwner.node_head:addChild(avatar)

	-- self._avatar:setInfo(remote.user.avatar)
	-- self._avatar:setSoulTrial(remote.user.soulTrial)
	self._ccbOwner.sp_name:setString(remote.user.nickname)
	local _, passChapter = remote.soulTrial:getCurChapter( remote.user.soulTrial )
	local curBossConfig = remote.soulTrial:getBossConfigByChapter( passChapter )
	local url = curBossConfig.title_icon3
	if url then
		QSetDisplayFrameByPath(self._ccbOwner.sp_soulTrial,url)
	end

	q.autoLayerNode({self._ccbOwner.sp_name,self._ccbOwner.sp_soulTrial},"x",5)
	self._ccbOwner.sp_severName:setString(remote.user.myGameAreaName or "")
end

-- -- 分享类型
-- SHARE_IMAGE_TYPE = {
--     WECHAT = 1,--微信
--     MOMENT = 2,--朋友圈
--     TENCENTQQ = 3,--qq
--     QZONE = 4,--QQ空间
--     WEIBO = 5,--微博
-- }
function QUIDialogShareSDK:shareSDKByTYpe( sdkType)
	remote.shareSDK:screenShot(self._ccbOwner.node_share,"shareSDK_image.jpg")
	self._isShareIng = true
	FinalSDK.shareImage(sdkType,"shareSDK_image.jpg",function(code)
		self._isShareIng = false
		if code and tonumber(code) == -100 then
			app.tip:floatTip("分享失败,没有安装对应得客户端。")
		else
			if self:safeCheck() then
				self._ccbOwner.node_btn:setVisible(true)
			end
			remote.shareSDK:shareToSDK()
		end
	end)

	scheduler.performWithDelayGlobal(function()
		self._isShareIng = false
	end,5)
end

function QUIDialogShareSDK:_onTriggerShareQQ( )
	if FinalSDK.checkAppExist(3) then
		self:shareSDKByTYpe(SHARE_IMAGE_TYPE.TENCENTQQ)
	else
		app.tip:floatTip("您还未安装QQ")
	end
end

function QUIDialogShareSDK:_onTriggerShareWX( )
	if FinalSDK.checkAppExist(1) then
		self:shareSDKByTYpe(SHARE_IMAGE_TYPE.WECHAT)
	else
		app.tip:floatTip("您还未安装微信")
	end
end

function QUIDialogShareSDK:_onTriggerSharePyq( )
	if FinalSDK.checkAppExist(1) then
		self:shareSDKByTYpe(SHARE_IMAGE_TYPE.MOMENT)
	else
		app.tip:floatTip("您还未安装微信")		
	end
end

function QUIDialogShareSDK:_onTriggerShareWB( )
	if FinalSDK.checkAppExist(2) then
		self:shareSDKByTYpe(SHARE_IMAGE_TYPE.WEIBO)
	else
		app.tip:floatTip("您还未安装微博")		
	end
end

function QUIDialogShareSDK:_onTriggerSharefacebook( )
	-- body
end

function QUIDialogShareSDK:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogShareSDK:_onTriggerClose()
	if self._isShareIng then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogShareSDK

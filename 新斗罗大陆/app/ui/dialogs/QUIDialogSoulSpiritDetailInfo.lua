-- @Author: zhouxiaoshu
-- @Date:   2019-06-18 17:04:30
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-07-24 16:10:56

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritDetailInfo = class("QUIDialogSoulSpiritDetailInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")
local QUIWidgetSoulSpiritInfoCell = import("..widgets.QUIWidgetSoulSpiritInfoCell")

function QUIDialogSoulSpiritDetailInfo:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_xiangqing.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
	}
	QUIDialogSoulSpiritDetailInfo.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true --是否动画显示
	
	self._soulSpiritId = options.soulSpiritId or options.actorId
    self._isTips = options.isTips

    if self._isTips then
        self._ccbOwner.tf_get:setString("确 定")
    else
        self._ccbOwner.tf_get:setString("获 取")
    end

    self:initScrollView()
    self:setHeroInfo()
end

function QUIDialogSoulSpiritDetailInfo:initScrollView()
    local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()

    self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setVerticalBounce(true)
end

--------------------------- main logic -----------------------------
function QUIDialogSoulSpiritDetailInfo:setHeroInfo()
    local soulSpiritConfig = db:getCharacterByID(self._soulSpiritId)
    self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._soulSpiritId)
    self._ccbOwner.frame_tf_title:setString(soulSpiritConfig.name or "")
    self._ccbOwner.tf_desc:setString("")

    local desc = soulSpiritConfig.brief or ""
	local itemContentSize = self._ccbOwner.desc_sheet_layout:getContentSize()
    local scrollView = QScrollView.new(self._ccbOwner.desc_sheet, itemContentSize, {bufferMode = 0})
    scrollView:setVerticalBounce(true)
	local text = QColorLabel:create(desc, 270, nil, nil, 20, GAME_COLOR_LIGHT.normal)
	text:setAnchorPoint(ccp(0, 1))
	local totalHeight = text:getContentSize().height
	scrollView:addChild(text)
	scrollView:setRect(0, -totalHeight, 0, 0)

    -- hero avatar
    local avatar = QUIWidgetActorDisplay.new(self._soulSpiritId)
    avatar:setPositionY(-100)
    self._ccbOwner.node_avatar:addChild(avatar)
    self._ccbOwner.node_avatar:setScaleX(-1)
    
	-- hero quality
    local aptitudeInfo = db:getActorSABC(self._soulSpiritId)
    self._ccbOwner.hero_qulity:setString(aptitudeInfo.qc.."级")

    local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
	self._ccbOwner.frame_tf_title:setColor(fontColor)
	setShadowByFontColor(self._ccbOwner.frame_tf_title, fontColor)

	self:setSABC()
	self:setPieceNum()
    self:showInfo()
end

function QUIDialogSoulSpiritDetailInfo:setSABC()
    local aptitudeInfo = db:getActorSABC(self._soulSpiritId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)

    self._ccbOwner["node_blue"]:setVisible(false)
    self._ccbOwner["node_purple"]:setVisible(false)
    self._ccbOwner["node_orange"]:setVisible(false)
    if aptitudeInfo.lower == "b" then
    	self._ccbOwner["node_blue"]:setVisible(true)
    elseif aptitudeInfo.lower == "a" or aptitudeInfo.lower == "a+" then
    	self._ccbOwner["node_purple"]:setVisible(true)
    elseif aptitudeInfo.lower == "s" or aptitudeInfo.lower == "s+" then
    	self._ccbOwner["node_orange"]:setVisible(true)
    end
end

function QUIDialogSoulSpiritDetailInfo:setPieceNum()
	-- 默认显示1星
	local grade = 0
    self._ccbOwner.tf_num_name:setString("合成碎片：")
	if self._soulSpiritInfo then
		grade = self._soulSpiritInfo.grade+1
        self._ccbOwner.tf_num_name:setString("升星碎片：")
	end

	local numWord = ""
	local info = db:getGradeByHeroActorLevel(self._soulSpiritId, grade) or {}
    local needNum = info.soul_gem_count or 0
    local currentNum = remote.items:getItemsNumByID(info.soul_gem) or 0
    if needNum > 0 then
        numWord = currentNum.."/"..needNum
    else
        numWord = currentNum
        self._ccbOwner.tf_num_name:setString("拥有碎片：")
    end
	self._ccbOwner.tf_have_num:setString(numWord)
end


function QUIDialogSoulSpiritDetailInfo:showInfo()
    self._scrollView:clear()
        
    if self._client then
        self._client:removeFromParent()
        self._client = nil
    end
    if not self._client then
        self._client = QUIWidgetSoulSpiritInfoCell.new()
    end
    self._client:setInfo(self._soulSpiritId)
    self._scrollView:addItemBox(self._client)

    local contentSize = self._client:getContentSize()
    self._client:setPosition(ccp(0, 0))
    self._scrollView:setRect(0, -contentSize.height, 0, contentSize.width)
end

function QUIDialogSoulSpiritDetailInfo:_onTriggerGet(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_get) == false then return end
	app.sound:playSound("common_common")

    if self._isTips then
        self:playEffectOut()
    else
        self:viewAnimationOutHandler()
	    QQuickWay:addQuickWay(QQuickWay.HERO_DROP_WAY, self._soulSpiritId, nil, nil, false)
    end
end

function QUIDialogSoulSpiritDetailInfo:_backClickHandler()
	self:_onTriggerClose()
end 

function QUIDialogSoulSpiritDetailInfo:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogSoulSpiritDetailInfo
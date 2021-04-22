--
-- Author: qsy
-- 
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMockBattleMountCardInfo = class("QUIDialogMockBattleMountCardInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")

function QUIDialogMockBattleMountCardInfo:ctor(options)
	local ccbFile = "ccb/Dialog_MockBattle_MountCardInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
		{ccbCallbackName = "onTriggerSkillInfo", callback = handler(self, self._onTriggerSkillInfo)},
	}
	QUIDialogMockBattleMountCardInfo.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true --是否动画显示
	
	self._mountId = options.mountId or options.actorId
    --self._params = options.params or {}
    self._id = options.id or 0
    self._mountInfo =nil
    self._mountInfo = remote.mockbattle:getCardInfoByIndex(self._id)
    if not  self._mountInfo then
        self._mountInfo = remote.mount:getMountById(self._mountId)
    end
	-- skill scroll view
    local size = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, size, {bufferMode = 1})
    self._scrollView:setVerticalBounce(true)
   	self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
   	self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))

    self:setHeroInfo()
end

function QUIDialogMockBattleMountCardInfo:viewDidAppear()
	QUIDialogMockBattleMountCardInfo.super.viewDidAppear(self)

end

function QUIDialogMockBattleMountCardInfo:viewWillDisappear()
	QUIDialogMockBattleMountCardInfo.super.viewWillDisappear(self)
end

--------------------------- main logic -----------------------------
function QUIDialogMockBattleMountCardInfo:setHeroInfo()
    self._mountConfig = db:getCharacterByID(self._mountId)
    --self._mountInfo = remote.mount:getMountById(self._mountId)
    self._ccbOwner.frame_tf_title:setString(self._mountConfig.name or "")
    self._ccbOwner.tf_desc:setVisible(false)

    local desc = self._mountConfig.brief or ""
	local itemContentSize = self._ccbOwner.desc_sheet_layout:getContentSize()
    local scrollView = QScrollView.new(self._ccbOwner.desc_sheet, itemContentSize, {bufferMode = 0})
    scrollView:setVerticalBounce(true)
	local text = QColorLabel:create(desc, 330, nil, nil, 20, GAME_COLOR_LIGHT.normal)
	text:setAnchorPoint(ccp(0, 1))
	local totalHeight = text:getContentSize().height
	scrollView:addChild(text)
	scrollView:setRect(0, -totalHeight, 0, 0)

    -- hero avatar
    local avatar = QUIWidgetActorDisplay.new(self._mountId)
    self._ccbOwner.node_avatar:addChild(avatar)
    self._ccbOwner.node_avatar:setScaleX(-1)
    
   
	-- hero quality
    local aptitudeInfo = db:getActorSABC(self._mountId)
   

    local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
	self._ccbOwner.frame_tf_title:setColor(fontColor)
    self._ccbOwner.frame_tf_title = setShadowByFontColor(self._ccbOwner.frame_tf_title, fontColor)


	self:setSABC()
    self:setSkillInfo()
end

function QUIDialogMockBattleMountCardInfo:setSABC()
    local aptitudeInfo = db:getActorSABC(self._mountId)
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

function QUIDialogMockBattleMountCardInfo:setSkillInfo()
	-- 默认显示5星
	local grade = 4
	if self._mountInfo then
		grade = self._mountInfo.grade
	end

    local height = 0
    local gradeConfig = db:getGradeByHeroActorLevel(self._mountId, grade)
    if gradeConfig then
        local skillIds = string.split(gradeConfig.zuoqi_skill_ms, ";")
        local skillConfig1 = db:getSkillByID(tonumber(skillIds[1]))
        if skillConfig1 ~= nil then
            local describe = "##e"..skillConfig1.name.."：##n"..(skillConfig1.description or "")
            describe = QColorLabel.replaceColorSign(describe)
            local strArr  = string.split(describe,"\n") or {}
            for i, v in pairs(strArr) do
                local richText = QRichText.new(v, 600, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
                richText:setAnchorPoint(ccp(0, 1))
                richText:setPositionY(-height)
                self._scrollView:addItemBox(richText)
                height = height + richText:getContentSize().height
            end
        end

        local skillConfig2 = db:getSkillByID(tonumber(skillIds[2]))
        if skillConfig2 ~= nil then
            local describe = "##e"..skillConfig2.name.."：##n"..(skillConfig2.description or "")
            describe = QColorLabel.replaceColorSign(describe)
            local strArr  = string.split(describe,"\n") or {}
            for i, v in pairs(strArr) do
                local richText = QRichText.new(v, 600, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
                richText:setAnchorPoint(ccp(0, 1))
                richText:setPositionY(-height)
                self._scrollView:addItemBox(richText)
                height = height + richText:getContentSize().height
            end
        end

        if gradeConfig.zuoqi_skill_xs then
            local skillIds = string.split(gradeConfig.zuoqi_skill_xs, ":")
            local skillConfig1 = db:getSkillByID(tonumber(skillIds[1]))
            local height1 = 0
            if skillConfig1 ~= nil then
                local describe = "##e"..skillConfig1.name.."：##n"..(skillConfig1.description or "")
                describe = QColorLabel.replaceColorSign(describe)
                local strArr  = string.split(describe,"\n") or {}
                for i, v in pairs(strArr) do
                    local richText = QRichText.new(v, 600, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
                    richText:setAnchorPoint(ccp(0, 1))
                    richText:setPositionY(-height)
                    self._scrollView:addItemBox(richText)
                    height = height + richText:getContentSize().height
                end
            end
        end
    end
    self._scrollView:setRect(0, -height, 0, 0)
end

function QUIDialogMockBattleMountCardInfo:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogMockBattleMountCardInfo:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogMockBattleMountCardInfo:_onTriggerGet(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_get) == false then return end
	app.sound:playSound("common_common")
    self:playEffectOut()
end

function QUIDialogMockBattleMountCardInfo:_onTriggerSkillInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_skill_info) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountSkill", 
        options = {mountId = self._mountId , isMockbattle = true , id = self._id}})
end

function QUIDialogMockBattleMountCardInfo:_backClickHandler()
	self:playEffectOut()
end 

function QUIDialogMockBattleMountCardInfo:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogMockBattleMountCardInfo
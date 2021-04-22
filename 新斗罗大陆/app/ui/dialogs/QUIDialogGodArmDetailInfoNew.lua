-- @Author: liaoxianbo
-- @Date:   2019-12-24 11:04:18
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-13 11:17:00
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGodArmDetailInfoNew = class("QUIDialogGodArmDetailInfoNew", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")

function QUIDialogGodArmDetailInfoNew:ctor(options)
	local ccbFile = "ccb/Dialog_Godarm_xiangqing.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
		{ccbCallbackName = "onTriggerSkillInfo", callback = handler(self, self._onTriggerSkillInfo)},
    }
    QUIDialogGodArmDetailInfoNew.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._godarmId = options.godarmId 
    self._isTips = options.isTips
    self._params = options.params or {}

    if self._isTips then
        self._ccbOwner.tf_ok_name:setString("确  定")
    end

	-- skill scroll view
    local size = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, size, {bufferMode = 1})
    self._scrollView:setVerticalBounce(true)
   	self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
   	self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))

    self:setGodarmInfo()

end

function QUIDialogGodArmDetailInfoNew:viewDidAppear()
	QUIDialogGodArmDetailInfoNew.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogGodArmDetailInfoNew:viewWillDisappear()
  	QUIDialogGodArmDetailInfoNew.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogGodArmDetailInfoNew:setGodarmInfo()
    self._godarmConfig = db:getCharacterByID(self._godarmId)
    self._godarmInfo = remote.godarm:getGodarmById(self._godarmId)
    self._ccbOwner.frame_tf_title:setString(self._godarmConfig.name or "")
    self._ccbOwner.tf_desc:setVisible(false)

    local desc = self._godarmConfig.brief or ""
	local itemContentSize = self._ccbOwner.desc_sheet_layout:getContentSize()
    local scrollView = QScrollView.new(self._ccbOwner.desc_sheet, itemContentSize, {bufferMode = 0})
    scrollView:setVerticalBounce(true)
	local text = QColorLabel:create(desc, 330, nil, nil, 20, GAME_COLOR_LIGHT.normal)
	text:setAnchorPoint(ccp(0, 1))
	local totalHeight = text:getContentSize().height
	scrollView:addChild(text)
	scrollView:setRect(0, -totalHeight, 0, 0)

    -- hero avatar
    local avatar = QUIWidgetActorDisplay.new(self._godarmId)
    self._ccbOwner.node_avatar:addChild(avatar)
    self._ccbOwner.node_avatar:setScaleX(-0.7)
    self._ccbOwner.node_avatar:setScaleY(0.7)
        
	-- hero quality
    local aptitudeInfo = db:getActorSABC(self._godarmId)
    self._ccbOwner.hero_qulity:setString(aptitudeInfo.qc.."级")

    local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
	self._ccbOwner.frame_tf_title:setColor(fontColor)
    self._ccbOwner.frame_tf_title = setShadowByFontColor(self._ccbOwner.frame_tf_title, fontColor)


    local jobIconPath = remote.godarm:getGodarmJobPath(self._godarmConfig.label)
    if jobIconPath then
        QSetDisplaySpriteByPath(self._ccbOwner.sp_jobType,jobIconPath)
    end

    local jobIconBgPath = remote.godarm:getGodarmJobBgPath(self._godarmConfig.label)
    if jobIconBgPath then
        QSetDisplaySpriteByPath(self._ccbOwner.sp_jobType_bg,jobIconBgPath)
    end
    self._ccbOwner.tf_jobType:setString(self._godarmConfig.label.."神器")



	self:setSABC()
	self:setPieceNum()
    self:setSkillInfo()
end

function QUIDialogGodArmDetailInfoNew:setSABC()
    local aptitudeInfo = db:getActorSABC(self._godarmId)
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

function QUIDialogGodArmDetailInfoNew:setPieceNum()
	-- 默认显示1星
	local grade = 0
    self._ccbOwner.tf_num_name:setString("合成碎片：")
	if self._godarmInfo then
		grade = self._godarmInfo.grade+1
        self._ccbOwner.tf_num_name:setString("升星碎片：")
	end

	local numWord = ""
	local info = db:getGradeByHeroActorLevel(self._godarmId, grade) or {}
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

function QUIDialogGodArmDetailInfoNew:setSkillInfo()
	-- 默认显示5星
	local grade = 4
	if self._godarmInfo then
		grade = self._godarmInfo.grade
	end

    local height = 0
    local gradeConfig = db:getGradeByHeroActorLevel(self._godarmId, grade)
    if gradeConfig then
        if gradeConfig.god_arm_skill_sz then
	        local skillIds = string.split(gradeConfig.god_arm_skill_sz, ":")
	        local skillConfig1 = db:getSkillByID(tonumber(skillIds[1]))
	        if skillConfig1 then  
	        	local strArray = {} 
            	table.insert(strArray,{oType = "img", fileName = "ui/update_godarm/sp_shenqijineng.png"})
            	table.insert(strArray,{oType = "font", content = skillConfig1.name,size = 20,color = COLORS.k})  	
	            local describe = "：##n"..(skillConfig1.description or "")
	            describe = QColorLabel.removeColorSign(describe)
	            local strArr  = string.split(describe,"\n") or {}
	            for i, v in pairs(strArr) do
	            	table.insert(strArray,{oType = "font", content = v,size = 20,color = COLORS.j})
	            end
                local richText = QRichText.new(strArray, 600, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20,lineSpacing = 4})
                richText:setAnchorPoint(ccp(0, 1))
                richText:setPositionY(-height)
                self._scrollView:addItemBox(richText)
                height = height + richText:getContentSize().height	            
	        end
        end


        if gradeConfig.god_arm_skill_yz then
            local skillIds = string.split(gradeConfig.god_arm_skill_yz, ":")
            local skillConfig1 = db:getSkillByID(tonumber(skillIds[1]))          
            local height1 = 0
            if skillConfig1 ~= nil then
            	local strArray = {}
            	table.insert(strArray,{oType = "img", fileName = "ui/update_godarm/sp_yuanzhujineng.png"})
            	table.insert(strArray,{oType = "font", content = skillConfig1.name,size = 20,color = COLORS.k})
                local describe = ":"..skillConfig1.description or ""
                describe = QColorLabel.removeColorSign(describe)
                local strArr  = string.split(describe,"\n") or {}
                for i, v in pairs(strArr) do
                	table.insert(strArray,{oType = "font", content = v,size = 20,color = COLORS.j})
                end
                local richText = QRichText.new(strArray, 600, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
                richText:setAnchorPoint(ccp(0, 1))
                richText:setPositionY(-height)
                self._scrollView:addItemBox(richText)
                height = height + richText:getContentSize().height
            end
        end
    end
    self._scrollView:setRect(0, -height, 0, 0)
end


function QUIDialogGodArmDetailInfoNew:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogGodArmDetailInfoNew:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogGodArmDetailInfoNew:_onTriggerGet(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_get) == false then return end
	app.sound:playSound("common_common")

    if self._isTips then
        self:playEffectOut()
    else
        self:viewAnimationOutHandler()
	    QQuickWay:addQuickWay(QQuickWay.HERO_DROP_WAY, self._godarmId, nil, nil, false)
    end
end

function QUIDialogGodArmDetailInfoNew:_onTriggerSkillInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_skill_info) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmSkillView", 
        options = {godarmId = self._godarmId}})
end

function QUIDialogGodArmDetailInfoNew:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGodArmDetailInfoNew:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogGodArmDetailInfoNew

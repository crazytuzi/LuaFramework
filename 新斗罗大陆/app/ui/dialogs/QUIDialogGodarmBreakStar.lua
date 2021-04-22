-- @Author: liaoxianbo
-- @Date:   2019-12-25 19:59:19
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-13 13:52:26
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGodarmBreakStar = class("QUIDialogGodarmBreakStar", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGodarmBox = import("..widgets.QUIWidgetGodarmBox")	
local QScrollView = import("...views.QScrollView")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")
local QActorProp = import("...models.QActorProp")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogGodarmBreakStar:ctor(options)
	local ccbFile = "ccb/Dialog_Godarm_breakstar.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSkillInfo", callback = handler(self,self._onTriggerSkillInfo)},
		{ccbCallbackName = "onTriggerAdvance", callback = handler(self,self._onTriggerAdvance)},
    }
    QUIDialogGodarmBreakStar.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._godarmId = options.godarmId
    self._godarmConfig = db:getCharacterByID(self._godarmId)
    self._scrollView = nil
    self._isAdvanceFlag = false
    self:initScrollView()
    self:setGodarmBreakInfo()
end

function QUIDialogGodarmBreakStar:viewDidAppear()
	QUIDialogGodarmBreakStar.super.viewDidAppear(self)
	self:addBackEvent(true)
    self._godarmProxy = cc.EventProxy.new(remote.godarm)
    self._godarmProxy:addEventListener(remote.godarm.GODARM_EVENT_UPDATE, handler(self, self.setGodarmBreakInfo))

end


function QUIDialogGodarmBreakStar:viewAnimationInHandler()
    --代码
    --弹出动画需要在动画后重置点击区域位置
    if  self._scrollView then
        self._scrollView:resetTouchRect()
    end
end


function QUIDialogGodarmBreakStar:viewWillDisappear()
  	QUIDialogGodarmBreakStar.super.viewWillDisappear(self)

	self:removeBackEvent()
	self._godarmProxy:removeAllEventListeners()
end


function QUIDialogGodarmBreakStar:initScrollView()
    if self._scrollView == nil then
        local size = self._ccbOwner.sheet_layout:getContentSize()
        self._scrollView = QScrollView.new(self._ccbOwner.sheet, size, {bufferMode = 1})
        self._scrollView:setVerticalBounce(true)
        self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
        self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    end
    self._scrollView:clearCache()

end

function QUIDialogGodarmBreakStar:showBreakMax(state)
	self._ccbOwner.nodemax:setVisible(state)
	self._ccbOwner.node_notMax:setVisible(not state)
end

function QUIDialogGodarmBreakStar:setGodarmBreakInfo( )
    local aptitudeInfo = db:getActorSABC(self._godarmId)
    self._godarmInfo = remote.godarm:getGodarmById(self._godarmId)
    QPrintTable( self._godarmInfo)
    if self._godarmInfo and self._godarmInfo.grade == 4 then
        self._ccbOwner.node_skill:setPositionY(28)
        if  self._scrollView then
            self._scrollView:resetTouchRect()
        end
    else
        self._ccbOwner.node_skill:setPositionY(-25)
    end

    local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
    local grade = self._godarmInfo.grade or 0
    if self._godarmInfo and self._godarmInfo.grade == 4 then
    	self:showBreakMax(true)
    	self:showSkillInfo(true)
    	self:showGodarmPropValue(true)
    	self._ccbOwner.hero_name_max:setString(self._godarmConfig.name.."("..(grade + 1).."星）")
        self._ccbOwner.hero_name_max:setColor(fontColor)
        self._ccbOwner.hero_name_max = setShadowByFontColor(self._ccbOwner.hero_name_max, fontColor)        
    	if self._godarmMaxBox == nil then
    		self._godarmMaxBox = QUIWidgetGodarmBox.new()
    		self._ccbOwner.node_godarm_max:addChild(self._godarmMaxBox)
    	end
    	self._godarmMaxBox:setGodarmInfo(self._godarmInfo)

    else
    	self:showBreakMax(false)
    	self:showGodarmPropValue()
    	self:setPieceNum()
    	self:showSkillInfo(false)
    	self._ccbOwner.hero_name1:setString(self._godarmConfig.name.."("..(grade + 1).."星）")
    	self._ccbOwner.hero_name2:setString(self._godarmConfig.name.."("..(grade + 2).."星）")
        self._ccbOwner.hero_name1:setColor(fontColor)
        self._ccbOwner.hero_name1 = setShadowByFontColor(self._ccbOwner.hero_name1, fontColor)
        self._ccbOwner.hero_name2:setColor(fontColor)
        self._ccbOwner.hero_name2 = setShadowByFontColor(self._ccbOwner.hero_name2, fontColor)
    	if self._godarmBox1 == nil then
    		self._godarmBox1 = QUIWidgetGodarmBox.new()
    		self._ccbOwner.node_godarm_1:addChild(self._godarmBox1)
    	end
    	self._godarmBox1:setGodarmInfo(self._godarmInfo)


    	if self._godarmBox2 == nil then
    		self._godarmBox2 = QUIWidgetGodarmBox.new()
    		self._ccbOwner.node_godarm_2:addChild(self._godarmBox2)
    	end
    	local nextGodInfo = clone(self._godarmInfo) 
    	nextGodInfo.grade = nextGodInfo.grade + 1
    	self._godarmBox2:setGodarmInfo(nextGodInfo) 

    end
end

function QUIDialogGodarmBreakStar:showGodarmPropValue(isMax)
	local curtentConfig = db:getGradeByHeroActorLevel(self._godarmId, self._godarmInfo.grade)
	local nextConfig = db:getGradeByHeroActorLevel(self._godarmId, self._godarmInfo.grade+1)

    local propDic  = remote.godarm:getUIPropInfo(curtentConfig)
    local index = 1
	for i, prop in ipairs(propDic) do
		self._ccbOwner["tf_old_name"..index]:setString(prop.name)
		self._ccbOwner["tf_old_value"..index]:setString("+"..prop.value)
		index = index + 1
	end

    index = 1
    local nextProDic = remote.godarm:getUIPropInfo(nextConfig)
    for key, prop in pairs(nextProDic) do
        self._ccbOwner["tf_new_name"..index]:setString(prop.name)
        self._ccbOwner["tf_new_value"..index]:setString("+"..prop.value)
        index = index + 1
    end	
    if isMax then
     	index = 1
		for i, prop in ipairs(propDic) do
			self._ccbOwner["tf_max_name"..index]:setString(prop.name)
			self._ccbOwner["tf_max_value"..index]:setString("+"..prop.value)
			index = index + 1
		end   	
    end
end
function QUIDialogGodarmBreakStar:showSkillInfo( isMax)
	self._scrollView:clear(true)
	-- 默认显示5星
	local grade = 0
	if self._godarmInfo then
		grade = self._godarmInfo.grade + 1
        if isMax then
            grade = self._godarmInfo.grade
        end
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
                local richText = QRichText.new(strArray, 600, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20,lineSpacing = 4})
                richText:setAnchorPoint(ccp(0, 1))
                richText:setPositionY(-height)
                self._scrollView:addItemBox(richText)
                height = height + richText:getContentSize().height
            end
        end
    end
    self._scrollView:setRect(0, -height, 0, 0)
end


function QUIDialogGodarmBreakStar:setPieceNum()
	-- 默认显示1星
	local grade = 0
	if self._godarmInfo then
		grade = self._godarmInfo.grade
	end

	local numWord = ""
	local info = db:getGradeByHeroActorLevel(self._godarmId, grade+1) or {}

    local needNum = info.soul_gem_count or 0
    local currentNum = remote.items:getItemsNumByID(info.soul_gem) or 0
    if needNum > 0 then

        numWord = currentNum.."/"..needNum
    
    	local curProportion = currentNum/needNum
    	if currentNum >= needNum then
            self._isAdvanceFlag = true
    		curProportion = 1
        else
            self._isAdvanceFlag = false
    	end
    	self._ccbOwner.sp_bar_progress:setScaleX(curProportion)
    	-- stencil:setPositionX(-self._totalStencilWidth + curProportion*self._totalStencilWidth)        
    else
        self._isAdvanceFlag = false
        numWord = currentNum
        self._ccbOwner.sp_bar_progress:setScaleX(1)
    end
	self._ccbOwner.tf_progress:setString(numWord)

    if self._itemBox == nil then
        self._itemBox = QUIWidgetItemsBox.new()
        self._ccbOwner.node_icon:addChild(self._itemBox)
    end
    self._itemBox:setGoodsInfo(info.soul_gem, ITEM_TYPE.ITEM, 0)
end

function QUIDialogGodarmBreakStar:_onScrollViewBegan( ... )
	self._isMoving = false
end

function QUIDialogGodarmBreakStar:_onScrollViewMoving( ... )
	self._isMoving = true
end


function QUIDialogGodarmBreakStar:_onTriggerSkillInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_skill_info) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmSkillView", 
        options = {godarmId = self._godarmId}})
end

function QUIDialogGodarmBreakStar:_onTriggerAdvance( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_advance) == false then return end
    app.sound:playSound("common_small")
    if not self._isAdvanceFlag then
        QQuickWay:addQuickWay(QQuickWay.HERO_DROP_WAY, self._godarmId, nil, nil, false)
        return
    end
    local godarmId = self._godarmId
    remote.godarm:godarmGradeUpRequest(godarmId,function(data)
        local godArmInfo = remote.godarm:getGodarmById(godarmId)
        local godArmGrade = godArmInfo.grade or 0
        local valueTbl = {}
        valueTbl[godarmId] = godArmGrade + 1
        remote.activity:updateLocalDataByType(713, valueTbl)
        
		if self:safeCheck()	then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmGradeSuccess",
				options = { godarmId = self._godarmId, callback = function ()
					remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
				end}},{isPopCurrentDialog = false})
		end
    end)
end
function QUIDialogGodarmBreakStar:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end	
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGodarmBreakStar:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogGodarmBreakStar

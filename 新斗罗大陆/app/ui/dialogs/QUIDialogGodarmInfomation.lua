-- @Author: liaoxianbo
-- @Date:   2019-12-24 17:15:06
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-13 11:24:56
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGodarmInfomation = class("QUIDialogGodarmInfomation", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGodarmIntroduce = import("..widgets.QUIWidgetGodarmIntroduce")
local QUIWidgetGodarmStrength = import("..widgets.QUIWidgetGodarmStrength")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QQuickWay = import("...utils.QQuickWay")

QUIDialogGodarmInfomation.TAB_DETAILS = "TAB_DETAILS"
QUIDialogGodarmInfomation.TAB_STRENGTH = "TAB_STRENGTH"

function QUIDialogGodarmInfomation:ctor(options)
	local ccbFile = "ccb/Dialog_Godarm_Information.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggereRight)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggereLeft)},
        {ccbCallbackName = "onTriggerDetails", callback = handler(self, self._onTriggerDetails)}, --打开详情
        {ccbCallbackName = "onTriggerStrength", callback = handler(self, self._onTriggerStrength)}, --点击强化
        {ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)}, 
        {ccbCallbackName = "onShowMax",callback = handler(self,self._onShowMax)},
        {ccbCallbackName = "onAwake", callback = handler(self,self._onAwake)},
        {ccbCallbackName = "onTriggerMaster", callback = handler(self,self._onTriggerMaster)},
    }
    QUIDialogGodarmInfomation.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    -- page.topBar:showWithGodarm()
    page.topBar:showWithHeroOverView()

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    ui.tabButton(self._ccbOwner.tab_details, "详情")
    ui.tabButton(self._ccbOwner.tab_strength, "强化")
    self._tabManager = ui.tabManager({self._ccbOwner.tab_details,self._ccbOwner.tab_strength})
    self._curtentTab = options.tab or QUIDialogGodarmInfomation.TAB_DETAILS
 	self._godarmId = options.godarmId

    self._statusWidth = self._ccbOwner.status_bar:getContentSize().width
    self._haveGodArmIds = options.godArmIds or remote.godarm:getHaveGodarmIdList()
    -- local godarmIdList = remote.godarm:getHaveGodarmIdList()
    -- if #godarmIdList <= 1 then
    --     self._ccbOwner.node_right:setVisible(false)
    --     self._ccbOwner.node_left:setVisible(false)
    -- end
    if #self._haveGodArmIds <= 1 then
        self._ccbOwner.node_right:setVisible(false)
        self._ccbOwner.node_left:setVisible(false)
    end



    -- -- 初始化进度条
    -- if not self._percentBarClippingNode then
    --     self._totalStencilPosition = self._ccbOwner.status_bar:getPositionX() -- 这个坐标必须sp_exp_bar节点的锚点为(0, 0.5)
    --     self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.status_bar)
    --     self._totalStencilWidth = self._ccbOwner.status_bar:getContentSize().width * self._ccbOwner.status_bar:getScaleX()
    -- end
 
 	self:showGodarmInformation()
	self:setSecletTab(self._curtentTab)

end

function QUIDialogGodarmInfomation:viewDidAppear()
	QUIDialogGodarmInfomation.super.viewDidAppear(self)
	self:addBackEvent(true)

    self._godarmProxy = cc.EventProxy.new(remote.godarm)
    self._godarmProxy:addEventListener(remote.godarm.GODARM_EVENT_UPDATE, handler(self, self.showGodarmInformation))
end

function QUIDialogGodarmInfomation:viewWillDisappear()
  	QUIDialogGodarmInfomation.super.viewWillDisappear(self)

	self:removeBackEvent()
	self._godarmProxy:removeAllEventListeners()
end

function QUIDialogGodarmInfomation:changeBackGround()
    if self._godarmConfig.aptitude == APTITUDE.SS then
        self._ccbOwner.sp_background_3:setVisible(true)
        self._ccbOwner.sp_background_2:setVisible(false)
        self._ccbOwner.sp_background_1:setVisible(false)
        self._ccbOwner.node_super_3:setVisible(true)
        self._ccbOwner.node_super_2:setVisible(false)   
        self._ccbOwner.node_super_1:setVisible(false)     
    elseif self._godarmConfig.aptitude == APTITUDE.S then
        self._ccbOwner.sp_background_3:setVisible(false)
        self._ccbOwner.sp_background_2:setVisible(true)
        self._ccbOwner.sp_background_1:setVisible(false)  
        self._ccbOwner.node_super_3:setVisible(false)
        self._ccbOwner.node_super_2:setVisible(true)   
        self._ccbOwner.node_super_1:setVisible(false)           
    else
        self._ccbOwner.sp_background_3:setVisible(false)
        self._ccbOwner.sp_background_2:setVisible(false)
        self._ccbOwner.sp_background_1:setVisible(true)  
        self._ccbOwner.node_super_3:setVisible(false)
        self._ccbOwner.node_super_2:setVisible(false)   
        self._ccbOwner.node_super_1:setVisible(true)                 
    end      
end

function QUIDialogGodarmInfomation:setSecletTab( tabType)
	self._curtentTab = tabType
	if self._curtentTab == QUIDialogGodarmInfomation.TAB_DETAILS then
		self._tabManager:selected(self._ccbOwner.tab_details)
        if self._introduce == nil then
            self._introduce = QUIWidgetGodarmIntroduce.new()
            self._introduce:setGodarmId(self._godarmId)
            self._ccbOwner.node_herointroduce:addChild(self._introduce,-1)
        elseif self._introduceNeedRefresh then
        	self._introduce:setGodarmId(self._godarmId)
        end
        self._introduceNeedRefresh = false
        self:_switchDetailForAnimation(self._introduce)
	elseif self._curtentTab == QUIDialogGodarmInfomation.TAB_STRENGTH then
		self._tabManager:selected(self._ccbOwner.tab_strength)
		if self._strength == nil then
			self._strength = QUIWidgetGodarmStrength.new({parent = self})
			self._strength:setGodarmStrengthInfo(self._godarmId)
			self._ccbOwner.node_herointroduce:addChild(self._strength,-1)
		elseif self._strengthNeedRefresh then
			self._strength:setGodarmStrengthInfo(self._godarmId)
		end
		self:_switchDetailForAnimation(self._strength)
		self._strengthNeedRefresh = false
	end
end

function QUIDialogGodarmInfomation:_switchDetailForAnimation(view)
    if view == nil then return end

    if self._detailView == nil then
        self._detailView = view
        self._detailView:setVisible(true)
        self._detailView:setPosition(0, 0)
    elseif self._detailView == view then
        return        
    else
        self._detailView:setVisible(false)
        self._detailView = view
        self._detailView:setVisible(true)
    end
end

function QUIDialogGodarmInfomation:showGodarmInformation()
    self._godarmConfig = db:getCharacterByID(self._godarmId)
    self._godarmInfo = remote.godarm:getGodarmById(self._godarmId)

    self:changeBackGround()
    self._ccbOwner.master_level:setString("Lv."..math.floor((self._godarmInfo.level or 1) / 10))
    -- hero avatar
   	self._ccbOwner.node_heroinformation:removeAllChildren()

    local jobIconPath = remote.godarm:getGodarmJobPath(self._godarmConfig.label)
    if jobIconPath then
        QSetDisplaySpriteByPath(self._ccbOwner.sp_jobType,jobIconPath)
    end

    local avatar = QUIWidgetActorDisplay.new(self._godarmId)
    self._ccbOwner.node_heroinformation:addChild(avatar)
    self._ccbOwner.node_heroinformation:setScaleX(-1)
    -- self._ccbOwner.node_heroinformation:setScale(self._godarmConfig.actor_scale or 1)

    self._ccbOwner.tf_level:setString("Lv."..(self._godarmInfo.level or 1))
    self._ccbOwner.tf_godarm_name:setString(self._godarmConfig.name or "")

    self._ccbOwner.lab_jobTitle:setString(self._godarmConfig.role_definition or "")

    self:setPieceNum()
    self:setSABC()

   
    if self._introduce ~= nil and self._curtentTab == QUIDialogGodarmInfomation.TAB_DETAILS then
    	print("-------_introduce------")
        self._introduce:setGodarmId(self._godarmId)
        self._introduceNeedRefresh = false
    elseif self._introduce then
        self._introduceNeedRefresh = true
    end

    if self._strength ~= nil and self._curtentTab == QUIDialogGodarmInfomation.TAB_STRENGTH then
        self._strength:setGodarmStrengthInfo(self._godarmId)
        self._strengthNeedRefresh = false
    elseif self._strength then
        self._strengthNeedRefresh = true
    end
end

function QUIDialogGodarmInfomation:setPieceNum()
	-- 默认显示1星
	local grade = 0
	if self._godarmInfo then
		grade = self._godarmInfo.grade
	end

	local numWord = ""
	local info = db:getGradeByHeroActorLevel(self._godarmId, grade + 1) or {}
	if next(info) ~= nil then
	    local needNum = info.soul_gem_count or 0
	    local currentNum = remote.items:getItemsNumByID(info.soul_gem) or 0
		-- local stencil = self._percentBarClippingNode:getStencil()    
	    if needNum > 0 then

	        numWord = currentNum.."/"..needNum
	    
	    	local curProportion = currentNum/needNum
	    	if currentNum > needNum then
	    		self._ccbOwner.node_tips_grade:setVisible(true)
	    		curProportion = 1
	    	else
	    		self._ccbOwner.node_tips_grade:setVisible(false)
	    	end
	    	self._ccbOwner.status_bar:setScaleX(curProportion)
	    	-- stencil:setPositionX(-self._totalStencilWidth + curProportion*self._totalStencilWidth)        
	    else
	        numWord = currentNum
	        self._ccbOwner.node_tips_grade:setVisible(false)
	        self._ccbOwner.status_bar:setScaleX(1)
	    end
		self._ccbOwner.status1_tf:setString(numWord)

	    if self._itemBox == nil then
	        self._itemBox = QUIWidgetItemsBox.new()
	        self._ccbOwner.node_icon:addChild(self._itemBox)
	    end
	    self._ccbOwner.node_icon:setVisible(true)
	    self._ccbOwner.btn_plus:setVisible(true)
        self._ccbOwner.btn_check:setVisible(false)
        self._ccbOwner.btn_grade:setVisible(true)        
	    self._itemBox:setGoodsInfo(info.soul_gem, ITEM_TYPE.ITEM, 0)
        self._ccbOwner.node_bar_status:setPositionX(-227)
	else
		self._ccbOwner.node_tips_grade:setVisible(false)
		self._ccbOwner.status1_tf:setString("已升星至上限")
		self._ccbOwner.node_icon:setVisible(false)
		self._ccbOwner.btn_plus:setVisible(false)
        self._ccbOwner.btn_check:setVisible(true)
        self._ccbOwner.btn_grade:setVisible(false)
        self._ccbOwner.status_bar:setScaleX(1)
        self._ccbOwner.node_bar_status:setPositionX(-190)
	end

    self:setGodarmStar(grade)
end

function QUIDialogGodarmInfomation:setSABC()
    local aptitudeInfo = db:getActorSABC(self._godarmId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)

    local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
	self._ccbOwner.tf_godarm_name:setColor(fontColor)
    self._ccbOwner.tf_godarm_name = setShadowByFontColor(self._ccbOwner.tf_godarm_name, fontColor)

    -- q.autoLayerNode({self._ccbOwner.tf_level,self._ccbOwner.tf_godarm_name},"x")
end

function QUIDialogGodarmInfomation:setGodarmStar(grade)
	local function addByOne(n)
		return n >= 0 and n + 1 or n - 1
	end
	local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(grade+1)
	print("starNum=",starNum)
	print("iconPath=",iconPath)
	if starNum == nil then return end

	if iconPath == "ui/common/one_star.png" then
		iconPath = "ui/common/one_star2.png"
	end
	local index = 3
	local ti = 0

	for i = 1, 5 do
		self._ccbOwner["heroStar_sprite_star" .. i]:setVisible(false)
	end
	self._ccbOwner.heroStar_nodeBigStar:setVisible(false)
	for i = 1, starNum do
		local displayFrame = QSpriteFrameByPath(iconPath)
		if displayFrame then
			self._ccbOwner["heroStar_sprite_star" .. index]:setDisplayFrame(displayFrame)
		end

		self._ccbOwner["heroStar_sprite_star" .. index]:setVisible(true)
		ti = -addByOne(ti)
		index = index + ti
	end
	self._ccbOwner.heroStar_nodeSmallStar:setVisible(true)
end

function QUIDialogGodarmInfomation:_onTriggerStrength()
	if self._curtentTab == QUIDialogGodarmInfomation.TAB_STRENGTH then 
		return
	end
	self._curtentTab = QUIDialogGodarmInfomation.TAB_STRENGTH
	self:setSecletTab(self._curtentTab)
end

function QUIDialogGodarmInfomation:_onTriggerDetails()
	if self._curtentTab == QUIDialogGodarmInfomation.TAB_DETAILS then 
		return
	end
	self._curtentTab = QUIDialogGodarmInfomation.TAB_DETAILS
	self:setSecletTab(self._curtentTab)
end

function QUIDialogGodarmInfomation:_onTriggereRight()
    app.sound:playSound("common_change")
    -- local haveGodarmList = remote.godarm:getHaveGodarmIdList()
    -- local n = table.nums(haveGodarmList)
    -- print("总个数=",n)
    -- self._pos = table.indexof(haveGodarmList, self._godarmId) or 1
    -- if nil ~= self._pos and n > 1 then
    --     self._pos = self._pos + 1
    --     if self._pos > n then
    --         self._pos = 1
    --     end
    --     local options = self:getOptions()
    --     options.godarmId = haveGodarmList[self._pos]
    --     self._godarmId = haveGodarmList[self._pos]

    --     self:showGodarmInformation()
    -- end


    local n = table.nums( self._haveGodArmIds)
    print("总个数=",n)
    self._pos = table.indexof( self._haveGodArmIds, self._godarmId) or 1
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos + 1
        if self._pos > n then
            self._pos = 1
        end
        local options = self:getOptions()
        options.godarmId =  self._haveGodArmIds[self._pos]
        self._godarmId =  self._haveGodArmIds[self._pos]

        self:showGodarmInformation()
    end

end

function QUIDialogGodarmInfomation:_onTriggereLeft()
    app.sound:playSound("common_change")
    -- local haveGodarmList = remote.godarm:getHaveGodarmIdList()
    -- local n = table.nums(haveGodarmList)
    -- print("Left 总个数=",n)
    -- self._pos = table.indexof(haveGodarmList, self._godarmId) or 1
    -- if nil ~= self._pos and n > 1 then
    --     self._pos = self._pos - 1
    --     if self._pos < 1 then
    --         self._pos = n
    --     end
    --     local options = self:getOptions()
    --     options.godarmId = haveGodarmList[self._pos]
    --     self._godarmId = haveGodarmList[self._pos]
   
    --     self:showGodarmInformation()
    -- end

    local n = table.nums(self._haveGodArmIds)
    print("Left 总个数=",n)
    self._pos = table.indexof(self._haveGodArmIds, self._godarmId) or 1
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos - 1
        if self._pos < 1 then
            self._pos = n
        end
        local options = self:getOptions()
        options.godarmId = self._haveGodArmIds[self._pos]
        self._godarmId = self._haveGodArmIds[self._pos]
   
        self:showGodarmInformation()
    end
    
end

function QUIDialogGodarmInfomation:_onTriggerMaster( event)
	app.sound:playSound("common_increase")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmMasterInfo", 
    	options={godarmId = self._godarmId}}, {isPopCurrentDialog = false})
end

function QUIDialogGodarmInfomation:_onPlus(event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
    app.sound:playSound("common_increase")
 	QQuickWay:addQuickWay(QQuickWay.HERO_DROP_WAY, self._godarmId, nil, nil, false)
end

function QUIDialogGodarmInfomation:_onShowMax( event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_check) == false then return end
    app.sound:playSound("common_increase")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmBreakStar", 
            options={godarmId = self._godarmId}}, {isPopCurrentDialog = false})    
end
function QUIDialogGodarmInfomation:_onAwake(event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_awake) == false then return end
    app.sound:playSound("common_increase")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmBreakStar", 
        	options={godarmId = self._godarmId}}, {isPopCurrentDialog = false})
end

function QUIDialogGodarmInfomation:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogGodarmInfomation

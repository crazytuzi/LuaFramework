local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityRate = class("QUIWidgetActivityRate", QUIWidget)
local QUIViewController = import("...ui.QUIViewController")
local QRichText = import("...utils.QRichText")
local QQuickWay = import("...utils.QQuickWay")
local QScrollView = import("...views.QScrollView")

function QUIWidgetActivityRate:ctor(options)
	local ccbFile = "ccb/Widget_ActivityTime.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
  	}
	QUIWidgetActivityRate.super.ctor(self,ccbFile,callBacks,options)
    -- CalculateUIBgSize(self._ccbOwner.node_big_title , 1280)

    self._btnPosY = self._ccbOwner.btn_go:getPositionY()
end

function QUIWidgetActivityRate:setInfo(info)
    self._info = info

    self._ccbOwner.sp_bg1:setVisible(true)        
    self._ccbOwner.sp_bg2:setVisible(true) 

    -- 国庆特殊处理颜色
    if self._info.title_icon == "activity_title_gqqd.jpg" or self._info.title_icon == "acitivity_11_2.jpg" then
        self._ccbOwner.sp_bg:setColor(ccc3(240,75,81))        
        self._ccbOwner.sp_bg1:setColor(ccc3(178,56,62))        
        self._ccbOwner.sp_bg2:setColor(ccc3(178,56,62))
    elseif self._info.title_icon == "activity_yuandan.png" or self._info.title_icon == "activity_title_labajie.png" then
        self._ccbOwner.sp_bg:setColor(ccc3(255,120,90))        
        self._ccbOwner.sp_bg1:setVisible(false)        
        self._ccbOwner.sp_bg2:setVisible(false)     
    elseif self._info.title_icon == "activity_yyz.png" then
        self._ccbOwner.sp_bg1:setColor(ccc3(137,43,192))        
        self._ccbOwner.sp_bg2:setColor(ccc3(137,43,192))
    elseif self._info.title_icon == "nvshenqingdian.png" then
        self._ccbOwner.sp_bg:setColor(ccc3(255,217,100))        
        self._ccbOwner.sp_bg1:setVisible(false)
        self._ccbOwner.sp_bg2:setVisible(false)
    elseif self._info.title_icon == "qingmingjie.png" then
        self._ccbOwner.sp_bg:setColor(ccc3(255,255,101))   
        self._ccbOwner.sp_bg1:setColor(ccc3(34,84,72))        
        self._ccbOwner.sp_bg2:setColor(ccc3(34,84,72))
    elseif self._info.title_icon == "dw_dwqd.jpg" then
        local namePath = "ui/Activity_game/zhongqiu_bj1.png"
        QSetDisplayFrameByPath(self._ccbOwner.sp_bg, namePath)
        self._ccbOwner.sp_bg1:setColor(ccc3(70,140,164))        
        self._ccbOwner.sp_bg2:setColor(ccc3(70,140,164))
        self._ccbOwner.tf_time_title:setColor(ccc3(255,235,173))
    elseif self._info.title_icon == "acitity_ksfmwld.jpg" then
        local namePath = "ui/Activity_game/zhongqiu_bj1.png"
        QSetDisplayFrameByPath(self._ccbOwner.sp_bg, namePath)
        self._ccbOwner.sp_bg1:setColor(ccc3(80,48,48))        
        self._ccbOwner.sp_bg2:setColor(ccc3(80,48,48))
        self._ccbOwner.tf_time_title:setColor(ccc3(255,235,173))
        setShadow5(self._ccbOwner.tf_time, ccc3(66,29,28))
    elseif self._info.title_icon == "xrkh.jpg" then
        self._ccbOwner.sp_bg1:setColor(ccc3(43,124,189))        
        self._ccbOwner.sp_bg2:setColor(ccc3(43,124,189))
        setShadow5(self._ccbOwner.tf_time_title, ccc3(25,79,162))
        setShadow5(self._ccbOwner.tf_time, ccc3(25,79,162))
    elseif self._info.title_icon == "znq2_bg.jpg" then
        self._ccbOwner.sp_bg:setColor(ccc3(255,160,255))        
        self._ccbOwner.sp_bg1:setColor(ccc3(142,0,74))        
        self._ccbOwner.sp_bg2:setColor(ccc3(142,0,74))
    else
        self._ccbOwner.sp_bg:setColor(ccc3(255,255,255))        
        self._ccbOwner.sp_bg1:setColor(ccc3(113,36,22))        
        self._ccbOwner.sp_bg2:setColor(ccc3(113,36,22))
    end

    local desc = info.description or ""
    local strArr  = string.split(desc,"\n") or {}
    local textNode = CCNode:create()
    local height = 10
    for i, v in pairs(strArr) do
        local richText = QRichText.new(v, 406, {stringType = 1, defaultColor = GAME_COLOR_SHADOW.normal, defaultSize = 22})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-height)
        textNode:addChild(richText)
        height = height + richText:getContentSize().height
    end
    textNode:setContentSize(CCSize(406, height))

    self._ccbOwner.sheet:removeAllChildren()
    self._ccbOwner.btn_go:setPositionY(self._btnPosY)
    if self._info.type == remote.activity.TYPE_ACTIVITY_FOR_RATE then
        self._ccbOwner.btn_go:setVisible(true)
        self._ccbOwner.btn_go:setPositionY(self._btnPosY+50)
        self._ccbOwner.sp_bg:setContentSize(CCSize(470, 160))
        textNode:setPositionY(height/2-80)
        self._ccbOwner.sheet:addChild(textNode)
    elseif self._info.title_icon == "jsj_dbj.jpg" then
        self._ccbOwner.btn_go:setVisible(false)
        self._ccbOwner.sp_bg:setVisible(false)
        self._ccbOwner.sp_bg1:setVisible(false)        
        self._ccbOwner.sp_bg2:setVisible(false)
        local posY = height/2-100
        if posY > 0 then
            posY = 0
        end
        textNode:setPositionY(posY)

        self._ccbOwner.sheet:setPositionY(self._ccbOwner.sheet:getPositionY()+3)
        local sheetSize = self._ccbOwner.sheet_layout1:getContentSize()
        sheetSize.height = 235
        self._scrollView = QScrollView.new(self._ccbOwner.sheet, sheetSize, {bufferMode = 1, sensitiveDistance = 10})
        self._scrollView:setVerticalBounce(true)
        self._scrollView:addItemBox(textNode)
        self._scrollView:setRect(0, -height, 0, 0)
    elseif self._info.targets and #self._info.targets == 0 then
        self._ccbOwner.btn_go:setVisible(false)
        self._ccbOwner.sp_bg:setContentSize(CCSize(470, 352))
        local posY = height/2-160
        if posY > 0 then
            posY = 0
        end
        textNode:setPositionY(posY)

        local sheetSize = self._ccbOwner.sheet_layout1:getContentSize()
        self._scrollView = QScrollView.new(self._ccbOwner.sheet, sheetSize, {bufferMode = 1, sensitiveDistance = 10})
        self._scrollView:setVerticalBounce(true)
        self._scrollView:addItemBox(textNode)
        self._scrollView:setRect(0, -height, 0, 0)
    else
        self._ccbOwner.btn_go:setVisible(true)
        self._ccbOwner.sp_bg:setContentSize(CCSize(470, 280))
        local posY = height/2-120
        if posY > 0 then
            posY = 0
        end
        textNode:setPositionY(posY)

        local sheetSize = self._ccbOwner.sheet_layout:getContentSize()
        self._scrollView = QScrollView.new(self._ccbOwner.sheet, sheetSize, {bufferMode = 1, sensitiveDistance = 10})
        self._scrollView:setVerticalBounce(true)
        self._scrollView:addItemBox(textNode)
        self._scrollView:setRect(0, -height, 0, 0)
    end

    local startTime = q.timeToMonthDayHourMin((info.start_at or 0)/1000)
    local endTime = q.timeToMonthDayHourMin((info.end_at or 0)/1000)
    local timeStr = string.format("%s～%s", startTime, endTime)
    self._ccbOwner.tf_time:setString(timeStr)
    
    -- 横幅背景
    if self._info.title_icon and not isChineseStr(self._info.title_icon)  then
        local bgPath = "ui/Activity_game/"..self._info.title_icon
        QSetDisplayFrameByPath(self._ccbOwner.sp_title_bg, bgPath)
    end
    CalculateUIBgSize(self._ccbOwner.sp_title_bg , self._ccbOwner.sp_title_bg:getContentSize().width)
    -- 横幅文字
    self._ccbOwner.sp_banner:setVisible(false)
    if self._info.banner and self._info.banner ~= "" then
        local namePath = "ui/Activity_game/"..self._info.banner
        QSetDisplayFrameByPath(self._ccbOwner.sp_banner, namePath)
        self._ccbOwner.sp_banner:setVisible(true)
    end 
end

function QUIWidgetActivityRate:setBannerPos(posX, posY)
    self._ccbOwner.sp_banner:setPosition(ccp(posX, posY))
end

 -- *      600 普通副本碎片掉落翻倍
 -- *      601 普通副本金魂币掉落翻倍
 -- *      602 精英副本碎片掉落翻倍
 -- *      603 精英副本金魂币掉落翻倍
 -- *      604 活动试炼进入次数翻倍
 -- *      605 活动试炼掉落翻倍
 -- *      606 斗魂场币翻倍
 -- *      607 雷电印记翻倍
 -- *      608 雷电王座宝箱产出翻倍
 -- *      609 太阳井币翻倍
 -- *      610 太阳井宝箱产出翻倍
 -- *      611 魂师大赛币翻倍
 -- *      612 魂师大赛宝箱产出翻倍
 -- *      613 酒馆高级召唤打折
 -- *      614 酒馆豪华召唤打折
 -- *      701 普通副本材料掉落翻倍
 -- *      702 宗门翻倍
function QUIWidgetActivityRate:_onTriggerGo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
    if self._info.targets == nil or self._info.targets[1] == nil or self._info.targets[1].type == nil then
        return
    end
    if self._info.targets[1].type == 600 then
		QQuickWay:instanceNormal()
    elseif self._info.targets[1].type == 601 then
        QQuickWay:instanceNormal()
    elseif self._info.targets[1].type == 602 then
        if app.unlock:getUnlockElite(true) == false then return end
        QQuickWay:instanceElite()
    elseif self._info.targets[1].type == 603 then
        if app.unlock:getUnlockElite(true) == false then return end
        QQuickWay:instanceElite()
    elseif self._info.targets[1].type == 604 then
        if app.unlock:getUnlockTimeTransmitter(true) == false then return end
        QQuickWay:tiemMachineQuickWay()
    elseif self._info.targets[1].type == 605 then
        if app.unlock:getUnlockTimeTransmitter(true) == false then return end
        QQuickWay:tiemMachineQuickWay()
    elseif self._info.targets[1].type == 606 then
        if app.unlock:getUnlockArena(true) == false then return end
        QQuickWay:arena()
    elseif self._info.targets[1].type == 607 then
        if app.unlock:getUnlockThunder(true) == false then return end
        QQuickWay:thunder()
    elseif self._info.targets[1].type == 608 then
        if app.unlock:getUnlockThunder(true) == false then return end
        QQuickWay:thunder()
    elseif self._info.targets[1].type == 609 then
        if app.unlock:getUnlockSunWar(true) == false then return end
        QQuickWay:sunWellQuickWay()
    elseif self._info.targets[1].type == 610 then
        if app.unlock:getUnlockSunWar(true) == false then return end
        QQuickWay:sunWellQuickWay()
    elseif self._info.targets[1].type == 611 then
        if app.unlock:getUnlockGloryTower(true) == false then return end
        QQuickWay:openGloryTower()
    elseif self._info.targets[1].type == 612 then
        if app.unlock:getUnlockGloryTower(true) == false then return end
        QQuickWay:openGloryTower()
    elseif self._info.targets[1].type == 613 then
        if app.unlock:getUnlockDirectionalTavern(true) == false then return end
        QQuickWay:tavernQuickWay()
    elseif self._info.targets[1].type == 614 then
        if app.unlock:getUnlockDirectionalTavern(true) == false then return end
        QQuickWay:tavernQuickWay()
    elseif self._info.targets[1].type == 701 then
        QQuickWay:instanceNormal()
    elseif self._info.targets[1].type == 702 then
        if app.unlock:checkLock("UNLOCK_UNION", true) == false then return end
        QQuickWay:openUnion()
    end
end

return QUIWidgetActivityRate
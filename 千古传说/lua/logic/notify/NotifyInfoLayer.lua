
local NotifyInfoLayer = class("NotifyInfoLayer", BaseLayer)

function NotifyInfoLayer:ctor()
    self.super.ctor(self)
   
    self:init("lua.uiconfig_mango_new.notify.NotifyLayer")

    self.selectInfoBtn = nil
    local btnIndex = 2--NotifyManager.selectBtnIndex
    self:infoBtnClickHandle(self.infoBtnList[btnIndex], btnIndex)
end

function NotifyInfoLayer:initUI(ui)
    self.super.initUI(self,ui)

    -- 1 战斗 2 系统
    self.infoBtnList = {}
    self.infoBtnList[1] = TFDirector:getChildByPath(ui, 'notifyBtn1')
    self.infoBtnList[2] = TFDirector:getChildByPath(ui, 'notifyBtn2')
    self.infoBtnList[3] = TFDirector:getChildByPath(ui, 'notifyBtn3')

    self.infoBgImg = TFDirector:getChildByPath(ui, 'listPanel')
    self.bgImg = TFDirector:getChildByPath(ui, 'bg')

    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.Notify,{HeadResType.COIN,HeadResType.SYCEE})


    self.btn_yjlq = TFDirector:getChildByPath(ui, 'btn_yjlq')
    self.btn_scyd = TFDirector:getChildByPath(ui, 'btn_scyd')
end

function NotifyInfoLayer:onShow()
    self.super.onShow(self)
    if self.currentLayer then
        self.currentLayer:onShow()
    end
    self.generalHead:onShow();
    
    CommonManager:setRedPoint(self.infoBtnList[1], NotifyManager:isHaveUnReadMailForType(1),"isHaveUnReadMailForType1",ccp(10,10))
    CommonManager:setRedPoint(self.infoBtnList[2], NotifyManager:isHaveUnReadMailForType(2),"isHaveUnReadMailForType2",ccp(10,10))
end

function NotifyInfoLayer:registerEvents(ui)
    self.super.registerEvents(self)

    for i=1,#self.infoBtnList do
        self.infoBtnList[i]:addMEListener(TFWIDGET_CLICK, 
        audioClickfun(function () 
            self:infoBtnClickHandle(self.infoBtnList[i], i)
        end))
    end

    if self.generalHead then
        self.generalHead:registerEvents()
    end



    self.btn_yjlq.logic = self
    self.btn_yjlq:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikGetEmailReward))


    self.btn_scyd.logic = self
    self.btn_scyd:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikDelEmail))
end


function NotifyInfoLayer:removeEvents()
    self.super.removeEvents(self)

    if self.generalHead then
        self.generalHead:removeEvents()
    end
end
function NotifyInfoLayer:removeUI()
    self.super.removeUI(self)
end

function NotifyInfoLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end


function NotifyInfoLayer:infoBtnClickHandle(btn, btnIndex)
    if btn == self.selectInfoBtn then
        return
    end
    TFWebView.removeWebView()
    if self.selectInfoBtn ~= nil then
        self.selectInfoBtn:setTextureNormal("ui_new/notify/notifybtn"..NotifyManager.selectBtnIndex..".png")
    end

    NotifyManager.selectBtnIndex = btnIndex
    self.selectInfoBtn = btn

    btn:setTextureNormal("ui_new/notify/notifybtn"..btnIndex.."_c.png")
    
    if btnIndex == 1 and NotifyManager:needSendFightNotify() then
        NotifyManager:SendQueryMsg(c2s.QUERY_FIGHT_NOTIFY)
    elseif btnIndex == 2 and NotifyManager:needSendSystemNotify() then
        NotifyManager:SendQueryMsg(c2s.QUERY_SYSTEM_NOTIFY)
    elseif btnIndex == 3 then
        if HeitaoSdk then
            local platformid = HeitaoSdk.getplatformId()
            local notice_url = "http://smi.heitao.com/mhqx/affiche?pfid="..platformid
            local designsize = CCDirector:sharedDirector():getOpenGLView():getDesignResolutionSize()
            local newx = (designsize.width - 960) / 2 + 185
            local newy = 100
            TFWebView.showWebView(notice_url, newx, 120, 735, 400)
        end
        self:RefreshUI()
        return
    else
        self:RefreshUI()
    end

    NotifyManager:onIntoMailLayer(btnIndex);
    CommonManager:setRedPoint(self.infoBtnList[1], NotifyManager:isHaveUnReadMailForType(1),"isHaveUnReadMailForType1",ccp(10,10))
    CommonManager:setRedPoint(self.infoBtnList[2], NotifyManager:isHaveUnReadMailForType(2),"isHaveUnReadMailForType2",ccp(10,10))

    local bShowButton = false
    if btnIndex == 2 and self.numberOfCellsInTableView() > 0 then
        bShowButton = true
    end

    self.btn_yjlq:setVisible(bShowButton)
    self.btn_scyd:setVisible(bShowButton)
end

function NotifyInfoLayer:RefreshUI()
    if self.infoList == nil then
        self.infoList = TFTableView:create()
        self.infoList.logic = self
        self.infoList:setTableViewSize(self.infoBgImg:getSize())
        self.infoList:setDirection(TFTableView.TFSCROLLVERTICAL)
        self.infoList:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)

        self.infoList:addMEListener(TFTABLEVIEW_SIZEFORINDEX, NotifyInfoLayer.cellSizeForTable)
        self.infoList:addMEListener(TFTABLEVIEW_SIZEATINDEX, NotifyInfoLayer.tableCellAtIndex)
        self.infoList:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, NotifyInfoLayer.numberOfCellsInTableView)
        self.infoBgImg:addChild(self.infoList)
    end
    
    self.infoList:reloadData()

    local bShowButton = true
    if self.numberOfCellsInTableView() == 0 then
        if self.emptyImg == nil then
            self.emptyImg = TFImage:create("ui_new/notify/empty.png")
            self.emptyImg:setPosition(ccp(0, -36))
            self.emptyImg:setZOrder(100)
            self.bgImg:addChild(self.emptyImg)
        end
        self.emptyImg:setVisible(true)    

        bShowButton = false
    else
        if self.emptyImg ~= nil then
            self.emptyImg:setVisible(false)
        end
    end

    if NotifyManager.selectBtnIndex == 3 then
        if self.emptyImg ~= nil then
            self.emptyImg:setVisible(false)
        end
    end
    self.btn_yjlq:setVisible(bShowButton)
    self.btn_scyd:setVisible(bShowButton)
end

function NotifyInfoLayer.cellSizeForTable(table,idx)
    return 135,755
end

function NotifyInfoLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = TFTableViewCell:create()
    else
        cell:removeAllChildren()
    end

    if NotifyManager.selectBtnIndex == 1 then
        table.logic:SetFightNotifyCell(cell, idx)
    elseif NotifyManager.selectBtnIndex == 2 then
        table.logic:SetSystemNotifyCell(cell, idx)
    end

    return cell
end

function GetTimeString(totalSecond)
    local hour = math.floor(totalSecond/3600)
    local min = math.floor((totalSecond - hour*3600)/60)
    local day = math.floor(hour/24)

    local string = ""

    if day > 0 then
        --string = string..day.."天前"
        string = string.. stringUtils.format(localizable.common_day_befor,day)
    end

    if hour > 0 and day == 0 then
        --string = string..hour.."小时前"
        string = string..stringUtils.format(localizable.common_hour_befor,hour)        
    end

    -- if min > 0 and hour == 0 then
    --     string = string..min.."分钟前"
    -- end

    if hour == 0 then
        if min > 0 then
            --string = string..min.."分钟前"
            string = string..stringUtils.format(localizable.common_min_befor,min)
        else
            --string = "刚刚"
            string = localizable.common_justnow
        end
    end


    return string
end

function NotifyInfoLayer:SetFightNotifyCell(cell, cellIndex)
    local notifyInfo = NotifyManager.fightNotifyList:objectAt(cellIndex+1)
    if notifyInfo == nil then
        return
    end

    local notifyBgImage = TFImage:create("ui_new/notify/xx_tianmu_iocn.png")
    notifyBgImage:setPosition(ccp(375, 60))
    cell:addChild(notifyBgImage)

    local notifyTypeBg = TFImage:create("ui_new/common/icon_bg/pz_bg_ding_118.png")
    notifyTypeBg:setPosition(ccp(70, 60))
    cell:addChild(notifyTypeBg)

    local fightTypeImage = nil
    if notifyInfo.fightType == 3 then
        fightTypeImage = TFImage:create("ui_new/notify/xx_qunhao_icon.png")
    elseif notifyInfo.fightType == 4 then
        fightTypeImage = TFImage:create("ui_new/notify/xx_baozang_icon.png")
    end
    notifyTypeBg:addChild(fightTypeImage)

    local timeBgImage = TFImage:create("ui_new/notify/timebg.png")
    timeBgImage:setPosition(ccp(0, -40))
    notifyTypeBg:addChild(timeBgImage)

    local totalSecond = GetGameTime() - math.floor(notifyInfo.time/1000)
    local timeLabel = TFLabel:create()
    timeLabel:setFontName(GameConfig.FONT_TYPE)
    timeLabel:setAnchorPoint(ccp(0.5, 0.5))
    timeLabel:setPosition(ccp(0, 0))
    timeLabel:setText(GetTimeString(totalSecond))
    timeLabel:setFontSize(24)
    timeLabel:setColor(ccc3(0x3f, 0xd2, 0x46))
    timeBgImage:addChild(timeLabel)

    local nameLabel = TFLabel:create()
    nameLabel:setFontName(GameConfig.FONT_TYPE)
    nameLabel:setAnchorPoint(ccp(0, 0))
    nameLabel:setPosition(ccp(145, 80))
    nameLabel:setText(notifyInfo.playerName)
    nameLabel:setFontSize(30)
    nameLabel:setColor(ccc3(0x00, 0x00, 0x00))
    cell:addChild(nameLabel)

    local levelLabel = TFLabel:create()
    levelLabel:setFontName(GameConfig.FONT_TYPE)
    levelLabel:setAnchorPoint(ccp(0, 0))
    levelLabel:setPosition(ccp(315, 80))
    levelLabel:setText("Lv:"..notifyInfo.playerLev)
    levelLabel:setFontSize(24)
    levelLabel:setColor(ccc3(0x00, 0x00, 0x00))
    cell:addChild(levelLabel)

    local powerLabel = TFLabel:create()
    powerLabel:setFontName(GameConfig.FONT_TYPE)
    powerLabel:setAnchorPoint(ccp(0, 0))
    powerLabel:setPosition(ccp(395, 80))
    --powerLabel:setText("战斗力:"..notifyInfo.playerPower)
    powerLabel:setText(stringUtils.format(localizable.common_CE, notifyInfo.playerPower))
    powerLabel:setFontSize(24)
    powerLabel:setColor(ccc3(0x00, 0x00, 0x00))
    cell:addChild(powerLabel)

    local textLabel = TFTextArea:create()
    textLabel:setFontName(GameConfig.FONT_TYPE)
    textLabel:setTextAreaSize(CCSizeMake(370,120))
    textLabel:setAnchorPoint(ccp(0, 1))
    textLabel:setPosition(ccp(145, 70))
    textLabel:setFontSize(22)
    textLabel:setColor(ccc3(0, 0, 0))
    if notifyInfo.fightType == 3 then
        if not notifyInfo.win then
            --textLabel:setText(notifyInfo.playerName.."在群豪谱中向你发起挑战，你将其轻松击退")
            textLabel:setText(stringUtils.format(localizable.notifyInfoLayer_fight_text1, notifyInfo.playerName))
        else
            --textLabel:setText(notifyInfo.playerName.."在群豪谱中击败了你，你的江湖排名降至"..notifyInfo.myRankPos)
            textLabel:setText(stringUtils.format(localizable.notifyInfoLayer_fight_text2, notifyInfo.playerName,notifyInfo.myRankPos))
        end
    elseif notifyInfo.fightType == 4 then
        if notifyInfo.win then
            ---textLabel:setText(notifyInfo.playerName.."在江湖宝藏中试图抢占你的星位，你成功的将其击退")
            textLabel:setText(stringUtils.format(localizable.notifyInfoLayer_start_text1,notifyInfo.playerName))
        else
            --textLabel:setText(notifyInfo.playerName.."在江湖宝藏中抢夺了你的星位，你获得了占位奖励："..notifyInfo.reward.."个碎片")
            textLabel:setText(stringUtils.format(localizable.notifyInfoLayer_start_text2,notifyInfo.playerName))
        end
    end
    cell:addChild(textLabel)

    local replayBtn = TFButton:create()
    cell:addChild(replayBtn)

    replayBtn:setTextureNormal("ui_new/notify/xx_guanzhan_btn.png") 
    replayBtn:setPosition(ccp(600,60))
    replayBtn:addMEListener(TFWIDGET_CLICK,
    audioClickfun(function()
        showLoading()
        TFDirector:send(c2s.QUERY_REPLAY_FIGHT, {notifyInfo.reportId})
    end))

    -- CommonManager:setRedPoint(notifyTypeBg, NotifyManager:isUnReadMail(notifyInfo.reportId),"isUnReadMail",ccp(10,10))
end

function NotifyInfoLayer:SetSystemNotifyCell(cell, cellIndex)
    local notifyInfo = NotifyManager.systemNotifyList:objectAt(cellIndex+1)
    if notifyInfo == nil then
        return
    end
    local notifyBgImage = TFImage:create("ui_new/notify/xx_tianmu_iocn.png")
    notifyBgImage:setPosition(ccp(375, 60))
    cell:addChild(notifyBgImage)

    -- local notifyTypeBg = TFImage:create("ui_new/common/icon_bg/pz_bg_ding_118.png")
    local notifyTypeBg = TFImage:create()
    if notifyInfo.status == 0 then
        notifyTypeBg:setTexture("ui_new/common/icon_bg/pz_bg_bing_118.png")
    else
        notifyTypeBg:setTexture("ui_new/common/icon_bg/pz_bg_ding_118.png")
    end
    notifyTypeBg:setPosition(ccp(70, 60))
    cell:addChild(notifyTypeBg)

    local notifyTypeImage = TFImage:create()
    if notifyInfo.status == 0 then
        notifyTypeImage:setTexture("ui_new/notify/xx_xt_icon.png")
    else
        notifyTypeImage:setTexture("ui_new/notify/xx_xt_icon2.png")
    end
    notifyTypeBg:addChild(notifyTypeImage)


    local timeBgImage = TFImage:create("ui_new/notify/timebg.png")
    timeBgImage:setPosition(ccp(0, -40))
    notifyTypeBg:addChild(timeBgImage)

    local totalSecond = GetGameTime() - math.floor(notifyInfo.time/1000)
    local timeLabel = TFLabel:create()
    timeLabel:setFontName(GameConfig.FONT_TYPE)
    timeLabel:setAnchorPoint(ccp(0.5, 0.5))
    timeLabel:setPosition(ccp(0, 0))
    timeLabel:setText(GetTimeString(totalSecond))
    timeLabel:setFontSize(24)
    timeLabel:setColor(ccc3(0x3f, 0xd2, 0x46))
    timeBgImage:addChild(timeLabel)

    local nameLabel = TFLabel:create()
    nameLabel:setFontName(GameConfig.FONT_TYPE)
    nameLabel:setAnchorPoint(ccp(0, 0))
    nameLabel:setPosition(ccp(145, 80))
    nameLabel:setText(notifyInfo.textTitle)
    nameLabel:setFontSize(30)
    nameLabel:setColor(ccc3(0x00, 0x00, 0x00))
    cell:addChild(nameLabel)

    if not self:ShowReward(cell, notifyInfo) then
        local textLabel = TFTextArea:create()
        textLabel:setTextAreaSize(CCSizeMake(500,120))
        textLabel:setAnchorPoint(ccp(0, 1))
        textLabel:setPosition(ccp(145, 80))
        textLabel:setFontSize(22)
        textLabel:setColor(ccc3(0, 0, 0))
        textLabel:setText(notifyInfo.textTitleSub)
        cell:addChild(textLabel)
    end

    if notifyInfo.canGet then
        local getBtn = TFButton:create()
        cell:addChild(getBtn)

        getBtn:setTextureNormal("ui_new/notify/xx_lingqu_btn.png") 
        getBtn:setPosition(ccp(600,50))
        getBtn:addMEListener(TFWIDGET_CLICK,
        audioClickfun(function()
            showLoading()
            TFDirector:send(c2s.QUERY_GET_SYSTEM_NOTIFY_ITEM, {notifyInfo.id})
        end))
    end

    notifyBgImage:setTouchEnabled(true)
    notifyBgImage:addMEListener(TFWIDGET_CLICK,
    function()
        local layer = AlertManager:addLayerByFile("lua.logic.notify.MailDetailLayer", AlertManager.BLOCK_AND_GRAY)
        AlertManager:show()
        layer:setNotifyId(notifyInfo.id, notifyInfo.canGet)
        layer:setText(notifyInfo.textTitle, notifyInfo.textTitleSub, notifyInfo.textContect)
        if notifyInfo.canGet == false and notifyInfo.status == 0 then
            TFDirector:send(c2s.QUERY_GET_SYSTEM_NOTIFY_ITEM, {notifyInfo.id})
            notifyInfo.status = 1
            self:reloadData()
        end
    end)
end

--按照id排序
local function sortlist( v1,v2 )
    if v1.status > v2.status then
        return false
    end
    if v1.status == v2.status then
        if v1.canGet == false and v2.canGet == true then
            return false
        end
        if v1.canGet == v2.canGet then
            if v1.time < v2.time then
                return false
            end
        end
    end
    return true
end

function NotifyInfoLayer:reloadData()
    NotifyManager.systemNotifyList:sort(sortlist)
    self.infoList:reloadData()
end
function NotifyInfoLayer:ShowReward(cell1, notifyInfo)
    local resCount = 0
    if notifyInfo.reslist ~= nil then
        resCount = #notifyInfo.reslist
    end

    local itemCount = 0
    if notifyInfo.itemlist ~= nil then
        itemCount = #notifyInfo.itemlist
    end

    if resCount == 0 and itemCount == 0 then
        return false
    end

    local posX = 180

    local ScrollViewSize = CCSize(450, 100)
    local cell = TFScrollView:create()
    cell:setPosition(ccp(150,0))
    cell:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    cell:setSize(ScrollViewSize)
    cell1:addChild(cell)
    local countTotal = 0
    local ItemSize = 0
    posX = 33

    for i=1,resCount do
        local resInfo = notifyInfo.reslist[i]
        local resBgImg = TFImage:create(GetResourceQualityBG(resInfo.type))
        resBgImg:setPosition(ccp(posX, 40))
        resBgImg:setScale(0.5)
        cell:addChild(resBgImg)

        local resIcon = TFImage:create()
        resIcon:setPosition(ccp(posX, 40))
      
        cell:addChild(resIcon)

        posX = posX + 75

        local resLabel = TFLabelBMFont:create()
        resLabel:setScale(0.6)
        resLabel:setFntFile("font/num_202.fnt")
        resLabel:setPosition(ccp(0, -30))
        resIcon:addChild(resLabel)

        local resIconImg = GetResourceIcon(resInfo.type)
        if resIconImg then
            resIcon:setTexture(resIconImg)
            resIcon:setTouchEnabled(true)
            resIcon:addMEListener(TFWIDGET_CLICK,
            audioClickfun(function()
                Public:ShowItemTipLayer(resInfo.itemid, resInfo.type)
            end))
            resLabel:setText("X"..resInfo.num)
        end
        
        countTotal = countTotal + 1
    end

    for i=1,itemCount do
        local itemInfo = notifyInfo.itemlist[i]

        local itemQualityImg = TFImage:create()
        itemQualityImg:setScale(0.5)
        itemQualityImg:setPosition(ccp(posX, 40))
        posX = posX + 75

        cell:addChild(itemQualityImg)
        local itemIcon = TFImage:create()
        itemQualityImg:addChild(itemIcon)

        local numLabel = TFLabelBMFont:create()
        numLabel:setScale(1.2)
        numLabel:setFntFile("font/num_202.fnt")
        numLabel:setPosition(ccp(0, -60))
        itemIcon:addChild(numLabel,2)
        numLabel:setText("X"..itemInfo.num)

        if itemInfo.type == 1 then
            local itemData = ItemData:objectByID(itemInfo.itemid)
            if itemData ~= nil then
                itemQualityImg:setTexture(GetColorIconByQuality(itemData.quality))
                itemIcon:setTexture(itemData:GetPath())
                itemIcon:setTouchEnabled(true)
                itemIcon:addMEListener(TFWIDGET_CLICK,
                audioClickfun(function()
                    Public:ShowItemTipLayer(itemInfo.itemid, itemInfo.type)
                end))
                Public:addPieceImg(itemIcon,{type = itemInfo.type,itemid = itemInfo.itemid})
            end
        elseif itemInfo.type == 2 then
            local cardData = RoleData:objectByID(itemInfo.itemid)
            if cardData ~= nil then
                itemQualityImg:setTexture(GetColorIconByQuality(cardData.quality))
                itemIcon:setTexture(cardData:getIconPath())
                itemIcon:setTouchEnabled(true)
                itemIcon:addMEListener(TFWIDGET_CLICK,
                audioClickfun(function()
                    Public:ShowItemTipLayer(itemInfo.itemid, itemInfo.type)
                end))
                Public:addPieceImg(itemIcon,{type = itemInfo.type,itemid = itemInfo.itemid})
            end
        end

        ItemSize   = itemQualityImg:getSize().width * 0.5
        countTotal = countTotal + 1
    end
    ItemSize = 75 * countTotal                  --by stephen  之前的计算方法错误
    if ScrollViewSize.width < ItemSize then
        cell:setInnerContainerSize(CCSizeMake(ItemSize, 100))
        cell:setIsInnerMoveEnabled(true)
        cell:setInertiaScrollEnabled(true)
        cell:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
    end

    return true
end

function NotifyInfoLayer.numberOfCellsInTableView(table)
    if NotifyManager.selectBtnIndex == 1 then
        return NotifyManager.fightNotifyList:length()
    elseif NotifyManager.selectBtnIndex == 2 then
        return NotifyManager.systemNotifyList:length()
    end
    return 0
end

function NotifyInfoLayer.OnclikGetEmailReward(sender)
    local self = sender.logic

    NotifyManager:getAllEmailReward()
end

function NotifyInfoLayer.OnclikDelEmail(sender)
    local self = sender.logic

    NotifyManager:delAllEmail()
end

return NotifyInfoLayer
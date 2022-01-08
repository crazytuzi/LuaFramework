local ArenaFightReport = class("ArenaFightReport", BaseLayer)

CREATE_SCENE_FUN(ArenaFightReport)
CREATE_PANEL_FUN(ArenaFightReport)

function ArenaFightReport:ctor(data)
    self.super.ctor(self,data)
    
    self:init("lua.uiconfig_mango_new.arena.ArenaZhanbao")
end

function ArenaFightReport:initUI(ui)
    self.super.initUI(self,ui)

    self.btn_close  = TFDirector:getChildByPath(ui, 'btn_close')
    self.panel_list = TFDirector:getChildByPath(ui, 'Panel_List')
    
    self.typeButton = {}
    for i=1,3 do
        self.typeButton[i]       = TFDirector:getChildByPath(ui, 'tab'..i)
        self.typeButton[i].index = i
    end

    self.btnIndex = 1

    -- 对应按钮的索引
    self.curBtnIndex  = 0

    self.layerList = {}

    self.TopFightReportList = TFArray:new()
    self.MyFightReportList = TFArray:new()

    ArenaManager:requestTopFightReport()

    self:drawDefault(self.btnIndex)

    -- notifyInfo.fightType == 3 

end

function ArenaFightReport:setArenaData(arenaInfo)
    self.ArenaInfo = arenaInfo

    -- print("self.ArenaInfo = ", self.ArenaInfo)
end

function ArenaFightReport:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()
end

function ArenaFightReport:refreshBaseUI()
    -- self.txt_challengeCount:setText(self.homeInfo.challengeCountOneDay - self.homeInfo.challengeCountToDay)
    -- self.txt_challengeCountLeave:setText(self.homeInfo.challengeCountToDay) 
end

function ArenaFightReport:refreshUI()
    -- if not self.isShow then
    --     return
    -- end
end


function ArenaFightReport:removeUI()
    self.super.removeUI(self)

end

function ArenaFightReport:registerEvents()
    self.super.registerEvents(self)

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)

    for i=1,3 do
        self.typeButton[i].index = i
        self.typeButton[i].logic = self
        self.typeButton[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTpye),1)
    end


    self.Top_FightReport_Update = function(event)
        -- print("event = ", event.data[1])
        self.TopFightReportList:clear()
        local report = event.data[1].report
        if report == nil then
            print("没有挑战数据")
            return
        end

        for k,v in pairs(report) do
            self.TopFightReportList:push(v)
        end

        self:drawTopResultLayer()
    end
    TFDirector:addMEGlobalListener(ArenaManager.TOP_FIGHT_REPORT_UPDATE ,self.Top_FightReport_Update)
   
    self.My_FightReport_Update = function(event)
        print("event = ", event.data[1])
        self.MyFightReportList:clear()
        local report = event.data[1].report

        if report == nil then
            print("没有我的挑战数据")
            return
        end

        for k,v in pairs(report) do
            self.MyFightReportList:push(v)
        end

        self:drawMyResultLayer()
    end
    TFDirector:addMEGlobalListener(ArenaManager.MY_FIGHT_REPORT_UPDATE ,self.My_FightReport_Update)
end

function ArenaFightReport:removeEvents()
    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener(ArenaManager.TOP_FIGHT_REPORT_UPDATE ,self.Top_FightReport_Update)
    self.Top_FightReport_Update = nil
    

    TFDirector:removeMEGlobalListener(ArenaManager.MY_FIGHT_REPORT_UPDATE ,self.My_FightReport_Update)
    self.My_FightReport_Update = nil
end

function ArenaFightReport:drawDefault(index)
    if self.curBtnIndex == index then
        return
    end

    local btn = nil
    -- 绘制上面的按钮
    if self.btnLastIndex ~= nil then
        btn = self.typeButton[self.btnLastIndex]
        btn:setTextureNormal("ui_new/spectrum/tab_tab"..self.btnLastIndex..".png")
    end

    self.btnLastIndex = index
    self.curBtnIndex  = index

    btn = self.typeButton[self.curBtnIndex]
    btn:setTextureNormal("ui_new/spectrum/tab_tab"..self.btnLastIndex.."h.png")


    self:onClickDay(index)

end

function ArenaFightReport:onClickDay(index)
    print("第"..index.."项")

    for i=1,3 do
        if self.layerList[i] then
            self.layerList[i]:setVisible(false)
        end 
    end

    if self.layerList[index] then
        self.layerList[index]:setVisible(true)
    end 

    if index == 1 then
        ArenaManager:requestTopFightReport()
        self:drawTopResultLayer() 

    elseif index == 2 then
        ArenaManager:requestMyFightReport()

        self:drawMyResultLayer()
    elseif index == 3 then
        self:drawMyInfoLayer()
    end
end

function ArenaFightReport.onClickTpye(sender)
    local self  = sender.logic
    local index = sender.index

    if self.curBtnIndex == index then
        return
    end

    self:drawDefault(index)
end



function ArenaFightReport:drawTopResultLayer()
    if self.topResultTableView ~= nil then
        self.topResultTableView:reloadData()
        self.topResultTableView:setScrollToBegin(false)
        self.topResultTableView:setVisible(true)
        return
    end

    local  topResultTableView =  TFTableView:create()
    topResultTableView:setTableViewSize(self.panel_list:getContentSize())
    topResultTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    topResultTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    topResultTableView:setPosition(self.panel_list:getPosition())
    self.topResultTableView = topResultTableView
    self.topResultTableView.logic = self

    topResultTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable_topResult)
    topResultTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex_topResult)
    topResultTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView_topResult)
    topResultTableView:reloadData()

    self.panel_list:getParent():addChild(self.topResultTableView,1)

    self.layerList[1] = topResultTableView
end


function ArenaFightReport.numberOfCellsInTableView_topResult(table)
    local self = table.logic

    return self.TopFightReportList:length()
end

function ArenaFightReport.cellSizeForTable_topResult(table,idx)
    return 137, 718
end

function ArenaFightReport.tableCellAtIndex_topResult(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = createUIByLuaNew("lua.uiconfig_mango_new.arena.ArenaZhanbaoCell1")

        node:setPosition(ccp(10, -10))
        cell:addChild(node)
        node:setTag(617)
        node.logic = self
        -- node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTask))
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawTopresultNode(node)

    node:setVisible(true)
    return cell
end

function ArenaFightReport:drawTopresultNode(node)
    local txt_battletime    = TFDirector:getChildByPath(node, 'txt_battletime')
    local btn_guanzhan      = TFDirector:getChildByPath(node, 'btn_guanzhan')


    local bg_name1     = TFDirector:getChildByPath(node, 'bg_name1')
    local bg_name2     = TFDirector:getChildByPath(node, 'bg_name2')

    local img_tzshengli  = TFDirector:getChildByPath(node, 'img_tzshengli')

    local index       = node.index
    local fightReport = self.TopFightReportList:objectAt(index)
    -- print("111fightReport = ", fightReport)


    btn_guanzhan.logic      = self
    btn_guanzhan.reportId   = fightReport.reportId


    -- 战斗时间
    local time = fightReport.time
    time = math.ceil(time/1000)
    time = MainPlayer:getNowtime() - time
    txt_battletime:setText(getTimeString(time))
    

    -- left
    local txt_name      = TFDirector:getChildByPath(bg_name1, 'txt_name')
    local txt_zhandouli = TFDirector:getChildByPath(bg_name1, 'txt_zhandouli')
    local icon_up1       = TFDirector:getChildByPath(bg_name1, 'icon_up')
    local txt_paiming1   = TFDirector:getChildByPath(bg_name1, 'txt_paiming')
    txt_name:setText(fightReport.fromRole.name)
    txt_zhandouli:setText(fightReport.fromRole.power)
    icon_up1:setVisible(fightReport.win)
    txt_paiming1:setText(fightReport.fromRank)

    print("fightReport.fromRole.ranking = ", fightReport.fromRole.ranking)

    -- right
    txt_name      = TFDirector:getChildByPath(bg_name2, 'txt_name')
    txt_zhandouli = TFDirector:getChildByPath(bg_name2, 'txt_zhandouli')
    local txt_paiming2   = TFDirector:getChildByPath(bg_name2, 'txt_paiming')
    local icon_up2       = TFDirector:getChildByPath(bg_name2, 'icon_up')
    txt_pm       = TFDirector:getChildByPath(bg_name2, 'txt_pm')

    txt_name:setText(fightReport.targetRole.name)
    txt_zhandouli:setText(fightReport.targetRole.power)

    -- txt_pm:setVisible(false)
    -- txt_paiming:setVisible(false)
    txt_paiming2:setText(fightReport.ranking)
    icon_up2:setVisible(fightReport.win)


    txt_paiming1:setColor(ccc3(255,255,255))
    txt_paiming2:setColor(ccc3(255,255,255))
    if fightReport.win then
        img_tzshengli:setTexture("ui_new/spectrum/img_tzshengli.png")

        if fightReport.fromRank < fightReport.ranking then
            icon_up1:setVisible(false)
            icon_up2:setVisible(false)

        else
            txt_paiming1:setText(fightReport.ranking)
            txt_paiming2:setText(fightReport.fromRank)
            txt_paiming1:setColor(ccc3(0,255,0))
            txt_paiming2:setColor(ccc3(255,0,0))
        end
    else
        img_tzshengli:setTexture("ui_new/spectrum/img_tzshibai.png")
    end

    btn_guanzhan:addMEListener(TFWIDGET_CLICK,
    audioClickfun(function()
        showLoading()
        TFDirector:send(c2s.PLAY_ARENA_TOP_BATTLE_REPORT, {fightReport.reportId})
    end))
end

function ArenaFightReport:drawMyResultLayer()
    if self.myResultTableView ~= nil then
        self.myResultTableView:reloadData()
        self.myResultTableView:setScrollToBegin(false)
        self.myResultTableView:setVisible(true)
        return
    end

    local  myResultTableView =  TFTableView:create()
    myResultTableView:setTableViewSize(self.panel_list:getContentSize())
    myResultTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    myResultTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    myResultTableView:setPosition(self.panel_list:getPosition())
    self.myResultTableView = myResultTableView
    self.myResultTableView.logic = self

    myResultTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable_myResult)
    myResultTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex_myResult)
    myResultTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView_myResult)
    myResultTableView:reloadData()

    self.panel_list:getParent():addChild(self.myResultTableView,1)

    self.layerList[2] = myResultTableView
end

function ArenaFightReport.numberOfCellsInTableView_myResult(table)
    local self = table.logic

    return self.MyFightReportList:length()
end

function ArenaFightReport.cellSizeForTable_myResult(table,idx)
    return 137, 718
end

function ArenaFightReport.tableCellAtIndex_myResult(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = createUIByLuaNew("lua.uiconfig_mango_new.arena.ArenaZhanbaoCell2")

        node:setPosition(ccp(10, -10))
        cell:addChild(node)
        node:setTag(617)
        node.logic = self
        -- node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTask))
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawMyresultNode(node)
    node:setVisible(true)
    return cell
end

function ArenaFightReport:drawMyresultNode(node)
    local img_result        = TFDirector:getChildByPath(node, 'img_win')
    local txt_paiming       = TFDirector:getChildByPath(node, 'txt_paiming')
    local txt_zhandouli     = TFDirector:getChildByPath(node, 'txt_zhandouli')
    local txt_FightName     = TFDirector:getChildByPath(node, 'txt_name')
    local txt_battletime    = TFDirector:getChildByPath(node, 'txt_battletime')
    local btn_share         = TFDirector:getChildByPath(node, 'btn_fenxiang')
    local btn_guanzhan      = TFDirector:getChildByPath(node, 'btn_guanzhan')
    local icon_up           = TFDirector:getChildByPath(node, 'icon_up')

    -- NotifyManager
    local index       = node.index
    local fightReport = self.MyFightReportList:objectAt(index)

    print("222fightReport = ",fightReport)

    -- 战斗时间
    local time = fightReport.time
    time = math.ceil(time/1000)
    time = MainPlayer:getNowtime() - time
    txt_battletime:setText(getTimeString(time))
    


    local rank = fightReport.ranking

    if fightReport.win then
        img_result:setTexture("ui_new/spectrum/img_sheng.png")
        icon_up:setTexture("ui_new/roleequip/js_jts_icon.png")

        rank = math.min(rank, fightReport.fromRank)
    else
        img_result:setTexture("ui_new/spectrum/img_fu.png")
        icon_up:setTexture("ui_new/roleequip/js_jtx_icon.png")
    end

    icon_up:setVisible(fightReport.win)

    txt_FightName:setText(fightReport.targetRole.name)
    txt_zhandouli:setText(fightReport.targetRole.power)

    local bChangeRank = false
    if fightReport.win then
        if fightReport.fromRank < fightReport.ranking then
            local str = localizable.arenafightreport_rank_no_change
            txt_paiming:setText(str)
            icon_up:setVisible(false)
        else
            local str = stringUtils.format(localizable.arenafightreport_rank_up, rank)
            txt_paiming:setText(str)
            bChangeRank = true
        end
    else
        local str = localizable.arenafightreport_rank_no_change
        txt_paiming:setText(str)
    end

    local pos = icon_up:getPosition()
    -- print("pos.x = ", pos.x)
    icon_up:setPosition(ccp(350, pos.y))
    -- icon_up:setVisible(true)
    -- txt_paiming:setText("排名升至第9999名")

    -- if bChangeRank then
    --     txt_paiming1:setColor(ccc3(0,255,0))
    --     txt_paiming2:setColor(ccc3(255,0,0))
    -- else
    --     txt_paiming1:setColor(ccc3(255,255,255))
    --     txt_paiming2:setColor(ccc3(255,255,255))
    -- end
    
    btn_guanzhan:addMEListener(TFWIDGET_CLICK,
    audioClickfun(function()
        showLoading()
        TFDirector:send(c2s.PLAY_ARENA_TOP_BATTLE_REPORT, {fightReport.reportId})
    end))

    btn_share:setVisible(false)

end


function ArenaFightReport:drawMyInfoLayer()
    if self.myInfoLayer == nil then
        self.myInfoLayer = createUIByLuaNew("lua.uiconfig_mango_new.arena.ArenaZhanbaoCell3")
        self.myInfoLayer:setPosition(ccp(0, 0))
        -- self.panel_list:getParent():addChild(self.myInfoLayer,1)
        self.panel_list:addChild(self.myInfoLayer,1)

        self.layerList[3] = self.myInfoLayer
    end

    local txt = {}
    for i=1,7 do
        txt[i] = TFDirector:getChildByPath(self.myInfoLayer, 'txt'..i)
    end

    local desc = {}
    for i=1,7 do
        desc[i] = TFDirector:getChildByPath(self.myInfoLayer, 'txt'..i.."b")
    end

    txt[1]:setText(localizable.arenafightreport_rank_text1)
    txt[2]:setText(localizable.arenafightreport_rank_text2)
    txt[3]:setText(localizable.arenafightreport_rank_text3)
    txt[4]:setText(localizable.arenafightreport_rank_text4)
    txt[5]:setText(localizable.arenafightreport_rank_text5)
    txt[6]:setText(localizable.arenafightreport_rank_text6)
    txt[7]:setText(localizable.arenafightreport_rank_text7)
    
    print("self.ArenaInfo = ",self.ArenaInfo)
    desc[1]:setText(self.ArenaInfo.bestRank + 1) --群豪谱最高排名:
    desc[2]:setText(self.ArenaInfo.activeChallenge)     --主动挑战场数:
    local str = stringUtils.format(localizable.arenafightreport_win_lose, self.ArenaInfo.activeWin
        , self.ArenaInfo.activeChallenge - self.ArenaInfo.activeWin)
    desc[3]:setText(str)
    desc[4]:setText(self.ArenaInfo.maxContinuityWin)

    local beHitTimesTotal  = self.ArenaInfo.challengeTotalCount - self.ArenaInfo.activeChallenge
    local beHitTimesSuc    = self.ArenaInfo.challengeWinCount - self.ArenaInfo.activeWin
    local beHitTimesFail   = beHitTimesTotal - beHitTimesSuc
 
    desc[5]:setText(beHitTimesTotal)--"防御战斗场数:"
    local str = stringUtils.format(localizable.arenafightreport_win_lose, beHitTimesSuc
        , beHitTimesFail)
    desc[6]:setText(str)--"被动防御战绩:"
    desc[7]:setText("")--"被动防御最大连胜:"

    txt[7]:setVisible(false)
end

    -- required int32 myRank = 1;                  //当前排名
    -- required int32 fightPower = 2;              //战力
    -- required int32 challengeTotalCount = 3;     //总挑战次数
    -- required int32 challengeWinCount = 4;       //胜利次数
    -- required int32 bestRank = 5;                //最佳排名
    -- required int32 activeChallenge = 6;         //主动挑战次数
    -- required int32 activeWin=7;                 //主动挑战胜利次数
    -- required int32 continuityWin=8;             //当前连胜次数
    -- required int32 maxContinuityWin=9;          //最大连胜次数

return ArenaFightReport

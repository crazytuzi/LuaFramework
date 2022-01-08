--[[
******帮派副本-章节列表*******

	-- by quanhuan
	-- 2015/12/28
]]

local ChapterListLayer = class("ChapterListLayer",BaseLayer)

local cellW = 960
local cellH = 150
local LocalData = {}
local ChapterData = {}

local StateAlreadyOpen = 1
local StateCanOpen = 2
local StateCanReset = 3
local StateCannotOpen = 4
-- local StateAlreadyDone = 5

function ChapterListLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.HoushanZhanjie")
end

function ChapterListLayer:initUI( ui )

	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.Hs_Faction,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE}) 

    self.txt_fangrong = TFDirector:getChildByPath(ui, "txt_fangrong")
    self.btn_help = TFDirector:getChildByPath(ui, "btn_help")

    --创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui, "Panel_Zhanjie")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))
    self.cellModel  = createUIByLuaNew("lua.uiconfig_mango_new.faction.HoushanZhanjieCell")
    self.cellModel:retain()    
end


function ChapterListLayer:removeUI()
	self.super.removeUI(self)
    if self.cellModel then
        self.cellModel:release()
        self.cellModel = nil
    end
end

function ChapterListLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function ChapterListLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHelpBtnClickHandle))

    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)

    self.openZoneSucessCallBack = function (event)
        local data = event.data[1][1]
        print(data)
        ChapterData[data].currProgress = 0
        ChapterData[data].state = StateAlreadyOpen
        self.TabView:reloadData()
        self.txt_fangrong:setText(FactionManager:getFactionBoom())
        toastMessage(localizable.Zone_Open_Suceess)
    end
    TFDirector:addMEGlobalListener(FactionManager.OpenZoneSucess, self.openZoneSucessCallBack)  
    self.resetZoneSucessCallBack = function (event)
        local data = event.data[1][1]
        ChapterData[data].currProgress = 0
        ChapterData[data].state = StateAlreadyOpen
        self.TabView:reloadData()
        self.txt_fangrong:setText(FactionManager:getFactionBoom())
        toastMessage(localizable.Zone_Reset_Suceess)
    end
    TFDirector:addMEGlobalListener(FactionManager.ResetZoneSucess, self.resetZoneSucessCallBack)      

    self.eventUpdateHoushanCallBack = function (event)
        self:loadData()
    end
    TFDirector:addMEGlobalListener(HoushanManager.EVENT_UPDATE_HOUSHAN, self.eventUpdateHoushanCallBack)    

    self.guildDpsAwardSucessCallBack = function (event)
        self:loadData()
    end
    TFDirector:addMEGlobalListener(FactionManager.guildDpsAwardSucess, self.guildDpsAwardSucessCallBack)

    
    self.registerEventCallFlag = true 

    -- print('ChapterListLayer:registerEvents() =77777777777777777777 ')
end

function ChapterListLayer:removeEvents()

    self.super.removeEvents(self)

	if self.generalHead then
        self.generalHead:removeEvents()
    end
 	
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)    
  

    TFDirector:removeMEGlobalListener(FactionManager.OpenZoneSucess, self.openZoneSucessCallBack)
    self.openZoneSucessCallBack = nil
    TFDirector:removeMEGlobalListener(FactionManager.ResetZoneSucess, self.resetZoneSucessCallBack)
    self.resetZoneSucessCallBack = nil
    TFDirector:removeMEGlobalListener(HoushanManager.EVENT_UPDATE_HOUSHAN, self.eventUpdateHoushanCallBack) 
    self.eventUpdateHoushanCallBack = nil  
    TFDirector:removeMEGlobalListener(FactionManager.guildDpsAwardSucess, self.guildDpsAwardSucessCallBack)
    self.guildDpsAwardSucessCallBack = nil  

    self.registerEventCallFlag = nil  
end

function ChapterListLayer:dispose()
	self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
end

function ChapterListLayer:loadData()
    self:chapterDataReady()

    self.TabView:reloadData()

    self.txt_fangrong:setText(FactionManager:getFactionBoom())
end

function ChapterListLayer:chapterDataReady()
    
    --[[
        --ChapterData
        idx 章节编号
        currProgress 当前进度
        totalProgress 总进度
        state 
        openFr 开启需要消耗的繁荣
        resetFr 开启需要消耗的繁荣
        resetCount 今日重置次数
    ]]
    local maxChapter = GuildZoneData:length()
    local percentList = FactionManager:getZonePercentList()
    print('percentListpercentList = ',percentList)
    ChapterData = {}
    for i=1,maxChapter do
        local zoneInfo = GuildZoneData:GetInfoByZoneId(i)
        if zoneInfo then
            local dataCount = #ChapterData + 1
            ChapterData[dataCount] = {}
            ChapterData[dataCount].idx = dataCount
            ChapterData[dataCount].currProgress = percentList[i].percent
            ChapterData[dataCount].totalProgress = 100
            ChapterData[dataCount].state = percentList[i].state
            ChapterData[dataCount].resetCount = percentList[i].resetCount
            ChapterData[dataCount].openFr = zoneInfo.open_boom or 0
            ChapterData[dataCount].resetFr = zoneInfo.reset_boom or 0
            local chapterIndex = numberToChinese(dataCount)
            ChapterData[dataCount].titleName = stringUtils.format(localizable.chapterListLayer_titleName,chapterIndex,zoneInfo.name)       
            ChapterData[dataCount].iconPath = 'ui_new/faction/houshan/bg_zhangjieA'..zoneInfo.icon..'.png'
        else
            print('cannot find zone_id = ',i)
        end
    end
   
end


function ChapterListLayer.cellSizeForTable(table,idx)
    return cellH,cellW
end

function ChapterListLayer.numberOfCellsInTableView(table)
    return #ChapterData
end

function ChapterListLayer.tableCellAtIndex(table, idx)

    local self = table.logic
    local cell = table:dequeueCell()

    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()
        panel = self.cellModel:clone()
        panel:setPosition(ccp(0,0))
        cell:addChild(panel)
        cell.panelNode = panel
    else
        panel = cell.panelNode
    end

    idx = idx + 1
    self:cellInfoSet(cell, panel, idx)

    return cell
end


function ChapterListLayer:cellInfoSet(cell, panel, idx)

    if not cell.boundData then
        cell.boundData = true
        cell.txt_jindu = TFDirector:getChildByPath(panel, 'txt_jindu')
        cell.txt_title = TFDirector:getChildByPath(panel, 'txt_title')
        cell.bgA = TFDirector:getChildByPath(panel, 'bgA')

        cell.btn_jinru = TFDirector:getChildByPath(panel, 'btn_jinru')
        cell.btn_kaiqi = TFDirector:getChildByPath(panel, 'btn_kaiqi')
        cell.btn_yitongguan = TFDirector:getChildByPath(panel, 'btn_yitongguan')
        cell.btn_chongzhi = TFDirector:getChildByPath(panel, 'btn_chongzhi')
        cell.txt_weikaiqi = TFDirector:getChildByPath(panel, 'txt_weikaiqi')
        cell.txt_weikaiqi:setVisible(false)

        cell.btn_jinru:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onEnterButtonClick))
        cell.btn_kaiqi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOpenClickHandle))
        cell.btn_yitongguan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onDoneButtonClick))
        cell.btn_chongzhi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onResetClickHandle))
    end

    cell.btn_jinru.idx = idx
    cell.btn_jinru.logic = self
    cell.btn_kaiqi.idx = idx
    cell.btn_kaiqi.logic = self
    cell.btn_yitongguan.idx = idx
    cell.btn_yitongguan.logic = self
    cell.btn_chongzhi.idx = idx
    cell.btn_chongzhi.logic = self

    local dataInfo = ChapterData[idx]
    -- cell.txt_jindu:setText('章节进度:'..dataInfo.currProgress..'/'..dataInfo.totalProgress)
    cell.txt_jindu:setText(stringUtils.format(localizable.ChapterListLayer_progress, dataInfo.currProgress, dataInfo.totalProgress))
    cell.txt_title:setText(dataInfo.titleName)

    cell.btn_jinru:setVisible(false)
    CommonManager:setRedPoint(cell.btn_jinru, false,"isRedJinru",ccp(0,0)) 
    cell.btn_kaiqi:setVisible(false)
    cell.btn_yitongguan:setVisible(false)
    CommonManager:setRedPoint(cell.btn_yitongguan, false,"isRedyitongguan",ccp(0,0)) 
    cell.btn_chongzhi:setVisible(false)

    cell.bgA:setTexture(dataInfo.iconPath)

    if dataInfo.state == StateAlreadyOpen then
        cell.btn_jinru:setVisible(true)
        CommonManager:setRedPoint(cell.btn_jinru, FactionManager:isCanGetRewardByZoneId(idx),"isRedJinru",ccp(0,0)) 
    elseif dataInfo.state == StateCanOpen then
        cell.btn_kaiqi:setVisible(true)
    elseif dataInfo.state == StateCanReset then
        cell.btn_yitongguan:setVisible(true)
        CommonManager:setRedPoint(cell.btn_yitongguan, FactionManager:isCanGetRewardByZoneId(idx),"isRedyitongguan",ccp(0,0)) 
        local myPost = FactionManager:getPostInFaction()
        if myPost == 1 or myPost == 2 then
            cell.btn_chongzhi:setVisible(true)
        end
    end
end

function ChapterListLayer.onResetClickHandle(btn)

    local self = btn.logic
    local dataInfo = ChapterData[btn.idx]

    local myPost = FactionManager:getPostInFaction()
    if myPost ~= 1 and myPost ~= 2 then
        toastMessage(localizable.No_Permissions)
        return
    end
    

    if dataInfo.resetCount > 0 then
        toastMessage(localizable.Everyday_Reset_One_time)
        return
    end
    -- local msg = TFLanguageManager:getString(ErrorCodeData.Consume_Prosperity_Reset)
    -- msg = string.format(msg,dataInfo.resetFr)    
    local msg = stringUtils.format(localizable.Consume_Prosperity_Reset, dataInfo.resetFr)

    CommonManager:showOperateSureLayer(
        function()
            local currFr = FactionManager:getFactionBoom()
            if currFr < dataInfo.resetFr then
                toastMessage(localizable.NoT_Enough_Prosperity)
                return
            end
            local myPost = FactionManager:getPostInFaction()
            if myPost == 1 or myPost == 2 then
                FactionManager:requestResetZone( dataInfo.idx, dataInfo.resetFr)
            else
                toastMessage(localizable.No_Permissions)
            end            
        end,
        function()
            AlertManager:close()
        end,
        {
        title = localizable.common_tips,
        msg = msg,
        }
    ) 
end

function ChapterListLayer.onOpenClickHandle(btn)
    local self = btn.logic
    local dataInfo = ChapterData[btn.idx]

    local myPost = FactionManager:getPostInFaction()
    if myPost ~= 1 and myPost ~= 2 then
        toastMessage(localizable.No_Permissions)
        return
    end

    -- local msg = TFLanguageManager:getString(ErrorCodeData.Consume_Prosperity_Open)
    -- msg = string.format(msg,dataInfo.openFr)
    
    local msg = stringUtils.format(localizable.Consume_Prosperity_Open, dataInfo.openFr)

    CommonManager:showOperateSureLayer(
        function()
            local currFr = FactionManager:getFactionBoom()
            if currFr < dataInfo.openFr then
                toastMessage(localizable.NoT_Enough_Prosperity)
                return
            end
            local myPost = FactionManager:getPostInFaction()
            if myPost == 1 or myPost == 2 then
                FactionManager:requestOpenZone( dataInfo.idx, dataInfo.openFr )
            else
                toastMessage(localizable.No_Permissions)
            end                
        end,
        function()
            AlertManager:close()
        end,
        {
        title = localizable.common_tips,
        msg = msg,
        }
    )
end

function ChapterListLayer.onEnterButtonClick(btn)
    --open details layer    
    HoushanManager:showHoushanLayer(btn.idx)
end

function ChapterListLayer.onDoneButtonClick(btn)
    --open details layer
    HoushanManager:showHoushanLayer(btn.idx)
end

function ChapterListLayer.onHelpBtnClickHandle( btn)
    CommonManager:showRuleLyaer( 'bangpaihoushan' )
end
return ChapterListLayer
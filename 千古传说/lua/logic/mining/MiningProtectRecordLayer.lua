

local MiningProtectRecordLayer = class("MiningProtectRecordLayer", BaseLayer)

function MiningProtectRecordLayer:ctor(data)
    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.mining.minimgGuardRecords")
end

function MiningProtectRecordLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.ui = ui

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close')
    self.panel_protectCell  = TFDirector:getChildByPath(ui, 'panel_cell')
    self.panel_protectCell:removeFromParentAndCleanup(false)
    self.panel_protectCell:retain()

    self.panel_more = TFDirector:getChildByPath(ui, 'panel_more')
    self.panel_more:removeFromParentAndCleanup(false)
    self.panel_more:retain()

    self.Panel_ProtectList = TFDirector:getChildByPath(ui, 'panel_guard')

    self.historyData = TFArray:new()
    self.pageIndex = 0
    MiningManager:requestGuardRecord(1)

    self.bFistDraw = true
end

function MiningProtectRecordLayer:registerEvents(ui)
    self.super.registerEvents(self)

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)




    self.updateHistory = function(event)
        local list = MiningManager:getGuardRecordListResult()
        if list == nil then
            if self.historyData:length() < 1 then
                --toastMessage("暂无记录")
                toastMessage(localizable.common_not_record)
                return
            else
                --toastMessage("没有更多的记录了")
                toastMessage(localizable.common_not_more_record)
            end
            return
        end

        for k,v in pairs(list) do
            self.historyData:push(v)
        end

        self.pageIndex = self.pageIndex + 1
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(MiningManager.EVENT_UPDATE_HISTORY, self.updateHistory)
end


function MiningProtectRecordLayer:removeEvents()

    TFDirector:removeMEGlobalListener(MiningManager.EVENT_UPDATE_HISTORY, self.updateHistory)
    self.updateHistory = nil

    self.super.removeEvents(self)
end

function MiningProtectRecordLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function MiningProtectRecordLayer:refreshUI()

    self:drawTableview()
end

function MiningProtectRecordLayer:removeUI()

    if self.panel_protectCell then
        self.panel_protectCell:release()
    end

    if self.panel_more then
        self.panel_more:release()
    end
    

   self.super.removeUI(self)
end


function MiningProtectRecordLayer:drawTableview()

    if self.ProtectTableView ~= nil then
        -- self.ProtectTableView:reloadData()
        -- self.ProtectTableView:setScrollToBegin(false)
        -- return        
        local offsetSize1 = self.ProtectTableView:getContentSize()
        self.ProtectTableView:reloadData()
        if self.bFistDraw == false then
            local offsetSize2 = self.ProtectTableView:getContentSize()
            if self.historyData:length() > 1 then 
                self.ProtectTableView:setContentOffset(ccp(0, offsetSize1.height - offsetSize2.height))
            end

        else
            self.ProtectTableView:setScrollToBegin(false)
            self.bFistDraw = false
        end
        return
    end

    local  ProtectTableView =  TFTableView:create()
    ProtectTableView:setTableViewSize(self.Panel_ProtectList:getContentSize())
    ProtectTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    ProtectTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    ProtectTableView:setPosition(self.Panel_ProtectList:getPosition())
    self.ProtectTableView = ProtectTableView
    self.ProtectTableView.logic = self

    ProtectTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    ProtectTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    ProtectTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    ProtectTableView:reloadData()

    self.Panel_ProtectList:getParent():addChild(self.ProtectTableView,1)
end


function MiningProtectRecordLayer.numberOfCellsInTableView(table)
    local self  = table.logic
    local num   = self.historyData:length()

    if num >= 5 then
        num = num + 1
    end

    return num
end

function MiningProtectRecordLayer.cellSizeForTable(table,idx)
    return 100, 773
end

function MiningProtectRecordLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = self.panel_protectCell:clone()

        node:setPosition(ccp(5, 0))
        cell:addChild(node)
        node:setTag(617)
        node.logic = self

        cell.record = node

        local more = self.panel_more:clone()

        more:setPosition(ccp(5, 0))
        cell:addChild(more)
        more:setTag(618)
        more.logic = self

        cell.more = more
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1

    self:drawCell(cell, idx + 1)

    -- node:setVisible(true)
    return cell
end

function MiningProtectRecordLayer:drawCell(cell, index)
    cell.record:setVisible(false)
    cell.more:setVisible(false)

    local totalCount = self.historyData:length()
    if index  == (totalCount + 1) then
        cell.more:setVisible(true)

        local btn_more = TFDirector:getChildByPath(cell.more, 'btn_more')

        print("set btn touch")
        btn_more:addMEListener(TFWIDGET_CLICK, audioClickfun(
            function ( )
                print("idx + 1 = ", 12312312)
                self:loadMore()
            end
        ),1)
        return
    end

    cell.record:setVisible(true)
    self:drawRecordCell(cell.record)
end

function MiningProtectRecordLayer:drawMoreCell(node)

end

function MiningProtectRecordLayer:drawRecordCell(node)
    local txt_date = TFDirector:getChildByPath(node, "txt_date")

    local txt_time   = TFDirector:getChildByPath(node, "txt_time")
    local txt_wenzi  = TFDirector:getChildByPath(node, "txt_wenzi")

    local index = node.index

    local data = self.historyData:objectAt(index)

    -- required int32 playerId = 1;                    //玩家ID
    -- required string employerPlayerName = 2;         //雇佣者玩家名
    -- required string robPlayerName = 3;              //打劫者玩家名
    -- required int32 brokerrage = 4;                  //雇佣佣金
    -- required int32 extraBrokerrage = 5;             //额外佣金      
    -- required int64 recordTime = 6;                  //记录时间

    local timestamp = math.floor(data.recordTime/1000)
    local date   = os.date("*t", timestamp)
    local timeDesc = date.year.."-"..date.month.."-"..date.day
    local timeDesc = string.format("%s", timeDesc)

    txt_date:setText(timeDesc)
    local timeDesc = string.format("%02d:%02d:%02d",date.hour,date.min,date.sec)
    txt_time:setText(timeDesc)


    -- str = string.format(str,neesBoom,level+1,guildPracticeByType[1].title)
    local str = ""

    -- 没有人来打劫
    if data.extraBrokerrage == 0 then
        -- str = TFLanguageManager:getString(ErrorCodeData.Mining_Protect_Record1)
        str = stringUtils.format(localizable.Mining_Protect_Record1, data.employerPlayerName, data.brokerrage)
        
    else
        -- str = TFLanguageManager:getString(ErrorCodeData.Mining_Protect_Record2)
        str = stringUtils.format(localizable.Mining_Protect_Record2, data.employerPlayerName, data.robPlayerName, data.extraBrokerrage)
    end

    txt_wenzi:setText(str)


end

function MiningProtectRecordLayer:loadMore()
    MiningManager:requestGuardRecord(self.pageIndex + 1)
end

return MiningProtectRecordLayer

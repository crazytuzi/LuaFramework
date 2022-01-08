--[[
******杀戮记录层*******

    -- by Chikui Peng
    -- 2016/3/28
]]

local ShaLuRewardLayer = class("ShaLuRewardLayer", BaseLayer)

function ShaLuRewardLayer:ctor(data)
    self.super.ctor(self, data)
    self.myRank = data
    self:init("lua.uiconfig_mango_new.youli.ShaluReward")
end

function ShaLuRewardLayer:initUI(ui)
    self.super.initUI(self, ui)
    self.Panel_list = TFDirector:getChildByPath(ui, "panel_reward")
    self.panel_myr = TFDirector:getChildByPath(ui, "panel_jiangli")
    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_close.logic = self
    self.txt_rank = TFDirector:getChildByPath(ui, "paiming")
    self.txt_rankNo = TFDirector:getChildByPath(ui, "txtrankNo")
    self.img_di2 = TFDirector:getChildByPath(ui, "img_di2")

    self.Img_paiming_data = {'ui_new/leaderboard/no1.png','ui_new/leaderboard/no2.png','ui_new/leaderboard/no3.png'}

    self:refreshUI()
    self:initTableView()
end

function ShaLuRewardLayer:onShow()
    self.super.onShow(self)
end

function ShaLuRewardLayer:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_close:setClickAreaLength(100)
end

function ShaLuRewardLayer:refreshUI()
    if self.myRank == 0 or self.myRank == nil then
        self.myRank = 999999
    end
    if self.myRank > 300 then
        self.txt_rank:setVisible(false)
        self.txt_rankNo:setVisible(true)
    else
        self.txt_rank:setVisible(true)
        self.txt_rank:setText(self.myRank.."")
        self.txt_rankNo:setVisible(false)
    end
    local rankConfig = ChampionsAwardData:getRewardData(4,self.myRank)
    if rankConfig ~= nil then
        local rewardList = rankConfig:getReward()
        for k,v in ipairs(rewardList) do
            local rewardItem = BaseDataManager:getReward({type = v.type,number = v.number,itemId = v.itemid})
            local node = Public:createIconNumNode(rewardItem)
            self.panel_myr:addChild(node)
            node:setScale(0.6)
            node:setPosition(ccp(4 + (k-1)*80,0))
        end
    end
end

function ShaLuRewardLayer:initTableData()
    self.dataList = ChampionsAwardData:getAllRewardDataByType(4) or {}
end

function ShaLuRewardLayer:initTableView()
    self:initTableData()
    local  tableView =  TFTableView:create()

    self.tableView = tableView
    tableView:setTableViewSize(self.Panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)

    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, handler(ShaLuRewardLayer.cellSizeForTable,self))
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, handler(ShaLuRewardLayer.tableCellAtIndex,self))
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, handler(ShaLuRewardLayer.numberOfCellsInTableView,self))
    self.tableView:addMEListener(TFTABLEVIEW_SCROLL, handler(ShaLuRewardLayer.tableScroll,self))
    self.Panel_list:addChild(tableView)
    self.tableView:reloadData()
end

function ShaLuRewardLayer:cellSizeForTable(table,idx)
    return 112,600
end

function ShaLuRewardLayer:tableCellAtIndex(table, idx)
    idx = idx + 1
    local cell = table:dequeueCell()
    if nil == cell then
        cell = TFTableViewCell:create()
        local node = createUIByLuaNew("lua.uiconfig_mango_new.youli.RewardCell")
        cell:addChild(node,1,101)
    end
    self:setCellInfo(cell,idx)
    return cell
end

function ShaLuRewardLayer:numberOfCellsInTableView(table)
    local num = #(self.dataList)
    if num < 0 then num = 0 end
    return num
end

function ShaLuRewardLayer:removeEvents()
    self.super.removeEvents(self)
end

function ShaLuRewardLayer:dispose()
    self.super.dispose(self)
end

function ShaLuRewardLayer:tableScroll(table)
    local size = self.tableView:getTableViewSize()
    local size2 = self.tableView:getContentSize()
    local pos = self.tableView:getContentOffset()
    if pos.y <= size.height - size2.height then
        self.img_di2:setVisible(false)
    else
        self.img_di2:setVisible(true)
    end
end 

function ShaLuRewardLayer:setCellInfo(cell,idx)
    local info = self.dataList[idx]
    if info == nil then
        cell:getChildByTag(101):setVisible(false)
        return
    end
    cell:getChildByTag(101):setVisible(true)
    local img_shunxu = TFDirector:getChildByPath(cell, "img_shunxu")
    local txt_num = TFDirector:getChildByPath(cell, "txt_num")
    local panel_jiangli = TFDirector:getChildByPath(cell, "panel_jiangli")

    if info.min_rank <= 3 then
        img_shunxu:setVisible(true)
        img_shunxu:setTexture(self.Img_paiming_data[info.min_rank])
        txt_num:setVisible(false)
    else
        img_shunxu:setVisible(false)
        txt_num:setVisible(true)
        if info.min_rank > 300 then
            txt_num:setText(localizable.shalu_info_txt1)
        else
            txt_num:setText(info.min_rank.."-"..info.max_rank)
        end
    end

    panel_jiangli:removeAllChildrenWithCleanup(true)
    local rewardList = info:getReward()
    for k,v in ipairs(rewardList) do
        local rewardItem = BaseDataManager:getReward({type = v.type,number = v.number,itemId = v.itemid})
        local node = Public:createIconNumNode(rewardItem)
        panel_jiangli:addChild(node)
        node:setScale(0.6)
        node:setPosition(ccp(25 + (k-1)*90,9))
    end
end


return ShaLuRewardLayer
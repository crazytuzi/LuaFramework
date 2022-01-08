
local TreasureNewResult = class("TreasureNewResult", BaseLayer)

local numOfCol = 5

function TreasureNewResult:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.treasure.TreasureResult")
end


function TreasureNewResult:initUI(ui)
    self.super.initUI(self,ui)

    self.layer_list = TFDirector:getChildByPath(self, 'panel_neirong')

    self.panel_daoju = TFDirector:getChildByPath(self, 'bg_icon')
    self.panel_daoju:setVisible(false)

    self.panel_daoju:removeFromParentAndCleanup(false)
    self.panel_daoju:retain()
end

function TreasureNewResult:loadData(rewardList)
    self.rewardList = rewardList
    print("rewardList----------------")
    print(rewardList)
    self.totalItem = #rewardList
    self.pageNum = math.ceil(self.totalItem / numOfCol)

end

function TreasureNewResult:registerEvents()
    self.super.registerEvents(self)

end

function TreasureNewResult:removeEvents()

    self.super.removeEvents(self)
end


function TreasureNewResult:removeUI()
    self.super.removeUI(self)
end

function TreasureNewResult:onShow()
    self.super.onShow(self)

    self:refreshUI()
end

function TreasureNewResult:dispose()
    self.super.dispose(self)
end

function TreasureNewResult:refreshUI()   
    self:drawEggRewardList()
end


function TreasureNewResult:drawEggRewardList()
    if self.tableView ~= nil then
        self.tableView:reloadData()
        return
    end

    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.layer_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView:setPosition(self.layer_list:getPosition())
    self.tableView = tableView
    self.tableView.logic = self

    local function numberOfCellsInTableView(table)
        return self.pageNum
    end

    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, numberOfCellsInTableView)
    tableView:reloadData()

    self.layer_list:getParent():addChild(self.tableView,1)

--[[
    if self.pageNum > 2 then
         self.tableView:setContentOffset(ccp(0, -60));
    end
    ]]
end

function TreasureNewResult.cellSizeForTable(table,idx)
    return 140,710
end

function TreasureNewResult.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic

    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        for i=1,numOfCol do
            local node = self.panel_daoju:clone()
            node:setVisible(true)
            node:setPosition(ccp((i-1)*140 + 8, 0))
            cell:addChild(node,10);
            node:setTag(100+i)
            node:setScale(1)
        end
    end
    --绘制每个节点
    for i=1,numOfCol do
        local node = cell:getChildByTag(100+i)

        local index = idx * numOfCol + i

        node:setVisible(true)
        if index > self.totalItem then
            node:setVisible(false)
        else
            self:drawReward(node, index)


        end
    end

    return cell
end

function TreasureNewResult:drawReward(node, index)
    local reward = self.rewardList[index]
    --required int32 resType = 1;         //资源类型
    --required int32 resId = 2;           //资源ID
    --required int32 number = 3;          //资源个数
    local commonReward ={}
    commonReward.type   = reward.resType
    commonReward.itemId = reward.resId
    commonReward.number = reward.number


    local rewardItem =  BaseDataManager:getReward(commonReward) 

    Public:loadIconNode(node,rewardItem)
    
 

end

return TreasureNewResult
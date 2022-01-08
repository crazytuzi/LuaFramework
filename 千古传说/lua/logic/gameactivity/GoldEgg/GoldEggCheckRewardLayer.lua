
local GoldEggCheckRewardLayer = class("GoldEggCheckRewardLayer", BaseLayer)

local numOfCol = 5

function GoldEggCheckRewardLayer:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.zadan.ZaDanCheck")
end

function GoldEggCheckRewardLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.layer_list = TFDirector:getChildByPath(self, 'panel_neirong')

    self.panel_daoju = TFDirector:getChildByPath(self, 'bg_icon')
    self.panel_daoju:setVisible(false)

    self.panel_daoju:removeFromParentAndCleanup(false)
    self.panel_daoju:retain()
end

function GoldEggCheckRewardLayer:setRewardList(rewardList)
    self.rewardList = rewardList

    self.totalItem = rewardList:length()


    self.pageNum = math.ceil(self.totalItem / numOfCol)

end

function GoldEggCheckRewardLayer:registerEvents()
    self.super.registerEvents(self)



end

function GoldEggCheckRewardLayer:removeEvents()

    self.super.removeEvents(self)
end


function GoldEggCheckRewardLayer:removeUI()
    self.super.removeUI(self)
end

function GoldEggCheckRewardLayer:onShow()
    self.super.onShow(self)

    self:refreshUI()
end

function GoldEggCheckRewardLayer:dispose()
    self.super.dispose(self)
end

function GoldEggCheckRewardLayer:refreshUI()

   
    self:drawEggRewardList()

end


function GoldEggCheckRewardLayer:drawEggRewardList()
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


    if self.pageNum > 2 then
         self.tableView:setContentOffset(ccp(0, -60));
    end
end

function GoldEggCheckRewardLayer.cellSizeForTable(table,idx)
    return 125,650
end

function GoldEggCheckRewardLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic

    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        for i=1,numOfCol do
            local node = self.panel_daoju:clone()
            node:setVisible(true)
            node:setPosition(ccp((i-1)*120 + 30, 0))
            cell:addChild(node,10);
            node:setTag(100+i)
            node:setScale(0.8)
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

function GoldEggCheckRewardLayer:drawReward(node, index)
    local rewardItem = self.rewardList:objectAt(index)

    Public:loadIconNode(node,rewardItem)
end

return GoldEggCheckRewardLayer
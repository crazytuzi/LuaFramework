--[[
******宝箱预览列表*******
    -- quanhuan
]]
local zyBoxPop = class("zyBoxPop", BaseLayer);

CREATE_SCENE_FUN(zyBoxPop);
CREATE_PANEL_FUN(zyBoxPop);

function zyBoxPop:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.faction.zyBoxPop");
end

function zyBoxPop:initUI(ui)
    self.super.initUI(self,ui);

    self.txt_cishu     = TFDirector:getChildByPath(ui, 'txt_cishu');
    self.Img_boxtips    = TFDirector:getChildByPath(ui, 'Img_boxtips');

    self.node_reward    = TFDirector:getChildByPath(ui, 'node_reward');
    self.node_reward_positionX = self.node_reward:getPosition().x
    self.bg_width = self.Img_boxtips:getSize().width
end

function zyBoxPop:loadData(rewardList, number)
   -- print(rewardList)
    self.rewardList = rewardList;
    self:refreshUI()

    self.txt_cishu:setText(number)   
end

function zyBoxPop:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function zyBoxPop:refreshBaseUI()

end

function zyBoxPop:refreshUI()

    local rewardList = self.rewardList;

    local cell_width = 123;

    local length = math.min(3 , rewardList:length()) 
    local offsetWidth = math.floor((3-length)*cell_width/2)

    self.node_reward:setPosition(ccp(self.node_reward_positionX + offsetWidth ,self.node_reward:getPosition().y ));
    if self.tableView == nil then
        local  tableView =  TFTableView:create()
        tableView:setName("btnTableView")
        self.tableView = tableView
        self.tableView.logic = self
        tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
        tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
        tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
        self.node_reward:addChild(self.tableView,1)
        self.tableView:setPosition(ccp(0,0))
        self.tableView:setTableViewSize(self.node_reward:getSize())
        self.tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
    end
    --self.tableView:setTableViewSize(ccs(cell_width*length ,self.node_reward:getSize().height))
    if rewardList:length() > 3 then
        self.tableView:setInertiaScrollEnabled(true)
    else
        self.tableView:setInertiaScrollEnabled(false)
    end
    --self.tableView:setPosition(self.node_reward:getPosition())
    self.tableView:reloadData();
end


function zyBoxPop.cellSizeForTable(table,idx)
    return 170,123
end

function zyBoxPop.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()

    local rewardList = table.logic.rewardList;
    local reward = rewardList:getObjectAt(idx+1);
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        local reward_item = Public:createRewardNode(reward);
        reward_item:setScale(0.9)
        reward_item:setPosition(ccp(-7,0))
        cell.reward_item = reward_item
        cell:addChild(reward_item);
    else
        Public:loadIconNode(cell.reward_item,reward)
    end
    return cell
end

function zyBoxPop.numberOfCellsInTableView(table)
    return table.logic.rewardList:length()
end

function zyBoxPop:removeUI()
   self.super.removeUI(self);
end

--注册事件
function zyBoxPop:registerEvents()
    self.super.registerEvents(self);
end

function zyBoxPop:removeEvents()
    self.super.removeEvents(self)
end

return zyBoxPop;

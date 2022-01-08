local ArenaRewardListLayer = class("ArenaRewardListLayer", BaseLayer);

ArenaRewardListLayer.LIST_ITEM_HEIGHT = 45; 

CREATE_SCENE_FUN(ArenaRewardListLayer);
CREATE_PANEL_FUN(ArenaRewardListLayer);

--[[
******群豪榜-奖励说明弹窗*******

    -- by haidong.gan
    -- 2013/12/27
]]

function ArenaRewardListLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.arena.ArenaRewardListLayer");
end

function ArenaRewardListLayer:initUI(ui)
    self.super.initUI(self,ui);
    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');

    self.bg_table       = TFDirector:getChildByPath(ui, 'panel_list');

    local  tableView    =  TFTableView:create()
    self.table_reward   = tableView

    tableView.logic = self;
    tableView:setTableViewSize(self.bg_table:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)


    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    Public:bindScrollFun(tableView);
    tableView:reloadData()
    tableView:scrollToYTop(0);
    self.bg_table:addChild(tableView)

end

function ArenaRewardListLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function ArenaRewardListLayer:refreshBaseUI()

end

function ArenaRewardListLayer.cellSizeForTable(tableView,idx)
    return ArenaRewardListLayer.LIST_ITEM_HEIGHT,960
end

function ArenaRewardListLayer.tableCellAtIndex(tableView, idx)
    local self = tableView.logic;
    local cell = tableView:dequeueCell()
    if nil == cell then
        tableView.cells = tableView.cells or {}
        cell = TFTableViewCell:create()
        tableView.cells[cell] = true

        local reward_node = createUIByLuaNew("lua.uiconfig_mango_new.arena.ArenaRewardItem");
        cell:addChild(reward_node);
        cell.reward_node = reward_node;
      
    end
    local rewardItem = ArenaManager.rewardList:objectAt(idx + 1);
    self:loadRewardNode(cell.reward_node,rewardItem,idx + 1);
    return cell
end

function ArenaRewardListLayer.numberOfCellsInTableView(tableView)

    local self = tableView.logic;
    return  ArenaManager.rewardList:length();
end

--添加玩家节点
function ArenaRewardListLayer:loadRewardNode(reward_node,rewardItem,index)
    -- local txt_rank = TFDirector:getChildByPath(reward_node, 'txt_mingci');
    -- txt_rank:setText("第" .. rewardItem.min_rank .. "-" .. rewardItem.max_rank .. "名");

    local img_mingci = TFDirector:getChildByPath(reward_node, 'img_mingci');
    local txt_mingci = TFDirector:getChildByPath(reward_node, 'txt_mingci');
    local bg = TFDirector:getChildByPath(reward_node, 'img_di');

    if index < 8 then
        img_mingci:setVisible(true);
        txt_mingci:setVisible(false);

        img_mingci:setTexture("ui_new/spectrum/qh_" .. index .. ".png")
        bg:setTexture("ui_new/spectrum/qh_bangdandi3.png")
        
    else
        img_mingci:setVisible(false);
        txt_mingci:setVisible(true);
        local str = stringUtils.format(localizable.arenarewardlayer_list, rewardItem.min_rank, rewardItem.max_rank)
        txt_mingci:setText(str)
        bg:setTexture("ui_new/spectrum/qh_bangdandi1.png")
    end

    local itemList = RewardConfigureData:GetRewardItemListById(rewardItem.reward_id);
    local txt_reward = {}
    txt_reward[1] = TFDirector:getChildByPath(reward_node, 'txt_tongqianzhi');
    txt_reward[2] = TFDirector:getChildByPath(reward_node, 'txt_xisuidanzhi');
    txt_reward[3] = TFDirector:getChildByPath(reward_node, 'txt_tongxinwanzhi');

    txt_reward[1]:setText(0);
    txt_reward[2]:setText(0);
    -- txt_reward[3]:setText(0);


    if itemList then
        local index = 1;
        for rewardItem in itemList:iterator() do
            if index > 3 then
                return;
            end 
            txt_reward[index]:setText(rewardItem.number);
            index = index + 1;
        end
    end
end

function ArenaRewardListLayer:removeUI()
    self.super.removeUI(self);
end

function ArenaRewardListLayer:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_close:setClickAreaLength(100);

end

function ArenaRewardListLayer:removeEvents()
    self.super.removeEvents(self);

end

return ArenaRewardListLayer;

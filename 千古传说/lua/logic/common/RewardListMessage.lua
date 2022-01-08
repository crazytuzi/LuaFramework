--[[
******奖励结果列表*******

    -- by haidong.gan
    -- 2013/11/27
]]
local RewardListMessage = class("RewardListMessage", BaseLayer);

CREATE_SCENE_FUN(RewardListMessage);
CREATE_PANEL_FUN(RewardListMessage);

local item_width = 130
local item_height = 145

function RewardListMessage:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.common.RewardListMessage");
end

function RewardListMessage:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_ok          = TFDirector:getChildByPath(ui, 'btn_ok');
    self.bg              = TFDirector:getChildByPath(ui, 'bg');
    self.bg.width        = self.bg:getSize().width;


    self.node_reward        = TFDirector:getChildByPath(ui, 'node_reward');
    self.node_reward.x      = self.node_reward:getPositionX();
    self.node_reward.width  = self.node_reward:getSize().width;
    self.item_panels    = {}
    -- self.node_reward_positionX = self.node_reward:getPosition().x
    -- self.bg_width = self.bg:getSize().width
end

function RewardListMessage:loadData(rewardList)
    self.rewardList = rewardList;
    self:refreshUI();
    self:showGetHero()
end

function RewardListMessage:showGetHero()
    local hero_list = TFArray:new()
    for v in self.rewardList:iterator() do
        if v.type == EnumDropType.ROLE then
            hero_list:push(v.itemid)
        end
    end

    function showGetHeroResultLayer()
        if hero_list:length() > 0 then
            local layer = require("lua.logic.shop.GetHeroResultLayer"):new(hero_list:pop())
            layer:setReturnFun(function ()
                    AlertManager:close()
                    showGetHeroResultLayer()
                end)
            AlertManager:addLayer(layer, AlertManager.BLOCK)
            AlertManager:show()
        end
    end
    showGetHeroResultLayer()
end

function RewardListMessage:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function RewardListMessage:refreshBaseUI()

end

function RewardListMessage:refreshUI()
    local rewardList = self.rewardList;
    if self.tableView == nil then
        local  tableView =  TFTableView:create()
        tableView:setName("btnTableView")
        self.tableView = tableView
        tableView.logic = self
        tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, RewardListMessage.cellSizeForTable)
        tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, RewardListMessage.tableCellAtIndex)
        tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, RewardListMessage.numberOfCellsInTableView)
        tableView:setTableViewSize(self.node_reward:getSize())
        tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
        tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLBOTTOMUP)
        self.node_reward:addChild(tableView, 1)
    end

    -- local scrollEnabled = rewardList:length() > 3
    -- self.tableView:setInertiaScrollEnabled(scrollEnabled)
    -- self.tableView:setVisible(scrollEnabled)

    -- for i=1, #self.item_panels do
    --     self.node_reward:removeChild(self.item_panels[i])
    -- end
    -- self.item_panels = {}
    
    -- if rewardList:length() > 3 then
    --     self.tableView:reloadData()
    -- else
    --     local width = self.node_reward:getSize().width
    --     local height = self.node_reward:getSize().height

    --     local offsetX = width / 2 - rewardList:length() * item_width / 2
    --     for reward in rewardList:iterator() do
    --         local reward_item = Public:createRewardNode(reward)
    --         reward_item:setPosition(ccp(offsetX, 0))
    --         self.node_reward:addChild(reward_item)
    --         offsetX = offsetX + item_width
    --         self.item_panels[#self.item_panels + 1] = reward_item
    --     end
    -- end

    local rewardSize = rewardList:length()
    local scrollEnabled = rewardSize > 5
    self.tableView:setInertiaScrollEnabled(scrollEnabled)
    self.tableView:setVisible(scrollEnabled)

    for i=1, #self.item_panels do
        self.node_reward:removeChild(self.item_panels[i])
    end
    self.item_panels = {}

    self:adjustRewardBox()

    if rewardSize > 5 then
        self.tableView:reloadData()
    else
        local width = self.node_reward:getSize().width
        local height = self.node_reward:getSize().height

        local offsetX = width / 2 - rewardList:length() * item_width / 2
        for reward in rewardList:iterator() do
            local reward_item = Public:createRewardNode(reward)
            reward_item:setPosition(ccp(offsetX, 0))
            self.node_reward:addChild(reward_item)
            offsetX = offsetX + item_width
            self.item_panels[#self.item_panels + 1] = reward_item
        end
    end
end

function RewardListMessage:adjustRewardBox()
    local rewardSize = self.rewardList:length()
    local bg = self.bg
    local node_reward = self.node_reward
    local tableView = self.tableView
    if rewardSize < 4 then
        bg:setSize(ccs(bg.width, bg:getSize().height))
        node_reward:setSize(ccs(node_reward.width, node_reward:getSize().height))
        node_reward:setPositionX(node_reward.x)
        tableView:setSize(node_reward:getSize())
    else
        local adjustX = rewardSize - 3
        adjustX = adjustX >= 3 and 2.5 or adjustX
        adjustX = adjustX * item_width
        bg:setSize(ccs(bg.width + adjustX, bg:getSize().height))
        node_reward:setSize(ccs(node_reward.width + adjustX, node_reward:getSize().height))
        node_reward:setPositionX(node_reward.x - adjustX / 2)
        tableView:setTableViewSize(node_reward:getSize())
        tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
        tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLBOTTOMUP)
    end
end

function RewardListMessage.cellSizeForTable(table,idx)
    return item_height, item_width
end

function RewardListMessage.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()

    local rewardList = table.logic.rewardList;
    local reward = rewardList:getObjectAt(idx+1);
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        local reward_item = Public:createRewardNode(reward);
        cell.reward_item = reward_item
        cell:addChild(reward_item);
    else
        Public:loadIconNode(cell.reward_item,reward)
    end

    return cell
end

function RewardListMessage.numberOfCellsInTableView(table)
    return table.logic.rewardList:length()
end

function RewardListMessage:removeUI()
   self.super.removeUI(self);
end

--注册事件
function RewardListMessage:registerEvents()
    self.super.registerEvents(self);

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_ok);
end

function RewardListMessage:removeEvents()
    self.super.removeEvents(self)
    self.btn_ok:removeMEListener(TFWIDGET_CLICK)
    if self.ntimer then
        TFDirector:removeTimer(self.ntimer)
        self.ntimer = nil
    end
end
return RewardListMessage;

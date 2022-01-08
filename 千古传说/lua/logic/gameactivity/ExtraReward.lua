--[[
******宝箱预览列表*******
    -- quanhuan
]]
local ExtraReward = class("ExtraReward", BaseLayer);

CREATE_SCENE_FUN(ExtraReward);
CREATE_PANEL_FUN(ExtraReward);

function ExtraReward:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.operatingactivities.extraReward");
end

function ExtraReward:initUI(ui)
    self.super.initUI(self,ui);

    self.Txt_letter     = TFDirector:getChildByPath(ui, 'Txt_letter');
    self.Img_boxtips    = TFDirector:getChildByPath(ui, 'Img_boxtips');

    self.node_reward    = TFDirector:getChildByPath(ui, 'node_reward');
    self.node_reward_positionX = self.node_reward:getPosition().x
    self.bg_width = self.Img_boxtips:getSize().width
end

function ExtraReward:loadData(rewardList, extraNum)
   -- print(rewardList)
    self.rewardList = rewardList;
    self:refreshUI()

    -- self.Txt_letter:setString(extraNum.."星可领取")
    self.Txt_letter:setString(stringUtils.format(localizable.ExtraReward_num,extraNum))

    --self:showGetHero()
end

-- function RewardListMessage:showGetHero()
--     local hero_list = TFArray:new()
--     for v in self.rewardList:iterator() do
--         if v.type == EnumDropType.ROLE then
--             hero_list:push(v.itemid)
--         end
--     end

--     function showGetHeroResultLayer()
--         if hero_list:length() > 0 then
--             local layer = require("lua.logic.shop.GetHeroResultLayer"):new(hero_list:pop())
--             layer:setReturnFun(function ()
--                     AlertManager:close()
--                     showGetHeroResultLayer()
--                 end)
--             AlertManager:addLayer(layer, AlertManager.BLOCK)
--             AlertManager:show()
--         end
--     end
--     showGetHeroResultLayer()
-- end

function ExtraReward:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function ExtraReward:refreshBaseUI()

end

function ExtraReward:refreshUI()

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
        tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, ExtraReward.cellSizeForTable)
        tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, ExtraReward.tableCellAtIndex)
        tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, ExtraReward.numberOfCellsInTableView)
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


function ExtraReward.cellSizeForTable(table,idx)
    return 170,123
end

function ExtraReward.tableCellAtIndex(table, idx)
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

function ExtraReward.numberOfCellsInTableView(table)
    return table.logic.rewardList:length()
end

function ExtraReward:removeUI()
   self.super.removeUI(self);
end

--注册事件
function ExtraReward:registerEvents()
    self.super.registerEvents(self);
end

function ExtraReward:removeEvents()
    self.super.removeEvents(self)
end

return ExtraReward;

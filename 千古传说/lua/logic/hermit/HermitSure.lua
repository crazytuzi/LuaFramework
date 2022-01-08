--[[
******归隐确认*******

]]
local HermitSure = class("HermitSure", BaseLayer);

CREATE_SCENE_FUN(HermitSure);
CREATE_PANEL_FUN(HermitSure);

function HermitSure:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.common.Confirm");
end

function HermitSure:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok');
    self.btn_cancel             = TFDirector:getChildByPath(ui, 'btn_cancel');
    self.bg              = TFDirector:getChildByPath(ui, 'bg');


    self.txt_title         = TFDirector:getChildByPath(ui, 'txt')
    self.txt_title:setVisible(false)
    
    self.node_reward    = TFDirector:getChildByPath(ui, 'Panel_Confirm_1');
    self.node_reward_positionX = self.node_reward:getPosition().x
    self.bg_width = self.bg:getSize().width
end

function HermitSure:loadData(rewardList)
    self.rewardList = rewardList;
    self:refreshUI();
end

function HermitSure:setTitle( text ,color)
    if text ~= nil then
        self.txt_title:setVisible(true)
        self.txt_title:setText(text)
    else
        self.txt_title:setVisible(false)
    end
    if color == nil then
        color = ccc3(0,0,0)
    end
    self.txt_title:setColor(color)
end

function HermitSure:onShow()
    self.super.onShow(self)
end


function HermitSure:refreshUI()
    local rewardList = self.rewardList;

    -- local cell_width = 138;
    -- local cell_height = 120;

    -- local length = math.min(4 , rewardList:length())
    -- self.length = length
    -- local width = math.max(math.min(cell_width * length + 80,800),800);

    -- local rewardwidthoffset = width - ( cell_width * length + 80);

    -- self.node_reward:setPosition(ccp(self.node_reward_positionX - (width - self.bg_width) / 2 + rewardwidthoffset /2 ,self.node_reward:getPosition().y ));
    -- -- self.bg:setSize(ccs( width ,self.bg:getSize().height))
    if self.tableView == nil then
        local tableView = TFTableView:create()
        tableView:setName("btnTableView")
        self.tableView = tableView
        tableView.logic = self
        tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, HermitSure.cellSizeForTable)
        tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, HermitSure.tableCellAtIndex)
        tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, HermitSure.numberOfCellsInTableView)
        tableView:setPosition(self.node_reward:getPosition())
        tableView:setTableViewSize(self.node_reward:getSize())
        tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
        tableView:setVerticalFillOrder(0)
        self.node_reward:getParent():addChild(self.tableView,1)

    end
    -- self.tableView:setTableViewSize(ccs(cell_width*length ,self.node_reward:getSize().height))--,cell_height * math.ceil(length/6)))--
    
    -- self.tableView:setVerticalFillOrder(0)
    if rewardList:length() > 4 then
        self.tableView:setInertiaScrollEnabled(true)
    else
        self.tableView:setInertiaScrollEnabled(false)
    end    
    self.tableView:reloadData();
end


function HermitSure.cellSizeForTable(table,idx)
    -- return 120,138*table.logic.length
    return 120, 517
end

function HermitSure.tableCellAtIndex(table, idx)
    local self = table.logic;
    local cell = table:dequeueCell()

    local rewardList = self.rewardList;
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        for i=1,4 do
            local index = i+idx*4
            if index <= rewardList:length() then
                local reward = rewardList:getObjectAt(index);
                local reward_item = Public:createRewardNode(reward);
                reward_item:setScale(0.9)
                cell.reward_item = cell.reward_item or {}
                cell.reward_item[i] = reward_item
                reward_item:setPosition(120*i - 100,0)
                cell:addChild(reward_item);
            end
        end
    else
        for i=1,4 do
            local index = i+idx*4
            if index <= rewardList:length() then
                local reward = rewardList:getObjectAt(index);
                if cell.reward_item[i] then
                    cell.reward_item[i]:setVisible(true)
                    Public:loadIconNode(cell.reward_item[i],reward)
                else
                    local reward_item = Public:createRewardNode(reward);
                    reward_item:setScale(0.9)
                    cell.reward_item = cell.reward_item or {}
                    cell.reward_item[i] = reward_item
                    reward_item:setPosition(120*i-100 ,0)
                    cell:addChild(reward_item);
                end
            else
                if cell.reward_item[i] then
                    cell.reward_item[i]:setVisible(false)
                end
            end
        end
    end

    return cell
end

function HermitSure.numberOfCellsInTableView(table)
    local length = math.ceil(table.logic.rewardList:length()/4)
    return length
end

function HermitSure:removeUI()
   self.super.removeUI(self);
end

--注册事件
function HermitSure:registerEvents()
    self.super.registerEvents(self);

    -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_ok);
end

function HermitSure:removeEvents()
    self.super.removeEvents(self)
    self.btn_ok:removeMEListener(TFWIDGET_CLICK)
    if self.ntimer then
        TFDirector:removeTimer(self.ntimer)
        self.ntimer = nil
    end
end

function HermitSure:setBtnHandle(okhandle, cancelhandle)
    if self.btn_ok then
        self.btn_ok.logic       = self
        self.btn_ok:addMEListener(TFWIDGET_CLICK,audioClickfun(function()
            AlertManager:close()
            okhandle()
        end),1)
    end
    if self.btn_cancel then
        self.btn_cancel.logic   = self
        if cancelhandle then
            self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(function()
                cancelhandle()
            end),1)
        else
            self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCancelBtnClickHandle),1)
        end
    end

end

function HermitSure.onCancelBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end
return HermitSure;

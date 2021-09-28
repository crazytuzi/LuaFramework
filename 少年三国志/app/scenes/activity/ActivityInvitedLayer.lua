
local ActivityInvitedLayer = class("ActivityInvitedLayer",UFCCSNormalLayer)

require("app.cfg.spread_reward_info")

function ActivityInvitedLayer.create(...)
    local layer = require("app.scenes.activity.ActivityInvitedLayer").new("ui_layout/activity_ActivityInvitedFinalLayer.json", ...)
    return layer
end

function ActivityInvitedLayer:ctor(json,...)
    self.super.ctor(self, ...)
    
    self._talkLabel = self:getLabelByName("Label_bubble")
    self._talkLabel:setText(G_lang:get("LANG_INVITED_TALK"))
    self._levelLabel = self:getLabelByName("Label_level")
    self._levelLabel:setText(G_lang:get("LANG_INVITED_LEVEL"))

    self._inputButton = self:getButtonByName("Button_input")
    self._getButton = self:getButtonByName("Button_get")
    self._gotImg = self:getImageViewByName("Image_bought")

    self:registerBtnClickEvent("Button_input", function()
        local gold = require("app.scenes.activity.ActivityInvitorGetID").create()
        uf_sceneManager:getCurScene():addChild(gold)
    end)
    self:registerBtnClickEvent("Button_get", function()
        G_HandlersManager.activityHandler:sendInvitedDrawReward(G_Me.activityData.invited.id)
    end)

    -- self:initScrollView()
    self:updateList()
end

function ActivityInvitedLayer:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_INVITEDGETDRAWREWARD, self._onGetInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_QUERYREGISTERRELATION, self._onGetRelation, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REGISTERID, self._onRegisterId, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_INVITEDDRAWREWARD, self._onDrawReward, self)
end

function ActivityInvitedLayer:_onGetInfo(data)   
    -- self:updateScrollView()
    self:updateView()
end

function ActivityInvitedLayer:_onDrawReward(data)   
    if data.ret == 1 then
        local info = spread_reward_info.get(data.rewardId)
        local award = {}
        for i = 1 , 4 do 
            if info["item_type"..i] > 0 then
                table.insert(award,#award+1,{type=info["item_type"..i],value=info["item_value"..i],size=info["item_size"..i]})
            end
        end
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(award)
        uf_notifyLayer:getModelNode():addChild(_layer,1000)
        -- self:updateScrollView()
        -- self._listView:reloadWithLength( #G_Me.activityData.invited.awardList)
        self:updateView()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
    end
end

function ActivityInvitedLayer:_onGetRelation(data)   
    -- self._listView:reloadWithLength( #G_Me.activityData.invited.awardList)
    self:updateView()
end

function ActivityInvitedLayer:_onRegisterId(data)   
    if data.ret == 1 then
        -- local awardInfo = {}
        -- for index = 1 , spread_reward_info.getLength() do 
        --     local info = spread_reward_info.indexOf(index)
        --     if info.type == "3" then
        --         awardInfo = info
        --     end
        -- end
        -- local info = awardInfo
        -- local award = {}
        -- for i = 1 , 3 do 
        --     if info["item_type"..i] > 0 then
        --         table.insert(award,#award+1,{type=info["item_type"..i],value=info["item_value"..i],size=info["item_size"..i]})
        --     end
        -- end
        -- local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(award)
        -- uf_notifyLayer:getModelNode():addChild(_layer,1000)
        -- self._listView:reloadWithLength( #G_Me.activityData.invited.awardList)
        G_MovingTip:showMovingTip(G_lang:get("LANG_INVITED_BINDSUCCESS"))
        self:updateView()
    end
end

function ActivityInvitedLayer:showPage()   
    G_HandlersManager.activityHandler:sendInvitedGetDrawReward()
    G_HandlersManager.activityHandler:sendQueryRegisterRelation()
end

function ActivityInvitedLayer:updateView()
    if not G_Me.activityData.invited.hasBind then
        self._inputButton:setVisible(true)
        self._getButton:setVisible(false)
        self._gotImg:setVisible(false)
    elseif G_Me.activityData.invited:hasGot(G_Me.activityData.invited.id) then
        self._inputButton:setVisible(false)
        self._getButton:setVisible(false)
        self._gotImg:setVisible(true)
    else
        self._inputButton:setVisible(false)
        self._getButton:setVisible(true)
        self._gotImg:setVisible(false)
    end
end

function ActivityInvitedLayer:updateList()
    local info = spread_reward_info.get(G_Me.activityData.invited.id)
    local award = {}
    for i = 1 , 4 do 
        if info["item_type"..i] > 0 then
            table.insert(award,#award+1,{type=info["item_type"..i],value=info["item_value"..i],size=info["item_size"..i]})
        end
    end
    self._iconList = GlobalFunc.createIconInPanel({panel=self:getPanelByName("Panel_awardIcon"),award=award,click=true,left=true,offset=1})
end

function ActivityInvitedLayer:updatePage()
    
end

function ActivityInvitedLayer:adapterLayer()
    -- self:adapterWidgetHeight("Panel_buttom","Panel_top","",8,0)
    -- local height = self:getPanelByName("Panel_buttom"):getContentSize().height
    -- self._listPanel:setSize(CCSize(594,height-20))

    -- self:initScrollView()
end

function ActivityInvitedLayer:initScrollView()   
    -- if self._listView == nil then
    --     self._listView = CCSListViewEx:createWithPanel(self._listPanel, LISTVIEW_DIR_VERTICAL)
    --     self._listView:setSpaceBorder(0, 40)
    --     self._listView:setCreateCellHandler(function ( list, index)
    --         return require("app.scenes.activity.ActivityInvitedListCell").new(list, index)
    --     end)
    --     self._listView:setUpdateCellHandler(function ( list, index, cell)
    --         local data = G_Me.activityData.invited.awardList
    --         if  index < #data then
    --            cell:updateData(data[index+1]) 
    --         end
    --     end)
    --     self._listView:initChildWithDataLength( #G_Me.activityData.invited.awardList)
    -- end
end

-- function ActivityInvitedLayer:updateScrollView()   
--     self._listView:refreshAllCell()
-- end

function ActivityInvitedLayer:onLayerExit()
    -- if self._schedule then
    --     GlobalFunc.removeTimer(self._schedule)
    -- end
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end

return ActivityInvitedLayer

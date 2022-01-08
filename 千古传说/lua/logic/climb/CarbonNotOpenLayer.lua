--[[
******无量山-万能副本未开放*******

    -- by Stephen.tao
    -- 2014/2/27
]]

local CarbonNotOpenLayer = class("CarbonNotOpenLayer", BaseLayer)

--CREATE_SCENE_FUN(CarbonNotOpenLayer)
CREATE_PANEL_FUN(CarbonNotOpenLayer)


function CarbonNotOpenLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.climb.CarbonNotOpenLayer");
end

function CarbonNotOpenLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.btn_close             = TFDirector:getChildByPath(ui, 'btn_close')

    self.txt_message        = TFDirector:getChildByPath(ui, 'txt_message')
    self.img_title          = TFDirector:getChildByPath(ui, 'img_title')

    self.node_reward1           = TFDirector:getChildByPath(ui, 'node_reward1')
    self.node_reward2           = TFDirector:getChildByPath(ui, 'node_reward2')
    self.node_reward3           = TFDirector:getChildByPath(ui, 'node_reward3')
    self.node_reward4           = TFDirector:getChildByPath(ui, 'node_reward4')
end

function CarbonNotOpenLayer:loadData(index)
    self.carbonItem = MoHeYaConfigure:objectAt(index);

    print("--- CarbonNotOpenLayer:loadData index = ",index)
    local carbonItem1 = MoHeYaConfigure:objectAt(index);
    local rewardList1 = ClimbManager:getSoulRewardItemList(carbonItem1.id)

    local _index = 1;
    for reward in rewardList1:iterator() do
        local rewardNode = Public:createIconNumNode(reward)
        -- local txt_num   = TFDirector:getChildByPath(rewardNode, 'txt_num');
        -- txt_num:setVisible(false);
        
        rewardNode:setScale(0.6);
        rewardNode:setPosition((_index - 1) * 75,0)
        self.node_reward1:addChild(rewardNode);
        _index = _index + 1;
    end


    local carbonItem2 = MoHeYaConfigure:objectAt(index + 1);
    local rewardList2 = ClimbManager:getSoulRewardItemList(carbonItem2.id)

    _index = 1;
    for reward in rewardList2:iterator() do
        local rewardNode = Public:createIconNumNode(reward)
        -- local txt_num   = TFDirector:getChildByPath(rewardNode, 'txt_num');
        -- txt_num:setVisible(false);
        
        rewardNode:setScale(0.6);
        rewardNode:setPosition((_index - 1) * 75,0)
        self.node_reward2:addChild(rewardNode);
        _index = _index + 1;
    end

    local carbonItem3 = MoHeYaConfigure:objectAt(index +2);
    local rewardList3 = ClimbManager:getSoulRewardItemList(carbonItem3.id)

    _index = 1;
    for reward in rewardList3:iterator() do
        local rewardNode = Public:createIconNumNode(reward)
        -- local txt_num   = TFDirector:getChildByPath(rewardNode, 'txt_num');
        -- txt_num:setVisible(false);
        
        rewardNode:setScale(0.6);
        rewardNode:setPosition((_index - 1) * 75,0)
        self.node_reward3:addChild(rewardNode);
        _index = _index + 1;
    end

    local carbonItem4 = MoHeYaConfigure:objectAt(index +3);
    local rewardList4 = ClimbManager:getSoulRewardItemList(carbonItem4.id)

    _index = 1;
    for reward in rewardList4:iterator() do
        local rewardNode = Public:createIconNumNode(reward)
        -- local txt_num   = TFDirector:getChildByPath(rewardNode, 'txt_num');
        -- txt_num:setVisible(false);
        
        rewardNode:setScale(0.6);
        rewardNode:setPosition((_index - 1) * 75,0)
        self.node_reward4:addChild(rewardNode);
        _index = _index + 1;
    end

    self.img_title:setTexture("ui_new/climb/img_soul_title_word" .. math.ceil(self.carbonItem.id / 4) .. ".png")
    self.txt_message:setText(self.carbonItem.open_description)
end

function CarbonNotOpenLayer:removeUI()
	self.super.removeUI(self)
end


function CarbonNotOpenLayer:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);

    self.btn_close:setClickAreaLength(100);
end


return CarbonNotOpenLayer

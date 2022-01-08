--[[
******缘分详情*******
    -- by haidong.gan
    -- 2014/4/10
]]

local FateDetail = class("FateDetail", BaseLayer)
local CardRole = require('lua.gamedata.base.CardRole')
function FateDetail:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.role.FateDetail")
end

function FateDetail:loadData(roleGmId)
    self.roleGmId   = roleGmId;
end

function FateDetail:setRoleId(roleId)
    self.roleId   = roleId;
end

function FateDetail:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();

    if self.scrollView then
        self.scrollView:removeFromParent();
        self.scrollView = nil;
    end

    if self.roleId == nil then
        self:refreshUI();
    else
        self:refreshUIWithRoleId()
    end
end

function FateDetail:refreshBaseUI()

end

function FateDetail:refreshUI()
    if not self.isShow then
        return;
    end
    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmId);
    
    self.txt_des:setText(self.cardRole.describe1);

    local fateArray = RoleFateData:getRoleFateById(self.cardRole.id)
    
    local scrollView = TFScrollView:create()
    scrollView:setPosition(ccp(0,0))
    scrollView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)

    scrollView:setSize(self.list_fate:getSize())
    scrollView:setInnerContainerSize(CCSizeMake(self.list_fate:getSize().width , 100 * fateArray:length() + 40))
    self.list_fate:addChild(scrollView)
    scrollView:setBounceEnabled(true)
    Public:bindScrollFun(scrollView);
    self.scrollView = scrollView;

    local panel_hui_yuanfen      = TFDirector:getChildByPath(self, 'panel_hui_yuanfen');
    local panel_liang_yuanfen    = TFDirector:getChildByPath(self, 'panel_liang_yuanfen');

    self.node_fateList = {}
    self.txt_fateList = {}
    self.txt_titleList = {}
    for i=1,fateArray:length() do
        self.node_fateList[i] =  panel_hui_yuanfen:clone()

        self.txt_fateList[i] = TFDirector:getChildByPath(self.node_fateList[i], "txt_yuanfen_word")
        self.txt_titleList[i] = TFDirector:getChildByPath(self.node_fateList[i], "txt_name")
        self.node_fateList[i] :setPosition(ccp(20, (fateArray:length() - i) * 100 + 40))
        scrollView:addChild(self.node_fateList[i] )
    end

    self.node_fateLList = {}
    self.txt_fateLList = {}
    self.txt_titleLList = {}
    for i=1,fateArray:length() do
        self.node_fateLList[i] = panel_liang_yuanfen:clone()
        self.txt_fateLList[i] = TFDirector:getChildByPath(self.node_fateLList[i], "txt_yuanfen_word")
        self.txt_titleLList[i] = TFDirector:getChildByPath(self.node_fateLList[i], "txt_name")
        self.node_fateLList[i]:setPosition(ccp(20, (fateArray:length() - i) * 100 + 40))
        scrollView:addChild(self.node_fateLList[i])
    end



    local index = 1;

    for fate in fateArray:iterator() do

        local status = self.cardRole:getFateStatus(fate.id)

        if status then
            self.node_fateLList[index]:setVisible(true);
        else
            self.node_fateList[index]:setVisible(true);
        end
        
        self.txt_fateList[index]:setText(fate.details);
        self.txt_fateLList[index]:setText(fate.details);
        self.txt_titleList[index]:setText(fate.title);
        self.txt_titleLList[index]:setText(fate.title);

        index = index +1;
    end
    scrollView:setInnerContainerSizeForHeight(100 * fateArray:length() + 40)
end

function FateDetail:refreshUIWithRoleId()
    if not self.isShow then
        return;
    end

    self.cardRole = CardRole:new(self.roleId)
    
    self.txt_des:setText(self.cardRole.describe1);


    local fateArray = RoleFateData:getRoleFateById(self.cardRole.id)

    local scrollView = TFScrollView:create()
    scrollView:setPosition(ccp(0,0))
    scrollView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)

    scrollView:setSize(self.list_fate:getSize())
    scrollView:setInnerContainerSize(CCSizeMake(self.list_fate:getSize().width , 100 * fateArray:length() + 40))
    self.list_fate:addChild(scrollView)
    scrollView:setBounceEnabled(true)
    Public:bindScrollFun(scrollView);
    self.scrollView = scrollView;

    local panel_hui_yuanfen      = TFDirector:getChildByPath(self, 'panel_hui_yuanfen');
    local panel_liang_yuanfen    = TFDirector:getChildByPath(self, 'panel_liang_yuanfen');

    self.node_fateList = {}
    self.txt_fateList = {}
    self.txt_titleList = {}
    for i=1,fateArray:length() do
        self.node_fateList[i] =  panel_hui_yuanfen:clone()

        self.txt_fateList[i] = TFDirector:getChildByPath(self.node_fateList[i], "txt_yuanfen_word")
        self.txt_titleList[i] = TFDirector:getChildByPath(self.node_fateList[i], "txt_name")
        self.node_fateList[i] :setPosition(ccp(20, (fateArray:length() - i) * 100 + 40))
        scrollView:addChild(self.node_fateList[i] )
    end

    self.node_fateLList = {}
    self.txt_fateLList = {}
    self.txt_titleLList = {}
    for i=1,fateArray:length() do
        self.node_fateLList[i] = panel_liang_yuanfen:clone()
        self.txt_fateLList[i] = TFDirector:getChildByPath(self.node_fateLList[i], "txt_yuanfen_word")
        self.txt_titleLList[i] = TFDirector:getChildByPath(self.node_fateLList[i], "txt_name")
        self.node_fateLList[i]:setPosition(ccp(20, (fateArray:length() - i) * 100 + 40))
        scrollView:addChild(self.node_fateLList[i])
    end

    local index = 1;

    for fate in fateArray:iterator() do

        local status = self.cardRole:getFateStatus(fate.id)

        if status then
            self.node_fateLList[index]:setVisible(true);
        else
            self.node_fateList[index]:setVisible(true);
        end
        
        self.txt_fateList[index]:setText(fate.details);
        self.txt_fateLList[index]:setText(fate.details);
        self.txt_titleList[index]:setText(fate.title);
        self.txt_titleLList[index]:setText(fate.title);

        index = index +1;
    end
    scrollView:setInnerContainerSizeForHeight(100 * fateArray:length() + 40)
end

function FateDetail:initUI(ui)
    self.super.initUI(self,ui)

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');
    self.list_fate      = TFDirector:getChildByPath(ui, 'panel_list');

    self.txt_des        = TFDirector:getChildByPath(ui, 'txt_wenben');
end

function FateDetail:registerEvents(ui)
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close);
    self.btn_close:setClickAreaLength(100);

end


return FateDetail

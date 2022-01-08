--[[
******活动提示界面*******

    -- by david.dai
    -- 2014/7/4
]]
local ActivitiesTipsLayer = class("ActivitiesTipsLayer", BaseLayer);

CREATE_SCENE_FUN(ActivitiesTipsLayer);
CREATE_PANEL_FUN(ActivitiesTipsLayer);

ActivitiesTipsLayer.LIST_ITEM_HEIGHT = 90; 

function ActivitiesTipsLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.setting.ActivitiesTipsLayer");
end

function ActivitiesTipsLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.list_item   = TFDirector:getChildByPath(ui, 'list_item');
    self.list_item:setBounceEnabled(true);

    Public:bindScrollFun(self.list_item);
    self.list_item:bindScrollArrow(ui);


    self.list_help   = TFDirector:getChildByPath(ui, 'list_help');
    self.list_help:setBounceEnabled(true);

    Public:bindScrollFun(self.list_help);


    self.btn_close        = TFDirector:getChildByPath(ui, 'btn_close');
    self.txt_content        = TFDirector:getChildByPath(ui, 'txt_content');

    local onUpdated = function(event)
          self:loadItemList();
    end;

    TFDirector:addTimer(0.1, 1, nil, onUpdated); 
end

function ActivitiesTipsLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function ActivitiesTipsLayer:refreshBaseUI()

end

local normalTexture={
    "ui_new/setting/xt_kaifu1.png",         --开服有礼
    "ui_new/setting/xt_fanxian1.png",       --充值返现
    "ui_new/setting/xt_yao1.png",           --摇出元宝
    "ui_new/setting/xt_bei1.png",           --首充三倍
}

local pressedTexture={
    "ui_new/setting/xt_kaifu.png",          --开服有礼
    "ui_new/setting/xt_fanxian.png",        --充值返现
    "ui_new/setting/xt_yao.png",            --摇出元宝
    "ui_new/setting/xt_bei.png",            --首充三倍
}

local markImage={
    "ui_new/setting/hot.png", 
    nil,
    "ui_new/setting/new.png", 
    nil,
}

function ActivitiesTipsLayer:loadItemList()
    --清除、重置列表
    self.list_item:getInnerContainer():stopAllActions();
    self.list_item:removeAllChildren();

    local function onSelectClickHandle(sender)
        self:selectItem(sender:getSelectIndex()+1)
    end

    --local length = SettingManager.helpList:length();
    local length = #normalTexture

    local btnGroup = TFButtonGroup:create()
    btnGroup:setZOrder(10)
    btnGroup:setPosition(ccp(0,10))
    btnGroup:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    btnGroup:setSize(CCSizeMake(self.list_item:getSize().width,length * (ActivitiesTipsLayer.LIST_ITEM_HEIGHT)))
    btnGroup:setLayoutType('grid')
    btnGroup:setRows(length)
    btnGroup:setColumn(1)
    btnGroup:setGap(0)
    btnGroup:addMEListener(TFGROUP_SELECTED, onSelectClickHandle)
    btnGroup:setLayoutDirect("bottom_top")

    self.list_item:addChild(btnGroup)
    
    for i = 1, length do
        --local item = SettingManager.helpList:objectAt(i);

        local groupBtn = TFGroupButton:create()
        groupBtn:setNormalTexture(normalTexture[i])
        groupBtn:setPressedTexture(pressedTexture[i])
        if (i == 1) then
            groupBtn:setSelect(true)
        end

        --groupBtn:setScale9Enabled(false)
        --groupBtn:setSize(CCSizeMake(self.list_item:getSize().width,ActivitiesTipsLayer.LIST_ITEM_HEIGHT))


        --local label_num = TFLabel:create()
        --label_num:setText(item.name)
        --label_num:setPosition(ccp(0,0))
        --label_num:setFontSize(25);
        --groupBtn:addChild(label_num)
        --groupBtn.label_num = label_num

        local rope = TFImage:create()
        rope:setTexture("ui_new/setting/xt_l.png")
        rope:setPosition(ccp(0,-40))
        groupBtn:addChild(rope)

        local markType = markImage[i]
        if markType and markType~= nil then
            local path = markImage[i]
            local newMarkImage = TFImage:create()
            newMarkImage:setTexture(path)
            newMarkImage:setPosition(ccp(-50,0))
            groupBtn:addChild(newMarkImage)
        end

        btnGroup:addChild(groupBtn)
    end

    btnGroup:doLayout()
    
    local listSize = CCSizeMake(self.list_item:getSize().width, length * (ActivitiesTipsLayer.LIST_ITEM_HEIGHT) + 20);

    self.list_item:setInnerContainerSize(listSize);
    self.list_item:setInnerContainerSizeForHeight(listSize.height);
end


function ActivitiesTipsLayer:selectItem(index)
   -- local item = SettingManager.helpList:objectAt(index);
   -- self.txt_content:setText(item.content);

   local item = SettingManager.activitie:objectAt(index);
   self.txt_content:setText(item.content);
   -- self.txt_content:setText("sdfsdf \nsdfsd")
   -- self.txt_content:setText("侠客:\n游戏中侠")
end

function ActivitiesTipsLayer:removeUI()
   self.list_item:cancelScrollArrow();
   self.super.removeUI(self);
end

--注册事件
function ActivitiesTipsLayer:registerEvents()
   self.super.registerEvents(self);

   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   self.btn_close:setClickAreaLength(100);

end

function ActivitiesTipsLayer:removeEvents()

end
return ActivitiesTipsLayer;
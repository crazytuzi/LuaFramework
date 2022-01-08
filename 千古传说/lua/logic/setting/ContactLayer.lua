--[[
******联系我们界面*******

    -- by david.dai
    -- 2014/7/4
]]
local ContactLayer = class("ContactLayer", BaseLayer);

CREATE_SCENE_FUN(ContactLayer);
CREATE_PANEL_FUN(ContactLayer);

ContactLayer.LIST_ITEM_HEIGHT = 90; 

function ContactLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.setting.ContactLayer");
end

function ContactLayer:initUI(ui)
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

function ContactLayer:onShow()
    self.super.onShow(self)
    self.super.onShow(self)
    self:refreshBaseUI();
end

function ContactLayer:refreshBaseUI()

end

local normalTexture={
    -- "ui_new/setting/xt_wangzhan1.png",      --官方网站
    -- "ui_new/setting/xt_luntan1.png",        --官方论坛
    -- "ui_new/setting/xt_kefu1.png",          --客服
    "ui_new/setting/xt_wanjia1.png",        --玩家交流
}

local pressedTexture={
--     "ui_new/setting/xt_wangzhan.png",       --官方网站
--     "ui_new/setting/xt_luntan.png",         --官方论坛
--     "ui_new/setting/xt_kefu.png",           --客服
    "ui_new/setting/xt_wanjia.png",         --玩家交流
}

local markImage={
    nil, 
    nil,
    nil, 
    nil,
}
local initBtnIndex = 4

function ContactLayer:loadItemList()
    --清除、重置列表
    self.list_item:getInnerContainer():stopAllActions();
    self.list_item:removeAllChildren();

    local function onSelectClickHandle(sender)
        self:selectItem(sender:getSelectIndex()+initBtnIndex)
    end

    --local length = SettingManager.helpList:length();
    local length = #normalTexture

    local btnGroup = TFButtonGroup:create()
    btnGroup:setZOrder(10)
    btnGroup:setPosition(ccp(0,10))
    btnGroup:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    btnGroup:setSize(CCSizeMake(self.list_item:getSize().width,length * (ContactLayer.LIST_ITEM_HEIGHT)))
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
        --groupBtn:setSize(CCSizeMake(self.list_item:getSize().width,ContactLayer.LIST_ITEM_HEIGHT))


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

    local listSize = CCSizeMake(self.list_item:getSize().width, length * (ContactLayer.LIST_ITEM_HEIGHT) + 20);

    self.list_item:setInnerContainerSize(listSize);
    self.list_item:setInnerContainerSizeForHeight(listSize.height);
end


function ContactLayer:selectItem(index)
   local item = SettingManager.contact:objectAt(index);
   self.txt_content:setText(item.content);
end

function ContactLayer:removeUI()
   self.list_item:cancelScrollArrow();
   self.super.removeUI(self);
end

--注册事件
function ContactLayer:registerEvents()
   self.super.registerEvents(self);

   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   self.btn_close:setClickAreaLength(100);

end

function ContactLayer:removeEvents()

end
return ContactLayer;
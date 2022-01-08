--[[
******帮助列表*******

    -- by haidong.gan
    -- 2013/11/27
]]
local HelpLayer = class("HelpLayer", BaseLayer);

CREATE_SCENE_FUN(HelpLayer);
CREATE_PANEL_FUN(HelpLayer);

HelpLayer.LIST_ITEM_HEIGHT = 90; 

function HelpLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.setting.HelpLayer");
end

function HelpLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.list_item   = TFDirector:getChildByPath(ui, 'list_item');
    self.list_item:setBounceEnabled(true);


    self.bg_helpList   = TFDirector:getChildByPath(ui, 'bg_helpList');

    Public:bindScrollFun(self.list_item);
    self.list_item:bindScrollArrow(ui);


    self.list_help   = TFDirector:getChildByPath(ui, 'list_help');
    self.list_help:setBounceEnabled(true);

    Public:bindScrollFun(self.list_help);


    self.btn_close        = TFDirector:getChildByPath(ui, 'btn_close');

    local onUpdated = function(event)
          self:loadItemList();
    end;

    TFDirector:addTimer(0.1, 1, nil, onUpdated); 
end

function HelpLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function HelpLayer:refreshBaseUI()

end

local normalTexture={
    "ui_new/setting/xt_buzhen1.png",        --布阵
    "ui_new/setting/xt_zhuangbei1.png",     --装备
    "ui_new/setting/xt_beibao1.png",        --背包
    "ui_new/setting/xt_chengjiu1.png",      --成就
}

local pressedTexture={
    "ui_new/setting/xt_buzhen.png",         --布阵
    "ui_new/setting/xt_zhuangbei.png",      --装备
    "ui_new/setting/xt_beibao.png",         --背包
    "ui_new/setting/xt_chengjiu.png",       --成就
}

function HelpLayer:loadItemList()
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
    btnGroup:setSize(CCSizeMake(self.list_item:getSize().width,length * (HelpLayer.LIST_ITEM_HEIGHT)))
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
        --groupBtn:setSize(CCSizeMake(self.list_item:getSize().width,HelpLayer.LIST_ITEM_HEIGHT))


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
        btnGroup:addChild(groupBtn)
    end

    btnGroup:doLayout()
    local listSize = CCSizeMake(self.list_item:getSize().width, length * (HelpLayer.LIST_ITEM_HEIGHT) + 20);

    self.list_item:setInnerContainerSize(listSize);
    self.list_item:setInnerContainerSizeForHeight(listSize.height);
end


function HelpLayer:selectItem(index)
    local item = SettingManager.helpList:objectAt(index);
    -- local content = item.content;

    -- 替换\n
    local content = "";
    local contentList = string.split(item.content, "\n")
    for i=1,#contentList do
        content = content .. "<br>" .. contentList[i] .. "</br>"
    end
    content = [[<p style="text-align:left margin:5px"> <font color="#000000" fontSize = "26">]] .. content .. [[</font></p>]];

    local richText = TFRichText:create(CCSizeMake(400,100))
    richText:setPosition(ccp(15,0))
    richText:setAnchorPoint(ccp(0, 0))
    self.list_help:removeAllChildren();
    self.list_help:addChild(richText)

    self.txt_content      = richText;
    self.txt_content:setText("");
    self.txt_content:appendText(content);
    self.list_help:setInnerContainerSizeForHeight(self.txt_content:getSize().height)
    self.list_help:scrollToYTop(0)
end

function HelpLayer:removeUI()
   self.list_item:cancelScrollArrow();
   self.super.removeUI(self);
end

--注册事件
function HelpLayer:registerEvents()
   self.super.registerEvents(self);

   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   self.btn_close:setClickAreaLength(100);

end

function HelpLayer:removeEvents()

end
return HelpLayer;
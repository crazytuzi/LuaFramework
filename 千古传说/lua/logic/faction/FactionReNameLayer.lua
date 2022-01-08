--[[
****** 帮派改名更面 *******

    -- by qunhuan
    -- 2016/1/9
]]
local FactionReNameLayer = class("FactionReNameLayer", BaseLayer);

CREATE_SCENE_FUN(FactionReNameLayer);
CREATE_PANEL_FUN(FactionReNameLayer);

function FactionReNameLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.main.ReNameLayer");
end

function FactionReNameLayer:initUI(ui)
    self.super.initUI(self,ui);


    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_random     = TFDirector:getChildByPath(ui, 'btn_random');

    self.btn_ok         = TFDirector:getChildByPath(ui, 'btn_ok');

    self.input_name      = TFDirector:getChildByPath(ui, 'playernameInput');
    self.img_input_bg    = TFDirector:getChildByPath(ui, 'bg_input');
    self.txt_cost       = TFDirector:getChildByPath(ui, 'txt_cost');

    self.content       = TFDirector:getChildByPath(ui, 'content');

    self.btn_random:setVisible(false)

    self.input_name:setMaxLength(10)

    print("---------- = ", ConstantData:getValue("guild.ReName.prop"))
    local item = BagManager:getItemById(ConstantData:getValue("guild.ReName.prop"));
    if item then
        local renameToolName = item.name
        --self.txt_cost:setText("改名需花费1张".. renameToolName .."（剩余：".. item.num .."）");
        self.txt_cost:setText(stringUtils.format(localizable.factionRename_rename,renameToolName,item.num));

        self.txt_cost.need = -1;
    else
        --self.txt_cost:setText("更名需花费".. ConstantData:getValue("guild.Sycee.Rename") .."元宝");
        self.txt_cost:setText(stringUtils.format(localizable.factionRename_rename_gold,ConstantData:getValue("guild.Sycee.Rename")));
        self.txt_cost.need = ConstantData:getValue("guild.Sycee.Rename");
    end
    
    self.input_pos_mark = self.content:getPosition()


    self.img_input_bg:setPositionX(480)
end

function FactionReNameLayer:removeUI()
    self.super.removeUI(self);
end


function FactionReNameLayer.btnOkClickHandle(sender)
    local self = sender.logic;
    local nameStr = self.input_name:getText()

    if nameStr == nil or nameStr == "" then
        --toastMessage("请输入帮派名");
        toastMessage(localizable.factionRename_input);
        
        return;
    end

    if self.txt_cost.need > 0 then
        if MainPlayer:isEnoughSycee( self.txt_cost.need , true) then
            FactionManager:RequestModifyFationName(nameStr);
        end
    else
        FactionManager:RequestModifyFationName(nameStr);
    end
end

function FactionReNameLayer:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_close:setClickAreaLength(100);
    
    self.btn_ok.logic = self
    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnOkClickHandle),1)


    local function onTextFieldChangedHandle(input)
        self.content:setPosition(ccp(self.input_pos_mark.x,self.input_pos_mark.y+100))
    end

    --add by david.dai
    --添加输入账号时输入框上移逻辑
    local function onTextFieldAttachHandle(input)
        self.content:setPosition(ccp(self.input_pos_mark.x,self.input_pos_mark.y+100))
        self.input_name:addMEListener(TFTEXTFIELD_TEXTCHANGE, onTextFieldChangedHandle)
    end
    self.input_name:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle)

    local function onTextFieldDetachHandle(input)
        self.content:setPosition(ccp(self.input_pos_mark.x,self.input_pos_mark.y))
        self.input_name:removeMEListener(TFTEXTFIELD_TEXTCHANGE)
    end

    self.input_name:addMEListener(TFTEXTFIELD_DETACH, onTextFieldDetachHandle)
end

function FactionReNameLayer:removeEvents()
  	self.super.removeEvents(self);
end

return FactionReNameLayer;

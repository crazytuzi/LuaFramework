--[[
****** 团队更面 *******

    -- by haidong.gan
    -- 2014/6/14
]]
local ReNameLayer = class("ReNameLayer", BaseLayer);

CREATE_SCENE_FUN(ReNameLayer);
CREATE_PANEL_FUN(ReNameLayer);

function ReNameLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.main.ReNameLayer");
end

function ReNameLayer:initUI(ui)
    self.super.initUI(self,ui);

            -- 名字配置
    self.nameList = require("lua.table.t_s_name")
    self.familyNameNum  = 0
    self.ManNameNum     = 0
    self.WomanNameNum   = 0

    -- 统计姓 名的个数
    for v in self.nameList:iterator() do
        if v.familyname ~= "" then
            self.familyNameNum = self.familyNameNum + 1
        end

        if v.manname ~= "" then
            self.ManNameNum = self.ManNameNum + 1
        end

        if v.womanname ~= "" then
            self.WomanNameNum = self.WomanNameNum + 1
        end
    end

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_random     = TFDirector:getChildByPath(ui, 'btn_random');

    self.btn_ok         = TFDirector:getChildByPath(ui, 'btn_ok');

    self.input_name      = TFDirector:getChildByPath(ui, 'playernameInput');
    self.img_input_bg    = TFDirector:getChildByPath(ui, 'bg_input');
    self.txt_cost       = TFDirector:getChildByPath(ui, 'txt_cost');

    self.content       = TFDirector:getChildByPath(ui, 'content');


    self.input_name:setMaxLength(10)
    -- local textField = TFDirector:getChildByPath(ui, 'playernameInput');
    -- textField:setMaxLengthEnabled(true);
    -- textField:setMaxLength(10)
    -- textField:setPlaceHolder("请输入团队名")
    -- textField:setFontSize(24)
    -- textField:setCursorEnabled(true)
    -- textField:setCursorColor(ccc3(0xFF, 0, 0))
    -- textField:setTouchEnabled(true);
    -- -- textField:setPosition(self.bg_input:getPosition())
    -- textField:setText(MainPlayer:getPlayerName())

    -- -- ui:addChild(textField,2)

    -- self.input_name = textField;
    print("---------- = ", ConstantData:getValue("Player.ReName.prop"))
    local item = BagManager:getItemById(ConstantData:getValue("Player.ReName.prop"));
    if item then
        local renameToolName = item.name
        --self.txt_cost:setText("改名需花费1张".. renameToolName .."（剩余：".. item.num .."）");
        self.txt_cost:setText(stringUtils.format(localizable.factionRename_rename,renameToolName,item.num))
        self.txt_cost.need = -1;
    else
        --self.txt_cost:setText("更名需花费".. ConstantData:getValue("Player.Sycee.Rename") .."元宝");
        self.txt_cost:setText(stringUtils.format(localizable.factionRename_rename_gold,ConstantData:getValue("Player.Sycee.Rename")))
        self.txt_cost.need = ConstantData:getValue("Player.Sycee.Rename");
    end
    
    self.input_pos_mark = self.content:getPosition()
end

function ReNameLayer:removeUI()
    self.super.removeUI(self);
end

function ReNameLayer.btnRandomClickHandle(sender)
    local self = sender.logic;
    -- toastMessage("未实现");
    local playerID      = MainPlayer:getProfession()
    local f1            = math.random(1, self.familyNameNum)
    local familyname    = self.nameList:getObjectAt(f1).familyname
    local name          = ""
    local isMan         = false
    if playerID == 77 or playerID == 78 then
        isMan = true
    end
    -- 男
    if isMan then
        local f2 = math.random(1, self.ManNameNum)
        name = self.nameList:getObjectAt(f2).manname

    -- 女
    else
        local f2 = math.random(1, self.WomanNameNum)
        name = self.nameList:getObjectAt(f2).womanname
    end

    -- print("familyname = %s,len = %d", familyname, string.len(familyname))
    -- print("name = %s", name)
    self.input_name:setText(familyname..name)

end

function ReNameLayer.btnOkClickHandle(sender)
    local self = sender.logic;
    local nameStr = self.input_name:getText()

    if nameStr == nil or nameStr == "" then
        --toastMessage("请输入团队名");
        toastMessage(localizable.ReNameLayer_input)
        return;
    end

    if self.txt_cost.need > 0 then
        if MainPlayer:isEnoughSycee( self.txt_cost.need , true) then
            CommonManager:reName(nameStr);
        end
    else
        CommonManager:reName(nameStr);
    end
end

function ReNameLayer:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_close:setClickAreaLength(100);
    
    self.btn_ok.logic = self
    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnOkClickHandle),1)

    self.btn_random.logic = self
    self.btn_random:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnRandomClickHandle),1)



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

function ReNameLayer:removeEvents()
  	self.super.removeEvents(self);
end

return ReNameLayer;

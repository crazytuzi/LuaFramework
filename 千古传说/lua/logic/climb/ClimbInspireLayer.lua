--[[
/*code is far away from bug with the animal protecting
    *  ┏┓　　　┏┓
    *┏┛┻━━━┛┻┓
    *┃　　　　　　　┃ 　
    *┃　　　━　　　┃
    *┃　┳┛　┗┳　┃
    *┃　　　　　　　┃
    *┃　　　┻　　　┃
    *┃　　　　　　　┃
    *┗━┓　　　┏━┛
    *　　┃　　　┃神兽保佑
    *　　┃　　　┃代码无BUG！
    *　　┃　　　┗━━━┓
    *　　┃　　　　　　　┣┓
    *　　┃　　　　　　　┏┛
    *　　┗┓┓┏━┳┓┏┛
    *　　　┃┫┫　┃┫┫
    *　　　┗┻┛　┗┻┛ 
    *　　　
    */
]]
local ClimbInspireLayer = class("ClimbInspireLayer", BaseLayer);

CREATE_SCENE_FUN(ClimbInspireLayer);
CREATE_PANEL_FUN(ClimbInspireLayer);


function ClimbInspireLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.climb.ClimbInspire");
end


function ClimbInspireLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close         = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_close:setVisible(false)
    self.btn_guwu = {}
    self.btn_gouxuan = {}
    for i=1,3 do
        self.btn_guwu[i]         = TFDirector:getChildByPath(ui, 'btn_guwu'..i);
        self.btn_gouxuan[i]         = TFDirector:getChildByPath(self.btn_guwu[i], 'btn_gouxuan');
    end
    self.btn_next         = TFDirector:getChildByPath(ui, 'btn_next');
    self.attr_scroll         = TFDirector:getChildByPath(ui, 'attr_scroll');
end

function ClimbInspireLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()
end

function ClimbInspireLayer:refreshBaseUI()

end

function ClimbInspireLayer:refreshUI()
    local northCaveAttributeInfo = NorthClimbManager:getNorthCaveAttributeInfoByFloor()
    if northCaveAttributeInfo == nil then
        print("取得鼓舞信息失败")
        return
    end
    self.northCaveAttributeInfo = northCaveAttributeInfo
    for i=1,3 do
        self:initChoiceAttributeInfo(i)
    end

    self:showAttributeInfo()
end

function ClimbInspireLayer:showAttributeInfo()
    self.attr_scroll:removeAllChildrenWithCleanup(true);
    local attribute_list , length = NorthClimbManager:getAttributeInfo()

    local temp = 0
    local interval = 30
    local size = self.attr_scroll:getContentSize()
    local height = math.max(math.ceil(length/3)*interval ,  size.height)
    for k,v in pairs(attribute_list) do
        local label = TFLabel:create()
        label:setAnchorPoint(ccp(0, 1))
        local pos_x = math.mod(temp,3)*202
        local pos_y = height - math.floor(temp/3)*interval
        label:setPosition(ccp(pos_x, pos_y))
        --label:setText("全体"..AttributeTypeStr[k] .."+"..v.."%")
        --label:setText(localizable.common_all_body..AttributeTypeStr[k] .."+"..v.."%")
        --这个百分号 可能有问题
        label:setText(stringUtils.format(localizable.common_all_body,AttributeTypeStr[k],v))
        label:setFontSize(20)
        label:setColor(ccc3(0,0,0))
        self.attr_scroll:addChild(label)
        temp = temp + 1
    end
    self.attr_scroll:setInnerContainerSize(CCSizeMake(size.width, height))
end

function ClimbInspireLayer:initChoiceAttributeInfo( index )
    local option = self.northCaveAttributeInfo.option[index]
    local exterAttr = NorthCaveExterAttrData:objectByID(option)
    if exterAttr == nil then
        print("鼓舞属性信息 == null ， id ==",option)
        return
    end
    local img_attr = TFDirector:getChildByPath(self.btn_guwu[index] , 'img_shenfa');
    img_attr:setTexture("ui_new/climb/img_".. exterAttr.attribute_key..".png");
    
    local txt_num = TFDirector:getChildByPath(self.btn_guwu[index] , 'txt_num');
    txt_num:setText("+"..math.floor(exterAttr.attribute_value/100).."%")

    local txt_cost = TFDirector:getChildByPath(self.btn_guwu[index] , 'txt_num2');
    txt_cost:setText(exterAttr.consume)
end


function ClimbInspireLayer:choiceInspire(index)
    for i=1,3 do
       if i == index then
            self.btn_gouxuan[i]:setSelectedState(true)
            self.btn_guwu[i]:setTextureNormal("ui_new/climb/btn_guwu_press.png")
            local txt_cost = TFDirector:getChildByPath(self.btn_guwu[i] , 'txt_num2');
            txt_cost:setColor(ccc3(255,255,255))
        else
            self.btn_gouxuan[i]:setSelectedState(false)
            self.btn_guwu[i]:setTextureNormal("ui_new/climb/btn_guwu.png")
            local txt_cost = TFDirector:getChildByPath(self.btn_guwu[i] , 'txt_num2');
            txt_cost:setColor(ccc3(0,0,0))
        end
    end
end



function ClimbInspireLayer.onGoClickHandle(sender)
   local self = sender.logic;
end

function ClimbInspireLayer:removeUI()
    self.super.removeUI(self);

end


function ClimbInspireLayer.onClickInspire(sender)
    local self = sender.logic;
    local index = sender.tag
    local state = sender:getSelectedState();
    if state == true then
        self:choiceInspire(index)
    else
        sender:setSelectedState(false)
        self.btn_guwu[index]:setTextureNormal("ui_new/climb/btn_guwu.png")
        local txt_cost = TFDirector:getChildByPath(self.btn_guwu[index] , 'txt_num2');
        txt_cost:setColor(ccc3(0,0,0))
    end
end


function ClimbInspireLayer.onBtnClickInspire(sender)
    local self = sender.logic;
    local index = sender.tag
    local state = self.btn_gouxuan[index]:getSelectedState();

    if state == true then
        self.btn_gouxuan[index]:setSelectedState(false)
        self.btn_guwu[index]:setTextureNormal("ui_new/climb/btn_guwu.png")
        local txt_cost = TFDirector:getChildByPath(self.btn_guwu[index] , 'txt_num2');
        txt_cost:setColor(ccc3(0,0,0))
    else
        self:choiceInspire(index)
    end
end

function ClimbInspireLayer.onBtnClickNext(sender)
    local self = sender.logic
    self:sendChice()
end

function ClimbInspireLayer:sendChice()
    for i=1,3 do
        if self.btn_gouxuan[i]:getSelectedState() == true then
            NorthClimbManager:RequestChoiceCaveAttribute( self.northCaveAttributeInfo.option[i] )
            return
        end
    end
    NorthClimbManager:RequestChoiceCaveAttribute(0)
end

function ClimbInspireLayer:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)

    for i=1,3 do
        self.btn_gouxuan[i].logic    = self;
        self.btn_gouxuan[i].tag = i
        self.btn_gouxuan[i]:addMEListener(TFWIDGET_TOUCHENDED,  audioClickfun(self.onClickInspire,play_lingdaolitisheng),1);

        self.btn_guwu[i].logic    = self;
        self.btn_guwu[i].tag = i
        self.btn_guwu[i]:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBtnClickInspire,play_lingdaolitisheng),1);
    end
    self.btn_next.logic    = self;
    self.btn_next:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBtnClickNext),1);
end

function ClimbInspireLayer:removeEvents()
    self.super.removeEvents(self);
end

return ClimbInspireLayer;

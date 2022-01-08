
local IllustrationSkyBookDetailLayer = class("IllustrationSkyBookDetailLayer", BaseLayer)
local CardSkyBook = require('lua.gamedata.base.CardSkyBook')
local GameAttributeData = require('lua.gamedata.base.GameAttributeData')
function IllustrationSkyBookDetailLayer:ctor(bookId)
    self.super.ctor(self)
    self.bookId = bookId
    self:init("lua.uiconfig_mango_new.handbook.HandSkybookDetail")
    
    self:removeUnuseTexEnabled(true);
end

function IllustrationSkyBookDetailLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn           = TFDirector:getChildByPath(ui, 'btn_close')
    self.txt_title          = TFDirector:getChildByPath(ui, 'txt_name')
    self.img_touxiang       = TFDirector:getChildByPath(ui, 'img_touxiang')

    self.txt_des            = TFDirector:getChildByPath(ui, 'txt_des')
    self.img_pinzhiditu     = TFDirector:getChildByPath(ui, 'img_pinzhiditu')
    self.btn_huodetujin     = TFDirector:getChildByPath(ui, 'btn_huodetujin')
    
    -- 基础武力
    self.txt_basePower           = TFDirector:getChildByPath(ui, 'txt_basepowerdes')
    self.txt_basePowerNum        = TFDirector:getChildByPath(self.txt_basePower, 'txt_num')
    -- 成长武力
    self.txt_growPower           = TFDirector:getChildByPath(ui, 'txt_grow')
    self.txt_growPowerNum        = TFDirector:getChildByPath(self.txt_growPower, 'txt_num')
   
    -- 
    -- txt_quality4 txt_quality4
    self.attr_list_panel        = {}
    for i=1,5 do
        self.attr_list_panel[i]     = {}
        self.attr_list_panel[i].txt = TFDirector:getChildByPath(ui, 'txt_attr_'..i)
        self.attr_list_panel[i].num = TFDirector:getChildByPath(self.attr_list_panel[i].txt, 'txt_num')
    end


    self.btn_huodetujin.logic = self

    self:draw()

    --图鉴控制
    local skyBook  = ItemData:objectByID(self.bookId)
    self.output = skyBook.show_way

    self.btn_huodetujin:setVisible(false)
    if self.output and string.len(self.output) > 0 then
        self.btn_huodetujin:setVisible(true)
    end


end

function IllustrationSkyBookDetailLayer:registerEvents(ui)
    self.super.registerEvents(self)
    self.btn_huodetujin:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onclikOutPut),1)

    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn)
end

function IllustrationSkyBookDetailLayer:removeEvents()
    self.super.removeEvents(self)

end

function IllustrationSkyBookDetailLayer.onclikOutPut(sender)
    local self = sender.logic

    
    IllustrationManager:showOutputList({output = self.output, id = 2})
end

function IllustrationSkyBookDetailLayer:draw()
    local skyBook  = ItemData:objectByID(self.bookId)
    if skyBook == nil then
        return
    end
    self.txt_title:setText(skyBook.name)
    self.txt_des:setText(skyBook.details)
    self.img_touxiang:setTexture(skyBook:GetPath())
    local qualityIcon   = GetColorIconByQuality(skyBook.quality)
    self.img_pinzhiditu:setTexture(qualityIcon)

     -- 属性描述
    local skyBook = CardSkyBook:new(self.bookId)
    if skyBook == nil  then
        print("skyBook not found .",self.bookId)
        return
    end

    self.txt_basePower:setText(localizable.Tianshu_Main_Attr)
    self.txt_basePowerNum:setText(AttributeTypeStr[skyBook.config.kind])

    self.txt_growPower:setText(localizable.Tianshu_Attr_Grow)
    self.txt_growPowerNum:setText(skyBook.breachConfig.factor)

    local baseAttr = skyBook.totalAttribute.attribute
    local index = 1
    for i=1,(EnumAttributeType.Max-1) do
        if baseAttr[i] and baseAttr[i] ~= 0 and index <= 5 then
            self.attr_list_panel[i].txt:setText(AttributeTypeStr[i])
            self.attr_list_panel[i].num:setText("+ " .. covertToDisplayValue(i,baseAttr[i]))
            self.attr_list_panel[i].txt:setVisible(true)
            index = index + 1
        end
    end
    for i=index,5 do
        self.attr_list_panel[i].txt:setVisible(false)
    end
end


return IllustrationSkyBookDetailLayer
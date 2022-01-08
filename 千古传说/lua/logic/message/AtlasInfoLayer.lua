--[[
******图谱信息层*******

    -- by Stephen.tao
    -- 2014/2/27
]]

local AtlasInfoLayer = class("AtlasInfoLayer", BaseLayer)

--CREATE_SCENE_FUN(AtlasInfoLayer)
CREATE_PANEL_FUN(AtlasInfoLayer)


function AtlasInfoLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.message.AtlasInfoLayer")
end


function AtlasInfoLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_open         = TFDirector:getChildByPath(ui, 'btn_open')
    self.txt_name         = TFDirector:getChildByPath(ui, 'txt_name')
    self.img_quality      = TFDirector:getChildByPath(ui, 'img_quality')
    self.img_icon         = TFDirector:getChildByPath(ui, 'img_icon')
    self.txt_level        = TFDirector:getChildByPath(ui, 'txt_level')

    self.bg_attr        = {}
    self.txt_attr       = {}
    self.txt_attrMin    = {}
    self.img_attrTo     = {}
    self.txt_attrMax    = {}

    for i=1,3 do
        local str = "bg_attr_"..i
        self.bg_attr[i]         = TFDirector:getChildByPath(ui, str)
        str = "txt_attr_"..i
        self.txt_attr[i]        = TFDirector:getChildByPath(ui, str)
        str = "txt_attrMin_"..i
        self.txt_attrMin[i]     = TFDirector:getChildByPath(ui, str)
        str = "img_attrTo_"..i
        self.img_attrTo[i]      = TFDirector:getChildByPath(ui, str)
        str = "txt_attrMax_"..i
        self.txt_attrMax[i]     = TFDirector:getChildByPath(ui, str)
    end

    self.btn_open.logic   = self
end

function AtlasInfoLayer:removeUI()
	self.super.removeUI(self)
    self.itemId = nil
    self.btn_open         = nil
    self.txt_name         = nil
    self.img_quality      = nil
    self.img_icon         = nil
    self.txt_level        = nil
    self.bg_attr          = nil
    self.txt_attr         = nil
    self.txt_attrMin      = nil
    self.img_attrTo       = nil
    self.txt_attrMax      = nil

end


function AtlasInfoLayer:setItemid( itemid )
    self.itemId = itemid
    local baseItem = ItemData:objectByID(self.itemId)

    self.img_icon:setTexture(baseItem:GetPath())
    self.img_quality:setTexture(GetColorIconByQuality(baseItem.quality))

    self.txt_name:setText(baseItem.name)
    -- self.txt_name:setColor(GetColorByQuality(baseItem.quality))

    local forging =  EquipmentBuildManager.forgingList:objectByID(itemid)
    if forging == nil then return end
    self.txt_level:setText(forging.level)

    local equipmentTemplate = EquipmentTemplateData:objectByID(forging.product_id)
    if equipmentTemplate == nil then return end
    local min_attribute , max_attribute = equipmentTemplate:getAttribute()
    local index = 1
    for i=1,(EnumAttributeType.Max-1) do
        if min_attribute[i] then
            self.bg_attr[index]:setVisible(true)
            self.txt_attr[index]:setText(AttributeTypeStr[i])
            self.txt_attrMin[index]:setText(min_attribute[i])
            self.img_attrTo[index]:setPosition(ccp((self.txt_attrMin[index]:getPosition().x + self.txt_attrMin[index]:getSize().width),self.img_attrTo[index]:getPosition().y))
            self.txt_attrMax[index]:setPosition(ccp((self.img_attrTo[index]:getPosition().x + self.img_attrTo[index]:getSize().width),self.txt_attrMax[index]:getPosition().y))
            self.txt_attrMax[index]:setText(max_attribute[i])
            index = index + 1
        end
    end
    while index <= 3 do
        self.bg_attr[index]:setVisible(false)
        index = index + 1
    end
end

function AtlasInfoLayer.onOpenBtnClickHandle(sender)
    local forging =  EquipmentBuildManager.forgingList:objectByID(itemid)
    if forging == nil then
        return
    end
    local data = {}
    data.level = forging.level
    data.type = forging.product_type
    local layer = require("lua.logic.equipmentbuild.BuildHomeLayer"):new(data)
    AlertManager:close()
    AlertManager:close()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()

end


function AtlasInfoLayer:registerEvents()
    self.super.registerEvents(self)
    self.btn_open:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOpenBtnClickHandle),1)
end


return AtlasInfoLayer

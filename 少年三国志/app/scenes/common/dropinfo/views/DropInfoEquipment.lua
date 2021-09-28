
local DropInfoBaseView = require("app.scenes.common.dropinfo.DropInfoBaseView")


local DropInfoEquipment = class("DropInfoTreasure", DropInfoBaseView)
local MergeEquipment = require("app.data.MergeEquipment")

local EquipmentInfo = require("app.scenes.equipment.EquipmentInfo")

function DropInfoEquipment.create(...)
    return DropInfoEquipment.new("ui_layout/dropinfo_DropInfoEquipment.json", ...)
end

function DropInfoEquipment:_addEvents()
    self:registerBtnClickEvent("Button_close", function()
        self:_close()
    end)


end

function DropInfoEquipment:setData(type, value, isSubview)
    self._type = type
    self._value = value

    self:_addEvents()

 

    local goods_info = G_Goods.convert(type,value)

    local info = goods_info.info
    --名字
    self:getLabelByName("Label_name"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_name"):setText(info.name)

    --描述
    -- self:getLabelByName("Label_desc_title"):setText(G_lang:get("LANG_DROP_TREASURE_DESC"))
    self:getLabelByName("Label_desc_title"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_desc"):setText(info.directions)
    self:getLabelByName("Label_title"):setText(G_lang:get("LANG_DROP_EQUIPMENT_SHUXING"))

    
    --强化属性
    local attrs = {}
    if info.strength_type ~= 0 then
        table.insert(attrs, MergeEquipment.convertAttrTypeAndValueObject(info.strength_type, info.strength_value))
        EquipmentInfo.setAttrLabels(self, attrs,{"Label_attr1_title", "Label_attr1_value"})
    end  
    


    --每集属性加成
    local attrsAdd = {}
    if info.strength_type ~= 0 then
        table.insert(attrsAdd, MergeEquipment.convertAttrTypeAndValueObject(info.strength_type, info.strength_growth))
        EquipmentInfo.setAttrLabels(self, attrsAdd,{"Label_add_attr1_title", "Label_add_attr1_value"})
    end  




    -- 每集属性加成标题
    self:getLabelByName("Label_level_desc"):setText(G_lang:get("LANG_DROP_PER_ADD"))

    --图片
    self:getImageViewByName("ImageView_icon"):loadTexture( G_Path.getEquipmentPic(info.res_id) )

    --颜色图片
    self:getImageViewByName("ImageView_color"):loadTexture(G_Path.getEquipmentColorImage(info.quality))

    
    --类型文字图片    
    self:getImageViewByName("ImageView_type"):loadTexture(G_Path.getEquipmentTypeImage(info.type) )


    --套装

    EquipmentInfo.setSuitPanel(self, info)
    
end


return DropInfoEquipment

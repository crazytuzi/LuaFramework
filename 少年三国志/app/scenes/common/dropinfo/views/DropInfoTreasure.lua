
local DropInfoBaseView = require("app.scenes.common.dropinfo.DropInfoBaseView")


local DropInfoTreasure = class("DropInfoTreasure", DropInfoBaseView)
local MergeEquipment = require("app.data.MergeEquipment")

local TreasureInfo = require("app.scenes.treasure.TreasureInfo")


function DropInfoTreasure.create(...)
    return DropInfoTreasure.new("ui_layout/dropinfo_DropInfoTreasure.json", ...)
end

function DropInfoTreasure:_addEvents()
    self:registerBtnClickEvent("Button_close", function()
        self:_close()
    end)


end

function DropInfoTreasure:setData(type, value, isSubview)
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
    self:getLabelByName("Label_desc_title"):setText(G_lang:get("LANG_DROP_TREASURE_DESC"))
    self:getLabelByName("Label_desc"):setText(info.directions)


    self:getLabelByName("Label_title"):setText(G_lang:get("LANG_DROP_TREASURE_SHUXING"))


    --强化属性
    local attrs = {}
    if info.strength_type_1 ~= 0 then
        table.insert(attrs, MergeEquipment.convertAttrTypeAndValueObject(info.strength_type_1, info.strength_value_1))
    end
    if info.strength_type_2 ~= 0 then
        table.insert(attrs, MergeEquipment.convertAttrTypeAndValueObject(info.strength_type_2, info.strength_value_2))
    end

    TreasureInfo.setAttrLabels(self, attrs,{"Label_attr1_title", "Label_attr1_value", "Label_attr2_title", "Label_attr2_value"})

    --经验
    self:getLabelByName("Label_exp_desc"):setText(G_lang:get("LANG_DROP_EXP", {exp=info.supply_exp}))

    --图片
    self:getImageViewByName("ImageView_icon"):loadTexture( G_Path.getTreasurePic(info.res_id) )

    --颜色图片
    self:getImageViewByName("ImageView_color"):loadTexture(G_Path.getEquipmentColorImage(info.quality))

   
    --类型文字图片    
    self:getImageViewByName("ImageView_type"):loadTexture(G_Path.getTreasureTypeImage(info.type) )
    
    
end



return DropInfoTreasure

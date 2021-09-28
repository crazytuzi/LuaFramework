
local DropInfoBaseView = require("app.scenes.common.dropinfo.DropInfoBaseView")


local DropInfoItem = class("DropInfoItem", DropInfoBaseView)


local Colors = require("app.setting.Colors")


function DropInfoItem.create(...)
    return DropInfoItem.new("ui_layout/dropinfo_DropInfoItem.json", ...)
end



function DropInfoItem:setData(type, value, isSubview)
    self:_addEvents()
  

    local goods_info = G_Goods.convert(type,value)

    local info = goods_info.info

    self:getLabelByName("Label_name"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_name"):setText(info.name)
    self:getLabelByName("Label_desc"):setText(info.directions)
    
    local hasNum = G_Me.bagData:getPropCount(value)
    self:getLabelByName("Label_has"):setText(G_lang:get("LANG_DROP_NUM",{num=hasNum}))

    self:getImageViewByName("ImageView_icon"):loadTexture(goods_info.icon,UI_TEX_TYPE_LOCAL)
    self:getImageViewByName("ImageView_border"):loadTexture(G_Path.getEquipColorImage(goods_info.quality,goods_info.type))
    self:getImageViewByName("ImageView_icon_bg"):loadTexture(G_Path.getEquipIconBack(goods_info.quality))

end

function DropInfoItem:_addEvents()
    self:registerBtnClickEvent("Button_close", function()
        self:_close()
    end)


end


return DropInfoItem


local DropInfoBaseView = require("app.scenes.common.dropinfo.DropInfoBaseView")


local DropInfoOther = class("DropInfoOther", DropInfoBaseView)


local Colors = require("app.setting.Colors")


function DropInfoOther.create(...)
    return DropInfoOther.new("ui_layout/dropinfo_DropInfoOther.json", ...)
end



function DropInfoOther:setData(type, value, isSubview)
    self:_addEvents()
  
    local goods_info = G_Goods.convert(type,value)

    if goods_info then
        self:getLabelByName("Label_name"):setColor(Colors.qualityColors[goods_info.quality])
        self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown,1)
        self:getLabelByName("Label_name"):setText(goods_info.name)
        self:getLabelByName("Label_desc"):setText(goods_info.desc)
        self:getImageViewByName("ImageView_icon"):loadTexture(goods_info.icon,UI_TEX_TYPE_LOCAL)
        self:getImageViewByName("ImageView_border"):loadTexture(G_Path.getEquipColorImage(goods_info.quality,type))
        self:getImageViewByName("ImageView_icon_quality"):loadTexture(G_Path.getEquipIconBack(goods_info.quality))

        if type ==G_Goods.TYPE_AWAKEN_ITEM then
            local hasNum = G_Me.bagData:getAwakenItemNumById(value)
            self:getLabelByName("Label_has"):setText(G_lang:get("LANG_DROP_NUM",{num=hasNum}))
            self:getLabelByName("Label_has"):setVisible(true)
        else
            self:getLabelByName("Label_has"):setVisible(false)
        end
    end
end

function DropInfoOther:_addEvents()
    self:registerBtnClickEvent("Button_close", function()
        self:_close()
    end)


end


return DropInfoOther

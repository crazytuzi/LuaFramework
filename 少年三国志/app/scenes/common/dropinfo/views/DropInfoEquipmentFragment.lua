
local DropInfoBaseView = require("app.scenes.common.dropinfo.DropInfoBaseView")


local DropInfoEquipmentFragment = class("DropInfoEquipmentFragment",DropInfoBaseView)
local DropInfoEquipment = require("app.scenes.common.dropinfo.views.DropInfoEquipment")
local Colors = require("app.setting.Colors")
function DropInfoEquipmentFragment.create(...)
    return DropInfoEquipmentFragment.new("ui_layout/dropinfo_DropInfoEquipmentFragment.json", ...)
end



function DropInfoEquipmentFragment:_addEvents()
    self:registerBtnClickEvent("Button_close", function()
        self:_close()
    end)


    self:registerBtnClickEvent("Button_detail", function()
        self:_toggleDetail()
    end)

    self:registerWidgetClickEvent("Label_detail" , function(widget, _type)
        self:_toggleDetail()
    end)

end

function DropInfoEquipmentFragment:setData(type, value)
    self._type = type
    self._value = value
    
    self:_addEvents()


    self:getLabelByName("Label_detail"):setText(G_lang:get('LANG_DROP_EQUIPMENT_DETAIL'))



    local goods_info = G_Goods.convert(type,value)

    local info = goods_info.info

    self:getLabelByName("Label_name"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown,1 )
    self:getLabelByName("Label_name"):setText(info.name)
    self:getLabelByName("Label_desc"):setText(info.directions)
    self:getImageViewByName("ImageView_icon_bg"):loadTexture(G_Path.getEquipIconBack(goods_info.quality))
    self:getImageViewByName("ImageView_icon"):loadTexture(goods_info.icon,UI_TEX_TYPE_LOCAL)
    self:getImageViewByName("ImageView_border"):loadTexture(G_Path.getEquipColorImage(goods_info.quality, G_Goods.TYPE_FRAGMENT))


end


function DropInfoEquipmentFragment:_onOpenDetail()

  
    self:getButtonByName("Button_detail"):setFlipY(true)
    self:getLabelByName("Label_detail"):setText(G_lang:get('LANG_DROP_EQUIPMENT_DETAIL_CLOSE'))

end

function DropInfoEquipmentFragment:_onCloseDetail()

    self:getButtonByName("Button_detail"):setFlipY(false)
    self:getLabelByName("Label_detail"):setText(G_lang:get('LANG_DROP_EQUIPMENT_DETAIL'))

end

function DropInfoEquipmentFragment:_createSubview()
    local view =  DropInfoEquipment.create()


    local goods_info = G_Goods.convert(self._type, self._value)

    view:setData(G_Goods.TYPE_EQUIPMENT, goods_info.info.fragment_value, true)

    return view
end





return DropInfoEquipmentFragment

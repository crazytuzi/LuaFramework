
local DropInfoBaseView = require("app.scenes.common.dropinfo.DropInfoBaseView")


local DropInfoKnightFragment = class("DropInfoKnightFragment",DropInfoBaseView)
local DropInfoKnight = require("app.scenes.common.dropinfo.views.DropInfoKnight")

function DropInfoKnightFragment.create(...)
    return DropInfoKnightFragment.new("ui_layout/dropinfo_DropInfoKnightFragment.json", ...)
end



function DropInfoKnightFragment:_addEvents()
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

function DropInfoKnightFragment:setData(type, value)
    self._type = type
    self._value = value 

    self:_addEvents()


    self:getLabelByName("Label_detail"):setText(G_lang:get('LANG_DROP_KNIGHT_DETAIL'))

    local goods_info = G_Goods.convert(type,value)

    local info = goods_info.info    
    self:getLabelByName("Label_name"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_detail"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_name"):setText(info.name)
    self:getLabelByName("Label_desc"):setText(info.directions)
    self:getImageViewByName("ImageView_icon"):loadTexture(goods_info.icon,UI_TEX_TYPE_LOCAL)
    self:getImageViewByName("ImageView_border"):loadTexture(G_Path.getEquipColorImage(goods_info.quality, G_Goods.TYPE_FRAGMENT))

end


function DropInfoKnightFragment:_onOpenDetail()

  
    self:getButtonByName("Button_detail"):setFlipY(true)
    self:getLabelByName("Label_detail"):setText(G_lang:get('LANG_DROP_KNIGHT_DETAIL_CLOSE'))

end

function DropInfoKnightFragment:_onCloseDetail()

    self:getButtonByName("Button_detail"):setFlipY(false)
    self:getLabelByName("Label_detail"):setText(G_lang:get('LANG_DROP_KNIGHT_DETAIL'))

end

function DropInfoKnightFragment:_createSubview()
    local view = DropInfoKnight.create()
    local goods_info = G_Goods.convert(self._type, self._value)

    view:setData(G_Goods.TYPE_KNIGHT, goods_info.info.fragment_value, true)
    return view
end




return DropInfoKnightFragment

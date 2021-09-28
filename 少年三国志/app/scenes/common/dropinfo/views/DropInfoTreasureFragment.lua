
local DropInfoBaseView = require("app.scenes.common.dropinfo.DropInfoBaseView")


local DropInfoTreasureFragment = class("DropInfoTreasureFragment",DropInfoBaseView)
local DropInfoTreasure = require("app.scenes.common.dropinfo.views.DropInfoTreasure")

function DropInfoTreasureFragment.create(...)
    return DropInfoTreasureFragment.new("ui_layout/dropinfo_DropInfoTreasureFragment.json", ...)
end



function DropInfoTreasureFragment:_addEvents()
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

function DropInfoTreasureFragment:setData(type, value)
    self._type = type
    self._value = value

    self:_addEvents()


    self:getLabelByName("Label_detail"):setText(G_lang:get('LANG_DROP_TREASURE_DETAIL'))



    local goods_info = G_Goods.convert(type,value)

    local info = goods_info.info
    
    self:getLabelByName("Label_name"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_detail"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_name"):setText(info.name)
    self:getLabelByName("Label_desc"):setText(info.directions)
    self:getImageViewByName("ImageView_icon_bg"):loadTexture(G_Path.getEquipIconBack(goods_info.quality))
    self:getImageViewByName("ImageView_icon"):loadTexture(goods_info.icon,UI_TEX_TYPE_LOCAL)
    self:getImageViewByName("ImageView_border"):loadTexture(G_Path.getEquipColorImage(goods_info.quality, G_Goods.TYPE_TREASURE_FRAGMENT))

end


function DropInfoTreasureFragment:_onOpenDetail()

  
    self:getButtonByName("Button_detail"):setFlipY(true)
    self:getLabelByName("Label_detail"):setText(G_lang:get('LANG_DROP_TREASURE_DETAIL_CLOSE'))

end

function DropInfoTreasureFragment:_onCloseDetail()

    self:getButtonByName("Button_detail"):setFlipY(false)
    self:getLabelByName("Label_detail"):setText(G_lang:get('LANG_DROP_TREASURE_DETAIL'))

end

function DropInfoTreasureFragment:_createSubview()
    local view = DropInfoTreasure.create()
    local goods_info = G_Goods.convert(self._type, self._value)

    view:setData(G_Goods.TYPE_TREASURE, goods_info.info.treasure_id, true)
    return view
end




return DropInfoTreasureFragment

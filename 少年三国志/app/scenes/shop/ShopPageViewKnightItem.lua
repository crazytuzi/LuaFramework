local ShopPageViewKnightItem = class("ShopPageViewKnightItem",function (  )
    return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/shop_ShopPageViewKnightItem.json")
    -- return CCSPageCellBase:create("ui_layout/shop_ShopPageViewKnightItem.json")
end)
require("app.cfg.knight_info")
local knightPic = require("app.scenes.common.KnightPic")

function ShopPageViewKnightItem:ctor(_,layer)

    self._reviewFunc = nil 
    --self._imageView = self:getButtonByName("Button_knight")
    -- self._panel = self:getPanelByName("Panel_knight")
    -- self._nameLabel = self:getLabelByName("Label_name")
    self._layer = layer
    self._panel = UIHelper:seekWidgetByName(self,"Panel_knight")
    self._nameLabel = UIHelper:seekWidgetByName(self,"Label_name")

    self._panel = tolua.cast(self._panel,"Layout")
    self._nameLabel = tolua.cast(self._nameLabel,"Label")
    self._nameLabel:createStroke(Colors.strokeBrown,1)
    self._imageView = nil
end

function ShopPageViewKnightItem:updatePage(knightId)
    local knight = knight_info.get(knightId)
    local size = self._panel:getContentSize()

    --必须这样写,不然会被多次创建
    if self._imageView ~= nil then
        self._panel:removeChild(self._imageView)
    end
    self._imageView = knightPic.createKnightPic(knight.res_id,self._panel,"" .. knight.id,true)
    self._panel:setScale(0.8)
    self._nameLabel:setColor(Colors.qualityColors[knight.quality])
    self._nameLabel:setText(knight.name)
end

function ShopPageViewKnightItem:setReviewClickEvent(func)
    self._reviewFunc = func
end


return ShopPageViewKnightItem

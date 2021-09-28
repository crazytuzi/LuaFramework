
local ActivityShouChongItem = class("ActivityShouChongItem",function ()
    return CCSItemCellBase:create("ui_layout/activity_ActivityDailyCellItem.json")
end)


function ActivityShouChongItem:ctor( good,... )
    self:showWidgetByName("Image_vip",false)
    self._numLabel = self:getLabelByName("Label_num")
    self._qualityBtn = self:getButtonByName("Button_item")
    self._imageItem = self:getImageViewByName("ImageView_item")
    self._numLabel:createStroke(Colors.strokeBrown,1)
    self:_updateItem(good)
end

function ActivityShouChongItem:_updateItem(good)
    self._good = good
    if not self._good then
        return
    end
    self._numLabel:setText("x"..(self._good.size or 0))
    self._qualityBtn:loadTextureNormal(G_Path.getEquipColorImage(self._good.quality or 1,self._good.type))
    self._qualityBtn:loadTexturePressed(G_Path.getEquipColorImage(self._good.quality or 1,self._good.type))
    self:getImageViewByName("Image_bg"):loadTexture(G_Path.getEquipIconBack(self._good.quality or 1))
    self._imageItem:loadTexture(self._good.icon)

    self:registerBtnClickEvent("Button_item",function()
        if not self._good then
            return
        end
        require("app.scenes.common.dropinfo.DropInfo").show(self._good.type,self._good.info.id) 
        end)
end


return ActivityShouChongItem


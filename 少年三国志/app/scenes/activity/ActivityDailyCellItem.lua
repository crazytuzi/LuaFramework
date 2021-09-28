
local ActivityDailyCellItem = class("ActivityDailyCellItem",function ()
    return CCSItemCellBase:create("ui_layout/activity_ActivityDailyCellItem.json")
end)


function ActivityDailyCellItem:ctor( good,vip,... )
    self._vip = vip or 0
    self._numLabel = self:getLabelByName("Label_num")
    self._qualityBtn = self:getButtonByName("Button_item")
    self._imageItem = self:getImageViewByName("ImageView_item")
    self._numLabel:createStroke(Colors.strokeBrown,1)
    self:_updateItem(good)
end

function ActivityDailyCellItem:_updateItem(good)
    self._good = good
    if not self._good then
        return
    end
    if self._vip == 0 then
        self:showWidgetByName("Image_vip",false)
    else
        self:getImageViewByName("Image_vip"):loadTexture(G_Path.getTextPath(string.format("mrqd_shuangbei_v%s.png",self._vip)))
        self:showWidgetByName("Image_vip",true)
    end
    self._numLabel:setText("x"..G_GlobalFunc.ConvertNumToCharacter3(self._good.size or 0))
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

function ActivityDailyCellItem:setGray()
    if not self._good then
        return
    end
    if G_Goods.checkOwnGood(self._good) then
        self:getImageViewByName("Image_bg"):showAsGray(false)
        self._imageItem:showAsGray(false)
        self._qualityBtn:showAsGray(false)
    else
        self._imageItem:showAsGray(true)
        self:getImageViewByName("Image_bg"):showAsGray(true)
        self._qualityBtn:showAsGray(true)
    end

end

return ActivityDailyCellItem


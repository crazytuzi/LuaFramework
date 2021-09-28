local GiftMailIconCell = class ("GiftMailIconCell", function (  )
    return CCSItemCellBase:create("ui_layout/giftmail_GiftMailIconCell.json")
end)

require("app.cfg.item_info")

function GiftMailIconCell:ctor(data, name)
    self._txtCount = self:getLabelByName("Label_count")
    self._icon =  self:getImageViewByName("ImageView_icon")
    self._des =  self:getLabelByName("Label_des")
   self._boardBg =  self:getImageViewByName("Image_board_bg")
    self._boardBtn = self:getButtonByName("Button_board")
   self._name = buttonName

end

function GiftMailIconCell:updateData(award )

	local info = G_Goods.convert(award.type, award.value)
  if info == nil then
    return
  end
    	self._txtCount:setText("x"..G_GlobalFunc.ConvertNumToCharacter3(award.size))
   	self._icon:loadTexture(info.icon,UI_TEX_TYPE_LOCAL);
      self._des:setColor(Colors.getColor(info.quality))
   	self._des:setText(info.name)
   	self._boardBg:loadTexture(G_Path.getEquipIconBack(info.quality))
      self._boardBtn:loadTextureNormal(G_Path.getEquipColorImage(info.quality,info.type))
      self._boardBtn:loadTexturePressed(G_Path.getEquipColorImage(info.quality,info.type))

   	self._des:createStroke(Colors.strokeBlack, 1)
   	self._txtCount:createStroke(Colors.strokeBlack, 1)

    self:registerBtnClickEvent("Button_board",function()
        local itemInfo = item_info.get(award.value)
        if itemInfo and itemInfo.item_type == 1 and award.type == 3 then
          local layer = require("app.scenes.shop.ShopGiftReviewDialog").create(itemInfo)
          uf_sceneManager:getCurScene():addChild(layer)
        else
          require("app.scenes.common.dropinfo.DropInfo").show(award.type,award.value)
        end
    end)
end

function GiftMailIconCell:getButtonName()
    return self._name
end 

function GiftMailIconCell:getWidth()
  local width = self:getContentSize().width
  return width
end

return GiftMailIconCell


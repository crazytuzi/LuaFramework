local TreasureRefineCailiaoCell = class ("TreasureRefineCailiaoCell", function (  )
    return CCSItemCellBase:create("ui_layout/treasure_TreasureRefineCailiaoCell.json")
end)


function TreasureRefineCailiaoCell:ctor()
    self._cailiaoTreasureList = nil -- 同名宝物的实例, 一般是最低强化等级的宝物, 
    self._containHighLevelTreasureList = false
end


--强化等级, 精炼等级
local sortFunc = function(a,b) 
    
    if a.level ~= b.level then
        return a.level < b.level
    end

    return a.refining_level < b.refining_level
end

function TreasureRefineCailiaoCell:updateData(type, value, size, currentCount,_equipment)

    if size == 0 then
      self:getImageViewByName("ImageView_bg"):setVisible(false)
      self:getImageViewByName("ImageView_icon"):setVisible(false)
      return 
    end
    self:getImageViewByName("ImageView_bg"):setVisible(true)
    self:getImageViewByName("ImageView_icon"):setVisible(true)

    local goods = G_Goods.convert(type, value)
    self:getImageViewByName("ImageView_icon"):loadTexture(goods.icon,UI_TEX_TYPE_LOCAL)
    local nameLabel = self:getLabelByName("Label_name")
    nameLabel:setColor(Colors.getColor(goods.quality))
    nameLabel:setText(goods.name)
    nameLabel:createStroke(Colors.strokeBrown, 1)

    self:getButtonByName("Button_equipment"):loadTextureNormal(G_Path.getEquipColorImage(goods.quality,goods.type))
    self:getButtonByName("Button_equipment"):loadTexturePressed(G_Path.getEquipColorImage(goods.quality,goods.type))

   self:registerBtnClickEvent("Button_equipment", function()
       require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(type, value,
        GlobalFunc.sceneToPack("app.scenes.treasure.TreasureDevelopeScene", {_equipment,2}))
   end)
   if currentCount < size then
       --红色
       self:getLabelByName("Label_count"):setColor(Colors.lightColors.TIPS_01)
   else
       --绿色
       self:getLabelByName("Label_count"):setColor(Colors.lightColors.ATTRIBUTE)
   end

    self:getLabelByName("Label_count"):setText(  currentCount .. "/" .. size)

end


return TreasureRefineCailiaoCell


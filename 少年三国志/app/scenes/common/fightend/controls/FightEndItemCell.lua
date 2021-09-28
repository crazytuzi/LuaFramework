local FightEndItemCell = class ("FightEndItemCell", function (  )
    return CCSItemCellBase:create("ui_layout/fightend_FightEndItemCell.json")
end)


function FightEndItemCell:ctor()
   
end



function FightEndItemCell:updateData( icon, quality, count,_type )
    self:getImageViewByName("ImageView_border"):loadTexture(G_Path.getEquipColorImage(quality,_type))
    self:getImageViewByName("ImageView_icon"):loadTexture(icon, UI_TEX_TYPE_LOCAL)
    self:getImageViewByName("Image_back"):loadTexture(G_Path.getEquipIconBack(quality))

    if count > 1 then
        self:getLabelByName("Label_count"):setVisible(true)
        self:getLabelByName("Label_count"):setText("x" .. GlobalFunc.ConvertNumToCharacter(count))
        self:getLabelByName("Label_count"):createStroke(Colors.strokeBrown,1)
    else
        self:getLabelByName("Label_count"):setVisible(false)
    end


end


return FightEndItemCell


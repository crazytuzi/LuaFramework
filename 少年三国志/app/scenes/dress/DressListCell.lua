local DressListCell = class("DressListCell",function()
    return CCSItemCellBase:create("ui_layout/dress_DressCell.json")
end)

require("app.cfg.knight_info")
require("app.cfg.dress_info")

function DressListCell:ctor()

        self:setTouchEnabled(true)
     
        self:registerCellClickEvent(function ( cell, index )
            if self._func and not ((self._equipment.id == 0 and self._curEquip == nil)or(self._curEquip and self._equipment.id == self._curEquip.base_id )) then
                self._func(self._equipment)
            end
        end) 
end

function DressListCell:updateData(data,equip,func)
        local equipment = data
        self._equipment = equipment
        self._curEquip = equip
        self._func = func
        local img = self:getImageViewByName("Image_equip")
        local board = self:getImageViewByName("Image_board")
        local boardicon = self:getImageViewByName("Image_boardicon")
        local equiped = self:getImageViewByName("Image_equiped")
        local levelLabel =  self:getLabelByName("Label_level")
        local imgChoosed =  self:getImageViewByName("Image_choosed")
        local ball = self:getImageViewByName("Image_ball" )
        local nameLabel = self:getLabelByName("Label_name")
        levelLabel:createStroke(Colors.strokeBrown, 1)
        nameLabel:createStroke(Colors.strokeBrown, 1)
        local grayColor = ccc3(0xae, 0xae, 0xae) 
        if data.id == 0 then
            local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
            local knight = knight_info.get(baseId)
            local icon = G_Path.getKnightIcon(knight.res_id)
            self:getLabelByName("Label_future"):setVisible(false)
            img:setColor(Colors.Noraml)
            img:loadTexture(icon)
            board:setColor(Colors.Noraml)
            board:loadTexture(G_Path.getAddtionKnightColorImage(knight.quality))
            boardicon:setVisible(false)
            nameLabel:setVisible(false)
            if G_Me.dressData:getDressed() == nil then
                equiped:setVisible(true)
            else
                equiped:setVisible(false)
            end
            levelLabel:setVisible(false)
            if equip == nil then
                imgChoosed:setVisible(true)
            else
                imgChoosed:setVisible(false)
            end
        elseif data.id == -1 then
            self:getLabelByName("Label_future"):createStroke(Colors.strokeBrown, 1)
            self:getLabelByName("Label_future"):setVisible(true)
            self:getLabelByName("Label_future"):setText(G_lang:get("LANG_DRESS_FUTURE"))
            img:setColor(grayColor)
            img:loadTexture("icon/dress/100.png")
            board:setColor(grayColor)
            board:loadTexture(G_Path.getAddtionKnightColorImage(5))
            ball:loadTexture(G_Path.getEquipIconBack(5))
            boardicon:setVisible(false)
            equiped:setVisible(false)
            levelLabel:setVisible(false)
            imgChoosed:setVisible(false)
            nameLabel:setVisible(false)
        else
            -- local info = G_Me.dressData:getDressInfo(equipment.id) 
            local info = equipment
            -- self:getLabelByName("Label_future"):setVisible(false)
            img:setColor(Colors.Noraml)
            img:loadTexture("icon/dress/"..info.id..".png")
            board:setColor(Colors.Noraml)
            board:loadTexture(G_Path.getAddtionKnightColorImage(info.quality))
            -- boardicon:setVisible(true)
            ball:loadTexture(G_Path.getEquipIconBack(info.quality))
            nameLabel:setVisible(true)
            nameLabel:setText(info.name)
            nameLabel:setColor(Colors.qualityColors[info.quality])
            if G_Me.dressData:getDressed() and G_Me.dressData:getDressed().base_id == data.id then
                equiped:setVisible(true)
            else
                equiped:setVisible(false)
            end
            local hasEquip = G_Me.dressData:getDressByBaseId(equipment.id)
            if hasEquip then
                levelLabel:setVisible(G_Me.dressData:getDressCanStrength())
                levelLabel:setText(hasEquip.level)
                boardicon:setVisible(G_Me.dressData:getDressCanStrength())
                img:setColor(Colors.Noraml)
                board:setColor(Colors.Noraml)
                self:getLabelByName("Label_future"):setVisible(false)
            else
                levelLabel:setVisible(false)
                boardicon:setVisible(false)
                img:setColor(grayColor)
                board:setColor(grayColor)
                self:getLabelByName("Label_future"):createStroke(Colors.strokeBrown, 1)
                self:getLabelByName("Label_future"):setVisible(true)
                self:getLabelByName("Label_future"):setText(G_lang:get("LANG_DRESS_GET"))
            end
            if equip and equip.base_id == data.id then
                imgChoosed:setVisible(true)
            else
                imgChoosed:setVisible(false)
            end
        end
        -- levelLabel:setVisible(false)
        -- boardicon:setVisible(false)
end

function DressListCell:onLayerUnload()
    
    uf_eventManager:removeListenerWithTarget(self)

end

return DressListCell

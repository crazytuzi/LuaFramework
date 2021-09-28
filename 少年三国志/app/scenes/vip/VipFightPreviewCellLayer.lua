local VipFightPreviewCellLayer = class ("VipFightPreviewCellLayer", function (  )
	return CCSItemCellBase:create("ui_layout/vip_VipFightPreviewCellLayer.json")
end)

require("app.cfg.dungeon_vip_info")

function VipFightPreviewCellLayer:ctor(list, index)     
        self._userName = self:getLabelByName("Label_Name")
        self._floor = self:getLabelByName("Label_Floor")
        self._bg = self:getImageViewByName("ImageView_bg")
end

function VipFightPreviewCellLayer:updateData( list, index, map )

    self._bg:loadTexture("ui/vip/fubentiaozhan_list"..(index%2+1)..".png")
    local info = dungeon_vip_info.get(map)
    if index == 0 then
        self._userName:setColor(Colors.lightColors.TITLE_01)
        self._floor:setColor(Colors.lightColors.TITLE_01)
        if info.type == 1 then 
            self._userName:setText(G_lang:get("LANG_VIP_POINT1"))
        else
            self._userName:setText(G_lang:get("LANG_VIP_POINT2"))
        end
        local g = Goods.convert(info.output_type, info.output_value)
        self._floor:setText(G_lang:get("LANG_VIP_GASS")..g.name)
        self._userName:createStroke(Colors.strokeBrown, 1)
        self._floor:createStroke(Colors.strokeBrown, 1)
        return 
    end

    self._userName:setText(info["extra_ratio_"..index])
    self._floor:setText(info["extra_size_"..index])
    if info["extra_ratio_"..index] > 0 then
        self._userName:setVisible(true)
    else
        self._userName:setVisible(false)
    end
    if info["extra_size_"..index] > 0 then
        self._floor:setVisible(true)
    else
        self._floor:setVisible(false)
    end
end

return VipFightPreviewCellLayer



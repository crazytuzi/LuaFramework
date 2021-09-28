local Test500Item = class("Test500Item",function()
	--记得修改json
    return CCSItemCellBase:create("ui_layout/herosoul_ReviewItem.json")
end)
--require("app.cfg.knight_info")
local Colors = require("app.setting.Colors")


function Test500Item:ctor(...)

end

function Test500Item:updateItem(tTmplList)
    for i=1, 4 do
        local tSoulTmpl = tTmplList[i]
        local imgBg = self:getImageViewByName("Image_Bg"..i)
        if tSoulTmpl then
            imgBg:setVisible(true)
            self:_updateSigleIcon(i, tSoulTmpl)
        else
            imgBg:setVisible(false)
        end
    end
end

function Test500Item:_updateSigleIcon(nIndex, tSoulTmpl)
    local imgIcon = self:getImageViewByName("Image_Icon"..nIndex)
    if imgIcon then
        imgIcon:loadTexture(G_Path.getKnightIcon(tSoulTmpl.res_id))
    end
    local labelName = self:getLabelByName("Label_Name"..nIndex)
    if labelName then
        labelName:createStroke(Colors.strokeBrown, 1)
        labelName:setColor(Colors.qualityColors[tSoulTmpl.quality])
        labelName:setText(tSoulTmpl.name)
    end
    local imgQualityFrame = self:getImageViewByName("Image_QualityFrame"..nIndex)
    if imgQualityFrame then
        imgQualityFrame:loadTexture(G_Path.getEquipColorImage(tSoulTmpl.quality, G_Goods.TYPE_HERO_SOUL))
    end
end


return Test500Item
	

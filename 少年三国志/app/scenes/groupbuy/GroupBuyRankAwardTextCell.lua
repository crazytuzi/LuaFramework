-- GroupBuyRankAwardTextCell.lua
require("app.cfg.wheel_prize_info")

local GroupBuyRankAwardTextCell = class ("GroupBuyRankAwardTextCell", function ()
	return CCSItemCellBase:create("ui_layout/groupbuy_RankAwardTextCell.json")
end)

function GroupBuyRankAwardTextCell:ctor(list, index, _type)
    self._type = _type

end

function GroupBuyRankAwardTextCell:updateData(list, index, data)
    local info = data
    if info == nil then return end
    local lower_rank = info.lower_rank
    local upper_rank = info.upper_rank
    local str = ""..upper_rank
    if lower_rank > upper_rank then
        str = str.."~"..lower_rank
    end
    self:getLabelByName("Label_txt"):setText(G_lang:get("LANG_GROUP_BUY_RANKSTR",{rank = str}))
    for i = 1, 3 do 
        if info["type_"..i] > 0 then
            local g = G_Goods.convert(info["type_"..i], info["value_"..i])
            local label = self:getLabelByName("Label_value"..i)
            label:setVisible(true)
            label:setText(g.name.."x"..info["size_"..i])
            label:setColor(info["color_"..i]==1 and Colors.lightColors.DESCRIPTION or Colors.lightColors.TIPS_01)
        else
            self:getLabelByName("Label_value"..i):setVisible(false)
        end
        
    end
end

return GroupBuyRankAwardTextCell


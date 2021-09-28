local TrigramsRankTxtCell = class ("TrigramsRankTxtCell", function (  )
	return CCSItemCellBase:create("ui_layout/trigrams_RankTxtCell.json")
end)

require("app.cfg.wheel_prize_info")

local FuCommon = require("app.scenes.dafuweng.FuCommon")


function TrigramsRankTxtCell:ctor(...)
    self._text2posX = self:getLabelByName("Label_value2"):getPositionX()
    self._text2PosY = self:getLabelByName("Label_value2"):getPositionY()
    self._text3posX = self:getLabelByName("Label_value3"):getPositionX()
    self._text3PosY = self:getLabelByName("Label_value3"):getPositionY()
end

function TrigramsRankTxtCell:updateData( list, _type, rankInfo)

    if type(rankInfo) ~= "table" then
        return
    end

    _type = _type or FuCommon.RANK_TYPE_PT

    local lower_rank = rankInfo.lower_rank
    local upper_rank = rankInfo.upper_rank
    local str = ""..upper_rank
    if lower_rank > upper_rank then
        str = str.."~"..lower_rank
    end

    self:getLabelByName("Label_txt"):setText(G_lang:get("LANG_TRIGRAMS_RANKSTR",{rank=str}))
    for i = 1 , 3 do 
        if rankInfo["type_"..i] > 0 then
            --local g = G_Goods.convert(rankInfo["type_"..i], rankInfo["value_"..i])
            local label = self:getLabelByName("Label_value"..i)
            label:setVisible(true)
            --label:setText(g.name.."x"..rankInfo["size_"..i])
            label:setText(rankInfo["prize_"..i].." x"..rankInfo["size_"..i])
            label:setColor(rankInfo["color_"..i]==1 and Colors.lightColors.DESCRIPTION or Colors.lightColors.TIPS_01)
        else
            self:getLabelByName("Label_value"..i):setVisible(false)
        end    
    end

    if _type == FuCommon.RANK_TYPE_PT then
        self:getLabelByName("Label_value2"):setPositionXY(self._text2posX,self._text2PosY)
        self:getLabelByName("Label_value3"):setPositionXY(self._text3posX,self._text3PosY)
    else
        self:getLabelByName("Label_value2"):setPositionXY(self._text3posX,self._text3PosY)
        self:getLabelByName("Label_value3"):setPositionXY(self._text2posX,self._text3PosY)
    end
end

return TrigramsRankTxtCell


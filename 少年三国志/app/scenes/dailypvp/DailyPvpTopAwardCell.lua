
local DailyPvpTopAwardCell = class ("DailyPvpTopAwardCell", function (  )
    return CCSItemCellBase:create("ui_layout/dailypvp_PaiHangAwardCell.json")
end)
require("app.cfg.daily_crosspvp_rank")

function DailyPvpTopAwardCell:ctor(list, index)
    self._rankImg = self:getImageViewByName("Image_rank")
    self._rank = self:getLabelByName("Label_rank")
end

function DailyPvpTopAwardCell:updateData( data)
        if data.id < 4 then
            self._rank:setVisible(false)
            self._rankImg:setVisible(true)
            self._rankImg:loadTexture("ui/top/mrt_huangguan"..data.id..".png")
        else
            self._rank:setVisible(true)
            self._rankImg:setVisible(false)
            self._rank:setText(G_lang:get("LANG_DAILY_RANK_DESC",{up=data.upper_rank,low=data.lower_rank}))
        end

        for i = 1 , 2 do
            local g = G_Goods.convert(data["type_"..i], data["value_"..i])
            if g then
                -- item:setVisible(true)
                self:getImageViewByName("Image_boardBg"..i):setVisible(true)
                self:getImageViewByName("Image_icon"..i):loadTexture(g.icon)
                self:getButtonByName("Button_board"..i):loadTextureNormal(G_Path.getEquipColorImage(g.quality))
                self:getLabelByName("Label_num"..i):setText("x"..GlobalFunc.ConvertNumToCharacter4(data["size_"..i]))
                self:getLabelByName("Label_num"..i):createStroke(Colors.strokeBrown, 1)

                self:registerBtnClickEvent("Button_board"..i, function ( widget, param )
                        require("app.scenes.common.dropinfo.DropInfo").show(data["type_"..i], data["value_"..i])  
                end)
            else
                self:getImageViewByName("Image_boardBg"..i):setVisible(false)
            end
        end
end

return DailyPvpTopAwardCell


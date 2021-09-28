local WushLeaderboardCellLayer = class ("WushLeaderboardCellLayer", function (  )
	return CCSItemCellBase:create("ui_layout/wush_WushLeaderboardCellLayer.json")
end)


function WushLeaderboardCellLayer:ctor(list, index)     
        self._number = self:getLabelBMFontByName("LabelBMFont_Number")
        self._userName = self:getLabelByName("Label_Name")
        self._floor = self:getLabelByName("Label_Floor")
        self._championImg = self:getImageViewByName("ImageView_Champion")
        self._mingciImg = self:getImageViewByName("ImageView_Mingci")
        self.infoBg = self:getImageViewByName("ImageView_Infobg")
end

function WushLeaderboardCellLayer:updateData( list, index, rankInfo )
        --todo read config
        if index < 3 then
            self._mingciImg:loadTexture("ui/dungeon/mingci_1.png")
            self.infoBg:loadTexture("ui/dungeon/info_1.png")
            self._number:setVisible(false)
            self._championImg:loadTexture(string.format("ui/text/txt/phb_%dst.png", index+1))
            self._championImg:setVisible(true)
        else
            self._mingciImg:loadTexture("ui/dungeon/mingci_2.png")
            self.infoBg:loadTexture("ui/dungeon/info_2.png")
            self._number:setText(index+1)
            self._championImg:setVisible(false)
            self._number:setVisible(true)
        end
        
        if rankInfo.name == G_Me.userData.name then
            self.infoBg:loadTexture("ui/dungeon/info_3.png")
            self._mingciImg:loadTexture("ui/dungeon/mingci_3.png")
        end
        
        self._userName:setText(rankInfo.name)
        self._floor:setText(rankInfo.star.."星")
end

return WushLeaderboardCellLayer



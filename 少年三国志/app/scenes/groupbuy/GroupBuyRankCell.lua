-- GroupBuyRankCell.lua
local GroupBuyCommon = require("app.scenes.groupbuy.GroupBuyCommon")
require("app.cfg.knight_info")
require("app.cfg.wheel_prize_info")

local string = string

local GroupBuyRankCell = class("GroupBuyRankCell", function ( ... )
	return CCSItemCellBase:create("ui_layout/groupbuy_RankCell.json")
end)

function GroupBuyRankCell:ctor(list, index,_type)
        self.listView = list
        self.cellIndex = index
        self._type = _type
        self._data = nil
        
        self._vip = self:getImageViewByName("Image_vip")
        self._vip:setVisible(false)
        self._playerName = self:getLabelByName("Label_name")
        self._playerLevel = self:getLabelByName("Label_level")
        self._hero = self:getImageViewByName("Image_heroIcon")
        self._board = self:getButtonByName("Button_border")
        self._score = self:getLabelByName("Label_score")
        self._rankLabel = self:getLabelBMFontByName("BitmapLabel_9")
        self._rankImg = self:getImageViewByName("Image_rank")
        self._bg = self:getImageViewByName("Image_bg")
        self._boardbg = self:getImageViewByName("Image_board")

        self._playerName:createStroke(Colors.strokeBrown, 1)
        
        self:registerBtnClickEvent("Button_border", function ( widget)
            if self._data.name ~= G_Me.userData.name then 
                local input = require("app.scenes.friend.FriendInfoLayer").createByName(nil,self._data.name,function ( index )
                end)   
                uf_sceneManager:getCurScene():addChild(input)
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CLICK_SELF"))
            end
        end)
end

function GroupBuyRankCell:updateData(list, index, data, type)
        self._data = data

        if self._data.name == G_Me.userData.name then 
            self._bg:loadTexture("board_red.png",UI_TEX_TYPE_PLIST)
            self._boardbg:loadTexture("list_board_red.png",UI_TEX_TYPE_PLIST)
        else
            self._bg:loadTexture("board_normal.png",UI_TEX_TYPE_PLIST)
            self._boardbg:loadTexture("list_board.png",UI_TEX_TYPE_PLIST)
        end
        local knightBaseInfo = knight_info.get(data.main_role)
        local resId = G_Me.dressData:getDressedResidWithClidAndCltm(data.main_role, data.dress_id , data.clid,data.cltm,data.clop)
        local heroPath = G_Path.getKnightIcon(resId)
        self._hero:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
        self._board:loadTextureNormal(G_Path.getEquipColorImage(knightBaseInfo.quality,G_Goods.TYPE_KNIGHT))
        self._playerName:setColor(Colors.qualityColors[knightBaseInfo.quality])
        self._playerName:setText(data.name)
        self._score:setText(G_lang:get("LANG_WHEEL_SCORE")..data.score)
        local rank = index+1
        if rank <= 3 then
            self._rankLabel:setVisible(false)
            self._rankImg:setVisible(true)
            self._rankImg:loadTexture(string.format("ui/text/txt/phb_%dst.png", rank))
        else
            self._rankLabel:setVisible(true)
            self._rankImg:setVisible(false)
            self._rankLabel:setText(rank)
        end

        local info = GroupBuyCommon.getAward(rank,type)
        if info == nil then return end
        for i = 1 , 3 do
            if info["type_"..i] > 0 then
                local g = G_Goods.convert(info["type_"..i], info["value_"..i])
                if g then
                    self:getLabelByName("Label_award"..i):setText(g.name.."  x"..GlobalFunc.ConvertNumToCharacter2(info["size_"..i]))
                    self:getLabelByName("Label_award"..i):setVisible(true)
                end
            else
                self:getLabelByName("Label_award"..i):setVisible(false)
            end
        end
end

return GroupBuyRankCell


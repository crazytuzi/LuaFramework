local TrigramsRankCell = class ("TrigramsRankCell", function (  )
	return CCSItemCellBase:create("ui_layout/trigrams_RankCell.json")
end)

require("app.cfg.wheel_prize_info")

function TrigramsRankCell:ctor(...)
     
    self._vip = self:getImageViewByName("Image_vip")
    self._vip:setVisible(false)
    self._playerName = self:getLabelByName("Label_name")
    self._playerLevel = self:getLabelByName("Label_level")
    self._serverName = self:getLabelByName("Label_sname")
    self._serverName:setText("")
    self._hero = self:getImageViewByName("Image_heroIcon")
    self._board = self:getButtonByName("Button_border")
    self._score = self:getLabelByName("Label_score")
    self._rankLabel = self:getLabelBMFontByName("BitmapLabel_9")
    self._rankImg = self:getImageViewByName("Image_rank")
    self._bg = self:getImageViewByName("Image_bg")
    self._boardbg = self:getImageViewByName("Image_board")
    self._frameImage = self:getImageViewByName("Image_frame")

    self._playerName:createStroke(Colors.strokeBrown, 1)
    
    --self:registerBtnClickEvent("Button_border", function ( widget)
    --    self:_viewFriendInfo()
    --end)
end

--[[
function TrigramsRankCell:_viewFriendInfo()
    if self._data and self._data.name ~= G_Me.userData.name then 
        local input = require("app.scenes.friend.FriendInfoLayer").createByName(nil,self._data.name,function ( index )
            end)   
        uf_sceneManager:getCurScene():addChild(input)
    end
end
]]

function TrigramsRankCell:updateData( list, index, data, _type)
    self._data = nil

	if data == nil or type(data) ~= "table" then
        return
    end

    self._data = data

    if self._data.name == G_Me.userData.name then 
        self._bg:loadTexture("board_red.png",UI_TEX_TYPE_PLIST)
        self._boardbg:loadTexture("list_board_red.png",UI_TEX_TYPE_PLIST)
    else
        self._bg:loadTexture("board_normal.png",UI_TEX_TYPE_PLIST)
        self._boardbg:loadTexture("list_board.png",UI_TEX_TYPE_PLIST)
    end

    local knightBaseInfo = knight_info.get(data.main_role)
    local resId = G_Me.dressData:getDressedResidWithDress(data.main_role,data.dress_id)
    local heroPath = G_Path.getKnightIcon(resId)
    self._hero:loadTexture(heroPath, UI_TEX_TYPE_LOCAL)
    self._board:loadTextureNormal(G_Path.getEquipColorImage(knightBaseInfo.quality,G_Goods.TYPE_KNIGHT))
    self._playerName:setColor(Colors.qualityColors[knightBaseInfo.quality])
    self._playerName:setText(data.name)
    self._score:setText(G_lang:get("LANG_TRIGRAMS_RANKSCORE")..data.sp1)

    if rawget(data, "sname") then
    	self._serverName:setText("[".. data.sname .."]")
    end

    --头像框
    self._frameImage:setVisible(false)

    if rawget(data,"fid") and data.fid > 0 then
        require("app.cfg.frame_info")
        local frame = frame_info.get(data.fid)
        self._frameImage:setVisible(true)
        self._frameImage:loadTexture(G_Path.getAvatarFrame(data.fid))
        G_GlobalFunc.addHeadIcon(self._frameImage,frame.vip_level)
    end

    self:showWidgetByName("Image_vip", rawget(data,"vip") and data.vip > 0 or false)

    local rank = index+1
    if rank <= 3 then
        self._rankLabel:setVisible(false)
        self._rankImg:setVisible(true)
        self._rankImg:loadTexture("ui/text/txt/phb_"..rank.."st.png")
    else
        self._rankLabel:setVisible(true)
        self._rankImg:setVisible(false)
        self._rankLabel:setText(rank)
    end

    local awardInfo = G_Me.trigramsData:getAward(rank, _type)
   
    if awardInfo ~= nil then    
	    for i = 1 , 3 do
	        if awardInfo["type_"..i] > 0 then
	            --local g = G_Goods.convert(awardInfo["type_"..i], awardInfo["value_"..i])
                self:getLabelByName("Label_award"..i):setText(awardInfo["prize_"..i].." x"..GlobalFunc.ConvertNumToCharacter2(awardInfo["size_"..i]))
	            --self:getLabelByName("Label_award"..i):setText(g.name.."  x"..GlobalFunc.ConvertNumToCharacter2(awardInfo["size_"..i]))
	            self:getLabelByName("Label_award"..i):setVisible(true)
	        else
	            self:getLabelByName("Label_award"..i):setVisible(false)
	        end
	    end
	end

    --查看阵容
    self:registerWidgetClickEvent("Image_hero", handler(self, self._onTouchHead))
end


function TrigramsRankCell:_onTouchHead(...)
    __Log("[TrigramsRankCell:_onTouchHead]")
    if self._data.id ~= G_Me.userData.id then
        if self._data.sid and self._data.id then
            uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_PLAYER_TEAM, self._onRcvPlayerTeam, self)
            G_HandlersManager.crossWarHandler:sendGetPlayerTeam(self._data.sid, self._data.id)
        end
    end
end

function TrigramsRankCell:_onRcvPlayerTeam(data)
    if data.user_id == self._data.id and data.sid == self._data.sid then
        local user = rawget(data, "user")
        if user ~= nil then
            local layer = require("app.scenes.arena.ArenaZhenrong").create(user)
            uf_sceneManager:getCurScene():addChild(layer)
        end
    end

    uf_eventManager:removeListenerWithTarget(self)
end

return TrigramsRankCell


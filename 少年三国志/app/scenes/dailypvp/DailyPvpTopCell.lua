local DailyPvpTopCell = class ("DailyPvpTopCell", function (  )
	return CCSItemCellBase:create("ui_layout/dailypvp_PaiHangCell.json")
end)

require("app.cfg.daily_crosspvp_rank")

function DailyPvpTopCell:ctor(list, index)
        
        self._vip = self:getImageViewByName("Image_vip")
        self._vip:setVisible(false)
        self._vip:setZOrder(7)
        self._playerName = self:getLabelByName("Label_name")
        self._hero = self:getImageViewByName("Image_heroIcon")
        self._board = self:getButtonByName("Button_border")
        self._score = self:getLabelByName("Label_score")
        self._rankLabel = self:getLabelBMFontByName("BitmapLabel_rank")
        self._rankImg = self:getImageViewByName("Image_rank")
        self._bg = self:getImageViewByName("Image_bg")
        self._boardbg = self:getImageViewByName("Image_board")
        self._serverName = self:getLabelByName("Label_serverName")
        self._frame = self:getImageViewByName("ImageView_Frame")
        self._frame:setVisible(false)

        self._playerName:createStroke(Colors.strokeBrown, 1)
        
        self:registerBtnClickEvent("Button_border", function ( widget)
            local info = self._data
            if tostring(info.sid) == tostring(G_PlatformProxy:getLoginServer().id) then
                if info.id ~= G_Me.userData.id then
                    local input = require("app.scenes.friend.FriendInfoLayer").createByName(info.id,nil,function ( index )
                    end)   
                    uf_sceneManager:getCurScene():addChild(input)
                end
            else
                G_HandlersManager.crossWarHandler:sendGetPlayerTeam(info.sid, info.id)
            end
        end)
end

function DailyPvpTopCell:updateData( data,index)
        self._data = data
        -- dump(data)
        if self._data.name == G_Me.userData.name then 
            self._bg:loadTexture("board_red.png",UI_TEX_TYPE_PLIST)
            self._boardbg:loadTexture("list_board_red.png",UI_TEX_TYPE_PLIST)
        else
            self._bg:loadTexture("board_normal.png",UI_TEX_TYPE_PLIST)
            self._boardbg:loadTexture("list_board.png",UI_TEX_TYPE_PLIST)
        end
        local knightBaseInfo = knight_info.get(data.main_role)

        local resId = G_Me.dressData:getDressedResidWithClidAndCltm(data.main_role,data.dress_id,
           rawget(data,"clid"),rawget(data,"cltm"),rawget(data,"clop"))
        local heroPath = G_Path.getKnightIcon(resId)
        self._hero:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
        self._board:loadTextureNormal(G_Path.getEquipColorImage(knightBaseInfo.quality,G_Goods.TYPE_KNIGHT))
        self._playerName:setColor(Colors.qualityColors[knightBaseInfo.quality])
        self._playerName:setText(data.name)
        self._serverName:setText(data.sname)
        self._score:setText(G_lang:get("LANG_DAILY_RANK_SCORE",{score=data.honor}))

        --头像框
        local frameId = rawget(data,"fid") and data.fid or 0
        if frameId > 0 then
            require("app.cfg.frame_info")
            local frame = frame_info.get(frameId)
            if frame then
                self._frame:setVisible(true)
                self._frame:loadTexture(G_Path.getAvatarFrame(frame.res_id))
                G_GlobalFunc.addHeadIcon(self._frame,frame.vip_level)
            else
                self._frame:setVisible(false)
            end
        else
            self._frame:setVisible(false)
        end
        
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

        self._vip:setVisible(data.vip>0)

        local info = G_Me.dailyPvpData:getRankData(rank)
        for i = 1 , 2 do
            if info["type_"..i] > 0 then
                local g = G_Goods.convert(info["type_"..i], info["value_"..i])
                self:getLabelByName("Label_award"..i):setText(g.name.."  x"..GlobalFunc.ConvertNumToCharacter4(info["size_"..i]))
                self:getLabelByName("Label_award"..i):setVisible(true)
            else
                self:getLabelByName("Label_award"..i):setVisible(false)
            end
        end
end

return DailyPvpTopCell


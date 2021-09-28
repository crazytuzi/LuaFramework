local DailyPvpInviteCell = class ("DailyPvpInviteCell", function (  )
	return CCSItemCellBase:create("ui_layout/dailyPvp_InviteLayerCell.json")
end)
require("app.cfg.daily_crosspvp_rank_title")

DailyPvpInviteCell.MAX_CD = 60

function DailyPvpInviteCell:ctor(list, index)
        
        self._uid = 0
        self._friend = nil
        self._type = 0
        
        self._vip = self:getImageViewByName("ImageView_vip")
        self._fightCapacity = self:getLabelByName("Label_zhanli")
        self._playerName = self:getLabelByName("Label_name")
        self._playerLevel = self:getLabelByName("Label_level")
        self._isOnline = self:getLabelByName("Label_lineupIn")
        self._hero = self:getImageViewByName("ImageView_equipment_icon")
        self._board = self:getButtonByName("Button_border")
        self._frame = self:getImageViewByName("ImageView_Frame")
        self._frame:setVisible(false)

        self._legionLabel = self:getLabelByName("Label_legion")
        self._titleLabel = self:getLabelByName("Label_title")
        self._timeLabel = self:getLabelByName("Label_time")
        self._timeLabel:setVisible(false)
        self._inviteButton = self:getButtonByName("Button_invite")
 
         self._playerName:createStroke(Colors.strokeBrown, 1)
         self._titleLabel:createStroke(Colors.strokeBrown, 1)

         self:attachImageTextForBtn("Button_invite","Image_invite")

        self:registerBtnClickEvent("Button_invite", function(widget)
            self:_inviteFriend()
        end)
        
        self:registerBtnClickEvent("Button_border", function ( widget)
                local input = require("app.scenes.friend.FriendInfoLayer").create(self._friend)   
                uf_sceneManager:getCurScene():addChild(input)
                
        end)
end

function DailyPvpInviteCell:updateData( friend )
        if not friend then
            return
        end
        
        self._uid = friend.id
        self._friend = friend
        
        local knightBaseInfo = knight_info.get(friend.mainrole)
        local resId = G_Me.dressData:getDressedResidWithClidAndCltm(friend.mainrole,friend.dress_id,
            friend.clid,friend.cltm,friend.clop)
        local heroPath = G_Path.getKnightIcon(resId)
        self._hero:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
        self._board:loadTextureNormal(G_Path.getEquipColorImage(knightBaseInfo.quality,G_Goods.TYPE_KNIGHT))
        self._playerName:setColor(Colors.qualityColors[knightBaseInfo.quality])
        
        if self._vip then
            self._vip:setVisible(friend.vip > 0)
        end
        
        if self._playerName then
            self._playerName:setText(friend.name)
        end
        
        --头像框
        local frameId = rawget(friend,"fid") and friend.fid or 0
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

        if self._fightCapacity then
            self._fightCapacity:setText(friend.fighting_capacity)
        end
        
        if self._playerLevel then
            self._playerLevel:setText(friend.level..G_lang:get("LANG_FRIEND_LEVEL"))
        end

        if #friend.guild_name > 0 then
            self._legionLabel:setText(friend.guild_name)
        else
            self._legionLabel:setText(G_lang:get("LANG_FRIEND_ZANWU"))
        end

        local maxCD = DailyPvpInviteCell.MAX_CD
        if G_ServerTime:getTime() - friend.lastSendTime > maxCD then
            self._inviteButton:setTouchEnabled(true)
            self._timeLabel:setVisible(false)
        else
            self._inviteButton:setTouchEnabled(false)
            self._timeLabel:setVisible(true)
            self._timeLabel:setText(G_lang:get("LANG_DAILY_CD",{time=maxCD - G_ServerTime:getTime() + friend.lastSendTime}) )
        end
        
        local titleId = friend.team_pvp_title
        local titleInfo = daily_crosspvp_rank_title.get(titleId)
        self._titleLabel:setText(titleInfo.text)
        self._titleLabel:setColor(Colors.qualityColors[titleInfo.quality])
end

function DailyPvpInviteCell:_inviteFriend( )
    G_HandlersManager.dailyPvpHandler:sendTeamPVPInvite(self._uid)
end

return DailyPvpInviteCell


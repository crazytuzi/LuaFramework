local FriendSugListCell = class ("FriendSugListCell", function (  )
	return CCSItemCellBase:create("ui_layout/friend_FriendSugListCell.json")
end)


function FriendSugListCell:ctor(list, index)
        self.listView = list
        self.cellIndex = index
        
        self._uid = 0
        self._friend = nil
        self._type = 0
        
        self._vip = self:getImageViewByName("ImageView_vip")
        self._fightCapacity = self:getLabelByName("Label_zhanli")
        self._playerName = self:getLabelByName("Label_name")
        self._playerLevel = self:getLabelByName("Label_level")
        self._isOnline = self:getLabelByName("Label_lineupIn")
        self._present = self:getButtonByName("Button_jingli")
        self._hero = self:getImageViewByName("ImageView_equipment_icon")
        self._board = self:getButtonByName("Button_border")
        self._frame = self:getImageViewByName("ImageView_Frame")
        self._frame:setVisible(false)

        -- self._fightCapacity:createStroke(Colors.strokeBrown, 1)
        self._playerName:createStroke(Colors.strokeBrown, 1)
        -- self._playerLevel:createStroke(Colors.strokeBrown, 1)
        -- self._isOnline:createStroke(Colors.strokeBrown, 1)

        self:getLabelByName("Label_attr01Name01"):setText(G_lang:get("LANG_FRIEND_BANGHUI"))
        self:getLabelByName("Label_attr01Value01"):setText(G_lang:get("LANG_FRIEND_ZANWU"))
        
        self:registerBtnClickEvent("Button_jingli", function(widget)
            self:_addFriend()
        end)
        
        self:registerBtnClickEvent("Button_border", function ( widget)
                local input = require("app.scenes.friend.FriendInfoLayer").create(self._friend)   
                uf_sceneManager:getCurScene():addChild(input)
                
        end)
end

function FriendSugListCell:updateData( list, index, friend )
        if not friend then
            return
        end

        self._uid = friend.id
        self._friend = friend

        local knightBaseInfo = knight_info.get(friend.mainrole)
        -- local resId = knightBaseInfo["res_id"]

        local resId = G_Me.dressData:getDressedResidWithClidAndCltm(friend.mainrole,friend.dress_id,friend.clid,friend.cltm,friend.clop)
        local heroPath = G_Path.getKnightIcon(resId)
        self._hero:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
        self._board:loadTextureNormal(G_Path.getEquipColorImage(knightBaseInfo.quality,G_Goods.TYPE_KNIGHT))
        self._board:loadTexturePressed(G_Path.getEquipColorImage(knightBaseInfo.quality,G_Goods.TYPE_KNIGHT))
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
        
        if self._isOnline then
            if friend.online == 0 then
                self._isOnline:setColor(Colors.lightColors.TIPS_01)
            else
                self._isOnline:setColor(Colors.lightColors.TIPS_02)
            end
            -- self._isOnline:setText(self:_getTime(friend.online))
            self._isOnline:setText(G_GlobalFunc.getOnlineTime(friend.online))
        end

        if #friend.guild_name > 0 then
            self:getLabelByName("Label_attr01Value01"):setText(friend.guild_name)
        else
            self:getLabelByName("Label_attr01Value01"):setText(G_lang:get("LANG_FRIEND_ZANWU"))
        end
        
end

function FriendSugListCell:_getTime( time )
    local t = G_ServerTime:getTime() - time
    local str
    if time == 0 then 
        str = G_lang:get("LANG_FRIEND_ONLINE1")
        return str
    else
        -- str = G_lang:get("LANG_FRIEND_OFFLINE")
        -- return str
    end

    local min=math.floor(t/60)
    local hour=math.floor(min/60)
    local day=math.floor(hour/24)
    if day >= 1 then 
        str = G_lang:get("LANG_FRIEND_ONLINE2", {time=day})
    elseif hour >= 1 then 
        str = G_lang:get("LANG_FRIEND_ONLINE3", {time=hour})
    else
        if min == 0 then
            min = 1
        end
        str = G_lang:get("LANG_FRIEND_ONLINE4", {time=min})
    end
    return str
end

function FriendSugListCell:_addFriend( )
    G_HandlersManager.friendHandler:sendAddFriend(self._friend.name)
end

return FriendSugListCell


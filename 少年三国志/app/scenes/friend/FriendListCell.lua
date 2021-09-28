local FriendListCell = class ("FriendListCell", function (  )
	return CCSItemCellBase:create("ui_layout/friend_FriendListCell.json")
end)


function FriendListCell:ctor(list, index)
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
            self:_givePresent()
        end)
        
        self:registerBtnClickEvent("Button_jiechu", function(widget)
            self:_blackOff()
        end)

        self:registerBtnClickEvent("Button_tongyi", function(widget)
            self:_tongyi()
        end)
        
        self:registerBtnClickEvent("Button_jujue", function(widget)
            self:_jujue()
        end)
        
        self:registerBtnClickEvent("Button_border", function ( widget)
                -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_USER_INFO, nil, false, self._friend)
                -- local input = require("app.scenes.friend.FriendInfoLayer").createByName(self._friend.id,self._friend.name,function ( index )
                --     print(index)
                --     return true
                -- end)   
                local input = require("app.scenes.friend.FriendInfoLayer").create(self._friend)   
                uf_sceneManager:getCurScene():addChild(input)
                
        end)
end

function FriendListCell:updateData( list, index, friend ,btnName)
        if not friend then
            return
        end

        self._uid = friend.id
        self._friend = friend
        self._type = btnName

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
        self:_updatePresentStatus(friend,btnName)
end

function FriendListCell:_getTime( time )
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

function FriendListCell:_givePresent()
        if not self._friend then
            return
        end
        if self._type == "CheckBox_friend" then 
            G_HandlersManager.friendHandler:sendGivePresent(self._friend.id)
        else 
            if G_Me.friendData:getPresentLeft() == 0 then
                G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_PRESENT_DONE"))
                return
            end
            local CheckFunc = require("app.scenes.common.CheckFunc")
            if CheckFunc.checkSpiritFromFriend() then
                G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_PRESENT_FULL"))
                return
            end
            G_HandlersManager.friendHandler:sendReceivePresent(self._friend.id)
        end
end

function FriendListCell:_blackOff()
        if not self._friend then
            return
        end
        MessageBoxEx.showYesNoMessage( G_lang:get("LANG_FRIEND_TISHI"),
         G_lang:get("LANG_FRIEND_REMOVEBLACK",{name=self._friend.name}), false, 
            function() 
                G_HandlersManager.friendHandler:sendDeleteBlack(self._friend.id)
            end,
            function() end, 
            self )
end

function FriendListCell:_updatePresentStatus(friend,btnName)
        if btnName == "CheckBox_friend" then
            self:getImageViewByName("Image_31"):loadTexture("ui/text/txt/zengsongjinli.png")
            self:getButtonByName("Button_jiechu"):setVisible(false)
            if friend.present then
                self:getImageViewByName("Image_yizengsong"):setVisible(false)
               self._present:setVisible(true)
            else
                self:getImageViewByName("Image_yizengsong"):setVisible(true)
                self._present:setVisible(false)
            end
            self:getButtonByName("Button_tongyi"):setVisible(false)
            self:getButtonByName("Button_jujue"):setVisible(false)
        elseif btnName == "CheckBox_tili" then
            self:getImageViewByName("Image_31"):loadTexture("ui/text/txt/linqujingli.png")
            self._present:setVisible(true)
            self:getImageViewByName("Image_yizengsong"):setVisible(false)
            self:getButtonByName("Button_jiechu"):setVisible(false)
            self:getButtonByName("Button_tongyi"):setVisible(false)
            self:getButtonByName("Button_jujue"):setVisible(false)
        elseif btnName == "CheckBox_black" then
            self:getButtonByName("Button_jiechu"):setVisible(true)
            self:getImageViewByName("Image_yizengsong"):setVisible(false)
            self._present:setVisible(false)
            self:getButtonByName("Button_tongyi"):setVisible(false)
            self:getButtonByName("Button_jujue"):setVisible(false)
        else
            self:getButtonByName("Button_jiechu"):setVisible(false)
            self:getImageViewByName("Image_yizengsong"):setVisible(false)
            self._present:setVisible(false)
            self:getButtonByName("Button_tongyi"):setVisible(true)
            self:getButtonByName("Button_jujue"):setVisible(true)
        end
end

function FriendListCell:_tongyi()
        if not self._friend then
            return
        end
        G_HandlersManager.friendHandler:sendConfirmFriend(self._uid,true)
end

function FriendListCell:_jujue()
        if not self._friend then
            return
        end
        G_HandlersManager.friendHandler:sendConfirmFriend(self._uid,false)
end

return FriendListCell


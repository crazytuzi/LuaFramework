
FriendRightBtsBarControll = class("FriendRightBtsBarControll");

function FriendRightBtsBarControll:New()
    self = { };
    setmetatable(self, { __index = FriendRightBtsBarControll });
    return self
end

function FriendRightBtsBarControll:Init(gameObject)
    self.gameObject = gameObject;

    self.btn_chakan = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_chakan");
    self.btn_yqzudui = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_yqzudui");
    self.btn_yqruzong = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_yqruzong");
    self.btn_schaoyou = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_schaoyou");
    self.btn_schaoyouIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "btn_schaoyou");


    self._onClickbtn_chakan = function(go) self:_OnClickbtn_chakan(self) end
    UIUtil.GetComponent(self.btn_chakan, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_chakan);

    self._onClickbtn_yqzudui = function(go) self:_OnClickbtn_yqzudui(self) end
    UIUtil.GetComponent(self.btn_yqzudui, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_yqzudui);

    self._onClickbtn_yqruzong = function(go) self:_OnClickbtn_yqruzong(self) end
    UIUtil.GetComponent(self.btn_yqruzong, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_yqruzong);

    self._onClickbtn_schaoyou = function(go) self:_OnClickbtn_schaoyou(self) end
    UIUtil.GetComponent(self.btn_schaoyou, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_schaoyou);


    MessageManager.AddListener(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_SELECTED, FriendRightBtsBarControll.FriendListItemSelected, self)

    -- 需要判断 自己是否已经入仙盟
    local ising= GuildDataManager.InGuild();
    if not ising then
    self.btn_yqruzong.gameObject:SetActive(false);
    
    Util.SetLocalPos(self.btn_schaoyou,597, -139, 0)
--    self.btn_schaoyou.transform.localPosition = Vector3.New(602, -56, 0);
   end

end



function FriendRightBtsBarControll:FriendListItemSelected(target)


    self.curr_fdata = target.curr_data;
    local type = self.curr_fdata.type;

    local p_id = self.curr_fdata.id;

    local friend = FriendDataManager.GetFriend(p_id);

    if friend ~= nil then
        self.btn_schaoyou.normalSprite = "schaoyou";
    else

        FixedUpdateBeat:Add(self.UpTime, self)
    end

end

function FriendRightBtsBarControll:UpTime()


    self.btn_schaoyou.normalSprite = "addFriendBt";
    FixedUpdateBeat:Remove(self.UpTime, self)
end


function FriendRightBtsBarControll:_OnClickbtn_chakan()

    ModuleManager.SendNotification(OtherInfoNotes.OPEN_INFO_PANEL, self.curr_fdata.id);

end

function FriendRightBtsBarControll:_OnClickbtn_yqzudui()

    if FriendDataManager.currSelectTarget ~= nil then
        FriendProxy.TryInviteToTeam(FriendDataManager.currSelectTarget.id,FriendDataManager.currSelectTarget.name);
    end
    
end

function FriendRightBtsBarControll:_OnClickbtn_yqruzong()
    GuildDataManager.InvitatePlayer(self.curr_fdata.id);
end

function FriendRightBtsBarControll:_OnClickbtn_schaoyou()

    if FriendDataManager.currSelectTarget ~= nil then

        local type = FriendDataManager.currSelectTarget.type;

        self.currSelect = FriendDataManager.currSelectTarget;
        local id = FriendDataManager.currSelectTarget.id;
        local fd = FriendDataManager.GetFriend(id);

        if fd ~= nil then

          self.currSelect = fd;

            ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                title = LanguageMgr.Get("common/notice"),
                msg = LanguageMgr.Get("friend/FriendRightBtsBarControll/removeFriendTip",{ n = FriendDataManager.currSelectTarget.name }),
                ok_Label = LanguageMgr.Get("common/ok"),
                cance_lLabel = LanguageMgr.Get("common/cancle"),
                hander = FriendRightBtsBarControll.SureToRemoveFriend,
                data = nil,
                target = self
            } );
        else
            -- 添加好友
            AddFriendsProxy.TryAddFriend(FriendDataManager.currSelectTarget.id, nil)
        end

    end

end


function FriendRightBtsBarControll:SureToRemoveFriend()
    local tid = self.currSelect.tid;
    local name = self.currSelect.name;

    FriendProxy.TryRemoveFriend(tid, name);
end


function FriendRightBtsBarControll:Dispose()

    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_SELECTED, FriendRightBtsBarControll.FriendListItemSelected)


    UIUtil.GetComponent(self.btn_chakan, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.btn_yqzudui, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.btn_yqruzong, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.btn_schaoyou, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._onClickbtn_chakan = nil;
    self._onClickbtn_yqzudui = nil;
    self._onClickbtn_yqruzong = nil;
    self._onClickbtn_schaoyou = nil;

     self.gameObject =nil;

    self.btn_chakan = nil;
    self.btn_yqzudui = nil;
    self.btn_yqruzong = nil;
    self.btn_schaoyou = nil;
    self.btn_schaoyouIcon = nil;

end
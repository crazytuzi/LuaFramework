require "Core.Module.Common.UIItem"

GuildListJoinItem = UIItem:New();

function GuildListJoinItem:_Init()
    
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtLv = UIUtil.GetChildByName(self.transform, "UILabel", "txtLv");
    self._txtLeader = UIUtil.GetChildByName(self.transform, "UILabel", "txtLeader");
    self._icoLeader = UIUtil.GetChildByName(self.transform, "UISprite", "icoLeader");
    self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "txtNum");
    self._txtJoin = UIUtil.GetChildByName(self.transform, "UILabel", "txtJoin");
    
    self._btnJoin = UIUtil.GetChildByName(self.transform, "UIButton", "btnJoin");

    self._icoVip = UIUtil.GetChildByName(self.gameObject, "UISprite", "icoVip");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self._onClickJoinBtn = function(go) self:_OnClickJoinBtn(self) end
    UIUtil.GetComponent(self._btnJoin, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickJoinBtn);

    self:UpdateItem(self.data);
end

function GuildListJoinItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    UIUtil.GetComponent(self._btnJoin, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickJoinBtn = nil;
end

function GuildListJoinItem:UpdateItem(data)
    self.data = data;
    
    if data then
        self._txtRank.text = data.rank;
        self._txtName.text = data.name;
        self._txtLv.text = data.level;
        self._txtLeader.text = data.leader;
        self._icoLeader.spriteName = "c" .. data.leaderKind;

        local cfg = ConfigManager.GetGuildLevelConfig(data.level);
        local max = cfg.number;
        self._txtNum.text = LanguageMgr.Get("common/numMax", {num = data.num, max = max});

        --self._icoVip.spriteName = VIPManager.GetVipIconByVip(data.leaderVip);
        self._icoVip.spriteName = ""
	    local vc = ColorDataManager.Get_Vip(data.leaderVip)
	    self._txtLeader.text = vc .. self._txtLeader.text

        self:UpdateStatus();
    else
        self._txtRank.text = "";
        self._txtName.text = "";
        self._txtLv.text = "";
        self._txtLeader.text = "";
        self._icoLeader.spriteName = "";
        self._txtNum.text = "";
        self._txtJoin.gameObject:SetActive(false);
        self._btnJoin.gameObject:SetActive(false);

        self._icoVip.spriteName = "";
    end
end

function GuildListJoinItem:SetStatus(id, st)
    if self.data and self.data.id == id and self.data.status ~= st then
        self.data.status = st;
        self:UpdateStatus();
    end
end

function GuildListJoinItem:UpdateStatus()
    local isReq = self.data.status == GuildInfo.Status.REQ;
    self._txtJoin.gameObject:SetActive(isReq == true);
    self._btnJoin.gameObject:SetActive(isReq == false);
end

function GuildListJoinItem:_OnClickBtn()
    ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_DETAIL_PANEL, self.data);
end

function GuildListJoinItem:_OnClickJoinBtn()
    SequenceManager.TriggerEvent(SequenceEventType.Guide.GUILD_REQ_JOIN);
    GuildProxy.ReqJoin(self.data.id);
end


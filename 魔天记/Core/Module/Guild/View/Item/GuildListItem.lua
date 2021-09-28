require "Core.Module.Common.UIItem"

GuildListItem = UIItem:New();

function GuildListItem:_Init()
    
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtLv = UIUtil.GetChildByName(self.transform, "UILabel", "txtLv");
    self._txtLeader = UIUtil.GetChildByName(self.transform, "UILabel", "txtLeader");
    self._icoLeader = UIUtil.GetChildByName(self.transform, "UISprite", "icoLeader");
    self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "txtNum");
    
    self._btnView = UIUtil.GetChildByName(self.transform, "UIButton", "btnView");

    self._icoVip = UIUtil.GetChildByName(self.gameObject, "UISprite", "icoVip");

    self._onClickViewBtn = function(go) self:_OnClickViewBtn(self) end
    UIUtil.GetComponent(self._btnView, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickViewBtn);

    self:UpdateItem(self.data);
end

function GuildListItem:_Dispose()

    UIUtil.GetComponent(self._btnView, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickViewBtn = nil;
end

function GuildListItem:UpdateItem(data)
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


function GuildListItem:_OnClickViewBtn()
    ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_DETAIL_PANEL, self.data);
end



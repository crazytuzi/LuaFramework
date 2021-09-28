require "Core.Module.Common.Panel";

GuildDetailPanel = Panel:New();

function GuildDetailPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function GuildDetailPanel:_InitReference()
    self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
    self._txtLeader = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleLeader/txtLeader");
    self._txtId = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleId/txtId");
    self._txtLevel = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleLevel/txtLevel");
    self._txtNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleNum/txtNum");
    self._txtFight = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleFight/txtFight");
    self._txtMoney = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleMoney/txtMoney");
    self._txtRank = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleRank/txtRank");
    self._txtNotice = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtNotice");
    
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._btnContent = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnContent");
end

function GuildDetailPanel:_InitListener()
    self._onClickClose = function(go) self:_OnClickClose() end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickClose);

    self._onClickContent = function(go) self:_OnClickContent() end
	UIUtil.GetComponent(self._btnContent, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickContent);  
end

function GuildDetailPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildDetailPanel:_DisposeReference()
    
end

function GuildDetailPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickClose = nil;

    UIUtil.GetComponent(self._btnContent, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickContent = nil;
end


function GuildDetailPanel:_OnClickClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILD_DETAIL_PANEL);
end

function GuildDetailPanel:_OnClickContent()
    if self.data then
        if self.data.leaderId == PlayerManager.playerId then
            MsgUtils.ShowTips("friend/cannotTalkToSelf");
            return;
        end
        FriendDataManager.TryOpenCharUI(self.data.leaderId);
    end
end

function GuildDetailPanel:UpdateDisplay(data)
    self.data = data;
    if data then
        self._txtName.text = data.name;
        self._txtLeader.text = data.leader;
        self._txtId.text = data.id;
        self._txtLevel.text = data.level;

        local lvCfg = ConfigManager.GetGuildLevelConfig(data.level);
        self._txtNum.text = LanguageMgr.Get("common/numMax", {num = data.num, max = lvCfg.number});
        self._txtFight.text = data.fight;
        self._txtMoney.text = data.money;
        self._txtRank.text = data.rank;
        self._txtNotice.text = data.notice;
    else
        self._txtName.text = "";
        self._txtLeader.text = "";
        self._txtId.text = "";
        self._txtLevel.text = "";
        self._txtNum.text = "";
        self._txtFight.text = "";
        self._txtMoney.text = "";
        self._txtRank.text = "";
        self._txtNotice.text = "";
    end
end
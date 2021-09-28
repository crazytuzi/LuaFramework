require "Core.Module.Common.Panel";
require "Core.Module.Guild.View.Item.GuildHelpListItem"

GuildHelpListPanel = Panel:New();

function GuildHelpListPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function GuildHelpListPanel:_InitReference()
    
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");


    self._txtCount = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtCount");
    self._txtGold = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtGold");

    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildHelpListItem);
    
end

function GuildHelpListPanel:_InitListener()
    
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_TASK_HELPLIST, GuildHelpListPanel.UpdateInfo, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_HELP_COLLECTITEM, GuildHelpListPanel.UpdateOpt, self);
    MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, GuildHelpListPanel.UpdateGold, self);

end

function GuildHelpListPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildHelpListPanel:_DisposeReference()
    self._phalanx:Dispose();
end

function GuildHelpListPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_TASK_HELPLIST, GuildHelpListPanel.UpdateInfo);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_HELP_COLLECTITEM, GuildHelpListPanel.UpdateOpt);
    MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, GuildHelpListPanel.UpdateGold);
end

function GuildHelpListPanel:_Opened()
	--self._txtDesc.text = LanguageMgr.Get("guild/desc");
	--self:UpdateInfo();
    --self:UpdateList();
    self.data = nil;
    self.num = 0;
    TaskProxy.ReqTaskHelpList();
end

function GuildHelpListPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILD_OTHER_PANEL, GuildNotes.OTHER.HELPLIST);
    MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_REFRESH);
end

function GuildHelpListPanel:UpdateInfo(data)
    self.data = data.l;
    self.num = data.hn;
    self:UpdateDisplay();
end

function GuildHelpListPanel:UpdateOpt(data)
    if self.data and #self.data > 1 then
        for i=#self.data, 1,-1 do
            if self.data[i].id == data.id and self.data[i].pi == data.pi then
                table.remove(self.data, i);
            end
        end
    else
        self.data = {};
    end
    self.num = data.hn;
    self:UpdateDisplay();
end

function GuildHelpListPanel:UpdateDisplay()
    local count = #self.data;
    self._phalanx:Build(count, 1, self.data);
    if self.num < 5 then 
        self._txtCount.text = LanguageMgr.GetColor("g", LanguageMgr.Get("common/numMax", {num = 5 - self.num, max = 5}));
    else
        self._txtCount.text = LanguageMgr.GetColor("r", LanguageMgr.Get("common/numMax", {num = 5 - self.num, max = 5}));
    end
    self:UpdateGold();
end

function GuildHelpListPanel:UpdateGold()
    self._txtGold.text = MoneyDataManager.Get_bgold();
end
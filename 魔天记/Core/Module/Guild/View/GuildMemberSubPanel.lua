require "Core.Module.Common.UISubPanel";
require "Core.Module.Guild.View.Item.GuildInfoMemberItem";

GuildMemberSubPanel = class("GuildMemberSubPanel", UISubPanel);

GuildMemberSubPanel.SortType = {
    LV = 2;
    IDENTITY = 3;
    DKPDAY = 4;
    DKPALL = 5;
    TIME = 6;
}
local _sortfunc = table.sort 

function GuildMemberSubPanel:_InitReference()
    
    
    self._btnGuildQuit = UIUtil.GetChildByName(self._transform, "UIButton", "btnGuildQuit");
    self._btnSendNotice = UIUtil.GetChildByName(self._transform, "UIButton", "btnSendNotice");
    self._btnGuildLog = UIUtil.GetChildByName(self._transform, "UIButton", "btnGuildLog");
    self._btnGuildVerify = UIUtil.GetChildByName(self._transform, "UIButton", "btnGuildVerify");
    
    self._btnSendNotice.gameObject:SetActive(false);

    self._txtNum = UIUtil.GetChildByName(self._transform, "UILabel", "titleNum/txtNum");

    self._rpGuildVerify = UIUtil.GetChildByName(self._btnGuildVerify, "UISprite", "redPoint");
    self._rpGuildVerify.gameObject:SetActive(false);

    self._txtBtnQuit = UIUtil.GetChildByName(self._btnGuildQuit, "UILabel", "txtBtnQuit");

    
    self._onClickBtnQuit = function(go) self:_OnClickBtnQuit() end
	UIUtil.GetComponent(self._btnGuildQuit, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnQuit);
    self._onClickBtnSendNotice = function(go) self:_OnClickBtnSendNotice() end
    UIUtil.GetComponent(self._btnSendNotice, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSendNotice);
    
    self._onClickBtnGuildLog = function(go) self:_OnClickBtnGuildLog() end
	UIUtil.GetComponent(self._btnGuildLog, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGuildLog);
    self._onClickBtnVerify = function(go) self:_OnClickBtnVerify() end
	UIUtil.GetComponent(self._btnGuildVerify, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnVerify);

    self._icoSortDict = {};
    self._trsTitle = UIUtil.GetChildByName(self._transform, "Transform", "trsTitle");
    self._onClickSortBtn = function(go) self:_OnClickSortBtn(go) end
    for i = 2, 6 do
        local tmpBg = UIUtil.GetChildByName(self._trsTitle, "UISprite", "bg".. i);
        local icoSort = UIUtil.GetChildByName(tmpBg, "Transform", "icoSelBg/icoSel");
        self._icoSortDict[i] = icoSort;
        UIUtil.GetComponent(tmpBg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickSortBtn);
        self["_bg" .. i] = tmpBg;
    end
    
    self._trsList = UIUtil.GetChildByName(self._transform, "Transform", "trsList");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx", true);
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildInfoMemberItem);
end

function GuildMemberSubPanel:_DisposeReference()
    
    UIUtil.GetComponent(self._btnGuildQuit, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnQuit = nil;
    UIUtil.GetComponent(self._btnSendNotice, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnSendNotice = nil;
    
    UIUtil.GetComponent(self._btnGuildLog, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGuildLog = nil;
    UIUtil.GetComponent(self._btnGuildVerify, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnVerify = nil;

    for i = 2, 6 do
        UIUtil.GetComponent(self["_bg" .. i], "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    self._onClickSortBtn = nil;

    self._phalanx:Dispose();
end

function GuildMemberSubPanel:_InitListener()
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_MEMBERS, GuildMemberSubPanel.UpdateMember, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.ENV_GUILD_MEMBERS_CHG, GuildMemberSubPanel._OnMemberChg, self);
    
end

function GuildMemberSubPanel:_DisposeListener()
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_MEMBERS, GuildMemberSubPanel.UpdateMember);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_GUILD_MEMBERS_CHG, GuildMemberSubPanel._OnMemberChg);
end

function GuildMemberSubPanel:_OnEnable()
    self._sortType = nil;
    self._sortAsc = false;
    GuildProxy.ReqMember();

    self:UpdateDisplay();
end

function GuildMemberSubPanel:_OnMemberChg()
    --如果有新成员加入. 则刷新成员列表.
    GuildProxy.ReqMember();
end

function GuildMemberSubPanel:_Refresh()
    GuildProxy.ReqMember();
end

function GuildMemberSubPanel:UpdateDisplay()
    
end

function GuildMemberSubPanel:UpdateMember(data)
    local d = GuildDataManager.data;

    self.data = data;
    if #data <= 1 then
        self._txtBtnQuit.text = LanguageMgr.Get("guild/quit/1");
    else
        self._txtBtnQuit.text = LanguageMgr.Get("guild/quit/0");
    end
    --self:UpdateList();
    if self._sortType == nil then
        self:SortAndShow(GuildMemberSubPanel.SortType.IDENTITY);
    else
        self:SortAndShow(self._sortType);
    end
    
    local lvCfg = ConfigManager.GetGuildLevelConfig(d.level);
    self._txtNum.text = #self.data .. "/" .. lvCfg.number;

    self._rpGuildVerify.gameObject:SetActive(GuildDataManager.GetGrant(GuildDataManager.opt.approve) and GuildDataManager.reqVertifyNum > 0);

    self._btnSendNotice.gameObject:SetActive(GuildDataManager.GetGrant(GuildDataManager.opt.recruit));
end

function GuildMemberSubPanel:UpdateList()
    local count = #self.data;
    self._phalanx:Build(count, 1, self.data);
end

function GuildMemberSubPanel:_OnClickSortBtn(go)
    local st = nil;
    if go.name == "bg2" then
        st = GuildMemberSubPanel.SortType.LV;
    elseif go.name == "bg3" then
        st = GuildMemberSubPanel.SortType.IDENTITY;
    elseif go.name == "bg4" then
        st = GuildMemberSubPanel.SortType.DKPDAY;
    elseif go.name == "bg5" then
        st = GuildMemberSubPanel.SortType.DKPALL;
    elseif go.name == "bg6" then
        st = GuildMemberSubPanel.SortType.TIME;
    end
    if self._sortType ~=  st then
        self._sortAsc = false;
        self:SortAndShow(st);
    else
        self._sortAsc = not self._sortAsc;
        self:SortByAsc();
    end
end

function GuildMemberSubPanel:SortAndShow(st)
    self._sortType = st;
    for k, v in pairs(self._icoSortDict) do
        v.gameObject:SetActive(k == st);
    end
    local sortFun = nil;
    
    if st == GuildMemberSubPanel.SortType.LV then
        sortFun = GuildMemberSubPanel.SortByLevel;
    elseif st == GuildMemberSubPanel.SortType.IDENTITY then
        sortFun = GuildMemberSubPanel.SortByIdentity;
    elseif st == GuildMemberSubPanel.SortType.DKPDAY then
        sortFun = GuildMemberSubPanel.SortByDkpDay;
    elseif st == GuildMemberSubPanel.SortType.DKPALL then
        sortFun = GuildMemberSubPanel.SortByDkpAll;
    elseif st == GuildMemberSubPanel.SortType.TIME then
        sortFun = GuildMemberSubPanel.SortByTime;
    end
    if sortFun then
        _sortfunc(self.data, sortFun);

        if self._sortAsc then
            self:SortByAsc();
        else
            self:UpdateList();
        end
    end
end

function GuildMemberSubPanel:SortByAsc()
    local tmp = {};
    for i = 1, #self.data do  
        tmp[i] = table.remove(self.data)  
    end
    self.data = tmp;
    self:UpdateList();
end

function GuildMemberSubPanel:_OnClickBtnQuit()
    local identity = GuildDataManager.GetMyIdentity();
    local count = self.data and #self.data or 0;
    if identity == GuildInfo.Identity.Leader then
        if count > 1 then
            MsgUtils.ShowTips("error/guild/LeaderCannotQuit");            
        else
            MsgUtils.ShowConfirm(self, "guild/msg/dissolve", GuildDataManager.GetMyGuildData(), GuildMemberSubPanel.ConfirmQuit);
        end
    else
        MsgUtils.ShowConfirm(self, "guild/msg/quit", GuildDataManager.GetMyGuildData(), GuildMemberSubPanel.ConfirmQuit);
    end
end

function GuildMemberSubPanel:_OnClickBtnSendNotice()
    GuildProxy.ReqSendJoinNotice();
end

function GuildMemberSubPanel:_OnClickBtnGuildLog()
    ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_LOG_PANEL);
end

function GuildMemberSubPanel:_OnClickBtnVerify()
    ModuleManager.SendNotification(GuildNotes.OPEN_GUILDVERIFYPANEL);
end

function GuildMemberSubPanel:ConfirmQuit()
    GuildProxy.ReqQuit();
end

function GuildMemberSubPanel.SortByLevel(a,b)
    if a.level == b.level then
        return a.joinTime < b.joinTime;
    end
    return a.level > b.level;
end

function GuildMemberSubPanel.SortByIdentity(a,b)
    if a.identity == b.identity then
        return a.joinTime < b.joinTime;
    end
    return a.identity < b.identity;
end

function GuildMemberSubPanel.SortByDkpDay(a,b)
    if a.dkpDay == b.dkpDay then
        return a.joinTime < b.joinTime;
    end
    return a.dkpDay > b.dkpDay;
end

function GuildMemberSubPanel.SortByDkpAll(a,b)
    if a.dkpAll == b.dkpAll then
        return a.joinTime < b.joinTime;
    end
    return a.dkpAll > b.dkpAll;
end

function GuildMemberSubPanel.SortByTime(a,b)
    if a.onlineType == b.onlineType then
        if a.onlineType == 1 then
            if a.identity == b.identity then
                return a.joinTime < b.joinTime;
            end
            return a.identity > b.identity;
        else
            return a.offlineTime < b.offlineTime;
        end
    end
    return a.onlineType > b.onlineType;
end






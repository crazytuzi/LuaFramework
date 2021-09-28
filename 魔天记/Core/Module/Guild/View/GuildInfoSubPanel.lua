require "Core.Module.Common.UISubPanel";
require "Core.Module.Guild.View.GuildInfoSubDetail";
require "Core.Module.Guild.View.Item.GuildInfoOLMemberItem";

GuildInfoSubPanel = class("GuildInfoSubPanel", UISubPanel);
local _sortfunc = table.sort

function GuildInfoSubPanel:_InitReference()

    self._trsInfo = UIUtil.GetChildByName(self._transform, "Transform", "trsInfo");
    self._txtLeader = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleLeader/txtLeader");
    self._txtLevel = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleLevel/txtLevel");
    self._txtExp = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleExp/txtExp");
    self._sliderExp = UIUtil.GetChildByName(self._trsInfo, "UISlider", "titleExp/sliderExp");
    self._txtMoney = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleMoney/txtMoney");
    self._txtTodayRepair = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleTodayRepair/txtTodayRepair");
    self._inputNotice = UIUtil.GetChildByName(self._trsInfo, "UIInput", "inputNotice");
    self._inputNotice.selectAllTextOnFocus = false;

    self._btnGuildList = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnGuildList");
    -- self._btnTaskHelp = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnTaskHelp");
    -- self._rpTaskHelp = UIUtil.GetChildByName(self._btnTaskHelp, "UISprite", "redPoint");
    -- self._rpTaskHelp.gameObject:SetActive(false);

    self._onClickBtnList = function(go) self:_OnClickBtnList() end
    UIUtil.GetComponent(self._btnGuildList, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnList);
    -- self._onClickBtnTaskHelp = function(go) self:_OnClickBtnTaskHelp() end
    -- UIUtil.GetComponent(self._btnTaskHelp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTaskHelp);

    -- self._inputBox = UIUtil.GetChildByName(self._trsInfo, "BoxCollider", "inputNotice");
    self._txtOnlineNum = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleOnlineNum/txtOnlineNum");
    -- self._txtMyDkp = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleMyDkp/txtMyDkp");
    self._inputNoticeChgCallBack = EventDelegate.Callback( function() self:_OnInputNoticeChg() end)
    EventDelegate.Add(self._inputNotice.onChange, self._inputNoticeChgCallBack);

    self._btnModNotice = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnModNotice");
    self._onClickModNotice = function(go) self:_OnClickModNotice(self) end
    UIUtil.GetComponent(self._btnModNotice, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickModNotice);

    self._btnSaveNotice = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnSaveNotice");
    self._onClickSaveNotice = function(go) self:_OnClickSaveNotice(self) end
    UIUtil.GetComponent(self._btnSaveNotice, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickSaveNotice);

    self._btnFram = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnFram");
    self._onClickBtnFram = function(go) self:_OnClickBtnFram(self) end
    UIUtil.GetComponent(self._btnFram, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFram);

    self._btnDetail = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnDetail");
    self._onClickBtnDetail = function(go) self:_OnClickBtnDetail(self) end
    UIUtil.GetComponent(self._btnDetail, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnDetail);

    self._btnEnemy = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnEnemy");
    self._onClickBtnEnemy = function(go) self:_OnClickBtnEnemy(self) end
    UIUtil.GetComponent(self._btnEnemy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnEnemy);

    self._btnHongBao = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnHongBao");
    self._goHongBaoTip = UIUtil.GetChildByName(self._btnHongBao, "tip").gameObject;

    self._onClickBtnHongBao = function(go) self:_OnClickBtnHongBao(self) end
    UIUtil.GetComponent(self._btnHongBao, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnHongBao);


    self.btnTuoJiExp = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnTuoJiExp");
    self.btnTuoJiExpTip = UIUtil.GetChildByName(self.btnTuoJiExp, "tip").gameObject;

    self._onClickBtnTuoJiExp = function(go) self:_OnClickBtnTuoJiExp(self) end
    UIUtil.GetComponent(self.btnTuoJiExp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTuoJiExp);



    self._trsList = UIUtil.GetChildByName(self._transform, "Transform", "trsList");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx", true);
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildInfoOLMemberItem);

    self._trsDetail = UIUtil.GetChildByName(self._transform, "Transform", "trsPop/trsDetail");
    self._detailPanel = GuildInfoSubDetail.New();
    self._detailPanel:Init(self._trsDetail);
    self._detailPanel:Disable();
end

function GuildInfoSubPanel:_DisposeReference()
    self._phalanx:Dispose();
    self._detailPanel:Dispose();

    UIUtil.GetComponent(self._btnGuildList, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnList = nil;
    -- UIUtil.GetComponent(self._btnTaskHelp, "LuaUIEventListener"):RemoveDelegate("OnClick");
    -- self._onClickBtnTaskHelp = nil;

    UIUtil.GetComponent(self._btnModNotice, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickModNotice = nil;
    UIUtil.GetComponent(self._btnSaveNotice, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickSaveNotice = nil;
    UIUtil.GetComponent(self._btnFram, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnFram = nil;
    UIUtil.GetComponent(self._btnDetail, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnDetail = nil;
    UIUtil.GetComponent(self._btnEnemy, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnEnemy = nil;
    UIUtil.GetComponent(self._btnHongBao, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnHongBao = nil;

    UIUtil.GetComponent(self.btnTuoJiExp, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTuoJiExp = nil;



    EventDelegate.Remove(self._inputNotice.onChange, self._inputNoticeChgCallBack);
    self:UpdateTuoJiExp();
end

function GuildInfoSubPanel:_InitListener()
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_INFO, GuildInfoSubPanel.UpdateDisplay, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_MEMBERS, GuildInfoSubPanel.UpdateMember, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_NOTICE, GuildInfoSubPanel.UpdateNotice, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_NTF_LEVELUP, GuildInfoSubPanel.OnLevelUp, self);
    MessageManager.AddListener(GuildDataManager, GuildDataManager.HONGBAOREDPOINT, GuildInfoSubPanel.SetGuideInfoRedPoint, self)
    MessageManager.AddListener(GuildNotes, GuildNotes.TFEC_ENV_CHG, GuildInfoSubPanel.UpdateTuoJiExp, self)


end

function GuildInfoSubPanel:_DisposeListener()
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_INFO, GuildInfoSubPanel.UpdateDisplay);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_MEMBERS, GuildInfoSubPanel.UpdateMember);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_NOTICE, GuildInfoSubPanel.UpdateNotice);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_NTF_LEVELUP, GuildInfoSubPanel.OnLevelUp);
    MessageManager.RemoveListener(GuildDataManager, GuildDataManager.HONGBAOREDPOINT, GuildInfoSubPanel.SetGuideInfoRedPoint, self)
    MessageManager.RemoveListener(GuildNotes, GuildNotes.TFEC_ENV_CHG, GuildInfoSubPanel.UpdateTuoJiExp, self)

end

function GuildInfoSubPanel:SetGuideInfoRedPoint()
    self._goHongBaoTip:SetActive(GuildDataManager.GetGuideHongBaoRedPoint())
end

function GuildInfoSubPanel:_OnEnable()
    GuildProxy.ReqInfo();
    GuildProxy.ReqMember();
end

function GuildInfoSubPanel:_Refresh()
    GuildProxy.ReqInfo();
    GuildProxy.ReqMember();
end

function GuildInfoSubPanel:UpdateDisplay()
    self:SetGuideInfoRedPoint()
    local data = GuildDataManager.data;
    local info = GuildDataManager.info;
    self._txtLeader.text = data.leader;
    self._txtLevel.text = GetLvDes1(data.level);

    -- self._rpTaskHelp.gameObject:SetActive(data.helpNum > 0);

    local nextLvCfg = ConfigManager.GetGuildLevelConfig(data.level + 1);
    local lvCfg = ConfigManager.GetGuildLevelConfig(data.level);
    if nextLvCfg then
        local max = lvCfg.exp;
        local cur = data.exp;
        self._txtExp.text = LanguageMgr.Get("common/numMax", { num = cur, max = max });
        self._sliderExp.value = cur / max;
    else
        self._txtExp.text = LanguageMgr.Get("guild/lvMax");
        self._sliderExp.value = 1;
    end

    self._txtMoney.text = data.money;
    self._txtTodayRepair.text = lvCfg.maintenance_und;
    self._inputNotice.value = data.notice;
    self._btnSaveNotice.gameObject:SetActive(false);

    -- self._txtMyDkp.text = info.dkpAll - info.dkpUse;
    local grant = GuildDataManager.GetGrant(GuildDataManager.opt.notice);
    self._btnModNotice.gameObject:SetActive(grant)
    -- self._inputBox.enabled = grant;

    self:UpdateTuoJiExp()
end

function GuildInfoSubPanel:UpdateTuoJiExp()
    local n = GuildDataManager.Get_tfec();

    if n == 0 then
        self.btnTuoJiExpTip.gameObject:SetActive(true);
    else
        self.btnTuoJiExpTip.gameObject:SetActive(false);
    end

end

function GuildInfoSubPanel:UpdateMember(data)
    for i = #data, 1, -1 do
        local v = data[i];
        if v:IsOnline() == false then
            table.remove(data, i);
        end
    end

    _sortfunc(data, function(a, b)
        if a.id == PlayerManager.playerId then
            return true;
        elseif b.id == PlayerManager.playerId then
            return false;
        end
        if a.identity == b.identity then
            return a.dkpDay > b.dkpDay;
        end
        return a.identity < b.identity;
    end );

    local count = #data;
    self._txtOnlineNum.text = count;
    self._phalanx:Build(count, 1, data);
end

function GuildInfoSubPanel:UpdateNotice(data)
    self._inputNotice.value = data;
    self._btnSaveNotice.gameObject:SetActive(false);
end

function GuildInfoSubPanel:OnLevelUp()
    GuildProxy.ReqInfo();
end

function GuildInfoSubPanel:_OnClickBtnList()
    ModuleManager.SendNotification(GuildNotes.OPEN_GUILDLISTPANEL);
end

--[[
function GuildInfoSubPanel:_OnClickBtnTaskHelp()
	ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_OTHER_PANEL, GuildNotes.OTHER.HELPLIST);
end
]]

function GuildInfoSubPanel:_OnInputNoticeChg()
    self._btnSaveNotice.gameObject:SetActive(true);
end

function GuildInfoSubPanel:_OnClickModNotice()
    -- local str = self._inputNotice.value;
    -- GuildProxy.ReqSetNotice(str);
    self._inputNotice.isSelected = true;
end

function GuildInfoSubPanel:_OnClickSaveNotice()
    local str = self._inputNotice.value;
    GuildProxy.ReqSetNotice(str);
end

function GuildInfoSubPanel:_OnClickBtnFram()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDPANEL);
    GuildProxy.ReqEnterZone();
end

function GuildInfoSubPanel:_OnClickBtnDetail()
    self._detailPanel:Enable();
end

function GuildInfoSubPanel:_OnClickBtnEnemy()
    ModuleManager.SendNotification(GuildNotes.OPEN_GUILDENEMYPANEL);
end

function GuildInfoSubPanel:_OnClickBtnHongBao()
    ModuleManager.SendNotification(GuildNotes.OPEN_GUILDHONGBAOPANEL);
end

function GuildInfoSubPanel:_OnClickBtnTuoJiExp()
    GuildProxy.Try_Get_TuoJi_ExpRes();
end
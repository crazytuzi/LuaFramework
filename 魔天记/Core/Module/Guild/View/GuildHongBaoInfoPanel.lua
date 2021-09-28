require "Core.Module.Common.Panel"
require "Core.Module.Guild.View.Item.GuildHBPlayerItem"

GuildHongBaoInfoPanel = class("GuildHongBaoInfoPanel", Panel);

local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_RED_PACKET);

function GuildHongBaoInfoPanel:New()
    self = { };
    setmetatable(self, { __index = GuildHongBaoInfoPanel });
    return self
end

function GuildHongBaoInfoPanel:GetUIOpenSoundName( )
    return UISoundManager.ui_gold
end

function GuildHongBaoInfoPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function GuildHongBaoInfoPanel:_OnClickMask()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDHONGBAOINFOPANEL);
end

function GuildHongBaoInfoPanel:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgIcon");
    self._txtLevel = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtLevel");
    self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
    self._txtTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTitle");
    self._txtMoney = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMoney");
    self._txtMoneyState = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMoneyState");
    self._txtInfo = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtInfo");
    self._txtState = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtState");
    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._scrollPanel = UIUtil.GetComponent(self._trsList, "UIPanel");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildHBPlayerItem);
end

function GuildHongBaoInfoPanel:_InitListener()

end

function GuildHongBaoInfoPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function GuildHongBaoInfoPanel:_DisposeListener()

end

function GuildHongBaoInfoPanel:_DisposeReference()
    self._imgIcon = nil;
    self._txtLevel = nil;
    self._txtName = nil;
    self._txtTitle = nil;
    self._txtMoney = nil;
    self._txtMoneyState = nil;
    self._txtInfo = nil;
    self._txtState = nil;
    self._trsList = nil;
    self._scrollView = nil;
    self._scrollPanel = nil;
    self._phalanx:Dispose();
    self._phalanx = nil;
end

function GuildHongBaoInfoPanel:SetData(data)
    local cfgItem = cfg[data.rptid];
    local myMoney = self:_FormatList(data.l);
    local len = table.getCount(data.l);
    self._data = data;
    self._imgIcon.spriteName = data.okind
    self._txtName.text = data.on
    self._txtLevel.text = data.olv
    self._txtTitle.text = cfgItem.name
    if (myMoney > 0) then
        self._txtMoney.text = myMoney;
        self._txtMoney.gameObject:SetActive(true)
        self._txtMoneyState.gameObject:SetActive(false)
    else
        self._txtMoney.gameObject:SetActive(false)
        self._txtMoneyState.gameObject:SetActive(true)        
    end

    self._txtInfo.text =  LanguageMgr.Get("GuildHongBaoInfoPanel/label1",{n1=data.num, n2=data.bgold}) ;
    if (data.num > len) then
        self._txtState.text = LanguageMgr.Get("GuildHongBaoInfoPanel/label2",{n1=(data.num - len)}) ; 
    else
        self._txtState.text =  LanguageMgr.Get("GuildHongBaoInfoPanel/label3") ;
    end
    self._phalanx:Build(len, 1, data.l)
    self._scrollView:ResetPosition();
end

function GuildHongBaoInfoPanel:_FormatList(list)
    local heroId = PlayerManager.hero.id;
    local money = 0;
    local max = 0;
    local curItem;
    for i, v in pairs(list) do
        if (v.bgold > max) then
            curItem = v
            max = v.bgold
        end
        if (v.pi == heroId) then
            money = v.bgold
        end
    end
    if (curItem) then
        curItem.best = true;
    end
    return money
end
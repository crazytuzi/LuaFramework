require "Core.Module.Common.Panel"
require "Core.Module.Common.CoinBar"
local StarSubSpite = require "Core.Module.Star.View.StarSubSpite"
local StarSubExChange = require "Core.Module.Star.View.StarSubExChange"
local StarSubUpgrade = require "Core.Module.Star.View.StarSubUpgrade"
local StarSubDivinatio = require "Core.Module.Star.View.StarSubDivinatio"


local StarPanel = class("StarPanel", Panel);

function StarPanel:New(trs)
    self = { };
    setmetatable(self, { __index = StarPanel });
    if trs then self:Init(trs) end
    return self
end


function StarPanel:_Init()
    self:_InitReference();
    self:_InitListener();

end

function StarPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btnStar = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnStar");
    self._btnSpite = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnSpite");
    self._btnExChange = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnExChange");
    self._btnDivination = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnDivination");
    self._btnHelp = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnHelp");
    self._helpPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "helpPanel");
    self._helpMask = UIUtil.GetChildByName(self._helpPanel, "Transform", "mask");
    self._txtHelp = UIUtil.GetChildByName(self._helpPanel, "UILabel", "txtHelp");
    self._txtHelp.text = LanguageMgr.Get("StarPanel/help")

    self._starTips = UIUtil.GetChildByName(self._btnStar, "UISprite", "imgTips");
    self._divinationTips = UIUtil.GetChildByName(self._btnDivination, "UISprite", "imgTips");

    self._trsStar = UIUtil.GetChildByName(self._trsContent, "Transform", "trsStar")
    self._trsSpite = UIUtil.GetChildByName(self._trsContent, "Transform", "trsSpite")
    self._trsExChange = UIUtil.GetChildByName(self._trsContent, "Transform", "trsExChange")
    self._trsDivination = UIUtil.GetChildByName(self._trsContent, "Transform", "trsDivinatio")

    self._coinBar = UIUtil.GetChildByName(self._trsContent, "Transform", "CoinBar")
    self._coinBarCtrl = CoinBar:New(self._coinBar)
    self._coinBarCtrl:SetGetFunc(StarManager.GetDebris, StarManager.GetCoin, nil)

    self._toggleStar = UIUtil.GetComponent(self._btnStar, "UIToggle");
    self._toggleSpite = UIUtil.GetComponent(self._btnSpite, "UIToggle");
    self._toggleExChange = UIUtil.GetComponent(self._btnExChange, "UIToggle")
    self._toggleDivination = UIUtil.GetComponent(self._btnDivination, "UIToggle")
    self._toggles = {self._toggleStar, self._toggleSpite, self._toggleExChange, self._toggleDivination};

    self._panels = { }
    self._panels[1] = StarSubUpgrade:New(self._trsStar)
    self._panels[2] = StarSubSpite:New(self._trsSpite)
    self._panels[3] = StarSubExChange:New(self._trsExChange)
    self._panels[4] = StarSubDivinatio:New(self._trsDivination)

	self._btnSpite.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.StarSplit))
    self._btnExChange.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.StarExchange))
    self._btnDivination.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.StarDivination))

end

function StarPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickbtnSpite = function(go) self:_OnClickbtnSpite(self) end
    UIUtil.GetComponent(self._btnSpite, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnSpite);
    self._onClickbtnStar = function(go) self:_OnClickbtnStar(self) end
    UIUtil.GetComponent(self._btnStar, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnStar);
    self._onClickbtnExChange = function(go) self:_OnClickbtnExChange(self) end
    UIUtil.GetComponent(self._btnExChange, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnExChange);
    self._onClickbtnDivination = function(go) self:_OnClickbtnDivination(self) end
    UIUtil.GetComponent(self._btnDivination, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnDivination);
    MessageManager.AddListener(StarNotes, StarNotes.STAR_DATA_CHANGE, StarPanel._UpdateTips, self)
    self._onClickbtnHelp = function(go) self:_OnClickbtnHelp(self) end
    UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnHelp);
    self._onClickhelpMask = function(go) self:_OnClickhelpMask(self) end
    UIUtil.GetComponent(self._helpMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickhelpMask);
end 

function StarPanel:SetOpenParam(p)
    self._openParam = p;
end

function StarPanel:_Opened()
    self:SelectPanel(self._openParam or 1);
    self:_UpdateTips()
end

function StarPanel:_OnClickbtnHelp()
    self._helpPanel.gameObject:SetActive(true)
end 

function StarPanel:_OnClickhelpMask()
    self._helpPanel.gameObject:SetActive(false)
end 

function StarPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(StarNotes.CLOSE_STAR_PANEL)
end 

function StarPanel:_OnClickbtnSpite()
    self:SelectPanel(2)
end

function StarPanel:_OnClickbtnStar()
    self:SelectPanel(1)
end

function StarPanel:_OnClickbtnExChange()
    self:SelectPanel(3)
end 

function StarPanel:_OnClickbtnDivination()
    self:SelectPanel(4)
end

function StarPanel:_UpdateTips()
    self._starTips.enabled = StarManager.HasStarUpgradeTips()
    self._divinationTips.enabled = StarManager.HasDivinationTips()
    self._coinBarCtrl:MoneyChange()
end

function StarPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    for i = 1, table.getCount(self._panels) do
        self._panels[i]:Dispose()
    end
    self._panels = nil
    self._coinBarCtrl:Dispose()
end

function StarPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btnSpite, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtnSpite = nil;
    UIUtil.GetComponent(self._btnStar, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtnStar = nil;
    UIUtil.GetComponent(self._btnExChange, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtnExChange = nil;
    UIUtil.GetComponent(self._btnDivination, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtnDivination = nil;
    MessageManager.RemoveListener(StarNotes, StarNotes.STAR_DATA_CHANGE, StarPanel._UpdateTips, self)
    UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtnHelp = nil;
    UIUtil.GetComponent(self._helpMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickhelpMask = nil;
end

function StarPanel:_DisposeReference()
    self._btn_close = nil;
    self._btnSpite = nil;
    self._btnStar = nil;
    self._btnExChange = nil;
end

function StarPanel:UpdateSubPanel()
    if (self._panels[self._panenIndex]) then
        self._panels[self._panenIndex]:UpdatePanel()
    end
end

function StarPanel:SelectPanel(to)
    for i = #self._panels, 1, -1 do
        --self._panels[i]:SetActive(i == to)
        self._panels[i]:SetEnable(i == to)
    end

    if(self._toggles[to]) then
        self._toggles[to].value = true
    end
    
    self._panenIndex = to
    self:UpdateSubPanel()
end

return StarPanel
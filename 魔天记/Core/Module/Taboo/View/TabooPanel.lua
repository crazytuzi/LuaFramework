require "Core.Module.Common.Panel"

local TabooPanel = class("TabooPanel",Panel);
function TabooPanel:New()
	self = { };
	setmetatable(self, { __index =TabooPanel });
	return self
end


function TabooPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    TabooProxy.GetTabooCollectNum()
end

function TabooPanel:_InitReference()
	self._txtdes1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtdes1");
	self._txtdes2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtdes2");
	self._txtdes3 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtdes3");
	self._txtNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtNum");
	self._txtTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTime");
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnClose = UIUtil.GetChildInComponents(btns, "btnClose");
	self._btnHelp = UIUtil.GetChildInComponents(btns, "btnHelp");
	self._btnGo = UIUtil.GetChildInComponents(btns, "btnGo");
	self._trsAwards = UIUtil.GetChildByName(self._trsContent, "Transform", "trsAwards");
	self._imgMap = UIUtil.GetChildByName(self._trsContent, "UITexture", "imgMap");
    self:_InitConfig()
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
end

function TabooPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	self._onClickBtnHelp = function(go) self:_OnClickBtnHelp(self) end
	UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnHelp);
	self._onClickBtnGo = function(go) self:_OnClickBtnGo(self) end
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGo);
    MessageManager.AddListener(TabooNotes, TabooNotes.TABOO_COLLECT_NUM, TabooPanel.SetCuurentNum, self)
	self._onClickbtn_close = function(go) self:_OnClickbtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_close);
end

function TabooPanel:_InitConfig()
    TabooProxy.InitConfig()
    self._txtdes1.text = LanguageMgr.Get("TabooPanel/des1")
    self._txtdes2.text = LanguageMgr.Get("TabooPanel/des2")
    self._txtdes3.text = LanguageMgr.Get("TabooPanel/des3")
    self._txtTime.text = TabooProxy.GetCollectInfoShow()
    self:_InitAwards()
    self:_InitMap()
end
function TabooPanel:_InitAwards()
    local as = TabooProxy.GetAwards()
    self.pis = ProductItems:New()
    self.pis:Init(self._trsAwards, as, 120, 120, 3)
end
function TabooPanel:_InitMap()
    self._mainTexturePath = "map/10015_03"
    self._imgMap.mainTexture = UIUtil.GetTexture(self._mainTexturePath)
end
function TabooPanel:SetCuurentNum(num)
    self._txtNum.text = TabooProxy.GetNumShow()
end

function TabooPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(TabooNotes.CLOSE_TABOO_PANEL)
end

function TabooPanel:_OnClickBtnHelp()
    if not self._helpPanel then
	    self._helpPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "helpPanel");
	    self._txtHelp = UIUtil.GetChildByName(self._helpPanel, "UILabel", "txtHelp");
        self._txtHelp.text = LanguageMgr.Get("TabooPanel/help")
    end
	self._helpPanel.gameObject:SetActive(true)
end

function TabooPanel:_OnClickBtnGo()    
	ModuleManager.SendNotification(TabooNotes.CLOSE_TABOO_PANEL)
    TabooProxy.GameStart()
end

function TabooPanel:_OnClickbtn_close()    
	self._helpPanel.gameObject:SetActive(false)
end

function TabooPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function TabooPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnHelp = nil;
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGo = nil;
    MessageManager.RemoveListener(TabooNotes, TabooNotes.TABOO_COLLECT_NUM, TabooPanel.SetCuurentNum)
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickbtn_close = nil;
end

function TabooPanel:_DisposeReference()
	self._btnClose = nil;
	self._btnHelp = nil;
	self._btnGo = nil;
	self._txtdes1 = nil;
	self._txtdes2 = nil;
	self._txtdes3 = nil;
	self._txtNum = nil;
	self._txtTime = nil;
	self._trsAwards = nil;
    self._imgMap = nil
    if self.pis then self.pis:Dispose() self.pis = nil end
    if self._mainTexturePath then
        UIUtil.RecycleTexture(self._mainTexturePath);
        self._mainTexturePath = nil;
    end
end
return TabooPanel
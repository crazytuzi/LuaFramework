require "Core.Module.Common.Panel"
require "Core.Module.Common.CoinBar"
require "Core.Module.Trump.View.Item.SubFusionPanel"
require "Core.Module.Trump.View.Item.SubTrumpRefinePanel"
require "Core.Module.Trump.View.Item.SubTrumpPanel"
require "Core.Module.Trump.View.Item.SubTrumpObtainPanel"


TrumpPanel = class("TrumpPanel", Panel);

function TrumpPanel:New()
    self = { };
    setmetatable(self, { __index = TrumpPanel });
    return self
end


function TrumpPanel:_Init()
    self:_InitReference();
    self:_InitListener();

end

function TrumpPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btnRefine = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnRefine");
    self._btnTrump = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnTrump");
    self._btnFusion = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnFusion");
    self._btnGetTrump = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGet");


    self._tsTrump = UIUtil.GetChildByName(self._trsContent, "tsTrump")
    self._tsFusion = UIUtil.GetChildByName(self._trsContent, "tsFusion")
    self._tsRefine = UIUtil.GetChildByName(self._trsContent, "tsRefine")
    self._tsGetTrump = UIUtil.GetChildByName(self._trsContent, "tsGetTrump")

    self._coinBar = UIUtil.GetChildByName(self._trsContent, "CoinBar")
    self._coinBarCtrl = CoinBar:New(self._coinBar)
    self._panels = { }
    self._panels[1] = SubTrumpPanel:New(self._tsTrump)
    self._panels[2] = SubFusionPanel:New(self._tsFusion)
    self._panels[3] = SubTrumpRefinePanel:New(self._tsRefine)
    self._panels[4] = SubTrumpObtainPanel:New(self._tsGetTrump)


    self._panenIndex = 1
    self:SelectPanel(self._panenIndex)    
end

function TrumpPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtnRefine = function(go) self:_OnClickBtnRefine(self) end
    UIUtil.GetComponent(self._btnRefine, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRefine);
    self._onClickBtnTrump = function(go) self:_OnClickBtnTrump(self) end
    UIUtil.GetComponent(self._btnTrump, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTrump);
    self._onClickBtnFusion = function(go) self:_OnClickBtnFusion(self) end
    UIUtil.GetComponent(self._btnFusion, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFusion);
    self._onClickBtnGetTrump = function(go) self:_OnClickBtnGetTrump(self) end
    UIUtil.GetComponent(self._btnGetTrump, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGetTrump);

end 

function TrumpPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(TrumpNotes.CLOSE_TRUMPPANEL)
end 

function TrumpPanel:_OnClickBtnRefine()
    self:SelectPanel(3)
end

function TrumpPanel:_OnClickBtnTrump()
    self:SelectPanel(1)
end

function TrumpPanel:_OnClickBtnFusion()
    self:SelectPanel(2)
end 

function TrumpPanel:_OnClickBtnGetTrump()
    self:SelectPanel(4)
end

function TrumpPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    for i = 1, table.getCount(self._panels) do
        self._panels[i]:Dispose()
    end
    self._panels = nil
    self._coinBarCtrl:Dispose()
end

function TrumpPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btnRefine, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnRefine = nil;
    UIUtil.GetComponent(self._btnTrump, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTrump = nil;
    UIUtil.GetComponent(self._btnFusion, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnFusion = nil;
    UIUtil.GetComponent(self._btnGetTrump, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGetTrump = nil;
end

function TrumpPanel:_DisposeReference()
    self._btn_close = nil;
    self._btnRefine = nil;
    self._btnTrump = nil;
    self._btnFusion = nil;
end

function TrumpPanel:UpdateTrumpSubPanel()
    if (self._panels[self._panenIndex]) then
        self._panels[self._panenIndex]:UpdatePanel()
    end
end

function TrumpPanel:SelectPanel(to)
    for i = 1, table.getCount(self._panels) do
        if i == to then
            self._panels[i]:SetActive(true)
        else
            self._panels[i]:SetActive(false)
        end
    end

    self._panenIndex = to
    self:UpdateTrumpSubPanel()
end

function TrumpPanel:UpdateSelectMaterial()
    self._panels[2]:UpdateSelectMaterial()
end

function TrumpPanel:UpdateSubPanelTrumpData(data)
    self._panels[2]:UpdateTrumpData(data)
end

function TrumpPanel:SetActiveSelectPanel()
    self._panels[2]:SetSelectPanelActive()
end

function TrumpPanel:UpdateSubRefinePanelTrumpData(data)
    self._panels[3]:UpdateTrumpData(data)
end

function TrumpPanel:SetObtainPanelSelectPanel()
    self._panels[4]:OnClickBtnQualitySelect()
end
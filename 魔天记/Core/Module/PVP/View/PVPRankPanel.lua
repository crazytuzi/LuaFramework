require "Core.Module.Common.Panel"
require "Core.Module.PVP.View.Item.PVPRankItem"


PVPRankPanel = class("PVPRankPanel", Panel);
PVPRankPanel.MAXRANKPAGECOUNT = 20 -- 最多显示的页数
function PVPRankPanel:New()
    self = { };
    setmetatable(self, { __index = PVPRankPanel });
    return self
end


function PVPRankPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self.index = 0
    self:SetBtnEnable()
    PVPProxy.SendGetPVPRank(self.index)
end

function PVPRankPanel:SetBtnEnable()
--    if (self.index == 0) then
--        self._btnLast.gameObject:SetActive(false)
--        self._btnNext.gameObject:SetActive(true)
--    elseif (self.index >= PVPRankPanel.MAXRANKPAGECOUNT) then
--        self._btnLast.gameObject:SetActive(true)
--        self._btnNext.gameObject:SetActive(false)
--    else
--        self._btnLast.gameObject:SetActive(true)
--        self._btnNext.gameObject:SetActive(true)
--    end
end

function PVPRankPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btnLast = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnLast");
    self._btnNext = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnNext");
    self._tsScrollView = UIUtil.GetChildByName(self._trsContent, "Scorview")
    self._scrollView = UIUtil.GetComponent(self._tsScrollView, "UIScrollView")
    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "Scorview/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, PVPRankItem)
    
    self._callBack = function() if(self._scrollView:RestrictWithinBounds(true)) then self:_OnClickBtnNext() end end;
    self._scrollView.onDragFinished = self._callBack

  end


function PVPRankPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
   

end

function PVPRankPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(PVPNotes.CLOSE_PVPRANKPANEL)
end

--function PVPRankPanel:_OnClickBtnLast()
--    self.index = math.clamp(self.index - 1, 0, PVPRankPanel.MAXRANKPAGECOUNT - 1)
--    PVPProxy.SendGetPVPRank(self.index)
--    self:SetBtnEnable()
--end

function PVPRankPanel:_OnClickBtnNext()
    if(self.index == PVPRankPanel.MAXRANKPAGECOUNT - 1) then return end
    self.index = math.clamp(self.index + 1, 0, PVPRankPanel.MAXRANKPAGECOUNT - 1)
    PVPProxy.SendGetPVPRank(self.index)
    self:SetBtnEnable()
end

function PVPRankPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    self._phalanx:Dispose()
    PVPManager.ResetPVPRankData()
end

function PVPRankPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
--    UIUtil.GetComponent(self._btnLast, "LuaUIEventListener"):RemoveDelegate("OnClick");
--    self._onClickBtnLast = nil;
--    UIUtil.GetComponent(self._btnNext, "LuaUIEventListener"):RemoveDelegate("OnClick");
--    self._onClickBtnNext = nil;
end

function PVPRankPanel:_DisposeReference()
    self._btn_close = nil;
    self._btnLast = nil;
    self._btnNext = nil;
    self._callBack = nil;
    self._scrollView.onDragFinished:Destroy();
end

function PVPRankPanel:UpdatePVPRankPanel()
    local data = PVPManager.GetPVPRankData()

    if (data) then
        self._phalanx:Build(table.getCount(data), 1, data)
    end
--    self._scrollView:ResetPosition()

end


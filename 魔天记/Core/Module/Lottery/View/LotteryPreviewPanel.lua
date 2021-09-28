require "Core.Module.Common.Panel"
require "Core.Module.Lottery.View.Item.LotteryRewardItem"

LotteryPreviewPanel = class("LotteryPreviewPanel", Panel);
function LotteryPreviewPanel:New()
    self = { };
    setmetatable(self, { __index = LotteryPreviewPanel });
    return self
end


function LotteryPreviewPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self:UpdatePanel()
end

function LotteryPreviewPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "Scorview/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, LotteryRewardItem)
end

function LotteryPreviewPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function LotteryPreviewPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(LotteryNotes.CLOSE_LOTTERYPREVIEWPANEL)
end

function LotteryPreviewPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    if (self._phalanx) then
        self._phalanx:Dispose()
        self._phalanx = nil
        self._phalanxInfo = nil
    end
end

function LotteryPreviewPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function LotteryPreviewPanel:_DisposeReference()
    self._btn_close = nil;
end

function LotteryPreviewPanel:UpdatePanel()
    local data = LotteryManager.GetLotteryShowReward()
    self._phalanx:Build(math.ceil(((table.getCount(data) -1) / 5) + 1), 5, data)
end

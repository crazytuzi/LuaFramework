require "Core.Module.Common.Panel"
require "Core.Module.FBResult.View.ResultPanel"

XLTFailResultPanel = class("XLTFailResultPanel", ResultPanel);
function XLTFailResultPanel:New()
    self = { };
    setmetatable(self, { __index = XLTFailResultPanel });
    self:_OnNew()
    return self
end


function XLTFailResultPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XLTFailResultPanel:_InitReference()
    self._btnok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnok");
    self._okbtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnok/Label");
    self.wbg = UIUtil.GetChildByName(self._trsContent, "UISprite", "wbg");

     UISoundManager.PlayUISound(UISoundManager.path_fb_fail);
end

function XLTFailResultPanel:_InitListener()
    self._onClickBtnok = function(go) self:_OnClickBtnok(self) end
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnok);
end

function XLTFailResultPanel:_Opened()
    self.ui_lose = UIUtil.GetUIEffect("ui_lose", self._trsContent, self.wbg, 1);

    self.ui_lose.transform.localScale = Vector3.New(360, 360, 360);

end

function XLTFailResultPanel:_OnClickBtnok()

    local tem = ConfigManager.Clone(self.oldScene);
    ModuleManager.SendNotification(FBResultNotes.CLOSE_XLTFAILRESULTPANEL);
    FBResultProxy.PlaySingleFbExit(tem)
end

function XLTFailResultPanel:SetData(data)
    self.oldScene = data.scene;

    self.djsTime = 10;
    self._okbtLabel.text = LanguageMgr.Get("common/ok") .. "(" .. self.djsTime .. ")";
    self._sec_timer = Timer.New( function()

        self.djsTime = self.djsTime - 1;
        self._okbtLabel.text = LanguageMgr.Get("common/ok") .. "(" .. self.djsTime .. ")";

        if self.djsTime <= 0 then
            if self._sec_timer ~= nil then
                self._sec_timer:Stop();
                self._sec_timer = nil;
            end
            self:_OnClickBtnok();
        end
    end , 1, self.djsTime, false);
    self._sec_timer:Start();

end

function XLTFailResultPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    self._btnok = nil;
    self._okbtLabel = nil;
    self.wbg = nil;

end

function XLTFailResultPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnok = nil;
end

function XLTFailResultPanel:_DisposeReference()
    self._btnok = nil;

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    if (self.ui_lose) then
        Resourcer.Recycle(self.ui_lose, false);
        self.ui_lose = nil;
    end
    self:_DisposeBase();

end

require "Core.Module.Common.Panel"
require "Core.Module.FBResult.View.ResultPanel"

EndlessTryResultPanel = class("EndlessTryResultPanel", ResultPanel);
function EndlessTryResultPanel:New()
    self = { };
    setmetatable(self, { __index = EndlessTryResultPanel });
    return self
end


function EndlessTryResultPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function EndlessTryResultPanel:_InitReference()
    self._btnok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnok");
    self._okbtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnok/Label");
    self.useTimeTxt = UIUtil.GetChildByName(self._trsContent, "UILabel", "useTimeTxt");
    self.txtKillNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtKillNum");
    self.txtExp = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtExp");
    self.wbg = UIUtil.GetChildByName(self._trsContent, "UISprite", "wbg");
    UISoundManager.PlayUISound(UISoundManager.path_fb_win);
end

function EndlessTryResultPanel:_InitListener()
    self._onClickBtnok = function(go) self:_OnClickBtnok(self) end
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnok);
end

function EndlessTryResultPanel:_Opened()
    self.ui_win_BG = UIUtil.GetUIEffect("ui_win_BG", self._trsContent, self.wbg, 1);
    self.ui_win = UIUtil.GetUIEffect("ui_win", self._trsContent, self.wbg, 2);
    self.ui_win_BG.transform.localScale = Vector3.New(360, 360, 360);
    self.ui_win.transform.localScale = Vector3.New(360, 360, 360);
end

function EndlessTryResultPanel:_OnClickBtnok()
    local tem = ConfigManager.Clone(self.oldScene);
    ModuleManager.SendNotification(FBResultNotes.CLOSE_INSPIRETRY_WIN_PANEL);
    -- 返回上一个地图
    FBResultProxy.PlaySingleFbExit(tem)
end

function EndlessTryResultPanel:SetData(data)
    self.oldScene = data.scene;
    self.useTimeTxt.text = LanguageMgr.Get("FBResult/SingleFBWinResultPanel/label1") .. GetTimeByStr(data.time)
    self.txtKillNum.text = LanguageMgr.Get("FBResult/EndlessTryResultPanel/killMonster", { n = data.kn })
    self.txtExp.text = data.exp

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


function EndlessTryResultPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function EndlessTryResultPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnok = nil;
end

function EndlessTryResultPanel:_DisposeReference()
    if (self.ui_win_BG) then
        Resourcer.Recycle(self.ui_win_BG, false);
        self.ui_win_BG = nil;
    end
    if (self.ui_win) then
        Resourcer.Recycle(self.ui_win, false);
        self.ui_win = nil;
    end
    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end
    self._btnok = nil;
    self._okbtLabel = nil;
    self.useTimeTxt = nil;
    self.txtKillNum = nil;
    self.txtExp = nil;
    self.wbg = nil;
end

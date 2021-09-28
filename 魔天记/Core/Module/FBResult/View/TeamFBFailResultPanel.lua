require "Core.Module.Common.Panel"
require "Core.Module.FBResult.View.ResultPanel"

TeamFBFailResultPanel = class("TeamFBFailResultPanel", ResultPanel);
function TeamFBFailResultPanel:New()
    self = { };
    setmetatable(self, { __index = TeamFBFailResultPanel });
    self:_OnNew()
    return self
end 

function TeamFBFailResultPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function TeamFBFailResultPanel:_InitReference()
    self._btnok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnok");

    self._okbtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnok/Label");
    self.wbg = UIUtil.GetChildByName(self._trsContent, "UISprite", "wbg");

     UISoundManager.PlayUISound(UISoundManager.path_fb_fail);
end

function TeamFBFailResultPanel:_InitListener()
    self._onClickBtnok = function(go) self:_OnClickBtnok(self) end
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnok);
end

function TeamFBFailResultPanel:_Opened()
    self.ui_lose = UIUtil.GetUIEffect("ui_lose", self._trsContent, self.wbg, 1);

    self.ui_lose.transform.localScale = Vector3.New(360, 360, 360);



end

function TeamFBFailResultPanel:_OnClickBtnok()

    local tem = ConfigManager.Clone(self.oldScene);
    FBResultProxy.PlaySingleFbExit(tem)
end

--[[
 local testData = {};
 testData.instId="750004";
 testData.fItems={ {am=2,spId=301003},{am=1000,spId=1},{am=1,spId=301004} };
 testData.star={5,2};
 testData.it=1;
 testData.time = 40;
 testData.items={ {am=2,spId=301003},{am=100,spId=4},{am=1000,spId=1} ,{am=1,spId=301004},{am=2,spId=301005} };
 testData.win = 0;
 testData.scene={x=-35,y=55,z=-955,sid="709999"};

 ModuleManager.SendNotification( FBResultNotes.OPEN_TEAMFBFAILRESULTPANEL, testData);
]]

function TeamFBFailResultPanel:SetData(data)

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

function TeamFBFailResultPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    self._btnok = nil;

    self._okbtLabel = nil;
    self.wbg = nil;


end

function TeamFBFailResultPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnok = nil;
end

function TeamFBFailResultPanel:_DisposeReference()
    self._btnok = nil;

    if (self.ui_lose) then
        Resourcer.Recycle(self.ui_lose, false);
        self.ui_lose = nil;
    end

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end
    self:_DisposeBase();
end

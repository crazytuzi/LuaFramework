require "Core.Module.Common.Panel"
require "Core.Module.FBResult.View.ResultPanel"

SingleFBFailResultPanel = class("SingleFBFailResultPanel", ResultPanel);
function SingleFBFailResultPanel:New()
    self = { };
    setmetatable(self, { __index = SingleFBFailResultPanel });
    self:_OnNew()
    return self
end

function SingleFBFailResultPanel:GetUIOpenSoundName()
    return ""
end

function SingleFBFailResultPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SingleFBFailResultPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btnReDo = UIUtil.GetChildInComponents(btns, "btnReDo");
    self._btnok = UIUtil.GetChildInComponents(btns, "btnok");
    self._okbtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnok/Label");
    self.wbg = UIUtil.GetChildByName(self._trsContent, "UISprite", "wbg");

     UISoundManager.PlayUISound(UISoundManager.path_fb_fail);
end

function SingleFBFailResultPanel:_InitListener()
    self._onClickBtnReDo = function(go) self:_OnClickBtnReDo(self) end
    UIUtil.GetComponent(self._btnReDo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReDo);
    self._onClickBtnok = function(go) self:_OnClickBtnok(self) end
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnok);


end

function SingleFBFailResultPanel:_Opened()
    self.ui_lose = UIUtil.GetUIEffect("ui_lose", self._trsContent, self.wbg, 1);

    self.ui_lose.transform.localScale = Vector3.New(360, 360, 360);

end

function SingleFBFailResultPanel:_OnClickBtnReDo()
    FBResultProxy.PlaySingleFbAgain()
end

function SingleFBFailResultPanel:_OnClickBtnok()

    -- 返回上一个地图
     local tem = ConfigManager.Clone(self.oldScene);
   
     -- 返回上一个地图
    -- 需要判断是否  是 剧情副本
    if insCf ~= nil and  insCf.type == InstanceDataManager.InstanceType.MainInstance then
        FBResultProxy.PlaySingleFbExit(tem,FBResultProxy.TryShowInstancePanel)
    else
        FBResultProxy.PlaySingleFbExit(tem)
    end

end

--[[
 local testData = {};
 testData.instId="750004";
 testData.fItems={ {am=2,spId=301003},{am=1000,spId=1},{am=1,spId=301004} };
 testData.star={5,2};
 testData.it=1;
 testData.time = 40;
 testData.items={ {am=2,spId=301003},{am=100,spId=4},{am=1000,spId=1} ,{am=1,spId=301004},{am=2,spId=301005} };
 testData.win = 1;
 testData.scene={x=-35,y=55,z=-955,sid="709999"};

 ModuleManager.SendNotification( FBResultNotes.OPEN_SINGLEFBWINRESULTPANEL, testData);
 ]]

--[[
 local testData = {};
 testData.instId="750004";
 testData.fItems={ {am=2,spId=301003},{am=1000,spId=1},{am=1,spId=301004} };
 testData.star={5,2,1};
 testData.it=1;
 testData.time = 40;
 testData.items={ {am=2,spId=301003},{am=100,spId=4},{am=1000,spId=1} ,{am=1,spId=301004},{am=2,spId=301005} };
 testData.win = 0;
 testData.scene={x=-35,y=55,z=-955,sid="709999"};

 ModuleManager.SendNotification( FBResultNotes.OPEN_SINGLEFBFAILRESULTPANEL, testData);
 ]]
function SingleFBFailResultPanel:SetData(data)

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

function SingleFBFailResultPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    self._btnReDo = nil;
    self._btnok = nil;
    self._okbtLabel = nil;
    self.wbg = nil;
end

function SingleFBFailResultPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnReDo, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReDo = nil;
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnok = nil;


end

function SingleFBFailResultPanel:_DisposeReference()
    self._btnReDo = nil;
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

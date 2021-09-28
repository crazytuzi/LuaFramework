require "Core.Module.Common.Panel"
require "Core.Module.FBResult.View.ResultPanel"

PVPFBFailResultPanel = class("PVPFBFailResultPanel", ResultPanel);
function PVPFBFailResultPanel:New()
    self = { };
    setmetatable(self, { __index = PVPFBFailResultPanel });
    self:_OnNew()
    return self
end

function PVPFBFailResultPanel:GetUIOpenSoundName()
    return ""
end

function PVPFBFailResultPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function PVPFBFailResultPanel:_InitReference()
    self._btnok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnok");

    self._okbtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnok/Label");

    self.useTimeTxt = UIUtil.GetChildByName(self._trsContent, "UILabel", "useTimeTxt");

    self.gvalue1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "gvalue1");
    self.gvalue2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "gvalue2");


    self.wbg = UIUtil.GetChildByName(self._trsContent, "UISprite", "wbg");
     UISoundManager.PlayUISound(UISoundManager.path_fb_fail);
end

function PVPFBFailResultPanel:_Opened()
    self.ui_lose = UIUtil.GetUIEffect("ui_lose", self._trsContent, self.wbg, 1);
    self.ui_lose.transform.localScale = Vector3.New(360, 360, 360);
end

function PVPFBFailResultPanel:_InitListener()
    self._onClickBtnok = function(go) self:_OnClickBtnok(self) end
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnok);
end

function PVPFBFailResultPanel:_OnClickBtnok()
    
    local tem =  ConfigManager.Clone(self.oldScene);
    ModuleManager.SendNotification(FBResultNotes.CLOSE_PVPFBFAILRESULTPANEL);

    -- 返回上一个地图
    FBResultProxy.PlaySingleFbExit(tem)
end

--[[
 local testData = {};
 testData.instId="750004";
 testData.fItems={ {am=2000,spId=5},{am=1000,spId=6},{am=1548,spId=4} };
 testData.star={5,2};
 testData.it=1;
 testData.time = 40;
 testData.items={ {am=2000,spId=5},{am=1000,spId=6},{am=1548,spId=4} };
 testData.win = 0;
 testData.rank=45478;
 testData.scene={x=-35,y=55,z=-955,sid="709999"};

 ModuleManager.SendNotification( FBResultNotes.OPEN_PVPFBFAILRESULTPANEL, testData);

]]
function PVPFBFailResultPanel:SetData(data)
    self.resluat_data = data;

    self.oldScene = data.scene;

    for key, value in pairs(data.items) do

        if value.spId == SpecialProductId.Vp then
            self.gvalue1.text = "" .. value.am;
            -- http://192.168.0.8:3000/issues/4005
        elseif value.spId == SpecialProductId.GongXunCoin then
            self.gvalue2.text = "" .. value.am;
        end
    end


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

function PVPFBFailResultPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    if (self.ui_lose) then
        Resourcer.Recycle(self.ui_lose, false);
        self.ui_lose = nil;
    end
     self._btnok = nil;

    self._okbtLabel = nil;

    self.useTimeTxt = nil;

    self.gvalue1 = nil;
    self.gvalue2 = nil;


    self.wbg = nil;

end

function PVPFBFailResultPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnok = nil;
end

function PVPFBFailResultPanel:_DisposeReference()
    self._btnok = nil;

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end
    self:_DisposeBase();
end

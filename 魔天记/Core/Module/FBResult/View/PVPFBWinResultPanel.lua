require "Core.Module.Common.Panel"
require "Core.Module.FBResult.View.ResultPanel"

PVPFBWinResultPanel = class("PVPFBWinResultPanel", ResultPanel);
function PVPFBWinResultPanel:New()
    self = { };
    setmetatable(self, { __index = PVPFBWinResultPanel });
     self:_OnNew()
    return self
end

function PVPFBWinResultPanel:GetUIOpenSoundName()
    return ""
end

function PVPFBWinResultPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function PVPFBWinResultPanel:_InitReference()
    self._btnok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnok");

    self._okbtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnok/Label");

    self.useTimeTxt = UIUtil.GetChildByName(self._trsContent, "UILabel", "useTimeTxt");

    self.gvalue1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "gvalue1");
    self.gvalue2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "gvalue2");


    self.wbg = UIUtil.GetChildByName(self._trsContent, "UISprite", "wbg");


    UISoundManager.PlayUISound(UISoundManager.path_fb_win);
end

function PVPFBWinResultPanel:_Opened()
    self.ui_win_BG = UIUtil.GetUIEffect("ui_win_BG", self._trsContent, self.wbg, 1);
    self.ui_win = UIUtil.GetUIEffect("ui_win", self._trsContent, self.wbg, 2);
    self.ui_win_BG.transform.localScale = Vector3.New(360, 360, 360);
    self.ui_win.transform.localScale = Vector3.New(360, 360, 360);


   

end

function PVPFBWinResultPanel:_InitListener()
    self._onClickBtnok = function(go) self:_OnClickBtnok(self) end
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnok);
end

function PVPFBWinResultPanel:_OnClickBtnok()
    
   local tem =  ConfigManager.Clone(self.oldScene);

      ModuleManager.SendNotification(FBResultNotes.CLOSE_PVPFBWINPANEL);
    -- 返回上一个地图

    FBResultProxy.PlaySingleFbExit(tem);
  
end

--[[
S <-- 14:26:33.770, 0x030A, 0, {"instId":"755000",
"fItems":[{"am":81050,"spId":6},{"am":100,"spId":5},{"am":100,"spId":4}],"star":[],
"rank":1994,"it":6,"time":17,
"items":[{"am":81050,"spId":6},{"am":100,"spId":5},{"am":100,"spId":4}],"win":1,
"harts":[{"s":0,"t":1,"h":0,"id":"20100244","icon_id":"101000","l":81,"n":"赖义宇"}],
"scene":{"x":-35,"y":55,"z":-955,"sid":"709999"}}

 local testData = {};
 testData.instId="750004";
 testData.fItems={ {am=2000,spId=5},{am=1000,spId=6},{am=1548,spId=4} };
 testData.star={5,2};
 testData.it=1;
 testData.time = 40;
 testData.items={ {am=2000,spId=5},{am=1000,spId=6},{am=1548,spId=4} };
 testData.win = 1;
 testData.rank=45478;
 testData.scene={x=-35,y=55,z=-955,sid="709999"};

 ModuleManager.SendNotification( FBResultNotes.OPEN_PVPFBWINPANEL, testData);

]]

function PVPFBWinResultPanel:SetData(data)
    self.resluat_data = data;


    self.useTimeTxt.text = string.format(LanguageMgr.Get("FBResult/PVPFBWinResultPanel/label1"), data.rank)
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
    self._okbtLabel.text = LanguageMgr.Get("common/ok").."(" .. self.djsTime .. ")";
    self._sec_timer = Timer.New( function()

        self.djsTime = self.djsTime - 1;
        self._okbtLabel.text = LanguageMgr.Get("common/ok").."(" .. self.djsTime .. ")";

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

function PVPFBWinResultPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

     self._btnok = nil;

    self._okbtLabel =nil;

    self.useTimeTxt = nil;

    self.gvalue1 = nil;
    self.gvalue2 = nil;


    self.wbg = nil;


end

function PVPFBWinResultPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnok = nil;
end

function PVPFBWinResultPanel:_DisposeReference()
    self._btnok = nil;

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
     self:_DisposeBase();
end

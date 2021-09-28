require "Core.Module.Common.Panel"
require "Core.Module.FBResult.View.ResultPanel"

TeamFBWinResultPanel = class("TeamFBWinResultPanel", ResultPanel);
function TeamFBWinResultPanel:New()
    self = { };
    setmetatable(self, { __index = TeamFBWinResultPanel });
    self._OnNew();
    return self
end

function TeamFBWinResultPanel:GetUIOpenSoundName()
    return ""
end

function TeamFBWinResultPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function TeamFBWinResultPanel:_InitReference()

    self._btnok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnok");

    self._okbtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnok/Label");

    self.useTimeTxt = UIUtil.GetChildByName(self._trsContent, "UILabel", "useTimeTxt");

    self.gvalue1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "gvalue1");
    self.gvalue2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "gvalue2");

    self._pag_phalanx = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "products/subPanel/Table");
    self.tablePanel = UIUtil.GetChildByName(self._trsContent, "Transform", "products/subPanel/Table");

    self.wbg = UIUtil.GetChildByName(self._trsContent, "UISprite", "wbg");

    UISoundManager.PlayUISound(UISoundManager.path_fb_win);
end

function TeamFBWinResultPanel:_Opened()
    self.ui_win_BG = UIUtil.GetUIEffect("ui_win_BG", self._trsContent, self.wbg, 1);
    self.ui_win = UIUtil.GetUIEffect("ui_win", self._trsContent, self.wbg, 2);
    self.ui_win_BG.transform.localScale = Vector3.New(360, 360, 360);
    self.ui_win.transform.localScale = Vector3.New(360, 360, 360);
end

function TeamFBWinResultPanel:_InitListener()

    self._onClickBtnok = function(go) self:_OnClickBtnok(self) end
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnok);


end



function TeamFBWinResultPanel:_OnClickBtnok()

    local tem = ConfigManager.Clone(self.oldScene);
    ModuleManager.SendNotification(FBResultNotes.CLOSE_TEAMFBWINRESULTPANEL);

    -- 返回上一个地图
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
 testData.win = 1;
 testData.scene={x=-35,y=55,z=-955,sid="709999"};

 ModuleManager.SendNotification( FBResultNotes.OPEN_TEAMFBWINRESULTPANEL, testData);

]]
function TeamFBWinResultPanel:SetData(data)
    self.resluat_data = data;

    self.useTimeTxt.text = LanguageMgr.Get("FBResult/SingleFBWinResultPanel/label1") .. GetTimeByStr(data.time);
    self.oldScene = data.scene;

    self:UpAwards(data)
end


function TeamFBWinResultPanel:UpAwards(data)

    local fItems = data.fItems;
    local items = data.items;

    local temItems = { };
    local index = 1;

    for k, v in pairs(items) do
        if (v.spId == SpecialProductId.Money) then
            self.gvalue1.text = tostring(v.am)
        elseif (v.spId == SpecialProductId.Exp) then
            self.gvalue2.text = tostring(v.am);

        else
            temItems[index] = v;
            index = index + 1;
        end
    end

    if fItems ~= nil then
        for k, v in pairs(fItems) do
            temItems[index] = v;
            index = index + 1;
        end
    end

  

      -----------------------------------------------------------------------
    local map = GameSceneManager.map;
    local map_dropList = map:GetDropInfos();

 


    temItems= ProductInfo.GetProducts(temItems, map_dropList, {SpecialProductId.Money,SpecialProductId.Exp},5, function(a, b)
        return a:GetQuality() > b:GetQuality();
    end )

   
    local len = table.getn(temItems);
   
    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._pag_phalanx, FBAwardItem);
    self.product_phalanx:Build(1, len, temItems);

   -- 设置  位置
     Util.SetLocalPos(self.tablePanel,-(len*108)/2, 0, 0);

      -----------------------------------------------------------------------


    ------------------------
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

function TeamFBWinResultPanel:Wait()


end

function TeamFBWinResultPanel:MovePanel()

    local lx = self.tablePanel.localPosition.x;
    local ly = self.tablePanel.localPosition.y;
    Util.SetLocalPos(self.tablePanel,lx - 110 / 5, ly, 0)

--    self.tablePanel.localPosition = Vector3.New(lx - 110 / 5, ly, 0);

end

function TeamFBWinResultPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

     if (self.ui_win_BG) then
        Resourcer.Recycle(self.ui_win_BG, false);
        self.ui_win_BG = nil;
    end

     if (self.ui_win) then
        Resourcer.Recycle(self.ui_win, false);
        self.ui_win = nil;
    end


    self._btnok = nil;

    self._okbtLabel = nil;

    self.useTimeTxt = nil;

    self.gvalue1 = nil;
    self.gvalue2 = nil;

    self._pag_phalanx = nil;
    self.tablePanel = nil;

    self.wbg = nil;

   

end

function TeamFBWinResultPanel:_DisposeListener()

    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnok = nil;
end

function TeamFBWinResultPanel:_DisposeReference()
    self._btnReDo = nil;
    self._btnok = nil;

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end
    self:_DisposeBase();

    self.product_phalanx:Dispose();
    self.product_phalanx = nil;

    if self.enterFrameRun ~= nil then
        self.enterFrameRun:Stop();
        self.enterFrameRun = nil;
    end
end

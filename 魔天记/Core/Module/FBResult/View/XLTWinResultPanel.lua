require "Core.Module.Common.Panel"
require "Core.Module.FBResult.View.ResultPanel"

XLTWinResultPanel = class("XLTWinResultPanel", ResultPanel);
function XLTWinResultPanel:New()
    self = { };
    setmetatable(self, { __index = XLTWinResultPanel });
    self:_OnNew()
    return self
end


function XLTWinResultPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XLTWinResultPanel:_InitReference()
    self._btnReDo = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnReDo");
    self._btnok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnok");

    self._okbtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnReDo/Label");

    self.useTimeTxt = UIUtil.GetChildByName(self._trsContent, "UILabel", "useTimeTxt");

    self.gvalue1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "gvalue1");
    self.gvalue2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "gvalue2");

    self._pag_phalanx = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "products/subPanel/Table");
    self.tablePanel = UIUtil.GetChildByName(self._trsContent, "Transform", "products/subPanel/Table");

    self.wbg = UIUtil.GetChildByName(self._trsContent, "UISprite", "wbg");

    UISoundManager.PlayUISound(UISoundManager.path_fb_win);

end

function XLTWinResultPanel:_InitListener()
    self._onClickBtnReDo = function(go) self:_OnClickBtnReDo(self) end
    UIUtil.GetComponent(self._btnReDo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReDo);
    self._onClickBtnok = function(go) self:_OnClickBtnok(self) end
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnok);
end

function XLTWinResultPanel:_Opened()
    self.ui_win_BG = UIUtil.GetUIEffect("ui_win_BG", self._trsContent, self.wbg, 1);
    self.ui_win = UIUtil.GetUIEffect("ui_win", self._trsContent, self.wbg, 2);
    self.ui_win_BG.transform.localScale = Vector3.New(360, 360, 360);
    self.ui_win.transform.localScale = Vector3.New(360, 360, 360);





end

function XLTWinResultPanel:_OnClickBtnReDo()
    -- 挑战下一层
    --  {"tsi":"706002","fid":"756002"}


    -------------------------------------------------------------------------------------------------------
    local obj;

    if FBMLTItem.curr_can_play_fb ~= nil then
        local mobj = FBMLTItem.curr_can_play_fb;
        obj = mobj.data;

        if obj ~= nil and obj.id ~= nil then
            obj.fid = obj.id;
        else
            obj = { fid = self.instId };
        end

    else
        obj = { fid = self.instId };
    end


    if obj.fid == nil then
        self:_OnClickBtnok();
        Warning("error --XLTWinResultPanel:_OnClickBtnReDo--> obj.fid == nil ");
        return;
    end

    local fid = obj.fid + 0;


    ----------------------------------------------------------------------------------------------------------------------------------------

    -- 需要检查 是否 到 最顶程了
    local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
    local t_num = table.getn(bfCflist);
    local lastFb = bfCflist[t_num];
    if lastFb.id == fid then
        -- 已经 市最高层
        self:_OnClickBtnok()

        return;
    end

    ----------------------------------------------------------------------------------------------------------------------------------------

    local next_id = fid + 1;

    local nextFb = InstanceDataManager.GetMapCfById(next_id);
    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    if my_lv < nextFb.level then
        MsgUtils.ShowTips("FBResult/XLTWinResultPanel/label1");
        self:_OnClickBtnok()
    else

        local next_ceng = InstanceDataManager.GetXLTHasPassCen() + 1;

        InstanceDataManager.TrySetXLTNext(next_ceng, true);

        self.data = nextFb;
        FBMLTItem.curr_can_play_fb = { data = nextFb };

        local fb_id = self.data.id;

        -- 进入副本
        ModuleManager.SendNotification(FBResultNotes.CLOSE_XLTWINRESULTPANEL);


        GameSceneManager.GoToFB(fb_id)

    end

end

function XLTWinResultPanel:_OnClickBtnok()

    local tem = ConfigManager.Clone(self.oldScene);
    ModuleManager.SendNotification(FBResultNotes.CLOSE_XLTWINRESULTPANEL);

    -- 返回上一个地图
    FBResultProxy.PlaySingleFbExit(tem)
end

function XLTWinResultPanel:SetData(data)
    self.resluat_data = data;
    self.instId = data.instId;

    self.useTimeTxt.text = LanguageMgr.Get("FBResult/SingleFBWinResultPanel/label1") .. GetTimeByStr(data.time);
    self.oldScene = data.scene;

    self:UpAwards(data)

end

function XLTWinResultPanel:UpAwards(data)

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

    -- 初始化 数据

    -----------------------------------------------------------------------
    local map = GameSceneManager.map;
    local map_dropList = map:GetDropInfos();

    temItems = ProductInfo.GetProducts(temItems, map_dropList, { SpecialProductId.Money, SpecialProductId.Exp }, 5, function(a, b)
        return a:GetQuality() > b:GetQuality();
    end )


    local len = table.getn(temItems);

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._pag_phalanx, FBAwardItem);
    self.product_phalanx:Build(1, len, temItems);

    -- 设置  位置
    Util.SetLocalPos(self.tablePanel, -(len * 108) / 2, 0, 0);

    -----------------------------------------------------------------------



    ------------------------
    self.djsTime = 10;
    self._okbtLabel.text = LanguageMgr.Get("FBResult/XLTWinResultPanel/label2", { n = self.djsTime });
    self._sec_timer = Timer.New( function()

        self.djsTime = self.djsTime - 1;
        self._okbtLabel.text = LanguageMgr.Get("FBResult/XLTWinResultPanel/label2", { n = self.djsTime });

        if self.djsTime <= 0 then
            if self._sec_timer ~= nil then
                self._sec_timer:Stop();
                self._sec_timer = nil;
            end

            self:_OnClickBtnReDo();
        end
    end , 1, self.djsTime, false);
    self._sec_timer:Start();

end

function XLTWinResultPanel:Wait()


end

function XLTWinResultPanel:MovePanel()

    local lx = self.tablePanel.localPosition.x;
    local ly = self.tablePanel.localPosition.y;
    Util.SetLocalPos(self.tablePanel, lx - 110 / 5, ly, 0)

    --    self.tablePanel.localPosition = Vector3.New(lx - 110 / 5, ly, 0);

end

function XLTWinResultPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    self._btnReDo = nil;
    self._btnok = nil;

    self._okbtLabel = nil;

    self.useTimeTxt = nil;

    self.gvalue1 = nil;
    self.gvalue2 = nil;

    self._pag_phalanx = nil;
    self.tablePanel = nil;

    self.wbg = nil;

end

function XLTWinResultPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnReDo, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReDo = nil;
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnok = nil;
end

function XLTWinResultPanel:_DisposeReference()
    self._btnReDo = nil;
    self._btnok = nil;

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    if (self.ui_win_BG) then
        Resourcer.Recycle(self.ui_win_BG, false);
        self.ui_win_BG = nil;
    end

    if (self.ui_win) then
        Resourcer.Recycle(self.ui_win, false);
        self.ui_win = nil;
    end

    self:_DisposeBase();

    self.product_phalanx:Dispose();
    self.product_phalanx = nil;

    if self.enterFrameRun ~= nil then
        self.enterFrameRun:Stop();
        self.enterFrameRun = nil;
    end

end

require "Core.Module.Common.Panel"

require "Core.Module.FBResult.View.ResultPanel"
require "Core.Module.FBResult.View.item.FBAwardItem"

require "Core.Module.Common.EnterFrameRun"

require "Core.Manager.Item.ConditionDataManager"

SingleFBWinResultPanel = class("SingleFBWinResultPanel", ResultPanel);
function SingleFBWinResultPanel:New()
    self = { };
    setmetatable(self, { __index = SingleFBWinResultPanel });
    self:_OnNew()
    return self
end

function SingleFBWinResultPanel:GetUIOpenSoundName()
    return ""
end

function SingleFBWinResultPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SingleFBWinResultPanel:_InitReference()
    self._btnReDo = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnReDo");
    self._btnok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnok");

    self._okbtLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnok/Label");

    self.useTimeTxt = UIUtil.GetChildByName(self._trsContent, "UILabel", "useTimeTxt");

    self.gvalue1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "gvalue1");
    self.gvalue2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "gvalue2");

    self._pag_phalanx = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "products/subPanel/Table");
    self.tablePanel = UIUtil.GetChildByName(self._trsContent, "Transform", "products/subPanel/Table");

    self.wbg = UIUtil.GetChildByName(self._trsContent, "UISprite", "wbg");

    for i = 1, 3 do
        self["star" .. i] = UIUtil.GetChildByName(self._trsContent, "UISprite", "star" .. i);
    end

    for i = 1, 3 do
        self["bottomstar" .. i] = UIUtil.GetChildByName(self._trsContent, "UISprite", "bottomstar" .. i);
        self["bottomstarTxt" .. i] = UIUtil.GetChildByName(self._trsContent, "UILabel", string.format("bottomstar%sTxt", i));
    end

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._pag_phalanx, FBAwardItem);

    UISoundManager.PlayUISound(UISoundManager.path_fb_win);
end

function SingleFBWinResultPanel:_Opened()
    self.ui_win_BG = UIUtil.GetUIEffect("ui_win_BG", self._trsContent, self.wbg, 1);
    self.ui_star3 = UIUtil.GetUIEffect("ui_star3", self._trsContent, self.wbg, 2);
    self.ui_win_BG.transform.localScale = Vector3.New(360, 360, 360);
    self.ui_star3.transform.localScale = Vector3.New(360, 360, 360);



    self.star1 = UIUtil.GetChildByName(self.ui_star3, "Transform", "star1");
    self.star2 = UIUtil.GetChildByName(self.ui_star3, "Transform", "star2");
    self.star3 = UIUtil.GetChildByName(self.ui_star3, "Transform", "star3");

    local star_num = table.getn(self.resluat_data.star);



    if star_num == 1 then
        self.star1.gameObject:SetActive(true);
        self.star2.gameObject:SetActive(false);
        self.star3.gameObject:SetActive(false);

    elseif star_num == 2 then
        self.star1.gameObject:SetActive(true);
        self.star2.gameObject:SetActive(true);
        self.star3.gameObject:SetActive(false);

    elseif star_num == 3 then
        self.star1.gameObject:SetActive(true);
        self.star2.gameObject:SetActive(true);
        self.star3.gameObject:SetActive(true);

    end

end



function SingleFBWinResultPanel:_InitListener()
    self._onClickBtnReDo = function(go) self:_OnClickBtnReDo(self) end
    UIUtil.GetComponent(self._btnReDo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReDo);
    self._onClickBtnok = function(go) self:_OnClickBtnok(self) end
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnok);
end

function SingleFBWinResultPanel:_OnClickBtnReDo()
    FBResultProxy.PlaySingleFbAgain()
end

function SingleFBWinResultPanel:_OnClickBtnok()

    local tem = ConfigManager.Clone(self.oldScene);

    local insCf = InstanceDataManager.GetMapCfById(self.insId);

    ModuleManager.SendNotification(FBResultNotes.CLOSE_SINGLEFBWINRESULTPANEL);


    -- 返回上一个地图
    -- 需要判断是否  是 剧情副本
    if insCf ~= nil and insCf.type == InstanceDataManager.InstanceType.MainInstance then
        FBResultProxy.PlaySingleFbExit(tem, FBResultProxy.TryShowInstancePanel)
    else
        FBResultProxy.PlaySingleFbExit(tem)
    end

end


--[[
S <-- 19:53:59.506, 0x030A, 0, {"instId":"750004","fItems":[
{"am":2,"spId":301003},{"am":100,"spId":4},{"am":1000,"spId":1},{"am":1,"spId":301004}
],

"star":[5,2,1],
"it":1,
"time":40,
"items":[{"am":2,"spId":301003},{"am":100,"spId":4},{"am":1000,"spId":1},{"am":1,"spId":301004}],
"win":1,
"harts":[{"s":99,"t":1,"h":11772,"id":"20100244","icon_id":"101000","l":81,"n":"赖义宇"}],
"scene":{"x":-35,"y":55,"z":-955,"sid":"709999"}}

]]

--[[
 失败的

S <-- 17:17:15.309, 0x030A, 0, {"instId":"750001",
"fItems":[{"am":100,"spId":4},{"am":1000,"spId":1},
{"am":1,"spId":301001}],"star":[],"it":1,"time":600,
"items":[{"am":100,"spId":4},{"am":1000,"spId":1},{"am":1,"spId":301001}],
"win":0,"harts":[{"s":99,"t":1,"h":1492,"id":"20100290","icon_id":"101000","l":15,"n":"秦霄素"}],

"scene":{"x":128,"y":55,"z":-636,"sid":"709999"}}
UnityEngine.Debug:Log(Object)

]]
function SingleFBWinResultPanel:SetData(data)
    self.resluat_data = data;
    self.insId = data.instId;

    self.useTimeTxt.text = LanguageMgr.Get("FBResult/SingleFBWinResultPanel/label1") .. GetTimeByStr(data.time);
    self.oldScene = data.scene;

    self:UpAwards(data)
    self:UpStar(data.star, data.instId)
end

function SingleFBWinResultPanel:UpAwards(data)

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

    local resItem = ProductInfo.GetProducts(temItems, map_dropList, { SpecialProductId.Money, SpecialProductId.Exp }, 5, function(a, b)
        return a:GetQuality() > b:GetQuality();
    end )

    local len = table.getn(resItem);


    self.product_phalanx:Build(1, len, resItem);

    -- 设置  位置
    Util.SetLocalPos(self.tablePanel, -(len * 108) / 2, 0, 0);

    -----------------------------------------------------------------------

    --[[
    if len > 4 then
        -- 需要播放 动画
        self.enterFrameRun = EnterFrameRun:New();

        local esleLen = len - 4;

        for i = 1, esleLen do
            self.enterFrameRun:AddHandler(SingleFBWinResultPanel.Wait, self, 10);
            self.enterFrameRun:AddHandler(SingleFBWinResultPanel.MovePanel, self, 5);
        end

        self.enterFrameRun:Start()
    end
    ]]

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

function SingleFBWinResultPanel:Wait()


end

function SingleFBWinResultPanel:MovePanel()

    local lx = self.tablePanel.localPosition.x;
    local ly = self.tablePanel.localPosition.y;
    Util.SetLocalPos(self.tablePanel, lx - 110 / 5, ly, 0)

    --    self.tablePanel.localPosition = Vector3.New(lx - 110 / 5, ly, 0);

end

function SingleFBWinResultPanel:UpStar(star, instId)


    local star_num = table.getn(star);

    -- 753003
    local mapcf = InstanceDataManager.GetMapCfById(instId);
    local pass_conditions = mapcf.pass_conditions;
    local plen = table.getn(pass_conditions);

    local conditnArr = { };

    local set_Star_num = 0;

    local trySetStat = function(star_c)
        local hasget = 0;
        for j = 1, star_num do
            if star[j] == star_c and set_Star_num <= star_num then
                hasget = 1;
                set_Star_num = set_Star_num + 1;
                star[j] = -1;
                return hasget;
            end
        end

        return hasget;
    end

    for i = 1, plen do
        local condition = pass_conditions[i];
        local condition_arr = SceneInfosGetManager.Get_ins():SpildString(condition);
        local conditionStr = ConditionDataManager.GetConditionMsg(condition_arr[1], condition_arr[2], condition_arr[3]);

        local star_c = condition_arr[1] + 0;

        local hasget = trySetStat(star_c);

        conditnArr[i] = { conditionStr = conditionStr, hasget = hasget };

    end


    table.sort(conditnArr, function(a, b) return a.hasget > b.hasget end)

    for i = 1, plen do
        local condition = conditnArr[i];

        -- 星级评定
      
        self["bottomstarTxt" .. i].text = condition.conditionStr;

        if condition.hasget == 1 then
            self["bottomstar" .. i].spriteName = "star1";
        else
            self["bottomstar" .. i].spriteName = "star2";
        end
        
    end

end 

function SingleFBWinResultPanel:_Dispose()
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

    for i = 1, 3 do
        self["star" .. i] = nil;
    end

    for i = 1, 3 do
        self["bottomstar" .. i] = nil;
        self["bottomstarTxt" .. i] = nil;
    end
end

function SingleFBWinResultPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnReDo, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReDo = nil;
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnok = nil;
end

function SingleFBWinResultPanel:_DisposeReference()
    self._btnReDo = nil;
    self._btnok = nil;

    if (self.ui_win_BG) then
        Resourcer.Recycle(self.ui_win_BG, false);
        self.ui_win_BG = nil;
    end

    if (self.ui_star3) then
        Resourcer.Recycle(self.ui_star3, false);
        self.ui_star3 = nil;
    end

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    self:_DisposeBase();

    if self.product_phalanx ~= nil then
        self.product_phalanx:Dispose();
        self.product_phalanx = nil;
    end


    if self.enterFrameRun ~= nil then
        self.enterFrameRun:Stop();
        self.enterFrameRun = nil;
    end

end

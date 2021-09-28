require "Core.Module.Common.Panel"

require "Core.Module.XMBoss.View.item.XMBossGameResultItem"

XMBossGameResultPanel = class("XMBossGameResultPanel", Panel);
local _sortfunc = table.sort 

function XMBossGameResultPanel:New()
    self = { };
    setmetatable(self, { __index = XMBossGameResultPanel });
    return self
end


function XMBossGameResultPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XMBossGameResultPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
    self._txtTitle2 = UIUtil.GetChildInComponents(txts, "txtTitle2");
    self._txtTitle3 = UIUtil.GetChildInComponents(txts, "txtTitle3");
    self._txtTitle5 = UIUtil.GetChildInComponents(txts, "txtTitle5");
    self.elseTimeTxt = UIUtil.GetChildInComponents(txts, "elseTimeTxt");


    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btnTog1 = UIUtil.GetChildInComponents(btns, "btnTog1");
    self._btnTog2 = UIUtil.GetChildInComponents(btns, "btnTog2");
    self._btnTog3 = UIUtil.GetChildInComponents(btns, "btnTog3");
    self._btnTog4 = UIUtil.GetChildInComponents(btns, "btnTog4");

    local togs = UIUtil.GetComponentsInChildren(self._trsContent, "UIToggle");

    self._Tog1 = UIUtil.GetChildInComponents(togs, "btnTog1");
    self._Tog2 = UIUtil.GetChildInComponents(togs, "btnTog2");
    self._Tog3 = UIUtil.GetChildInComponents(togs, "btnTog3");
    self._Tog4 = UIUtil.GetChildInComponents(togs, "btnTog4");



    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsToggle = UIUtil.GetChildInComponents(trss, "trsToggle");
    self._trsTitle = UIUtil.GetChildInComponents(trss, "trsTitle");


    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");
    self._item_phalanx = UIUtil.GetChildByName(self.mainView, "LuaAsynPhalanx", "listPanel/subPanel/table");


    XMBossGameResultPanel.listMaxNum = 30;
    local dataArr = { };
    for i = 1, XMBossGameResultPanel.listMaxNum do
        dataArr[i] = { };
    end

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, XMBossGameResultItem);
    self.product_phalanx:Build(XMBossGameResultPanel.listMaxNum, 1, dataArr);


    self._fb_else_totalTime = 30;
    -- 设置 倒计时
    self._sec_timer = Timer.New( function()

        local tstr = GetTimeByStr1(self._fb_else_totalTime);
        self._fb_else_totalTime = self._fb_else_totalTime - 1;
        self.elseTimeTxt.text = LanguageMgr.Get("downTime/prefix") .. tstr;
        -- 倒计时:

        if self._fb_else_totalTime <= 0 then
            if self._sec_timer ~= nil then
                self._sec_timer:Stop();
                self._sec_timer = nil;
            end
            self:_OnClickBtn_close();
        end

    end , 1, self._fb_else_totalTime, false);
    self._sec_timer:Start();

end

function XMBossGameResultPanel:_Opened()
    self._trsContent.gameObject:SetActive(false);
    self._trsContent.gameObject:SetActive(true);
end

function XMBossGameResultPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtnTog1 = function(go) self:_OnClickBtnTog1(self) end
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog1);
    self._onClickBtnTog2 = function(go) self:_OnClickBtnTog2(self) end
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog2);
    self._onClickBtnTog3 = function(go) self:_OnClickBtnTog3(self) end
    UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog3);
    self._onClickBtnTog4 = function(go) self:_OnClickBtnTog4(self) end
    UIUtil.GetComponent(self._btnTog4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog4);
end

function XMBossGameResultPanel:_OnClickBtn_close()

    local tem = ConfigManager.Clone(self.oldScene);

    ModuleManager.SendNotification(XMBossNotes.CLOSE_XMBOSSJOININFOSPANEL);
    ModuleManager.SendNotification(XMBossNotes.CLOSE_XMBOSSGAMERESULTPANEL);

    FBResultProxy.PlaySingleFbExit(tem)
end

function XMBossGameResultPanel:_OnClickBtnTog1()
    self:SetList(self.data.l1, 1);
    self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label1");
end

function XMBossGameResultPanel:_OnClickBtnTog2()
    self:SetList(self.data.l2, 2);
    self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label1");
end

function XMBossGameResultPanel:_OnClickBtnTog3()
    self:SetList(self.data.l3, 3);
    --self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label2");
     self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label1");
end

function XMBossGameResultPanel:_OnClickBtnTog4()
    self:SetList(self.data.l4, 4);
   -- self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label3");
    self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label1");
end

function XMBossGameResultPanel:Trysort(list)

    local t_num = table.getn(list);
    if t_num > 1 then
        _sortfunc(list, function(a, b) return a.id < b.id end);
    end
end

--  仙盟boss 副本 结算
--[[
0A 帮会boss结算（服务器发出）
输出：
win：（0失败1成功）
instId：副本ID
items：道具[spIdL:道具ID,am:数量]
fItems：道具[spIdL:道具ID,am:数量](第一次通过额外奖励)
time：用时
l1：伤害列表[id：玩家排名,n:玩家呢称，v:伤害值,s:伤害比例,r:[spid:道具id，num:数量] ]
l2：治疗列表[id：玩家排名,n:玩家呢称，v:治疗值,s:伤害比例,r:[spid:道具id，num:数量] ]
l3：承受伤害列表[id：玩家排名,n:玩家呢称，v:承受伤害值,s:伤害比例,r:[spid:道具id，num:数量] ]

scene:{sid:sceneId,x,y,z} 下线场景点

0x030A

]]
function XMBossGameResultPanel:SetData(data)


    self.data = data;

    local win = data.win;
    local instId = data.instId;
    local items = data.items;
    local fItems = data.fItems;
    local time = data.time;
    self.oldScene = data.scene;

    --  排序

    self:Trysort(self.data.l1)
    self:Trysort(self.data.l2)
    self:Trysort(self.data.l3)
    self:Trysort(self.data.l4)

    -- 切换到 自己 职业的 列表

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local k = heroInfo.kind+0;

    if 101000 == k then
        -- 太清门
        self._Tog1.value = true;
        self:_OnClickBtnTog1()

    elseif 102000 == k then
        -- 天妖谷
        self._Tog4.value = true;
        self:_OnClickBtnTog4()
    elseif 103000 == k then
        -- 魔玄宗
        self._Tog2.value = true;
        self:_OnClickBtnTog2()
    elseif 104000 == k then
        -- 天工宗
        self._Tog3.value = true;
        self:_OnClickBtnTog3()
    end




end


function XMBossGameResultPanel:SetList(list, type)

    local items = self.product_phalanx._items;

    for i = 1, XMBossGameResultPanel.listMaxNum do
        local obj = items[i].itemLogic;
        obj:SetData(list[i], type);
    end

end



function XMBossGameResultPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function XMBossGameResultPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog1 = nil;
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog2 = nil;
    UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog3 = nil;
    UIUtil.GetComponent(self._btnTog4, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog4 = nil;
end

function XMBossGameResultPanel:_DisposeReference()

    self.product_phalanx:Dispose();
    self.product_phalanx = nil;

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    self._btn_close = nil;
    self._btnTog1 = nil;
    self._btnTog2 = nil;
    self._btnTog3 = nil;
    self._txtTitle1 = nil;
    self._txtTitle2 = nil;
    self._txtTitle3 = nil;
    self._txtTitle5 = nil;
    self._trsToggle = nil;
    self._trsTitle = nil;

    self.mainView = nil;
    self._item_phalanx = nil;


end

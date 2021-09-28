require "Core.Module.Common.Panel"
require "Core.Module.Common.UIAnimationModel"
require "Core.Role.ModelCreater.MonsterModelCreater"

XMBossPanel = class("XMBossPanel", Panel);

XMBossPanel.Fb_id = 756600;

local _sortfunc = table.sort 

function XMBossPanel:New()
    self = { };
    setmetatable(self, { __index = XMBossPanel });
    return self
end


function XMBossPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XMBossPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txttitle = UIUtil.GetChildInComponents(txts, "txttitle");
    self._txttitle = UIUtil.GetChildInComponents(txts, "txttitle");

   -- self.moneyTxt1 = UIUtil.GetChildInComponents(txts, "moneyTxt1");
  --  self.moneyTxt2 = UIUtil.GetChildInComponents(txts, "moneyTxt2");
    self.stateTipTxt = UIUtil.GetChildInComponents(txts, "stateTipTxt");

    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btn_xiangxiRank = UIUtil.GetChildInComponents(btns, "btn_xiangxiRank");
    self._btn_shoulingjieshao = UIUtil.GetChildInComponents(btns, "btn_shoulingjieshao");
    self._btn_box = UIUtil.GetChildInComponents(btns, "btn_box");
    self._btn_zhaohuan = UIUtil.GetChildInComponents(btns, "btn_zhaohuan");
    self._btn_tiaozhan = UIUtil.GetChildInComponents(btns, "btn_tiaozhan");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");
    self.leftPanel = UIUtil.GetChildByName(self.mainView, "Transform", "leftPanel");
    self.rightPanel = UIUtil.GetChildByName(self.mainView, "Transform", "rightPanel");
    self.centerPanel = UIUtil.GetChildByName(self.mainView, "Transform", "centerPanel");

    self.Product1 = UIUtil.GetChildByName(self.rightPanel, "Transform", "Product1");
    self.Product2 = UIUtil.GetChildByName(self.rightPanel, "Transform", "Product2");

    self._productCtrl1 = ProductCtrl:New();
    self._productCtrl1:Init(self.Product1, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
    self._productCtrl1:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

    self._productCtrl2 = ProductCtrl:New();
    self._productCtrl2:Init(self.Product2, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
    self._productCtrl2:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

    self.trsRoleParent = UIUtil.GetChildByName(self._trsContent, "mainView/centerPanel/imgRole/heroCamera/trsRoleParent");

    self.stateTipTxt.gameObject:SetActive(false);
    self._btn_zhaohuan.gameObject:SetActive(false);

    XMBossProxy.GetXMBossMainInfos();



    MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_GETXMBOSSMAININFOS, XMBossPanel.MainInfoChenge, self);

    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE, XMBossPanel.SceneChange, self);

    MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_ZHAOHUAN_SUCCESS, XMBossPanel.ZhaohuanSuccess, self);

    -- 测试数据
    --[[
    local resData = { };
    resData.l = { };
    resData.l[1] = { idx = 1, tn = "sdhfesf", h = 60 };
    resData.l[2] = { idx = 2, tn = "sdhfesf", h = 60 };

    resData.tb = { mid = 125001, l = 10, hp = 1000, max_hp = 2000 };

    self:MainInfoChenge(resData)
    ]]


end

function XMBossPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtn_xiangxiRank = function(go) self:_OnClickBtn_xiangxiRank(self) end
    UIUtil.GetComponent(self._btn_xiangxiRank, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_xiangxiRank);
    self._onClickBtn_shoulingjieshao = function(go) self:_OnClickBtn_shoulingjieshao(self) end
    UIUtil.GetComponent(self._btn_shoulingjieshao, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_shoulingjieshao);
    self._onClickBtn_box = function(go) self:_OnClickBtn_box(self) end
    UIUtil.GetComponent(self._btn_box, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_box);
    self._onClickBtn_zhaohuan = function(go) self:_OnClickBtn_zhaohuan(self) end
    UIUtil.GetComponent(self._btn_zhaohuan, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_zhaohuan);
    self._onClickBtn_tiaozhan = function(go) self:_OnClickBtn_tiaozhan(self) end
    UIUtil.GetComponent(self._btn_tiaozhan, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_tiaozhan);
end

--[[
输出：
l:{[idx:排名，tn：帮会呢称，h:伤害值]}
tb：[mid:当前挑战怪物id，l:boss等级，hp：当前挑战怪物的血量，max_hp:当前怪物的最大血量值]
]]
function XMBossPanel:MainInfoChenge(data)

    local l = data.l;
    local tb = data.tb;
    XMBossProxy.s = data.s;

    -- f:是否扣资金（0:没扣，1：已扣）
    self.hasKouFei = data.f;


    if tb.mid == -1 then
        local obj = XMBossDataManager.tong_monsterCf[1];
        tb.mid = obj.monster_id;

        local mcf = ConfigManager.GetMonById(tb.mid);

        local att_ = ConfigManager.GetMonAtt(mcf.attr_calc, tb.l);
        tb.hp = att_.hp_max;
        tb.max_hp = att_.hp_max;
    end


    self:UpRank(l)
    self:UpBossData(tb);

    local b = self:IsManager();

    if b then
        --  self._btn_zhaohuan.gameObject:SetActive(true);
    else
        --  self._btn_zhaohuan.gameObject:SetActive(false);
    end

    -- s:帮会boss活动状态（1：没开启，2：进心中，3：已结束,4：胜利）
    if XMBossProxy.s == 1 then


    elseif XMBossProxy.s == 2 then

    elseif XMBossProxy.s == 3 then

        -- self._btn_zhaohuan.gameObject:SetActive(false);
        self._btn_tiaozhan.gameObject:SetActive(false);

        self.stateTipTxt.text = LanguageMgr.Get("XMBoss/XMBossPanel/label2");
        self.stateTipTxt.gameObject:SetActive(true);

    elseif XMBossProxy.s == 4 then

        -- self._btn_zhaohuan.gameObject:SetActive(false);
        self._btn_tiaozhan.gameObject:SetActive(false);

        self.stateTipTxt.text = LanguageMgr.Get("XMBoss/XMBossPanel/label3");
        self.stateTipTxt.gameObject:SetActive(true);
    end




end


function XMBossPanel:IsManager()

    if GuildDataManager.info.identity == GuildInfo.Identity.Leader or
        GuildDataManager.info.identity == GuildInfo.Identity.AssLeader or
        GuildDataManager.info.identity == GuildInfo.Identity.Elder then
        return true;
    else
        return false;
    end

end


function XMBossPanel:UpBossData(tb)




    self:UpMonster(tb.mid);
    -- 125001
    self:SetActivetyAward(tb.l);

    local hp = tb.hp;
    local max_hp = tb.max_hp;
    local monCf = ConfigManager.GetMonById(tb.mid);

    self.bossIcon = UIUtil.GetChildByName(self.centerPanel, "UISprite", "bossIcon");
    self.bosshpct = UIUtil.GetChildByName(self.centerPanel, "UISprite", "bosshpct");
    -- 599

    self.bossLvTxt = UIUtil.GetChildByName(self.centerPanel, "UILabel", "bossLvTxt");
    self.bossNameTxt = UIUtil.GetChildByName(self.centerPanel, "UILabel", "bossNameTxt");
    self.bosshpPcTxt = UIUtil.GetChildByName(self.centerPanel, "UILabel", "bosshpPcTxt");

    self.bossBeKieTxt = UIUtil.GetChildByName(self.centerPanel, "UILabel", "bossBeKieTxt");

    self.bossLvTxt.text = "" .. tb.l;
    self.bossNameTxt.text = monCf.name;
    self.bossIcon.spriteName = "" .. monCf.icon_id;

    if tb.hp <= 0 then
        self.bosshpct.gameObject:SetActive(false);
        self.bosshpPcTxt.text = "";
    else
        local pc = tb.hp / tb.max_hp;
        self.bosshpct.width = pc * 560;
        self.bosshpPcTxt.text = math.floor(tb.hp) .. "/" .. math.floor(tb.max_hp);
    end

    if XMBossDataManager.tong_monsterCf[3].monster_id == tb.mid and hp == 0 then
        self.bossBeKieTxt.gameObject:SetActive(true);
    else
        self.bossBeKieTxt.gameObject:SetActive(false);
    end

end


function XMBossPanel:UpRank(l)



    local t_num = table.getn(l);

    if t_num > 1 then
        _sortfunc(l, function(a, b) return(a.idx - b.idx) < 0 end);
    end

    for i = 1, 3 do
        local item = UIUtil.GetChildByName(self.leftPanel, "Transform", "item" .. i);

        if i <= t_num then
            local labelTxt = UIUtil.GetChildByName(item, "UILabel", "labelTxt");
            local hurtTxt = UIUtil.GetChildByName(item, "UILabel", "hurtTxt");

            local obj = l[i];

            labelTxt.text = obj.tn;
            hurtTxt.text = GetNumStrW(obj.h);

        else
            item.gameObject:SetActive(false);
        end

    end


end

function XMBossPanel:UpMonster(id)
    local monCf = ConfigManager.GetMonById(id);
    local info = { kind = monCf.id };
    if (self._uiAnimationModel == nil) then
        self._uiAnimationModel = UIAnimationModel:New(info, self.trsRoleParent, MonsterModelCreater);
    else
        self._uiAnimationModel:ChangeModel(info, self.trsRoleParent)
    end

    local sc = XMBossDataManager.Get_model_scale_rate(id);

    self.trsRoleParent.transform.localScale = Vector3.New(100 * sc, 100 * sc, 100 * sc);

end

function XMBossPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(XMBossNotes.CLOSE_XMBOSSPANEL);
end

function XMBossPanel:_OnClickBtn_xiangxiRank()
    ModuleManager.SendNotification(XMBossNotes.OPEN_XMHUODONGJINDURANKPANEL);
end

function XMBossPanel:_OnClickBtn_shoulingjieshao()
    ModuleManager.SendNotification(XMBossNotes.OPEN_XMBOSSSHOULINGJIESHAOPANEL);
end

function XMBossPanel:_OnClickBtn_box()

    if self.activetyAward ~= nil then

        ProductCtrl.ShowProductTip(self.activetyAward.product_id_1, ProductCtrl.TYPE_FROM_OTHER, 1)

    end


end



function XMBossPanel:ZhaohuanSuccess()
    self.hasKouFei = 1;
end

function XMBossPanel:_OnClickBtn_zhaohuan()

    -- f:是否扣资金（0:没扣，1：已扣）

    if self.hasKouFei == 1 then
        -- 不需要弹窗
        XMBossProxy.TryMXBossZaoHuang();
    else
        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM5PANEL);

    end


end



function XMBossPanel:_OnClickBtn_tiaozhan()



    -- self.data = InstanceDataManager.GetMapCfById(XMBossPanel.Fb_id);

    --[[
    local tx = SceneInfosGetManager.Get_ins():GetRandom(self.data.position_x);
    local ty = self.data.position_y + 0;
    local tz = SceneInfosGetManager.Get_ins():GetRandom(self.data.position_z);

    local toScene = { };
    toScene.sid = self.data.map_id;
    toScene.position = Convert.PointFromServer(tx, ty, tz);
    toScene.rot = self.data.toward + 0;

    GameSceneManager.to = toScene;
    GameSceneManager.GotoScene(self.data.map_id, self.data.id);
    ]]

    -- LanguageMgr.Get("XMBoss/XMBossPanel/label2");
    --[[
    local b = self:IsManager();
    -- s:帮会boss活动状态（1：没开启，2：进心中，3：已结束,4：胜利）
    if XMBossProxy.s == 1 then

        if b then

            MsgUtils.ShowTips("XMBoss/XMBossPanel/label4");
        else

            MsgUtils.ShowTips("XMBoss/XMBossPanel/label5");
        end

    else

        if GameSceneManager.fid == XMBossPanel.Fb_id then

            MsgUtils.ShowTips("XMBoss/XMBossPanel/label1");
        else

            -- 关闭活动界面
            ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
            GameSceneManager.GoToFB(XMBossPanel.Fb_id)
        end

    end

    ]]

    if GameSceneManager.fid == XMBossPanel.Fb_id then

        MsgUtils.ShowTips("XMBoss/XMBossPanel/label1");
    else

        -- 关闭活动界面
        ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
        GameSceneManager.GoToFB(XMBossPanel.Fb_id)
    end

end

function XMBossPanel:SceneChange()

    ModuleManager.SendNotification(XMBossNotes.CLOSE_XMBOSSPANEL);
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDPANEL);

    MessageManager.Dispatch(MainUINotes, MainUINotes.SET_SYSPANEL_DISPLAY, MainUIPanel.Mode.HIDE);

    MessageManager.Dispatch(PartyAndTaskPanel, PartyAndTaskPanel.MESSAGE_PARTYANDTASKPANEL_ACT, MainUIPanel.Mode.SHOW);
end


function XMBossPanel:SetActivetyAward(boss_lv)


    self.activetyAward = XMBossDataManager.GetActivetyAward(boss_lv);

    local ranking_award = self.activetyAward.ranking_award;
    local battle_award = self.activetyAward.battle_award;

    
    ranking_award = ConfigSplit(ranking_award);
    battle_award = ConfigSplit(battle_award);
   

    local info1 = ProductManager.GetProductInfoById(ranking_award[1], 1)
    local info2 = ProductManager.GetProductInfoById(battle_award[1], 1)

    self._productCtrl1:SetData(info1);
    self._productCtrl2:SetData(info2);

    --self.moneyTxt1.text = "" .. ranking_award[2];
    --self.moneyTxt2.text = "" .. battle_award[2];


end

function XMBossPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function XMBossPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_xiangxiRank, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_xiangxiRank = nil;
    UIUtil.GetComponent(self._btn_shoulingjieshao, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_shoulingjieshao = nil;
    UIUtil.GetComponent(self._btn_box, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_box = nil;
    UIUtil.GetComponent(self._btn_zhaohuan, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_zhaohuan = nil;
    UIUtil.GetComponent(self._btn_tiaozhan, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_tiaozhan = nil;
end

function XMBossPanel:_DisposeReference()

    if self._uiAnimationModel ~= nil then
        self._uiAnimationModel:Dispose();
        self._uiAnimationModel = nil;
    end

    self._productCtrl1:Dispose();
    self._productCtrl1 = nil;

    self._productCtrl2:Dispose();
    self._productCtrl2 = nil;


    MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_GETXMBOSSMAININFOS, XMBossPanel.MainInfoChenge);
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE, XMBossPanel.SceneChange);
    MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_ZHAOHUAN_SUCCESS, XMBossPanel.ZhaohuanSuccess);

    self._btn_close = nil;
    self._btn_xiangxiRank = nil;
    self._btn_shoulingjieshao = nil;
    self._btn_box = nil;
    self._btn_zhaohuan = nil;
    self._btn_tiaozhan = nil;
    self._txttitle = nil;
    self._txttitle = nil;




    --self.moneyTxt1 = nil;
    --self.moneyTxt2 = nil;
    self.stateTipTxt = nil;



    self.mainView = nil;
    self.leftPanel = nil;
    self.centerPanel = nil;

    self.trsRoleParent = nil;




end

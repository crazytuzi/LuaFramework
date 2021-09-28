require "Core.Module.Common.Panel"
require "Core.Module.Common.UIEffect"
require "Core.Module.Equip.controll.QianghuaPanelControll"
require "Core.Module.Equip.controll.JingLianControll"
require "Core.Module.Equip.controll.EquipGemCtrl"

require "Core.Module.Equip.controll.LeftPanelControll";
require "Core.Module.Equip.controll.EquipDressTipPanelControll";
require "Core.Module.Equip.Item.ProductGetMsgPanelItem"
local NewEquipQiangHuaPanel = require "Core.Module.Equip.Item.NewEquipQiangHuaPanel"
local EquipSuitControll = require "Core.Module.Equip.controll.EquipSuitControll"

EquipMainPanel = class("EquipMainPanel", Panel);

EquipMainPanel.getEquipTips = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GETEQUIPTIP); -- require "Core.Config.getEquipTip";
EquipMainPanel.ins = nil;
function EquipMainPanel:New()
    self = { };
    setmetatable(self, { __index = EquipMainPanel });
    EquipMainPanel.ins = self;
    return self
end


function EquipMainPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function EquipMainPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txt_title = UIUtil.GetChildInComponents(txts, "txt_title");

    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");

    -- self._btn_jinglian = UIUtil.GetChildInComponents(btns, "btn_jinglian");

    self._coinBar = UIUtil.GetChildByName(self._trsContent, "CoinBar");
    self._coinBarCtrl = CoinBar:New(self._coinBar);

    self._leftPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "leftPanel");

    self._leftPanelCtr = LeftPanelControll:New();
    self._leftPanelCtr:Init(self._leftPanel, EquipMainPanel.EqPanelClickHandler, self);

    self._fuling = UIUtil.GetChildByName(self._trsContent, "Transform", "fuling");
    self._jingnian = UIUtil.GetChildByName(self._trsContent, "Transform", "jingnian");
    self._shenqi = UIUtil.GetChildByName(self._trsContent, "Transform", "shenqi");
    self._gem = UIUtil.GetChildByName(self._trsContent, "Transform", "gem");
    self._qianghua = UIUtil.GetChildByName(self._trsContent, "Transform", "qianghua");
    self._equipSuit = UIUtil.GetChildByName(self._trsContent, "Transform", "equipSuit");

    self._uieffectParent = UIUtil.GetChildByName(self._trsContent, "effectParent")
    self._bg = UIUtil.GetChildByName(self._trsContent, "UISprite", "effectParent/bg")

    self._sucUIEffect = UIEffect:New()
    self._faildUIEffect = UIEffect:New()

    self._sucUIEffect:Init(self._uieffectParent, self._bg, 2, "ui_promote_s")
    self._faildUIEffect:Init(self._uieffectParent, self._bg, 2, "ui_promote_d")

    self._sucForSuitUIEffect = UIEffect:New()
    self._sucForSuitUIEffect:Init(self._uieffectParent, self._bg, 2, "ui_suit")


    -- 如何获取装备提示
    self.getEqTipPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "getEqTipPanel");
    -- local _ScrollView = UIUtil.GetChildByName(self.getEqTipPanel, "Transform", "ScrollView");
    self._eqTip_phalanx = UIUtil.GetChildByName(self.getEqTipPanel, "LuaAsynPhalanx", "ScrollView/bag_phalanx");
    self.mychtxt = UIUtil.GetChildByName(self.getEqTipPanel, "UILabel", "mychtxt");

    self:InitGetEqTip();

    self._equipDressTipPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "equipDressTipPanel");

    self._eqDressTipPanelCtr = EquipDressTipPanelControll:New();
    self._eqDressTipPanelCtr:Init(self._equipDressTipPanel)

    self._product_tabs = UIUtil.GetChildByName(self._trsContent, "Transform", "product_tabs");

    SetUIEnable(self.getEqTipPanel, false);

    self._fulingCtr = QianghuaPanelControll:New();
    self._fulingCtr:Init(self._fuling, self.getEqTipPanel);

    self._jinglianCtr = JingLianControll:New();
    self._jinglianCtr:Init(self._jingnian, self.getEqTipPanel);

    self._equipGemCtrl = EquipGemCtrl:New();
    self._equipGemCtrl:Init(self._gem, self.getEqTipPanel);


    self._newEquipQiangHuaPanel = NewEquipQiangHuaPanel:New()
    self._newEquipQiangHuaPanel:Init(self._qianghua)
    self._newEquipQiangHuaPanel:SetEqTipPanel(self.getEqTipPanel)

    self._equipSuitControll = EquipSuitControll:New();
    self._equipSuitControll:Init(self._equipSuit, self.getEqTipPanel)

    self:SetTagleHandler(EquipNotes.classify_1);
    self:SetTagleHandler(EquipNotes.classify_2);
    -- self:SetTagleHandler(EquipNotes.classify_3);
    self:SetTagleHandler(EquipNotes.classify_4);
    self:SetTagleHandler(EquipNotes.classify_5);
    self:SetTagleHandler(EquipNotes.classify_6);



    MessageManager.AddListener(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE, EquipMainPanel.EquipChange, self);

    MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, EquipMainPanel.BagChange, self);

    FixedUpdateBeat:Add(self.UpTime, self)


    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_EQUIPREFINERESULT, EquipMainPanel.EquipRefineResult, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_EQUIPSTRONGRESULT, EquipMainPanel.EquipStrongResult, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_EQUIPNEWSTRONGRESULT, EquipMainPanel.EquipNewStrongResult, self);
    MessageManager.AddListener(EquipProxy, EquipProxy.MESSAGE_EQUIP_SUIT_UPCOMPLETE, EquipMainPanel.SucForSuit, self);


    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_1_CHANGE, EquipMainPanel.Npoint_c1_change, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_2_CHANGE, EquipMainPanel.Npoint_c2_change, self);

    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_4_CHANGE, EquipMainPanel.Npoint_c4_change, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_5_CHANGE, EquipMainPanel.Npoint_c5_change, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_6_CHANGE, EquipMainPanel.Npoint_c6_change, self);


    MessageManager.AddListener(EquipProxy, EquipProxy.MESSAGE_EQUIP_STAR_CHANGE, EquipMainPanel.EquipStarChange, self);


    EquipProxy.TrySQGetSuitLvData();



end

function EquipMainPanel:TrySetDefulSelect()
    self._leftPanelCtr:TrySetDefulSelect()
end


--  前往 获取装备
function EquipMainPanel:InitGetEqTip()

    if self._eqTip_product_phalanx == nil then

        local t_num = table.getn(EquipMainPanel.getEquipTips);
        self._eqTip_product_phalanx = Phalanx:New();
        self._eqTip_product_phalanx:Init(self._eqTip_phalanx, ProductGetMsgPanelItem);
        self._eqTip_product_phalanx:Build(t_num, 1, EquipMainPanel.getEquipTips);
    end

    local myinfo = PlayerManager.GetPlayerInfo();
    local sex = myinfo:GetSex();

    if sex == 0 then
        self.mychtxt.text = LanguageMgr.Get("equip/jl/sx");
    else
        self.mychtxt.text = LanguageMgr.Get("equip/jl/lx");
    end



end

function EquipMainPanel:UpTime()

    -- self._trsContent.gameObject:SetActive(false);
    -- self._trsContent.gameObject:SetActive(true);
    FixedUpdateBeat:Remove(self.UpTime, self)

    EquipDataManager.CheckMainEqBtNeedShowTip();

end

function EquipMainPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);


end





function EquipMainPanel:EqPanelClickHandler(eqPanelControll)


    self._leftPanelCtr.currSelect = eqPanelControll;
    self._select_eqPanelControll = eqPanelControll;
    SetUIEnable(self.getEqTipPanel, false);
    -- self.getEqTipPanel.gameObject:SetActive(false);
    if eqPanelControll ~= nil then
        local kind = eqPanelControll.kind;
        self._leftPanelCtr:CheckSelect(kind);

    end

    if self._curr_classify == EquipNotes.classify_1 then

        self._fulingCtr:EqPanelClickHandler(eqPanelControll);

    elseif self._curr_classify == EquipNotes.classify_2 then

        self._jinglianCtr:EqPanelClickHandler(eqPanelControll)

        -- elseif self._curr_classify == EquipNotes.classify_3 then
        --  ShenQiControll.EqPanelClickHandler(eqPanelControll);
    elseif self._curr_classify == EquipNotes.classify_4 then
        self._equipGemCtrl:EqPanelClickHandler(eqPanelControll)
    elseif self._curr_classify == EquipNotes.classify_5 then

        -- 装备栏被点击的时候
        local select_kind = self:GetSelectEqKind();
        self._newEquipQiangHuaPanel:UpdatePanel(select_kind)

    elseif self._curr_classify == EquipNotes.classify_6 then
        self._equipSuitControll:EqPanelClickHandler(eqPanelControll);
    end

end

function EquipMainPanel:SetTagleHandler(name)

    self[name .. "Handler"] = function(go) self:Classify_OnClick(name) end
    self["_" .. name] = UIUtil.GetChildByName(self._product_tabs, "Transform", name).gameObject;

    self.isOpen = true;
    if name == EquipNotes.classify_4 then
        self.isOpen = SystemManager.IsOpen(SystemConst.Id.Gem);
        self["_" .. name]:SetActive(self.isOpen);
        -- elseif name == EquipNotes.classify_3 then
        --     self.isOpen = SystemManager.IsOpen(SystemConst.Id.ShenQi);
        --     self["_" .. name]:SetActive(self.isOpen);
    elseif name == EquipNotes.classify_1 then
        self.isOpen = SystemManager.IsOpen(SystemConst.Id.EquipFuLing);
        self["_" .. name]:SetActive(self.isOpen);
    elseif name == EquipNotes.classify_2 then
        self.isOpen = SystemManager.IsOpen(SystemConst.Id.EquipRefine);
        self["_" .. name]:SetActive(self.isOpen);
    elseif name == EquipNotes.classify_5 then
        self.isOpen = SystemManager.IsOpen(SystemConst.Id.EquipNewStrong);
        self["_" .. name]:SetActive(self.isOpen);
    elseif name == EquipNotes.classify_6 then
        self.isOpen = SystemManager.IsOpen(SystemConst.Id.EquipSuit);
        self["_" .. name]:SetActive(self.isOpen);
    end

    if self.isOpen then
        UIUtil.GetComponent(self["_" .. name], "LuaUIEventListener"):RegisterDelegate("OnClick", self[name .. "Handler"]);
    end

    self["_" .. name .. "_npoint"] = UIUtil.GetChildByName(self["_" .. name], "Transform", "npoint").gameObject;
    self["_" .. name .. "_npoint"]:SetActive(false);


    -- if name == EquipNotes.classify_1 then
    --     self["_" .. name .. "_npoint"] = UIUtil.GetChildByName(self["_" .. name], "Transform", "npoint").gameObject;
    --     self["_" .. name .. "_npoint"]:SetActive(false);
    -- elseif name == EquipNotes.classify_2 then
    --     self["_" .. name .. "_npoint"] = UIUtil.GetChildByName(self["_" .. name], "Transform", "npoint").gameObject;
    --     self["_" .. name .. "_npoint"]:SetActive(false);
    -- elseif name == EquipNotes.classify_3 then
    --     self["_" .. name .. "_npoint"] = UIUtil.GetChildByName(self["_" .. name], "Transform", "npoint").gameObject;
    --     self["_" .. name .. "_npoint"]:SetActive(false);
    -- elseif name == EquipNotes.classify_4 then
    --     self["_" .. name .. "_npoint"] = UIUtil.GetChildByName(self["_" .. name], "Transform", "npoint").gameObject;
    --     self["_" .. name .. "_npoint"]:SetActive(false);
    -- end
end


function EquipMainPanel:Npoint_x_change(classify, data)
    local b = data.result;

    if b then
        self["_" .. classify .. "_npoint"]:SetActive(true);
    else
        self["_" .. classify .. "_npoint"]:SetActive(false);
    end

    if self._curr_classify == classify then
      self._leftPanelCtr:CheckAndSetNpointV(data.resuleData);
    end 
   
end

function EquipMainPanel:Npoint_c1_change(data)

    self:Npoint_x_change(EquipNotes.classify_1, data);
end

function EquipMainPanel:Npoint_c2_change(data)
    self:Npoint_x_change(EquipNotes.classify_2, data);
end



function EquipMainPanel:Npoint_c4_change(data)
    self:Npoint_x_change(EquipNotes.classify_4, data);
end

function EquipMainPanel:Npoint_c5_change(data)
    self:Npoint_x_change(EquipNotes.classify_5, data);
end

function EquipMainPanel:Npoint_c6_change(data)
    self:Npoint_x_change(EquipNotes.classify_6, data);
end


function EquipMainPanel:RemoveTagleHandler(name)
    UIUtil.GetComponent(self["_" .. name], "LuaUIEventListener"):RemoveDelegate("OnClick");
    self[name .. "Handler"] = nil;
end


function EquipMainPanel:SetTagleSelect(name)
    local gobj = UIUtil.GetChildByName(self._product_tabs, "Transform", name).gameObject;
    local toggle = UIUtil.GetComponent(gobj, "UIToggle");
    toggle.value =(true);
end

function EquipMainPanel:BagChange()
 local select_kind = self:GetSelectEqKind();
    if self._curr_classify == EquipNotes.classify_1 then

        self._fulingCtr:Updata(select_kind);
        self._fulingCtr:UpIntensifyMaterials(true);

    elseif self._curr_classify == EquipNotes.classify_2 then
        self._jinglianCtr:Updata(select_kind);

    elseif self._curr_classify == EquipNotes.classify_5 then

        local select_kind = self:GetSelectEqKind();
        self._newEquipQiangHuaPanel:UpdatePanel(select_kind)
        self._leftPanelCtr:UpEqBagForNewEquipStrong()
        EquipDataManager.Check_Npoint(EquipNotes.classify_5);

    elseif self._curr_classify == EquipNotes.classify_6 then
        local select_kind = self:GetSelectEqKind();
        self._equipSuitControll:upDataByKind(select_kind)
    end


    self._leftPanelCtr:UpFightPower();
end

function EquipMainPanel:EquipChange()
 local select_kind = self:GetSelectEqKind();
    if self._curr_classify == EquipNotes.classify_1 then
        self._fulingCtr:Updata(select_kind);
        self._fulingCtr:UpIntensifyMaterials(true);
    elseif self._curr_classify == EquipNotes.classify_2 then
        self._jinglianCtr:Updata(select_kind);

    elseif self._curr_classify == EquipNotes.classify_4 then
        self._equipGemCtrl:Updata(select_kind);
    elseif self._curr_classify == EquipNotes.classify_5 then
        local select_kind = self:GetSelectEqKind();
        self._newEquipQiangHuaPanel:UpdatePanel(select_kind)
        self._leftPanelCtr:UpEqBagForNewEquipStrongByKind(select_kind);

    elseif self._curr_classify == EquipNotes.classify_6 then
        local select_kind = self:GetSelectEqKind();
        self._equipSuitControll:upDataByKind(select_kind)
    end

    self._leftPanelCtr:UpFightPower();

end

--[[获取当前选择的装备
]]
function EquipMainPanel:GetSelectEqKind()

    if self._select_eqPanelControll ~= nil then
        return self._select_eqPanelControll.kind;
    end

    return self._leftPanelCtr:GetSelectKind();
end



function EquipMainPanel:EquipStarChange(kind)

    --[[
    if kind ~= nil then

        local eqinfo = EquipDataManager.GetProductByKind(kind);
        local newStar = eqinfo:GetStar();

        ShenQiControll.TryShowEffect(newStar);

    end
    ]]
end

function EquipMainPanel:Classify_OnClick(name)
   
    if self._curr_classify ~= name then
        self._curr_classify = name;
         local select_kind = self:GetSelectEqKind();

        if name == EquipNotes.classify_1 then
            LogHttp.SendOperaLog(LanguageMgr.Get("equip/qh/label1"))

            SetUIEnable(self._fuling, true);
            SetUIEnable(self._jingnian, false);
            SetUIEnable(self._shenqi, false);
            SetUIEnable(self._gem, false);
            SetUIEnable(self._qianghua, false);
            SetUIEnable(self._equipSuit, false);

            self._fulingCtr.eqPanelControlls = self._leftPanelCtr.eqPanelControlls;
            self._fulingCtr:Updata(select_kind);

            self._leftPanelCtr:ShowForOther()
            SequenceManager.TriggerEvent(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, 1)
        elseif name == EquipNotes.classify_2 then
            LogHttp.SendOperaLog(LanguageMgr.Get("equip/qh/label2"))

            SetUIEnable(self._fuling, false);
            SetUIEnable(self._jingnian, true);
            SetUIEnable(self._shenqi, false);
            SetUIEnable(self._gem, false);
            SetUIEnable(self._qianghua, false);
            SetUIEnable(self._equipSuit, false);


            self._jinglianCtr.eqPanelControlls = self._leftPanelCtr.eqPanelControlls;
            self._jinglianCtr:Updata(select_kind);

            self._leftPanelCtr:ShowForOther()
            SequenceManager.TriggerEvent(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, 2)


        elseif name == EquipNotes.classify_4 then
            LogHttp.SendOperaLog(LanguageMgr.Get("equip/qh/label4"))

            SetUIEnable(self._fuling, false);
            SetUIEnable(self._jingnian, false);
            SetUIEnable(self._shenqi, false);
            SetUIEnable(self._gem, true);
            SetUIEnable(self._qianghua, false);
            SetUIEnable(self._equipSuit, false);


            self._equipGemCtrl.eqPanelControlls = self._leftPanelCtr.eqPanelControlls;
            self._equipGemCtrl:Updata(select_kind);
            self._leftPanelCtr:ShowForOther()
            SequenceManager.TriggerEvent(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, 4)
        elseif name == EquipNotes.classify_5 then
            LogHttp.SendOperaLog(LanguageMgr.Get("equip/qh/label5"))
            SetUIEnable(self._fuling, false);
            SetUIEnable(self._jingnian, false);
            SetUIEnable(self._shenqi, false);
            SetUIEnable(self._gem, false);
            SetUIEnable(self._qianghua, true);
            SetUIEnable(self._equipSuit, false);


            self._leftPanelCtr:UpEqBagForNewEquipStrong()
            local select_kind = self:GetSelectEqKind();
            self._newEquipQiangHuaPanel:UpdatePanel(select_kind)

            self._leftPanelCtr:ShowForOther()
            SequenceManager.TriggerEvent(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, 5);

        elseif name == EquipNotes.classify_6 then
            LogHttp.SendOperaLog(LanguageMgr.Get("equip/qh/label6"))
            SetUIEnable(self._fuling, false);
            SetUIEnable(self._jingnian, false);
            SetUIEnable(self._shenqi, false);
            SetUIEnable(self._gem, false);
            SetUIEnable(self._qianghua, false);
            SetUIEnable(self._equipSuit, true);

           
            self._equipSuitControll:upDataByKind(select_kind)

            self._equipSuitControll:UpLeftEqs()


            self._leftPanelCtr:ShowForOther()
            SequenceManager.TriggerEvent(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, 6);
        end

        for k, v in pairs(self._leftPanelCtr.eqPanelControlls) do
            v:SetShowGem(name == EquipNotes.classify_4);
            -- v:SetShowStar(name == EquipNotes.classify_3);
        end
        -- 宝石标签不用重新计算.
        EquipDataManager.Check_Npoint(self._curr_classify);
    end

end





function EquipMainPanel:_OnClickBtn_close()


    SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
    ModuleManager.SendNotification(EquipNotes.CLOSE_EQUIPMAINPANELL);

end



--[[0A 装备栏精炼¶
输入：
idx:装备部位 0到7
输出：
idx:装备部位 0到7
rlv：精炼等级

]]
function EquipMainPanel:EquipRefineResult(data)

 local select_kind = self:GetSelectEqKind();
    self._jinglianCtr:TryShowEffect();
    self._jinglianCtr:Updata(select_kind);
    self._leftPanelCtr:UpFightPower()
end

--[[09 装备栏强化
输入：
idx:装备部位 0到7
items：[道具ID,...]
amouts：[对应的数量]

输出：
idx:装备部位 0到7
slv：强化等级
exp：经验


]]
-- {"idx":0,"slv":1,"sexp":1}
function EquipMainPanel:EquipStrongResult(data)
    local select_kind = self:GetSelectEqKind();
    self._fulingCtr:SelectQualitysReset();
    self._fulingCtr:UpIntensifyMaterials();
    self._fulingCtr:Updata(select_kind);
    self._fulingCtr:UpPanel3();

    self._leftPanelCtr:UpFightPower()
end

function EquipMainPanel:UpData(classify)
    classify = classify or EquipNotes.classify_5;
    self:SetTagleSelect(classify);
    self:Classify_OnClick(classify);
end


function EquipMainPanel:_Dispose()
    if (self._sucUIEffect) then
        self._sucUIEffect:Dispose()
        self._sucUIEffect = nil
    end

    if (self._faildUIEffect) then
        self._faildUIEffect:Dispose()
        self._faildUIEffect = nil
    end

    if (self._sucForSuitUIEffect) then
        self._sucForSuitUIEffect:Dispose()
        self._sucForSuitUIEffect = nil
    end

    self:_DisposeListener();
    self:_DisposeReference();
end



function EquipMainPanel:SucForSuit()

    self._sucForSuitUIEffect:Stop();
    self._sucForSuitUIEffect:Play();

   self:Classify_OnClick(self._curr_classify);
   EquipDataManager.Check_Npoint_for_classify_6();

end


function EquipMainPanel:EquipNewStrongResult(suc)

    self._sucUIEffect:Stop()
    self._faildUIEffect:Stop()
    if (suc) then
        self._sucUIEffect:Play()
    else
        self._faildUIEffect:Play()
    end

    local select_kind = self:GetSelectEqKind();
    self._newEquipQiangHuaPanel:UpdatePanel(select_kind);

    self._leftPanelCtr:UpEqBagForNewEquipStrongByKind(select_kind);
    self._leftPanelCtr:UpFightPower()
end

function EquipMainPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;




    MessageManager.RemoveListener(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE, EquipMainPanel.EquipChange);
    MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, EquipMainPanel.BagChange);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_EQUIPREFINERESULT, EquipMainPanel.EquipRefineResult);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_EQUIPSTRONGRESULT, EquipMainPanel.EquipStrongResult);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_EQUIPNEWSTRONGRESULT, EquipMainPanel.EquipNewStrongResult, self);
    MessageManager.RemoveListener(EquipProxy, EquipProxy.MESSAGE_EQUIP_SUIT_UPCOMPLETE, EquipMainPanel.SucForSuit);

    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_1_CHANGE, EquipMainPanel.Npoint_c1_change);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_2_CHANGE, EquipMainPanel.Npoint_c2_change);

    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_4_CHANGE, EquipMainPanel.Npoint_c4_change);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_5_CHANGE, EquipMainPanel.Npoint_c5_change);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_6_CHANGE, EquipMainPanel.Npoint_c6_change);

    MessageManager.RemoveListener(EquipProxy, EquipProxy.MESSAGE_EQUIP_STAR_CHANGE, EquipMainPanel.EquipStarChange);


    self._leftPanelCtr:Dispose();
    self._leftPanelCtr = nil;
end

function EquipMainPanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_fuling = nil;

    self._fulingCtr:Dispose();
    self._fulingCtr = nil;

    self._jinglianCtr:Dispose();
    self._jinglianCtr = nil;

    self._equipGemCtrl:Dispose();
    self._equipGemCtrl = nil;

    -- ShenQiControll.Dispose();
    self._eqDressTipPanelCtr:Dispose();
    self._eqDressTipPanelCtr = nil;
    self._equipSuitControll:Dispose()

    self._coinBarCtrl:Dispose();

    if self._eqTip_product_phalanx ~= nil then

        self._eqTip_product_phalanx:Dispose();
    end


    self:RemoveTagleHandler(EquipNotes.classify_1);
    self:RemoveTagleHandler(EquipNotes.classify_2);
    -- self:RemoveTagleHandler(EquipNotes.classify_3);
    self:RemoveTagleHandler(EquipNotes.classify_4);
    self:RemoveTagleHandler(EquipNotes.classify_5);
    self:RemoveTagleHandler(EquipNotes.classify_6);

    EquipMainPanel.ins = nil;

end

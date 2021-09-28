require "Core.Module.Equip.controll.EquipPanelCtrl"
require "Core.Manager.Item.EquipLvDataManager"
require "Core.Manager.Item.BackpackDataManager"
require "Core.Manager.Item.RefineDataManager"
require "Core.Module.Equip.Item.ProductGetMsgPanelItem"
require "Core.Module.Equip.Item.ProductDressPanelItem"

require "Core.Module.Equip.controll.SelectQualityBtCtrl"

require "Core.Module.Equip.controll.SelectEquipPanelCtrl"
require "Core.Module.Equip.controll.ProductNeedPanelCtrl"


JingLianControll = class("JingLianControll")
function JingLianControll:New()
    self = { };
    setmetatable(self, { __index = JingLianControll });
    return self;
end


function JingLianControll:Init(gameObject, getEqTipPanel)
    self.getEquipTips = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GETEQUIPTIP);
    -- require "Core.Config.getEquipTip";

    self.gameObject = gameObject;


    self.rightPanel = UIUtil.GetChildByName(gameObject, "Transform", "rightPanel");

    self.panel1 = getEqTipPanel;

    self.panel3 = UIUtil.GetChildByName(self.rightPanel, "Transform", "panel3");



    ---------------------------------------------------------------------------------------------------------------------



    ------------------------------------------------------------------------------------
    local eq_select = UIUtil.GetChildByName(self.panel3, "Transform", "eq_select");
    self.p3_eq_select = SelectEquipPanelCtrl:New();
    self.p3_eq_select:Init(eq_select.gameObject, 1, false);

    -- --------------------------
    local ProductNeedPanel1 = UIUtil.GetChildByName(self.panel3, "Transform", "ProductNeedPanel1");
    self.ProductNeedPanelCtrl1 = ProductNeedPanelCtrl:New();
    self.ProductNeedPanelCtrl1:Init(ProductNeedPanel1.gameObject);

    local ProductNeedPanel2 = UIUtil.GetChildByName(self.panel3, "Transform", "ProductNeedPanel2");
    self.ProductNeedPanelCtrl2 = ProductNeedPanelCtrl:New();
    self.ProductNeedPanelCtrl2:Init(ProductNeedPanel2.gameObject);

    local ProductNeedPanel3 = UIUtil.GetChildByName(self.panel3, "Transform", "ProductNeedPanel3");
    self.ProductNeedPanelCtrl3 = ProductNeedPanelCtrl:New();
    self.ProductNeedPanelCtrl3:Init(ProductNeedPanel3.gameObject);

    self.needCostMoneyTxt = UIUtil.GetChildByName(self.panel3, "UILabel", "needCostMoneyTxt");
    self.needCostMoneyIcon = UIUtil.GetChildByName(self.panel3, "Transform", "needCostMoneyIcon");
    self.btn_jinglian = UIUtil.GetChildByName(self.panel3, "UIButton", "btn_jinglian");

     self._onClickBtn_jinglian = function(go) self:_OnClickBtn_jinglian(self) end
    UIUtil.GetComponent(self.btn_jinglian, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_jinglian);


    self.currSelectKind = 1;
end


function JingLianControll:_OnClickBtn_jinglian()
    local idx = self:GetSelectIdx();
    EquipProxy.TryEquipRefine(idx);
    SequenceManager.TriggerEvent(SequenceEventType.Guide.EQUIP_REFINE)
end

function JingLianControll:EqPanelClickHandler(eqPanelControll)

    local kind = eqPanelControll.kind;

    self:LeftSelectIndex(kind);

end


function JingLianControll:TryShowEffect()


    self.p3_eq_select:TryShowEffect();

end

function JingLianControll:LeftSelectIndex(kind)

    self.currSelectKind = kind;
    local selectCtr = nil;

    for i = 1, 8 do
        if i == kind then
            selectCtr = self.eqPanelControlls[i];
            selectCtr:Selected(true);

        else
            self.eqPanelControlls[i]:Selected(false);
        end
    end
    self:CheckSelectCtr(selectCtr, kind);

end


function JingLianControll:CheckSelectCtr(selectCtr, kind)

    self.currSelectCtr = selectCtr;
    self.currInfo = nil;
    if selectCtr ~= nil then
        self.currInfo = selectCtr._productInfo;
        if selectCtr._productInfo == nil then
            -- 装备栏没有装备  ,需要 到背包中 找对应的 可穿戴的装备， 如果 有，那么现实  穿戴 界面， 如果没有， 那么显示 装备获取来源 界面
            local me = HeroController:GetInstance();
            local heroInfo = me.info;

            local bag_equips = BackpackDataManager.GetFixMyEqByTypeAndKind(1, kind, heroInfo.kind);
            local t_num = table.getn(bag_equips);

            if t_num > 0 then
                -- 背包 里有对应的装备
                SetUIEnable(self.panel1, false);
                -- self.panel1.gameObject:SetActive(false);
                MessageManager.Dispatch(EquipNotes,EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_SHOW);
                self.panel3.gameObject:SetActive(false);
                self:UpPanel2(bag_equips);

            else
                -- 背包里没有找到对应的装备
                SetUIEnable(self.panel1, true);
                -- self.panel1.gameObject:SetActive(true);
                MessageManager.Dispatch(EquipNotes,EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE);
                self.panel3.gameObject:SetActive(false);
            end


        else
            SetUIEnable(self.panel1, false);
            -- self.panel1.gameObject:SetActive(false);
            MessageManager.Dispatch(EquipNotes,EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE);
            self.panel3.gameObject:SetActive(true);
            self:UpPanel3(selectCtr)

        end

    end

end







-- 穿上装备
function JingLianControll:UpPanel2(bag_equips)

    local eqs = EquipDataManager.GetEqBySort(bag_equips);
   MessageManager.Dispatch(EquipNotes,EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_UPDATA,eqs);

end

function JingLianControll:GetSelectIdx()
    local index = self.select_idx - 1;
    return index;
end

-- 参数 selectCtr  不能去掉
function JingLianControll:UpPanel3(selectCtr)

    if selectCtr ~= nil then

        local equip_lv_data = selectCtr.equip_lv_data;
        self.select_idx = selectCtr.equip_lv_data.idx;

        -- equip_lv:[{idx 部位0开始,slv强化等级,sexp强化经验,rlv精炼等级},..]
        self.p3_eq_select:SetData(equip_lv_data);

        local eq_select_name = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_name");
        local eq_select_qianghua = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_qianghua");

        local hasUpToMaxTipTxt = UIUtil.GetChildByName(self.panel3, "UILabel", "hasUpToMaxTipTxt");

        hasUpToMaxTipTxt.gameObject:SetActive(false);

        local info = self.p3_eq_select._productInfo;


        eq_select_qianghua.text = LanguageMgr.Get("equip/jl/jinglianLabelAdd") .. equip_lv_data.rlv;

        ----------------------------
        local rlv = equip_lv_data.rlv;
        local refData = nil;
        local refData_next = nil;

        local kind = info:GetKind();
        local quality = info:GetQuality();
        local lev = info:GetLevel();

        if quality < 5 then
            eq_select_name.text = ColorDataManager.GetColorTextByQuality(quality, info:GetName());
        else
            local n = info:GetName();
            eq_select_name.text = ColorDataManager.GetColorTextByQuality(quality, n);
        end

        local me = HeroController:GetInstance();
        local heroInfo = me.info;
        local my_career = heroInfo:GetCareer()

        -- kind, career,refine_lev

        self.btn_jinglian.enabled = true;
        self.btn_jinglian.gameObject:SetActive(true);

        -- http://192.168.0.8:3000/issues/7105
        if rlv == 0 then
            rlv = 1;
        end

        if rlv == 0 then
            refData = RefineDataManager.GetRefine_item(kind, my_career, 1);
            self:UpGLevelInfo(kind, refData, refData_next, rlv, equip_lv_data);
        else
            refData = RefineDataManager.GetRefine_item(kind, my_career, rlv);
            refData_next = RefineDataManager.GetRefine_item(kind, my_career, rlv + 1);

            if refData_next == nil then
                -- 说明  已经到最高等级了，
                self:UpMaxGLevelInfo(kind, refData);
                hasUpToMaxTipTxt.gameObject:SetActive(true);
            else
                self:UpGLevelInfo(kind, refData, refData_next, rlv, equip_lv_data);

            end
        end


    end


end

function JingLianControll:UpMaxGLevelInfo(kind, refData)

    local eq_select_att1 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_att1");
    local eq_select_upIcon1 = UIUtil.GetChildByName(self.panel3, "UISprite", "eq_select_upIcon1");
    local eq_select_extatt1 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extatt1");

    local eq_select_att2 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_att2");
    local eq_select_upIcon2 = UIUtil.GetChildByName(self.panel3, "UISprite", "eq_select_upIcon2");
    local eq_select_extatt2 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extatt2");

    local eq_select_extattCurr1 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extattCurr1");
    local eq_select_extattCurr2 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extattCurr2");


    local baseAtts = ProductInfo.GetSampleBaseAtt(self.currInfo.att_configData)

    local ownAtts = ProductInfo.GetSampleBaseAtt(refData)

    eq_select_att1.text = baseAtts[1].des .. ": " .. baseAtts[1].property;
    eq_select_att2.text = baseAtts[2].des .. ": " .. baseAtts[2].property;

    eq_select_extattCurr1.text = "+" .. ownAtts[1].property;
    eq_select_extattCurr2.text = "+" .. ownAtts[2].property;

    eq_select_upIcon1.gameObject:SetActive(false);
    eq_select_upIcon2.gameObject:SetActive(false);

    eq_select_extatt1.text = LanguageMgr.Get("equip/jl/max");
    eq_select_extatt2.text = LanguageMgr.Get("equip/jl/max");


    self.ProductNeedPanelCtrl1:SetMaxInfo();
    self.ProductNeedPanelCtrl2:SetMaxInfo();
    self.ProductNeedPanelCtrl3:SetMaxInfo();

    self.needCostMoneyTxt.gameObject:SetActive(false);
    self.needCostMoneyIcon.gameObject:SetActive(false);

    self.btn_jinglian.enabled = false;
    self.btn_jinglian.gameObject:SetActive(false);

    local tindex = 1;
    local need_item = refData.need_item;
    for key, pinfo in pairs(need_item) do
        self["ProductNeedPanelCtrl" .. tindex]:SetProduct(pinfo);
        self["ProductNeedPanelCtrl" .. tindex]:SetMaxInfo();
        tindex = tindex + 1;
    end
end


function JingLianControll:UpGLevelInfo(kind, refData, refData_next, rlv, equip_lv_data)

    local eq_select_att1 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_att1");
    local eq_select_upIcon1 = UIUtil.GetChildByName(self.panel3, "UISprite", "eq_select_upIcon1");
    local eq_select_extatt1 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extatt1");

    local eq_select_att2 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_att2");
    local eq_select_upIcon2 = UIUtil.GetChildByName(self.panel3, "UISprite", "eq_select_upIcon2");
    local eq_select_extatt2 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extatt2");

    local eq_select_extattCurr1 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extattCurr1");
    local eq_select_extattCurr2 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extattCurr2");

    local baseAtts = ProductInfo.GetSampleBaseAtt(self.currInfo.att_configData)

    eq_select_att1.text = baseAtts[1].des .. ": " .. baseAtts[1].property;
    eq_select_att2.text = baseAtts[2].des .. ": " .. baseAtts[2].property;



    eq_select_upIcon1.gameObject:SetActive(false);
    eq_select_extatt1.text = "";

    eq_select_upIcon2.gameObject:SetActive(false);
    eq_select_extatt2.text = "";

    local ownAtts = ProductInfo.GetSampleBaseAtt(refData)

    local ownAttsNext = ProductInfo.GetSampleBaseAtt(refData_next)

    local t_num = table.getn(ownAtts);

    if equip_lv_data.rlv == 0 then
        eq_select_extattCurr1.text = "+0"
        -- .. ownAtts[1].property ;

        if t_num > 1 then
            eq_select_extattCurr2.text = "+0"
            -- ..  ownAtts[2].property ;
        else
            eq_select_extattCurr2.text = "+0";
        end

    else

        eq_select_extattCurr1.text = "+" .. ownAtts[1].property;

        eq_select_upIcon1.gameObject:SetActive(true);
        eq_select_extatt1.text = "" ..(ownAttsNext[1].property - ownAtts[1].property);

        if t_num > 1 then
            eq_select_extattCurr2.text = "+" .. ownAtts[2].property;

            eq_select_upIcon2.gameObject:SetActive(true);
            eq_select_extatt2.text = "" ..(ownAttsNext[2].property - ownAtts[2].property);

        else
            eq_select_extattCurr2.text = "";
        end
    end

    --  设置消耗物品
    -- self.ProductNeedPanelCtrl3:SetProduct();

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_career = heroInfo:GetCareer()

    local needobj = RefineDataManager.GetRefine_item(kind, my_career, equip_lv_data.rlv + 1);
    local need_item = needobj.need_item;

    local tindex = 1;

    for key, pinfo in pairs(need_item) do
   
        self["ProductNeedPanelCtrl" .. tindex]:SetProduct(pinfo);
        tindex = tindex + 1;
    end

    --  设置需要金币
    local need_money = needobj.need_money;


    local my_md = tonumber(MoneyDataManager.Get_money());

    if my_md >= need_money then
        self.needCostMoneyTxt.text = "[94ade7]" .. LanguageMgr.Get("equip/jl/sh") .. need_money .. "[-]";

    else
        self.needCostMoneyTxt.text = "[94ade7]" .. LanguageMgr.Get("equip/jl/sh") .. "[-]" .. "[ff0000]" .. need_money .. "[-]";

    end

end

function JingLianControll:Updata(select_kind)

    for i = 1, 8 do
        local qx = EquipLvDataManager.getItem(i);
        self.eqPanelControlls[i]:SetShowGem(false);
        self.eqPanelControlls[i]:SetShowStar(false);
        self.eqPanelControlls[i]:SetData(qx, "rlv");
    end

    -- 默认选中对象
    self:LeftSelectIndex(select_kind);
end



function JingLianControll:Dispose()

  UIUtil.GetComponent(self.btn_jinglian, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_jinglian = nil;

    for i = 1, 3 do
        self["ProductNeedPanelCtrl" .. i]:Dispose();
        self["ProductNeedPanelCtrl" .. i] = nil;
    end

    self.product_pd_phalanx = nil;
    self.product_phalanx = nil;



    self.rightPanel = nil;

    self.panel1 = nil;

    self.panel3 = nil;

    self.p3_eq_select:Dispose()
    self.p3_eq_select = nil;


    self.needCostMoneyTxt = nil;
    self.needCostMoneyIcon = nil;
    self.btn_jinglian = nil;

    self.currSelectKind = nil;





end
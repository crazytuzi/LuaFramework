require "Core.Module.Equip.controll.EquipPanelCtrl"
require "Core.Manager.Item.EquipLvDataManager"
require "Core.Manager.Item.BackpackDataManager"
require "Core.Manager.Item.StrongExpDataManager"
require "Core.Manager.Item.ColorDataManager"
require "Core.Module.Equip.Item.ProductGetMsgPanelItem"
require "Core.Module.Equip.Item.ProductDressPanelItem"
require "Core.Module.Equip.Item.ProductCostPanelItem"

require "Core.Module.Equip.controll.SelectQualityBtCtrl"
require "Core.Module.Equip.controll.SliderControll"
require "Core.Module.Equip.controll.SelectEquipPanelCtrl"

QianghuaPanelControll = class("QianghuaPanelControll")
function QianghuaPanelControll:New()
    self = { };
    setmetatable(self, { __index = QianghuaPanelControll });
    return self;
end

local _sortfunc = table.sort;

function QianghuaPanelControll:Init(gameObject, getEqTipPanel)

    self.getEquipTips = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GETEQUIPTIP);

    self.currSelectKind = 1;
    self.intensifyMaterials_num = 0;

    self.oldSelectInfos = { };

    self.gameObject = gameObject;

    self.rightPanel = UIUtil.GetChildByName(gameObject, "Transform", "rightPanel");

    self.panel1 = getEqTipPanel;

    self.panel3 = UIUtil.GetChildByName(self.rightPanel, "Transform", "panel3");

    -----------------------------------------------------------------

    local eq_select = UIUtil.GetChildByName(self.panel3, "Transform", "eq_select");
    self.p3_eq_select = SelectEquipPanelCtrl:New();
    self.p3_eq_select:Init(eq_select.gameObject, 1, false);
    -----------------------------------------------------------------------------------

    --------------------------------------------------------------------------------------------------
    self._ScrollView = UIUtil.GetChildByName(self.panel3, "UIScrollView", "ScrollView");

    _ScrollViewTf = UIUtil.GetChildByName(self.panel3, "Transform", "ScrollView");
    self.es_phalanx = UIUtil.GetChildByName(_ScrollViewTf, "LuaAsynPhalanx", "es_phalanx");

    self.product_es_phalanx = Phalanx:New();
    self.product_es_phalanx:Init(self.es_phalanx, ProductCostPanelItem);


    self.selectQPanel = UIUtil.GetChildByName(self.panel3, "Transform", "selectQPanel");

    self.vip_exp_add = UIUtil.GetChildByName(self.panel3, "UILabel", "vip_exp_add");


    self.quality_num = 6;

    self.selectQualitys = { };
    for i = 1, self.quality_num do
        local selectQuality = UIUtil.GetChildByName(self.selectQPanel, "Transform", "selectQuality" .. i);

        self.selectQualitys[i] = SelectQualityBtCtrl:New();
        self.selectQualitys[i]:Init(selectQuality.gameObject, i);
        self.selectQualitys[i]:SetOnClickBtnHandler(self.SelectQualitysClickHandler, self);
    end

    ---------------------------------------------------------------
    self.expSlider = UIUtil.GetChildByName(self.panel3, "Transform", "expSlider");
    self.expSliderCtrl = SliderControll:New();
    self.expSliderCtrl:Init(self.expSlider, 305);
    -- 230

    self.btn_selectQ = UIUtil.GetChildByName(self.panel3, "UIButton", "btn_selectQ");

    self._obtn_selectQ_onClick = function(go) self:_btn_selectQ_onClick(self) end
    UIUtil.GetComponent(self.btn_selectQ, "LuaUIEventListener"):RegisterDelegate("OnClick", self._obtn_selectQ_onClick);

    self._btn_fuling = UIUtil.GetChildByName(self.panel3, "UIButton", "btn_fuling");

    self._onClickBtn_fuling = function(go) self:_OnClickBtn_fuling(self) end
    UIUtil.GetComponent(self._btn_fuling, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_fuling);


    self.currSelectIndex = nil;

    self.selectQPanelEnb = false;
    self.selectQPanel.gameObject:SetActive(self.selectQPanelEnb);

    ProductCostPanelItem.clickEnble = true;


    self._onClickselectQPanel = function(go) self:_OnClickselectQPanel(self) end
    UIUtil.GetComponent(self.selectQPanel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickselectQPanel);


end

function QianghuaPanelControll:TryShowSliderEffect()


    self.expSliderCtrl:TryShowEffect();


end

function QianghuaPanelControll:_OnClickselectQPanel()


    self.selectQPanel.gameObject:SetActive(false);

end


function QianghuaPanelControll:_OnClickBtn_fuling()

    -- http://192.168.0.8:3000/issues/4142
    if self.intensifyMaterials_num <= 0 then
        ProductGetProxy.TryShowGetUI(350001)
    end

    local sendData = self:GetQiangHuaNetData();
    local oldSlv = self.curr_slv;

    if sendData ~= nil then

        SequenceManager.TriggerEvent(SequenceEventType.Guide.EQUIP_FL_OPT);

        EquipProxy.needUpNPoint = true;
        EquipProxy.TryEquipStrong(sendData,
        function()
            -- 需要显示特效
            if self.p3_eq_select ~= nil then
                self.p3_eq_select:TryShowEffect();

                local newSlv = self.curr_slv;
                if newSlv > oldSlv then
                    self:TryShowSliderEffect()
                end

                UISoundManager.PlayUISound(UISoundManager.path_ui_enhance1);
            end

        end
        );
    else
        MsgUtils.ShowTips("equip/qh/tip1");
    end
end


function QianghuaPanelControll:_btn_selectQ_onClick()


    if self.selectQPanelEnb then
        self.selectQPanelEnb = false;
    else
        self.selectQPanelEnb = true;
    end

    self.selectQPanel.gameObject:SetActive(self.selectQPanelEnb);

end


function QianghuaPanelControll:SelectQualitysReset()

    for i = 1, self.quality_num do
        self.selectQualitys[i]:Selected(false);
    end

    self:UpPanel3BProductsByQuality(0);

    self.selectQPanelEnb = false;
    self.selectQPanel.gameObject:SetActive(self.selectQPanelEnb);
end

function QianghuaPanelControll:SelectQualitysClickHandler(selectQualitysCtrl)



    local index = selectQualitysCtrl.index;
    local select_qt = 1;

    for i = 1, self.quality_num do
        if self.selectQualitys[i] == selectQualitysCtrl then

            if self.selectQualitys[i].isSelect then
                self.selectQualitys[i]:Selected(false);
                select_qt = 0;
            else
                self.selectQualitys[i]:Selected(true);
                select_qt = i;
            end

        else
            self.selectQualitys[i]:Selected(false);
        end
    end

    self:UpPanel3BProductsByQuality(index);

    self.selectQPanelEnb = false;
    self.selectQPanel.gameObject:SetActive(self.selectQPanelEnb);

end

function QianghuaPanelControll:UpPanel3BProductsByQuality(ql)

    local eb = true;

    if self.currSelectIndex ~= ql then
        eb = true;
        self.currSelectIndex = ql;

    else
        eb = false;
        self.currSelectIndex = nil;
    end

    if self.product_es_phalanx ~= nil then


        local items = self.product_es_phalanx._items;
        for key, value in pairs(items) do

            local info = value.itemLogic.infoData;
            local fight_up = value.itemLogic.fight_up;
            if info ~= nil then
                local q = info:GetQuality() + 1;

                if q <= ql then

                    if eb and not fight_up then
                        value.itemLogic:SetSelect(true);
                    else
                        value.itemLogic:SetSelect(false);
                    end


                else
                    value.itemLogic:SetSelect(false);
                end

            else
                value.itemLogic:SetSelect(false);
            end

        end
    end


end



function QianghuaPanelControll:EqPanelClickHandler(eqPanelControll)

    local kind = eqPanelControll.kind;

    self:LeftSelectIndex(kind);
end

function QianghuaPanelControll:LeftSelectIndex(kind)

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

function QianghuaPanelControll:CheckSelectCtr(selectCtr, kind)

    self.currSelectCtr = selectCtr;

    if selectCtr ~= nil then


        if selectCtr._productInfo == nil then
            -- 装备栏没有装备  ,需要 到背包中 找对应的 可穿戴的装备， 如果 有，那么现实  穿戴 界面， 如果没有， 那么显示 装备获取来源 界面
            local me = HeroController:GetInstance();
            local heroInfo = me.info;


            local bag_equips = BackpackDataManager.GetFixMyEqByTypeAndKind(1, kind, heroInfo.kind);
            local t_num = table.getn(bag_equips);

            if t_num > 0 then
                -- 背包 里有对应的装备
                SetUIEnable(self.panel1, false);
                MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_SHOW);
                self.panel3.gameObject:SetActive(false);
                self:UpPanel2(bag_equips);

            else
                -- 背包里没有找到对应的装备
                SetUIEnable(self.panel1, true);
                MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE);
                self.panel3.gameObject:SetActive(false);

            end


        else
            SetUIEnable(self.panel1, false);
            MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE);
            self.panel3.gameObject:SetActive(true);
            self:UpPanel3()

        end

    end

end








-- 穿上装备
function QianghuaPanelControll:UpPanel2(bag_equips)

    -- 需要进行排序
    local eqs = EquipDataManager.GetEqBySort(bag_equips);
    MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_UPDATA, eqs);

end


function QianghuaPanelControll:CheckOldSelet(infoctrPanel)

    local infoData = infoctrPanel.infoData;
    if infoData ~= nil then
        local i_id = infoData:GetId();
        local b = self.oldSelectInfos[i_id .. ""];
        if b then

            infoctrPanel:SetSelect(true);
        end
    end

end


-- 材料 quality >4 的都需要过滤
function QianghuaPanelControll:UpIntensifyMaterials(us_ql)

    if self.product_es_phalanx ~= nil then

        local intensifyMaterials = BackpackDataManager.GetMaterialsBySort();


        local t_num = table.getn(intensifyMaterials);

        local tem_w_num = t_num / 4;
        local w_num = math.ceil(tem_w_num);
        self.product_es_phalanx:Build(w_num, 4, intensifyMaterials);


    end

    if us_ql then
        if self.currSelectIndex ~= nil then
            local tem = self.currSelectIndex;
            self.currSelectIndex = nil;
            self:UpPanel3BProductsByQuality(tem);
        end


    else
        self.currSelectIndex = nil;
    end

    self._ScrollView:SetDragAmount(0, 0, false);

    if us_ql == nil then

        self:UpOldSelected();
    end


end

function QianghuaPanelControll:UpOldSelected()
    if self.product_es_phalanx ~= nil then

        local items = self.product_es_phalanx._items;
        for key, value in pairs(items) do
            self:CheckOldSelet(value.itemLogic)
        end
    end

    self.oldSelectInfos = { };
end


-- 强化
function QianghuaPanelControll:UpPanel3()

    local selectCtr = self.currSelectCtr;
    if selectCtr ~= nil then
        --------------------------- 获取 对应的材料 -------------------------------------
        if self.product_es_phalanx ~= nil then
            -- 获取 背包里 可用的 物品 条件是：  type==1   ||  type==3 & kind==1
            local intensifyMaterials = BackpackDataManager.GetMaterialsBySort();

            local t_num = table.getn(intensifyMaterials);
            self.intensifyMaterials_num = t_num;



            if t_num > 0 then

                local tem_w_num = t_num / 4;
                local w_num = math.ceil(tem_w_num);


                self.product_es_phalanx:Build(w_num, 4, intensifyMaterials);

                local items = self.product_es_phalanx._items;
                for key, value in pairs(items) do
                    value.itemLogic:SetSelecteHandler(self.OnProductEsSelect, self);
                end

            end

        end
        --------------------------------------------------------------------------

        local equip_lv_data = selectCtr.equip_lv_data;


        self.p3_eq_select:SetData(equip_lv_data);

        local eq_select_name = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_name");


        -- equip_lv":[{"idx":0,"slv":1,"rlv":0,"sexp":0}
        -----------------------------------------------------------------------------------
        local info = self.p3_eq_select._productInfo;

        self.total_exp = StrongExpDataManager.GetExp(info:GetKind(), equip_lv_data.slv);

        local quality = info:GetQuality();

        if quality < 5 then
            eq_select_name.text = ColorDataManager.GetColorTextByQuality(quality, info:GetName());
        else

            local n = info:GetName();
            eq_select_name.text = ColorDataManager.GetColorTextByQuality(quality, n);
        end



        -------------------------------------------------------------------------------------
        self:Product_es_phalanxChange();



    end

end

function QianghuaPanelControll:OnProductEsSelect()
    self:Product_es_phalanxChange();
    SequenceManager.TriggerEvent(SequenceEventType.Guide.EQUIP_FL_SELECT);
end

function QianghuaPanelControll:TryGetTotalExp()

    local exp_value_total = 0;

    local items = self.product_es_phalanx._items;
    local needPros = { };
    -- 需要需要消耗的材料
    local index = 1;

    for key, value in pairs(items) do
        -- 获取选中的 对象

        if value.itemLogic.selected then
            local info = value.data;
            local ev = info:GetExp_value();
            exp_value_total = exp_value_total + ev;

            needPros[index] = value.data;
            index = index + 1;

        end
    end


    if index > 2 then

        -- 通过 exp_value 进行排序
        -- 对已经选中的 道具 通过  拥有 经验值 从小到大进行排序
        _sortfunc(needPros, function(a, b)

            local a_exp_value = a:GetExp_value();
            local b_exp_value = b:GetExp_value();

            if (a_exp_value > b_exp_value) then
                return true
            else
                return false
            end
        end );

    end

    return exp_value_total;

end

--  需要计算 总值
function QianghuaPanelControll:Product_es_phalanxChange()

    local eq_select_upIcon1 = UIUtil.GetChildByName(self.panel3, "UISprite", "eq_select_upIcon1");
    local eq_select_extatt1 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extatt1");

    local eq_select_upIcon2 = UIUtil.GetChildByName(self.panel3, "UISprite", "eq_select_upIcon2");
    local eq_select_extatt2 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extatt2");


    eq_select_extatt1.text = "";
    eq_select_extatt2.text = "";



    eq_select_upIcon1.gameObject:SetActive(false);
    eq_select_upIcon2.gameObject:SetActive(false);


    if self.product_es_phalanx ~= nil then
        -- 尝试 获取选中 目标
        local exp_value_total = self:TryGetTotalExp();

        -- 根据自己的等级 去除多余的 消耗物品
        self:UpPanel3ByAddExp(exp_value_total);


    else

        -- log("   error ---->");
        local eq_select_qianghua = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_qianghua");
        local eq_select_att1 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_att1");
        local eq_select_att2 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_att2");

        -- 需要设置  基础属性
        local baseAtts = ProductInfo.GetSampleBaseAtt(selectInfo.att_configData)
        local baseAtt_len = table.getn(baseAtts);

        local currLv = 0;

        eq_select_qianghua.text = LanguageMgr.Get("equip/jl/qianhuaLabelAdd") .. currLv;


        eq_select_att1.text = baseAtts[1].des .. ": " .. baseAtts[1].property;
        if baseAtt_len > 1 then
            eq_select_att2.text = baseAtts[2].des .. ": " .. baseAtts[2].property;
        end


        self:UpPanel3ByAddExp(0);
    end


end


function QianghuaPanelControll:TraceInfos(res)

    --------------------------------------------- 测试打印  ---------------------------------------------------------------------

    local canUpLv = res.canUpLv;
    if canUpLv then
        local upLvInfos = res.upLvInfos;
        local curr_slv = res.curr_slv;

        local t_num = table.getn(upLvInfos);

        -- log("---添加显示--> " .. t_num);

        for i = 1, t_num do
            local lastInfo = upLvInfos[i];

            log("等级: " .. curr_slv .. " + " .. lastInfo.dlv .. "  经验：" .. lastInfo.baseExp .. "  + " .. lastInfo.extExp .. " / " .. lastInfo.parenExp);

            if i == t_num then

                log("强化后强化属性为");

            end

        end


    else
        if res.canNotType == 1 then
            log("到达满级， 不需要升级");
        elseif res.canNotType == 2 then
            log("经验不足够升级");
        end

    end


    ------------------------------------------------------------------------------------------------------------------


end

--[[
获取 当前的  强化 等级 添加

]]
function QianghuaPanelControll:ShowEuqipSampleInfo(data, selectInfo)



    local eq_select_qianghua = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_qianghua");
    local eq_select_att1 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_att1");
    local eq_select_upIcon1 = UIUtil.GetChildByName(self.panel3, "UISprite", "eq_select_upIcon1");
    local eq_select_extatt1 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extatt1");
    local eq_select_extattCurr1 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extattCurr1");

    local eq_select_att2 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_att2");
    local eq_select_upIcon2 = UIUtil.GetChildByName(self.panel3, "UISprite", "eq_select_upIcon2");
    local eq_select_extatt2 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extatt2");
    local eq_select_extattCurr2 = UIUtil.GetChildByName(self.panel3, "UILabel", "eq_select_extattCurr2");

    eq_select_upIcon1.gameObject:SetActive(false);
    eq_select_extatt1.gameObject:SetActive(false);

    eq_select_upIcon2.gameObject:SetActive(false);
    eq_select_extatt2.gameObject:SetActive(false);




    local canUpLv = data.canUpLv;
    local upLvInfos = data.upLvInfos;
    local curr_slv = data.curr_slv;

    local baseAtts = ProductInfo.GetSampleBaseAtt(selectInfo.att_configData)
    -- selectInfo:GetOwnBaseAtt();
    local baseAtt_len = table.getn(baseAtts);

    -- local temInfo = selectInfo:Clone();
    -- temInfo.att_configData = StrongExpDataManager.GetExtStrongAtt(temInfo, curr_slv);
    local tcf = StrongExpDataManager.GetExtStrongAtt(selectInfo, curr_slv);


    local base_ext_att = ProductInfo.GetSampleBaseAtt(tcf)
    -- temInfo:GetOwnBaseAtt();


    eq_select_extattCurr1.text = ""
    eq_select_extattCurr2.text = ""
    ----------------------------------------------------------------------------------------------------------------

    if canUpLv then
        local t_num = table.getn(upLvInfos);

        local lastInfo = upLvInfos[t_num];

        if lastInfo.dlv > 0 then
            eq_select_qianghua.text = LanguageMgr.Get("equip/jl/qianhuaLabelAdd") .. curr_slv .. "  [00ff00]+" .. lastInfo.dlv .. "[-]";


            ---------------------------------------------------------------------------------------------------------------------------
            -- 属性长度

            if curr_slv > 0 then
                eq_select_att1.text = baseAtts[1].des .. ": " .. baseAtts[1].property;

                eq_select_extattCurr1.text = "+" .. base_ext_att[1].property;

                if baseAtt_len > 1 then
                    eq_select_att2.text = baseAtts[2].des .. ": " .. baseAtts[2].property;
                    eq_select_extattCurr2.text = "+" .. base_ext_att[2].property;
                end
            else
                eq_select_att1.text = baseAtts[1].des .. ": " .. baseAtts[1].property;
                eq_select_extattCurr1.text = "+0";
                if baseAtt_len > 1 then
                    eq_select_att2.text = baseAtts[2].des .. ": " .. baseAtts[2].property;
                    eq_select_extattCurr2.text = "+0";
                end
            end
            ---------------------------------------------------------------------------------------------------------------------------


            --  log("--- lastInfo.upToLv  " .. lastInfo.upToLv);

            -- 需要显示 添加属性

            --  temInfo.att_configData = StrongExpDataManager.GetExtStrongAtt(temInfo, lastInfo.upToLv);
            local temCf = StrongExpDataManager.GetExtStrongAtt(selectInfo, lastInfo.upToLv);
            local next_extAtts = ProductInfo.GetSampleBaseAtt(temCf)
            -- temInfo:GetOwnBaseAtt();
            local nextAtt_len = table.getn(baseAtts);

            eq_select_upIcon1.gameObject:SetActive(true);
            eq_select_extatt1.gameObject:SetActive(true);


            if base_ext_att[1] ~= nil then
                eq_select_extatt1.text = next_extAtts[1].property - base_ext_att[1].property;
            else
                eq_select_extatt1.text = next_extAtts[1].property;
            end


            if nextAtt_len > 1 then

                eq_select_upIcon2.gameObject:SetActive(true);
                eq_select_extatt2.gameObject:SetActive(true);

                if base_ext_att[2] ~= nil then
                    eq_select_extatt2.text = next_extAtts[2].property - base_ext_att[2].property;
                else
                    eq_select_extatt2.text = next_extAtts[2].property;
                end

            end


        else
            eq_select_qianghua.text = LanguageMgr.Get("equip/jl/qianhuaLabelAdd") .. curr_slv;


            if curr_slv > 0 then
                eq_select_att1.text = baseAtts[1].des .. ": " .. baseAtts[1].property;
                eq_select_extattCurr1.text = "+" .. base_ext_att[1].property;

                if baseAtt_len > 1 then
                    eq_select_att2.text = baseAtts[2].des .. ": " .. baseAtts[2].property;
                    eq_select_extattCurr2.text = "+" .. base_ext_att[2].property;
                end
            else

                eq_select_att1.text = baseAtts[1].des .. ": " .. baseAtts[1].property;
                eq_select_extattCurr1.text = "+0";
                if baseAtt_len > 1 then
                    eq_select_att2.text = baseAtts[2].des .. ": " .. baseAtts[2].property;
                    eq_select_extattCurr2.text = "+0";
                end

            end


        end


    else

        --  到达满级， 不需要升级
        eq_select_qianghua.text = LanguageMgr.Get("equip/jl/qianhuaLabelAdd") .. curr_slv;

        if curr_slv > 0 then
            eq_select_att1.text = baseAtts[1].des .. ": " .. baseAtts[1].property;
            eq_select_extattCurr1.text = "+" .. base_ext_att[1].property;
            if baseAtt_len > 1 then
                eq_select_att2.text = baseAtts[2].des .. ": " .. baseAtts[2].property;
                eq_select_extattCurr2.text = "+" .. base_ext_att[2].property;
            end
        else
            eq_select_att1.text = baseAtts[1].des .. ": " .. baseAtts[1].property;
            eq_select_extattCurr1.text = "+0"

            if baseAtt_len > 1 then
                eq_select_att2.text = baseAtts[2].des .. ": " .. baseAtts[2].property;
                eq_select_extattCurr2.text = "+0"
            end
        end




    end

end

--[[
  can_to_expObj 经验升级数据    StrongExpDataManager.GetBagerExp  里面的数据结构
  info 物品信息

   upLvInfos1--extExp= [7]
|         | --parenExp= [7]
|         | --upToLv= [1]
|         | --canUpTo= [true]
|         | --dlv= [1]
|         | --baseExp= [0]
|         2--extExp= [3]
|           --parenExp= [21]
|           --upToLv= [1]
|           --canUpTo= [false]
|           --dlv= [1]
|           --baseExp= [0]
--curr_slv= [0]
--canUpLv= [true]
--curr_slv
--curr_exp
--curr_parenExp  (VIP+10%)

]]
function QianghuaPanelControll:UpSliderCtr(can_to_expObj, info)

    local pc = VIPManager.GetStrongPer();
    self.vip_exp_add.text = LanguageMgr.Get("equip/jl/qianhuaLabelVIPAdd", { n = pc });
  
    self.expSliderCtrl:SetData(can_to_expObj, info);
end

-- 根据活动 的 最多 添加经验 进行 处理
function QianghuaPanelControll:UpPanel3ByAddExp(addExp)


    ----------------------------------------------------------------------------------------------

    local selectCtr = self.currSelectCtr;
    if selectCtr == nil then
        return;
    end
    -- 当前选中的装备
    local equip_lv_data = selectCtr.equip_lv_data;
    local info = self.p3_eq_select._productInfo;
    local slv = equip_lv_data.slv;
    self.curr_slv = slv;
    -- 当前装备的强化等级
    local currExp = equip_lv_data.sexp;
    -- 当前 拥有经验
    local kind = info:GetKind();

    local my_info = HeroController:GetInstance().info;
    local my_level = my_info.level;

    -- 测试值
    --  addExp = 10;
    -- addExp = 16;
    --  addExp = 26;
    --  addExp = 88;
    -- addExp = 98;
    -- addExp = 800;

    local pc = VIPManager.GetStrongPer();
    local pc1 = pc / 100;
    addExp = math.ceil(addExp *(1 + pc1));

    local can_to_expObj = StrongExpDataManager.GetBagerExp(my_level, kind, slv, currExp, addExp)

    self:ShowEuqipSampleInfo(can_to_expObj, info)


    --  显示经验  变化
    self:UpSliderCtr(can_to_expObj, info);


end

function QianghuaPanelControll:Updata(select_kind)

    if self.eqPanelControlls ~= nil then
        for i = 1, 8 do
            local qx = EquipLvDataManager.getItem(i);
            self.eqPanelControlls[i]:SetShowGem(false);
            self.eqPanelControlls[i]:SetShowStar(false);
            self.eqPanelControlls[i]:SetData(qx, "slv");
        end

        self:LeftSelectIndex(select_kind);

    end

end

--[[
09 装备栏强化
输入：
idx:装备部位 0到7
items：[道具ID,...]
amouts：[对应的数量]

输出：
idx:装备部位 0到7
slv：强化等级
exp：经验


]]



function QianghuaPanelControll:GetQiangHuaNetData()

    local res = { };

    local info = self.p3_eq_select._productInfo;

    res.idx = info:GetKind() -1;
    res.items = { };
    res.amounts = { };
    local index = 1;

    local hasSome = false;

    if self.product_es_phalanx ~= nil then

        local items = self.product_es_phalanx._items;
        for key, value in pairs(items) do

            if value.itemLogic.selected then
                local info = value.itemLogic.infoData;
                local id = info:GetId();

                res.items[index] = id;
                res.amounts[index] = 1;
                -- 数量永远 为 1
                index = index + 1;
                hasSome = true;

                --[[
                id name type kind
350000 低阶强化石 3:材料 1:强化石
350001 中阶强化石 3:材料 1:强化石
350002 高阶强化石 3:材料 1:强化石
350003 极品强化石 3:材料 1:强化石
                ]]

                local ty = info:GetType();
                local kd = info:GetKind();
                local am = info:GetAm();
                -- http://192.168.0.8:3000/issues/1214

                -- log("---> ty: " .. ty .. " kd: " .. kd .. " am: " .. am);

                if ty == ProductManager.type_3 and kd == 1 and am > 1 then
                    local pid = info:GetId() .. "";
                    -- log("---- add--> " .. pid);
                    self.oldSelectInfos[pid] = true;
                end


            end
        end

    end



    if not hasSome then
        return nil;
    end

    return res;
end


function QianghuaPanelControll:Dispose()


    self.oldSelectInfos = { };
    UIUtil.GetComponent(self.btn_selectQ, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._obtn_selectQ_onClick = nil

    UIUtil.GetComponent(self.selectQPanel, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickselectQPanel = nil

    UIUtil.GetComponent(self._btn_fuling, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_fuling = nil;

    for i = 1, self.quality_num do
        self.selectQualitys[i]:Dispose();
        self.selectQualitys[i] = nil;
    end


    self.expSliderCtrl:Dispose();
    self.expSliderCtrl = nil;

    self.product_pd_phalanx = nil;
    self.product_phalanx = nil;

    self.gameObject = nil;
    self.leftPanel = nil;
    self.rightPanel = nil;
    self.eqPanels = nil;

    self.panel1 = nil;
    self.panel2 = nil;
    self.panel3 = nil;
    self.currSelectCtr = nil;

    if self.product_es_phalanx ~= nil then
        self.product_es_phalanx:Dispose();
    end

    ------------------------------------------------------------------------------------

    self.p3_eq_select:Dispose()
    self.p3_eq_select = nil;

    -- --------------------------

    self.product_es_phalanx = nil;

    self.currSelectKind = 1;

end

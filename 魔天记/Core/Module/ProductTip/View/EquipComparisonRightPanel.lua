
require "Core.Manager.Item.ProducTipsManager"

EquipComparisonRightPanel = class("EquipComparisonRightPanel");



function EquipComparisonRightPanel:New()
    self = { };
    setmetatable(self, { __index = EquipComparisonRightPanel });

    return self;
end

function EquipComparisonRightPanel:Init(tagetPanel, centerPanel)

    self.tagetPanel = tagetPanel;
    self.centerPanel = centerPanel;

    local product = UIUtil.GetChildByName(self.tagetPanel, "Product").gameObject;
    self._productCtrl = ProductCtrl:New();
    self._productCtrl:Init(product, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });


    self.fightCpSp = UIUtil.GetChildByName(self.tagetPanel, "UISprite", "fightCp");




    local txts = UIUtil.GetComponentsInChildren(self.tagetPanel, "UILabel");
    self._txtFightp = UIUtil.GetChildInComponents(txts, "txtFightp");
    self._txtzhiye = UIUtil.GetChildInComponents(txts, "txtzhiye");
    self._txtleixing = UIUtil.GetChildInComponents(txts, "txtleixing");
    self._txtLevelValue = UIUtil.GetChildInComponents(txts, "txtLevelValue");
    self.txtPrice = UIUtil.GetChildInComponents(txts, "txtPrice");
    self.txtzbbindTip = UIUtil.GetChildInComponents(txts, "txtzbbindTip");

    self._txtTipTitle = UIUtil.GetChildInComponents(txts, "txtTipTitle");
    self.txtPingWei = UIUtil.GetChildInComponents(txts, "txtPingWei");

    self._gobangding = UIUtil.GetChildByName(self.tagetPanel, "gobangding");

    self.txtzbbindTip.gameObject:SetActive(false);
    self._gobangding.gameObject:SetActive(false);


    self.subPanel = UIUtil.GetChildByName(self.centerPanel, "Transform", "subPanel");
    self.Table = UIUtil.GetChildByName(self.subPanel, "UITable", "Table");

    self.baseAtt = UIUtil.GetChildByName(self.Table, "Transform", "baseAtt");
    self.jlAtt = UIUtil.GetChildByName(self.Table, "Transform", "jlAtt");
    self.fmAtt = UIUtil.GetChildByName(self.Table, "Transform", "fmAtt");

    self.attValueTxts = { };
    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        self.attValueTxts[i] = UIUtil.GetChildByName(self.fmAtt, "UILabel", "attValueTxt" .. i .. "_r");
    end



    self._trsGem = UIUtil.GetChildByName(self.Table, "Transform", "trsGems");
    self._gems = { };

    for i = 1, 4 do
        local gemGo = UIUtil.GetChildByName(self._trsGem, "Transform", "gem" .. i .. "_r");
        self._gems[i] = gemGo;
    end



    self.dec = UIUtil.GetChildByName(self.Table, "Transform", "dec");

    self.fmcost = UIUtil.GetChildByName(self.tagetPanel, "Transform", "fmcost");
    self.fmcost_txtPrice = UIUtil.GetChildByName(self.fmcost, "UILabel", "txtPrice");

    self._btn_menu1 = UIUtil.GetChildByName(self.tagetPanel, "UIButton", "btn_menu1");
    self._btn_menu2 = UIUtil.GetChildByName(self.tagetPanel, "UIButton", "btn_menu2");
    self._btn_menu3 = UIUtil.GetChildByName(self.tagetPanel, "UIButton", "btn_menu3");
    self._btn_menu4 = UIUtil.GetChildByName(self.tagetPanel, "UIButton", "btn_menu4");

    self._btn_menu1_label = UIUtil.GetChildByName(self._btn_menu1, "UILabel", "Label");
    self._btn_menu2_label = UIUtil.GetChildByName(self._btn_menu2, "UILabel", "Label");
    self._btn_menu3_label = UIUtil.GetChildByName(self._btn_menu3, "UILabel", "Label");
    self._btn_menu4_label = UIUtil.GetChildByName(self._btn_menu4, "UILabel", "Label");

    self:SetBtnMenuV(self._btn_menu1, false);
    self:SetBtnMenuV(self._btn_menu2, false);
    self:SetBtnMenuV(self._btn_menu3, false);
    self:SetBtnMenuV(self._btn_menu4, false);

    self._onClickBtn_menu1 = function(go) self:_OnClickBtn_menu1(self) end
    UIUtil.GetComponent(self._btn_menu1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu1);
    self._onClickBtn_menu2 = function(go) self:_OnClickBtn_menu2(self) end
    UIUtil.GetComponent(self._btn_menu2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu2);
    self._onClickBtn_menu3 = function(go) self:_OnClickBtn_menu3(self) end
    UIUtil.GetComponent(self._btn_menu3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu3);
    self._onClickBtn_menu4 = function(go) self:_OnClickBtn_menu4(self) end
    UIUtil.GetComponent(self._btn_menu4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu4);


    self.fightCpSp.gameObject:SetActive(false);

    MessageManager.AddListener(EquipTipPanel, EquipTipPanel.MESSAGE_EQUIPTIPPANEL_UPDATA, EquipComparisonRightPanel.UpData, self);

end

function EquipComparisonRightPanel:SetBtnMenuV(target, v)
    target.isEnabled = v;
    target.gameObject:SetActive(v);
end

function EquipComparisonRightPanel:_OnClickBtn_menu1()

    local data = self.btDatas[1];
    ProducTipsManager.CallFunById(data, self.info);

end

function EquipComparisonRightPanel:_OnClickBtn_menu2()
    local data = self.btDatas[2];
    ProducTipsManager.CallFunById(data, self.info);

end

function EquipComparisonRightPanel:_OnClickBtn_menu3()
    local data = self.btDatas[3];
    ProducTipsManager.CallFunById(data, self.info);

end

function EquipComparisonRightPanel:_OnClickBtn_menu4()
    local data = self.btDatas[4];
    ProducTipsManager.CallFunById(data, self.info);

end

function EquipComparisonRightPanel:GetMenuBt(name)
    for k, v in pairs(self.btDatas) do
        if v.interface == name then
            return self["_btn_menu" .. k];
        end
    end
    return nil;
end

function EquipComparisonRightPanel:UpData(data)


   local info = BackpackDataManager.GetProductById(self.info.id);

    self:SetProduct(info, self.inEqBag_fightcp, self.needShowSqTip, self.maxStar, self.hideBtn);
end 

function EquipComparisonRightPanel:SetProduct(info, inEqBag_fightcp, needShowSqTip, maxStar, hideBtn)

    hideBtn = hideBtn or false

    self.info = info;
    self._productCtrl:SetData(info);
    self.inEqBag_fightcp = inEqBag_fightcp;
    self.hideBtn = hideBtn;
    self.needShowSqTip = needShowSqTip;
    self.maxStar = maxStar;

    if (hideBtn == true) then
        self._btn_menu1.gameObject:SetActive(false)
        self._btn_menu2.gameObject:SetActive(false)
        self._btn_menu3.gameObject:SetActive(false)
        self._btn_menu4.gameObject:SetActive(false)
    end

    self.container_type = ProductCtrl.TYPE_FROM_BACKPACK;

    local product_type = self.info:GetType();
    self.btDatas = { }
    -- local btDatas_ = ConfigManager.GetTipButtons(self.container_type, product_type);
    local p_spid = info:GetSpId();
    local isbind = info:IsBind();
    local btDatas_ = ProducTipsManager.GetTipInfos(ProductCtrl.TYPE_FROM_BACKPACK, p_spid, isbind, self.info);

    local num = table.getn(btDatas_);
    local index = 5 - num;

    if (hideBtn) then
        self._btn_menu1.gameObject:SetActive(false)
        self._btn_menu2.gameObject:SetActive(false)
        self._btn_menu3.gameObject:SetActive(false)
        self._btn_menu4.gameObject:SetActive(false)
    else
        for i = 1, num do
            self.btDatas[index] = btDatas_[i];
            self:SetBtnMenuV(self["_btn_menu" .. index], true);
            self["_btn_menu" .. index .. "_label"].text = btDatas_[i].button_label;
            index = index + 1;
        end
    end



    local quality = info:GetQuality();

    local name_str = ColorDataManager.GetColorTextByQuality(quality, info:GetName());
    local strongData = NewEquipStrongManager.GetEquipStrongDataByIdx(info.kind)
    if (strongData ~= nil and strongData.level > 0) then
        name_str = name_str .. "[9cff94] +" .. strongData.level .. "[-]";
    end

    self._txtTipTitle.text = name_str;


    self._txtzhiye.text = info:GetCareerName();

    -- 一定是在 装备栏里面的
    local fightInfo = ProductCtrl.GetEquipAllAtt(self.info, true);

    self._fightcp = tonumber(CalculatePower(fightInfo));



    self._txtFightp.text = self._fightcp .. "";

    self.fightCpSp.gameObject:SetActive(false);

    if self._fightcp > self.inEqBag_fightcp then
        self.fightCpSp.gameObject:SetActive(true);
        self.fightCpSp.spriteName = "up";
    elseif self._fightcp < self.inEqBag_fightcp then
        self.fightCpSp.gameObject:SetActive(true);
        self.fightCpSp.spriteName = "down";

    else
        self.fightCpSp.gameObject:SetActive(false);
    end

    self._txtleixing.text = info:GetKindName();

    -- 需要判断是否 符合要求
    local r_lv = info:GetReq_lev();
    local _lv = info:GetLevel();

    local me = HeroController:GetInstance();
    local my_lv = me.info.level;

    self.txtPingWei.text = EquipDataManager.GetEquipGradName(_lv);

    if my_lv < r_lv then
        self._txtLevelValue.text = "[ff4b4b]" .. info:GetReq_lev() .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label1") .. "[-]";
    else
        self._txtLevelValue.text = info:GetReq_lev() .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label1");
    end

    local price = info:GetPrice();
    self.txtPrice.text = "" .. price;

    -- 判断 绑定
    local isBind = info:IsBind();
    if isBind then
        self._gobangding.gameObject:SetActive(true);
        self.txtzbbindTip.gameObject:SetActive(false);
    else
        local bind_type = info:Getbind_type();
        if bind_type == 2 then
            self.txtzbbindTip.gameObject:SetActive(true);
             self._gobangding.gameObject:SetActive(false);
        end
    end

    local kind = self.info:GetKind();
    ------------------------------------  判断是否有强化等级  ----------------------------------------------
    local eqlv = EquipLvDataManager.getItem(kind);
    local slv = 0;
    if eqlv ~= nil then
        slv = eqlv.slv;
    end

    self.info:UpAttribute(slv);


    ------------------------------------ 显示 宝石孔 -----------------------------------------------
    self:UpGems();
    self:Up_baseAtt(self.info, "_r");
    self:Up_FumoAtt(self.info, "_r");
    self:Up_jlAtt(self.info, "_r");
    self:Up_dec(self.info, "_r");
    -----------------------------------------------------------------------------------------------------------

    self.Table:Reposition();
end


function EquipComparisonRightPanel:Up_FumoAtt(info, key)

    local kind = info:GetKind();
    if kind ~= EquipDataManager.KIND_XIANBING and kind ~= EquipDataManager.KIND_XUANBING then
        self.fmAtt.gameObject:SetActive(false);
        self.fmcost.gameObject:SetActive(false);
        return;
    end

    local st = info.st;



    local bg = UIUtil.GetChildByName(self.fmAtt, "UISprite", "bg" .. key);
    local notJDTip = UIUtil.GetChildByName(self.fmAtt, "UILabel", "notJDTip" .. key);

    local hasJD = info:IsHasFairyGroove();
    self.fmcost.gameObject:SetActive(false);
    if hasJD then
        notJDTip.gameObject:SetActive(false);
    else

        local fairy_lev = info:GetLevel();
        local quality = info:GetQuality();
        local cf = EquipDataManager.GetFairyGrooveCf(fairy_lev, quality)
        local identify_cost = cf.identify_cost;

        self.fmcost.gameObject:SetActive(true);
        self.fmcost_txtPrice.text = "" .. identify_cost;
        notJDTip.gameObject:SetActive(true);
    end

    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        self.attValueTxts[i].gameObject:SetActive(false);
    end

    local index = 1;
    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        local att = info:GetFairyGroove(i);
        if att ~= nil then
            self.attValueTxts[index].text = "[" .. att.color .. "]" .. att.att_name .. "[-] +" .. att.att_value;

            bg.height = 32 + index * 30;
            self.attValueTxts[index].gameObject:SetActive(true);
            index = index + 1;
        end
    end



    self.fmAtt.gameObject:SetActive(true);

end



function EquipComparisonRightPanel:Up_dec(info, key)

    local decTxt = UIUtil.GetChildByName(self.dec, "UILabel", "decTxt" .. key);
    decTxt.text = info:GetDesc();

end



function EquipComparisonRightPanel:Up_jlAtt(info, key)


    local strongData = NewEquipStrongManager.GetEquipStrongDataByIdx(info.kind)
    if (strongData ~= nil and strongData.level > 0) then

        local jlLvTxt = UIUtil.GetChildByName(self.jlAtt, "UILabel", "jlLvTxt" .. key);
        local attValueTxt1 = UIUtil.GetChildByName(self.jlAtt, "UILabel", "attValueTxt1" .. key);
        local attValueTxt2 = UIUtil.GetChildByName(self.jlAtt, "UILabel", "attValueTxt2" .. key);

        local baseAtt = info:GetBaseAttr():GetPropertyAndDes()
        local attr = NewEquipStrongManager.GetEquipAttrByInfo(info)

        jlLvTxt.text = "[bccbff]" .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label5") .. "[-]" .. "[-] [77ff47]+" .. strongData.level .. "[-]";
        attValueTxt1.text = "[bccbff]" .. baseAtt[1].des .. " [77ff47]+" .. attr[baseAtt[1].key] .. "[-]"
        attValueTxt2.text = "[bccbff]" .. baseAtt[1].des .. " [77ff47]+" .. attr[baseAtt[2].key] .. "[-]"

        self.jlAtt.gameObject:SetActive(true);
    else
        self.jlAtt.gameObject:SetActive(false);
    end



end

function EquipComparisonRightPanel:Up_baseAtt(info, key)

    local strengthenLvTxt = UIUtil.GetChildByName(self.baseAtt, "UILabel", "strengthenLvTxt" .. key);
    local attValueTxt1 = UIUtil.GetChildByName(self.baseAtt, "UILabel", "attValueTxt1" .. key);
    local attValueTxt2 = UIUtil.GetChildByName(self.baseAtt, "UILabel", "attValueTxt2" .. key);


    strengthenLvTxt.gameObject:SetActive(false);

    local baseAtt = info:GetBaseAttr():GetPropertyAndDes()
    -- info:GetOwnBaseAtt();
    -- 如果是仙器的话， 需要排除 职业之外的 属性
    local kind = info:GetKind();
    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();
    baseAtt = ProductInfo.GetAttByCareer(baseAtt, kind, my_career)


    local st = info.st;
    local st_lv = info.st_lv;
    -- 强化等级
    if st_lv > 0 then
        strengthenLvTxt.text = "[bccbff]" .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label3") .. "[-] [77ff47]+" .. st_lv .. "[-]   ";
        strengthenLvTxt.gameObject:SetActive(true);

        --  local temInfo = info:Clone();
        local temAtt = nil;
        if self.equipSlotInfo then

            -- temInfo.att_configData = StrongExpDataManager.GetExtStrongAtt(temInfo, st_lv);
            temAtt = StrongExpDataManager.GetExtStrongAtt(info, st_lv);
        else
            -- temInfo.att_configData = StrongExpDataManager.GetExtStrongAtt(temInfo, st_lv);
            temAtt = StrongExpDataManager.GetExtStrongAtt(info, st_lv);
        end

        local this_ext_att = ProductInfo.GetSampleBaseAtt(temAtt)
        -- temInfo:GetOwnBaseAtt();
        attValueTxt1.text = "[bccbff]" .. baseAtt[1].des .. "[-]  [ffffff]+[-] [77ff47]" .. baseAtt[1].property .. "[-] [ffffff]+[-] [77ff47]" .. this_ext_att[1].property .. "[-]";
        attValueTxt2.text = "[bccbff]" .. baseAtt[2].des .. "[-]  [ffffff]+[-] [77ff47]" .. baseAtt[2].property .. "[-] [ffffff]+[-] [77ff47]" .. this_ext_att[2].property .. "[-]";

    else
        attValueTxt1.text = "[bccbff]" .. baseAtt[1].des .. "[-]  [ffffff]+[-] [77ff47]" .. baseAtt[1].property .. "[-]";
        attValueTxt2.text = "[bccbff]" .. baseAtt[2].des .. "[-]  [ffffff]+[-] [77ff47]" .. baseAtt[2].property .. "[-]";
    end



    local kind = info:GetKind();
    local jlData = EquipLvDataManager.getItem(kind);

    if jlData ~= nil and jlData.rlv ~= nil and jlData.rlv > 0 then

        local rlv = jlData.rlv;
        local _career = info:Get_career();
        local refData = RefineDataManager.GetRefine_item(kind, _career, rlv);
        local ownAtts = ProductInfo.GetSampleBaseAtt(refData)

        strengthenLvTxt.gameObject:SetActive(true);
        strengthenLvTxt.text = strengthenLvTxt.text .. "[bccbff]" .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label2") .. "[-]" .. "[-] [77ff47]+" .. rlv .. "[-]";
        attValueTxt1.text = attValueTxt1.text .. " [77ff47]+" .. ownAtts[1].property .. "[-]"
        attValueTxt2.text = attValueTxt2.text .. " [77ff47]+" .. ownAtts[2].property .. "[-]"

    end

end

function EquipComparisonRightPanel:UpGems()

    local kind = self.info:GetKind();
    local gemData = GemDataManager.GetSlotData(kind);
    if gemData == nil then
        self._trsGem.gameObject:SetActive(false);
        return;
    end

    self._trsGem.gameObject:SetActive(true);
    local gemNum = VIPManager.GetMyGemSlotNum();
    local vipLvs = string.split(LanguageMgr.Get("equip/gem/vip"), ",");

    for i = 1, 4 do
        local gemGo = self._gems[i];

        local attLable = { };

        local txtName = UIUtil.GetChildByName(gemGo, "UILabel", "txtTitle");
        attLable[1] = UIUtil.GetChildByName(gemGo, "UILabel", "att1");
        attLable[2] = UIUtil.GetChildByName(gemGo, "UILabel", "att2");
        local ico = UIUtil.GetChildByName(gemGo, "UISprite", "icoGem");

        if gemData[i] > 0 then
            gemGo.gameObject:SetActive(true);
            local cfg = ConfigManager.GetProductById(gemData[i]);
            ProductManager.SetIconSprite(ico, cfg.icon_id);
            txtName.text = ColorDataManager.GetColorTextByQuality(cfg.quality, cfg.name);

            local att = GemDataManager.GetGemAttr(gemData[i]);
            local attdec = ProductInfo.GetSampleBaseAtt(att)

            local att_num = table.getCount(attdec);
            for j = 1, att_num do
                local obj = attdec[j];
                attLable[j].text = ColorDataManager.GetColorTextByQuality(cfg.quality, obj.des .. " + " .. obj.property .. obj.sign);
            end

        else
            gemGo.gameObject:SetActive(false);
        end
        -- 宝石属性
    end

end

function EquipComparisonRightPanel:Dispose()


    self._productCtrl:Dispose();

    UIUtil.GetComponent(self._btn_menu1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_menu1 = nil;
    UIUtil.GetComponent(self._btn_menu2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_menu2 = nil;
    UIUtil.GetComponent(self._btn_menu3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_menu3 = nil;
    UIUtil.GetComponent(self._btn_menu4, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_menu4 = nil;

    MessageManager.RemoveListener(EquipTipPanel, EquipTipPanel.MESSAGE_EQUIPTIPPANEL_UPDATA, EquipComparisonRightPanel.UpData);

    self.tagetPanel = nil;
    self.centerPanel = nil;

    self._btn_menu1 = nil;
    self._btn_menu2 = nil;
    self._btn_menu3 = nil;
    self._btn_menu4 = nil;


    self._productCtrl = nil;

    self.fightCpSp = nil;

    self._trsGem = nil;
    self._gems = nil;


    self._txtFightp = nil;
    self._txtzhiye = nil;
    self._txtleixing = nil;
    self._txtLevelValue = nil;
    self.txtPrice = nil;
    self.txtzbbindTip = nil;

    self._txtTipTitle = nil;


    self._gobangding = nil;



    self.subPanel = nil;
    self.Table = nil;

    self.baseAtt = nil;
    self.jlAtt = nil;
    -- self.sqAtt = nil;
    -- self.sqskill = nil;

    self.dec = nil;



    self._btn_menu1_label = nil;
    self._btn_menu2_label = nil;
    self._btn_menu3_label = nil;
    self._btn_menu4_label = nil;

end 
EquipComparisonLeftPanel = class("EquipComparisonLeftPanel");

function EquipComparisonLeftPanel:New()
    self = { };
    setmetatable(self, { __index = EquipComparisonLeftPanel });

    return self;
end

function EquipComparisonLeftPanel:Init(tagetPanel, centerPanel)

    self.tagetPanel = tagetPanel;
    self.centerPanel = centerPanel;

    local product = UIUtil.GetChildByName(self.tagetPanel, "Product").gameObject;
    self._productCtrl = ProductCtrl:New();
    self._productCtrl:Init(product, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });




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
        self.attValueTxts[i] = UIUtil.GetChildByName(self.fmAtt, "UILabel", "attValueTxt" .. i .. "_l");
    end

    self._trsGem = UIUtil.GetChildByName(self.Table, "Transform", "trsGems");
    self._gems = { };

    for i = 1, 4 do
        local gemGo = UIUtil.GetChildByName(self._trsGem, "Transform", "gem" .. i .. "_l");
        self._gems[i] = gemGo;
    end


    self.dec = UIUtil.GetChildByName(self.Table, "Transform", "dec");

end


function EquipComparisonLeftPanel:SetProduct(info, needShowSqTip, maxStar)

    self.info = info:Clone();

    self._productCtrl:SetData(info);

    local quality = info:GetQuality();
    local name_str = ColorDataManager.GetColorTextByQuality(quality, info:GetName());


    local strongData = NewEquipStrongManager.GetEquipStrongDataByIdx(info.kind)
    if (strongData ~= nil and strongData.level > 0) then
        name_str = name_str .. "[9cff94] +" .. strongData.level .. "[-]";
    end

    self._txtTipTitle.text = name_str;

    self._txtzhiye.text = info:GetCareerName();

    -- 模拟在 装备栏里面的
    local fightInfo = ProductCtrl.GetEquipAllAtt(self.info, true);
    self.fightcp = CalculatePower(fightInfo);

    self._txtFightp.text = self.fightcp .. "";


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
    self:Up_baseAtt(self.info, "_l");
    self:Up_FumoAtt(self.info, "_l");
    self:Up_jlAtt(self.info, "_l");
    self:Up_dec(self.info, "_l");
    -----------------------------------------------------------------------------------------------------------

    self.Table:Reposition();
end


function EquipComparisonLeftPanel:Up_FumoAtt(info, key)

    local kind = info:GetKind();
    if kind ~= EquipDataManager.KIND_XIANBING and kind ~= EquipDataManager.KIND_XUANBING then
        self.fmAtt.gameObject:SetActive(false);
        return;
    end

    local st = info.st;

    local bg = UIUtil.GetChildByName(self.fmAtt, "UISprite", "bg" .. key);

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


function EquipComparisonLeftPanel:Up_dec(info, key)

    local decTxt = UIUtil.GetChildByName(self.dec, "UILabel", "decTxt" .. key);
    decTxt.text = info:GetDesc();


end



function EquipComparisonLeftPanel:Up_jlAtt(info, key)


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

function EquipComparisonLeftPanel:Up_baseAtt(info, key)

    local strengthenLvTxt = UIUtil.GetChildByName(self.baseAtt, "UILabel", "strengthenLvTxt" .. key);
    local attValueTxt1 = UIUtil.GetChildByName(self.baseAtt, "UILabel", "attValueTxt1" .. key);
    local attValueTxt2 = UIUtil.GetChildByName(self.baseAtt, "UILabel", "attValueTxt2" .. key);


    strengthenLvTxt.gameObject:SetActive(false);

    local baseAtt = info:GetBaseAttr():GetPropertyAndDes()
    local kind = info:GetKind();

    -- 如果是仙器的话， 需要排除 职业之外的 属性
    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();
    baseAtt = ProductInfo.GetAttByCareer(baseAtt, kind, my_career)


    local st = info.st;
    local st_lv = info.st_lv;
    -- 强化等级
    if st_lv > 0 then
        strengthenLvTxt.text = "[bccbff]" .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label3") .. "[-] [77ff47]+" .. st_lv .. "[-]   ";
        strengthenLvTxt.gameObject:SetActive(true);

        local temCf = nil;
        if self.equipSlotInfo then

            temCf = StrongExpDataManager.GetExtStrongAtt(info, st_lv);
        else
            temCf = StrongExpDataManager.GetExtStrongAtt(info, st_lv);
        end

        local this_ext_att = ProductInfo.GetSampleBaseAtt(temCf)

        attValueTxt1.text = "[bccbff]" .. baseAtt[1].des .. "[-] [ffffff]+[-] [77ff47]" .. baseAtt[1].property .. "[-] [ffffff]+[-] [77ff47]" .. this_ext_att[1].property .. "[-]";
        attValueTxt2.text = "[bccbff]" .. baseAtt[2].des .. "[-] [ffffff]+[-] [77ff47]" .. baseAtt[2].property .. "[-] [ffffff]+[-] [77ff47]" .. this_ext_att[2].property .. "[-]";

    else
        attValueTxt1.text = "[bccbff]" .. baseAtt[1].des .. "[-] [ffffff]+[-] [77ff47]" .. baseAtt[1].property .. "[-]";
        attValueTxt2.text = "[bccbff]" .. baseAtt[2].des .. "[-] [ffffff]+[-] [77ff47]" .. baseAtt[2].property .. "[-]";
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

function EquipComparisonLeftPanel:UpGems()

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

    end

end

function EquipComparisonLeftPanel:Dispose()


    self._productCtrl:Dispose()

    self.tagetPanel = nil;
    self.centerPanel = nil;

    self._productCtrl = nil;


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

end 
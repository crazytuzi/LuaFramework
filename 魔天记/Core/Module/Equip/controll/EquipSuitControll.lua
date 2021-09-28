require "Core.Manager.Item.EquipSuitDataManager"

local EquipSuitControll = class("EquipSuitControll");


function EquipSuitControll:New()
    self = { };
    setmetatable(self, { __index = EquipSuitControll });
    return self
end

function EquipSuitControll:Init(tg, eqTipPanel)
    self.transform = tg;
    self.getEqTipPanel = eqTipPanel;

    self.proDoPanel = UIUtil.GetChildByName(self.transform, "Transform", "proDoPanel");


    self.eq_select = UIUtil.GetChildByName(self.proDoPanel, "Transform", "eq_select");
    self.eq_selectCtr = SelectEquipPanelCtrl:New();
    self.eq_selectCtr:Init(self.eq_select.gameObject, 1, false);

    self.nextLvIcon = UIUtil.GetChildByName(self.proDoPanel, "UISprite", "nextLvIcon");

    self.txt_selectName = UIUtil.GetChildByName(self.proDoPanel, "UILabel", "txt_selectName");
    self.txt_selectNextLvName = UIUtil.GetChildByName(self.proDoPanel, "UILabel", "txt_selectNextLvName");
    self.txt_suitAttTitle = UIUtil.GetChildByName(self.proDoPanel, "UILabel", "txt_suitAttTitle");
    self.txt_hasMaxLvTip = UIUtil.GetChildByName(self.proDoPanel, "UILabel", "txt_hasMaxLvTip");

    self.suitAtts = UIUtil.GetChildByName(self.proDoPanel, "Transform", "suitAtts");

    self.eqsuitTips = UIUtil.GetChildByName(self.transform, "Transform", "eqsuitTips");
    self.txt_eq = { };
    self.txt_eq_bg = { };
    for i = 1, 8 do
        self.txt_eq[i] = UIUtil.GetChildByName(self.eqsuitTips, "UILabel", "txt_eq" .. i);
        self.txt_eq_bg[i] = UIUtil.GetChildByName(self.txt_eq[i], "UISprite", "bg");
    end

    self.suitAttsArr = { };
    for i = 1, EquipSuitDataManager.SUIT_ATTRIBUTE_NUM do
        local tem = UIUtil.GetChildByName(self.suitAtts, "Transform", "item" .. i);
        local res = { };
        res.title = UIUtil.GetChildByName(tem, "UILabel", "title");
        res.txt_att1 = UIUtil.GetChildByName(tem, "UILabel", "txt_att1");
        res.txt_att2 = UIUtil.GetChildByName(tem, "UILabel", "txt_att2");
        res.txt_att3 = UIUtil.GetChildByName(tem, "UILabel", "txt_att3");
        res.txt_att4 = UIUtil.GetChildByName(tem, "UILabel", "txt_att4");

        self.suitAttsArr[i] = res;
    end

    self.duanzaoPanel = UIUtil.GetChildByName(self.proDoPanel, "Transform", "duanzaoPanel");

    self.ProductNeedPanel1 = UIUtil.GetChildByName(self.duanzaoPanel, "Transform", "ProductNeedPanel1");
    self.ProductNeedPanel2 = UIUtil.GetChildByName(self.duanzaoPanel, "Transform", "ProductNeedPanel2");

    self.ProductNeedPanelCtrl1 = ProductNeedPanelCtrl:New();
    self.ProductNeedPanelCtrl1:Init(self.ProductNeedPanel1.gameObject);

    self.ProductNeedPanelCtrl2 = ProductNeedPanelCtrl:New();
    self.ProductNeedPanelCtrl2:Init(self.ProductNeedPanel2.gameObject);



    self.btn_duanzao = UIUtil.GetChildByName(self.duanzaoPanel, "UIButton", "btn_duanzao");
    self._onClickBtn_duanzao = function(go) self:_OnClickBtn_duanzao(self) end
    UIUtil.GetComponent(self.btn_duanzao, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_duanzao);



    ----------------------------------------------------------
    self.needEgLvTip = UIUtil.GetChildByName(self.transform, "Transform", "needEgLvTip");

    MessageManager.AddListener(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE, EquipSuitControll.Eqsuit_levChange, self);

    self:Eqsuit_levChange();
end

function EquipSuitControll:EqPanelClickHandler(eqPanelControll)

    local kind = eqPanelControll.kind;
    self:upDataByKind(kind)

end



function EquipSuitControll:TryShowEffect()


    self.eq_selectCtr:TryShowEffect();



end

function EquipSuitControll:_OnClickBtn_duanzao()

    for i = 1, EquipSuitDataManager.NEED_MATERIALS_MAX_NUM do
        local _productInfo = self["ProductNeedPanelCtrl" .. i]._productInfo;
        if _productInfo ~= nil then
            local enough_num = self["ProductNeedPanelCtrl" .. i].enough_num;
            if not enough_num then
                self["ProductNeedPanelCtrl" .. i]:_OnClickBtn();
                return;
            end
        end

    end

    -- 有足够的材料， 可以锻造
    EquipProxy.TrySQUpStar(self.select_kind - 1)
end


function EquipSuitControll:Eqsuit_levChange()

    if self.select_kind ~= nil then
        self:upDataByKind(self.select_kind)
        self:UpLeftEqs()

    end

    self:UpSuitTxts();
end 

function EquipSuitControll:UpSuitTxts()


    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();


    for i = 1, 8 do

        self.txt_eq[i].gameObject:SetActive(false);

        local eqInfoInEqBag = EquipDataManager.GetProductByKind(i);
        if eqInfoInEqBag ~= nil then

            local select_spid = eqInfoInEqBag:GetSpId();
            local isFitSuit = EquipSuitDataManager.IsCanBeSuitAtt(my_career, select_spid);
            if isFitSuit then
                -- 可以有套装属性
                local sqlvdata = EquipLvDataManager.getItem(i);
                local suit_lev = sqlvdata.suit_lev;
                local suit_id = sqlvdata.suit_id;
                local suit_material_cf = EquipSuitDataManager.Get_suit_materials(suit_id, suit_lev, select_spid);
                self.txt_eq[i].gameObject:SetActive(true);
                if suit_lev > 0 then


                    self.txt_eq[i].text = suit_material_cf.suit_name1;
                    -- EquipSuitDataManager.GetSuitEqName(eqInfoInEqBag, suit_lev, true);
                    self.txt_eq_bg[i].spriteName = "eqbg_" .. suit_lev;

                else
                    suit_material_cf = EquipSuitDataManager.Get_suit_materials(suit_id, 1, select_spid);
                    self.txt_eq_bg[i].spriteName = "eqbg_1";
                    self.txt_eq[i].text = suit_material_cf.suit_name2;

                end

            end

        end


    end
end

function EquipSuitControll:UpLeftEqs()
    MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_UPLEFTEQSDATA);
end


-- 
function EquipSuitControll:upDataByKind(kind)
    self.select_kind = kind;
    local me = HeroController:GetInstance();
    local heroInfo = me.info;

    local eqInfoInEqBag = EquipDataManager.GetProductByKind(kind);


    if eqInfoInEqBag == nil then
        -- 装备位置没有装备
        local bag_equips = BackpackDataManager.GetFixMyEqByTypeAndKind(1, kind, heroInfo.kind);
        local t_num = table.getn(bag_equips);

        if t_num > 0 then
            -- 背包 里有对应的装备
            SetUIEnable(self.getEqTipPanel, false);

            -- 需要进行排序
            local eqs = EquipDataManager.GetEqBySort(bag_equips);

            MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_UPDATA, eqs);
            MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_SHOW);
            self.transform.gameObject:SetActive(false);


        else
            -- 背包里没有找到对应的装备

            SetUIEnable(self.getEqTipPanel, true);

            MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE);
            self.transform.gameObject:SetActive(false);

        end

    else

        SetUIEnable(self.getEqTipPanel, false);

        MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE);
        self.transform.gameObject:SetActive(true);
        self:Updata(eqInfoInEqBag);

    end

end

function EquipSuitControll:Updata(eqInfoInEqBag)
    self.eq_selectCtr:SetProduct(eqInfoInEqBag);


    self.eqInfoInEqBag = eqInfoInEqBag;
    self.my_info = HeroController:GetInstance().info;
    self.my_career = self.my_info:GetCareer();
    self.select_spid = eqInfoInEqBag:GetSpId();

    local isFitSuit = EquipSuitDataManager.IsCanBeSuitAtt(self.my_career, self.select_spid);
    if isFitSuit then
        -- 可以有套装属性

        self:UpProDoPanelInfos(self.eqInfoInEqBag)

        self.needEgLvTip.gameObject:SetActive(false);
        self.proDoPanel.gameObject:SetActive(true);
    else

        self.needEgLvTip.gameObject:SetActive(true);
        self.proDoPanel.gameObject:SetActive(false);
    end


end

function EquipSuitControll:UpProDoPanelInfos(eqInfoInEqBag)

    local select_spid = eqInfoInEqBag:GetSpId();
    local kind = eqInfoInEqBag:GetKind();

    local sqlvdata = EquipLvDataManager.getItem(kind);

    local suit_id = sqlvdata.suit_id;
    local suit_lev = sqlvdata.suit_lev;

    local suit_material_cf = EquipSuitDataManager.Get_suit_materials(suit_id, suit_lev, select_spid)

    local suit_up_materials = nil;
    if suit_material_cf == nil then
        -- suit_lev==0 的情况
        suit_material_cf = EquipSuitDataManager.Get_suit_materials(suit_id, 1, select_spid)
        if suit_material_cf ~= nil then
            suit_up_materials = suit_material_cf.suit_up_materials;
        end

    else
        if suit_lev < 2 then
            local tcf = EquipSuitDataManager.Get_suit_materials(suit_id, suit_lev + 1, select_spid)
            suit_up_materials = tcf.suit_up_materials;
        end

    end
    self.txt_suitAttTitle.text = suit_material_cf.suit_name;

    self.txt_selectName.text = EquipSuitDataManager.GetSuitEqName(eqInfoInEqBag, suit_lev);


    if suit_lev < EquipSuitDataManager.MAX_LEV then

        self.txt_selectNextLvName.text = EquipSuitDataManager.GetSuitEqName(eqInfoInEqBag, suit_lev + 1);
        self.nextLvIcon.gameObject:SetActive(true);
        self.duanzaoPanel.gameObject:SetActive(true);
        self.txt_hasMaxLvTip.gameObject:SetActive(false);


    else
        self.duanzaoPanel.gameObject:SetActive(false);
        self.txt_hasMaxLvTip.gameObject:SetActive(true);
        self.nextLvIcon.gameObject:SetActive(false);
        self.txt_selectNextLvName.text = "";

    end

    -----------------------------------------------------------------


    local attInfo = BaseAdvanceAttrInfo:New();
    if suit_lev == 0 then
        suit_lev = 1;
    end

    suit_id, suit_lev, spid = EquipSuitDataManager.CheckKeys(suit_id, suit_lev, select_spid);

    for i = 1, EquipSuitDataManager.SUIT_ATTRIBUTE_NUM do

        local obj = self.suitAttsArr[i];

        local need_num = EquipSuitDataManager.attForSuitNums[i];
        local num = EquipLvDataManager.GetNumForSuit_lev(suit_id, suit_lev);

        local key = suit_id .. "_" .. suit_lev .. "_" .. need_num;
        -- log(" key " .. key);

        local suit_att = EquipSuitDataManager.GetSuitAttbutiByKey(key);
        attInfo:Init(suit_att);

        local attDec = attInfo:GetPropertyAndDes();
        local att_num = table.getn(attDec);

        if num > need_num then
            num = need_num;
        end

        local tstr = LanguageMgr.Get("EquipSuitControll/label1", { a = need_num, b = num, c = need_num });

        if num >= need_num then
            -- 够数量， 可以获得套装属性

            obj.title.text = EquipSuitDataManager.GetSuitEqColorStr(tstr, suit_lev);

            for i = 1, EquipSuitDataManager.SUIT_MAX_ATTRIBUTE do

                if i <= att_num then
                    local attobj = attDec[i];
                    obj["txt_att" .. i].text = LanguageMgr.Get("EquipSuitControll/label3", { a = attobj.des, b = attobj.property .. attobj.sign .. attobj.sign });
                else
                    obj["txt_att" .. i].text = "";
                end

            end

        else

            obj.title.text = LanguageMgr.Get("EquipSuitControll/label5", { a = tstr });

            for j = 1, EquipSuitDataManager.SUIT_MAX_ATTRIBUTE do
                if j <= att_num then
                    local attobj = attDec[j];
                    obj["txt_att" .. j].text = LanguageMgr.Get("EquipSuitControll/label4", { a = attobj.des, b = attobj.property .. attobj.sign .. attobj.sign });
                else
                    obj["txt_att" .. j].text = "";
                end

            end

        end

    end

    --------------------------------------------------------------------------------------------------------------------------

    if suit_up_materials ~= nil then

        local l_num = table.getn(suit_up_materials);

        for i = 1, EquipSuitDataManager.NEED_MATERIALS_MAX_NUM do

            if i <= l_num then
                local infoArr = ConfigSplit(suit_up_materials[i]);

                local info = ProductManager.GetProductInfoById(infoArr[1], infoArr[2]);
                self["ProductNeedPanelCtrl" .. i]:SetProduct(info);

                self["ProductNeedPanelCtrl" .. i]:SetActive(true);
            else
                self["ProductNeedPanelCtrl" .. i]:SetProduct(nil);
                self["ProductNeedPanelCtrl" .. i]:SetActive(false);
            end

        end

    end



end

function EquipSuitControll:Dispose()

    UIUtil.GetComponent(self.btn_duanzao, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_duanzao = nil;

    MessageManager.RemoveListener(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE, EquipSuitControll.Eqsuit_levChange);

    self.ProductNeedPanelCtrl1:Dispose()
    self.ProductNeedPanelCtrl2:Dispose()

    self.transform = nil;
    self.getEqTipPanel = nil;

    self.eq_selectCtr:Dispose()
    self.eq_selectCtr = nil;

end

return EquipSuitControll

--  self._equipSuitControll:Init(self._equipSuit)
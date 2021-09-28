require "Core.Module.Common.Panel"
require "Core.Module.Common.ProductCtrl"
require "Core.Manager.ConfigManager"

require "Core.Manager.Item.ProducTipsManager"

EquipTipPanel = class("EquipTipPanel", Panel);

EquipTipPanel.MESSAGE_EQUIPTIPPANEL_UPDATA = "MESSAGE_EQUIPTIPPANEL_UPDATA";

function EquipTipPanel.UpPanelInfo(data)

    MessageManager.Dispatch(EquipTipPanel, EquipTipPanel.MESSAGE_EQUIPTIPPANEL_UPDATA,data);
end

function EquipTipPanel:New()
    self = { };
    setmetatable(self, { __index = EquipTipPanel });
    return self
end

function EquipTipPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end


-- function EquipTipPanel:IsFixDepth()
-- 	return true;
-- end
function EquipTipPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtFightp = UIUtil.GetChildInComponents(txts, "txtFightp");
    self._txtzhiye = UIUtil.GetChildInComponents(txts, "txtzhiye");
    self._txtleixing = UIUtil.GetChildInComponents(txts, "txtleixing");
    self._txtLevelValue = UIUtil.GetChildInComponents(txts, "txtLevelValue");
    self.txtPrice = UIUtil.GetChildInComponents(txts, "txtPrice");
    self.txtzbbindTip = UIUtil.GetChildInComponents(txts, "txtzbbindTip");
    self.txtPingWei = UIUtil.GetChildInComponents(txts, "txtPingWei");

     self.txt_gemTitle = UIUtil.GetChildInComponents(txts, "txt_gemTitle");

    self.txtchushou = UIUtil.GetChildInComponents(txts, "txtchushou");
    self.txtPrice = UIUtil.GetChildInComponents(txts, "txtPrice");
    self.micon = UIUtil.GetChildByName(self._trsContent, "UISprite", "micon");


    self.txtzbbindTip.gameObject:SetActive(false);


    self._txtTipTitle = UIUtil.GetChildInComponents(txts, "txtTipTitle");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._btn_menu1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_menu1");
    self._btn_menu2 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_menu2");
    self._btn_menu3 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_menu3");
    self._btn_menu4 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_menu4");

    self.bg = UIUtil.GetChildByName(self._trsContent, "Transform", "wbg");

    self._gobangding = UIUtil.GetChildByName(self._trsContent, "gobangding").gameObject;
    self.centerPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "centerPanel");
    self.subPanel = UIUtil.GetChildByName(self.centerPanel, "Transform", "subPanel");
    self.Table = UIUtil.GetChildByName(self.subPanel, "UITable", "Table");

    self.baseAtt = UIUtil.GetChildByName(self.Table, "Transform", "baseAtt");
    self.fmAtt = UIUtil.GetChildByName(self.Table, "Transform", "fmAtt");
    self.jlAtt = UIUtil.GetChildByName(self.Table, "Transform", "jlAtt");

    --------------------------------------------------

    self.txt_suitAttTitle = UIUtil.GetChildByName(self.Table, "UILabel", "txt_suitAttTitle");
    self.suitAttsArr = { };
    for i = 1, EquipSuitDataManager.SUIT_ATTRIBUTE_NUM do
        local tem = UIUtil.GetChildByName(self.Table, "Transform", "suitAtts_item" .. i);
        local res = { };
        res.gameObject = tem.gameObject;
        res.title = UIUtil.GetChildByName(tem, "UILabel", "title");
        res.txt_att1 = UIUtil.GetChildByName(tem, "UILabel", "txt_att1");
        res.txt_att2 = UIUtil.GetChildByName(tem, "UILabel", "txt_att2");
        res.txt_att3 = UIUtil.GetChildByName(tem, "UILabel", "txt_att3");
        res.txt_att4 = UIUtil.GetChildByName(tem, "UILabel", "txt_att4");

        self.suitAttsArr[i] = res;
    end
    --------------------------------------------------

    self.attValueTxts = { };
    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        self.attValueTxts[i] = UIUtil.GetChildByName(self.fmAtt, "UILabel", "attValueTxt" .. i);
    end

    -- self.sqskill = UIUtil.GetChildByName(self.Table, "Transform", "sqskill");

    self.dec = UIUtil.GetChildByName(self.Table, "Transform", "dec");

    self.decTxt = UIUtil.GetChildByName(self.dec, "UILabel", "decTxt");

    self.fmcost = UIUtil.GetChildByName(self._trsContent, "Transform", "fmcost");
    self.fmcost_txtPrice = UIUtil.GetChildByName(self.fmcost, "UILabel", "txtPrice");


    self._gems = { };

    for i = 1, 4 do
        local gemGo = UIUtil.GetChildByName(self.Table, "Transform", "gem" .. i);
        self._gems[i] = gemGo;
    end

    local product = UIUtil.GetChildByName(self._trsContent.transform, "Product").gameObject;
    self._productCtrl = ProductCtrl:New();
    self._productCtrl:Init(product, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });

    self._btn_menu1_label = UIUtil.GetChildByName(self._btn_menu1, "UILabel", "Label");
    self._btn_menu2_label = UIUtil.GetChildByName(self._btn_menu2, "UILabel", "Label");
    self._btn_menu3_label = UIUtil.GetChildByName(self._btn_menu3, "UILabel", "Label");
    self._btn_menu4_label = UIUtil.GetChildByName(self._btn_menu4, "UILabel", "Label");

    self:SetBtnMenuV(self._btn_menu1, false);
    self:SetBtnMenuV(self._btn_menu2, false);
    self:SetBtnMenuV(self._btn_menu3, false);
    self:SetBtnMenuV(self._btn_menu4, false);

    MessageManager.AddListener(EquipTipPanel, EquipTipPanel.MESSAGE_EQUIPTIPPANEL_UPDATA, EquipTipPanel.UpData, self);

end

function EquipTipPanel:SetActive(v)
    for i = 1, 4 do
        self._gems[i].gameObject:SetActive(v);
    end

    self.txt_gemTitle.gameObject:SetActive(v);
end

function EquipTipPanel:SetSuitAttsActive(v)
    for i = 1, EquipSuitDataManager.SUIT_ATTRIBUTE_NUM do
        self.suitAttsArr[i].gameObject:SetActive(v);
    end
    self.txt_suitAttTitle.gameObject:SetActive(v);
end

function EquipTipPanel:SetBtnMenuV(target, v)
    target.isEnabled = v;
    target.gameObject:SetActive(v);
end

function EquipTipPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

    self._onClickBtn_menu1 = function(go) self:_OnClickBtn_menu1(self) end
    UIUtil.GetComponent(self._btn_menu1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu1);
    self._onClickBtn_menu2 = function(go) self:_OnClickBtn_menu2(self) end
    UIUtil.GetComponent(self._btn_menu2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu2);
    self._onClickBtn_menu3 = function(go) self:_OnClickBtn_menu3(self) end
    UIUtil.GetComponent(self._btn_menu3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu3);
    self._onClickBtn_menu4 = function(go) self:_OnClickBtn_menu4(self) end
    UIUtil.GetComponent(self._btn_menu4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu4);
end

function EquipTipPanel:_OnClickBtn_close()

    ModuleManager.SendNotification(ProductTipNotes.CLOSE_EQUIPTIPPANEL);
end


function EquipTipPanel:_OnClickBtn_menu1()

    local data = self.btDatas[1];
    -- ProductTipProxy.DealPruductMenyHandler(self.container_type, self._info, data);
    ProducTipsManager.CallFunById(data, self._info);
end

function EquipTipPanel:_OnClickBtn_menu2()
    local data = self.btDatas[2];
    -- ProductTipProxy.DealPruductMenyHandler(self.container_type, self._info, data);
    ProducTipsManager.CallFunById(data, self._info);
end

function EquipTipPanel:_OnClickBtn_menu3()
    local data = self.btDatas[3];
    -- ProductTipProxy.DealPruductMenyHandler(self.container_type, self._info, data);
    ProducTipsManager.CallFunById(data, self._info);
end

function EquipTipPanel:_OnClickBtn_menu4()
    local data = self.btDatas[4];
    -- ProductTipProxy.DealPruductMenyHandler(self.container_type, self._info, data);
    ProducTipsManager.CallFunById(data, self._info);
end

function EquipTipPanel:GetMenuBt(name)

    for k, v in pairs(self.btDatas) do
        if v.interface == name then
            return self["_btn_menu" .. k];
        end
    end
    return nil;
end

function EquipTipPanel:_Dispose()

    MessageManager.RemoveListener(EquipTipPanel, EquipTipPanel.MESSAGE_EQUIPTIPPANEL_UPDATA, EquipTipPanel.UpData);

    self:_DisposeListener();
    self:_DisposeReference();


end

function EquipTipPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_menu1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_menu1 = nil;
    UIUtil.GetComponent(self._btn_menu2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_menu2 = nil;
    UIUtil.GetComponent(self._btn_menu3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_menu3 = nil;
    UIUtil.GetComponent(self._btn_menu4, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_menu4 = nil;

    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RemoveDelegate("OnClick");

end

function EquipTipPanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_menu1 = nil;
    self._btn_menu2 = nil;
    self._btn_menu3 = nil;
    self._btn_menu4 = nil;

    self._productCtrl:Dispose();


    self._txtFightp = nil;
    self._txtzhiye = nil;
    self._txtleixing = nil;
    self._txtLevelValue = nil;
    self.txtPrice = nil;
    self.txtzbbindTip = nil;


    self._txtTipTitle = nil;
    self._btn_close = Unil;



    self._gobangding = nil;
    self.centerPanel = nil;
    self.subPanel = nil;
    self.Table = nil;

    self.baseAtt = nil;
    self.jlAtt = nil;
    -- self.sqAtt = nil;
    -- self.sqskill = nil;

    self.dec = nil;


    self._gems = nil;

    self._productCtrl = nil;

    self._btn_menu1_label = nil;
    self._btn_menu2_label = nil;
    self._btn_menu3_label = nil;
    self._btn_menu4_label = nil;

end

function EquipTipPanel:UpData(data)

    self:SetData(self.container_type, self._info, self.equipSlotInfo, self.hideBtn);
end 


function EquipTipPanel:SetData(container_type, info, equipSlotInfo, hideBtn)
    hideBtn = hideBtn or false
    local me = HeroController:GetInstance();
    local my_info = me.info;

    self.container_type = container_type;
    self._info = info;
    self.equipSlotInfo = equipSlotInfo;
    self.hideBtn = hideBtn;


    self.btDatas = { }

    local product_type = info:GetType();
    -- local btDatas = ConfigManager.GetTipButtons(container_type, product_type);
    local p_spid = info:GetSpId();
    local isbind = info:IsBind();
    local btDatas = ProducTipsManager.GetTipInfos(container_type, p_spid, isbind, info);

    local num = table.getn(btDatas);
    local index = 5 - num;

    if (hideBtn) then
        self._btn_menu1.gameObject:SetActive(false)
        self._btn_menu2.gameObject:SetActive(false)
        self._btn_menu3.gameObject:SetActive(false)
        self._btn_menu4.gameObject:SetActive(false)
    else
        for i = 1, num do
            self.btDatas[index] = btDatas[i];
            self:SetBtnMenuV(self["_btn_menu" .. index], true);
            self["_btn_menu" .. index .. "_label"].text = btDatas[i].button_label;
            index = index + 1;
        end
    end




    local st = info.st;

    self._productCtrl:SetData(info);

    local quality = info:GetQuality();


    local pro_career = tonumber(info:Get_career());
    local my_career = tonumber(my_info:GetCareer());

    if pro_career ~= my_career and pro_career ~= 0 then

        self._txtzhiye.text = "[ff4b4b]" .. info:GetCareerName() .. "[-]";
    else
        self._txtzhiye.text = info:GetCareerName();
    end



    local fight = 0;

    if st == ProductManager.ST_TYPE_IN_EQUIPBAG then
        fightInfo = ProductCtrl.GetEquipAllAtt(info, true);
        fight = CalculatePower(fightInfo);
    else
        fight = info:GetFight();
    end

    self._txtFightp.text = fight;


    self.equipSlotInfo = equipSlotInfo;

    -- 需要判断是否 符合要求
    local r_lv = info:GetReq_lev();
    local _lv = info:GetLevel();

    self.txtPingWei.text = EquipDataManager.GetEquipGradName(_lv);

    local my_lv = me.info.level;

    if my_lv < r_lv then
        self._txtLevelValue.text = "[ff4b4b]" .. info:GetReq_lev() .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label1") .. "[-]";
    else
        self._txtLevelValue.text = info:GetReq_lev() .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label1");
    end

    self._txtleixing.text = info:GetKindName();

    -- 装备强化属性 是 在 装备栏里面的时候才有
    if st == ProductManager.ST_TYPE_IN_EQUIPBAG then
        -- 在装备栏里面
        local kind = info.configData.kind;
        local slv = 0;
        info.plv = 0;
        local gemData = { };
        local gemNum = 0;
        local vipLvs = string.split(LanguageMgr.Get("equip/gem/vip"), ",");

        -- self.equipSlotInfo ~= nil 表示 数据来原 后台数据  否则活动自己的数据
        if self.equipSlotInfo then
            slv = self.equipSlotInfo.slv;
            info.plv = self.equipSlotInfo.plv;

            local tmp = string.split(equipSlotInfo.gems, ",");
            for i, v in ipairs(tmp) do
                gemData[i] = tonumber(v);
            end
            gemNum = VIPManager.GetGemSlotNum(self.equipSlotInfo.vip);
        else
            local eqlv = EquipLvDataManager.getItem(kind);
            slv = eqlv.slv;
            local strongData = NewEquipStrongManager.GetEquipStrongDataByIdx(info.idx + 1)
            info.plv = strongData.level;
            gemData = GemDataManager.GetSlotData(info.configData.kind);
            gemNum = VIPManager.GetMyGemSlotNum();
        end

        info:UpAttribute(slv);

        self:SetActive(true);
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
                txtName.text =  ColorDataManager.GetColorTextByQuality(cfg.quality, cfg.name);

                local att = GemDataManager.GetGemAttr(gemData[i]);
                local attdec = ProductInfo.GetSampleBaseAtt(att)

                local att_num = table.getCount(attdec);
                for j = 1, att_num do
                    local obj = attdec[j];
                    attLable[j].text =  ColorDataManager.GetColorTextByQuality(cfg.quality, obj.des.." + "..obj.property..obj.sign );
                end
               
            else
                gemGo.gameObject:SetActive(false);
            end

        end
    else
        self:SetActive(false);
    end

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

    local name_str = ColorDataManager.GetColorTextByQuality(quality, info:GetName());
    if (info ~= nil and info.plv ~= nil and info.plv > 0) then
        name_str = name_str .. "[9cff94] +" .. info.plv .. "[-]";
    end

    self._txtTipTitle.text = name_str;

    self:Up_baseAtt(info);
    self:Up_FumoAtt(info)
    self:Up_jlAtt(info);
    self:Up_suitAtts(info);
    self:Up_dec(info);

    if self.container_type == ProductCtrl.TYPE_FROM_OTHER_PLAYER then
        self.txtchushou.gameObject:SetActive(false);
        self.txtPrice.gameObject:SetActive(false);
        self.micon.gameObject:SetActive(false);


    end

    self.Table:Reposition();

end



function EquipTipPanel:Up_baseAtt(info)

    local strengthenLvTxt = UIUtil.GetChildByName(self.baseAtt, "UILabel", "strengthenLvTxt");
    local attValueTxt1 = UIUtil.GetChildByName(self.baseAtt, "UILabel", "attValueTxt1");
    local attValueTxt2 = UIUtil.GetChildByName(self.baseAtt, "UILabel", "attValueTxt2");


    strengthenLvTxt.gameObject:SetActive(false);
    strengthenLvTxt.text = ""

    local baseAtt = info:GetBaseAttr():GetPropertyAndDes();
    local kind = info:GetKind();

    -- 如果是仙器的话， 需要排除 职业之外的 属性
    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();
    baseAtt = ProductInfo.GetAttByCareer(baseAtt, kind, my_career)

    local attLen = table.getCount(baseAtt);
    if attLen < 2 then
        local p_spid = info:GetSpId();
        Error(" 物品基础属性小于 2 当前属性个数 " .. attLen .. " 道具 id " .. p_spid);

    end


    local st = info.st;

    if st == ProductManager.ST_TYPE_IN_EQUIPBAG then

        local st_lv = info.st_lv;
        -- 附灵等级
        if st_lv > 0 then
            strengthenLvTxt.text = "[bccbff]" .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label3") .. "[-] [77ff47]+" .. st_lv .. "[-]   ";
            strengthenLvTxt.gameObject:SetActive(true);
            -- 附灵属性
            local tematt = StrongExpDataManager.GetExtStrongAtt(info, st_lv);
            local this_ext_att = ProductInfo.GetSampleBaseAtt(tematt)
            -- temInfo:GetOwnBaseAtt();
            attValueTxt1.text = "[bccbff]" .. baseAtt[1].des .. "[-] [ffffff]+[-] " .. baseAtt[1].property .. " [ffffff]+[-]  [77ff47]" .. this_ext_att[1].property .. "[-]   ";
            attValueTxt2.text = "[bccbff]" .. baseAtt[2].des .. "[-] [ffffff]+[-] " .. baseAtt[2].property .. " [ffffff]+[-] [77ff47]" .. this_ext_att[2].property .. "[-]   ";
        else
            attValueTxt1.text = "[bccbff]" .. baseAtt[1].des .. "[-] [ffffff]+[-]  [77ff47]" .. baseAtt[1].property .. "[-]   ";
            attValueTxt2.text = "[bccbff]" .. baseAtt[2].des .. "[-] [ffffff]+[-]  [77ff47]" .. baseAtt[2].property .. "[-]   ";
        end

        -- 改为 显示精炼

        local jlData = nil;
        if self.equipSlotInfo then
            jlData = self.equipSlotInfo;
        else
            jlData = EquipLvDataManager.getItem(kind);
        end

        if jlData ~= nil and jlData.rlv ~= nil and jlData.rlv > 0 then

            local rlv = jlData.rlv;
            strengthenLvTxt.gameObject:SetActive(true);
            strengthenLvTxt.text = strengthenLvTxt.text .. "[bccbff]" .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label2") .. "[-]" .. "[-] [77ff47]+" .. rlv .. "[-]";

            local _career = info:Get_career();
            local refData = RefineDataManager.GetRefine_item(kind, _career, rlv);
            local ownAtts = ProductInfo.GetSampleBaseAtt(refData)

            attValueTxt1.text = attValueTxt1.text .. " [77ff47]+" .. ownAtts[1].property .. "[-]"
            attValueTxt2.text = attValueTxt2.text .. " [77ff47]+" .. ownAtts[2].property .. "[-]"

        end

    else
        attValueTxt1.text = "[bccbff]" .. baseAtt[1].des .. "[-] [ffffff]+[-]  [77ff47]" .. baseAtt[1].property .. "[-]";
        attValueTxt2.text = "[bccbff]" .. baseAtt[2].des .. "[-] [ffffff]+[-]  [77ff47]" .. baseAtt[2].property .. "[-]";

    end

end

function EquipTipPanel:Up_FumoAtt(info)

    local kind = info:GetKind();

    if kind ~= EquipDataManager.KIND_XIANBING and kind ~= EquipDataManager.KIND_XUANBING then
        self.fmAtt.gameObject:SetActive(false);
        self.fmcost.gameObject:SetActive(false);
        return;
    end

    local st = info.st;
    local hasJD = info:IsHasFairyGroove();


    self.fmcost.gameObject:SetActive(false);
    if not hasJD then
        self.fmAtt.gameObject:SetActive(false);
        local fairy_lev = info:GetLevel();
        local quality = info:GetQuality();
        local cf = EquipDataManager.GetFairyGrooveCf(fairy_lev, quality)
        local identify_cost = cf.identify_cost;
        self.fmcost.gameObject:SetActive(true);
        self.fmcost_txtPrice.text = "" .. identify_cost;
        return;

    end

    local bg = UIUtil.GetChildByName(self.fmAtt, "UISprite", "bg");

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

--  改成显示 强化
function EquipTipPanel:Up_jlAtt(info)



    if (info.plv ~= nil and info.plv > 0) then

        local jlLvTxt = UIUtil.GetChildByName(self.jlAtt, "UILabel", "jlLvTxt");
        local attValueTxt1 = UIUtil.GetChildByName(self.jlAtt, "UILabel", "attValueTxt1");
        local attValueTxt2 = UIUtil.GetChildByName(self.jlAtt, "UILabel", "attValueTxt2");

        local baseAtt = info:GetBaseAttr():GetPropertyAndDes()
        local attr = NewEquipStrongManager.GetEquipAttrByInfo(info)

        jlLvTxt.text = "[bccbff]" .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label5") .. "[-]" .. "[-] [77ff47]+" .. info.plv .. "[-]";
        attValueTxt1.text = "[bccbff]" .. baseAtt[1].des .. "[-] [77ff47]+" .. attr[baseAtt[1].key] .. "[-]"
        attValueTxt2.text = "[bccbff]" .. baseAtt[2].des .. "[-] [77ff47]+" .. attr[baseAtt[2].key] .. "[-]"

        self.jlAtt.gameObject:SetActive(true);
    else
        self.jlAtt.gameObject:SetActive(false);
    end




end

function EquipTipPanel:Up_suitAtts(info)

    local kind = info:GetKind();

    if kind == EquipDataManager.KIND_XIANBING or kind == EquipDataManager.KIND_XUANBING then

        self:SetSuitAttsActive(false);
        return;
    end

    self.my_info = HeroController:GetInstance().info;
    self.my_career = self.my_info:GetCareer();
    self.select_spid = info:GetSpId();

    local isFitSuit = EquipSuitDataManager.IsCanBeSuitAtt(self.my_career, self.select_spid);
    if isFitSuit then
        self:SetSuitAttsActive(true);
        self:UpSuitAttInfo(info)

    else
        self:SetSuitAttsActive(false);
    end

end

function EquipTipPanel:UpSuitAttInfo(info)

    local kind = info:GetKind();
    local select_spid = info:GetSpId();

    local suit_id = 0;
    local suit_lev = 1;
    local num = 1;

    if self.container_type == ProductCtrl.TYPE_FROM_EQUIPS then
        local sqlvdata = EquipLvDataManager.getItem(kind);

        suit_id = sqlvdata.suit_id;
        suit_lev = sqlvdata.suit_lev;

        suit_id, suit_lev, spid = EquipSuitDataManager.CheckKeys(suit_id, suit_lev, select_spid);
        num = EquipLvDataManager.GetNumForSuit_lev(suit_id, suit_lev);

    elseif info.suitAttInvented ~= nil then
        -- 有套装虚拟信息， 需要显示
        suit_id, suit_lev, spid = EquipSuitDataManager.CheckKeys(suit_id, suit_lev, select_spid);
    else
        self:SetSuitAttsActive(false);
        return;
    end

    if suit_lev == 0 then
        self:SetSuitAttsActive(false);
        return;
    end

    local attInfo = BaseAdvanceAttrInfo:New();
    local suit_material_cf = EquipSuitDataManager.Get_suit_materials(suit_id, suit_lev, select_spid);

    local tnum = EquipSuitDataManager.attForSuitNums[3];
    if num > tnum then
        num = tnum;
    end

    self.txt_suitAttTitle.text = suit_material_cf.suit_name .. " (" .. num .. "/" .. tnum .. ")";

    for i = 1, EquipSuitDataManager.SUIT_ATTRIBUTE_NUM do

        local obj = self.suitAttsArr[i];

        local need_num = EquipSuitDataManager.attForSuitNums[i];


        local key = suit_id .. "_" .. suit_lev .. "_" .. need_num;

        local suit_att = EquipSuitDataManager.GetSuitAttbutiByKey(key);
        attInfo:Init(suit_att);

        local attDec = attInfo:GetPropertyAndDes();
        local att_num = table.getn(attDec);

        local tstr = LanguageMgr.Get("EquipSuitControll/label2", { a = need_num });

        if num >= need_num then
            -- 够数量， 可以获得套装属性

            obj.title.text = EquipSuitDataManager.GetSuitEqColorStr(tstr, suit_lev);

            for i = 1, EquipSuitDataManager.SUIT_MAX_ATTRIBUTE do


                if i <= att_num then
                    local attobj = attDec[i];
                    obj["txt_att" .. i].gameObject:SetActive(true);
                    obj["txt_att" .. i].text = LanguageMgr.Get("EquipTipPanel/label3", { a = attobj.des, b = attobj.property .. attobj.sign .. attobj.sign });

                else
                    obj["txt_att" .. i].gameObject:SetActive(false);
                end

            end

        else

            obj.title.text = LanguageMgr.Get("EquipTipPanel/label5", { a = tstr });

            for i = 1, EquipSuitDataManager.SUIT_MAX_ATTRIBUTE do

                if i <= att_num then
                    local attobj = attDec[i];
                    obj["txt_att" .. i].gameObject:SetActive(true);
                    obj["txt_att" .. i].text = LanguageMgr.Get("EquipTipPanel/label4", { a = attobj.des, b = attobj.property .. attobj.sign .. attobj.sign });

                else
                    obj["txt_att" .. i].gameObject:SetActive(false);
                end

            end

        end

    end


end


function EquipTipPanel:Up_dec(info)

    self.decTxt.text = info:GetDesc();

    local price = info:GetPrice();
    self.txtPrice.text = "" .. price;
end


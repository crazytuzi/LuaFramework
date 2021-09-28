require "Core.Module.Common.Panel"

require "Core.Manager.Item.ProducTipsManager"

SampleProductTipPanel = Panel:New();

function SampleProductTipPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SampleProductTipPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");

    self._gobangding = UIUtil.GetChildByName(self._trsContent, "gobangding").gameObject;
    self._txtItemType = UIUtil.GetChildInComponents(txts, "txtItemType");
    self._txtUseLevel = UIUtil.GetChildInComponents(txts, "txtUseLevel");
    self._txtTitle = UIUtil.GetChildInComponents(txts, "txtTitle");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._btn_menu1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_menu1");
    self._btn_menu2 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_menu2");
    self._btn_menu3 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_menu3");
    self._btn_menu4 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_menu4");

    self.bg = UIUtil.GetChildByName(self._trsContent, "Transform", "bg");


    self.centerPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "centerPanel");
    self.subPanel = UIUtil.GetChildByName(self.centerPanel, "Transform", "subPanel");
    self.Table = UIUtil.GetChildByName(self.subPanel, "Transform", "Table");

    self.baseAtt = UIUtil.GetChildByName(self.Table, "Transform", "baseAtt");
    self.dec = UIUtil.GetChildByName(self.Table, "Transform", "dec");


    self._txtnum = UIUtil.GetChildInComponents(txts, "txtnum");
    self._txtPrice = UIUtil.GetChildInComponents(txts, "txtPrice");

    local product = UIUtil.GetChildByName(self._trsContent.transform, "Product").gameObject;
    self._productCtrl = ProductCtrl:New();
    self._productCtrl:Init(product, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, false);

    self._btn_menu1_label = UIUtil.GetChildByName(self._btn_menu1, "UILabel", "Label");
    self._btn_menu2_label = UIUtil.GetChildByName(self._btn_menu2, "UILabel", "Label");
    self._btn_menu3_label = UIUtil.GetChildByName(self._btn_menu3, "UILabel", "Label");
    self._btn_menu4_label = UIUtil.GetChildByName(self._btn_menu4, "UILabel", "Label");

    self:SetBtnMenuV(self._btn_menu1, false);
    self:SetBtnMenuV(self._btn_menu2, false);
    self:SetBtnMenuV(self._btn_menu3, false);
    self:SetBtnMenuV(self._btn_menu4, false);



    -- ProducTipsManager.TraceFunConstName();

end

function SampleProductTipPanel:SetBtnMenuV(target, v)
    target.isEnabled = v;
    target.gameObject:SetActive(v);
end

function SampleProductTipPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

    self._onClickBtn_menu1 = function(go) self:_OnClickBtn_menu1(self) end
    UIUtil.GetComponent(self._btn_menu1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu1);
    self._onClickBtn_menu2 = function(go) self:_OnClickBtn_menu2(self) end
    UIUtil.GetComponent(self._btn_menu2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu2);
    self._onClickBtn_menu3 = function(go) self:_OnClickBtn_menu3(self) end
    UIUtil.GetComponent(self._btn_menu3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu3);
    self._onClickBtn_menu4 = function(go) self:_OnClickBtn_menu4(self) end
    UIUtil.GetComponent(self._btn_menu4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_menu4);


    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

end

function SampleProductTipPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(ProductTipNotes.CLOSE_SAMPLEPRODUCTTIPPANEL);
end

function SampleProductTipPanel:_OnClickBtn_menu1()

    local data = self.btDatas[1];
    -- ProductTipProxy.DealPruductMenyHandler(self.container_type, self._info, data);
    ProducTipsManager.CallFunById(data, self._info);
end

function SampleProductTipPanel:_OnClickBtn_menu2()
    local data = self.btDatas[2];
    -- ProductTipProxy.DealPruductMenyHandler(self.container_type, self._info, data);
    ProducTipsManager.CallFunById(data, self._info);
end

function SampleProductTipPanel:_OnClickBtn_menu3()
    local data = self.btDatas[3];
    -- ProductTipProxy.DealPruductMenyHandler(self.container_type, self._info, data);
    ProducTipsManager.CallFunById(data, self._info);
end

function SampleProductTipPanel:_OnClickBtn_menu4()
    local data = self.btDatas[4];
    -- ProductTipProxy.DealPruductMenyHandler(self.container_type, self._info, data);
    ProducTipsManager.CallFunById(data, self._info);
end



function SampleProductTipPanel:_OnClickBtn_chushou()
    ProductTipProxy.TrySell(self._info);
end

function SampleProductTipPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function SampleProductTipPanel:_DisposeListener()
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

function SampleProductTipPanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_menu1 = nil;
    self._btn_menu2 = nil;
    self._btn_menu3 = nil;
    self._btn_menu4 = nil;


    self._gobangding = nil;
    self._txtItemType = nil;
    self._txtUseLevel = nil;
    self._txtTitle = nil;
    self._btn_close = nil;



    self.centerPanel = nil;
    self.subPanel = nil;
    self.Table = nil;

    self.baseAtt = nil;
    self.dec = nil;


    self._txtnum = nil;
    self._txtPrice = nil;


    self._productCtrl:Dispose()
    self._productCtrl = nil;

    self._btn_menu1_label = nil;
    self._btn_menu2_label = nil;
    self._btn_menu3_label = nil;
    self._btn_menu4_label = nil;




end

function SampleProductTipPanel:SetData(container_type, info)

    self.container_type = container_type;
    self._info = info;
    self.btDatas = { }

    local product_type = info:GetType();
    --  local btDatas = ConfigManager.GetTipButtons(container_type, product_type);

    local p_spid = info:GetSpId();
    local isbind = info:IsBind();
    local btDatas = ProducTipsManager.GetTipInfos(container_type, p_spid, isbind, info);

    local num = table.getn(btDatas);
    local index = 5 - num;
    for i = 1, num do
        self.btDatas[index] = btDatas[i];
        self:SetBtnMenuV(self["_btn_menu" .. index], true);
        self["_btn_menu" .. index .. "_label"].text = btDatas[i].button_label;
        index = index + 1;
    end

    self._productCtrl:SetData(info);

    local quality = info:GetQuality();
    self._txtTitle.text = ColorDataManager.GetColorTextByQuality(quality, info:GetName());

    -- 需要判断是否 符合要求
    local r_lv = info:GetReq_lev();

    local me = HeroController:GetInstance();
    if me == nil then
        -- 在选择界面弹出的提示会出现这种情况
        self._txtUseLevel.text = info:GetReq_lev() .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label1");
    else
        local heroInfo = me.info;
        local my_lv = heroInfo.level;

        if my_lv < r_lv then
            self._txtUseLevel.text = "[ff4b4b]" .. info:GetReq_lev() .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label1") .. "[-]";
        else
            self._txtUseLevel.text = info:GetReq_lev() .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label1");
        end
    end



    self._txtItemType.text = info:GetTypeName();
    self._txtnum.text = info:GetAm();
    self._txtPrice.text = info:GetPrice();


    -- 判断 绑定
    local isBind = info:IsBind();
    if isBind then
        self._gobangding.gameObject:SetActive(true);
    end

    self:Up_baseAtt(info);
    self:Up_dec(info);

end

function SampleProductTipPanel:Up_baseAtt(info)


    local attValueTxt = UIUtil.GetChildByName(self.baseAtt, "UILabel", "attValueTxt");
    local attValueTxt2 = UIUtil.GetChildByName(self.baseAtt, "UILabel", "attValueTxt2");

    local ty = info:GetType();
    if ty == ProductManager.type_2 then
        self.baseAtt.gameObject:SetActive(true);
        info:UpStoneAttribute();
        local baseAtt = ProductInfo.GetSampleBaseAtt(info.att_configData)

        attValueTxt.text = "[bccbff]" .. baseAtt[1].des .. "[-] [ffffff]+[-] [77ff47]" .. baseAtt[1].property .. "[-]";

        if baseAtt[2] ~= nil then
            attValueTxt2.gameObject:SetActive(true);
            attValueTxt2.text = "[bccbff]" .. baseAtt[2].des .. "[-] [ffffff]+[-] [77ff47]" .. baseAtt[2].property .. "[-]";
        else
            attValueTxt2.gameObject:SetActive(false);
            attValueTxt2.text = "";
        end



    elseif ty == ProductManager.type_6 then
        -- 灵药
        self.baseAtt.gameObject:SetActive(true);
        local spId = info:GetSpId();
        local elixirObj = LingYaoDataManager.GetAttById(spId);

        local title = UIUtil.GetChildByName(self.baseAtt, "UILabel", "title");
        title.text = LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label4");

        attValueTxt.text = "[bccbff]" .. elixirObj.att_name .. "[-] [ffffff]+[-] [77ff47]" .. elixirObj.value .. "[-]";
        attValueTxt2.gameObject:SetActive(false);
    else
        self.baseAtt.gameObject:SetActive(false);
    end

end

function SampleProductTipPanel:Up_dec(info)

    local decTxt = UIUtil.GetChildByName(self.dec, "UILabel", "decTxt");
    decTxt.text = info:GetDesc();

end

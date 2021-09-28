local ContentFumoCtr = class("ContentFumoCtr")

local WiseEquipAttLeftCtr = require "Core.Module.WiseEquip.trc.item.WiseEquipAttLeftCtr"
local WiseEquipAttRightCtr = require "Core.Module.WiseEquip.trc.item.WiseEquipAttRightCtr"
local WiseEquipAttItem = require "Core.Module.WiseEquip.trc.item.WiseEquipAttItem"


require "Core.Module.WiseEquip.trc.item.WiseEquipInBagItem"
local LeftBtnItem = require "Core.Module.WiseEquip.trc.item.LeftBtnItem"
local sort = table.sort

function ContentFumoCtr:New()
    self = { };
    setmetatable(self, { __index = ContentFumoCtr });

    return self;
end


function ContentFumoCtr:Init(transform)

    self.transform = transform;

    self._btn_xianBing = UIUtil.GetChildByName(self.transform, "Transform", "btn_xianBing");
    self._btn_xuabBing = UIUtil.GetChildByName(self.transform, "Transform", "btn_xuabBing");

    self._btn_xianBingCtr = LeftBtnItem:New(self._btn_xianBing);
    self._btn_xuabBingCtr = LeftBtnItem:New(self._btn_xuabBing);

    self.leftPanel = UIUtil.GetChildByName(self.transform, "Transform", "ctrEqInEqBagPanel");
    self.rightPanel = UIUtil.GetChildByName(self.transform, "Transform", "ctrEqInBagPanel");

    self.leftPanelCtr = WiseEquipAttLeftCtr:New();
    self.leftPanelCtr:Init(self.leftPanel);

    self.rightPanelCtr = WiseEquipAttRightCtr:New();
    self.rightPanelCtr:Init(self.rightPanel);

    local btns = UIUtil.GetComponentsInChildren(self.transform, "UIButton");
    self._btnSell = UIUtil.GetChildInComponents(btns, "btnSell");
    self._btnFumo = UIUtil.GetChildInComponents(btns, "btnFumo");


    self.eqInBagListPanel = UIUtil.GetChildByName(self.transform, "Transform", "eqInBagListPanel");

    self._txtNeedMoney = UIUtil.GetChildByName(self.transform, "UILabel", "needPrice/txtprice");
    self._eqInBagListPanelTitle = UIUtil.GetChildByName(self.eqInBagListPanel, "UILabel", "title");



    self.subPanel = UIUtil.GetChildByName(self.eqInBagListPanel, "UIScrollView", "subPanel");

    self._phalanxInfo = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, WiseEquipInBagItem)


    self._onClickBtn_xianBing = function(go) self:_OnClickBtn_xianBing(self) end
    UIUtil.GetComponent(self._btn_xianBing.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_xianBing);

    self._onClickBtn_xuabBing = function(go) self:_OnClickBtn_xuabBing(self) end
    UIUtil.GetComponent(self._btn_xuabBing.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_xuabBing);


    self._onClickBtn_Sell = function(go) self:_OnClickBtn_Sell(self) end
    UIUtil.GetComponent(self._btnSell, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_Sell);

    self._onClickBtn_Fumo = function(go) self:_OnClickBtn_Fumo(self) end
    UIUtil.GetComponent(self._btnFumo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_Fumo);

    MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, ContentFumoCtr.ProChange, self);
    MessageManager.AddListener(WiseEquipInBagItem, WiseEquipInBagItem.MESSAGE_WISEEQUIPINBAGITEM_SELECT, ContentFumoCtr.UpRightCtr, self);

    MessageManager.AddListener(WiseEquipAttItem, WiseEquipAttItem.MESSAGE_WISEEQUIPATTITEM_SELECT_CHANGE, ContentFumoCtr.ItemSelectHandler, self);

    MessageManager.AddListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2002_RESULT, ContentFumoCtr.FMSuccessHandler, self);
    MessageManager.AddListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2001_RESULT, ContentFumoCtr.JDSuccessHandler, self);
    self.leftLockSelect = nil;
    self._txtNeedMoney.text = LanguageMgr.Get("ContentFumoCtr/label4", { n = 0 });

    self.bag_select = { };
    self.isfirst = true;
end

function ContentFumoCtr:SetData(eqIndex, selectEq)

    self.selectEq = selectEq;
    self:UpIndex(eqIndex, false)
    self:UpRightCtr(selectEq)


    -------- set select for first --------------------
    local _items = self._phalanx._items;
    local list_num = table.getn(_items);
    if list_num > 0 then

        if selectEq ~= nil then
            for i = 1, list_num do
                local ctr = _items[i].itemLogic;
                if ctr.data ~= nil and ctr.data.id == selectEq.id then
                    ctr:ProClick();
                end
            end
        else

            local ctr = _items[1].itemLogic;
            if ctr.isJD then
                ctr:ProClick();
            end
        end
    end
    self:UpEq();
end


function ContentFumoCtr:UpEq()


    self._btn_xianBingCtr:SetProduct(EquipDataManager.GetProductByKind(EquipDataManager.KIND_XIANBING));
    self._btn_xuabBingCtr:SetProduct(EquipDataManager.GetProductByKind(EquipDataManager.KIND_XUANBING));

end

function ContentFumoCtr:FMSuccessHandler()

    self.extEq = EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx["Idx" .. self.eqIndex]);
    self.leftPanelCtr:SetData(self.extEq);

    self.rightPanelCtr:UpData();

end

function ContentFumoCtr:JDSuccessHandler(data)

    local id = data.id;

    local _items = self._phalanx._items;
    local list_num = table.getn(_items);
    if list_num > 0 then

        for i = 1, list_num do
            local ctr = _items[i].itemLogic;
            ctr:UpState()

            if ctr.data.id == id then
                ctr:ProClick()
            end

        end
    end
end


function ContentFumoCtr:UpIndex(eqIndex, doNotSetBt)
    self.eqIndex = eqIndex;

    if eqIndex == 1 then


        self:_OnClickBtn_xianBing()
    elseif eqIndex == 2 then


        self:_OnClickBtn_xuabBing()
    end
end

function ContentFumoCtr:UpRightCtr(selectEq)

    if selectEq ~= nil then
        local k = selectEq.kind;
        self.bag_select[k] = selectEq;
    end


    self.rightPanelCtr:SetData(selectEq);
end

function ContentFumoCtr:UpLeftCtr(eqIndex)
    self.eqIndex = eqIndex;
    self.extEq = EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx["Idx" .. eqIndex]);
    self.leftPanelCtr:SetData(self.extEq);

    self:UpEpInBag(self.bag_select[self.left_select_kind], true)

end

function ContentFumoCtr:BlToNum(v)
    if v then
        return 1;
    else
        return 0;
    end
end

function ContentFumoCtr:ProChange()

    self:UpEpInBag(self.bag_select[self.left_select_kind], false)
end 

function ContentFumoCtr:UpEpInBag(selectEq, isbyTb)

    local list = BackpackDataManager.GetProductsByTypes2(ProductManager.type_1, self.left_select_kind);
    local list_num = table.getn(list);

    -- 需要进行排序
    -- 1 可附魔
    -- 2 未鉴定
    -- 3 没有属性
    -- 4  lv
    --
    if list_num > 1 then


        local eqIbEqBag = EquipDataManager.GetExtEquipByKind(self.left_select_kind);

        sort(list, function(a, b)
            local a1 = self:BlToNum(a:IsHasFairyGroove()) * 10000000;
            local b1 = self:BlToNum(b:IsHasFairyGroove()) * 10000000;

            local a2 = self:BlToNum(a:IsHasFairyGrooveAtt()) * 1000000;
            local b2 = self:BlToNum(b:IsHasFairyGrooveAtt()) * 1000000;

            local a3 = 0;
            local b3 = 0;


            if eqIbEqBag ~= nil then
                local l_a1 = EquipDataManager.IsCanFuMoByPro(eqIbEqBag, a);
                local l_b1 = EquipDataManager.IsCanFuMoByPro(eqIbEqBag, b);

                a3 = self:BlToNum(l_a1) * 100000;
                b3 = self:BlToNum(l_b1) * 100000;
            end


            local a4 = a:GetLevel() * 100;
            local b4 = b:GetLevel() * 100;

            local a5 = a:GetQuality();
            local b5 = b:GetQuality();

            return(a1 + a2 + a3 + a4 + a5) >(b1 + b2 + b3 + b4 + b5);
        end );

    else
        self.rightPanelCtr:SetData(nil);
    end

    WiseEquipInBagItem.selectTg = nil;
    list_num = table.getn(list);
    self._phalanx:Build(list_num, 1, list);

    local _items = self._phalanx._items;
    local t_num = table.getn(_items);
    if t_num > 0 then
        for i = 1, t_num do
            _items[i].itemLogic:SetSelectEQ(self.extEq);
        end

        if isbyTb then
            local ctr = _items[1].itemLogic;
            if ctr.isJD then
                ctr:ProClick();
            end
        else
            self:CheckBagSelect()

        end
    else
        --  需要设置
        if isbyTb then
            self.rightPanelCtr:SetData(nil);
        end

    end

end

function ContentFumoCtr:CheckBagSelect()

    local _items = self._phalanx._items;
    local t_num = table.getn(_items);

    local b = false;
    for i = 1, t_num do
        local lb = _items[i].itemLogic:CheckAndSelectOld();
        if lb then
            b = true;
        end
    end

    if not b then
        -- 没有选择任何一个对象
        MessageManager.Dispatch(WiseEquipInBagItem, WiseEquipInBagItem.MESSAGE_WISEEQUIPINBAGITEM_SELECT, nil);
    end

end

function ContentFumoCtr:_OnClickBtn_Sell()

    if WiseEquipInBagItem.selectTg ~= nil then
        local info = WiseEquipInBagItem.selectTg.data;
        local isfg = info:IsHasFairyGrooveAtt();
        if isfg then
            ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                title = LanguageMgr.Get("common/notice"),
                msg = LanguageMgr.Get("ContentFumoCtr/label3"),
                ok_Label = LanguageMgr.Get("common/ok"),
                cance_lLabel = LanguageMgr.Get("common/cancle"),
                hander = function()
                    ProductTipProxy.TrySell(info, true);
                end,
                target = nil,
                data = nil
            } );
        else
            ProductTipProxy.TrySell(info);

        end
    end

end

function ContentFumoCtr:_OnClickBtn_Fumo()

    if self.leftPanelCtr.data == nil then
        MsgUtils.ShowTips("ContentFumoCtr/label1")
        return;
    end

    self.l_select = self:GetSelectTg(self.leftPanelCtr);
    self.r_select = self:GetSelectTg(self.rightPanelCtr);

    if self.l_select == nil or self.r_select == nil or self.r_select.att == nil then

        MsgUtils.ShowTips("ContentFumoCtr/label1")
        return;
    end

    local l_arr = self.l_select.att;
    local r_arr = self.r_select.att;



    if l_arr ~= nil and r_arr ~= nil and(l_arr.max_attr_lev > r_arr.max_attr_lev) then

        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            title = LanguageMgr.Get("common/notice"),
            msg = LanguageMgr.Get("ContentFumoCtr/label2"),
            ok_Label = LanguageMgr.Get("common/ok"),
            cance_lLabel = LanguageMgr.Get("common/cancle"),
            hander = ContentFumoCtr.SureToFM,
            target = self,
            data = nil
        } );

        return;
    end

    self:SureToFM()

end


function ContentFumoCtr:SureToFM()
    local s_id = self.rightPanelCtr.data.id;
    local s_idx = self.r_select.sindex;

    local t_id = self.leftPanelCtr.data.id;
    local t_idx = self.l_select.sindex;

    local canSellPro = self.rightPanelCtr.data;

    WiseEquipPanelProxy.TryWiseEquip_fumo(s_id, s_idx, t_id, t_idx, canSellPro);
end

function ContentFumoCtr:_OnClickBtn_xianBing()
    self.left_select_kind = EquipDataManager.KIND_XIANBING;
    self:UpLeftCtr(1)
    self:CheckBagSelect()
    self._btn_xianBingCtr:SetSelect(true);
    self._btn_xuabBingCtr:SetSelect(false);
    self.subPanel:ResetPosition();
end

function ContentFumoCtr:_OnClickBtn_xuabBing()
    self.left_select_kind = EquipDataManager.KIND_XUANBING;
    self:UpLeftCtr(2);
    self:CheckBagSelect()
    self._btn_xianBingCtr:SetSelect(false);
    self._btn_xuabBingCtr:SetSelect(true);
    self.subPanel:ResetPosition();
end

function ContentFumoCtr:ItemSelectHandler(tg)


    local type = tg.type;

    if type == WiseEquipAttItem.TYPE_FOR_LEFT then

        if self.leftLockSelect ~= nil then

            for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
                local l_item = self.leftPanelCtr:GetItem(i);
                if l_item == self.leftLockSelect then
                    l_item:_OnClickBtn_cb();

                end
            end
        end


    elseif type == WiseEquipAttItem.TYPE_FOR_RIGHT then

        self.leftLockSelect = nil;

        -- 有变点击的时候，需要对左边进行 默认选择进行判断操作
        -- 优先操作步骤

        self.curr_select_right_attr = nil

        for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
            local r_item = self.rightPanelCtr:GetItem(i);
            local r_select = r_item.select;
            if r_select then
                local r_att = r_item.att;
                if r_att ~= nil then
                    self.curr_select_right_attr = r_att;

                end
            end
        end


        ---------------------------------------------------------
        if self.curr_select_right_attr ~= nil then

            local enchant_cost = self.curr_select_right_attr.enchant_cost;

            self._txtNeedMoney.text = LanguageMgr.Get("ContentFumoCtr/label4", { n = enchant_cost });

            -- 1  如果 左右有属性字段一样， 那么必须锁定左边的 同属性字段， 而且不能修改
            local hasSameTg = nil;
            for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
                local l_item = self.leftPanelCtr:GetItem(i);
                local l_att = l_item.att;
                if l_att ~= nil then
                    if l_att.att_name == self.curr_select_right_attr.att_name then

                        self.leftLockSelect = l_item;
                        -- 需要隐藏所有的 可点击区域
                        hasSameTg = i;
                    end
                end
            end

            if hasSameTg ~= nil then
                for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
                    local l_item = self.leftPanelCtr:GetItem(i);
                    if hasSameTg ~= i then

                        l_item:SetCBSetActive(false);
                    else
                        l_item:SetCBSetActive(true);
                        l_item:_OnClickBtn_cb();
                    end
                end
                return;
            end

            for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do

                local l_item = self.leftPanelCtr:GetItem(i);
                l_item:SetCBSetActive(true);

            end

            -- 2 如果没有 相同的属性字段的情况下 ，优先选择没有属性的孔
            for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
                local l_item = self.leftPanelCtr:GetItem(i);
                local l_att = l_item.att;
                if l_att == nil and l_item.is_open then
                    l_item:_OnClickBtn_cb();
                    return;
                end
            end

        else
            for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do

                local l_item = self.leftPanelCtr:GetItem(i);
                l_item:SetCBSetActive(true);
                if l_item.select then
                    l_item:_OnClickBtn_cb(true);
                end

            end
        end
    end

end

function ContentFumoCtr:GetSelectTg(ct)
    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        local r_item = ct:GetItem(i);
        local r_select = r_item.select;
        if r_select then
            r_item.sindex = i;

            return r_item;
        end
    end

    return nil;
end 

function ContentFumoCtr:Show()
    self.transform.gameObject:SetActive(true);
end

function ContentFumoCtr:Hide()
    self.transform.gameObject:SetActive(false);
end

function ContentFumoCtr:Dispose()

    UIUtil.GetComponent(self._btn_xianBing.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btn_xuabBing.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnSell, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnFumo, "LuaUIEventListener"):RemoveDelegate("OnClick");

    MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, ContentFumoCtr.ProChange);
    MessageManager.RemoveListener(WiseEquipInBagItem, WiseEquipInBagItem.MESSAGE_WISEEQUIPINBAGITEM_SELECT, ContentFumoCtr.UpRightCtr);
    MessageManager.RemoveListener(WiseEquipAttItem, WiseEquipAttItem.MESSAGE_WISEEQUIPATTITEM_SELECT_CHANGE, ContentFumoCtr.ItemSelectHandler);
    MessageManager.RemoveListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2002_RESULT, ContentFumoCtr.FMSuccessHandler);
    MessageManager.RemoveListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2001_RESULT, ContentFumoCtr.JDSuccessHandler);

    self._onClickBtn_xianBing = nil;
    self._onClickBtn_xuabBing = nil;
    self._onClickBtn_Sell = nil;
    self._onClickBtn_Fumo = nil;

    WiseEquipInBagItem.selectTg = nil;

    if (self._phalanx) then
        self._phalanx:Dispose()
        self._phalanx = nil
    end

    self.leftPanelCtr:Dispose();
    self.rightPanelCtr:Dispose();

    self.leftPanelCtr = nil;
    self.rightPanelCtr = nil;

    self._btn_xianBingCtr:Dispose();
    self._btn_xuabBingCtr:Dispose();

    self._btn_xianBingCtr = nil;
    self._btn_xuabBingCtr = nil;

    self.transform = nil;

end


return ContentFumoCtr;


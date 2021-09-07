-- 作者:jia
-- 6/30/2017 10:42:59 AM
-- 功能:选择礼包界面

BackPackSelectGiftPanel = BackPackSelectGiftPanel or BaseClass(BasePanel)
function BackPackSelectGiftPanel:__init(parent)
    self.parent = parent
    self.resList = {
        { file = AssetConfig.backpackselectgiftpanel, type = AssetType.Main }
    }
    self.RewardItems = { };
    self.setting = {
        column = 4
        ,
        cspacing = 10
        ,
        rspacing = 10
        ,
        cellSizeX = 65
        ,
        cellSizeY = 65,
    }
    self.SelectTab = 0;
    self.UseNum = 1;
    self.ItemChangeHandler =
    function()
        self:ItemChange()
    end
    self.UpdateNumHandler = function()
        self:UpdateNum();
    end
    self.isSure = false
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    self.hasInit = false
end

function BackPackSelectGiftPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackPackSelectGiftPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.ItemChangeHandler)
    if self.RewardItems ~= nil then
        for _, item in pairs(self.RewardItems) do
            item:DeleteMe()
            item = nil
        end
        self.RewardItems = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackPackSelectGiftPanel:OnOpen()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.ItemChangeHandler)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.ItemChangeHandler)
    if self.openArgs ~= nil then
        local baseID = self.openArgs;
        self:UpdateData(baseID);
    end
end

function BackPackSelectGiftPanel:OnClickShow(tabID)
    self.SelectTab = tabID;
    for key, item in pairs(self.RewardItems) do
        item:SlotSelect(key == tabID)
    end
end

function BackPackSelectGiftPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpackselectgiftpanel))
    self.gameObject.name = "BackPackSelectGiftPanel"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    -- UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.BtnPanel = self.transform:Find("Panel"):GetComponent(Button)
    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.TxtTitle = self.transform:Find("Main/TxtTitle"):GetComponent(Text)
    self.TxtDesc = self.transform:Find("Main/TxtDesc"):GetComponent(Text)

    self.GrdItems = self.transform:Find("Main/GrdItems")
    self.BaseItem = self.transform:Find("Main/BaseItem").gameObject


    self.TxtCount = self.transform:Find("Main/BuyCount/CountBg/Count"):GetComponent(Text)
    self.BtnCount = self.transform:Find("Main/BuyCount/CountBg"):GetComponent(Button)
    self.BtnAdd = self.transform:Find("Main/BuyCount/AddBtn"):GetComponent(Button)
    self.BtnMinus = self.transform:Find("Main/BuyCount/MinusBtn"):GetComponent(Button)

    self.BtnCount.onClick:AddListener( function() self:OnNumberpad() end)
    self.BtnAdd.onClick:AddListener( function() self:AddOrMinus(1) end)
    self.BtnMinus.onClick:AddListener( function() self:AddOrMinus(0) end)

    self.BtnSure = self.transform:Find("Main/BtnSure"):GetComponent(Button)

    self.BtnPanel.onClick:AddListener(
    function()
        self:OnClose()
    end )
    self.CloseButton.onClick:AddListener(
    function()
        self:OnClose()
    end )

    self.BtnSure.onClick:AddListener(
    function()
        self:OnSuerHandler()
    end )
end

function BackPackSelectGiftPanel:OnClose()
    BackpackManager.Instance.mainModel:CloseSelectGiftPanel()
end

function BackPackSelectGiftPanel:OnSuerHandler()
    if self.SelectTab <= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择道具"));
        return;
    end
    BackpackManager.Instance:SendSelectGift(self.ItemData.id, self.SelectTab, self.UseNum);
    self.isSure = true
end

function BackPackSelectGiftPanel:UpdateData(baseID)
    self.SelectTab = 0
    self.UseNum = 1;
    self.TxtCount.text = tostring(self.UseNum);
    if self.Layout ~= nil then
        self.Layout:DeleteMe()
    end
    local items = BackpackManager.Instance:GetItemByBaseid(baseID);
    self.GiftList = { };
    if items ~= nil and #items > 0 then
        self.ItemData = items[1];
        local gift_list = DataItemGift.data_select_gift_list[baseID]
        self.GiftList = self:FilterTmps(gift_list);
        local len = #self.GiftList;
        if len > 0 then
            local soreFun =
            function(a, b)
                return a.tab_id < b.tab_id;
            end;
            table.sort(self.GiftList, soreFun);
            self.TxtDesc.text = self.GiftList[1].gift_desc;
            self.TxtTitle.text = string.format(TI18N("%s：剩余%s"),self.ItemData.name, self.ItemData.quantity);
           -- ColorHelper.color_item_name(self.ItemData.quality , string.format(TI18N("%s：剩余%s"), self.ItemData.name, self.ItemData.quantity))
            local borderleft = 0
            if len < 4 then
                borderleft =(290 - len * self.setting.cellSizeX -(len - 1) * self.setting.cspacing) * 0.5
            end
            self.setting.borderleft = borderleft
            self.Layout = LuaGridLayout.New(self.GrdItems, self.setting)
            local nowIndex = 0
            for _, giftTmp in pairs(self.GiftList) do
                nowIndex = nowIndex + 1
                local itmeBase = BackpackManager.Instance:GetItemBase(giftTmp.item_id);
                itmeBase.bind = giftTmp.bind;
                itmeBase.quantity = giftTmp.num;
                itmeBase.tab_id = giftTmp.tab_id;
                itmeBase.show_num = true
                local item = self.RewardItems[giftTmp.tab_id]
                if item == nil or BaseUtils.is_null(item.gameObject) then
                    item = BackpackSelectGiftItem.New(self.BaseItem);
                    item.nowIndex = nowIndex
                    self.RewardItems[giftTmp.tab_id] = item;
                end
                local itemData = ItemData.New()
                itemData:SetBase(itmeBase)
                item:SetData(itemData)
                item.gameObject:SetActive(true)
                item.Slot.clickSelfFunc = function(baseData) self:OnClickShow(baseData.tab_id) end
                self.Layout:AddCell(item.gameObject)
            end
            self.max_result = self.ItemData.quantity
            self.numberpadSetting = {
                -- 弹出小键盘的设置
                gameObject = self.BtnCount.gameObject,
                min_result = 1,
                max_by_asset = self.max_result,
                max_result = self.max_result,
                textObject = self.TxtCount,
                show_num = false,
                funcReturn = function() NoticeManager.Instance:FloatTipsByString(TI18N("请确认使用")) end,
                callback = self.UpdateNumHandler
            }
        end
        if #self.GiftList < #self.RewardItems then
            for index = #self.GiftList + 1, #self.RewardItems do
                for k,v in pairs(self.RewardItems) do
                    if v.nowIndex == index then
                        local item = self.RewardItems[k];
                        item:DeleteMe();
                        item = nil;
                        self.RewardItems[k] = nil
                    end
                end

            end
        end
    else
        self.ItemData = nil
        self:OnClose();
    end
end

function BackPackSelectGiftPanel:FilterTmps(tmplist)
    if tmplist == nil or #tmplist == 0 then
        return {};
    end
    local recList = { };
    local roleData = RoleManager.Instance.RoleData;
    for _, tmpdata in pairs(tmplist) do
        if (tmpdata.sex == roleData.sex or tmpdata.sex == 2)
            and(tmpdata.classes == roleData.classes or tmpdata.classes == 0)
            and(tmpdata.lev_low <= roleData.lev or tmpdata.lev_low == 0)
            and(tmpdata.lev_high >= roleData.lev or tmpdata.lev_high == 0) then
            table.insert(recList, tmpdata)
        end
    end
    return recList;
end

function BackPackSelectGiftPanel:ItemChange()
    if not self.isSure then
        return
    end
    local items = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.selectgift);
    if items ~= nil and #items > 0 then
        self:UpdateData(items[1].base_id)
    else
        self:OnClose();
    end
end

function BackPackSelectGiftPanel:OnNumberpad()
    NumberpadManager.Instance:set_data(self.numberpadSetting)
end

function BackPackSelectGiftPanel:UpdateNum()
    self.UseNum = NumberpadManager.Instance:GetResult()
end

function BackPackSelectGiftPanel:AddOrMinus(status)
    local num = self.UseNum;
    if status == 1 then
        if num < self.max_result then
            num = num + 1
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("不能使用更多了"))
        end
    else
        if num > 1 then
            num = num - 1
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("最少使用一个"))
        end
    end
    self.UseNum = num;
    self.TxtCount.text = tostring(self.UseNum);
end

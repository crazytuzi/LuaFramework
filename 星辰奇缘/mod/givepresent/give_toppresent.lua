TopPresent = TopPresent or BaseClass()

function TopPresent:__init(gameObject, base_id, main)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.base_id = base_id
    self.main = main
    self.assetWrapper = main.assetWrapper
    self:RefreshData()
end

function TopPresent:RefreshData()
    local item = self.transform
    local select_num = self.main.selectPresentList[self.base_id]
    self.num = 0
    if DataItem.data_get[self.base_id].type == 156 then
        if NationalSecondManager.Instance.flowerGiveFriendData ~= nil then
            for k,v in pairs(NationalSecondManager.Instance.flowerGiveFriendData) do
                if self.base_id == v.id then
                    self.num = v.num
                end
            end
        end
    else
        -- 答题入场券特殊处理
        if self.base_id == 26013 then
            self.num = BackpackManager.Instance:GetUnbindItemCount(self.base_id)
        else
            self.num = BackpackManager.Instance:GetItemCount(self.base_id)
        end
    end
    if select_num ~= nil then
        self.num = self.num - select_num
    end
    item:GetComponent(Button).onClick:RemoveAllListeners()
    if self.base_id ~= nil then
        self.main:GetIcon(item:Find("Icon").gameObject, self.base_id)
        item:Find("NumImg/NumText"):GetComponent(Text).text = tostring(self.num)
        item:GetComponent(Button).onClick:AddListener(function() self:Onclick() end)
    end
    item:Find("Icon").gameObject:SetActive(self.base_id ~= nil)
    item:Find("makeClick").gameObject:SetActive(false)
    item:Find("NumImg").gameObject:SetActive(self.num > 0)
end

function TopPresent:Onclick()
    if self.num>0 then
        self.main:OnSelectPresent(self.base_id)
    else
        if self:IsShop() then
            ShopManager.Instance.model:OpenQuickBuyPanel(self.base_id)
        else
            -- TipsManager.Instance:ShowItem({gameObject = self.gameObject, itemData = info.result, extra = {nobutton = true}})
            local cell = DataItem.data_get[self.base_id]
            local itemdata = ItemData.New()
            itemdata:SetBase(cell)
            TipsManager.Instance:ShowItem({["gameObject"] = self.gameObject, ["itemData"] = itemdata})
        end
    end
end

function TopPresent:IsShop()
    for k,v in pairs(ShopManager.Instance.itemPriceTab) do
        if v.base_id == self.base_id and v.limit_role == -1 then
            return true
        end
    end
    return false
end
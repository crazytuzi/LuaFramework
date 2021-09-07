-- 2016/8/29
-- zzl
-- 一元夺宝兑换panel
LotteryExchangeItem = LotteryExchangeItem or BaseClass()

function LotteryExchangeItem:__init(parent, originItem, index)
    self.index = index
    self.parent = parent

    self.gameObject = originItem
    self.transform = self.gameObject.transform
    -- self.transform:SetParent(originItem.transform.parent)
    -- self.transform.localScale = Vector3.one
    self.gameObject:SetActive(true)

    self.ImgSelectBg=self.transform:FindChild("Select").gameObject
    self.ImgSelectBg:SetActive(false)

    self.SlotCon= self.transform:FindChild("SlotCon").gameObject
    self.TxtName= self.transform:FindChild("Name"):GetComponent(Text)
    self.PriceBg =  self.transform:FindChild("PriceBg").gameObject
    self.TxtCost=  self.PriceBg.transform:FindChild("Price"):GetComponent(Text)
    self.ImgGx=  self.PriceBg.transform:FindChild("Currency"):GetComponent(Image)
    self.SoldoutImage = self.transform:FindChild("SoldoutImage").gameObject
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClickItem() end)
end

function LotteryExchangeItem:Release()
    self.ImgGx.sprite = nil
    self.slot:DeleteMe()
end

function LotteryExchangeItem:InitPanel(_data)

end

function LotteryExchangeItem:SetData(data, index)
    self.data = data
    self.index = index

    self:UpdateData()

    if self.parent.selectedData ~= nil and self.parent.selectedData.Id == self.data.Id then
        self:OnClickItem()
    elseif index == 1 then
        self:OnClickItem()
    end
end

function LotteryExchangeItem:UpdateData()
    ---道具图标
    if self.slot == nil then
        self.slot = ItemSlot.New()
        local cell = ItemData.New()
        cell:SetBase(DataItem.data_get[self.data.base_id])
        self.slot:SetAll(cell, nil)
        self.slot.gameObject.transform:SetParent(self.SlotCon.transform)
        self.slot.gameObject.transform.localScale = Vector3.one
        self.slot.gameObject.transform.localPosition = Vector3.zero
        self.slot.gameObject.transform.localRotation = Quaternion.identity
        local rect = self.slot.gameObject:GetComponent(RectTransform)
        rect.anchorMax = Vector2(1, 1)
        rect.anchorMin = Vector2(0, 0)
        rect.localPosition = Vector3(0, 0, 1)
        rect.offsetMin = Vector2(0, 0)
        rect.offsetMax = Vector2(0, 2)
        rect.localScale = Vector3.one
        self.slot:SetNotips(true)
    end
    self.myItemData = DataItem.data_get[self.data.base_id]

    if self.data.num > 1 then
        self.TxtName.text = string.format("%sx%s", self.myItemData.name, self.data.num)
    else
        self.TxtName.text = self.myItemData.name
    end

    local myNum = RoleManager.Instance.RoleData.lottery_luck
    -- if myNum < self.data.price then
    --     local temp = string.format("<color='#ff0000'>%d</color>",tostring(self.data.price))
    --     self.TxtCost.text = tostring(temp)
    -- else
    --     local temp = string.format("<color='#4dd52b'>%d</color>",tostring(self.data.price))
    --     self.TxtCost.text = tostring(temp)
    -- end
    self.TxtCost.text = tostring(self.data.price)
    -- self.ImgGx.gameObject:SetActive(false)


    --非共享
    if self.data.limit_role == -1 then
        self.slot:SetNum(1)
    else
        local hasBuyNum = ShopManager.Instance.model.hasBuyList[self.data.id]
        if hasBuyNum == nil then
            hasBuyNum = 0
        end
        local leftNum = self.data.limit_role - hasBuyNum
        if leftNum <= 0 then
            self.SoldoutImage:SetActive(true)
            self.slot:SetNum(1)
        else
            self.SoldoutImage:SetActive(false)
            self.slot:SetNum(leftNum)
        end
    end
end


function LotteryExchangeItem:OnClickItem()
    self.parent:UpdateRight(self)
end


--设置选中状态
function LotteryExchangeItem:SetSelect(state)
    self.ImgSelectBg:SetActive(state)
end
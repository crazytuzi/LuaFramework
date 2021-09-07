-- @author hze
-- @date #19/08/19#
--战令活动奖励item
WarOrderRewardItem = WarOrderRewardItem or BaseClass()

function WarOrderRewardItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self._active = self.gameObject.activeSelf

    self.itemObjList = {}
    self.bgObjList = {}
    self.itemList = {}

    self:InitPanle()
end

function WarOrderRewardItem:__delete()
    if self.itemList then 
        for _, v in ipairs(self.itemList) do
            v:DeleteMe()
        end
    end
end

function WarOrderRewardItem:Show()

end

function WarOrderRewardItem:Hide()

end

function WarOrderRewardItem:InitPanle()
    self.levTxt = self.transform:Find("LevText"):GetComponent(Text)
    for i = 1, 3 do
        self.itemObjList[i] = self.transform:Find("Item" .. i).gameObject
        if i > 1 then 
            self.bgObjList[i] = self.transform:Find("ItemBg" .. i).gameObject
        end
    end
end

function WarOrderRewardItem:update_my_self(data, index)
    self:SetData(data, index)
end

function WarOrderRewardItem:SetData(data, index)
    self.data = data
    self.lev = data[1].lev or data[2].lev
    self.levTxt.text = data[1].lev .. TI18N("级")


    local list = WarOrderConfigHelper.GetReward(self.lev)

    local count = 1
    for i, dat in ipairs(list) do
        local item = self.itemList[i]
        if not item then 
            item  = WarOrderSingleItem.New(self.model, self.itemObjList[i])
        end
        item:SetData(dat, i)
        self.itemList[i] = item

        if i > 1 then 
            self.bgObjList[i]:SetActive(true)
        end
        self.itemObjList[i]:SetActive(true)
        count = count + 1
    end
    
    for i = count, 3 do
        self.bgObjList[i]:SetActive(false)
        self.itemObjList[i]:SetActive(false)
    end
end

function WarOrderRewardItem:SetActive(bool)
    if bool ~= self._active then 
        self.gameObject:SetActive(bool)
        self._active = bool
    end
end

function WarOrderRewardItem:OnClick()
    -- local itemdata = ItemData.New()
    -- itemdata:SetBase(BackpackManager.Instance:GetItemBase(self.data.item_id))
    -- TipsManager.Instance:ShowItem({["gameObject"] = self.transform.gameObject, ["itemData"] = itemdata, ["extra"] = {nobutton = true}})
end

function WarOrderRewardItem:ShowEffect(bool)
    for i, v in ipairs(self.itemList) do
        v:ShowEffect(bool)
    end
end

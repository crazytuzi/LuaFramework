-- @author hze
-- @date #2019/05/30#
--奖励单个item
WarOrderSingleItem = WarOrderSingleItem or BaseClass()

function WarOrderSingleItem:__init(model, gameObject)
    self.model = model

    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.__active = self.gameObject.activeSelf

    self:InitPanle()
end

function WarOrderSingleItem:__delete()
    if self.iconloader ~= nil then
        self.iconloader:DeleteMe()
    end

    if self.effect then 
        self.effect:DeleteMe()
    end
end

function WarOrderSingleItem:InitPanle()
    self.obtainObj = self.transform:Find("Obtain").gameObject
    self.maskObj = self.transform:Find("Mask").gameObject
    self.slotTrans = self.transform:Find("Slot")

    self.icon = self.transform:Find("Icon")
    self.iconloader = SingleIconLoader.New(self.icon.gameObject)
    self.numBg = self.transform:Find("NumBg").gameObject
    self.numBgRect = self.numBg:GetComponent(RectTransform)
    self.numTxt = self.transform:Find("Num"):GetComponent(Text)
    self.numRect = self.numTxt:GetComponent(RectTransform)


    self.btn = self.transform:GetComponent(Button)
    self.btn.onClick:AddListener(function() self:OnClick() end)

end

function WarOrderSingleItem:SetData(data, index)
    self.data = data
    -- BaseUtils.dump(data)

    self:SetActive(true)
    self.iconloader:SetSprite(SingleIconType.Item, DataItem.data_get[data.item_id].icon)
    self:SetNum(data.num)
    self:ShowEffect(true)

    self.id =  data.id
    self.lev =  data.lev
    self.status = self.model:GetWarOrderObtainedStatus(self.id, self.lev)

    self.obtainObj:SetActive(self.status == 2)
    self.maskObj:SetActive(self.status == 0)
end

function WarOrderSingleItem:SetNum(num)
    num = num or 1
    self.numTxt.text = self:FormatNum(num)
    self.numTxt.gameObject:SetActive(num > 1)
    self.numBg:SetActive(num > 1)

    local w = math.max(math.ceil(self.numTxt.preferredWidth) + 1, 18)
    self.numRect.sizeDelta = Vector2(w, 24)
end

function WarOrderSingleItem:FormatNum(val)
    if val >= 10000 and val < 100000 then
        local temp = math.floor(val / 10000)
        return string.format("%s%s", temp, TI18N("万"))
    elseif val >= 100000 and val < 1000000 then
        local temp = math.floor(val / 1000)
        return string.format("%s%s", temp / 10, TI18N("万"))
    elseif val >= 1000000 and val < 10000000 then
        local temp = math.floor(val / 1000)
        return string.format("%s%s", temp / 10, TI18N("万"))
    elseif val >= 10000000 and val < 100000000 then
        local temp = math.floor(val / 10000000)
        return string.format("%s%s", temp, TI18N("千万"))
    elseif val >= 100000000 and val < 1000000000 then
        local temp = math.floor(val / 10000000)
        return string.format("%s%s", temp / 10, TI18N("亿"))
    elseif val >= 1000000000 then
        local temp = math.floor(val / 10000000)
        return string.format("%s%s", temp / 10, TI18N("亿"))
    end
    return tostring(val)
end


function WarOrderSingleItem:SetActive(bool)
    if bool ~= self._active then 
        self.gameObject:SetActive(bool)
        self._active = bool
    end
end

function WarOrderSingleItem:OnClick()
    if self.status == 1 then 
        self.model.mgr:Send20489(self.id, self.lev)
    else
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[self.data.item_id])
        TipsManager.Instance:ShowItem({gameObject = self.gameObject, itemData = itemData, extra = {nobutton = true, inbag = false}})
    end
end

function WarOrderSingleItem:ShowEffect(bool)
    if bool then 
        if self.status == 1 then 
            if self.effect1 == nil then 
                self.effect1 = BaseUtils.ShowEffect(20053, self.icon, Vector3.one * 0.9, Vector3(-30, -21, -300))
            end
            self.effect1:SetActive(true)
            if self.effect2 ~= nil then 
                self.effect2:SetActive(false)
            end
        else
            if self.data.effect == 1 then 
                if self.effect2 == nil then
                    self.effect2 = BaseUtils.ShowEffect(20223, self.icon, Vector3.one, Vector3(0, 0, -300))
                end
                self.effect2:SetActive(true)
                if self.effect1 ~= nil then
                    self.effect1:SetActive(false)
                end
            else
                if self.effect1 ~= nil then
                    self.effect1:SetActive(false)
                end
                if self.effect2 ~= nil then
                    self.effect2:SetActive(false)
                end
            end
        end
    else
        if self.effect1 ~= nil then
            self.effect1:SetActive(false)
        end
        if self.effect2 ~= nil then
            self.effect2:SetActive(false)
        end
    end
end

LuckeyChestItem = LuckeyChestItem or BaseClass()

function LuckeyChestItem:__init(gameObject, id, config)
    self.gameObject = gameObject
    local transform = gameObject.transform
    self.transform = transform 
    self.id = id
    self.config = config

    self:InitItemSlot()
    if config.is_effect == 1 then
        self.effect = self:ShowEffect(20223, self.itemSlot.gameObject.transform, Vector3.one, Vector3(0, 0, -400))
    end
    self.selectBg = transform:Find("SelectBg").gameObject
    self.imageHaveGot = transform:Find("HaveGot").gameObject
    self.imageHaveGotActive = false
end

function LuckeyChestItem:__delete()
    self:ReleaseField("itemSlot")
    self:ReleaseField("effect")
end

function LuckeyChestItem:InitItemSlot()
    local itemSlot = ItemSlot.New()
    self.itemSlot = itemSlot
    local itemData = ItemData.New()
    self.itemData = itemData
    local base = DataItem.data_get[self.config.item_id]
    itemData:SetBase(base)
    itemData.quantity = self.config.num
    itemSlot:SetAll(itemData, {inbag = false, nobutton = true})
    UIUtils.AddUIChild(self.transform:Find("Bg").gameObject, itemSlot.gameObject)
end

function LuckeyChestItem:ShowSelctBg(show)
    self.selectBg:SetActive(show)
end

function LuckeyChestItem:ShowHaveGot(show)
    self.imageHaveGot:SetActive(show)
    self.imageHaveGotActive = show
    self.itemSlot.gameObject:SetActive(not show)
    if self.effect ~= nil then
        self.effect:SetActive(not show)
    end
end

function LuckeyChestItem:ShowEffect(id, transform, scale, position, time)
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(transform)
        effectObject.name = "Effect"
        effectObject.transform.localScale = scale
        effectObject.transform.localPosition = position
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    end
    return BaseEffectView.New({effectId = id, time = time, callback = fun})
end

function LuckeyChestItem:ReleaseField(fieldName)
    if self[fieldName] ~= nil then
        self[fieldName]:DeleteMe()
        self[fieldName] = nil
    end
end

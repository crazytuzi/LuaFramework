RankRewardItem = RankRewardItem or BaseClass()

function RankRewardItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject

    local t = gameObject.transform
    self.transform = gameObject.transform
    self.nameText = t:Find("Title/Text"):GetComponent(Text)
    self.Container = t:Find("Mask/Container")
    self.layout = LuaBoxLayout.New(t:Find("Mask/Container"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 12})
    self.firstPlaceTrans = t:Find("FirstPlace")

    self.rect = gameObject:GetComponent(RectTransform)

    self.parentRect = nil

    t:Find("Mask"):GetComponent(ScrollRect).enabled = false

    self.slot = {}
    self.slotData = {}
    self.effectList = {}
end

function RankRewardItem:__delete()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.slot ~= nil then
        for k,v in pairs(self.slot) do
            if v ~= nil then
                v:DeleteMe()
                self.slot[k] = nil
                v = nil
            end
        end
        self.slot = nil
    end
    if self.slotData ~= nil then
        for k,v in pairs(self.slotData) do
            if v ~= nil then
                v:DeleteMe()
                self.slotData[k] = nil
                v = nil
            end
        end
        self.slotData = nil
    end

    for _,v in pairs(self.effectList) do
        v:DeleteMe()
    end
    self.effectList = nil
end

function RankRewardItem:SetData(data, index)
    self.parentRect = self.transform.parent:GetComponent(RectTransform)
    self.index = index

    if data == nil then
        self:SetActive(false)
        return
    end
    self.nameText.text = data.conds

    local cell = nil
    self.layout:ReSet()
    for i,v in ipairs(data.rewardgift) do
        if self.slot[i] == nil then
            self.slot[i] = ItemSlot.New()
            self.slotData[i] = ItemData.New()
            self.slot[i].transform.sizeDelta = Vector2(60, 60)
        end
        cell = DataItem.data_get[v[1]]
        self.slotData[i]:SetBase(cell)
        self.slotData[i].quantity = v[2]
        self.slot[i]:SetAll(self.slotData[i], {inbag = false, nobutton = true})
        self.layout:AddCell(self.slot[i].gameObject)

        if v[3] ~= nil and tonumber(v[3]) == 1 then
            if self.effectList[i] == nil then
                local fun = function(effectView)
                    local effectObject = effectView.gameObject
                    effectObject.transform:SetParent(self.slot[i].transform)
                    effectObject.transform.localScale = Vector3.one
                    effectObject.transform.localPosition = Vector3(30, 0, 0)
                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                    effectObject:SetActive(self.index < 4)
                end
                local effect = BaseEffectView.New({effectId = 20223, time = nil, callback = fun})
                self.effectList[i] = effect
            else
                self.effectList[i].gameObject:SetActive(true)
            end
        end
    end
    for i=#data.rewardgift + 1, #self.slot do
        self.slot[i].gameObject:SetActive(false)
    end

    self.firstPlaceTrans:SetParent(self.gameObject.transform)
    self.firstPlaceTrans.anchoredPosition = Vector2(225, 23)
    -- if #data.rewardgift >= 3 then
    --     self.firstPlaceTrans.anchoredPosition = Vector2(330, 23)
    -- else
        -- self.firstPlaceTrans.anchoredPosition = Vector2(172.6 + #data.rewardgift * 60 + (#data.rewardgift - 1) * 12, 23)
    -- end
    self.firstPlaceTrans:SetParent(self.Container)
    self:SetActive(true)
end

function RankRewardItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function RankRewardItem:OnValueChanged()
    local selfy = math.abs(self.rect.anchoredPosition.y)
    local y = self.parentRect.anchoredPosition.y

    local show = true
    if (selfy + 81) - (288 + y) > 20 or y - selfy > 20 then
        show = false
    end

    if show then
        for k,v in pairs(self.effectList) do
            if v.gameObject ~= nil then
                v.gameObject:SetActive(true)
            end
        end
    else
        for k,v in pairs(self.effectList) do
            if v.gameObject ~= nil then
                v.gameObject:SetActive(false)
            end
        end
    end
end

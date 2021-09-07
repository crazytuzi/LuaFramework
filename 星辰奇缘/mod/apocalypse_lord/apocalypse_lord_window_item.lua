-- @author 黄耀聪
-- @date 2017年3月22日

ApocalypseLordWindowItem = ApocalypseLordWindowItem or BaseClass()

function ApocalypseLordWindowItem:__init(model, gameObject, parent)
    self.model = model
    self.parent = parent
    self.gameObject = gameObject
    self.transform = gameObject.transform

    local t = self.transform
    self.item = t:Find("Item")
    self.iconBgImage = t:Find("Item/IconBg"):GetComponent(Image)
    self.iconImage = t:Find("Item/Icon"):GetComponent(Image)
    self.button = self.item:GetComponent(Button)
    self.titleText = self.item:Find("Title"):GetComponent(Text)
    self.lockObj = self.item:Find("Lock").gameObject

    self.height = self.transform.sizeDelta.y

    self.button.onClick:AddListener(function() self:OnClick() end)
end

function ApocalypseLordWindowItem:__delete()
    self.assetWrapper = nil
    self.iconImage.sprite = nil
    self.iconBgImage.sprite = nil
end

function ApocalypseLordWindowItem:update_my_self(data, index)
    self.index = index
    self.data = data

    local model = self.model
    local cfgData = self.model:GetUnitData(data.base_id, data.difficulty)
    if cfgData ~= nil then
        if cfgData.stage == 2 and self.model.status ~= 3 then
            self.titleText.text = cfgData.name
            self.iconImage.gameObject:SetActive(true)
            self.iconImage.color = Color(0.43, 0.43, 0.43, 1)
            self.lockObj:SetActive(true)
        elseif cfgData.stage == 1 and self.model.status == 3 then
            self.titleText.text = cfgData.name
            self.iconImage.gameObject:SetActive(true)
            self.iconImage.color = Color(0.43, 0.43, 0.43, 1)
            self.lockObj:SetActive(false)
        else
            self.titleText.text = cfgData.name
            self.iconImage.gameObject:SetActive(true)
            self.iconImage.color = Color.white
            self.lockObj:SetActive(false)
        end
        self.iconImage.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.starchallenge_textures, cfgData.head_id + 5)
        self.iconBgImage.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.starchallenge_textures, string.format("Round%s", cfgData.head_color))
        self:SetEffect(cfgData.stage == 2 and self.model.status == 3)
    end
end

function ApocalypseLordWindowItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function ApocalypseLordWindowItem:SetScale(value)
    local scale = Vector3(value, value, 1)
    self.iconBgImage.transform.localScale = scale
    self.iconImage.transform.localScale = scale
    self.lockObj.transform.localScale = scale
end

function ApocalypseLordWindowItem:OnClick()
    if self.clickCallback ~= nil and self.index ~= nil then
        -- if self.data.isLock == true then
        --     NoticeManager.Instance:FloatTipsByString(string.format(TI18N("达到<color='#ffff00'>%s境界</color>后，可开启更多境界"), TalismanEumn.FlowerColorName[DataTalisman.data_fusion[self.data.id].color - 1]))
        -- else
            self.clickCallback(self.index)
        -- end
    end
end

function ApocalypseLordWindowItem:SetEffect(show)
    if show then
        if self.effect == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.name = "Effect"
                effectObject.transform:SetParent(self.item)
                effectObject.transform.localScale = Vector3.one
                effectObject.transform.localPosition = Vector3(9, 4, -400)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                effectObject:SetActive(true)

                self.effect = effectView
            end
            self.effect = BaseEffectView.New({effectId = 20484, time = nil, callback = fun})
        else
            self.effect:SetActive(true)
        end
    elseif self.effect ~= nil then
        self.effect:SetActive(false)
    end
end

function ApocalypseLordWindowItem:HideEffect()
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end
-- @author 黄耀聪
-- @date 2017年3月22日

TalismanAdditionItem = TalismanAdditionItem or BaseClass()

function TalismanAdditionItem:__init(model, gameObject, parent)
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

function TalismanAdditionItem:__delete()
    self.assetWrapper = nil
    self.iconImage.sprite = nil
    self.iconBgImage.sprite = nil
end

function TalismanAdditionItem:update_my_self(data, index)
    self.index = index
    self.data = data
    if data.isEmpty == true then
        self.item.gameObject:SetActive(false)
    else
        if data.unknown == true then
            -- 显示未完待续
            self.lockObj:SetActive(true)
            self.iconImage.gameObject:SetActive(false)
            self.titleText.text = TI18N("其他境界")
            self.item.gameObject:SetActive(true)
        else
            local model = self.model
            local cfgData = DataTalisman.data_fusion[data.id]
            if cfgData.lev == (self.model.fusion_lev or 0) then
                self.titleText.text = string.format("<color='#ffff00'>%s</color>", cfgData.name)
            -- elseif cfgData.lev == 1 and self.model.fusion_lev == 0 then
            --     self.titleText.text = string.format("<color='#ffff00'>%s</color>", cfgData.name)
            else
                self.titleText.text = cfgData.name
            end
            self.item.gameObject:SetActive(true)

            if (model.fusion_lev == nil or model.fusion_lev == 0) and cfgData.lev == 1 then
                self.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_fusion_textures, tostring(cfgData.icon))
                self.iconImage.gameObject:SetActive(true)
                self.lockObj:SetActive(false)
            elseif (model.fusion_lev or 0) < cfgData.lev then
                self.lockObj:SetActive(true)
                self.iconImage.gameObject:SetActive(false)
            else
                self.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_fusion_textures, tostring(cfgData.icon))
                self.iconImage.gameObject:SetActive(true)
                self.lockObj:SetActive(false)
            end
        end
    end
end

function TalismanAdditionItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function TalismanAdditionItem:SetScale(value)
    local scale = Vector3(value, value, 1)
    self.iconBgImage.transform.localScale = scale
    self.iconImage.transform.localScale = scale
    self.lockObj.transform.localScale = scale
end

function TalismanAdditionItem:OnClick()
    if self.clickCallback ~= nil and self.index ~= nil then
        if self.data.unknown == true then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("达到<color='#ffff00'>%s境界</color>后，可开启更多境界"), TalismanEumn.FlowerColorName[DataTalisman.data_fusion[self.data.id].color - 1]))
        else
            self.clickCallback(self.index)
        end
    end
end
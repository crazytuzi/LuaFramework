WarriorHeadItem = WarriorHeadItem or BaseClass()

function WarriorHeadItem:__init(gameObject, assetWrapper)
    self.assetWrapper = assetWrapper
    self.gameObject = gameObject

    self.transform = gameObject.transform
    self.image = self.transform:Find("Image"):GetComponent(Image)
    self.addObj = self.transform:Find("Add").gameObject
    self.extraText = self.transform:Find("ExtraText"):GetComponent(Text)
    self.extraBg = self.transform:Find("ImageBg")
    self.attrText = self.transform:Find("Attr/Text"):GetComponent(Text)
    self.arrowImage1 = self.transform:Find("Attr/Arrow1"):GetComponent(Image)
    self.arrowImage2 = self.transform:Find("Attr/Arrow2"):GetComponent(Image)
    self.attr = self.transform:Find("Attr")
    self.attrBg = self.transform:Find("Attr/Image")
    self.btn = gameObject:GetComponent(Button)

    self.effect = nil
end

function WarriorHeadItem:__delete()
    self.arrowImage1.sprite = nil
    self.arrowImage2.sprite = nil
    self.image.sprite = nil
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    self.btn.onClick:RemoveAllListeners()
end

function WarriorHeadItem:Default()
    self.addObj:SetActive(true)
    self.image.gameObject:SetActive(false)
    self.extraBg.gameObject:SetActive(false)
    self.extraText.text = ""
    self.arrowImage1.gameObject:SetActive(false)
    self.arrowImage2.gameObject:SetActive(false)
    self.attrBg.gameObject:SetActive(false)
    self.attrText.gameObject:SetActive(false)
end

function WarriorHeadItem:SetData(data)
    if data == nil then
        self:Default()
        return
    end

    if data.type == 1 then          -- 角色
        self.image.gameObject:SetActive(true)
        self.addObj.gameObject:SetActive(false)
        self.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", data.classes, data.sex))
        self.extraBg.gameObject:SetActive(false)
        self.extraText.gameObject:SetActive(false)
        self:ShowEffect(false)
    elseif data.type == 2 then      -- 宠物
        if data.base_id ~= nil then
            self.image.gameObject:SetActive(true)
            self.addObj.gameObject:SetActive(false)
            self:ShowEffect(false)
            if self.headLoader == nil then
                self.headLoader = SingleIconLoader.New(self.image.gameObject)
            end
            self.headLoader:SetSprite(SingleIconType.Pet,DataPet.data_pet[data.base_id].head_id)
            -- self.image.sprite = PreloadManager.Instance:GetPetSprite(DataPet.data_pet[data.base_id].head_id)
        else
            self.image.gameObject:SetActive(false)
            self.addObj.gameObject:SetActive(true)
            self:ShowEffect(true)
        end
        self.extraBg.gameObject:SetActive(false)
        self.extraText.gameObject:SetActive(false)
    elseif data.type == 3 then      -- 守护
        self:ShowEffect(false)
        if data.base_id ~= nil and data.base_id ~= 0 then
            self.image.gameObject:SetActive(true)
            self.addObj.gameObject:SetActive(false)
            self.image.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(data.base_id))
        else
            self.image.gameObject:SetActive(false)
            self.addObj.gameObject:SetActive(true)
        end
        self.extraBg.gameObject:SetActive(false)
        self.extraText.gameObject:SetActive(false)
    end

    self.attr.gameObject:SetActive(true)

    local str = ""
    local attr = data.effect[1]
    if attr ~= nil then
        self.arrowImage1.gameObject:SetActive(true)
        str = KvData.attr_name_show[attr.attr_name]
        if attr.val > 0 then
            self.arrowImage1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
        else
            self.arrowImage1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
        end
    else
        self.arrowImage1.gameObject:SetActive(false)
    end

    attr = data.effect[2]
    if attr ~= nil then
        self.arrowImage2.gameObject:SetActive(true)
        str = string.format("%s\n%s", str, KvData.attr_name_show[attr.attr_name])
        if attr.val > 0 then
            self.arrowImage2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
        else
            self.arrowImage2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
        end
    else
        self.arrowImage2.gameObject:SetActive(false)
    end
    self.attrText.text = str
    self.attrBg.gameObject:SetActive(true)

    self:SetExt()

    if #data.effect == 0 then
    elseif #data.effect == 1 then
        self.attrBg.gameObject:SetActive(true)
        self.attrText.gameObject:SetActive(true)
        self.arrowImage1.transform.anchoredPosition = Vector2(20.9, 0)
        self.arrowImage2.gameObject:SetActive(false)
        self.attrBg.sizeDelta = Vector2(70, 25)
    elseif #data.effect == 2 then
        self.attrBg.gameObject:SetActive(true)
        self.arrowImage1.transform.anchoredPosition = Vector2(20.9, 12.4)
        self.attrText.gameObject:SetActive(true)
        self.arrowImage2.gameObject:SetActive(true)
        self.attrBg.sizeDelta = Vector2(70, 40)
    end
end

function WarriorHeadItem:SetExt(str)
    self.attrBg.gameObject:SetActive(false)
    self.attrText.gameObject:SetActive(false)
    if str ~= nil then
        self.extraBg.gameObject:SetActive(true)
        self.extraText.gameObject:SetActive(true)
        self.extraText.text = str
    else
        self.extraBg.gameObject:SetActive(false)
        self.extraText.gameObject:SetActive(false)
    end
end

function WarriorHeadItem:ShowEffect(bool)
    if bool == true then
        if self.effect == nil then
            self.effect = BibleRewardPanel.ShowEffect(20053, self.addObj.transform, Vector3(0.9, 0.9, 1), Vector3(-30, -21, -400))
        else
            self.effect:SetActive(true)
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end

-- 作者:jia
-- 5/18/2017 5:58:29 PM
-- 功能:新手任务奖励展示装备item
TeamQuestShowEquipItem = TeamQuestShowEquipItem or BaseClass()
function TeamQuestShowEquipItem:__init(origin_item, _index)
    self.index = _index
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.gameObject:SetActive(true)

    self.TxtPos = self.transform:Find("TxtPos"):GetComponent(Text)
    self.SlotCon = self.transform:Find("SlotCon")
    self.ImgQuality = self.transform:Find("ImgQuality"):GetComponent(Image)
    local newX =(_index - 1) * 55
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(newX, 0)

    self.slot = nil
    self.extra = {
        nobutton = true
    }
end

function TeamQuestShowEquipItem:__delete()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
end

function TeamQuestShowEquipItem:SetData(euqioData)
    if euqioData == nil then
        self.SlotCon.gameObject:SetActive(false)
        self.TxtPos.gameObject:SetActive(true)
        self.ImgQuality.gameObject:SetActive(false)
        return
    end
    self.ImgQuality.gameObject:SetActive(true)
    self.SlotCon.gameObject:SetActive(true)
    self.TxtPos.gameObject:SetActive(false)
    if self.slot == nil then
        self.slot = ItemSlot.New()
    end
    self.slot:SetAll(euqioData, self.extra)
    self.slot.itemImgRect.sizeDelta = Vector2.one * 53
    if euqioData.quality > 2 then
        self.ImgQuality.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Item%s", euqioData.quality + 1))
    end
    UIUtils.AddUIChild(self.SlotCon.gameObject, self.slot.gameObject)
end
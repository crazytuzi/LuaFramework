ClassesChangeItem = ClassesChangeItem or BaseClass()

function ClassesChangeItem:__init(model,gameObject,parent)
    self.model = model
    self.parent = parent
    self.gameObject = gameObject
    self.transform = gameObject.transform

    local t = self.transform
    self.item = t:Find("Item")
    self.icon = self.item:Find("Icon"):GetComponent(Image)
    self.selectedImg = self.item:Find("Selected"):GetComponent(Image)

    self.button = self.item:GetComponent(Button)

    self.button.onClick:AddListener(function() self:OnClick() end)
end

function ClassesChangeItem:__delete()
    self.assetWrapper = nil
    self.selectedImg.sprite = nil
    self.icon.sprite = nil
end

function ClassesChangeItem:update_my_self(data, index)

    self.index = index
    self.data = data

    self.selectedImg.gameObject:SetActive(false)
end


function ClassesChangeItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end


function ClassesChangeItem:SetScale(value)
    local scale = Vector3(value, value, 1)
    self.icon.transform.localScale = scale
    self.selectedImg.transform.localScale = scale
end


function ClassesChangeItem:OnClick()
    if self.clickCallback ~= nil and self.index ~= nil then
        --if self.data.unknown == true then
        --   NoticeManager.Instance:FloatTipsByString(string.format(TI18N("达到<color='#ffff00'>%s境界</color>后，可开启更多境界"), TalismanEumn.FlowerColorName[DataTalisman.data_fusion[self.data.id].color - 1]))
        --else
            self.clickCallback(self.index)
        --end
    end
end
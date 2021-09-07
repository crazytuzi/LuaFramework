SkillLifeItem = SkillLifeItem or BaseClass()

function SkillLifeItem:__init(parent, origin_item, index)
    self.parent = parent
    self.index = index
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform

    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one

    self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform
    self.btn = self.transform:GetComponent(Button)
    self.ImgCon = self.transform:FindChild("ImgCon").gameObject
    self.Img = self.ImgCon.transform:FindChild("Img"):GetComponent(Image)
    self.ImgName = self.transform:FindChild("ImgName"):GetComponent(Image)
    self.TxtName = self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtLev = self.transform:FindChild("TxtLev"):GetComponent(Text)
    self.ImgSelect = self.transform:FindChild("ImgSelect").gameObject
    self.ImgSelect:SetActive(false)
    self.ImgPoint = self.transform:FindChild("ImgPoint").gameObject

    self.ImgPoint:SetActive(false)

    self.btn.onClick:AddListener(function() self:on_click() end) --BtnRest

    local newY = (self.index - 1)*-82
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(5, newY)
end

function SkillLifeItem:Release()
    self.Img.sprite = nil
    self.ImgName.sprite = nil
end

function SkillLifeItem:InitPanel(_data)

end


function SkillLifeItem:set_item_data(data)
    self.data = data
    self.Img.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.skill_life_icon, tostring(data.id))
    self.ImgName.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.skill_life_name, tostring(data.id))
    self.ImgName:SetNativeSize()
    self.TxtName.text = data.name
    self.TxtLev.text = string.format("Lv.%s", tostring(data.lev))

    if self.data.id == 10004 or self.data.id == 10003 or self.data.id == 10008 then
         self.ImgPoint:SetActive(false)
    else

        if #self.data.product == 0 then
            self.ImgPoint:SetActive(false)
        else
            local state = SkillManager.Instance.model:check_huoli_val()
            self.ImgPoint:SetActive(state)
        end
    end
end

function SkillLifeItem:on_click()
    self.parent:update_right_con(self)
end
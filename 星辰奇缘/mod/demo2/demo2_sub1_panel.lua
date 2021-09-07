Demo2Sub1Panel = Demo2Sub1Panel or BaseClass(BasePanel)

function Demo2Sub1Panel:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.demo2_panel1, type = AssetType.Main}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.font, type = AssetType.Dep}
    }

    self.vContainer = nil
    self.hContainer = nil
    self.gContainer = nil

    self.vRect = nil
    self.hRect = nil
    self.gRect = nil

    self.vItem = nil
    self.hItem = nil
    self.gItem = nil
end

function Demo2Sub1Panel:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function Demo2Sub1Panel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.demo2_panel1))
    self.gameObject.name = "Demo2Panel1"
    self.gameObject.transform:SetParent(self.parent.mainObj.transform)
    self.gameObject.transform.localPosition = Vector3.zero
    self.gameObject.transform.localScale = Vector3.one
    self.gameObject:SetActive(true)

    self.vContainer = self.gameObject.transform:Find("VScroll/Container").gameObject
    self.vRect = self.vContainer:GetComponent(RectTransform)
    self.vItem = self.gameObject.transform:Find("VScroll/Item").gameObject
    self.vItem:SetActive(false)

    self.hContainer = self.gameObject.transform:Find("HScroll/Container").gameObject
    self.hRect = self.hContainer:GetComponent(RectTransform)
    self.hItem = self.gameObject.transform:Find("HScroll/Item").gameObject
    self.hItem:SetActive(false)

    self.gContainer = self.gameObject.transform:Find("GScroll/Container").gameObject
    self.gRect = self.gContainer:GetComponent(RectTransform)
    self.gItem = self.gameObject.transform:Find("GScroll/Item").gameObject
    self.gItem:SetActive(false)

    self:VInitElement()
    self:HInitElement()
    self:GInitElement()
end

function Demo2Sub1Panel:VInitElement()
    local count = 0
    for i = 1,50 do
        local item = GameObject.Instantiate(self.vItem)
        item.name = "item"..i
        local t = item.transform
        t:SetParent(self.vContainer.transform)
        t.localScale = Vector3.one
        t:Find("Text"):GetComponent(Text).text = TI18N("文字 ") .. tostring(i)
        t.localPosition = Vector3(0, -22.5 - (count * 58), 0)
        count = count + 1
        item:SetActive(true)
    end
    self.vRect.sizeDelta = Vector2(230, count * 58)
end

function Demo2Sub1Panel:HInitElement()
    local count = 0
    for i = 1,50 do
        local item = GameObject.Instantiate(self.hItem)
        item.name = "item"..i
        item.transform:SetParent(self.hContainer.transform)
        item.transform.localScale = Vector3.one
        item.transform:Find("Text"):GetComponent(Text).text = TI18N("文字 ")..tostring(i)
        item.transform.localPosition = Vector3(34 + (count * 70), 0, 0)
        count = count + 1
        item:SetActive(true)
    end
    self.hRect.sizeDelta = Vector2(count * 70, 165)
end

function Demo2Sub1Panel:GInitElement()
    local a = 0
    local b = 0
    for i = 1,50 do
        local item = GameObject.Instantiate(self.gItem)
        item.name = "item"..i
        item.transform:SetParent(self.gContainer.transform)
        item.transform:Find("Text"):GetComponent(Text).text = tostring(i)
        item.transform.localScale = Vector3.one
        a = (i - 1) % 5
        b = math.floor((i - 1) / 5)
        item.transform.localPosition = Vector3(40 + a * 85, -40 - b * 85, 0)
        item:SetActive(true)
    end
    self.gRect.sizeDelta = Vector2(490, math.ceil(50/5) * 85)
end

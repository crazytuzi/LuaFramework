Demo2Sub2Panel = Demo2Sub2Panel or BaseClass(BasePanel)

function Demo2Sub2Panel:__init(parent)
    self.parent = parent
    self.resList = {{file = AssetConfig.demo2_panel2, type = AssetType.Main}}

    self.baseItem = nil
    self.container = nil
    self.containerRect = nil

    self.itemTab = {}
end

-- 销毁对象，删除gameobject，清理资源
function Demo2Sub2Panel:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function Demo2Sub2Panel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.demo2_panel2))
    self.gameObject.name = "Demo2Panel2"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainObj.transform)
    self.transform.localPosition = Vector3.zero
    self.transform.localScale = Vector3.one

    self.baseItem = self.transform:Find("Scroll/Button").gameObject
    self.container = self.transform:Find("Scroll/Container").gameObject
    self.containerRect = self.container:GetComponent(RectTransform)
    self.baseItem:SetActive(false)
    self.gameObject:SetActive(true)
    self:InitElement()
end

function Demo2Sub2Panel:InitElement()
    local a = 0
    local b = 0
    for i = 1,100 do
        local item = GameObject.Instantiate(self.baseItem)
        local trans = item.transform
        item.name = "item"..i
        trans:SetParent(self.container.transform)
        trans.localScale = Vector3.one
        trans:Find("Text"):GetComponent(Text).text = TI18N("文字 ") ..tostring(i)
        a = (i - 1) % 8
        b = math.floor((i - 1) / 8)
        item.transform.localPosition = Vector3(45 + a * 90, -45 - b * 90, 0)
        table.insert(self.itemTab, item)
        item:SetActive(true)
    end
    self.containerRect.sizeDelta = Vector2(760, math.ceil(100/8) * 90)
end

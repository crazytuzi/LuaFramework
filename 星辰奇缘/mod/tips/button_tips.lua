-- -----------------------------
-- 按钮tips
-- hosr
-- -----------------------------
ButtonTips = ButtonTips or BaseClass(BaseTips)
function ButtonTips:__init(model)
    self.model = model
    self.mgr = TipsManager.Instance
    self.path = "prefabs/ui/tips/buttontips.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
    }
    self.buttonTab = {}

    self.offsetY = -25
    self.offsetX = -6
    self.spacing = 5

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)
end

function ButtonTips:__delete()
end

function ButtonTips:RemoveTime()
    self.mgr.updateCall = nil
end

function ButtonTips:UnRealUpdate()
    if Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Began then
        local v2 = Input.GetTouch(0).position
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end

    if Input.GetMouseButtonDown(0) then
        local v2 = Input.mousePosition
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end
end

function ButtonTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "ButtonTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.mainRect = self.gameObject:GetComponent(RectTransform)

    -- 最多放10个按钮
    for i = 1, 10 do
        local tab = {}
        local index = i
        local btn = self.transform:GetChild(i - 1)
        tab.gameObject = btn.gameObject
        tab.transform = btn.transform
        tab.rect = btn.gameObject:GetComponent(RectTransform)
        tab.label = btn.transform:Find("Text"):GetComponent(Text)
        tab.label.supportRichText = true
        tab.gameObject:SetActive(false)
        tab.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickBtn(index) end)
        table.insert(self.buttonTab, tab)
    end
end

function ButtonTips:ClickBtn(index)
    local tab = self.buttonTab[index]
    if tab ~= nil and tab.data ~= nil and tab.data.callback ~= nil then
        tab.data.callback()
    end
    self.model:Closetips()
end

-- 到这里的数据是一个数据列表
-- dataList = {{label = "按钮名称", callback = nil}...}
function ButtonTips:UpdateInfo(dataList)
    self.btnWidth = 0
    self.count = 0
    for i,data in ipairs(dataList) do
        self.count = i
        local tab = self.buttonTab[i]
        tab.label.text = tostring(data.label)
        tab.data = data
        self.btnWidth = math.max(self.btnWidth, tab.label.preferredWidth)
    end

    for i = self.count + 1, 10 do
        self.buttonTab[i].gameObject:SetActive(false)
    end

    self:Layout()
    self.mgr.updateCall = self.updateCall
end

function ButtonTips:Layout()
    self.btnWidth = self.btnWidth + 40
    for i = 1, self.count do
        local tab = self.buttonTab[i]
        tab.rect.sizeDelta = Vector2(self.btnWidth, 48)
        tab.rect.anchoredPosition = Vector2(self.offsetX, self.offsetY - (self.spacing + 48) * (i - 1))
        tab.gameObject:SetActive(true)
    end

    self.width = self.btnWidth + 60
    self.height = 48 * self.count + self.spacing * (self.count - 1) - self.offsetY * 2
    self.mainRect.sizeDelta = Vector2(self.width, self.height)
end

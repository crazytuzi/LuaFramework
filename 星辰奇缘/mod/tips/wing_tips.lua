-- ----------------------------
-- 翅膀tips
-- hosr
-- ----------------------------
WingTips = WingTips or BaseClass(BaseTips)

function WingTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_wing, type = AssetType.Main}
    }
    self.mgr = TipsManager.Instance
    self.width = 315
    self.height = 20
    self.buttons = {}
    self.DefaultSize = Vector2(315, 0)

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)

    self.qualityName = {
        TI18N("<color='#4dd52b'>绿色</color>"),
        TI18N("<color='#01c0ff'>蓝色</color>"),
        TI18N("<color='#ff00ff'>紫色</color>"),
        TI18N("<color='#ffa500'>橙色</color>"),
        TI18N("<color='#cc3333'>红色</color>"),
    }

    self.txtTab = {}
end

function WingTips:__delete()
    if self.itemCell ~= nil then
        self.itemCell:DeleteMe()
        self.itemCell = nil
    end
    self.mgr = nil
    self.buttons = {}
    self.height = 20
    self:RemoveTime()
end

function WingTips:RemoveTime()
    self.mgr.updateCall = nil
end

function WingTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_wing))
    self.gameObject.name = "WingTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self.model:Closetips() end)

    self.rect = self.gameObject:GetComponent(RectTransform)

    local head = self.transform:Find("HeadArea")
    self.itemCell = ItemSlot.New(head:Find("ItemSlot").gameObject)
    self.itemCell:SetNotips()
    self.nameTxt = head:Find("Name"):GetComponent(Text)
    self.otherTxt = head:Find("TimeLimit"):GetComponent(Text)

    local mid = self.transform:Find("MidArea")
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.line = mid:Find("Line").gameObject
    self.descObj = mid:Find("Desc").gameObject
    self.descObj:SetActive(false)
    self.descTxt = mid:Find("Desc"):GetComponent(Text)
    self.baseTxt = mid:Find("BaseTxt").gameObject
    self.baseTxt:SetActive(false)

    self.container = mid:Find("Container").gameObject
    self.containerTransform = self.container.transform
    self.containerRect = self.container:GetComponent(RectTransform)

end

function WingTips:UnRealUpdate()
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

function WingTips:Default()
    self.height = 20
    self.nameTxt.text = ""
    self.otherTxt.text = ""
    self.descTxt.text = ""

    self.rect.sizeDelta = self.DefaultSize
end

-- ------------------------------------
-- 外部调用更新数据
-- 参数说明:
-- info = 道具数据
-- ------------------------------------
function WingTips:UpdateInfo(info)
    self:Default()

    self.itemData = info
    self.wingData = info.wingData
    self.nameTxt.text = ColorHelper.color_item_name(self.itemData.quality, self.itemData.name)
    local baseWingData = DataWing.data_base[self.wingData.wing_id]
    if baseWingData ~= nil then
        self.nameTxt.text = ColorHelper.color_item_name(self.wingData.growth, baseWingData.name)
    end
    self.otherTxt.text = string.format(TI18N("%s阶"), BaseUtils.NumToChn(self.wingData.grade))

    self.itemCell:SetAll(self.itemData)
    self.itemCell:ShowNum(false)

    self.height = 105

    -- 处理描述显示
    local th = 0
    -- self.descTxt.text = string.format(TI18N("品质:%s"), self.qualityName[self.wingData.growth])
    self.descTxt.text = ""

    for i,v in ipairs(self.txtTab) do
        v.gameObject:SetActive(false)
    end
    local useCount = 0
    local hh = 0

    local baseData = DataWing.data_attribute[string.format("%s_%s_%s_%s", RoleManager.Instance.RoleData.classes, self.wingData.grade, self.wingData.growth, "0")]
    if baseData ~= nil then
        local attr = baseData.attr
        for i,v in ipairs(attr) do
            useCount = useCount + 1
            local tab = self:GetItem(useCount)
            tab.txt.text = string.format("<color='#97abb4'>%s</color><color='#4dd52b'>+%s</color>", KvData.attr_name[v.attr_name], v.val)
            tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
            tab.rect.anchoredPosition = Vector2(0, -hh - (i - 1) * 25)
        end
    end
    hh = hh + useCount * 25

    self.containerRect.anchoredPosition = Vector2(0, -10)
    self.containerRect.sizeDelta = Vector2(255, hh)
    self.height = self.height + hh + 30
    self.rect.sizeDelta = Vector2(self.width, self.height)

    self.mgr.updateCall = self.updateCall
end

function WingTips:GetItem(index)
    local tab = self.txtTab[index]
    if tab == nil then
        tab = {}
        tab.gameObject = GameObject.Instantiate(self.baseTxt)
        tab.gameObject.name = "Txt"..index
        tab.transform = tab.gameObject.transform
        tab.transform:SetParent(self.containerTransform)
        tab.transform.localScale = Vector3.one
        tab.rect = tab.gameObject:GetComponent(RectTransform)
        tab.txt = tab.gameObject:GetComponent(Text)
        table.insert(self.txtTab, tab)
    end
    tab.gameObject:SetActive(true)
    return tab
end
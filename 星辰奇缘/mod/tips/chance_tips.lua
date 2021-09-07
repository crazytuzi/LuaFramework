-- @author ###   （与window区分开）
-- @date 2018年4月18日,星期三

ChanceShowTips = ChanceShowTips or BaseClass(BaseTips)

function ChanceShowTips:__init(model)
    self.model = model
    self.name = "ChanceShowTips"

    self.resList = {
        {file = AssetConfig.chance_tips, type = AssetType.Main},
    }
    self.mgr = TipsManager.Instance
    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)
    self.tabObjList = {}
    self.HasTableData = false
    self.isScrolling = false
end

function ChanceShowTips:__delete()
    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end
end

function ChanceShowTips:RemoveTime()
    self.mgr.updateCall = nil
end
function ChanceShowTips:UnRealUpdate()
    if self.isScrolling == false then
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
    
end

function ChanceShowTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.chance_tips))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform = t
    --self.gameObject:GetComponent(Button).onClick:AddListener(function() EventMgr.Instance:Fire(event_name.tips_cancel_close) self.model:CloseChancePanel() end)
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchorMax = Vector2.one * 0.5
    self.rect.anchorMin = Vector2.one * 0.5
    self.rect.pivot = Vector2(0, 0.5)
    self.rect.anchoredPosition = Vector2(0,0)
    self.rect.sizeDelta = Vector2(400,147)
    --self.itemChanceTips = self.transform:Find("Main/ItemChanceTips")
    --self.panel = self.transform:Find("Panel"):GetComponent(Button)
    --self.panel.onClick:AddListener(function() TipsManager.Instance.model:CloseChancePanel() end)
    -- self.transform:Find("Main/GrowguidePanel").gameObject:SetActive(false)
    --self.mainTransform = self.transform:Find("Main")
    self.tabTemplate = self.transform:Find("TextTemplate").gameObject
    self.tabTemplate.gameObject:SetActive(false)
    self.DescText = self.transform:Find("Desc")
    self.DescText.gameObject:SetActive(false)
    self.scrollRect = self.transform:Find("ScrollRect"):GetComponent(ScrollRect)
    self.container = self.transform:Find("ScrollRect/Container")
    self.title = self.transform:Find("TitleBg/Text")
    --self.tabLayout = LuaBoxLayoutLuaBoxLayout.New(self.container.gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})
end

function ChanceShowTips:UpdateInfo(info)
    if self.tabLayout ~= nil then
        self.tabLayout:Clear()
    end
    self.tabObjList = {}
    self.DescText:GetComponent(Text).text = ""

    self.chanceId = info.chanceId
    self.chanceData = info.chanceData
    self.isMutil = info.isMutil or false
    self.classList = {}
    self.mgr.updateCall = self.updateCall
    if self.chanceId ~= nil then
        for k,v in pairs(DataItem.data_chance_item) do
            if v.chance_id == self.chanceId then
                table.insert(self.classList,v)
                self.HasTableData = true
            end
        end
    else
        if self.chanceData ~= nil then
            self.DescText:GetComponent(Text).text = self.chanceData[1]
            if self.chanceData[2] ~= nil then
                self.title:GetComponent(Text).text = self.chanceData[2]
            end
            self.DescText.sizeDelta = Vector2(356, self.DescText:GetComponent(Text).preferredHeight + 5)
            self.container.gameObject:SetActive(false)
            self.DescText.gameObject:SetActive(true)
            self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x,110 + self.DescText.sizeDelta.y)
            return
        end
    end
    self.DescText.gameObject:SetActive(false)
    if #self.classList >= 10 then
        self.tabLayout = LuaGridLayout.New(self.container, {column = 2, cellSizeX = 170, cellSizeY = 30, bordertop = 2, borderleft = 2})
    else
        self.tabLayout = LuaGridLayout.New(self.container, {column = 1, cellSizeX = 170, cellSizeY = 30, bordertop = 2, borderleft = 95})
    end

    for i,v in ipairs(self.classList) do
        if v ~= nil then
            if self.tabObjList[i] == nil then
                local obj = GameObject.Instantiate(self.tabTemplate)
                self.tabObjList[i] = obj
                self.tabLayout:AddCell(obj)
            end

            self.tabObjList[i].transform:Find("Text1"):GetComponent(Text).text = v.chance
            self.tabObjList[i].transform:Find("Text2"):GetComponent(Text).text = v.name
        end
    end

    self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x,130 + self.container.transform.sizeDelta.y)
    if 130 + self.container.transform.sizeDelta.y > 400 then
        self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x,400)
        self.scrollRect.transform.sizeDelta = Vector2(self.container.transform.sizeDelta.x,310)
        self.scrollRect.movementType = ScrollRect.MovementType.Elastic
    else
        self.scrollRect.movementType = ScrollRect.MovementType.Clamped

        self.scrollRect.transform.sizeDelta = Vector2(self.container.transform.sizeDelta.x,self.container.transform.sizeDelta.y)
        self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x,130 + self.container.transform.sizeDelta.y)
    end
end



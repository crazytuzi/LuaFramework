-- ----------------------------
-- 概率Tips
-- zyh
-- ----------------------------

ChangeTipsWindow = ChangeTipsWindow or BaseClass(BaseWindow)

function ChangeTipsWindow:__init(parent)
    self.model = GodsWarManager.Instance.model
    self.parent = parent
    self.windowId = WindowConfig.WinID.change_tips_window
    self.resList = {
        {file = AssetConfig.chancetips_window, type = AssetType.Main},
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.tabObjList = {}

end

function ChangeTipsWindow:__delete()

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end
end



function ChangeTipsWindow:OnHide()
end

function ChangeTipsWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.chancetips_window))
    self.gameObject.name = "ChangeTipsWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    -- self.transform.localScale = Vector3.one
    -- self.transform.localPosition = Vector3.zero
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0,0)
    self.itemChanceTips = self.transform:Find("Main/ItemChanceTips")
    self.panel = self.transform:Find("Panel"):GetComponent(Button)
    self.panel.onClick:AddListener(function() TipsManager.Instance.model:CloseChancewindow() end)
    -- self.transform:Find("Main/GrowguidePanel").gameObject:SetActive(false)
    self.mainTransform = self.transform:Find("Main")
    self.tabTemplate = self.transform:Find("Main/ItemChanceTips/TextTemplate").gameObject
    self.tabTemplate.gameObject:SetActive(false)
    self.scrollRect = self.transform:Find("Main/ItemChanceTips/ScrollRect"):GetComponent(ScrollRect)
    self.container = self.transform:Find("Main/ItemChanceTips/ScrollRect/Container")
    self.tabLayout = LuaBoxLayout.New(self.container.gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})




    self.OnOpenEvent:Fire()
end

function ChangeTipsWindow:OnShow()
    self:Layout()
end

function ChangeTipsWindow:Layout()
    self.classList = {}
    for k,v in pairs(DataItem.data_chance_item) do
        if v.chance_id == self.openArgs then
            table.insert(self.classList,v)
        end
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

    self.itemChanceTips.transform.sizeDelta = Vector2(self.itemChanceTips.transform.sizeDelta.x,130 + self.container.transform.sizeDelta.y)
    if 130 + self.container.transform.sizeDelta.y > 400 then
        self.itemChanceTips.transform.sizeDelta = Vector2(self.itemChanceTips.transform.sizeDelta.x,400)
        self.scrollRect.transform.sizeDelta = Vector2(self.container.transform.sizeDelta.x,310)
        self.scrollRect.movementType = ScrollRect.MovementType.Elastic
    else
        self.scrollRect.movementType = ScrollRect.MovementType.Clamped

        self.scrollRect.transform.sizeDelta = Vector2(self.container.transform.sizeDelta.x,self.container.transform.sizeDelta.y)
        self.itemChanceTips.transform.sizeDelta = Vector2(self.itemChanceTips.transform.sizeDelta.x,130 + self.container.transform.sizeDelta.y)
    end
end



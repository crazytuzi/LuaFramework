-- @author zyh(花朵收集)
-- @date 2017年9月20日

NationalSecondFlowerTipsPanel = NationalSecondFlowerTipsPanel or BaseClass(BasePanel)


function NationalSecondFlowerTipsPanel:__init(parent,parentTr)
    self.parent = parent
    self.parentTr = parentTr
    self.name = "NationalSecondFlowerTipsPanel"
    -- self.Effect = "prefabs/effect/20298.unity3d"
    self.resList = {
        {file = AssetConfig.nationalsecond_tips_panel, type = AssetType.Main}
        ,{file = AssetConfig.combat_uires,type = AssetType.Dep}
    }

    self.pageConut = 8
    self.setting = {
        column = 4
        ,cspacing = 10
        ,rspacing = 1
        ,cellSizeX = 64
        ,cellSizeY = 64
        ,borderleft = 23
        ,bordertop = 0
    }

    self.itemSlotList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
     self.maxPage = 2
     self.toggleTab = {}
     self.layoutList = {}
     self.initTab = {}
    self.extra = {inbag = false, nobutton = true}
end


function NationalSecondFlowerTipsPanel:OnInitCompleted()

end

function NationalSecondFlowerTipsPanel:__delete()

    self:OnHide()

    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
    end
    self.tabbedPanel = nil

    if self.layoutList ~= nil then
        for k,v in pairs(self.layoutList) do
            v:DeleteMe()
        end
        self.layoutList = nil
    end

    if self.itemSlotList ~= nil then
        for k,v in pairs(self.itemSlotList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.itemSlotList = nil
    end
    self:AssetClearAll()

end

function NationalSecondFlowerTipsPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationalsecond_tips_panel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "NationalSecondFlowerTipsPanel"
    self.transform = self.gameObject.transform

    self.scrollRect = self.transform:Find("MainCon/ScrollRect"):GetComponent(ScrollRect)
    self.content = self.transform:Find("MainCon/ScrollRect/Container")
    self.content.transform.sizeDelta = Vector2(700,196)


    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.giveButton = self.transform:Find("MainCon/GiveButton"):GetComponent(Button)
    self.giveButton.onClick:AddListener(function() self:ApplyGiveButton() end)
    for i = 1, 2 do
        local page = self.content:GetChild(i-1).gameObject
        table.insert(self.initTab,page)
        table.insert(self.layoutList, LuaGridLayout.New(page, self.setting))
    end
    self.transform:SetAsFirstSibling()
    for i,v in ipairs(self.layoutList) do
        for i = 1,8 do
            local itemSlot = ItemSlot.New()
            itemSlot:Default()
            table.insert(self.itemSlotList,itemSlot)
            v:UpdateCellIndex(itemSlot.gameObject,i)
        end
    end

    self.tabbedPanel = TabbedPanel.New(self.scrollRect.gameObject,self.maxPage,348)
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnMoveEnd(currentPage, direction) end)

    self.toggleGroup = self.transform:Find("MainCon/ToggleGroup")
    for i = 1,2 do
        self.toggleTab[i] = self.toggleGroup:GetChild(i - 1):GetComponent(Toggle)
        self.toggleTab[i].gameObject:SetActive(true)
    end
    self:OnOpen()
end

function NationalSecondFlowerTipsPanel:ApplyGiveButton()
    self:Hiden()
    if #self.list == 0 then
        NoticeManager.Instance:FloatTipsByString("当前<color='#FFFF00'>没有可赠送的花语</color>，快努力收集吧{face_1,18}")
    else
        local data = {index =2 }
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.giftwindow,data)
    end
end
function NationalSecondFlowerTipsPanel:OnHide()

end

function NationalSecondFlowerTipsPanel:OnOpen()
    self:ResetPanel()
end

function NationalSecondFlowerTipsPanel:OnMoveEnd(currentPage, direction)
    self:OnChangePage(currentPage)
    if self.initTab[currentPage] == nil then
        self:InitPage(currentPage)
    end
    if currentPage < self.maxPage and self.initTab[currentPage + 1] == nil then
        self:InitPage(currentPage + 1)
    end

end

function NationalSecondFlowerTipsPanel:InitPage(currentPage)

end

function NationalSecondFlowerTipsPanel:OnChangePage(index)
    if self.toggleTab[index] ~= nil then
        self.toggleTab[index].isOn = true
    end
end

function NationalSecondFlowerTipsPanel:ResetPanel()
    self.list = NationalSecondManager.Instance.flowerGiveFriendData

    for i,v in ipairs(self.list) do
        local cell = DataItem.data_get[v.id]
        local itemdata = ItemData.New()
        itemdata:SetBase(cell)
        self.itemSlotList[i]:SetAll(itemdata,self.extra)
        self.itemSlotList[i]:SetNum(v.num)
    end
    self.tabbedPanel:TurnPage(1)
    if #self.list <9 then
        self.toggleGroup.gameObject:SetActive(false)
        self.tabbedPanel:SetPageCount(1)
        self.scrollRect.enabled = false

    else
        self.toggleGroup.gameObject:SetActive(true)
        self.tabbedPanel:SetPageCount(2)
        self.scrollRect.enabled = true
    end

    self:OnChangePage(1)
end

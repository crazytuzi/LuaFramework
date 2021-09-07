-- 9格小背包
-- ljh 20170602

QuickBackpackWindow = QuickBackpackWindow or BaseClass(BasePanel)

function QuickBackpackWindow:__init(model)
    self.model = model
    self.name = "QuickBackpackWindow"

    self.buffItemObjList = {}

    self.resList = {
        {file = AssetConfig.quickbackpackwindow, type = AssetType.Main}
    }


    self.pageList = {}
    self.itemList = {}
    self.itemSlotList = {}
    self.toggleList = {}
	self.curPage = 1

    --------------------------------------
    self._Update = function() self:Update() end
    self._UpdateItem = function() self:UpdateItem() end

    --------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function QuickBackpackWindow:__delete()
    self:OnHide()

    if self.pageLayout ~= nil then
        self.pageLayout:DeleteMe()
        self.pageLayout = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function QuickBackpackWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.quickbackpackwindow))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:SetAsLastSibling()
    -- self.transform.localPosition = Vector3(0, 0, -1)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    --------------------------------------
    self.transform:Find("Main/Button1"):GetComponent(Button).onClick:AddListener(function() self:OnClickButton1() end)
    self.transform:Find("Main/Button2"):GetComponent(Button).onClick:AddListener(function() self:OnClickButton2() end)
    self.transform:Find("Main/Button3"):GetComponent(Button).onClick:AddListener(function() self:OnClickButton3() end)

    --------------------------------------
    self.toggleLayout = LuaBoxLayout.New(self.transform:Find("Main/Toggle"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 10})
    self.toggleCloner = self.transform:Find("Main/Toggle/Cloner").gameObject
    self.pageCloner = self.transform:Find("Main/Scroll/Page").gameObject
    self.pageCloner:SetActive(false)
    self.pageLayout = LuaBoxLayout.New(self.transform:Find("Main/Scroll/Container"), {axis = BoxLayoutAxis.X, cspacing = 0})
    self.pageTabbedPanel = TabbedPanel.New(self.transform:Find("Main/Scroll").gameObject, 0, 225, 0.5)
    self.pageTabbedPanel.MoveEndEvent:AddListener(function(page) self:OnMoveEnd(page) end)
    --------------------------------------
    self:OnShow()
end

function QuickBackpackWindow:OnShow()
	EventMgr.Instance:AddListener(event_name.backpack_item_change, self._UpdateItem)

	 if self.openArgs ~= nil then
        self.checkFun = self.openArgs.checkFun

        if self.openArgs.showButtonType == 1 then
        	self.transform:Find("Main/Button1").gameObject:SetActive(true)
        	self.transform:Find("Main/Button2").gameObject:SetActive(true)
        	self.transform:Find("Main/Button3").gameObject:SetActive(false)
        else
        	self.transform:Find("Main/Button1").gameObject:SetActive(false)
        	self.transform:Find("Main/Button2").gameObject:SetActive(false)
        	self.transform:Find("Main/Button3").gameObject:SetActive(true)
        end

        self.button1_callback = self.openArgs.button1_callback
        self.button2_callback = self.openArgs.button2_callback
        self.button3_callback = self.openArgs.button3_callback
    end

    self:Update()
end

function QuickBackpackWindow:OnHide()
	EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._UpdateItem)
    SkillManager.Instance.OnHideTips:Fire()
end

function QuickBackpackWindow:Close()
    self.model:CloseQuickBackpackWindow()
end

function QuickBackpackWindow:Update()
	self:UpdateItem()
end

function QuickBackpackWindow:UpdateItem()
	local datalist = {}

    for _,v in pairs(BackpackManager.Instance.itemDic) do
        if self.checkFun == nil then
            table.insert(datalist, v)
        elseif self.checkFun(v) then
        	table.insert(datalist, v)
        end
    end

    local function sortfun(a,b)
        return a.base_id < b.base_id
    end
    table.sort(datalist, sortfun)

    local pageCount = math.ceil(#datalist / 9)
    if pageCount < 3 then pageCount = 3 end

    self.pageLayout:ReSet()
    for i=1,pageCount do
        local page = self.pageList[i]
        if page == nil then
            page = {}
            page.gameObject = GameObject.Instantiate(self.pageCloner)
            page.transform = page.gameObject.transform
            local count = page.transform.childCount
            for key = 1, count do
                page.transform:GetChild(key - 1).gameObject:SetActive(false)
            end

            for j=1,9 do
                local item = self.itemList[(i - 1) * 9 + j]
                if item == nil then
                    item = {}
                    local itemSlot = ItemSlot.New()
                    item.gameObject = itemSlot.gameObject
                    item.transform = item.gameObject.transform
                    self.itemList[(i - 1) * 9 + j] = item
                    self.itemSlotList[(i - 1) * 9 + j] = itemSlot
                end
                item.transform:SetParent(page.transform)
                item.transform.anchoredPosition = Vector2(72*(((j-1)%3)-1),-72*(math.ceil(j/3)-2))
            end
            -- for j=1,9 do
            --     local item = self.itemList[(i - 1) * 9 + j]
            --     if item == nil then
            --         item = {}
            --         item.transform = page.transform:GetChild(j - 1)
            --         item.gameObject = item.transform.gameObject
            --         self.itemList[(i - 1) * 9 + j] = item

            --         local itemSlot = ItemSlot.New(item.gameObject)
            --         self.itemSlotList[(i - 1) * 9 + j] = itemSlot
            --     end
            -- end
            self.pageList[i] = page
        end
        self.pageLayout:AddCell(page.gameObject)
    end
    for i=pageCount + 1,#self.pageList do
        self.pageList[i].gameObject:SetActive(false)
    end
    for i=1,pageCount * 9 do
        self.itemSlotList[i]:SetAll(datalist[i], { inbag = true })
    end

    self.pageTabbedPanel:SetPageCount(pageCount)
    self:ReloadToggles(pageCount)
    self.pageTabbedPanel:TurnPage(self.curPage)
end

function QuickBackpackWindow:ReloadToggles(page)
    self.toggleLayout:ReSet()
    for i=1,page do
        local toggle = self.toggleList[i]
        if toggle == nil then
            toggle = {}
            toggle.gameObject = GameObject.Instantiate(self.toggleCloner)
            toggle.transform = toggle.gameObject.transform
            toggle.select = toggle.transform:Find("Select").gameObject
            self.toggleList[i] = toggle
        end
        self.toggleLayout:AddCell(toggle.gameObject)
        toggle.select:SetActive(false)
    end
    for i=page+1,#self.toggleList do
        self.toggleList[i].gameObject:SetActive(false)
    end
    self.toggleCloner:SetActive(false)
end

function QuickBackpackWindow:OnMoveEnd(page)
    self.curPage = page
    for i,v in ipairs(self.toggleList) do
        v.select:SetActive(page == i)
    end
end

function QuickBackpackWindow:OnClickButton1()
	self:Close()
	if self.button1_callback == nil then
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market)
	else
		self.button1_callback()
	end
end

function QuickBackpackWindow:OnClickButton2()
	self:Close()
	if self.button2_callback == nil then
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop)
	else
		self.button2_callback()
	end
end

function QuickBackpackWindow:OnClickButton3()
	self:Close()
	if self.button3_callback == nil then
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market)
	else
		self.button3_callback()
	end
end
-- 9格小背包 加雕文bufftips
-- ljh 20170602

GlyphsQuickBackpackWindow = GlyphsQuickBackpackWindow or BaseClass(BasePanel)

function GlyphsQuickBackpackWindow:__init(model)
    self.model = model
    self.name = "GlyphsQuickBackpackWindow"

    self.buffItemObjList = {}

    self.resList = {
        {file = AssetConfig.glyphsquickbackpackwindow, type = AssetType.Main}
        ,{file  =  AssetConfig.normalbufficon, type  =  AssetType.Dep}
    }


    self.pageList = {}
    self.itemList = {}
    self.itemSlotList = {}
    self.toggleList = {}
	self.curPage = 1

	self.buffItemList = {}

    --------------------------------------
    self._Update = function() self:Update() end
    self._UpdateItem = function() self:UpdateItem() end
    self._UpdateBuff = function() self:UpdateBuff() end

    --------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function GlyphsQuickBackpackWindow:__delete()
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

function GlyphsQuickBackpackWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glyphsquickbackpackwindow))
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

    self.itemGrid = self.transform:Find("Sub/Mask/ItemGrid")
    self.buffItem_Clone = self.itemGrid:Find("BuffItem").gameObject
    self.buffItem_Clone:SetActive(false)

    self.noItem = self.transform:Find("Sub/Mask/NoItem")
    --------------------------------------
    self:OnShow()
end

function GlyphsQuickBackpackWindow:OnShow()
	EventMgr.Instance:AddListener(event_name.backpack_item_change, self._UpdateItem)
	EventMgr.Instance:AddListener(event_name.buff_update, self._UpdateBuff)

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

function GlyphsQuickBackpackWindow:OnHide()
	EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._UpdateItem)
	EventMgr.Instance:RemoveListener(event_name.buff_update, self._UpdateBuff)
end

function GlyphsQuickBackpackWindow:Close()
    self.model:CloseGlyphsQuickBackpackWindow()
end

function GlyphsQuickBackpackWindow:Update()
	self:UpdateItem()
	self:UpdateBuff()
end

function GlyphsQuickBackpackWindow:UpdateItem()
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
            for j=1,9 do
                local item = self.itemList[(i - 1) * 9 + j]
                if item == nil then
                    item = {}
                    item.transform = page.transform:GetChild(j - 1)
                    item.gameObject = item.transform.gameObject
                    self.itemList[(i - 1) * 9 + j] = item

                    local itemSlot = ItemSlot.New(item.gameObject)
                    self.itemSlotList[(i - 1) * 9 + j] = itemSlot
                end
            end
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

function GlyphsQuickBackpackWindow:ReloadToggles(page)
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

function GlyphsQuickBackpackWindow:OnMoveEnd(page)
    self.curPage = page
    for i,v in ipairs(self.toggleList) do
        v.select:SetActive(page == i)
    end
end

function GlyphsQuickBackpackWindow:UpdateBuff()
	local buffList = {}
	for key, buffData in pairs(self.model.buffDic) do
        if DataBuff.data_prewar[buffData.id] then
        	table.insert(buffList, buffData)
        end
    end

    for i = 1, #buffList do 
    	local buffData = buffList[i]
    	local buffConfigData = DataBuff.data_list[buffData.id]
    	local buffItem = self.buffItemList[i]

    	if buffItem == nil then
    		buffItem = GameObject.Instantiate(self.buffItem_Clone)
    		buffItem.transform:SetParent(self.itemGrid)
    		buffItem.transform.localScale = Vector3.one
            buffItem.transform.anchoredPosition = Vector2.zero
            buffItem:SetActive(true)

            self.buffItemList[i] = buffItem
    	end

    	buffItem.transform:Find("Top/BuffName"):GetComponent(Text).text = buffConfigData.name
    	buffItem.transform:Find("Top/Buffbg/BuffIcon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffConfigData.icon))

    	local attrTxt = ""
    	local attrLine = 0
		for i,v in ipairs(buffData.dynamic_attr) do
		    local name = KvData.attr_name[v.attr]
		    local value = v.value
		    if v.attr == 30 or v.attr == 31 or v.attr == 45 or v.attr == 46 then
		        value = string.format("%s%s", v.value/10, "%")
		    end
		    if attrLine > 0 then
		    	attrTxt = string.format("%s\n%s +%s", attrTxt, tostring(name), tostring(value))
		    else
			    attrTxt = string.format("%s +%s", tostring(name), tostring(value))
			end
		    attrLine = attrLine + 1
		end
		buffItem.transform:Find("AttrText"):GetComponent(Text).text = attrTxt


		local dataTxt = ""
		local time = (buffData.duration- BaseUtils.BASE_TIME + buffData.start_time)
		if time < 3600 then
		    dataTxt = string.format(TI18N("剩余%s分钟"), tostring(math.ceil(time/60)))
		elseif time < 3600 * 10 then
		    dataTxt = string.format(TI18N("剩余%s小时%s分钟"), tostring(math.floor(time/3600)),tostring(math.floor(time%3600/60)))
		else
		    dataTxt = string.format(TI18N("剩余%s小时"), tostring(math.floor(time/3600)))
		end

		buffItem.transform:Find("dataText"):GetComponent(Text).text = dataTxt

		buffItem:GetComponent(LayoutElement).preferredHeight = 75 + (attrLine - 1) * 22
    end

    for i = #buffList+1, #self.buffItemList do
    	local buffItem = self.buffItemList[i]
    	buffItem:SetActive(false)
    end

    if #buffList == 0 then
    	self.noItem.gameObject:SetActive(true)
    	self.itemGrid.gameObject:SetActive(false)
    else
    	self.noItem.gameObject:SetActive(false)
    	self.itemGrid.gameObject:SetActive(true)
	end
end

function GlyphsQuickBackpackWindow:OnClickButton1()
	self:Close()
	if self.button1_callback == nil then
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market)
	else
		self.button1_callback()
	end
end

function GlyphsQuickBackpackWindow:OnClickButton2()
	self:Close()
	if self.button2_callback == nil then
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop)
	else
		self.button2_callback()
	end
end

function GlyphsQuickBackpackWindow:OnClickButton3()
	self:Close()
	if self.button3_callback == nil then
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market)
	else
		self.button3_callback()
	end
end
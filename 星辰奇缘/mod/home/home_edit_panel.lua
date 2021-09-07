HomeEditPanel = HomeEditPanel or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function HomeEditPanel:__init(model)
    self.model = model
	self.resList = {
        {file = AssetConfig.homeeditpanel, type = AssetType.Main}
        , {file = AssetConfig.homeTexture, type = AssetType.Dep}
    }

    self.name = "HomeEditPanel"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------
    self.view_index = 1
    self.tabGroupObj = nil
    self.tabGroup = nil

    self.item_list = {}
    self.item_icon_list = {}
    self.item_text_list = {}

    self.page = 1
    self.max_page = 1

    self.num_pre_page = 7 --每页的物品个数

    self.page_text = nil

    self.storeshowType = 1

    self.downTime = 0

    ------------------------------------
    self._update = function()
    	self:update()
	end

	self._home_warehouse_out = function(item)
    	self:home_warehouse_out(item)
	end

	self._ShowButton = function(num)
    	self:ShowButton(num)
	end

    self.sellFunc = function() self:Sell() end

	self._ZoomValueChange = function(value) self:ZoomValueChange(value) end
	self._ZoomEnd = function() self:ZoomEnd() end

	-- 上次选中项
	self.lastSelectItem = nil

	self:LoadAssetBundleBatch()
end

function HomeEditPanel:__delete()
	self:Hide()

    for _, itemSlot in pairs(self.item_icon_list) do
        itemSlot:DeleteMe()
    end
    self.item_icon_list = {}

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HomeEditPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.homeeditpanel))
    self.gameObject.name = "HomeEditPanel"
    self.gameObject.transform:SetParent(HomeManager.Instance.homeCanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 0)
    rect.localScale = Vector3.one

    self.mainRect = rect
    self.transform = self.gameObject.transform

    -- self.gameObject.transform:SetAsFirstSibling()

	-----------------------------

	self.main = self.transform:FindChild("Main").gameObject
	self.sub = self.transform:FindChild("Sub").gameObject
	self.tips = self.transform:Find("Tips").gameObject

	self.tabGroupObj = self.transform:FindChild("Main/TabButtonGroup").gameObject
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end)

    self.container = self.transform:FindChild("Main/ItemPanel/Content").gameObject
    self.itemobject = self.transform:FindChild("Main/ItemPanel/Content/Item").gameObject

	self.allSureButton = self.transform:FindChild("Main/AllSureButton"):GetComponent(Button)
    self.allSureButton.onClick:AddListener(function() self:OnAllSureButton() end)

    self.allCancelButton = self.transform:FindChild("Main/AllCancelButton"):GetComponent(Button)
    self.allCancelButton.onClick:AddListener(function() self:OnAllCancelButton() end)

    self.allSureButton.gameObject:SetActive(false)
	self.allCancelButton.gameObject:SetActive(false)

    self.showAlllButton_Text = self.transform:FindChild("Main/ShowAlllButton/Text"):GetComponent(Text)

	local btn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnCloseButton() end)

	btn = self.transform:FindChild("Main/ShowAlllButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnShowAlllButton() end)

    btn = self.transform:FindChild("Main/PutAwayButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnPutAwayButton() end)
    self.putAwayButton = btn

    btn = self.transform:FindChild("Main/ShopButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnShopButton() end)

    btn = self.transform:FindChild("Main/PreviewButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnPreviewButton() end)

    btn = self.transform:FindChild("Main/FurnitureListButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnFurnitureListButton() end)

    btn = self.transform:FindChild("Sub/ZoomInButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnZoomInButton() end)

    btn = self.transform:FindChild("Sub/ZoomOutButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnZoomOutButton() end)

    btn = self.transform:FindChild("Sub/CancelZoomButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnCancelZoomButton() end)
    self.cancelZoomButton = btn.gameObject

    btn = self.transform:FindChild("Sub/BackButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnBackButton() end)

    btn = self.transform:FindChild("Sub/ScreenShotButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnScreenShotButton() end)

    -----------------------------
    self:Show()

    self:ClearMainAsset()

    -- HomeManager.Instance:test()
end

function HomeEditPanel:Show()
    self:RemoveListeners()

	if self.transform ~= nil then
		self.transform.localPosition = Vector3(0, 0, 0)

		EventMgr.Instance:AddListener(event_name.home_warehouse_update, self._update)
		EventMgr.Instance:AddListener(event_name.home_warehouse_out, self._home_warehouse_out)
		EventMgr.Instance:AddListener(event_name.home_eidt_num_update, self._ShowButton)
        EventMgr.Instance:AddListener(event_name.home_item_sell, self.sellFunc)

		HomeManager.Instance.homeElementsModel:GetEditUnitNum()
		self:update()
	end
end

function HomeEditPanel:Hide()
    if self.transform ~= nil then
	   self.transform.localPosition = Vector3(0, -2000, 0)
    end
    self:RemoveListeners()
end

function HomeEditPanel:RemoveListeners()
	EventMgr.Instance:RemoveListener(event_name.home_warehouse_update, self._update)
	EventMgr.Instance:RemoveListener(event_name.home_warehouse_out, self._home_warehouse_out)
	EventMgr.Instance:RemoveListener(event_name.home_eidt_num_update, self._ShowButton)
    EventMgr.Instance:RemoveListener(event_name.home_item_sell, self.sellFunc)
end

function HomeEditPanel:ShowType(type)
	if type == 1 then
		self.main:SetActive(true)
		self.tips:SetActive(true)
		self.sub:SetActive(false)
		self.cancelZoomButton:SetActive(false)
        --显示四个按钮
        if self.model.mapArea ~= nil then
            self.model.mapArea:update_button()
        end
	else
		self.main:SetActive(false)
		self.tips:SetActive(false)
		self.sub:SetActive(true)
		self.cancelZoomButton:SetActive(false)
        --隐藏四个按钮
        if self.model.mapArea ~= nil then
            self.model.mapArea:hide_all_button()
        end
	end
end
----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function HomeEditPanel:OnCloseButton()
	self.model:HideEditPanel()
end

function HomeEditPanel:OnAllSureButton()
	for k,v in pairs(HomeManager.Instance.homeElementsModel.Edit_List) do
        v:OnSureButton()
    end
end

function HomeEditPanel:OnAllCancelButton()
	for k,v in pairs(HomeManager.Instance.homeElementsModel.Edit_List) do
        v:OnCancelButton()
    end
end

function HomeEditPanel:OnShowAlllButton()
	-- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.visithomewindow, {1,1})
	if self.storeshowType == 1 then
		self.storeshowType = 2
		self.showAlllButton_Text.text = TI18N("显示全部")
		self:update()
	else
		self.storeshowType = 1
		self.showAlllButton_Text.text = TI18N("显示已有")
		self:update()
	end
end

function HomeEditPanel:OnPutAwayButton()
	-- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.magicbeenpanel)
	local list = {}
	for k,v in pairs(HomeManager.Instance.homeElementsModel.Edit_List) do
		table.insert(list, v)
	end
	for k,v in pairs(HomeManager.Instance.homeElementsModel.WaitForCreateUnitData_List) do
		if v.isEdit then
			table.insert(list, { data = v })
		end
	end
	for _,value in ipairs(list) do
		if value.transform ~= nil then
	        self.model:FlyIcon(value)
	    end

        HomeManager.Instance.homeElementsModel:RemoveUnit(value.data.uniqueid)
        HomeManager.Instance:Send11207(value.data.id)
    end
end

function HomeEditPanel:OnShopButton()
	-- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.invitemagicbeenwindow, { 999999999999999 })
	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {3})
end

function HomeEditPanel:OnFurnitureListButton()
	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.furniturelistwindow)
end

function HomeEditPanel:OnZoomInButton()
	if not self.model.zooming and self.model.zoomIndex > 1 then
		self.model.zoomIndex = self.model.zoomIndex - 1
		self.model.zooming = true
		self:Zoom()

		if self.model.zoomIndex < #self.model.zoomValue then
			SceneManager.Instance.sceneModel.sceneView.alwaysShowMiniMap = false
		end
	end
end

function HomeEditPanel:OnZoomOutButton()
	if not self.model.zooming and self.model.zoomIndex < #self.model.zoomValue then
		self.model.zoomIndex = self.model.zoomIndex + 1
		self.model.zooming = true
		self:Zoom()

		if self.model.zoomIndex == #self.model.zoomValue then
			SceneManager.Instance.sceneModel.sceneView.alwaysShowMiniMap = true
			SceneManager.Instance.sceneModel.sceneView:ShowMiniMapTexture(true)
		end
	end
end

function HomeEditPanel:OnCancelZoomButton()
	local data = NoticeConfirmData.New()
	data.type = ConfirmData.Style.Normal
	data.content = TI18N("当前处于预览状态，是否恢复正常视觉？")
	data.sureLabel = TI18N("确定")
	data.cancelLabel = TI18N("取消")
	data.sureCallback = function()
	    self.model.zoomIndex = 2
	    self.model.zooming = true
		self:Zoom()
	end

	NoticeManager.Instance:ConfirmTips(data)
end

function HomeEditPanel:Zoom()
	Tween.Instance:ValueChange(SceneManager.Instance.MainCamera.camera.orthographicSize, self.model.zoomValue[self.model.zoomIndex], 0.5, self._ZoomEnd, LeanTweenType.linear, self._ZoomValueChange)

	if self.model.zoomIndex ~= 2 then
		HomeManager.Instance.zoomMark = true
		-- HomeManager.Instance:CameraFixedUpdate()
		self.cancelZoomButton:SetActive(true)
	else
		HomeManager.Instance.zoomMark = false
		self.cancelZoomButton:SetActive(false)
	end
end

function HomeEditPanel:ZoomValueChange(value)
	SceneManager.Instance.MainCamera.camera.orthographicSize = value
	-- if self.model.zoomIndex ~= 2 then
	-- 	HomeManager.Instance:CameraFixedUpdate()
	-- end
end

function HomeEditPanel:ZoomEnd()
	self.model.zooming = false
end

function HomeEditPanel:OnPreviewButton()
	self:ShowType(2)
	self.model.previewType = true
	HomeManager.Instance:ShowOtherUI()
end

function HomeEditPanel:OnBackButton()
	self.model.zoomIndex = 2
	self.model.zooming = true
	self:Zoom()

	self:ShowType(1)
	self.model.previewType = false
	HomeManager.Instance:ShowOtherUI()
end

function HomeEditPanel:OnScreenShotButton()
	if BaseUtils.GetPlatform() == "ios" or BaseUtils.GetPlatform() == "jailbreak" then
		NoticeManager.Instance:FloatTipsByString(TI18N("当前暂不支持该功能，可自行截图哦"))
		return
	end
	BaseUtils.ScreenShot()
	NoticeManager.Instance:FloatTipsByString(string.format("%s%s%s", TI18N("截图已保存在"), Application.persistentDataPath, TI18N("目录下")))
end

function HomeEditPanel:ShowButton(num)
	-- if num > 1 then
	-- 	self.allSureButton.gameObject:SetActive(true)
	-- 	self.allCancelButton.gameObject:SetActive(true)
	-- else
	-- 	self.allSureButton.gameObject:SetActive(false)
	-- 	self.allCancelButton.gameObject:SetActive(false)
	-- end

	if num > 0 then
		self.putAwayButton.transform:GetComponent(Image).sprite
                = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
	else
		self.putAwayButton.transform:GetComponent(Image).sprite
                = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
	end
end

function HomeEditPanel:ChangeTab(index)
    if self.view_index == index then return end
    self.view_index = index
    self.page = 1

	self:update()
end

function HomeEditPanel:update()
	if self.storeshowType == 1 then
		self.list = self.model:GetAllByType(self.view_index)
	else
		self.list = self.model:GetWarehouseByType(self.view_index)
	end

	self.list = self.model:sub_edit_list(self.list)

	local list = self.list
	for i = 1, #list do
		if self.item_list[i] == nil then
			local item = GameObject.Instantiate(self.itemobject)
			item:SetActive(true)
			item.transform:SetParent(self.container.transform)
			item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
			local icon = ItemSlot.New()
			UIUtils.AddUIChild(item, icon.gameObject)
			local text = item.transform:FindChild("Text"):GetComponent(Text)
			local trect = text.gameObject:GetComponent(RectTransform)
			trect.sizeDelta = Vector2(80, 30)

			item.transform:GetComponent(CustomButton).onHold:AddListener(function()
			    self:holdItem(i)
			end)
			item.transform:GetComponent(CustomButton).onDown:AddListener(function()
			    self:onDownItem(i)
			end)
			item.transform:GetComponent(CustomButton).onUp:AddListener(function()
			    self:onUpItem(i)
			end)

			-- icon.gameObject:AddComponent(TransitionButton)

			table.insert(self.item_list, item)
			table.insert(self.item_icon_list, icon)
			table.insert(self.item_text_list, text)
		end

		self.item_list[i]:SetActive(true)
    	self.item_list[i].transform.localScale = Vector3.one
		local itembase = BackpackManager.Instance:GetItemBase(list[i].base.item_id)
		if itembase == nil then
			Log.Error("家园表配错了，物品id不存在"..list[i].base.item_id)
			break
		end
		local itemData = ItemData.New()
		itemData:SetBase(itembase)
        table.insert(itembase.tips_type, {tips = 10,val = "[{购买;11200|3|1}]"})
        table.insert(itembase.tips_type, {tips = 3,val = "[4]"})
		itemData.quantity = list[i].num
		if itemData.quantity < 0 then itemData.quantity = 0 end
		-- self.item_icon_list[i]:SetAll(itemData, { white_list = { { id = 20, show = true } } })

		self.item_icon_list[i]:SetAll(itemData)
		self.item_icon_list[i]:SetNotips(false)
		self.item_icon_list[i]:ShowNum(true)
		self.item_icon_list[i]:ShowSelect(false)
		self.item_icon_list[i].numRect.anchoredPosition = Vector2(0, 2)
		if self.item_icon_list[i].numBg ~= nil then
	        self.item_icon_list[i].numBg:SetActive(false)
	    end
		-- self.item_icon_list[i]:SetGrey(list[i].num <= 0)
		self.item_text_list[i].text = BaseUtils.string_cut(itemData.name, 15, 12)
	end

	if #list < #self.item_list then
		for i = #list + 1, #self.item_list do
			self.item_list[i]:SetActive(false)
		end
	end
end

function HomeEditPanel:home_warehouse_out(itemData)
	local item = itemData
	local data = self.model:GetFurnitureByItemId(item.base_id)
	if data == nil then return end

	if data.base.type == 15 then
		HomeManager.Instance:Send11204(data.id, 0, 0, 0, 0, 0)
	else
		local p = SceneManager.Instance.sceneModel:transport_big_pos(SceneManager.Instance.MainCamera.transform.localPosition.x, SceneManager.Instance.MainCamera.transform.localPosition.y)
		p.x = p.x - 103
		p.y = p.y + 67
		-- 调整到格子中间
		local px = p.x
        local py = p.y
        local gridWidth = ctx.sceneManager.Map.GridWidth
        local gridHeight = ctx.sceneManager.Map.GridHeight
        local gridOffsetX = (gridWidth / 2) - (px % gridWidth)
        local gridOffsetY = (gridHeight / 2) - ((ctx.sceneManager.Map.Height - py) % gridHeight)
        px = px + gridOffsetX
        py = py - gridOffsetY
		local unitData = {id = data.id, battle_id = 998, base_id = data.base_id, dir = 1
	                    , isEdit = true, status = 3, x = px, y = py}
		HomeManager.Instance.homeElementsModel:UpdateUnitList({unitData})
	end
end

function HomeEditPanel:holdItem(i)
    self.selectIndex = i
	if math.abs(self.lastmouseX - Input.mousePosition.x) < 2 and math.abs(self.lastmouseY - Input.mousePosition.y) < 2 then
		if self.item_icon_list[i].itemData.quantity == 0 then
	    	self.item_icon_list[i].extra = { showopenwindow = true, tipsOffsetY = -5 }
	    else
            local data = self.list[self.selectIndex]
			-- self.item_icon_list[i].extra = {inbag = true, showopenwindow = true, white_list = { { id = 20, show = true }, {id = 3, show = (data.rid == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id)} }, tipsOffsetY = -5 }
			self.item_icon_list[i].extra = {inbag = true, showopenwindow = true, white_list = { { id = 20, show = true }, {id = 3, show = true} }, tipsOffsetY = -5 }
		end
		TipsManager.Instance:ShowItem(self.item_icon_list[i])
	end
end

function HomeEditPanel:onDownItem(i)
    self.selectIndex = i
	self.downTime = Time.time

	local width = ctx.ScreenWidth
    local height = ctx.ScreenHeight
    local origin = 960 / 540
    local current = width / height

    -- 实际UI长宽
    local h = ((origin / current - 1) / 2 + 1) * 540
    local w = ((origin - current) / 2 + current) / origin * 960

    -- 屏幕长宽转换成UI长宽
    local x = w * Input.mousePosition.x / width
    local y = h * Input.mousePosition.y / height

	local pos = Vector2(x - w / 2, y - h / 2 + 50)
    self.holdEffectTimer = LuaTimer.Add(300, function () HomeManager.Instance.homeCanvasView:ShowHoldEffect(pos)  end)

    self.lastmouseX = Input.mousePosition.x
    self.lastmouseY = Input.mousePosition.y

    local obj = self.item_list[i]
    if obj ~= nil then
    	obj.transform.localScale = Vector3.one * 1.1
    end

    if self.lastSelectItem ~= nil then
    	self.lastSelectItem:ShowSelect(false)
    end
    self.lastSelectItem = self.item_icon_list[i]
    self.lastSelectItem:ShowSelect(true)
end

function HomeEditPanel:onUpItem(i)
    self.selectIndex = i
	if self.holdEffectTimer ~= nil then LuaTimer.Delete(self.holdEffectTimer) end
	HomeManager.Instance.homeCanvasView:HidHoldEffect()

	local time = Time.time
    local offset = time - self.downTime
    self.downTime = 0
    if math.abs(self.lastmouseX - Input.mousePosition.x) < 10 and math.abs(self.lastmouseY - Input.mousePosition.y) < 10 then
	    if offset < 0.4 then
	    	-- if self.storeshowType == 1 and self.item_icon_list[i].itemData.quantity == 0 then
	    	-- 	self.item_icon_list[i].extra = { showopenwindow = true, tipsOffsetY = -5 }
	    	-- 	TipsManager.Instance:ShowItem(self.item_icon_list[i])
	    	-- else
		    --     self:home_warehouse_out(self.item_icon_list[i].itemData)
		    -- end
		    if self.item_icon_list[i].itemData.quantity == 0 then
		    	self.item_icon_list[i].extra = { showopenwindow = true, tipsOffsetY = -5 }
		    else
	            local data = self.list[self.selectIndex]
				-- self.item_icon_list[i].extra = {inbag = true, showopenwindow = true, white_list = { { id = 20, show = true }, {id = 3, show = (data.rid == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id)} }, tipsOffsetY = -5 }
				self.item_icon_list[i].extra = {inbag = true, showopenwindow = true, white_list = { { id = 20, show = true }, {id = 3, show = true} }, tipsOffsetY = -5 }
			end
			TipsManager.Instance:ShowItem(self.item_icon_list[i])
	    end
	end

    local obj = self.item_list[i]
    if obj ~= nil then
    	obj.transform.localScale = Vector3.one
    end
end

function HomeEditPanel:Sell()
    if self.selectIndex ~= nil then
        if self.list[self.selectIndex].num > 0 then
        	local furnishingsData = self.list[self.selectIndex]
        	local base = furnishingsData.base
        	if base.type == 15 then
        		NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>是家园的基础，不能出售{face_1,3}"), base.name))
        	elseif (furnishingsData.rid == RoleManager.Instance.RoleData.id and furnishingsData.platform == RoleManager.Instance.RoleData.platform and furnishingsData.zone_id == RoleManager.Instance.RoleData.zone_id) then
	        	if base.sell_val == 0 then
	        		NoticeManager.Instance:FloatTipsByString(TI18N("稀有家具不能出售哟{face_1,2}"))
	        	else
		        	local data = NoticeConfirmData.New()
		            data.type = ConfirmData.Style.Normal
		            data.content = string.format(TI18N("是否以{assets_1,90000,%s}出售<color='#ffff00'>%s</color>？"), base.sell_val, base.name)
		            data.sureLabel = TI18N("出售")
		            data.cancelLabel = TI18N("取消")
		            data.sureCallback = function()
		            		BaseUtils.dump(furnishingsData)
		            		HomeManager.Instance:Send11235(furnishingsData.id)
		            	end
		            NoticeManager.Instance:ConfirmTips(data)
		        end
	        else
	        	NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>是您的伴侣购买，不能出售{face_1,3}"), base.name))
	        end
        end
    end
end

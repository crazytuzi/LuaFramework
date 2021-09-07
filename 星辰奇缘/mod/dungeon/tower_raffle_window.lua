-- @author 黄耀聪
-- @date 2016年6月15日

TowerRaffleWindow = TowerRaffleWindow or BaseClass(BaseWindow)

function TowerRaffleWindow:__init(model)
    self.model = model
    self.name = "TowerRaffleWindow"

	self.mgr = DungeonManager.Instance

    self.resList = {
        {file = AssetConfig.tower_raffle_window , type = AssetType.Main},
		{file = AssetConfig.tower_raffle_textures, type = AssetType.Dep},
    }

	self.boxList = {}
	self.effectList = {}
	self.receiveString = TI18N("<color=#23F0F7>%s</color>选择了奖励")
	self.titleString = TI18N("成功挑战<color='#13fc60'>%s</color>，获得<color='#d781f2'>%s</color>")

	self.updateListener = function(id, data) self:Update(id, data) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function TowerRaffleWindow:Update(id, data)
	if id ~= nil and id == self.id then
		if data == nil then
			self:UpdateBoxes()
		else
			local roleData = RoleManager.Instance.RoleData
			local time = 0
			if BaseUtils.get_unique_roleid(roleData.id, roleData.platform, roleData.zone_id) == BaseUtils.get_unique_roleid(data.rid, data.platform, data.zone_id) then
				time = 500
				if self.delay1 == nil then
					self.delay1 = LuaTimer.Add(time, function()
							if self.gameObject == nil or BaseUtils.isnull(self.gameObject) then
								return
							end
							if self.effectList[0] ~= nil then self.effectList[0]:DeleteMe() end
							self.effectList[0] = BibleRewardPanel.ShowEffect(20143, self.boxList[data.pos].trans, Vector3(1, 1, 1), Vector3(0, 0, 0))
						end)
				end
			end
			if self.delay2 == nil then
				self.delay2 = LuaTimer.Add(time, function() self:SetData(self.boxList[data.pos], data, data.pos) self.delay2 = nil end)
			end
			self.descObj:SetActive(false)

			self.countDownTimer1 = LuaTimer.Add(3000, function() self:SetCanClose() end)
		end
	end
end

function TowerRaffleWindow:__delete()
    self.OnHideEvent:Fire()
    if self.effectList ~= nil then
    	for k,v in pairs(self.effectList) do
    		if v ~= nil then
    			v:DeleteMe()
    		end
    	end
    	self.effectList = nil
    end
    if self.boxList ~= nil then
	    for i,v in pairs(self.boxList) do
	    	if v.itemSlot ~= nil then
	    		v.itemSlot:DeleteMe()
	    		v.itemSlot = nil
	    	end
	    end
	    self.boxList = nil
	end

    self:AssetClearAll()
end

function TowerRaffleWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tower_raffle_window))
	self.gameObject.name = self.name
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
	local t = self.gameObject.transform
	self.transform = t
	self.container = t:Find("Main/Container")
	self.titleText = t:Find("Main/Title/Text"):GetComponent(Text)
	self.normalBox = self.container:Find("Cloner").gameObject
	self.descObj = t:Find("Main/Desc").gameObject
	self.exitBtn = t:Find("Main/Panel"):GetComponent(Button)
	self.panelTextObj = t:Find("Main/Panel/Text").gameObject

	self.container:Find("Cloner/Open/Item/NameBg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemBg13")

	self.exitBtn.gameObject:SetActive(false)

	t:Find("Main/Panel"):GetComponent(Button).onClick:AddListener(function() self.exitBtn.gameObject:SetActive(true) end)
	self.exitBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
end

function TowerRaffleWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function TowerRaffleWindow:OnOpen()
    self:RemoveListeners()
	self.mgr.onTreasureBoxUpdate:AddListener(self.updateListener)

	self.id = self.openArgs[1]
	self.base_id = self.openArgs[2]
	if self.id ~= nil then
		self:UpdateBoxes()
	end

	self.countDownTimer2 = LuaTimer.Add(5000, function() self:SetCanClose() self.countDownTimer2 = nil end)

	SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
end

function TowerRaffleWindow:OnHide()
    self:RemoveListeners()
    if self.delay1 ~= nil then
    	LuaTimer.Delete(self.delay1)
    	self.delay1 = nil
    end
    if self.delay2 ~= nil then
    	LuaTimer.Delete(self.delay2)
    	self.delay2 = nil
    end
	if self.countDownTimer1 ~= nil then
		LuaTimer.Delete(self.countDownTimer1)
		self.countDownTimer1 = nil
	end
	if self.countDownTimer2 ~= nil then
		LuaTimer.Delete(self.countDownTimer2)
		self.countDownTimer2 = nil
	end
	if self.shakeTimerId ~= nil then
		LuaTimer.Delete(self.shakeTimerId)
		self.shakeTimerId = nil
	end
end

function TowerRaffleWindow:RemoveListeners()
	self.mgr.onTreasureBoxUpdate:RemoveListener(self.updateListener)
end

function TowerRaffleWindow:UpdateBoxes()
	if self.layout == nil then
		self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X})
	end
	self.layout:ReSet()
	self.list = self.mgr.treasureBoxData[self.id].list
	self.titleText.text = string.format(self.titleString, self.mgr.treasureBoxData[self.id].from_name, self.mgr.treasureBoxData[self.id].name)

	for i,v in ipairs(self.list) do
		if self.boxList[i] == nil then
			local tab = {
				obj = nil,
				trans = nil,
				item = nil,
				open = nil,
				close = nil,
				itemData = nil,
				itemSlot = nil,
				rect = nil,
				nameObj = nil,
				nameText = nil,
				double = nil,
			}
			tab.obj = GameObject.Instantiate(self.normalBox)
			tab.rect = tab.obj:GetComponent(RectTransform)
			tab.trans = tab.obj.transform
			tab.open = tab.trans:Find("Open").gameObject
			tab.close = tab.trans:Find("Close").gameObject
			tab.descText = tab.trans:Find("Desc"):GetComponent(Text)
			tab.item = tab.trans:Find("Open/Item")
			tab.btn = tab.obj:GetComponent(Button)
			tab.btn.onClick:AddListener(function() self:OnClick(i) end)
			tab.nameObj = tab.item:Find("NameBg").gameObject
			tab.nameRect = tab.nameObj:GetComponent(RectTransform)
			tab.nameText = tab.item:Find("NameBg/Name"):GetComponent(Text)
			tab.double = tab.trans:Find("Double").gameObject
			self.boxList[i] = tab
			self.effectList[i] = BibleRewardPanel.ShowEffect(20142, tab.trans, Vector3(1, 1, 1), Vector3(0, 0, 0))
			-- tab.close:GetComponent(RectTransform).anchoredPosition = Vector2(0, -20.9)
		end
		self.layout:AddCell(self.boxList[i].obj)
		self.boxList[i].rect.pivot = Vector2(0.5, 0.5)
		self:SetData(self.boxList[i], v, i)
	end

	self.normalBox:SetActive(false)
	for i=#self.list + 1, #self.boxList do
		self.boxList[i].obj:SetActive(false)
	end

	self.layout.panelRect.sizeDelta = Vector2(#self.list * 150 + (#self.list + 1) * 30, 200)
	self.layout.panelRect.anchoredPosition = Vector2(90, 0)
end

function TowerRaffleWindow:SetData(tab, data, index)
	local rolldata = DataRoll.data_card[self.base_id]
	local baseData = DataItem.data_get[data.item_id]
	tab.obj:SetActive(true)
	-- tab.nameObj:SetActive(false)
	tab.double:SetActive(false)

	if baseData == nil then
		tab.open:SetActive(false)
		tab.close:SetActive(true)
		tab.descText.text = ""
	else
		tab.open:SetActive(true)
		tab.close:SetActive(false)
		tab.itemData = tab.itemData or ItemData.New()
		tab.itemData:SetBase(baseData)
		tab.nameText.text = tab.itemData.name
		if tab.itemSlot == nil then
			tab.itemSlot = ItemSlot.New()
			NumberpadPanel.AddUIChild(tab.item, tab.itemSlot.gameObject)
		end
		tab.nameRect.sizeDelta = Vector2(tab.nameText.preferredWidth + 10, 30)
		tab.itemSlot:SetAll(tab.itemData, {inbag = false, nobutton = true})
		if rolldata.is_double == 1 then
			tab.itemSlot:SetNum(data.num / 2)
			tab.double:SetActive(true)
		else
			tab.itemSlot:SetNum(data.num)
			tab.double:SetActive(false)
		end
		if data.name ~= "" then
			tab.descText.text = string.format(self.receiveString, data.name)
		else
			tab.descText.text = ""
		end
	end

	if self.effectList[index] ~= nil then
		self.effectList[index]:DeleteMe()
		self.effectList[index] = nil
	end
end

function TowerRaffleWindow:OnClick(index)
	self.exitBtn.gameObject:SetActive(true)
	if DataItem.data_get[self.list[index].item_id] == nil then
		self:Shake(self.boxList[index].obj)
		DungeonManager.Instance:Require12321(self.id, index)
	end
end

function TowerRaffleWindow:Shake(obj)
	local rect = obj:GetComponent(RectTransform)
	local rotating = function(theta, objRect)
		objRect.rotation = Quaternion.Euler(0, 0, theta)
	end

	local T = 50
	local A = 5
	if self.shakeTimerId ~= nil then
		LuaTimer.Delete(self.shakeTimerId)
	end
	local c = 0
	self.shakeTimerId = LuaTimer.Add(0, 10, function()
				c = (c + 1) % 30
				if c == 0 then
					rotating(0, rect)
					LuaTimer.Delete(self.shakeTimerId)
					self.shakeTimerId = nil
				end
				rotating(A * math.sin(2*math.pi * c * 10 / T), rect)
			end)
end

function TowerRaffleWindow:SetCanClose()
	if BaseUtils.isnull(self.descObj) ~= true then
		self.descObj:SetActive(false)
		self.exitBtn.gameObject:SetActive(true)
		self.panelTextObj:SetActive(true)
	end
end




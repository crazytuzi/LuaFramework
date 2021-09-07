-- 竞技场结算界面
-- ljh 20160919
ArenaSettlementWindow = ArenaSettlementWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function ArenaSettlementWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.arenasettlementwindow
    self.name = "ArenaSettlementWindow"
    self.resList = {
        {file = AssetConfig.arenasettlementwindow, type = AssetType.Main}
        , {file = AssetConfig.guard_head, type = AssetType.Dep}
        , {file = AssetConfig.zone_textures, type = AssetType.Dep}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        ,{file = AssetConfig.attr_icon,type = AssetType.Dep}
    }

    -----------------------------------------

    self.okButton = nil
    self.toggle1 = nil
    self.toggle2 = nil

    self.arrowImage = nil
	self.cupText = nil
	self.cupImage = nil

	self.itemList = {}
	self.slider_tweenId = {}
	self.headLoaderList = {}

	self.title1 = nil
	self.title2 = nil
	self.light = nil
	self.rotateId = 0
    -----------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self._Update = function() self:Update() end
    self.petString = TI18N("出战宠物")
end

function ArenaSettlementWindow:__delete()
    self:OnHide()
    if self.showTitleId ~= nil then
    	LuaTimer.Delete(self.showTitleId)
    	self.showTitleId = nil
    end

    if self.headLoaderList ~= nil then
    	for k,v in pairs(self.headLoaderList) do
    		if v ~= nil then
    			v:DeleteMe()
    			v = nil
    		end
    	end
    	self.headLoaderList = nil
    end

    self:ClearDepAsset()
end

function ArenaSettlementWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.arenasettlementwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    -- self.CloseButton = self.transform:Find("Main/CloseButton")
    -- self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Panel").gameObject:AddComponent(Button).onClick:AddListener(function() self:Close() end)

    self.mainTransform = self.transform:Find("Main")

    self.okButton = self.mainTransform:FindChild("OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:okButtonClick() end)

    self.toggle1 = self.mainTransform:FindChild("Toggle1"):GetComponent(Toggle)
    self.toggle1.onValueChanged:AddListener(function(on) self:ontoggle1change(on) end)

    self.toggle2 = self.mainTransform:FindChild("Toggle2"):GetComponent(Toggle)
	self.toggle2.onValueChanged:AddListener(function(on) self:ontoggle2change(on) end)

	self.text = self.mainTransform:FindChild("Text"):GetComponent(Text)
	self.arrowImage = self.mainTransform:FindChild("ArrowImage")
	self.cupText = self.mainTransform:FindChild("CupText"):GetComponent(Text)
	self.cupImage = self.mainTransform:FindChild("CupImage")

	self.title1 = self.mainTransform:FindChild("Title/Title1")
	self.title2 = self.mainTransform:FindChild("Title/Title2")
	self.light = self.transform:FindChild("Light")
	self.light.gameObject:SetActive(false)

	self.itemList = {}
	local container = self.mainTransform:FindChild("Panel")
	for i = 1, 6 do
		-- local item = self.mainTransform:FindChild(string.format("Panel/Item%s", i))
		local item = container:GetChild(i - 1)
		item.gameObject.name = "Item" .. i
		local self_item = item:FindChild("Self")
		local self_head = self_item:FindChild("HeadImage/Image")
		local self_head_default = self_item:FindChild("HeadImage/Default")
		local self_classes = self_item:FindChild("ClassesImage")
		local self_name = self_item:FindChild("NameText"):GetComponent(Text)
		local self_type = self_item:FindChild("TypeText"):GetComponent(Text)
		local self_value = self_item:FindChild("ValueText"):GetComponent(Text)
		local self_cup = self_item:FindChild("CupText"):GetComponent(Text)
		local self_cupimage = self_item:FindChild("Image")
		local self_expslider = self_item:FindChild("ExpSlider"):GetComponent(Slider)

		local other_item = item:FindChild("Other")
		local other_head = other_item:FindChild("HeadImage/Image")
		local other_head_default = other_item:FindChild("HeadImage/Default")
		local other_classes = other_item:FindChild("ClassesImage")
		local other_name = other_item:FindChild("NameText"):GetComponent(Text)
		local other_type = other_item:FindChild("TypeText"):GetComponent(Text)
		local other_value = other_item:FindChild("ValueText"):GetComponent(Text)
		local other_cup = other_item:FindChild("CupText"):GetComponent(Text)
		local other_cupimage = other_item:FindChild("Image")
		local other_expslider = other_item:FindChild("ExpSlider"):GetComponent(Slider)

		table.insert(self.itemList, { self_item = self_item, self_head = self_head, self_head_default = self_head_default, self_classes = self_classes, self_name = self_name
									, self_type = self_type, self_value = self_value, self_cup = self_cup, self_cupimage = self_cupimage, self_expslider = self_expslider
									, other_item = other_item, other_head = other_head, other_head_default = other_head_default, other_classes = other_classes, other_name = other_name
									, other_type = other_type, other_value = other_value, other_cup = other_cup, other_cupimage = other_cupimage, other_expslider = other_expslider})
	end

    self:OnShow()
end

function ArenaSettlementWindow:Close()
    self:OnHide()

    WindowManager.Instance:CloseWindow(self)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arena_window, {1})
end

function ArenaSettlementWindow:OnShow()
	if self.openArgs ~= nil and #self.openArgs > 0 then
        self.data = self.openArgs[1]
    end

	if self.data ~= nil then
		self:Update()
	end
end

function ArenaSettlementWindow:OnHide()
	for _,value in ipairs(self.slider_tweenId) do
		if value[1] ~= nil then
			Tween.Instance:Cancel(value[1])
		end
		if value[2] ~= nil then
			Tween.Instance:Cancel(value[2])
		end
	end

	if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
    end
end

function ArenaSettlementWindow:Update()
	local function sortfun1(a,b)
		if a.type_1 == b.type_1 then
			return a.base_id_1 < b.base_id_1
		else
		    return (a.type_1 + 2) % 3 > (b.type_1 + 2) % 3
		end
	end
	table.sort(self.data.s_statistics, sortfun1)

	local function sortfun2(a,b)
		if a.type_2 == b.type_2 then
			return a.base_id_2 < b.base_id_2
		else
		    return (a.type_2 + 2) % 3 > (b.type_2 + 2) % 3
		end
	end
	table.sort(self.data.t_statistics, sortfun2)


	self.max_dmg = 0
	self.max_heal = 0

	for _, value in ipairs(self.data.s_statistics) do
		if value.dmg_1 > self.max_dmg then
			self.max_dmg = value.dmg_1
		end
		if value.heal_1 > self.max_heal then
			self.max_heal = value.heal_1
		end
	end
	for _, value in ipairs(self.data.t_statistics) do
		if value.dmg_2 > self.max_dmg then
			self.max_dmg = value.dmg_2
		end
		if value.heal_2 > self.max_heal then
			self.max_heal = value.heal_2
		end
	end

	if self.max_dmg == 0 then
		self.max_dmg = 1
	end
	if self.max_heal == 0 then
		self.max_heal = 1
	end
    self:Update_info()
    self:Update_type()
end

function ArenaSettlementWindow:Update_info()
	local roleData = RoleManager.Instance.RoleData

    for i = 1, 6 do
    	local item = self.itemList[i]
    	if i == 1 then
    		item.self_head_default.gameObject:SetActive(false)
    		item.self_head.gameObject:SetActive(true)
    		item.self_head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", roleData.classes, roleData.sex))

    		item.self_classes:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, string.format("ClassesIcon_%s", roleData.classes))
			item.self_name.text = roleData.name

			item.other_head_default.gameObject:SetActive(false)
    		item.other_head.gameObject:SetActive(true)
    		item.other_head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", self.data.t_classes, self.data.t_sex))

    		item.other_classes:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, string.format("ClassesIcon_%s", self.data.t_classes))
			item.other_name.text = self.data.t_name

    		item.self_cup.text = self.data.s_cup
    		item.other_cup.text = self.data.t_cup
		else
			local self_shouhu = nil
			local self_pet = nil
			if self.data.s_statistics[i] ~= nil then
				self_shouhu = DataShouhu.data_guard_base_cfg[self.data.s_statistics[i].base_id_1]
				self_pet = DataPet.data_pet[self.data.s_statistics[i].base_id_1]
			end
			if self_shouhu ~= nil then
				item.self_head_default.gameObject:SetActive(false)
				item.self_head.gameObject:SetActive(true)
		    	item.self_head:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, self_shouhu.avatar_id)

		    	item.self_classes:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, string.format("ClassesIcon_%s", self_shouhu.classes))
				item.self_name.text = self_shouhu.name
			elseif self_pet ~= nil then
				item.self_head_default.gameObject:SetActive(false)
				item.self_head.gameObject:SetActive(true)
				local loaderId = item.self_head:GetComponent(Image).gameObject:GetInstanceID()
				if self.headLoaderList[loaderId] == nil then
					self.headLoaderList[loaderId] = SingleIconLoader.New(item.self_head:GetComponent(Image).gameObject)
				end
				self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,self_pet.id)
				-- item.self_head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(self_pet.id), tostring(self_pet.id))
				item.self_classes:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth4")
				-- item.self_name.text = self_pet.name
				item.self_name.text = self.petString
			else
				item.self_classes.gameObject:SetActive(false)
				item.self_name.text = ""
			end

			local other_shouhu = nil
			local other_pet = nil
			if self.data.t_statistics[i] ~= nil then
				other_shouhu = DataShouhu.data_guard_base_cfg[self.data.t_statistics[i].base_id_2]
				other_pet = DataPet.data_pet[self.data.t_statistics[i].base_id_2]
			end
			if other_shouhu ~= nil then
				item.other_head_default.gameObject:SetActive(false)
		    	item.other_head.gameObject:SetActive(true)
		    	item.other_head:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, other_shouhu.avatar_id)

		    	item.other_classes:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, string.format("ClassesIcon_%s", other_shouhu.classes))
				item.other_name.text = other_shouhu.name
			elseif other_pet ~= nil then
				item.other_head_default.gameObject:SetActive(false)
				item.other_head.gameObject:SetActive(true)
				local loaderId = item.other_head:GetComponent(Image).gameObject:GetInstanceID()
				if self.headLoaderList[loaderId] == nil then
				    self.headLoaderList[loaderId] = SingleIconLoader.New(item.other_head:GetComponent(Image).gameObject)
				end
				self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,other_pet.id)
				-- item.other_head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(other_pet.id), tostring(other_pet.id))
				item.other_classes:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth4")
				item.other_name.text = self.petString
		    else
		    	item.other_classes.gameObject:SetActive(false)
				item.other_name.text = ""
		    end

	    	item.self_cup.gameObject:SetActive(false)
	    	item.self_cupimage.gameObject:SetActive(false)
	    	item.other_cup.gameObject:SetActive(false)
	    	item.other_cupimage.gameObject:SetActive(false)
	    end
    end

	if self.data.result == 1 then
		-- self.mainTransform:FindChild("Title/Title1").gameObject:SetActive(true)
		-- self.mainTransform:FindChild("Title/Title2").gameObject:SetActive(false)

	    self.text.text = string.format(TI18N("你对<color=#05A2E4>%s</color>发起了战斗,你胜利了"), self.data.t_name)
	else
		-- self.mainTransform:FindChild("Title/Title1").gameObject:SetActive(false)
		-- self.mainTransform:FindChild("Title/Title2").gameObject:SetActive(true)

	    self.text.text = string.format(TI18N("你对<color=#05A2E4>%s</color>发起了战斗,你失败了"), self.data.t_name)
	end

	if self.data.s_cup_change > 0 then
		self.cupText.text = tostring(math.abs(self.data.s_cup_change))
	    self.arrowImage:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
	else
		self.cupText.text = ""
	    self.arrowImage.gameObject:SetActive(false)
	    self.cupImage.gameObject:SetActive(false)
	end

	if self.showTitleId ~= nil then
		LuaTimer.Delete(self.showTitleId)
	end
	self.showTitleId = LuaTimer.Add(600, function() self:showTitle() end)
end

function ArenaSettlementWindow:Update_type()
	for i = 1, 6 do
    	local item = self.itemList[i]

	    if self.slider_tweenId[i] ~= nil then
	    	if self.slider_tweenId[i][1] ~= nil then
		    	Tween.Instance:Cancel(self.slider_tweenId[i][1])
		    end
		    if self.slider_tweenId[i][2] ~= nil then
		    	Tween.Instance:Cancel(self.slider_tweenId[i][2])
		    end
	    end

	    self.slider_tweenId[i] = {}
    	if self.toggle1.isOn then

	    	local self_data = self.data.s_statistics[i]
	    	if i == 1 then
	    		item.self_type.text = TI18N("伤害量")
				-- item.self_value.text = string.format("%s/%s", self_data.dmg_1, self.max_dmg)
				-- item.self_value.text = self_data.dmg_1
				item.self_value.text = ""
				item.self_expslider.value = 0

				local fun1 = function(value) item.self_expslider.value = value * 0.9 end
				local slider_value = self_data.dmg_1 / self.max_dmg
				if slider_value < 0.01 then
					slider_value = 0.01
				end
			    self.slider_tweenId[i][1] = Tween.Instance:ValueChange(item.self_expslider.value, slider_value, 0.6, nil, LeanTweenType.linear, fun1).id
			else
				local self_shouhu = nil
				local self_pet = nil
				if self_data ~= nil then
					self_shouhu = DataShouhu.data_guard_base_cfg[self_data.base_id_1]
					self_pet = DataPet.data_pet[self.data.s_statistics[i].base_id_1]
				end
				if self_shouhu ~= nil or self_pet ~= nil then
					item.self_type.text = TI18N("伤害量")
					-- item.self_value.text = string.format("%s/%s", self_data.dmg_1, self.max_dmg)
					-- item.self_value.text = self_data.dmg_1
					item.self_value.text = ""
					item.self_expslider.value = 0

					local fun1 = function(value) item.self_expslider.value = value * 0.9 end
					local slider_value = self_data.dmg_1 / self.max_dmg
					if slider_value < 0.01 then
						slider_value = 0.01
					end
				    self.slider_tweenId[i][1] = Tween.Instance:ValueChange(item.self_expslider.value, slider_value, 0.6, nil, LeanTweenType.linear, fun1).id
				    item.self_expslider.gameObject:SetActive(true)
				else
					item.self_type.text = ""
					item.self_value.text = ""
			   		item.self_expslider.gameObject:SetActive(false)
				end
			end

			local other_data = self.data.t_statistics[i]
			if i == 1 then
				item.other_type.text = TI18N("伤害量")
				-- item.other_value.text = string.format("%s/%s", other_data.dmg_2, self.max_dmg)
				-- item.other_value.text = other_data.dmg_2
				item.other_value.text = ""
				item.other_expslider.value = 0

				local fun2 = function(value) item.other_expslider.value = value * 0.9 end
				local slider_value = other_data.dmg_2 / self.max_dmg
				if slider_value < 0.01 then
					slider_value = 0.01
				end
		   	 	self.slider_tweenId[i][2] = Tween.Instance:ValueChange(item.other_expslider.value, slider_value, 0.6, nil, LeanTweenType.linear, fun2).id
			else
				local other_shouhu = nil
				local other_pet = nil
				if other_data ~= nil then
					other_shouhu = DataShouhu.data_guard_base_cfg[other_data.base_id_2]
					other_pet = DataPet.data_pet[self.data.t_statistics[i].base_id_2]
				end
				if other_shouhu ~= nil or other_pet then
					item.other_type.text = TI18N("伤害量")
					-- item.other_value.text = string.format("%s/%s", other_data.dmg_2, self.max_dmg)
					-- item.other_value.text = other_data.dmg_2
					item.other_value.text = ""
					item.other_expslider.value = 0

					local fun2 = function(value) item.other_expslider.value = value * 0.9 end
					local slider_value = other_data.dmg_2 / self.max_dmg
					if slider_value < 0.01 then
						slider_value = 0.01
					end
			   	 	self.slider_tweenId[i][2] = Tween.Instance:ValueChange(item.other_expslider.value, slider_value, 0.6, nil, LeanTweenType.linear, fun2).id
			   	 	item.other_expslider.gameObject:SetActive(true)
			   	elseif other_pet ~= nil then
					item.self_type.text = TI18N("伤害量")
			   	else
			   		item.other_type.text = ""
			   		item.other_value.text = ""
			   		item.other_expslider.gameObject:SetActive(false)
			   	end
			end
		else
			local self_data = self.data.s_statistics[i]
			if i == 1 then
				item.self_type.text = TI18N("治疗量")
				-- item.self_value.text = string.format("%s/%s", self_data.heal_1, self.max_heal)
				-- item.self_value.text = self_data.heal_1
				item.self_value.text = ""
				item.self_expslider.value = 0

				local fun1 = function(value) item.self_expslider.value = value * 0.9 end
				local slider_value = self_data.heal_1 / self.max_heal
				if slider_value < 0.01 then
					slider_value = 0.01
				end
			    self.slider_tweenId[i][1] = Tween.Instance:ValueChange(item.self_expslider.value, slider_value, 0.6, nil, LeanTweenType.linear, fun1).id
			else
				local self_shouhu = nil
				local self_pet = nil
				if self_data ~= nil then
					self_shouhu = DataShouhu.data_guard_base_cfg[self_data.base_id_1]
					self_pet = DataPet.data_pet[self.data.s_statistics[i].base_id_1]
				end
				if self_shouhu ~= nil or self_pet ~= nil then
					item.self_type.text = TI18N("治疗量")
					-- item.self_value.text = string.format("%s/%s", self_data.heal_1, self.max_heal)
					-- item.self_value.text = self_data.heal_1
					item.self_value.text = ""
					item.self_expslider.value = 0

					local fun1 = function(value) item.self_expslider.value = value * 0.9 end
					local slider_value = self_data.heal_1 / self.max_heal
					if slider_value < 0.01 then
						slider_value = 0.01
					end
				    self.slider_tweenId[i][1] = Tween.Instance:ValueChange(item.self_expslider.value, slider_value, 0.6, nil, LeanTweenType.linear, fun1).id
				    item.self_expslider.gameObject:SetActive(true)
				else
					item.self_type.text = ""
					item.self_value.text = ""
					item.self_expslider.gameObject:SetActive(false)
				end
			end

			local other_data = self.data.t_statistics[i]
			if i == 1 then
				item.other_type.text = TI18N("治疗量")
				-- item.other_value.text = string.format("%s/%s", other_data.heal_2, self.max_heal)
				-- item.other_value.text = other_data.heal_2
				item.other_value.text = ""
				item.other_expslider.value = 0

				local fun2 = function(value) item.other_expslider.value = value * 0.9 end
				local slider_value = other_data.heal_2 / self.max_heal
				if slider_value < 0.01 then
					slider_value = 0.01
				end
			    self.slider_tweenId[i][2] = Tween.Instance:ValueChange(item.other_expslider.value, slider_value, 0.6, nil, LeanTweenType.linear, fun2).id
			else
				local other_shouhu = nil
				local other_pet = nil
				if other_data ~= nil then
					other_shouhu = DataShouhu.data_guard_base_cfg[other_data.base_id_2]
					other_pet = DataPet.data_pet[self.data.t_statistics[i].base_id_2]
				end
				if other_shouhu ~= nil or other_pet ~= nil then
					item.other_type.text = TI18N("治疗量")
					-- item.other_value.text = string.format("%s/%s", other_data.heal_2, self.max_heal)
					-- item.other_value.text = other_data.heal_2
					item.other_value.text = ""
					item.other_expslider.value = 0

					local fun2 = function(value) item.other_expslider.value = value * 0.9 end
					local slider_value = other_data.heal_2 / self.max_heal
					if slider_value < 0.01 then
						slider_value = 0.01
					end
				    self.slider_tweenId[i][2] = Tween.Instance:ValueChange(item.other_expslider.value, slider_value, 0.6, nil, LeanTweenType.linear, fun2).id
				    item.other_expslider.gameObject:SetActive(true)
				else
					item.other_type.text = ""
					item.other_value.text = ""
					item.other_expslider.gameObject:SetActive(false)
				end
			end
		end
	end
end

function ArenaSettlementWindow:okButtonClick()
	self:Close()
end

function ArenaSettlementWindow:ontoggle1change(on)
    if on then
        self.toggle1.isOn = true
        self.toggle2.isOn = false
    else
        self.toggle1.isOn = false
        self.toggle2.isOn = true
    end
    self:Update_type()
end

function ArenaSettlementWindow:ontoggle2change(on)
    if on then
        self.toggle1.isOn = false
        self.toggle2.isOn = true
    else
        self.toggle1.isOn = true
        self.toggle2.isOn = false
    end
    self:Update_type()
end

function ArenaSettlementWindow:showTitle()
	if self.data.result == 1 then
		self.title1.gameObject:SetActive(true)
		self.title2.gameObject:SetActive(false)

		self.title1.localScale = Vector3.one * 3
	    Tween.Instance:Scale(self.title1.gameObject, Vector3.one, 1, function() self:show_light() end, LeanTweenType.easeOutElastic)
	else
		self.title1.gameObject:SetActive(false)
		self.title2.gameObject:SetActive(true)

		self.title2.localScale = Vector3.one * 3
	    Tween.Instance:Scale(self.title2.gameObject, Vector3.one, 1, function()  end, LeanTweenType.easeOutElastic)
	end
end

function ArenaSettlementWindow:show_light()
	self.light.gameObject:SetActive(true)

	self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function ArenaSettlementWindow:Rotate()
    self.light.transform:Rotate(Vector3(0, 0, 0.5))
end
-- ---------------------------------
-- 幻化手册卡片项
-- hosr
-- ---------------------------------
HandbookItem = HandbookItem or BaseClass()

function HandbookItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.transform = gameObject.transform
	self.parent = parent
	self.isActive = false

	self.imgList = {}
	self:InitPanel()
end

function HandbookItem:__delete()
	if self.headLoader ~= nil then
    	self.headLoader:DeleteMe()
	    self.headLoader = nil
	end
	self.bg.sprite = nil
	self.img.sprite = nil
	self.iconImg.sprite = nil
end

function HandbookItem:InitPanel()
	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickItem() end)
	self.bg = self.transform:Find("Bg"):GetComponent(Image)
	self.img = self.transform:Find("Img"):GetComponent(Image)
	self.img.gameObject:SetActive(true)
	self.select = self.transform:Find("Select").gameObject
	self.select:SetActive(false)
	self.icon = self.transform:Find("Icon").gameObject
	self.iconImg = self.icon:GetComponent(Image)
	self.levObj = self.transform:Find("Lev").gameObject
	self.levText = self.transform:Find("Lev/Val"):GetComponent(Text)
	self.red = self.transform:Find("Red").gameObject
	self.container = self.transform:Find("Container").gameObject
	self.Label = self.transform:Find("Label").gameObject
	local trans = self.container.transform
	local len = trans.childCount
	for i = 1, len do
		local img = trans:GetChild(i - 1).gameObject
		img:SetActive(false)
		table.insert(self.imgList, img)
	end
end

function HandbookItem:ClickItem()
	if self.data ~= nil then
		self:Select(true)
		self.parent:SelectOne(self)
	end
end

function HandbookItem:Select(bool)
	self.select:SetActive(bool)
end

function HandbookItem:SetData(data)
	self.data = data
	self.handbook = HandbookManager.Instance:GetDataById(self.data.id)

	self.isActive = false
	local activeVal = 0
	if self.handbook ~= nil then
		self.isActive = (self.handbook.status == HandbookEumn.Status.Active)
		activeVal = self.handbook.active_step
	end

	if self.parent.grade == self.data.lev then
		self.gameObject:SetActive(true)
	else
		self.gameObject:SetActive(false)
	end

	self.levText.text = data.level_limit

	if data.effect_type == HandbookEumn.EffectType.Pet then
		local pet = DataPet.data_pet[data.preview_id]
		if pet ~= nil then
			if self.headLoader == nil then
        		self.headLoader = SingleIconLoader.New(self.img.gameObject)
		    end
		    self.headLoader:SetSprite(SingleIconType.Pet, pet.head_id)

			-- self.img.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(pet.head_id), tostring(pet.head_id))
			self.img.gameObject.transform.localScale = Vector3.one
		end
	elseif data.effect_type == HandbookEumn.EffectType.Guard then
		local guard = DataShouhu.data_guard_base_cfg[data.preview_id]
		if guard ~= nil then
			if self.headLoader == nil then
        		self.headLoader = SingleIconLoader.New(self.img.gameObject)
		    end
		    self.headLoader:SetOtherSprite(self.parent.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(guard.base_id)))

			self.img.gameObject.transform.localScale = Vector3.one * 0.7
		end
	elseif data.effect_type == HandbookEumn.EffectType.NPC then
		if self.headLoader == nil then
        		self.headLoader = SingleIconLoader.New(self.img.gameObject)
		end
		self.headLoader:SetOtherSprite(self.parent.assetWrapper:GetSprite(AssetConfig.handbookhead, tostring(data.preview_id)))
		self.img.gameObject.transform.localScale = Vector3.one
	end
	self.bg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, string.format("HandbookBg%s", data.grade_type))
	self.bg:SetNativeSize()

	if self.isActive then
		self.icon:SetActive(true)
		if self.handbook.star_step == 1 then
			self.iconImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookStar1")
			self.iconImg:SetNativeSize()
		elseif self.handbook.star_step == 2 then
			self.iconImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookMoon1")
			self.iconImg:SetNativeSize()
		else
			self.icon:SetActive(false)
		end
		-- self.img.color = Color.white
		-- self.bg.color = Color.white
		self.container:SetActive(false)
	else
		self.container:SetActive(true)
		self.icon:SetActive(false)
		-- self.img.color = Color.gray
		-- self.bg.color = Color.gray
	end
	local has = 0
	for i,v in ipairs(self.data.allow_item) do
		if v ~= 28607 then
			has = BackpackManager.Instance:GetItemCount(v)
		end
	end

	self.levObj:SetActive(RoleManager.Instance.RoleData.lev <= data.level_limit)

	-- if self.handbook ~= nil and self.handbook.active_step == self.data.max_active_step then
	if self.handbook ~= nil and self.handbook.star_step == self.data.max_star_step then
		self.red:SetActive(false)
	else
		self.red:SetActive(has >= 1)
	end

	for i,img in ipairs(self.imgList) do
		if activeVal >= i then
			img:SetActive(false)
		else
			img:SetActive(true)
		end
	end
	self.Label:SetActive(HandbookManager.Instance.model:GetIdNeedById(self.data.id))
end

function HandbookItem:Update()
	if self.data ~= nil then
		self:SetData(self.data)
	end
end

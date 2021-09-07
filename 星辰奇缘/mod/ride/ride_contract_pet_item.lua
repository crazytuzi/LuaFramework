-- -------------------------------------
-- 坐骑契约宠物单项结构
-- hosr
-- -------------------------------------
RideContractPetItem = RideContractPetItem or BaseClass()

function RideContractPetItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.transform = self.gameObject.transform
	self.parent = parent

	self.lock = false
    self.selectArgs = {function(data) self:SelectOnePet(data) end, nil, 2}
	self:InitPanel()
end

function RideContractPetItem:__delete()
	if self.headLoader ~= nil then
		self.headLoader:DeleteMe()
		self.headLoader = nil
	end
	self.img.sprite = nil
end

function RideContractPetItem:InitPanel()
	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
	self.imgObj = self.transform:Find("Icon/Img").gameObject
	self.img = self.imgObj:GetComponent(Image)
	self.add = self.transform:Find("Icon/Add").gameObject
	self.lock = self.transform:Find("Icon/Lock").gameObject
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.lev = self.transform:Find("Lev"):GetComponent(Text)
	self.lockDesc = self.transform:Find("LockDesc").gameObject
	self.lockDescText = self.transform:Find("LockDesc/Text"):GetComponent(Text)
	self.btnObj = self.transform:Find("Button").gameObject
	self.btnObj:GetComponent(Button).onClick:AddListener(function() self:ClickRemove() end)
end

function RideContractPetItem:SetData(data)
	self.data = data
	if self.data == nil then
		self.add:SetActive(true)
		self.imgObj:SetActive(false)
		self.btnObj:SetActive(false)
		self.name.text = ""
		self.lev.text = ""
	else
		self.add:SetActive(false)
		self.imgObj:SetActive(true)
		self.btnObj:SetActive(true)
		if self.headLoader == nil then
        	self.headLoader = SingleIconLoader.New(self.img.gameObject)
	    end
	    self.headLoader:SetSprite(SingleIconType.Pet,self.data.base.head_id)
		-- self.img.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(self.data.base.head_id), self.data.base.head_id)
		self.name.text = self.data.name
		self.lev.text = string.format(TI18N("等级:%s"), self.data.lev)
	end
	self.gameObject:SetActive(true)

	self:SetLock(false)
end

function RideContractPetItem:SetLock(show, growth)
	self.lockMark = show
	if show then
		self.lock:SetActive(true)
		self.lockDesc:SetActive(true)
		if growth == nil then
			self.lockDesc.gameObject:SetActive(false)
		else
			self.growthData = RideManager.Instance.growthDataList[growth]
			self.lockDesc:GetComponent(Image).sprite = self.parent.assetWrapper:GetSprite(AssetConfig.ride_texture, string.format("RideGrowth%s", self.growthData.growth))
			self.lockDescText.text = string.format(TI18N("%s成长开启"), self.growthData.name)
			self.lockDesc.gameObject:SetActive(true)
		end
		self.add:SetActive(false)
		self.imgObj:SetActive(false)
		self.btnObj:SetActive(false)
		self.name.text = ""
		self.lev.text = ""
	else
		self.lock:SetActive(false)
		self.lockDesc:SetActive(false)
	end

	self.gameObject:SetActive(true)
end

-- 点击整个
function RideContractPetItem:ClickSelf()
	if self.lockMark then
		return
	end

	if self.data == nil then
		-- 加入
		PetManager.Instance.model:OpenPetSelectWindow(self.selectArgs)
	else
		-- 已有宠物的点击打开宠物预览tips
		local pet = PetManager.Instance:GetPetById(self.data.id)
		-- PetManager.Instance.model.quickshow_petdata = pet
		-- PetManager.Instance.model:OpenPetQuickShowWindow()
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {1})
	end
end

-- 移除
function RideContractPetItem:ClickRemove()
	RideManager.Instance:Send17014(self.parent.rideData.index, self.data.id)
end

function RideContractPetItem:SelectOnePet(data)
	RideManager.Instance:Send17007(self.parent.rideData.index, data.id)
end
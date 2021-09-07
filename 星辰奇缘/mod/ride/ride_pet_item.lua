-- ---------------------------
-- 坐骑契约宠物项
-- hosr
-- ---------------------------
RidePetItem = RidePetItem or BaseClass()

function RidePetItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.transform = self.gameObject.transform
	self.parent = parent

	self.bind = false
	self.full = false

	self.petList = {}
	self.headLoaderList = {}

	self:InitPanel()
end

function RidePetItem:__delete()
	if self.headLoaderList ~= nil then
    	for k,v in pairs(self.headLoaderList) do
	        if v ~= nil then
	            v:DeleteMe()
	            v = nil
	        end
	    end
	    self.headLoaderList = nil
	end
	if self.petList ~= nil then
		for i,v in ipairs(self.petList) do
			v.img.sprite = nil
			v.img = nil
			v.obj = nil
		end
		self.petList = nil
	end
end

function RidePetItem:InitPanel()
	self.select = self.transform:Find("Select").gameObject
	self.headImg = self.transform:Find("Head/Img"):GetComponent(Image)
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.lev = self.transform:Find("Lev"):GetComponent(Text)
	self.tag = self.transform:Find("Tag").gameObject
	self.redPoint = self.transform:Find("RedPoint").gameObject
	local pets = self.transform:Find("Pets")
	local len = pets.childCount

	for i = 1, len do
		local item = pets:GetChild(i - 1)
		item.gameObject:AddComponent(Button).onClick:AddListener(function() self:ItemClick(i) end)
		table.insert(self.petList, {obj = item.gameObject, img = item:Find("Image"):GetComponent(Image)})
	end

	self.select:SetActive(false)
	self.gameObject:SetActive(false)
end

function RidePetItem:update_my_self(rideData)
	self.rideData = rideData
	self.name.text = rideData.base.name
	self.lev.text = string.format("Lv.%s", rideData.lev)

    local headId = tostring(self.rideData.base.head_id)
    -- if self.rideData.transformation_id ~= nil and self.rideData.transformation_id ~= 0 then
    --     headId = tostring(DataMount.data_ride_data[self.rideData.transformation_id].head_id)
    -- end
	self.headImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.headride, headId)

	self.bind = false
	local count = 0
	for _,pet in ipairs(self.rideData.manger_pets) do
		local petData = PetManager.Instance:GetPetById(pet.pet_id)
		if petData ~= nil then
			if pet.pet_id == self.parent.petData.id then
				self.bind = true
			end
			count = count + 1
			local item = self.petList[count]
			item.obj:SetActive(true)
			local loaderId = item.img:GetComponent(Image).gameObject:GetInstanceID()
			if self.headLoaderList[loaderId] == nil then
			    self.headLoaderList[loaderId] = SingleIconLoader.New(item.img:GetComponent(Image).gameObject)
			end
			self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,petData.base.head_id)
			-- item.img.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(petData.base.head_id), petData.base.head_id)
			item.img.rectTransform.sizeDelta = Vector2(30, 30)
		end
	end

	local contractData = self.parent.model:GetContractData(self.rideData.index, self.rideData.tmp_growth)

	local fullNum = contractData.maxNum
	local oepnNum = contractData.num

	self.petConut = count
	self.oepnNum = oepnNum
	self.full = (count == oepnNum)

	for i = count+1, oepnNum do
		self.petList[i].obj:SetActive(true)
		self.petList[i].img.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage")
		self.petList[i].img.rectTransform.sizeDelta = Vector2(22, 22)
	end

	for i = oepnNum+1, fullNum do
		self.petList[i].obj:SetActive(true)
		self.petList[i].img.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Lock")
		self.petList[i].img.rectTransform.sizeDelta = Vector2(22, 22)
	end

	for i = fullNum+1, 4 do
		self.petList[i].obj:SetActive(false)
	end

	self.tag:SetActive(self.bind)
	self.gameObject:SetActive(true)


	if not self.bind and not self.full then
		local rideTypeList = {}
		if self.rideData.index == 1 or self.rideData.index == 2 then
			rideTypeList = { 1, 2 }
		elseif self.rideData.index == 3 then
			rideTypeList = { 3 }
		end

		local bind = false
		for _,rideData in ipairs(RideManager.Instance.model.ridelist) do
			if rideData.index ~= self.rideData.index and table.containValue(rideTypeList, rideData.index) then
				for __,pet in ipairs(rideData.manger_pets) do
					if pet.pet_id == self.parent.petData.id then
						bind = true
					end
				end
			end
		end
		self.redPoint:SetActive(not bind)
	else
		self.redPoint:SetActive(false)
	end
end

function RidePetItem:ClickOne()
	self.select:SetActive(true)
	self.parent:SelectOne()
end

function RidePetItem:Select(bool)
	self.select:SetActive(bool)
end

function RidePetItem:ItemClick(index)
	if index <= self.petConut then

	elseif index <= self.oepnNum then
		RideManager.Instance.model:CloseRidePet()
		WindowManager:OpenWindowById(WindowConfig.WinID.ridewindow, {4, nil, self.rideData.index})
	else
		local contractData = RideManager.Instance.model:GetContractData(self.rideData.index, self.rideData.tmp_growth)
		NoticeManager.Instance:FloatTipsByString(string.format(TI18N("坐骑成长达到%s色开启"), RideManager.Instance.growthDataList[contractData.openSlotData[index].growth].name))
	end
end
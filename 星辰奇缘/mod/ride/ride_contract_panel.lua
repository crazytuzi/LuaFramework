-- ---------------------------------
-- 坐骑契约
-- hosr
-- ---------------------------------
RideContractPanel = RideContractPanel or BaseClass(BasePanel)

function RideContractPanel:__init(parent)
	self.parent = parent
	self.model = RideManager.Instance.model

	self.resList = {
		{file = AssetConfig.ridecontract, type = AssetType.Main},
		{file = AssetConfig.ride_texture, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.skillItemList = {}
    self.petItemList = {}
    self.selectArgs = {function() self:SelectOnePet() end}

    self.listener = function() self:update() end
    self.init = false
end

function RideContractPanel:__delete()
	if self.petItemList ~= nil then
		for i,v in ipairs(self.petItemList) do
			v:DeleteMe()
		end
	end

    if self.skillItemList ~= nil then
        for i,v in ipairs(self.skillItemList) do
            v:DeleteMe()
        end
    end

    self.skillItemList = nil
    self.petItemList = nil
end

function RideContractPanel:OnShow()
    RideManager.Instance.OnContractUpdate:Add(self.listener)
	self:update()
end

function RideContractPanel:OnHide()
    RideManager.Instance.OnContractUpdate:Remove(self.listener)
end

function RideContractPanel:InitPanel()
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.ridecontract))
    self.gameObject.name = "RideContractPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(116, -7)

    self.transform:Find("Title/Text"):GetComponent(Text).text = TI18N("宠物契约")
    self.desc = self.transform:Find("Desc"):GetComponent(Text)
    self.desc.text = TI18N("与宠物<color='#ffff00'>签订契约</color>，拥有契约的宠物可获得坐骑附带的契约技能。 一只坐骑最多只能与<color='#248813'>两只宠物</color>同时签订契约。 坐骑精力不足<color='#248813'>50点</color>时，契约无法生效。")

    self.skillContainerRect = self.transform:Find("Skills/Container")
    for i = 1, self.skillContainerRect.childCount do
        local index = i
        local item = RideSkillItem.New(self.skillContainerRect:GetChild(i - 1).gameObject, self, true, false, index)
        table.insert(self.skillItemList, item)
    end

    self.petContainer = self.transform:Find("Pets/Scroll/Container").gameObject
    -- self.transform:Find("Pets/Scroll"):GetComponent(ScrollRect).enabled = false
    self.petRect = self.petContainer:GetComponent(RectTransform)
    local len = self.petContainer.transform.childCount
    for i = 1, len do
    	local item = RideContractPetItem.New(self.petContainer.transform:GetChild(i - 1).gameObject, self)
    	item.gameObject:SetActive(false)
    	table.insert(self.petItemList, item)
    end

    self.init = true
    self:OnShow()
end

function RideContractPanel:update()
    if self.model.cur_ridedata.lev == 0 then
        return
    end
	self.rideData = self.model.cur_ridedata

	self:UpdateSkill()
	self:UpdatePets()

    if self.rideData.index == 3 then
        self.transform:Find("Desc1"):GetComponent(Text).text = TI18N("坐骑三契约宠物可与<color='#ffff00'>坐骑一、二</color>重复")
    else
        self.transform:Find("Desc1"):GetComponent(Text).text = TI18N("签订或取消契约无任何消耗")
    end
end

function RideContractPanel:UpdateSkill()
    local list = self.rideData.skill_list
    table.sort(list, function(a,b) return a.skill_index < b.skill_index end)

    -- for i = 1, 4 do
    --     local v = list[i]
    --     self.skillItemList[i]:SetData(v)
    -- end

    -- for i = 5, #self.skillItemList do
    --     self.skillItemList[i].gameObject:SetActive(false)
    -- end

    local skill_num = 5

    for i = 1, #list do
        local v = list[i]
        self.skillItemList[i]:SetData(v)
    end

    if #list < skill_num then
        for i = #list+1, skill_num do
            self.skillItemList[i]:SetData(nil)
        end
    end

    if skill_num < #self.skillItemList then
        for i = skill_num+1, #self.skillItemList do
            self.skillItemList[i].gameObject:SetActive(false)
        end
    end

    self.skillContainerRect.sizeDelta = Vector2(skill_num * 90, 88)
end

function RideContractPanel:UpdatePets()
    for i,v in ipairs(self.petItemList) do
        v.gameObject:SetActive(false)
    end

	self.myPetList = {}
	for i,v in ipairs(self.rideData.manger_pets) do
        local pet = PetManager.Instance:GetPetById(v.pet_id)
        if pet ~= nil then
            table.insert(self.myPetList, pet)
        end
	end
    local count = 0
    for i,v in ipairs(self.myPetList) do
        count = i
        local item = self.petItemList[i]
        item:SetData(v)
    end

    local contractData = self.model:GetContractData(self.rideData.index, self.rideData.tmp_growth)
    local len = contractData.num - count
    for i = 1, len do
        -- 补一个加号
        count = count + 1
        local addItem = self.petItemList[count]
        if addItem ~= nil then
            addItem:SetData(nil)
        else
            count = count - 1
        end
    end

    len = contractData.maxNum - count
    for i = 1, len do
        -- 补一个加号
        count = count + 1
        local lockItem = self.petItemList[count]
        if lockItem ~= nil then
            -- if count == contractData.nextNum then
            --     lockItem:SetLock(true, contractData.nextGrowth)
            -- else
            --     lockItem:SetLock(true)
            -- end
            lockItem:SetLock(true, contractData.openSlotData[count].growth)
        else
            count = count - 1
        end
    end

    local w = 455
    local h = 80 * math.ceil(count / 2)
    self.petRect.sizeDelta = Vector2(w, h)
    self.petRect.anchoredPosition = Vector2.zero
end

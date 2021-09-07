-- 攻略宠物附灵 ljh
-- 20170629

EncyclopediaPetSpirit = EncyclopediaPetSpirit or BaseClass(BasePanel)


function EncyclopediaPetSpirit:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaPetSpirit"

    self.resList = {
        {file = AssetConfig.pet_spirit_pedia, type = AssetType.Main},
        {file = AssetConfig.petevaluation_texture,type = AssetType.Dep},
        {file = AssetConfig.pet_textures, type = AssetType.Dep},
    }
    self.currPetData = nil
    self.currGroup = 1
    self.currType = 1
    self.petdata = {}
    self.petdata[1] = {}
    self.petdata[2] = {}
    self.skilllist = {}
    self.headLoaderList = {}
    self.selectgo = nil
    local levlist = {1, 15, 35, 45, 55, 65, 75, 85, 95, 105, 110}
    local maxlev = 110
    for i=2,#levlist do
        if levlist[i-1] <= RoleManager.Instance.RoleData.lev and RoleManager.Instance.RoleData.lev < levlist[i] then
            maxlev = levlist[i]
            break
        end
    end
    for k,v in pairs(DataPet.data_pet) do
        if v.genre ~= 2 and v.genre ~= 4 and maxlev >= v.manual_level then
        	if v.manual_level >= 75 then
                local mark = false
                for _,data_pet_spirt_score in ipairs(DataPet.data_pet_spirt_score) do
                    if data_pet_spirt_score.base_id == v.id then
                        mark = true
                        break
                    end
                end
                if mark then
    	            table.insert(self.petdata[1], v)
                end
	        end
        elseif maxlev >= v.manual_level then
            local mark = false
            for _,data_pet_spirt_score in ipairs(DataPet.data_pet_spirt_score) do
                if data_pet_spirt_score.base_id == v.id then
                    mark = true
                    break
                end
            end
            if mark then
                table.insert(self.petdata[2], v)
            end
        end
    end
    BaseUtils.dump(self.petdata[2])
    table.sort(self.petdata[1], function(a,b)
        return a.manual_level < b.manual_level or a.id<b.id
    end)
    table.sort(self.petdata[2], function(a,b)
        return a.manual_level < b.manual_level or a.id<b.id
    end)
    self.gray_pet_list = {}
    for k,v in pairs(DataPet.data_pet) do
        if v.manual_type == self.showtype and v.manual_level <= manual_lev then
            if v.manual_level < manual_lev then
                table.insert(pet_list, {data = v, gray = false})
                self.gray_pet_list[v.id] = false
            else
                table.insert(pet_list, {data = v, gray = true})
                self.gray_pet_list[v.id] = true
            end
        end
    end

    self.skillItemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaPetSpirit:__delete()
    self.OnHideEvent:Fire()

    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    if self.skilllist ~= nil then
        for k,v in ipairs(self.skilllist) do
            v:DeleteMe()
        end
    end

    if self.Layout1 ~= nil then
        self.Layout1:DeleteMe()
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaPetSpirit:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_spirit_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.ToggleList = t:Find("ToggleList")
    self.Background = t:Find("ToggleList/Background").gameObject
    self.Label = t:Find("ToggleList/Label"):GetComponent(Text)
    self.ToggleList:GetComponent(Button).onClick:AddListener(function()
        local open = self.Background.activeSelf
        self.Background:SetActive(open == false)
        self.LevList:SetActive(open == false)
    end)

    self.LevList = t:Find("LevList").gameObject
    self.LevListbtn = t:Find("LevList/Button"):GetComponent(Button)
    self.LevListbtn.onClick:AddListener(function()
        self.Background:SetActive(false)
        self.LevList:SetActive(false)
    end)
    self.LevListCon = t:Find("LevList/Mask/Scroll")
    self.LevListItem = t:Find("LevList/Mask/Scroll"):GetChild(0).gameObject
    self.LevListItem:SetActive(false)

    self.ItemListCon = t:Find("ItemList/Mask/Scroll")
    self.ItemListItem = t:Find("ItemList/Mask/Scroll"):GetChild(0).gameObject
    self.ItemListItem.transform:SetParent(self.ItemListCon)

    self.skillNamelText = t:Find("Right/NamelText"):GetComponent(Text)
    self.skillLevelItemPanel = t:Find("Right/Mask/Panel")
    self.itemObject = t:Find("Right/Mask/Panel/Item").gameObject

    self.skillItemGrid = self.skillLevelItemPanel:GetComponent(GridLayoutGroup)


    self.skillSlot =  SkillSlot.New()
    UIUtils.AddUIChild(t:Find("Right/Icon").gameObject, self.skillSlot.gameObject)

    local setting1 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = 4
        ,Top = 0
    }
    self.Layout1 = LuaBoxLayout.New(self.LevListCon, setting1)
    for i=1,2 do
        local item = GameObject.Instantiate(self.LevListItem)
        self.Layout1:AddCell(item)
        if i == 1 then
            item.transform:Find("I18NText"):GetComponent(Text).text = TI18N("普通宠物")
            item.transform:GetComponent(Button).onClick:AddListener(function()
                self.Label.text = TI18N("普通宠物")
                self.currGroup = 1
                self.Background:SetActive(false)
                self.LevList:SetActive(false)
                self:InitPetList()
            end)
        else
            item.transform:Find("I18NText"):GetComponent(Text).text = TI18N("神兽")
            item.transform:GetComponent(Button).onClick:AddListener(function()
                self.Label.text = TI18N("神兽")
                self.currGroup = 2
                self.Background:SetActive(false)
                self.LevList:SetActive(false)
                self:InitPetList()
            end)
        end
    end
    self.Label.text = TI18N("普通宠物")
    self.currGroup = 1
    self.Background:SetActive(false)
    self.LevList:SetActive(false)
    self:InitPetList()
end

function EncyclopediaPetSpirit:OnTabChange(index)
    self.currType = index
    self:SetPetData(self.currPetData)
end

function EncyclopediaPetSpirit:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaPetSpirit:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaPetSpirit:OnHide()
    self:RemoveListeners()
end

function EncyclopediaPetSpirit:RemoveListeners()
end

function EncyclopediaPetSpirit:InitPetList()
    local oldList = {}
    for i=1, self.ItemListCon.childCount do
        self.ItemListCon:GetChild(i-1).gameObject:SetActive(false)
        table.insert(oldList, self.ItemListCon:GetChild(i-1))
    end
    local petList = self.petdata[self.currGroup]
    for i,v in ipairs(petList) do
        local Petitem = nil
        if #oldList > 0 then
            Petitem = oldList[#oldList]
            table.remove(oldList)
            Petitem.transform:SetParent(self.ItemListCon)
        else
            Petitem = GameObject.Instantiate(self.ItemListItem)
            Petitem.transform:SetParent(self.ItemListCon)
        end
        Petitem.gameObject:SetActive(true)
        Petitem.transform.localScale = Vector3.one

        local loaderId = Petitem.transform:Find("Head"):GetComponent(Image).gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(Petitem.transform:Find("Head"):GetComponent(Image).gameObject)

        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,v.head_id)
        self.headLoaderList[loaderId]:SetIconColor(Color(1,1,1,1))
        -- Petitem.transform:Find("Head"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(v.head_id), tostring(v.head_id))

        if v.need_lev_break > 0 then
            Petitem.transform:Find("Lv"):GetComponent(Text).text = string.format("突破%s", tostring(v.manual_level))
        else
            Petitem.transform:Find("Lv"):GetComponent(Text).text = v.manual_level
        end
        Petitem.transform:Find("Lv").sizeDelta = Vector2(math.ceil(Petitem.transform:Find("Lv"):GetComponent(Text).preferredWidth), 20)
        if v.manual_level > RoleManager.Instance.RoleData.lev or v.need_lev_break > RoleManager.Instance.RoleData.lev_break_times then
            Petitem.transform:Find("Lv"):GetComponent(Text).color = Color(1,0,0)
        else
            Petitem.transform:Find("Lv"):GetComponent(Text).color = Color(1,1,1)
        end
        Petitem.transform:Find("numbg").sizeDelta = Petitem.transform:Find("Lv").sizeDelta
        Petitem.transform:Find("Select").gameObject:SetActive(false)
        Petitem.transform:GetComponent(Button).onClick:RemoveAllListeners()
        Petitem.transform:GetComponent(Button).onClick:AddListener(function()
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Petitem.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)
            self:SetPetData(v)
        end)
        if i == 1 then
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Petitem.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)

            self:SetPetData(v)
        end
    end
end

function EncyclopediaPetSpirit:SetPetData(data)
    if data == nil then return end
    self.currPetData = data
    local transform = self.transform
    local petdata = data

    local skillIdList = {}
    local talentList = {}
    for k,v in pairs(DataPet.data_pet_spirt_score) do
    	if v.base_id == petdata.id then
    		local skillId = 0
    		if #v.skills > 0 then
    			skillId = v.skills[1][1]
    		end
    		if skillId ~= 0 and not table.containValue(skillIdList, skillId) then
	    		table.insert(skillIdList, skillId)
	    		table.insert(talentList, v.talent_min)
	    	end
    	end
    end

    local skillId = skillIdList[1]
    if skillId ~= nil then
    	local skillData = DataSkill.data_petSkill[string.format("%s_1", skillId)]
	    self.skillSlot:SetAll(Skilltype.petskill, skillData)

	    local tab = StringHelper.ConvertStringTable(skillData.name)
	    local length = #tab
		local tab1 = {}
		for i=1,length - 4 do
		    table.insert(tab1, tab[i])
		end
		local skillName = tostring(table.concat(tab1))

	    self.skillNamelText.text = skillName
    end
    local isSpecial = false
    if skillIdList[1] == 60920 or skillIdList[1] == 60940  then
        isSpecial = true
    end
    self.skillItemGrid.cellSize = Vector2(320, 100)
    if isSpecial then
        self.skillItemGrid.cellSize = Vector2(320, 120)
    end
	for i=1, #skillIdList do
		local item = self.skillItemList[i]
		if item == nil then
			item = GameObject.Instantiate(self.itemObject)
            item:SetActive(true)
            item.transform:SetParent(self.skillLevelItemPanel)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            self.skillItemList[i] = item
        end


		item.transform:Find("NamelText"):GetComponent(Text).text = string.format(TI18N("Lv.%s 宠物评分%s"), i, talentList[i])
		local skillData = DataSkill.data_petSkill[string.format("%s_1", skillIdList[i])]
        item.transform:Find("DesclText"):GetComponent(Text).text = skillData.desc
        local lineTrans = item.transform:Find("Line")
        local nameTrans = item.transform:Find("NamelText")
        local itemTrans = item.transform:Find("DesclText")
        
        if isSpecial then
            itemTrans.anchoredPosition = Vector2(5, -18)
            itemTrans.sizeDelta = Vector2(310, 83)
            lineTrans.anchoredPosition = Vector2(0, 54)
            nameTrans.anchoredPosition = Vector2(-66, 37.5)
        else
            itemTrans.anchoredPosition = Vector2(5, -22)
            itemTrans.sizeDelta = Vector2(310, 50)
            lineTrans.anchoredPosition = Vector2(0, 38)
            nameTrans.anchoredPosition = Vector2(-66, 18)
        end
    end
    

end
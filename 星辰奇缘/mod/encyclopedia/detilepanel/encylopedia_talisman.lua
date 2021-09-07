--作者:hzf
--03/28/2017 00:49:19
--功能:法宝百科

TalismanpediaTalisman = TalismanpediaTalisman or BaseClass(BasePanel)
function TalismanpediaTalisman:__init(parent)
	self.Mgr = EncyclopediaManager.Instance
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "TalismanpediaTalisman"
	self.resList = {
		{file = AssetConfig.talismanpedia, type = AssetType.Main},
		{file = AssetConfig.talisman_textures, type = AssetType.Dep},
		{file = AssetConfig.talisman_set, type = AssetType.Dep},
	}
	self.OnOpenEvent:Add(function() self:OnOpen() end)
	self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
	self.currset = 1
    self.iconloader = {}
end

function TalismanpediaTalisman:__delete()
    if self.iconloader ~= nil then
        for k,v in pairs(self.iconloader) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.iconloader = nil
    end
    if self.SetImage ~= nil then
        self.SetImage.sprite = nil
    end
    if self.Skill1Icon ~= nil then
        self.Skill1Icon.sprite = nil
    end
    if self.Skill2Icon ~= nil then
        self.Skill2Icon.sprite = nil
    end
    if self.Skill1IconLoader ~= nil then
        self.Skill1IconLoader:DeleteMe()
        self.Skill1IconLoader = nil
    end
    if self.Skill2IconLoader ~= nil then
        self.Skill2IconLoader:DeleteMe()
        self.Skill2IconLoader = nil
    end
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function TalismanpediaTalisman:OnHide()

end

function TalismanpediaTalisman:OnOpen()

end

function TalismanpediaTalisman:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.talismanpedia))
	self.gameObject.name = "TalismanpediaTalisman"

	self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

	self.Desc = self.transform:Find("Desc")
	self.ToggleList = self.transform:Find("ToggleList"):GetComponent(Toggle)
	self.Checkmark = self.transform:Find("ToggleList/Checkmark")
	self.Background = self.transform:Find("ToggleList/Background")
	self.Label = self.transform:Find("ToggleList/Label")
	self.ToggleList = t:Find("ToggleList")
    self.Background = t:Find("ToggleList/Background").gameObject
    self.Label = t:Find("ToggleList/Label"):GetComponent(Text)
    self.ToggleList:GetComponent(Button).onClick:AddListener(function()
        local open = self.Background.activeSelf
        self.Background:SetActive(open == false)
        self.ClassList:SetActive(open == false)
    end)


	self.ItemList = self.transform:Find("ItemList")
	self.Mask = self.transform:Find("ItemList/Mask")
	self.Scroll = self.transform:Find("ItemList/Mask/Scroll")


	self.Item = self.transform:Find("ItemList/Mask/Scroll/Item")
	-- self.Slot = self.transform:Find("ItemList/Mask/Scroll/Item/Slot")
	-- self.Icon = self.transform:Find("ItemList/Mask/Scroll/Item/Icon")
	-- self.Select = self.transform:Find("ItemList/Mask/Scroll/Item/Select")
	-- self.ItemName = self.transform:Find("ItemList/Mask/Scroll/Item/ItemName")
	-- self.SkillLev = self.transform:Find("ItemList/Mask/Scroll/Item/SkillLev")

    self.Skill1 = self.transform:Find("Skill1")
    self.skill1Button = self.Skill1.gameObject:AddComponent(Button)
    -- self.SkillCon = self.transform:Find("Skill1/SkillCon")
    self.Skill1Icon = self.transform:Find("Skill1/Skill"):GetComponent(Image)
    self.Skill1IconLoader = SingleIconLoader.New(self.Skill1Icon.gameObject)
    -- self.Title = self.transform:Find("Skill1/Title")
    self.Skill1Name = self.transform:Find("Skill1/SkillName"):GetComponent(Text)

    self.Skill2 = self.transform:Find("Skill2")
	self.skill2Button = self.Skill2.gameObject:AddComponent(Button)
	-- self.SkillCon = self.transform:Find("Skill2/SkillCon")
	self.Skill2Icon = self.transform:Find("Skill2/Skill"):GetComponent(Image)
    self.Skill2IconLoader = SingleIconLoader.New(self.Skill2Icon.gameObject)
	-- self.Title = self.transform:Find("Skill2/Title")
	self.Skill2Name = self.transform:Find("Skill2/SkillName"):GetComponent(Text)

	self.Right = self.transform:Find("Right")
	self.HeadArea = self.transform:Find("Right/HeadArea")
	self.Slot = self.transform:Find("Right/HeadArea/Slot")
	self.Icon = self.transform:Find("Right/HeadArea/Icon"):GetComponent(Image)
    self.NameText = self.transform:Find("Right/HeadArea/Name"):GetComponent(Text)
    self.ClassText = self.transform:Find("Right/HeadArea/Class"):GetComponent(Text)
    self.SetImage = self.transform:Find("Right/HeadArea/Set"):GetComponent(Image)
    -- self.ClassText.horizontalOverflow = 1
	self.Scroll = self.transform:Find("Right/Scroll")
	self.Container = self.transform:Find("Right/Scroll/Container")

	self.BaseTitle = self.transform:Find("Right/Scroll/Container/BaseTitle")
	self.ExtraTitle = self.transform:Find("Right/Scroll/Container/ExtraTitle")

	self.BaseAttr = self.transform:Find("Right/Scroll/BaseAttr").gameObject

	self.ExtraAttr = self.transform:Find("Right/Scroll/ExtraAttr")


	self.ClassList = t:Find("ClassList").gameObject
	t:Find("ClassList").anchoredPosition3D = Vector2(-184.7, 69.3, 0)
    self.ClassListBtn = t:Find("ClassList/Button"):GetComponent(Button)
    self.ClassListBtn.onClick:AddListener(function()
        self.Background:SetActive(false)
        self.ClassList:SetActive(false)
    end)

    self.ClassListCon = t:Find("ClassList/Mask/Scroll")
    self.ClassListItem = t:Find("ClassList/Mask/Scroll"):GetChild(0).gameObject
    self.ClassListItem:SetActive(false)

	self.ItemListCon = t:Find("ItemList/Mask/Scroll")
    self.ItemListItem = t:Find("ItemList/Mask/Scroll"):GetChild(0).gameObject

    local setting1 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = 4
        ,Top = 0
    }
    local setting2 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = -4.8
        ,Top = 0
    }
    self.Layout1 = LuaBoxLayout.New(self.ClassListCon, setting1)
    self.Layout2 = LuaBoxLayout.New(self.ItemListCon, setting2)

    local roleData = RoleManager.Instance.RoleData
    local index = 1
    for i,v in ipairs(self.Mgr.setList) do
        if true then
        -- if roleData.lev >= v.show_lev then
            local item = GameObject.Instantiate(self.ClassListItem)
            item.transform:Find("I18NText"):GetComponent(Text).text = v.set_name
            -- if v.quality == 3 then
            --     item.transform:Find("I18NText"):GetComponent(Text).text = string.format("[史诗]%s", v.set_name)
            -- elseif v.quality == 4 then
            --     item.transform:Find("I18NText"):GetComponent(Text).text = string.format("[传说]%s", v.set_name)
            -- end
            local tempIndex = index
            item.transform:GetComponent(Button).onClick:AddListener(function()
                self.Label.text = v.set_name
                -- if v.quality == 3 then
                --     self.Label.text = string.format("[史诗]%s", v.set_name)
                -- elseif v.quality == 4 then
                --     self.Label.text = string.format("[传说]%s", v.set_name)
                -- end
                self.currset = tempIndex
                self.Background:SetActive(false)
                self.ClassList:SetActive(false)
                self:RefreshItemList()
            end)
            self.Layout1:AddCell(item)

            index = index + 1
        end
    end
    self.Label.text = self.Mgr.setList[self.currset].set_name
    self:RefreshItemList()
end


function TalismanpediaTalisman:RefreshItemList()

    local oldList = {}
    for i=1, self.ItemListCon.childCount do
        self.ItemListCon:GetChild(i-1).gameObject:SetActive(false)
        table.insert(oldList, self.ItemListCon:GetChild(i-1))
    end

    local data = self.Mgr.setList[self.currset].childList
    self.Layout2:ReSet()
    for i,v in ipairs(data) do
        local Skillitem = nil
        if #oldList > 0 then
            Skillitem = oldList[#oldList]
            table.remove(oldList)
        else
            Skillitem = GameObject.Instantiate(self.ItemListItem)
        end
        self.Layout2:AddCell(Skillitem.gameObject)
        Skillitem.gameObject:SetActive(true)
        -- Skillitem.transform.localScale = Vector3.one
        local Img = Skillitem.transform:Find("Icon"):GetComponent(Image)
        local itemdata = DataItem.data_get[v.base_id]
        local id = Img.gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(Img.gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, itemdata.icon)
        self.iconloader[id]:SetIconColor(Color.white)
        Skillitem.transform:Find("ItemName"):GetComponent(Text).text = v.name
        -- Skillitem.transform:Find("SkillLev"):GetComponent(Text).text = v.about
        Skillitem.transform:Find("Select").gameObject:SetActive(false)
        Skillitem.transform:Find("Set"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(DataTalisman.data_get[v.base_id].set_id))
        Skillitem.transform:GetComponent(Button).onClick:RemoveAllListeners()
        Skillitem.transform:GetComponent(Button).onClick:AddListener(function()
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Skillitem.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)
            self:SetSkillData(v)
        end)
        if i == 1 then
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Skillitem.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)

            self:SetSkillData(v)
        end
    end
end


function TalismanpediaTalisman:SetSkillData(data)
    local itemdata = DataItem.data_get[data.base_id]
    local id = self.Icon.gameObject:GetInstanceID()
    if self.iconloader[id] == nil then
        self.iconloader[id] = SingleIconLoader.New(self.Icon.gameObject)
        self.iconloader[id]:SetSprite(SingleIconType.Item, itemdata.icon)
    else
        self.iconloader[id]:SetSprite(SingleIconType.Item, itemdata.icon)
    end

    self.NameText.text = data.name
    local str = TI18N("推荐：")
    if next(self.Mgr.setList[self.currset].perfectclass) == nil then
        str = str..TI18N("全职业")
    else
        for i,v in ipairs(self.Mgr.setList[self.currset].perfectclass) do
            if i == 1 then
                str = str..KvData.classes_name[v]
            else
                str = string.format("%s、%s", str, KvData.classes_name[v])
            end
        end
    end
    self.SetImage.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(DataTalisman.data_get[data.base_id].set_id))
	self.ClassText.text = str
	local firstskill = nil
	local secondskill = nil
    local currQuality = self.Mgr.setList[self.currset].quality
    -- if currQuality == 2 then
    --     firstskill = self.Mgr.setList[self.currset].skills_blue_2[1][2]
    --     secondskill = self.Mgr.setList[self.currset].skills_blue_4[1][2]
    -- elseif currQuality == 3 then
    --     firstskill = self.Mgr.setList[self.currset].skills_purple_2[1][2]
    --     secondskill = self.Mgr.setList[self.currset].skills_purple_4[1][2]
    -- elseif currQuality == 4 then
    --     firstskill = self.Mgr.setList[self.currset].skills_orange_2[1][2]
    --     secondskill = self.Mgr.setList[self.currset].skills_orange_4[1][2]
    -- end
    --2018/06/27 @hze @显示最高品质描述
    firstskill = self.Mgr.setList[self.currset].skills_red_2[1][2]
    secondskill = self.Mgr.setList[self.currset].skills_red_4[1][2]
	if firstskill then
		local cfg = DataSkill.data_talisman_skill[string.format("%s_1", firstskill)]
        -- self.Skill1Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_skill, cfg.icon)
        self.Skill1IconLoader:SetSprite(SingleIconType.SkillIcon, cfg.icon)
        self.skill1Button.onClick:RemoveAllListeners()
        self.skill1Button.onClick:AddListener(function()
            TipsManager.Instance:ShowSkill({gameObject = self.skill1Button.gameObject, skillData = cfg, type = Skilltype.talisman})
        end)
        self.Skill1Name.text = string.sub(cfg.name, 1, 12)
    end
    if secondskill then
		local cfg = DataSkill.data_talisman_skill[string.format("%s_1", secondskill)]
		-- self.Skill2Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_skill, cfg.icon)
        self.Skill2IconLoader:SetSprite(SingleIconType.SkillIcon, cfg.icon)
        self.skill2Button.onClick:RemoveAllListeners()
        self.skill2Button.onClick:AddListener(function()
            TipsManager.Instance:ShowSkill({gameObject = self.skill2Button.gameObject, skillData = cfg, type = Skilltype.talisman})
        end)
        self.Skill2Name.text = string.sub(cfg.name, 1, 12)
	end
	self.oldbaseAttrList = {}
	self.oldextraAttrList = {}
	for child in Slua.iter(self.Container) do
		if child.gameObject.name == "BaseAttr" then
			table.insert(self.oldbaseAttrList, child)
			child.gameObject:SetActive(false)
		elseif child.gameObject.name == "ExtraAttr" then
			table.insert(self.oldextraAttrList, child)
			child.gameObject:SetActive(false)
		end
	end

	local H = 30
	for i,v in ipairs(data.base_attr) do
		local go = table.remove(self.oldbaseAttrList)
		if go ~= nil then
			go = go.gameObject
		else
			go = GameObject.Instantiate(self.BaseAttr)
			go.name = "BaseAttr"
			go.transform:SetParent(self.Container)
			go.transform.localScale = Vector3.one
		end
		go:SetActive(true)
		go.transform.anchoredPosition3D = Vector3(0, -H, 0)
		go.transform:Find("Attr"):GetComponent(Text).text = string.format("<color='#8dcfec'>%s</color> <color='#c7f9ff'>+%s</color>", KvData.attr_name[v.key], KvData.GetAttrVal(v.key, v.val))
		H = H + 23
	end
	self.ExtraTitle.anchoredPosition3D = Vector3(0, -H, 0)
	H = H + 30
    local key = BaseUtils.Key(data.type, data.quality, data.grade, 1)
	local spdata = self.Mgr.talismanSp[key]
    if spdata ~= nil then
    	for i=1,10 do
    		local key1 = string.format("attr_name%s", i)
            local key2 = string.format("attr_val%s", i)
            local key3 = string.format("attr_ratio%s", i)
            if spdata[key1] ~= nil then
            	local go = table.remove(self.oldextraAttrList)
    			if go ~= nil then
    				go = go.gameObject
    			else
    				go = GameObject.Instantiate(self.BaseAttr)
    				go.name = "ExtraAttr"
    				go.transform:SetParent(self.Container)
    				go.transform.localScale = Vector3.one
    			end
    			go:SetActive(true)
    			go.transform.anchoredPosition3D = Vector3(0, -H, 0)
    			go.transform:Find("Attr"):GetComponent(Text).text = string.format("<color='#00ffff'>%s +%s</color>", KvData.GetAttrName(spdata[key1], spdata.action_object), KvData.GetAttrVal(spdata[key1], spdata[key2]))
    			H = H + 23
            end
    	end
    end

    key = BaseUtils.Key(data.type, data.quality, data.grade, 2)
    spdata = self.Mgr.talismanSp[key]
    if spdata ~= nil then
        for i=1,10 do
            local key1 = string.format("attr_name%s", i)
            local key2 = string.format("attr_val%s", i)
            local key3 = string.format("attr_ratio%s", i)
            if spdata[key1] ~= nil then
                local go = table.remove(self.oldextraAttrList)
                if go ~= nil then
                    go = go.gameObject
                else
                    go = GameObject.Instantiate(self.BaseAttr)
                    go.name = "ExtraAttr"
                    go.transform:SetParent(self.Container)
                    go.transform.localScale = Vector3.one
                end
                go:SetActive(true)
                go.transform.anchoredPosition3D = Vector3(0, -H, 0)
                go.transform:Find("Attr"):GetComponent(Text).text = string.format("<color='#00ffff'>%s +%s</color>", KvData.GetAttrName(spdata[key1], spdata.action_object), KvData.GetAttrVal(spdata[key1], spdata[key2]))
                H = H + 23
            end
        end
    end
	self.Container.sizeDelta = Vector2(250, H)
end
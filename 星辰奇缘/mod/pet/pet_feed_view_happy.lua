-- ----------------------------------------------------------
-- UI - 宠物喂养窗口 喂养面板
-- ----------------------------------------------------------
PetFeedView_Happy = PetFeedView_Happy or BaseClass(BasePanel)

function PetFeedView_Happy:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "PetFeedView_Happy"
    self.resList = {
        {file = AssetConfig.pet_feed_window_happy, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.petData = nil

	self.itemdata_list = {}
    self.headLoaderList = {}
	self.item_list = {}

	self.page_base_obj = nil --道具页基础母本
	self.page_content_obj = nil --道具页的父亲
	self.toggle_content_obj = nil
	self.toggle_base_obj = nil
	self.scroll = nil
	self.can_scroll = false

	self.init_index = 0
	self.each_count = 10 --每页的数量
	self.item_table = {}
	self.page_table = {}
	self.page_count = 0 --开启的页数

    self.toggleContainer = nil
    self.toggleCloner = nil
    self.toggleList = {}

    self.defualt_item_list = { 21301, 20004, 22202, 21312, 29103, 21304}

    self.happyTips = {TI18N("1、宠物寿命没有上限，每场战斗消耗<color='#ffff00'>1点</color>")
                    , TI18N("2、宠物战斗死亡后将消耗<color='#ffff00'>50点</color>寿命")
                    , TI18N("3、神兽和珍兽拥有<color='#00ff00'>永生</color>效果")
                    , TI18N("4、宠物寿命低于<color='#ffff00'>50点</color>将无法参战")
                    , TI18N("5、喂养宠物<color='#ffff00'>长生果</color>可以增加宠物寿命值")}

    ------------------------------------------------
    self._update_pet = function() self:update_base() self:update_qualityattrs() end
    -- self._update_base = function() self:update_base() end
    self._update_qualityattrs = function() self:update_qualityattrs() end
    self._update_items = function() self:update_items() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetFeedView_Happy:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_feed_window_happy))
    self.gameObject.name = "PetFeedView_Happy"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform
    -- self.transform:SetAsFirstSibling()

    local transform = self.transform
    -- 按钮功能绑定
    transform:FindChild("DescButton"):GetComponent(Button).onClick:AddListener(
        function() TipsManager.Instance:ShowText({gameObject = transform:FindChild("DescButton").gameObject, itemData = self.happyTips}) end)

    transform:FindChild("PetHead/HappyGroup").gameObject:AddComponent(Button).onClick:AddListener(
        function() TipsManager.Instance:ShowText({gameObject = transform:FindChild("DescButton").gameObject, itemData = self.happyTips}) end)

    transform:FindChild("PetHead/ClickArea").gameObject:GetComponent(Button).onClick:AddListener(
        function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, {function(data) self:selectPet(data) end}) end)

    transform:FindChild("PetHead/Button").gameObject:GetComponent(Button).onClick:AddListener(
        function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, {function(data) self:selectPet(data) end}) end)

    self.page_content_obj = transform:Find("ItemPanel/ScrollView/Container").gameObject
    self.page_base_obj = transform:Find("ItemPanel/ScrollView/Container/ItemPage").gameObject

    self.tabbedPanel = TabbedPanel.New(transform:Find("ItemPanel/ScrollView").gameObject, 1, 345)
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnMoveEnd(currentPage, direction) end)
    self.toggleContainer = transform:Find("ItemPanel/ToggleGroup")
    self.toggleCloner = self.toggleContainer:Find("Toggle").gameObject
    self.toggleContainer.gameObject:SetActive(true)
    self.toggleCloner:SetActive(false)

    self.init_index = 0

    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function PetFeedView_Happy:__delete()
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
    for k,v in pairs(self.item_table) do
        v:DeleteMe()
        v = nil
    end

    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
end

function PetFeedView_Happy:OnShow()
	PetManager.Instance.OnUpdatePetList:Add(self._update_pet)
    -- PetManager.Instance.OnPetUpdate:Add(self._update_base)
    PetManager.Instance.OnPetUpdate:Add(self._update_qualityattrs)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._update_items)

    self.petData = self.model.cur_petdata

    self:update()
end

function PetFeedView_Happy:OnHide()
	PetManager.Instance.OnUpdatePetList:Remove(self._update_pet)
    -- PetManager.Instance.OnPetUpdate:Remove(self._update_base)
    PetManager.Instance.OnPetUpdate:Remove(self._update_qualityattrs)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._update_items)
end

function PetFeedView_Happy:update()
    if self.petData == nil then return end
    self.pet_level = self.petData.lev
    self:update_base()
    self:update_qualityattrs()
    self:update_items()
end

function PetFeedView_Happy:update_base()
    local petData = self.petData
    local transform = self.transform
    local panel = transform:FindChild("PetHead").gameObject
    panel.transform:FindChild("ExpGroup/HappyText"):GetComponent(Text).text = string.format("%s/%s", petData.exp, petData.max_exp)
    local slider1 = panel.transform:FindChild("ExpGroup/HappySlider"):GetComponent(Slider)
    if self.pet_level ~= self.petData.lev then
        local fun = function() BaseUtils.tweenDoSlider(slider1, 0, petData.exp / petData.max_exp, 0.3) end
        BaseUtils.tweenDoSlider(slider1, slider1.value, 1, 0.3, fun)
        self.pet_level = self.petData.lev
    else
        BaseUtils.tweenDoSlider(slider1, slider1.value, petData.exp / petData.max_exp, 0.3)
    end
    if petData.genre == 2 or petData.genre == 4 then
        panel.transform:FindChild("HappyGroup/HappyText"):GetComponent(Text).text = string.format("<color='#ffff00'>%s</color>", TI18N("永生"))
    else
        panel.transform:FindChild("HappyGroup/HappyText"):GetComponent(Text).text = string.format("<color='#ffff00'>%s</color>", petData.happy)
    end
	-- local slider2 = panel.transform:FindChild("HappyGroup/HappySlider"):GetComponent(Slider)
    -- BaseUtils.tweenDoSlider(slider2, slider2.value, petData.happy / 100, 0.3)

    panel.transform:FindChild("NameText"):GetComponent(Text).text = self.model:get_petname(petData)--petData.name
    panel.transform:FindChild("LVText"):GetComponent(Text).text = string.format(TI18N("等级：%s"), petData.lev)

    local headId = tostring(petData.base.head_id)

    local loaderId = panel.transform:FindChild("Head_78/Head"):GetComponent(Image).gameObject:GetInstanceID()
    if self.headLoaderList[loaderId] == nil then
        self.headLoaderList[loaderId] = SingleIconLoader.New(panel.transform:FindChild("Head_78/Head"):GetComponent(Image).gameObject)
    end
    self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,petData.base.head_id)
    -- panel.transform:FindChild("Head_78/Head"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
        -- headitem.transform:FindChild("Head_78/Head"):GetComponent(Image):SetNativeSize()
    panel.transform:FindChild("Head_78/Head"):GetComponent(Image).rectTransform.sizeDelta = Vector2(64, 64)
end

function PetFeedView_Happy:update_qualityattrs()
    local petData = self.petData
    local transform = self.transform
    transform:FindChild("AttrsPanel/ValueText1"):GetComponent(Text).text = string.format("%s/%s", petData.phy_aptitude, petData.max_phy_aptitude)
    transform:FindChild("AttrsPanel/ValueText2"):GetComponent(Text).text = string.format("%s/%s", petData.pdef_aptitude, petData.max_pdef_aptitude)
    transform:FindChild("AttrsPanel/ValueText3"):GetComponent(Text).text = string.format("%s/%s", petData.hp_aptitude, petData.max_hp_aptitude)
    transform:FindChild("AttrsPanel/ValueText4"):GetComponent(Text).text = string.format("%s/%s", petData.magic_aptitude, petData.max_magic_aptitude)
    transform:FindChild("AttrsPanel/ValueText5"):GetComponent(Text).text = string.format("%s/%s", petData.aspd_aptitude, petData.max_aspd_aptitude)

    transform:FindChild("AttrsPanel/GrowthText"):GetComponent(Text).text = tostring(petData.growth / 500)
    transform:FindChild("AttrsPanel/GrowthImage"):GetComponent(Image).sprite
        -- = ctx.ResourcesManager:GetSprite(config.resources.base, string.format("PetGrowth%s", petData.growth_type))
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", petData.growth_type))
end

function PetFeedView_Happy:update_items()
	self:update_item_volumn()
	self:update_use_items()
end

--更新可使用的物品数量
function PetFeedView_Happy:update_item_volumn()
    self.itemdata_list = {}
    local item_data_by_baseid = nil
    local item = nil

    for i=1,#self.defualt_item_list do
        item_data_by_baseid = BackpackManager.Instance:GetItemByBaseid(self.defualt_item_list[i])
        if #item_data_by_baseid > 0 then
            item = BaseUtils.copytab(item_data_by_baseid[1])
            item.quantity = BackpackManager.Instance:GetItemCount(self.defualt_item_list[i])
            item.show_num = true
        else
        	item = BackpackManager.Instance:GetItemBase(self.defualt_item_list[i])
            item.quantity = 0
            item.show_num = false
        end
        table.insert(self.itemdata_list, item)
    end

    --------------------------------------------------------------------------------------
    local items = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.pet_growth)
    for i,v in ipairs(items) do
        if not table.containValue(self.defualt_item_list, v.base_id) then
            table.insert(self.itemdata_list, v)
        end
    end
    local items = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.pet_max_apt)
    for i,v in ipairs(items) do
        if not table.containValue(self.defualt_item_list, v.base_id) then
            table.insert(self.itemdata_list, v)
        end
    end
    items = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.pet_expbook)
    for i,v in ipairs(items) do
        if not table.containValue(self.defualt_item_list, v.base_id) then
            table.insert(self.itemdata_list, v)
        end
    end
    items = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.pet_feed)
    for i,v in ipairs(items) do
        if not table.containValue(self.defualt_item_list, v.base_id) then
            table.insert(self.itemdata_list, v)
        end
    end
    items = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.petglutinousriceballs)
    for i,v in ipairs(items) do
        if not table.containValue(self.defualt_item_list, v.base_id) then
            table.insert(self.itemdata_list, v)
        end
    end

    -- BaseUtils.dump(self.itemdata_list)
end

--更新道具
function PetFeedView_Happy:update_use_items()
    local page_count = math.ceil(#self.itemdata_list / self.each_count)

    for i,item in ipairs(self.itemdata_list) do
        local solt = self.item_table[i]
        if solt == nil then
        	local page = self.page_table[math.ceil(i / self.each_count)]
        	if page == nil then
        		page = GameObject.Instantiate(self.page_base_obj)
        		table.insert(self.page_table, page)
        		UIUtils.AddUIChild(self.page_content_obj, page)
        	end
        	solt = ItemSlot.New()
        	table.insert(self.item_table, solt)
        	UIUtils.AddUIChild(page, solt.gameObject)

            local toggle = self.toggleList[math.ceil(i / self.each_count)]
            if toggle == nil then
                toggle = GameObject.Instantiate(self.toggleCloner)
                table.insert(self.toggleList, toggle:GetComponent(Toggle))
                UIUtils.AddUIChild(self.toggleContainer, toggle)
                if math.ceil(i / self.each_count) == 1 then
                    toggle:GetComponent(Toggle).isOn = true
                end
            end
        end
		solt.gameObject:SetActive(true)
        if item.quantity > 0 then
        	local extra = { white_list = {{id = 1, show = true}, {id = 10, show = false}}}
            if item.base_id  == 20004 then
                table.insert(extra.white_list, {id = 22, show = true})
            end
        	solt:SetAll(item, extra)
            solt:SetGrey(false)
        else
        	local extra = { white_list = {{id = 1, show = false}, {id = 2, show = true}, {id = 10, show = false}}}
        	solt:SetAll(item, extra)
            solt:SetGrey(true)
        end
    end

    local show_solt_num = #self.itemdata_list
    if #self.itemdata_list % self.each_count ~= 0 then
        show_solt_num = math.floor(#self.itemdata_list / self.each_count + 1) * self.each_count
        for i = #self.itemdata_list+1, show_solt_num do
            local solt = self.item_table[i]
            if solt == nil then
                local page = self.page_table[math.ceil(i / self.each_count)]
                if page == nil then
                    page = GameObject.Instantiate(self.page_base_obj)
                    table.insert(self.page_table, page)
                    UIUtils.AddUIChild(self.page_content_obj, page)
                end
                solt = ItemSlot.New()
                table.insert(self.item_table, solt)
                UIUtils.AddUIChild(page, solt.gameObject)
            end
            solt:SetAll(nil)
        end
    end

    for i = show_solt_num+1, #self.item_table do
    	local solt = self.item_table[i]
    	solt.gameObject:SetActive(false)
        solt:SetAll(nil)
    end

	if self.page_count ~= page_count then
	    self.tabbedPanel:SetPageCount(page_count)

        if self.page_count > page_count then
            for i = page_count+1, self.page_count do
                local page = self.page_table[i]
                page:SetActive(false)
                local toggle = self.toggleList[i]
                toggle.gameObject:SetActive(false)
            end
        else
            for i = self.page_count+1, page_count do
                local page = self.page_table[i]
                page:SetActive(true)
                local toggle = self.toggleList[i]
                toggle.gameObject:SetActive(true)
            end
        end
	    self.page_count = page_count
	end
end

function PetFeedView_Happy:OnMoveEnd(currentPage, direction)
    for _, toggle in ipairs(self.toggleList) do
        toggle.isOn = false
    end
    self.toggleList[currentPage].isOn = true
end

function PetFeedView_Happy:selectPet(data)
    if data ~= nil then
        self.petData = data
        self.model.cur_petdata = data
        self:update()

        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("切换成功，当前选中宠物切换为<color=#00FF00>%s</color>"), tostring(data.name)))
    end
end
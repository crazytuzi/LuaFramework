-- -------------------------------------
-- 子女喂养
-- hosr
-- -------------------------------------
PetChildFeedView = PetChildFeedView or BaseClass(BaseWindow)

function PetChildFeedView:__init()
    self.windowId = WindowConfig.WinID.pet_child_feed
    self.resList = {
        { file = AssetConfig.childfeedwindow, type = AssetType.Main },
        { file = AssetConfig.childhead, type = AssetType.Dep },
        { file = AssetConfig.pet_textures, type = AssetType.Dep },
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
    }

    self.init_index = 0
    self.each_count = 5
    -- 每页的数量
    self.item_table = { }
    self.page_table = { }
    self.page_count = 0
    -- 开启的页数

    self.toggleContainer = nil
    self.toggleCloner = nil
    self.toggleList = { }
    self.TipsData = {
        TI18N("1、子女<color='#ffff00'>快乐值>=60</color>点时，子女<color='#ffff00'>冒险</color>有一定加成")
        ,TI18N("2、子女<color='#ffff00'>快乐值<60</color>点，子女<color='#ffff00'>能力</color>会相应下降")
        ,TI18N("3、子女每次出场参战，心情有几率降低，使用<color='#ffff00'>桂花糕、金香果</color>增加子女心情值")
    }
    self.defualt_item_list = { 23830, 23831, 23840, 23841, 23842, 23843, 23844, 23845, 23846 }
    self.listener = function() self:Update() end
    self.itemListener = function() self:UpdateItems() end
end

function PetChildFeedView:__delete()
    for k, v in pairs(self.item_table) do
        v:DeleteMe()
        v = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.selectReminPanl ~= nil then
        self.selectReminPanl:DeleteMe()
        self.selectReminPanl = nil
    end

    if self.growhImg ~= nil then
        self.growhImg.sprite = nil
    end
    ChildrenManager.Instance.OnChildAttrUpdate:Remove(self.listener)
    ChildrenManager.Instance.OnChildDataUpdate:Remove(self.listener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemListener)
end

function PetChildFeedView:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet_child_feed)
end

function PetChildFeedView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childfeedwindow))
    self.gameObject.name = "PetChildFeedView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener( function() self:Close() end)

    local feed = self.transform:Find("Main/PetFeedHappy")
    self.headImg = feed:Find("PetHead/Head_78/Head"):GetComponent(Image)
    self.headImgRect = feed:Find("PetHead/Head_78/Head"):GetComponent(RectTransform)
    self.name = feed:Find("PetHead/NameText"):GetComponent(Text)
    self.lev = feed:Find("PetHead/LVText"):GetComponent(Text)

    self.fullSlider = feed:Find("PetHead/HappyGroup/HappySlider"):GetComponent(Slider)
    feed:Find("PetHead/HappyGroup/Text"):GetComponent(Text).text = TI18N("心 情")
    self.sliderFillImg = feed:Find("PetHead/HappyGroup/HappySlider/Fill Area/Fill"):GetComponent(Image)
    self.fullVal = feed:Find("PetHead/HappyGroup/HappyText"):GetComponent(Text)

    feed:Find("PetHead/Button"):GetComponent(Button).onClick:AddListener( function() self:OnChange() end)
    self.DescButton = feed:Find("DescButton"):GetComponent(Button)
    self.DescButton.onClick:AddListener( function() self:OnDesc() end)

    local attr = feed:Find("AttrsPanel")
    self.phyAtk = attr:Find("ValueText1"):GetComponent(Text)
    self.phyDef = attr:Find("ValueText2"):GetComponent(Text)
    self.hp = attr:Find("ValueText3"):GetComponent(Text)
    self.mag = attr:Find("ValueText4"):GetComponent(Text)
    self.speed = attr:Find("ValueText5"):GetComponent(Text)
    self.growhVal = attr:Find("GrowthText"):GetComponent(Text)
    self.growhImg = attr:Find("GrowthImage"):GetComponent(Image)

    self.page_content_obj = feed:Find("ItemPanel/ScrollView/Container").gameObject
    self.page_base_obj = feed:Find("ItemPanel/ScrollView/Container/ItemPage").gameObject
    self.tabbedPanel = TabbedPanel.New(feed:Find("ItemPanel/ScrollView").gameObject, 1, 345)
    self.tabbedPanel.MoveEndEvent:Add( function(currentPage, direction) self:OnMoveEnd(currentPage, direction) end)
    self.toggleContainer = feed:Find("ItemPanel/ToggleGroup")
    self.toggleCloner = self.toggleContainer:Find("Toggle").gameObject
    self.toggleContainer.gameObject:SetActive(true)
    self.toggleCloner:SetActive(false)

    self.attrsPanl = feed:Find("AttrsPanel")
    self.statusPanl = feed:Find("StatusPanel")

    self.txt_status1 = feed:Find("StatusPanel/txt_status1"):GetComponent(Text)
    self.txt_status2 = feed:Find("StatusPanel/txt_status2"):GetComponent(Text)
    self.item_list = { }
    for i = 1, 3 do
        local item = feed:Find("StatusPanel/AttrItem" .. i).gameObject
        local btn =  feed:Find("StatusPanel/AttrItem" .. i):GetComponent(Button)
        btn.onClick:AddListener(function() self:OnStatusAttrClick(i) end)
        table.insert(self.item_list, item)
    end
    self.txt_remind = feed:Find("StatusPanel/btn_remind/Text"):GetComponent(Text)
    self.btn_remind = feed:Find("StatusPanel/btn_remind"):GetComponent(Button)
    self.btn_remind.onClick:AddListener(
    function()
        self.selectPanel.gameObject:SetActive(true)
    end )

    self.tabGroupObj = feed:Find("TabButtonGroup").gameObject
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end)

    self.selectPanel = self.transform:Find("ChildHappyRemindSelectPanel")
    self.selectPanel.gameObject:SetActive(false)
    self.selectPanel:Find("Panel"):GetComponent(Button).onClick:AddListener( function() self.selectPanel.gameObject:SetActive(false) end)
    local selectMain = self.selectPanel:Find("Main")
    for i = 1, 4 do
        local item = selectMain:GetChild(i - 1).gameObject
        local index = 5 - i
        item.transform:Find("Text"):GetComponent(Text).text = ChildrenEumn.ChildRemindTitle[index]
        item:GetComponent(Button).onClick:AddListener( function() self:OnSelectClick(index) end)
    end

    ChildrenManager.Instance.OnChildAttrUpdate:Add(self.listener)
    ChildrenManager.Instance.OnChildDataUpdate:Add(self.listener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemListener)
    self:OnShow()
end

function PetChildFeedView:OnShow()
    self.child = self.openArgs[1]
    local  tab = self.openArgs[2] or 1
    self.tabGroup:ChangeTab(tab)
    self:Update()
    local childNoviceData = ChildrenManager.Instance:GetChildNovice(self.child.child_id, self.child.platform, self.child.zone_id)
    local index = 4
    if childNoviceData ~= nil then
        index = childNoviceData.lev
    else
        index = 4
    end
    self:OnSelectRemind(index)

    if PetManager.Instance.model:CheckChildCanFollow() then
        local child = PetManager.Instance.model.currChild
        ChildrenManager.Instance:Require18624(child.child_id, child.platform, child.zone_id, ChildrenEumn.Status.Follow)
    end
end

function PetChildFeedView:OnChange()
end

function PetChildFeedView:OnDesc()
    TipsManager.Instance:ShowText( { gameObject = self.DescButton.gameObject, itemData = self.TipsData })
end

function PetChildFeedView:Update()
    self:UpdateInfo()
    self:UpdateAttr()
    self:UpdateItems()
    self:UpdateHappiness()
end

function PetChildFeedView:UpdateInfo()
    self.base = DataChild.data_child[self.child.base_id]
    self.name.text = self.child.name
    self.lev.text = string.format(TI18N("等级:%s"), self.child.lev)
    self.headImg.sprite = self.assetWrapper:GetSprite(AssetConfig.childhead, self.base.head_id)
    self.headImgRect.sizeDelta = Vector2(54, 54)
end

function PetChildFeedView:UpdateAttr()
    self.fullVal.text = string.format("%s/%s", self.child.hungry, 100)
    self.fullSlider.value = self.child.hungry / 100
    self.phyAtk.text = string.format("%s/%s", self.child.phy_aptitude, self.child.max_phy_aptitude)
    self.phyDef.text = string.format("%s/%s", self.child.pdef_aptitude, self.child.max_pdef_aptitude)
    self.hp.text = string.format("%s/%s", self.child.hp_aptitude, self.child.max_hp_aptitude)
    self.mag.text = string.format("%s/%s", self.child.magic_aptitude, self.child.max_magic_aptitude)
    self.speed.text = string.format("%s/%s", self.child.aspd_aptitude, self.child.max_aspd_aptitude)

    self.growhVal.text = string.format("%.2f", self.child.growth / 500)
    self.growhImg.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", self.child.growth_type))
   local  curHappData = ChildrenManager.Instance:GetHappinessByHugry(self.child.hungry)
      if curHappData ~= nil then
        if curHappData.happiness < 4 then
            self.sliderFillImg.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures,"ProgressBarY")
        else
            self.sliderFillImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ProgressBar1")
        end
         self.fullVal.text = string.format("%s/%s（%s）", self.child.hungry, 100,ChildrenEumn.ChildHappinessTitle[curHappData.happiness])
    end
end

function PetChildFeedView:UpdateHappiness()
    local hungry = self.child.hungry
    local cur_data = ChildrenManager.Instance:GetHappinessByHugry(hungry)
    local next_data = nil
    if cur_data ~= nil then
        local statusStr = ""
        statusStr = string.format(TI18N("当前心情：<color='#ffff00'>%s</color>"), ChildrenEumn.ChildHappinessTitle[cur_data.happiness] .. "(" .. cur_data.min_val .. "-" .. cur_data.max_val .. ")")
        self.txt_status1.text = statusStr
        local nextHappy = cur_data.happiness + 1
        if nextHappy > 5 then
            nextHappy = 5
            statusStr = string.format(TI18N("激活以下效果："))
        else
            next_data = ChildrenManager.Instance.happyList[nextHappy]
            statusStr = string.format(TI18N("下级心情：<color='#ffff00'>%s</color>，%s"), ChildrenEumn.ChildHappinessTitle[next_data.happiness] .. "(" .. next_data.min_val .. "-" .. next_data.max_val .. ")", TI18N("激活以下效果："))
        end
        self.txt_status2.text = statusStr
        local addAttr = cur_data.skill_prac
        for key, item in ipairs(self.item_list) do
            local attr_data = { }
            attr_data.skill_id = addAttr[key][1]
            attr_data.val = addAttr[key][2]
            attr_data.upval = 0
            if next_data ~= nil then
                attr_data.upval = next_data.skill_prac[key][2] - addAttr[key][2]
            end
            self:SetAttrItem(item, attr_data)
        end
    end
end

function PetChildFeedView:UpdateItems()
    self:update_item_volumn()
    self:update_use_items()
end

-- 更新可使用的物品数量
function PetChildFeedView:update_item_volumn()
    self.itemdata_list = { }
    local item_data_by_baseid = nil
    local item = nil

    for i = 1, #self.defualt_item_list do
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

    local items = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.childTelent)
    for i, v in ipairs(items) do
        if not table.containValue(self.defualt_item_list, v.base_id) then
            table.insert(self.itemdata_list, v)
        end
    end
    local items = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.childGrowth)
    for i, v in ipairs(items) do
        if not table.containValue(self.defualt_item_list, v.base_id) then
            table.insert(self.itemdata_list, v)
        end
    end
    items = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.childFood)
    for i, v in ipairs(items) do
        if not table.containValue(self.defualt_item_list, v.base_id) then
            table.insert(self.itemdata_list, v)
        end
    end
    items = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.childPoint)
    for i, v in ipairs(items) do
        if not table.containValue(self.defualt_item_list, v.base_id) then
            table.insert(self.itemdata_list, v)
        end
    end
end

-- 更新道具
function PetChildFeedView:update_use_items()
    local page_count = math.ceil(#self.itemdata_list / self.each_count)

    for i, item in ipairs(self.itemdata_list) do
        local solt = self.item_table[i]
        if solt == nil then
            local page = self.page_table[math.ceil(i / self.each_count)]
            if page == nil then
                page = GameObject.Instantiate(self.page_base_obj)
                table.insert(self.page_table, page)
                UIUtils.AddUIChild(self.page_content_obj, page)
            end
            solt = ItemSlot.New()
            solt.clickSelfFunc = function(item_data)
                local tab = 1
                if item_data.type == BackpackEumn.ItemType.childFood then
                    tab = 2
                end
                self.tabGroup:ChangeTab(tab)
            end
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
            local extra = { inbag = false, white_list = { { id = 1, show = true }, { id = 10, show = false } } }
            solt:SetAll(item, extra)
            solt:SetGrey(false)
        else
            local extra = { inbag = false, white_list = { { id = 1, show = false }, { id = 2, show = true }, { id = 10, show = false } } }
            solt:SetAll(item, extra)
            solt:SetGrey(true)
        end
    end

    local show_solt_num = #self.itemdata_list
    if #self.itemdata_list % self.each_count ~= 0 then
        show_solt_num = math.floor(#self.itemdata_list / self.each_count + 1) * self.each_count
        for i = #self.itemdata_list + 1, show_solt_num do
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
            solt:Default()
        end
    end

    for i = show_solt_num + 1, #self.item_table do
        local solt = self.item_table[i]
        solt.gameObject:SetActive(false)
    end

    if self.page_count ~= page_count then
        self.tabbedPanel:SetPageCount(page_count)
        self.page_count = page_count
    end
end

function PetChildFeedView:OnMoveEnd(currentPage, direction)
    for _, toggle in ipairs(self.toggleList) do
        toggle.isOn = false
    end
    self.toggleList[currentPage].isOn = true
end

-- 设置属性Item
function PetChildFeedView:SetAttrItem(item, data)
    -- local ImgIcon = item.transform:Find("icon"):GetComponent(Image)
    local TxtName = item.transform:Find("txt_attr"):GetComponent(Text)
    local UpObj = item.transform:Find("UpImg").gameObject
    local UpTxt = item.transform:Find("UpImg/Text"):GetComponent(Text)
    local skillData = DataSkillPrac.data_skill[data.skill_id]
    local upStr = data.val
     if data.val >= 0 then
        upStr = "+"..data.val
    end
    TxtName.text = string.format("%s <color='#ffff00'>%s</color>", skillData.name, upStr)
    -- local iconStr = string.format("AttrIcon%s", skillData.ico)
    -- ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, iconStr)
    local upStr = data.upval
    if data.upval > 0 then
        upStr = "+"..data.upval
    end
    UpTxt.text = upStr
    UpObj:SetActive(data.upval > 0)
end

function PetChildFeedView:OnSelectRemind(index)
    index = index or 4
    local title = ChildrenEumn.ChildRemindTitle[index]
    self.txt_remind.text = title
end

function PetChildFeedView:OnSelectClick(index)
    self:OnSelectRemind(index)
    self:SendRemind(index)
    self.selectPanel.gameObject:SetActive(false)
end

function PetChildFeedView:SendRemind(index)
    ChildrenManager.Instance:SendChangeRemind(self.child.child_id, self.child.platform, self.child.zone_id, index)
end

function PetChildFeedView:ChangeTab(index)
    self.attrsPanl.gameObject:SetActive(index == 1)
    self.statusPanl.gameObject:SetActive(index == 2)
end

function PetChildFeedView:OnStatusAttrClick(index)
    local itemData = ""
    if index == 1 then
        itemData = {TI18N("每级可使子女造成伤害增加<color='#b031d5'>3%+15</color>，提升控制成功率<color='#b031d5'>3%</color>")}
        elseif index == 2 then
        itemData = {TI18N("每级可使子女受到物理伤害减少<color='#b031d5'>3%+15</color>")}
        else
        itemData = {TI18N("每级可使子女受到魔法伤害减少<color='#b031d5'>3%+15</color>，提升抗控制率<color='#b031d5'>3%</color>")}
    end
    TipsManager.Instance:ShowText(
        {gameObject = self.item_list[index].gameObject,itemData = itemData})
end
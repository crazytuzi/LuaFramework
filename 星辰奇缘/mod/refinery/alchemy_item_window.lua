AlchemyItemWindow  =  AlchemyItemWindow or BaseClass(BasePanel)

function AlchemyItemWindow:__init(model)
    self.name  =  "AlchemyItemWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.alchemy_item_window, type  =  AssetType.Main},
        {file = AssetConfig.slotbg, type = AssetType.Dep},
    }

    self.windowId = WindowConfig.WinID.alchemy_item_window
    self.pageInitedList = {false, false, false, false, false}

    self.SingleRefinery_Num_Dic = {}
    self.slot_dic = {}

    self.loadItemCount = 0
    self.has_init = false

    self.has_select_power_stone_tips = false

    self.loaders = {}

    return self
end

function AlchemyItemWindow:__delete()
    if self.right_top_slot ~= nil then
        self.right_top_slot:DeleteMe()
        self.right_top_slot = nil
    end

    for _, v in pairs(self.loaders) do
        v:DeleteMe()
    end
    self.loaders = {}

    if self.slot_dic ~= nil then
        for k, v in pairs(self.slot_dic) do
            v:DeleteMe()
        end
    end

    self.has_init = false

    self.SingleRefinery_Num_Dic = nil
    self.slot_dic = nil

    self.posToOrder = nil
    self.posToNumber = nil
    self.backpackIdToPos = nil
    self.sellBackpackIdList = nil
    self.posToBackpackId = nil

    self.OnHideEvent:Fire()
    if self.boxXLayout ~= nil then
        self.boxXLayout:DeleteMe()
        self.boxXLayout = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.OnOpenEvent:Remove(self.openListener)
    self.OnHideEvent:Remove(self.hideListener)
    self:AssetClearAll()
end

function AlchemyItemWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.alchemy_item_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "AlchemyItemWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.transform:GetComponent(RectTransform).localPosition = Vector3(0, 0, -305)

    self.mainCon = self.transform:Find("Main")
    local closeBtn = self.mainCon:Find("CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseLianhuUI()
    end)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseLianhuUI() end)


    self.sellPanel = self.mainCon:Find("SellPanel")
    self.infoPanel = self.mainCon:Find("InfoPanel")
    self.nameText = self.infoPanel:Find("NameText"):GetComponent(Text)
    self.useText = self.infoPanel:Find("DescText"):GetComponent(Text)
    self.descText2_temp = self.infoPanel:Find("DescText2"):GetComponent(Text)
    self.descText2 = MsgItemExt.New(self.descText2_temp, 270, 16, 23)
    self.ImgIconTop1 = self.infoPanel:Find("ImgIconTop1").gameObject
    self.descText3 = self.infoPanel:Find("DescText3"):GetComponent(Text)
    self.ImgIconTop2 = self.infoPanel:Find("ImgIconTop2").gameObject
    self.ImgIcon3 = self.infoPanel:Find("ImgIcon3").gameObject
    self.ImgIcon4 = self.infoPanel:Find("ImgIcon4").gameObject

    local instanceID = self.ImgIconTop1:GetInstanceID()
    local loader = self.loaders[instanceID]
    if loader == nil then
        loader = SingleIconLoader.New(self.ImgIconTop1.gameObject)
        self.loaders[instanceID] = loader
    end
    loader:SetSprite(SingleIconType.Item, 90017)

    instanceID = self.ImgIconTop2:GetInstanceID()
    loader = self.loaders[instanceID]
    if loader == nil then
        loader = SingleIconLoader.New(self.ImgIconTop2.gameObject)
        self.loaders[instanceID] = loader
    end
    loader:SetSprite(SingleIconType.Item, 90017)

    instanceID = self.ImgIcon3:GetInstanceID()
    loader = self.loaders[instanceID]
    if loader == nil then
        loader = SingleIconLoader.New(self.ImgIcon3.gameObject)
        self.loaders[instanceID] = loader
    end
    loader:SetSprite(SingleIconType.Item, 90017)

    instanceID = self.ImgIcon4:GetInstanceID()
    loader = self.loaders[instanceID]
    if loader == nil then
        loader = SingleIconLoader.New(self.ImgIcon4.gameObject)
        self.loaders[instanceID] = loader
    end
    loader:SetSprite(SingleIconType.Item, 90017)

    self.numObj = self.infoPanel:Find("NumObject")
    self.numText = self.numObj:Find("NumBg/Value"):GetComponent(Text)
    self.addBtn = self.numObj:Find("PlusButton"):GetComponent(Button)
    self.minusBtn = self.numObj:Find("MinusButton"):GetComponent(Button)
    self.SingleRefineryTxt = self.infoPanel:Find("SingleRefineryTxt"):GetComponent(Text)
    self.RefineryAfterTxt = self.infoPanel:Find("RefineryAfterTxt"):GetComponent(Text)

    self.OnePressButton = self.infoPanel:FindChild("OnePressButton"):GetComponent(Button)
    self.infoPanel:Find("OnePressButton/Text"):GetComponent(Text).text = TI18N("30     兑换")
    self.LianHuaBtn = self.infoPanel:Find("PutButton"):GetComponent(Button)
    self.LianHuaBtnTxt = self.infoPanel:Find("PutButton/Text"):GetComponent(Text)
    self.sellScrollRect = self.sellPanel:Find("ScrollView"):GetComponent(ScrollRect)
    self.sellPanel:Find("ScrollView/Container/ItemPage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.slotbg, "SlotBg")
    self.itemPageTemplate = self.sellPanel:Find("ScrollView/Container/ItemPage").gameObject-- 分页模板

    self.blue_img = self.OnePressButton.image.sprite
    self.green_img = self.LianHuaBtn.image.sprite


    self.SingleRefineryTxt.text = "<color='#ffff00'>0</color>"
    self.RefineryAfterTxt.text = "<color='#ffff00'>0</color>"

    -- 初始化各自布局排版
    local setting = {
        axis = BoxLayoutAxis.X
        ,spacing = 20
    }
    self.boxXLayout = LuaBoxLayout.New(self.sellPanel:Find("ScrollView/Container").gameObject, setting)
    self.itemPageTemplate:SetActive(false)

    self.pageObjList = {}
    -- 生成分页
    for i=1,5 do
        local itemPage = GameObject.Instantiate(self.itemPageTemplate)
        itemPage.name = "itemPage"..i
        self.pageObjList[i] = itemPage
        self.boxXLayout:AddCell(itemPage)
        itemPage.transform.localScale = Vector3.one
    end
    self.tabbedPanel = TabbedPanel.New(self.sellScrollRect.gameObject, 5, 350)
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnMoveEnd(currentPage, direction) end)

    self.toggleList = {nil, nil, nil, nil, nil}
    for i=1,5 do
        self.toggleList[i] = self.sellPanel:Find("ToggleGroup"):Find("Toggle"..i):GetComponent(Toggle)
        self.toggleList[i].isOn = false
    end
    self.toggleList[1].isOn = true

    --右边逻辑
    self.right_top_slot = ItemSlot.New()
    NumberpadPanel.AddUIChild(self.infoPanel:Find("Item"), self.right_top_slot.gameObject)

    --初始化数据
    local allItemDic = BackpackManager.Instance.itemDic
    self.itemDic = {}-- pos 为key
    local c = 1
    for k,v in pairs(allItemDic) do
        if v.alchemy ~= 0 and v.alchemy ~= nil then
            self.itemDic[c] = v
            c = c + 1
        end
    end

    --注册监听器
    self.addBtn.onClick:AddListener(function()
        self:On_addBtn_click()
    end)

    self.minusBtn.onClick:AddListener(function()
        self:On_minusBtn_click()
    end)

    self.LianHuaBtn.onClick:AddListener(function()
        local _list = {}
        for k, v in pairs(self.SingleRefinery_Num_Dic) do
            local infodata = self.itemDic[k]
            -- table.insert(_list, {id= infodata.base_id, num = v.buy_num})
            table.insert(_list, {id= infodata.id, num = v.buy_num})
        end
        if #_list == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择炼化物品"))
        else
            if #_list == 1 then
                AlchemyManager.Instance:request14904(_list)
            else
                local selected_list = {}
                for k, v in pairs(self.SingleRefinery_Num_Dic) do
                    local infodata = self.itemDic[k]
                    table.insert(selected_list, {id= infodata.base_id, num = v.buy_num, itemData = infodata})
                end
                self.model.confirm_data = {}
                self.model.confirm_data.selected_list = selected_list
                self.model.confirm_data.sureCallback = function()
                    AlchemyManager.Instance:request14904(_list)
                end
                self.model:InitLianhuaConfirmUI()
            end
        end
    end)

    self.OnePressButton.onClick:AddListener(function()
        if AlchemyManager.Instance.has_tips_cost == false then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.showClose = 1
            data.content = TI18N("消耗<color='FFFF00'>30</color>{assets_2, 90002}兑换<color='FFFF00'>100</color>{assets_2, 90017}")
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                AlchemyManager.Instance:request14905(1)
            end
            NoticeManager.Instance:ConfirmTips(data)
            AlchemyManager.Instance.has_tips_cost = true
        else
            AlchemyManager.Instance:request14905(1)
        end
    end)


    self:update_view()
end

----------------------------事件监听逻辑

--点击加号按钮
function AlchemyItemWindow:On_addBtn_click()
    local lastSelectPos = self.model.lastSelectPos
    if lastSelectPos == nil or lastSelectPos == 0 then
        return
    end
    local infodata = self.itemDic[lastSelectPos]
    local num = tonumber(self.numText.text)
    if num < infodata.quantity then
        num = num + 1
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("没有更多了"))
    end
    self.posToNumber[lastSelectPos] = num
    self.numText.text = tostring(num)
    self.SingleRefinery_Num_Dic[tonumber(lastSelectPos)].buy_num = num

    self.RefineryAfterTxt.text = "<color='#ffff00'>0</color>"
    local Refinery_Num = 0
    for k, v in pairs(self.SingleRefinery_Num_Dic) do
        if v ~= nil then
            Refinery_Num = Refinery_Num + self:count_item_aclhemy_val(self.itemDic[k], v.buy_num)
        end
    end
    if Refinery_Num > 0 then
        self.RefineryAfterTxt.text = string.format("<color='#ffff00'>%s</color>", Refinery_Num)
    end

    self.SingleRefineryTxt.text = string.format("<color='#ffff00'>%s</color>", self:count_item_aclhemy_val(self.itemDic[tonumber(lastSelectPos)], num))--self.itemDic[tonumber(lastSelectPos)].alchemy*num)

    if self.itemDic[lastSelectPos].quantity > 1 then
        local slot = self.slot_dic[lastSelectPos]
        slot:SetNum(num,self.itemDic[lastSelectPos].quantity, true)
    end
end

--点击减号按钮
function AlchemyItemWindow:On_minusBtn_click()
    local lastSelectPos = self.model.lastSelectPos
    if lastSelectPos == nil or lastSelectPos == 0 then
        return
    end
    local infodata = self.itemDic[lastSelectPos]
    local num = tonumber(self.numText.text)
    if num > 1 then
        num = num - 1
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("最少炼化一个物品"))
    end
    self.posToNumber[lastSelectPos] = num
    self.numText.text = tostring(num)

    self.SingleRefinery_Num_Dic[tonumber(lastSelectPos)].buy_num = num

    self.RefineryAfterTxt.text = "<color='#ffff00'>0</color>"
    local Refinery_Num = 0
    for k, v in pairs(self.SingleRefinery_Num_Dic) do
        if v ~= nil then
            Refinery_Num = Refinery_Num + self:count_item_aclhemy_val(self.itemDic[k], v.buy_num)
        end
    end
    if Refinery_Num > 0 then
        self.RefineryAfterTxt.text = string.format("<color='#ffff00'>%s</color>", Refinery_Num)
    end

    self.SingleRefineryTxt.text = string.format("<color='#ffff00'>%s</color>", self:count_item_aclhemy_val(self.itemDic[tonumber(lastSelectPos)], num))--self.itemDic[tonumber(lastSelectPos)].alchemy*num)

    if self.itemDic[lastSelectPos].quantity > 1 then
        local slot = self.slot_dic[lastSelectPos]
        slot:SetNum(num, self.itemDic[lastSelectPos].quantity, true)
    end
end

function AlchemyItemWindow:On_SelectItem(item)

    local theId = tonumber(item.name)
    local id = self.posToBackpackId[theId]

    local base_id = self.itemDic[theId].base_id
    if BackpackManager.Instance:GetPreciousItem(base_id) then 
        local itemData = DataItem.data_get[base_id]
        local str = ColorHelper.color_item_name(itemData.quality ,string.format("[%s]", itemData.name))
        local str2 = string.format("%s<color='#ffff00'>1</color>%s<color='#ffff00'>%s</color>{assets_2, 90017}", TI18N("炼化"), TI18N("个可获得"), itemData.alchemy)
        local confirm_dat = {
            titleTop = TI18N("贵重物品")
            , title = string.format( "%s%s,<color='#df3435'>%s</color>,%s", str, TI18N("十分珍贵"), TI18N("炼化后无法找回"), str2)
            , password = TI18N(tostring(math.random(100, 999)))
            , confirm_str = TI18N("炼 化")
            , cancel_str = TI18N("取 消")
            , confirm_callback = function() 
                AlchemyManager.Instance:request14904({{id = id, num = 1}}) 
            end
        }
        TipsManager.Instance.model:OpentwiceConfirmPanel(confirm_dat)
        return
    end

    -- 确定当前选中的item的选中顺序
    if self.model.lastSelectPos == nil then      -- 首次选中
        self:UpdateItemSelectState(item, true)
        self.model.lastSelectPos = theId
        self.posToOrder[theId] = self.model.sellSelectOrder
        self.model.sellSelectOrder = self.model.sellSelectOrder + 1
        self.model.sellSelectNum = 1
    else
        if self.model.lastSelectPos == 0 then
            self:UpdateItemSelectState(item, true)
            self.model.lastSelectPos = theId
            self.posToOrder[theId] = self.model.sellSelectOrder
            self.model.sellSelectOrder = self.model.sellSelectOrder + 1
            self.model.sellSelectNum = self.model.sellSelectNum + 1
        elseif self.posToOrder[theId] == nil then      -- 点击未选中的物品
            self:UpdateItemSelectState(item, true)
            self.posToOrder[theId] = self.model.sellSelectOrder
            self.model.sellSelectOrder = self.model.sellSelectOrder + 1
            self.model.lastSelectPos = theId
            self.model.sellSelectNum = self.model.sellSelectNum + 1
        else                                        -- 点击已选中的物品，即取消选择
            self:UpdateItemSelectState(item, false)
            self.posToOrder[theId] = nil
            local lastSelectId = 0
            for k,v in pairs(self.posToOrder) do
                if v ~= nil then
                    if self.posToOrder[k] > self.posToOrder[lastSelectId] then
                        lastSelectId = k
                    end
                end
            end
            self.model.lastSelectPos = lastSelectId
            self.model.sellSelectNum = self.model.sellSelectNum - 1
        end
    end

    self.RefineryAfterTxt.text = "<color='#ffff00'>0</color>"
    local Refinery_Num = 0
    for k, v in pairs(self.SingleRefinery_Num_Dic) do
        if v ~= nil then
            Refinery_Num = Refinery_Num + self:count_item_aclhemy_val(self.itemDic[k], self.itemDic[k].quantity)
        end
    end
    if Refinery_Num > 0 then
        self.RefineryAfterTxt.text = string.format("<color='#ffff00'>%s</color>", Refinery_Num)
    end

    self:UpdateInfoPanel()
end


---------------------------------各种更新界面逻辑
function AlchemyItemWindow:update_view()

    self.loadItemCount = 0
    self.model.lastSelectPos = nil
    self.posToNumber = {}      -- 上架对应id商品的数量
    self.model.posToPercent = {}  -- 上架对应id商品的调价百分比
    self.backpackIdToPos = {}   -- 上架对应商品的cell_id
    self.sellBackpackIdList = {}
    self.posToOrder = {}   -- 选中的物品列表，key=物品pos，value=点击顺序
    self.posToOrder[0] = 0 -- 辅助
    self.model.sellSelectOrder = 1   -- 选中顺序
    self.model.lastSelectPos = nil    -- 最后选中物品的id（窗格id，不是base_id）
    self.model.sellSelectNum = 0         -- 选中的item数目
    self.maxSelectableNum = 0
    self.posToBackpackId = {}
    self.posToOrder[0] = 0
    self.model.sellSelectOrder = 1

    for i=1,#self.itemDic do
        if self.itemDic[i].id == self.model.targetBaseId then    -- 此处targetBaseid是背包唯一id，非basd_id
            self.model.lastSelectPos = i
            break
        end
    end

    if self.model.sellCellItem ~= nil then
        for i=1, #self.model.sellCellItem do
            if self.model.sellCellItem[i].item_base_id == nil then
                self.maxSelectableNum = self.maxSelectableNum + 1
            end
        end
    end

    local currentPage = 1
    if self.model.lastSelectPos ~= nil then
        currentPage = math.ceil(self.model.lastSelectPos / 25)
    end
    self:InitDataPanel(currentPage - 1)
    self:InitDataPanel(currentPage)
    self:InitDataPanel(currentPage + 1)
    self:UpdateInfoPanel()
end

function AlchemyItemWindow:UpdateItemSelectState(item, bool)
    item.transform:Find("Select").gameObject:SetActive(bool)
    if bool then
        self.SingleRefinery_Num_Dic[tonumber(item.name)] = {}
        self.SingleRefinery_Num_Dic[tonumber(item.name)].buy_num = self.itemDic[tonumber(item.name)].quantity
    else
        self.SingleRefinery_Num_Dic[tonumber(item.name)] = nil
    end
end

function AlchemyItemWindow:UpdateInfoPanel()

    local lastSelectId = self.model.lastSelectPos

    self.ImgIconTop1.gameObject:SetActive(false)
        self.ImgIconTop2.gameObject:SetActive(false)
    if lastSelectId == nil or lastSelectId == 0 then
        self.LianHuaBtn.image.sprite = self.blue_img
        self.LianHuaBtnTxt.color = ColorHelper.DefaultButton1
        self.nameText.text = ""
        self.useText.text = ""
        self.descText2:SetData(TI18N("请点击左侧的物品，选择多个物品可批量炼化"))
        self.ImgIconTop1.gameObject:SetActive(false)
        self.ImgIconTop2.gameObject:SetActive(false)
        self.descText3.text = ""
        self.numText.text = "0"
        self.SingleRefineryTxt.text = "<color='#ffff00'>0</color>"
        if self.right_top_slot~= nil then
            self.right_top_slot.gameObject:SetActive(false)
        end

    else
        self.LianHuaBtn.image.sprite = self.green_img
        self.LianHuaBtnTxt.color = ColorHelper.DefaultButton3
        local itemData = BackpackManager.Instance.itemDic[self.posToBackpackId[lastSelectId]]
        local basedata = DataItem.data_get[itemData.base_id]

        self.SingleRefineryTxt.text = "<color='#ffff00'>0</color>"
        if basedata.alchemy > 0 then
            self.SingleRefineryTxt.text = string.format("<color='#ffff00'>%s</color>", self:count_item_aclhemy_val(itemData, itemData.quantity))-- basedata.alchemy*itemData.quantity)
        end

        local item_name = basedata.name
        if itemData.step ~= 0 then item_name = string.format("%s Lv.%s", item_name, itemData.step) end
        -- item_text.text = utils.color_item_name(basedata.quality, item_name)

        local ddesc = basedata.desc
        local time_limit_text = ""
        local fudai_skill = ""
        if itemData.step ~= nil and itemData.step ~= 0 then
            time_limit_text = string.format(TI18N("品阶:%s"), itemData.step)
            local step_data = DataSkillLife.data_fight_effect[string.format("%s_%s", basedata.id, itemData.step)]
            if step_data ~= nil then
                ddesc = string.gsub(ddesc, "%[skill_life1%]", tostring(step_data.args[1]))
                ddesc = string.gsub(ddesc, "%[skill_life2%]", tostring(step_data.args[2]))
            else
                ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
                ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
            end
        else
            time_limit_text = ""
            ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
        end

        local height = 0
        local strs = {}
        for s1, s2 in string.gmatch(ddesc, "(.+);(.+)") do
            strs = {s1, s2}
        end

        self.nameText.text = item_name
        self.useText.text = string.format(TI18N("作用:%s"), basedata.func)

        if #strs == 0 then
            if time_limit_text ~= "" then
                fudai_skill = string.format("<color='#ACE92A'>%s</color>", time_limit_text)
            end
        else
            ddesc = strs[1]
            fudai_skill = strs[2]
        end

        --附带技能
        local skill_str = ""
        for k,v in pairs(itemData.attr) do
            if v.type == GlobalEumn.ItemAttrType.base then
                if v.name == KvData.attrname_skill then
                    skill_str = skill_str..string.format("<color='#00ff00'>[%s]</color>", DataSkill.data_petSkill[string.format("%s_1", v.val)].name)
                end
            end
        end
        if skill_str ~= "" then
            fudai_skill = string.format(TI18N("<color='#BCBDBD'>附带技能:</color> %s"), skill_str)
        end
        ddesc = string.format("%s。%s", ddesc, fudai_skill)
        ddesc = string.gsub(ddesc, "<.->", "")
        self.descText2:SetData(ddesc)
        self.descText2_temp.gameObject:SetActive(true)
        self.numText.text = tostring(self.posToNumber[lastSelectId])


        self.right_top_slot.gameObject:SetActive(true)
        self.right_top_slot:SetAll(itemData, self.extra)
    end
end


---------------------------------翻页逻辑
-- 获取下一个空cell
function AlchemyItemWindow:GetNextEmptyCell(begin)
    local cellItemList = self.model.sellCellItem
    local pos
    for i=begin + 1,#cellItemList do
        if cellItemList[i].cell_id == nil then
            pos = i
            break
        end
    end
    return pos
end

function AlchemyItemWindow:InitDataPanel(index)
    if index < 1 or index > math.ceil(#self.itemDic / 25) then
        return
    end
    print("初始化面板："..tostring(index))
    local t = self.pageObjList[index].transform

    for i=1,25 do
        local go = t:GetChild(i-1).gameObject
        if go ~= nil then
            go.transform:Find("Select").gameObject:SetActive(false)
            go:SetActive(false)
        end
    end

    local has_first_selected = false
    for i=1,25 do
        self.loadItemCount = self.loadItemCount + 1
        if self.loadItemCount > #self.itemDic then
            break
        end

        local basedata = DataItem.data_get[self.itemDic[self.loadItemCount].base_id]
        local go = t:GetChild(i-1).gameObject
        go.transform:Find("Slot"):GetComponent(Image).color = Color(0, 0, 0, 0)
        go.transform:Find("Num").gameObject:SetActive(false)

        if go.transform:Find("ItemSlot") ~= nil then
            GameObject.DestroyImmediate(go.transform:Find("ItemSlot").gameObject)
        end

        local slot = ItemSlot.New()
        local itemdata = ItemData.New()
        itemdata:SetBase(basedata)
        NumberpadPanel.AddUIChild(go.transform, slot.gameObject)
        slot:SetAll(itemdata, {inbag = true, nobutton = true})
        slot:SetNum(self.itemDic[self.loadItemCount].quantity,self.itemDic[self.loadItemCount].quantity, true)


        slot.gameObject.transform:SetAsFirstSibling()
        self.slot_dic[self.loadItemCount] = slot

        local btn = go:GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function ()
            self:On_SelectItem(go)
        end)
        go:SetActive(true)
        go.name = tostring(self.loadItemCount)
        self.posToBackpackId[self.loadItemCount] = self.itemDic[self.loadItemCount].id
        self.model.posToPercent[self.loadItemCount] = 100
        self.posToNumber[self.loadItemCount] = self.itemDic[self.loadItemCount].quantity

        if basedata.id == 22210 or basedata.id == 22211 then
            has_first_selected = true
            self:On_SelectItem(go)
        end
    end
    self.pageInitedList[index] = true
    -- if t:Find(tostring(self.model.lastSelectPos)) ~= nil then
    --     self:On_SelectItem(t:Find(tostring(self.model.lastSelectPos)).gameObject)
    -- end


    if has_first_selected then
        if self.has_select_power_stone_tips == false then
            NoticeManager.Instance:FloatTipsByString(TI18N("已自动选中<color='#ffff00'>能量石</color>道具"))
            self.has_select_power_stone_tips = true
        end
    end
end

function AlchemyItemWindow:OnMoveEnd(currentPage, direction)
    if direction == LuaDirection.Left then
        self.toggleList[currentPage - 1].isOn = false
        self.toggleList[currentPage].isOn = true
        if currentPage < 5 then
            if currentPage > 1 and self.pageInitedList[currentPage + 1] == false then
                self:InitDataPanel(currentPage + 1)
            end
        end
    elseif direction == LuaDirection.Right then
        self.toggleList[currentPage + 1].isOn = false
        self.toggleList[currentPage].isOn = true
    end
end

--计算传入的道具的可炼化值
function AlchemyItemWindow:count_item_aclhemy_val(info, num)
    local alchemy_num = 0
    if info.type == BackpackEumn.ItemType.limit_fruit then
        local currTime = 0
        local maxTime = DataItem.data_fruit[tonumber(info.base_id)].num
        -- 限量果实显示使用次数
        for k,v in pairs(info.extra) do
            if v.name == BackpackEumn.ExtraName.fruit_time then
                currTime = v.value
            end
        end
        if currTime == 0 then
            currTime = maxTime
        end
        currTime = math.max(currTime, 1)
        alchemy_num = math.ceil(num*info.alchemy*(currTime/maxTime))
    else
        alchemy_num = num*info.alchemy
    end
    return alchemy_num
end


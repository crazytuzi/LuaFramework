-- ------------------------------
-- 幻化果实tips对应幻化功能
-- hosr
-- ------------------------------
FruitTipsNew = FruitTipsNew or BaseClass(BaseTips)

function FruitTipsNew:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_fruit_new, type = AssetType.Main}
    }
    self.mgr = TipsManager.Instance
    self.width = 315
    self.height = 20
    self.buttons = {}
    self.DefaultSize = Vector2(315, 0)

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)

    self.maxMidHeight = 230
    self.extraDesc = ""
end

function FruitTipsNew:__delete()
    if self.itemCell ~= nil then
        self.itemCell:DeleteMe()
        self.itemCell = nil
    end
    self.mgr = nil
    self.buttons = {}
    self.height = 20
    self:RemoveTime()
end

function FruitTipsNew:RemoveTime()
    self.mgr.updateCall = nil
end

function FruitTipsNew:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_fruit_new))
    self.gameObject.name = "FruitTipsNew"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self.model:Closetips() end)

    self.rect = self.gameObject:GetComponent(RectTransform)

    local head = self.transform:Find("HeadArea")
    self.itemCell = ItemSlot.New(head:Find("ItemSlot").gameObject)
    self.itemCell:SetNotips()
    self.itemCell:ShowEnchant(true)
    self.nameTxt = head:Find("Name"):GetComponent(Text)
    self.typeTxt = head:Find("Type"):GetComponent(Text)
    self.bindObj = head:Find("Bind").gameObject

    local mid = self.transform:Find("MidArea")
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.scroll = mid:GetComponent(ScrollRect)
    self.containerRect = mid:Find("Container"):GetComponent(RectTransform)
    self.midLine = mid:Find("Container/Line").gameObject
    self.extarTypeTxt = mid:Find("Container/Type"):GetComponent(Text)
    self.extarTypeTxtRect = self.extarTypeTxt.gameObject:GetComponent(RectTransform)
    self.descTxt = mid:Find("Container/Desc"):GetComponent(Text)
    self.midLineRect = self.midLine:GetComponent(RectTransform)
    self.attrContainer = mid:Find("Container/Attr1").gameObject
    self.attrTxt = self.attrContainer:GetComponent(Text)
    self.attrRect = self.attrContainer:GetComponent(RectTransform)

    self.skillContainer = mid:Find("Container/Attr2").gameObject
    self.skillTxt = self.skillContainer:GetComponent(Text)
    self.skillRect = self.skillContainer:GetComponent(RectTransform)

    self.eqmBaseTxt = mid:Find("Container/BaseText").gameObject
    self.eqmBaseTxt:SetActive(false)

    self.descRect = self.descTxt.gameObject:GetComponent(RectTransform)
    self.eqmRect = self.attrContainer:GetComponent(RectTransform)

    local bottom = self.transform:Find("BottomArea")
    self.bottomRect = bottom.gameObject:GetComponent(RectTransform)
    local use = bottom:Find("UseButton").gameObject
    local drop = bottom:Find("DropButtonOnly").gameObject
    local sell = bottom:Find("SellButton").gameObject
    local cons = bottom:Find("ConsignmentButton").gameObject
    local simth = bottom:Find("SmithButton").gameObject
    local ware = bottom:Find("WareButton").gameObject
    local merge = bottom:Find("MergeButton").gameObject
    local open = bottom:Find("OpenWindowButton").gameObject
    local remove = bottom:Find("RemoveButton").gameObject
    local discard = bottom:Find("DiscardButton").gameObject
    local petgemoff = bottom:Find("PetGemOffButton").gameObject
    local inStore = bottom:Find("InStoreButton").gameObject
    local outStore = bottom:Find("OutStoreButton").gameObject
    local petgemreplace = bottom:Find("PetGemReplaceButton").gameObject
    local LianhuaButton = bottom:Find("LianhuaButton").gameObject
    local combineButton = bottom:Find("CombineButton").gameObject

    self.sellBtnIcon = sell.transform:Find("Image"):GetComponent(Image)
    self.sellBtnTxt = sell.transform:Find("Text"):GetComponent(Text)
    self.opentxt = open.transform:Find("Text"):GetComponent(Text)

    use:GetComponent(Button).onClick:AddListener(function() self.model:Use(self.itemData) end)
    sell:GetComponent(Button).onClick:AddListener(function() self.model:Sell(self.itemData) end)
    cons:GetComponent(Button).onClick:AddListener(function() self.model:Sell(self.itemData) end)
    merge:GetComponent(Button).onClick:AddListener(function() self.model:Merge(self.itemData) end)
    open:GetComponent(Button).onClick:AddListener(function() self.model:Openwindow(self.openwindowid) end)
    discard:GetComponent(Button).onClick:AddListener(function() self.model:Discard(self.itemData) end)
    petgemoff:GetComponent(Button).onClick:AddListener(function() self.model:Pet_gem_off(self.itemData) end)
    inStore:GetComponent(Button).onClick:AddListener(function() self.model:InStore(self.itemData) end)
    outStore:GetComponent(Button).onClick:AddListener(function() self.model:OutStore(self.itemData) end)
    petgemreplace:GetComponent(Button).onClick:AddListener(function() self.model:Pet_gem_replace(self.itemData) end)
    LianhuaButton:GetComponent(Button).onClick:AddListener(function() self.model:Alchemy(self.itemData) end)
    combineButton:GetComponent(Button).onClick:AddListener(function() self.model:CombineFruit(self.itemData) end)

    self.buttons = {
        [TipsEumn.ButtonType.Use] = use
        ,[TipsEumn.ButtonType.Drop] = drop
        ,[TipsEumn.ButtonType.Sell] = sell
        ,[TipsEumn.ButtonType.Consigenment] = cons
        ,[TipsEumn.ButtonType.Smith] = simth
        ,[TipsEumn.ButtonType.Ware] = ware
        ,[TipsEumn.ButtonType.Merge] = merge
        ,[TipsEumn.ButtonType.Petgem_off] = pregem
        ,[TipsEumn.ButtonType.Remove] = remove
        ,[TipsEumn.ButtonType.Openwindow] = open
        ,[TipsEumn.ButtonType.Discard] = discard
        ,[TipsEumn.ButtonType.Petgemoff] = petgemoff
        ,[TipsEumn.ButtonType.InStore] = inStore
        ,[TipsEumn.ButtonType.OutStore] = outStore
        ,[TipsEumn.ButtonType.PetGemReplace] = petgemreplace
        ,[TipsEumn.ButtonType.AlchemyType] = LianhuaButton
        ,[TipsEumn.ButtonType.Combine] = combineButton
    }
end

function FruitTipsNew:UnRealUpdate()
    if Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Began then
        local v2 = Input.GetTouch(0).position
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end

    if Input.GetMouseButtonDown(0) then
        local v2 = Input.mousePosition
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end
end

function FruitTipsNew:Default()
    self.height = 20
    self.extraDesc = ""
    self.typeTxt.text = ""
    self.nameTxt.text = ""
    self.extarTypeTxt.text = ""
    self.descTxt.text = ""
    self.bindObj:SetActive(false)
    self.attrContainer:SetActive(false)
    self.skillContainer:SetActive(false)
    self.extarTypeTxt.gameObject:SetActive(false)

    for _,button in pairs(self.buttons) do
        button.gameObject:SetActive(false)
    end

    self.rect.sizeDelta = self.DefaultSize
end

-- ------------------------------------
-- 外部调用更新数据
-- 参数说明:
-- info = 道具数据
-- extra = 扩展参数
-- ---- inbag = 是否在背包
-- ---- nobutton = 是否不要任何按钮
-- ---- button_list = 自定义列表 {id,show}
-- ---- 注意，传人button_list就直接根据该列表处理，不做默认处理
-- ------------------------------------
function FruitTipsNew:UpdateInfo(info, extra)
    self:Default()

    self.itemData = info
    self.info_lev = 0
    if info.extra ~= nil then
        for k,v in pairs(info.extra) do
            if v.name == BackpackEumn.ExtraName.fruit_lev then
                self.info_lev = v.value
            end
        end
    end
    if self.info_lev == 0 then
        self.nameTxt.text = ColorHelper.color_item_name(info.quality, info.name)
    else
        local ext_name = info.name..string.format("+%s", self.info_lev)
        self.nameTxt.text = ColorHelper.color_item_name(info.quality, ext_name)
    end

    self.itemCell:SetAll(info)
    self.bindObj:SetActive(info.bind == 1)

    --加上上部分的高度
    self.height = self.height + 90

    local hh = 0
    local buffers = self:GetChangeBufferData(info)

    if self.extraDesc ~= "" then
        self.extarTypeTxt.gameObject:SetActive(true)
        hh = 30
    end
    self.fruitType = {}
    self.fruitType_index = {}
    local currTime = 0
    if info.type == BackpackEumn.ItemType.limit_fruit then
        -- 限量果实显示使用次数
        if info.extra ~= nil then
            local CSnum = nil
            for k,v in pairs(info.extra) do
                if v.name == BackpackEumn.ExtraName.fruit_time then
                    currTime = v.value
                elseif v.name == BackpackEumn.ExtraName.fruit_lev1_type then
                    CSnum = DataHandbook.data_base[self.fuseId]["lev_num1"]
                    self.fruitType[v.value] = {attr = v.value, val = CSnum}
                    table.insert(self.fruitType_index, v.value)
                elseif v.name == BackpackEumn.ExtraName.fruit_lev2_type then
                    CSnum = DataHandbook.data_base[self.fuseId]["lev_num2"]
                    if self.fruitType[v.value] ~= nil then
                        local num = self.fruitType[v.value].val + CSnum
                        self.fruitType[v.value].val = num
                    else
                        self.fruitType[v.value] = {attr = v.value, val = CSnum}
                        table.insert(self.fruitType_index, v.value)
                    end
                elseif v.name == BackpackEumn.ExtraName.fruit_lev3_type then
                    CSnum = DataHandbook.data_base[self.fuseId]["lev_num3"]
                    if self.fruitType[v.value] ~= nil then
                        local num = self.fruitType[v.value].val + CSnum
                        self.fruitType[v.value].val = num
                    else
                        self.fruitType[v.value] = {attr = v.value, val = CSnum}
                        table.insert(self.fruitType_index, v.value)
                    end
                end
            end
        end
        --BaseUtils.dump(info)
        local maxTime = DataItem.data_fruit[tonumber(info.base_id)].num
        if currTime == 0 then
            currTime = maxTime
        end
    end
    currTime = math.max(currTime, 1)
    if currTime > 1 then
    	self.extarTypeTxt.text = string.format(TI18N("%s\n剩余使用:<color='#ffff00'>%s次</color>"), self.extarTypeTxt.text, currTime)
    end
    local eh = self.extarTypeTxt.preferredHeight
    self.extarTypeTxtRect.sizeDelta = Vector2(250, eh)
    hh = eh

    if #buffers == nil then
        self.descTxt.text = info.desc
        self.descRect.anchoredPosition = Vector2(0, -hh)
        self.descRect.sizeDelta = Vector2(250, self.descTxt.preferredHeight)
        self.attrRect.anchoredPosition = Vector2(0, -hh - self.descTxt.preferredHeight - 10)
        -- 处理属性显示
        hh = hh + self:ParseAttribute(info.attr, false, hh)
    else
    	hh = self:AddBuff(buffers, hh)
    end


    local midHeight = self.descTxt.preferredHeight + 10 + hh
    self.containerRect.sizeDelta = Vector2(250, midHeight)
    self.scroll.enabled = false
    if midHeight >= self.maxMidHeight then
    	midHeight = self.maxMidHeight
    	self.scroll.enabled = true
    end
    self.midRect.sizeDelta = Vector2(250, midHeight)
    self.containerRect.anchoredPosition = Vector2.zero
    self.height = self.height + midHeight

    self.midLineRect.anchoredPosition = Vector2(0, -(self.descTxt.preferredHeight + hh + 20))
    -- 处理按钮
    self:ShowButton(info, extra)
    -- 加上底部间隔高度
    self.height = self.height + 40
    self.rect.sizeDelta = Vector2(self.width, self.height)

    self.mgr.updateCall = self.updateCall
end

function FruitTipsNew:AddBuff(buffers, hh)
	local isDescInit = false
	for i,v in ipairs(buffers) do
		local buffer = v.data
		if not isDescInit then
	        isDescInit = true
	        self.descTxt.text = buffer.desc
	        self.descRect.anchoredPosition = Vector2(0, -hh)
	        self.descRect.sizeDelta = Vector2(250, self.descTxt.preferredHeight)
		end
        -- 处理属性显示
        local nattr = {}
        for i,v in ipairs(buffer.attr) do
            table.insert(nattr, {name = v.attr_type, val = v.val})
        end
        if #buffer.attr_cli == 0 then
            for i,v in ipairs(buffer.effect) do
                if v.effect_type == 1 then
                    table.insert(nattr, {name = 100, val = v.val})
                end
            end
        else
            for i,v in ipairs(buffer.attr_cli) do
                if v.effect_type == 100 then
                    table.insert(nattr, {name = 100, val = v.val, showDesc = true})
                end
            end
        end
        
        if next(self.fruitType) ~= nil then
            if self.info_lev ~= 0 then
                for k,value in ipairs(self.fruitType_index) do
                    local j = self.fruitType[value]
                    --{attr = v.value, val = CSnum}
                    table.insert(nattr, {name = j.attr, val = j.val})
                end
            end
            --table.insert(self.fruitType,{name = 33, attr = 102})
        end
        hh = hh + self:ParseAttribute(nattr, v.varition, hh)
	end
	return hh
end

function FruitTipsNew:GetChangeBufferData(info)
	local list = {}
    for i,v in ipairs(info.effect) do
    	if v.effect_type == 52 then
            self.typeTxt.text = string.format(TI18N("类型:%s级幻化果"), tonumber(v.val[1][2]))
            self.extarTypeTxt.text = string.format(TI18N("需要幻化等级:<color='#ffff00'>%s级</color>"), tonumber(v.val[1][2]))
            self.extraDesc = string.format(TI18N("类型:%s级幻化果"), tonumber(v.val[1][2]))
            self.fuseId = v.val[1][1]  --对应幻化果id
            local handbook = DataHandbook.data_attr[string.format("%s_0", v.val[1][1])]
            table.insert(list, {data = DataBuff.data_list[handbook.buff], varition = false})
            if handbook.ratio > 0 then
            	-- 变异几率大于0才显示变异属性
            	table.insert(list, {data = DataBuff.data_list[handbook.varition_buff], varition = true})
            end
        end
    end
    return list
end

-- 处理属性显示
function FruitTipsNew:ParseAttribute(attr, varition, hh)
    local heqm = 0
	local container = self.attrContainer
	local rect = self.attrRect
	if varition then
		container = self.skillContainer
		rect = self.skillRect
	end
	rect.anchoredPosition = Vector2(0, -self.descTxt.preferredHeight - hh - 10)

    if #attr == 0 then
        attr = {{name = 0, val = 0}}
    end
    container:SetActive(false)
    local count1 = container.transform.childCount
    local count = 1
    for i,v in ipairs(attr) do
        container:SetActive(true)
        local txt = nil
        if i <= count1 then
            txt = container.transform:GetChild(i - 1).gameObject
        else
            txt = GameObject.Instantiate(self.eqmBaseTxt).gameObject
            txt.transform:SetParent(container.transform)
            txt.transform.localScale = Vector3.one
            txt:SetActive(true)
        end
        txt:GetComponent(Button).enabled = false
        if v.name == 0 then
            txt:GetComponent(Text).text = TI18N("<color='#00ffff'>无</color>")
            txt.transform.localPosition = Vector3(30, -20 - heqm, 0)
            txt:GetComponent(RectTransform).sizeDelta = Vector2(220, 25)
            heqm = heqm + 25
        elseif v.name == 100 then
        	-- 技能
	        local skill = DataSkill.data_skill_other[v.val]
	        if skill ~= nil then
                if v.showDesc then
                    txt:GetComponent(Text).text = string.format("<color='#00ffff'>%s:</color>%s", skill.name, skill.desc)
                    txt.transform.localPosition = Vector3(30, -20 - heqm, 0)
                    local h = txt:GetComponent(Text).preferredHeight
                    txt:GetComponent(RectTransform).sizeDelta = Vector2(220, h)
                    heqm = heqm + h
                else
                    txt:GetComponent(Button).enabled = true
                    txt:GetComponent(Text).text = string.format("%s:<color='#00ffff'>[%s]</color>", TI18N("附加技能"), skill.name)
                    local btn = txt:GetComponent(Button)
                    btn.onClick:RemoveAllListeners()
                    local data = skill
                    local info = {gameObject = self.gameObject, skillData = data, type = Skilltype.petskill}
                    btn.onClick:AddListener(function() self.model:ShowSkill(info, true) end)
                    txt.transform.localPosition = Vector3(30, -20 - heqm, 0)
                    txt:GetComponent(RectTransform).sizeDelta = Vector2(220, 25)
                    heqm = heqm + 25
                end
            end
        elseif v.name == 101 or v.name == 102 or v.name == 103 or v.name == 104 or v.name == 105 then
            txt:GetComponent(Text).text = string.format("<color='#97abb4'>%s</color><color='#00ff00'>+%s</color>", KvData.attr_name[v.name], v.val)
            txt:GetComponent(RectTransform).sizeDelta = Vector2(220, 25)
            txt.transform.localPosition = Vector3(30, -20 - heqm, 0)
            heqm = heqm + 25
        else
            if v.val > 0 then
                txt:GetComponent(Text).text = string.format("<color='#97abb4'>%s</color><color='#00ff00'>+%s%%</color>", KvData.attr_name[v.name], v.val / 10)
            else
                txt:GetComponent(Text).text = string.format("<color='#97abb4'>%s</color><color='#ff0000'>%s%%</color>", KvData.attr_name[v.name], v.val / 10)
            end
            txt:GetComponent(RectTransform).sizeDelta = Vector2(220, 25)
            txt.transform.localPosition = Vector3(30, -20 - heqm, 0)
            heqm = heqm + 25
        end
        -- txt.transform.localPosition = Vector3(30, -20-(count-1)*25, 0)
        count = count + 1
    end
    for i = count,count1 do
        GameObject.Destroy(container.transform:GetChild(i - 1).gameObject)
    end

    heqm = heqm + 25
    if count > 1 then
        -- heqm = 25 * count
        rect.sizeDelta = Vector2(250, heqm)
    end
    return heqm
end

-- 处理tips按钮
function FruitTipsNew:ShowButton(info, extra)
    extra = extra or {}
    local options = info.tips_type

    local showList = {}
    if not extra.nobutton then
        for i, data in ipairs(options) do
            if data.tips == TipsEumn.ButtonType.Drop then
                if not extra.inbag then
                    table.insert(showList, data.tips)
                end
            elseif data.tips == TipsEumn.ButtonType.Openwindow then
                local openwindow_str = data.val
                local items = StringHelper.MatchBetweenSymbols(openwindow_str, "{", "}")
                if #items > 0 then
                    local args = BaseUtils.split(items[1], ";")
                    if #args > 0 then
                        self.opentxt.text = args[1]
                    end
                    if #args > 1 then
                        self.openwindowid = args[2]
                    end
                end

                if extra.inbag then
                    if tonumber(self.openwindowid) == WindowConfig.WinID.giftwindow then
                        if info.bind == BackpackEumn.BindType.unbind then
                            table.insert(showList, data.tips)
                        end
                    else
                        table.insert(showList, data.tips)
                    end
                end
            elseif data.tips == TipsEumn.ButtonType.AlchemyType then
                if extra.inbag then
                    if data.val ~= nil and data.val ~= "[]" then
                        local num = StringHelper.MatchBetweenSymbols(data.val, "%[", "%]")[1]
                        num = tonumber(num)
                        local has = BackpackManager.Instance:GetItemCount(info.base_id)
                        if has > 1 then
                            if #options - 1 <= num then
                                table.insert(showList, data.tips)
                            end
                        else
                            table.insert(showList, data.tips)
                        end
                    end
                end
            else
                if extra.inbag then
                    if data.tips == TipsEumn.ButtonType.Sell then
                        --绑定物品无法出售，寄售,不显示
                        if info.bind == BackpackEumn.BindType.unbind then
                            -- has_sell = true
                            table.insert(showList, data.tips)
                        end
                        --处理是否显示产出图标
                        local btn = self.buttons[data.tips]
                        if data.val ~= nil and data.val ~= "[]" then
                            local icon = StringHelper.MatchBetweenSymbols(data.val, "%[", "%]")[1]
                            if icon == "1" then
                                --显示金币
                                self.sellBtnIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Assets90003")
                                self.sellBtnTxt.text = TI18N("出售")
                            elseif icon == "2" then
                                --显示银币
                                self.sellBtnIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Assets90000")
                                self.sellBtnTxt.text = TI18N("上架")
                            elseif icon == "3" then
                                --显示钻石
                                self.sellBtnIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Assets90002")
                                self.sellBtnTxt.text = TI18N("上架")
                            end
                            self.sellBtnIcon.gameObject:SetActive(true)
                        else
                            self.sellBtnIcon.gameObject:SetActive(false)
                        end
                    elseif data.tips == TipsEumn.ButtonType.Consigenment then
                        --绑定物品无法出售，寄售,不显示
                        if info.bind == BackpackEumn.BindType.unbind then
                            table.insert(showList, data.tips)
                        end
                    elseif data.tips == TipsEumn.ButtonType.Combine then
                        local has = BackpackManager.Instance:GetItemCount(info.base_id)
                        if has > 1 then
                            table.insert(showList, data.tips)
                        end
                    else
                        table.insert(showList, data.tips)
                    -- if data.val == "[0]" then --按钮禁用
                    -- end
                    end
                end
            end
        end
    end

    if extra.white_list == nil then
       for i,v in ipairs(showList) do
            if self.buttons[v] ~= nil then
                self.buttons[v]:SetActive(true)
            end
        end
    else
        --不根据配置的额外处理部分
        showList = {}
        for i, data in ipairs(extra.white_list) do
            if data.show then
                table.insert(showList, data.id)
            end
            self.buttons[data.id]:SetActive(data.show)
        end
    end

    local count = 0
    local temp  = {}
    table.sort(showList, function(a,b) return a < b end)
    for i,id in ipairs(showList) do
        if id == TipsEumn.ButtonType.Sell then
            table.remove(showList, i)
            table.insert(temp, id)
            break
        end
    end

    for _,id in ipairs(showList) do
        table.insert(temp, id)
    end
    showList = temp
    temp = nil

    if #showList == 1 then
        count = count + 1
        local rect = self.buttons[showList[1]]:GetComponent(RectTransform)
        if showList[1] == TipsEumn.ButtonType.Drop then
            rect.anchoredPosition = Vector2(0, 0)
            rect.sizeDelta = Vector2(230, 48)
        else
            rect.anchoredPosition = Vector2(60, 0)
            rect.sizeDelta = Vector2(110, 48)
        end
    else
        for _,id in ipairs(showList) do
            count = count + 1
            local rect = self.buttons[showList[count]]:GetComponent(RectTransform)
            rect.anchoredPosition = Vector2(120*((count-1)%2), -58*(math.ceil(count/2)-1))
            rect.sizeDelta = Vector2(110, 48)
        end
    end

    if count == 0 then
        self.midLine:SetActive(false)
    else
        self.midLine:SetActive(true)
    end

    self.bottomRect.anchoredPosition = Vector2(0, -self.height-30)
    self.height = self.height + 58 * math.ceil(count / 2) + 5
end

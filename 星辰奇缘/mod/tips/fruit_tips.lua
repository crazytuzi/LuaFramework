-- ------------------------------
-- 果实tips
-- hosr
-- ------------------------------
FruitTips = FruitTips or BaseClass(BaseTips)

function FruitTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_fruit, type = AssetType.Main}
    }
    self.mgr = TipsManager.Instance
    self.width = 315
    self.height = 20
    self.buttons = {}
    self.DefaultSize = Vector2(315, 0)

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)

    self.extraDesc = ""
end

function FruitTips:__delete()
    if self.itemCell ~= nil then
        self.itemCell:DeleteMe()
        self.itemCell = nil
    end
    self.mgr = nil
    self.buttons = {}
    self.height = 20
    self:RemoveTime()
end

function FruitTips:RemoveTime()
    self.mgr.updateCall = nil
end

function FruitTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_fruit))
    self.gameObject.name = "FruitTips"
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
    self.midLine = mid:Find("Line").gameObject
    self.extarTypeTxt = mid:Find("Type"):GetComponent(Text)
    self.descTxt = mid:Find("Desc"):GetComponent(Text)
    self.midLineRect = self.midLine:GetComponent(RectTransform)
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.attrContainer = mid:Find("EqmAtrribute").gameObject
    self.attrTxt = self.attrContainer:GetComponent(Text)
    self.attrRect = self.attrContainer:GetComponent(RectTransform)

    self.skillContainer = mid:Find("EqmSkill").gameObject
    self.skillTxt = self.skillContainer:GetComponent(Text)
    self.skillRect = self.skillContainer:GetComponent(RectTransform)

    self.eqmBaseTxt = mid:Find("EqmBaseText").gameObject
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

function FruitTips:UnRealUpdate()
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

function FruitTips:Default()
    self.height = 20
    self.extraDesc = ""
    self.typeTxt.text = ""
    self.nameTxt.text = ""
    self.extarTypeTxt.text = ""
    self.descTxt.text = ""
    self.bindObj:SetActive(false)
    self.attrContainer:SetActive(false)
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
function FruitTips:UpdateInfo(info, extra)
    self:Default()

    self.itemData = info
    self.nameTxt.text = ColorHelper.color_item_name(info.quality, info.name)


    self.itemCell:SetAll(info)
    self.bindObj:SetActive(info.bind == 1)

    --加上上部分的高度
    self.height = self.height + 90

    local hh = 0
    local buffer = self:GetChangeBufferData(info)

    if self.extraDesc ~= "" then
        self.extarTypeTxt.gameObject:SetActive(true)
        hh = 30
    end

    local currTime = 0
    if info.type == BackpackEumn.ItemType.limit_fruit then
        -- 限量果实显示使用次数
        for k,v in pairs(info.extra) do
            if v.name == BackpackEumn.ExtraName.fruit_time then
                currTime = v.value
            end
        end
        local maxTime = DataItem.data_fruit[tonumber(info.base_id)].num
        if currTime == 0 then
            currTime = maxTime
        end
    end
    currTime = math.max(currTime, 1)
    self.extarTypeTxt.text = string.format(TI18N("%s\n剩余使用:<color='#ffff00'>%s次</color>"), self.extarTypeTxt.text, currTime)
    hh = self.extarTypeTxt.preferredHeight

    if buffer == nil then
        self.descTxt.text = info.desc
        self.descRect.anchoredPosition = Vector2(0, -hh)
        self.descRect.sizeDelta = Vector2(250, self.descTxt.preferredHeight)
        self.attrRect.anchoredPosition = Vector2(0, -hh - self.descTxt.preferredHeight - 10)
        -- 处理属性显示
        hh = hh + self:ParseAttribute(info.attr)
    else
        self.descTxt.text = buffer.desc
        self.descRect.anchoredPosition = Vector2(0, -hh)
        self.descRect.sizeDelta = Vector2(250, self.descTxt.preferredHeight)
        self.attrRect.anchoredPosition = Vector2(0, -hh - self.descTxt.preferredHeight - 10)
        -- 处理属性显示
        local nattr = {}
        for i,v in ipairs(buffer.attr) do
            table.insert(nattr, {name = v.attr_type, val = v.val})
        end
        hh = hh + self:ParseAttribute(nattr)
        self.skillRect.anchoredPosition = Vector2(0, -self.descTxt.preferredHeight - hh - 10)
        nattr = {}
        for i,v in ipairs(buffer.effect) do
            if v.effect_type == 1 then
                table.insert(nattr, v.val)
            end
        end
        hh = hh + self:ParseSkill(nattr)
    end

    self.height = self.height + self.descTxt.preferredHeight + 10 + hh
    self.midRect.sizeDelta = Vector2(250, self.descTxt.preferredHeight + hh + 10)
    self.midLineRect.anchoredPosition = Vector2(0, -(self.descTxt.preferredHeight + hh + 20))
    -- 处理按钮
    self:ShowButton(info, extra)
    -- 加上底部间隔高度
    self.height = self.height + 40
    self.rect.sizeDelta = Vector2(self.width, self.height)

    self.mgr.updateCall = self.updateCall
end

function FruitTips:GetChangeBufferData(info)
    for i,v in ipairs(info.effect) do
        if v.effect_type == 10 then
            return DataBuff.data_list[v.val[1]]
        elseif v.effect_type == 37 then
            self.typeTxt.text = string.format(TI18N("类型:%s级幻化果"), tonumber(v.val[1][2]))
            self.extarTypeTxt.text = string.format(TI18N("需要幻化等级:<color='#ffff00'>%s级</color>"), tonumber(v.val[1][2]))
            self.extraDesc = string.format(TI18N("类型:%s级幻化果"), tonumber(v.val[1][2]))
            return DataBuff.data_list[v.val[1][1]]
        end
    end
    return nil
end

-- 处理属性显示
function FruitTips:ParseAttribute(attr)
    if #attr == 0 then
        attr = {{name = 0, val = 0}}
    end
    self.attrContainer:SetActive(false)
    local count1 = self.attrContainer.transform.childCount
    local count = 1
    for i,v in ipairs(attr) do
        self.attrContainer:SetActive(true)
        local txt = nil
        if i <= count1 then
            txt = self.attrContainer.transform:GetChild(i - 1).gameObject
        else
            txt = GameObject.Instantiate(self.eqmBaseTxt).gameObject
            txt.transform:SetParent(self.attrContainer.transform)
            txt.transform.localScale = Vector3.one
            txt:SetActive(true)
        end
        txt:GetComponent(Button).enabled = false
        if v.name == 0 then
            txt:GetComponent(Text).text = TI18N("<color='#00ffff'>无</color>")
        else
            if v.val > 0 then
                txt:GetComponent(Text).text = string.format("<color='#97abb4'>%s</color><color='#00ff00'>+%s%%</color>", KvData.attr_name[v.name], v.val / 10)
            else
                txt:GetComponent(Text).text = string.format("<color='#97abb4'>%s</color><color='#ff0000'>%s%%</color>", KvData.attr_name[v.name], v.val / 10)
            end
        end
        txt.transform.localPosition = Vector3(30, -20-(count-1)*25, 0)
        count = count + 1
    end
    for i = count,count1 do
        GameObject.Destroy(self.attrContainer.transform:GetChild(i - 1).gameObject)
    end

    local heqm = 0
    if count > 1 then
        heqm = 25 * count
        self.attrRect.sizeDelta = Vector2(250, heqm)
    end
    return heqm
end

-- 处理属性显示
function FruitTips:ParseSkill(attr)
    self.skillContainer:SetActive(false)
    local hh = 0
    local base = {}
    for i,v in ipairs(attr) do
        local skill = DataSkill.data_skill_other[v]
        if skill ~= nil then
            table.insert(base, skill)
        end
    end
    if #base == 0 then
        base = {0}
    end

    local count1 = self.skillContainer.transform.childCount

    local count = 1
    for i,skill in ipairs(base) do
        self.skillContainer:SetActive(true)
        local txt = nil
        if i <= count1 then
            txt = self.skillContainer.transform:GetChild(i - 1).gameObject
        else
            txt = GameObject.Instantiate(self.eqmBaseTxt).gameObject
            txt.transform:SetParent(self.skillContainer.transform)
            txt.transform.localScale = Vector3.one
            txt:SetActive(true)
        end
        if skill == 0 then
            txt:GetComponent(Button).enabled = false
            txt:GetComponent(Text).text = TI18N("<color='#00ffff'>无</color>")
        else
            txt:GetComponent(Button).enabled = true
            txt:GetComponent(Text).text = string.format("<color='#00ffff'>[%s]</color>", skill.name)
            local btn = txt:GetComponent(Button)
            btn.onClick:RemoveAllListeners()
            local data = skill
            local info = {gameObject = self.gameObject, skillData = data, type = Skilltype.petskill}
            btn.onClick:AddListener(function() self.model:ShowSkill(info, true) end)
        end
        txt.transform.localPosition = Vector3(30, -20-(count-1)*25, 0)
        count = count + 1
    end
    for i = count,count1 do
        GameObject.Destroy(self.skillContainer.transform:GetChild(i - 1).gameObject)
    end

    local heqm = 0
    if count > 1 then
        heqm = 25 * count
        self.skillRect.sizeDelta = Vector2(250, heqm)
    end
    return heqm
end

-- 处理tips按钮
function FruitTips:ShowButton(info, extra)
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
                local items = StringHelper.MatchBetweenSymbols(data.val, "{", "}")
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
                            has_sell = true
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

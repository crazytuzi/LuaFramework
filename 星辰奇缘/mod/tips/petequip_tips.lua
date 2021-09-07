-- ------------------------------
-- 宠物装tips
-- hosr
-- ------------------------------
PetEquipTips = PetEquipTips or BaseClass(BaseTips)

function PetEquipTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_petequip, type = AssetType.Main}
    }
    self.mgr = TipsManager.Instance
    self.width = 315
    self.height = 20
    self.buttons = {}
    self.DefaultSize = Vector2(315, 0)

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:OnHide() self:RemoveTime() end)
end

function PetEquipTips:__delete()
    if self.itemCell ~= nil then
        self.itemCell:DeleteMe()
        self.itemCell = nil
    end
    self.mgr = nil
    self.buttons = {}
    self.height = 20
    self:RemoveTime()
end

function PetEquipTips:RemoveTime()
    self.mgr.updateCall = nil
end

function PetEquipTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_petequip))
    self.gameObject.name = "PetEquipTips"
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
    self.descTxt = mid:Find("Desc"):GetComponent(Text)
    self.midLineRect = self.midLine:GetComponent(RectTransform)
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.attrContainer = mid:Find("EqmAtrribute").gameObject
    self.attrContainerTxt = self.attrContainer:GetComponent(Text)
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
    local meltButton = bottom:Find("MeltButton").gameObject

    self.sellBtnIcon = sell.transform:Find("Image"):GetComponent(Image)
    self.sellBtnTxt = sell.transform:Find("Text"):GetComponent(Text)
    self.opentxt = open.transform:Find("Text"):GetComponent(Text)

    use:GetComponent(Button).onClick:AddListener(function() self.model:Use(self.itemData) end)
    sell:GetComponent(CustomButton).onClick:AddListener(function() self.model:Sell(self.itemData) end)
    sell:GetComponent(CustomButton).onHold:AddListener(function() self.model:Sell(self.itemData, true) end)
    sell:GetComponent(CustomButton).onDown:AddListener(function() self:OnDownSell() end)
    sell:GetComponent(CustomButton).onUp:AddListener(function() self:OnUpSell() end)
    self.noticeBtn = sell.transform:Find("Notice"):GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    cons:GetComponent(Button).onClick:AddListener(function() self.model:Sell(self.itemData) end)
    -- simth:GetComponent(Button).onClick:AddListener(function() self.model:Use() end)
    -- ware:GetComponent(Button).onClick:AddListener(function() self.model:Use() end)
    merge:GetComponent(Button).onClick:AddListener(function() self.model:Merge(self.itemData) end)
    -- remove:GetComponent(Button).onClick:AddListener(function() self.model:Use() end)
    open:GetComponent(Button).onClick:AddListener(function() self.model:Openwindow(self.openwindowid) end)
    discard:GetComponent(Button).onClick:AddListener(function() self.model:Discard(self.itemData) end)
    petgemoff:GetComponent(Button).onClick:AddListener(function() self.model:Pet_gem_off(self.itemData, self.extra) end)
    inStore:GetComponent(Button).onClick:AddListener(function() self.model:InStore(self.itemData) end)
    outStore:GetComponent(Button).onClick:AddListener(function() self.model:OutStore(self.itemData) end)
    petgemreplace:GetComponent(Button).onClick:AddListener(function() self.model:Pet_gem_replace(self.itemData, self.extra) end)
    LianhuaButton:GetComponent(Button).onClick:AddListener(function() self.model:Alchemy(self.itemData) end)
    meltButton:GetComponent(Button).onClick:AddListener(function() self.model:Melt(self.itemData) end)

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
        ,[TipsEumn.ButtonType.Melt] = meltButton
    }

    for _,v in pairs(self.buttons) do
        if v ~= nil then
            v.transform.pivot = Vector2(0.5, 0.5)
        end
    end
end

function PetEquipTips:OnHide()
    if self.arrowEffect ~= nil then
        self.arrowEffect:SetActive(false)
    end
end

function PetEquipTips:UnRealUpdate()
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

function PetEquipTips:Default()
    self.height = 20
    self.typeTxt.text = ""
    self.nameTxt.text = ""
    self.descTxt.text = ""
    self.bindObj:SetActive(false)
    self.attrContainer:SetActive(false)

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
function PetEquipTips:UpdateInfo(info, extra)
    self:Default()

    self.itemData = info
    self.extra = extra
    self.nameTxt.text = info.name
    self.typeTxt.text = TI18N("类型:宠物装备")
    if info.type == BackpackEumn.ItemType.childattreqm or info.type == BackpackEumn.ItemType.childskilleqm then
        self.typeTxt.text = TI18N("类型:子女装备")
    end
    self.descTxt.text = info.desc
    self.itemCell:SetAll(info)
    self.bindObj:SetActive(info.bind == 1)

    --加上上部分的高度
    self.height = self.height + 90

    self.descRect.sizeDelta = Vector2(250, self.descTxt.preferredHeight)
    self.eqmRect.anchoredPosition = Vector2(0, -self.descTxt.preferredHeight-10)

    --加上换行的高度
    self.height = self.height + self.descTxt.preferredHeight + 10

    -- 处理属性显示
    if info.attr ~= nil and #info.attr > 0 then
        self:ParseAttribute(info.attr)
    else
        local list = {}
        for i,v in ipairs(info.effect) do
            if v.effect_type == 51 then
                local tmp = DataItem.data_stone_skill[v.val[1][2]];
                if tmp ~= nil then
                    local skills = tmp.list
                    for i,v in ipairs(skills) do
                        table.insert(list, {name = 100, val = v})
                    end
                end
            end
        end
        self:ParseAttribute(list)
    end
    -- 处理按钮
    self:ShowButton(info, extra)
    -- 加上底部间隔高度
    self.height = self.height + 10
    self.rect.sizeDelta = Vector2(self.width, self.height)

    self.mgr.updateCall = self.updateCall
end

-- 处理属性显示
function PetEquipTips:ParseAttribute(attr)
    attr = attr or {}
    self.attrContainer:SetActive(false)

    local hh = 0
    local base = {}
    local list = {}
    for i,v in ipairs(attr) do
        if v.val ~= 0 then
            if v.name == 100 then
                local skill = DataSkill.data_petSkill[string.format("%s_1", v.val)]
                if skill ~= nil then
                    table.insert(base, skill)
                    -- table.insert(base, string.format("<color='#00ffff'>[%s]</color>", skill.name))
                end
            elseif v.name == 101 or v.name == 102 or v.name == 103 or v.name == 104 or v.name == 105 then
                local str = string.format("%s+%s", KvData.attr_name[v.name], v.val)
                table.insert(list, str)
            end
        end
    end

    local count1 = self.attrContainer.transform.childCount

    local count = 1
    for i,skill in ipairs(base) do
        self.attrContainerTxt.text = TI18N("附带技能")
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
        txt:GetComponent(Text).text = string.format("<color='#00ffff'>[%s]</color>", skill.name)
        local btn = txt:GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        local data = skill
        local info = {gameObject = self.gameObject, skillData = data, type = Skilltype.petskill}
        btn.onClick:AddListener(function() self.model:ShowSkill(info, true) end)
        txt.transform.localPosition = Vector3(30, -20-(count-1)*25, 0)
        count = count + 1
    end

    for i,str in ipairs(list) do
        self.attrContainer:SetActive(true)
        self.attrContainerTxt.text = TI18N("附带属性")
        local txt = nil
        if i <= count1 then
            txt = self.attrContainer.transform:GetChild(i - 1).gameObject
        else
            txt = GameObject.Instantiate(self.eqmBaseTxt).gameObject
            txt.transform:SetParent(self.attrContainer.transform)
            txt.transform.localScale = Vector3.one
            txt:SetActive(true)
        end
        txt:GetComponent(Text).text = string.format("<color='#00ffff'>%s</color>", str)
        txt:GetComponent(Button).onClick:RemoveAllListeners()
        txt.transform.localPosition = Vector3(30, -20-(count-1)*25, 0)
        count = count + 1
    end

    for i = count,count1 do
        GameObject.Destroy(self.attrContainer.transform:GetChild(i - 1).gameObject)
    end

    local heqm = 0
    heqm = 25 * count + 10
    self.height = self.height + heqm
    self.eqmRect.sizeDelta = Vector2(250, heqm)
    self.midRect.sizeDelta = Vector2(250, self.descTxt.preferredHeight+heqm+10)
    self.midLineRect.anchoredPosition = Vector2(0, -(self.descTxt.preferredHeight+heqm+10))
    self.height = self.height + 10
end

-- 处理tips按钮
function PetEquipTips:ShowButton(info, extra)
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
                    table.insert(showList, data.tips)
                end
            elseif data.tips == TipsEumn.ButtonType.AlchemyType then
                if extra.inbag then
                    table.insert(showList, data.tips)
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
                                self.noticeBtn.gameObject:SetActive(true)
                            elseif icon == "2" then
                                --显示银币
                                self.sellBtnIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Assets90000")
                                self.sellBtnTxt.text = TI18N("上架")
                                self.noticeBtn.gameObject:SetActive(false)
                            elseif icon == "3" then
                                --显示钻石
                                self.sellBtnIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Assets90002")
                                self.sellBtnTxt.text = TI18N("上架")
                                self.noticeBtn.gameObject:SetActive(false)
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
                    elseif data.tips == TipsEumn.ButtonType.Melt then
                        if RoleManager.Instance.RoleData.lev >= 80 then
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
            rect.anchoredPosition = Vector2(115, -24)
            rect.sizeDelta = Vector2(230, 48)
        else
            rect.anchoredPosition = Vector2(115, -24)
            rect.sizeDelta = Vector2(110, 48)
        end
    else
        for _,id in ipairs(showList) do
            count = count + 1
            local rect = self.buttons[showList[count]]:GetComponent(RectTransform)
            rect.anchoredPosition = Vector2(120*((count-1)%2) + 55, -58*(math.ceil(count/2)-1) - 24)
            rect.sizeDelta = Vector2(110, 48)
        end
    end

    if count == 0 then
        self.midLine:SetActive(false)
    else
        self.midLine:SetActive(true)
    end

    self.bottomRect.anchoredPosition = Vector2(0, -self.height-10)
    self.height = self.height + 58 * math.ceil(count / 2) + 5
end

function PetEquipTips:OnDownSell()
    self.isUp = false
    LuaTimer.Add(100, function()
        if self.isUp then
            return
        end
        if self.arrowEffect == nil then
            self.arrowEffect = BibleRewardPanel.ShowEffect(20009, self.buttons[TipsEumn.ButtonType.Sell].transform, Vector3(1, 1, 1), Vector3(53, 29, -400))
        else
            self.arrowEffect:SetActive(false)
            self.arrowEffect:SetActive(true)
        end
    end)
end

function PetEquipTips:OnUpSell()
    self.isUp = true
    if self.arrowEffect ~= nil then
        self.arrowEffect:SetActive(false)
    end
end

function PetEquipTips:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.buttons[TipsEumn.ButtonType.Sell].gameObject, itemData = {TI18N("长按可<color='#ffff00'>批量出售</color>")}, special = true})
end



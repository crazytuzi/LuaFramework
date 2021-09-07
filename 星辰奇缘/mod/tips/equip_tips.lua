-- ------------------------------
-- 装备tips
-- hosr
-- ------------------------------
EquipTips = EquipTips or BaseClass(BaseTips)

function EquipTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_equip, type = AssetType.Main}
    }
    self.mgr = TipsManager.Instance
    self.width = 315
    self.height = 20
    self.buttons = {}
    self.txtTab = {}
    self.DefaultSize = Vector2(315, 0)

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)
end

function EquipTips:__delete()
    self.mgr = nil
    self.buttons = {}
    self.height = 20
    self:RemoveTime()
    if self.itemCell ~= nil then
        self.itemCell:DeleteMe()
        self.itemCell = nil
    end
end

function EquipTips:RemoveTime()
    self.mgr.updateCall = nil
end

function EquipTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_equip))
    self.gameObject.name = "EquipTips"
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
    self.itemCell:ShowLevel(true)
    self.nameTxt = head:Find("Name"):GetComponent(Text)
    self.levelTxt = head:Find("Level"):GetComponent(Text)
    self.pointTxt = head:Find("Point"):GetComponent(Text)
    self.bindObj = head:Find("Bind").gameObject
    self.bindObj:SetActive(false)
    self.equipedObj = head:Find("IsEquipImg").gameObject
    self.lookup = head:Find("Lookup").gameObject
    self.lookup:GetComponent(Button).onClick:AddListener(function() self:ClickLookup() end)
    self.lookup:SetActive(false)

    local mid = self.transform:Find("MidArea")
    self.midLine = mid:Find("Line").gameObject
    self.midLineRect = self.midLine:GetComponent(RectTransform)
    self.midTransform = mid.transform
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.baseTxt = mid:Find("BaseText").gameObject
    self.baseTxt:SetActive(false)



    local bottom = self.transform:Find("BottomArea")
    self.bottomRect = bottom.gameObject:GetComponent(RectTransform)
    local use = bottom:Find("UseButton").gameObject
    local drop = bottom:Find("DropButtonOnly").gameObject
    local sell = bottom:Find("SellButton").gameObject
    local cons = bottom:Find("ConsignmentButton").gameObject
    local simth = bottom:Find("SmithButton").gameObject
    local trans = bottom:Find("TransformButton").gameObject
    local ware = bottom:Find("WareButton").gameObject
    local merge = bottom:Find("MergeButton").gameObject
    local open = bottom:Find("OpenWindowButton").gameObject
    local discard = bottom:Find("DiscardButton").gameObject
    local inStore = bottom:Find("InStoreButton").gameObject
    local outStore = bottom:Find("OutStoreButton").gameObject
    local lianhua = bottom:Find("LianhuaButton").gameObject
    local xilian = bottom:Find("XilianButton").gameObject
    local dianhua = bottom:Find("DianhuaButton").gameObject

    self.sellBtnIcon = sell.transform:Find("Image"):GetComponent(Image)
    self.opentxt = open.transform:Find("Text"):GetComponent(Text)
    self.simthUp = bottom:Find("SmithButton/Up").gameObject

    use:GetComponent(Button).onClick:AddListener(function() self.model:Use(self.itemData) end)
    ware:GetComponent(Button).onClick:AddListener(function() self.model:Use(self.itemData) end)
    simth:GetComponent(Button).onClick:AddListener(function() self.model:Smith(self.itemData) end)
    trans:GetComponent(Button).onClick:AddListener(function() self.model:Trans(self.itemData, 1) end)
    merge:GetComponent(Button).onClick:AddListener(function() self.model:Merge(self.itemData) end)
    -- sell:GetComponent(Button).onClick:AddListener(function() self.model:Use() end)
    -- cons:GetComponent(Button).onClick:AddListener(function() self.model:Use() end)
    discard:GetComponent(Button).onClick:AddListener(function() self.model:Discard(self.itemData) end)
    inStore:GetComponent(Button).onClick:AddListener(function() self.model:InStore(self.itemData) end)
    outStore:GetComponent(Button).onClick:AddListener(function() self.model:OutStore(self.itemData) end)
    lianhua:GetComponent(Button).onClick:AddListener(function() self.model:Alchemy(self.itemData) end)
    xilian:GetComponent(Button).onClick:AddListener(function() self.model:Trans(self.itemData, 2) end)
    dianhua:GetComponent(Button).onClick:AddListener(function() self.model:Dianhua(self.itemData) end)

    self.buttons = {
        [TipsEumn.ButtonType.Use] = use
        ,[TipsEumn.ButtonType.Drop] = drop
        ,[TipsEumn.ButtonType.Sell] = sell
        ,[TipsEumn.ButtonType.Consigenment] = cons
        ,[TipsEumn.ButtonType.Smith] = simth
        ,[TipsEumn.ButtonType.Ware] = ware
        ,[TipsEumn.ButtonType.Merge] = merge
        ,[TipsEumn.ButtonType.Petgem_off] = pregem
        ,[TipsEumn.ButtonType.Openwindow] = open
        ,[TipsEumn.ButtonType.Discard] = discard
        ,[TipsEumn.ButtonType.InStore] = inStore
        ,[TipsEumn.ButtonType.OutStore] = outStore
        ,[TipsEumn.ButtonType.Trans] = trans
        ,[TipsEumn.ButtonType.AlchemyType] = lianhua
        ,[TipsEumn.ButtonType.Xilian] = xilian
        ,[TipsEumn.ButtonType.Dianhua] = dianhua
    }

    self.extra = EquipTipsExt.New(self.transform:Find("Extra").gameObject, self)
end

function EquipTips:UnRealUpdate()
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

function EquipTips:Default()
    self.height = 20
    self.nameTxt.text = ""
    self.levelTxt.text = ""
    self.equipedObj:SetActive(false)
    self.bindObj:SetActive(false)

    self.extra:Hide()
    --处理有效区域
    self.model:CancelEquipTipsRightArea()

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
function EquipTips:UpdateInfo(info, extra)
    self:Default()

    self.itemData = info

    BaseUtils.dump(info, "equip")

    self.roleLev = RoleManager.Instance.RoleData.lev
    self.roleClasses = RoleManager.Instance.RoleData.classes
    self.roleSex = RoleManager.Instance.RoleData.sex
    if extra ~= nil then
        if extra.lev ~= nil then
            self.roleLev = extra.lev
        end

        if extra.classes ~= nil then
            self.roleClasses = extra.classes
        end

        if extra.sex ~= nil then
            self.roleSex = extra.sex
        end
    end

    local name_str = ColorHelper.color_item_name(info.quality, info.name)
    if info ~= nil and info.extra ~= nil then
        --装备神器图标统一处理
        if info.type == BackpackEumn.ItemType.swords or info.type == BackpackEumn.ItemType.gloves or info.type == BackpackEumn.ItemType.wands or info.type == BackpackEumn.ItemType.bows or info.type == BackpackEumn.ItemType.magicbook then
            --组织神器的名字
            for i=1,#info.extra do
                 if info.extra[i].name == 9 then
                    local temp_id = info.extra[i].value
                    local max_flag = 0
                    for j=1,#info.attr do
                        if info.attr[j].type == GlobalEumn.ItemAttrType.shenqi then
                            if info.attr[j].flag > max_flag then
                                max_flag = info.attr[j].flag
                            end
                        end
                    end
                    if max_flag ~= 0 then
                        name_str = ColorHelper.color_item_name(DataItem.data_get[temp_id].quality, string.format("[%s]%s",EquipStrengthManager.Instance.model.  dianhua_name[max_flag] ,DataItem.data_get[temp_id].name))
                    else
                        name_str = ColorHelper.color_item_name(DataItem.data_get[temp_id].quality, DataItem.data_get[temp_id].name)
                    end
                    break
                 end
            end
        else
            --非武器装备
            local max_flag = 0
            for j=1,#info.attr do
                if info.attr[j].type == GlobalEumn.ItemAttrType.shenqi then
                    if info.attr[j].flag > max_flag then
                        max_flag = info.attr[j].flag
                    end
                end
            end
            if max_flag ~= 0 then
                name_str = string.format("[%s]%s",EquipStrengthManager.Instance.model.dianhua_name[max_flag] ,info.name)
            else
                name_str = ColorHelper.color_item_name(info.quality, info.name)
            end
        end
    end

    self.nameTxt.text = name_str

    self.levelTxt.text = string.format(TI18N("部位:%s"), BackpackEumn.GetEquipNameByType(info.type))
    self.pointTxt.text = string.format(TI18N("评分:%s"), BaseUtils.EquipPoint(info.attr))
    if extra~= nil and extra.pointTxt ~= nil then
        self.pointTxt.text = extra.pointTxt
    end
    self.itemCell:SetAll(info)
    self.itemCell:ShowEnchant(true)
    self.itemCell:ShowLevel(true)
    -- self.bindObj:SetActive(info.bind == 1)

    --加上上部分的高度
    self.height = self.height + 90
    -- 处理属性显示
    self:ParseAttribute(info.attr)
    -- 处理按钮
    self:ShowButton(info, extra)
    -- 加上底部间隔高度
    self.height = self.height + 10
    self.rect.sizeDelta = Vector2(self.width, self.height)

    self.mgr.updateCall = self.updateCall

    if self.itemData.lev >= 40 then
        self.lookup:SetActive(true)
    else
        self.lookup:SetActive(false)
    end

    --强制显示额外属性
    if self.itemData.show_extra == true then
        LuaTimer.Add(300, function() self:ClickLookup() end) --延迟下触发，不然会有问题
    end
end

function EquipTips:GetItem(index)
    local tab = self.txtTab[index]
    if tab == nil then
        tab = {}
        tab.gameObject = GameObject.Instantiate(self.baseTxt)
        tab.gameObject.name = "Txt"..index
        tab.transform = tab.gameObject.transform
        tab.transform:SetParent(self.midTransform)
        tab.transform.localScale = Vector3.one
        tab.rect = tab.gameObject:GetComponent(RectTransform)
        tab.txt = tab.gameObject:GetComponent(Text)
        table.insert(self.txtTab, tab)
    end
    tab.gameObject:SetActive(true)
    return tab
end



-- 处理属性显示
function EquipTips:ParseAttribute(attr)
    for i,v in ipairs(self.txtTab) do
        v.gameObject:SetActive(false)
    end

    if attr == nil or #attr == 0 then
        attr = self:DefualtAttr()
    end

    local base = {} -- 基础属性
    local enchant = {} -- 强化基础属性
    local extra = {} -- 附加属性
    local gem = {} -- 宝石属性
    local effect = {} -- 特效属性
    local wing = {} -- 翅膀特技
    local enchantExtra = {} -- 强化奖励属性
    local temp_shenqi = {} --神器
    local zero_speed = false --万年玄冰

    for i,v in ipairs(attr) do
        if v.type == GlobalEumn.ItemAttrType.base then
            table.insert(base, v)
        elseif v.type == GlobalEumn.ItemAttrType.enchant then
            if v.flag == 0 then
                enchant[v.name] = v
            else
                table.insert(enchantExtra, v)
            end
        elseif v.type == GlobalEumn.ItemAttrType.extra then
            table.insert(extra, v)
        elseif v.type == GlobalEumn.ItemAttrType.gem then
            table.insert(gem, v)
        elseif v.type == GlobalEumn.ItemAttrType.effect then
            table.insert(effect, v)
        elseif v.type == GlobalEumn.ItemAttrType.wing_skill then
            table.insert(wing, v)
        elseif v.type == GlobalEumn.ItemAttrType.shenqi then
            local flag = v.flag
            if flag%2 == 0 then
                flag = flag - 1
            end
            if temp_shenqi[flag] == nil then
                temp_shenqi[flag] = {}
            end
            table.insert(temp_shenqi[flag], BaseUtils.copytab(v))
        elseif v.type == GlobalEumn.ItemAttrType.zero_speed then
            zero_speed = true
        end
    end



    table.sort(base, function(a,b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)
    table.sort(enchantExtra, function(a,b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)
    table.sort(extra, function(a,b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)
    table.sort(gem, function(a,b)
        return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name]
    end)
    table.sort(effect, function(a,b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)

    local shenqi = {}
    for k, v in pairs(temp_shenqi) do
        for i=1,#v do
            local v2 = v[i]
            if shenqi[v2.name] == nil then
                shenqi[v2.name] = v2
            else
                shenqi[v2.name].val = shenqi[v2.name].val + v2.val
            end
        end
    end


    table.sort(shenqi, function(a,b) return a.val < b.val end)

    local hh = 0
    local useCount = 0
    local num  = 0
    for i,v in ipairs(base) do
        num = num + 1
        useCount = useCount + 1
        local tab = self:GetItem(useCount)

        -- 查看是否有强化加成
        local enchantStr = ""
        local enchantAdd = enchant[v.name]
        if KvData.prop_percent[v.name] then
            if enchantAdd ~= nil then
                enchantStr = string.format("<color='#00B0F0'>(+%s%%)</color>", math.ceil(enchantAdd.val)/10)
            end
            tab.txt.text = string.format("<color='#97abb4'>%s</color><color='#4dd52b'>+%s%%</color>%s", KvData.attr_name[v.name], v.val/10, enchantStr)
        else
            if enchantAdd ~= nil then
                enchantStr = string.format("<color='#00B0F0'>(+%s)</color>", math.ceil(enchantAdd.val))
            end
            tab.txt.text = string.format("<color='#97abb4'>%s</color><color='#4dd52b'>+%s</color>%s", KvData.attr_name[v.name], v.val, enchantStr)
        end
        tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
        tab.rect.anchoredPosition = Vector2(10, -hh - (i - 1) * 25)
    end
    hh = hh + num * 25

    num  = 0
    local str = ""
    for i,v in ipairs(extra) do
        num = num + 1
        if v.val < 0 then
            str = str .. string.format("<color='#00ffff'>%s%s</color>", KvData.attr_name[v.name], v.val) .. " "
        else
            str = str .. string.format("<color='#00ffff'>%s+%s</color>", KvData.attr_name[v.name], v.val) .. " "
        end
    end
    useCount = useCount + 1
    local tab = self:GetItem(useCount)
    tab.txt.text = str
    tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
    tab.rect.anchoredPosition = Vector2(10, -hh)

    hh = hh + math.ceil(num / 2) * 25

    num  = 0
    for i,v in ipairs(gem) do
        local gemData = nil
        if v.name == 112 then
            --英雄宝石
            gemData = DataBacksmith.data_hero_stone_base[v.val]
        else
            gemData = DataBacksmith.data_gem_base[v.val]
        end
        local itemData = DataItem.data_get[v.val]
        for j,gemAttr in ipairs(gemData.attr) do
            num = num + 1
            useCount = useCount + 1
            local tab = self:GetItem(useCount)
            tab.txt.text = string.format("<color='#00ffff'>%s</color>", KvData.GetAttrStringNoColor(gemAttr.attr_name, gemAttr.val1))
            tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
            tab.rect.anchoredPosition = Vector2(10, -hh - (num - 1) * 25)

            useCount = useCount + 1
            local tab1 = self:GetItem(useCount)
            tab1.txt.text = string.format("<color='#00ffff'>(%s)</color>", itemData.name)
            tab1.rect.sizeDelta = Vector2(tab1.txt.preferredWidth, 25)
            tab1.rect.anchoredPosition = Vector2(tab.rect.anchoredPosition.x + 120, tab.rect.anchoredPosition.y)
        end
    end
    hh = hh + num * 25

    num  = 0
    for i,v in ipairs(effect) do
        num = num + 1
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
        local str = ""
        if v.name == 100 then
            -- 技能
            local skillData = DataSkill.data_skill_effect[v.val]
            if skillData == nil then
                skillData = DataSkill.data_skill_role[string.format("%s_%s", v.val, self.roleLev)]
                str = string.format("真·%s", skillData.name)
            else
                str = skillData.name
            end
        else
            str = KvData.attr_name[v.name]
        end
        tab.txt.text = string.format(TI18N("<color='#dc83f5'>特效 %s</color>"), str)
        tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
        tab.rect.anchoredPosition = Vector2(10 + (i - 1) * 120, -hh - (i - 1) * 25)
    end
    hh = hh + num * 25

    num  = 0
    for i,v in ipairs(wing) do
        num = num + 1
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
        local str = ""
        if v.name == 100 then
            -- 技能
            local skillData = DataSkill.data_wing_skill[string.format("%s_1", v.val)]
            str = skillData.name
        else
            str = KvData.attr_name[v.name]
        end
        tab.txt.text = string.format(TI18N("<color='#dc83f5'>特技 %s</color>"), str)
        tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
        tab.rect.anchoredPosition = Vector2(10 + (i - 1) * 120, -hh - (i - 1) * 25)
    end
    hh = hh + num * 25

    -- 装备突破显示
    num = 0
    if BackpackEumn.IsEnchantBreak(self.itemData) then
        num = num + 1
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
        tab.txt.text = TI18N("<color='#d781f2'>已突破：强化效果+2%</color>")
        tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
        tab.rect.anchoredPosition = Vector2(10, -hh - (num - 1) * 25)
    end
    hh = hh + num * 25

    num  = 0
    for i,v in ipairs(enchantExtra) do
        if v.val ~= 0 then
            num = num + 1
            useCount = useCount + 1
            local tab = self:GetItem(useCount)
            tab.txt.text = string.format("<color='#d781f2'>%s+%s%%</color>", KvData.attr_name[v.name], tostring(v.val/10))
            tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
            tab.rect.anchoredPosition = Vector2(10, -hh - (num - 1) * 25) -- Vector2(10 + (i - 1) * 120, -hh - (i - 1) * 25)

            useCount = useCount + 1
            local tab1 = self:GetItem(useCount)
            tab1.txt.text = string.format(TI18N("<color='#d781f2'>强化[+%s]奖励</color>"), v.flag)
            tab1.rect.sizeDelta = Vector2(tab1.txt.preferredWidth, 25)
            tab1.rect.anchoredPosition = Vector2(tab.rect.anchoredPosition.x + 120, tab.rect.anchoredPosition.y)
        end
    end
    hh = hh + num * 25


    --处理神器显示
    local str_list = {}
    local temp_index = 1
    for k, v in pairs(shenqi) do
        local index = math.ceil(temp_index/2)
        if str_list[index] == nil then
            str_list[index] = string.format("%s+%s", KvData.attr_name[v.name], v.val)
        else
            str_list[index] = string.format("%s、%s+%s", str_list[index], KvData.attr_name[v.name], v.val)
        end
        temp_index = temp_index + 1
    end
    num  = 0
    for i=1, #str_list do
        num = num + 1
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
        if i==1 then
            tab.txt.text = string.format("<color='#ffa500'>%s %s</color>", TI18N("精炼"),str_list[i])
        else
            tab.txt.text = string.format("<color='#ffa500'>   %s</color>", str_list[i])
        end

        tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
        tab.rect.anchoredPosition = Vector2(10, -hh - (num - 1) * 25)
    end
    hh = hh + num * 25



    -- 处理强化成长值显示
    num = 0
    if self.itemData.growth_val ~= nil and self.itemData.growth_val > 0 and self.itemData.enchant < self.itemData.growth_lev then
        num = num + 1
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
        local max = DataBacksmith.data_enchant_growth[self.itemData.growth_lev].growth_val
        tab.txt.text = string.format(TI18N("<color='#ffff00'>+%s成长值:%s/%s</color>"), self.itemData.growth_lev, self.itemData.growth_val, max)
        tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
        tab.rect.anchoredPosition = Vector2(10, -hh - (num - 1) * 25)

        num = num + 1
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
        local max = DataBacksmith.data_enchant_growth[self.itemData.growth_lev].growth_val
        tab.txt.text = string.format(TI18N("<color='#ffff00'>(成长值满将直接升到+%s)</color>"), self.itemData.growth_lev)
        tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
        tab.rect.anchoredPosition = Vector2(10, -hh - (num - 1) * 25)
    end
    hh = hh + num * 25

    -- 处理万年玄冰
    num = 0
    if zero_speed then
        num = num + 1
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
        tab.txt.text = TI18N("<color='#C7F9FF'>该装备使用了<color='#ffff00'>万年玄冰</color>，\n所附加的攻速降为0</color>\n<color='#7eb9f7'>（重铸或升级装备可恢复）</color>")
        tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 75)
        tab.rect.anchoredPosition = Vector2(10, -hh - (num - 1) * 75)
    end
    hh = hh + num * 75

    hh = hh + 10
    self.midRect.sizeDelta = Vector2(250, hh)

    self.height = self.height + hh + 20
end

-- 处理tips按钮
function EquipTips:ShowButton(info, extra)
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
                    local args = utils.split(items[1], ";")
                    if #args > 0 then
                        self.opentxt.text = args[1]
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
                            elseif icon == "2" then
                                --显示银币
                                self.sellBtnIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Assets90000")
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
            if data.id ==  TipsEumn.ButtonType.Xilian then
                if self.roleLev < 70 then
                    data.show = false
                end
            elseif data.id ==  TipsEumn.ButtonType.Dianhua then
                if self.roleLev < 80 then
                    data.show = false
                end
            elseif data.id == TipsEumn.ButtonType.Smith then
                self.simthUp:SetActive(BackpackManager.Instance:EquipCanUpgrade(info))
            end
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

    self.bottomRect.anchoredPosition = Vector2(0, -self.height-10)
    self.height = self.height + 58 * math.ceil(count / 2) + 5
end

function EquipTips:ClickLookup()
    if self.extra.gameObject ~= nil and self.extra.gameObject.activeSelf then
        return
    end
    self.extra:Show(self.itemData)
    --处理有效区域
    self.model:LocateEquipTipsRightArea()
end

function EquipTips:DefualtAttr()
    local dattr = {}
    local lev = self.itemData.lev
    lev = math.floor(lev  / 10) * 10
    local key = string.format("%s_%s", self.itemData.type, lev)
    local bases = EquipStrengthManager.Instance.model:get_eqm_prop_by_type_lev(key)
    bases = BaseUtils.copytab(bases)
    for i,v in ipairs(bases) do
        if v.val > 0 then
            v.type = GlobalEumn.ItemAttrType.base
            table.insert(dattr, v)
        end
    end
    return dattr or {}
end
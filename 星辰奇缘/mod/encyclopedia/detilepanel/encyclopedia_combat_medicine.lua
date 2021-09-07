-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaMedicine = EncyclopediaMedicine or BaseClass(BasePanel)


function EncyclopediaMedicine:__init(parent)
    self.Mgr = EncyclopediaManager.Instance
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaMedicine"

    self.resList = {
        {file = AssetConfig.medicine_peida, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.btnListener = function() self:ClickToggleBtn() end
    self.currIndex = 0
    self.skillIconList = {}
    self.setting = {
        column = 3
        ,cspacing = 5
        ,rspacing = 1
        ,cellSizeX = 64
        ,cellSizeY = 84
    }

    self.indexName = {}
    self.iconloader = {}
end

function EncyclopediaMedicine:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    if self.itemCell ~= nil then
        self.itemCell:DeleteMe()
    end
    self.itemCell = nil
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
    end
    self:AssetClearAll()
end

function EncyclopediaMedicine:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.medicine_peida))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.ItemCon = self.transform:Find("ItemList/Mask/Scroll")
    self.baseItem = self.transform:Find("ItemList/Mask/Scroll/Item").gameObject
    self.transform:Find("ItemList/Mask/Scroll/Item/Icon").gameObject:SetActive(true)
    self.baseItem:SetActive(false)

    local head = self.transform:Find("Right/HeadArea")
    self.itemCell = ItemSlot.New(head:Find("ItemSlot").gameObject)
    self.itemCell:SetNotips()
    self.nameTxt = head:Find("Name"):GetComponent(Text)
    self.otherTxt = head:Find("TimeLimit"):GetComponent(Text)
    self.bindObj = head:Find("Bind").gameObject

    local mid = self.transform:Find("Right/MidArea")
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.descTxt = mid:Find("Desc"):GetComponent(Text)
    self.descTxt.horizontalOverflow = HorizontalWrapMode.Overflow
    self.descRect = self.descTxt.gameObject:GetComponent(RectTransform)
    self.text1 = mid:Find("Text1"):GetComponent(Text)
    self.text2 = mid:Find("Text2"):GetComponent(Text)
    self.text3 = mid:Find("Text3"):GetComponent(Text)

    self.msg1 = MsgItemExt.New(self.text1, 250, 18, 21)
    self.msg2 = MsgItemExt.New(self.text2, 250, 18, 21)
    self.msg3 = MsgItemExt.New(self.text3, 250, 18, 21)

    self.trect1 = self.text1.gameObject:GetComponent(RectTransform)
    self.trect2 = self.text2.gameObject:GetComponent(RectTransform)
    self.trect3 = self.text3.gameObject:GetComponent(RectTransform)

    self:InitItemList()
end

function EncyclopediaMedicine:CreanteSlot()
    local item = GameObject.Instantiate(self.baseItem)
    item.transform:SetParent(self.ItemCon)
    item.gameObject:SetActive(false)
    item.transform.position = Vector3.zero
    item.transform.localScale = Vector3.one
    local slot = {}
    slot.gameObject = item
    -- item:GetComponent(Image).enabled = false
    slot.btn = item:GetComponent(Button)
    item.transform:Find("Select").gameObject:SetActive(false)
    slot.qualityimg = item.transform:Find("quality"):GetComponent(Image)
    slot.iconimg = item.transform:Find("Icon"):GetComponent(Image)
    slot.selectobj = item.transform:Find("Select").gameObject
    return slot
end

function EncyclopediaMedicine:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaMedicine:OnOpen()
    self:RemoveListeners()
    -- self:UpdateSelect()
end

function EncyclopediaMedicine:OnHide()
    self:RemoveListeners()
end

function EncyclopediaMedicine:RemoveListeners()
end

function EncyclopediaMedicine:InitItemList()
    local datalist = self.Mgr.MedicineData
    for i,v in ipairs(datalist) do
        local slot = self:CreanteSlot()

        local id = slot.iconimg.gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(slot.iconimg.gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, v.icon)
        if v.quality+1 < 4 then
            slot.qualityimg.gameObject:SetActive(false)
        else
            slot.qualityimg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Item%s", v.quality+1))
            slot.qualityimg.gameObject:SetActive(true)
        end
        slot.btn.onClick:AddListener(function()
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = slot.selectobj
            self.selectgo:SetActive(true)
            self:ClickItem(v)
        end)
        if i == 1 then
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = slot.selectobj
            self.selectgo:SetActive(true)
            self:ClickItem(v)
        end
        slot.gameObject:SetActive(true)
    end
end

function EncyclopediaMedicine:ClickItem(info)
    self.nameTxt.text = ColorHelper.color_item_name(info.quality, info.name)
    self.itemCell:SetAll(info, extra)
    self.itemCell:ShowNum(false)
    self.bindObj:SetActive(info.bind == 1)
    info.base_id = info.id
    local ddesc = info.desc

    -- 处理品阶描述显示
    -- print(info.base_id)
    -- BaseUtils.dump(info,"asdsdsaasdsadsa")
    if info.step ~= nil and info.step ~= 0 then
        self.otherTxt.text = string.format(TI18N("品阶:%s"), info.step)
        local step_data = DataSkillLife.data_fight_effect[string.format("%s_%s", info.base_id, info.step)]
        if step_data ~= nil then
            ddesc = string.gsub(ddesc, "%[skill_life1%]", tostring(step_data.args[1]))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", tostring(step_data.args[2]))
        else
            ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
        end
    else
        self.otherTxt.text = ""
        ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
        ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
    end

    self.height = 105

    -- 处理描述显示
    local th = 0
    local descStr = ""

    -- 处理有效时间显示
    if info.expire_type == nil or info.expire_type == BackpackEumn.ExpireType.None then
        descStr = ""
    elseif info.expire_type == BackpackEumn.ExpireType.StartTime or info.expire_type == BackpackEumn.ExpireType.StartDate then
        if BaseUtils.BASE_TIME > info.expire_time then
            descStr = ""
        else
            local timeStr = string.format("%s %s", os.date("%Y-%m-%d", info.expire_time), os.date("%H:%M", info.expire_time))
            descStr = string.format(TI18N("\n<color='#00ffff'>%s 可开启</color>"), timeStr)
        end
    else
        local timeStr = string.format("%s %s", os.date("%Y-%m-%d", info.expire_time), os.date("%H:%M:00", info.expire_time))
        descStr = string.format(TI18N("\n<color='#00ffff'>过期:%s</color>"), timeStr)
    end

    if descStr ~= "" then
        self.descRect.sizeDelta = Vector2(250, 60)
        th = -65
    else
        self.descRect.sizeDelta = Vector2(250, 40)
        th = -45
    end

    self.descTxt.text = string.format(TI18N("作用:%s"), info.func) .. descStr

    local strs = {}
    for s1, s2 in string.gmatch(ddesc, "(.+);(.+)") do
        strs = {s1, s2}
    end
    if #strs == 0 then
        self.trect1.anchoredPosition = Vector2(0, th)
        self.msg1:SetData(ddesc)
        self.text1.gameObject:SetActive(true)
        self.text2.text = ""
        self.text2.gameObject:SetActive(false)
        th = th - self.msg1.selfHeight - 5
    else
        self.trect1.anchoredPosition = Vector2(0, th)
        self.msg1:SetData(strs[1])
        self.text1.gameObject:SetActive(true)
        th = th - self.msg1.selfHeight - 5

        self.trect2.anchoredPosition = Vector2(0, th)
        self.msg2:SetData(strs[2])
        self.text2.gameObject:SetActive(true)
        th = th - self.msg2.selfHeight - 5
    end

    -- 处理价格显示
    local price = BackpackEumn.GetSellPrice(info)
    if price ~= 0 and info.bind ~= 1 then
        self.trect3.anchoredPosition = Vector2(0, th)
        self.msg3:SetData(string.format(TI18N("出售价格: {assets_1,90003,%s}"), price))
        self.text3.gameObject:SetActive(true)
        th = th - self.msg3.selfHeight - 5
    else
        self.text3.text = ""
        self.text3.gameObject:SetActive(false)
    end
    self.midRect.sizeDelta = Vector2(255, math.abs(th))
    self.height = self.height + math.abs(th) + 10

    -- self.rect.sizeDelta = Vector2(self.width, self.height)
end

-- @author 黄耀聪
-- @date 2017年3月25日

TalismanFusionWindow = TalismanFusionWindow or BaseClass(BaseWindow)

function TalismanFusionWindow:__init(model)
    self.model = model
    self.name = "TalismanFusionWindow"

    self.windowId = WindowConfig.WinID.talisman_fusion

    self.resList = {
        {file = AssetConfig.talisman_fusion, type = AssetType.Main},
        {file = AssetConfig.talisman_textures, type = AssetType.Dep},
        {file = AssetConfig.talisman_set, type = AssetType.Dep},
        {file = AssetConfig.talisman_fusion_textures, type = AssetType.Dep},
    }

    self.attrDataList = {
        {key = "up_mask"},
        {key = "up_ring"},
        {key = "up_cloak"},
        {key = "up_blazon"},
    }

    self.filterData = {
        {text = TI18N("火焰套装"), conditionCallback = function(data) return data.type == 0 and DataTalisman.data_get[data.protoData.base_id].set_id == 1000 end},
        {text = TI18N("剑心套装"), conditionCallback = function(data) return data.type == 0 and DataTalisman.data_get[data.protoData.base_id].set_id == 1100 end},
        {text = TI18N("幻影套装"), conditionCallback = function(data) return data.type == 0 and DataTalisman.data_get[data.protoData.base_id].set_id == 1200 end},
        {text = TI18N("时空套装"), conditionCallback = function(data) return data.type == 0 and DataTalisman.data_get[data.protoData.base_id].set_id == 1300 end},
        {text = TI18N("光辉套装"), conditionCallback = function(data) return data.type == 0 and DataTalisman.data_get[data.protoData.base_id].set_id == 1400 end},
        {text = TI18N("掌控套装"), conditionCallback = function(data) return data.type == 0 and DataTalisman.data_get[data.protoData.base_id].set_id == 1500 end},
        {text = TI18N("狂怒者套装"), conditionCallback = function(data) return data.type == 0 and DataTalisman.data_get[data.protoData.base_id].set_id == 1600 end},
        {text = TI18N("毁灭者套装"), conditionCallback = function(data) return data.type == 0 and DataTalisman.data_get[data.protoData.base_id].set_id == 1700 end},
        {text = TI18N("预言者套装"), conditionCallback = function(data) return data.type == 0 and DataTalisman.data_get[data.protoData.base_id].set_id == 1800 end},
        {text = TI18N("守护者套装"), conditionCallback = function(data) return data.type == 0 and DataTalisman.data_get[data.protoData.base_id].set_id == 1900 end},
        {text = TI18N("子女装备"), conditionCallback = function(data) return data.type == 1 and data.protoData.type == BackpackEumn.ItemType.childattreqm or data.protoData.type == BackpackEumn.ItemType.childskilleqm end},
        {text = TI18N("宠物装备"), conditionCallback = function(data) return data.type == 1 and (data.protoData.type ~= BackpackEumn.ItemType.childattreqm and data.protoData.type ~= BackpackEumn.ItemType.childskilleqm) end},
    }

    self.maxTime = 10

    self.toggleList = {}
    self.baseAttrList = {}
    self.extraAttrList = {}
    self.pageList = {}
    self.itemList = {}

    -- 选中的法宝
    self.talismanDic = {}
    self.talismanCount = 0
    self.height = 0

    -- 选中的道具
    self.itemDic = {}
    self.itemCount = 0

    self.updateListener = function()
        self.talismanDic = {}
        self.talismanCount = 0
        self.itemCount = 0
        self.dis = 0
        self.itemDic = {}
        self:ReloadPages()
        self:ReloadNone()
        self:UpdateSlider()
        self:ReloadInfo()
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function TalismanFusionWindow:__delete()
    self.OnHideEvent:Fire()
    if self.imgLoader1 ~= nil then
        self.imgLoader1:DeleteMe()
        self.imgLoader1 = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.suitDesc ~= nil then
        self.suitDesc:DeleteMe()
        self.suitDesc = nil
    end
    if self.attrLayout ~= nil then
        self.attrLayout:DeleteMe()
        self.attrLayout = nil
    end
    if self.pageLayout ~= nil then
        self.pageLayout:DeleteMe()
        self.pageLayout = nil
    end
    if self.toggleLayout ~= nil then
        self.toggleLayout:DeleteMe()
        self.toggleLayout = nil
    end
    if self.baseAttrLayout ~= nil then
        self.baseAttrLayout:DeleteMe()
        self.baseAttrLayout = nil
    end
    if self.pageTabbedPanel ~= nil then
        self.pageTabbedPanel:DeleteMe()
        self.pageTabbedPanel = nil
    end
    if self.filter ~= nil then
        self.filter:DeleteMe()
        self.filter = nil
    end
    if self.setImage ~= nil then
        self.setImage.sprite = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.iconBgImg.sprite = nil
                v.setImage.sprite = nil
                v.iconLoader:DeleteMe()
            end
        end
    end
    self:AssetClearAll()
end

function TalismanFusionWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.talisman_fusion))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    -- ======================================== 左边 ============================================

    -- 法宝tips部分
    local tips = t:Find("Left/Tips")
    self.talismanTips = tips.gameObject
    self.headArea = tips:Find("HeadArea")
    self.iconBgImg = tips:Find("HeadArea/Slot"):GetComponent(Image)
    self.iconImg = tips:Find("HeadArea/Icon")
    self.nameText = tips:Find("HeadArea/Name"):GetComponent(Text)
    self.text1 = tips:Find("HeadArea/Text1"):GetComponent(Text)
    self.text2 = tips:Find("HeadArea/Text2"):GetComponent(Text)
    self.setImage = tips:Find("HeadArea/Set"):GetComponent(Image)

    self.line1 = tips:Find("Line1").gameObject
    self.line2 = tips:Find("Line2").gameObject

    self.attrLayout = LuaBoxLayout.New(tips:Find("Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0})

    self.baseAttr = tips:Find("Scroll/BaseAttr")
    self.baseAttrList[1] = self.baseAttr:GetChild(0):GetComponent(Text)

    self.extraAttr = tips:Find("Scroll/ExtraAttr")
    for i=0,self.extraAttr.childCount - 1 do
        self.extraAttrList[i + 1] = {gameObject = self.extraAttr:GetChild(i).gameObject, text = self.extraAttr:GetChild(i):Find("Text"):GetComponent(Text), star = self.extraAttr:GetChild(i):Find("Star"):GetComponent(Text)}
    end

    self.suitArea = tips:Find("SuitInfo").gameObject
    self.suitDesc = MsgItemExt.New(tips:Find("SuitInfo/Suits"):GetComponent(Text), 210, 16, 18.52)
    self.suitTitleText = tips:Find("SuitInfo/Title"):GetComponent(Text)
    self.suitInfoList = tips:Find("Active/Text"):GetComponent(Text)

    self.buttonArea = tips:Find("ButtonArea")

    self.line1 = tips:Find("Line1").gameObject
    self.line2 = tips:Find("Line2").gameObject

    self.baseAttrLayout = LuaBoxLayout.New(self.baseAttr, {axis = BoxLayoutAxis.Y, cspacing = 5})
    self.baseAttrList[1] = self.baseAttr:GetChild(0):GetComponent(Text)

    self.infoObj = t:Find("Left/Info").gameObject
    self.descObj = t:Find("Left/Desc").gameObject
    self.descExt = MsgItemExt.New(t:Find("Left/Desc/Text"):GetComponent(Text), 190, 16, 18.52)
    self.infoText = t:Find("Left/Info/Text"):GetComponent(Text)
    t:Find("Left/Info/Fire").anchoredPosition = Vector2(-78, 0)
    self.infoText.transform.anchoredPosition = Vector2(18, 0)
    self.infoText.transform.sizeDelta = Vector2(180, 32)

    self.infoObj:SetActive(false)

    -- 子女装备tips
    self.petEquitTips = self.transform:Find("Left/PetEquit").gameObject
    local head = self.petEquitTips.transform:Find("HeadArea")
    self.itemCell = ItemSlot.New(head:Find("ItemSlot").gameObject)
    self.itemCell:SetNotips()
    self.itemCell:ShowEnchant(true)
    self.nameTxt = head:Find("Name"):GetComponent(Text)
    self.typeTxt = head:Find("Type"):GetComponent(Text)
    self.bindObj = head:Find("Bind").gameObject

    local mid = self.petEquitTips.transform:Find("MidArea")
    self.midLine = mid:Find("Line").gameObject
    self.descTxt = mid:Find("Desc"):GetComponent(Text)
    self.midLineRect = self.midLine:GetComponent(RectTransform)
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.attrContainer = mid:Find("EqmAtrribute").gameObject
    self.attrContainerTxt = self.attrContainer:GetComponent(Text)
    self.eqmBase = mid:Find("EqmBase").gameObject
    self.eqmBaseTxt = mid:Find("EqmBase/EqmBaseText").gameObject
    self.eqmBaseTxt:SetActive(false)
    self.petEquitLayout = LuaBoxLayout.New(mid:Find("Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 1, border = 0})

    self.descRect = self.descTxt.gameObject:GetComponent(RectTransform)
    self.eqmRect = self.attrContainer:GetComponent(RectTransform)

    -- ============================================== 右边 ===============================================
    self.slider = t:Find("Right/Slider"):GetComponent(Slider)
    self.insideSlider = t:Find("Right/Slider/Slider"):GetComponent(Slider)
    self.sliderText = t:Find("Right/Slider/Text"):GetComponent(Text)
    self.titleIconBgImg = t:Find("Right/IconBg"):GetComponent(Image)
    self.titleIconImg = t:Find("Right/IconBg/Icon"):GetComponent(Image)
    self.toggleLayout = LuaBoxLayout.New(t:Find("Right/Toggle"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 10})
    self.toggleCloner = t:Find("Right/Toggle/Cloner").gameObject
    self.pageCloner = t:Find("Right/Scroll/Page").gameObject
    self.pageLayout = LuaBoxLayout.New(t:Find("Right/Scroll/Container"), {axis = BoxLayoutAxis.X, cspacing = 0})
    self.pageTabbedPanel = TabbedPanel.New(t:Find("Right/Scroll").gameObject, 0, 267.62, 0.5)
    self.pageTabbedPanel.MoveEndEvent:AddListener(function(page) self:OnMoveEnd(page) end)

    self.button = t:Find("Right/Button"):GetComponent(Button)

    self.filterBtn = t:Find("Right/Filter"):GetComponent(Button)
    self.filterArrow = t:Find("Right/Filter/Image")
    self.filterArea = t:Find("Right/FilterArea")

    self.button.onClick:AddListener(function() self:OnFusion() end)
    t:Find("Right/Close"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    t:Find("Right/Title/Text"):GetComponent(Text).text = TI18N("宝物熔炼")
    self.filterBtn.onClick:AddListener(function() self:OnFilter() end)

    self.filter = TalismanFilter.New(self.filterArea)
    self.filter:SetData(self.filterData, {allEnd = true})
    self.filter.filterCallback = function(datalist) self:UpdatePage(datalist) end
    self.filter:Hide()
end

function TalismanFusionWindow:OnInitCompleted()
    self.transform:Find("Panel"):GetComponent(Button).onClick:RemoveAllListeners()
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.OnOpenEvent:Fire()
end

function TalismanFusionWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.talisman_item_change, self.updateListener)

    self.fusion_lev = self.model.fusion_lev or 0
    self.fusion_val = self.model.fusion_val or 0

    self:ReloadPages()
    self:SetSlider(0)
    self:ReloadNone()

    self:ReloadInfo()
end

function TalismanFusionWindow:OnHide()
    self:RemoveListeners()
    if self.sliderTweenId ~= nil then
        Tween.Instance:Cancel(self.sliderTweenId)
        self.sliderTweenId = nil
    end
end

function TalismanFusionWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.talisman_item_change, self.updateListener)
end

function TalismanFusionWindow:ReloadTips(data)
    if data == nil then
        self:ReloadNone()
    elseif data.type == 0 then
        self:ReloadTalismanTips(data)
    else
        self:ReloadItemTips(data)
    end
end

-- 背包数据
function TalismanFusionWindow:ReloadItemTips(data)
    self.descObj:SetActive(false)
    self.talismanTips:SetActive(false)
    self.petEquitTips:SetActive(true)
    local info = data.protoData
    self.itemData = info
    self.extra = extra
    self.nameTxt.text = info.name
    self.typeTxt.text = TI18N("类型:宠物装备")
    if info.type == BackpackEumn.ItemType.childattreqm or info.type == BackpackEumn.ItemType.childskilleqm then
        self.typeTxt.text = TI18N("类型:子女装备")
    end
    self.setImage.gameObject:SetActive(false)
    self.descTxt.text = info.desc
    self.itemCell:SetAll(info)
    self.bindObj:SetActive(info.bind == 1)

    --加上上部分的高度
    self.height = self.height + 90

    self.descRect.sizeDelta = Vector2(210, self.descTxt.preferredHeight)
    self.eqmRect.anchoredPosition = Vector2(0, -self.descTxt.preferredHeight-10)

    --加上换行的高度
    self.height = self.height + self.descTxt.preferredHeight + 10

    -- 处理属性显示
    local list = nil
    if info.attr ~= nil and #info.attr > 0 then
        list = info.attr
        -- self:ParseAttribute(info.attr)
    else
        list = {}
        for i,v in ipairs(info.effect) do
            if v.effect_type == 51 then
                local skills = DataItem.data_stone_skill[v.val[1][2]].list
                for i,v in ipairs(skills) do
                    table.insert(list, {name = 100, val = v})
                end
            end
        end
    end
    self:ParseAttribute(list)

    self.petEquitLayout:ReSet()
    self.petEquitLayout:AddCell(self.descRect.gameObject)
    -- self.petEquitLayout:AddCell(self.eqmBase)
    if #list > 0 then
        self.petEquitLayout:AddCell(self.attrContainer)
    else
        self.attrContainer:SetActive(false)
    end
end
-- 处理属性显示
function TalismanFusionWindow:ParseAttribute(attr)
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
        -- btn.onClick:AddListener(function() TipsManager.Instance:ShowSkill(info, special) end)
        txt.transform.anchoredPosition = Vector2(30, -20-(count-1)*25)
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
        txt.transform.anchoredPosition = Vector2(30, -20-(count-1)*25)
        count = count + 1
    end

    for i = count,count1 do
        GameObject.Destroy(self.attrContainer.transform:GetChild(i - 1).gameObject)
    end

    local heqm = 0
    heqm = 25 * count + 10
    self.height = self.height + heqm
    self.eqmRect.sizeDelta = Vector2(210, heqm)
    -- self.midRect.sizeDelta = Vector2(210, self.descTxt.preferredHeight+heqm+10)
    -- self.midLineRect.anchoredPosition = Vector2(0, -(self.descTxt.preferredHeight+heqm+10))
    self.height = self.height + 10
end

-- 法宝协议数据
function TalismanFusionWindow:ReloadTalismanTips(data)
    self.descObj:SetActive(false)
    self.talismanTips:SetActive(true)
    self.petEquitTips:SetActive(false)
    local cfgData = DataTalisman.data_get[data.protoData.base_id]
    self.setImage.gameObject:SetActive(true)
    self.setImage.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfgData.set_id))
    self.nameText.text = ColorHelper.color_item_name(cfgData.quality, TalismanEumn.FormatQualifyName(cfgData.quality, cfgData.name))
    if self.imgLoader1 == nil then
        self.imgLoader1 = SingleIconLoader.New(self.iconImg.gameObject)
    end
    self.imgLoader1:SetSprite(SingleIconType.Item, cfgData.icon)

    self.text1.text = string.format(TI18N("%s级 %s"), tostring(cfgData.lev), TalismanEumn.Name[TalismanEumn.TypeProto[cfgData.type]])
    self.text2.text = string.format(TI18N("评分:%s"), tostring(TalismanManager.Instance.model.itemDic[data.protoData.id].fc or 0))

    -- self.totalLayout:AddCell(self.headArea.gameObject)
    -- self.totalLayout:AddCell(self.line1)

    self.attrLayout:ReSet()

    local baseAttrData = {}
    local extraAttrData = {}
    for i,v in ipairs(data.protoData.attr) do
        if v.type == 7 then
            table.insert(baseAttrData, v)
        elseif v.type == 9 then
            table.insert(extraAttrData, v)
        end
    end

    -- 基础属性
    self.baseAttrLayout:ReSet()
    local add = 0
    for i,v in ipairs(baseAttrData) do
        local attr = self.baseAttrList[i]
        if attr == nil then
            attr = GameObject.Instantiate(self.baseAttrList[1].gameObject):GetComponent(Text)
            self.baseAttrList[i] = attr
        end
        self.baseAttrLayout:AddCell(attr.gameObject)

        add = BaseUtils.Round(v.val * DataTalisman.data_fusion[TalismanManager.Instance.model.fusion_lev or 0][self.attrDataList[TalismanEumn.TypeProto[cfgData.type]].key] / 1000)
        if add > 0 then
            if KvData.prop_percent[v.name] == nil then
                attr.text = string.format("%s<color='%s'>+%s</color><color='%s'>(+%s)</color>", KvData.attr_name[v.name], ColorHelper.color[1], v.val, ColorHelper.color[2], add)
            else
                attr.text = string.format("%s<color='%s'>+%s</color><color='%s'>(+%s%%)</color>", KvData.attr_name[v.name], ColorHelper.color[1], v.val, ColorHelper.color[2], add/10)
            end
        elseif add < 0 then
            if KvData.prop_percent[v.name] == nil then
                attr.text = string.format("%s<color='%s'>+%s</color><color='%s'>(-%s)</color>", KvData.attr_name[v.name], ColorHelper.color[1], v.val, ColorHelper.color[6], -add)
            else
                attr.text = string.format("%s<color='%s'>+%s</color><color='%s'>(-%s%%)</color>", KvData.attr_name[v.name], ColorHelper.color[1], v.val, ColorHelper.color[6], -add/10)
            end
        else
            if KvData.prop_percent[v.name] == nil then
                attr.text = string.format("%s<color='%s'>+%s</color>", KvData.attr_name[v.name], ColorHelper.color[1], v.val)
            else
                attr.text = string.format("%s<color='%s'>+%s%%</color>", KvData.attr_name[v.name], ColorHelper.color[1], v.val/10)
            end
        end
    end
    for i=#baseAttrData + 1, #self.baseAttrList do
        self.baseAttrList[i].gameObject:SetActive(false)
    end

    self.attrLayout:AddCell(self.baseAttrLayout.panel.gameObject)

    -- 额外属性
    local extraAttr = nil
    table.sort(extraAttrData, function(a,b) return (TalismanEumn.DecodeFlag(a.flag, 2)) > (TalismanEumn.DecodeFlag(b.flag, 2)) end)
    for i,v in ipairs(self.extraAttrList) do
        extraAttr = extraAttrData[i]
        if extraAttr == nil then
            v.gameObject:SetActive(false)
        else
            v.gameObject:SetActive(true)
            add = TalismanEumn.DecodeFlag(extraAttr.flag, 2)
            v.star.text = ""

            if KvData.attr_name[extraAttr.name] == nil then
                v.text.text = TI18N("可洗练")
            elseif add == 6 then
                v.text.text = string.format("<color='#ff00ff'>%s</color>", KvData.GetAttrStringNoColor(extraAttr.name, extraAttr.val, TalismanEumn.DecodeFlag(extraAttr.flag, 3)))
            else
                v.text.text = string.format("%s", KvData.GetAttrStringNoColor(extraAttr.name, extraAttr.val, TalismanEumn.DecodeFlag(extraAttr.flag, 3)))
            end
        end
    end
    self.extraAttr.transform.sizeDelta = Vector2(210, 30 * #extraAttrData)
    self.attrLayout:AddCell(self.extraAttr.gameObject)

    -- 套装
    local talismanList = TalismanManager.Instance.model.suitItemSet[cfgData.set_id]
    local planData = TalismanManager.Instance.model.planList[TalismanManager.Instance.model.use_plan or 1]
    local nameList = {}
    local orderList = {}
    for i,base_id in ipairs(talismanList) do
        local tab = {index = i}
        if planData[i] ~= nil and cfgData.set_id == DataTalisman.data_get[TalismanManager.Instance.model.itemDic[planData[i].id].base_id].set_id then
            tab.order = 7
            table.insert(nameList, string.format("<color='#00ff00'>%s</color>", DataTalisman.data_get[base_id].name))
        else
            tab.order = 0
            table.insert(nameList, DataTalisman.data_get[base_id].name)
        end
        orderList[i] = tab
    end
    table.sort(orderList, function(a,b) if a.order == b.order then return a.index < b.index else return a.order > b.order end end)
    local resList = {}
    for i,v in ipairs(orderList) do
        resList[i] = nameList[v.index]
    end
    resList[3] = "\n" .. resList[3]
    self.suitTitleText.text = DataTalisman.data_set[cfgData.set_id].set_name
    self.suitDesc:SetData(table.concat(resList, " "))
    self.suitArea.transform.sizeDelta = Vector2(230, self.suitDesc.contentRect.sizeDelta.y - self.suitDesc.contentRect.anchoredPosition.y)
    self.attrLayout:AddCell(self.suitArea)

    -- 激活的技能
    local activeSkillList = TalismanManager.Instance:GetSkillList()
    local setCfgData = DataTalisman.data_set[cfgData.set_id]

    local nameString = nil
    local bool = false
    local skill_id_2 = setCfgData[string.format("skills_%s_%s",TalismanEumn.Qualify[cfgData.quality],2)][1][2]
    local skill_id_4 = setCfgData[string.format("skills_%s_%s",TalismanEumn.Qualify[cfgData.quality],4)][1][2]
    for i,v in ipairs(activeSkillList) do
        if v == skill_id_2 then
            nameString = string.format("<color='#ff00ff'>%s</color>", DataSkill.data_talisman_skill[skill_id_2 .. "_1"].name)
            bool = true
            break
        end
    end
    if not bool then
        nameString = DataSkill.data_talisman_skill[skill_id_2 .. "_1"].name
    end
    local str = string.format(TI18N("2件套激活: %s"), tostring(nameString))

    bool = false
    for i,v in ipairs(activeSkillList) do
        if v == skill_id_4 then
            nameString = string.format("<color='#ff00ff'>%s</color>", DataSkill.data_talisman_skill[skill_id_4 .. "_1"].name)
            bool = true
            break
        end
    end
    if not bool then
        nameString = DataSkill.data_talisman_skill[skill_id_4 .. "_1"].name
    end
    str = str .. "\n" .. string.format(TI18N("4件套激活: %s"), tostring(nameString))
    self.suitInfoList.text = str
    self.suitInfoList.transform.sizeDelta = Vector2(210, math.ceil(self.suitInfoList.preferredHeight))
    self.attrLayout:AddCell(self.suitInfoList.gameObject)
end

function TalismanFusionWindow:ReloadToggles(page)
    self.toggleLayout:ReSet()
    for i=1,page do
        local toggle = self.toggleList[i]
        if toggle == nil then
            toggle = {}
            toggle.gameObject = GameObject.Instantiate(self.toggleCloner)
            toggle.transform = toggle.gameObject.transform
            toggle.select = toggle.transform:Find("Select").gameObject
            self.toggleList[i] = toggle
        end
        self.toggleLayout:AddCell(toggle.gameObject)
        toggle.select:SetActive(false)
    end
    for i=page+1,#self.toggleList do
        self.toggleList[i].gameObject:SetActive(false)
    end
    self.toggleCloner:SetActive(false)
end

function TalismanFusionWindow:OnMoveEnd(page)
    self.model.lastFusionPage = page
    for i,v in ipairs(self.toggleList) do
        v.select:SetActive(page == i)
    end
end

function TalismanFusionWindow:UpdatePage(datalist)
    local pageCount = math.ceil(#datalist / 9)
    if pageCount < 3 then pageCount = 3 end

    self.pageLayout:ReSet()
    for i=1,pageCount do
        local page = self.pageList[i]
        if page == nil then
            page = {}
            page.gameObject = GameObject.Instantiate(self.pageCloner)
            page.transform = page.gameObject.transform
            local count = page.transform.childCount
            for j=1,9 do
                local item = self.itemList[(i - 1) * 9 + j]
                if item == nil then
                    item = {}
                    item.transform = page.transform:GetChild(j - 1)
                    item.gameObject = item.transform.gameObject
                    item.button = item.gameObject:GetComponent(Button)
                    item.iconBgImg = item.transform:Find("Bg"):GetComponent(Image)
                    item.iconLoader = SingleIconLoader.New(item.transform:Find("Icon").gameObject) -- :GetComponent(Image)
                    item.select = item.transform:Find("Select").gameObject
                    item.suiting = item.transform:Find("Suiting").gameObject
                    item.numBg = item.transform:Find("NumBg").gameObject
                    item.extBg = item.transform:Find("ExtBg")
                    item.ext = item.transform:Find("Ext"):GetComponent(Text)
                    item.numText = item.transform:Find("NumBg/Text"):GetComponent(Text)
                    item.setImage = item.transform:Find("Set"):GetComponent(Image)
                    item.transitionBtn = item.gameObject:GetComponent(TransitionButton)
                    self.itemList[(i - 1) * 9 + j] = item
                    item.button.onClick:AddListener(function() self:OnClick(item) end)
                end
            end
            self.pageList[i] = page
        end
        self.pageLayout:AddCell(page.gameObject)
    end
    for i=pageCount + 1,#self.pageList do
        self.pageList[i].gameObject:SetActive(false)
    end
    for i=1,pageCount * 9 do
        self:SetItem(self.itemList[i], datalist[i])
    end

    self.pageTabbedPanel:SetPageCount(pageCount)

    self.pageCloner:SetActive(false)
    self:ReloadToggles(pageCount)
    self.pageTabbedPanel:TurnPage(self.model.lastFusionPage or 1)
end

function TalismanFusionWindow:ReloadPages()
    local datalist = {}

    for _,v in pairs(self.model.itemDic) do
        if self.model.useItemDic[v.id] == nil then
            table.insert(datalist, {type = 0, protoData = v})
        end
    end
    for _,v in pairs(BackpackManager.Instance.itemDic) do
        if DataTalisman.data_bag_fusion[v.base_id] ~= nil then
            table.insert(datalist, {type = 1, protoData = v})
        end
    end
    table.sort(datalist, function(a,b)
        if a.type == b.type then
            if a.type == 0 then
                return self.model:Sort(a.protoData.id, b.protoData.id)
            else
                return a.protoData.base_id < b.protoData.base_id
            end
        else
            return a.type > b.type
        end
    end)

    self.filter.datalist = datalist
    self:UpdatePage(self.filter:Filter())
end

function TalismanFusionWindow:SetItem(item, data)
    item.data = data
    if data == nil then
        item.iconBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level2")
        item.iconLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Twills"))
        item.select:SetActive(false)
        item.numBg:SetActive(false)
        item.transitionBtn.scaleSetting = false
        item.transitionBtn.soundSetting = false
        item.extBg.gameObject:SetActive(false)
        item.setImage.gameObject:SetActive(false)
        item.ext.text = nil
    else
        item.transitionBtn.scaleSetting = true
        item.transitionBtn.soundSetting = true

        if data.type == 0 then
            local cfgData = DataTalisman.data_get[data.protoData.base_id]
            item.setImage.gameObject:SetActive(true)
            item.iconBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level" .. cfgData.quality)
            item.setImage.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfgData.set_id))
            item.iconLoader:SetSprite(SingleIconType.Item, cfgData.icon)

            item.numBg.gameObject:SetActive(false)
            item.extBg.gameObject:SetActive(false)
            item.ext.gameObject:SetActive(false)
            item.ext.text = string.format("+%s", cfgData.fusion_val)

            item.select:SetActive(self.talismanDic[data.protoData.id] ~= nil)
        else
            item.setImage.gameObject:SetActive(false)
            item.iconBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level2")

            item.iconLoader:SetSprite(SingleIconType.Item, data.protoData.icon)

            if data.protoData.quantity > 1 then
                item.numBg.gameObject:SetActive(true)
                item.numText.text = data.protoData.quantity
            else
                item.numBg.gameObject:SetActive(false)
            end
            item.extBg.gameObject:SetActive(false)
            item.ext.gameObject:SetActive(false)
            item.ext.text = string.format("+%s", DataTalisman.data_bag_fusion[data.protoData.base_id].val)

            item.select:SetActive(self.itemDic[data.protoData.id] ~= nil)
        end
    end
end

function TalismanFusionWindow:OnClick(item)
    if item.data == nil then
        return
    end

    local add = 0
    local data = nil

    local time = self.maxTime - self.model.times

    if item.data.type == 0 then
        -- 法宝
        if self.talismanDic[item.data.protoData.id] == nil then
            -- if self.itemCount + self.talismanCount >= time then
            -- if self.talismanCount >= time then
                -- NoticeManager.Instance:FloatTipsByString(TI18N("今日炼化宝物已达上限"))
                -- return
            -- end

            self.talismanCount = self.talismanCount + 1
            self.talismanDic[item.data.protoData.id] = 1
            item.select:SetActive(true)
            item.extBg.gameObject:SetActive(true)
            item.ext.gameObject:SetActive(true)
            add = DataTalisman.data_get[item.data.protoData.base_id].fusion_val
            data = item.data
        else
            self.talismanCount = self.talismanCount - 1
            self.talismanDic[item.data.protoData.id] = nil
            item.select:SetActive(false)
            item.extBg.gameObject:SetActive(false)
            item.ext.gameObject:SetActive(false)
            add = -DataTalisman.data_get[item.data.protoData.base_id].fusion_val
            data = nil
        end
    else
        -- 背包
        if self.itemDic[item.data.protoData.id] == nil then
            -- if self.talismanCount >= time then
            --     NoticeManager.Instance:FloatTipsByString(TI18N("今日炼化宝物已达上限"))
            --     return
            -- end

            self.itemCount = self.itemCount + 1
            self.itemDic[item.data.protoData.id] = 1
            item.select:SetActive(true)
            item.extBg.gameObject:SetActive(true)
            item.ext.gameObject:SetActive(true)
            add = DataTalisman.data_bag_fusion[item.data.protoData.base_id].val * item.data.protoData.quantity
            data = item.data
        else
            self.itemCount = self.itemCount - 1
            self.itemDic[item.data.protoData.id] = nil
            item.select:SetActive(false)
            item.extBg.gameObject:SetActive(false)
            item.ext.gameObject:SetActive(false)
            add = -DataTalisman.data_bag_fusion[item.data.protoData.base_id].val * item.data.protoData.quantity
            data = nil
        end
    end
    item.ext.transform.sizeDelta = Vector2(item.ext.preferredWidth + 5, 24)
    item.extBg.sizeDelta = Vector2(item.ext.transform.sizeDelta.x, item.ext.transform.sizeDelta.y)

    self:SetSlider(add)
    self:ReloadTips(data)
end

function TalismanFusionWindow:SetSlider(add)
    add = add or 0
    local model = self.model
    local fusionData = DataTalisman.data_fusion[model.fusion_lev or 0]

    self.dis = (self.dis or 0) + add
    self.slider.value = (model.fusion_val or 0) / fusionData.need_val

    local nextVal = self.dis + (model.fusion_val or 0)
    if self.dis == 0 then
        self.insideSlider.value = nextVal / fusionData.need_val
        self.sliderText.text = string.format("%s/%s", tostring(model.fusion_val or 0), fusionData.need_val)
    elseif nextVal >= fusionData.need_val then
        self.insideSlider.value = 1
        self.sliderText.text = string.format("%s+<color='#00ff00'>%s</color>/%s", tostring(model.fusion_val or 0), tostring(self.dis), fusionData.need_val)
    else
        self.insideSlider.value = nextVal / fusionData.need_val
        self.sliderText.text = string.format("%s+<color='#00ff00'>%s</color>/%s", tostring(model.fusion_val or 0), tostring(self.dis), fusionData.need_val)
    end
end

-- 什么都没选中
function TalismanFusionWindow:ReloadNone()
    self.descObj:SetActive(true)
    self.talismanTips:SetActive(false)
    self.petEquitTips:SetActive(false)

--     self.descExt:SetData(string.format(TI18N([[1.选中右侧的<color='#00ff00'>宝物</color>、<color='#00ff00'>子女装备</color>，点击熔宝可获得对应熔炼经验

-- 2.每日最多可熔炼<color='#00ff00'>%s件宝物</color>]]), self.maxTime))
    self.descExt:SetData(TI18N([[选中右侧的<color='#00ff00'>宝物</color>、<color='#00ff00'>子女装备</color>，点击熔宝可获得对应熔炼经验]]))

    local size = self.descExt.contentRect.sizeDelta
    self.descExt.contentRect.anchoredPosition = Vector2(-size.x / 2, size.y / 2)
end

function TalismanFusionWindow:ReloadInfo()
    local times = self.model.times
    -- self.infoText.text = string.format(TI18N("今日已炼宝物:<color>%s/%s</color>"), (times or 0), self.maxTime)
    self.titleIconImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_fusion_textures, DataTalisman.data_fusion[self.model.fusion_lev or 0].icon)
end

-- 发起熔炼
function TalismanFusionWindow:OnFusion()
    local talismanList = {}
    local backpackList = {}
    for id,v in pairs(self.talismanDic) do
        if v ~= nil then table.insert(talismanList, {id1 = id}) end
    end
    for id,v in pairs(self.itemDic) do
        if v ~= nil then table.insert(backpackList, {id2 = id}) end
    end

    -- if #talismanList > self.maxTime then
    if #backpackList + #talismanList > 0 then
        self.model.old_fusion_lev = self.fusion_lev
        self.model.old_fusion_val = self.fusion_val
        TalismanManager.Instance:send19606(talismanList, backpackList)
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.talisman_window, {2})
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要熔炼的法宝和道具"))
    end
end

function TalismanFusionWindow:UpdateSlider()
    self.addEffect = 0
    self:GoTween()
end

-- 进度条缓动
function TalismanFusionWindow:GoTween()
    if self.fusion_val == self.model.fusion_val and self.fusion_lev == self.model.fusion_lev then
        return
    end
    if self.sliderTweenId ~= nil then
        Tween.Instance:Cancel(self.sliderTweenId)
        self.sliderTweenId = nil
    end
    if self.fusion_lev == self.model.fusion_lev then
        self.dis = 0
        self.fusion_val = self.model.fusion_val or 0
        self.sliderTweenId = Tween.Instance:ValueChange(self.slider.value, (self.fusion_val or 0) / DataTalisman.data_fusion[self.fusion_lev].need_val, 0.3,
        function()
            self.sliderTweenId = nil
            self:SetSlider()
            self.addEffect = self.addEffect + 1
        end
        , LeanTweenType.linear, function(value) self.slider.value = value self.insideSlider.value = 0 end).id
    else
        self.insideSlider.value = 0
        self.dis = self.dis - (DataTalisman.data_fusion[self.fusion_lev].need_val - self.fusion_val)
        self.fusion_val = DataTalisman.data_fusion[self.fusion_lev].need_val
        self.fusion_lev = self.fusion_lev + 1
        self.sliderTweenId = Tween.Instance:ValueChange(self.slider.value, (self.fusion_val or 0) / DataTalisman.data_fusion[self.fusion_lev - 1].need_val, 0.3, function()
                self.slider.value = 0
                self.addEffect = self.addEffect + 1
                self:GoTween()
            end, LeanTweenType.linear, function(value) self.slider.value = value self.insideSlider.value = 0 end).id
    end
end

function TalismanFusionWindow:Close()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.talisman_window, {2, self.addEffect})
end

-- 点击筛选按钮
function TalismanFusionWindow:OnFilter()
    if self.filter ~= nil then
        if self.filter.isShow then
            self.filterArrow.localScale = Vector3(1, 1, 1)
            self.filter:Hide()
        else
            self.filterArrow.localScale = Vector3(1, -1, 1)
            self.filter:Show()
        end
    end
end


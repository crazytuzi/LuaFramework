-- @author 黄耀聪
-- @date 2017年4月1日

TalismanTipsDrop = TalismanTipsDrop or BaseClass()

function TalismanTipsDrop:__init(model, gameObject, assetWrapper)
    self.model = model
    self.assetWrapper = assetWrapper
    self.gameObject = gameObject
    self.transform = gameObject.transform

    self.attrDataList = {
        {key = "up_mask"},
        {key = "up_ring"},
        {key = "up_cloak"},
        {key = "up_blazon"},
    }

    self.baseAttrList = {}
    self.extraAttrList = {}
    self.suitInfoList = {}
    self.buttonList = {}

    self.dropBaseAttrList = {}
    self.dropExtraAttrList = {}

    self.unloadFunc = function() self:UnloadTalisman() end
    self.loadFunc = function() self:LoadTalisman() end
    self.absorbFunc = function() self:Absorb() end
    self.fusionFunc = function() self:Fusion() end

    self:InitPanel()
end

function TalismanTipsDrop:InitPanel()
    self.rect = self.transform

    local btn = self.gameObject:GetComponent(Button)
    if btn == nil then
        btn = self.gameObject:AddComponent(Button)
    end
    btn.onClick:AddListener(function() self.model:Closetips() end)

    local t = self.transform

    -- self.totalLayout = LuaBoxLayout.New(self.transform, {axis = BoxLayoutAxis.Y, cspacing = 20})

    self.headArea = t:Find("HeadArea")
    self.iconBgImg = t:Find("HeadArea/Slot"):GetComponent(Image)
    self.iconImg = t:Find("HeadArea/Icon")
    self.nameText = t:Find("HeadArea/Name"):GetComponent(Text)
    self.text1 = t:Find("HeadArea/Text1"):GetComponent(Text)
    self.text2 = t:Find("HeadArea/Text2"):GetComponent(Text)
    self.previewBtn = t:Find("HeadArea/Preview"):GetComponent(Button)
    self.equit = t:Find("HeadArea/Equit").gameObject
    self.setImage = t:Find("HeadArea/Set"):GetComponent(Image)
    self.previewBtn.gameObject:SetActive(false)

    self.line1 = t:Find("Line1").gameObject
    self.line2 = t:Find("Line2").gameObject

    self.attrLayout = LuaBoxLayout.New(t:Find("Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.scrollRect = t:Find("Scroll")
    self.scrollRect.pivot = Vector2(0.5, 1)
    self.scrollRect.anchoredPosition = Vector2(0, -108)
    self.baseAttr = t:Find("Scroll/BaseAttr")
    self.baseAttrList[1] = self.baseAttr:GetChild(0):GetComponent(Text)

    self.extraAttr = t:Find("Scroll/ExtraAttr")
    for i=0,self.extraAttr.childCount - 2 do
        self.extraAttrList[i + 1] = {transform = self.extraAttr:GetChild(i), gameObject = self.extraAttr:GetChild(i).gameObject, text = self.extraAttr:GetChild(i):Find("Text"):GetComponent(Text), star = self.extraAttr:GetChild(i):Find("Star"):GetComponent(Text), icon = self.extraAttr:GetChild(i):Find("Icon"):GetComponent(Image)}
    end
    self.extraText = self.extraAttr:GetChild(self.extraAttr.childCount - 1):GetComponent(Text)
    self.extraText.text = TI18N("有机会获得")

    self.suitArea = t:Find("SuitInfo").gameObject
    self.suitDesc = MsgItemExt.New(t:Find("SuitInfo/Suits"):GetComponent(Text), 230, 16, 18.52)
    self.suitTitleText = t:Find("SuitInfo/Title"):GetComponent(Text)
    self.suitInfoList[1] = {text = t:Find("Active1"):GetComponent(Text), btn = t:Find("Active1"):GetComponent(Button)}
    self.suitInfoList[2] = {text = t:Find("Active2"):GetComponent(Text), btn = t:Find("Active2"):GetComponent(Button)}

    self.restraint = t:Find("Restraint").gameObject
    self.restraintText = self.restraint.transform:Find("Text"):GetComponent(Text)

    self.buttonArea = t:Find("ButtonArea")
    self.buttonArea.anchorMax = Vector2(0.5,0)
    self.buttonArea.anchorMin = Vector2(0.5,0)
    self.buttonArea.pivot = Vector2(0.5,0)
    self.buttonArea.anchoredPosition = Vector2(0, 10)

    self.line1 = t:Find("Line1").gameObject
    self.line2 = t:Find("Line2").gameObject

    self.baseAttrLayout = LuaBoxLayout.New(self.baseAttr, {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.baseAttrList[1] = self.baseAttr:GetChild(0):GetComponent(Text)

    self.buttonCloner = t:Find("ButtonArea/Area").gameObject
    self.buttonGrid = LuaGridLayout.New(t:Find("ButtonArea"), {column = 2, bordertop = 0, borderleft = 0, cspacing = 0, rspacing = 0, cellSizeX = 125, cellSizeY = 55})
end

function TalismanTipsDrop:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
end

function TalismanTipsDrop:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function TalismanTipsDrop:UpdateInfo(data, extra)
    if data == nil then return end

    self.data = data
    self.attrLayout:ReSet()
    self.nobutton = (extra ~= nil and extra.nobutton or false)
    local talismanModel = TalismanManager.Instance.model

    local planData = nil
    if data.id ~= nil and data.id > 0 and not self.nobutton then
        planData = talismanModel.itemDic[(talismanModel.planList[talismanModel.use_plan or 1][TalismanEumn.TypeProto[DataTalisman.data_get[talismanModel.itemDic[data.id].base_id].type]] or {}).id or 0]
    end

    self.equit:SetActive(planData ~= nil and planData.id == data.id)
    -- self.totalLayout:ReSet()

    local cfgData = nil
    cfgData = DataTalisman.data_get[data.base_id]
    if cfgData == nil then
        -- 搞事情
        cfgData = DataTalisman.data_get[data.id]
        if cfgData ~= nil then
            data.base_id = data.id
            data.id = nil
        end
    end

    self.setImage.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfgData.set_id))
    self.iconBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level" .. cfgData.quality)
    self.nameText.text = ColorHelper.color_item_name(cfgData.quality, TalismanEumn.FormatQualifyName(cfgData.quality, cfgData.name))
    if self.imgLoader == nil then
        local go = self.iconImg.gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, cfgData.icon)

    if data.id ~= nil and data.id > 0 then
        -- data 是协议数据
        self:ReloadProtoInfo(data)
    else
        -- data 是配置数据
        self:ReloadBaseInfo(data)
    end
    -- 套装
    local talismanList = TalismanManager.Instance.model.suitItemSet[cfgData.set_id]
    local nameList = {}
    local orderList = {}
    local planData = TalismanManager.Instance.model.planList[TalismanManager.Instance.model.use_plan or 1]
    for i,base_id in ipairs(talismanList) do
        local tab = {index = i}
        if (planData[i] ~= nil and TalismanManager.Instance.model.itemDic[planData[i].id] ~= nil) and data.fc ~= nil and cfgData.set_id == DataTalisman.data_get[TalismanManager.Instance.model.itemDic[planData[i].id].base_id].set_id then
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
    self.suitTitleText.text = DataTalisman.data_set[DataTalisman.data_get[data.base_id].set_id].set_name
    resList[3] = "\n" .. resList[3]
    self.suitDesc:SetData(table.concat(resList, " "))
    self.suitArea.transform.sizeDelta = Vector2(230, self.suitDesc.contentRect.sizeDelta.y - self.suitDesc.contentRect.anchoredPosition.y)
    self.attrLayout:AddCell(self.suitArea)

    -- self.text1.text = string.format(TI18N("%s级 %s"), tostring(cfgData.lev), TalismanEumn.Name[TalismanEumn.TypeProto[cfgData.type]])
    -- 激活的技能
    local setCfgData = DataTalisman.data_set[cfgData.set_id]
    local skill_id_2 = setCfgData[string.format("skills_%s_%s",TalismanEumn.Qualify[cfgData.quality],2)][1][2]
    local skill_id_4 = setCfgData[string.format("skills_%s_%s",TalismanEumn.Qualify[cfgData.quality],4)][1][2]

    local activeSkillList = nil
    if data.fc ~= nil then
        activeSkillList = TalismanManager.Instance:GetSkillList()
    else
        activeSkillList = {skill_id_2, skill_id_4}
    end

    local nameString = nil
    local bool = false
    for i,v in ipairs(activeSkillList) do
        if v == skill_id_2 then
            nameString = string.format("<color='#ff00ff'>[%s]</color>", DataSkill.data_talisman_skill[skill_id_2 .. "_1"].name)
            bool = true
            break
        end
    end
    if not bool then
        nameString = string.format("[%s]", DataSkill.data_talisman_skill[skill_id_2 .. "_1"].name)
    end
    self.suitInfoList[1].text.text = string.format(TI18N("2件套技能: %s"), tostring(nameString))

    bool = false
    for i,v in ipairs(activeSkillList) do
        if v == skill_id_4 then
            nameString = string.format("<color='#ff00ff'>[%s]</color>", DataSkill.data_talisman_skill[skill_id_4 .. "_1"].name)
            bool = true
            break
        end
    end
    if not bool then
        nameString = string.format("[%s]", DataSkill.data_talisman_skill[skill_id_4 .. "_1"].name)
    end
    self.suitInfoList[2].text.text = string.format(TI18N("4件套技能: %s"), tostring(nameString))

    self.suitInfoList[1].btn.onClick:RemoveAllListeners()
    self.suitInfoList[2].btn.onClick:RemoveAllListeners()
    self.suitInfoList[1].btn.onClick:AddListener(function() TipsManager.Instance:ShowSkill({gameObject = self.gameObject, skillData = DataSkill.data_talisman_skill[skill_id_2 .. "_1"], type = Skilltype.talisman}, true) end)
    self.suitInfoList[2].btn.onClick:AddListener(function() TipsManager.Instance:ShowSkill({gameObject = self.gameObject, skillData = DataSkill.data_talisman_skill[skill_id_4 .. "_1"], type = Skilltype.talisman}, true) end)

    self.attrLayout:AddCell(self.suitInfoList[1].btn.gameObject)
    self.attrLayout:AddCell(self.suitInfoList[2].btn.gameObject)

    -- self.totalLayout:AddCell(self.attrLayout.panel.transform.parent.gameObject)
    -- self.totalLayout:AddCell(self.line2)


    -- self.totalLayout:AddCell(self.buttonGrid.panel.gameObject)

    -- local h = self.totalLayout.panelRect.sizeDelta.y
    -- self.totalLayout.panelRect.sizeDelta = Vector2( self.totalLayout.panelRect.sizeDelta.x, h + 30)
    if self.nobutton then
        self.line2:SetActive(false)
        self.scrollRect.sizeDelta = Vector2(315, 222)
        self.transform.sizeDelta = Vector2(315, 350)
        self.buttonArea.gameObject:SetActive(false)

        if data.fc ~= nil then
            self.text2.text = string.format(TI18N("评分:%s"), tostring(data.fc))
        else
            local str = TI18N("推荐:")
            local setData = DataTalisman.data_set[cfgData.set_id]
            if #setData.perfectclass == 0 then
                str = str .. TI18N("全职业")
            else
                for i,v in ipairs(setData.perfectclass) do
                    str = str .. string.format("%s ", KvData.classes_name[v])
                end
            end
            self.text2.text = str
        end
    else
        self.line2:SetActive(true)
        self:ReloadButtons()
        self.scrollRect.sizeDelta = Vector2(315, 335 - self.buttonGrid.panelRect.sizeDelta.y)
        self.transform.sizeDelta = Vector2(315, 472)
        self.buttonArea.gameObject:SetActive(true)
        self.line2.transform.anchoredPosition = Vector2(0, self.buttonGrid.panelRect.sizeDelta.y + self.buttonGrid.panelRect.anchoredPosition.y + 10)

        local currentCfgData = DataTalisman.data_fusion[TalismanManager.Instance.model.fusion_lev or 0]
        local key = self.attrDataList[TalismanEumn.TypeProto[cfgData.type]].key
        self.text2.text = string.format(TI18N("境界加成:%s%%\n评分:%s"), tostring(currentCfgData[key] / 10), tostring(data.fc))
    end
end

function TalismanTipsDrop:ReloadProtoInfo(data)
    local cfgData = DataTalisman.data_get[data.base_id]

    -- self.totalLayout:AddCell(self.headArea.gameObject)
    -- self.totalLayout:AddCell(self.line1)

    self.attrLayout:ReSet()
    self.extraText.gameObject:SetActive(false)

    local baseAttrData = {}
    local extraAttrData = {}
    for i,v in ipairs(data.attr) do
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

        add = Mathf.Round(v.val * DataTalisman.data_fusion[TalismanManager.Instance.model.fusion_lev or 0][self.attrDataList[TalismanEumn.TypeProto[cfgData.type]].key] / 1000)
        local attrName = KvData.GetAttrName(v.name, TalismanEumn.DecodeFlag(v.flag, 3))
        if add > 0 then
            if KvData.prop_percent[v.name] == nil then
                attr.text = string.format("%s<color='%s'>+%s</color><color='%s'>(+%s)</color>", attrName, "#4bcd2e", v.val, ColorHelper.color[1], add)
            else
                attr.text = string.format("%s<color='%s'>+%s%%</color><color='%s'>(+%s%%)</color>", attrName, "#4bcd2e", v.val / 10, ColorHelper.color[1], add / 10)
            end
        elseif add < 0 then
            if KvData.prop_percent[v.name] == nil then
                attr.text = string.format("%s<color='%s'>+%s</color><color='%s'>(-%s)</color>", attrName, "#4bcd2e", v.val, ColorHelper.color[6], -add)
            else
                attr.text = string.format("%s<color='%s'>+%s%%</color><color='%s'>(-%s%%)</color>", attrName, "#4bcd2e", v.val / 10, ColorHelper.color[6], -add / 10)
            end
        else
            if KvData.prop_percent[v.name] == nil then
                attr.text = string.format("%s<color='%s'>+%s</color>", attrName, ColorHelper.color[1], v.val)
            else
                attr.text = string.format("%s<color='%s'>+%s%%</color>", attrName, ColorHelper.color[1], v.val / 10)
            end
        end
    end
    for i=#baseAttrData + 1, #self.baseAttrList do
        self.baseAttrList[i].gameObject:SetActive(false)
    end

    self.attrLayout:AddCell(self.baseAttrLayout.panel.gameObject)

    -- 克制属性
    local data_rival_set = DataTalisman.data_rival_set[string.format("%s_%s", cfgData.set_id, cfgData.type)]
    if data_rival_set == nil or data_rival_set.desc == "" then
        self.restraint.transform.sizeDelta = Vector2(230, 0)
        self.attrLayout:AddCell(self.restraint)
        self.restraint:SetActive(false)
    else
        self.restraintText.text = data_rival_set.desc
        self.restraintText.transform.sizeDelta = Vector2(230, self.restraintText.preferredHeight)
        self.restraint.transform.sizeDelta = Vector2(230, self.restraintText.preferredHeight + 5)
        self.attrLayout:AddCell(self.restraint)
        self.restraint:SetActive(true)
    end


    -- 额外属性
    local extraAttr = nil
    -- BaseUtils.dump(extraAttrData, "extraAttr")
    table.sort(extraAttrData, function(a,b)
        return TalismanEumn.DecodeFlag(a.flag, 2) > TalismanEumn.DecodeFlag(b.flag, 2)
    end)
    for i,v in ipairs(self.extraAttrList) do
        extraAttr = extraAttrData[i]
        if extraAttr == nil then
            v.gameObject:SetActive(false)
        else
            add = TalismanEumn.DecodeFlag(extraAttr.flag, 2)
            v.gameObject:SetActive(true)
            v.icon.gameObject:SetActive(true)
            v.text.transform.anchoredPosition = Vector2(25, 0)
            v.transform.anchoredPosition = Vector2(0, (1 - i) * 30)

            if KvData.attr_name[extraAttr.name] == nil then
                v.text.text = TI18N("<color>可洗炼</color>")
                v.star.text = ""
            elseif add == 6 then
                v.text.text = string.format("<color='#ff00ff'>%s</color>", KvData.GetAttrStringNoColor(extraAttr.name, extraAttr.val, TalismanEumn.DecodeFlag(extraAttr.flag, 3)))
                v.star.text = TI18N("<color='#ff00ff'>完美</color>")
            else
                v.text.text = KvData.GetAttrStringNoColor(extraAttr.name, extraAttr.val, TalismanEumn.DecodeFlag(extraAttr.flag, 3))
                v.star.text = string.format(TI18N("%s星"), add)
            end
        end
    end
    self.extraAttr.transform.sizeDelta = Vector2(230, 30 * #extraAttrData)
    self.attrLayout:AddCell(self.extraAttr.gameObject)
end

function TalismanTipsDrop:ReloadBaseInfo(data)
    -- 基础属性
    local cfgData = DataTalisman.data_get[data.base_id]
    -- BaseUtils.dump(cfgData, "cfgData")
    self.baseAttrLayout:ReSet()
    local add = 0

    local base_attr = {}
    for _,v in ipairs(cfgData.base_attr) do
        if v.val ~= 0 then
            table.insert(base_attr, v)
        end
    end

    for i,v in ipairs(base_attr) do
        local attr = self.baseAttrList[i]
        if attr == nil then
            attr = GameObject.Instantiate(self.baseAttrList[1].gameObject):GetComponent(Text)
            self.baseAttrList[i] = attr
        end
        self.baseAttrLayout:AddCell(attr.gameObject)
        attr.text = string.format("%s<color='%s'>+%s</color>", KvData.attr_name[v.key], "#4bcd2e", v.val)
    end

    for i=#base_attr + 1, #self.baseAttrList do
        self.baseAttrList[i].gameObject:SetActive(false)
    end
    self.attrLayout:AddCell(self.baseAttrLayout.panelRect.gameObject)

    -- 克制属性
    local data_rival_set = DataTalisman.data_rival_set[string.format("%s_%s", cfgData.set_id, cfgData.type)]
    if data_rival_set == nil or data_rival_set.desc == "" then
        self.restraint.transform.sizeDelta = Vector2(230, 0)
        self.attrLayout:AddCell(self.restraint)
        self.restraint:SetActive(false)
    else
        self.restraintText.text = data_rival_set.desc
        self.restraintText.transform.sizeDelta = Vector2(230, self.restraintText.preferredHeight)
        self.restraint.transform.sizeDelta = Vector2(230, self.restraintText.preferredHeight + 5)
        self.attrLayout:AddCell(self.restraint)
        self.restraint:SetActive(true)
    end

    -- 额外属性
    -- self.extraAttrList[1].text.text = TI18N("属性未知")
    -- self.extraAttrList[1].star.text = ""
    -- self.extraAttrList[1].gameObject:SetActive(true)


    self.extraText.gameObject:SetActive(true)
    self.extraText.transform.anchoredPosition = Vector2(0, 0)
    local c = 0
    local extraAttrData = {}
    local baseAttr = DataTalisman.data_sp_attr[data.type .. "_" .. cfgData.quality .. "_" .. cfgData.grade .. "_" .. 1]
    if baseAttr ~= nil then
        for i=1,10 do
            if baseAttr["attr_val" .. i] ~= 0 then
                table.insert(extraAttrData, {name = baseAttr["attr_name"..i], val = baseAttr["attr_val" .. i], flag = 1})
            end
        end
    end
    baseAttr = DataTalisman.data_sp_attr[data.type .. "_" .. cfgData.quality .. "_" .. cfgData.grade .. "_" .. 2]
    if baseAttr ~= nil then
        for i=1,10 do
            if baseAttr["attr_val" .. i] ~= 0 then
                table.insert(extraAttrData, {name = baseAttr["attr_name"..i], val = baseAttr["attr_val" .. i], flag = 2})
            end
        end
    end
    local qualityData = BaseUtils.copytab(DataTalisman.data_star[cfgData.quality .. "_" .. cfgData.grade].step_list)
    table.sort(qualityData, function(a,b) return a[1] < b[1] end)
    local starStr = string.format(TI18N("%s-%s星"), qualityData[1][1], qualityData[#qualityData][1])

    for i,v in ipairs(extraAttrData) do
        local tab = self.extraAttrList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.extraAttrList[1].gameObject)
            tab.transform = tab.gameObject.transform
            tab.transform:SetParent(self.extraAttr)
            tab.transform.localScale = Vector3.one
            tab.star = tab.transform:Find("Star"):GetComponent(Text)
            tab.text = tab.transform:Find("Text"):GetComponent(Text)
            tab.icon = tab.transform:Find("Icon"):GetComponent(Image)
            self.extraAttrList[i] = tab
        end
        tab.gameObject:SetActive(true)
        tab.transform.anchoredPosition = Vector2(0, - i * 30)
        tab.icon.gameObject:SetActive(false)

        tab.star.text = starStr
        tab.text.transform.anchoredPosition = Vector2(5, 0)
        tab.text.text = string.format("<color='#ff00ff'>%s</color>", KvData.GetAttrStringNoColor(v.name, v.val, v.flag))
        tab.gameObject:SetActive(true)
    end
    for i=#extraAttrData + 1, #self.extraAttrList do
        self.extraAttrList[i].gameObject:SetActive(false)
    end
    self.extraAttr.transform.sizeDelta = Vector2(230, 30 * #extraAttrData + 30)
    self.attrLayout:AddCell(self.extraAttr.gameObject)
    self.attrLayout.panelRect.anchoredPosition = Vector2.zero
end

function TalismanTipsDrop:ReloadButtons()
    local datalist = {}

    if self.data ~= nil and TalismanManager.Instance.model.useItemDic[self.data.id] then
        table.insert(datalist, {text = TI18N("卸 下"), func = self.unloadFunc, up = false})
    else
        table.insert(datalist, {text = TI18N("装 备"), func = self.loadFunc, up = false})
    end
    -- if TalismanManager.Instance.model:CanAbsorbed(self.data.id) then
    if TalismanManager.Instance.model.useItemDic[self.data.id] == nil
        and TalismanManager.Instance.model.planList[TalismanManager.Instance.model.use_plan or 1][TalismanEumn.TypeProto[DataTalisman.data_get[self.data.base_id].type]] ~= nil
        then
        table.insert(datalist, {text = TI18N("洗 练"), func = self.absorbFunc, up = self:CheckForUp()})
        table.insert(datalist, {text = TI18N("熔 炼"), func = self.fusionFunc, up = false})
    end

    self.buttonGrid:ReSet()
    self.buttonCloner:SetActive(false)
    for i,v in ipairs(datalist) do
        local buttonTab = self.buttonList[i]
        if buttonTab == nil then
            buttonTab = {}
            buttonTab.gameObject = GameObject.Instantiate(self.buttonCloner)
            buttonTab.transform = buttonTab.gameObject.transform
            buttonTab.button = buttonTab.transform:Find("Button"):GetComponent(Button)
            buttonTab.btnText = buttonTab.transform:Find("Button/Text"):GetComponent(Text)
            buttonTab.up = buttonTab.transform:Find("Up").gameObject
            self.buttonList[i] = buttonTab
        end
        self.buttonGrid:AddCell(buttonTab.gameObject)
        buttonTab.button.onClick:RemoveAllListeners()
        buttonTab.button.onClick:AddListener(v.func)
        buttonTab.btnText.text = v.text
        buttonTab.up:SetActive(v.up == true)
    end
    for i=#datalist + 1,#self.buttonList do
        self.buttonList[i].gameObject:SetActive(false)
    end

    if #datalist == 1 then
        self.buttonArea.transform.anchoredPosition = Vector2(58, 10)
    else
        self.buttonArea.transform.anchoredPosition = Vector2(0, 10)
    end
end

function TalismanTipsDrop:UnloadTalisman()
    if self.data ~= nil then
        TalismanManager.Instance:send19609(DataTalisman.data_get[self.data.base_id].type)
    end
    self.model:Closetips()
end

function TalismanTipsDrop:LoadTalisman()
    if self.data ~= nil then
        TalismanManager.Instance:send19608(self.data.id)
    end
    self.model:Closetips()
end

function TalismanTipsDrop:Absorb()
    self.model:Closetips()
    if self:CheckForUp() then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.talisman_absorb, {id = self.data.id})
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("装备同名宝物才能洗炼"))
    end
end

function TalismanTipsDrop:CheckForUp()
    if self.data.id ~= nil and self.data.id > 0 then
        local currentCfgData = DataTalisman.data_get[TalismanManager.Instance.model.itemDic[self.data.id].base_id]
        local planData = TalismanManager.Instance.model.itemDic[TalismanManager.Instance.model.planList[TalismanManager.Instance.model.use_plan or 1][TalismanEumn.TypeProto[currentCfgData.type]].id]
        if planData == nil then
            return false
        end
        local cfgData = DataTalisman.data_get[planData.base_id]
        if cfgData.type == currentCfgData.type and planData.id ~= self.data.id then
            local data_absorb_set_id_map = DataTalisman.data_absorb_set_id_map[currentCfgData.set_id]
            if data_absorb_set_id_map ~= nil and BaseUtils.ContainValueTable(data_absorb_set_id_map.dst_map, cfgData.set_id) then
                return true
            elseif cfgData.set_id == currentCfgData.set_id then
                return true
            else
                return false
            end
        end
    end
    return false
end

function TalismanTipsDrop:Fusion()
    self.model:Closetips()
    if DataTalisman.data_get[self.data.base_id].quality > 2 then
        self.confirmData = self.confirmData or NoticeConfirmData.New()
        self.confirmData.content = string.format(TI18N("该宝物为[%s]宝物，熔炼后将消失"), ColorHelper.color_item_name(DataTalisman.data_get[self.data.base_id].quality, TalismanEumn.QualifyName[DataTalisman.data_get[self.data.base_id].quality]))
        self.confirmData.sureCallback = function() TalismanManager.Instance:send19606({{id1 = self.data.id}}, {}) end
        NoticeManager.Instance:ConfirmTips(self.confirmData)
    else
        TalismanManager.Instance:send19606({{id1 = self.data.id}}, {})
    end
end


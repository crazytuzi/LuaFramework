-- @author 黄耀聪
-- @date 2017年3月21日

TalismanAddition = TalismanAddition or BaseClass(BasePanel)

function TalismanAddition:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "TalismanAddition"

    self.resList = {
        {file = AssetConfig.talisman_addition, type = AssetType.Main},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
        {file = AssetConfig.talisman_textures, type = AssetType.Dep},
        {file = AssetConfig.talisman_fusion_textures, type = AssetType.Dep},
        {file = AssetConfig.rolebgnew, type = AssetType.Dep},
    }

    self.itemList = {}
    self.rowList = {}
    self.selectDic = {}
    self.itemDic = {}
    self.attrList = {}

    self.originRotation = Quaternion.Euler(340, 0, 0)

    self.nameString = TI18N("%s属性 %s %s")

    self.attrDataList = {
        {icon = "AttrIcon77", key = "up_mask"},
        {icon = "AttrIcon78", key = "up_ring"},
        {icon = "AttrIcon79", key = "up_cloak"},
        {icon = "AttrIcon80", key = "up_blazon"},

        {icon = "AttrIcon78", key = 62300},
        {icon = "AttrIcon79", key = 62400},
        {icon = "AttrIcon80", key = 62500},
    }

    self.clickItemFunc = function(data) self:ClickItem(data) end
    self.updateListener = function() self:Reload() self:RefreshSelect() self:UpdateInfo() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.effectTab = {}
    self.currColor = 0
end

function TalismanAddition:__delete()
    self.OnHideEvent:Fire()

    if self.effectView ~= nil then
        self.effectView:DeleteMe()
        self.effectView = nil
    end
    self.transform:Find("Right/Bg/Bg"):GetComponent(Image).sprite = nil
    for _,v in pairs(self.attrList) do
        v.transform:Find("Icon"):GetComponent(Image).sprite = nil
    end

    if self.upgradeEffect ~= nil then
        self.upgradeEffect:DeleteMe()
        self.upgradeEffect = nil
    end
    if self.addEffect ~= nil then
        self.addEffect:DeleteMe()
        self.addEffect = nil
    end

    for k,v in pairs(self.effectTab) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.effectTab = nil

    if self.effectView ~= nil then
        self.effectView:DeleteMe()
        self.effectView = nil
    end

    if self.lockEffect ~= nil then
        self.lockEffect:DeleteMe()
        self.lockEffect = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.rowLayout ~= nil then
        self.rowLayout:DeleteMe()
        self.rowLayout = nil
    end
    if self.itemDic ~= nil then
        for _,item in pairs(self.itemDic) do
            item:DeleteMe()
        end
    end
    self:AssetClearAll()
end

function TalismanAddition:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.talisman_addition))
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local left = t:Find("Left")
    self.container = left:Find("Scroll/Container")
    self.cloner = left:Find("Scroll/Cloner").gameObject
    self.scroll = left:Find("Scroll"):GetComponent(ScrollRect)
    self.pageController  = self.scroll.gameObject:AddComponent(PageTabbedController)

    self.pageController.onUpEvent:AddListener(function() self:OnUp() end)
    self.pageController.onEndDragEvent:AddListener(function() self:OnUp() end)

    self.markImg1 = left:Find("Select/Mark1"):GetComponent(Image)
    self.markImg2 = left:Find("Select/Mark2"):GetComponent(Image)

    local layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})
    for i=1,10 do
        self.itemList[i] = TalismanAdditionItem.New(self.model, GameObject.Instantiate(self.cloner), self)
        self.itemList[i].assetWrapper = self.assetWrapper
        layout:AddCell(self.itemList[i].gameObject)
        self.itemList[i].clickCallback = function(index) self:TweenTo(index - 3) end
    end
    self.cloner:SetActive(false)
    layout:DeleteMe()

    -- 右边
    local right = t:Find("Right")
    -- self.rowLayout = LuaBoxLayout.New(right:Find("Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0})
    -- self.rowCloner = right:Find("Scroll/Row").gameObject
    -- self.rowCloner:SetActive(false)
    self.rightBg = right:Find("Bg").gameObject
    right:Find("Bg/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    right:Find("Text"):GetComponent(Text).text = TI18N("熔炼多余宝物，提升宝物境界加强宝物能力（<color='#ffff00'>基础、附加</color>属性）")

    self.slider = right:Find("Slider"):GetComponent(Slider)
    self.sliderText = right:Find("Slider/Text"):GetComponent(Text)
    self.button = right:Find("Button"):GetComponent(Button)
    right:Find("Button/Text"):GetComponent(Text).text = TI18N("熔 宝")

    self.titleText = right:Find("Title/Bg/Name"):GetComponent(Text)
    -- self.iconBgImage = right:Find("Title/IconBg"):GetComponent(Image)
    -- self.iconImage = right:Find("Title/Icon"):GetComponent(Image)

    local attrArea = right:Find("Attr")
    for i=1,7 do
        local tab = {}
        tab.transform = attrArea:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, self.attrDataList[i].icon)
        tab.text = tab.transform:Find("Text"):GetComponent(Text)
        self.attrList[i] = tab
    end

    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll:GetComponent(RectTransform).rect.height --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) self:UpdatePos() end)

    self.button.onClick:AddListener(function() self:OnClickHeat() end)
end

function TalismanAddition:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function TalismanAddition:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.talisman_item_change, self.updateListener)

    self.openArgs = self.openArgs or {}

    self.fusion_lev = self.model.old_fusion_lev or self.model.fusion_lev or 0
    self.fusion_val = self.model.old_fusion_val or self.model.fusion_val or 0
    self:UpdateInfo()

    self:Reload()

    local lev = self.model.old_fusion_lev or self.model.fusion_lev
    if lev < DataTalisman.data_fusion_length - 1 then
        -- if lev == 0 then lev = 1 end
        self:StopAt(lev)
    else
        self:StopAt(DataTalisman.data_fusion_length - 1)
    end

    if self.openArgs[1] ~= nil then
        if self.openArgs[1] == 1 then
            self:RotateComp()
        elseif self.openArgs[1] > 1 then
            self:RotateComp()
            self:ShowUpgradeEffect()
        end
    end
    self:UnlockLev()
end

function TalismanAddition:OnHide()
    self:RemoveListeners()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
    if self.upgradeEffect ~= nil then
        self.upgradeEffect:SetActive(false)
    end
    if self.addEffect ~= nil then
        self.addEffect:SetActive(false)
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.sliderTweenId ~= nil then
        Tween.Instance:Cancel(self.sliderTweenId)
        self.sliderTweenId = nil
    end
    if self.rotateCompTweenId ~= nil then
        Tween.Instance:Cancel(self.rotateCompTweenId)
        self.rotateCompTweenId = nil
        self.model.old_fusion_val = self.model.fusion_val
        self.model.old_fusion_lev = self.model.fusion_lev
    end
    if self.lockEffect ~= nil then
        self.lockEffect:SetActive(false)
    end
    if self.timerId ~= nil then
        self.model.old_fusion_lev = self.model.fusion_lev
        self.model.old_fusion_val = self.model.fusion_val
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function TalismanAddition:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.talisman_item_change, self.updateListener)
end

function TalismanAddition:Reload()
    local datalist = {}

    local lev = self.model.fusion_lev or 0
    local currColor = 0
    if lev == 0 then
        currColor = 1
    else
        currColor = DataTalisman.data_fusion[lev].color
    end

    -- 占位
    table.insert(datalist, {isEmpty = true})
    table.insert(datalist, {isEmpty = true})

    local count = 0
    -- 取到当前品阶和下一阶的数量
    for i=0,DataTalisman.data_fusion_length - 1 do
        local cfgData = DataTalisman.data_fusion[i]
        if cfgData.color <= currColor + 1 then
            table.insert(datalist, {id = i, isEmpty = false, unknown = false})
        elseif cfgData.color == currColor + 2 then
            table.insert(datalist, {id = i, isEmpty = false, unknown = true})
            break
        else
            break
        end
    end
    self.currColor = currColor

    -- 占位
    if self.currColor == DataTalisman.data_fusion[DataTalisman.data_fusion_length - 1].color then
        table.insert(datalist, {isEmpty = true})
    end
    table.insert(datalist, {isEmpty = true})

    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)

    self:UpdatePos()
end

-- 更新位置，使轨迹像圆
function TalismanAddition:UpdatePos()
    local y = nil
    local res = nil

    -- 这个算法。。。看不懂也别问我
    -- 运动轨迹是椭圆，设坐标原点是左上角，然后标准方程是(x + 123)^2 / 250^2 + (y + 210)^2 / 296.5^2 = 1
    -- 然后就有下面的算法
    for i,v in ipairs(self.itemList) do
        y = v.transform.anchoredPosition.y + self.container.anchoredPosition.y - v.transform.sizeDelta.y / 2

        res = 1 - ((y + 210)*(y + 210) / (296.5*296.5))
        if res >= 0 then
            v.item.anchoredPosition = Vector2(math.sqrt(res) * 250 - 123 - 138.25 - 11, 0)
            v:SetScale(1 - (y + 210) * (y + 210) * (1 - 0.6)/44100)
        end
    end

    self:SetInfo(self.container.anchoredPosition.y)

    self:SetAlpha()
end

-- 转到
function TalismanAddition:TweenTo(index)
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.tweenId = Tween.Instance:ValueChange(self.container.anchoredPosition.y, 84 * index, 0.5, function() self.tweenId = nil end, LeanTweenType.easeOutQuart,
        function(value)
            self.container.anchoredPosition = Vector2(0, value)
            -- self.scroll.onValueChanged:Invoke({0, 1 - value / self.container.sizeDelta.y})
        end).id
end

function TalismanAddition:StopAt(index)
    self.scroll.onValueChanged:Invoke({0, 0})
    self.container.anchoredPosition = Vector2(0, 84 * index)
    self.scroll.onValueChanged:Invoke({0, 1 - 84 * index / self.container.sizeDelta.y})
end

function TalismanAddition:OnUp()
    local y = self.container.anchoredPosition.y
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.tweenId = Tween.Instance:ValueChange(y, 84 * math.ceil(math.floor(y * 2 / 84) / 2), 0.5, function() self.tweenId = nil end, LeanTweenType.easeOutQuart,
        function(value)
            self.container.anchoredPosition = Vector2(0, value)
            -- self.scroll.onValueChanged:Invoke({0, 1 - value / self.container.sizeDelta.y})
        end).id
end

-- 设置选中熔炉指针的透明度
function TalismanAddition:SetAlpha()
    local y = self.container.anchoredPosition.y
    -- local alpha = 1 - math.abs(y - 84 * math.floor((y + 42) / 84)) / 42
    local alpha = 1 - math.abs(y - 84 * math.floor((y + 42) / 84)) / 42

    self.markImg1.color = Color(1, 1, 1, alpha)
    self.markImg2.color = Color(1, 1, 1, alpha)
end

-- 刷新格子
function TalismanAddition:ReloadRows()
    local datalist = {}
    for id,v in pairs(self.model.itemDic) do
        if v ~= nil then
            table.insert(datalist, {["id"] = id, ["base_id"] = v.base_id})
        end
    end
    table.sort(datalist, function(a,b) return self.model:Sort(a.id, b.id) end)

    local rowIndex = 0
    local row = nil

    self.rowLayout:ReSet()
    rowIndex = math.ceil(#datalist / 5)
    if rowIndex < 2 then
        rowIndex = 2
    end
    self.rowLayout:ReSet()
    for i=1,rowIndex do
        row = self.rowList[i]
        if row == nil then
            row = {}
            row.gameObject = GameObject.Instantiate(self.rowCloner)
            row.transform = row.gameObject.transform
            row.items = {}
            for j=1,5 do
                row.items[j] = TalismanGridItem.New(row.transform:GetChild(j - 1), self.assetWrapper)
                row.items[j].clickCallback = self.clickItemFunc
            end
            self.rowList[i] = row
        end
        self.rowLayout:AddCell(row.gameObject)
    end
    rowIndex = 0
    for i,v in ipairs(datalist) do
        rowIndex = math.ceil(i / 5)
        row = self.rowList[rowIndex]
        self.itemDic[v.id] = row.items[(i - 1) % 5 + 1]
        self.itemDic[v.id]:SetData(v)
        self.itemDic[v.id]:Select(self.selectDic[v.id] ~= nil)
    end
    for i=(#datalist - 1) % 5 + 2, 5 do
        self.rowList[rowIndex].items[i]:SetDefault()
    end
    if rowIndex < 2 then
        rowIndex = 2
    end
    for i=rowIndex + 1, #self.rowList do
        self.rowList[i].gameObject:SetActive(false)
    end
end

-- 点击格子
function TalismanAddition:ClickItem(data)
    if data == nil then
        return
    end

    if self.selectDic[data.id] == nil then
        self.selectDic[data.id] = 1
        self.itemDic[data.id]:Select(true)
    else
        self.selectDic[data.id] = nil
        self.itemDic[data.id]:Select(false)
    end
end

-- 右边信息窗口
function TalismanAddition:SetInfo(y)
    local lev = math.floor((y - 42) / 84) + 1
    local cfgData = DataTalisman.data_fusion[lev]
    if self.lastLev == lev then
        if self.previewComp ~= nil then
            self.previewComp:Show()
        end
    else
        self:UpdatePreview(cfgData)
    end

    if lev >= 0 and lev < DataTalisman.data_fusion_length and self.lastLev ~= lev then
        self.lastLev = lev
        self.titleText.text = cfgData.name

        local currentCfgData = DataTalisman.data_fusion[self.model.fusion_lev or 0]
        local key = nil
        for i=1,4 do
            local tab = self.attrList[i]
            key = self.attrDataList[i].key
            if currentCfgData[key] > cfgData[key] then
                tab.text.text = string.format(self.nameString, TalismanEumn.Name[i], tostring(currentCfgData[key] / 10) .. "%", string.format("<color='%s'>-%s</color>",ColorHelper.color[6], tostring((currentCfgData[key] - cfgData[key]) / 10) .. "%"))
            elseif currentCfgData[key] < cfgData[key] then
                tab.text.text = string.format(self.nameString, TalismanEumn.Name[i], tostring(currentCfgData[key] / 10) .. "%", string.format("<color='%s'>+%s</color>",ColorHelper.color[1], tostring((cfgData[key] - currentCfgData[key]) / 10) .. "%"))
            else
                tab.text.text = string.format(self.nameString, TalismanEumn.Name[i], tostring(currentCfgData[key] / 10) .. "%", "")
            end
        end

        local skillPrac = {}
        for _,v in ipairs(cfgData.skill_prac) do
            skillPrac[v[1]] = v[2]
        end
        local currentSkillPrac = {}
        for _,v in ipairs(currentCfgData.skill_prac) do
            currentSkillPrac[v[1]] = v[2]
        end
        for i=5,7 do
            local tab = self.attrList[i]
            key = self.attrDataList[i].key
            if (currentSkillPrac[key] or 0) > (skillPrac[key] or 0) then
                tab.text.text = string.format("%s %s %s", DataSkillPrac.data_skill[key].name, (currentSkillPrac[key] or 0), string.format("<color='%s'>-%s</color>",ColorHelper.color[6], tostring((currentSkillPrac[key] or 0) - (skillPrac[key] or 0))))
            elseif (currentSkillPrac[key] or 0) < (skillPrac[key] or 0) then
                tab.text.text = string.format("%s %s %s", DataSkillPrac.data_skill[key].name, (currentSkillPrac[key] or 0), string.format("<color='%s'>+%s</color>",ColorHelper.color[1], tostring((skillPrac[key] or 0) - (currentSkillPrac[key] or 0))))
            else
                tab.text.text = string.format("%s +%s", DataSkillPrac.data_skill[key].name, tostring(currentSkillPrac[key] or 0), "")
            end
        end

    end
end

-- 刷新信息
function TalismanAddition:UpdateInfo()
    local model = self.model

    self.slider.value = (self.fusion_val or 0) / DataTalisman.data_fusion[self.fusion_lev or 0].need_val
    self.sliderText.text = string.format("%s/%s", tostring(self.fusion_val or 0), DataTalisman.data_fusion[self.fusion_lev or 0].need_val)

    self:GoSliderTween()
end

function TalismanAddition:GoSliderTween()
    if self.fusion_val == self.model.fusion_val and self.fusion_lev == self.model.fusion_lev then
        return
    end
    if self.sliderTweenId ~= nil then
        Tween.Instance:Cancel(self.sliderTweenId)
        self.sliderTweenId = nil
    end
    if self.fusion_lev == self.model.fusion_lev then
        -- self.dis = 0
        self.fusion_val = self.model.fusion_val or 0
        self.sliderTweenId = Tween.Instance:ValueChange(self.slider.value, (self.fusion_val or 0) / DataTalisman.data_fusion[self.fusion_lev].need_val, 0.3,
        function()
            self.sliderTweenId = nil
            self.model.old_fusion_val = self.model.fusion_val
            self.fusion_val = self.model.fusion_val
            self.sliderText.text = string.format("%s/%s", tostring(self.fusion_val or 0), DataTalisman.data_fusion[self.fusion_lev or 0].need_val)
        end
        , LeanTweenType.linear, function(value) self.slider.value = value end).id
    else
        -- self.dis = self.dis - (DataTalisman.data_fusion[self.fusion_lev].need_val - self.fusion_val)
        self.fusion_val = DataTalisman.data_fusion[self.fusion_lev].need_val
        self.fusion_lev = self.fusion_lev + 1
        self.sliderTweenId = Tween.Instance:ValueChange(self.slider.value, (self.fusion_val or 0) / DataTalisman.data_fusion[self.fusion_lev - 1].need_val, 0.3, function() self.slider.value = 0 self:GoSliderTween() end, LeanTweenType.linear, function(value) self.slider.value = value end).id
    end
end

-- 点击熔炼
function TalismanAddition:OnClickHeat()
    -- local idList = {}
    -- for id,v in pairs(self.selectDic) do
    --     if v ~= nil then
    --         table.insert(idList, {["id"] = id})
    --     end
    -- end
    -- if #idList == 0 then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要熔炼的法宝"))
    -- else
    --     local confirmData = NoticeConfirmData.New()
    --     confirmData.content = TI18N("确定消耗选中的法宝进行熔炼？")
    --     confirmData.sureCallback = function() TalismanManager.Instance:send19606(idList) end
    --     NoticeManager.Instance:ConfirmTips(confirmData)
    -- end

    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.talisman_fusion)
end

-- 更新选中列表
function TalismanAddition:RefreshSelect()
    local idList = {}
    for id,v in pairs(self.selectDic) do
        if v ~= nil and self.model.itemDic[id] == nil then
            table.insert(idList, id)
        end
    end
    for _,id in ipairs(idList) do
        self.selectDic[id] = nil
    end
end

function TalismanAddition:UpdatePreview(cfgData)
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "TalismanAddition"
        ,orthographicSize = 0.27
        ,width = 341
        ,height = 341
        ,offsetY = -0.1
        ,noDrag = true
    }
    local modelData = {type = PreViewType.Npc, skinId = cfgData.skin_id, modelId = cfgData.model_id, animationId = cfgData.anim_id, scale = 1}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        if modelData.skinId ~= self.previewComp.modelData.skinId or modelData.modelId ~= self.previewComp.modelData.modelId or modelData.animationId ~= self.previewComp.modelData.animationId then
            self.previewComp:Reload(modelData, callback)
        end
    end
    self.previewComp:Show()
    self.effect_id = cfgData.effect_id
    self:LoadEffect()
end

function TalismanAddition:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.rightBg.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(340, 0, 0))

    self.rightBg:SetActive(true)
end

function TalismanAddition:LoadEffect()
    if self.effectView ~= nil then
        if self.effectView.effectId ~= self.effect_id then
            self.effectView:SetActive(false)
        end
    end

    local effectView = self.effectTab[self.effect_id]
    if effectView == nil then
        effectView = BaseEffectView.New({effectId = self.effect_id, callback = function() self:EffectLoad() end})
        self.effectTab[self.effect_id] = effectView
        self.effectView = effectView
    else
        self.effectView = effectView
        self:EffectLoad()
    end
end

function TalismanAddition:EffectLoad()
    if self.effectView == nil or BaseUtils.isnull(self.effectView.gameObject) then
        return
    end
    self.effectView.transform:SetParent(self.rightBg.transform)
    Utils.ChangeLayersRecursively(self.effectView.transform, "UI")
    self.effectView.transform.localScale = Vector3.one
    self.effectView.transform.localPosition = Vector3(0, -80, -400)
    if self.effect_id ~= self.last_effect_id then
        self.effectView.gameObject:SetActive(false)
        self.last_effect_id = self.effect_id
    end
    self.effectView.gameObject:SetActive(true)
end

-- 解锁播放特效
function TalismanAddition:Unlock(transform)
    if self.lockEffect == nil then
        self.lockEffect = BibleRewardPanel.ShowEffect(20336, transform, Vector3(2, 2, 1), Vector3(-33, -40.7, -400))
    else
        self.lockEffect:SetActive(false)
        self.lockEffect.transform:SetParent(transform)
        self.lockEffect.localPosition = Vector3(0, 0, -400)
        self.lockEffect:SetActive(true)
    end
end

-- 解锁下一级
function TalismanAddition:UnlockLev()
    if self.model.old_fusion_lev ~= nil and self.model.old_fusion_lev < self.model.fusion_lev then
        for _,v in pairs(self.itemList) do
            if v.data ~= nil and v.data.id == (self.model.old_fusion_lev + 1) then
                self:Unlock(v.transform)
            end
        end
        self.model.old_fusion_lev = self.model.fusion_lev

        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
        end
        self.timerId = LuaTimer.Add(1500, function() self:TweenTo(self.model.old_fusion_lev) self:UnlockLev() end)
    end
end

-- 莲花加速旋转
function TalismanAddition:RotateComp()
    if self.previewComp ~= nil then
        if self.rotateCompTweenId ~= nil then
            Tween.Instance:Cancel(self.rotateCompTweenId)
            self.rotateCompTweenId = nil
        end
        if self.previewComp.tpose ~= nil and not BaseUtils.isnull(self.previewComp.tpose) then
            local q = self.previewComp.tpose.transform.localRotation
            self.rotateCompTweenId = Tween.Instance:ValueChange(0, -720, 1.5, function() self.rotateCompTweenId = nil end, LeanTweenType.easeInOutQuad, function(value) self:RotatePrevComp(value) end).id
        end
    end
    self:ShowAdditionEffect()
end

function TalismanAddition:ShowAdditionEffect()
    if self.addEffect == nil then
        self.addEffect = BibleRewardPanel.ShowEffect(20347, self.rightBg.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
    else
        self.addEffect:SetActive(false)
        self.addEffect:SetActive(true)
    end
end

function TalismanAddition:RotatePrevComp(value)
    if self.previewComp.tpose ~= nil and not BaseUtils.isnull(self.previewComp.tpose) then
        self.previewComp.tpose.transform.localRotation = Quaternion.AngleAxis(value, Vector3(0, math.cos(340 * math.pi / 180), math.sin(340 * math.pi / 180))) * self.originRotation
    end
end

-- 展示升级特效
function TalismanAddition:ShowUpgradeEffect()
    if self.upgradeEffect == nil then
        self.upgradeEffect = BibleRewardPanel.ShowEffect(20353, self.rightBg.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
    else
        self.upgradeEffect:SetActive(false)
        self.upgradeEffect:SetActive(true)
    end
end

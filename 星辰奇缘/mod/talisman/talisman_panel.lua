-- @author 黄耀聪
-- @date 2017年3月17日

TalismanPanel = TalismanPanel or BaseClass(BasePanel)

function TalismanPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "TalismanPanel"

    -- self.windowId = WindowConfig.WinID.talisman_window

    self.resList = {
        {file = AssetConfig.talisman_panel, type = AssetType.Main},
        {file = AssetConfig.talisman_textures, type = AssetType.Dep},
        {file = AssetConfig.talisman_set, type = AssetType.Dep},
    }

    self.pageBtnList = {}
    self.planItemList = {}
    self.selectBtnList = {}
    self.effectList = {}

    self.numToRoman = {
        [1] = "I",
        [2] = "II",
        [3] = "III",
    }
    self.attrDataList = {
        {key = "up_mask"},
        {key = "up_ring"},
        {key = "up_cloak"},
        {key = "up_blazon"},
    }

    self.itemOriginPos = {
        {pos = Vector2(-128,77), time = 1500},
        {pos = Vector2(-63,170), time = 1500},
        {pos = Vector2(63,170), time = 1500},
        {pos = Vector2(128,77), time = 1500}
    }

    self.filterData = {
        {text = TI18N("火焰套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1000 end},
        {text = TI18N("剑心套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1100 end},
        {text = TI18N("幻影套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1200 end},
        {text = TI18N("时空套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1300 end},
        {text = TI18N("光辉套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1400 end},
        {text = TI18N("掌控套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1500 end},
    }

    self.filterData2 = {
        {text = TI18N("狂怒者套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1600 end},
        {text = TI18N("毁灭者套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1700 end},
        {text = TI18N("预言者套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1800 end},
        {text = TI18N("守护者套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1900 end},
        {text = TI18N("火焰套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1000 end},
        {text = TI18N("剑心套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1100 end},
        {text = TI18N("幻影套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1200 end},
        {text = TI18N("时空套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1300 end},
        {text = TI18N("光辉套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1400 end},
        {text = TI18N("掌控套装"), conditionCallback = function(data) return DataTalisman.data_get[data.base_id].set_id == 1500 end},
    }

    self.tickClock = 20

    self.floatTimerCount = 0

    self.updateListener = function() self:UpdateGrid() self:ReloadInfo() self:ReloadEffect(self.model.use_plan or 1) end
    self.checkGuidePoint = function() self:CheckGuidePoint() end
    self.closeTips = function() self:CloseTips() end
    self._updateGrid = function() self:UpdateGrid() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function TalismanPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gridPanel ~= nil then
        self.gridPanel:DeleteMe()
        self.gridPanel = nil
    end
    if self.selectLayout ~= nil then
        self.selectLayout:DeleteMe()
        self.selectLayout = nil
    end
    if self.effectLayout ~= nil then
        self.effectLayout:DeleteMe()
        self.effectLayout = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.selectTabGroup ~= nil then
        self.selectTabGroup:DeleteMe()
        self.selectTabGroup = nil
    end
    if self.planItemList ~= nil then
        for _,v in pairs(self.planItemList) do
            v.bg.sprite = nil
            v.imgLoader:DeleteMe()
            if v.effect ~= nil then
                v.effect:DeleteMe()
                v.effect = nil
            end
        end
    end
    if self.filter ~= nil then
        self.filter:DeleteMe()
        self.filter = nil
    end
    if self.effectList ~= nil then
        for i,v in ipairs(self.effectList) do
            if v.skillSlot ~= nil then
                v.skillSlot:DeleteMe()
                v.skillSlot = nil
            end
        end
        self.effectList = nil
    end
    self:AssetClearAll()
end

function TalismanPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.talisman_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t

    local main = self.transform

    -- 左侧信息部分

    self.selectLayout = LuaBoxLayout.New(main:Find("Left/SelectArea"), {axis = BoxLayoutAxis.X, cspacing = 0})
    self.selectBtnList[1] = main:Find("Left/SelectArea/Button1"):GetComponent(Button)
    self.selectTabGroup = TabGroup.New(main:Find("Left/SelectArea"), function(index) self:SelectChange(index) end, {notAutoSelect = true, noCheckRepeat = true, perWidth = 110, perHeight = 32, isVertical = false, spacing = 5})

    self.effectLayout = LuaBoxLayout.New(main:Find("Left/EffectBg/Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.effectCloner = main:Find("Left/EffectBg/Scroll/Cloner").gameObject

    self.fcText = main:Find("Left/FcBg/Text"):GetComponent(Text)
    for i=1,4 do
        self.planItemList[i] = {}
        self.planItemList[i].transform = main:Find("Left/Item" .. i)
        self.planItemList[i].gameObject = self.planItemList[i].transform.gameObject
        self.planItemList[i].button = self.planItemList[i].gameObject:GetComponent(Button)
        self.planItemList[i].bg = self.planItemList[i].gameObject:GetComponent(Image)
        self.planItemList[i].imgLoader = SingleIconLoader.New(self.planItemList[i].transform:Find("Image").gameObject)
        self.planItemList[i].nameBg = self.planItemList[i].transform:Find("Name").gameObject
        self.planItemList[i].nameText = self.planItemList[i].transform:Find("Name/Text"):GetComponent(Text)
        self.planItemList[i].extBg = self.planItemList[i].transform:Find("ExtBg")
        self.planItemList[i].extText = self.planItemList[i].transform:Find("Text"):GetComponent(Text)
        self.planItemList[i].setImage = self.planItemList[i].transform:Find("Set"):GetComponent(Image)
        local j = i
        self.planItemList[i].extText.gameObject:GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.planItemList[i].extText.gameObject, itemData = {TI18N("熔炼多余宝物，提升宝物境界加强宝物能力（<color='#ffff00'>基础、附加</color>属性）")}}) end)
    end

    -- 右侧翻页部分

    local btnArea = t:Find("Right/ButtonArea")
    self.pageBtnList[1] = btnArea:Find("Button1"):GetComponent(Button)
    for i=2,5 do
        self.pageBtnList[i] = GameObject.Instantiate(self.pageBtnList[1].gameObject)
        self.pageBtnList[i].transform:SetParent(btnArea)
        self.pageBtnList[i].transform.localScale = Vector3.one
        self.pageBtnList[i].transform.anchoredPosition = Vector2(70 * (i - 1), 0)
    end
    self.tabGroup = TabGroup.New(btnArea, function(index) self:PageChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = true, perWidth = 60, perHeight = 32, isVertical = false, spacing = 1})
    for i,v in ipairs(self.tabGroup.buttonTab) do
        v.normalTxt.text = BaseUtils.NumToChn(i)
        v.selectTxt.text = BaseUtils.NumToChn(i)
    end

    self.gridPanel = TalismanGrid.New(main:Find("Right/GridPanel/CustomGrid"), self.assetWrapper,self)
    self.gridPanel.onDragEndListener = function(page) self:OnDragEnd(page) end

    self.infoText = main:Find("Right/Name"):GetComponent(Text)
    self.slider = main:Find("Right/Slider"):GetComponent(Slider)
    self.sliderText = main:Find("Right/Slider/Text"):GetComponent(Text)
    self.button = main:Find("Right/Button"):GetComponent(Button)

    self.filterBtn = main:Find("Right/Filter"):GetComponent(Button)
    self.filterArrow = main:Find("Right/Filter/Image")
    self.filterArea = main:Find("Right/FilterArea")

    self.button.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.talisman_window, {2}) end)
    self.transform:Find("Left/Book"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {1, 4}) end)
    self.filterBtn.onClick:AddListener(function() self:OnFilter() end)

    self.filterArrow.localScale = Vector3(1, -1, 1)
    self.filter = TalismanFilter.New(self.filterArea)
    self:SetFilterData()
    self.filter.filterCallback = function(datalist) self:ReloadGrid(datalist) end
end

function TalismanPanel:OnInitCompleted()
    self:ReloadPlans()
    self.OnOpenEvent:Fire()
end

function TalismanPanel:UpdateGrid()
    local datalist = {}
    for _,v in pairs(self.model.itemDic) do
        if self.model.useItemDic[v.id] == nil then
            table.insert(datalist, v)
        end
    end
    table.sort(datalist, function(a,b) return self.model:Sort(a.id, b.id) end)
    self.filter.datalist = datalist

    self:ReloadGrid(self.filter:Filter())
end

function TalismanPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.tips_close,self.closeTips)
    EventMgr.Instance:AddListener(event_name.quest_update,self.checkGuidePoint)
    EventMgr.Instance:AddListener(event_name.talisman_item_change,self.updateListener)
    TalismanManager.Instance.onUpdateGridNumEvent:AddListener(self._updateGrid)

    self:UpdateGrid()
    self:ReloadInfo()
    self.filter:Hide()

    self.tabGroup:ChangeTab(self.model.lastGridPage or 1)

    self.selectTabGroup:ChangeTab(self.model.use_plan or 1)

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, self.tickClock, function() self:FloatItems() end)
    end

    self:CheckGuidePoint()
end

function TalismanPanel:OnHide()
    self:RemoveListeners()
    for _,v in ipairs(self.planItemList) do
        if v.effect ~= nil then
            v.effect:SetActive(false)
        end
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    local idList = {}
    for id,v in pairs(self.model.newItemId) do
        if v ~= nil then
            table.insert(idList, id)
        end
    end
    for _,id in ipairs(idList) do
        self.model.newItemId[id] = nil
    end
end

function TalismanPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.tips_close,self.closeTips)
    EventMgr.Instance:RemoveListener(event_name.talisman_item_change, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.quest_update,self.checkGuidePoint)
    TalismanManager.Instance.onUpdateGridNumEvent:RemoveListener(self._updateGrid)
    --onUpdateGridNumEvent
end

-- 刷新右边
function TalismanPanel:ReloadGrid(datalist)
    --可能会有坑
    if #datalist < self.model.hasLockGridNum then
        table.insert(datalist, {})
    end
    self.gridPanel:SetData(datalist, 4)

    local page = self.gridPanel:GetPage()
    for i,v in ipairs(self.tabGroup.buttonTab) do
        if i > page then
            self.tabGroup.openLevel[i] = 255
        else
            self.tabGroup.openLevel[i] = 0
        end
    end
    self.tabGroup:Layout()
end

function TalismanPanel:PageChangeTab(index)
    self.model.lastGridPage = index
    self.gridPanel:TurnPage(index)
end

function TalismanPanel:ReloadPlans()
    local model = self.model
    self.selectLayout:ReSet()
    for i,v in ipairs(model.planList) do
        local tab = self.selectBtnList[i]
        if tab == nil then
            local obj = GameObject.Instantiate(self.selectBtnList[1].gameObject)
            tab = obj:GetComponent(Button)
            obj.transform:Find("Text"):GetComponent(Text).text = string.format(TI18N("套装:%s"), self.numToRoman[i])
        end
        self.selectLayout:AddCell(tab.gameObject)
        tab.onClick:RemoveAllListeners()
    end
    self.selectTabGroup:Init()

    for i=#model.planList + 1,#self.selectBtnList do
        self.selectBtnList[i].gameObject:SetActive(false)
    end
end

-- 选择套装方案
function TalismanPanel:SelectChange(index)
    local model = self.model

    if index ~= self.model.use_plan then
        TalismanManager.Instance:send19605(index)
    end

    self:ReloadEffect()
end

-- 套装效果展示
function TalismanPanel:ReloadEffect()
    local model = self.model
    local datalist = {}
    self.effectLayout:ReSet()

    -- 套装法宝
    local planData = self.model.planList[self.model.use_plan or 1] or {}

    -- BaseUtils.dump(model.itemDic, "model.itemDic")
    -- BaseUtils.dump(planData, "planData")

    for i,v in ipairs(self.planItemList) do
        v.bg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level2")
        v.button.onClick:RemoveAllListeners()

        if self.model.isChanging == true then
            if (v.protoData == nil and planData[i] ~= nil) or (v.protoData ~= nil and planData[i] == nil) or (v.protoData ~= nil and planData[i] ~= nil and v.protoData.id ~= planData[i].id) then
                self:ShowEffect(i)
            end
        end

        v.protoData = planData[i]
        if planData[i] == nil or model.itemDic[planData[i].id] == nil then
            v.imgLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Twills"))
            v.bg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level2")
            v.extText.gameObject:SetActive(false)
            v.extBg.gameObject:SetActive(false)
            v.nameText.text = TalismanEumn.Name[i]
            v.setImage.gameObject:SetActive(false)
        else
            local protoData = model.itemDic[planData[i].id]
            local cfgData = DataTalisman.data_get[protoData.base_id]
            local currentCfgData = DataTalisman.data_fusion[self.model.fusion_lev or 0]
            local key = self.attrDataList[TalismanEumn.TypeProto[cfgData.type]].key
            v.setImage.gameObject:SetActive(true)
            v.setImage.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfgData.set_id))
            v.nameText.text = ColorHelper.color_item_name(cfgData.quality, TalismanEumn.FormatQualifyName(cfgData.quality, cfgData.name))
            v.bg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level" .. cfgData.quality)
            v.imgLoader:SetSprite(SingleIconType.Item, cfgData.icon)

            v.button.onClick:AddListener(function() TipsManager.Instance:ShowTalisman({itemData = protoData}) end)
            v.extBg.gameObject:SetActive(true)
            v.extText.gameObject:SetActive(true)
            if currentCfgData[key] == 0 then
                v.extText.text = string.format("+%s%%", tostring(currentCfgData[key] / 10))
            else
                v.extText.text = string.format("<color='#ffff9a'>+%s%%</color>", tostring(currentCfgData[key] / 10))
            end
        end
    end

    local datalist = self.model:GetSkillList()
    local length = #datalist
    if length < 2 then
        length = 1
    end
    for i=1,length do
        local skill_id = datalist[i]
        local tab = self.effectList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.effectCloner)
            tab.transform = tab.gameObject.transform
            tab.skillSlot = SkillSlot.New()
            NumberpadPanel.AddUIChild(tab.transform:Find("Slot"), tab.skillSlot.gameObject)
            local transitionBtn = tab.skillSlot.gameObject:AddComponent(TransitionButton)
            transitionBtn.scaleSetting = true
            transitionBtn.scaleRate = 1.1
            tab.titleText = tab.transform:Find("Title"):GetComponent(Text)
            tab.descText = tab.transform:Find("Desc"):GetComponent(Text)
            tab.unactiveText = tab.transform:Find("Unactive"):GetComponent(Text)
            self.effectList[i] = tab
        end
        self.effectLayout:AddCell(tab.gameObject)
        if skill_id == nil then
            tab.skillSlot.skillData = nil
            tab.skillSlot:Default()
            tab.skillSlot.type = Skilltype.shouhuskill
            tab.skillSlot:SetImg(61043)
            tab.descText.text = TI18N("佩戴2件、4件同套宝物，可激活套装技能")
            tab.titleText.text = TI18N("未激活")
            tab.unactiveText.text = ""
        else
            local cfgSkillData = DataSkill.data_talisman_skill[skill_id .. "_1"]
            tab.skillSlot:SetAll(Skilltype.talisman, cfgSkillData)
            tab.titleText.text = cfgSkillData.name
            tab.descText.text = cfgSkillData.desc
            tab.unactiveText.text = ""
        end
    end
    for i=length + 1,#self.effectList do
        self.effectList[i].gameObject:SetActive(false)
    end

    self.effectCloner:SetActive(false)
    self:CheckGuidePoint()
end


-- 宝池信息
function TalismanPanel:ReloadInfo()
    local model = self.model

    self.slider.value = (model.fusion_val or 0) / DataTalisman.data_fusion[model.fusion_lev or 0].need_val
    self.sliderText.text = string.format("%s/%s", tostring(model.fusion_val or 0), DataTalisman.data_fusion[model.fusion_lev or 0].need_val)
    self.infoText.text = string.format(TI18N("宝物境界:%s"), DataTalisman.data_fusion[model.fusion_lev or 0].name)

    self.fcText.text = string.format(TI18N("总评分:%s"), model.fc)
end

function TalismanPanel:OnDragEnd(page)
    if self.tabGroup.currentIndex ~= nil and self.tabGroup.currentIndex ~= 0 then
        self.tabGroup:UnSelect(self.tabGroup.currentIndex)
    end
    self.tabGroup.currentIndex = page
    self.tabGroup:Select(page)
end

function TalismanPanel:FloatItems()
    self.floatTimerCount = self.floatTimerCount + 1
    for i,type in ipairs(TalismanEumn.ProtoType) do
        if self.model.planList[self.model.use_plan][i] == nil then
            self.planItemList[i].transform.anchoredPosition = self.itemOriginPos[i].pos
        else
            self.planItemList[i].transform.anchoredPosition = Vector2(self.itemOriginPos[i].pos.x, self.itemOriginPos[i].pos.y + 3 * math.sin(self.itemOriginPos[i].time * self.floatTimerCount / (self.tickClock * 720)))
        end
    end
end

-- type = 1, 2, 3, 4
function TalismanPanel:CheckForUp(type)
    local data = self.model.planList[self.model.use_plan or 1][type]
    local protoType = TalismanEumn.ProtoType[type]

    local c = 0
    for _,v in pairs(self.model.itemDic) do
        if v.id ~= data.id and v.type == protoType then
            c = c + 1
        end
    end

    return (c > 0)
end

-- 穿戴或卸下的特效
function TalismanPanel:ShowEffect(i)
    if self.planItemList[i].effect == nil then
        self.planItemList[i].effect = BibleRewardPanel.ShowEffect(20334, self.planItemList[i].transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
    else
        self.planItemList[i].effect:SetActive(false)
        self.planItemList[i].effect:SetActive(true)
    end
end

-- 点击筛选按钮
function TalismanPanel:OnFilter()
    if self.filter ~= nil then
        if self.filter.isShow then
            self.filter:Hide()
            self.filterArrow.localScale = Vector3(1, -1, 1)
        else
            self:SetFilterData()
            self.filter:Show()
            self.filterArrow.localScale = Vector3(1, 1, 1)
        end
    end
end

function TalismanPanel:CheckGuidePoint()

    -- local isGuidePoint = true
    -- local data = DataQuest.data_get[41751]
    -- local questData = QuestManager.Instance:GetQuest(data.id)
    -- if questData ~= nil and questData.finish == 1 then
    --     isGuidePoint = true
    -- end

    -- local hasEmpty = true
    -- for k,v in pairs(self.planItemList) do
    --     if v.extBg.gameObject.activeSelf == true then
    --         hasEmpty = false
    --         break
    --     end
    -- end

    -- local hasTailsMan = false
    -- if self.gridPanel.pageList[1].items[1].setImage.gameObject.activeSelf == true then
    --     hasTailsMan = true
    -- end


    -- if isGuidePoint == true and hasTailsMan == true and hasEmpty == true and self.gridPanel ~= nil then
    --     if self.gridPanel.step == 1 then
    --         self.gridPanel:CheckGuidePoint()
    --         TipsManager.Instance.model.talismanTips:HideGuideEffect()
    --         TipsManager.Instance.model.isCheckPoint = false
    --     elseif self.gridPanel.step == 2 then
    --         self.gridPanel:HideGuideEffect()
    --         TipsManager.Instance.model.talismanTips:CheckGuidePoint()
    --         TipsManager.Instance.model.isCheckPoint = true
    --     end

    -- else
    --     if self.gridPanel ~= nil then
    --         self.gridPanel:HideGuideEffect()
    --     end
    --     TipsManager.Instance.model.talismanTips:HideGuideEffect()
    --     GuideManager.Instance.effect:Hide()
    --     TipsManager.Instance.model.isCheckPoint = false
    -- end
end

function TalismanPanel:CloseTips()
    -- if TipsManager.Instance.model.isShowTailsManTips == true then
    --     self.gridPanel.step = 1
    --     TipsManager.Instance.model.isCheckPoint = false
    -- end
    -- self:CheckGuidePoint()
end

function TalismanPanel:SetFilterData()
    local roleData = RoleManager.Instance.RoleData
    self.filter:SetData(self.filterData2)
end
-- @author 黄耀聪
-- @date 2016年5月24日

WingSkillPanel = WingSkillPanel or BaseClass(BasePanel)

function WingSkillPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "WingSkillPanel"
    self.mgr = WingsManager.Instance

    self.resList = {
        {file = AssetConfig.wing_skill_panel, type = AssetType.Main},
        {file = AssetConfig.wing_textures, type = AssetType.Dep},
        {file = AssetConfig.pet_textures, type = AssetType.Dep},
    }

    self.maxSkillString = TI18N("最大技能数:%s")
    self.previewString = TI18N("预览")
    self.gradeString = TI18N("%s阶")
    self.resetDescString = TI18N("保存后将替换现有所有技能")
    self.resetString = TI18N("重 置")
    self.saveString = TI18N("保 存")
    self.freeString = TI18N("首次免费")
    self.currentSkillString = TI18N("当前技能")
    self.previewString = TI18N("技能预览")

    self.skillList = {}
    self.skillRightList = {nil, nil, nil, nil}
    self.needList = {}
    self.skillRightItemList = {}

    self.reloadListener = function() self:InitLeft() if self.rightOpen then self:InitRight() end end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WingSkillPanel:__delete()
    self.OnHideEvent:Fire()
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end
    if self.useLeftBtn.image ~= nil then
        self.useLeftBtn.image.sprite = nil
    end
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.iconImage ~= nil then
        self.iconImage.sprite = nil
    end
    if self.resetButton ~= nil then
        self.resetButton:DeleteMe()
        self.resetButton = nil
    end
    self:AssetClearAll()
end

function WingSkillPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.wing_skill_panel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t
    self.panelBtn = t:Find("Panel"):GetComponent(Button)

    local main = t:Find("Main")
    self.mainRect = main:GetComponent(RectTransform)
    self.closeBtn = main:Find("Close"):GetComponent(Button)

    local left = main:Find("Left")
    self.leftRect = left:GetComponent(RectTransform)
    self.nameText = left:Find("Info/Name"):GetComponent(Text)
    self.iconTrans = left:Find("Info/Icon")
    self.gradeText = left:Find("Info/Grade"):GetComponent(Text)
    self.maxSkillText = left:Find("Info/MaxSkill"):GetComponent(Text)
    self.eyeBtn = left:Find("Info/ImgEye"):GetComponent(Button)
    self.skillContainer = left:Find("MaskLayer/Container")
    self.skillCloner = left:Find("MaskLayer/Cloner").gameObject

    self.useLeftBtn = left:Find("Bottom/Use"):GetComponent(Button)
    self.useLeftBtn_txt = self.useLeftBtn.transform:Find("Text"):GetComponent(Text)
    self.resetLeftBtn = left:Find("Bottom/Reset"):GetComponent(Button)
    self.resetAreaPoint = self.resetLeftBtn.transform:FindChild("ImgPoint").gameObject
    self.resetLeftText = left:Find("Bottom/Reset/Text"):GetComponent(Text)
    self.downObj = left:Find("Down").gameObject

    local right = main:Find("Right")
    self.rightRect = right:GetComponent(RectTransform)
    self.skillItemContainerRect = right:Find("Skill/Container"):GetComponent(RectTransform)
    for i=1,4 do
        self.skillRightList[i] = WingSkillItem.New(self.model, right:Find("Skill/Container/SkillItem"..i).gameObject)
    end
    self.needContainer = right:Find("MaterialInfo/Needs")
    self.needCloner = right:Find("MaterialInfo/Needs/Item").gameObject
    self.needRect = self.needContainer:GetComponent(RectTransform)
    self.saveBtn = right:Find("Bottom/Save"):GetComponent(Button)
    self.saveBtnText = right:Find("Bottom/Save/Text"):GetComponent(Text)
    self.resetArea = right:Find("Bottom/Reset")
    self.resetAreaPoint:SetActive(true)
    self.descResetText = right:Find("Bottom/Desc"):GetComponent(Text)
    self.resetAreaRect = self.resetArea:GetComponent(RectTransform)
    self.skillLayout = LuaBoxLayout.New(self.skillItemContainerRect.gameObject, {axis = BoxLayoutAxis.X, cspacing = 0})

    local right1 = main:Find("Right1")
    self.rightRect1 = right1:GetComponent(RectTransform)
    self.titleText = right1:Find("Title/Text"):GetComponent(Text)
    self.right1Container = right1:Find("MaskLayer/Container")
    self.right1Cloner = right1:Find("MaskLayer/Cloner").gameObject

    self.closeBtn.onClick:AddListener(function() self:OnClose() end)
    self.panelBtn.onClick:AddListener(function() self:OnClose() end)
    self.eyeBtn.onClick:AddListener(function() self:OnEye() end)
    self.resetLeftBtn.onClick:AddListener(function()
        self.resetAreaPoint:SetActive(false)
        if self.rightOpen == true then self:Resize(1) else self:Resize(2) end
    end)

    self.useLeftBtn.onClick:AddListener(function()
        if WingsManager.Instance.model.cur_selected_option == WingsManager.Instance.valid_plan then
            NoticeManager.Instance:FloatTipsByString(TI18N("已经使用该方案"))
            return
        end

        local time = WingsManager.Instance.change_times+1
        time = time > DataWing.data_switch_cost_length and DataWing.data_switch_cost_length or time
        local cost = DataWing.data_switch_cost[time].coin
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.cancelSecond = 30
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function()
            WingsManager.Instance:Send11609(WingsManager.Instance.valid_plan)
        end
        confirmData.content = TI18N("切换翅膀技能，需要消耗%s{assets_2,90000}，确定要切换吗？")
        NoticeManager.Instance:ConfirmTips(confirmData)


    end)

    self.descResetText.text = self.resetDescString
    self.resetButton = BuyButton.New(self.resetArea.gameObject, self.resetString)
    self.resetButton.key = "WingSkillReset"
    self.resetButton.protoId = 11606
    self.resetButton:Show()
    self.saveBtnText.text = self.saveString
    self.saveBtn.onClick:AddListener(function()
        local skills = nil
        local tmp_skills = nil
        for i=1,#WingsManager.Instance.plan_data do
            if WingsManager.Instance.plan_data[i].index == WingsManager.Instance.valid_plan then
                skills = WingsManager.Instance.plan_data[i].skills
                tmp_skills = WingsManager.Instance.plan_data[i].tmp_skills
                break
            end
        end
        if skills == nil then
            skills = {}
        end
        if tmp_skills == nil then
            tmp_skills = {}
        end

        local waitCheck = false
        local lockSkills = {}
        for i,v in ipairs(skills) do
            if v.is_lock == 1 then
                table.insert(lockSkills, v)
            end
        end

        for i,v in ipairs(lockSkills) do
            local isExsit = false
            for _,vTemp in ipairs(tmp_skills) do
                if vTemp.id == v.id and vTemp.lev == v.lev then
                    isExsit = true
                    break
                end
            end

            if isExsit == false then
                waitCheck = true
                break
            end
        end

        if waitCheck then
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.cancelSecond = 30
            confirmData.sureLabel = TI18N("保存")
            confirmData.cancelLabel = TI18N("取消")
            confirmData.sureCallback = function()
                self.mgr:Send11607()
            end
            confirmData.content = TI18N("重置技能锁定状态与你当前技能锁定技能状态<color='#00ff00'>不同</color>，保存将会<color='#ffff00'>覆盖</color>掉你当前翅膀技能锁状态，确定要进行保存吗？")
            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            self.mgr:Send11607()
        end
    end)

    left:Find("Text"):GetComponent(Text).text = self.currentSkillString
end

function WingSkillPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingSkillPanel:OnEye()
    -- if self.rightOpen1 == true then
    --     self:Resize(1)
    -- else
    --     self:Resize(3)
    -- end
    self:OnClose()
    self.mgr:OpenSkillPreview()
end

function WingSkillPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onUpdateReset:AddListener(self.reloadListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.reloadListener)

    self:InitLeft()
    self:Resize(1)

    if self.mgr.redPointDic[1] ~= nil then
        if not self.mgr:CheckWakenSkillRedPoint() then
            self.mgr.redPointDic[1] = false
            self.mgr.onUpdateRed:Fire()
        end
    end

    self.transform:SetAsLastSibling()
end

function WingSkillPanel:OnHide()
    self:RemoveListeners()
end

function WingSkillPanel:RemoveListeners()
    self.mgr.onUpdateReset:RemoveListener(self.reloadListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.reloadListener)
end

function WingSkillPanel:OnClose()
    self.model:CloseWingSkillPanel()
end

-- status == 1 隐藏右边
-- status == 2 展开右边
-- status == 3 展开右边1
function WingSkillPanel:Resize(status)
    local leftSize = self.leftRect.sizeDelta
    local rightSize = self.rightRect.sizeDelta
    local rightSize1 = self.rightRect1.sizeDelta
    local status = status or 1
    self.leftRect.anchoredPosition = Vector2.zero
    if status == 1 then
        self.rightOpen = false
        self.rightOpen1 = false
        self.rightRect.gameObject:SetActive(false)
        self.rightRect1.gameObject:SetActive(false)
        self.mainRect.sizeDelta = Vector2(leftSize.x, leftSize.y)
    elseif status == 2 then
        self.rightOpen = true
        self.rightOpen1 = false
        self.rightRect.gameObject:SetActive(true)
        self.rightRect1.gameObject:SetActive(false)
        self.mainRect.sizeDelta = Vector2(leftSize.x + rightSize.x, leftSize.y)
        self.rightRect.anchoredPosition = Vector2(leftSize.x, 0)
        self:InitRight()
    elseif status == 3 then
        self.rightOpen = false
        self.rightOpen1 = true
        self.rightRect.gameObject:SetActive(false)
        self.rightRect1.gameObject:SetActive(true)
        self.mainRect.sizeDelta = Vector2(leftSize.x + rightSize1.x, leftSize.y)
        self.rightRect1.anchoredPosition = Vector2(leftSize.x, 0)
        self:InitRight1()
    end
end

function WingSkillPanel:InitLeft()
    local model = self.model
    local grade = self.mgr.grade
    local wingData = DataWing.data_base[self.mgr.wing_id]
    local baseData = DataItem.data_get[self.mgr:GetItemByGrade(grade)]

    self.maxSkillText.text = string.format(self.maxSkillString, tostring(WingsManager.Instance:GetMaxSkillCount(grade)))
    self.gradeText.text = string.format(self.gradeString, BaseUtils.NumToChn(grade))

    if self.itemData == nil then
        self.itemData = ItemData.New()
    end
    self.itemData:SetBase(baseData)
    if self.itemSlot == nil then
        self.itemSlot = ItemSlot.New()
        NumberpadPanel.AddUIChild(self.iconTrans.gameObject, self.itemSlot.gameObject)
    end
    self.itemSlot:SetAll(self.itemData, {nobutton = true, inbag = false})
    self.nameText.text = ColorHelper.color_item_name(baseData.quality, wingData.name)

    if self.layout == nil then self.layout = LuaBoxLayout.New(self.skillContainer, {axis = BoxLayoutAxis.Y, cspacing = 0}) end

    local skillData = {}
    local option_skill_data = nil
    local option_tmp_skill_data = nil
    for i=1,#WingsManager.Instance.plan_data do
        if WingsManager.Instance.plan_data[i].index == WingsManager.Instance.valid_plan then
            option_skill_data = WingsManager.Instance.plan_data[i].skills
            option_tmp_skill_data = WingsManager.Instance.plan_data[i].tmp_skills
            break
        end
    end
    if option_skill_data == nil then
        option_skill_data = {}
    end
    if option_tmp_skill_data == nil then
        option_tmp_skill_data = {}
    end
    for i=1,WingsManager.Instance:GetMaxSkillCount(WingsManager.Instance.grade) do
        local tab = nil

        if option_skill_data[i] ~= nil then
            tab = option_skill_data[i]
        else
            tab = {}
        end

        skillData[i] = tab
    end

    if #option_skill_data == 0 then
        self.resetAreaPoint:SetActive(true)
    else
        self.resetAreaPoint:SetActive(false)
    end

    for i,v in ipairs(skillData) do
        if self.skillList[i] == nil then
            local obj = GameObject.Instantiate(self.skillCloner)
            obj.name = tostring(i)
            self.skillList[i] = WingSkillShowItem.New(model, obj)
            self.skillList[i].callback = function() if self.rightOpen ~= true then self:Resize(2) end end
            self.skillList[i].assetWrapper = self.assetWrapper
            self.layout:AddCell(obj)
        end
        self.skillList[i]:SetData(v)
    end

    self.layout:ReSize()
    -- for i,v in ipairs(skillData) do
    --     self.layout:AddCell(self.skillList[i].gameObject)
    -- end

    for i=#skillData + 1, #self.skillList do
        self.skillList[i]:SetActive(false)
    end
    self.skillCloner:SetActive(false)

    if #option_skill_data == 0 and self.mgr.grade >= 4 and #option_tmp_skill_data == 0 and WingsManager.Instance.valid_plan == 1 then
        self.resetLeftText.text = self.freeString
    else
        self.resetLeftText.text = self.resetString
    end

    self.downObj:SetActive(#skillData > 2)


    --如果选中方案是当前方案，则按钮显示使用中同时灰掉
    if WingsManager.Instance.model.cur_selected_option == WingsManager.Instance.valid_plan then
        self.useLeftBtn.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.useLeftBtn_txt.text = TI18N("使用中")
    else
        self.useLeftBtn.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.useLeftBtn_txt.text = TI18N("使用")
    end
end

function WingSkillPanel:InitRight()
    local model = self.model
    local grade = self.mgr.grade
    local skillData = {}
    self.baseToNum = {}
    local wingData = DataWing.data_base[self.mgr.wing_id]
    local pos = self.saveBtn.gameObject:GetComponent(RectTransform).anchoredPosition

    local skill_data = nil

    local option_tmp_skill_data = nil
    local option_skill_data = nil

    for i=1,#WingsManager.Instance.plan_data do
        if WingsManager.Instance.plan_data[i].index == WingsManager.Instance.valid_plan then
            option_skill_data = WingsManager.Instance.plan_data[i].skills
            option_tmp_skill_data = WingsManager.Instance.plan_data[i].tmp_skills
            BaseUtils.dump(WingsManager.Instance.plan_data[i], tostring(WingsManager.Instance.valid_plan))
            break
        end
    end
    if option_skill_data == nil then
        option_skill_data = {}
    end
    if option_tmp_skill_data == nil then
        option_tmp_skill_data = {}
    end

    if #option_tmp_skill_data > 0 then
        skill_data = option_tmp_skill_data
        self.saveBtn.gameObject:SetActive(true)
        self.resetAreaRect.anchoredPosition = Vector2(-pos.x, pos.y)
    else
        skill_data = option_skill_data
        self.saveBtn.gameObject:SetActive(false)
        self.resetAreaRect.anchoredPosition = Vector2(0, pos.y)
    end

    for i=1,4 do
        local tab = nil
        if skill_data[i] ~= nil then
            tab = skill_data[i]
        else
            tab = {}
        end
        skillData[i] = tab
    end
    self.skillLayout:ReSet()
    if #skill_data == 2 then
        self.skillLayout.border = 28
    elseif #skill_data == 3 then
        self.skillLayout.border = 15
    elseif #skill_data == 4 then
        self.skillLayout.border = 7
    end

    -- BaseUtils.dump(skillData)
    for i,v in ipairs(self.skillRightList) do
        v.assetWrapper = self.assetWrapper
        v:update_my_self(skillData[i],i)
        if skillData[i].id == nil then
            v:SetActive(false)
        else
            self.skillLayout:AddCell(v.gameObject)
            v:SetActive(true)
        end
    end
    self.skillItemContainerRect.sizeDelta = Vector2((#skill_data * 60 + (#skill_data - 1) * self.skillLayout.border), 60)
    self.needCloner:SetActive(false)

    local resetData = DataWing.data_reset_skill[grade]
    local needCount = 0
    if resetData ~= nil then
        for i,v in ipairs(resetData.cost) do
            if self.needList[i] == nil then
                local obj = GameObject.Instantiate(self.needCloner)
                self.needList[i] = WingMergeNeedItem.New(model, obj)
                obj.name = tostring(i)
                obj.transform:SetParent(self.needContainer)
                obj.transform.localScale = Vector3.one
            end
            if v[1] >= 90000 then
            else
                self.baseToNum[v[1]] = {need = v[2]}
            end
            self.needList[i]:SetData(v)
        end

        needCount = needCount + #resetData.cost
    end

    local option_skill_data = nil

    for i=1,#WingsManager.Instance.plan_data do
        if WingsManager.Instance.plan_data[i].index == WingsManager.Instance.valid_plan then
            option_skill_data = WingsManager.Instance.plan_data[i].skills
            break
        end
    end
    option_skill_data = option_skill_data or {}

    if option_skill_data then
        local lockCount = 0
        for i,v in ipairs(option_skill_data) do
            if v.is_lock == 1 then
                lockCount = lockCount + 1
            end
        end

        if lockCount > 0 then
            local lockData = DataWing.data_get_lock[grade]
            if lockData ~= nil then
                for i,v in ipairs(lockData.item_list) do
                    if self.needList[needCount + i] == nil then
                        local obj = GameObject.Instantiate(self.needCloner)
                        self.needList[needCount + i] = WingMergeNeedItem.New(model, obj)
                        obj.name = tostring(i)
                        obj.transform:SetParent(self.needContainer)
                        obj.transform.localScale = Vector3.one
                    end

                    local costData = {}
                    costData[1] = v[1]
                    costData[2] = lockCount * v[2]
                    self.baseToNum[costData[1]] = {need = costData[2]}
                    self.needList[needCount + i]:SetData(costData)
                end

                needCount = needCount + #lockData.item_list
            end
        end
    end

    for i=needCount + 1,#self.needList do
        self.needList[i]:SetActive(false)
    end

    local w = 100
    if needCount > 3 then
        w = 90
    end
    self.needRect.sizeDelta = Vector2(w * needCount, 117)

    if #option_skill_data == 0 and grade >= 4 and #option_tmp_skill_data == 0 and WingsManager.Instance.valid_plan == 1 then
        self.resetButton.content = self.freeString
    else
        self.resetButton.content = self.resetString
    end

    if #option_skill_data == 0 and grade >= 4 and #option_tmp_skill_data == 0 then
        self.resetButton:Layout({}, function () self:OnResetBtnClick() end, function(baseidToBuyInfo) self:callbackAfter12406(baseidToBuyInfo) end)
    else
        self.resetButton:Layout(self.baseToNum, function () self:OnResetBtnClick() end, function(baseidToBuyInfo) self:callbackAfter12406(baseidToBuyInfo) end)
    end

    self.resetButton:ReleaseFrozon()
end

function WingSkillPanel:OnResetBtnClick()
    local option_skill_data = nil
    for i=1,#WingsManager.Instance.plan_data do
        if WingsManager.Instance.plan_data[i].index == WingsManager.Instance.valid_plan then
            option_skill_data = WingsManager.Instance.plan_data[i].skills
            break
        end
    end

    local itemEnough = true

    if option_skill_data then
        local lockCount = 0
        for i,v in ipairs(option_skill_data) do
            if v.is_lock == 1 then
                lockCount = lockCount + 1
            end
        end

        -- if lockCount > 0 then
        --     local lockData = DataWing.data_get_lock[self.model.grade]
        --     if lockData ~= nil then
        --         for i,v in ipairs(lockData.item_list) do
        --             local inBagNum = BackpackManager.Instance:GetItemCount(v[1])
        --             local needNum = lockCount * v[2]
        --             if inBagNum < needNum then
        --                 itemEnough = false
        --                 local baseData = DataItem.data_get[v[1]]
        --                 NoticeManager.Instance:FloatTipsByString(TI18N("所需道具不足"))
        --                 TipsManager.Instance:ShowItem({gameObject = nil, itemData = baseData})
        --                 self.resetButton:ReleaseFrozon()
        --                 break
        --             end
        --         end
        --     end
        -- end
    end

    if itemEnough then
        WingsManager.Instance:Send11606()
    end
end

function WingSkillPanel:InitRight1()
    if self.layout1 == nil then self.layout1 = LuaBoxLayout.New(self.right1Container.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 0}) end

    local setdata = function(tab, data)
        tab.descText.text = "<color=#FF609F>"..data.name..":</color>"..data.desc
        local h = tab.originHeight
        if h < tab.descText.preferredHeight - tab.descRect.anchoredPosition.y then
            h = tab.descText.preferredHeight - tab.descRect.anchoredPosition.y
        end
        tab.rect.sizeDelta = Vector2(tab.originWidth, h)
        tab.obj:SetActive(true)
    end
    local skillDataList = self.mgr:GetSkillList(self.mgr.grade)
    self.right1Cloner:SetActive(false)
    for i,v in ipairs(skillDataList) do
        local tab = self.skillRightItemList[i]
        if tab == nil then
            tab = {}
            tab.obj = GameObject.Instantiate(self.right1Cloner)
            tab.obj.name = tostring(i)
            local t = tab.obj.transform
            tab.descText = t:Find("Desc"):GetComponent(Text)
            tab.rect = tab.obj:GetComponent(RectTransform)
            tab.descRect = tab.descText.gameObject:GetComponent(RectTransform)
            tab.originWidth = tab.rect.sizeDelta.x
            tab.originHeight = tab.rect.sizeDelta.y
            self.skillRightItemList[i] = tab
            self.layout1:AddCell(tab.obj)
        end
        setdata(tab, DataSkill.data_wing_skill[v.."_1"])
    end
    self.layout1:ReSize()

    for i=#skillDataList + 1, #self.skillRightItemList do
        self.skillRightItemList[i].obj:SetActive(false)
    end
end

function WingSkillPanel:callbackAfter12406(baseidToBuyInfo)
    if DataWing.data_reset_skill[self.mgr.grade] ~= nil then
        for k, v in pairs(self.needList) do
            if baseidToBuyInfo[v.base_id] ~= nil then
                v:SetData(v.data, baseidToBuyInfo[v.base_id])
            end
        end
    end
end

WingSkillShowItem = WingSkillShowItem or BaseClass()

function WingSkillShowItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    local t = gameObject.transform
    self.transform = t

    self.resetString = TI18N("重置技能有机会获得")

    self.iconTrans = t:Find("Icon")
    self.iconPlusObj = self.iconTrans:Find("Plus").gameObject
    self.iconImage = self.iconTrans:Find("Image"):GetComponent(Image)
    self.iconLoader = SingleIconLoader.New(self.iconTrans:Find("Image").gameObject)
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.centerText = t:Find("CenterText"):GetComponent(Text)
    self.descText = t:Find("Desc"):GetComponent(Text)
    self.rect = gameObject:GetComponent(RectTransform)
    self.descRect = self.descText.gameObject:GetComponent(RectTransform)
    self.tagImage = self.iconTrans:Find("Tag"):GetComponent(Image)
    self.lockImage = self.iconTrans:Find("Lock"):GetComponent(Image)
    self.originHeight = self.rect.sizeDelta.y
    self.originWidth = self.rect.sizeDelta.x

    self.btn = self.iconTrans.gameObject:GetComponent(Button)
    self.btn.onClick:AddListener(function() self:OnClick() end)

    self.lockBtn = t:Find("LockBtn"):GetComponent(Button)
    self.lockBtn.onClick:AddListener(function() self:OnLockClick() end)
    self.lockBtnImage = self.lockBtn.transform:Find("LockImage"):GetComponent(Image)
    self.unlockBtnImage = self.lockBtn.transform:Find("UnlockImage"):GetComponent(Image)
    self.centerText.text = self.resetString
end

function WingSkillShowItem:__delete()
    if self.skillSlot ~= nil then
        self.skillSlot:DeleteMe()
        self.skillSlot = nil
    end
    if self.resetButton ~= nil then
        self.resetButton:DeleteMe()
        self.resetButton = nil
    end
end

function WingSkillShowItem:SetData(data)
    local h = self.originHeight
    self.data = data
    self.tagImage.gameObject:SetActive(false)
    self.lockImage.gameObject:SetActive(false)
    self.lockBtn.gameObject:SetActive(false)
    if data.id == nil then
        self.centerText.gameObject:SetActive(true)
        self.nameText.gameObject:SetActive(false)
        self.descText.gameObject:SetActive(false)
        self.iconPlusObj:SetActive(true)

        -- if self.skillSlot ~= nil then
        --     self.skillSlot.gameObject:SetActive(false)
        -- end
        self.iconImage.gameObject:SetActive(false)
    else
        self.skillData = DataSkill.data_wing_skill[data.id.."_"..data.lev]
        self.centerText.gameObject:SetActive(false)
        self.nameText.gameObject:SetActive(true)
        self.descText.gameObject:SetActive(true)
        self.iconPlusObj:SetActive(false)

        self.nameText.text = self.skillData.name --.." <color=#C7F9FF>Lv."..data.lev.."</color>"
        self.descText.text = self.skillData.desc

        if h < self.descText.preferredHeight - self.descRect.anchoredPosition.y then
            h = self.descText.preferredHeight - self.descRect.anchoredPosition.y
        end

        self.iconImage.gameObject:SetActive(true)
        -- self.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_skill, tostring(self.skillData.icon))
        self.iconLoader:SetSprite(SingleIconType.SkillIcon, self.skillData.icon)

        self.tagImage.gameObject:SetActive(self.skillData.cost_anger > 0)

        if WingsManager.Instance.grade > 4 then
            self.lockBtn.gameObject:SetActive(true)
        end

        if data.is_lock == 1 then
            self.lockImage.gameObject:SetActive(true)
            self.lockBtnImage.gameObject:SetActive(true)
            self.unlockBtnImage.gameObject:SetActive(false)
        else
            self.lockBtnImage.gameObject:SetActive(false)
            self.unlockBtnImage.gameObject:SetActive(true)
        end
    end
    self.rect.sizeDelta = Vector2(self.originWidth, h)

    self:SetActive(true)
end

function WingSkillShowItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function WingSkillShowItem:OnClick()
    if self.data ~= nil and self.data.id ~= nil then
        TipsManager.Instance:ShowSkill({gameObject = self.iconImage.gameObject, skillData = self.skillData, type = Skilltype.wingskill})
    else
        if self.callback ~= nil then
            self.callback()
        end
    end
end

function WingSkillShowItem:OnLockClick()
    if self.data ~= nil and self.data.id ~= nil then
        local confirmData = NoticeConfirmData.New()
        if WingsManager.Instance.grade <= 4 then
            confirmData.type = ConfirmData.Style.Sure
            confirmData.sureSecond = 180
            confirmData.cancelSecond = -1
            confirmData.sureLabel = TI18N("确认")

            confirmData.content = TI18N("当前只有<color='#00ff00'>1个</color>翅膀技能，不需要进行<color='#ffff00'>锁定</color>")
        else
            confirmData.type = ConfirmData.Style.Normal
            confirmData.sureSecond = -1
            confirmData.cancelSecond = 180
            confirmData.sureLabel = TI18N("确认")
            confirmData.cancelLabel = TI18N("取消")
            confirmData.sureCallback = function() WingsManager.Instance:Send11610(self.data.id, self.data.lev) end

            if self.data.is_lock == 1 then
                confirmData.content = string.format(TI18N("确定要<color='#ffff00'>解锁</color>翅膀技能<color='#00ff00'>[%s]</color>吗？解除锁定后重置将会改变该技能"), self.skillData.name)
            else
                confirmData.content = string.format(TI18N("确定要<color='#ffff00'>锁定</color>翅膀技能<color='#00ff00'>[%s]</color>吗？被锁定的技能<color='#ffff00'>重置时</color>将不会被改变"), self.skillData.name)
            end
        end

        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

WarriorGuardSelect = WarriorGuardSelect or BaseClass()

function WarriorGuardSelect:__init(model, gameObject, assetWrapper, callback)
    self.assetWrapper = assetWrapper
    self.model = model
    self.gameObject = gameObject
    self.callback = callback
    self.isOpen = false

    self.lastSelect = nil
    self.selectTab = {}
    self.guardItemList = {}
    self.effectItemList = {}

    local t = gameObject.transform:Find("Main")
    self.rect = t:GetComponent(RectTransform)
    self.container = t:Find("Scroll/Container")
    self.containerRect = self.container:GetComponent(RectTransform)
    self.maskLayerRect = t:Find("Scroll"):GetComponent(RectTransform)
    self.cloner = t:Find("Scroll/ItemBase").gameObject
    local rect = self.cloner:GetComponent(RectTransform)
    self.clonerX = rect.sizeDelta.x
    self.clonerY = rect.sizeDelta.y
    self.cloner:SetActive(false)
    self.maxHeight = self.clonerY * 4

    self.effectContainer = t:Find("FormationEffect/MaskLayer/Container")
    self.effectCloner = t:Find("FormationEffect/MaskLayer/Cloner").gameObject
    self.effectRect = t:Find("FormationEffect/MaskLayer"):GetComponent(RectTransform)
    rect = self.effectCloner:GetComponent(RectTransform)
    self.effectClonerX = rect.sizeDelta.x
    self.effectClonerY = rect.sizeDelta.y

    self.noEffectObj = t:Find("FormationEffect/MaskLayer/NoEffect").gameObject

    gameObject.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.effectCloner:SetActive(false)

    if self.layout == nil then
        self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})
    end
    if self.effectLayout == nil then
        self.effectLayout = LuaBoxLayout.New(self.effectContainer, {axis = BoxLayoutAxis.X, cspacing = 0})
    end
end

-- 传入{base_id = base_id}列表
function WarriorGuardSelect:Show(args, pos, id, formation)
    local obj = nil
    local model = self.model
    if args == nil then
        args = {}
    end
    self.selectTab = {}
    self.lastSelect = nil
    for i,v in ipairs(args) do
        if v.base_id == id then
            self.selectTab[i] = true
            self.lastSelect = i
        else
            self.selectTab[i] = false
        end
        if self.guardItemList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            self.layout:AddCell(obj)
            self.guardItemList[i] = WarriorGuardSelectItem.New(self.model, obj, self.assetWrapper, function() self.callback(i) end)
        end
        self.guardItemList[i]:SetData(v, i)
        self.guardItemList[i]:SetActive(true)
    end

    for i=#args + 1, #self.guardItemList do
        self.guardItemList[i]:SetActive(false)
    end
    local height = #args * self.clonerY
    self.containerRect.sizeDelta = Vector2(self.clonerX, height)
    -- self.maskLayerRect.sizeDelta = Vector2(self.clonerX, height)

    if height > self.maxHeight then
        height = self.maxHeight
    end
    -- self.rect.sizeDelta = Vector2(self.clonerX, height + 60)
    self.rect.anchoredPosition = Vector2(231 + (pos - 1) * 85, -150)

    -- 阵法效果
    local formation_id = formation.id
    local formation_lev = formation.lev

    BaseUtils.dump(formation, "formation")
    if formation_id == nil then
        formation_id = 2
    end
    if formation_lev == nil then
        formation_lev = 2
    end
    local effects = DataFormation.data_list[formation_id.."_"..formation_lev]["attr_"..(pos + 1)]
    for i,v in ipairs(effects) do
        if self.effectItemList[i] == nil then
            obj = GameObject.Instantiate(self.effectCloner)
            obj.name = tostring(i)
            self.effectItemList[i] = WarriorGuardSelectEffectItem.New(model, obj)
            self.effectLayout:AddCell(obj)
        end
        self.effectItemList[i]:SetData(v, i)
    end
    for i=#effects + 1,#self.effectItemList do
        self.effectItemList[i]:SetActive(false)
    end
    self.effectRect.sizeDelta = Vector2(self.effectClonerX * #effects, self.effectClonerY)
    self.noEffectObj:SetActive(#effects == 0)

    self.gameObject:SetActive(true)
    self.isOpen = true

    self:Select(self.lastSelect)
end

function WarriorGuardSelect:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
    self.isOpen = false
end

function WarriorGuardSelect:__delete()
    for k,v in pairs(self.guardItemList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.guardItemList = nil
    for k,v in pairs(self.effectItemList) do
        if v ~= nil then
            v:DeleteMe()
            self.effectItemList[k] = nil
        end
    end
    self.effectItemList = nil
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.effectLayout ~= nil then
        self.effectLayout:DeleteMe()
        self.effectLayout = nil
    end
end

function WarriorGuardSelect:Select(index)
    if index ~= nil then
        self.guardItemList[index]:Select()
    end
end

function WarriorGuardSelect:UnSelect(index)
    if index ~= nil then
        self.guardItemList[index]:UnSelect()
    end
end

function WarriorGuardSelect:GetSelection()
    for i,v in ipairs(self.selectTab) do
        if v == true then
            return i
        end
    end
    return nil
end

WarriorGuardSelectItem = WarriorGuardSelectItem or BaseClass()

function WarriorGuardSelectItem:__init(model, gameObject, assetWrapper, callback)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.callback = callback
    local t = gameObject.transform

    self.guardNameText = t:Find("Name"):GetComponent(Text)
    self.selectObj = t:Find("Select").gameObject
    self.guardHeadImage = t:Find("HeadImg"):GetComponent(Image)
    self.button = t:GetComponent(Button)
    self.jobImage = t:Find("ClassesImg"):GetComponent(Image)
    self.levelText = t:Find("Level"):GetComponent(Text)
    self.stateObj = t:Find("State").gameObject
    self.stateImage = t:Find("State"):GetComponent(Image)
    self.stateText = t:Find("State/Text"):GetComponent(Text)
    self.scoreText = t:Find("I18N/Score"):GetComponent(Text)

    self.selected = false
end

function WarriorGuardSelectItem:SetData(data, index)
    local shouhuData = DataShouhu.data_guard_base_cfg[data.base_id]
    local state1 = (data.war_id > 0)
    local state2 = (data.guard_fight_state == ShouhuManager.Instance.model.guard_fight_state.field)

    if state1 == true then
        self.stateImage.gameObject:SetActive(true)
        self.stateImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel2")
        self.stateText.text = TI18N("上阵中")
    elseif state2 == true then
        self.stateImage.gameObject:SetActive(true)
        self.stateImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel1")
        self.stateText.text = TI18N("助战")
    else
        self.stateImage.gameObject:SetActive(false)
    end
    self.data = data
    self.guardHeadImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(data.base_id))
    self.jobImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(shouhuData.classes))
    self.guardHeadImage.gameObject:SetActive(true)
    self.guardNameText.text = ColorHelper.color_item_name(data.quality, shouhuData.alias)
    self.selectObj:SetActive(false)
    self.levelText.text = tostring(data.sh_lev)
    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function() self:OnClick() end)
    self.scoreText.text = tostring(data.score)
    self:SetActive(true)
end

function WarriorGuardSelectItem:OnClick()
    if self.data.guard_fight_state == ShouhuManager.Instance.model.guard_fight_state.field then
        if self.confirmData == nil then
            self.confirmData = NoticeConfirmData.New()
        end
        self.confirmData.content = string.format(TI18N("<color='#ffff00'>%s</color>正在<color='#ffff00'>助阵</color>，是否前往调整？"), DataShouhu.data_guard_base_cfg[self.data.base_id].alias)
        self.confirmData.sureLabel = TI18N("前往调整")
        self.confirmData.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guardian) end
        NoticeManager.Instance:ConfirmTips(self.confirmData)
    else
        if self.callback ~= nil then
            self.callback()
        end
    end
end

function WarriorGuardSelectItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function WarriorGuardSelectItem:Select()
    self.selectObj:SetActive(true)
end

function WarriorGuardSelectItem:UnSelect()
    self.selectObj:SetActive(false)
end

function WarriorGuardSelectItem:__delete()
    self.guardHeadImage.sprite = nil
    self.jobImage.sprite = nil
    self.assetWrapper = nil
    self.button.onClick:RemoveAllListeners()
    self.callback = nil

    if self.confirmData ~= nil then
        self.confirmData:DeleteMe()
        self.confirmData = nil
    end
end

WarriorGuardSelectEffectItem = WarriorGuardSelectEffectItem or BaseClass()

function WarriorGuardSelectEffectItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject

    local t = gameObject.transform
    self.upObj = t:Find("Up").gameObject
    self.downObj = t:Find("Down").gameObject
    self.nameText = t:Find("Name"):GetComponent(Text)
end

function WarriorGuardSelectEffectItem:SetData(data, index)
    self.nameText.text = KvData.attr_name_show[data.attr_name]
    self.upObj:SetActive(data.val > 0)
    self.downObj:SetActive(data.val <= 0)
    self:SetActive(true)
end

function WarriorGuardSelectEffectItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function WarriorGuardSelectEffectItem:__delete()
end
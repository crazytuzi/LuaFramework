-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaWingSkill = EncyclopediaWingSkill or BaseClass(BasePanel)


function EncyclopediaWingSkill:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaWingSkill"

    self.resList = {
        {file = AssetConfig.wingskill_pedia, type = AssetType.Main},
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

    self.toggleList = {}
    self.indexName = {}
end

function EncyclopediaWingSkill:__delete()
    self.OnHideEvent:Fire()
    if self.skillImgIconLoader ~= nil then
        self.skillImgIconLoader:DeleteMe()
        self.skillImgIconLoader = nil
    end
    for i, v in ipairs(self.skillIconList) do
        v.imgIconLoader:DeleteMe()
        v = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
    end
    self:AssetClearAll()
end

function EncyclopediaWingSkill:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.wingskill_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.title = t:Find("Desc"):GetComponent(Text)

    t:Find("ToggleList"):GetComponent(Button).onClick:AddListener(self.btnListener)
    self.toggleLabel = t:Find("ToggleList/Label"):GetComponent(Text)
    self.levList = t:Find("LevList").gameObject
    self.levList.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(self.btnListener)
    t:Find("LevList/Mask"):GetComponent(Image).enabled = true
    t:Find("LevList/Mask"):GetComponent(ScrollRect).enabled = true
    t:Find("LevList/Mask"):GetComponent(Mask).enabled = true
    t:Find("LevList/Mask").sizeDelta = Vector2(158.1, 161.2)
    t:Find("LevList").sizeDelta = Vector2(175.2, 186)
    t:Find("LevList").anchoredPosition = Vector2(-182.5, 15.57)
    local layout = LuaBoxLayout.New(t:Find("LevList/Mask/Scroll"), {axis = BoxLayoutAxis.Y, cspacing = 4, border = 4})
    local len = t:Find("LevList/Mask/Scroll").transform.childCount
    for i = 1, len do
        local tab = {}
        tab.transform = t:Find("LevList/Mask/Scroll"):GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.nameText = tab.transform:Find("I18NText"):GetComponent(Text)
        tab.btn = tab.gameObject:GetComponent(Button)
        self.toggleList[i] = tab
    end

    for i,data in ipairs(EncyclopediaManager.Instance.WingSkillData) do
        if self.toggleList[i] == nil then
            local tab = {}
            tab.gameObject = GameObject.Instantiate(self.toggleList[1].gameObject)
            tab.transform = tab.gameObject.transform
            tab.btn = tab.gameObject:GetComponent(Button)
            tab.nameText = tab.transform:Find("I18NText"):GetComponent(Text)
            self.toggleList[i] = tab
        end
        layout:AddCell(self.toggleList[i].gameObject)
        local j = i
        self.toggleList[i].btn.onClick:AddListener(function() self:ClickToggle(i) end)
        self.toggleList[i].nameText.text = string.format(TI18N("%s阶翅膀"), BaseUtils.NumToChn(data.grade))
    end
    for i=#EncyclopediaManager.Instance.WingSkillData + 1,#self.toggleList do
        self.toggleList[i].gameObject:SetActive(false)
    end
    layout:DeleteMe()

    self.detail = t:Find("Right/Detail").gameObject
    local detailTrans = self.detail.transform
    self.detailTitle = detailTrans:Find("Title/Text"):GetComponent(Text)
    self.skillImg = detailTrans:Find("Icon/Image"):GetComponent(Image)
    self.skillImgIconLoader = SingleIconLoader.New(self.skillImg.gameObject)
    self.detailDesc = detailTrans:Find("Desc"):GetComponent(Text)
    self.detailType = detailTrans:Find("SkillType"):GetComponent(Text)
    self.detailDeplete = detailTrans:Find("Deplete"):GetComponent(Text)

    self.layoutParent = t:Find("ItemList/Mask/Scroll").gameObject
    self.layout =  LuaGridLayout.New(self.layoutParent, self.setting)
    self.baseItem = t:Find("ItemList/Mask/Scroll/Item").gameObject
    for i = 1, 15 do
        -- 预创建
        table.insert(self.skillIconList, self:CreanteSlot())
    end

    self:UpdateTitle()
end

function EncyclopediaWingSkill:CreanteSlot()
    local item = GameObject.Instantiate(self.baseItem)
    item.transform:SetParent(self.layoutParent.transform)
    item.gameObject:SetActive(false)
    item.transform.position = Vector3.zero
    local slot = {}
    slot.gameObject = item
    item:GetComponent(Image).enabled = false
    slot.btn = item:GetComponent(Button)
    -- slot.img = item.transform:Find("SkillCon"):GetComponent(Image)
    slot.imgIconLoader = SingleIconLoader.New(item.transform:Find("SkillCon").gameObject)
    slot.name = item.transform:Find("SkillName"):GetComponent(Text)
    item.transform:Find("SkillCon/Select").gameObject:SetActive(false)
    slot.selectobj = item.transform:Find("SkillCon/Select").gameObject
    return slot
end

function EncyclopediaWingSkill:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaWingSkill:OnOpen()
    self:RemoveListeners()
    self:UpdateSelect()
end

function EncyclopediaWingSkill:OnHide()
    self:RemoveListeners()
end

function EncyclopediaWingSkill:RemoveListeners()
end

-- 更新标题内容
function EncyclopediaWingSkill:UpdateTitle()
    local cfgdata = DataBrew.data_alldesc["wingskill"]
    if cfgdata ~= nil then
        self.title.text = cfgdata.desc1
    end
end

-- 左侧默认选中
function EncyclopediaWingSkill:UpdateSelect()
    -- 默认选中第一个
    for i,v in ipairs(EncyclopediaManager.Instance.WingSkillData) do
        if WingsManager.Instance.grade >= v.grade then
            self:ClickToggle(i)
            return
        end
    end
    self:ClickToggle(1)
end

-- 更新右侧技能详情
function EncyclopediaWingSkill:UpdateDetail(data)
    self.currentSkillData = data
    if self.currentSkillData == nil then
        return
    end
    -- DataSkill.data_wing_skill
    -- {id = 88001, lev = 1, name = "无双之刃", icon = 88001, cost_anger = 50, desc = "屏气凝神，对敌方造成随机<color='#ffff00'>2~4次物理攻击</color>"}
    self.detailTitle.text = self.currentSkillData.name
    self.detailDesc.text = self.currentSkillData.desc
    self.detailType.text = string.format(TI18N("技能类型:战斗特技"))
    self.detailDeplete.text = string.format(TI18N("怒气消耗:<color='#ffff00'>%s</color>"), self.currentSkillData.cost_anger)
    -- self.skillImg.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_skill, self.currentSkillData.icon)
    self.skillImgIconLoader:SetSprite(SingleIconType.SkillIcon, self.currentSkillData.icon)
end

function EncyclopediaWingSkill:ClickToggleBtn()
    if self.levList.activeSelf then
        self.levList:SetActive(false)
    else
        self.levList:SetActive(true)
    end
end

-- 点击下拉列表元素
function EncyclopediaWingSkill:ClickToggle(index)
    self.levList:SetActive(false)
    if self.currIndex == index then
        return
    end
    self.currIndex = index
    local list = EncyclopediaManager.Instance.WingSkillData[index].list
    self:RefreshList(list)

    self.toggleLabel.text = self.toggleList[index].nameText.text
end

-- 刷新技能显示列表
function EncyclopediaWingSkill:RefreshList(list)
    for i,v in ipairs(self.skillIconList) do
        v.gameObject:SetActive(false)
    end

    self.layout:ReSet()
    for i, id in ipairs(list) do
        local data = DataSkill.data_wing_skill[id .. "_1"]
        local slot = self.skillIconList[i]
        if slot == nil then
            slot = self:CreanteSlot()
            table.insert(self.skillIconList, slot)
        end
        self.layout:AddCell(slot.gameObject)
        -- slot.img.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_skill, data.icon)
        slot.imgIconLoader:SetSprite(SingleIconType.SkillIcon, data.icon)
        local n = data.name
        local nlist = StringHelper.ConvertStringTable(data.name)
        if #nlist > 4 then
            n = ""
            for i = 1, 3 do
                n = n .. nlist[i]
            end
            n = n .. ".."
        end
        slot.name.text = n
        slot.btn.onClick:RemoveAllListeners()
        slot.btn.onClick:AddListener(function()
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = slot.selectobj
            self.selectgo:SetActive(true)
            self:UpdateDetail(data)
        end)
        slot.gameObject:SetActive(true)

        if i == 1 then
            -- 默认选中第一个
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = slot.selectobj
            self.selectgo:SetActive(true)
            self:UpdateDetail(data)
        end
    end
end

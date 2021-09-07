-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaGuard = EncyclopediaGuard or BaseClass(BasePanel)


function EncyclopediaGuard:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaGuard"

    self.resList = {
        {file = AssetConfig.guard_pedia, type = AssetType.Main},
        {file = AssetConfig.guard_head, type = AssetType.Dep},
        {file = AssetConfig.petevaluation_texture,type = AssetType.Dep},
        {file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep},
    }
    self.skilllist = {}
    self.selectgo = nil
    self.currGuardData = nil
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaGuard:__delete()
    self.OnHideEvent:Fire()
    for i,v in ipairs(self.skilllist) do
        v:DeleteMe()
    end
    self.skilllist = nil

    if self.Layout1 ~= nil then
        self.Layout1:DeleteMe()
    end
    if self.previewCom ~= nil then
        self.previewCom:DeleteMe()
    end
    self:AssetClearAll()
end

function EncyclopediaGuard:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guard_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.goBtn = self.transform:Find("Right/Button"):GetComponent(Button)
    self.goBtn.onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guardian, self.currGuardData.base_id)
    end)

    local soltPanel = t:Find("Right/SkillCon")
    for i=1, 8 do
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(soltPanel, slot.gameObject)
        table.insert(self.skilllist, slot)
    end

    self.ItemListCon = t:Find("ItemList/Mask/Scroll")
    self.ItemBase = t:Find("ItemList/Mask/Scroll/Item")

    self.TopDesc = t:Find("Right/TopDesc"):GetComponent(Text)
    self.previewcon = t:Find("Right/previewcon")
    t:Find("Right/pbg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    self.evaluationbtn = t:Find("Right/EvaluationButton").gameObject:GetComponent(Button)
    self.evaluationbtn.onClick:AddListener(function()
         WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petevaluation,{self.currGuardData,2})
     end
    )

    local setting1 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = -5
        ,Top = 0
    }
    self.Layout1 = LuaBoxLayout.New(self.ItemListCon, setting1)
    self:InitGuardList()
end

function EncyclopediaGuard:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaGuard:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaGuard:OnHide()
    self:RemoveListeners()
end

function EncyclopediaGuard:RemoveListeners()
end

function EncyclopediaGuard:InitGuardList()
    local GuardData = {}
    for k,v in pairs(DataShouhu.data_guard_base_cfg) do
        table.insert(GuardData, v)
    end
    table.sort(GuardData,function(a,b) return a.recruit_lev < b.recruit_lev end)
    for i,v in ipairs(GuardData) do
        local Item = nil
        Item = GameObject.Instantiate(self.ItemBase.gameObject)
        Item.gameObject:SetActive(true)
        Item.transform.localScale = Vector3.one
        Item.transform:Find("Head"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(v.avatar_id))
        Item.transform:Find("Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(v.classes))
        Item.transform:Find("GuardName"):GetComponent(Text).text = v.name
        Item.transform:Find("Class"):GetComponent(Text).text = KvData.classes_name[v.classes]
        Item.transform:Find("Score"):GetComponent(Text).text = v.base_score
        Item.transform:Find("Select").gameObject:SetActive(false)
        Item.transform:GetComponent(Button).onClick:RemoveAllListeners()
        Item.transform:GetComponent(Button).onClick:AddListener(function()
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Item.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)
            self:SetGuardData(v)
        end)
        if i == 1 then
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Item.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)

            self:SetGuardData(v)
        end
        self.Layout1:AddCell(Item)
    end
end

function EncyclopediaGuard:SetGuardData(data)
    self.currGuardData = data
    if self.previewCom ~= nil then
        self.previewCom:DeleteMe()
    end
    self.goBtn.gameObject:SetActive(data.recruit_lev <= RoleManager.Instance.RoleData.lev)
    if ShouhuManager.Instance.model:check_has_sh_by_id(data.base_id) then
        self.goBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("<color='#00ff00'>已招募</color>")
        self.goBtn.transform:GetComponent(Image).enabled = false
        self.goBtn.enabled = false
    else
        self.goBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("前往招募")
        self.goBtn.enabled = true
        self.goBtn.transform:GetComponent(Image).enabled = true
    end

    local setting = {
        name = "Guardpedia"
        ,orthographicSize = 0.6
        ,width = 256
        ,height = 256
        ,offsetY = -0.35
        ,noDrag = true
    }
    local modelData = {type = PreViewType.Shouhu, skinId = data.paste_id, modelId = data.res_id, animationId = data.animation_id, scale = 1}
    self.previewCom = PreviewComposite.New(function(composite) self:SetPreview(composite) end, setting, modelData)
    local str = TI18N("可招募等级：<color='#00ff00'>%s</color>")
    if data.recruit_lev > RoleManager.Instance.RoleData.lev then
        str = TI18N("可招募等级：<color='#b24931'>%s</color>")
    end
    self.TopDesc.text = string.format(str, tostring(data.recruit_lev))
    self:SetSkill()
end

function EncyclopediaGuard:SetPreview(preview)
    local rawImage = preview.rawImage
    if rawImage ~= nil then
        rawImage.transform:SetParent(self.previewcon)
        rawImage.transform.localPosition = Vector3(-4, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        -- preview.tpose.transform:Rotate(Vector3(350,340,5))
        -- local btn = rawImage:AddComponent(Button)
        -- btn.onClick:AddListener(function() self:OnClickBox() end)
    end
end

function EncyclopediaGuard:SetSkill()
    if self.currGuardData == nil then return end

    for i=1,#self.skilllist do
        local icon = self.skilllist[i]
        icon.gameObject.name = ""
        icon:Default()
        icon.skillData = nil
    end

    local transform = self.transform
    local base_skills = DataShouhu.data_guard_skill_cfg[self.currGuardData.base_id].skills
    local index = 1
    for i=1,#base_skills do
        local skill_id = base_skills[i][1]
        local icon = self.skilllist[i]
        icon.gameObject.name = skill_id
        local cfgdata = base_skills[i]
        local skillData = DataSkill.data_skill_guard[string.format("%s_1", cfgdata[1])]
        icon:SetAll(Skilltype.shouhuskill, {id = cfgdata[1], icon = skillData.icon, lev = cfgdata[2]})
        index = index + 1
    end

    local wakeUpSkillList = ShouhuManager.Instance.model:get_wakeup_skills(self.currGuardData.base_id)
    for i = 1, #wakeUpSkillList do
        local wakeUpData = wakeUpSkillList[i]
        local skillData = DataSkill.data_skill_guard[string.format("%s_1", wakeUpData[1])]
        local icon = self.skilllist[index]
        icon.gameObject.name = skill_id
        icon:SetAll(Skilltype.shouhuskill, {id = skillData.id, icon = skillData.icon, quality = wakeUpData[2]})
        index = index + 1
    end
end
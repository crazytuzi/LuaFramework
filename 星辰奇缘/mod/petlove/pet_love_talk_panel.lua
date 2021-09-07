-- --------------
-- 宠物情愿对话对话
-- hosr
-- --------------
PetLoveTalkPanel = PetLoveTalkPanel or BaseClass(BasePanel)

function PetLoveTalkPanel:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.pet_love_talk_panel, type = AssetType.Main}
    }

    self.switch_type = 1
    self.actionData = nil
    self.callback = nil
    self.stringTab = {}
    self.PetSkillList = {}
    self.PetSkillSlotList = {}
    self.stringover = false
    self.currentStr = ""

    self.setting = {
        name = "DialogPreview"
        ,orthographicSize = 0.46
        ,width = 359
        ,height = 341
        ,offsetX = -0.04
        ,offsetY = -0.38
        ,noDrag = true
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil

    self.lastShowId = nil

    -- 点击任意地方，是否是提交任务
    self.AnywayCommitId = 0
    -- 点击任意地方做任务链任务
    self.AnywayDoChain = false
    -- 点击任意地方回调
    self.AnywayCallback = nil
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetLoveTalkPanel:__delete()
    if self.msg ~= nil then
        self.msg:DeleteMe()
        self.msg = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.dramaOption ~= nil then
        self.dramaOption:DeleteMe()
        self.dramaOption = nil
    end

    for i,v in ipairs(self.PetSkillSlotList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.PetSkillSlotList = nil

    self.PetSkillList = nil

    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.stringTab = nil
    self.stringover = false
    self.AnywayCommitId = 0
    self.AnywayCallback = nil

end

function PetLoveTalkPanel:OnHide()
end

function PetLoveTalkPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_love_talk_panel))
    self.gameObject.name = "DialgPetLovePanel"
    self.transform = self.gameObject.transform
    -- UIUtils.AddUIChild(NoticeManager.Instance.model.noticeCanvas, self.gameObject)
    -- self.transform:SetSiblingIndex(3)
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.gameObject.transform.localPosition = Vector3.zero

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseTalkUI() end)

    self.nameTrans = self.transform:Find("Name").gameObject:GetComponent(RectTransform)
    self.nameTxt = self.nameTrans:Find("Text"):GetComponent(Text)
    self.standBgTrans = self.transform:Find("StandBg").gameObject:GetComponent(RectTransform)
    self.contentTrans = self.transform:Find("ContentContainer/Content").gameObject:GetComponent(RectTransform)
    self.contentTxt = self.contentTrans.gameObject:GetComponent(Text)
    self.PetSkillCon = self.transform:Find("ContentContainer/PetSkillCon")
    for i=1,5 do
        local skill = self.PetSkillCon:Find(string.format("PetSkill%s", i)).gameObject
        table.insert(self.PetSkillList, skill)
    end
    self.contentTxt.gameObject:SetActive(true)
    self.PetSkillCon.gameObject:SetActive(false)

    self.rawImage = self.transform:Find("RawImage").gameObject
    self.rawImageTrans = self.rawImage:GetComponent(RectTransform)
    self.rawImage:SetActive(false)
    self.optionObj = self.transform:Find("Option").gameObject
    self.optionObj:SetActive(false)

    self.nameTrans.anchoredPosition = Vector2(-130, 168)
    self.standBgTrans.anchoredPosition = Vector2(-320, 10)
    self.contentTrans.anchoredPosition = Vector2(280, -35)
    self.rawImageTrans.anchoredPosition = Vector2(-320, 220)

    self.msg = MsgItemExt.New(self.contentTxt, 501, 18, 23)

    self:ClearMainAsset()

    self:update_info()
end

--更新界面信息
function PetLoveTalkPanel:update_info()
    local cfg_data = self.model:get_pet_cfg_data(self.model.touchNpcData.baseid)
    local pet_cfg_data = DataPet.data_pet[cfg_data.pet_base_id]
    self.nameTxt.text = cfg_data.desc


    local base = BaseUtils.copytab(DataUnit.data_unit[self.model.touchNpcData.baseid])
    base.looks = self.model.touchNpcData.looks
    base.classes = self.model.touchNpcData.classes
    base.sex = self.model.touchNpcData.sex
    base.name = self.model.touchNpcData.name
    base.buttons = {
        [1] = {
            button_id = 4,
            button_args = {
            },
            button_show = cfg_data.dialog,
            button_desc = TI18N("查看技能"),
        },
        [2] = {
            button_id = 38,
            button_args = {
            },
            button_show = "[]",
            button_desc = TI18N("50万{assets_2,90000}变换形象"),
        }
    }

    self:ChangeText(base.buttons[1].button_show)
    local ok = self:ShowOption({base = base, tasks = {}})
    if ok then
        self:ShowPreview(base)
    end

    local cfg_skill_list = DataPet.data_pet[cfg_data.pet_base_id].base_skills
    -- local skill_list = {}
    -- for i=1,#cfg_skill_list do
    --     skill_list[i] = {icon = cfg_skill_list[i][1]}
    -- end
    self:UpdateSkills(cfg_skill_list)

    --还原默认状态
    self.dramaOption.buttons[1]["label"].text = TI18N("查看技能")
    self.contentTxt.gameObject:SetActive(true)
    self.PetSkillCon.gameObject:SetActive(false)
    self.switch_type = 1
end

--更新技能图标
function PetLoveTalkPanel:UpdateSkills(skills)
    for i=1,#self.PetSkillList do
        self.PetSkillList[i]:SetActive(false)
    end
    for i=1, #skills do
        local skillItem = self.PetSkillSlotList[i]
        local skill_cfg_data = DataSkill.data_petSkill[string.format("%s_1", skills[i][1])]
        if skillItem == nil then
            skillItem = SkillSlot.New()
            UIUtils.AddUIChild(self.PetSkillList[i], skillItem.gameObject)
            self.PetSkillSlotList[i] = skillItem
        end

        self.PetSkillList[i].transform:Find("TxtSkill"):GetComponent(Text).text = skill_cfg_data.name
        skillItem.gameObject:SetActive(true)
        self.PetSkillList[i]:SetActive(true)
        skillItem:SetAll(Skilltype.petskill,skill_cfg_data)
        -- skillItem:SetNotips(true)
    end
end

--切换显示技能或者是描述
function PetLoveTalkPanel:switchCon()
    if self.switch_type == 1 then
        self.dramaOption.buttons[1]["label"].text = TI18N("返回")
        self.contentTxt.gameObject:SetActive(false)
        self.PetSkillCon.gameObject:SetActive(true)
        self.switch_type = 2
    else
        self.dramaOption.buttons[1]["label"].text = TI18N("查看技能")
        self.contentTxt.gameObject:SetActive(true)
        self.PetSkillCon.gameObject:SetActive(false)
        self.switch_type = 1
    end
end

function PetLoveTalkPanel:SetRawImage(composite)
    local image = composite.rawImage
    image.transform:SetParent(self.rawImage.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3(20, 0, 0)
    composite.tpose.transform:Rotate(Vector3(0, 0, 0))
    self.rawImage:SetActive(true)
end

function PetLoveTalkPanel:ShowPreview(npcData)
    self.npcData = npcData
    self.nameTxt.text = self.npcData.name
    -- npc在左边
    if self.lastShowId ~= self.npcData.id then
        self.lastShowId = self.npcData.id
        self.rawImage:SetActive(false)
        if npcData.classes == nil or npcData.sex == nil or npcData.classes == 0 then
            local modelData = {type = PreViewType.Npc, skinId = npcData.skin, modelId = npcData.res, animationId = npcData.animation_id, scale = 1}
            self:Preview(modelData)
        else
            local modelData = {type = PreViewType.Role, classes = npcData.classes, sex = npcData.sex, looks = npcData.looks}
            self:Preview(modelData)
        end
    end
    self.gameObject:SetActive(true)
end

function PetLoveTalkPanel:Preview(modelData)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

function PetLoveTalkPanel:ShowOption(options)
    self.AnywayDoChain = false
    self.AnywayCommitId = 0
    if self.dramaOption == nil then
        self.dramaOption = PetLoveTalkOption.New(self)
        self.dramaOption:InitPanel(self.optionObj)
    end
    return self.dramaOption:Show(options)
end

function PetLoveTalkPanel:ChangeText(str)
    self.msg:SetData(QuestEumn.FilterContent(str))
end
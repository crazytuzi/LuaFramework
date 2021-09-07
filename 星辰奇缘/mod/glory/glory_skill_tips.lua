GlorySkillTips = GlorySkillTips or BaseClass(BasePanel)

function GlorySkillTips:__init()
    self.resList = {
        {file = AssetConfig.glory_skill_dialog, type = AssetType.Main}
    }
    self.skillObjList = {}

    self.listener = function ()
        if self.openArgs[1] == 1 then
            self:Init1()
        elseif self.openArgs[1] == 2 then
            self:Init2()
        end
    end
    self.OnOpenEvent:Add(self.listener)
end

function GlorySkillTips:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.OnOpenEvent:RemoveAll()
    self:AssetClearAll()
end

function GlorySkillTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glory_skill_dialog))
    self.gameObject.name = "GlorySkillTips"
    UIUtils.AddUIChild(NoticeManager.Instance.model.noticeCanvas, self.gameObject)

    local t = self.gameObject.transform
    self.main1 = t:Find("Main1").gameObject
    self.main2 = t:Find("Main2").gameObject

    self.main1:SetActive(false)
    self.main2:SetActive(false)

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
        self.main1:SetActive(false)
        self.main2:SetActive(false)
        self.gameObject:SetActive(false)
    end)

    self.listener()
end

function GlorySkillTips:Init1()
    local t = self.main1.transform

    local skilldata = DataGlory.data_skill[self.openArgs[2]]
    for i=1,2 do
        local skillt = t:Find("Skill"..i)
        self.skillObjList[i] = skillt
        local iconImage = skillt:Find("Icon/Image"):GetComponent(Image)
        local nameText = skillt:Find("Name"):GetComponent(Text)
        local btn = skillt:Find("Icon"):GetComponent(Button)

        nameText.text = skilldata["skill_name_"..i]

        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
            if self.selectIndex ~= nil then
                self.skillObjList[self.selectIndex]:Find("Icon/Select").gameObject:SetActive(false)
            end
            self.skillObjList[i]:Find("Icon/Select").gameObject:SetActive(false)
            self.selectIndex = i
            TipsManager.Instance:ShowText({gameObject = self.skillObjList[i], itemData = {skilldata["skill_desc_"..i]}})
        end)
    end

    self.selectIndex = 1
    self.skillObjList[1]:Find("Icon/Select").gameObject:SetActive(false)

    t:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
    t:Find("Button"):GetComponent(Button).onClick:AddListener(function()
        GloryManager.Instace:send14402({skill_id = self.selectIndex})
    end)

    self.main1:SetActive(true)
end

function GlorySkillTips:Init2()
    local t = self.main2.transform

    local skilldata = DataGlory.data_skill[self.openArgs[2].."_"..RoleManager.Instance.RoleData.classes]

    for i=1,2 do
        local skillt = t:Find("Skill"..i)
        local iconImage = skillt:Find("Icon/Image"):GetComponent(Image)
        local nameText = skillt:Find("Name"):GetComponent(Text)
        local descText = skillt:Find("Desc"):GetComponent(Text)

        nameText.text = skilldata["skill_name_"..i]
        descText.text = skilldata["skill_desc_"..i]
    end

    local btn = t:Find("Skill2/TransformArea")
    btn.gameObject:SetActive(false)

    self.main2:SetActive(true)
end

function GlorySkillTips:Init3( ... )
    local t = self.main2.transform

    local skilldata = DataGlory.data_skill[self.openArgs[2].."_"..RoleManager.Instance.RoleData.classes]

    for i=1,2 do
        local skillt = t:Find("Skill"..i)
        local iconImage = skillt:Find("Icon/Image"):GetComponent(Image)
        local nameText = skillt:Find("Name"):GetComponent(Text)
        local descText = skillt:Find("Desc"):GetComponent(Text)

        nameText.text = skilldata["skill_name_"..i]
        descText.text = skilldata["skill_desc_"..i]
    end

    local btn = t:Find("Skill2"):GetComponent(Button)
    btn.gameObject:SetActive(true)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function()
        if self.openArgs[3] == 1 then
            GloryManager.Instance:send14403({skill_order = self.openArgs[2], skill_id = 2})
        else
            GloryManager.Instance:send14403({skill_order = self.openArgs[2], skill_id = 1})
        end
    end)

    self.main2:SetActive(true)
end
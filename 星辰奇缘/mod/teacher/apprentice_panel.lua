-- 师徒，询问是否成为师徒面板
-- @author zgs
ApprenticePanel = ApprenticePanel or BaseClass(BasePanel)

function ApprenticePanel:__init(model)
    self.model = model
    self.name = "ApprenticePanel"

    self.resList = {
        {file = AssetConfig.apprentice_panel, type = AssetType.Main},
        {file = AssetConfig.heads, type = AssetType.Dep},
        -- {file = AssetConfig.bible_textures, type = AssetType.Dep}

    }
    self.data = nil
    self.OnOpenEvent:AddListener(function()
        self.data = self.openArgs
        self:UpdatePanel()
    end)
    self.isTeacher = true
    self.teacher = nil
    self.student = nil
    self.OnHideEvent:AddListener(function () self:OnHide() end)
end

function ApprenticePanel:OnHide()
    self:DeleteMe()
end

function ApprenticePanel:OnInitCompleted()
    self.data = self.openArgs
    self:UpdatePanel()
end

function ApprenticePanel:__delete()
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.ap = nil
    self.model = nil
end

function ApprenticePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.apprentice_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    -- self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    -- self.closeBtn.onClick:AddListener(function()
    --     self:OnClickClose()
    -- end)

    self.MainCon = self.transform:FindChild("Main/Con")

    self.titleText = self.transform:Find("Main/Title/Text"):GetComponent(Text)
    self.titleText.text = TI18N("拜师")
    self.descText = self.MainCon:FindChild("DescText"):GetComponent(Text)

    self.teacherText = self.MainCon:FindChild("THead/TText"):GetComponent(Text)
    self.teacherImage = self.MainCon:Find("THead/Image"):GetComponent(Image)
    self.teacherSelectedObj = self.MainCon:Find("THead/Selected").gameObject
    self.teacherSelectedObj:SetActive(false)
    self.teacherLabelObj = self.MainCon:Find("THead/Lable").gameObject
    self.teacherLabelObj:SetActive(false)

    self.studentText = self.MainCon:FindChild("SHead/SText"):GetComponent(Text)
    self.studentImage = self.MainCon:Find("SHead/Image"):GetComponent(Image)
    self.studentSelectedObj = self.MainCon:Find("SHead/Selected").gameObject
    self.studentSelectedObj:SetActive(false)
    self.studentLabelObj = self.MainCon:Find("SHead/Lable").gameObject
    self.studentLabelObj:SetActive(false)
    
    self.agreeBtn = self.MainCon:Find("AgreeButton"):GetComponent(Button)
    self.agreeTxt = self.agreeBtn.gameObject.transform:Find("Text"):GetComponent(Text)
    self.opposeBtn = self.MainCon:FindChild("OpposeButton"):GetComponent(Button)
    self.opposeTxt = self.opposeBtn.gameObject.transform:Find("Text"):GetComponent(Text)

    self.agreeBtn.onClick:AddListener( function() self:onClickAgreeBtn() end)
    self.opposeBtn.onClick:AddListener( function() self:onClickOpposeBtn() end)

    -- self:DoClickPanel()
end

function ApprenticePanel:onClickAgreeBtn()
    if self.isTeacher == true then
        TeacherManager.Instance:send15800(self.student.id,self.student.platform,self.student.zone_id,"")
    else
        TeacherManager.Instance:send15802(self.teacher.id,self.teacher.platform,self.teacher.zone_id,1)
    end
    self:Hiden()
end

function ApprenticePanel:onClickOpposeBtn()
    if self.isTeacher == false then
        TeacherManager.Instance:send15802(self.teacher.id,self.teacher.platform,self.teacher.zone_id,0)
    end
    self:Hiden()
end

function ApprenticePanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    if self.isTeacher == false then
                        TeacherManager.Instance:send15802(self.teacher.id,self.teacher.platform,self.teacher.zone_id,0)
                    end
                    self:Hiden()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function ApprenticePanel:UpdatePanel()
    -- if TeamManager.Instance.teamNumber == 2 then
    --     local myData = RoleManager.Instance.RoleData
    --     for key, value in pairs(TeamManager.Instance.memberTab) do
    --         -- value.rid, value.platform, value.zone_id
    --          if value.status == RoleEumn.TeamStatus.Leader then
    --             --队长师父
    --             self.teacher = value
    --         else
    --             self.student = value
    --         end
    --     end
    -- end
    if self.data.tsFlag == TeacherEnum.Type.Student then
        self.student = self.data
        self.teacher = RoleManager.Instance.RoleData
        self.isTeacher = true
    else
        self.teacher = self.data
        self.student = RoleManager.Instance.RoleData
        self.isTeacher = false
    end
    -- if TeamManager.Instance:IsSelfCaptin() == true then
    if self.isTeacher == true then
        -- self.isTeacher = true
        self.descText.text = string.format(TI18N("你是否同意与<color='%s'>%s</color>结成师徒关系呢？"),ColorHelper.color[1],self.student.name)
    else
        -- self.isTeacher = false
        self.descText.text = string.format(TI18N("你是否同意与<color='%s'>%s</color>结成师徒关系呢？"),ColorHelper.color[1],self.teacher.name)
    end
    -- self.teacherText.text = string.format("师父：<color='%s'>%s</color>",ColorHelper.color[1],self.teacher.name)
    -- self.studentText.text = string.format("徒弟：<color='%s'>%s</color>",ColorHelper.color[1],self.student.name)
    self.teacherText.text = string.format("<color='%s'>%s</color>",ColorHelper.color[1],self.teacher.name)
    self.studentText.text = string.format("<color='%s'>%s</color>",ColorHelper.color[1],self.student.name)
    self.teacherImage.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", self.teacher.classes, self.teacher.sex))
    self.studentImage.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", self.student.classes, self.student.sex))
end
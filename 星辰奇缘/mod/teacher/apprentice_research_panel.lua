-- 拜师问卷调查
-- @author zgs
ApprenticeResearchPanel = ApprenticeResearchPanel or BaseClass(BasePanel)

function ApprenticeResearchPanel:__init(model)
    self.model = model
    self.name = "ApprenticeResearchPanel"

    self.localData = {
        [1] = {question=TI18N("您希望师傅的性别是？"),
               option_a=TI18N("男"),
               option_b=TI18N("女"),
               option_c=TI18N("随意"),
               option_d="",
              },
        [2] = {question=TI18N("您希望师傅的职业是？"),
               option_a=TI18N("输出型（狂剑/魔导/战弓/月魂/圣骑）"),
               option_b=TI18N("辅助型（秘言/兽灵）"),
               option_c=TI18N("随意"),
               option_d="",
              },
    }
    self.total = #self.localData

    self.resList = {
        {file = AssetConfig.apprentice_research_panel, type = AssetType.Main},
        -- {file = AssetConfig.heads, type = AssetType.Dep},
        -- {file = AssetConfig.bible_textures, type = AssetType.Dep}

    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdatePanel()
    end)
    self.OnHideEvent:AddListener(function () self:OnHide() end)
end

function ApprenticeResearchPanel:OnHide()
    self:DeleteMe()
end

function ApprenticeResearchPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdatePanel()
end

function ApprenticeResearchPanel:__delete()
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.arp = nil
    self.model = nil
end

function ApprenticeResearchPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.apprentice_research_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainCon = self.gameObject.transform:Find("MainCon")
    local closeBtn = self.gameObject.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self:Hiden()
    end)

    self.mainCon:Find("ImgTitle/TxtTitle"):GetComponent(Text).text = TI18N("问卷调查")

    self.OpenCon = self.mainCon:FindChild("OpenCon")
    self.ImgTec = self.OpenCon:FindChild("ImgTec")
    self.TxtLevDesc = self.ImgTec:FindChild("TxtLevDesc"):GetComponent(Text)
    self.TxtLevDesc.text = TI18N("拜师问卷")
    self.TxtQuestion = self.OpenCon:FindChild("TxtQuestion"):GetComponent(Text)

    self.btn_list = {}
    self.BottomCon = self.OpenCon:FindChild("BottomCon")
    self.Btn_A = self.BottomCon:FindChild("Btn_A"):GetComponent(Button)
    self.Text_A = self.Btn_A.transform:FindChild("Text"):GetComponent(Text)

    self.Btn_B = self.BottomCon:FindChild("Btn_B"):GetComponent(Button)
    self.Text_B = self.Btn_B.transform:FindChild("Text"):GetComponent(Text)

    self.Btn_C = self.BottomCon:FindChild("Btn_C"):GetComponent(Button)
    self.Text_C = self.Btn_C.transform:FindChild("Text"):GetComponent(Text)

    self.Btn_D = self.BottomCon:FindChild("Btn_D"):GetComponent(Button)
    self.Text_D = self.Btn_D.transform:FindChild("Text"):GetComponent(Text)

    self.Btn_A.image.sprite = self.Btn_B.image.sprite

    table.insert(self.btn_list, self.Btn_A)
    table.insert(self.btn_list, self.Btn_B)
    table.insert(self.btn_list, self.Btn_C)
    table.insert(self.btn_list, self.Btn_D)

    self.Btn_A.onClick:AddListener(function() self:on_click_answer(1) end)
    self.Btn_B.onClick:AddListener(function() self:on_click_answer(2) end)
    self.Btn_C.onClick:AddListener(function() self:on_click_answer(3) end)
    self.Btn_D.onClick:AddListener(function() self:on_click_answer(4) end)

    self:DoClickPanel()
end

function ApprenticeResearchPanel:on_click_answer(index)
    self.model.noProblem = self.model.noProblem + 1
    table.insert(self.model.answers,index)
    if self.model.noProblem > 2 then
        --问卷结束
        local sex = 2
        if self.model.answers[1] == 1 then
            sex = 1
        elseif self.model.answers[1] == 2 then
            sex = 0
        end
        local clazz = self.model.answers[2]
        TeacherManager.Instance:send15816(sex,clazz)

        self.model.noProblem = 1
        self.model.answers = nil
        self.model.answers = {}
        self:Hiden()
    else
        self:updateContent()
    end
end

function ApprenticeResearchPanel:onClickAgreeBtn()
    self:Hiden()
end

function ApprenticeResearchPanel:onClickOpposeBtn()
    self:Hiden()
end

function ApprenticeResearchPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self:Hiden()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function ApprenticeResearchPanel:UpdatePanel()
    self:updateContent()
end

function ApprenticeResearchPanel:updateContent()
    local question_cfg_data = self.localData[self.model.noProblem]
    self.TxtQuestion.text = string.format("<color='#3166ad'>%s%s/%s%s:</color>%s", TI18N("第"), self.model.noProblem, self.total, TI18N("题"), question_cfg_data.question)
    self:update_btn_state(self.Btn_A, self.Text_A, question_cfg_data.option_a, "A.")
    self:update_btn_state(self.Btn_B, self.Text_B, question_cfg_data.option_b, "B.")
    self:update_btn_state(self.Btn_C, self.Text_C, question_cfg_data.option_c, "C.")
    self:update_btn_state(self.Btn_D, self.Text_D, question_cfg_data.option_d, "D.")
end

--根据传入的答案状态设置按钮是否显示
function ApprenticeResearchPanel:update_btn_state(btn, btn_txt, btn_str, prefix)
    if btn_str == "" then
        btn.gameObject:SetActive(false)
        -- self:set_btn_state(btn, false)
    else
        btn.gameObject:SetActive(true)
        -- self:set_btn_state(btn, true)
        -- self:set_btn_answer_state(btn, 0)
        btn_txt.text = string.format("%s%s" , prefix, btn_str)
    end
end
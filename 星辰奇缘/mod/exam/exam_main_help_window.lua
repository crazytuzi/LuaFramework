ExamMainHelpWindow  =  ExamMainHelpWindow or BaseClass(BaseWindow)

function ExamMainHelpWindow:__init(model)
    self.name  =  "ExamMainHelpWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.exam_question_help_win, type  =  AssetType.Main}
    }
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.has_init = false
    self.btn_list = nil
    return self
end

function ExamMainHelpWindow:OnHide()
end

function ExamMainHelpWindow:OnShow()
end

function ExamMainHelpWindow:__delete()
    self.btn_list = nil
    self.has_init = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function ExamMainHelpWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exam_question_help_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ExamMainHelpWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform:GetComponent(RectTransform).localPosition = Vector3.zero

    self.MainCon = self.gameObject.transform:Find("MainCon")
    local closeBtn = self.MainCon:Find("CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseExamHelpUI()
    end)

    -- self.model.examHelpData
    self.OpenCon = self.MainCon:FindChild("OpenCon")
    self.ImgTec = self.OpenCon:FindChild("ImgTec")
    self.TxtLevDesc = self.ImgTec:FindChild("TxtLevDesc"):GetComponent(Text)
    self.TxtQuestion = self.OpenCon:FindChild("TxtQuestion"):GetComponent(Text)
    self.TxtQuestion.transform.anchorMax = Vector2(0, 1)
    self.TxtQuestion.transform.anchorMin = Vector2(0, 1)
    self.TxtQuestion.transform.pivot = Vector2(0, 1)
    self.TxtQuestion.transform:GetComponent(RectTransform).anchoredPosition = Vector2(19, -48)
    self.TxtQuestionMsg = MsgItemExt.New(self.TxtQuestion, 465.4, 17, 23)

    self.BottomCon = self.OpenCon:FindChild("BottomCon")
    self.Btn_A = self.BottomCon:FindChild("Btn_A"):GetComponent(Button)
    self.Text_A = self.Btn_A.transform:FindChild("Text"):GetComponent(Text)

    self.Btn_B = self.BottomCon:FindChild("Btn_B"):GetComponent(Button)
    self.Text_B = self.Btn_B.transform:FindChild("Text"):GetComponent(Text)

    self.Btn_C = self.BottomCon:FindChild("Btn_C"):GetComponent(Button)
    self.Text_C = self.Btn_C.transform:FindChild("Text"):GetComponent(Text)

    self.Btn_D = self.BottomCon:FindChild("Btn_D"):GetComponent(Button)
    self.Text_D = self.Btn_D.transform:FindChild("Text"):GetComponent(Text)

    self.btn_list = {}
    table.insert(self.btn_list, self.Btn_A)
    table.insert(self.btn_list, self.Btn_B)
    table.insert(self.btn_list, self.Btn_C)
    table.insert(self.btn_list, self.Btn_D)
    self.option_normal_sprite = self.Btn_B.image.sprite
    self.option_unable_sprite = self.Btn_A.image.sprite
    self.Btn_A.onClick:AddListener(function() self:on_click_answer(1) end)
    self.Btn_B.onClick:AddListener(function() self:on_click_answer(2) end)
    self.Btn_C.onClick:AddListener(function() self:on_click_answer(3) end)
    self.Btn_D.onClick:AddListener(function() self:on_click_answer(4) end)

    self.has_init = true
    self:update_question_info(self.model.examHelpData)
end

--更新问题内容
function ExamMainHelpWindow:update_question_info(data)
    if self.has_init == false then
        return
    end
    self.data = data
    self.OpenCon.gameObject:SetActive(true)
    for i=1,#self.btn_list do
        self.btn_list[i].enabled = true
    end
    local question_cfg_data = DataQuestion.data_guild_question_cfg[data.question]

    if question_cfg_data == nil then
        question_cfg_data = {}
        for i = 1, #data.str_array do
            local temp = data.str_array[i]
            if temp.key == 1003 then
                question_cfg_data.question = temp.value
            elseif temp.key == 1004 then
                question_cfg_data.option_a = temp.value
            elseif temp.key == 1005 then
                question_cfg_data.option_b = temp.value
            elseif temp.key == 1006 then
                question_cfg_data.option_c = temp.value
            elseif temp.key == 1007 then
                question_cfg_data.option_d = temp.value
            end
        end
        question_cfg_data.subject = 6
    end

    self.TxtLevDesc.text = ""
    -- self.TxtQuestion.text = string.format("<color='%s'>[%s]</color>%s", self.model.exam_type_name_colors[question_cfg_data.subject] , self.model.exam_type_name[question_cfg_data.subject], question_cfg_data.question)
    self.TxtQuestionMsg:SetData(string.format("<color='%s'>[%s]</color>%s", self.model.exam_type_name_colors[question_cfg_data.subject] , self.model.exam_type_name[question_cfg_data.subject], question_cfg_data.question))
    self:update_btn_state(self.Btn_A, self.Text_A, question_cfg_data.option_a, "A.")
    self:update_btn_state(self.Btn_B, self.Text_B, question_cfg_data.option_b, "B.")
    self:update_btn_state(self.Btn_C, self.Text_C, question_cfg_data.option_c, "C.")
    self:update_btn_state(self.Btn_D, self.Text_D, question_cfg_data.option_d, "D.")
end

--根据传入的答案状态设置按钮是否显示
function ExamMainHelpWindow:update_btn_state(btn, btn_txt, btn_str, prefix)
    if btn_str == "" then
        btn.gameObject:SetActive(false)
        self:set_btn_state(btn, false)
    else
        btn.gameObject:SetActive(true)
        self:set_btn_state(btn, true)
        self:set_btn_answer_state(btn, 0)
        btn_txt.text = string.format("%s%s" , prefix, btn_str)
    end
end

function ExamMainHelpWindow:set_btn_answer_state(btn, flag)
    local imgRight = btn.transform:FindChild("ImgRight").gameObject:SetActive(false)
    local imgWrong = btn.transform:FindChild("ImgWrong").gameObject:SetActive(false)
end

--更新传入按钮的状态
function ExamMainHelpWindow:set_btn_state(btn, state)
    btn.enabled = state
    if state then
        btn.image.sprite = self.option_normal_sprite
    else
        btn.image.sprite = self.option_unable_sprite
    end
end

--按钮点击监听
function ExamMainHelpWindow:on_click_answer(index)
    ExamManager.Instance:request14519(self.data.id, index)
end
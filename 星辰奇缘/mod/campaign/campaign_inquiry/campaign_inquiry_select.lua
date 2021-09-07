CampaignInquirySelectWindow = CampaignInquirySelectWindow or BaseClass(BaseWindow)

function CampaignInquirySelectWindow:__init(model)
    self.Mgr = CampaignInquiryManager.Instance
    self.model = model
    self.name = "CampaignInquirySelectWindow"
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.campaign_inquiry_select, type = AssetType.Main},
        {file = AssetConfig.campaign_inquiry, type = AssetType.Dep, holdTime = 5},
        -- {file = AssetConfig.base_textures, type = AssetType.Dep},
        -- {file = AssetConfig.basecompress_textures, type = AssetType.Dep},
        {file = AssetConfig.campaigninquiry2, type = AssetType.Main},

    }

    self.itemSlot = {}
    self.reward = {}
    self.canSelect = true

    self.selectList = {{},{},{},{}}
    self.currentSelect = 0

    self.ongetrate = function (data)
        self:OnAnswer(data)
    end

    self.onreply = function (data)
        self:ReplyTips(data)
    end

    self.imgList1 = {}
    self.imgList2 = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function CampaignInquirySelectWindow:__delete()
    self.OnHideEvent:Fire()

    if self.questionImg ~= nil then
        self.questionImg:DeleteMe()
    end
    for k,v in pairs(self.itemSlot) do
        v:DeleteMe()
    end
    self.itemSlot = {}

    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    for i=1,4 do
        if self.selectList[i].rate ~= nil then
            self.selectList[i].rate.sprite = nil
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CampaignInquirySelectWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.campaign_inquiry_select))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.main = self.gameObject.transform:Find("Main")
    self.gameObject.name = self.name
    self.main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    self.questionBg = self.main:Find("questionImg/Bg")
    self.questionImg = SingleIconLoader.New(self.main:Find("questionImg/Image").gameObject)
    self.bg = self.main:Find("Bg"):GetComponent(RectTransform)
    UIUtils.AddBigbg(self.questionBg, GameObject.Instantiate(self:GetPrefab(AssetConfig.campaigninquiry2)))

    self.question = self.main:Find("question/Text"):GetComponent(Text)

    local reward = self.main:Find("Reward")


    self.rewardImg = reward:Find("Image"):GetComponent(Image)
    self.reward[1] = reward:Find("Reward1")
    self.reward[2] = reward:Find("Reward2")
    self.rewardDesc = reward:Find("Desc"):GetComponent(Text)

    local list = self.main:Find("Option")
    for i=1,4 do
        self.selectList[i].option = list:GetChild(i-1)
        self.selectList[i].answer = self.selectList[i].option:Find("answer"):GetComponent(Text)
        self.selectList[i].select = self.selectList[i].option:Find("Select").gameObject
        self.selectList[i].rightOrNot = self.selectList[i].option:Find("RightOrNot"):GetComponent(Image)
        self.selectList[i].option:GetComponent(Button).onClick:AddListener(function ()
            if self.canSelect == true then
                if self.currentSelect ~= 0 then
                    self.selectList[self.currentSelect].select:SetActive(false)
                end
                self.currentSelect = i
                self.selectList[i].select:SetActive(true)
            end
        end)
        self.selectList[i].rate = self.selectList[i].option:Find("Rate"):GetComponent(Image)
        self.selectList[i].rateTxt = self.selectList[i].option:Find("Rate/Text"):GetComponent(Text)
    end

    self.confirmButton = self.main:Find("ConfirmButton"):GetComponent(Button)
    self.btnTxt =  self.main:Find("ConfirmButton/Text"):GetComponent(Text)
    self.confirmButton.onClick:RemoveAllListeners()
    self.confirmButton.onClick:AddListener(function ()
        if self.openArgs.status == 1 then
            if self.currentSelect == 0 then
                NoticeManager.Instance:FloatTipsByString(TI18N("请选择答案"))
            else
                CampaignInquiryManager.Instance:Send20601({inquiry_id = self.openArgs.id,answer = self.currentSelect })
                self.openArgs.answer = self.currentSelect
                CampaignInquiryManager.Instance:Send20602(self.openArgs.id)
                self.confirmButton.gameObject:SetActive(false)
                self.rewardDesc.text = TI18N("完成任务将会揭晓答案，\n快去完成任务吧！")
            end
        elseif self.openArgs.status == 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("您已经答过了"))
        elseif self.openArgs.status == 3 then
            CampaignInquiryManager.Instance:Send20603(self.openArgs.id)

            if self.effect ~= nil then
                self.effect:SetActive(false)
            end
            self.confirmButton.gameObject:SetActive(false)
            self.rewardImg.gameObject:SetActive(true)
            self.rewardImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "I18NHasGetTxt")
            self.rewardImg:SetNativeSize()

            CampaignInquiryManager.Instance.isRed = false

            CampaignManager.Instance.model:CheckRed(805)

        end
    end)
end

function CampaignInquirySelectWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CampaignInquirySelectWindow:OnOpen()
    self:AddListeners()
    BaseUtils.dump(self.openArgs, "答题数据")
    self.currentSelect = 0
    self:SetData(self.openArgs)
end

function CampaignInquirySelectWindow:OnHide()
    self:RemoveListeners()
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end

function CampaignInquirySelectWindow:AddListeners()
    self:RemoveListeners()
    CampaignInquiryManager.Instance.onGetRate:AddListener(self.ongetrate)
    CampaignInquiryManager.Instance.onReply:AddListener(self.onreply)
end

function CampaignInquirySelectWindow:RemoveListeners()
    CampaignInquiryManager.Instance.onGetRate:RemoveListener(self.ongetrate)
    CampaignInquiryManager.Instance.onReply:RemoveListener(self.onreply)
end

function CampaignInquirySelectWindow:OnClose()
    self.model:CloseSelectWindow()

end

function CampaignInquirySelectWindow:ReSize(index)
    if self.imgList1[index] == nil then
        self.main.sizeDelta = Vector2(479, 383)
        self.questionBg.gameObject:SetActive(false)
        self.questionImg.gameObject:SetActive(false)
        self.bg.sizeDelta = Vector2(434,270)
        self.bg.anchoredPosition = Vector2(-1,-177)
    else
        self.main.sizeDelta = Vector2(479, 497)
        self.questionBg.gameObject:SetActive(true)
        self.questionImg.gameObject:SetActive(true)
        if self.openArgs.status < 3 then
            -- self.questionImg.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_pet2, self.imgList1[index])
            self.questionImg:SetSprite(SingleIconType.SkillIcon, self.imgList1[index], true)
        else
            -- self.questionImg.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_pet2, self.imgList2[index])
            self.questionImg:SetSprite(SingleIconType.SkillIcon, self.imgList2[index], true)
        end
        self.bg.sizeDelta = Vector2(434,381)
        self.bg.anchoredPosition = Vector2(-1,-233)
    end
end

function CampaignInquirySelectWindow:SetData(data)
    local index = data.id
    local question_id = DataCampInquiry.data_clue_info[index].question_id
    local question = DataQuestion.inquiry_questionData[question_id]
    self.question.text = question.question
    local optionList = {}
    optionList[1] = question.option_a
    optionList[2] = question.option_b
    optionList[3] = question.option_c
    optionList[4] = question.option_d

    self:ReSize(index)

    for i=1,4 do
        if optionList[i] ~= "" then
            self.selectList[i].option.gameObject:SetActive(true)
            self.selectList[i].answer.text = optionList[i]
        else
            self.selectList[i].option.gameObject:SetActive(false)
        end
    end

    if data.status == 1 then
        for i=1,4 do
            self.selectList[i].rate.gameObject:SetActive(false)
            self.selectList[i].select:SetActive(false)
            self.selectList[i].rightOrNot.gameObject:SetActive(false)
        end
        self.canSelect = true
        self.rewardImg.gameObject:SetActive(false)
        self.confirmButton.gameObject:SetActive(true)
        self.btnTxt.text = TI18N("确定选择")
        self.rewardDesc.text = TI18N("挑选您心目中的答案，\n揭开线索即可领取左侧奖励，\n答对更有额外奖励！")
    elseif data.status == 2 then
        for i=1,4 do
            self.selectList[i].select:SetActive(false)
            self.selectList[i].rightOrNot.gameObject:SetActive(false)
        end
        self.selectList[data.answer].select:SetActive(true)
        CampaignInquiryManager.Instance:Send20602(data.id)
        self.canSelect = false
        self.rewardImg.gameObject:SetActive(false)
        self.confirmButton.gameObject:SetActive(false)
        self.rewardDesc.text = TI18N("挑选您心目中的答案，\n揭开线索即可领取左侧奖励，\n答对更有额外奖励！")
    elseif data.status == 3 then
        for i=1,4 do
            self.selectList[i].select:SetActive(false)
            self.selectList[i].rightOrNot.gameObject:SetActive(false)
        end
        self.selectList[data.answer].select:SetActive(true)
        CampaignInquiryManager.Instance:Send20602(data.id)
        self.canSelect = false
        self.selectList[data.answer].rightOrNot.gameObject:SetActive(true)
        self.selectList[question.answer].rightOrNot.gameObject:SetActive(true)
        self.selectList[data.answer].rightOrNot.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ExamWrongIcon")
        self.selectList[question.answer].rightOrNot.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ExamRightIcon")
        -- if data.answer == question.answer then
            self.confirmButton.gameObject:SetActive(true)
            self.btnTxt.text = TI18N("领取奖励")
            if self.effect == nil then
                self.effect = BibleRewardPanel.ShowEffect(20053,self.confirmButton.transform, Vector3(1.8, 0.7, 1),Vector3(-55, -15, -400))
            end
            self.effect:SetActive(true)
            self.rewardImg.gameObject:SetActive(false)
        -- else
        --     self.confirmButton.gameObject:SetActive(false)
        --     self.rewardImg.gameObject:SetActive(true)
        --     self.rewardImg.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_inquiry, "lostI18N")
        --     self.rewardImg:SetNativeSize()
        -- end
        self.rewardDesc.text = TI18N("线索已开启，您猜对了吗？")
    else
        for i=1,4 do
            self.selectList[i].select:SetActive(false)
            self.selectList[i].rightOrNot.gameObject:SetActive(false)
        end
        self.selectList[data.answer].select:SetActive(true)
        CampaignInquiryManager.Instance:Send20602(data.id)
        self.canSelect = false
        self.selectList[data.answer].rightOrNot.gameObject:SetActive(true)
        self.selectList[question.answer].rightOrNot.gameObject:SetActive(true)
        self.selectList[data.answer].rightOrNot.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ExamWrongIcon")
        self.selectList[question.answer].rightOrNot.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ExamRightIcon")

        self.confirmButton.gameObject:SetActive(false)
        self.rewardImg.gameObject:SetActive(true)
        self.rewardImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "I18NHasGetTxt")
        self.rewardImg:SetNativeSize()
        self.rewardDesc.text = TI18N("线索已开启，您猜对了吗？")
    end


    local roleData = RoleManager.Instance.RoleData
    local reward = {}
    for k,v in pairs(DataCampInquiry.data_inquiry_reward) do
        if v.id == (index) and (roleData.lev > v.lev_min or roleData.lev == v.lev_min) and (roleData.lev < v.lev_max or roleData.lev == v.lev_max) and v.sex == 2 or v.sex == roleData.sex then
            reward = v.rewards
        end
    end
    for i=1,2 do
        if reward[i] ~= nil then
            self.itemSlot[i] = ItemSlot.New()
            UIUtils.AddUIChild(self.reward[i], self.itemSlot[i].gameObject)
            local itemBaseData = BackpackManager:GetItemBase(reward[i][1])
            local itemData = ItemData.New()
            itemData:SetBase(itemBaseData)
            itemData.bind = reward[i][2]
            self.itemSlot[i]:SetAll(itemData, { nobutton = true })
            self.itemSlot[i]:SetNum(reward[i][3])
        end
    end
end

function CampaignInquirySelectWindow:OnAnswer(data)
    self.canSelect = false

    BaseUtils.dump(data)
    local selectData = {0,0,0,0}
    local total = 0
    for k,v in pairs(data.answer_info) do
        selectData[v.answer] = v.count
        total = total + v.count
    end
    for i=1,4 do
        if self.openArgs.answer == i then
            self.selectList[i].rate.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_inquiry, "rateBg1")
        else
            self.selectList[i].rate.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_inquiry, "rateBg2")
        end
        self.selectList[i].rate.gameObject:SetActive(true)
        self.selectList[i].rateTxt.text =  string.format(TI18N("支持率:%s"),BaseUtils.Round(selectData[i]/total*100)).."%"
    end
end

function CampaignInquirySelectWindow:ReplyTips(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

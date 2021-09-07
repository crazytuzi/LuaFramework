-- 功能预告面板
-- xhs  20171120

CampaignInquiryWindow = CampaignInquiryWindow or BaseClass(BaseWindow)

function CampaignInquiryWindow:__init(model)
    self.Mgr = CampaignInquiryManager.Instance
    self.model = model
    self.name = "CampaignInquiryWindow"
    self.windowId = WindowConfig.WinID.campaign_inquiry_window
    self.cacheMode = CacheMode.Visible

    self.ongetdata = function (data)
        self:SetData(data.camp_inquiry[1])
    end

    self.getquest = function (data)
        self:SetQuestData(data)
    end

    self.resList = {
        {file = AssetConfig.campaign_inquiry_window, type = AssetType.Main},
        {file = AssetConfig.campaign_inquiry, type = AssetType.Dep, holdTime = 5},
        {file = AssetConfig.campaigninquiry1, type = AssetType.Main},
        -- {file = AssetConfig.base_textures, type = AssetType.Dep},
        -- {file = AssetConfig.basecompress_textures, type = AssetType.Dep},
    }

    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function CampaignInquiryWindow:__delete()
    self.OnHideEvent:Fire()

    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end
    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end
    if self.timerId3 ~= nil then
        LuaTimer.Delete(self.timerId3)
        self.timerId3 = nil
    end
    if self.timerId4 ~= nil then
        LuaTimer.Delete(self.timerId4)
        self.timerId4 = nil
    end

    if self.processEffect ~= nil then
        self.processEffect:DeleteMe()
        self.processEffect = nil
    end

    if self.btnEft ~= nil then
        self.btnEft:DeleteMe()
        self.btnEft = nil
    end

    for i=(1 + self.Mgr.clueStart),(3 + self.Mgr.clueStart) do
        if self.itemList[i].bg ~= nil then
            self.itemList[i].bg.sprite = nil
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CampaignInquiryWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.campaign_inquiry_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local main = self.gameObject.transform:Find("Main")
    self.gameObject.name = self.name
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.campaigninquiry1)))
    self.openBtn = main:Find("OpenButton"):GetComponent(Button)

    self.Mgr.clueStart = DataCampInquiry.data_inquiry_camp[1].id - 1

    local list = main:Find("List")

    for i=(1 + self.Mgr.clueStart),(3 + self.Mgr.clueStart) do
        self.itemList[i] = {}
        local item = list:Find(tostring(i - self.Mgr.clueStart))
        self.itemList[i].bg = item:GetComponent(Image)
        self.itemList[i].reel = item:Find("Reel").gameObject
        self.itemList[i].desc = item:Find("Desc").gameObject
        self.itemList[i].descTxt = item:Find("Desc/Text"):GetComponent(Text)
        self.itemList[i].btn = item:Find("Button"):GetComponent(Button)
        self.itemList[i].btnTxt = item:Find("Button/Text"):GetComponent(Text)
        self.itemList[i].redPoint = item:Find("Button/RedPoint").gameObject
        self.itemList[i].openReel = item:Find("OpenReel")
        self.itemList[i].info = item:Find("OpenReel/GameObject/Text"):GetComponent(Text)
        self.itemList[i].info.fontSize = 16
    end

    local campId = DataCampInquiry.data_inquiry_camp[1].camp_id
    local start_time = DataCampaign.data_list[campId].cli_start_time[1]
    local end_time = DataCampaign.data_list[campId].cli_end_time[1]
    main:Find("Time"):GetComponent(Text).text = string.format("竞猜时间:%s月%s日-%s月%s日", start_time[2], start_time[3], end_time[2],end_time[3])

    main:Find("TitleImage/Text"):GetComponent(Text).text = DataCampaign.data_list[campId].name



end

function CampaignInquiryWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()

end

function CampaignInquiryWindow:OnOpen()
    self:AddListeners()
    CampaignInquiryManager.Instance:Send20600()

end

function CampaignInquiryWindow:OnHide()
    self:RemoveListeners()
    if self.btnEft ~= nil then
        self.btnEft:SetActive(false)
    end
end

function CampaignInquiryWindow:AddListeners()
    self:RemoveListeners()
    CampaignInquiryManager.Instance.onGetData:AddListener(self.ongetdata)
    CampaignInquiryManager.Instance.getQuestStatus:AddListener(self.getquest)
end

function CampaignInquiryWindow:RemoveListeners()
    CampaignInquiryManager.Instance.onGetData:RemoveListener(self.ongetdata)
    CampaignInquiryManager.Instance.getQuestStatus:RemoveListener(self.getquest)

end

function CampaignInquiryWindow:OnClose()
    CampaignInquiryManager.Instance:CloseWindow()
end

function CampaignInquiryWindow:SetData(data)
    if data == nil or data.inquiry_status == 0 then
        return
    end

    self.itemData = {}
    for k,v in pairs(data.clue_list) do
        self.itemData[v.id] = v
    end

    local data = DataCampInquiry.data_clue_info

    --BaseUtils.dump(self.itemData,"整合数据")
    local haveQuest = false
    for i=1 + self.Mgr.clueStart , 3 + self.Mgr.clueStart do
        self.itemList[i].redPoint:SetActive(false)
        if self.itemData[i].status == 0 then
            self.itemList[i].bg.sprite  = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "WindowBg2")
            self.itemList[i].bg.color = Vector4(0,0,0,143/255)
            self.itemList[i].reel:SetActive(true)
            self.itemList[i].desc:SetActive(true)
            self.itemList[i].descTxt.text = data[i].desc
            self.itemList[i].openReel.gameObject:SetActive(false)
            self.itemList[i].btn.gameObject:SetActive(false)


        elseif self.itemData[i].status == 1 then
            self.itemList[i].bg.sprite  = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Select2")
            self.itemList[i].bg.color = Vector4(1,1,1,1)
            self.itemList[i].bg.type = Image.Type.Sliced

            self.itemList[i].reel:SetActive(true)
            self.itemList[i].desc:SetActive(true)
            self.itemList[i].descTxt.text = data[i].desc
            self.itemList[i].openReel.gameObject:SetActive(false)

            self.itemList[i].btn.gameObject:SetActive(true)
            self.itemList[i].btnTxt.text = TI18N("猜一猜")
            self.itemList[i].btn.onClick:RemoveAllListeners()
            self.itemList[i].btn.onClick:AddListener(function ()
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.inquiry_select_win, self.itemData[i])
            end)



        elseif self.itemData[i].status == 2 then

            CampaignInquiryManager.Instance:Send10200()

            self.itemList[i].bg.sprite  = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Select2")
            self.itemList[i].bg.color = Vector4(1,1,1,1)
            self.itemList[i].bg.type = Image.Type.Sliced

            self.itemList[i].reel:SetActive(true)
            self.itemList[i].desc:SetActive(true)
            self.itemList[i].openReel.gameObject:SetActive(false)

            self.itemList[i].btn.gameObject:SetActive(true)
            self.itemList[i].btnTxt.text = TI18N("猜一猜")
            self.itemList[i].btn.onClick:RemoveAllListeners()
            self.itemList[i].btn.onClick:AddListener(function ()
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.inquiry_select_win, self.itemData[i])
            end)

            haveQuest = true

            if CampaignInquiryManager.Instance.questOver == true then

                if self.btnEft == nil then
                    self.btnEft = BibleRewardPanel.ShowEffect(20053,self.openBtn.transform, Vector3(1.8, 0.7, 1),Vector3(-55, -15, -400))
                end
                self.btnEft:SetActive(true)

            end



        elseif self.itemData[i].status == 3 then
            self.itemList[i].bg.sprite  = self.assetWrapper:GetSprite(AssetConfig.campaign_inquiry, "whiteframe")
            self.itemList[i].bg.color = Vector4(1,1,1,1)
            self.itemList[i].btn.gameObject:SetActive(true)
            self.itemList[i].reel:SetActive(false)
            self.itemList[i].desc:SetActive(false)
            self.itemList[i].openReel.gameObject:SetActive(true)
            self.itemList[i].info.text = data[i].content

            self.itemList[i].btn.gameObject:SetActive(true)
            self.itemList[i].btnTxt.text = TI18N("查看答案")
            self.itemList[i].btn.onClick:RemoveAllListeners()
            self.itemList[i].btn.onClick:AddListener(function ()
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.inquiry_select_win, self.itemData[i])
            end)

            --if self.itemData[i].answer == DataQuestion.inquiry_questionGetFunc(DataCampInquiry.data_clue_info[self.itemData[i].id].question_id).answer then
                self.itemList[i].redPoint:SetActive(true)
            --end

        elseif self.itemData[i].status == 4 then
            self.itemList[i].bg.sprite  = self.assetWrapper:GetSprite(AssetConfig.campaign_inquiry, "whiteframe")
            self.itemList[i].bg.color = Vector4(1,1,1,1)
            self.itemList[i].btn.gameObject:SetActive(true)
            self.itemList[i].reel:SetActive(false)
            self.itemList[i].desc:SetActive(false)
            self.itemList[i].openReel.gameObject:SetActive(true)
            self.itemList[i].info.text = data[i].content

            self.itemList[i].btn.gameObject:SetActive(true)
            self.itemList[i].btnTxt.text = TI18N("查看答案")
            self.itemList[i].btn.onClick:RemoveAllListeners()
            self.itemList[i].btn.onClick:AddListener(function ()
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.inquiry_select_win, self.itemData[i])
            end)

        end


        self.openBtn.onClick:RemoveAllListeners()

        if haveQuest == true then

            self.openBtn.onClick:AddListener(function ()
                if CampaignInquiryManager.Instance.questOver == false then
                    NoticeManager.Instance:FloatTipsByString("线索任务暂未完成，无法开启线索")
                elseif CampaignInquiryManager.Instance.questOver == true then

                    QuestManager.Instance:Send10206(CampaignInquiryManager.Instance.currentQuest)
                    --print(CampaignInquiryManager.Instance.currentQuest)

                    local i = CampaignInquiryManager.Instance.currentclue
                    CampaignInquiryManager.Instance.questOver = false
                    CampaignInquiryManager.Instance.isRed = false
                    --if self.itemData[i].answer == DataQuestion.inquiry_questionGetFunc(DataCampInquiry.data_clue_info[self.itemData[i].id].question_id).answer then
                        self.itemList[i].redPoint:SetActive(true)
                        CampaignInquiryManager.Instance.isRed = true
                    --end


                    LuaTimer.Add(200, function() CampaignManager.Instance.model:CheckRed(805) end)


                    self.btnEft:SetActive(false)

                    self:Release(CampaignInquiryManager.Instance.currentclue,200)
                end
            end)

        elseif  self.itemData[3 + self.Mgr.clueStart].status > 2 then
            self.openBtn.onClick:AddListener(function ()  NoticeManager.Instance:FloatTipsByString("线索已经全部揭晓，敬请期待新功能吧")  end)
        else
            self.openBtn.onClick:AddListener(function ()  NoticeManager.Instance:FloatTipsByString("请先参与竞猜")  end)
        end

    end
end

function CampaignInquiryWindow:SetQuestData(data)

    local temp = DataCampInquiry.data_clue_info
    local index = CampaignInquiryManager.Instance.currentclue

    if data.questOver == true then
        self.itemList[index].descTxt.text = string.format("%s<color='#2fc823'>%s</color>/%s%s", temp[index].quest_desc1,data.val,data.target_val,temp[index].quest_desc2)

        if self.btnEft == nil then
            self.btnEft = BibleRewardPanel.ShowEffect(20053,self.openBtn.transform, Vector3(1.8, 0.7, 1),Vector3(-55, -15, -400))
        end
        self.btnEft:SetActive(true)
    else
        self.itemList[index].descTxt.text = string.format("%s<color='#df3435'>%s</color>/%s%s", temp[index].quest_desc1,data.val,data.target_val,temp[index].quest_desc2)
    end
end

function CampaignInquiryWindow:Release(index,delta)

    -- 当前线索特效
    self.itemData[index].status = 3

    if self.processEffect == nil then
        local fun = function(effectView)
            local effectObject = effectView.gameObject
            effectObject.name = "Effect"
            effectObject.transform:SetParent(self.itemList[index].bg.transform)
            effectObject.transform.localScale = Vector3(1, 1, 1)
            effectObject.transform.localPosition = Vector3(0, 0, -500)
            effectObject.transform.localRotation = Quaternion.identity
            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            effectObject:SetActive(true)
        end
        self.processEffect = BaseEffectView.New({effectId = 20435, time = nil, callback = fun})
    else
        self.processEffect.transform:SetParent(self.itemList[index].bg.transform)
        self.processEffect.transform.localPosition = Vector3(0, 0,-500)
        self.processEffect.gameObject:SetActive(false)
        self.processEffect.gameObject:SetActive(true)
    end

    -- 卷轴展开

    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
    end

    self.timerId1 = LuaTimer.Add(500, function()
        self.itemList[index].reel:SetActive(false)
        self.itemList[index].desc:SetActive(false)
        self.itemList[index].bg.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_inquiry, "whiteframe")
        self.itemList[index].bg.color = Vector4(1,1,1,1)
        self.itemList[index].btnTxt.text = TI18N("查看答案")
        self.itemList[index].openReel.gameObject:SetActive(true)
        self.itemList[index].info.text = DataCampInquiry.data_clue_info[index].content
        self.itemList[index].openReel.sizeDelta = Vector2(188, 10)
        if self.timerId2 ~= nil then
            LuaTimer.Delete(self.timerId2)
        end
        self.counter = 0
        self.timerId2 = LuaTimer.Add(0, 20, function()
            self.counter = self.counter + 1
            self.itemList[index].openReel.sizeDelta = Vector2(188, 10 + self.counter * (184 - 10) / math.ceil(delta / 20))
            if self.itemList[index].openReel.sizeDelta.y >= 184 then
                if self.timerId2 ~= nil then
                    LuaTimer.Delete(self.timerId2)
                    self.timerId2 = nil
                end
            end
        end)
    end)


    --下一线索特效

    local nextId = DataCampInquiry.data_clue_info[index].next_clue

    if nextId ~= 0 then

        if self.timerId3 ~= nil then
            LuaTimer.Delete(self.timerId3)
        end
        self.timerId3 = LuaTimer.Add(1100, function()

            self.itemData[nextId].status = 1


            if self.processEffect == nil then
                local fun = function(effectView)
                    local effectObject = effectView.gameObject
                    effectObject.name = "Effect"
                    effectObject.transform:SetParent(self.itemList[nextId].bg.transform)
                    effectObject.transform.localScale = Vector3(1, 1, 1)
                    effectObject.transform.localPosition = Vector3(0, 0, -500)
                    effectObject.transform.localRotation = Quaternion.identity
                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                    effectObject:SetActive(true)
                end
                self.processEffect = BaseEffectView.New({effectId = 20435, time = nil, callback = fun})
            else
                self.processEffect.transform:SetParent(self.itemList[nextId].bg.transform)
                self.processEffect.transform.localPosition = Vector3(0, 0, -500)
                self.processEffect.gameObject:SetActive(false)
                self.processEffect.gameObject:SetActive(true)
            end

            if self.timerId4 ~= nil then
                LuaTimer.Delete(self.timerId4)
            end

            self.timerId4 = LuaTimer.Add(0, function()

                self.itemList[nextId].bg.sprite  = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Select2")
                self.itemList[nextId].bg.color = Vector4(1,1,1,1)
                self.itemList[nextId].bg.type = Image.Type.Sliced

                self.itemList[nextId].btn.gameObject:SetActive(true)
                self.itemList[nextId].btnTxt.text = TI18N("猜一猜")

                self.itemList[nextId].btn.onClick:AddListener(function ()
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.inquiry_select_win, self.itemData[nextId])
                end)

            end)

        end)
    else
        self.itemData[3 + self.Mgr.clueStart].status = 3
    end
end
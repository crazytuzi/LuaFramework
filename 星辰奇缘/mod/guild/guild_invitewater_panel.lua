GuildInvitewaterPanel = GuildInvitewaterPanel or BaseClass(BaseWindow)

function GuildInvitewaterPanel:__init(model)
    self.model = model
    self.name = "GuildInvitewaterPanel"
    self.plantFlowerInfoData = nil
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    --是否隐藏主ui
    self.isHideMainUI = false

    self.resList = {
        {file = AssetConfig.guildinvitewaterpanel, type = AssetType.Main}
    }
    self.OnOpenEvent:AddListener(function()
        self.plantFlowerInfoData = self.openArgs
        self:UpdateWindow()
    end)

    self.isOpenRecord = true
    self.waterDesc = {
        [1] = TI18N("给鲜花浇水"),
        [2] = TI18N("一边念叨着“快快长大吧”，一边给鲜花浇了水"),
        [3] = TI18N("给鲜花浇了水后深吸一口：“哇，好香啊~"),
        [4] = TI18N("用全身力气扛起一桶水，哗啦啦的浇在了鲜花之上"),
        [5] = TI18N("在为鲜花拔除了杂草后，又浇了一壶水"),
    }

    self.descRole = {
        TI18N("1.鲜花成熟后，将根据浇水次数给予<color='#ffff00'>额外奖励</color>"),
        TI18N("2.给公会成员的鲜花浇水，自己也可获得奖励"),
        TI18N("3.鲜花浇水满<color='#ffff00'>5</color>次或每晚0点，将进入成熟态，<color='#ffff00'>不能</color>再浇水了"),
    }
    self.timerId = nil
    self.clickInterval = 0
end

function GuildInvitewaterPanel:OnInitCompleted()
    self.plantFlowerInfoData = self.openArgs
    self:UpdateWindow()
end

function GuildInvitewaterPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end

    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
    -- EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._UpdateWindow)
    -- EventMgr.Instance:RemoveListener(event_name.buff_update, self._UpdateWindow)
end

function GuildInvitewaterPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildinvitewaterpanel))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainContainer = self.transform:Find("Main")
    self.waterrecord = self.mainContainer:Find("WaterRecord")
    self.grid = self.waterrecord:Find("Container/Grid"):GetComponent(RectTransform)
    self.waterContainerText = self.waterrecord:Find("Container/Grid/WaterContainText"):GetComponent(Text)
    self.waterrecord.gameObject:SetActive(false)

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
                self:OnClickClose()
            end)

    self.flowerImgBg = self.transform:Find("Main/ImageFlower")
    self.flowerName = self.transform:Find("Main/Content/FlowerName"):GetComponent(Text)
    self.rewardText = self.transform:Find("Main/Content/RewardText"):GetComponent(Text)
    self.rewardText.fontSize = 20
    self.descText = self.transform:Find("Main/Content/DescText"):GetComponent(Text)
    self.descText.text = TI18N("(每次浇水可获得任务奖励加成)")

    self.slider = self.transform:Find("Main/Slider"):GetComponent(Slider)
    self.ruleInfobtn = self.transform:Find("Main/Image"):GetComponent(Button)
    self.ruleInfobtn.onClick:AddListener(function()
                self:OnClickRuleBtn()
            end)
    self.waterTimesText = self.transform:Find("Main/Slider/WaterTimesText"):GetComponent(Text)

    self.sureBtn = self.transform:Find("Main/SureButton"):GetComponent(Button)
    self.sureBtn.onClick:AddListener(function()
                self:OnClickSureBtn()
            end)
    self.cancelBtn = self.transform:Find("Main/CancelButton"):GetComponent(Button)
    self.cancelBtn.onClick:AddListener(function()
                self:OnClickCancelBtn()
            end)
    self.okBtn = self.transform:Find("Main/OkButton"):GetComponent(Button)
    self.okBtn.onClick:AddListener(function()
                self:OnClickOk()
            end)

    -- self:DoClickPanel()

    -- EventMgr.Instance:AddListener(event_name.role_asset_change, self._UpdateWindow)
    -- EventMgr.Instance:AddListener(event_name.buff_update, self._UpdateWindow)
end
--关闭界面
function GuildInvitewaterPanel:OnClickClose()
    -- self.isOpenRecord = false
    self:Hide()
end
--点击显示浇水规则
function GuildInvitewaterPanel:OnClickRuleBtn()
    TipsManager.Instance:ShowText({gameObject = self.ruleInfobtn.gameObject, itemData = self.descRole})
end
--点击邀请浇水
function GuildInvitewaterPanel:OnClickSureBtn()
    if self.clickInterval == 0 then
        self.clickInterval = 60
        self.timerId = LuaTimer.Add(0, 1000, function()
            --print(self.clickInterval)
            if self.clickInterval > 0 then
                self.clickInterval = self.clickInterval - 1
            else
                self.clickInterval = 0
                LuaTimer.Delete(self.timerId)
            end
        end)
        --公会
        --{role_2,谁谁谁}在公会领地中种下鲜花，快去帮ta浇水吧！{unit_2,battleId,唯一id,单位基础id,前往浇水}
        local msg = string.format(TI18N("我在公会领地种了鲜花，快来帮我浇水吧！{flower_1,%d,%d,%d,前往浇水}")
            ,self.plantFlowerInfoData.battle_id,self.plantFlowerInfoData.uid,self.plantFlowerInfoData.unit_base_id)
        ChatManager.Instance:SendMsg(MsgEumn.ChatChannel.Guild, msg)
        NoticeManager.Instance:FloatTipsByString(TI18N("已成功发送邀请，请耐心等待{face_1,3}"))
        -- local msg = string.format("{role_2,%s:}<color='%s'>我在公会领地种了鲜花，快来帮我浇水吧！</color>", self.plantFlowerInfoData.owner_name, MsgEumn.ChannelColor[MsgEumn.ChatChannel.Guild])
        -- local msgData = MessageParser.GetMsgData(msg)
        -- local chatData = ChatData.New()
        -- chatData.unitId = self.plantFlowerInfoData.uid
        -- chatData.battleId = self.plantFlowerInfoData.battle_id
        -- chatData.unitBaseId = self.plantFlowerInfoData.unit_base_id
        -- chatData.showType = MsgEumn.ChatShowType.Water
        -- chatData.msgData = msgData
        -- chatData.prefix = MsgEumn.ChatChannel.Guild
        -- chatData.channel = MsgEumn.ChatChannel.Guild
        -- ChatManager.Instance.model:ShowMsg(chatData)
    elseif self.clickInterval > 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("你刚发出邀请，%d秒后再尝试吧"),self.clickInterval))
    end
end
--点击浇水记录
function GuildInvitewaterPanel:OnClickCancelBtn()
    if self.isOpenRecord == false then
        self.isOpenRecord = true
        self.mainContainer.localPosition = Vector3(120,0,0)
        self.waterrecord.gameObject:SetActive(true)
        self:updateWaterFlowerRecord()
    else
        self.isOpenRecord = false
        self.mainContainer.localPosition = Vector3(0,0,0)
        self.waterrecord.gameObject:SetActive(false)
    end
end
function GuildInvitewaterPanel:updateWaterFlowerRecord()
    self.waterFlowerRecordList = nil
    self.waterFlowerRecordList = {}
    for k,v in pairs(self.plantFlowerInfoData.irrigations) do
        local ph = tonumber(os.date("%H", v.ctime))
        local pm = tonumber(os.date("%M", v.ctime))
        local recordContent = string.format("<color='%s'>%s</color><color='%s'>%s</color>%s",
            ColorHelper.color[1],string.format("%d:%d",ph,pm),ColorHelper.color[2],v.name,self.waterDesc[Random.Range(1,#self.waterDesc+1)])
        table.insert(self.waterFlowerRecordList,1,recordContent)
    end
    local contentTemp = table.concat(self.waterFlowerRecordList, "\n")
    self.waterContainerText.text = contentTemp

    self.grid.sizeDelta = Vector2(260, self.waterContainerText.preferredHeight)
end

function GuildInvitewaterPanel:SendSureWater(data)
    GuildManager.Instance:request11167(self.plantFlowerInfoData.battle_id,self.plantFlowerInfoData.uid)
end

--点击浇水
function GuildInvitewaterPanel:OnClickOk()
    self:OnClickClose()
    GuildManager.Instance:ShowWaterFlowerCollection(2000)
end

-- function GuildInvitewaterPanel:DoClickPanel()
--     if self.gameObject ~= nil then
--         local panel = self.gameObject.transform:FindChild("Panel")
--         if panel ~= nil then
--             local panelBut = panel:GetComponent(Button)
--             if panelBut ~= nil then
--                 local onClick = function()
--                     self:Hide()
--                 end
--                 panelBut.onClick:AddListener(onClick)
--             end
--         end
--     end
-- end

function GuildInvitewaterPanel:UpdateWindow()
    self.isOpenRecord = true
    -- Log.Error(#self.plantFlowerInfoData.irrigations)
    if self.plantFlowerInfoData ~= nil then
        local descTemp = TI18N("的鲜花幼苗")
        local timesTemp = #self.plantFlowerInfoData.irrigations
        if timesTemp >=5 then
            descTemp = TI18N("的鲜花")
        end
        self.flowerName.text = string.format("<color='%s'>%s</color>%s",ColorHelper.color[2], self.plantFlowerInfoData.owner_name,descTemp)
        -- self.rewardText.text = string.format("奖励加成：%d%s",20*timesTemp,"%")
        local isWatered = false
        for k,v in pairs(self.plantFlowerInfoData.irrigations) do
            if v.rid == RoleManager.Instance.RoleData.id then
                isWatered = true
                break
            end
        end
        if isWatered == false then
            self.rewardText.text = ""
        else
            self.rewardText.text = string.format(TI18N("已浇水"),ColorHelper.color[6])
        end
        self.waterTimesText.text = string.format("%d/5",timesTemp)
        self.slider.value = timesTemp / 5
        
        local u_id = BaseUtils.get_unique_roleid(self.plantFlowerInfoData.owner_id,self.plantFlowerInfoData.owner_zone_id,self.plantFlowerInfoData.owner_platform)
        local l_id = BaseUtils.get_self_id()
        if u_id == l_id then
            self.sureBtn.gameObject:SetActive(true)
            self.okBtn.gameObject:SetActive(false)
        else
            self.sureBtn.gameObject:SetActive(false)
            self.okBtn.gameObject:SetActive(true)
        end

        if self.isOpenRecord == false then
            self.mainContainer.localPosition = Vector3(0,0,0)
            self.waterrecord.gameObject:SetActive(false)
        else
            self.mainContainer.localPosition = Vector3(120,0,0)
            self.waterrecord.gameObject:SetActive(true)
            self:updateWaterFlowerRecord()
        end
    else
        Log.Debug("鲜花信息为空")
    end
end




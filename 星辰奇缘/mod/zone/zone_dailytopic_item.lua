-- @author pwj
-- @date 2018年5月30日,星期三

ZoneDailyTopicItem = ZoneDailyTopicItem or BaseClass()

function ZoneDailyTopicItem:__init(Parent, gameObject, data)
    self.Parent = Parent
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.hasInit = false
    self.hasLoadAsset = false
    local resources = {
        {file = AssetConfig.zone_textures, type = AssetType.Dep}
        ,{file = AssetConfig.friendtexture, type = AssetType.Dep}
        ,{file = AssetConfig.dailytopic, type = AssetType.Dep}
        --,{file = AssetConfig.bigbg1001, type = AssetType.Dep}
        --,{file = AssetConfig.bigbg1002, type = AssetType.Dep}
        --,{file = AssetConfig.bigbg1003, type = AssetType.Dep}

    }
    local fun = function() self.hasLoadAsset = true end
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources,fun)

    self.Title1 = self.transform:Find("Title1"):GetComponent(Image)
    self.Title1Text = self.transform:Find("Title1/nameText"):GetComponent(Text)
    self.Title1Num = self.transform:Find("Title1/numText"):GetComponent(Text)

    self.timeStatus = self.transform:Find("timeStatus"):GetComponent(Image)

    self.Head = self.transform:Find("Head/Custom/Image"):GetComponent(Image)
    self.HeadBtn = self.transform:Find("Head"):GetComponent(Button)

    self.Name = self.transform:Find("Name"):GetComponent(Text)
    self.NameButton = self.transform:Find("Name/Button"):GetComponent(Button)

    self.AnniImg = self.transform:Find("AnniTag")
    self.AnniImgBtn = self.AnniImg:GetComponent(Button)
    self.AnniImgBtn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString("被评论、点赞达到一定数量，可获得{face_1, 3}") end)
    self.AnniImg.gameObject:SetActive(false)
    self.TimeText = self.transform:Find("TimeTitle/Text"):GetComponent(Text)
    self.Msgbtn = self.transform:Find("Msg"):GetComponent(Button)
    self.Msg = self.transform:Find("Msg/Msg"):GetComponent(Text)

    self.Photo = self.transform:Find("Photo")
    self.PhotoImage = self.Photo:Find("1"):GetComponent(Image)

    self.statusCon = self.transform:Find("statusCon")
    self.Arrow = self.statusCon:Find("Arrow")
    self.Topdesc = self.statusCon:Find("Topdesc")
    self.TopdescTxt = self.statusCon:Find("Topdesc/Text"):GetComponent(Text)
    self.TopdescTxtRect = self.TopdescTxt.gameObject:GetComponent(RectTransform)

    self.ComeOnButton = self.transform:Find("ComeOnButton"):GetComponent(Button)
    self.ComeOnBtnBg = self.transform:Find("ComeOnButton"):GetComponent(Image)
    self.ComeOnButtonText = self.transform:Find("ComeOnButton/I18NText"):GetComponent(Text)
    self.ComeOnButton.onClick:AddListener(function() self:RequirePreviousData() end)

    self.MsgExt = MsgItemExt.New(self.Msg, 407, 17, 18.62)
    self.selfHeight = 43
    self.hasInit = true
    self.isCurrTopic = false    --是否是本期活动

    self.FirstInit = true
end

function ZoneDailyTopicItem:__delete()

    if self.MsgExt ~= nil then
        self.MsgExt:DeleteMe()
    end
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil
end

function ZoneDailyTopicItem:update_my_self(data, index)
    if not self.hasInit or BaseUtils.isnull(self.Arrow) then return end
    self.selfHeight = 87
    self.data = data
    self.index = index
    self.isCurrTopic = BaseUtils.CheckCampaignTime(data.camp_id)
    self.Title1Num.text = string.format("第%s期", index)
    self.Title1Text.text = string.format("#%s#", data.theme)
    if self.isCurrTopic == true then
        self.timeStatus.sprite = self.assetWrapper:GetSprite(AssetConfig.zone_textures,"DoingIcon")
        self.ComeOnButtonText.text = TI18N("立即参与")
        self.ComeOnBtnBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.ComeOnButtonText.color =  ColorHelper.DefaultButton3
    else
        self.timeStatus.sprite = self.assetWrapper:GetSprite(AssetConfig.zone_textures,"CompletedIcon")
        self.ComeOnButtonText.text = TI18N("精彩回顾")
        self.ComeOnBtnBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.ComeOnButtonText.color =  ColorHelper.DefaultButton1
    end
    if self.hasLoadAsset == false then
        if self.data ~= nil and self.index ~= nil then
            LuaTimer.Add(50,function() self:update_my_self(self.data, self.index) end)
        end
    end
    self.Head.sprite = self.assetWrapper:GetSprite(AssetConfig.friendtexture,"HelpGril1")
    self.Name.text = TI18N(data.npc_name)
    local firstTime = DataCampaign.data_list[data.camp_id].cli_start_time
    self.TimeText.text = string.format("%s-%s-%s",firstTime[1][1],firstTime[1][2],firstTime[1][3])
    if self.FirstInit then
        self.MsgExt:SetData(data.content)
    end
    self.Msgbtn.transform.sizeDelta = Vector2(407, self.MsgExt.selfHeight)

    self.selfHeight = self.selfHeight + self.MsgExt.selfHeight

    if data.picture ~= 0 then
        self.PhotoImage.transform.sizeDelta = Vector2(200,100)
        self.PhotoImage.transform.anchoredPosition = Vector2(6.4,0)
        self.PhotoImage.gameObject:SetActive(true)
        self.Photo.anchoredPosition = Vector2(84, -self.selfHeight)
        self.Photo.sizeDelta = Vector2(212, 110)
        self.Photo.gameObject:SetActive(true)
        self.selfHeight = self.selfHeight + 120 + 5
        -- if self.data.picture == 1001 then
        --     self.PhotoImage.sprite = self.assetWrapper:GetSprite(AssetConfig.bigbg1001,"1001")
        -- elseif self.data.picture == 1002 then
        --     self.PhotoImage.sprite = self.assetWrapper:GetSprite(AssetConfig.bigbg1002,"1002")
        -- elseif self.data.picture == 1003 then
        --     self.PhotoImage.sprite = self.assetWrapper:GetSprite(AssetConfig.bigbg1003,"1003")
        -- end
        self.PhotoImage.sprite = self.assetWrapper:GetSprite(AssetConfig.dailytopic, tostring(self.data.picture))
    end
    self:SetStatusCon()
    self.statusCon.anchoredPosition = Vector2(84, -(self.selfHeight))
    self.ComeOnButton.transform.anchoredPosition = Vector2(388, -(self.selfHeight + 3))

    self.selfHeight = self.selfHeight + 45
    self.transform.sizeDelta = Vector2(508, self.selfHeight)

    self.FirstInit = false
end

function ZoneDailyTopicItem:SetStatusCon()
    if BaseUtils.isnull(self.Arrow) then
        return
    end
    local H = 0
    H = H + self.Arrow.sizeDelta.y

    local str = ""
    local likesData = {}
    local PriseData = ZoneManager.Instance.TopicSystemParseList
    --local PriseData = ZoneManager.Instance.Querdata
    --BaseUtils.dump(PriseData,"PriseData")
    for i,v in pairs(PriseData) do
        if self.data.camp_id == v.camp_id then
            if next(v.moments) ~= nil then
                likesData = v.moments[1].likes
            end
        end
    end
    local data = likesData[1]
    if data ~= nil then
        str = str..data.name
    end
    if #likesData < 2 then
        str = string.format(TI18N("%s觉得很赞"), str)
    else
        str = string.format(TI18N("%s等%s人觉得很赞"), str, #likesData)
    end
    self.TopdescTxt.text = str
    self.TopdescTxtRect.sizeDelta = Vector2(385 ,self.TopdescTxt.preferredHeight)
    self.Topdesc.sizeDelta = Vector2(286, self.TopdescTxt.preferredHeight +8)
    self.Topdesc.anchoredPosition = Vector2(0,-H)
    if #likesData == 0 then
        self.Topdesc.gameObject:SetActive(false)
        self.Arrow.gameObject:SetActive(false)
    else
        self.Topdesc.gameObject:SetActive(true)
        H = self.Topdesc.sizeDelta.y + H + 2
    end
end

function ZoneDailyTopicItem:onClick()
    if self.data ~= nil then
        ZoneManager.Instance:OpenOtherZone(self.data.role_id, self.data.platform, self.data.zone_id, {2})
    end
end
--点击立即参与按钮查看数据
function ZoneDailyTopicItem:RequirePreviousData()
    --发协议并跳转面板，事件驱动刷新面板
    if self.isCurrTopic == true then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_uniwin, {self.data.camp_id})
    else
        ZoneManager.Instance:Require11893(self.data.camp_id, 1)
        self.Parent.panelId = 2
        self.Parent.model.currCampId = self.data.camp_id
        self.Parent:InitTab(self.index)
    end
end
function ZoneDailyTopicItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end
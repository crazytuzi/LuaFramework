-- @author ###
-- @date 2018年4月28日,星期六

AnniversaryTyPanel = AnniversaryTyPanel or BaseClass(BasePanel)

function AnniversaryTyPanel:__init(model, parent)
    self.model = AnniversaryTyManager.Instance.model
    self.parent = parent
    self.name = "AnniversaryTyPanel"

    self.resList = {
        {file = AssetConfig.anniversaryPanel, type = AssetType.Main}
        --,{file = AssetConfig.anniversary_firstBg, type = AssetType.Main}
        ,{file = "prefabs/effect/20166.unity3d", type = AssetType.Main}
        --,{file = AssetConfig.pack_seven, type = AssetType.Dep}
        ,{file = AssetConfig.anniversary_textures, type = AssetType.Dep}
        ,{file  =  AssetConfig.zone_textures, type  =  AssetType.Dep}
        ,{file  =  AssetConfig.topicbigbg, type  =  AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.refresh_comments = function(campId)
        if campId == self.campId then
            self:OnMomentsRefresh()
        end
    end
    self.TextList = {{},{}}

    self.IndexMax = 3

    self.bubbleIndex = 0    --气泡循环播放的索引

    self.step = 0
    self.effectDirection = -1
    self.plotNpcFormation = {baseid = 43091,x = 1850,y = 1700,unit_id = 8,battle_id = 8}

    self.TextBubbleList = {}
end

function AnniversaryTyPanel:__delete()
    self.OnHideEvent:Fire()

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

    if self.DuangId ~= nil then
        Tween.Instance:Cancel(self.DuangId)
        self.DuangId = nil
    end

    if self.momentList ~= nil then
        self.momentList:DeleteMe()
        self.momentList = nil
    end

    if self.msgExt ~= nil then
        self.msgExt:DeleteMe()
        self.msgExt = nil
    end

    if self.photopreview ~= nil then
        self.photopreview:DeleteMe()
        self.photopreview = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function AnniversaryTyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.anniversaryPanel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    -- self.TextBubbleList = {
    --     TI18N("快给你的朋友发送周年庆祝福吧~")
    --     ,TI18N("带图的朋友圈更容易上主页哦~")
    --     ,TI18N("好玩的游戏截图也是不错的选择")
    --     ,TI18N("写下你们的故事和你想说的话!")
    --     ,TI18N("你的祝福有机会对全服玩家展示!")
    --     ,TI18N("情感真挚的祝福将获得神秘奖励~")
    --     ,TI18N("送出祝福更有机会带走鲸鱼公主!")
    -- }


    self.lastPanel = t:Find("LastPanel")
    self.lastPanel.gameObject:SetActive(false)
    self.TopCon = self.lastPanel:Find("TopCon")
    self.TopCon:Find("Left/Bg/pet"):GetComponent(Button).onClick:AddListener(function() self:OnNoticeNpc() end)
    self.TalkBgBtn = self.TopCon:Find("Left/TalkBg"):GetComponent(Button)
    self.TalkBgBtn.onClick:AddListener(function() self:OnNoticeNpc() end)
    self.talkMsg = self.TopCon:Find("Left/TalkBg/Text"):GetComponent(Text)

    self.msgExt = MsgItemExt.New(self.talkMsg, 253, 17, 23)

    self.Topicbigbg = self.TopCon:Find("bigbg"):GetComponent(Image)
    self.Topicbigbg.sprite = self.assetWrapper:GetSprite(AssetConfig.topicbigbg,"TopicBigbg")
    self.Topicbigbg.transform.anchoredPosition = Vector2(-3, 25)
    self.Topicbigbg.gameObject:SetActive(true)

    self.BottomCon = self.lastPanel:Find("BottomCon")

    self.MaskCon = self.BottomCon:Find("Mask")
    self.Container = self.MaskCon:Find("Container")
    self.TopLoading = self.MaskCon:Find("TopLoading").gameObject
    self.BotLoading = self.MaskCon:Find("BotLoading").gameObject
    self.TopText = self.MaskCon:Find("TopLoading/I18NText"):GetComponent(Text)
    self.BotText = self.MaskCon:Find("BotLoading/I18NText"):GetComponent(Text)
    local go = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20166.unity3d"))
    go.transform:SetParent(self.TopLoading.transform:Find("Image"))
    go.transform.localPosition = Vector3(0,0,-1000)
    go.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(go.transform, "UI")
    local go2 = GameObject.Instantiate(go)
    go2.transform:SetParent(self.BotLoading.transform:Find("Image"))
    go2.transform.localPosition = Vector3(0,0,-1000)
    go2.transform.localScale = Vector3.one

    self.detialOption = self.BottomCon:Find("detialOption")
    self.detialOption:Find("Panel"):GetComponent(Button).onClick:AddListener(function()self.detialOption.gameObject:SetActive(false) end)
    self.likeOpt = self.detialOption:Find("LikeButton"):GetComponent(Button)
    self.likeOpt.onClick:AddListener(function() self:OnLikeOpt() end)
    self.commentsOpt = self.detialOption:Find("CommentButton"):GetComponent(Button)
    self.commentsOpt.onClick:AddListener(function() self:OnCommentsOpt(1) end)
    self.hideOpt = self.detialOption:Find("HideButton"):GetComponent(Button)
    self.hideOpt.onClick:AddListener(function() self:OnHideOpt() end)
    self.reportOpt = self.detialOption:Find("ReportButton"):GetComponent(Button)
    self.reportOpt.onClick:AddListener(function() self:OnReportOpt() end)

    self.scrollRect = self.BottomCon:Find("Mask"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function(val)
        self:OnScrollBoundary(val)
    end)

    self.SureBtn = self.lastPanel:Find("TopCon/Left/SureBtn"):GetComponent(Button)
    self.SureBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.zone_mywin, {nil,nil,1})  end)
    self.momentList = MomentsListPanel.New(self.Container.gameObject, self, 2)
end

function AnniversaryTyPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function AnniversaryTyPanel:OnOpen()
    self:RemoveListeners()
    ZoneManager.Instance.OnAnniMomentsUpdate:AddListener(self.refresh_comments)
    self.TopicData = nil
    for i,v in pairs(DataFriendWish.data_get_camp_theme) do
        if v.camp_id ==self.campId then
            self.TopicData = v
            break
        end
    end
    if self.TopicData ~= nil then
        self.lastPanel:Find("TopCon/Left/SureBtn/Text"):GetComponent(Text).text = self.TopicData.join_btn
        self.TextBubbleList = StringHelper.Split(self.TopicData.desc,";")
    end
    --ZoneManager.Instance:Send11894()    --寄语列表
    ZoneManager.Instance:Require11893(self.campId, 1)    --1  首批
    self:OnFirstCheck()
    self:ShowDuangEffect()
end

function AnniversaryTyPanel:OnHide()
    self:RemoveListeners()
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end
    if self.BubbleTimer ~= nil then
        LuaTimer.Delete(self.BubbleTimer)
        self.BubbleTimer = nil
    end

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

    if self.DuangId ~= nil then
        Tween.Instance:Cancel(self.DuangId)
        self.DuangId = nil
    end

end


function AnniversaryTyPanel:RemoveListeners()
    ZoneManager.Instance.OnAnniMomentsUpdate:RemoveListener(self.refresh_comments)
end

function AnniversaryTyPanel:OnFirstCheck()
    self.lastPanel.gameObject:SetActive(true)
    self:SetLastData()
end


-- function AnniversaryTyPanel:GiftShowCompleted()
--     EffectBrocastManager.Instance:On9907({id = 30224,type = 0, time = 5, map = SceneManager.Instance:CurrentMapId(),x = -59,y = -68})

--     self.timeId = LuaTimer.Add(5000, function() self:Next() end)
-- end

-- function AnniversaryTyPanel:NpcTalk()
--     self.dramaList = {
--         {type = DramaEumn.ActionType.Plotunitcreate, unit_id = self.plotNpcFormation.unit_id, battle_id = self.plotNpcFormation.battle_id, unit_base_id = self.plotNpcFormation.baseid, msg = self.plotNpcFormation.name, mapid = 53011, x = self.plotNpcFormation.x, y = self.plotNpcFormation.y,time = 600}
--         ,{type = DramaEumn.ActionType.WaitClient, val = 500}
--         ,{type = DramaEumn.ActionType.Unittalk, unit_id = self.plotNpcFormation.unit_id,battle_id = self.plotNpcFormation.battle_id,msg = string.format("亲爱的%s，周年庆快乐!",RoleManager.Instance.RoleData.name),time = 1000,isUnit = true}
--         ,{type = DramaEumn.ActionType.WaitClient, val = 500}
--         ,{type = DramaEumn.ActionType.Unittalk,unit_id = self.plotNpcFormation.unit_id,battle_id = self.plotNpcFormation.battle_id,msg = "2年以来，感谢大家陪伴星辰奇缘一起成长！希望大家能够继续在这里收获快乐和更多珍贵的回忆！",time = 1000,isUnit = true}
--         ,{type = DramaEumn.ActionType.WaitClient, val = 500}
--         ,{type = DramaEumn.ActionType.Unittalk,unit_id = self.plotNpcFormation.unit_id,battle_id = self.plotNpcFormation.battle_id,msg = "往后的冒险历程，还请继续多多关照！",time = 1000,isUnit = true}
--         ,{type = DramaEumn.ActionType.Plotunitdel, unit_id = 8}

--         ,{type = DramaEumn.ActionType.Endplot, callback = function() self:EndPlot() end}
--     }
--     DramaManagerCli.Instance:ExquisiteShelf(self.dramaList)
--     self:BeginPlot()
-- end

-- function AnniversaryTyPanel:BeginPlot()
--     if MainUIManager.Instance.mainuitracepanel ~= nil then
--         MainUIManager.Instance.mainuitracepanel:TweenHiden()
--     end
--     TipsManager.Instance.model:Closetips()
--     MainUIManager.Instance:HideDialog()
--     DramaManager.Instance.model.plotPlaying = true
--     NoticeManager.Instance:HideAutoUse()
--     DramaManager.Instance.model:HideOtherUI()
--     SceneManager.Instance.sceneElementsModel:Show_Npc(false)
--     SceneManager.Instance.sceneElementsModel:Show_OtherRole(false)
--     SceneManager.Instance.sceneElementsModel:Show_Self(false)
--     LuaTimer.Add(800, function() self:SetMove(false) end)
-- end

-- function AnniversaryTyPanel:SetMove(bool)
--     SceneManager.Instance.sceneElementsModel:Set_isovercontroll(bool == true)
-- end

-- function AnniversaryTyPanel:EndPlot()
--     if MainUIManager.Instance.mainuitracepanel ~= nil then
--         MainUIManager.Instance.mainuitracepanel:TweenShow()
--     end
--     self:SetMove(true)
--     self.timeId = LuaTimer.Add(1000, function() self:Next() end)
-- end

function AnniversaryTyPanel:SetLastData()
    --加载朋友圈数据
    self.bubbleIndex = 0
    self.BubbleTimer = LuaTimer.Add(10, 5000, function() self:SetBubbleTalk() end)
    ZoneManager.Instance.model.currCampId = self.campId
end


function AnniversaryTyPanel:SetBubbleTalk()
    if next(self.TextBubbleList) == nil then return end
    self.bubbleIndex = self.bubbleIndex + 1
    if self.bubbleIndex < (#self.TextBubbleList + 1) then
        if self.msgExt ~= nil then
            self.msgExt:SetData(self.TextBubbleList[self.bubbleIndex])
        end
    else
        self.bubbleIndex = self.bubbleIndex % (#self.TextBubbleList + 1)
    end
end

--------------------向服务端传递数据----------------------------
function AnniversaryTyPanel:OnOpenZone()
    self.LocalPath = ctx.ResourcesPath.."/Photo/"
    --table.insert(ZoneManager.Instance.model.LocalPhotoList, {key = "p111111", val = 1245})
    --local photo = ZoneManager.Instance.model:LoadLocalPhoto(1,1,11,11,1245)
    local photo = BaseUtils.LoadLocalFile(self.LocalPath.."p111111.jpg")
    local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
    tex2d:LoadImage(photo)
    local scaletex = self:ScaleTextureBilinear(tex2d, 0.25)
    local newbyte2 = scaletex:EncodeToJPG()
    local thumbphotoList = {}
    thumbphotoList[1] = newbyte2
    local photoList = {}
    photoList[1] = photo
    local str = "星辰奇缘两周年快乐！成长的路上，感谢有你的陪伴,往后的故事，还想继续与你书写！"
    local send_msg = MessageParser.ConvertToTag_Face(str)
    --ZoneManager.Instance:Require11858(send_msg, 2, {}, {}, {})
    ZoneManager.Instance:Require11858(send_msg, 2, photoList, {}, thumbphotoList)
end

function AnniversaryTyPanel:ScaleTextureBilinear(originalTexture, scaleFactor)
    local newTexture = Texture2D(math.ceil (originalTexture.width * scaleFactor), math.ceil (originalTexture.height * scaleFactor), TextureFormat.RGB24, false)
    local scale = 1.0 / scaleFactor;
    local maxX = originalTexture.width - 1
    local maxY = originalTexture.height - 1
    for y = 0, newTexture.height-1 do
        for x = 0, newTexture.width-1 do
            -- Bilinear Interpolation
            local targetX = x * scale;
            local targetY = y * scale;
            local x1 = Mathf.Min(maxX, math.floor(targetX))
            local y1 = Mathf.Min(maxY, math.floor(targetY))
            local x2 = Mathf.Min(maxX, x1 + 1)
            local y2 = Mathf.Min(maxY, y1 + 1)

            local u = targetX - x1
            local v = targetY - y1
            local w1 = (1 - u) * (1 - v)
            local w2 = u * (1 - v)
            local w3 = (1 - u) * v
            local w4 = u * v
            local color1 = originalTexture:GetPixel(x1, y1)
            local color2 = originalTexture:GetPixel(x2, y1)
            local color3 = originalTexture:GetPixel(x1, y2)
            local color4 = originalTexture:GetPixel(x2,  y2)
            local color = Color(Mathf.Clamp01(color1.r * w1 + color2.r * w2 + color3.r * w3+ color4.r * w4),
                Mathf.Clamp01(color1.g * w1 + color2.g * w2 + color3.g * w3 + color4.g * w4),
                Mathf.Clamp01(color1.b * w1 + color2.b * w2 + color3.b * w3 + color4.b * w4),
                Mathf.Clamp01(color1.a * w1 + color2.a * w2 + color3.a * w3 + color4.a * w4)
                )
            newTexture:SetPixel(x, y, color)
        end
    end
    -- newTexture:Apply(false)
    return newTexture
end
------------------------------------------------

--打开npc播放对话
function AnniversaryTyPanel:OnNoticeNpc(index)
    local NpcData = DataFriendWish.data_get_camp_desc[self.campId]
    local npcBase = {}
    if NpcData ~= nil then
        npcBase = DataUnit.data_unit[NpcData.unit_id]
    end
    local extra = {base = BaseUtils.copytab(npcBase)}
    local buttons = {}
    extra.base.plot_talk = NpcData.npc_desc
    extra.base.name = NpcData.npc_name
    extra.base.buttons = {}
    MainUIManager.Instance:OpenDialog({baseid = npcBase.id, name = npcBase.name}, extra, true)
end


function AnniversaryTyPanel:ShowDetailOption(data, position)
    self.detialOptionData = data
    if self.detialOptionData.type == 3 then
        self.commentsOpt.gameObject:SetActive(false)
    else
        self.commentsOpt.gameObject:SetActive(true)
    end
    self.hideOpt.gameObject:SetActive(false)
    self.reportOpt.gameObject:SetActive(false)
    if self:IsLiked() then
        self.likeOpt.transform:Find("I18NText"):GetComponent(Text).text = TI18N("取消")
    else
        self.likeOpt.transform:Find("I18NText"):GetComponent(Text).text = TI18N("点赞")
    end
    self.detialOption.position = position
    self.detialOption.gameObject:SetActive(true)
end


function AnniversaryTyPanel:IsLiked()
    for i,v in ipairs(self.detialOptionData.likes) do
        if RoleManager.Instance.RoleData.id == v.liker_id and RoleManager.Instance.RoleData.platform == v.liker_platform and RoleManager.Instance.RoleData.zone_id == v.liker_zone_id
            or RoleManager.Instance.RoleData.id == v.role_id and RoleManager.Instance.RoleData.platform == v.platform and RoleManager.Instance.RoleData.zone_id == v.zone_id  then
            return true
        end
    end
    return false
end

function AnniversaryTyPanel:OnLikeOpt()
    if self:IsLiked() then
        ZoneManager.Instance:Require11861(self.detialOptionData.m_id, self.detialOptionData.m_platform, self.detialOptionData.m_zone_id)
    else
        ZoneManager.Instance:Require11860(self.detialOptionData.m_id, self.detialOptionData.m_platform, self.detialOptionData.m_zone_id)
    end
    self.detialOption.gameObject:SetActive(false)
end

function AnniversaryTyPanel:OnScrollBoundary(value)
    local Top = (value.y-1)*(self.scrollRect.content.sizeDelta.y - 382.83) + 50
    local Bot = Top - 382.83 - 50
    self.momentList:OnScroll(Top, Bot)
    local space = 0
    if value.y > 1 then
        space = (value.y-1)*math.max(382.83, self.scrollRect.content.sizeDelta.y - 382.83)
    elseif value.y < 0 then
        space = value.y*math.max(382.83, self.scrollRect.content.sizeDelta.y - 382.83) * -1
    end
    if space > 5 and self.excuRefresh == nil then
        if value.y > 1 then
            if self.checking then
                self.TopLoading:SetActive(true)
            else
                self.checking = true
                self.checkTime = Time.time
                self.TopText.text = TI18N("保持下拉将会刷新")
                self.TopLoading:SetActive(true)
                if self.checkTimer == nil then
                    self.checkTimer = LuaTimer.Add(300, function()
                        if self.checking == true and self.TopText ~= nil then
                            self.TopText.text = TI18N("松开手指刷新")
                            self.checking = false
                            self.excuRefresh = 1
                            self.checkTimer = nil
                        end
                    end)
                end
            end
        elseif value.y < 0 then
            if self.checking then
                self.BotLoading:SetActive(true)
            else
                self.checking = true
                self.checkTime = Time.time
                self.BotText.text = TI18N("保持上拉将会刷新")
                self.BotLoading:SetActive(true)
                if self.checkTimer == nil then
                    self.checkTimer = LuaTimer.Add(300, function()
                        if self.checking == true and self.TopText ~= nil then
                            self.BotText.text = TI18N("松开手指刷新")
                            self.checking = false
                            self.excuRefresh = 2
                            self.checkTimer = nil
                        end
                    end)
                end
            end
        end
    elseif space <= 5 then
        if self.checkTimer ~= nil then
            LuaTimer.Delete(self.checkTimer)
            self.checkTimer = nil
        end
        if self.excuRefresh ~= nil then
            ZoneManager.Instance:Require11893(self.campId, self.excuRefresh)
            self.excuRefresh = nil
        end
        self.checking = false
        self.TopLoading:SetActive(false)
        self.BotLoading:SetActive(false)
    end
end

--11893刷新数据
function AnniversaryTyPanel:OnMomentsRefresh()
    --刷新数据
    -- ZoneManager.Instance.AnnimomentsList 需要去保持该表数据在20 左右
    if self.momentList ~= nil then
        self.scrollRect.inertia = false
        self.momentList:RefreshData(ZoneManager.Instance.TopicmomentsData[self.campId], self.isshow)
        self.scrollRect.inertia = true
    end
    self.TopLoading:SetActive(false)
    self.BotLoading:SetActive(false)
end

function AnniversaryTyPanel:OpenPhotoPreview(data)
    if self.photopreview == nil then
        self.photopreview = MomentsPhotoPreviewPanel.New(self.model, self)
    end
    self.photopreview:Show(data)
end

function AnniversaryTyPanel:OnCommentsOpt(data)
    if self.detialOptionData ~= nil then
        ZoneManager.Instance:OpenOtherZone(self.detialOptionData.role_id, self.detialOptionData.platform, self.detialOptionData.zone_id, {2})
    end
end

function AnniversaryTyPanel:ShowDuangEffect()

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    if self.DuangId ~= nil then
        Tween.Instance:Cancel(self.DuangId)
        self.DuangId = nil
    end

    self.effTimerId = LuaTimer.Add(1000, 3000, function()
        self.SureBtn.gameObject.transform.localScale = Vector3(1.2,1.2,1)
        self.DuangId = Tween.Instance:Scale(self.SureBtn.gameObject, Vector3(1,1,1), 1.2, function() self.DuangId = nil end, LeanTweenType.easeOutElastic).id
    end)
end
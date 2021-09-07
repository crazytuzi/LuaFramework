RankPanel = RankPanel or BaseClass(BasePanel)

function RankPanel:__init(parent)
    self.parent = parent
    self.model = parent.model

    self.resList = {
        {file = AssetConfig.rank_panel, type = AssetType.Main}
        , {file = AssetConfig.intimacybg2, type = AssetType.Main}
        , {file = AssetConfig.rank_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.half_length, type = AssetType.Dep}
        , {file = AssetConfig.hero_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
        , {file = AssetConfig.portrait_textures, type = AssetType.Dep}
        , {file = AssetConfig.rank_no_1, type = AssetType.Dep}
        , {file = AssetConfig.rank_no_2, type = AssetType.Dep}
    }


    self.boxYLayout = nil
    self.model.lastPosition = self.model.lastPosition or 0

    self.selectData = {TI18N("全部"), TI18N("好友")}

    self.cellObjList5 = {}  -- 5列模板
    self.cellObjList = {}   -- 4列模板
    self.headSlot = {}
    self.imageLoadList = {}
    self.CampGroup = {}     -- 上方分组菜单
    self.tempNum = 0

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.headLoaderList = {}
    self._update = function(updateType)
        self:update(updateType)
    end
end

function RankPanel:InitPanel()
    local model = self.model

    local floor = math.floor

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rank_panel))
    self.gameObject.name = "RankPanel"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)
    self.headBg = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "HeadBg")
    self.rectangleBg = self.assetWrapper:GetSprite(AssetConfig.portrait_textures, "RectangleBg")

    local main = self.gameObject.transform

    self.panel4 = main:Find("Panel4")

    self.panel4Pos = self.panel4:GetComponent(RectTransform).localPosition
    self.panel4Pos2 = Vector2(self.panel4Pos.x,self.panel4Pos.y + 47)
    self.panel4Pos3 = Vector2(self.panel4Pos.x,self.panel4Pos.y + 48)
    self.panel4Size = self.panel4:GetComponent(RectTransform).sizeDelta
    self.panel4Size2 = Vector2(self.panel4Size.x,self.panel4Size.y + 94 )
    self.panel4Size3 = Vector2(self.panel4Size.x,self.panel4Size.y + 96 )

    self.line = self.panel4:Find("Line")
    self.line:GetComponent(RectTransform).anchoredPosition = Vector2(33,160.7)
    self.line.gameObject:SetActive(true)

    self.divideGroup = self.panel4:Find("DivideGroup")
    self.leftArrow = self.panel4:Find("DivideGroup/LeftArrow")
    self.rightArrow = self.panel4:Find("DivideGroup/RightArrow")

    self.leftArrow:GetComponent(Button).onClick:AddListener(function() self:OnClickArrow(1) end)
    self.rightArrow:GetComponent(Button).onClick:AddListener(function() self:OnClickArrow(2) end)
    self.container = self.divideGroup:Find("Container")
    self.itemer = self.container:Find("Group1").gameObject
    self.itemer:SetActive(false)
    self.TopLayout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 18, border = 12})
    self.divideGroup.gameObject:SetActive(false)

    self.infoContainer = main:Find("Panel4/Panel/Container").gameObject
    self.infoContainerRect = self.infoContainer:GetComponent(RectTransform)
    self.cloner = self.infoContainer.transform:Find("Cloner").gameObject
    local panel4 = main:Find("Panel4/Panel")
    self.vScroll = panel4.gameObject:GetComponent(ScrollRect)

    self.scrollLayer4Size = panel4.gameObject:GetComponent(RectTransform).sizeDelta
    self.scrollLayer4Size2 = Vector2(self.scrollLayer4Size.x,self.scrollLayer4Size.y + 94 )
    self.scrollLayer4Size3 = Vector2(self.scrollLayer4Size.x,self.scrollLayer4Size.y + 96 )
    self.scrollLayer4Pos = panel4.gameObject:GetComponent(RectTransform).localPosition + Vector3(0,35,0)
    self.scrollLayer4Pos2 = Vector2(self.scrollLayer4Pos.x,self.scrollLayer4Pos.y)
    self.scrollLayer4Pos3 = Vector2(self.scrollLayer4Pos.x,self.scrollLayer4Pos.y)


    self.nothing = main:Find("Panel4/Panel/Container/Nothing").gameObject
    self.nothingText = self.nothing.transform:Find("Text"):GetComponent(Text)

    self.barContainer = main:Find("Bar/Container").gameObject
    self.barRect = self.barContainer:GetComponent(RectTransform)
    self.mainButtonTemplate = self.barContainer.transform:Find("MainButton").gameObject
    self.mainButtonHeight = 58
    self.mainButtonTemplate:SetActive(false)
    self.subButtonTemplate = self.barContainer.transform:Find("SubButton").gameObject
    self.subButtonHeight = 50
    self.subButtonTemplate:SetActive(false)

    self.panelTitle4 = main:Find("Panel4/PanelTitle")
    self.panelTitle4_2 = main:Find("Panel4/PanelTitle2")

    self.title1Text = main:Find("Panel4/PanelTitle/Title1"):GetComponent(Text)
    self.title2Text = main:Find("Panel4/PanelTitle/Title2"):GetComponent(Text)
    self.title3Text = main:Find("Panel4/PanelTitle/Title3"):GetComponent(Text)
    self.title4Text = main:Find("Panel4/PanelTitle/Title4/Text"):GetComponent(Text)
    self.title4Image = main:Find("Panel4/PanelTitle/Title4/Image"):GetComponent(Image)

    self.title1Text2 = main:Find("Panel4/PanelTitle2/Title1"):GetComponent(Text)
    self.title2Text2 = main:Find("Panel4/PanelTitle2/Title2"):GetComponent(Text)
    self.title3Text2 = main:Find("Panel4/PanelTitle2/Title3"):GetComponent(Text)
    self.title4Text2 = main:Find("Panel4/PanelTitle2/Title4/Text"):GetComponent(Text)
    self.title4Image2 = main:Find("Panel4/PanelTitle2/Title4/Image"):GetComponent(Image)

    self.panel5 = main:Find("Panel5")

    self.panel5Pos = self.panel5:GetComponent(RectTransform).localPosition
    self.panel5Pos2 = Vector2(self.panel5Pos.x,self.panel5Pos.y + 47)
    self.panel5Pos3 = Vector2(self.panel5Pos.x,self.panel5Pos.y + 48)
    self.panel5Size = self.panel5:GetComponent(RectTransform).sizeDelta
    self.panel5Size2 = Vector2(self.panel5Size.x,self.panel5Size.y + 94 )
    self.panel5Size3 = Vector2(self.panel5Size.x,self.panel5Size.y + 96 )

    self.infoContainer5 = self.panel5:Find("Panel/Container").gameObject
    self.infoContainer5Rect = self.infoContainer5:GetComponent(RectTransform)
    self.cloner5 = self.infoContainer5.transform:Find("Cloner").gameObject
    self.cloner5:SetActive(false)
    self.vScroll5 = self.panel5:Find("Panel"):GetComponent(ScrollRect)

    local panel5 = main:Find("Panel5/Panel")

    self.scrollLayer5Size = panel5.gameObject:GetComponent(RectTransform).sizeDelta
    self.scrollLayer5Size2 = Vector2(self.scrollLayer5Size.x,self.scrollLayer5Size.y + 94 )
    self.scrollLayer5Size3 = Vector2(self.scrollLayer5Size.x,self.scrollLayer5Size.y + 96)
    self.scrollLayer5Pos = panel5.gameObject:GetComponent(RectTransform).localPosition  + Vector3(0,35,0)
    self.scrollLayer5Pos2 = Vector2(self.scrollLayer5Pos.x,self.scrollLayer5Pos.y)
    self.scrollLayer5Pos3 = Vector2(self.scrollLayer5Pos.x,self.scrollLayer5Pos.y)



    self.nothing5 = self.panel5:Find("Panel/Container/Nothing").gameObject
    self.nothing5Text = self.nothing5.transform:Find("Text"):GetComponent(Text)

    -- self.title1Text5 = self.panel5:Find("PanelTitle/Title1"):GetComponent(Text)
    -- self.title2Text5 = self.panel5:Find("PanelTitle/Title2"):GetComponent(Text)
    -- self.title3Text5 = self.panel5:Find("PanelTitle/Title3"):GetComponent(Text)
    -- self.title4Text5 = self.panel5:Find("PanelTitle/Title4/Text"):GetComponent(Text)
    -- self.title4Image5 = self.panel5:Find("PanelTitle/Title4/Image"):GetComponent(Image)

    self.panelTitle5 = self.panel5:Find("PanelTitle")
    self.panelTitle5_2 = self.panel5:Find("PanelTitle2")

    self.panelTitle4_2.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,1)
    self.panelTitle5_2.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,1)

    self.title1Text5 = self.panel5:Find("PanelTitle/Title1"):GetComponent(Text)
    self.title2Text5 = self.panel5:Find("PanelTitle/Title2"):GetComponent(Text)
    self.title3Text5 = self.panel5:Find("PanelTitle/Title3"):GetComponent(Text)
    self.title4Text5 = self.panel5:Find("PanelTitle/Title4/Text"):GetComponent(Text)
    self.title5Text5 = self.panel5:Find("PanelTitle/Title5"):GetComponent(Text)
    self.title4Image5 = self.panel5:Find("PanelTitle/Title4/Image"):GetComponent(Image)

    self.title1Text5_2 = self.panel5:Find("PanelTitle2/Title1"):GetComponent(Text)
    self.title2Text5_2 = self.panel5:Find("PanelTitle2/Title2"):GetComponent(Text)
    self.title3Text5_2 = self.panel5:Find("PanelTitle2/Title3"):GetComponent(Text)
    self.title4Text5_2 = self.panel5:Find("PanelTitle2/Title4/Text"):GetComponent(Text)
    self.title5Text5_2 = self.panel5:Find("PanelTitle2/Title5"):GetComponent(Text)
    self.title4Image5_2 = self.panel5:Find("PanelTitle2/Title4/Image"):GetComponent(Image)

    self.title1Rect5 = self.panel5:Find("PanelTitle/Title1"):GetComponent(RectTransform)
    self.title2Rect5 = self.panel5:Find("PanelTitle/Title2"):GetComponent(RectTransform)
    self.title3Rect5 = self.panel5:Find("PanelTitle/Title3"):GetComponent(RectTransform)
    self.title4Rect5 = self.panel5:Find("PanelTitle/Title4"):GetComponent(RectTransform)
    self.title5Rect5 = self.panel5:Find("PanelTitle/Title5"):GetComponent(RectTransform)

    self.title1Rect5_2 = self.panel5:Find("PanelTitle2/Title1"):GetComponent(RectTransform)
    self.title2Rect5_2 = self.panel5:Find("PanelTitle2/Title2"):GetComponent(RectTransform)
    self.title3Rect5_2 = self.panel5:Find("PanelTitle2/Title3"):GetComponent(RectTransform)
    self.title4Rect5_2 = self.panel5:Find("PanelTitle2/Title4"):GetComponent(RectTransform)
    self.title5Rect5_2 = self.panel5:Find("PanelTitle2/Title5"):GetComponent(RectTransform)

    -- self.descText = main:Find("Desc"):GetComponent(Text)
    self.noticeBtn = main:Find("Notice").gameObject:GetComponent(Button)

    self.personal = main:Find("Personal")
    self.personal:Find("RoleImage").gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-91.6,431.1)
    self.personalPos = self.personal.gameObject:GetComponent(RectTransform).localPosition
    self.personal.gameObject:GetComponent(RectTransform).localPosition = Vector2(self.personalPos.x - 85 ,self.personalPos.y - 412)
    -- self.roleImage = personal:Find("RoleImage"):GetComponent(Image)
    self.scoreImage = self.personal:Find("ScoreImage"):GetComponent(Image)
    self.scoreText = self.personal:Find("Score"):GetComponent(Text)
    self.rankText = self.personal:Find("Rank"):GetComponent(Text)
    --self.myRank = self.personal:Find("I18N_Text")
    self.myDescText = self.personal:Find("Desc"):GetComponent(Text)
    self.selectArea = main:Find("SelectArea")
    -- self.selectCombox = SelectCombox.New(self.selectArea, self.selectData, {selectIndex = 1, listener = function() self:ReloadRankpanel() self:ReloadMydata() end})
    self.toggle = self.selectArea:Find("Toggle"):GetComponent(Toggle)


    self.fristThreePanel = main:Find("FristThree")
    self.fristThreePanel.gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "BackGround")
    self.fristThreePanel.gameObject:SetActive(false)

    self.toggle.isOn = false
    self.toggle.onValueChanged:RemoveAllListeners()
    self.toggle.onValueChanged:AddListener(function() self:SwitchAllAndFriend() end)
    self.title4Image.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon1001")
    self.title4Image2.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon1001")
    self.title4Image5.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon1001")
    self.title4Image5_2.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon1001")
    self.scoreImage.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon1001")
    self.questionBtn = main:Find("Question"):GetComponent(Button)

    self.setting_data = {
       item_list = self.cellObjList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.infoContainer  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.infoContainer:GetComponent(RectTransform).anchoredPosition.y ---父容器改变时上一次的y坐标
       ,scroll_con_height = self.vScroll:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.setting_data5 = {
       item_list = self.cellObjList5 --放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.infoContainer5  --item列表的父容器
       ,single_item_height = self.cloner5:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.infoContainer5:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.vScroll5:GetComponent(RectTransform).sizeDelta.y--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.scoreImage.gameObject:SetActive(false)
    self.scoreText.gameObject:SetActive(false)
    self.myDescText.gameObject:SetActive(false)
    -- self.roleImage.gameObject:SetActive(false)
    self.gameObject.transform:Find("Personal/RoleImage").gameObject:SetActive(false)
    self.cloner:SetActive(false)
    self.cloner5:SetActive(false)
    self.vScroll.gameObject.name = "ScrollLayer"
    self.vScroll5.gameObject.name = "ScrollLayer"

    self.ctnPos =  self.infoContainer:GetComponent(RectTransform)
    self.ctn5Pos =  self.infoContainer5:GetComponent(RectTransform)

    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)

        local model = self.model
        local main = model.currentMain
        local sub = model.currentSub
        local rankClass = model.classList[main].subList[sub]

        if rankClass.type == model.rank_type.Child or
            rankClass.type == model.rank_type.Guild or
            rankClass.type == model.rank_type.GuildBattle or
            rankClass.type == model.rank_type.GoodVoice or
            rankClass.type == model.rank_type.GoodVoice2 then
        else
            if self.ctnPos.anchoredPosition.y > 215 then
                self.panelTitle4_2.gameObject:SetActive(true)
            else
                self.panelTitle4_2.gameObject:SetActive(false)
            end
        end
    end)
    self.vScroll5.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data5)

        local model = self.model
        local main = model.currentMain
        local sub = model.currentSub
        local rankClass = model.classList[main].subList[sub]
        local pos = 0
        if  rankClass.type == model.rank_type.LoveHistory or
            rankClass.type == model.rank_type.LoveWeekly then
            pos = 170
        else
            pos = 215
        end
        if rankClass.type == model.rank_type.Child or
            rankClass.type == model.rank_type.Guild or
            rankClass.type == model.rank_type.GuildBattle or
            rankClass.type == model.rank_type.GoodVoice or
            rankClass.type == model.rank_type.GoodVoice2 then
        else
            if self.ctn5Pos.anchoredPosition.y > pos then
                self.panelTitle5_2.gameObject:SetActive(true)
            else
                self.panelTitle5_2.gameObject:SetActive(false)
            end
        end
    end)

    GameObject.Destroy(self.cloner:GetComponent(TransitionButton))
    GameObject.Destroy(self.cloner5:GetComponent(TransitionButton))

    self.Layout = LuaBoxLayout.New(self.infoContainer, {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.Layout5 = LuaBoxLayout.New(self.infoContainer5, {axis = BoxLayoutAxis.Y, cspacing = 0})

    local obj = nil
    for i=1,15 do
        obj = GameObject.Instantiate(self.cloner)
        obj.name = tostring(i)
        self.Layout:AddCell(obj)
        self.cellObjList[i] = RankItemFourColumn.New(self.model, obj, self.assetWrapper)
        obj = GameObject.Instantiate(self.cloner5)
        obj.name = tostring(i)
        self.Layout5:AddCell(obj)
        self.cellObjList5[i] = RankItemFiveColumn.New(self.model, obj, self.assetWrapper)
    end

    self.width5 = {}
    for i=1,5 do
        self.width5[i] = self["title"..i.."Rect5"].sizeDelta.x
    end
    self.width5_2 = {}
    for i=1,5 do
        self.width5_2[i] = self["title"..i.."Rect5_2"].sizeDelta.x
    end




    self:InitButtonList()

    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
    }
    self.boxYLayout = LuaBoxLayout.New(self.infoContainer, setting)

    -- print(#datalist)
    self.fristThreePanel2 = main:Find("FristThree2")
    self.fristThreePanel2.gameObject:SetActive(false)
    local Bg = self.fristThreePanel2:Find("Bg")
    local bigbg = GameObject.Instantiate(self:GetPrefab(AssetConfig.intimacybg2))
    bigbg.gameObject.transform.localPosition = Vector3(0, 0, 0)
    bigbg.gameObject.transform.localScale = Vector3(1, 1, 1)
    UIUtils.AddBigbg(Bg, bigbg)

    self.fristThree = {}
    self.fristThreeName = {}
    self.fristThreeClass = {}
    self.fristThreeType = {}
    self.fristThreeTypeIcon = {}
    self.fristThreeScore = {}
    self.fristThreeNoPlayer = {}
    self.fristThreeHead = {}
    self.headSlot = {}
    self.fristThreeButton = {}
    for i=1,3 do
        local fristThree = self.gameObject.transform:Find("FristThree/"..i)
        fristThree:Find("RankImage").gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..i)
        if i==1 then
           fristThree.gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_no_1,"No_1")
        else
           fristThree.gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_no_2,"No_2")
        end
        self.fristThreeName[i] = fristThree:Find("Name").gameObject:GetComponent(Text)
        self.fristThreeName[i].color = ColorHelper.ListItem -- self.model.colorList[i]
        self.fristThreeClass[i] = fristThree:Find("ClassImage").gameObject:GetComponent(Image)
        self.fristThreeType[i] = fristThree:Find("ScoreType").gameObject:GetComponent(Text)
        self.fristThreeType[i].color = ColorHelper.ListItem
        self.fristThreeTypeIcon[i] = fristThree:Find("ScoreTypeIcon").gameObject:GetComponent(Image)
        self.fristThreeTypeIcon[i].sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon1001")
        self.fristThreeScore[i] = fristThree:Find("Score").gameObject:GetComponent(Text)
        self.fristThreeScore[i].color = ColorHelper.ListItem --self.model.colorList[i]
        self.fristThreeNoPlayer[i] = fristThree:Find("NoPlayer").gameObject
        self.fristThreeHead[i] = fristThree:Find("Head")
        self.fristThreeHead[i]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "HeadBg")
        self.fristThreeButton[i] = fristThree.gameObject:GetComponent(Button)
        self.fristThreeButton[i].onClick:RemoveAllListeners()

        local j = i
        self.fristThreeButton[i].onClick:AddListener(function() self:OnClickTop(j) end)
    end

    self.fristThreeName2 = {}
    self.fristThreeNoPlayer2 = {}
    self.fristThreeHead2 = {}
    self.fristThreeScore2 = {}
    self.headSlot2 = {}
    self.fristThreeButton2 = {}
    for i=1,3 do
        local fristThree2 = self.gameObject.transform:Find("FristThree2/"..i)
        fristThree2:Find("Heart").gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "LoveWeekly")
        fristThree2:Find("RankBg/Heart").gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "LoveWeekly")
        fristThree2:Find("RankBg/Image").gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..i)
        fristThree2:Find("HeadBg1").gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "HeadBg")
        fristThree2:Find("HeadBg2").gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "HeadBg")
        self.fristThreeName2[2*i-1] = fristThree2:Find("Name1").gameObject:GetComponent(Text)
        self.fristThreeName2[2*i-1].color = Color.white
        self.fristThreeName2[2*i] = fristThree2:Find("Name2").gameObject:GetComponent(Text)
        self.fristThreeName2[2*i].color = Color.white
        self.fristThreeNoPlayer2[i] = fristThree2:Find("NoPlayer1").gameObject
        self.fristThreeHead2[2*i-1] = fristThree2:Find("Head1")
        self.fristThreeHead2[2*i] = fristThree2:Find("Head2")
        self.fristThreeScore2[i] = fristThree2:Find("RankBg/Text").gameObject:GetComponent(Text)
        self.fristThreeScore2[i].color = Color(1, 1, 0, 1)
    end

    self:OnShow()
    self.noticeBtn.onClick:RemoveAllListeners()
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    self.questionBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("排名奖励")
end

function RankPanel:OnShow()
    -- self.selectCombox:Show()
    local model = self.model

    local main = model.currentMain
    local sub = model.currentSub
    local rankClass = model.classList[main].subList[sub]
    local role_info = RoleManager.Instance.RoleData
    self.gameObject.transform:Find("Personal/RoleImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.half_length, "half_"..role_info.classes..role_info.sex)
    self.gameObject.transform:Find("Personal/RoleImage").gameObject:SetActive(true)
    -- self.roleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.half_length, "half_"..role_info.classes..role_info.sex)
    -- self.roleImage.gameObject:SetActive(true)

    -- self:ReloadRankpanel(true)
    -- self:ReloadMydata()
    self:ReloadButtonList()
    self:ChangePanel(model.currentMain,model.currentSub)
    self:SwitchAllAndFriend()

    RankManager.Instance.OnUpdateList:Remove(self._update)
    RankManager.Instance.OnUpdateList:Add(self._update)
end

function RankPanel:OnHide()
    SingManager.Instance.model:StopSong()
    self:EnableSub(self.model.currentMain, self.model.currentSub, false)

    local rankClass = self.model.classList[self.model.currentMain].subList[self.model.currentSub]
    if rankClass ~= nil then
        if #rankClass.title == 4 then
            self.model.lastPosition = self.infoContainerRect.anchoredPosition.y
        elseif #rankClass.title == 5 then
            self.model.lastPosition = self.infoContainer5Rect.anchoredPosition.y
        end
    end
    RankManager.Instance.OnUpdateList:Remove(self._update)
    if self.fristThree ~= nil then
        self.fristThree[3] = nil
        self.fristThree[2] = nil
        self.fristThree[1] = nil
    end
end

function RankPanel:update(updateType)
    if updateType == "ReloadRankpanel" then
        self:ReloadRankpanel()
    elseif updateType == "ReloadMydata" then
        self:ReloadMydata()
    end
end

function RankPanel:InitButtonList()
    local preload = PreloadManager.Instance
    local model = self.model
    self.mainButtonList = {}
    self.mainImageList = {}
    self.subButtonList = {}
    self.subImageList = {}
    self.mainTextList = {}
    self.subTextList = {}
    self.subOpenList = {}

    local mainBtn
    local subBtn
    local subList = nil
    local subObjList = nil
    local subImageList = nil
    local subTextList = nil
    for i=1,#model.classList do
        local data = model.classList[i]
        mainBtn = GameObject.Instantiate(self.mainButtonTemplate)
        mainBtn.name = tostring(i)
        mainBtn:SetActive(true)
        UIUtils.AddUIChild(self.barContainer, mainBtn)
        self.mainTextList[i] = mainBtn.transform:Find("Text"):GetComponent(Text)
        self.mainTextList[i].text = data.name

        mainBtn.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, data.icon)

        mainBtn:GetComponent(Button).onClick:AddListener(function ()
            self:ClickMainButton(i)
        end)

        subList = data.subList
        subObjList = {}
        subImageList = {}
        subTextList = {}

        local show = false
        for j=1,#subList do
            local subdata = subList[j]
            subBtn = GameObject.Instantiate(self.subButtonTemplate)
            subBtn:GetComponent(Button).onClick:AddListener(function ()
                self:ClickSubButton(i, j)
            end)
            subBtn.name = tostring(i.."_"..j)
            UIUtils.AddUIChild(self.barContainer, subBtn)
            subObjList[j] = subBtn
            subTextList[j] = subBtn.transform:Find("Text"):GetComponent(Text)
            subTextList[j].text = subdata.name
            if subdata.path == nil then
                subBtn.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, subdata.icon)
            else
                subBtn.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(subdata.path, subdata.icon)
            end
            subImageList[j] = subBtn:GetComponent(Image)
            subBtn:SetActive(false)

            show = show or (self.model.showFuncTab[subdata.type] == nil or self.model.showFuncTab[subdata.type]())
        end
        self.mainButtonList[i] = mainBtn
        self.subButtonList[i] = subObjList
        self.mainImageList[i] = mainBtn:GetComponent(Image)
        self.subImageList[i] = subImageList
        self.subTextList[i] = subTextList
        self.subOpenList[i] = false

        mainBtn.gameObject:SetActive(show)
    end
end

function RankPanel:__delete()
    self:OnHide()

    if self.cellObjList ~= nil then
        for _,v in pairs(self.cellObjList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.cellObjList = nil
    end

    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
    end

    if self.cellObjList5 ~= nil then
        for _,v in pairs(self.cellObjList5) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.cellObjList5 = nil
    end

    if self.boxYLayout ~= nil then
        self.boxYLayout:DeleteMe()
        self.boxYLayout = nil
    end
    if self.Layout ~= nil then
        self.Layout:DeleteMe()
        self.Layout = nil
    end
    if self.Layout5 ~= nil then
        self.Layout5:DeleteMe()
        self.Layout5 = nil
    end
    if self.selectCombox ~= nil then
        self.selectCombox:DeleteMe()
        self.selectCombox = nil
    end
    self.model.currentSelectItem = nil
    -- if self.gameObject ~= nil then
    --     GameObject.DestroyImmediate(self.gameObject)
    --     self.gameObject = nil
    -- end
    if self.fristThreeButton ~= nil then
        for _,v in pairs(self.fristThreeButton) do
            if v ~= nil then
                v.gameObject:GetComponent(Image).sprite = nil
            end
        end
    end
    if self.headSlot ~= nil then
        for _,v in pairs(self.headSlot) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.headSlot = nil
    end
    if self.headSlot2 ~= nil then
        for _,v in pairs(self.headSlot2) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.headSlot2 = nil
    end
    self.headBg = nil
    self:AssetClearAll()
end

function RankPanel:ClickMainButton(selectMain)
    local model = self.model

    local main = model.currentMain
    local sub = model.currentSub
    local rankClass = model.classList[main].subList[sub]

    model.lastPosition = 0
    model.selectIndex = nil
    if selectMain ~= model.currentMain then
        self:EnableMain(model.currentMain, false)
        self:ShowSubButton(model.currentMain, false)
        model.currentSub = 1
        if selectMain == 6 and RoleManager.Instance.RoleData.lev >= 80 then
            --诸神排行特殊处理
            model.currentSub = model.rankTypeToPageIndexList[model.rank_type.GodswarNewTalent].sub
        end
        model.currentMain = selectMain
        self:EnableMain(model.currentMain, true)
        if model.currentMain == 5 then
            self:EnableSub(model.currentMain, model.rankTypeToPageIndexList[model.rank_type.MasqNewTalent].sub, false)
            self:EnableSub(model.currentMain, model.rankTypeToPageIndexList[model.rank_type.WarriorNewTalent].sub, false)
        elseif model.currentMain == 6 then
            self:EnableSub(model.currentMain, model.rankTypeToPageIndexList[model.rank_type.GodswarNewTalent].sub, false)
            self:EnableSub(model.currentMain, model.rankTypeToPageIndexList[model.rank_type.WorldchampionElite].sub, false)
        end
        self:ShowSubButton(model.currentMain, true) --展示子菜单列表，并将currentSub置为高亮

        --self:ClickSubButton(model.currentMain, model.currentSub)
        -- self:ReloadMydata()
        -- self:ReloadRankpanel(true)
        if (model.currentMain == 6 and model.currentSub == model.rankTypeToPageIndexList[model.rank_type.WorldchampionElite].sub) then
            --武道大会在前面
            local index = model:CheckMyselfChampionDevel()
            self:OnTopMenuClick(index)
        elseif (model.currentMain == 6 and model.currentSub == model.rankTypeToPageIndexList[model.rank_type.GodswarNewTalent].sub) then
            local index = model:CheckMyselfGodwarsDevel()
            self:OnTopMenuClick(index)
        else
            self:ChangePanel(model.currentMain,model.currentSub)
            self:SwitchAllAndFriend()
        end
    else
        self:ShowSubButton(selectMain, not self.subOpenList[selectMain])
    end
end

function RankPanel:ClickSubButton(selectMain, selectSub)
    SingManager.Instance.model:StopSong()
    local model = self.model

    local main = model.currentMain
    local sub = model.currentSub
    local rankClass = model.classList[main].subList[sub]

    model.lastPosition = 0
    model.selectIndex = nil
    --print(model.currentMain)
    --print(model.currentSub)
    --BaseUtils.dump(model.datalist[model.currentMain][model.currentSub])
    model.datalist[model.currentMain][model.currentSub][2] = nil
    if selectMain ~= model.currentMain then
        self:EnableSub(model.currentMain, model.currentSub, false)
        self:EnableMain(selectMain, false)
        self:ShowSubButton(model.currentMain, false)
        model.currentMain = selectMain
        model.currentSub = selectSub
        self:ShowSubButton(model.currentMain, true) --展示子菜单列表
        self:EnableMain(selectMain, true)
        self:EnableSub(model.currentMain, model.currentSub, true)

        self:ChangePanel(model.currentMain,model.currentSub)
        self:SwitchAllAndFriend()

    elseif selectSub ~= model.currentSub then
        local firstType = self.model:GetCurrFirstType()
        self:EnableSub(model.currentMain, model.rankTypeToPageIndexList[firstType].sub, false)
        --self:EnableSub(model.currentMain, model.currentSub, false)
        model.currentSub = selectSub

        --如果是秘境与战场 将type对应的位置为选中状态
        local secondType = self.model:GetCurrFirstType()
        self:EnableSub(model.currentMain, model.rankTypeToPageIndexList[secondType].sub, true)

        --查看自己的组别
        local lev = RoleManager.Instance.RoleData.lev
        if (selectMain == 5 and selectSub == model.rankTypeToPageIndexList[model.rank_type.WarriorNewTalent].sub) then
            local MyWarriorLevel = 4
            for i,v in pairs(DataWarrior.data_group) do
                if lev >= v.min_lev and lev <= v.max_lev then
                    MyWarriorLevel = v.id
                    break
                end
            end
            self:OnTopMenuClick(4 - MyWarriorLevel + 1)
        elseif (selectMain == 5 and selectSub == model.rankTypeToPageIndexList[model.rank_type.MasqNewTalent].sub) then
            local MyElfLevel = 4
            for i,v in pairs(DataElf.data_group) do
                if lev >= v.min and lev <= v.max then
                    MyElfLevel = v.group
                    break
                end
            end
            self:OnTopMenuClick(4 - MyElfLevel + 1)
        elseif (selectMain == 6 and selectSub == model.rankTypeToPageIndexList[model.rank_type.WorldchampionElite].sub) then
            local index = model:CheckMyselfChampionDevel()
            --print(index.."index")
            self:OnTopMenuClick(index)
        elseif (selectMain == 6 and selectSub == model.rankTypeToPageIndexList[model.rank_type.GodswarNewTalent].sub) then
            --取自身诸神组别
            local index = model:CheckMyselfGodwarsDevel()
            --print(index.."index")
            self:OnTopMenuClick(index)

        elseif (selectMain == 5 and selectSub == model.rankTypeToPageIndexList[model.rank_type.canyonYoungster].sub) then
            local MyLevel = 4
            for i,v in pairs(DataCanyonSummit.data_group_info) do
                if lev >= v.lev_min and lev <= v.lev_max then
                    if v.group_id == 3 then
                        MyLevel = v.group_id -1
                    elseif v.group_id > 3 then
                        MyLevel = v.group_id -2
                    elseif v.group_id > 5 then
                        MyLevel = v.group_id -3
                    end
                    break
                end
            end
            if MyLevel > 4 or MyLevel < 1 then 
                MyLevel = 1
            end 
            self:OnTopMenuClick(MyLevel)
        else
            self:ChangePanel(model.currentMain,model.currentSub)
            self:SwitchAllAndFriend()
        end
    end
end

function RankPanel:EnableMain(currentMain, bool)
    local preload = PreloadManager.Instance
    if bool then
        self.mainImageList[currentMain].sprite = preload:GetSprite(AssetConfig.base_textures, "DefaultButton9")
        self.mainTextList[currentMain].color = ColorHelper.DefaultButton9
        self.mainButtonList[currentMain].transform:Find("Arrow"):GetComponent(Image).sprite = preload:GetSprite(AssetConfig.base_textures, "Arrow3")
    else
        self.mainImageList[currentMain].sprite = preload:GetSprite(AssetConfig.base_textures, "DefaultButton8")
        self.mainTextList[currentMain].color = ColorHelper.DefaultButton8
        self.mainButtonList[currentMain].transform:Find("Arrow"):GetComponent(Image).sprite = preload:GetSprite(AssetConfig.base_textures, "Arrow4")
    end
end

function RankPanel:EnableSub(currentMain, currentSub, bool)
    if bool then
        if self.subImageList[currentMain][currentSub] ~= nil then
            self.subImageList[currentMain][currentSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton11")
            self.subTextList[currentMain][currentSub].color = ColorHelper.DefaultButton11
        end
    else
        if self.subImageList ~= nil and self.subImageList[currentMain][currentSub] ~= nil then
            self.subImageList[currentMain][currentSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton10")
            self.subTextList[currentMain][currentSub].color = ColorHelper.DefaultButton10
        end
    end
end

function RankPanel:ShowSubButton(selectMain, bool)
    local model = self.model
    self.subOpenList[selectMain] = bool
    local h = (self.mainButtonHeight + 3) * #self.model.classList
    for k,v in pairs(self.subButtonList[selectMain]) do
        local type = model.classList[selectMain].subList[k].type
        local show = (bool and (model.showFuncTab[type] == nil or model.showFuncTab[type]()))
        v:SetActive(show)
        if show then
            h = h + self.subButtonHeight
        end
    end
    self.barRect.sizeDelta = Vector2(self.barRect.sizeDelta.x, h)
    self:EnableSub(model.currentMain, model.currentSub, bool)
    if bool then
        self.mainButtonList[selectMain].transform:Find("Arrow").localScale = Vector3(-1, 1, 1)
    else
        self.mainButtonList[selectMain].transform:Find("Arrow").localScale = Vector3(1, 1, 1)
    end
end

-- 重新载入排名数据
function RankPanel:ReloadRankpanel(isFirst)
    local model = self.model
    local main = model.currentMain
    local sub = model.currentSub
    self:UpdateTitle(main, sub)
    self.datalist = nil
    local rankClass = model.classList[main].subList[sub]
    if self.toggle.isOn == true then
        model.sub_type = 2
    else
        model.sub_type = 1
    end

    model.datalist = model.datalist or {}
    model.datalist[main] = model.datalist[main] or {}
    model.datalist[main][sub] = model.datalist[main][sub] or {}

    --self.datalist = model.datalist[main][sub][model.sub_type]
    self.datalist = self.datalist or {}
    local length = #self.datalist
    for i=1,length do
        self.datalist[i] = nil
    end
    --BaseUtils.dump(model.datalist[main][sub][model.sub_type],"*******2222*******")
    for i,v in ipairs(model.datalist[main][sub][model.sub_type] or {}) do
        self.datalist[i] = v
    end

    --BaseUtils.dump(self.datalist,"**************")

    if #self.datalist > 0 then
        self.model.lastShowMomentList[self.model.classList[main].subList[sub].type] = BaseUtils.BASE_TIME
    end
    --table.remove(datalist,1)
    -- if (model.datalist[main][sub][model.sub_type] == nil or rankClass.nocache == true) and isFirst == true then
    --     -- model.datalist[main][sub][model.sub_type] = {}
    --     RankManager.Instance:send12500({type = rankClass.type, page = 1, num = rankClass.num, sub_type = model.sub_type})
    -- end

    -- model.selectIndex = nil

    if #rankClass.title == 5 then
        self.panel5.gameObject:SetActive(true)
        self.panel4.gameObject:SetActive(false)
        if #self.datalist == 0 then
            self.nothing5:SetActive(true)
            if self.fristThree[1] == nil then
                self.nothing5Text.text = TI18N("当前排行榜暂时没有数据")
            else
                self.nothing5Text.text = TI18N("暂时没有其他数据")
            end
        else
            self.nothing5:SetActive(false)
        end
    else
        self.panel5.gameObject:SetActive(false)
        self.panel4.gameObject:SetActive(true)
        if #self.datalist == 0 then
            self.nothing:SetActive(true)
             if self.fristThree[1] == nil then
                self.nothingText.text = TI18N("当前排行榜暂时没有数据")
            else
                self.nothingText.text = TI18N("暂时没有其他数据")
            end
        else
            self.nothing:SetActive(false)
        end
    end

    if rankClass.type ~= model.rank_type.Child and
        rankClass.type ~= model.rank_type.Guild and
        rankClass.type ~= model.rank_type.GuildBattle and
        rankClass.type ~= model.rank_type.GoodVoice and
        rankClass.type ~= model.rank_type.GoodVoice2 then
        if self.datalist[1] ~= nil then
            self.fristThree[1] = table.remove(self.datalist,1)
        end
        if self.datalist[1] ~= nil then
            self.fristThree[2] = table.remove(self.datalist,1)
        end
        if self.datalist[1] ~= nil then
            self.fristThree[3] = table.remove(self.datalist,1)
        end

        for i=1,4 do
            table.insert(self.datalist,1,{virtual = true})
        end
        if rankClass.type ~= model.rank_type.LoveWeekly and
            rankClass.type ~= model.rank_type.LoveHistory then
            table.insert(self.datalist,1,{virtual = true})
        end
    end
    -- BaseUtils.dump(self.datalist,"self.datalist2")
    -- local virtualNum = 5
    -- if rankClass.type == model.rank_type.LoveWeekly or rankClass.type == model.rank_type.LoveHistory then
    --         virtualNum = 4
    -- end

    if #rankClass.title == 5 then
        self.setting_data5.data_list = self.datalist
        BaseUtils.refresh_circular_list(self.setting_data5)
        self.vScroll5.onValueChanged:Invoke({0, 1})
        self.infoContainer5Rect.anchoredPosition = Vector2(0, self.model.lastPosition)
        self.vScroll5.onValueChanged:Invoke({0,1 - self.model.lastPosition / self.infoContainer5Rect.sizeDelta.y})
    else
        self.setting_data.data_list = self.datalist
        BaseUtils.refresh_circular_list(self.setting_data)

        self.vScroll.onValueChanged:Invoke({0, 1})
        self.infoContainerRect.anchoredPosition = Vector2(0, self.model.lastPosition)
        self.vScroll.onValueChanged:Invoke({0, 1 - self.model.lastPosition / self.infoContainerRect.sizeDelta.y})
    end
    -- if rankClass.nocache == true then
    --     model.datalist[main][sub][model.sub_type] = nil
    -- end

    -- if rankClass.type == model.rank_type.WarriorNewTalent
    self.questionBtn.transform:Find("Panel").gameObject:SetActive(true)
    self.questionBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("排名奖励")
    local rect1 = self.questionBtn.transform:Find("Text"):GetComponent(RectTransform)
    rect1.offsetMin = Vector2(-90,0)
    rect1.offsetMax = Vector2(4,0)
    if rankClass.type == model.rank_type.WarriorElite
        or rankClass.type == model.rank_type.WarriorCourage
        or rankClass.type == model.rank_type.WarriorHero
        then
        self.questionBtn.onClick:RemoveAllListeners()
        self.questionBtn.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = self.questionBtn.gameObject, itemData = DataItem.data_get[21160], extra = {nobutton = true}}) end)
        self.questionBtn.gameObject:SetActive(true)
        self.selectArea.gameObject:SetActive(false)
    elseif rankClass.type == model.rank_type.StarChallenge then
        self.questionBtn.onClick:RemoveAllListeners()
        self.questionBtn.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = self.questionBtn.gameObject, itemData = DataItem.data_get[24052], extra = {nobutton = true}}) end)
        self.questionBtn.gameObject:SetActive(true)
        self.selectArea.gameObject:SetActive(false)
    elseif rankClass.type == model.rank_type.ApocalypseLord then
        self.questionBtn.onClick:RemoveAllListeners()
        self.questionBtn.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = self.questionBtn.gameObject, itemData = DataItem.data_get[24055], extra = {nobutton = true}}) end)
        self.questionBtn.gameObject:SetActive(true)
        self.selectArea.gameObject:SetActive(false)
    elseif model:CheckGodswarType(rankClass.type) then
        self.questionBtn.transform:Find("Panel").gameObject:SetActive(false)
        self.questionBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("历届诸神")
        local rect = self.questionBtn.transform:Find("Text"):GetComponent(RectTransform)
        rect.offsetMin = Vector2(-100,0)
        rect.offsetMax = Vector2(4,0)
        self.questionBtn.onClick:RemoveAllListeners()
        self.questionBtn.onClick:AddListener(function() GodsWarManager.Instance.model:OpenMain({4, isChoose = true}) end)
        self.questionBtn.gameObject:SetActive(true)
    else
        self.questionBtn.gameObject:SetActive(false)
        self.selectArea.gameObject:SetActive(true)
    end
    if model.classList[main].subList[sub].friendSupported ~= true then
        self.selectArea.gameObject:SetActive(false)
    else
        self.selectArea.gameObject:SetActive(true)
    end
    self:UpdateFristThree()
    if rankClass.type == model.rank_type.LoveHistory or
        rankClass.type == model.rank_type.LoveWeekly then
        self:UpdateFristThree2()
    end

    if #rankClass.title == 5 then

        if rankClass.type == model.rank_type.Child or
            rankClass.type == model.rank_type.Guild or
            rankClass.type == model.rank_type.GuildBattle or
            rankClass.type == model.rank_type.GoodVoice or
            rankClass.type == model.rank_type.GoodVoice2 then
            self.panelTitle5:SetParent(self.panel5)
            self.panelTitle5.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-0.5,34)
            self.panelTitle5_2.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,1)
        elseif self.model:CheckMasqType(rankClass.type) then
            self.fristThreePanel:SetParent(self.gameObject.transform)
            self.fristThreePanel.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(83.5,100+ self.ctn5Pos.anchoredPosition.y - 50)
            local temp = self.fristThreePanel.gameObject:GetComponent(RectTransform).anchoredPosition
            self.fristThreePanel:SetParent(self.infoContainer5.transform)
            self.panelTitle5:SetParent(self.panel5)
            self.panelTitle5.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-0.5,-215+ self.ctn5Pos.anchoredPosition.y - 57)
            self.panelTitle5:SetParent(self.infoContainer5.transform)

            self.panelTitle5_2.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-50)
        else
            self.fristThreePanel:SetParent(self.gameObject.transform)
            self.fristThreePanel.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(83.5,100+ self.ctn5Pos.anchoredPosition.y)
            self.fristThreePanel:SetParent(self.infoContainer5.transform)
            self.fristThreePanel2:SetParent(self.gameObject.transform)
            self.fristThreePanel2.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(83.5,146+ self.ctn5Pos.anchoredPosition.y)
            self.fristThreePanel2:SetParent(self.infoContainer5.transform)

            self.panelTitle5:SetParent(self.panel5)
            if rankClass.type == model.rank_type.LoveHistory or
                rankClass.type == model.rank_type.LoveWeekly then
                self.panelTitle5.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-0.5,-169.9+ self.ctn5Pos.anchoredPosition.y)
            else
                self.panelTitle5.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-0.5,-215+ self.ctn5Pos.anchoredPosition.y)
            end
            self.panelTitle5:SetParent(self.infoContainer5.transform)
            self.panelTitle5_2.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,1)
        end

    else
        if rankClass.type == model.rank_type.Child or
            rankClass.type == model.rank_type.Guild or
            rankClass.type == model.rank_type.GuildBattle or
            rankClass.type == model.rank_type.GoodVoice or
            rankClass.type == model.rank_type.GoodVoice2 then
            self.panelTitle4:SetParent(self.panel4)
            self.panelTitle4.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-0.5,34)
            self.panelTitle4_2.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,1)
        elseif self.model:CheckWarriorType(rankClass.type) or self.model:CheckChampionType(rankClass.type) or self.model:CheckGodswarType(rankClass.type) or self.model:CheckCanyonType(rankClass.type) then
            self.fristThreePanel:SetParent(self.gameObject.transform)
            self.fristThreePanel.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(83.5,100+ self.ctnPos.anchoredPosition.y - 50)
            --self.fristThreePanel.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(83.5,100)
            self.fristThreePanel:SetParent(self.infoContainer.transform)
            self.panelTitle4:SetParent(self.panel4)
            self.panelTitle4.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-0.5,-215+ self.ctnPos.anchoredPosition.y - 57)
            self.panelTitle4:SetParent(self.infoContainer.transform)

            self.panelTitle4_2.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-50)
        else
            self.fristThreePanel:SetParent(self.gameObject.transform)
            self.fristThreePanel.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(83.5,100+ self.ctnPos.anchoredPosition.y)

            self.fristThreePanel:SetParent(self.infoContainer.transform)
            self.panelTitle4:SetParent(self.panel4)
            self.panelTitle4.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-0.5,-215+ self.ctnPos.anchoredPosition.y)
            self.panelTitle4:SetParent(self.infoContainer.transform)
            self.panelTitle4_2.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,1)
        end
    end
    for i=1,5 do
        if self.cellObjList[i].isVirtual == true then
            self.cellObjList[i]:SetActive(false)
        end
        if self.cellObjList5[i].isVirtual == true then
            self.cellObjList5[i]:SetActive(false)
        end
    end
end

function RankPanel:ReloadMydata()
    local model = self.model
    local main = model.currentMain
    local sub = model.currentSub

    if model.mydata == nil then
        model.mydata = {}
    end
    if model.mydata[main] == nil then
        model.mydata[main] = {}
    end

    local ranktype = model.classList[main].subList[sub].type

    if model.mydata[main][sub] == nil then
        -- RankManager.Instance:send12501({type = ranktype})
        model.mydata[main][sub] = {rank = 0}
    end

    local data = model.mydata[main][sub]

    if data.rank == 0 then
        self.scoreText.gameObject:SetActive(false)
        self.scoreImage.gameObject:SetActive(false)
        self.myDescText.gameObject:SetActive(false)
        self.rankText.text = TI18N("昨日未上榜")
        if ranktype == model.rank_type.GoodVoice or ranktype == model.rank_type.GoodVoice2 or self.model:CheckChampionType(ranktype) then
            self.rankText.text = TI18N("未上榜")
            --self.rankText.text = string.format(TI18N("未上榜"), DataTournament.data_list[WorldChampionManager.Instance.rankData.rank_lev].name)
        end
	else
		self.rankText.text = tostring(data.rank)
        self.scoreText.gameObject:SetActive(true)
        self.myDescText.gameObject:SetActive(true)
		if ranktype == model.rank_type.DragonBoat then
            --self.scoreText.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
			if data.val1 < 3600 then
                local s = data.val1 % 60
                local m = math.floor(data.val1 / 60)
				self.scoreText.text = string.format(TI18N("%s分%s秒"), tostring(m), tostring(s))
			else
				local s = data.val1 % 60
				local h = math.floor(data.val1 / 3600)
                local m = math.floor((data.val1 - h * 3600) / 60)
				self.scoreText.text = string.format(TI18N("%s小时%s分%s秒"), tostring(h), tostring(m), tostring(s))
			end
        elseif model:CheckChampionType(ranktype) then
            self.scoreText.gameObject:SetActive(false)
            self.myDescText.gameObject:SetActive(false)
            self.rankText.text = string.format(TI18N("%s  我的头衔:%s"), data.rank, DataTournament.data_list[data.val1].name)
        elseif model:CheckGodswarType(ranktype) then
            self.scoreText.gameObject:SetActive(false)
            self.myDescText.gameObject:SetActive(false)
            self.rankText.text = string.format(TI18N("%s  我的诸神:%s"), data.rank, model.GodsWarLevel[data.val1])
		else
            --self.scoreText.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(25.7, 0)
			self.scoreText.text = tostring(data.val1)
		end

        if ranktype ~= model.rank_type.Jingji_cup then
            self.scoreImage.gameObject:SetActive(false)
            self.scoreText.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(136.6, 0)
        else
            self.scoreImage.gameObject:SetActive(true)
            self.scoreText.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(166.6, 0)
        end
    end

end

function RankPanel:UpdateTitle(currentMain, currentSub)
    local model = self.model
    local data = model.classList[currentMain].subList[currentSub]
    model.currentType = data.type

    if #data.title == 5 then
        local titleIndex = data.titleIndex
        self.title1Text5.text = data.title[1]
        self.title2Text5.text = data.title[2]
        self.title3Text5.text = data.title[3]
        self.title4Text5.text = data.title[4]
        self.title5Text5.text = data.title[5]

        self.title1Text5_2.text = data.title[1]
        self.title2Text5_2.text = data.title[2]
        self.title3Text5_2.text = data.title[3]
        self.title4Text5_2.text = data.title[4]
        self.title5Text5_2.text = data.title[5]

        if data.title[4] == "" then
            self.title4Image5.gameObject:SetActive(true)
            self.title4Image5_2.gameObject:SetActive(true)
        else
            self.title4Image5.gameObject:SetActive(false)
            self.title4Image5_2.gameObject:SetActive(false)
        end

        if titleIndex == nil then
            titleIndex = {1, 2, 3, 4, 5}
        end
        local x = 0
        for _,v in ipairs(titleIndex) do
            self["title"..v.."Rect5"].anchoredPosition = Vector2(x, 0)
            x = x + self.width5[v]
        end
        local x = 0
        for _,v in ipairs(titleIndex) do
            self["title"..v.."Rect5_2"].anchoredPosition = Vector2(x, 0)
            x = x + self.width5_2[v]
        end
    else
        self.title1Text.text = data.title[1]
        self.title2Text.text = data.title[2]
        self.title3Text.text = data.title[3]
        self.title4Text.text = data.title[4]

        self.title1Text2.text = data.title[1]
        self.title2Text2.text = data.title[2]
        self.title3Text2.text = data.title[3]
        self.title4Text2.text = data.title[4]

        if data.title[4] == "" then
            self.title4Image.gameObject:SetActive(true)
            self.title4Image2.gameObject:SetActive(true)
        else
            self.title4Image.gameObject:SetActive(false)
            self.title4Image2.gameObject:SetActive(false)
        end
    end

    if model.currentType == model.rank_type.Pet then
        self.title2Text.text = data.title[3]
        self.title3Text.text = data.title[2]
        self.title2Text2.text = data.title[3]
        self.title3Text2.text = data.title[2]
    end

    -- self.descText.text = data.desc
    self.myDescText.text = data.scoreDesc

    --self.noticeBtn.gameObject:SetActive(data.notice ~= nil)
end

function RankPanel:ReloadButtonList()
    local model = self.model

    for i=1,#model.classList do
        self:EnableMain(i, false)
        self:ShowSubButton(i, false)
    end

    self:EnableMain(model.currentMain, true)
    for i=1,#model.classList[model.currentMain].subList do
        self:EnableSub(model.currentMain, i, false)
    end
    self:EnableSub(model.currentMain, model.currentSub, true)

    self:ShowSubButton(model.currentMain, true)
end

function RankPanel:SwitchAllAndFriend()
    local model = self.model
    local main = model.currentMain
    local sub = model.currentSub
    local sub_type = 1

    -- model.selectIndex = nil
    -- model.datalist[main][sub][2] = nil
    if self.model.currentSelectItem ~= nil then
        self.model.currentSelectItem:SetActive(false)
    end
    self.model.lastPosition = self.model.lastPosition or 0


    if self.toggle.isOn == true then
        sub_type = 2
        if model.classList[main].subList[sub].friendSupported ~= true then
            self.toggle.onValueChanged:RemoveAllListeners()
            self.toggle.isOn = false
            self.toggle.onValueChanged:AddListener(function() self:SwitchAllAndFriend() end)
            --NoticeManager.Instance:FloatTipsByString(TI18N("该榜不支持好友排行"))
            sub_type = 1
            -- return
        end
    end
    --print(main.."&&"..sub)
    --print(model.classList[main].subList[sub].type.."type")
    model:CheckAskData(model.classList[main].subList[sub].type, sub_type)  --发协议

    self.fristThree[3] = nil
    self.fristThree[2] = nil
    self.fristThree[1] = nil

    if model.classList[main].subList[sub].friendSupported ~= true then
        self.selectArea.gameObject:SetActive(false)
    else
        self.selectArea.gameObject:SetActive(true)
    end
    self:ReloadMydata()
    self:ReloadRankpanel(true)
end

function RankPanel:OnNotice()
    local model = self.model
    local data = model.classList[model.currentMain].subList[model.currentSub]
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {data.desc}})
end
--点击左边按钮显示
function RankPanel:ChangePanel(selectMain, selectSub)
    local model = self.model
    local main = model.currentMain
    local sub = model.currentSub
    local rankClass = model.classList[main].subList[sub]
    self.panelTitle4_2.gameObject:SetActive(false)
    self.panelTitle5_2.gameObject:SetActive(false)
    self.line.gameObject:SetActive(false)
    self.divideGroup.gameObject:SetActive(false)
    if rankClass == nil then
        rankClass = model.classList[1].subList[1]
    end
    if rankClass.type == model.rank_type.Child or
        rankClass.type == model.rank_type.Guild or
        rankClass.type == model.rank_type.GuildBattle or
        rankClass.type == model.rank_type.GoodVoice or
        rankClass.type == model.rank_type.GoodVoice2 then
        self.panel4:GetComponent(RectTransform).localPosition = self.panel4Pos
        self.panel4:GetComponent(RectTransform).sizeDelta = self.panel4Size
        self.gameObject.transform:Find("Panel4/ScrollLayer").gameObject:GetComponent(RectTransform).sizeDelta = self.scrollLayer4Size
        self.gameObject.transform:Find("Panel4/ScrollLayer").gameObject:GetComponent(RectTransform).localPosition = self.scrollLayer4Pos
        self.panel5:GetComponent(RectTransform).localPosition = self.panel5Pos
        self.panel5:GetComponent(RectTransform).sizeDelta = self.panel5Size
        self.gameObject.transform:Find("Panel5/ScrollLayer").gameObject:GetComponent(RectTransform).sizeDelta = self.scrollLayer5Size
        self.gameObject.transform:Find("Panel5/ScrollLayer").gameObject:GetComponent(RectTransform).localPosition = self.scrollLayer5Pos

        self.personal:Find("RoleImage").gameObject:SetActive(true)
        --self.personal.gameObject:GetComponent(RectTransform).localPosition = self.personalPos
        self.fristThreePanel.gameObject:SetActive(false)
        self.fristThreePanel2.gameObject:SetActive(false)
        --self.rankText.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-97, -411)
        --self.myRank.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-181, -411)

        self.nothing.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-150)
        self.nothing5.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-150)
    --         if rankClass.type ~= model.rank_type.Child and
    --     rankClass.type ~= model.rank_type.Guild and
    --     rankClass.type ~= model.rank_type.GuildBattle and
    --     rankClass.type ~= model.rank_type.GoodVoice and
    --     rankClass.type ~= model.rank_type.GoodVoice2 then

    --     self.nothing.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,0)
    --     self.nothing5.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,0)

    -- else
    --     self.nothing.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-115)
    --     self.nothing5.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-115)
    -- end

    elseif rankClass.type == model.rank_type.LoveHistory or rankClass.type == model.rank_type.LoveWeekly then
        self.panel4:GetComponent(RectTransform).localPosition = self.panel4Pos3
        self.panel4:GetComponent(RectTransform).sizeDelta = self.panel4Size3
        self.gameObject.transform:Find("Panel4/ScrollLayer").gameObject:GetComponent(RectTransform).sizeDelta = self.scrollLayer4Size3
        self.gameObject.transform:Find("Panel4/ScrollLayer").gameObject:GetComponent(RectTransform).localPosition = self.scrollLayer4Pos3
        self.panel5:GetComponent(RectTransform).localPosition = self.panel5Pos3
        self.panel5:GetComponent(RectTransform).sizeDelta = self.panel5Size3
        self.gameObject.transform:Find("Panel5/ScrollLayer").gameObject:GetComponent(RectTransform).sizeDelta = self.scrollLayer5Size3
        self.gameObject.transform:Find("Panel5/ScrollLayer").gameObject:GetComponent(RectTransform).localPosition = self.scrollLayer5Pos3

        self.personal:Find("RoleImage").gameObject:SetActive(false)
        --self.personal.gameObject:GetComponent(RectTransform).localPosition = self.personalPos2
        self.fristThreePanel.gameObject:SetActive(false)
        self.fristThreePanel2.gameObject:SetActive(true)
        --self.rankText.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-16.3, 0)
        --self.myRank.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-100, 0)
        self.nothing.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-194)
        self.nothing5.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-194)
    elseif self.model:CheckWarriorType(rankClass.type) or self.model:CheckChampionType(rankClass.type) or self.model:CheckGodswarType(rankClass.type) or self.model:CheckCanyonType(rankClass.type)then
        self.panel4:GetComponent(RectTransform).localPosition = self.panel4Pos2
        self.panel4:GetComponent(RectTransform).sizeDelta = self.panel4Size2
        self.gameObject.transform:Find("Panel4/ScrollLayer").gameObject:GetComponent(RectTransform).sizeDelta = self.scrollLayer4Size2 - Vector3(0,53,0)
        self.gameObject.transform:Find("Panel4/ScrollLayer").gameObject:GetComponent(RectTransform).localPosition = self.scrollLayer4Pos2 - Vector3(0,25,0)
        self.fristThreePanel.gameObject:SetActive(true)
        self.fristThreePanel2.gameObject:SetActive(false)

        self.personal:Find("RoleImage").gameObject:SetActive(false)
        self.nothing.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-206)
        self.nothing5.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-206)
        self.divideGroup:SetParent(self.panel4)
        self.line:SetParent(self.panel4)
        self.divideGroup.gameObject:GetComponent(RectTransform).anchoredPosition = Vector3(0,-28,0)
        self.line.gameObject:SetActive(true)
        self.divideGroup.gameObject:SetActive(true)
        local info = nil
        for i,v in pairs (self.CampGroup) do
            if self.model:CheckChampionType(rankClass.type) then
                info = model.Champion[i]
                if info ~= nil then
                    v.title.text = TI18N(info.name)
                    v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, tostring(info.icon))
                end

            elseif self.model:CheckGodswarType(rankClass.type) then
                info = model.Gods[i]
                if info ~= nil then
                    v.title.text = TI18N(info.name)
                    v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, tostring(info.icon))
                end

            elseif self.model:CheckWarriorType(rankClass.type) then
                info = model.Warrior[i]
                if info ~= nil then
                    v.title.text = TI18N(info.name)
                    v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, tostring(info.icon))
                end
            elseif self.model:CheckCanyonType(rankClass.type) then
                info = model.Canyon[i]
                if info ~= nil then
                    v.title.text = TI18N(info.name)
                    v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, tostring(info.icon))
                end
            end
        end
        --Warrior
    elseif self.model:CheckMasqType(rankClass.type) then
        --精灵幻境
        self.panel5:GetComponent(RectTransform).localPosition = self.panel5Pos2
        self.panel5:GetComponent(RectTransform).sizeDelta = self.panel5Size2
        self.gameObject.transform:Find("Panel5/ScrollLayer").gameObject:GetComponent(RectTransform).sizeDelta = self.scrollLayer5Size2 - Vector3(0,53,0)
        self.gameObject.transform:Find("Panel5/ScrollLayer").gameObject:GetComponent(RectTransform).localPosition = self.scrollLayer5Pos2 - Vector3(0,25,0)
        self.fristThreePanel.gameObject:SetActive(true)
        self.fristThreePanel2.gameObject:SetActive(false)

        self.personal:Find("RoleImage").gameObject:SetActive(false)
        self.nothing.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-206)
        self.nothing5.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-206)
        self.divideGroup:SetParent(self.panel5)
        self.line:SetParent(self.panel5)
        self.divideGroup.gameObject:GetComponent(RectTransform).anchoredPosition = Vector3(0,-28,0)
        self.line.gameObject:SetActive(true)
        self.divideGroup.gameObject:SetActive(true)
        local info = nil
        for i,v in pairs (self.CampGroup) do
            info = model.Masq[i]
            if info ~= nil then
                v.title.text = TI18N(info.name)
                v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, tostring(info.icon))
            end

        end
    else
        self.panel4:GetComponent(RectTransform).localPosition = self.panel4Pos2
        self.panel4:GetComponent(RectTransform).sizeDelta = self.panel4Size2
        self.gameObject.transform:Find("Panel4/ScrollLayer").gameObject:GetComponent(RectTransform).sizeDelta = self.scrollLayer4Size2
        self.gameObject.transform:Find("Panel4/ScrollLayer").gameObject:GetComponent(RectTransform).localPosition = self.scrollLayer4Pos2
        self.panel5:GetComponent(RectTransform).localPosition = self.panel5Pos2
        self.panel5:GetComponent(RectTransform).sizeDelta = self.panel5Size2
        self.gameObject.transform:Find("Panel5/ScrollLayer").gameObject:GetComponent(RectTransform).sizeDelta = self.scrollLayer5Size2
        self.gameObject.transform:Find("Panel5/ScrollLayer").gameObject:GetComponent(RectTransform).localPosition = self.scrollLayer5Pos2

        self.personal:Find("RoleImage").gameObject:SetActive(false)
        --self.personal.gameObject:GetComponent(RectTransform).localPosition = self.personalPos2
        self.fristThreePanel.gameObject:SetActive(true)
        self.fristThreePanel2.gameObject:SetActive(false)

        self.nothing.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-212)
        self.nothing5.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-212)
        --self.rankText.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-16.3, 0)
        --self.myRank.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-100, 0)
    end
end

function RankPanel:UpdateFristThree()

    for i=1,3 do
        if self.fristThree[i] ~= nil then
            local data = self.fristThree[i]
            local model = self.model
            local main = model.currentMain
            local sub = model.currentSub
            local rankClass = model.classList[main].subList[sub]

            if rankClass.type ~= model.rank_type.LoveWeekly and
                rankClass.type ~= model.rank_type.LoveHistory then
                self.fristThreeName[i].text = self.fristThree[i].name
                self.fristThreeType[i].gameObject:SetActive(true)
                self.fristThreeButton[i].interactable = true
                local typeText = nil
                local scoreText = nil
                if rankClass.type == model.rank_type.Home or
                    rankClass.type == model.rank_type.StarChallenge or
                    rankClass.type == model.rank_type.ApocalypseLord or
                    rankClass.type == model.rank_type.MasqNewTalent or
                    rankClass.type == model.rank_type.MasqElite or
                    rankClass.type == model.rank_type.MasqCourage or
                    rankClass.type == model.rank_type.MasqHero then
                    -- self.fristThreeTypeIcon[i].gameObject:SetActive(false)
                    -- self.fristThreeType[i].text = rankClass.title[5]
                    typeText = rankClass.title[5]
                elseif rankClass.type == model.rank_type.TopChallenge or

                       rankClass.type == model.rank_type.ClassesChallenge then
                    -- self.fristThreeTypeIcon[i].gameObject:SetActive(false)
                    -- self.fristThreeType[i].text = rankClass.title[3]
                    typeText = rankClass.title[3]
                elseif rankClass.type == model.rank_type.AdventureSkill then
                    -- self.fristThreeType[i].text = TI18N("总等级")
                    typeText = TI18N("总等级")
                elseif rankClass.type == model.rank_type.Pet or
                       rankClass.type == model.rank_type.Shouhu  then
                    typeText = data.desc
                else
                    -- self.fristThreeType[i].text = rankClass.title[4]
                    typeText = rankClass.title[4]
                    -- if rankClass.title[4] == "" then
                    --     self.fristThreeTypeIcon[i].gameObject:SetActive(true)
                    -- else
                    --     self.fristThreeTypeIcon[i].gameObject:SetActive(false)
                    -- end
                end

                self.fristThreeNoPlayer[i].gameObject:SetActive(false)

                if self.headSlot[i] == nil then
                    self.headSlot[i] = HeadSlot.New(nil,true)
                    self.fristThreeHead[i].transform.localScale = Vector3(1,1,1)
                    self.fristThreeHead[i].transform.sizeDelta = Vector2(60,60)
                    self.headSlot[i]:SetRectParent(self.fristThreeHead[i])

                    self.headSlot[i].transform.localScale = Vector3(1,1,1)
                    self.headSlot[i].gameObject:GetComponent(Button).enabled = false
                    self.headSlot[i].gameObject:GetComponent(TransitionButton).enabled = false
                    -- self.headSlot[i].image = self.headSlot[i].gameObject:GetComponent(Image)
                end

                if rankClass.type == model.rank_type.GuildBattle or
                    rankClass.type == model.rank_type.Guild then
                    --RankManager.Instance:send11102(data.desc)
                    -- BaseUtils.dump(self.model.guildData)
                    --BaseUtils.dump(data.desc)
                elseif rankClass.type == model.rank_type.Pet then
                    -- BaseUtils.dump(data)
                    self.fristThreeHead[i].gameObject:SetActive(true)
                    self.headSlot[i].image.sprite = self.headBg
                    self.headSlot[i].baseLoader.gameObject:SetActive(true)
                    self.headSlot[i].transform:Find("Custom/Container").gameObject:SetActive(false)
                    if data.val4 == 0 then
                        for k,v in pairs(DataPet.data_pet) do
                            if v.name == data.desc then
                                self.headSlot[i].baseLoader:SetSprite(SingleIconType.Pet,v.head_id)
                                break
                            end
                        end
                    else
                        self.headSlot[i].baseLoader:SetSprite(SingleIconType.Pet, DataPet.data_pet[data.val4].head_id)
                    end
                    self.fristThreeClass[i].gameObject:SetActive(true)
                    self.fristThreeClass[i].sprite = PreloadManager.Instance:GetClassesSprite(data.classes)
                else
                    self.fristThreeHead[i].gameObject:SetActive(true)
                    self.headSlot[i].image.sprite = self.rectangleBg
                    local myId = data.role_id or data.rid
                    local dat = {id = myId, platform = data.platform, zone_id = data.zone_id,classes = data.classes, sex = data.sex}
                    self.headSlot[i]:SetAll(dat, {isSmall = true})
                    self.fristThreeClass[i].gameObject:SetActive(true)
                    self.fristThreeClass[i].sprite = PreloadManager.Instance:GetClassesSprite(data.classes)
                end

                self.fristThreeScore[i].gameObject:SetActive(true)
                local type = rankClass.type
                if type == model.rank_type.RenQiWeekly
                    or type == model.rank_type.RenQiHistory
                    or type == model.rank_type.GetFlower
                    or type == model.rank_type.SendFlower
                    or type == model.rank_type.WarriorNewTalent
                    or type == model.rank_type.WarriorElite
                    or type == model.rank_type.WarriorCourage
                    or type == model.rank_type.WarriorHero
                    or type == model.rank_type.AdventureSkill
                    or type == model.rank_type.Duanwei
                    or type == model.rank_type.Achievement
                    or type == model.rank_type.Students
                    or type == model.rank_type.Teacher
                    or type == model.rank_type.Wise
                    or type == model.rank_type.Glory
                    or type == model.rank_type.Sword
                    or type == model.rank_type.Magic
                    or type == model.rank_type.Orc
                    or type == model.rank_type.Arrow
                    or type == model.rank_type.Devine
                    or type == model.rank_type.Moon
                    or type == model.rank_type.Temple
                    or type == model.rank_type.Universe
                    or type == model.rank_type.Jingji_cup
                    or type == model.rank_type.Weapon
                    or type == model.rank_type.Cloth
                    or type == model.rank_type.Belt
                    or type == model.rank_type.Pant
                    or type == model.rank_type.Shoes
                    or type == model.rank_type.Ring
                    or type == model.rank_type.Nacklace
                    or type == model.rank_type.Bracelet
                    or type == model.rank_type.Pet
                    or type == model.rank_type.Shouhu
                    or type == model.rank_type.Hero
                    or type == model.rank_type.canyonYoungster
                    or type == model.rank_type.canyonElite
                    or type == model.rank_type.canyonValiant
                    or type == model.rank_type.canyonHero
                    or type == model.rank_type.allCanyonYoungster
                    or type == model.rank_type.allCanyonElite
                    or type == model.rank_type.allCanyonValiant
                    or type == model.rank_type.allCanyonHero
                    then
                    -- self.fristThreeScore[i].text = tostring(data.val1)
                    scoreText = tostring(data.val1)
                elseif type == model.rank_type.StarChallenge then

                    -- self.fristThreeScore[i].text = BaseUtils.formate_time_gap(data.use_time, ":", 0, BaseUtils.time_formate.MIN)
                    if data.use_time < 3600 then
                        scoreText = BaseUtils.formate_time_gap(data.use_time, ":", 0, BaseUtils.time_formate.MIN)
                    else
                        scoreText = BaseUtils.formate_time_gap(data.use_time, ":", 0, BaseUtils.time_formate.HOUR)
                    end

                elseif type == model.rank_type.ApocalypseLord then
                    if data.use_time < 3600 then
                        scoreText = BaseUtils.formate_time_gap(data.use_time, ":", 0, BaseUtils.time_formate.MIN)
                    else
                        scoreText = BaseUtils.formate_time_gap(data.use_time, ":", 0, BaseUtils.time_formate.HOUR)
                    end
                elseif type == model.rank_type.Lev
                    then
                    -- self.fristThreeScore[i].text = tostring(data.lev)
                    scoreText = tostring(data.lev)
                elseif type == model.rank_type.ClassesChallenge
                    then
                    local day = nil
                    local hour = nil
                    local min = nil
                    local sec = nil

                    day,hour,min,sec = BaseUtils.time_gap_to_timer(data.val2)
                    if hour > 0 then
                        -- self.fristThreeScore[i].text = string.format(TI18N("%s小时%s分%s秒"), hour, min, sec)
                        scoreText = string.format(TI18N("%s小时%s分%s秒"), hour, min, sec)
                    else
                        -- self.fristThreeScore[i].text = string.format(TI18N("%s分%s秒"), min, sec)
                        scoreText = string.format(TI18N("%s分%s秒"), min, sec)
                    end
                elseif type == model.rank_type.TopChallenge
                    then
                    -- self.fristThreeScore[i].text = tostring(data.val2)
                    scoreText = tostring(data.val1)
                elseif type == model.rank_type.MasqNewTalent
                    or type == model.rank_type.MasqElite
                    or type == model.rank_type.MasqCourage
                    or type == model.rank_type.MasqHero
                    then
                    -- self.fristThreeScore[i].text = tostring(data.val1)
                    scoreText = tostring(data.val1)
                elseif type == model.rank_type.Home
                    then
                    -- self.fristThreeScore[i].text = tostring(data.val1)
                    scoreText = tostring(data.val1)
                elseif model:CheckChampionType(type) then
                    scoreText = DataTournament.data_list[data.rank_lev].name
                elseif self.model:CheckGodswarType(type) then
                    scoreText = model.GodsWarLevel[data.val1]
                end

                if type ~= model.rank_type.Jingji_cup then

                    self.fristThreeTypeIcon[i].gameObject:SetActive(false)
                    self.fristThreeType[i].gameObject:SetActive(false)
                    self.fristThreeScore[i].gameObject:SetActive(true)
                    self.fristThreeScore[i].text = typeText.."  "..scoreText

                else
                    self.fristThreeTypeIcon[i].gameObject:SetActive(true)
                    self.fristThreeType[i].gameObject:SetActive(true)
                    self.fristThreeScore[i].gameObject:SetActive(false)
                    self.fristThreeType[i].text = scoreText
                end


            end
        else
            self.fristThreeName[i].text = TI18N("虚位以待")
            self.fristThreeClass[i].gameObject:SetActive(false)
            self.fristThreeType[i].gameObject:SetActive(false)
            self.fristThreeScore[i].gameObject:SetActive(false)
            self.fristThreeNoPlayer[i].gameObject:SetActive(true)
            self.fristThreeHead[i].gameObject:SetActive(false)
            self.fristThreeButton[i].interactable = false
            self.fristThreeTypeIcon[i].gameObject:SetActive(false)
        end
    end
end

function RankPanel:UpdateFristThree2()
    for i=1,3 do
        if self.fristThree[i] ~= nil then
            local data = self.fristThree[i]
            if #StringHelper.ConvertStringTable(data.male_name)>4 then
                self.fristThreeName2[2*i-1].text = BaseUtils.string_cut_utf8(data.male_name,4,3).."."
            else
                self.fristThreeName2[2*i-1].text = data.male_name
            end
            if #StringHelper.ConvertStringTable(data.female_name)>4 then
                self.fristThreeName2[2*i].text = BaseUtils.string_cut_utf8(data.female_name,4,3).."."
            else
                self.fristThreeName2[2*i].text = data.female_name
            end
            self.fristThreeNoPlayer2[i].gameObject:SetActive(false)
            if self.headSlot2[2*i-1] == nil then
                self.headSlot2[2*i-1] = HeadSlot.New()
                self.headSlot2[2*i-1]:SetRectParent(self.fristThreeHead2[2*i-1])
                self.headSlot2[2*i-1].transform.localScale = Vector3(1,1,1)
            end
            if self.headSlot2[2*i] == nil then
                self.headSlot2[2*i] = HeadSlot.New()
                self.headSlot2[2*i]:SetRectParent(self.fristThreeHead2[2*i])
                self.headSlot2[2*i].transform.localScale = Vector3(1,1,1)
            end
            self.fristThreeHead2[2*i-1].gameObject:SetActive(true)
            self.fristThreeHead2[2*i].gameObject:SetActive(true)
            local dat = {id = data.m_id, platform = data.m_platform, zone_id = data.m_zone_id,classes = data.male_classes, sex = data.male_sex}
            self.headSlot2[2*i-1]:SetAll(dat, {isSmall = true})
            self.headSlot2[2*i-1].gameObject:GetComponent(TransitionButton).scaleSetting = true
            self.headSlot2[2*i-1].gameObject:GetComponent(Button).onClick:RemoveAllListeners()
            self.headSlot2[2*i-1].gameObject:GetComponent(Button).onClick:AddListener(function()
                    if self.model.currentSelectItem ~= nil then
                        self.model.currentSelectItem:SetActive(false)
                    end
                    self.model.selectIndex = -2*i+1
                    local data = self.fristThree[i]
                    local showData = {id = data.m_id, zone_id = data.m_zone_id, platform = data.m_platform, sex = data.male_sex, classes = data.male_classes, name = data.male_name, lev = data.male_lev}
                    TipsManager.Instance:ShowPlayer(showData)
                end)
            local dat = {id = data.f_id, platform = data.f_platform, zone_id = data.f_zone_id,classes = data.female_classes, sex = data.female_sex}
            self.headSlot2[2*i]:SetAll(dat, {isSmall = true})
            self.headSlot2[2*i].gameObject:GetComponent(TransitionButton).scaleSetting = true
            self.headSlot2[2*i].gameObject:GetComponent(Button).onClick:RemoveAllListeners()
            self.headSlot2[2*i].gameObject:GetComponent(Button).onClick:AddListener(function()
                    if self.model.currentSelectItem ~= nil then
                        self.model.currentSelectItem:SetActive(false)
                    end
                    self.model.selectIndex = -2*i
                    local data = self.fristThree[i]
                    local showData = {id = data.f_id, zone_id = data.f_zone_id, platform = data.f_platform, sex = data.female_sex, classes = data.female_classes, name = data.female_name, lev = data.female_lev}
                    TipsManager.Instance:ShowPlayer(showData)
                end)
            self.fristThreeScore2[i].gameObject:SetActive(true)
            self.fristThreeScore2[i].text = tostring(data.val1)
        else
            self.fristThreeName2[2*i-1].text = TI18N("虚位以待")
            self.fristThreeName2[2*i].text = TI18N("虚位以待")
            self.fristThreeNoPlayer2[i].gameObject:SetActive(true)
            self.fristThreeHead2[2*i-1].gameObject:SetActive(false)
            self.fristThreeHead2[2*i].gameObject:SetActive(false)
            self.fristThreeScore2[i].gameObject:SetActive(false)
        end
    end
end

function RankPanel:OnClickTop(index)
    local model = self.model
    local type = model.currentType
    if model.currentSelectItem ~= nil then
        model.currentSelectItem:SetActive(false)
    end
    model.selectIndex = -index
    local data = self.fristThree[index]
    local data_cpy = BaseUtils.copytab(data)
    if type == model.rank_type.Lev
        or type == model.rank_type.Guild
        or type == model.rank_type.Guild
        or type == model.rank_type.Jingji_cup
        or type == model.rank_type.RenQiWeekly
        or type == model.rank_type.RenQiHistory
        or type == model.rank_type.GetFlower
        or type == model.rank_type.SendFlower
        or type == model.rank_type.Duanwei
        or type == model.rank_type.WarriorNewTalent
        or type == model.rank_type.WarriorElite
        or type == model.rank_type.WarriorCourage
        or type == model.rank_type.WarriorHero
        or type == model.rank_type.AdventureSkill
        or type == model.rank_type.Achievement
        or type == model.rank_type.Universe
        or type == model.rank_type.Sword
        or type == model.rank_type.Magic
        or type == model.rank_type.Arrow
        or type == model.rank_type.Orc
        or type == model.rank_type.Devine
        or type == model.rank_type.Moon
        or type == model.rank_type.Temple
        or type == model.rank_type.Students
        or type == model.rank_type.Teacher
        or type == model.rank_type.Hero
        or type == model.rank_type.Glory
        or type == model.rank_type.TopChallenge
        or type == model.rank_type.StarChallenge
        or type == model.rank_type.ClassesChallenge
        or type == model.rank_type.Wise
        or type == model.rank_type.MasqNewTalent
        or type == model.rank_type.MasqElite
        or type == model.rank_type.MasqCourage
        or type == model.rank_type.MasqHero
        --or type == model.rank_type.Home
        or type == model.rank_type.StarChallenge
        or type == model.rank_type.ApocalypseLord
        or type == model.rank_type.canyonYoungster
        or type == model.rank_type.canyonElite
        or type == model.rank_type.canyonValiant
        or type == model.rank_type.canyonHero
        or type == model.rank_type.allCanyonYoungster
        or type == model.rank_type.allCanyonElite
        or type == model.rank_type.allCanyonValiant
        or type == model.rank_type.allCanyonHero
        then
        local showData = {id = data.role_id, zone_id = data.zone_id, platform = data.platform, rid = data.rid}
        TipsManager.Instance:ShowPlayer(showData)
    elseif type == model.rank_type.Home then
        TipsManager.Instance:ShowPlayer({id = data_cpy.role_id, zone_id = data_cpy.zone_id, platform = data_cpy.platform, sex = data_cpy.sex, classes = data_cpy.classes, name = data_cpy.name, guild = data_cpy.desc, lev = data.lev})
    elseif type == model.rank_type.Shouhu then
        ShouhuManager.Instance.model.shouhu_look_lev = data.lev
        ShouhuManager.Instance.model.shouhu_look_owner_name = data.name
        local data = {type = type, role_id = data.role_id, platform = data.platform, zone_id = data.zone_id, sub_type = model.sub_type}
        RankManager.Instance:send12503(data)
    elseif type == model.rank_type.Pet then
        RankManager.Instance:send12502({type = type, sub_type = model.sub_type, role_id = data.role_id, platform = data.platform, zone_id = data.zone_id})
    elseif self.model:CheckGodswarType(type) then
        --RankManager.Instance.model:OpenRankTeamShowPanel()
        local currIndex = model.classList[model.currentMain].subList[model.currentSub].type - 66
        RankManager.Instance:send12506(data.role_id, data.platform, data.zone_id, currIndex) 
    elseif self.model:CheckChampionType(type) then
        --RankManager.Instance.model:OpenRankTeamShowPanel()
        --local showData = {id = data.rid, zone_id = data.zone_id, platform = data.platform, rid = data.rid}
        TipsManager.Instance:ShowPlayer(data)
    end
end

function RankPanel:OnTopMenuClick(index)
    local model = self.model
    if model.currentMain == 5 and (model:GetCurrFirstType() == model.rank_type.WarriorNewTalent or model:GetCurrFirstType() == model.rank_type.MasqNewTalent or model:GetCurrFirstType() == model.rank_type.canyonYoungster) then
        self.tempNum = 4
    elseif model.currentMain == 6 and model:GetCurrFirstType() == model.rank_type.WorldchampionElite then
        self.tempNum = 7
    elseif model.currentMain == 6 and model:GetCurrFirstType() == model.rank_type.GodswarNewTalent then
        self.tempNum = 5
    end
    if self.tempNum == 0 then return end
    for i = 1,self.tempNum do
        if self.CampGroup[i] == nil then
            local divide = {}
            divide.item = GameObject.Instantiate(self.itemer).transform
            divide.btn = divide.item:GetComponent(Button)
            divide.btn.onClick:AddListener(function() self:OnTopMenuClick(i) end)
            divide.title = divide.item:Find("Title1"):GetComponent(Text)
            divide.image = divide.item:Find("Image"):GetComponent(Image)
            divide.bgimage = divide.item:GetComponent(Image)
            self.TopLayout:AddCell(divide.item.gameObject)
            self.CampGroup[i] = divide
        else
            self.CampGroup[i].item.gameObject:SetActive(true)
        end
    end
    for i =self.tempNum + 1, #self.CampGroup do
        self.CampGroup[i].item.gameObject:SetActive(false)
    end
    self.container.transform.sizeDelta = Vector2(self.tempNum * 132 + 18, 36.5)
    self.container.transform.anchoredPosition = Vector2(0, 0)
    if self.tempNum <= 4 then
        self.rightArrow.gameObject:SetActive(false)
        self.leftArrow.gameObject:SetActive(false)
    elseif self.tempNum > 4 then
        self.rightArrow.gameObject:SetActive(true)
        self.leftArrow.gameObject:SetActive(true)
        if index > 4 then
            self.container.transform.anchoredPosition = Vector2(-(self.container.transform.sizeDelta.x - 546), 0)
        end
    end

    for i,v in pairs (self.CampGroup) do
        if index == i then
            v.bgimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton7")
        else
            v.bgimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton5")
        end
    end

    local firstType = self.model:GetCurrFirstType()
    model.currentSub = model.rankTypeToPageIndexList[firstType].sub + index -1
    self:ChangePanel(model.currentMain, model.currentSub)   --初始化位置和显示
    self:SwitchAllAndFriend()
end

function RankPanel:OnClickArrow(index)
    local currPosition = self.container.transform.anchoredPosition
    local currSize = self.container.transform.sizeDelta
    if index == 1 then
        if -currPosition.x > 546 then
            self.container.transform.anchoredPosition = self.container.transform.anchoredPosition + Vector2(546, 0)
        else
            self.container.transform.anchoredPosition = self.container.transform.anchoredPosition + Vector2(-currPosition.x, 0)
        end
    elseif index == 2 then
        if currSize.x - (-currPosition.x + 546) > 546 then
            self.container.transform.anchoredPosition = self.container.transform.anchoredPosition - Vector2(546, 0)
        else
            self.container.transform.anchoredPosition = self.container.transform.anchoredPosition - Vector2(currSize.x - (546 -currPosition.x), 0)
        end
    end
end





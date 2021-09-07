GodsWarWorShipWindow  =  GodsWarWorShipWindow or BaseClass(BaseWindow)

function GodsWarWorShipWindow:__init(model)
    self.name  =  "GodsWarWorShipWindow"
    self.model  =  model
    self.windowId = WindowConfig.WinID.godswar_worship_window
    -- 缓存
    self.cacheMode = CacheMode.Visible
    self.resList  =  {
        {file = AssetConfig.godswarworshippanel, type = AssetType.Main},
        {file = AssetConfig.godswarworshiptexture, type = AssetType.Dep},
        {file = AssetConfig.godswarworshipBg,type = AssetType.Dep}
    }

    self.tabShowMount = 3
    self.tabIndex = 0
    self.maxTabIndex = 7
    self.godsWarWorShipItemList = {}
    self.friendItemList = {}
    self.selectionData = nil
    self.campId = 842
    -- self.dolarListener = function() self:UpdateDolar() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.classList =
    {
        [1] = {id = 1,name = "冠军"},
        [2] = {id = 2,name = "亚军"},
        [3] = {id = 3,name = "季军"},

    }


    self.chossesList =
    {
        {id = 1,name = "S6赛季冠军"},
        {id = 2,name = "S5赛季冠军"},
        {id = 3,name = "S4赛季冠军"},
        {id = 4,name = "S3赛季冠军"},
        {id = 5,name = "S2赛季冠军"},
        {id = 6,name = "S1赛季冠军"},
    }

    self.tabObjList = {}
    self.tabRedPoint = {}
    self.panelList = {}
    self.txtList = {}
    self.currentTabIndexId = 1
    self.isInit = false

    self.Top = Vector2(0, 1)
    self.Bottom = Vector2(0, 0)
    self.allHeight = 0

    self.firstTime = 0
    self.firstWorShip = false

    self.msgItemList = {}
    self.chooseList = {}
    self.updateGodWarWorShipData = function() self:UpdateGodWarWorShipData() end
    self.updateGodWarWorShipMsgList = function() self:UpdateMsgList() end
    self.OnInitCompletedEvent:Add(function() self:OnInitCompleted() end)
    self.isUpdateButton = function() self:IsApplyWorShip() end
end

function GodsWarWorShipWindow:OnHide()
    self:RemoveAllListeners()
    NoticeManager.Instance.model.noticeCanvas.transform:GetComponent(Canvas).overrideSorting = false
    TipsManager.Instance.model.tipsCanvas.transform:GetComponent(Canvas).overrideSorting = false
    if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
            self.tweenId = nil
    end
    if self.godsWarWorShipItemList ~= nil then
        for i,v in ipairs(self.godsWarWorShipItemList) do
            if v ~= nil then
                v:OnHide()
            end
        end
    end


end

function GodsWarWorShipWindow:__delete()
    self:RemoveAllListeners()
   NoticeManager.Instance.model.noticeCanvas.transform:GetComponent(Canvas).overrideSorting = false
   TipsManager.Instance.model.tipsCanvas.transform:GetComponent(Canvas).overrideSorting = false
    if self.bigBg ~= nil and self.bigBg.sprite ~= nil then
        self.bigBg.sprite = nil
    end
    if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
            self.tweenId = nil
    end
    if self.refreshId ~= nil then
        LuaTimer.Delete(self.refreshId)
        self.refreshId = 0
    end

    if self.timerId ~= nil then
       LuaTimer.Delete(self.timerId)
       self.timerId = nil
    end

    if self.holdTimerId ~= nil then
       LuaTimer.Delete(self.holdTimerId)
       self.holdTimerId = nil
    end

    if self.godsWarWorShipItemList ~= nil then
        for k,v in pairs(self.godsWarWorShipItemList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.godsWarWorShipItemList = nil
    end

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end

    if self.tabLayout2 ~= nil then
        self.tabLayout2:DeleteMe()
        self.tabLayout2 = nil
    end

    if self.tabLayout3 ~= nil then
        self.tabLayout3:DeleteMe()
        self.tabLayout3 = nil
    end


    if self.msgItemList ~= nil then
        for k,v in pairs(self.msgItemList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
            self.msgItemList = nil
        end
    end

    if self.arrowEffect~= nil then
        self.arrowEffect:DeleteMe()
        self.arrowEffect = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end


function GodsWarWorShipWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarworshippanel))
    self.gameObject.name = "GodsWarWorShipWindow"


    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform = self.gameObject.transform

     self.closeBtn = self.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
     self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.scrollRect = self.transform:Find("MainCon/ScrollRect")
    self.container = self.transform:Find("MainCon/ScrollRect/Container")
    self.godsWarWorShipItem = self.transform:Find("MainCon/ScrollRect/Container/GodsWarWorShipItem")
    self.godsWarWorShipItem.gameObject:SetActive(false)

    self.bigBg = self.transform:Find("WorShipPanel/Main"):GetComponent(Image)
    self.bigBg.sprite = self.assetWrapper:GetSprite(AssetConfig.godswarworshipBg, "WorShipBigBg")


    self.leftButton = self.transform:Find("MainCon/LeftButton"):GetComponent(Button)
    self.leftCanvas = self.leftButton.gameObject:AddComponent(Canvas)
    self.leftButton.gameObject:AddComponent(GraphicRaycaster)
    self.leftCanvas.overrideSorting  = true
    self.leftCanvas.sortingOrder  = 30

    self.rightButton = self.transform:Find("MainCon/RightButton"):GetComponent(Button)
    self.RightCanvas = self.rightButton.gameObject:AddComponent(Canvas)
    self.rightButton.gameObject:AddComponent(GraphicRaycaster)

    self.RightCanvas.overrideSorting  = true
    self.RightCanvas.sortingOrder  = 30

    self.mainScrollRect = self.transform:Find("MainCon/ScrollRect")
    self.mainScrollRect:GetComponent(Image).material = PreloadManager.Instance:GetMainAsset("textures/materials/uimask.unity3d")
    self.leftButton.onClick:AddListener(function() self:ChangeTabIndex(-1) end)
    self.rightButton.onClick:AddListener(function() self:ChangeTabIndex(1) end)


    self.noFriendText = self.transform:Find("ReqHelpMaskPanel/FriendCon/Mask/noFriendText")
    self.topbgButtonText = self.transform:Find("MainCon/TopBg/Button/Text"):GetComponent(Text)

    self.topVoteText = self.transform:Find("MainCon/TopBg/Image/Text"):GetComponent(Text)

    self.msgTemplate = self.transform:Find("MainCon/BottomMsg/Scroll/Cloner")
    self.msgTemplate.gameObject:SetActive(false)


    self.tabLayout = LuaBoxLayout.New(self.container.gameObject, {axis = BoxLayoutAxis.X, cspacing = -63,border = -124,Dir = -30})
    for i=1,self.maxTabIndex do
        local go = GameObject.Instantiate(self.godsWarWorShipItem.gameObject)
        local selectionItem = GodsWarWorShipItem.New(go,self,i)
        self.godsWarWorShipItemList[i] = selectionItem
        self.tabLayout:AddCell(go)
    end
    self.msgContainer = self.transform:Find("MainCon/BottomMsg/Scroll/Container")
    self.msgContainer = self.transform:Find("MainCon/BottomMsg").gameObject:AddComponent(Mask)
    self.slider = self.transform:Find("MainCon/BottomMsg/Scroll"):GetComponent(ScrollRect)

    -- self.slider.onValueChanged:AddListener(function(value)
    --     self:Check(value)
    -- end)

    self.recordButton = self.transform:Find("MainCon/RecordButton"):GetComponent(Button)


    self.worShipButton = self.transform:Find("MainCon/WorShipButton"):GetComponent(CustomButton)
    self.worShipImage = self.transform:Find("MainCon/WorShipButton"):GetComponent(Image)
    self.worShipButton.onHold:AddListener(function() self:ApplyWorShipHold() end)
    self.worShipButton.onDown:AddListener(function() self:ApplyWorShipDown() end)
    self.worShipButton.onUp:AddListener(function() self:ApplyWorShipUp() end)

    self.worShipButtonText = self.transform:Find("MainCon/WorShipButton/Text"):GetComponent(Text)

    self.containerRect = self.transform:Find("MainCon/BottomMsg/Scroll/Container")

    self.tabTemplate = self.transform:Find("MainCon/TabListPanel/TabButton").gameObject
    self.tabTemplate.gameObject:SetActive(false)

    self.bottomText = self.transform:Find("MainCon/BottomText"):GetComponent(Text)

    self.tabLayout2 = LuaBoxLayout.New(self.transform:Find("MainCon/TabListPanel").gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})
    self.transform:Find("MainCon/TabListPanel").gameObject:SetActive(false)

    self.chossesTemplate = self.transform:Find("ChossesPanel/Main/scroll/scroll_content/btn")
    self.chossesTemplate.gameObject:SetActive(false)

    self.chossesPanel = self.transform:Find("ChossesPanel")
    self.chossesPanel.gameObject:SetActive(true)
    self.chossesPanel.transform:GetComponent(Button).onClick:AddListener(function() self.chossesPanel.gameObject:SetActive(false) end)

    self.chossesCanvas = self.chossesPanel.gameObject:AddComponent(Canvas)
    self.chossesPanel.gameObject:AddComponent(GraphicRaycaster)

    self.chossesCanvas.overrideSorting  = true
    self.chossesCanvas.sortingOrder  = 30
    self.chossesPanel.gameObject:SetActive(false)

    self.tabLayout3 = LuaBoxLayout.New(self.transform:Find("ChossesPanel/Main/scroll/scroll_content").gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})

    self.titleText = self.transform:Find("MainCon/TopBg/Image/Text"):GetComponent(Text)

    self.chossesButton = self.transform:Find("MainCon/TopBg/Button"):GetComponent(Button)
    self.chossesButtonCanvas = self.chossesButton.gameObject:AddComponent(Canvas)
    self.chossesButtonCanvas.gameObject:AddComponent(GraphicRaycaster)
    self.chossesButtonCanvas.overrideSorting  = true
    self.chossesButtonCanvas.sortingOrder  = 30

    self.chossesButton.gameObject:SetActive(false)
    self.chossesButton.onClick:AddListener(function() self.chossesPanel.gameObject:SetActive(true) end)

    self.worshipPanel = self.transform:Find("WorShipPanel")
    self.worshipCanvas = self.worshipPanel.gameObject:AddComponent(Canvas)
    self.worshipPanel.gameObject:AddComponent(GraphicRaycaster)
    self.worshipCanvas.overrideSorting  = true
    self.worshipCanvas.sortingOrder  = 30
    self.worshipPanel.gameObject:SetActive(false)

    self.worshipPanel.transform:GetComponent(Button).onClick:AddListener(function() self.worshipPanel.gameObject:SetActive(false) end)

    self.godWarWorShipTextIcon = self.transform:Find("WorShipPanel/Main/Image")
     if self.arrowEffect == nil then
        self.arrowEffect = BibleRewardPanel.ShowEffect(20445, self.worshipPanel.transform:Find("Main/EffectPoint").transform, Vector3(0.762, 0.762, 1), Vector3(0, 0, -400),nil,nil,40)
        -- self.arrowEffect.gameObject.transform:GetComponent(Render).sortingOrder = 22
    end

    self.arrowEffect:SetActive(true)


    self:OnShow()
end

function GodsWarWorShipWindow:OnInitCompleted()
    self.gameObject:GetComponent(Canvas).overrideSorting = true
    self.gameObject:GetComponent(Canvas).sortingOrder = 28
end


function GodsWarWorShipWindow:ChangeChosses(id)
    self.chossesPanel.gameObject:SetActive(false)
    self.tabIndex = 0

    self:ChangeItemList(id)
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    self.container.transform.anchoredPosition = Vector2(13,0)
    self:UpdateSelectionItem()
end

function GodsWarWorShipWindow:AddAllListeners()
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipData:AddListener(self.updateGodWarWorShipData)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipMsg:AddListener(self.updateGodWarWorShipMsgList)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipButton:AddListener(self.isUpdateButton)
end

function GodsWarWorShipWindow:RemoveAllListeners()
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipData:RemoveListener(self.updateGodWarWorShipData)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipMsg:RemoveListener(self.updateGodWarWorShipMsgList)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipButton:RemoveListener(self.isUpdateButton)
end

function GodsWarWorShipWindow:OnShow()
    NoticeManager.Instance.model.noticeCanvas.transform:GetComponent(Canvas).overrideSorting = true
    TipsManager.Instance.model.tipsCanvas.transform:GetComponent(Canvas).overrideSorting = true
    self.isCanGodWarWorship = false
    self:RemoveAllListeners()
    self:AddAllListeners()
    GodsWarWorShipManager.Instance:Send17941()
    GodsWarWorShipManager.Instance:Send17945()
    GodsWarWorShipManager.Instance:Send17947()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    self.doTween = false

    self:Layout()
    -- self:UpdateDolar()
    self.tabIndex = 0
    self.container.transform.anchoredPosition = Vector2(13,0)
    self:SwitchTabs(1)
    -- if DataCampFashionVote ~= nil and DataCampFashionVote.data_campfashiontime[1] ~= nil then
        -- self.topTimeText.text = string.format("活动时间:%s月%s日~%s月%s日",DataCampFashionVote.data_campfashiontime[1].start_time[1][1],DataCampFashionVote.data_campfashiontime[1].start_time[1][2],DataCampFashionVote.data_campfashiontime[1].end_time[1][1],DataCampFashionVote.data_campfashiontime[1].end_time[1][2])
    -- end



    for i,v in ipairs(self.godsWarWorShipItemList) do
        v:OnOpen()
    end

end

function GodsWarWorShipWindow:UpdateGodWarWorShipData()
     self.nowTeamIndex = #GodsWarWorShipManager.Instance.godsWarWorShipData
     -- print("666666666" .. self.nowTeamIndex)
     self.maxTabIndex = math.floor(#GodsWarWorShipManager.Instance.godsWarWorShipData[self.nowTeamIndex].members)
    self.topbgButtonText.text = string.format("第%s赛季",GodsWarWorShipManager.Instance.godsWarWorShipData[self.nowTeamIndex].serial_id)
    self.recordButton.onClick:RemoveAllListeners()
    self.recordButton.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_main, {4,2,isChoose = true,number = GodsWarWorShipManager.Instance.godsWarWorShipData[self.nowTeamIndex].serial_id}) end)
    self:InitChosses()
    self:UpdateSelectionItem()

end

function GodsWarWorShipWindow:InitChosses()
    self.tabLayout3:ReSet()
    for i,v in ipairs(GodsWarWorShipManager.Instance.godsWarWorShipData) do
        local go = nil
        if self.chooseList[i] == nil then
            go = GameObject.Instantiate(self.chossesTemplate.gameObject)
            self.tabLayout3:AddCell(go)
            self.chooseList[i] = go
        end
        self.chooseList[i].transform:GetComponent(Button).onClick:RemoveAllListeners()
        self.chooseList[i].transform:GetComponent(Button).onClick:AddListener(function() self:ChangeChosses(v.serial_id) end)
        self.chooseList[i].transform:Find("Text"):GetComponent(Text).text = "第" .. v.serial_id .. "赛季"
    end

    if #self.chooseList > #GodsWarWorShipManager.Instance.godsWarWorShipData then
        for i=#GodsWarWorShipManager.Instance.godsWarWorShipData + 1,#self.chooseList do
            self.chooseList[i].gameObject:SetActive(false)
        end
    end
    self.chossesButton.gameObject:SetActive(true)
end

function GodsWarWorShipWindow:ChangeTabIndex(index)
    if self.doTween == true then
        return
    end
    local nowtabIndex = self.tabIndex + index
    if nowtabIndex < 0 or nowtabIndex > self.maxTabIndex - self.tabShowMount then
        return
    end
    self.tabIndex = nowtabIndex
    -- print("56555555555555")
    -- print(self.maxTabIndex)
    self.targetMovePostion = -(self.container.transform.sizeDelta.x/7) *  nowtabIndex

    self.tweenId = Tween.Instance:ValueChange(self.container.transform.anchoredPosition.x,self.targetMovePostion + 13,0.7, function() self.tweenId = nil self:MoveEnd(callback) end, LeanTweenType.easeOutQuart, function(value) self:SetMove(value) end).id
    self.doTween = true
end

function GodsWarWorShipWindow:MoveEnd()
        self.doTween = false
end

function GodsWarWorShipWindow:SetMove(valueX)
    self.container.transform.anchoredPosition = Vector2(valueX,self.container.transform.anchoredPosition.y)
end



function GodsWarWorShipWindow:OnclickCloseFriendHelpButton()
    self.friendConMaskPanel.gameObject:SetActive(false)
end

function GodsWarWorShipWindow:ChangeItemList(id)
    for i,v in ipairs(GodsWarWorShipManager.Instance.godsWarWorShipData) do
        if id == v.serial_id then
            self.maxTabIndex = math.floor(#v.members)
            self.nowTeamIndex = i
            self.topbgButtonText.text = string.format("第%s赛季",v.serial_id)

            if #GodsWarWorShipManager.Instance.godsWarWorShipData ~= i then
                self.recordButton.gameObject:SetActive(false)
                self.worShipButton.gameObject:SetActive(false)
                self.bottomText.text = string.format("第%s赛季已结束膜拜\n请切换到最新赛季",id)
                self.bottomText.transform.sizeDelta = Vector2(200,82)
                self.bottomText.transform.anchoredPosition = Vector2(251,-191)
            else
                self.recordButton.gameObject:SetActive(true)
                self.worShipButton.gameObject:SetActive(true)
                self.bottomText.text = "膜拜队伍可获得神秘奖励哦!"
                self.bottomText.transform.sizeDelta = Vector2(200,30)
                self.bottomText.transform.anchoredPosition = Vector2(251,-164.5)
            end
            break
        end
    end
end
function GodsWarWorShipWindow:SelectFriend(frienditem, data)
    if self.lastSelectFriend ~= nil then
        self.lastSelectFriend.transform:Find("select").gameObject:SetActive(false)
    end
    self.lastSelectFriend = frienditem
    self.lastSelectFriend.transform:Find("select").gameObject:SetActive(true)
    self.lastSelectFirendData = data
end

-- function GodsWarWorShipWindow:UpdateRoleStatus()
--     -- self.topInviteVote.text = string.format("%s/%s",FashionSelectionManager.Instance.fashionRoleData.invite_votes,FashionSelectionManager.Instance.fashionData.invite_votes)
--      for i,v in ipairs(self.godsWarWorShipItemList) do
--         v:SetButtonStatus()
--     end

-- end

function GodsWarWorShipWindow:UpdateSelectionItem()
    local isMiddle = false
    self.titleText.text = string.format("%s - <color='#FF00FF'>%s</color>",BaseUtils.GetServerNameMerge(GodsWarWorShipManager.Instance.godsWarWorShipData[self.nowTeamIndex].platfrom, GodsWarWorShipManager.Instance.godsWarWorShipData[self.nowTeamIndex].zone_id),GodsWarWorShipManager.Instance.godsWarWorShipData[self.nowTeamIndex].name)
    for i,v in ipairs(self.godsWarWorShipItemList) do

        local data = GodsWarWorShipManager.Instance.godsWarWorShipData[self.nowTeamIndex].members[i]
        if data ~= nil then
            v.gameObject:SetActive(true)
            v:SetData(data)

            v:OnOpen()

        else
            isMiddle = true
            v.gameObject:SetActive(false)
        end
    end

    -- if isMiddle == true then
    --     self.mainScrollRect.transform.anchoredPosition = Vector2(88,-2.5)
    -- else
    --     self.mainScrollRect.transform.anchoredPosition = Vector2(0,-2.5)
    -- end


end


--================================================================================================
function GodsWarWorShipWindow:UpdateMsgList()
    self:PivotTop()

    for i,v in ipairs(GodsWarWorShipManager.Instance.godsWarMsgList) do
        if self.msgItemList[i] == nil then
            local gameObject = GameObject.Instantiate(self.msgTemplate)
            local transform = gameObject.transform
            transform.gameObject:SetActive(true)
            transform:SetParent(self.containerRect.transform)
            transform.localScale = Vector3.one
            transform.localPosition = Vector3.zero
            local msgItem = MsgItemExt.New(transform:GetComponent(Text), 340, 16, 19)
            self.msgItemList[i] = msgItem
        end
        self.msgItemList[i]:SetData(v.msg)
        self.msgItemList[i].contentTxt.gameObject:SetActive(true)
    end
    self.msgListLenght = #GodsWarWorShipManager.Instance.godsWarMsgList

    if #GodsWarWorShipManager.Instance.godsWarMsgList > #self.msgItemList then
        for i2=#self.msgItemList + 1,#GodsWarWorShipManager.Instance.godsWarMsgList do
            self.msgItemList[i].contentTxt.gameObject:SetActive(false)
        end
    end
    self:ChangeOtherAnchorBottom()
    self.allHeight = self:GetHeight()
    self.containerRect.sizeDelta = Vector2(340, self.allHeight)
end

function GodsWarWorShipWindow:ChangeOtherAnchorBottom()
    local h = 0
    for i,item in ipairs(self.msgItemList) do
        h = h + item.selfHeight
        item.rect = item.contentRect
        item:AnchorBottom(h)
    end
end

-- 当滚到位置在最上面时，容器 ====注册点==== 在上方，这样保证了在新增元素容器拉大时，位置往下移
function GodsWarWorShipWindow:PivotTop()
    self.containerRect.pivot = self.Top
end

-- 当滚动位置在中间时，玩家查看历史消息时，容器 ====注册点==== 在下方，保证了在新增元素容器拉大时当前位置不变，容器往上增大
function GodsWarWorShipWindow:PivotBottom()
    self.containerRect.pivot = self.Bottom
end





function GodsWarWorShipWindow:GetHeight()
    local h = 0

    for i=1,self.msgListLenght do
        h = h + self.msgItemList[i].selfHeight
    end
    return h
end




function GodsWarWorShipWindow:Layout()
     for i,v in ipairs(self.classList) do
      if v ~= nil then
         self.lastGroupIndex = v.group_index
         if self.tabObjList[i] == nil then
            local obj = GameObject.Instantiate(self.tabTemplate)
            self.tabObjList[i] = obj
            self.tabLayout2:AddCell(obj)
         end
         self.tabObjList[i].name = tostring(i)
         local t = self.tabObjList[i].transform
         local content = v.name
         self.tabRedPoint[v.id] = t:Find("RedPoint").gameObject
         local txt = t:Find("Text"):GetComponent(Text)
         txt.text = content
         self.tabObjList[i]:GetComponent(Button).onClick:RemoveAllListeners()
         self.tabObjList[i]:GetComponent(Button).onClick:AddListener(function() self:SwitchTabs(v.id) end)

         if v.spriteFun ~= nil then
            local tab = v.spriteFun
            t:Find("Text").anchoredPosition = Vector2(16,0)
            if type(v.spriteFun) == "table" then
                local sprite = self.assetWrapper:GetSprite(tab.package,tab.name)
                if sprite == nil then
                    sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, tostring(v.icon))
                end
                t:Find("Icon"):GetComponent(Image).sprite  = sprite
            end
            t:Find("Icon").gameObject:SetActive(true)
         else
            t:Find("Text").anchoredPosition = Vector2(0,0)
            t:Find("Icon").gameObject:SetActive(false)
         end
         -- if v.cond_type == 25 then
         --    local icon = t:Find("Icon").gameObject:GetComponent(RectTransform)
         --    icon.localScale = Vector3(1.2, 1.2, 1)
         --    icon.localPosition = Vector3(26, 3, 0)
         -- end

         self.txtList[i] = txt
        end
    end

    if #self.tabObjList > #self.classList then
        for i=#self.classList + 1,#self.tabObjList do
            self.tabObjList[i].gameObject:SetActive(false)
        end
    end
end

function GodsWarWorShipWindow:SwitchTabs(indexId)

    if self.currentTabIndexId == indexId and self.isInit == true  then
        return
    end
    self.isInit = true
    self.txtList[self.currentTabIndexId].text = string.format(ColorHelper.TabButton2NormalStr, self.classList[self.currentTabIndexId].name)
    self.txtList[indexId].text = string.format(ColorHelper.TabButton2SelectStr, self.classList[indexId].name)
    self:EnableTab(self.currentTabIndexId, false)
    self:EnableTab(indexId, true)
    self:ChangePanel(indexId)
    self.currentTabIndexId = indexId
end

function GodsWarWorShipWindow:EnableTab(main, bool)

    if bool == true then
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Select")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Select")
    else
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Normal")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Normal")
    end
end

function GodsWarWorShipWindow:ChangePanel(indexId)
    self.tabIndex = 0
    -- self:ChangeTabItemList()
    -- self:UpdateSelectionItem()
    -- self:UpdateRoleStatus()
end


function GodsWarWorShipWindow:ApplyWorShipDown()

    if GodsWarWorShipManager.Instance.isGodWarWorship == 1 and self.isCanGodWarWorship == true then
        if self.firstWorShip == false then
            self.firstWorShip = true
            self.firstTime = Time.time
            self.worshipPanel.gameObject:SetActive(true)
            self.godWarWorShipTextIcon.gameObject:SetActive(true)
            self.holdTimerId = LuaTimer.Add(2000, function() self:ApplyWorShipUp() end)

        end
    elseif GodsWarWorShipManager.Instance.isGodWarWorship == 0 and self.isCanGodWarWorship == true then
        NoticeManager.Instance:FloatTipsByString("您本周已经膜拜过了，请下周再来")
    end
end

function GodsWarWorShipWindow:ApplyWorShipUp()
    if GodsWarWorShipManager.Instance.isGodWarWorship == 1 and self.isCanGodWarWorship == true then
        if self.holdTimerId ~= nil then
            LuaTimer.Delete(self.holdTimerId)
            self.holdTimerId = nil
        end
        if self.firstWorShip == true then
            local endTime = Time.time
            local distanceTime = endTime - self.firstTime
            if distanceTime < 1.95 then
                self.worshipPanel.gameObject:SetActive(false)
            else

                if 3100 - distanceTime*1000 > 0 then
                    self.godWarWorShipTextIcon.gameObject:SetActive(false)
                    self.timerId = LuaTimer.Add(3100 - distanceTime*1000, function() self:WorShipSuccess() end)

                end
            end
            self.firstWorShip = false
            self.firstTime = 0
        end
    end
end

function GodsWarWorShipWindow:WorShipSuccess()
    self.isCanGodWarWorship = false
    self.worshipPanel.gameObject:SetActive(false)

    GodsWarWorShipManager.Instance:Send17942()
end

function GodsWarWorShipWindow:ApplyWorShipHold()


end

function GodsWarWorShipWindow:IsApplyWorShip()
    if GodsWarWorShipManager.Instance.isGodWarWorship == 0 then
        self.worShipImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.worShipButtonText.color =  ColorHelper.DefaultButton4
    elseif GodsWarWorShipManager.Instance.isGodWarWorship == 1 then
        self.worShipImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.worShipButtonText.color =  ColorHelper.DefaultButton3
    end
    self.isCanGodWarWorship = true
end




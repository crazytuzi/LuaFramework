-- @author 黄耀聪
-- @date 2017年8月28日, 星期一

FaceWindow = FaceWindow or BaseClass(BaseWindow)

function FaceWindow:__init(model)
    self.model = model
    self.name = "FaceWindow"
    self.windowId = WindowConfig.WinID.face_merge

    self.resList = {
        {file = AssetConfig.face_window, type = AssetType.Main},
        -- {file = AssetConfig.new_face_bg, type = AssetType.Main},
        {file = AssetConfig.face_textures, type = AssetType.Dep},
    }

    -- self.verStringList = {}
    self.horStringList = {TI18N("小表情"), TI18N("大表情")}
    self.panelList = {}
    -- self.verList = {}
    self.horList = {}
    self.titleBgList = {}

    self.faceList = {}

    self.curHorIndex = 1

    self.classList =
    {
        [1] = {id = 1,name = "表情1"},
        [2] = {id = 2,name = "表情2"},
    }

    self.tabObjList = {}
    self.tabRedPoint = {}
    self.txtList = {}
    self.currentTabIndexId = 1
    self.isUpdateFace = true

    -- self.faceUpdateListener = function()
    --     if self.isUpdateFace == false then
    --         self.isUpdateFace = true
    --     else
    --         self:ReloadFaces(self.curHorIndex)
    --     end
    -- end
    self.itemListener = function() self:OnUpdateItem() end
    self._OnGetNewFace = function(args) self:OnGetNewFace(args) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function FaceWindow:__delete()
    self.OnHideEvent:Fire()
    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end
    -- if self.verTabGroup ~= nil then
    --     self.verTabGroup:DeleteMe()
    --     self.verTabGroup = nil
    -- end
    if self.horTabGroup ~= nil then
        self.horTabGroup:DeleteMe()
        self.horTabGroup = nil
    end
    if self.faceGrid ~= nil then
        self.faceGrid:DeleteMe()
        self.faceGrid = nil
    end
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
    end

    if self.myPanelId ~= nil then
        self.myPanelId:DeleteMe()
        self.myPanelId = nil
    end
    if self.tipsPanel ~= nil then
        self.tipsPanel:DeleteMe()
        self.tipsPanel = nil
    end
    self:AssetClearAll()
end

function FaceWindow:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.face_window))

    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t
    local canvas = self.gameObject:GetComponent(Canvas)
    canvas.overrideSorting = true
    canvas.sortingOrder = 20
    canvas.overrideSorting = false

    local main = t:Find("Main")
    -- UIUtils.AddBigbg(main:Find("Merge/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.new_face_bg)))
    -- UIUtils.AddBigbg(main:Find("Draw/Bg/Image"), GameObject.Instantiate(self:GetPrefab(AssetConfig.face_call_bg)))

    self.closeBtn = main:Find("Close"):GetComponent(Button)

    self.title = main:Find("Title/Text"):GetComponent(Text)
    self.title.text = TI18N("表 情")

    -- self.verTabCloner = main:Find("VerTabContainer/Tab").gameObject
    -- main:Find("VerTabContainer").gameObject:SetActive(false)
    self.horTabCloner = main:Find("HorTabContainer/Tab").gameObject

    self.mergeObj = main:Find("Merge").gameObject
    self.titleBg = main:Find("TitleBg").gameObject
    self.titleBg.gameObject:SetActive(false)
    self.drawObj = main:Find("Draw").gameObject
    self.tipsObj = main.transform.parent:Find("TipsPanel").gameObject
    self.tipsRect = main.transform.parent:Find("TipsPanel/Main"):GetComponent(RectTransform)
    self.tipsObj.gameObject:SetActive(false)
    self.leftBotomText = main:Find("BottomText"):GetComponent(Text)
    self.textExt = MsgItemExt.New(t:Find("Main/TextExt"):GetComponent(Text), 250, 16, 30)
    self.noticeButton = main:Find("Notice"):GetComponent(Button)
    self.noticeButton.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.noticeButton.gameObject
            , itemData = { TI18N("1、合成获得<color='#00ff00'>重复</color>大表情时可获得<color='#ffff00'>包子币</color>")
                            , TI18N("2、使用<color='#ffff00'>三个</color>包子币可兑换指定大表情")
                        }})
    end)
    self.previewRectScroll = main:Find("FacePreview")
    self.previewContainer = main:Find("FacePreview/Container")
    self.faceGrid = LuaGridLayout.New(main:Find("FacePreview/Container"), {column = 3, bordertop = 0, borderleft = 0, cspacing = 16, rspacing = 16, cellSizeX = 66, cellSizeY = 66})
    self.faceCloner = main:Find("FacePreview/Item").gameObject


    self:ReloadTabs()
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.transform:Find("Main/TabListPanel").gameObject:SetActive(false)
    self.tabLayout = LuaBoxLayout.New(self.transform:Find("Main/TabListPanel").gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})
    self.tabTemplate = self.transform:Find("Main/TabListPanel/TabButton").gameObject
    self.tabTemplate.gameObject:SetActive(false)
    self.mergeObj:SetActive(false)
    self.drawObj:SetActive(false)
    self:OnOpen()
end

function FaceWindow:OnInitCompleted()
end

function FaceWindow:OnOpen()
    self:RemoveListeners()
    -- EventMgr.Instance:AddListener(event_name.new_face_update, self.faceUpdateListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemListener)
    FaceManager.Instance.OnGetNewFace:Add(self._OnGetNewFace)

    self:Layout()
    if self.tipsPanel ~= nil then
        self.tipsPanel:Hiden()
    end
    if self.openArgs ~= nil  then
        if self.openArgs[1] ~= nil and self.openArgs[2] ~= nil then
            self:SwitchTabs(tonumber(self.openArgs[1]),tonumber(self.openArgs[2]))
        elseif self.openArgs[1] ~= nil then
            self:SwitchTabs(tonumber(self.openArgs[1]),1)
        end
    else
        self:SwitchTabs(1,1)
    end

    -- if self.openArgs ~= nil and self.openArgs[1] ~= nil then
    --     self:Switch(tonumber(self.openArgs[1]))
    -- else
    --     self:Switch(1)
    -- end
end

function FaceWindow:OnHide()
    self:RemoveListeners()
    for _,panel in pairs(self.panelList) do
        if panel ~= nil then
            panel:Hiden()
        end
    end
end

function FaceWindow:RemoveListeners()
    -- EventMgr.Instance:RemoveListener(event_name.new_face_update, self.faceUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemListener)
    FaceManager.Instance.OnGetNewFace:Remove(self._OnGetNewFace)
end

-- function FaceWindow:VerChangeTab(index)
--     if self.lastVerIndex ~= nil then
--         self.panelList[self.lastVerIndex]:Hiden()
--     end
--     if self.panelList[index] == nil then
--         if index == 1 then
--             self.panelList[1] = FaceMergePanel.New(self.model, self.mergeObj,self.assetWrapper)
--         elseif index == 2 then
--             self.panelList[2] = FaceDrawPanel.New(self.model, self.drawObj)
--         end
--     end
--     self.panelList[index]:Show()
--     self.lastVerIndex = index
--
-- end

function FaceWindow:HorChangeTab(index)
    if self.lastFaceIndex ~= nil then
        self.faceList[self.lastFaceIndex].select:SetActive(false)
        self.faceList[self.lastFaceIndex].face:Animate(false)
        self.lastFaceIndex = nil
    end
    self:ReloadFaces(index)
    self.curHorIndex = index
    -- if self.isMyChange == true then
    --     if self.panelList[self.currentTabIndexId] ~= nil then
    --         print("233333333333333333")
    --         print(index)
    --         self.panelList[self.currentTabIndexId]:ChooseFinal(index)
    --     end
    -- end
    -- self.isMyChange = true
end

function FaceWindow:ReloadTabs()
    -- for i=2,#self.verStringList do
    --     local g = GameObject.Instantiate(self.verTabCloner)
    --     g.transform:SetParent(self.transform:Find("Main/VerTabContainer"))
    --     g.transform.localScale = Vector3.one
    -- end
    -- self.verTabGroup = TabGroup.New(self.transform:Find("Main/VerTabContainer").gameObject, function(index) self:VerChangeTab(index) end, {
    --     isVertical = true,
    --     perWidth = 46,
    --     perHeight = 95,
    --     spacing = 5,
    --     openLevel = {0, 0},
    --     notAutoSelect = true,
    --     })
    self.horTabGroup = TabGroup.New(self.transform:Find("Main/HorTabContainer").gameObject, function(index) self:HorChangeTab(index) end, {
        isVertical = false,
        perWidth = 115,
        perHeight = 78,
        spacing = 5,
        openLevel = {0, 0},
        notAutoSelect = true,
        noCheckRepeat = true,
        })

    -- for i,v in ipairs(self.verTabGroup.buttonTab) do
    --     v.normalTxt.text = self.verStringList[i]
    --     v.selectTxt.text = self.verStringList[i]
    -- end
    for i,v in ipairs(self.horTabGroup.buttonTab) do
        v.normalTxt.text = self.horStringList[i]
        v.selectTxt.text = self.horStringList[i]
    end
end

-- function FaceWindow:Switch(index)
--     self.verTabGroup:ChangeTab(1)
-- end

function FaceWindow:ReloadFaces(index)
    local list = {}
    local titleList = {}
    for _,v in pairs(DataChatFace.data_new_face) do
        if index == 1 then
            if (v.type == 1 or v.type == 4) and v.tabIndex == self.currentTabIndexId then
                table.insert(list, v.id)
            end
        elseif index == 2 then
            if v.type == 2 and v.tabIndex == self.currentTabIndexId then
                table.insert(list, v.id)
            end
        end
    end
    self.faceGrid:ReSet()


    table.sort(list,function(a,b)
               if a ~= b then
                    return a < b
                else
                    return false
                end
            end)
    local myList = {}
    local lastDistance = 0
    local nowDistance = 0
    local titleIndex = 1
    local nowNum = 0

    for i,v in ipairs(list) do
        if DataChatFace.data_new_face[v].isdistance ~= lastDistance and DataChatFace.data_new_face[v].isdistance ~= 0 then
            local tnumber = nowNum-1
            if tnumber < 0 then
                tnumber = 0
            end
            local num = (math.ceil(i-1-tnumber/3)*3 - (i - 1-tnumber))%3
            for i2=1,3+num do
                if i2 == num + 1 then
                    table.insert(myList,1000)
                else
                    table.insert(myList,999)
                end
            end
            table.insert(myList, v)
            local str = DataChatFace.data_new_face[v].title
            table.insert(titleList,str)
            nowNum = i - nowNum
        else
            table.insert(myList, v)
        end
        lastDistance = DataChatFace.data_new_face[v].isdistance
    end
    local total = 0
    local now = 0
    local totalDistance = 0

    for i,id in ipairs(myList) do
        if id < 1000 then
            local tab = self.faceList[i]
            if tab == nil then
                tab = {}
                tab.gameObject = GameObject.Instantiate(self.faceCloner)
                tab.gameObject.name = "face" .. tostring(i)
                tab.transform = tab.gameObject.transform
                tab.face = FaceItem.New(tab.transform)
                tab.select = tab.transform:Find("Select").gameObject
                tab.select:SetActive(false)
                tab.face:Animate(false)
                local j = i
                tab.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickFace(j) end)
                if id ~= 999 then
                    self.faceList[i] = tab
                end
            end

            self.faceGrid:AddCell(tab.gameObject)
            if id == 999 then
                tab.gameObject:SetActive(false)
            else
                if index == 1 then
                    if id == 114 or id == 123 or id == 124 or id == 125 or id == 126 or id == 128 or id == 135 then
                        if ChatManager.Instance.miniFaceDic[id] ~= nil then
                            tab.face:Show(id, Vector2(-5, -20), false, Vector2(75, 40))
                        else
                            tab.face:Show(id, Vector2(11,-16), false, Vector2(44, 44))
                        end
                    else
                        tab.face:Show(id, Vector2(11, -16), false, Vector2(44, 44))
                    end
                    tab.face:SetGrey(false)
                    tab.face:SetSprite(ChatManager.Instance.miniFaceDic[id] == nil)

                    if ChatManager.Instance.miniFaceDic[id] ~= nil then
                        now = now + 1
                    end
                     tab.gameObject.transform.anchoredPosition = Vector2(tab.gameObject.transform.anchoredPosition.x,tab.gameObject.transform.anchoredPosition.y + totalDistance * 32)
                else
                    tab.face.size = Vector2(56, 56)
                    tab.face:Show(id, Vector2(6, -10))
                    tab.face:SetSprite(false)
                    tab.face:SetGrey(ChatManager.Instance.bigFaceDic[id] == nil)

                    if ChatManager.Instance.bigFaceDic[id] ~= nil then
                        now = now + 1
                    end
                end

                total = total + 1
            end
        elseif id == 1000 then

            local tab = self.titleBgList[i]
            if tab == nil then
                tab = {}
                tab.gameObject = GameObject.Instantiate(self.titleBg)
                tab.gameObject.name = "titleBg" .. totalDistance
                tab.gameObject.transform:Find("Title"):GetComponent(Text).text = titleList[titleIndex]
                titleIndex = titleIndex + 1
                tab.gameObject:SetActive(true)
                self.titleBgList[i] = tab
            end
            self.faceGrid:AddCell(tab.gameObject)
            tab.gameObject.transform.sizeDelta = Vector2(260,30)
            tab.gameObject.transform.anchoredPosition = Vector2(-20,tab.gameObject.transform.anchoredPosition.y + totalDistance * 32)
            totalDistance = totalDistance + 1
        end

    end

    for i=#myList+1,#self.faceList do
        self.faceList[i].gameObject:SetActive(false)
    end
    self.faceCloner:SetActive(false)
    if index == 1 then
        self.leftBotomText.text = string.format("小表情收集度：<color='#ffff00'>%s</color>/%s",now,total)
        self.textExt.contentTxt.gameObject:SetActive(false)
        self.noticeButton.gameObject:SetActive(false)
    elseif index == 2 then
        self.leftBotomText.text = string.format("大表情收集度：<color='#ffff00'>%s</color>/%s",now,total)
        self.textExt.contentTxt.gameObject:SetActive(true)
        self.noticeButton.gameObject:SetActive(true)
        self.textExt:SetData(string.format(TI18N("拥有包子币{assets_2,22454}:{string_2, #00ff00, %s}"), BackpackManager.Instance:GetItemCount(22454)))
    end
end

function FaceWindow:ClickFace(index)
    if self.lastFaceIndex ~= nil then
        self.faceList[self.lastFaceIndex].select:SetActive(false)
        self.faceList[self.lastFaceIndex].face:Animate(false)
    end
    self.faceList[index].select:SetActive(true)
    self.faceList[index].face:Animate(true)
    self.lastFaceIndex = index

    if self.curHorIndex == 2 then
        self:ShowTipsPanel(index)
    end
end

function FaceWindow:ShowTipsPanel(index)
    if self.tipsPanel == nil then
        self.tipsPanel = FaceTipsPanel.New(self.model, self.tipsObj)
    end

    if self.faceList[index] ~= nil then
        self.tipsPanel:Show({self.faceList[index].face.faceId,self.faceList[index].gameObject})
    end
end

function FaceWindow:OnGetNewFace(args)
    local id = args
    local index = 1
    for _,v in pairs(DataChatFace.data_new_face) do
        if v.id == id then
            index = v.type
            break
        end
    end
    -- self:HorChangeTab(index)
    if index == 4 then
            self.horTabGroup:ChangeTab(1)
    else
            self.horTabGroup:ChangeTab(index)
    end
end

function FaceWindow:OnUpdateItem()
    self.textExt:SetData(string.format(TI18N("拥有包子币{assets_2,22454}:{string_2, #00ff00, %s}"), BackpackManager.Instance:GetItemCount(22454)))
end


function FaceWindow:Layout()
     for i,v in ipairs(self.classList) do
      if v ~= nil then
         self.lastGroupIndex = v.group_index
         if self.tabObjList[i] == nil then
            local obj = GameObject.Instantiate(self.tabTemplate)
            self.tabObjList[i] = obj
            self.tabLayout:AddCell(obj)
         end
         self.tabObjList[i].name = tostring(i)
         local t = self.tabObjList[i].transform
         local content = v.name
         self.tabRedPoint[v.id] = t:Find("RedPoint").gameObject
         local txt = t:Find("Text"):GetComponent(Text)
         txt.text = content
         self.tabObjList[i]:GetComponent(Button).onClick:RemoveAllListeners()
         self.tabObjList[i]:GetComponent(Button).onClick:AddListener(function() self:SwitchTabs(v.id,self.curHorIndex) end)

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

         self.txtList[v.id] = txt
        end
    end

    if #self.tabObjList > #self.classList then
        for i=#self.classList + 1,#self.tabObjList do
            self.tabObjList[i].gameObject:SetActive(false)
        end
    end
end


function FaceWindow:SwitchTabs(indexId,topIndexId)

    if self.currentTabIndexId == indexId and self.isInit == true  then
        return
    end
    self.isInit = true
    self.txtList[self.currentTabIndexId].text = string.format(ColorHelper.TabButton2NormalStr, self.classList[self.currentTabIndexId].name)
    self.txtList[indexId].text = string.format(ColorHelper.TabButton2SelectStr, self.classList[indexId].name)
    self:EnableTab(self.currentTabIndexId, false)
    self:EnableTab(indexId, true)
    self:ChangePanel(indexId,topIndexId)
    self.currentTabIndexId = indexId
end

function FaceWindow:EnableTab(main, bool)

    if bool == true then
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Select")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Select")
    else
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Normal")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Normal")
    end
end

function FaceWindow:ChangePanel(indexId,topIndexId)

    -- if self.currentTabIndexId ~= 1 and self.currentTabIndexId ~= 2 then
        if self.panelList[self.currentTabIndexId] ~= nil then
                self.panelList[self.currentTabIndexId]:Hiden()
        end
    -- end

    local panelId = nil
    self.currentTabIndexId = indexId
    if tonumber(indexId) == 1 or tonumber(indexId) == 2 then
            if self.myPanelId == nil then
                    self.myPanelId = FaceMergePanel.New(self.model, self.mergeObj,self.assetWrapper,self)
            end
            self.myPanelId:Show(topIndexId)
    else
        if self.myPanelId ~= nil then
                self.myPanelId:Hiden()
        end

        if self.panelList[self.currentTabIndexId] == nil then

            -- panelId = FaceMergePanel.New(self.model, self.mergeObj,self.assetWrapper,self)
            self.panelList[indexId] = panelId
        end
        if self.panelList[indexId] ~= nil then
            self.panelList[indexId]:Show()
        end
    end

    if topIndexId == 3 then
        self.horTabGroup:ChangeTab(1)
    else
        self.horTabGroup:ChangeTab(topIndexId)
    end
end
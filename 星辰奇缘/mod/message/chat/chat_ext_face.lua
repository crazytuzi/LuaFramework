-- --------------------------------
-- 聊天扩展界面--标签
-- --------------------------------
ChatExtFace = ChatExtFace or BaseClass(ChatExtBase)

function ChatExtFace:__init(gameObject, type, otherOption,isActiveBig)
    self.gameObject = gameObject
    self.gameObject.name = "ChatExtFace"
    self.otherOption = otherOption

    self.tabInfoList = {{str = TI18N("普通表情"), beginIndex = 1}, {str = TI18N("特权表情"), beginIndex = 2}, {str = TI18N("新春表情"), beginIndex = 3},{str = TI18N("大表情"), beginIndex = 4}}

    self.itemTab = {}
    self.currentPageCount = 1
    self.pageTab = {}
    self.pageBaseList = {}
    self.pageBigList = {}
    self.tabList = {}
    self.type = type
    self.isActiveBig = isActiveBig
    self:InitPanel()


    self.isInit = false
    -- 特权表情从第几页开始
    self.specialPage = 0

    -- 预览列表
    self.previewList = {}

    self.bigFaceNum = 10
    -- self.listener = function()
    --     if self.isInit then
    --         self:Refresh(self:GetFaceList())
    --     end
    -- end
    -- EventMgr.Instance:AddListener(event_name.privilege_lev_change, self.listener)
    self.faceUpdateListener = function() self.faceUpdateMark = true end
    EventMgr.Instance:AddListener(event_name.new_face_update, self.faceUpdateListener)

    self.updateRechargeListener = function()
        if not BaseUtils.isnull(self.gameObject) then
            self:Refresh(self:GetFaceList())
        end
    end
    PrivilegeManager.Instance.updateRecharge:AddListener(self.updateRechargeListener)
end

-- 重载
function ChatExtFace:InitPanel()
    self.transform = self.gameObject.transform

    self.container = self.transform:Find("Container").gameObject
    self.rect = self.container:GetComponent(RectTransform)
    self.pageBase = self.container.transform:Find("ItemPage").gameObject
    self.bigFaceBase = self.container.transform:Find("BigFacePage").gameObject
    self.bigTab = self.transform:Find("TabGroup/Container/Big").gameObject

    self.tabGroup = TabGroup.New(self.transform:Find("TabGroup/Container").gameObject, function(index) self:ChangeTab(index) end, {openLevel = {0, 0, 0}, notAutoSelect = true, noCheckRepeat = false, perWidth = 124, perHeight = 40, isVertical = false, spacing = 5})
    self.tabGroupContainer = self.transform:Find("TabGroup/Container")

    self.pageBase:SetActive(false)
    self.bigFaceBase:SetActive(false)
    self.pageTab = {}

    self.transform:Find("TabGroup/Container/Mini/Select/Image").transform.anchoredPosition = Vector2(-37.9,5.5)
    self.transform:Find("TabGroup/Container/Mini/Select/Text").transform.anchoredPosition = Vector2(18.2,2)

    self.transform:Find("TabGroup/Container/Special/Select/Image").transform.anchoredPosition = Vector2(-37.9,5.5)
    self.transform:Find("TabGroup/Container/Special/Select/Text").transform.anchoredPosition = Vector2(18.2,2)

    self.transform:Find("TabGroup/Container/Big/Select/Image").transform.anchoredPosition = Vector2(-37.9,5.5)
    self.transform:Find("TabGroup/Container/Big/Select/Text").transform.anchoredPosition = Vector2(18.2,2)


    self.transform:Find("TabGroup/Container/New/Select/Image").transform.anchoredPosition = Vector2(-37.9,5.5)
    self.transform:Find("TabGroup/Container/New/Select/Text").transform.anchoredPosition = Vector2(18.2,2)

    if self.isActiveBig == false then
        self.bigTab.gameObject:SetActive(false)
    else
        self.bigTab.gameObject:SetActive(true)
    end

    -- local pageTransform = self.pageBase.transform
    -- self:GetItem(pageTransform)
end

function ChatExtFace:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    if not self.isInit then
        self.isInit = true
        self:InitPage(self:GetFaceList(), 560, 24)
        self:ReloadTabs()
    elseif self.faceUpdateMark then
        self.faceUpdateMark = false
        -- self:InitPage(self:GetFaceList(), 560, 24)
        self:Refresh(self:GetFaceList())
    end

    if self.mainPanel ~= nil then
        self.mainPanel:UpdateToggleShow(self.pageMax)
        self.mainPanel:UpdateToggleIndex(self.currentPageCount)
    end

    self.tabGroup:ChangeTab(1)
end

function ChatExtFace:GetItems(page, count)
    local itemList = {}
    for i = 1, count do
        local item = page.transform:GetChild(i - 1)
        local tab = {}
        tab["gameObject"] = item.gameObject
        tab["transform"] = item.transform
        tab["rect"] = item.gameObject:GetComponent(RectTransform)
        tab["button"] = item.gameObject:GetComponent(CustomButton)
        tab["face"] = FaceItem.New(item.transform)
        tab["preview"] = page.preview
        table.insert(itemList, tab)
        tab["button"].onClick:RemoveAllListeners()
        tab["button"].onClick:AddListener(function() self:ClickBtn(tab) end)
        tab["button"].onDown:RemoveAllListeners()
        tab["button"].onDown:AddListener(function() self:DownBtn(tab) end)
        tab["button"].onUp:RemoveAllListeners()
        tab["button"].onUp:AddListener(function() self:UpBtn(tab) end)
    end
    return itemList
end

function ChatExtFace:Refresh(list)
    if BaseUtils.isnull(self.gameObject) then
        return
    end

    local normalList = list[1] or {}
    local specialList = list[2] or {}
    local bigList = list[3] or {}
    local normalNewList = list[4] or {}
    local newYearList = list[5] or {}
    local count = 24
    local pageCount = 0
    for i,id in ipairs(normalList) do
        if i % 24 == 1 then
            pageCount = pageCount + 1
        end
        local tab = self.pageBaseList[pageCount].itemList[(i - 1) % 24 + 1]
        if id > 0 then
            tab["face"]:Show(id, Vector2(12, -15))
            tab["face"]:SetSprite(DataChatFace.data_new_face[id] ~= nil and ChatManager.Instance.miniFaceDic[id] == nil)
            tab["match"] = string.format("%%#%s", id)
            tab["append"] = string.format("#%s", id)
            tab["send"] = string.format("#%s", id)
            tab["gameObject"]:SetActive(true)
        else
            tab["gameObject"]:SetActive(false)
        end
        count = count % 24 + 1
    end
    -- 多出来的隐藏
    for i = count + 1, 24 do
        self.pageBaseList[pageCount].itemList[i]["gameObject"]:SetActive(false)
    end

    count = 24
    for i,id in ipairs(normalNewList) do
        if i % 24 == 1 then
            pageCount = pageCount + 1
        end
        local tab = self.pageBaseList[pageCount].itemList[(i - 1) % 24 + 1]
        if id > 0 then

            tab["face"]:Show(id, Vector2(12, -15))
            tab["face"]:SetSprite(DataChatFace.data_new_face[id] ~= nil and ChatManager.Instance.miniFaceDic[id] == nil)
            tab["match"] = string.format("%%#%s", id)
            tab["append"] = string.format("#%s", id)
            tab["send"] = string.format("#%s", id)
            tab["gameObject"]:SetActive(true)
        else
            tab["gameObject"]:SetActive(false)
        end
        count = count % 24 + 1
    end
    -- 多出来的隐藏
    for i = count + 1, 24 do
        self.pageBaseList[pageCount].itemList[i]["gameObject"]:SetActive(false)
    end


    local _type = PrivilegeManager.Instance:GetValueByType(PrivilegeEumn.Type.specialFacePack)

    local specialFaceMark = DataChatFace.data_get_chat_face_privilege[faceId] ~= nil and _type < DataChatFace.data_get_chat_face_privilege[faceId].privilege

    count = 24
    for i,id in ipairs(specialList) do
        if i % 24 == 1 then
            pageCount = pageCount + 1
        end
        local tab = self.pageBaseList[pageCount].itemList[(i - 1) % 24 + 1]
        if id > 0 then
            tab["face"]:Show(id, Vector2(12, -15))
            tab["face"]:SetGrey(false)
            tab["match"] = string.format("%%#%s", id)
            tab["append"] = string.format("#%s", id)
            tab["send"] = string.format("#%s", id)
            tab["gameObject"]:SetActive(true)
        else
            tab["gameObject"]:SetActive(false)
        end
        count = count % 24 + 1
    end

    -- 多出来的隐藏
    for i = count + 1, self.bigFaceNum do
        self.pageBigList[pageCount].itemList[i]["gameObject"]:SetActive(false)
    end

    BaseUtils.dump(newYearList,"sdkjfksdjfklsdjfsdjfsdjfksl")
    count = 24
    for i,id in ipairs(newYearList) do
        if i % 24 == 1 then
            pageCount = pageCount + 1
        end
        local tab = self.pageBaseList[pageCount].itemList[(i - 1) % 24 + 1]
        if id > 0 then
            tab["face"]:Show(id, Vector2(12, -15))
            tab["face"]:SetSprite(DataChatFace.data_new_face[id] ~= nil and ChatManager.Instance.miniFaceDic[id] == nil)
            tab["match"] = string.format("%%#%s", id)
            tab["append"] = string.format("#%s", id)
            tab["send"] = string.format("#%s", id)
            tab["gameObject"]:SetActive(true)
        else
            tab["gameObject"]:SetActive(false)
        end
        count = count % 24 + 1
    end
    -- 多出来的隐藏
    for i = count + 1, 24 do
        self.pageBaseList[pageCount].itemList[i]["gameObject"]:SetActive(false)
    end



    pageCount = 0
    count = self.bigFaceNum
    for i,id in ipairs(bigList) do
        if i % self.bigFaceNum == 1 then
            pageCount = pageCount + 1
        end
        local tab = self.pageBigList[pageCount].itemList[(i - 1) % self.bigFaceNum + 1]
        if id > 0 then
            tab["face"]:Show(id, Vector2(0, -5))
            tab["face"]:SetSprite(DataChatFace.data_new_face[id] ~= nil and ChatManager.Instance.bigFaceDic[id] == nil)
            tab["match"] = string.format("%%#%s", id)
            tab["append"] = string.format("#%s", id)
            tab["send"] = string.format("#%s", id)
            tab["gameObject"]:SetActive(true)
        else
            tab["gameObject"]:SetActive(false)
        end
        count = count % self.bigFaceNum + 1
    end
    -- self:InitPreview()
    -- self:ShowSpecial()
end

function ChatExtFace:InitPreview()
    self.previewList = {}
    for i,obj in ipairs(self.pageTab) do
        local dat = {}
        dat.gameObject = self.pageTab[i].transform:Find("Preview").gameObject
        dat.parent = dat.gameObject.transform:Find("Image/Face").transform
        dat.faceObj = nil
        dat.faceId = 0
        dat.rect = dat.gameObject:GetComponent(RectTransform)
        dat.rect.anchorMin = Vector2(0, 1)
        dat.rect.anchorMax = Vector2(0, 1)
        dat.rect.pivot = Vector2(1, 0)
        table.insert(self.previewList, dat)
    end
end

function ChatExtFace:GetPreview(pageTransform)
    local dat = {}
    dat.gameObject = pageTransform:Find("Preview").gameObject
    dat.parent = dat.gameObject.transform:Find("Image/Face").transform
    dat.imgBg = dat.gameObject.transform:Find("Image").transform
    dat.faceObj = nil
    dat.faceId = 0
    dat.rect = dat.gameObject:GetComponent(RectTransform)
    dat.rect.anchorMin = Vector2(0, 1)
    dat.rect.anchorMax = Vector2(0, 1)
    dat.rect.pivot = Vector2(1, 0)
    return dat
end

-- 检查是否显示特权
function ChatExtFace:ShowSpecial()
    for i,v in ipairs(self.pageTab) do
        v.transform:Find("Special").gameObject:SetActive(false)
    end

    if self.specialPage > 0 then
        local len = self.pageMax - self.specialPage
        for i = self.specialPage, self.specialPage + len do
            self.pageTab[i].transform:Find("Special").gameObject:SetActive(true)
        end
    end
end

function ChatExtFace:DownBtn(tab)
    local ismask = tab["face"].mask
    if ismask == true then
        return
    end
    -- local tab = self.itemTab[index]
    local w = tab["face"].width
    local h = tab["face"].height
    local faceObj = tab["face"].gameObject
    local rect = tab["rect"]
    if BaseUtils.is_null(faceObj) then
        return
    end

    -- local page = math.ceil(index / 24)
    local dat = tab.preview
    if dat == nil then
        return
    end

    if dat.faceId ~= tab["face"].faceId then
        if not BaseUtils.is_null(dat.faceObj) then
            GameObject.DestroyImmediate(dat.faceObj)
            dat.faceObj = nil
        end

        dat.faceObj = GameObject.Instantiate(faceObj)
        dat.faceObj:SetActive(true)
        dat.faceObj.transform:SetParent(dat.parent)
        dat.faceObj.transform.localScale = Vector3.one
        dat.faceObj.transform.localPosition = Vector3.zero
        local r = dat.faceObj:GetComponent(RectTransform)
        r.anchoredPosition = Vector2.zero
        r.anchorMin = Vector2(0.5, 0.5)
        r.anchorMax = Vector2(0.5, 0.5)
        r.pivot = Vector2(0.5, 0.5)
        r.sizeDelta = Vector2(w, h)
    end
    dat.rect.anchoredPosition = rect.anchoredPosition + Vector2(7, 20)
    dat.imgBg.transform.sizeDelta = Vector2(tab["face"].width + 40,tab["face"].height + 40)
    dat.gameObject:SetActive(true)
end

function ChatExtFace:UpBtn(tab, index)
    local ismask = tab["face"].mask
    if ismask == true then
        return
    end
    -- local tab = self.itemTab[index]
    local faceObj = tab["face"].gameObject
    local rect = tab["face"].rect
    if BaseUtils.is_null(faceObj) then
        return
    end

    -- local page = math.ceil(index / 24)
    -- local dat = self.previewList[page]
    local dat = tab.preview
    if dat == nil then
        return
    end
    dat.gameObject:SetActive(false)
end

function ChatExtFace:ClickBtn(tab)
    -- local tab = self.itemTab[index]

    -- if true then
    --     ChatManager.Instance:SendMsg(ChatManager.Instance:CurrentChannel(), )
    --     return
    -- end

    local faceId = tab["face"].faceId
    
        --峡谷准备区屏蔽大表情
    if DataChatFace.data_new_face[faceId] ~= nil and DataChatFace.data_new_face[faceId].type == FaceEumn.FaceType.Big and
        ChatManager.Instance.model.chatWindow ~= nil and
            ChatManager.Instance.model.chatWindow.currentChannel ~= nil and
                ChatManager.Instance.model.chatWindow.currentChannel.channel == MsgEumn.ChatChannel.Scene and 
                    RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady 
                        then 
                        NoticeManager.Instance:FloatTipsByString(TI18N("峡谷备战区，大表情将影响备战哟{face_1,2}"))
                        return
    end

    local _type = PrivilegeManager.Instance:GetValueByType(PrivilegeEumn.Type.specialFacePack)
    if DataChatFace.data_get_chat_face_privilege[faceId] ~= nil and _type < DataChatFace.data_get_chat_face_privilege[faceId].privilege then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("累充{assets_1,90002,1000}可获得使用{string_2,#ffff00,特权表情包}福利")
        data.sureLabel = TI18N("立刻充值")
        data.cancelLabel = TI18N("稍后再充")
        data.showSureEffect = true
        data.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3,1}) end
        NoticeManager.Instance:ConfirmTips(data)
        return
    elseif DataChatFace.data_new_face[faceId] ~= nil then



           --创建角色小描述-- 大表情直接发送
            if DataChatFace.data_new_face[faceId].type == FaceEumn.FaceType.Big then
                if ChatManager.Instance.bigFaceDic[faceId] ~= nil then
                    if self.type == MsgEumn.ExtPanelType.Chat then
                        ChatManager.Instance:Send10400(ChatManager.Instance:CurrentChannel(), string.format("{face_3, %d}", faceId))
                    else
                        FaceManager.Instance.OnBigFaceClick:Fire({ type = self.type, message = string.format("{face_3, %d}", faceId) } )
                    end
                else
                    -- NoticeManager.Instance:FloatTipsByString(TI18N("你尚未开启该表情"))
                    self:ConfirmFace(faceId)
                    return
                end
                return
            else
                -- 小表情需要合成
                if ChatManager.Instance.miniFaceDic[faceId] == nil then
                    -- NoticeManager.Instance:FloatTipsByString(TI18N("你尚未开启该表情"))
                    if DataChatFace.data_new_face[faceId].isdistance == 1 then
                        local data = NoticeConfirmData.New()
                        data.type = ConfirmData.Style.Sure
                        data.content = DataChatFace.data_new_face[faceId].getdese
                        data.showClose = true
                        data.sureLabel = TI18N("前往收藏")
                        data.sureCallback = function ()
                            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.wing_book)
                        end
                        NoticeManager.Instance:ConfirmTips(data)
                        return
                    elseif DataChatFace.data_new_face[faceId].isdistance ~= 1 then
                        self:ConfirmFace(faceId)
                        return
                    end
                end
            end
    end

    local str = tab["append"]
    if str ~= nil and str ~= "" then
        local element = {}
        element.type = MsgEumn.AppendElementType.Face
        element.showString = str
        element.sendString = tab["send"]
        element.matchString = tab["match"]
        element.data = faceId
        ChatManager.Instance:AppendInputElement(element, self.type, self.otherOption)
    end
end

function ChatExtFace:GetFaceList()
    local special = {}--特权列表
    local normalList = {}
    local normalNewList = {}
    local bigList = {}
    local newYearList = {}

    -- for i = 1, DataChatFace.data_get_chat_face_privilege_length do
    for _, cfg_data in pairs(DataChatFace.data_get_chat_face_privilege) do
        if cfg_data ~= nil then
            if cfg_data.privilege > 0 then
                table.insert(special, cfg_data.id)
            else
                table.insert(normalList, cfg_data.id)
            end
        end
    end



    -- 加入大表情，到新的一页开始
    for _,cfg_data in pairs(DataChatFace.data_new_face) do
        if cfg_data ~= nil then
            if cfg_data.isdistance ~= 1  then
                if cfg_data.type == FaceEumn.FaceType.Big then
                    table.insert(bigList, cfg_data.id)
                else
                    if cfg_data.isdistance ~= 2 then
                        table.insert(normalNewList, cfg_data.id)
                    elseif cfg_data.isdistance == 2 then
                        table.insert(newYearList, cfg_data.id)
                    end

                end
            elseif cfg_data.isdistance == 1 then
                table.insert(normalList,cfg_data.id)
            end
        end
    end

    self.normalPage = math.ceil(#normalList / 24)
    self.specialPage = math.ceil(#special / 24)
    self.normalNewPage = math.ceil(#normalNewList / 24)
    self.bigPage = math.ceil(#bigList / self.bigFaceNum)
    self.newYearPage = math.ceil(#newYearList / 24)

    table.sort(newYearList, function(id1,id2) return id1 < id2 end)
    table.sort(normalList, function(id1,id2) return id1 < id2 end)
    table.sort(special, function(id1,id2) return id1 < id2 end)
    table.sort(bigList, function(id1,id2) return id1 < id2 end)
    table.sort(normalNewList,function(id1,id2) return id1 < id2 end)

    return {normalList, special, bigList,normalNewList,newYearList}
end

function ChatExtFace:InitPage(list, width)
    local normalList = list[1] or {}
    local specialList = list[2] or {}
    local bigList = list[3] or {}
    local normalNewList = list[4] or {}
    local newYearList = list[5] or {}

    local pageLength = #normalList + #specialList + #bigList + #newYearList

    local baseIndex = 1
    local bigIndex = 1
    local index = 1

    local normalPageCount = math.ceil(#normalList / 24)
    if normalPageCount > 0 then
        self.tabInfoList[1].beginIndex = index
        for i=1,normalPageCount do
            local basePage = self.pageBaseList[baseIndex]
            if basePage == nil then
                basePage = {}
                basePage.gameObject = GameObject.Instantiate(self.pageBase)
                basePage.transform = basePage.gameObject.transform
                basePage.transform:SetParent(self.container.transform)
                basePage.transform.localScale = Vector3.one
                basePage.preview = self:GetPreview(basePage.transform)
                basePage.itemList = self:GetItems(basePage, 24)
                basePage.SetActive = function(page, bool) page.gameObject:SetActive(bool) end
                self.pageBaseList[#self.pageBaseList + 1] = basePage
            end
            basePage.transform.localPosition = Vector3((index - 1) * width, 0, 0)
            self.pageTab[index] = basePage
            basePage.gameObject:SetActive(true)
            baseIndex = baseIndex + 1
            index = index + 1
        end

    end

    local normalNewPageCount = math.ceil(#normalNewList / 24)
    if normalNewPageCount > 0 then
        for i= 1,normalNewPageCount do
            local basePage = self.pageBaseList[baseIndex]
            if basePage == nil then
                basePage = {}
                basePage.gameObject = GameObject.Instantiate(self.pageBase)
                basePage.transform = basePage.gameObject.transform
                basePage.transform:SetParent(self.container.transform)
                basePage.transform.localScale = Vector3.one
                basePage.preview = self:GetPreview(basePage.transform)
                basePage.itemList = self:GetItems(basePage, 24)
                basePage.SetActive = function(page, bool) page.gameObject:SetActive(bool) end
                self.pageBaseList[#self.pageBaseList + 1] = basePage
            end
            basePage.transform.localPosition = Vector3((index - 1) * width, 0, 0)
            self.pageTab[index] = basePage
            basePage.gameObject:SetActive(true)
            baseIndex = baseIndex + 1
            index = index + 1
        end
    end

    if normalNewPageCount + normalPageCount > 0 then
        self.tabGroup.openLevel[1] = 0
    else
        self.tabGroup.openLevel[1] = 255
    end


    local specialPageCount = math.ceil(#specialList / 24)
    if specialPageCount > 0 then
        self.tabInfoList[2].beginIndex = index
        for i=1,specialPageCount do
            local basePage = self.pageBaseList[baseIndex]
            if basePage == nil then
                basePage = {}
                basePage.gameObject = GameObject.Instantiate(self.pageBase)
                basePage.transform = basePage.gameObject.transform
                basePage.transform:SetParent(self.container.transform)
                basePage.transform.localScale = Vector3.one
                basePage.preview = self:GetPreview(basePage.transform)
                basePage.itemList = self:GetItems(basePage, 24)
                basePage.SetActive = function(page, bool) page.gameObject:SetActive(bool) end
                self.pageBaseList[#self.pageBaseList + 1] = basePage
            end
            basePage.transform.localPosition = Vector3((index - 1) * width, 0, 0)
            self.pageTab[index] = basePage
            basePage.gameObject:SetActive(true)
            baseIndex = baseIndex + 1
            index = index + 1
        end
        self.tabGroup.openLevel[2] = 0
    else
        self.tabGroup.openLevel[2] = 255
    end

    for i=baseIndex,#self.pageBaseList do
        self.pageBaseList[i].gameObject:SetActive(false)
    end

    local newYearPageCount = math.ceil(#newYearList / 24)
    if newYearPageCount > 0 then
        self.tabInfoList[3].beginIndex = index
        for i= 1,newYearPageCount do
            local basePage = self.pageBaseList[baseIndex]
            if basePage == nil then
                basePage = {}
                basePage.gameObject = GameObject.Instantiate(self.pageBase)
                basePage.transform = basePage.gameObject.transform
                basePage.transform:SetParent(self.container.transform)
                basePage.transform.localScale = Vector3.one
                basePage.preview = self:GetPreview(basePage.transform)
                basePage.itemList = self:GetItems(basePage, 24)
                basePage.SetActive = function(page, bool) page.gameObject:SetActive(bool) end
                self.pageBaseList[#self.pageBaseList + 1] = basePage
            end
            basePage.transform.localPosition = Vector3((index - 1) * width, 0, 0)
            self.pageTab[index] = basePage
            basePage.gameObject:SetActive(true)
            baseIndex = baseIndex + 1
            index = index + 1
        end
        self.tabGroup.openLevel[3] = 0
    else
        self.tabGroup.openLevel[3] = 255
    end

    local bigCount = math.ceil(#bigList / self.bigFaceNum)
    if bigCount > 0 then
        self.tabInfoList[4].beginIndex = index
        for i=1,bigCount do
            local bigPage = self.pageBigList[bigIndex]
            if bigPage == nil then
                bigPage = {}
                bigPage.gameObject = GameObject.Instantiate(self.bigFaceBase)
                bigPage.transform = bigPage.gameObject.transform
                bigPage.transform:SetParent(self.container.transform)
                bigPage.transform.localScale = Vector3.one
                bigPage.preview = self:GetPreview(bigPage.transform)
                bigPage.itemList = self:GetItems(bigPage, self.bigFaceNum)
                bigPage.SetActive = function(page, bool) page.gameObject:SetActive(bool) end
                self.pageBigList[#self.pageBigList + 1] = bigPage
            end
            bigPage.transform.localPosition = Vector3((index - 1) * width, 0, 0)
            self.pageTab[index] = bigPage
            bigPage.gameObject:SetActive(true)
            bigIndex = bigIndex + 1
            index = index + 1
        end
        self.tabGroup.openLevel[4] = 0
    else
        self.tabGroup.openLevel[4] = 255
    end

    for i=bigIndex,#self.pageBigList do
        self.pageBigList[i].gameObject:SetActive(false)
    end
    if self.isActiveBig == false then
        index = index - 1
        self.bigIndex = index
    end

    self.container.transform.sizeDelta = Vector2((index - 1) * width, 200)

    if self.tabbedPanel == nil then

        self.tabbedPanel = TabbedPanel.New(self.gameObject, index - 1, width)
        self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnMoveEnd(currentPage, direction) self:OnMoveEndFace(currentPage) end)
    else
        self.tabbedPanel:SetPageCount(index - 1)
    end

    self.pageMax = index - 1

    self:Refresh(list)
end

function ChatExtFace:ReloadTabs()
    for i,v in ipairs(self.tabGroup.buttonTab) do
        v.normalTxt.text = self.tabInfoList[i].str
        v.selectTxt.text = self.tabInfoList[i].str
    end
end

function ChatExtFace:ChangeTab(index)
    self.tabbedPanel:TurnPage(self.tabInfoList[index].beginIndex)
    self:OnMoveEnd(self.tabInfoList[index].beginIndex)
end

function ChatExtFace:OnMoveEndFace(currentPage)
    if self.tabGroup.currentIndex ~= 0 then
        self.tabGroup:UnSelect(self.tabGroup.currentIndex)
    end

    local index = 1
    for i=#self.tabInfoList,1,-1 do
        if RoleManager.Instance.RoleData.lev >= (self.tabGroup.openLevel[i] or 0) and self.tabInfoList[i].beginIndex <= currentPage then
            index = i
            break
        end
    end
    self.tabGroup.currentIndex = index
    self.tabGroup:Select(self.tabGroup.currentIndex)
end

function ChatExtFace:ConfirmFace(faceId)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Sure
    data.content = TI18N("该表情需要<color='#ffff00'>合成</color>后才可使用哟{face_1, 22}快去合成获得吧")
    data.showClose = true
    data.sureLabel = TI18N("前往合成")
    if DataChatFace.data_new_face[faceId].type == FaceEumn.FaceType.Big then
        data.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.face_merge, {1,2}) end
    else
            if DataChatFace.data_new_face[faceId].type ~= 4 then
                data.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.face_merge, {1,1}) end
            elseif DataChatFace.data_new_face[faceId].type == 4 then
                data.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.face_merge, {1,3}) end
            end
    end
    NoticeManager.Instance:ConfirmTips(data)
end


function ChatExtFace:OnMoveEnd(currentPage, direction)
    if self.pageTab[currentPage - 2] ~= nil then
        self.pageTab[currentPage - 2]:SetActive(false)
    end
    if self.pageTab[currentPage - 1] ~= nil then
        self.pageTab[currentPage - 1]:SetActive(true)
    end
    if self.pageTab[currentPage] ~= nil then
        self.pageTab[currentPage]:SetActive(true)
    end
    if self.pageTab[currentPage + 1] ~= nil then
        self.pageTab[currentPage + 1]:SetActive(true)
    end
    if self.pageTab[currentPage + 2] ~= nil then
        self.pageTab[currentPage + 2]:SetActive(false)
    end

    if self.isActiveBig == false then
        self.pageTab[self.bigIndex]:SetActive(false)
    end

    self.currentPageCount = currentPage
    if self.mainPanel ~= nil then
        if self.gameObject.name ~= "ChatExtHonor" then
            self.mainPanel:UpdateToggleIndex(currentPage)
        end
    end
end
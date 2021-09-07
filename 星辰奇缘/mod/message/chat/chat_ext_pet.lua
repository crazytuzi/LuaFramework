-- --------------------------------
-- 聊天扩展界面--宠物
-- --------------------------------
ChatExtPet = ChatExtPet or BaseClass(ChatExtBase)

function ChatExtPet:__init(gameObject, type)
    self.gameObject = gameObject
    self.gameObject.name = "ChatExtPet"

    self.itemTab = {}
    self.currentPageCount = 1
    self.pageTab = {}
    self.headLoaderList = {}
    self.type = type

    self:InitPanel()
end

function ChatExtPet:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    local list = {}
    for key,value in pairs(ChildrenManager.Instance.childData) do
        if value.stage == 3 then
            table.insert(list, { type = "Child", data = value })
        end
    end
    for key,value in pairs(RideManager.Instance.model.ridelist) do
        if value.live_status == 3 then
            table.insert(list, { type = "Ride", data = value })
        end
    end
    for key,value in pairs(PetManager.Instance:Get_PetList()) do
        table.insert(list, { type = "Pet", data = value })
    end
    self:InitPage(list, 560, 6)
    if self.mainPanel ~= nil then
        self.mainPanel:UpdateToggleShow(self.pageMax)
        self.mainPanel:UpdateToggleIndex(self.currentPageCount)
    end
end

function ChatExtPet:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function ChatExtPet:GetItem(pageTransform)
    for i = 1, 6 do
        local item = pageTransform:GetChild(i - 1)
        local tab = {}
        tab["gameObject"] = item.gameObject
        tab["transform"] = item.transform
        tab["button"] = item.gameObject:GetComponent(Button)
        tab["levTxt"] = item:Find("TxtLev"):GetComponent(Text)
        tab["nameTxt"] = item:Find("TxtName"):GetComponent(Text)
        tab["select"] = item:Find("Img_Select").gameObject
        tab["headImg"] = item:Find("ImgHeadCon/ImgHead"):GetComponent(Image)
        tab["headImg"].gameObject:SetActive(true)
        table.insert(self.itemTab, tab)
        local index = #self.itemTab
        tab["button"].onClick:RemoveAllListeners()
        tab["button"].onClick:AddListener(function() self:ClickBtn(index) end)
    end
end

function ChatExtPet:Refresh(list)
    local count = 0
    for i,data in ipairs(list) do
        count = i
        local tab = self.itemTab[i]
        if data.type == "Pet" then
            local pet = data.data
            tab["childData"] = nil
            tab["petData"] = pet
            tab["rideData"] = nil
            tab["nameTxt"].text = pet.name
            tab["levTxt"].text = string.format(TI18N("等级:%s"), pet.lev)

            local loaderId = tab["headImg"].gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(tab["headImg"].gameObject)
            end
            self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,pet.base.head_id)
            -- tab["headImg"].sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(pet.base.head_id), tostring(pet.base.head_id))
            tab["match"] = string.format("%%[%s%%]", pet.base.name)
            tab["append"] = string.format("[%s]", pet.base.name)
            tab["send"] = string.format("{pet_2,%s}", pet.base.id)
        elseif data.type == "Ride" then
            local ride = BaseUtils.copytab(data.data)
            local baseData = ride.base
            -- if ride.transformation_id ~= nil and ride.transformation_id ~= 0 then
            --     baseData = DataMount.data_ride_data[ride.transformation_id]
            -- end
            tab["childData"] = nil
            tab["rideData"] = ride
            tab["petData"] = nil
            tab["nameTxt"].text = baseData.name
            tab["levTxt"].text = string.format(TI18N("等级:%s"), ride.lev)
            tab["headImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.headride, tostring(baseData.head_id))
            tab["match"] = string.format("%%[%s%%]", baseData.name)
            tab["append"] = string.format("[%s]", baseData.name)


            tab["send"] = string.format("{ride_2,%s}", baseData.base_id)
        elseif data.type == "Child" then
            local child = BaseUtils.copytab(data.data)
            local name = string.format(TI18N("%s的子女"), self:GetChildName(child))

            tab["childData"] = child
            tab["rideData"] = nil
            tab["petData"] = nil
            tab["nameTxt"].text = name
            tab["levTxt"].text = string.format(TI18N("等级:%s"), child.lev)
            tab["headImg"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.childhead, string.format("%s%s", child.classes_type, child.sex))
            tab["match"] = string.format("%%[%s%%]", name)
            tab["append"] = string.format("[%s]", name)

            tab["send"] = string.format("{child_2,%s}", child.base_id)
        end
        tab["gameObject"]:SetActive(true)
    end
    -- 多出来的隐藏
    local allLen = #self.itemTab
    for i = count + 1, allLen do
        local tab = self.itemTab[i]
        tab["gameObject"]:SetActive(false)
    end
end

function ChatExtPet:ClickBtn(index)
    local tab = self.itemTab[index]
    local str = tab["append"]
    if str ~= nil and str ~= "" then
        local element = {}
        if tab["petData"] ~= nil then
            ChatManager.Instance:Send10406(MsgEumn.CacheType.Pet, tab.petData.id)

            element.type = MsgEumn.AppendElementType.Pet
            element.id = tab.petData.id
            element.base_id = tab.petData.base_id
            element.cacheType = MsgEumn.CacheType.Pet
            element.showString = str
            element.sendString = tab["send"]
            element.matchString = tab["match"]
        elseif tab["rideData"] ~= nil then
            ChatManager.Instance:Send10406(MsgEumn.CacheType.Ride, tab.rideData.index)

            element.type = MsgEumn.AppendElementType.Ride
            element.id = tab.rideData.index
            element.base_id = tab.rideData.base.base_id
            element.cacheType = MsgEumn.CacheType.Ride
            element.showString = str
            element.sendString = tab["send"]
            element.matchString = tab["match"]
        elseif tab["childData"] ~= nil then
            ChatManager.Instance:Send10420(tab.childData.child_id, tab.childData.platform, tab.childData.zone_id)

            element.type = MsgEumn.AppendElementType.Child
            element.id = tab.childData.index
            element.base_id = tab.childData.base_id
            element.cacheType = MsgEumn.CacheType.Child
            element.showString = str
            element.sendString = tab["send"]
            element.matchString = tab["match"]
            element.child_id = tab.childData.child_id
        end

        ChatManager.Instance:AppendInputElement(element, self.type)

        -- if self.type == MsgEumn.ExtPanelType.Chat then
        --     ChatManager.Instance.model:AppendInputElement(element)
        -- elseif self.type == MsgEumn.ExtPanelType.Friend then
        --     FriendManager.Instance.model:AppendInputElement(element)
        -- end
    end
end

function ChatExtPet:GetChildName(child)
    local name = RoleManager.Instance.RoleData.name
    if #child.parents > 1 then
        local parent = child.parents[1]
        local roleData = RoleManager.Instance.RoleData
        if parent.parent_id == roleData.lover_id and parent.p_platform == roleData.lover_platform and parent.p_zone_id == roleData.lover_zone_id then
            name = string.format(TI18N("%s和%s"), RoleManager.Instance.RoleData.name, roleData.lover_name)
        end

        parent = child.parents[2]
        if parent.parent_id == roleData.lover_id and parent.p_platform == roleData.lover_platform and parent.p_zone_id == roleData.lover_zone_id then
            name = string.format(TI18N("%s和%s"), RoleManager.Instance.RoleData.name, roleData.lover_name)
        end
    end

    return name
end
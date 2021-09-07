PetEvaluationWindow = PetEvaluationWindow or BaseClass(BaseWindow)

function PetEvaluationWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.petevaluation
    self.name = "PetEvaluationWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
       {file = AssetConfig.petevaluation_main,type = AssetType.Main},
       {file = "prefabs/effect/20166.unity3d", type = AssetType.Main},
       {file = AssetConfig.petevaluation_texture,type = AssetType.Dep},
       {file = AssetConfig.pet_textures, type = AssetType.Dep},
       {file = AssetConfig.guard_head, type = AssetType.Dep},
    --    {file = AssetConfig.basecompress_textures, type = AssetType.Dep}
    }
    self.winLinkType = WinLinkType.Link
    self.holdTime = 60
    self.Mgr = self.model.Mgr

    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    -- 记录下拉刷新的次数
    self.refreshTimes = 1

    -- 处理刷新文本的显示
    self.checking = false
    -- LuaTime
    self.checkTimer = nil
    -- 是否执行刷新
    self.refresh = false
    -- 用来区别是宠物还是守护
    self.typeIndex = nil
    -- 存放获得的评论对象数据
    self.currentTargetData = {}
    self.myCurrentEvaluation = nil    -- 存放我当前的评论
    self.appendTab = {}
    self.currentElement = nil
    self.specialIds = {}

    self.headlist = { }
    self.headLoaderList = {}
end

function PetEvaluationWindow:__delete()
    self.scrollRect.onValueChanged:RemoveAllListeners()
    PetEvaluationManager.Instance.noRefresh = false


    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
    if self.checkTimer ~= nil then
       LuaTimer.Delete(self.checkTimer)
       self.checkTimer = nil
    end

    if self.petEvaluationList ~=nil then
        self.petEvaluationList:DeleteMe()
    end



    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.model = nil
    self:AssetClearAll()
end


function PetEvaluationWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petevaluation_main))
    self.gameObject.name = self.name
    self.transform =self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    self.closeBtn = self.gameObject.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)
    self.tileText = self.gameObject.transform:Find("Main/Title/Text"):GetComponent(Text)
    self.MaskCon = self.transform:Find("Main/MainPanel/Mask")
    self.Container = self.transform:Find("Main/MainPanel/Mask/Container")
    self.BotLoading = self.transform:Find("Main/MainPanel/BotLoading").gameObject
    self.BotText = self.transform:Find("Main/MainPanel/BotLoading/I18NText"):GetComponent(Text)
    self.BotLoading:SetActive(false)
    -- 加载刷新动画
    local go = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20166.unity3d"))
    go.transform:SetParent(self.BotLoading.transform:Find("Image"))
    go.transform.localPosition = Vector3(0,0,-1000)
    go.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(go.transform, "UI")

    self.petEvaluationList = PetEvaluationListPanel.New(self.Container.gameObject,self,self.Boundary)
    self.scrollRect = self.transform:Find("Main/MainPanel/Mask"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function(val)
        self:OnScrollBoundary(val)
    end)

    self.HeadImage = self.transform:Find("Main/MainPanel/Head/ItemSlot/Image"):GetComponent(Image)
    self.ChangeBtn = self.transform:Find("Main/MainPanel/Head/ItemSlot/Replace"):GetComponent(Button)
    self.ChangeBtn.onClick:AddListener(function() self:OnReplaceBtnClick() end)
    self.TypeImage = self.transform:Find("Main/MainPanel/Head/TypeImage"):GetComponent(Image)
    self.NameText = self.transform:Find("Main/MainPanel/Head/PetName"):GetComponent(Text)

    self.EvaluationBtn = self.transform:Find("Main/MainPanel/EvaluationButton"):GetComponent(Button)
    self.EvaluationBtn.onClick:AddListener(function()
        self:RefreshEvaluationRequire()
    end)

    self.MoveBtn = self.transform:Find("Main/MainPanel/MoreButton"):GetComponent(Button)
    self.MoveBtn.onClick:AddListener(function()
        self:OpenChatShowPanel()
    end)
    -- self.MoveBtn.gameObject:SetActive(false)

    self.EvaluationInputField = self.transform:Find("Main/MainPanel/Input/InputField"):GetComponent(InputField)
    self.EvaluationInputField.textComponent  =  self.EvaluationInputField.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.EvaluationInputField.placeholder  =  self.EvaluationInputField.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)

    self.changePanel = self.transform:Find("Main/MainPanel/ChangePanel")
    self.changePanel.gameObject:SetActive(false)

    self.changePanel:Find("bgButton"):GetComponent(Button).onClick:AddListener(function()
        self.changePanel.gameObject:SetActive(false)
    end)

    self.changeMaskRect = self.changePanel:FindChild("HeadPanel/mask"):GetComponent(RectTransform)

    self.manualHeadContainer = self.changePanel:FindChild("HeadPanel/mask/HeadContainer").gameObject
    self.manualHeadObject = self.changePanel:FindChild("HeadPanel/mask/HeadContainer/PetHead").gameObject

    local btn
    btn = self.changePanel:FindChild("HeadPanel/TabButtonGroup/Button1"):GetComponent(Button)
    btn.onClick:AddListener(function() self:ShowPetHead_one() end)

    btn = self.changePanel:FindChild("HeadPanel/TabButtonGroup/Button2"):GetComponent(Button)
    btn.onClick:AddListener(function() self:ShowPetHead_two() end)
    -- 改变输入框的默认显示
    self:OnOpen()
end

--设置genre 宝宝 野生 等
function PetEvaluationWindow:SetTargetData(data,tp)

    -- 如果是宠物的话
    if tp == EvaluationTypeEumn.Type.Pet then
        self.TypeImage.sprite= self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (data.icon_id+1)))
        self.TypeImage:SetNativeSize()
        self.NameText.text = data.name

        if self.headLoader == nil then
          self.headLoader = SingleIconLoader.New(self.HeadImage.gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet, data.head_id)

       -- self.HeadImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(data.head_id), tostring(data.head_id))
    -- 如果是守护的话
   elseif tp == EvaluationTypeEumn.Type.ShouHu then
       self.TypeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" .. data.icon_id)
       self.TypeImage.transform.sizeDelta = Vector2(30,30)
       self.HeadImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(data.head_id))
       self.NameText.text = data.name
   end
end
-- 拉动改变
function PetEvaluationWindow:OnScrollBoundary(value)
    local Top = (value.y-1)*(self.scrollRect.content.sizeDelta.y - 340) + 50
    local Bot = Top - 340 -50

    self.petEvaluationList:OnScroll(Top,Bot)

    local space = 0
    if value.y <0 then
        space = value.y*math.max(340,self.scrollRect.content.sizeDelta.y -340) * -1
    end


    if space >5 and value.y<0 then
        if self.checking == false then
          self.BotText.text = TI18N("保持上拉将会刷新")
        end
         self.BotLoading:SetActive(true)

         if self.checkTimer == nil then

            self.checkTimer = LuaTimer.Add(400, function()
                if self.checking == false then
                    self.checking = true
                    self.BotText.text = TI18N("松开手指刷新")
                    self.refresh = true
                    self.checkTimer = nil
                end
            end)
        end
    elseif space <= 5 or value.y>0 then
         if self.checking == true and self.refresh==true then
              self:RefreshPanelContinueRequire()
              self.refresh = false
         end

         if self.checkTimer ~= nil then
            LuaTimer.Delete(self.checkTimer)
            self.checkTimer = nil
         end
         self.BotLoading:SetActive(false)
         self.checking = false
    end
end
function PetEvaluationWindow:OnInitCompleted()
    self:ClearMainAsset()
end

function PetEvaluationWindow:OnOpen()
    if PetEvaluationManager.Instance.noRefresh == false then
        print("我可以进去这里去初始化列表")
        BaseUtils.dump(self.openArgs[1],"大数据")
        if self.openArgs ~= nil then
            self.typeIndex = self.openArgs[2]
            if self.typeIndex == EvaluationTypeEumn.Type.Pet then
                self.currentTargetData.id = self.openArgs[1].id
                self.currentTargetData.spacialId = self.openArgs[3]
                self.currentTargetData.head_id = self.openArgs[1].head_id
                self.currentTargetData.icon_id = self.openArgs[1].genre
            elseif self.typeIndex == EvaluationTypeEumn.Type.ShouHu then
              BaseUtils.dump(self.openArgs[1],"self.openArgs[1]")
                self.currentTargetData.id = self.openArgs[1].base_id
                self.currentTargetData.spacialId = self.openArgs[1].base_id
                self.currentTargetData.head_id = self.openArgs[1].avatar_id
                self.currentTargetData.icon_id = self.openArgs[1].classes
            end
            self.currentTargetData.name = self.openArgs[1].name
        end
        self:RefreshPanelFirstRequire()
        self:SetTargetData(self.currentTargetData,self.typeIndex)
        self:ChangeTitle()
        self:ReloadChangeList(self.currentTargetData,self.typeIndex)
    else
        PetEvaluationManager.Instance.noRefresh = false
    end
    -- self:ChangeInputText()
end

function PetEvaluationWindow:ChangeTitle()
    if self.typeIndex == EvaluationTypeEumn.Type.Pet then
        self.tileText.text = TI18N("宠物评论")
    elseif self.typeIndex == EvaluationTypeEumn.Type.ShouHu then
        self.tileText.text = TI18N("守护评论")
    end
end

function PetEvaluationWindow:OnHide()
     if self.checkTimer ~= nil then
            LuaTimer.Delete(self.checkTimer)
            self.checkTimer = nil
     end
     if PetEvaluationManager.Instance.noRefresh == false then
          self.EvaluationInputField.text = ""
          self.BotLoading:SetActive(false)
          self.checking = false
          self.petEvaluationList:ReCycle()
     end
end

function PetEvaluationWindow:OnClickClose()
    self.model:CloseMain()
end


-- function PetEvaluationWindow:ChangeInputText()
--     if self.typeIndex == EvaluationTypeEumn.Type.Pet then
--       self.EvaluationInputField.text = TI18N("喜欢这只宠物吗？快留下你的评论吧！")
--     elseif self.typeIndex == EvaluationTypeEumn.Type.ShouHu then
--       self.EvaluationInputField.text = TI18N("喜欢这只守护吗？快留下你的评论吧！")
--     end
-- end

-- 第一次刷新列表请求
function PetEvaluationWindow:RefreshPanelFirstRequire()
    local data = nil

    data = {type = self.typeIndex,base_id = self.currentTargetData.id,page = 0}
    PetEvaluationManager.Instance:Send19400(data)
end


-- 第一次刷新列表
function PetEvaluationWindow:RefreshPanelFirstReply(data)
    self.petEvaluationList:RefreshData(data)
end


-- 下拉刷新列表
function PetEvaluationWindow:RefreshPanelContinueRequire()
    local data = nil

    data = {type = self.typeIndex,base_id = self.currentTargetData.id,page = 1}
    PetEvaluationManager.Instance:Send19400(data)
end

-- 下拉刷新列表
function PetEvaluationWindow:RefreshPanelContinueReply(data)
    self.petEvaluationList:UpdateRefresh(data)
end


--评论回复
function PetEvaluationWindow:RefreshEvaluationRequire()
    if not self:CheckElement() then
        local str = self.EvaluationInputField.text
        -- 去掉手动输入的控制符 如 \n
        str = string.gsub(str, "%c+", "　")
        str = string.gsub(str, "{(%l-_%d.-),(.-)}", "")


        -- if str ~= "" then
       local ok = PetEvaluationManager.Instance:SendMsg(self.typeIndex,self.currentTargetData.id,self.specialIds,str)
        -- -- self.petEvaluationList:AddMyEvaluation(data)
        -- end
    end
    -- local str = self.EvaluationInputField.text


end

function PetEvaluationWindow:RefreshEvaluationReply(data)
    local myData = data
    myData.name = RoleManager.Instance.RoleData.name
    myData.content = self.myCurrentEvaluation
    myData.con = 0
    myData.pro = 0
    myData.role_id = RoleManager.Instance.RoleData.id
    self.petEvaluationList:AddMyEvaluation(data,self.specialIds)
end

--点赞回复
function PetEvaluationWindow:RefreshThumbsUpReply(data)
     self.petEvaluationList.evaluationTarget:CheckUpButtonRepley(data)
end


--点踩回复
function PetEvaluationWindow:RefreshThumbsDownReply(data)
     self.petEvaluationList.evaluationTarget:CheckDownButtonRepley(data)
end

-- function PetEvaluationWindow:GetMyCurrentEvaluation()
--     return self.myCurrentEvaluation
-- end

function PetEvaluationWindow:AppendInputElement(element)
   self.currentElement = element
    -- 其他：同类只有一个，如果是自己，则过滤掉
    local delIndex = 0
    local srcStr = ""
    if element.type ~= nil then
        for i,has in ipairs(self.appendTab) do
            if has.type == element.type and element.type ~= MsgEumn.AppendElementType.Face then
               if element.type == MsgEumn.AppendElementType.Pet and has.id ~= element.id then

               else
                 delIndex = i
                 srcStr = has.matchString
               end
            end
        end
    end

    local nowStr = self.EvaluationInputField.text
    if delIndex ~= 0 then
        table.remove(self.appendTab, delIndex)
        table.insert(self.appendTab, delIndex, element)
        if string.find(nowStr, srcStr) ~= nil then
            local repStr = element.matchString
            nowStr = string.gsub(nowStr, srcStr, repStr, 1)
        else
            nowStr = nowStr .. element.showString
        end
    else
        nowStr = nowStr .. element.showString
        table.insert(self.appendTab, element)
    end
    self.EvaluationInputField.text = nowStr
end

function PetEvaluationWindow:OpenChatShowPanel()
     local list = {}
     local data = nil
     -- 获取我自己拥有的守护列表

     if self.typeIndex == EvaluationTypeEumn.Type.Pet then
          local myOwnPet = {}
          for key,value in pairs(PetManager.Instance:Get_PetList()) do
               table.insert(myOwnPet, { type = "Pet", data = value })
          end
           -- data = DataPet.data_pet[self.currentTargetData.spacialId]
           for i,v in ipairs(myOwnPet) do
              if self.currentTargetData.id == v.data.base.id then
                 table.insert(list,v)
              end
           end
     elseif self.typeIndex == EvaluationTypeEumn.Type.ShouHu then
           local myOwnShouHu = ShouhuManager.Instance.model.my_sh_list
           data = DataShouhu.data_guard_base_cfg[self.currentTargetData.id]
           for i,v in ipairs(myOwnShouHu) do
              if data.base_id == v.base_id then
                 table.insert(list,v)
              end
           end
     end


     if #list ~= 0 then
           if self.chatShowPanel == nil then
               self.chatShowPanel = PetEvaluationChatShowPanel.New(self.gameObject,MsgEumn.ExtPanelType.PetEvaluation)
           end

           self.chatShowPanel:Show({self.typeIndex,list})
    else
          NoticeManager.Instance:FloatTipsByString(TI18N("你没有这个宠物喲~"))
    end
end


-----------------------------------------------------------------------------------------------------------------

function PetEvaluationWindow:CheckElement()
    self.specialIds = {}
    if #self.appendTab == 0 then
        return false
    end
    local role = RoleManager.Instance.RoleData
    local str = self.EvaluationInputField.text
    local numb = 1
    for i,v in ipairs(self.appendTab) do
        local newSendStr = v.sendString

        if v.type == MsgEumn.AppendElementType.Pet then
              local myPetData = PetManager.Instance:GetPetById(v.id)
              newSendStr = string.format("{pet_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id,v.id,v.base_id,myPetData.growth_type)
              self.specialIds[numb] = {}
              self.specialIds[numb].id = v.id
              numb = numb + 1

        elseif v.cacheType == MsgEumn.CacheType.Guard then
            -- local cacheId = ChatManager.Instance.guardCache[v.id]
            -- if cacheId ~= nil then
                local myShData = ShouhuManager.Instance.model:get_my_shouhu_data_by_id(self.currentTargetData.id)
                BaseUtils.dump(myShData,"守护数据")
                newSendStr = string.format("{guard_1,%s,%s,%s,%s, %s}", role.platform, role.zone_id,self.currentTargetData.id, self.currentTargetData.id, myShData.quality)
            -- end
        end
        str = string.gsub(str, v.matchString, newSendStr, 1)
    end

    if self.typeIndex == EvaluationTypeEumn.Type.ShouHu then
        self.specialIds[1] = {}
        self.specialIds[1].id = self.currentTargetData.id
    end
    -- ChatManager.Instance:AppendHistory(self.EvaluationInputField.text)
    -- 去掉手动输入的控制符 如 \n
    str = string.gsub(str, "%c+", "　")
    self.EvaluationInputField.text = ""
        -- self.myCurrentEvaluation = str
        -- local data = { type = self.typeIndex,base_id = self.currentTargetData.id,content = msg}
    local ok = PetEvaluationManager.Instance:SendMsg(self.typeIndex,self.currentTargetData.id,self.specialIds,str)
        -- self.petEvaluationList:AddMyEvaluation(data)

    if ok then
        self.appendTab = {}
    end
    -- local ok = ChatManager.Instance:SendMsg(self.currentChannel.channel, str)
    -- if ok then
    --     self.EvaluationInputField.text = ""
    --     self.appendTab = {}
    -- end
    return true
end

function PetEvaluationWindow:SetCurrentEvaluation(str)
    self.myCurrentEvaluation = str
end

function PetEvaluationWindow:ReloadChangeList(currData, typeIndex)
    if typeIndex == EvaluationTypeEumn.Type.Pet then
        if currData ~= nil and DataPet.data_pet[currData.id] ~= nil and (DataPet.data_pet[currData.id].genre == 2 or DataPet.data_pet[currData.id].genre == 4) then
            self:ShowPetHead_two()
        else
            self:ShowPetHead_one()
        end
    elseif typeIndex == EvaluationTypeEumn.Type.ShouHu then
        self:ShowGuildHead()
    end
end

function PetEvaluationWindow:OnReplaceBtnClick()
    self.changePanel.gameObject:SetActive(true)
    --刷新列表
end

function PetEvaluationWindow:ShowGuildHead()
    self.changePanel:FindChild("HeadPanel/TabButtonGroup").gameObject:SetActive(false)
    self.changeMaskRect.offsetMax = Vector2(0, -11)
    self:UpdateGuildHead()
end


function PetEvaluationWindow:ShowPetHead_one()
    self.changeMaskRect.offsetMax = Vector2(0, -65)
    self.changePanel:FindChild("HeadPanel/TabButtonGroup").gameObject:SetActive(true)
    self.changePanel:FindChild("HeadPanel/TabButtonGroup/Button1/Select").gameObject:SetActive(true)
    self.changePanel:FindChild("HeadPanel/TabButtonGroup/Button2/Select").gameObject:SetActive(false)
    self.changePanel:FindChild("HeadPanel/TabButtonGroup/Button1/Normal").gameObject:SetActive(false)
    self.changePanel:FindChild("HeadPanel/TabButtonGroup/Button2/Normal").gameObject:SetActive(true)
    self.showtype = 1
    self:UpdatePetHead()
end

function PetEvaluationWindow:ShowPetHead_two()
    self.changeMaskRect.offsetMax = Vector2(0, -65)
    self.changePanel:FindChild("HeadPanel/TabButtonGroup/Button1/Select").gameObject:SetActive(false)
    self.changePanel:FindChild("HeadPanel/TabButtonGroup/Button2/Select").gameObject:SetActive(true)
    self.changePanel:FindChild("HeadPanel/TabButtonGroup/Button1/Normal").gameObject:SetActive(true)
    self.changePanel:FindChild("HeadPanel/TabButtonGroup/Button2/Normal").gameObject:SetActive(false)
    self.showtype = 2
    self:UpdatePetHead()
end

--刷新守护列表
function PetEvaluationWindow:UpdateGuildHead()
    --local headlist = self.headlist
    local index = 1
    local select_head = nil
    local Guild_list = {}
    for i,v in pairs(DataShouhu.data_guard_base_cfg) do
        if v.display_lev <= RoleManager.Instance.RoleData.lev then
            table.insert(Guild_list,v)
        end
    end
    local sortfunction = function(a,b) return a.recruit_lev < b.recruit_lev end
    table.sort(Guild_list, sortfunction)

    for i = 1,#Guild_list do
        local data = Guild_list[i]
        local headitem = self.headlist[index]

        if headitem == nil then
            local item = GameObject.Instantiate(self.manualHeadObject)
            item:SetActive(true)
            item.transform:SetParent(self.manualHeadContainer.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            local fun = function() self:OnHeadItemClick(item) end
            item:GetComponent(Button).onClick:AddListener(fun)
            self.headlist[index] = item
            headitem = item
        end
        headitem:SetActive(true)

        headitem.name = tostring(data.base_id)
        headitem.transform:FindChild("Head"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(data.avatar_id))

        headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format("%s", data.recruit_lev)
        headitem.transform:FindChild("Image"):GetComponent(Image).rectTransform.sizeDelta = Vector2(35.7, 18.8)
        index = index + 1
    end
    for i = index, #self.headlist do
        local headitem = self.headlist[i]
        headitem:SetActive(false)
    end
end

function PetEvaluationWindow:UpdatePetHead()
    local headlist = self.headlist
    local headlist_index = 1
    local select_head = nil
    local pet_list = {}
    local manual_lev = 10000
    local role_lve = RoleManager.Instance.RoleData.lev
    if role_lve < 15 then
        manual_lev = 15
    elseif role_lve < 35 then
        manual_lev = 35
    elseif role_lve < 45 then
        manual_lev = 45
    elseif role_lve < 55 then
        manual_lev = 55
    elseif role_lve < 65 then
        manual_lev = 65
    elseif role_lve < 75 then
        manual_lev = 75
    elseif role_lve < 85 then
        manual_lev = 85
    elseif role_lve < 95 then
        manual_lev = 95
    elseif role_lve < 105 then
        manual_lev = 105
    elseif role_lve < 115 then
        manual_lev = 115
    elseif role_lve < 125 then
        manual_lev = 125
    elseif role_lve < 135 then
        manual_lev = 135
    end

    local lev_break_times = RoleManager.Instance.RoleData.lev_break_times

    self.gray_pet_list = {}
    for k,v in pairs(DataPet.data_pet) do
        if v.manual_type == self.showtype and v.genre ~= 6 and v.show_manual == 1 and ( (v.need_lev_break <= lev_break_times and v.manual_level <= manual_lev) or (v.need_lev_break > lev_break_times and v.manual_level <= manual_lev - 10 )) then
                if v.manual_level <= RoleManager.Instance.RoleData.lev and v.need_lev_break <= lev_break_times then
                    table.insert(pet_list, {data = v, gray = false})
                    self.gray_pet_list[v.id] = false
                else
                    table.insert(pet_list, {data = v, gray = true})
                    self.gray_pet_list[v.id] = true
                end
        end
    end

    local sortfunction = function(a,b) return a.data.manual_sort < b.data.manual_sort end
    table.sort(pet_list, sortfunction)
    for i = 1,#pet_list do
        local data = pet_list[i].data
        local gray = pet_list[i].gray
        local headitem = headlist[headlist_index]

        if headitem == nil then
            local item = GameObject.Instantiate(self.manualHeadObject)
            item:SetActive(true)
            item.transform:SetParent(self.manualHeadContainer.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            local fun = function() self:OnHeadItemClick(item) end
            item:GetComponent(Button).onClick:AddListener(fun)
            headlist[headlist_index] = item
            headitem = item
        end
        headitem:SetActive(true)

        headitem.name = tostring(data.id)
        local loaderId = headitem.transform:FindChild("Head"):GetComponent(Image).gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(headitem.transform:FindChild("Head"):GetComponent(Image).gameObject)
        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,data.head_id)
        if data.need_lev_break == 0 then
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format("%s", data.manual_level)
            headitem.transform:FindChild("Image"):GetComponent(Image).rectTransform.sizeDelta = Vector2(35.7, 18.8)
        else
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format("突破%s", data.manual_level)
            headitem.transform:FindChild("Image"):GetComponent(Image).rectTransform.sizeDelta = Vector2(62, 18.8)
        end

        if gray then
            headitem.transform:FindChild("Head"):GetComponent(Image).color = Color.gray
            headitem.transform:FindChild("LVText"):GetComponent(Text).color = Color.red
        else
            headitem.transform:FindChild("Head"):GetComponent(Image).color = Color.white
            headitem.transform:FindChild("LVText"):GetComponent(Text).color = Color.white
        end

        headlist_index = headlist_index + 1

        -- if self.currentTargetData.id == data.id then
        --     select_head = headitem
        -- end
    end
    local headitem = {}
    for i = headlist_index, #headlist do
        local headitem = headlist[i]
        headitem:SetActive(false)
    end

    -- if select_head ~= nil then
    --     self:onheaditemclick(select_head)
    -- elseif #headlist > 0 then
    --     self:onheaditemclick(headlist[1])
    -- end
end


function PetEvaluationWindow:OnHeadItemClick(item)
    if self.typeIndex == EvaluationTypeEumn.Type.Pet then
        self.data = DataPet.data_pet[tonumber(item.name)]
    elseif self.typeIndex == EvaluationTypeEumn.Type.ShouHu then
        self.data = DataShouhu.data_guard_base_cfg[tonumber(item.name)]
    end
    self.changePanel.gameObject:SetActive(false)
    self:UpdateContent(self.data)
end

function PetEvaluationWindow:UpdateContent(data)
    if self.typeIndex == EvaluationTypeEumn.Type.Pet then
        self.currentTargetData.id = data.id
        self.currentTargetData.spacialId = nil
        self.currentTargetData.head_id = data.head_id
        self.currentTargetData.icon_id = data.genre
    elseif self.typeIndex == EvaluationTypeEumn.Type.ShouHu then
       self.currentTargetData.id = data.base_id
       self.currentTargetData.spacialId = data.base_id
       self.currentTargetData.head_id = data.avatar_id
       self.currentTargetData.icon_id = data.classes
    end
    self.currentTargetData.name = data.name
    self.petEvaluationList:ReCycle()
    self:RefreshPanelFirstRequire()
    self:SetTargetData(self.currentTargetData,self.typeIndex)
    self:ChangeTitle()
end


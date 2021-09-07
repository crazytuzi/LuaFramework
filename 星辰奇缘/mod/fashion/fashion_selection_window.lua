FashionSelectionWindow  =  FashionSelectionWindow or BaseClass(BaseWindow)

function FashionSelectionWindow:__init(model)
    self.name  =  "FashionSelectionWindow"
    self.model  =  model
    self.windowId = WindowConfig.WinID.fashion_selection_window
    -- 缓存
    self.cacheMode = CacheMode.Visible
    self.resList  =  {
        {file = AssetConfig.fashion_selection_window, type = AssetType.Main}
        ,{file = AssetConfig.heads,type = AssetType.Dep}
        ,{file = AssetConfig.fashion_selection_big_bg,type = AssetType.Main}
        ,{file = AssetConfig.fashion_selection_texture, type = AssetType.Dep}
    }

    self.tabShowMount = 4
    self.tabIndex = 0
    self.maxTabIndex = 0
    self.fashionSelectionItemList = {}
    self.friendItemList = {}
    self.selectionData = nil
    self.campId = 842
    self.roleListener = function() self:UpdateRoleStatus() end
    self.dolarListener = function() self:UpdateDolar() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function FashionSelectionWindow:OnHide()
    self:RemoveAllListeners()
    if self.fashionSelectionItemList ~= nil then
        for i,v in ipairs(self.fashionSelectionItemList) do
            if v ~= nil then
                v:OnHide()
            end
        end
    end


end

function FashionSelectionWindow:__delete()
    self:RemoveAllListeners()
    if self.refreshId ~= nil then
        LuaTimer.Delete(self.refreshId)
        self.refreshId = 0
    end
    if self.fashionSelectionItemList ~= nil then
        for k,v in pairs(self.fashionSelectionItemList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.fashionSelectionItemList = nil
    end

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end

    if self.tabLayout2 ~= nil then
        self.tabLayout2:DeleteMe()
        self.tabLayout2 = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end


function FashionSelectionWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_selection_window))
    self.gameObject.name = "FashionSelectionWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform = self.gameObject.transform

     self.closeBtn = self.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
     self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.fashionScrollRect = self.transform:Find("MainCon/FashionScrollRect")
    self.fashionContainer = self.transform:Find("MainCon/FashionScrollRect/FashionContainer")
    self.fashionItem = self.transform:Find("MainCon/FashionScrollRect/FashionContainer/FashionItem")
    self.fashionItem.gameObject:SetActive(false)

    self.upButton = self.transform:Find("MainCon/UpButton"):GetComponent(Button)
    self.downButton = self.transform:Find("MainCon/DownButton"):GetComponent(Button)

    self.noticeButton = self.transform:Find("MainCon/NoticeButton"):GetComponent(Button)


    self.bigParent = self.transform:Find("MainCon/BigBg")

    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_selection_big_bg))
    UIUtils.AddBigbg(self.bigParent,bigObj)
    self.maxTabIndex = math.floor(#self.model.fashionList / 4)
    self.upButton.onClick:AddListener(function() self:ChangeTabIndex(1) end)
    self.downButton.onClick:AddListener(function() self:ChangeTabIndex(-1) end)

    self.friendConMaskPanel = self.transform:Find("ReqHelpMaskPanel")


     self.friendConMaskPanel:GetComponent(Button).onClick:AddListener(function ()
        self:OnclickCloseFriendHelpButton()
    end)
    self.friendObj = self.transform:Find("ReqHelpMaskPanel/FriendCon")
    self.friendcon = self.transform:Find("ReqHelpMaskPanel/FriendCon/Mask/Con")
    self.friendcon:GetComponent(VerticalLayoutGroup).enabled = false
    self.friendConMaskPanel.transform.localPosition = Vector3(0,0,-2000)

    self.frienditem = self.transform:Find("ReqHelpMaskPanel/FriendCon/Mask/friendItem")
    self.frienditem.transform.gameObject:SetActive(false)
    self.frienditem.transform:GetComponent(LayoutElement).enabled = false
    self.friendcon.transform:GetComponent(ContentSizeFitter).enabled = false

    self.noFriendText = self.transform:Find("ReqHelpMaskPanel/FriendCon/Mask/noFriendText")

    self.sendHelpButton = self.transform:Find("ReqHelpMaskPanel/FriendCon/Sendbtn"):GetComponent(Button)
    self.sendHelpButton.onClick:AddListener(function () self:SendHelp() end)

    self.topVoteText = self.transform:Find("MainCon/TopBg/Text"):GetComponent(Text)

    self.topTimeText = self.transform:Find("MainCon/TopTime/Text"):GetComponent(Text)

    self.topInviteVote = self.transform:Find("MainCon/TopBg/LeftText"):GetComponent(Text)


    self.friendConMaskPanel.gameObject:SetActive(false)
    local renders = self.friendConMaskPanel.transform:GetComponentsInChildren(Renderer, true)
    local meshrenders = self.friendConMaskPanel.transform:GetComponentsInChildren(MeshRenderer, true)
    for i=1, #renders do
        renders[i].sortingOrder = 22
    end
    for i=1, #meshrenders do
            meshrenders[i].sortingOrder = 22
    end


    self.tabLayout = LuaBoxLayout.New(self.fashionContainer.gameObject, {axis = BoxLayoutAxis.X, cspacing = -70,border = -190,Dir = -70})
    self.tabLayout2 = LuaBoxLayout.New(self.friendcon.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 0})
    for i=1,self.tabShowMount do
        local go = GameObject.Instantiate(self.fashionItem.gameObject)
        local selectionItem = FashionSelectionItem.New(go,self,i)
        self.fashionSelectionItemList[i] = selectionItem
        self.tabLayout:AddCell(go)
    end


    self:OnShow()
end

function FashionSelectionWindow:AddAllListeners()
    FashionSelectionManager.Instance.onUpdateRoleData:AddListener(self.roleListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change,self.dolarListener)
end

function FashionSelectionWindow:RemoveAllListeners()
    FashionSelectionManager.Instance.onUpdateRoleData:RemoveListener(self.roleListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.dolarListener)
end

function FashionSelectionWindow:OnShow()
    self:RemoveAllListeners()
    self:AddAllListeners()
    self:UpdateDolar()
    if self.openArgs ~= nil then
        self.noticeButton.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.noticeButton.gameObject, itemData = {DataCampaign.data_list[self.campId].reward_content}}) end)
    end
    self.tabIndex = 0
    -- if DataCampFashionVote ~= nil and DataCampFashionVote.data_campfashiontime[1] ~= nil then
        self.topTimeText.text = string.format("活动时间:%s月%s日~%s月%s日",DataCampFashionVote.data_campfashiontime[1].start_time[1][1],DataCampFashionVote.data_campfashiontime[1].start_time[1][2],DataCampFashionVote.data_campfashiontime[1].end_time[1][1],DataCampFashionVote.data_campfashiontime[1].end_time[1][2])
    -- end

    FashionSelectionManager.Instance:send20410()

    self:UpdateSelectionItem()
    for i,v in ipairs(self.fashionSelectionItemList) do
        v:OnOpen()
    end

end



function FashionSelectionWindow:ChangeTabIndex(index)
    self.tabIndex = self.tabIndex + index
    if self.tabIndex < 0 then
        self.tabIndex = self.maxTabIndex - 1
    elseif self.tabIndex >= self.maxTabIndex then
        self.tabIndex = 0
    end
    self:UpdateSelectionItem()
    self:UpdateRoleStatus()
end

function FashionSelectionWindow:UpdateSelectionItem()
    local isMiddle = false
    for i,v in ipairs(self.fashionSelectionItemList) do
        local data = self.model.fashionList[self.tabIndex * self.tabShowMount + i]
        if data ~= nil then
            v.gameObject:SetActive(true)
            v:SetData(data)

            v:OnOpen()

        else
            isMiddle = true
            v.gameObject:SetActive(false)
        end
    end

    if isMiddle == true then
        self.fashionScrollRect.transform.anchoredPosition = Vector2(88,-34)
    else
        self.fashionScrollRect.transform.anchoredPosition = Vector2(0,-34)
    end


end

function FashionSelectionWindow:ApplyFriendHelpButton(selectionFationData,selectionWeapData)
    self.selectionWeapData = selectionWeapData
    self.selectionFashionData = selectionFationData
    self:ShowOnLineFriendList()
end

function FashionSelectionWindow:ShowOnLineFriendList()


    self.friendConMaskPanel.gameObject:SetActive(true)
    for i=1,#self.friendItemList do
        self.friendItemList[i].gameObject:SetActive(false)
    end
    local friend_scrollRect = self.friendcon.parent:GetComponent(ScrollRect)
    for i,v in ipairs(FriendManager.Instance.online_friend_List) do
        local frienditem = self.friendItemList[i]
        if frienditem == nil then
            frienditem = GameObject.Instantiate(self.frienditem.gameObject)



            self.tabLayout2:AddCell(frienditem)
            frienditem.transform.anchoredPosition = Vector2(111,frienditem.transform.anchoredPosition.y)


            self.friendItemList[i] = frienditem
        end

        frienditem:SetActive(true)
        local key = BaseUtils.Key(v.classes,v.sex)
        frienditem.transform:Find("Slot/icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.heads, key)
        frienditem.transform:Find("Slot/icon").gameObject:SetActive(true)
        if v.sex > 0 then
            frienditem.transform:Find("male").gameObject:SetActive(true)
        else
            frienditem.transform:Find("male").gameObject:SetActive(false)
        end
        frienditem.transform:Find("classes"):GetComponent(Text).text = KvData.classes_name[v.classes]
        frienditem.transform:Find("name"):GetComponent(Text).text = v.name
        frienditem.transform:GetComponent(Button).onClick:AddListener(function ()
            self:SelectFriend(frienditem, v)
            -- if self.helper ~= nil and #self.helper > 0 and self.selectitemgoid ~= nil and self.selectitemgoid.data.id ~= nil then
            --     self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            -- else
            --     self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            -- end
        end)
        if i == 1 then
            self:SelectFriend(frienditem, v)
        end
    end
    if #FriendManager.Instance.online_friend_List < 1 then
        self.noFriendText.gameObject:SetActive(true)
    end
end


function FashionSelectionWindow:OnclickCloseFriendHelpButton()
    self.friendConMaskPanel.gameObject:SetActive(false)
   -- if self.fashionSelectionItemList ~= nil then
   --      for k,v in pairs(self.fashionSelectionItemList) do
   --          if v ~= nil then
   --              if v.previewComp.loader.weaponLoader.weaponEffect ~= nil then
   --                  v.previewComp.loader.weaponLoader.weaponEffect.gameObject:SetActive(true)
   --              end

   --              if v.previewComp.loader.weaponLoader.weaponEffect2 ~= nil then
   --                  v.previewComp.loader.weaponLoader.weaponEffect2.gameObject:SetActive(true)
   --              end
   --          end
   --      end

   --  end
end

function FashionSelectionWindow:SelectFriend(frienditem, data)
    if self.lastSelectFriend ~= nil then
        self.lastSelectFriend.transform:Find("select").gameObject:SetActive(false)
    end
    self.lastSelectFriend = frienditem
    self.lastSelectFriend.transform:Find("select").gameObject:SetActive(true)
    self.lastSelectFirendData = data
    -- BaseUtils.dump(data,"SelectFriend ==")
end

function FashionSelectionWindow:SendHelp()

    -- if RoleManager.Instance.RoleData.lev >=30 then
        -- local sendData = string.format(TI18N("亲爱的{string_2,#b031d5,%s},我想和你共同激活同心锁哟~{magpiefestival_1,点击接受邀请,%s,%s,%s}"), RoleManager.Instance.RoleData.name,RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id)

    if self.lastSelectFirendData ~= nil then
        FashionSelectionManager.Instance.lastSelectFirendData = self.lastSelectFirendData
        FashionSelectionManager.Instance.selectionFashionDataGroupId = self.selectionFashionData.group_id
        FashionSelectionManager.Instance.selectionWeapDataLooks_mode = self.selectionWeapData.looks_mode
        FashionSelectionManager.Instance.selectionWeapDataLooks_val = self.selectionWeapData.looks_val
        local sendData = {group_id = self.selectionFashionData.group_id,f_id =self.lastSelectFirendData.id,f_platform = self.lastSelectFirendData.platform,f_zone_id = self.lastSelectFirendData.zone_id}
        FashionSelectionManager.Instance:send20412(sendData)
    end
    -- else
    --     NoticeManager.Instance:FloatTipsByString("<color='#ffff00'>30级</color>以上才能参与，努力升级吧{face_1,3}")
    -- end
end

function FashionSelectionWindow:UpdateRoleStatus()
    self.topInviteVote.text = string.format("%s/%s",FashionSelectionManager.Instance.fashionRoleData.invite_votes,FashionSelectionManager.Instance.fashionData.invite_votes)
     for i,v in ipairs(self.fashionSelectionItemList) do
        v:SetButtonStatus()
    end

end

function FashionSelectionWindow:ApplyVoteButton(data)
    FashionSelectionManager.Instance:send20411(data.group_id)
end

function FashionSelectionWindow:UpdateDolar()

    local baseTime = BaseUtils.BASE_TIME
    local day = tonumber(os.date("%d",baseTime))
    local startDay = DataCampaign.data_list[self.campId].cli_start_time[1][3]
    local distance = day - startDay
    local mount = 0
    if distance == 0 then
        mount = BackpackManager.Instance:GetItemCount(29929)
    elseif distance == 1 then
        mount = BackpackManager.Instance:GetItemCount(29930)
    elseif distance == 2 then
        mount = BackpackManager.Instance:GetItemCount(29931)
    end

    self.topVoteText.text = "投票券: " .. mount


end
SeekChildrensDetailDescPanel = SeekChildrensDetailDescPanel or BaseClass(BasePanel)

function SeekChildrensDetailDescPanel:__init(model)
    self.model = model
    self.name = "SeekChildrensDetailDescPanel"

    self.resList = {
        {file = AssetConfig.seek_children_detail_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.summer_res, type  =  AssetType.Dep}
        ,{file = AssetConfig.heads, type = AssetType.Dep}
        ,{file = AssetConfig.stongbg, type = AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function()
        self.childData = self.openArgs
        self:UpdateWindow()
    end)
    self.OnHideEvent:AddListener(function ()
        self:DeleteMe()
    end)

    self.Type_Share = 1
    self.Type_Ask = 2
    self.type = self.Type_Share

    self.friendItemList = {}
end

function SeekChildrensDetailDescPanel:OnInitCompleted()
    self.childData = self.openArgs
    self:UpdateWindow()
end

function SeekChildrensDetailDescPanel:__delete()
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end

    self:AssetClearAll()
    self.gameObject = nil
    self.model.seekchildrenDetailPanel = nil
    self.model = nil

end

function SeekChildrensDetailDescPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.seek_children_detail_panel))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self:DoClickPanel()

    -- 大图 hosr
    self.transform:Find("Main/Item_1/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    self.itemPlaceTxt = self.transform:Find("Main/Item_1/PlaceNameText"):GetComponent(Text)
    self.itemDescTxt = self.transform:Find("Main/Item_1/DescText"):GetComponent(Text)
    self.girlImg = self.transform:Find("Main/Item_1/GirlImage"):GetComponent(Image)
    self.girlImg.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-6,0)

    self.centerTitleDescTxt = self.transform:Find("Main/DescText"):GetComponent(Text)
    self.contentTxt = self.transform:Find("Main/ContentText"):GetComponent(Text)
    self.contentTxt.horizontalOverflow = HorizontalWrapMode.Wrap
    self.contentMsg = MsgItemExt.New(self.contentTxt, 330, 18, 20)

    self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function()
                self:OnClickClose()
            end)
    self.shareBtn = self.transform:Find("Main/ShareButton"):GetComponent(Button)
    self.shareBtn.onClick:AddListener(function()
                self:OnClickSharePlaceBtn()
            end)
    self.shareBtnTxt = self.transform:Find("Main/ShareButton/Text"):GetComponent(Text)
    self.askBtn = self.transform:Find("Main/AskButton"):GetComponent(Button)
    self.askBtn.onClick:AddListener(function()
                self:OnClickSharePlaceBtn()
            end)
    self.askBtnImg = self.transform:Find("Main/AskButton"):GetComponent(Image)
    self.askBtnTxt = self.transform:Find("Main/AskButton/Text"):GetComponent(Text)

    self.reqHelp = self.transform:Find("Main/reqhelp").gameObject
    self.reqHelpRect = self.reqHelp:GetComponent(RectTransform)
    self.reqHelpMaskPanel = self.transform:Find("Main/ReqHelpMaskPanel").gameObject
    self.reqHelpMaskPanel:GetComponent(Button).onClick:AddListener(function ()
        self:OnclickCloseReqHelpButton()
    end)
    self.guildHelpBtn = self.reqHelp.transform:Find("Guildhelp"):GetComponent(Button)
    self.guildHelpBtn.onClick:AddListener(function ()
        self:OnclickGuildHelpButton()
    end)
    self.guildText = self.reqHelp.transform:Find("Guildhelp/Text"):GetComponent(Text)

    self.friendHelpBtn = self.reqHelp.transform:Find("Friendhelp"):GetComponent(Button)
    self.friendHelpBtn.onClick:AddListener(function ()
        self:OnclickFriendHelpButton()
    end)
    self.friendText = self.reqHelp.transform:Find("Friendhelp/Text"):GetComponent(Text)

    self.worldHelpBtn = self.reqHelp.transform:Find("Worldhelp"):GetComponent(Button)
    self.worldHelpBtn.onClick:AddListener(function ()
        self:OnclickWroldHelpButton()
    end)
    self.worldText = self.reqHelp.transform:Find("Worldhelp/Text"):GetComponent(Text)
    self.reqHelpMaskPanel:SetActive(false)
    self.reqHelp:SetActive(false)

    self.friendObj = self.transform:Find("Main/FriendCon").gameObject
    self.friendConMaskPanel = self.transform:Find("Main/FriendConMaskPanel").gameObject
    self.friendConMaskPanel:GetComponent(Button).onClick:AddListener(function ()
        self:OnclickCloseFriendHelpButton()
    end)
    self.friendcon = self.transform:Find("Main/FriendCon/Mask/Con")
    self.frienditem = self.transform:Find("Main/FriendCon/Mask/friendItem")
    self.frienditem.gameObject:SetActive(false)
    self.noFriendText = self.transform:Find("Main/FriendCon/Mask/noFriendText")
    self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Button).onClick:AddListener(function () self:SendHelp() end)
    self.sendBtnTxt = self.transform:Find("Main/FriendCon/Sendbtn/Text"):GetComponent(Text)
    self.friendConMaskPanel:SetActive(false)
    self.friendObj:SetActive(false)
end
--关闭求助按钮
function SeekChildrensDetailDescPanel:OnclickCloseReqHelpButton()
    self.reqHelp:SetActive(false)
    self.reqHelpMaskPanel:SetActive(false)
end
--关闭好友求助界面
function SeekChildrensDetailDescPanel:OnclickCloseFriendHelpButton()
    self.friendObj:SetActive(false)
    self.friendConMaskPanel:SetActive(false)
end
--公会求助
function SeekChildrensDetailDescPanel:OnclickGuildHelpButton()
    if GuildManager.Instance.model:check_has_join_guild() then
        if self.type == self.Type_Share then
            SummerManager.Instance:request14035(MsgEumn.ChatChannel.Guild,self.childData.childInfo.base_id)
            NoticeManager.Instance:FloatTipsByString(TI18N("分享成功"))
            self.model:startTimeShareCal()
        elseif self.type == self.Type_Ask then
            SummerManager.Instance:request14034(MsgEumn.ChatChannel.Guild,self.childData.childInfo.base_id)
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请创建或加入一个公会"))
    end
    self:OnclickCloseReqHelpButton()
    self:OnClickClose()
end
--好友求助
function SeekChildrensDetailDescPanel:OnclickFriendHelpButton()
    self:ShowOnLineFriendList()
    self:OnclickCloseReqHelpButton()
end
--世界求助
function SeekChildrensDetailDescPanel:OnclickWroldHelpButton()
    --
    if self.type == self.Type_Share then
        SummerManager.Instance:request14035(MsgEumn.ChatChannel.World,self.childData.childInfo.base_id)
        NoticeManager.Instance:FloatTipsByString(TI18N("分享成功"))
        self.model:startTimeShareCal()
    elseif self.type == self.Type_Ask then
        SummerManager.Instance:request14034(MsgEumn.ChatChannel.World,self.childData.childInfo.base_id)
    end
    self:OnclickCloseReqHelpButton()
    self:OnClickClose()
end
function SeekChildrensDetailDescPanel:ShowOnLineFriendList()
    self.friendConMaskPanel:SetActive(true)
    self.friendObj:SetActive(true)
    for i=1,#self.friendItemList do
        self.friendItemList[i].gameObject:SetActive(false)
    end
    local friend_scrollRect = self.friendcon.parent:GetComponent(ScrollRect)
    for i,v in ipairs(FriendManager.Instance.online_friend_List) do
        local frienditem = self.friendItemList[i]
        if frienditem == nil then
            frienditem = GameObject.Instantiate(self.frienditem.gameObject)
            frienditem.transform:SetParent(self.friendcon)
            frienditem.transform.localScale = Vector3.one

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
function SeekChildrensDetailDescPanel:SelectFriend(frienditem, data)
    if self.lastSelectFriend ~= nil then
        self.lastSelectFriend.transform:Find("select").gameObject:SetActive(false)
    end
    self.lastSelectFriend = frienditem
    self.lastSelectFriend.transform:Find("select").gameObject:SetActive(true)
    self.lastSelectFirendData = data
    -- BaseUtils.dump(data,"SelectFriend ==")
end
function SeekChildrensDetailDescPanel:SendHelp()
    if self.lastSelectFirendData ~= nil then
        if self.type == self.Type_Share then
            SummerManager.Instance:request14035(MsgEumn.ChatChannel.Private,self.childData.childInfo.base_id,
                self.lastSelectFirendData.id,self.lastSelectFirendData.platform,self.lastSelectFirendData.zone_id)
            NoticeManager.Instance:FloatTipsByString(TI18N("分享成功"))
            self.model:startTimeShareCal()
        elseif self.type == self.Type_Ask then
            SummerManager.Instance:request14034(MsgEumn.ChatChannel.Private,self.childData.childInfo.base_id,
                self.lastSelectFirendData.id,self.lastSelectFirendData.platform,self.lastSelectFirendData.zone_id)
        end
    end
    self:OnclickCloseFriendHelpButton()
    self:OnClickClose()
end

function SeekChildrensDetailDescPanel:OnClickSharePlaceBtn()
    if self:checkGoDirect() == true then
        local dataInfo = SummerManager.Instance.npcDataSeekChild[self.childData.childInfo.base_id]
        --寻路到npc
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        local key = BaseUtils.get_unique_npcid(dataInfo.u_id, dataInfo.battle_id)
        SceneManager.Instance.sceneElementsModel:Self_PathToTarget(key,false)

        if WindowManager.Instance.currentWin ~= nil then
            WindowManager.Instance:CloseWindow(WindowManager.Instance.currentWin, false)
        end
        self:OnClickClose()
        return
    end
    if self.type == self.Type_Share then
        --分享
        if self.model.timerIdShare == 0 then
            self.worldHelpBtn.gameObject:SetActive(false)
            self.worldText.text = TI18N("世界分享")
            self.friendHelpBtn.gameObject:SetActive(true)
            self.friendText.text = TI18N("好友分享")
            self.guildHelpBtn.gameObject:SetActive(true)
            self.guildText.text = TI18N("公会分享")
            self.reqHelpRect.sizeDelta = Vector2(182,140)
            -- self.reqHelpRect.sizeDelta = Vector2(182,190)

            self.reqHelpMaskPanel:SetActive(true)
            self.reqHelp:SetActive(true)
        else
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请<color='#ffff00'>%d秒</color>后再分享吧"),self.model.timeShareCount))
        end
    elseif self.type == self.Type_Ask then
        --询问
        self.worldHelpBtn.gameObject:SetActive(false)
        self.worldText.text = TI18N("世界求助")
        self.guildHelpBtn.gameObject:SetActive(true)
        self.guildText.text = TI18N("公会求助")
        self.friendHelpBtn.gameObject:SetActive(true)
        self.friendText.text = TI18N("好友求助")
        self.reqHelpRect.sizeDelta = Vector2(182,140)

        --
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("公会或好友可能知道<color='#ffff00'>%s</color>的位置，快去询问吧"),self.childData.childInfo.name_child))
    end
    -- self.reqHelpMaskPanel:SetActive(true)
    -- self.reqHelp:SetActive(true)
end

function SeekChildrensDetailDescPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                -- print("222222222222")
                    self:Hiden()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function SeekChildrensDetailDescPanel:checkGoDirect()
    -- if self.childData.index == 1 and self.childData.isFinish == false then
    --     return true
    -- end
    local childrenData = SummerManager.Instance.childrensGroupData
    for i,v in ipairs(childrenData.active_list) do
        if v.id == self.childData.childInfo.base_id then
            local isDone = false
            for ii,vv in ipairs(childrenData.list) do
                if vv.id == v.id then
                    isDone = true
                    break
                end
            end
            if isDone == false then
                return true
            end
        end
    end
    return false
end

function SeekChildrensDetailDescPanel:UpdateWindow()
    -- BaseUtils.dump(self.childData,"SeekChildrensDetailDescPanel:UpdateWindow() ==")
    self.reqHelp:SetActive(false)
    self.reqHelpMaskPanel:SetActive(false)
    self.friendObj:SetActive(false)
    self.friendConMaskPanel:SetActive(false)
    if self.childData.isFinish == true then -- or self.childData.index == 1 then
        self.type = self.Type_Share
    else
        self.type = self.Type_Ask
    end
    local isGoDirection = self:checkGoDirect()
    if self.type == self.Type_Share then
        --分享
        self.shareBtn.gameObject:SetActive(true)
        self.askBtn.gameObject:SetActive(false)
        self.sendBtnTxt.text = TI18N("分 享")
        if isGoDirection == true then
            self.shareBtnTxt.text = TI18N("立即前往")
        else
            self.shareBtnTxt.text = TI18N("分享位置")
        end
    elseif self.type == self.Type_Ask then
        --询问
        self.shareBtn.gameObject:SetActive(false)
        self.askBtn.gameObject:SetActive(true)
        self.sendBtnTxt.text = TI18N("求 助")
        if isGoDirection == true then
            self.askBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.askBtnTxt.color = ColorHelper.DefaultButton2
            self.askBtnTxt.text = TI18N("立即前往")
        else
            self.askBtnTxt.text = TI18N("询问位置")
            self.askBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.askBtnTxt.color = ColorHelper.DefaultButton3
        end
    end

    self.girlImg.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, self.childData.childInfo.child_res_name)
    self.girlImg:SetNativeSize()
    if self.childData.isFinish == true then
        self.itemPlaceTxt.text = string.format("<color='#ffff00'>%s</color>",self.childData.mapInfo.name)
    else
        self.itemPlaceTxt.text = "？？？"
    end
    -- if self.childData.index == 1 or isGoDirection == true then
    if isGoDirection == true then
        self.itemPlaceTxt.text = string.format("<color='#ffff00'>%s</color>",self.childData.mapInfo.name)
    end
    -- self.itemPlaceTxt.text = self.childData.mapInfo.name
    self.itemDescTxt.text = self.childData.childInfo.name_child
    self.centerTitleDescTxt.text = self.childData.childInfo.name_task
    -- self.contentTxt.text = self.childData.childInfo.desc_task
    self.contentMsg:SetData(self.childData.childInfo.desc_task)
    if self.childData.isFinish == true then
        self.contentMsg:SetData(TI18N("该任务已完成，快向其他<color='#ffff00'>好友共享</color>小孩的位置吧{face_1,22}"))
    end
end

function SeekChildrensDetailDescPanel:OnClickClose()
    self:Hiden()
end
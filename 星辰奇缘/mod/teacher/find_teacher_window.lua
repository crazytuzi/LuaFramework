FindTeacherWindow  =  FindTeacherWindow or BaseClass(BaseWindow)

function FindTeacherWindow:__init(model)
    self.name  =  "ApprenticeSignUpWindow"
    self.model  =  model

    self.windowId = WindowConfig.WinID.findteacherwindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList  =  {
        {file  =  AssetConfig.findteacherwindow, type  =  AssetType.Main}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.font, type = AssetType.Dep}
    }
    
    self.itemList = {}
    self.headSlotList = {}
    self.refreshMark = false

    self.apprenticeList = {}

    self._Update = function(data) self:Update(data.list) end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    return self
end


function FindTeacherWindow:__delete()
    self.is_open  =  false

    TeacherManager.Instance.onUpdateInfo:RemoveListener(self._Update)

    for i=1, #self.headSlotList do
        self.headSlotList[i]:DeleteMe()
        self.headSlotList[i] = nil
    end

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end

function FindTeacherWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.findteacherwindow))
    self.gameObject.name  =  "FindTeacherWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.mainTransform = self.gameObject.transform:FindChild("Main")
    
    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.container = self.mainTransform:FindChild("Mask/Container")
    self.clonerItem = self.container:FindChild("Item").gameObject
    self.clonerItem:SetActive(false)

    self.noTips = self.mainTransform:FindChild("NoTips").gameObject
    self.noTips:SetActive(false)

    local btn = self.mainTransform:Find("RefreshButton"):GetComponent(Button)
    btn.onClick:AddListener(function() 
            self:Refresh()
        end)

    self:OnShow()

    self:ClearMainAsset()
end

function FindTeacherWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function FindTeacherWindow:OnShow()
    TeacherManager.Instance.onUpdateInfo:AddListener(self._Update)
    self:Refresh()
    self.refreshMark = false
end

function FindTeacherWindow:OnHide()
    TeacherManager.Instance.onUpdateInfo:RemoveListener(self._Update)
end

function FindTeacherWindow:Update(datalist)
    if self.refreshMark then
        NoticeManager.Instance:FloatTipsByString(TI18N("已成功刷新{face_1, 7}"))
    end

    for i, data in ipairs(datalist) do
        local item = self.itemList[i]
        local headSlot = self.headSlotList[i]
        if item == nil then
            item = GameObject.Instantiate(self.clonerItem)
            item.transform:SetParent(self.container)
            item.transform.localScale = Vector3(1, 1, 1)
            item:SetActive(true)
            self.itemList[i] = item

            headSlot = HeadSlot.New()
            UIUtils.AddUIChild(item.transform:Find("LeaderHead"), headSlot.gameObject)
            self.headSlotList[i] = headSlot
        end
        item:SetActive(true)

        local btn = item.transform:Find("TalkButton"):GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function() 
                self:DoTalk(data)
                -- self:OnClickClose()
            end)
        btn = item.transform:Find("OkButton"):GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function() 
                self:DoApprentice(data, btn)
                -- self:OnClickClose()
            end)

        if self:CheckApprentice(data) then
            btn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            btn.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
        else
            btn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            btn.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
        end

        item.transform:Find("Classes"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, string.format("ClassesIcon_%s", data.classes))
        item.transform:Find("NameText"):GetComponent(Text).text = data.name
        item.transform:Find("LevText"):GetComponent(Text).text = string.format(TI18N("%s  %s级"), KvData.classes_name[data.classes], data.lev)

        item.transform:Find("Text"):GetComponent(Text).text = data.msg

        local showPlayerTipsFunction = function() 
                TipsManager.Instance:ShowPlayer({ id = data.rid, zone_id = data.zone_id, platform = data.platform, sex = data.sex, classes = data.classes, name = data.name, lev = data.lev })
            end
        local dat = {id = data.rid, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}
        headSlot:SetAll(dat, {isSmall = true, clickCallback = showPlayerTipsFunction })
    end

    for i=#datalist+1, #self.itemList do
        self.itemList[i]:SetActive(false)
    end

    if #datalist > 0 then
        self.container.gameObject:SetActive(true)
        self.noTips:SetActive(false)
    else
        self.container.gameObject:SetActive(false)
        self.noTips:SetActive(true)
    end
end

function FindTeacherWindow:Refresh(data)
    self.refreshMark = true
    TeacherManager.Instance:send15823()
end

function FindTeacherWindow:DoTalk(data)
    local talkData = BaseUtils.copytab(data)
    talkData.online = 1
    talkData.id = talkData.rid
    FriendManager.Instance:TalkToUnknowMan(talkData, 1)
end

function FindTeacherWindow:DoApprentice(data, btn)
    local callback = function()
        local key = BaseUtils.get_unique_roleid(data.rid, data.zone_id, data.platform)
        for index, value in ipairs(self.apprenticeList) do
            if key == value then
                NoticeManager.Instance:FloatTipsByString(TI18N("已经联系过该玩家了，等等再来吧{face_1, 22}"))
                return
            end
        end
        table.insert(self.apprenticeList, key)

        btn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        btn.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4

        local talkData = BaseUtils.copytab(data)
        talkData.online = 1
        talkData.id = talkData.rid
        FriendManager.Instance:TalkToUnknowMan(talkData, 1)
        FriendManager.Instance:SendMsg(talkData.id, talkData.platform, talkData.zone_id, TI18N("我在德林导师处听说你正在找师傅，我可以做你的师傅吗小可爱{face_1,16}"))

        -- TeacherManager.Instance:send15819(talkData.id, talkData.platform, talkData.zone_id)
        TeacherManager.Instance:send15800(talkData.id, talkData.platform, talkData.zone_id, "")
    end

    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = string.format(TI18N("你确认要收<color='#00ff00'>%s（%s级%s）</color>为徒吗？"), data.name, data.lev, KvData.classes_name[data.classes])
    confirmData.sureLabel = TI18N("确认收徒")
    confirmData.cancelLabel = TI18N("我再想想")
    confirmData.sureCallback = callback
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function FindTeacherWindow:CheckApprentice(data)
    local key = BaseUtils.get_unique_roleid(data.rid, data.zone_id, data.platform)
    for index, value in ipairs(self.apprenticeList) do
        if key == value then
            return true
        end
    end

    return false
end
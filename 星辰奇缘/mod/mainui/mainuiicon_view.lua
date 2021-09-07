-- 主界面图标
MainUIIconView = MainUIIconView or BaseClass(BasePanel)

function MainUIIconView:__init()
    self.model = model
    self.resList = {
        {file = AssetConfig.basefunctioniconarea, type = AssetType.Main}
    }

    self.originPos = {
        Vector3.zero,
        Vector3.zero,
        Vector3(960, 0, 0),-- Vector3.zero,
        nil,
        Vector3.zero,
        Vector3(0, 170, 0),
        Vector3(0, 170, 0),
    }

    self.name = "MainUIIconView"

    self.gameObject = nil
    self.transform = nil

    ------------------------------.
    self.systemicon_startx = -75
    self.systemicon_starty = 10
    self.systemicon_width = -70

    self.othericon_startx = 88
    self.othericon_starty = -178
    self.othericon_height = -58

    self.ativeicon_startx = -755
    self.ativeicon_starty = -120
    self.ativeicon_width = 65
    self.ativeicon_height = 58

    self.ativeicon2_startx = -330
    self.ativeicon2_starty = -116
    self.ativeicon2_width = -74

    self.ativeicon3_startx = 35
    self.ativeicon3_starty = 0
    self.ativeicon3_width = 64

    self.icon_type1_list = {}
    self.icon_type2_list = {}
    self.icon_type3_list = {}
    self.icon_type4_list = {}
    self.icon_type5_list = {}
    self.icon_type6_list = {}

    self.ativeicon1 = {}
    self.ativeicon2 = {}
    self.ativeicon3 = {}

    self.isiconshow = true
    self.isiconshow2 = true
    self.isiconshow3 = true
    self.isiconshow5 = true
    self.isiconshow6 = true
    self.hide_icon_id_list = {}
    self.hide_icon_id_list[24] = true
    self.hide_icon_id_list[17] = true

    if BaseUtils.IsVerify then
        -- 审核服不显示
        self:CheckVerify()
    end

    self.newicon_gameobject = nil
    self.newicon_gameobject2 = nil
    self.newicon_gameobject3 = nil
    self.iconSwitcher = nil
    self.iconSwitcher_image = nil
    self.guideEffect = nil

    self.timeText = nil

    self.show_top = true
    self.show_top_exception_list = {}

    self.show_leftbottom = true
    self.show_leftbottom_exception_list = {}

    self._mainui_icon_update = function(iconId, show, ...)
        self:mainui_icon_update(iconId, show, {...})
    end
    self._refresh_icon = function()
        self:refresh_icon()
    end
    self.sortfun = function(a,b)
        return a.sort > b.sort
    end
    self.checkGuidePoint = function() self:CheckGuidePoint() end
    MainUIManager.Instance.OnUpdateIcon:Add(self._mainui_icon_update)
    EventMgr.Instance:AddListener(event_name.equip_item_change,self.checkGuidePoint)
    EventMgr.Instance:AddListener(event_name.quest_update,self.checkGuidePoint)
    EventMgr.Instance:AddListener(event_name.role_level_change, self._refresh_icon)
    EventMgr.Instance:AddListener(event_name.cross_type_change, self._refresh_icon)
    EventMgr.Instance:AddListener(event_name.role_attr_change, function() self:CheckRed() end)
    EventMgr.Instance:AddListener(event_name.role_wings_change, function() self:CheckRed() end)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, function() self:CheckRed() end)
    EventMgr.Instance:AddListener(event_name.adapt_iphonex, function() self:AdaptIPhoneX() end)
    WingsManager.Instance.onUpdateRed:AddListener(function() self:CheckRed() end)
    -- EventMgr.Instance:AddListener(event_name.chat_mini_size_change, function(show) self:Set_ShowIconPanel6(show) end)

   self.isTweenShow = true
end

function MainUIIconView:CheckVerify()
    for k,v in pairs(DataSystem.data_icon) do
        self.hide_icon_id_list[v.id] = true
    end
    for k,v in pairs(DataSystem.data_daily_icon) do
        self.hide_icon_id_list[v.id] = true
    end
    self.hide_icon_id_list[1] = false
    self.hide_icon_id_list[2] = false
    self.hide_icon_id_list[3] = false
    self.hide_icon_id_list[4] = false
    self.hide_icon_id_list[5] = false
    self.hide_icon_id_list[6] = false
    self.hide_icon_id_list[8] = false
    self.hide_icon_id_list[11] = false
    -- self.hide_icon_id_list[17] = false
    -- self.hide_icon_id_list[18] = false
    -- self.hide_icon_id_list[22] = false
    self.hide_icon_id_list[35] = false
    -- self.hide_icon_id_list[36] = false

    DataSystem.data_icon[17].lev = 999
end

function MainUIIconView:ShowCanvas(bool)
    if self.gameObject == nil then
        return
    end

    if bool then
        BaseUtils.ChangeLayersRecursively(self.transform, "UI")
        if self.raycaster == nil then
            self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        end
        if self.raycaster ~= nil then
            self.raycaster.enabled = true
        end
    else
        BaseUtils.ChangeLayersRecursively(self.transform, "Water")
        if self.raycaster == nil then
            self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        end
        if self.raycaster ~= nil then
            self.raycaster.enabled = false
        end
    end
end

function MainUIIconView:__delete()
    if self.guideEffect ~= nil then
        self.guideEffect:DeleteMe()
        self.guideEffect = nil
    end
    BaseUtils.CancelIPhoneXTween(self.transform)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MainUIIconView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.basefunctioniconarea))
    self.gameObject.name = "MainUIIconView"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local rect = self.gameObject.transform:Find("ButtonPanel3"):GetComponent(RectTransform)
    rect.anchorMax = Vector2(0, 1)
    rect.anchorMin = Vector2(0, 1)
    rect.localPosition = Vector3(960, 0, 0)

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 0)
    rect.localScale = Vector3.one

    self.transform = self.gameObject.transform

    -----------------------------
    self:initButton()
    self:ClearMainAsset()
    -- EventMgr.Instance:AddListener(event_name.mainui_icon_update, self._mainui_icon_update)

    if DownLoadManager.Instance.model:IsSubpackage() then
        CSSubpackageManager.GetInstance():StartDownload()
    end

    if self:CheckGuide() then
        -- 恢复奖励引导
        GuideManager.Instance:Start(10005)
    end

    self:AdaptIPhoneX()
end

function MainUIIconView:CheckToDestroy(nowTime)
    return false
end

function MainUIIconView:initButton()
    local transform = self.transform
    for k, v in pairs(DataSystem.data_icon) do
        local icon
        if v.icon_type == 4 then
            icon = transform:FindChild("ButtonPanel1/"..v.icon_name)
        else
            icon = transform:FindChild("ButtonPanel"..v.icon_type.."/"..v.icon_name)
        end

        if BaseUtils.IsVerify == true and (v.id == 7 or v.id == 31 or v.id == 32) then
            icon.gameObject:SetActive(false)
        else
            if icon ~= nil then
                v.icon = icon.gameObject
                DataSystem.data_icon[k].icon = icon.gameObject
                icon:GetComponent(Button).onClick:AddListener(function() MainUIManager.Instance:btnOnclick(v.id) end)

                if v.icon_type == 1 then
                    table.insert(self.icon_type1_list, v)
                elseif v.icon_type == 2 then
                    table.insert(self.icon_type2_list, v)
                elseif v.icon_type == 3 then
                    table.insert(self.icon_type3_list, v)
                elseif v.icon_type == 4 then
                    table.insert(self.icon_type4_list, v)
                elseif v.icon_type == 5 then
                    table.insert(self.icon_type5_list, v)
                elseif v.icon_type == 6 then
                    table.insert(self.icon_type6_list, v)
                end
            end
        end
    end

    table.sort(self.icon_type1_list, self.sortfun)
    table.sort(self.icon_type2_list, self.sortfun)
    table.sort(self.icon_type3_list, self.sortfun)
    table.sort(self.icon_type4_list, self.sortfun)
    table.sort(self.icon_type5_list, self.sortfun)
    table.sort(self.icon_type6_list, self.sortfun)

    self.ativeIconPanel = transform:FindChild("ButtonPanel3").gameObject
    self.newicon_gameobject = transform:FindChild("ButtonPanel3/NewIconButton").gameObject
    self.ativeIconPanel2 = transform:FindChild("ButtonPanel5").gameObject
    self.ativeIconPanel3 = transform:FindChild("ButtonPanel6").gameObject
    self.newicon_gameobject3 = transform:FindChild("ButtonPanel6/NewIconButton").gameObject

    self.iconSwitcher = transform:FindChild("ButtonPanel1/IconSwitcherIconButton").gameObject
    self.iconSwitcher:GetComponent(Button).onClick:AddListener(function() self:iconSwitcher_click() end)
    self.iconSwitcher_image = self.iconSwitcher:GetComponent(Image)

    self.foldButton_ativeIconPanel = transform:FindChild("ButtonPanel3/FoldButton"):GetComponent(Button)
    self.foldButton_ativeIconPanel.onClick:AddListener(function() self:foldButton_ativeIconPanel_click() end)
    self.foldButton_ativeIconPanel_image = transform:FindChild("ButtonPanel3/FoldButton/Image")
    transform:FindChild("ButtonPanel3/FoldButton/RedPointImage").gameObject:SetActive(false)
    self.foldButton_ativeIconPanel.transform:GetComponent(RectTransform).anchoredPosition = Vector3(-769, self.ativeicon_starty)

    self.iconPanelRect1 = transform:FindChild("ButtonPanel1"):GetComponent(RectTransform)
    self.iconPanelRect2 = transform:FindChild("ButtonPanel2"):GetComponent(RectTransform)
    self.iconPanelRect3 = transform:FindChild("ButtonPanel3"):GetComponent(RectTransform)
    self.iconPanelRect5 = transform:FindChild("ButtonPanel5"):GetComponent(RectTransform)
    self.iconPanelRect6 = transform:FindChild("ButtonPanel6"):GetComponent(RectTransform)
    self.iconPanelRect7 = transform:FindChild("ButtonPanel7"):GetComponent(RectTransform)
    self.iconPanelRect8 = transform:FindChild("ButtonPanel8"):GetComponent(RectTransform)

    self.iconPanelRect1.anchoredPosition = self.originPos[1]
    self.iconPanelRect2.anchoredPosition = self.originPos[2]
    self.iconPanelRect3.anchoredPosition = self.originPos[3]
    self.iconPanelRect5.anchoredPosition = self.originPos[5]
    self.iconPanelRect6.anchoredPosition = self.originPos[6]
    self.iconPanelRect7.anchoredPosition = self.originPos[7]


    self:AddAtiveIcon_ByCache()

    self:refreshicon()

    -- EventMgr.Instance:Fire(event_name.mainui_btn_init)
end

-- 刷新按钮显示
function MainUIIconView:refreshicon()
    if self.gameObject == nil then
        return
    end
    self:showbaseicon()
    self:showbaseicon2()
    self:showbaseicon3()
    self:hidebaseicon4()
    self:showbaseicon5()
    self:showbaseicon6()

    self:CheckRed()

    self:CheckGuidePoint()

    MainUIManager.Instance.isMainUIInconInit = true

    EventMgr.Instance:Fire(event_name.mainui_btn_init)
end

-- 按id获取按钮对象
function MainUIIconView:getbuttonbyid(id)
    -- BaseUtils.dump(DataSystem.data_icon,"sdlfjsdkjfklsdjfkjsdfjsdljfsdkjfklsdj")
    if DataSystem.data_icon[id] ~= nil then
        return DataSystem.data_icon[id].icon
    else
        for i = 1, #self.icon_type3_list do
            if self.icon_type3_list[i].id == id then
                return self.icon_type3_list[i].icon
            end
        end
        for i = 1, #self.icon_type5_list do
            if self.icon_type5_list[i].id == id then
                return self.icon_type5_list[i].icon
            end
        end
        for i = 1, #self.icon_type6_list do
            if self.icon_type6_list[i].id == id then
                return self.icon_type6_list[i].icon
            end
        end
        return nil
    end
end

-- 按id获取按钮对象的坐标
function MainUIIconView:getbuttonpositionbyid(id)
    local icon = self:getbuttonbyid(id)
    if icon ~= nil then
        local position = ctx.UICamera:WorldToScreenPoint(icon.transform.position)
        local rect = icon:GetComponent(RectTransform)
        for k, v in pairs(DataSystem.data_icon) do
            if v.id == id then
                if v.icon_type == 1 or v.icon_type == 4 then
                    return Vector3(position.x, position.y + rect.rect.height/2, 0)
                elseif v.icon_type == 2 then
                    return Vector3(position.x + rect.rect.width/2, position.y - rect.rect.height/2, 0)
                elseif v.icon_type == 3 then
                    return Vector3(position.x + rect.rect.width/2, position.y + rect.rect.height/2, 0)
                end
            end
        end
    end
    return nil
end

-- 收缩按钮 Mark
function MainUIIconView:iconSwitcher_click()
    if self.isiconshow then
        self:hidebaseicon()
        self:showbaseicon4()
    else
        self:hidebaseicon4()
        self:showbaseicon(true)
    end

    self:SetSwitchRedPoint()

    self:CheckGuidePoint()
    -- ---------------------------------------------
    -- 缓动测试代码
    -- ---------------------------------------------
    -- 写法1,标准写法
    -- local descr1 = Tween.Instance:Rotate(self.iconSwitcher:GetComponent(RectTransform), 90, 5, function() print("旋转结束") end, LeanTweenType.linear)

    --写法2,有特殊需求时使用
    -- local descr2 = Tween.Instance:Scale(self.iconSwitcher, Vector3.one * 0.5, 1)
    -- descr2:setDelay(1)
    -- descr2:setOnComplete(function() print("缓动结束") Tween.Instance:Resume(descr1.id) end)
    -- descr2:setOnStart(function() print("缓动开始") Tween.Instance:Pause(descr1.id) end)
end

function MainUIIconView:showbaseicon(rotation, notween)
    self.isiconshow = true

    local index = 0
    if self.iconSwitcher == nil then return end
    local switcherx = self.iconSwitcher.transform.localPosition.x

    local level = RoleManager.Instance.RoleData.lev
    local cross_type = RoleManager.Instance.RoleData.cross_type

    for i = 1, #self.icon_type1_list do
        local icondata = self.icon_type1_list[i]
        local crossserver_hide_icon = DataSystem.data_crossserver_hide_icon[icondata.id]
        if icondata.lev <= level and (not self.hide_icon_id_list[icondata.id]) then
            icondata.icon:SetActive(true)
            local startposition = icondata.icon:GetComponent(RectTransform).anchoredPosition
            local endposition = Vector2(switcherx + self.systemicon_startx + index * self.systemicon_width, self.systemicon_starty)
            -- if not notween then
            --     tween:DoPosition_CallBack(icondata.icon, startposition, endposition, 0.3, "ui_basefunctioiconarea.setactive_true", "linear", 2)
            -- else
            --     icondata.icon:GetComponent(RectTransform).anchoredPosition = endposition
            -- end
            icondata.icon:GetComponent(RectTransform).anchoredPosition = endposition
            icondata.icon.transform.localScale = Vector3.one

            index = index + 1

            if cross_type == 1 and crossserver_hide_icon ~= nil then
                if crossserver_hide_icon.hide_type == 1 then
                    icondata.icon:SetActive(false)
                    index = index - 1
                elseif crossserver_hide_icon.hide_type == 2 then
                    icondata.dark = true
                    icondata.icon:GetComponent(Image).color = Color(0.5, 0.5, 0.5)
                end
            elseif cross_type == 0 and icondata.dark then
                icondata.dark = false
                icondata.icon:GetComponent(Image).color = Color.white
            end
        else
            icondata.icon:SetActive(false)
        end
    end

    -- if rotation then
    --     tween:DoRotation(iconSwitcher_image, Vector3.zero, Vector3(0, 0, -135), 0.3)
    -- end
    -- self.iconSwitcher_image.transform.localRotation = Quaternion.identity
    -- self.iconSwitcher_image.transform:Rotate(Vector3(0, 0, -135))
    self.iconSwitcher_image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "IconSwitcher1")

    -- if hidebaseicon_timer ~= nil then
    --     ctx.TimerManager:Remove_interval_lsnr("ui_basefunctioiconarea.hidebaseicon")
    --     hidebaseicon_timer:RemoveListener(ui_basefunctioiconarea.hidebaseicon)
    --     hidebaseicon_timer = nil
    -- end
    -- if not GuideManager.Instance.isfunctionguide then
    --     hidebaseicon_timer = ctx.TimerManager:GetIntervalTimeEvent(20, "ui_basefunctioiconarea.hidebaseicon")
    --     hidebaseicon_timer:AddListener(ui_basefunctioiconarea.hidebaseicon)
    -- end

    if BaseUtils.IsVerify then
        BaseUtils.VestChangeSprite(self.iconSwitcher_image)
    end
end

function MainUIIconView:hidebaseicon()
    -- if game_status.isFight then
    --     return
    -- end
    -- if GuideManager.Instance.isfunctionguide then
    --     return
    -- end
    self.isiconshow = false

    local gotoX = self.iconSwitcher.transform.localPosition.x

    for i = 1, #self.icon_type1_list do
        local icondata = self.icon_type1_list[i]

        local startposition = icondata.icon:GetComponent(RectTransform).anchoredPosition
        local endposition = Vector2(gotoX, startposition.y)
        -- tween:DoPosition_CallBack(icondata.icon, startposition, endposition, 0.3, "ui_basefunctioiconarea.setactive_false", "linear", 2)
        icondata.icon:GetComponent(RectTransform).anchoredPosition = endposition
        icondata.icon:SetActive(false)
    end

    -- tween:DoRotation(iconSwitcher_image, Vector3(0, 0, 225), Vector3(0, 0, 360), 0.3)
    -- self.iconSwitcher_image.transform.localRotation = Quaternion.identity
    -- self.iconSwitcher_image.transform:Rotate(Vector3(0, 0, 360))
    self.iconSwitcher_image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "IconSwitcher2")

    -- if hidebaseicon_timer ~= nil then
    --     ctx.TimerManager:Remove_interval_lsnr("ui_basefunctioiconarea.hidebaseicon")
    --     hidebaseicon_timer:RemoveListener(ui_basefunctioiconarea.hidebaseicon)
    --     hidebaseicon_timer = nil
    -- end

    if BaseUtils.IsVerify then
        BaseUtils.VestChangeSprite(self.iconSwitcher_image)
    end
end

function MainUIIconView.iconSwitcher2_click()
    if self.isiconshow2 then
        self:hidebaseicon2()
    else
        self:showbaseicon2()
    end
end

function MainUIIconView:showbaseicon2()
    self.isiconshow2 = true

    local index = 0
    local switchery = self.othericon_starty--iconSwitcher2.transform.localPosition.y

    local level = RoleManager.Instance.RoleData.lev
    local cross_type = RoleManager.Instance.RoleData.cross_type

    for i = 1, #self.icon_type2_list do
        local icondata = self.icon_type2_list[i]
        local crossserver_hide_icon = DataSystem.data_crossserver_hide_icon[icondata.id]
        if icondata.lev <= level and (not self.hide_icon_id_list[icondata.id]) then
            icondata.icon:SetActive(true)
            local startposition = icondata.icon:GetComponent(RectTransform).anchoredPosition
            local endposition = Vector2(self.othericon_startx, self.othericon_starty + index * self.othericon_height)
            -- tween:DoPosition_CallBack(icondata.icon, startposition, endposition, 0.5, "ui_basefunctioiconarea.setactive_true", "linear", 2)
            icondata.icon:GetComponent(RectTransform).anchoredPosition = endposition
            icondata.icon.transform.localScale = Vector3.one
            index = index + 1

            if cross_type == 1 and crossserver_hide_icon ~= nil then
                if crossserver_hide_icon.hide_type == 1 then
                    icondata.icon:SetActive(false)
                    index = index - 1
                elseif crossserver_hide_icon.hide_type == 2 then
                    icondata.dark = true
                    icondata.icon:GetComponent(Image).color = Color(0.5, 0.5, 0.5)
                end
            elseif cross_type == 0 and icondata.dark then
                icondata.dark = false
                icondata.icon:GetComponent(Image).color = Color.white
            end
        else
            icondata.icon:SetActive(false)
        end
    end

    -- tween:DoRotation(iconSwitcher2_image, Vector3(0, 0, -180), Vector3(0, 0, -360), 0.5)
    -- iconSwitcher2_image.transform.localRotation = Quaternion.identity
    -- iconSwitcher2_image.transform:Rotate(Vector3(0, 0, -360))
end

function MainUIIconView:hidebaseicon2()
    self.isiconshow2 = false

    local gotoY = self.othericon_starty --iconSwitcher2.transform.localPosition.y - 50

    for i = 1, #self.icon_type2_list do
        local icondata = self.icon_type2_list[i]

        local startposition = icondata.icon:GetComponent(RectTransform).anchoredPosition
        local endposition = Vector2(startposition.x, gotoY)
        -- tween:DoPosition_CallBack(icondata.icon, startposition, endposition, 0.5, "ui_basefunctioiconarea.setactive_false", "linear", 2)
        icondata.icon:GetComponent(RectTransform).anchoredPosition = endposition
        icondata.icon:SetActive(false)
    end

    -- tween:DoRotation(iconSwitcher2_image, Vector3.zero, Vector3(0, 0, 180), 0.5)
    -- iconSwitcher2_image.transform.localRotation = Quaternion.identity
    -- iconSwitcher2_image.transform:Rotate(Vector3(0, 0, 180))
end

function MainUIIconView:showbaseicon3()
    self.isiconshow3 = true
    -- local level = RoleManager.Instance.RoleData.lev
    -- local cross_type = RoleManager.Instance.RoleData.cross_type
    -- local index = 0
    -- for i = 1, #self.icon_type3_list do
    --     local icondata = self.icon_type3_list[i]
    --     local crossserver_hide_icon = DataSystem.data_crossserver_hide_icon[icondata.id]
    --     if icondata.lev <= level and (not self.hide_icon_id_list[icondata.id])
    --         and self:checkIconGroup(self.icon_type3_list, icondata.id)
    --         and (self.show_top or table.containValue(self.show_top_exception_list, icondata.id)) then
    --         icondata.icon:SetActive(true)
    --         if DataSystem.data_festival_icon[1] ~= nil and table.containValue(DataSystem.data_festival_icon[1], icondata.iconPath) then
    --             icondata.icon.transform:SetParent(icondata.parent)
    --         end
    --         icondata.icon.transform:GetComponent(RectTransform).anchoredPosition =
    --             Vector2(self.ativeicon_startx + index * self.ativeicon_width, self.ativeicon_starty)
    --         icondata.icon.transform.localScale = Vector3.one
    --         index = index + 1

    --         if cross_type == 1 and crossserver_hide_icon ~= nil then
    --             if crossserver_hide_icon.hide_type == 1 then
    --                 icondata.icon:SetActive(false)
    --                 index = index - 1
    --             elseif crossserver_hide_icon.hide_type == 2 then
    --                 icondata.dark = true
    --                 icondata.icon:GetComponent(Image).color = Color(0.5, 0.5, 0.5)
    --             end
    --         elseif cross_type == 0 and icondata.dark then
    --             icondata.dark = false
    --             icondata.icon:GetComponent(Image).color = Color.white
    --         end
    --         if DataSystem.data_festival_icon[1] ~= nil and table.containValue(DataSystem.data_festival_icon[1], icondata.iconPath) then
    --             icondata.icon.transform:SetParent(self.iconPanelRect8.transform)
    --         end
    --     else
    --         icondata.icon:SetActive(false)
    --     end
    -- end

    self:FoldIcon3(self:get_ativeIconPanel_fold() == 1)
end

function MainUIIconView:hidebaseicon3()
    self.isiconshow3 = false

    local gotoY = self.othericon_starty --iconSwitcher2.transform.localPosition.y - 50

    for i = 1, #self.icon_type3_list do
        local icondata = self.icon_type3_list[i]

        local startposition = icondata.icon:GetComponent(RectTransform).anchoredPosition
        local endposition = Vector2(startposition.x, gotoY)
        -- tween:DoPosition_CallBack(icondata.icon, startposition, endposition, 0.5, "ui_basefunctioiconarea.setactive_false", "linear", 2)
        icondata.icon:GetComponent(RectTransform).anchoredPosition = endposition
        icondata.icon:SetActive(false)
    end

    -- tween:DoRotation(iconSwitcher2_image, Vector3.zero, Vector3(0, 0, 180), 0.5)
    -- iconSwitcher2_image.transform.localRotation = Quaternion.identity
    -- iconSwitcher2_image.transform:Rotate(Vector3(0, 0, 180))
end

function MainUIIconView:showbaseicon4(notween)
    local index = 0
    if self.iconSwitcher == nil then return end
    local switcherx = self.iconSwitcher.transform.localPosition.x

    local level = RoleManager.Instance.RoleData.lev
    local cross_type = RoleManager.Instance.RoleData.cross_type
    for i = 1, #self.icon_type4_list do
        local icondata = self.icon_type4_list[i]
        local crossserver_hide_icon = DataSystem.data_crossserver_hide_icon[icondata.id]
        if icondata.lev <= level and (not self.hide_icon_id_list[icondata.id]) then
            icondata.icon:SetActive(true)
            local startposition = icondata.icon:GetComponent(RectTransform).anchoredPosition
            local endposition = Vector2(switcherx + self.systemicon_startx + index * self.systemicon_width, self.systemicon_starty)
            -- if not notween then
            --     tween:DoPosition_CallBack(icondata.icon, startposition, endposition, 0.3, "ui_basefunctioiconarea.setactive_true", "linear", 2)
            -- else
            --     icondata.icon:GetComponent(RectTransform).anchoredPosition = endposition
            -- end
            icondata.icon:GetComponent(RectTransform).anchoredPosition = endposition
            icondata.icon.transform.localScale = Vector3.one

            index = index + 1

            if cross_type == 1 and crossserver_hide_icon ~= nil then
                if crossserver_hide_icon.hide_type == 1 then
                    icondata.icon:SetActive(false)
                    index = index - 1
                elseif crossserver_hide_icon.hide_type == 2 then
                    icondata.dark = true
                    icondata.icon:GetComponent(Image).color = Color(0.5, 0.5, 0.5)
                end
            elseif cross_type == 0 and icondata.dark then
                icondata.dark = false
                icondata.icon:GetComponent(Image).color = Color.white
            end
        else
            icondata.icon:SetActive(false)
        end
    end
end

function MainUIIconView:hidebaseicon4()
    -- if game_status.isFight then
    --     return
    -- end
    -- if GuideManager.Instance.isfunctionguide then
    --     return
    -- end
    if BaseUtils.isnull(self.iconSwitcher) then
        return
    end

    local gotoX = self.iconSwitcher.transform.localPosition.x

    for i = 1, #self.icon_type4_list do
        local icondata = self.icon_type4_list[i]

        local startposition = icondata.icon:GetComponent(RectTransform).anchoredPosition
        local endposition = Vector2(gotoX, startposition.y)

        -- tween:DoPosition_CallBack(icondata.icon, startposition, endposition, 0.3, "ui_basefunctioiconarea.setactive_false", "linear", 2)
        icondata.icon:GetComponent(RectTransform).anchoredPosition = endposition
        icondata.icon:SetActive(false)
    end
end

function MainUIIconView:showbaseicon5()
    self.isiconshow5 = true
    local level = RoleManager.Instance.RoleData.lev
    local cross_type = RoleManager.Instance.RoleData.cross_type
    local index = 0

    for i = 1, #self.icon_type5_list do
        local icondata = self.icon_type5_list[i]
        local crossserver_hide_icon = DataSystem.data_crossserver_hide_icon[icondata.id]
        if icondata.lev <= level and (not self.hide_icon_id_list[icondata.id])
            and self:checkIconGroup(self.icon_type5_list, icondata.id)
            and (self.show_top or table.containValue(self.show_top_exception_list, icondata.id)) then
            icondata.icon:SetActive(true)
            if DataSystem.data_festival_icon[1] ~= nil and table.containValue(DataSystem.data_festival_icon[1], icondata.iconPath) then
                icondata.icon.transform:SetParent(icondata.parent)
            end
            icondata.icon.transform:GetComponent(RectTransform).anchoredPosition =
                Vector2(self.ativeicon2_startx + index * self.ativeicon2_width, self.ativeicon2_starty)
            index = index + 1

            if cross_type == 1 and crossserver_hide_icon ~= nil then
                if crossserver_hide_icon.hide_type == 1 then
                    icondata.icon:SetActive(false)
                    index = index - 1
                elseif crossserver_hide_icon.hide_type == 2 then
                    icondata.dark = true
                    icondata.icon:GetComponent(Image).color = Color(0.5, 0.5, 0.5)
                end
            elseif cross_type == 0 and icondata.dark then
                icondata.dark = false
                icondata.icon:GetComponent(Image).color = Color.white
            end
            if DataSystem.data_festival_icon[1] ~= nil and table.containValue(DataSystem.data_festival_icon[1], icondata.iconPath) then
                icondata.icon.transform:SetParent(self.iconPanelRect8.transform)
            end
        else
            icondata.icon:SetActive(false)
        end
    end
end


function MainUIIconView:hidebaseicon5()
    self.isiconshow5 = false
    if BaseUtils.isnull(self.iconSwitcher) then
        return
    end

    local gotoX = self.iconSwitcher.transform.localPosition.x

    for i = 1, #self.icon_type5_list do
        local icondata = self.icon_type5_list[i]

        local startposition = icondata.icon:GetComponent(RectTransform).anchoredPosition
        local endposition = Vector2(gotoX, startposition.y)

        -- tween:DoPosition_CallBack(icondata.icon, startposition, endposition, 0.3, "ui_basefunctioiconarea.setactive_false", "linear", 2)
        icondata.icon:GetComponent(RectTransform).anchoredPosition = endposition
        icondata.icon:SetActive(false)
    end
end

function MainUIIconView:showbaseicon6()
    self.isiconshow6 = true
    local level = RoleManager.Instance.RoleData.lev
    local cross_type = RoleManager.Instance.RoleData.cross_type
    local index = 0

    for i = 1, #self.icon_type6_list do
        local icondata = self.icon_type6_list[i]
        local crossserver_hide_icon = DataSystem.data_crossserver_hide_icon[icondata.id]
        if icondata.lev <= level and (not self.hide_icon_id_list[icondata.id])
            and self:checkIconGroup(self.icon_type6_list, icondata.id)
            and (self.show_leftbottom or table.containValue(self.show_leftbottom_exception_list, icondata.id)) then
            icondata.icon:SetActive(true)
            if DataSystem.data_festival_icon[1] ~= nil and table.containValue(DataSystem.data_festival_icon[1], icondata.iconPath) then
                icondata.icon.transform:SetParent(icondata.parent)
            end
            icondata.icon.transform:GetComponent(RectTransform).anchoredPosition =
                Vector2(self.ativeicon3_startx + index * self.ativeicon3_width, self.ativeicon3_starty)
            index = index + 1

            if cross_type == 1 and crossserver_hide_icon ~= nil then
                if crossserver_hide_icon.hide_type == 1 then
                    icondata.icon:SetActive(false)
                    index = index - 1
                elseif crossserver_hide_icon.hide_type == 2 then
                    icondata.dark = true
                    icondata.icon:GetComponent(Image).color = Color(0.5, 0.5, 0.5)
                end
            elseif cross_type == 0 and icondata.dark then
                icondata.dark = false
                icondata.icon:GetComponent(Image).color = Color.white
            end
            if DataSystem.data_festival_icon[1] ~= nil and table.containValue(DataSystem.data_festival_icon[1], icondata.iconPath) then
                icondata.icon.transform:SetParent(self.iconPanelRect7.transform)
            end
        else
            icondata.icon:SetActive(false)
        end
    end
end

function MainUIIconView:hidebaseicon6()
    self.isiconshow6 = false

    local gotoY = self.othericon_starty --iconSwitcher2.transform.localPosition.y - 50

    for i = 1, #self.icon_type6_list do
        local icondata = self.icon_type6_list[i]

        local startposition = icondata.icon:GetComponent(RectTransform).anchoredPosition
        local endposition = Vector2(startposition.x, gotoY)
        -- tween:DoPosition_CallBack(icondata.icon, startposition, endposition, 0.5, "ui_basefunctioiconarea.setactive_false", "linear", 2)
        icondata.icon:GetComponent(RectTransform).anchoredPosition = endposition
        icondata.icon:SetActive(false)
    end

    -- tween:DoRotation(iconSwitcher2_image, Vector3.zero, Vector3(0, 0, 180), 0.5)
    -- iconSwitcher2_image.transform.localRotation = Quaternion.identity
    -- iconSwitcher2_image.transform:Rotate(Vector3(0, 0, 180))
end
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
function MainUIIconView:mainui_icon_update(iconId, show, args)
    self:set_icon_Redpoint_by_id(iconId, show)
    -- for k,v in pairs(args) do
    --     print(v)
    -- end
end

function MainUIIconView:refresh_icon()
    if self.isiconshow6 then
        self:showbaseicon6()
    end
    if self.isiconshow5 then
        self:showbaseicon5()
    end
    self:hidebaseicon4()
    if self.isiconshow3 then
        self:showbaseicon3()
    end
    if self.isiconshow2 then
        self:showbaseicon2()
    end
    self:showbaseicon()

    self:CheckRed()
    self:CheckGuidePoint()
end

function MainUIIconView:hide_icon_by_idlist(id, hide)
    self.hide_icon_id_list[id] = hide
    for k, v in pairs(DataSystem.data_icon) do
        if v.id == id then
            if v.icon_type == 1 or v.icon_type == 4 then
                self:showbaseicon(false)
            elseif v.icon_type == 2 then
                self:showbaseicon2()
            elseif v.icon_type == 3 then
                if self.isiconshow3 then
                    self:showbaseicon3()
                end
            end
        end
    end
    self:showbaseicon6()
end

function MainUIIconView:set_icon_Redpoint_by_id(id, show)
    local cross_type = RoleManager.Instance.RoleData.cross_type
    for k, v in pairs(DataSystem.data_icon) do
        if v.id == id then
            if v.icon ~= nil then
                v.showRedpoint = show

                local canShowRedPoint = true
                local crossserver_hide_icon = DataSystem.data_crossserver_hide_icon[v.id]
                if cross_type == 1 and crossserver_hide_icon ~= nil then
                    if crossserver_hide_icon.hide_type == 2 then
                        canShowRedPoint = false
                    end
                end

                local redpoint = v.icon.transform:Find("RedPointImage")
                if redpoint ~= nil then
                    redpoint.transform.sizeDelta = Vector2(24, 24)
                    redpoint.transform.localScale = Vector3.one
                    redpoint.gameObject:SetActive(show == true and canShowRedPoint)
                end
            end
        end
    end

    for i,v in ipairs(self.icon_type3_list) do
        if v.isAtiveIconIcon == true and v.id == id then
            if v.icon ~= nil then
                v.showRedpoint = show

                local canShowRedPoint = true
                local crossserver_hide_icon = DataSystem.data_crossserver_hide_icon[v.id]
                if cross_type == 1 and crossserver_hide_icon ~= nil then
                    if crossserver_hide_icon.hide_type == 2 then
                        canShowRedPoint = false
                    end
                end

                local redpoint = v.icon.transform:Find("RedPointImage")
                if redpoint ~= nil then
                    redpoint.transform.sizeDelta = Vector2(24, 24)
                    redpoint.transform.localScale = Vector3.one
                    redpoint.gameObject:SetActive(show == true and canShowRedPoint)
                end
            end
        end
    end

    for i,v in ipairs(self.icon_type5_list) do
        if v.isAtiveIconIcon == true and v.id == id then
            if v.icon ~= nil then
                v.showRedpoint = show

                local canShowRedPoint = true
                local crossserver_hide_icon = DataSystem.data_crossserver_hide_icon[v.id]
                if cross_type == 1 and crossserver_hide_icon ~= nil then
                    if crossserver_hide_icon.hide_type == 2 then
                        canShowRedPoint = false
                    end
                end

                local redpoint = v.icon.transform:Find("RedPointImage")
                if redpoint ~= nil then
                    redpoint.transform.sizeDelta = Vector2(24, 24)
                    redpoint.transform.localScale = Vector3.one
                    redpoint.gameObject:SetActive(show == true and canShowRedPoint)
                end
            end
        end
    end

    for i,v in ipairs(self.icon_type6_list) do
        if v.isAtiveIconIcon == true and v.id == id then
            if v.icon ~= nil then
                v.showRedpoint = show

                local canShowRedPoint = true
                local crossserver_hide_icon = DataSystem.data_crossserver_hide_icon[v.id]
                if cross_type == 1 and crossserver_hide_icon ~= nil then
                    if crossserver_hide_icon.hide_type == 2 then
                        canShowRedPoint = false
                    end
                end

                local redpoint = v.icon.transform:Find("RedPointImage")
                if redpoint ~= nil then
                    redpoint.transform.sizeDelta = Vector2(24, 24)
                    redpoint.transform.localScale = Vector3.one
                    redpoint.gameObject:SetActive(show == true and canShowRedPoint)
                end
            end
        end
    end

    self:SetSwitchRedPoint()
end

function MainUIIconView:SetSwitchRedPoint()
    self.switchRedStatus = false
    for i = 1, #self.icon_type1_list do
        local icon = self.icon_type1_list[i].icon
        if icon ~= nil and icon.transform:Find("RedPointImage") ~= nil then
            self.switchRedStatus = self.switchRedStatus or icon.transform:Find("RedPointImage").gameObject.activeSelf
        end
    end

    self.switchRedStatus2 = false
    for i=1,#self.icon_type4_list do
        local icon = self.icon_type4_list[i].icon
        if icon ~= nil and icon.transform:Find("RedPointImage") ~= nil then
            self.switchRedStatus2 = self.switchRedStatus2 or icon.transform:Find("RedPointImage").gameObject.activeSelf
        end
    end

    if self.iconSwitcher ~= nil then
        if self.isiconshow == true then
            self.iconSwitcher.transform:Find("RedPointImage").gameObject:SetActive(self.switchRedStatus2)
        else
            self.iconSwitcher.transform:Find("RedPointImage").gameObject:SetActive(self.switchRedStatus)
        end
    end
end

-- 增加动态活动图标
function MainUIIconView:AddAtiveIcon(data)
    local data_daily_icon = DataSystem.data_daily_icon[data.id]
    if data_daily_icon ~= nil then
        data.fold_type = data_daily_icon.fold_type
    end

    self:DelAtiveIcon(data.id)

    local iconData = data
    iconData.icon_name = "NewIconButton"
    iconData.icon_type = 3
    iconData.icon_show_type = 1
    iconData.boolean_type = 0
    iconData.parent = self.ativeIconPanel.transform

    local icon = self:CreateAtiveIcon(iconData, self.newicon_gameobject)
    table.insert(self.icon_type3_list, iconData)
    table.insert(self.ativeicon1, data.id)
    table.sort(self.icon_type3_list, self.sortfun)
    if self.isiconshow3 then
        self:showbaseicon3()
    end

    return icon
end

-- 删除动态活动图标 删除图标不会触发 clickCallBack timeoutCallBack 回调
function MainUIIconView:DelAtiveIcon(id)
    local index = nil
    local iconData = nil
    for i,v in ipairs(self.icon_type3_list) do
        if v.id == id then
            index = i
            iconData = v
        end
    end

    if iconData == nil then
        return
    end
    if iconData.timerId ~= nil then LuaTimer.Delete(iconData.timerId) end
    if iconData.singleIconLoader ~= nil then iconData.singleIconLoader:DeleteMe() end
    if iconData.icon ~= nil then GameObject.Destroy(iconData.icon) end
    table.remove(self.icon_type3_list, index)
    for i,v in ipairs(self.ativeicon1) do
        if v == id then
            index = i
        end
    end
    table.remove(self.ativeicon1, index)

    table.sort(self.icon_type3_list, self.sortfun)

    if self.isiconshow3 then
        self:showbaseicon3()
    end
end

-- 增加动态活动图标
function MainUIIconView:AddAtiveIcon2(data)
    self:DelAtiveIcon2(data.id)

    local iconData = data
    iconData.icon_name = "NewIconButton"
    iconData.icon_type = 5
    iconData.icon_show_type = 1
    iconData.boolean_type = 0
    iconData.parent = self.ativeIconPanel2.transform

    local icon = self:CreateAtiveIcon(iconData, self.newicon_gameobject)
    table.insert(self.icon_type5_list, iconData)
    table.insert(self.ativeicon2, data.id)
    table.sort(self.icon_type5_list, self.sortfun)

    if self.isiconshow3 then
        self:showbaseicon5()
    end

    return icon
end

-- 删除动态活动图标 删除图标不会触发 clickCallBack timeoutCallBack 回调
function MainUIIconView:DelAtiveIcon2(id)
    local index = nil
    local iconData = nil
    for i,v in ipairs(self.icon_type5_list) do
        if v.id == id then
            index = i
            iconData = v
        end
    end

    if iconData == nil then
        return
    end
    if iconData.timerId ~= nil then LuaTimer.Delete(iconData.timerId) end
    if iconData.singleIconLoader ~= nil then iconData.singleIconLoader:DeleteMe() end
    if iconData.icon ~= nil then GameObject.Destroy(iconData.icon) end
    table.remove(self.icon_type5_list, index)
    for i,v in ipairs(self.ativeicon2) do
        if v == id then
            index = i
        end
    end
    table.remove(self.ativeicon2, index)

    table.sort(self.icon_type5_list, self.sortfun)

    self:showbaseicon5()
end


-- 增加动态活动图标
function MainUIIconView:AddAtiveIcon3(data)
    self:DelAtiveIcon3(data.id)

    local iconData = data
    iconData.icon_name = "NewIconButton"
    iconData.icon_type = 6
    iconData.icon_show_type = 1
    iconData.boolean_type = 0
    iconData.parent = self.ativeIconPanel3.transform

    local icon = self:CreateAtiveIcon(iconData, self.newicon_gameobject3)
    table.insert(self.icon_type6_list, iconData)
    table.insert(self.ativeicon3, data.id)
    table.sort(self.icon_type6_list, self.sortfun)

    self:showbaseicon6()

    return icon
end

-- 删除动态活动图标 删除图标不会触发 clickCallBack timeoutCallBack 回调
function MainUIIconView:DelAtiveIcon3(id)
    local index = nil
    local iconData = nil
    for i,v in ipairs(self.icon_type6_list) do
        if v.id == id then
            index = i
            iconData = v
        end
    end

    if iconData == nil then
        return
    end
    if iconData.timerId ~= nil then LuaTimer.Delete(iconData.timerId) end
    if iconData.singleIconLoader ~= nil then iconData.singleIconLoader:DeleteMe() end
    if iconData.icon ~= nil then GameObject.Destroy(iconData.icon) end
    table.remove(self.icon_type6_list, index)
    for i,v in ipairs(self.ativeicon3) do
        if v == id then
            index = i
        end
    end
    table.remove(self.ativeicon3, index)

    table.sort(self.icon_type6_list, self.sortfun)

    self:showbaseicon6()
end

-- 创建动态活动图标对象
function MainUIIconView:CreateAtiveIcon(data, newicon_gameobject)
    local iconObject = GameObject.Instantiate(newicon_gameobject)
    -- UIUtils.AddUIChild(self.ativeIconPanel, iconObject)
    iconObject.transform:SetParent(data.parent)
    iconObject.transform.localPosition = Vector3(0, 0, 0)
    iconObject:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)


    if DataSystem.data_festival_icon[1] ~= nil and table.containValue(DataSystem.data_festival_icon[1], data.iconPath) then
        local singleIconLoader = SingleIconLoader.New(iconObject)
        if CampaignManager.Instance.model.isSpecialIcon == true then
            singleIconLoader:SetSprite(SingleIconType.MianUI, "358")
            CampaignManager.Instance.model.isSpecialIcon = false
        else
            singleIconLoader:SetSprite(SingleIconType.MianUI, data.iconPath)
        end

        data.singleIconLoader = singleIconLoader
    else
        if CampaignManager.Instance.model.isSpecialIcon == true then
            iconObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "358")
            CampaignManager.Instance.model.isSpecialIcon = false
        else
            iconObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, data.iconPath)
        end
    end

    iconObject:GetComponent(Button).onClick:AddListener(function()
        if data.clickCallBack ~= nil then
            data.clickCallBack()
        else
            Log.Error(string.format("活动图标没有回调函数：id = %s", data.id))
        end
    end)
    data.icon = iconObject


    if data.text ~= nil then
        local textBG = iconObject.transform:FindChild("TextBG").gameObject
        local text = textBG.transform:FindChild("Text"):GetComponent(Text)
        text.text = data.text
        textBG:SetActive(true)
    end

    if data.timestamp ~= nil then
        local timeBG = iconObject.transform:FindChild("TimeBG").gameObject
        local timeText = timeBG.transform:FindChild("TimeText"):GetComponent(Text)
        local timeOut = data.timestamp
        local callBack = data.timeoutCallBack
        local timerId = nil
        local fun = function()
            if timeOut >= Time.time then
                -- timeText.text = BaseUtils.formate_time_gap(timeOut - Time.time, ":", 0, BaseUtils.time_formate.MIN)
                if data.id == 204 or data.id == 205 or data.id == 119 or data.id == 379 then --限时返利
                    timeText.text = self:GetTimeStr(timeOut - Time.time,data)
                else
                    timeText.text = self:GetTimeStr(timeOut - Time.time)
                end
            else
                if callBack ~= nil then
                    LuaTimer.Delete(timerId) callBack()
                end
            end
        end
        timerId = LuaTimer.Add(10, 1000, fun)
        data.timerId = timerId
        if timeOut >= Time.time then
            -- timeText.text = BaseUtils.formate_time_gap(timeOut - Time.time, ":", 0, BaseUtils.time_formate.MIN)
            if data.id == 204 or data.id == 205 or data.id == 119 or data.id == 379 then --限时返利
                timeText.text = self:GetTimeStr(timeOut - Time.time,data)
            else
                timeText.text = self:GetTimeStr(timeOut - Time.time)
            end
            timeText.gameObject:SetActive(true)
            timeBG:SetActive(true)
            -- timeBG.transform.localPosition = Vector3(2, -67, 0)
        end
    end

    if data.createCallBack ~= nil then
        data.createCallBack(iconObject)
    end
    if data.effectId ~= nil and data.effectId ~= 0 then
        local fun = function(effectView)
            local effectObject = effectView.gameObject
            if BaseUtils.isnull(iconObject) then
                effectView:DeleteMe()
                return
            end
            effectObject.name = "Effect"
            effectObject.transform:SetParent(iconObject.transform)
            effectObject.transform.localScale = data.effectScale ~= nil and data.effectScale or Vector3.one
            effectObject.transform.localPosition = data.effectPos ~= nil and data.effectPos or Vector3.zero
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            effectObject:SetActive(true)
        end
        BaseEffectView.New({effectId = data.effectId, time = nil, callback = fun})
    end
    return iconObject
end

function MainUIIconView:GetTimeStr(time,data)
    if data ~= nil then
        if data.id == 204 or data.id == 205 then
            local day,hour,min,second = BaseUtils.time_gap_to_timer(math.floor(time))
            -- min = min + hour * 60
            local timeStr = tostring(hour)
            if hour < 10 then
                timeStr = string.format("0%d",hour)
            end
            if min < 10 then
                timeStr = string.format("%s:0%d",timeStr,min)
            else
                timeStr = string.format("%s:%d",timeStr,min)
            end
            if second < 10 then
                timeStr = string.format("<color='#13fc60'>%s:0%d</color>",timeStr,second)
            else
                timeStr = string.format("<color='#13fc60'>%s:%d</color>",timeStr,second)
            end
            -- local itemData = BibleManager.Instance.model.bibleList[9]
            -- if BibleManager.Instance ~= nil and itemData ~= nil
            --     and BibleManager.Instance.model ~= nil
            --     and BibleManager.Instance.model.bibleWin ~= nil
            --     and BibleManager.Instance.model.bibleWin.panelList ~= nil and BibleManager.Instance.model.bibleWin.panelList[1] ~= nil
            --     and BibleManager.Instance.model.bibleWin.panelList[1].tabGroupTimeText[itemData.key] ~= nil then
            --     self.timeText = BibleManager.Instance.model.bibleWin.panelList[1].tabGroupTimeText[itemData.key]
            --     self.timeText.supportRichText = true
            --     self.timeText.gameObject:SetActive(true)
            --     self.timeText.text = timeStr
            -- end
            return timeStr
        elseif data.id == 119 then
            local timeStr = ""
            local day,hour,min,second = BaseUtils.time_gap_to_timer(math.floor(time))
            if day > 1 then
                timeStr = string.format(TI18N("%s天后开启"), day)
            elseif day > 0 then
                timeStr = TI18N("明天开启")
            elseif hour > 0 then
                if min < 10 then
                    timeStr = string.format(TI18N("%s:0%s后开启"), hour, min)
                else
                    timeStr = string.format(TI18N("%s:%s后开启"), hour, min)
                end
            elseif min > 0 then
                timeStr = string.format(TI18N("%s分后开启"), min)
            else
                timeStr = TI18N("1分后开启")
            end
            return timeStr
        elseif data.id == 379 then
            local timeStr = ""
            local day,hour,min,second = BaseUtils.time_gap_to_timer(math.floor(time))
            if day > 1 then
                timeStr = string.format(TI18N("%s天后开启"), day)
            elseif day > 0 then
                timeStr = TI18N("明天开启")
            elseif hour > 0 then
                if min < 10 then
                    timeStr = string.format(TI18N("%s:0%s后开启"), hour, min)
                else
                    timeStr = string.format(TI18N("%s:%s后开启"), hour, min)
                end
            elseif min > 0 then
                timeStr = string.format(TI18N("%s分后开启"), min)
            else
                timeStr = TI18N("1分后开启")
            end
            return timeStr
        end
    else
        if time < 60 then
            return string.format(TI18N("剩余%s秒"), math.floor(time))
        elseif time < 3600 then
            return string.format(TI18N("剩余%s分"), math.floor(time/60))
        else
            return string.format(TI18N("剩余%s小时"), math.floor(time/3600))
        end
    end
end

function MainUIIconView:AddAtiveIcon_ByCache()
    for k, v in pairs(MainUIManager.Instance.ativeicon_cache) do
        self:AddAtiveIcon(v)
    end

    for k, v in pairs(MainUIManager.Instance.ativeicon_cache2) do
        self:AddAtiveIcon2(v)
    end

    for k, v in pairs(MainUIManager.Instance.ativeicon_cache3) do
        self:AddAtiveIcon3(v)
    end
end

function MainUIIconView:Set_ShowTop(show, exception_list)
    -- Log.Error(debug.traceback())
    -- print(debug.traceback())
    -- print(show)
    self.show_top = show
    if exception_list == nil then
        self.show_top_exception_list = {}
    else
        self.show_top_exception_list = exception_list
    end
    if self.isiconshow3 then
        -- print('328974444444444382745823784728=============================================================================================================================================================================================================')
        --BaseUtils.dump(self.show_top_exception_list,"dskfjklsdjfklsdjfklsdjklfjsdklfjsdkljfklsdjfklsdjfklsdjfklsdjf")

        self:showbaseicon3()
    end
    self:showbaseicon5()
end

function MainUIIconView:Set_ShowLeftBottom(show, exception_list)
    -- Log.Error(debug.traceback())
    -- print(debug.traceback())
    -- print(show)
    self.show_leftbottom = show
    if exception_list == nil then
        self.show_leftbottom_exception_list = {}
    else
        self.show_leftbottom_exception_list = exception_list
    end
    self:showbaseicon6()
end

function MainUIIconView:Set_ShowIconPanel6(show)
    self.ativeIconPanel3.gameObject:SetActive(show)
end

function MainUIIconView:IconSwitcherById(id)
    if DataSystem.data_icon[id].icon_type == 4 then
        self:hidebaseicon()
        self:showbaseicon4()
    else
        self:hidebaseicon4()
        self:showbaseicon(true)
    end

    self:SetSwitchRedPoint()
end

-- 是否显示红点
function MainUIIconView:CheckRed()
    self:set_icon_Redpoint_by_id(1, ((RoleManager.Instance.RoleData.point or 0) > 0 or WingsManager.Instance:Upgradable()))

    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        self:set_icon_Redpoint_by_id(33, SdkManager.Instance:CheckFacebook() > 0)
    end

    -- print("===================  CheckRed ====================")
    self:set_icon_Redpoint_by_id(8, ShareManager.Instance.model.needRed)

    self:set_icon_Redpoint_by_id(313, NationalDayManager.Instance.model.rollNeedRed)

    self:set_icon_Redpoint_by_id(320, RegressionManager.Instance.model:CheckRedPointBerecruit() or RegressionManager.Instance.model:CheckRedPointLogin())

    local cross_type = RoleManager.Instance.RoleData.cross_type
    if cross_type == 1 then
        for k, v in pairs(DataSystem.data_icon) do
            if v.showRedpoint == true then
                self:set_icon_Redpoint_by_id(v.id, v.showRedpoint)
            end
        end

        for i,v in ipairs(self.icon_type3_list) do
            if v.showRedpoint == true then
                self:set_icon_Redpoint_by_id(v.id, v.showRedpoint)
            end
        end

        for i,v in ipairs(self.icon_type5_list) do
            if v.showRedpoint == true then
                self:set_icon_Redpoint_by_id(v.id, v.showRedpoint)
            end
        end

        for i,v in ipairs(self.icon_type6_list) do
            if v.showRedpoint == true then
                self:set_icon_Redpoint_by_id(v.id, v.showRedpoint)
            end
        end
    end
end

function MainUIIconView:checkIconGroup(icon_type_list, iconId)
    for _, icon_group_data in ipairs (DataSystem.data_icon_group) do
        local index = string.find(icon_group_data.group, iconId)
        if index ~= nil then
            for __, icondata in ipairs(icon_type_list) do
                local index2 = string.find(icon_group_data.group, icondata.id)
                if index2 ~= nil and index2 < index then
                    return false
                end
            end
        end
    end
    return true
end

function MainUIIconView:TweenHide()
    if self.isTweenShow then
        self.isTweenShow = false
        if not BaseUtils.is_null(self.iconPanelRect1) then
            Tween.Instance:MoveY(self.iconPanelRect1, -100, 0.2)
        end

        if not BaseUtils.is_null(self.iconPanelRect3) then
            Tween.Instance:MoveY(self.iconPanelRect3, 100, 0.2)
        end

        if not BaseUtils.is_null(self.iconPanelRect2) then
            Tween.Instance:MoveX(self.iconPanelRect2, -100, 0.2)
        end

        if not BaseUtils.is_null(self.iconPanelRect6) then
            Tween.Instance:MoveX(self.iconPanelRect6, -320, 0.2)
        end

        if not BaseUtils.is_null(self.iconPanelRect7) then
            Tween.Instance:MoveX(self.iconPanelRect7, -320, 0.2)
        end

        if not BaseUtils.is_null(self.iconPanelRect5) then
            Tween.Instance:MoveY(self.iconPanelRect5, 100, 0.2)
        end

        if not BaseUtils.is_null(self.iconPanelRect8) then
            Tween.Instance:MoveY(self.iconPanelRect8, 100, 0.2)
        end
    end
end

function MainUIIconView:TweenShow()
    if not self.isTweenShow then
        self.isTweenShow = true
        if not BaseUtils.is_null(self.iconPanelRect1) then
            Tween.Instance:MoveY(self.iconPanelRect1, self.originPos[1].y, 0.2)
        end
        if not BaseUtils.is_null(self.iconPanelRect3) then
            Tween.Instance:MoveY(self.iconPanelRect3, self.originPos[3].y, 0.2)
        end
        if not BaseUtils.is_null(self.iconPanelRect2) then
            Tween.Instance:MoveX(self.iconPanelRect2, self.originPos[2].x, 0.2)
        end
        if not BaseUtils.is_null(self.iconPanelRect6) then
            Tween.Instance:MoveX(self.iconPanelRect6, self.originPos[6].x, 0.2)
        end
        if not BaseUtils.is_null(self.iconPanelRect7) then
            Tween.Instance:Move(self.iconPanelRect7, self.originPos[7], 0.2)
        end
        if not BaseUtils.is_null(self.iconPanelRect5) then
            Tween.Instance:Move(self.iconPanelRect5, self.originPos[5], 0.2)
        end
        if not BaseUtils.is_null(self.iconPanelRect8) then
            Tween.Instance:MoveY(self.iconPanelRect8, 0, 0.2)
        end
    end
end

function MainUIIconView:CheckGuide()
    if RoleManager.Instance.RoleData.lev > 20 then
        return
    end

    local quest = QuestManager.Instance:GetQuest(10084)
    if quest ~= nil and quest.finish == 1 then
        return true
    end

    local quest1 = QuestManager.Instance:GetQuest(22084)
    if quest1 ~= nil and quest1.finish == 1 then
        return true
    end

    return false
end

function MainUIIconView:CheckGuidePoint()

    MainUIManager.Instance.priority = 0
    local isGuidePetAddPoint = false

    local data = DataQuest.data_get[41640]
    local questData = QuestManager.Instance:GetQuest(data.id)

    local data2 = DataQuest.data_get[41639]
    local questData2 = QuestManager.Instance:GetQuest(data2.id)

    local isEnoughLev = false
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        if v.id == 1 then
            local temp_lev = EquipStrengthManager.Instance.model:check_equip_is_last_lev(v)
            if temp_lev >= 80 then
                isEnoughLev = true
            end
        end
    end

    if questData ~= nil and questData.finish == 1 and isEnoughLev == true and questData2 == nil then
        MainUIManager.Instance.priority = -1
    end

    data = DataQuest.data_get[41310]
    questData = QuestManager.Instance:GetQuest(data.id)
    if questData ~= nil and questData.finish == 1 and RoleManager.Instance.RoleData.lev >=45 then
        MainUIManager.Instance.priority = 1
        isGuidePetAddPoint = true
    end

    data = DataQuest.data_get[41261]
    questData = QuestManager.Instance:GetQuest(data.id)
    if questData ~= nil and questData.finish == 1 then
        MainUIManager.Instance.priority = 2
    end

    data = DataQuest.data_get[41021]
    questData = QuestManager.Instance:GetQuest(data.id)
    if questData ~= nil and questData.finish == 1 then
        MainUIManager.Instance.priority = 3
        isGuidePetAddPoint = true
    end

end

function MainUIIconView:FoldIcon3(isFold)
    if self.gameObject == nil then
        return
    end

    local showIconList = {}

    local level = RoleManager.Instance.RoleData.lev
    local cross_type = RoleManager.Instance.RoleData.cross_type
    local index = 0
    local foldButton_width = 0
    if level < 50 or not self.show_top then
        self.foldButton_ativeIconPanel.gameObject:SetActive(false)
        isFold = false
    else
        self.foldButton_ativeIconPanel.gameObject:SetActive(true)
        foldButton_width = 34

        if isFold then
            self.foldButton_ativeIconPanel_image.localScale = Vector3(-1, 1, 1)
        else
            self.foldButton_ativeIconPanel_image.localScale = Vector3(1, 1, 1)
        end
    end

    for i = 1, #self.icon_type3_list do
        local icondata = self.icon_type3_list[i]
        local crossserver_hide_icon = DataSystem.data_crossserver_hide_icon[icondata.id]
        if icondata.lev <= level and (not self.hide_icon_id_list[icondata.id])
            and self:checkIconGroup(self.icon_type3_list, icondata.id)
            and (self.show_top or table.containValue(self.show_top_exception_list, icondata.id)) then

            table.insert(showIconList, icondata)
        else
            icondata.icon:SetActive(false)
        end
    end

    if isFold then -- 折叠
        for i = 1, #showIconList do
            local icondata = showIconList[i]
            if icondata.fold_type == 1 then
                icondata.icon:SetActive(false)
            else
                icondata.icon:SetActive(true)
                if DataSystem.data_festival_icon[1] ~= nil and table.containValue(DataSystem.data_festival_icon[1], icondata.iconPath) then
                    icondata.icon.transform:SetParent(icondata.parent)
                end
                icondata.icon.transform:GetComponent(RectTransform).anchoredPosition =
                    Vector2(self.ativeicon_startx + index * self.ativeicon_width + foldButton_width, self.ativeicon_starty)
                icondata.icon.transform.localScale = Vector3.one
                index = index + 1

                if cross_type == 1 and crossserver_hide_icon ~= nil then
                    if crossserver_hide_icon.hide_type == 1 then
                        icondata.icon:SetActive(false)
                        index = index - 1
                    elseif crossserver_hide_icon.hide_type == 2 then
                        icondata.dark = true
                        icondata.icon:GetComponent(Image).color = Color(0.5, 0.5, 0.5)
                    end
                elseif cross_type == 0 and icondata.dark then
                    icondata.dark = false
                    icondata.icon:GetComponent(Image).color = Color.white
                end
                if DataSystem.data_festival_icon[1] ~= nil and table.containValue(DataSystem.data_festival_icon[1], icondata.iconPath) then
                    icondata.icon.transform:SetParent(self.iconPanelRect8.transform)
                end
            end
        end
    else -- 不折叠
        local line_num = 6 -- 每行的图标个数
        local num = 0 -- 不可折叠图标的个数，不可折叠的图标需要放在第二层
        local index_line2 = 0
        for i = 1, #self.icon_type3_list do
            local icondata = self.icon_type3_list[i]
            if icondata.fold_type == 0 then
                num = num + 1
            end
        end

        for i = 1, #showIconList do
            local icondata = showIconList[i]
            icondata.icon:SetActive(true)
            if DataSystem.data_festival_icon[1] ~= nil and table.containValue(DataSystem.data_festival_icon[1], icondata.iconPath) then
                icondata.icon.transform:SetParent(icondata.parent)
            end

            if icondata.fold_type == 1 and #self.icon_type3_list - line_num > 0 and line_num - num < index then
                icondata.icon.transform:GetComponent(RectTransform).anchoredPosition =
                    Vector2(self.ativeicon_startx + index_line2 * self.ativeicon_width + foldButton_width, self.ativeicon_starty - self.ativeicon_height)
                index_line2 = index_line2 + 1
            else
                icondata.icon.transform:GetComponent(RectTransform).anchoredPosition =
                    Vector2(self.ativeicon_startx + index * self.ativeicon_width + foldButton_width, self.ativeicon_starty)
                index = index + 1
            end
            icondata.icon.transform.localScale = Vector3.one


            if cross_type == 1 and crossserver_hide_icon ~= nil then
                if crossserver_hide_icon.hide_type == 1 then
                    icondata.icon:SetActive(false)
                    index = index - 1
                elseif crossserver_hide_icon.hide_type == 2 then
                    icondata.dark = true
                    icondata.icon:GetComponent(Image).color = Color(0.5, 0.5, 0.5)
                end
            elseif cross_type == 0 and icondata.dark then
                icondata.dark = false
                icondata.icon:GetComponent(Image).color = Color.white
            end
            if DataSystem.data_festival_icon[1] ~= nil and table.containValue(DataSystem.data_festival_icon[1], icondata.iconPath) then
                icondata.icon.transform:SetParent(self.iconPanelRect8.transform)
            end
        end
    end
end

function MainUIIconView:foldButton_ativeIconPanel_click()
    if self:get_ativeIconPanel_fold() == 1 then
        PlayerPrefs.SetInt("ativeIconPanel_fold", 0)
    else
        PlayerPrefs.SetInt("ativeIconPanel_fold", 1)
    end
    self:FoldIcon3(self:get_ativeIconPanel_fold() == 1)
end

function MainUIIconView:get_ativeIconPanel_fold()
    if PlayerPrefs.HasKey("ativeIconPanel_fold") == false then
        return 0
    end

    return PlayerPrefs.GetInt("ativeIconPanel_fold")
end

function MainUIIconView:AdaptIPhoneX()
    -- if MainUIManager.Instance.adaptIPhoneX then
    --     if Screen.orientation == ScreenOrientation.LandscapeRight then
    --         self.originPos[1] = Vector3(-12, 8)
    --         self.originPos[2] = Vector3(0, 0)
    --         self.originPos[3] = Vector3(0, -3)
    --         self.originPos[5] = Vector3(-20, -3)
    --         self.originPos[6] = Vector3(3, 170)
    --         self.originPos[7] = Vector3(3, 170)
    --     else
    --         self.originPos[1] = Vector3(-12, 8)
    --         self.originPos[2] = Vector3(35, 0)
    --         self.originPos[3] = Vector3(0, -3)
    --         self.originPos[5] = Vector3(-20, -3)
    --         self.originPos[6] = Vector3(38, 170)
    --         self.originPos[7] = Vector3(38, 170)
    --     end
    -- else
    --     self.originPos[1] = Vector3.zero
    --     self.originPos[2] = Vector3.zero
    --     self.originPos[3] = Vector3.zero
    --     self.originPos[5] = Vector3.zero
    --     self.originPos[6] = Vector3(0, 170)
    --     self.originPos[7] = Vector3(0, 170)
    -- end

    -- self.isTweenShow = not self.isTweenShow
    -- if not self.isTweenShow then
    --     self:TweenShow()
    -- else
    --     self:TweenHide()
    -- end
    BaseUtils.AdaptIPhoneX(self.transform)
end

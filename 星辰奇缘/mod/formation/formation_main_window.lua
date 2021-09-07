-- --------------------------
-- 阵法主界面
-- hosr
-- --------------------------
FormationMainWindow = FormationMainWindow or BaseClass(BaseWindow)

function FormationMainWindow:__init(model)
    self.model = model

    self.windowId = WindowConfig.WinID.formation
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.learnPanel = FormationLearnPanel.New(self)

    self.resList  = {
        {file = AssetConfig.formation, type = AssetType.Main},
        {file = AssetConfig.formation_icon, type = AssetType.Dep},
        {file = AssetConfig.teamres, type = AssetType.Dep},
        {file = AssetConfig.guard_head, type = AssetType.Dep},
    }

    -- 左边的选项列表
    self.formationList = {}
    self.id2indexTab = {}

    -- 站位列表
    self.standList = {}

    -- 右边列表
    self.rightList = {}

    -- 当前选中左边
    self.currentLeftItem = nil

    -- 是否有更新
    self.needUpdate = true

    self.listener = function() self:UpdateLeft(true) end
    self.guardpositionlistener = function() self:GuardPositionChange() end
    self.updateMemListener = function() self:NeedUpdateMember() end

    self.OnOpenEvent:Add(self.listener)

    self.memberCount = 0

    self.currentId = 0
    self.currentLev = 0

    -- 守护切换界面
    self.changeGuard = nil
end

function FormationMainWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.formation_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.guard_position_change, self.guardpositionlistener)
    EventMgr.Instance:RemoveListener(event_name.team_position_change, self.updateMemListener)

    for i,v in ipairs(self.standList) do
        if v.composite ~= nil then
            v.composite:DeleteMe()
            v.composite = nil
        end
    end

    if self.changeGuard ~= nil then
        self.changeGuard:DeleteMe()
        self.changeGuard = nil
    end

    if self.learnPanel ~= nil then
        self.learnPanel:DeleteMe()
        self.learnPanel = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function FormationMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.formation))
    self.transform = self.gameObject.transform
    self.gameObject.name = "FormationMainWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)


    local main = self.transform:Find("Main")
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseMain() end)

    local teamBtn = main:Find("TeamButton"):GetComponent(Button).onClick:AddListener(function() self.cacheMode = CacheMode.Destroy WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team) end)

    local leftContainer = main:Find("Scroll/Container")
    local len = leftContainer.childCount
    for i=1,len do
        local tab = FormationItem.New(leftContainer:GetChild(i - 1).gameObject, self)
        local index = i
        tab.index = index
        table.insert(self.formationList, tab)
    end

    main:Find("LeftButton"):GetComponent(Button).onClick:AddListener(function() self:LookPrev() end)
    main:Find("RightButton"):GetComponent(Button).onClick:AddListener(function() self:LookNext() end)
    self.descTxt = main:Find("DestTitle"):GetComponent(Text)

    local rightContainer = main:Find("RightContainer")
    len = rightContainer.childCount
    for i=1,len do
        local tab = {}
        local rightItem = rightContainer:GetChild(i - 1)
        tab["button"] = rightItem.gameObject:AddComponent(Button)
        tab["gameObject"] = rightItem.gameObject
        tab["button"] = rightItem.gameObject:GetComponent(Button)
        tab["desc1"] = rightItem:Find("Desc1"):GetComponent(Text)
        tab["desc2"] = rightItem:Find("Desc2"):GetComponent(Text)
        tab["arrow1"] = rightItem:Find("Arrow1"):GetComponent(Image)
        tab["arrow2"] = rightItem:Find("Arrow2"):GetComponent(Image)
        tab["classes"] = rightItem:Find("SexIcon"):GetComponent(Image)
        tab["head"] = rightItem:Find("Head"):GetComponent(Image)
        tab["head"].gameObject:SetActive(true)
        tab["classes"].gameObject:SetActive(true)
        tab["index"] = i
        table.insert(self.rightList, tab)
        tab["button"].onClick:AddListener(function() self:OpenChangeGuard(tab["index"]) end)
    end

    local midContainer = main:Find("MidContainer")
    self.nameTxt = midContainer:Find("Top/Name"):GetComponent(Text)
    self.levTxt = midContainer:Find("Top/Lev"):GetComponent(Text)
    self.upBtn = midContainer:Find("Top/Button"):GetComponent(Button)
    self.upBtnImg = midContainer:Find("Top/Button"):GetComponent(Image)
    self.upBtnTxt = self.upBtn.transform:Find("Text"):GetComponent(Text)
    self.slider = midContainer:Find("Top/Slider"):GetComponent(Slider)
    self.slider.value = 0
    self.valTxt = midContainer:Find("Top/Value"):GetComponent(Text)
    self.headImg = midContainer:Find("Top/Head"):GetComponent(Image)
    self.headImg.gameObject:SetActive(true)
    self.saveButton = midContainer:Find("Button"):GetComponent(Button)
    self.saveButton.onClick:AddListener(function() self:OnClickSave() end)
    self.saveLabel = self.saveButton.gameObject.transform:Find("Text"):GetComponent(Text)
    self.fdesc = midContainer:Find("Desc"):GetComponent(Text)

    self.RestrainText = midContainer:Find("restrainText"):GetComponent(Text)
    self.RestrainText.gameObject:GetComponent(Button).onClick:AddListener(function()
        local tipsText = {
            TI18N("1.黄色字体为<color='#ffff00'>强克制</color>，绿色字体为<color='#00ff00'>弱克制</color>"),
            TI18N("2.强克制：受到敌方的伤害<color='#ffff00'>降低10%</color>"),
            TI18N("3.弱克制：受到敌方的伤害<color='#ffff00'>降低5%</color>")
        }
        TipsManager.Instance:ShowText({gameObject = self.saveButton.gameObject, itemData = tipsText})
    end)
    self.upBtn.onClick:AddListener(function() self:OnClickUpBtn() end)

    local stand = midContainer:Find("StandContainer")
    len = stand.childCount
    for i=1,len do
        local tab = {}
        local standItem = stand:Find(string.format("Item%s", i))
        tab["gameObject"] = standItem.gameObject
        tab["transform"] = standItem
        tab["button"] = standItem.gameObject:GetComponent(Button)
        tab["classes"] = standItem:Find("Classes"):GetComponent(Image)
        tab["preview"] = standItem:Find("Preview").gameObject
        tab["arrow"] = standItem:Find("Arrow").gameObject
        tab["arrow"]:SetActive(false)
        table.insert(self.standList, tab)
        local index = i
        tab["button"].onClick:AddListener(function() self:ClickOne(index) end)
    end

    -- self:ShowLeft()
    self:UpdateLeft()
    self:AutoSelect()

    EventMgr.Instance:AddListener(event_name.formation_update, self.listener)
    EventMgr.Instance:AddListener(event_name.guard_position_change, self.guardpositionlistener)
    EventMgr.Instance:AddListener(event_name.team_position_change, self.updateMemListener)
end

-- 打开界面后根据情况选中一个
function FormationMainWindow:AutoSelect()
    self.currentId = FormationManager.Instance.formationId
    self.currentLev = FormationManager.Instance.formationLev
    self:ClickLeft(self.currentId)
end

--  查看下一个等级
function FormationMainWindow:LookNext()
    local lev = self.currentLev + 1
    self:ShowRight(self.currentId, lev)
end

-- 查看上一个等级
function FormationMainWindow:LookPrev()
    local lev = self.currentLev - 1
    lev = math.max(lev, 1)
    self:ShowRight(self.currentId, lev)
end

-- 布局左边
function FormationMainWindow:ShowLeft()
    for i=1,8 do
        local fdata = DataFormation.data_list[string.format("%s_%s", i, 1)]
        local tab = self.formationList[i]
        tab["data"] = fdata
        tab["icon"].sprite = self.assetWrapper:GetSprite(AssetConfig.formation_icon, tostring(i))
        tab["name"].text = fdata.name
        tab["level"].text = TI18N("<color='#cc3333'>未学习</color>")
        tab["state"]:SetActive(false)
        local id = i
        tab["id"] = i
        tab["button"].onClick:AddListener(function() self:ClickLeft(id) end)
        tab["level_val"] = 1
        tab["exp_val"] = 0
        tab["has"] = false
    end

    self:UpdateLeft()
end

function FormationMainWindow:NeedUpdateMember()
    self.needUpdate = true
    self:UpdateLeft(true)
end

-- 更新左边
function FormationMainWindow:UpdateLeft(isUpdate)
    self.cacheMode = CacheMode.Destroy
    FormationManager.Instance:Check()
    -- 已有的阵法进行数据显示
    local hasTab = {}
    for i,v in ipairs(FormationManager.Instance.formationList) do
        local tab = self.formationList[i]
        tab:SetData(v)
        hasTab[v.id] = 1
        if self.currentId == v.id then
            self.currentLev = v.lev
        end
        local index = i
        self.id2indexTab[v.id] = index
    end

    local index = #FormationManager.Instance.formationList + 1
    for i = 1, 8 do
        if hasTab[i] == nil then
            local tab = self.formationList[index]
            local id = i
            tab:SetNil(id)
            self.id2indexTab[id] = index
            index = index + 1
        end
    end

    if isUpdate then
        self:ClickLeft(self.currentId, true)
        -- self:ShowMidInfo()
        -- self:ShowRight(self.currentId, self.currentLev)
    end
    -- self.RestrainText.text = FormationManager.Instance:GetRestrain(self.currentId)
end

function FormationMainWindow:ClickLeft(id, force)
    if self.currentLeftItem ~= nil and self.currentLeftItem.id ~= id then
        self.currentLeftItem:Select(false)
        -- self.currentLeftItem["select"]:SetActive(false)
    end
    if force or self.currentLeftItem == nil or self.currentLeftItem.id ~= id then
        local tab = self.formationList[self.id2indexTab[id]]
        self.currentLeftItem = tab
        self.currentLeftItem:Select(true)
        -- self.currentLeftItem["select"]:SetActive(true)

        self.currentId = id
        self.RestrainText.text = FormationManager.Instance:GetRestrain(self.currentId)
        if id == FormationManager.Instance.formationId then
            self.currentLev = FormationManager.Instance.formationLev
            self:ShowRight(id, FormationManager.Instance.formationLev)
        else
            self.currentLev = 1
            local d = FormationManager.Instance:GetData(id)
            if d ~= nil then
                self.currentLev = d.lev
            end
            self:ShowRight(id, self.currentLev)
        end

        self:ShowMidInfo()
        self:ShowStand()

        if self.needUpdate then
            self.needUpdate = false
            self:PutInMember()
        end
    end
end

-- 布局右边
function FormationMainWindow:ShowRight(id, lev)
    local fdata = DataFormation.data_list[string.format("%s_%s", id, lev)]
    if fdata ~= nil then
        self.currentLev = lev

        if id == FormationManager.Instance.formationId and lev == FormationManager.Instance.formationLev then
            self.descTxt.text = TI18N("当前效果")
        else
            self.descTxt.text = string.format(TI18N("%s级效果"), lev)
        end

        local attrs = {fdata.attr_1, fdata.attr_2, fdata.attr_3, fdata.attr_4, fdata.attr_5}
        local upDescs = {fdata.up_1, fdata.up_2, fdata.up_3, fdata.up_4, fdata.up_5}
        local downDescs = {fdata.down_1, fdata.down_2, fdata.down_3, fdata.down_4, fdata.down_5}

        for i,attr in ipairs(attrs) do
            local tab = self.rightList[i]
            if #attr == 0 then
                tab["desc1"].text = TI18N("无效果\n")
                tab["desc2"].text = TI18N("无效果")
                tab["arrow1"].gameObject:SetActive(false)
                tab["arrow2"].gameObject:SetActive(false)
            elseif #attr == 1 then
                tab["desc1"].gameObject:SetActive(true)
                tab["arrow1"].gameObject:SetActive(true)
                tab["desc2"].gameObject:SetActive(false)
                tab["arrow2"].gameObject:SetActive(false)

                if attr[1].val > 0 then
                    tab["desc1"].text = upDescs[i]
                    tab["arrow1"].sprite = self.assetWrapper:GetSprite(AssetConfig.teamres, "GreenUp")
                else
                    tab["desc1"].text = downDescs[i]
                    tab["arrow1"].sprite = self.assetWrapper:GetSprite(AssetConfig.teamres, "RedDown")
                end
            elseif #attr == 2 then
                tab["desc1"].gameObject:SetActive(true)
                tab["arrow1"].gameObject:SetActive(true)
                tab["desc2"].gameObject:SetActive(true)
                tab["arrow2"].gameObject:SetActive(true)

                if attr[1].val > 0 then
                    tab["desc1"].text = upDescs[i]
                    tab["arrow1"].sprite = self.assetWrapper:GetSprite(AssetConfig.teamres, "GreenUp")
                else
                    tab["desc1"].text = downDescs[i]
                    tab["arrow1"].sprite = self.assetWrapper:GetSprite(AssetConfig.teamres, "RedDown")
                end

                if attr[2].val > 0 then
                    tab["desc2"].text = upDescs[i]
                    tab["desc2"].gameObject:SetActive(false)
                    tab["arrow2"].sprite = self.assetWrapper:GetSprite(AssetConfig.teamres, "GreenUp")
                else
                    tab["desc2"].text = downDescs[i]
                    tab["arrow2"].sprite = self.assetWrapper:GetSprite(AssetConfig.teamres, "RedDown")
                end
            end
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("没有更多效果"))
    end
end

-- 布局中间 信息
function FormationMainWindow:ShowMidInfo()
    self.nameTxt.text = self.currentLeftItem.data.name
    self.fdesc.text = self.currentLeftItem.data.desc

    if not self.currentLeftItem.has then
        self.levTxt.text = string.format(TI18N("%s级"), self.currentLeftItem.level_val)
        local has = BackpackManager.Instance:GetItemCount(self.currentLeftItem.data.item_id)
        if has > 0 then
            self.levTxt.text = TI18N("可学习")
            self.upBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        else
            self.levTxt.text = TI18N("<color='#cc3333'>未学习</color>")
            self.upBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        end
        self.slider.gameObject:SetActive(false)
        self.valTxt.gameObject:SetActive(false)
        self.upBtnTxt.text = TI18N("学习")
        self.saveButton.gameObject:SetActive(false)
        self.upBtn.gameObject:SetActive(true)
    else
        local nowExp = self.currentLeftItem.exp_val
        local maxExp = self.currentLeftItem.data.next_exp
        if maxExp == 0 then
            self.slider.value = 0
            self.slider.gameObject:SetActive(false)

            self.valTxt.gameObject:SetActive(false)

            self.upBtn.gameObject:SetActive(false)

            self.levTxt.text = TI18N("不可升级")
        else
            self.levTxt.text = string.format(TI18N("%s级"), self.currentLeftItem.level_val)

            self.slider.value = nowExp / maxExp
            self.slider.gameObject:SetActive(true)

            self.valTxt.text = string.format("%s/%s", nowExp, maxExp)
            self.valTxt.gameObject:SetActive(true)

            self.upBtnTxt.text = TI18N("提升")
            self.upBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            self.upBtn.gameObject:SetActive(true)
        end

        if FormationManager.Instance.formationId ~= self.currentLeftItem.id then
            self.saveLabel.text = TI18N("使用阵法")
        else
            self.saveLabel.text = TI18N("使用中")
        end
        self.saveButton.gameObject:SetActive(true)
    end

    self.headImg.sprite = self.assetWrapper:GetSprite(AssetConfig.formation_icon, tostring(self.currentLeftItem.id))
end

-- 布局站位
function FormationMainWindow:ShowStand()
    local positions = FormationEumn.TypePosition[self.currentLeftItem.id]
    for i,tab in ipairs(self.standList) do
        tab["transform"].localPosition = positions[i]
    end
    local layers = FormationEumn.TypeLayer[self.currentLeftItem.id]
    for i,layer in ipairs(layers) do
        self.standList[layer].transform:SetSiblingIndex(5 - i)
    end
end

-- 放入队伍或守护数据
function FormationMainWindow:PutInMember()
    self.memberCount = 0
    self.currentSelectId = 0
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        -- 队长就放入队员 和 守护
        local list = TeamManager.Instance:GetMemberOrderList()
        for i,member in ipairs(list) do
            self.memberCount = self.memberCount + 1
            local tab = self.rightList[self.memberCount]
            tab["classes"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(member.classes))
            tab["head"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", member.classes, member.sex))
            tab["gameObject"]:SetActive(true)
            tab["is_guard"] = false
            tab["data"] = member

            local modelData = {type = PreViewType.Role, classes = member.classes, sex = member.sex, looks = member.looks, noWing = true}
            self:SetPriview(i, modelData)

            local standTab = self.standList[self.memberCount]
            standTab["classes"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(member.classes))
            standTab["arrow"].gameObject:SetActive(false)
            standTab["is_guard"] = false
        end

        self:PutInTeamGuard()
    else
        -- 自己就放入守护
        local role = RoleManager.Instance.RoleData
        local tab = self.rightList[1]
        tab["classes"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(role.classes))
        tab["head"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", role.classes, role.sex))
        tab["gameObject"]:SetActive(true)
        tab["data"] = role
        tab["is_guard"] = false

        local standTab = self.standList[1]
        standTab["classes"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(role.classes))
        standTab["is_guard"] = false
        standTab["arrow"].gameObject:SetActive(false)

        self.memberCount = self.memberCount + 1

        self:PutInGuard()

        local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = SceneManager.Instance:MyData().looks, noWing = true}
        self:SetPriview(1, modelData)
    end

    for i = self.memberCount + 1, 5 do
        self.rightList[i]["gameObject"]:SetActive(false)
        self.standList[i]["classes"].gameObject:SetActive(false)
        self.standList[i]["arrow"].gameObject:SetActive(false)
    end
end

function FormationMainWindow:SetPriview(_id, modelData)
    local id = _id
    local callback = function(composite)
        self.standList[id]["composite"] = composite
        self:SetRawImage(id)
    end
    local setting = {
        name = "FormationPreview1"
        ,orthographicSize = 0.6
        ,width = 100
        ,height = 150
        ,offsetY = -0.4
        ,noDrag = true
    }

    if self.standList[id]["composite"] == nil then
        PreviewComposite.New(callback, setting, modelData)
    else
        self.standList[id]["composite"]:Reload(modelData, callback)
    end
end

function FormationMainWindow:SetRawImage(id)
    local tab = self.standList[id]
    if BaseUtils.is_null(tab.gameObject) then
        return
    end
    local rawImage = tab.composite.rawImage
    rawImage.transform:SetParent(tab.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 45, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    tab.composite.tpose.transform:Rotate(Vector3(11.8, 108.8, 325.4))
    tab.preview:SetActive(true)
end

-- 点击提升阵法按钮
function FormationMainWindow:OnClickUpBtn()
    local fdata = DataFormation.data_list[string.format("%s_%s", self.currentId, self.currentLev)]
    local learned = self.formationList[self.id2indexTab[self.currentId]].has
    if learned then
        self.learnPanel:Show(fdata)
    else
        local has = BackpackManager.Instance:GetItemCount(fdata.item_id)
        if has > 0 then
            -- local list = BackpackManager.Instance:GetItemByBaseid(fdata.item_id)
            FormationManager.Instance:Send12907(self.currentId, fdata.item_id, 1)
        else
            -- 没道具时跳转到市场阵法
            self.cacheMode = CacheMode.Visible
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, {1, 6})
        end
    end
end

-- 点击保存更换阵法
function FormationMainWindow:OnClickSave()
    if self.currentLeftItem ~= nil then
        FormationManager.Instance:Send12901(self.currentLeftItem.id)
    end
end

function FormationMainWindow:ClickOne(index)
    if TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.Leader and TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.None then
        NoticeManager.Instance:FloatTipsByString(TI18N("只有队长可以操作"))
        return
    end
    local currentStandTab = self.standList[index]
    local currentTab = self.rightList[index]
    if currentTab.data == nil then
        return
    end
    if self.currentSelectId == index then
        self.currentSelectId = 0
        currentStandTab["arrow"]:SetActive(false)
    else
        local lastTab = nil
        local lastStandTab = nil
        if self.currentSelectId ~= 0 then
            -- 交换逻辑
            lastTab = self.rightList[self.currentSelectId]
            lastStandTab = self.standList[self.currentSelectId]
            lastStandTab["arrow"]:SetActive(false)
            local lastInfo = lastTab.data
            local currRoleInfo = currentTab.data
            if lastTab.is_guard and currentTab.is_guard then
                if TeamManager.Instance:HasTeam() then
                    FormationManager.Instance:Send12904(lastInfo.base_id, currRoleInfo.base_id)
                else
                    FormationManager.Instance:Send12905(lastInfo.base_id, 1, currRoleInfo.base_id)
                end
            elseif not lastTab.is_guard and not currentTab.is_guard then
                FormationManager.Instance:Send12903(currRoleInfo.rid, currRoleInfo.platform, currRoleInfo.zone_id, lastInfo.rid, lastInfo.platform, lastInfo.zone_id)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("玩家和守护无法交换位置"))
            end
            self.currentSelectId = 0
            return
        end
        self.currentSelectId = index
        currentStandTab["arrow"]:SetActive(true)
    end
end

-- 守护位置变改
function FormationMainWindow:GuardPositionChange()
    self.currentSelectId = 0
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        --队长用守护补充队伍
        self.memberCount = #TeamManager.Instance:GetMemberOrderList()
        self:PutInTeamGuard()
    else
        self.memberCount = 1
        self:PutInGuard()
    end

    for i = self.memberCount + 1, 5 do
        self.rightList[i]["gameObject"]:SetActive(false)
        self.standList[i]["classes"].gameObject:SetActive(false)
        self.standList[i]["arrow"].gameObject:SetActive(false)
    end
end


--放入守护,没队伍的，取自己的守护信息
function FormationMainWindow:PutInGuard()
    table.sort(FormationManager.Instance.guardList, function(a,b) return a.number < b.number end)
    local endval = 5 - self.memberCount
    local list = FormationManager.Instance:GetFightGuardList()
    endval = math.min(endval, #list)
    for i = 1, endval do
        local guard = list[i]
        local gdata = DataShouhu.data_guard_base_cfg[guard.guard_id]

        if gdata ~= nil then
            gdata = BaseUtils.copytab(gdata)
            local res_id = gdata.res_id
            local animation_id = gdata.animation_id
            local paste_id = gdata.paste_id
            local wakeUpCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", gdata.base_id, guard.quality)]
            if wakeUpCfgData ~= nil and wakeUpCfgData.model ~= 0 then
                gdata.res_id = wakeUpCfgData.model
                gdata.paste_id = wakeUpCfgData.skin
                gdata.animation_id = wakeUpCfgData.animation
            end

            self:PutGuard(gdata)
        end
    end
end

--放入守护,有队伍的取队伍的守护信息
function FormationMainWindow:PutInTeamGuard()
    local endval = 5 - self.memberCount
    endval = math.min(endval, #FormationManager.Instance.teamGuardList)
    for i = 1, endval do
        local guard_id = FormationManager.Instance.teamGuardList[i].guard_id
        local gdata = DataShouhu.data_guard_base_cfg[guard_id]
        if gdata ~= nil then
            self:PutGuard(gdata)
        end
    end
end

function FormationMainWindow:PutGuard(gdata)
    self.memberCount = self.memberCount + 1
    local tab = self.rightList[self.memberCount]
    local standTab = self.standList[self.memberCount]
    tab["head"].sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(gdata.avatar_id))
    tab["classes"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(gdata.classes))
    tab["gameObject"]:SetActive(true)
    tab["data"] = gdata
    tab["is_guard"] = true
    local modelData = {type = PreViewType.Shouhu, skinId = gdata.paste_id, modelId = gdata.res_id, animationId = gdata.animation_id, scale = 1}
    self:SetPriview(self.memberCount, modelData)

    standTab["classes"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(gdata.classes))
    standTab["classes"].gameObject:SetActive(true)
    standTab["is_guard"] = true
end

-- 打开守护切换
function FormationMainWindow:OpenChangeGuard(index)
    local data = self.rightList[index]
    if data.is_guard then
        if self.changeGuard == nil then
            self.changeGuard = FormationChangeGuardPanel.New(self)
        end
        self.changeGuard:Show(data.data)
    end
end

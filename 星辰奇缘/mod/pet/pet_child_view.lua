-- --------------------------
-- 子女养成
-- hosr
-- --------------------------
PetChildView = PetChildView or BaseClass(BasePanel)

function PetChildView:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "PetView_Child"
    self.resList = {
        {file = AssetConfig.petwindow_child, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20357), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.headride, type = AssetType.Dep}
    }

    self.headbar = nil
    self.panelList = {}
    self.currIndex = 0
    self.currPreviewId = 0

    self.isInit = false

    self.callback = function(composite)
	    self:SetRawImage(composite)
	end
    self.previewsetting = {
        name = "PetChildView"
        ,orthographicSize = 0.4
        ,width = 200
        ,height = 250
        ,offsetY = -0.2
    }

    self.setting = {
        noCheckRepeat = true,
        notAutoSelect = true,
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    -- self.listener = function() self:UpdateStatus() end
    self.listener = function() self:Update() end
    self.telentListener = function() self:UpdateTabGroup() end

    self.attriconList = {
        [1] = 23840,
        [2] = 23841,
        [3] = 23842,
        [4] = 23843,
        [5] = 23844,
        [6] = 23845,
        [7] = 23846,
    }

    self.imgLoader = {}
end

function PetChildView:__delete()
    self:OnHide()

    for i,v in ipairs(self.imgLoader) do
        if v ~= nil then
            v:DeleteMe()
            v = nil
        end
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    if self.panelList ~= nil then
        for i,v in ipairs(self.panelList) do
    		v:DeleteMe()
    	end
    	self.panelList = nil
    end

    self.fightImg.sprite = nil

	if self.previewComp ~= nil then
		self.previewComp:DeleteMe()
		self.previewComp = nil
	end
end

function PetChildView:OnShow()
    self:RemoveListeners()
    ChildrenManager.Instance.OnChildDataUpdate:Add(self.listener)
    ChildrenManager.Instance.OnChildTelentUpdate:Add(self.telentListener)

    ChildrenManager.Instance:Require18600()
    self:Update()
    self.openArgs = nil
end

function PetChildView:OnHide()
    self:RemoveListeners()
    self:HidePreview()
end

function PetChildView:RemoveListeners()
    ChildrenManager.Instance.OnChildDataUpdate:Remove(self.listener)
    ChildrenManager.Instance.OnChildTelentUpdate:Remove(self.telentListener)
end

function PetChildView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petwindow_child))
    self.gameObject.name = "PetView_Child"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3.zero
    self.gameObject.transform.localScale = Vector3.one

    self.transform = self.gameObject.transform

    self.previewArea = self.transform:Find("ModelPanel").gameObject
    self.previewName = self.transform:Find("ModelPanel/NameText"):GetComponent(Text)
    self.score = self.transform:Find("ModelPanel/GifeText"):GetComponent(Text)

    self.transform:Find("ModelPanel/LockBtn").gameObject:SetActive(false)
    self.transform:Find("ModelPanel/HandBookButton"):GetComponent(Button).onClick:AddListener(function()
        self:onHandBookButtonClick()
    end)
    self.transform:Find("ModelPanel/TalkButton"):GetComponent(Button).onClick:AddListener(function()
        self:opentalksetpanel()
    end)
    self.transform:Find("ModelPanel/RideButton").gameObject:SetActive(false)
    self.transform:Find("ModelPanel/GenreImage").gameObject:SetActive(false)
    self.transform:Find("ModelPanel/NameEditButtom"):GetComponent(Button).onClick:AddListener(function() self:Rename() end)

    self.preview = self.transform:Find("ModelPanel/Preview").gameObject
    self.preview:GetComponent(Button).onClick:AddListener(function() self:PlayAction() end)

    self.panelContainer = self.transform:Find("InfoPanel")
    self.panelList = {
        PetChildAttrView.New(self),
        PetChildSkillView.New(self),
        PetChildTelentView.New(self),
    }
    self.handBookPanel = self.transform:Find("HandBookPanel").gameObject
    self.handBookPanel.transform:GetComponent(Button).onClick:AddListener(function()
        self.handBookPanel:SetActive(false)
    end)
    self.handBookPanel.transform:Find("Main/MoreButton"):GetComponent(Button).onClick:AddListener(function()
        self.handBookPanel.transform:Find("MorePanel").gameObject:SetActive(not self.handBookPanel.transform:Find("MorePanel").gameObject.activeSelf)
    end)
    self.handBookPanel.transform:Find("MorePanel/MoreButton"):GetComponent(Button).onClick:AddListener(function()
        self.handBookPanel:SetActive(false)
        self.panelList[1]:ClickAddFull()
    end)
    self.handBookText = {}
    for i=1, 9 do
        self.handBookText[i] = self.handBookPanel.transform:FindChild("Main/NumText"..tostring(i)):GetComponent(Text)
    end
    local MorePanel = self.handBookPanel.transform:Find("MorePanel")
    self.moreAttrText = {}
    for i=1,7 do
        self.moreAttrText[i] = MorePanel:GetChild(i-1):GetComponent(Text)

        if self.imgLoader[i] == nil then
            local go = MorePanel:GetChild(i-1):Find("icon").gameObject
            self.imgLoader[i] = SingleIconLoader.New(go)
        end
        self.imgLoader[i]:SetSprite(SingleIconType.Item, DataItem.data_get[self.attriconList[i]].icon)
    end

    self.btnArea = self.transform:Find("ButtonArea").gameObject
    local btn = self.transform:Find("ButtonArea/ToBattleButton")
    btn:GetComponent(Button).onClick:AddListener(function() self:ClickFight() end)
    self.fightImg = btn:GetComponent(Image)
    self.fightTxt = btn:Find("Text"):GetComponent(Text)

    btn = self.transform:Find("ButtonArea/FeedButtom")
    btn:GetComponent(Button).onClick:AddListener(function() self:OpenFeed() end)

    btn = self.transform:Find("ButtonArea/ArtificeButton")
    btn.gameObject:SetActive(false)

    self.shareBtn = self.transform:Find("ButtonArea/ReleaseButton").gameObject
    self.shareBtn:GetComponent(Button).onClick:AddListener(function() self:ClickShare() end)

    self.tabGroup = TabGroup.New(self.transform:Find("TabButtonGroup").gameObject, function(index) self:ChangeTab(index) end, self.setting)
    self.spiritButton = self.transform:Find("TabButtonGroup/SpiritButton")

    self.isInit = true

    self:OnShow()
end

function PetChildView:Update()
    if not self.isInit then
        return
    end

    self.child = PetManager.Instance.model.currChild
    if self.child == nil then
        return
    end

    self:UpdateTabGroup()
    if self.isInit then
        if self.openArgs ~= nil then
            self.tabGroup:ChangeTab(self.openArgs)
        else
            if self.currIndex == 0 then
                self.tabGroup:ChangeTab(1)
            else
                self.tabGroup:ChangeTab(self.currIndex)
            end
        end

        self:UpdateStatus()
    end
    self:ShowPreview()
end

function PetChildView:UpdateTabGroup()
    self.lock = false
    table.sort(self.child.talent_skills, function(a,b) return a.grade < b.grade end)
    if self.child ~= nil and #self.child.talent_skills == 0 then
        self.lock = true
    elseif self.child ~= nil and #self.child.talent_skills >= 1 and self.child.talent_skills[1].id == 0 then
        self.lock = true
    end

    if self.lock then
        self.parent.subIndex = 1
        self.tabGroup.cannotSelect = {false, false, true}
    else
        self.tabGroup.cannotSelect = {false, false, false}
    end

    if DataChild.data_child_condition[1].need_lev > RoleManager.Instance.RoleData.lev then
        self.spiritButton.gameObject:SetActive(false)
    else
        self.spiritButton.gameObject:SetActive(true)
    end
end

function PetChildView:ChangeTab(index)
    if index == 4 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ChildSkinWindow)
        return
    end

    if index == 5 then
        print(index)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.childSpirtWindow)
        return
    end


    if index == 3 and self.lock then
        local info = {child = self.child}
        self.parent.subIndex = 1
        self.model.childVewIndex = 1
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_change_telnet, info)
        return
    end

	if self.currIndex ~= 0 then
		self.panelList[self.currIndex]:Hiden()
	end
	self.currIndex = index
    self.parent.subIndex = index
	self.panelList[self.currIndex]:Show()

	if self.currIndex == 3 then
        self.previewArea:SetActive(false)
        self.btnArea:SetActive(false)
        self:HidePreview()
	else
		self.previewArea:SetActive(true)
        self.btnArea:SetActive(true)
		self:ShowPreview()
	end
end

function PetChildView:ShowPreview()
    if self.child ~= nil then
        local previewID = string.format("%s_%s", tostring(self.child.base_id), tostring(self.child.grade))
        local modelData = nil
        local childData = DataChild.data_child[self.child.base_id]

        local skinId = 0
        local modelId = 0
        local animationId = 0
        local effects = {}

        --默认模型
        if childData ~= nil then
            -- self.previewName.text = self.child.name
            if self.child.grade == 0 then
                skinId = childData.skin_id_0
                modelId = childData.model_id
            elseif self.child.grade == 1 then
                skinId = childData.skin_id_1
                modelId = childData.model_id1
            elseif self.child.grade == 2 then
                skinId = childData.skin_id_2
                modelId = childData.model_id2
            elseif self.child.grade == 3 then
                skinId = childData.skin_id_3
                modelId = childData.model_id3
            end
            animationId = childData.animation_id
            effects = childData.effects_0
        end

        --使用皮肤模型
        local child_skin_info = self.child.child_skin or {}
        for k,v in ipairs(child_skin_info) do
            if v.skin_active_flag == 2 then
                skinId = v.skin_id
                break
            end
        end
        local data_child_skin = DataChild.data_child_skin[skinId]
        if data_child_skin ~= nil then
            skinId = data_child_skin.texture
            modelId = data_child_skin.model_id
            animationId = data_child_skin.animation_id
        end

        local modelData = {type = PreViewType.Pet, skinId = skinId, modelId = modelId, animationId = animationId, effects = effects, scale = 1}

        if self.previewComp == nil and self.currPreviewId ~= previewID then
            self.previewComp = PreviewComposite.New(self.callback, self.previewsetting, modelData,"ModelPreview")
        elseif self.currPreviewId ~= previewID then
            self.previewComp:Reload(modelData, self.callback)
        end
    	self.currPreviewId = previewID
        local childHappyData = ChildrenManager.Instance:GetHappinessByHugry(self.child.hungry)
        if childHappyData ~= nil and childHappyData.happiness > 4 then
            if self.maxHappyEffect == nil then
                   self.maxHappyEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20357)))
                   self.maxHappyEffect.transform:SetParent(self.transform:Find("ModelPanel/Preview").transform)
                   self.maxHappyEffect.transform.localRotation = Quaternion.identity
                   Utils.ChangeLayersRecursively(self.maxHappyEffect.transform, "UI")
                   self.maxHappyEffect.transform.localScale = Vector3(1, 1, 1)
                   self.maxHappyEffect.transform.localPosition = Vector3(0, -40, -1600)
            end
            self.maxHappyEffect:SetActive(true)
        else
            if self.maxHappyEffect ~= nil then
                self.maxHappyEffect:SetActive(false)
            end
        end
    end
    if self.previewComp ~= nil then
        self.previewComp:Show()
        self:PlayIdleAction()
    end

end

function PetChildView:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
    composite.tpose.transform:Rotate(Vector3(0, -30, 0))
    self:PlayIdleAction()
end

function PetChildView:HidePreview()
	if self.previewComp ~= nil then
		self.previewComp:Hide()
	end
end

function PetChildView:OpenFeed(index)
    if PetManager.Instance.model.currChild == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有孩子，快去生一个吧！"))
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_child_feed, {PetManager.Instance.model.currChild,1})
    end
end

function PetChildView:ClickFight()
    if PetManager.Instance.model.currChild ~= nil then
        local child = PetManager.Instance.model.currChild
        if child.status == ChildrenEumn.Status.Follow then
            if BaseUtils.get_unique_roleid(self.child.follow_id, self.child.f_zone_id, self.child.f_platform) == BaseUtils.get_self_id() then
                ChildrenManager.Instance:Require18624(child.child_id, child.platform, child.zone_id, ChildrenEumn.Status.Idel)
            else
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s正在跟随你的伴侣，无法操作"), self.child.name))
            end
        else
            ChildrenManager.Instance:Require18624(child.child_id, child.platform, child.zone_id, ChildrenEumn.Status.Follow)
        end
    end
end

function PetChildView:UpdateStatus()
    self.child = PetManager.Instance.model.currChild
    if self.child == nil then
        return
    end
    self:ShowPreview()
    if self.child.status == ChildrenEumn.Status.Follow then
        if BaseUtils.get_unique_roleid(self.child.follow_id, self.child.f_zone_id, self.child.f_platform) == BaseUtils.get_self_id() then
            self.fightTxt.text = TI18N("休 息")
            self.fightTxt.color = ColorHelper.DefaultButton1
            self.fightImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        else
            -- 跟随母亲
            if RoleManager.Instance.RoleData.sex == 0 then
                self.fightTxt.text = TI18N("跟随父亲中")
            else
                self.fightTxt.text = TI18N("跟随母亲中")
            end
            self.fightTxt.color = ColorHelper.DefaultButton4
            self.fightImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        end
    else
        self.fightTxt.text = TI18N("携 带")
        self.fightTxt.color = ColorHelper.DefaultButton3
        self.fightImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    end

    self.previewName.text = self.child.name
    self.score.text = string.format("%s(%s)", PetManager.Instance.model:gettalentclass(self.child.talent), self.child.talent)
end

function PetChildView:Rename()
    ChildrenManager.Instance.model:OpenRename(PetManager.Instance.model.currChild)
end

function PetChildView:PlayAction()
    if self.timeId_PlayAction == nil and self.previewComp ~= nil and self.previewComp.tpose ~= nil and self.child ~= nil then
        local model_data = DataChild.data_child[self.child.base_id]
        local animationData = DataAnimation.data_npc_data[model_data.animation_id]
        local action_list = {"1000", "2000", "Idle1" }
        local action_name = action_list[math.random(1, 3)]
        self.previewComp:PlayAnimation(action_name)

        local motion_event = DataMotionEvent.data_motion_event[string.format("%s_%s", action_name, model_data.model_id)]
        if motion_event ~= nil then
            if action_name == "1000" then
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function()
                        self.timeId_PlayAction = nil
                        if not BaseUtils.isnull(self.previewComp.tpose) then
                            self.previewComp:PlayMotion(FighterAction.Stand)
                        end
                    end)
            elseif action_name == "2000" then
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function()
                        self.timeId_PlayAction = nil
                        if not BaseUtils.isnull(self.previewComp.tpose) then
                            self.previewComp:PlayMotion(FighterAction.Stand)
                        end
                    end)
            else
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil end)
            end
        end
    end
end

function PetChildView:PlayIdleAction()
    if self.timeId_PlayAction == nil and self.previewComp ~= nil and self.previewComp.tpose ~= nil and self.child ~= nil then
        self.previewComp:PlayMotion(FighterAction.Idle)
    end
end

function PetChildView:ClickShare()
    -- local btns = {{label = TI18N("朋友圈"), callback = function() ChildrenManager.Instance:Share(self.child) end}
    --             ,{label = TI18N("分享好友"), callback = function() ChildrenManager.Instance:Share(self.child) end}
    --             ,{label = TI18N("世界频道"), callback = function() ChildrenManager.Instance:Share(self.child) end}
    --             ,{label = TI18N("公会频道"), callback = function() ChildrenManager.Instance:Share(self.child) end}}
    local btns = {{label = TI18N("分享好友"), callback = function() ChildrenManager.Instance:Share(MsgEumn.ChatChannel.Private, self.child) end}
                ,{label = TI18N("世界频道"), callback = function() ChildrenManager.Instance:Share(MsgEumn.ChatChannel.World, self.child) end}
                ,{label = TI18N("公会频道"), callback = function() ChildrenManager.Instance:Share(MsgEumn.ChatChannel.Guild, self.child) end}}
    TipsManager.Instance:ShowButton({gameObject = self.shareBtn, data = btns})
end

function PetChildView:onHandBookButtonClick()
    self.handBookPanel:SetActive(true)
    local attrs = self.model:GetHandBookAttr(self.model.cur_petdata)
    self.handBookText[1].text = string.format("+%s", attrs[4])
    self.handBookText[2].text = string.format("+%s", attrs[6])
    self.handBookText[3].text = string.format("+%s", attrs[5])
    self.handBookText[4].text = string.format("+%s", attrs[7])
    self.handBookText[5].text = string.format("+%s", attrs[1])
    self.handBookText[6].text = string.format("+%s", attrs[3])
    -- self.handBookText[7].text = string.format("+%s%%", attrs[54]/10)
    -- self.handBookText[8].text = string.format("+%s%%", attrs[51]/10)
    -- self.handBookText[9].text = string.format("+%s%%", attrs[55]/10)
    self.handBookText[7].text = "+0%"
    self.handBookText[8].text = "+0%"
    self.handBookText[9].text = "+0%"
    self.handBookPanel.transform:FindChild("Main/Line1").gameObject:SetActive(true)
    self.handBookPanel.transform:FindChild("Main/Line2").gameObject:SetActive(true)
    local handbookNumByActiveEffectType = HandbookManager.Instance:GetHandbookNumByActiveEffectType(1)
    local handbookNumByStarEffectType = HandbookManager.Instance:GetHandbookNumByStarEffectType(1)
    self.handBookPanel.transform:FindChild("Main/StarText"):GetComponent(Text).text =
            string.format(TI18N("宠物图鉴已激活：<color='#ffff00'>%s</color>/%s\n1★图鉴已激活：<color='#ffff00'>%s</color>/%s")
                , self.model.cur_petdata.handbook_num, handbookNumByActiveEffectType, self.model.cur_petdata.star_handbook_num, handbookNumByStarEffectType)
    self.moreAttrText[1].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[1]].name, "ffff00", self.child.max_phy_apt_used, 10)
    self.moreAttrText[2].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[2]].name, "ffff00", self.child.max_pdef_apt_used, 10)
    self.moreAttrText[3].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[3]].name, "ffff00", self.child.max_hp_apt_used, 10)
    self.moreAttrText[4].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[4]].name, "ffff00", self.child.max_magic_apt_used, 10)
    self.moreAttrText[5].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[5]].name, "ffff00", self.child.max_aspd_apt_used, 10)
    self.moreAttrText[6].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[6]].name, "ffff00", self.child.use_growth, 10+(self.child.grade)*5)
    self.moreAttrText[7].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[7]].name, "ffff00", self.child.add_point, 20)
end


function PetChildView:opentalksetpanel()
    if self.model.cur_petdata ~= nil then
        PetManager.Instance:Send18633(self.child.child_id, self.child.platform, self.child.zone_id)
        -- self.model:OpenPetSetTalkPanel()
    end
end

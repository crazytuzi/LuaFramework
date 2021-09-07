-- -------------------------------
-- 诸神之战 -- 准备观赛界面
-- -------------------------------
GodsWarChallengePanel = GodsWarChallengePanel or BaseClass(BasePanel)

function GodsWarChallengePanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.godswarchallangepanel, type = AssetType.Main},
        {file = AssetConfig.godswarchallengebg, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self._update = function(dat) self:ReloadData(dat) end
    self._update2 = function()
        self:ReloadStatus()
        self:ShowEffect()
    end

    self.rewardList = {20617,29101,90026}

    self.BossUnit_id = "50_55"

    self.statusDesc = { "未开启","正在开启","挑战成功","挑战失败","挑战失败"}

    self.Status = nil
    self.BossHP = 100

    self.SlotList = {}
    self.VideoId = nil
    self.firstEffect = nil
end

function GodsWarChallengePanel:__delete()

	for i,v in ipairs(self.SlotList) do
		v:DeleteMe()
	end
	self.SlotList = nil

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.headIconLoader ~= nil then
        self.headIconLoader:DeleteMe()
        self.headIconLoader = nil
    end

    if self.firstEffect ~= nil then
        self.firstEffect:DeleteMe()
        self.firstEffect = nil
    end

end

function GodsWarChallengePanel:OnShow()
    -- GodsWarManager.Instance:Send17933()
    GodsWarWorShipManager.Instance.OnUpdateGodsWarChallengeBossStatus:AddListener(self._update)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarChallengeStatus:AddListener(self._update2)
    self.updateTimer = LuaTimer.Add(10,60000,function() GodsWarWorShipManager.Instance:Send17957() end)
    GodsWarWorShipManager.Instance:Send17956()
    self:SetData()
    --self.previewComp:Show()
end

function GodsWarChallengePanel:OnHide()
    GodsWarWorShipManager.Instance.OnUpdateGodsWarChallengeBossStatus:RemoveListener(self._update)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarChallengeStatus:RemoveListener(self._update2)
    if self.updateTimer ~= nil then
        LuaTimer.Delete(self.updateTimer)
        self.updateTimer = nil
    end

    --self.previewComp:Hide()
end

function GodsWarChallengePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarchallangepanel))
    self.gameObject.name = "GodsWarChallengePanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -30)

    self.Bigbg = self.transform:Find("Main/Bigbg")
    local bg = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarchallengebg))
    UIUtils.AddBigbg(self.Bigbg, bg)
    self.Bigbg.anchoredPosition = Vector2(-302.5, 162)


    self.TopCon = self.transform:Find("Main/TopCon")
    self.KuangImg = self.TopCon:Find("Kuang"):GetComponent(Image)
    self.BossImg = self.TopCon:Find("Kuang/Boss")
    self.headIconLoader = SingleIconLoader.New(self.BossImg.gameObject)
    self.headIconLoader:SetSprite(SingleIconType.Other, 1000)
    self.BossHpSlider = self.TopCon:Find("Slider"):GetComponent(Slider)
    self.BossHpPercent = self.TopCon:Find("Slider/Fill Area/Progress"):GetComponent(Text)
    self.BossHpPercent.transform.anchoredPosition = Vector2(-83, -1.3)

    self.StatusText = self.transform:Find("Main/StatusImg/Status"):GetComponent(Text)

    self.BossDesc = self.transform:Find("Main/BossDesc")

    self.Desc2 = self.BossDesc:Find("RightCon/Desc2"):GetComponent(Text)
    self.Desc2.text = TI18N("1、诸神之战王者组冠军队伍参与挑战，其他玩家观战\n2、每间隔一段时间，观战玩家可获得观战奖励\n3、挑战者挑战成功后，全服玩家都可获得来自诸神的奖励，失败不获得奖励")

    self.WatchBtn = self.transform:Find("Main/WatchButton"):GetComponent(Button)
    self.WatchBtn.onClick:AddListener(function() self:OnWatchBtnClick() end)

    self.WatchBtnTxt = self.transform:Find("Main/WatchButton/Text"):GetComponent(Text)
    self.WatchBtnTxt.text = TI18N("观看挑战")
    -- self.Reward1 = self.BossDesc:Find("Reward1")
    -- self.Reward2 = self.BossDesc:Find("Reward1")
    -- self.Reward3 = self.BossDesc:Find("Reward1")

    self.ModelParent = self.BossDesc:Find("Bg")

    self:OnShow()
end

function GodsWarChallengePanel:SetData()
    for i,v in ipairs(self.rewardList) do
        if i > 3 then break end
        local baseid = v
        local _slotbg = self.BossDesc:Find(string.format("Rewards/Reward%s",tostring(i))).gameObject
        self:CreatSlot(baseid,_slotbg, i)
        self.BossDesc:Find(string.format("Rewards/Reward%s",tostring(i))).gameObject:SetActive(true)
    end
    self:SetPreview()
end

function GodsWarChallengePanel:CreatSlot(baseid, parent, index)
    local slot = self.SlotList[index]
    if slot == nil then
        slot = ItemSlot.New()
        self.SlotList[index] = slot
    end
    -- table.insert(self.slotlist, slot)
    local info = ItemData.New()
    local base = DataItem.data_get[baseid]
    info:SetBase(base)
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
end

function GodsWarChallengePanel:ReloadData(data)
    self.VideoId = data.id
    if data ~= nil then
        if data.hp_percent ~= nil then
            self.BossHP = data.hp_percent
        end
        self.BossHpSlider.value = self.BossHP/100
        self.BossHpPercent.text = tostring(TI18N(self.BossHP.."%"))
    end
end
function GodsWarChallengePanel:ReloadStatus()
    local Status = GodsWarWorShipManager.Instance.BossStatus
    if Status ~= nil then
        self.StatusText.text = string.format(TI18N("当前状态  <color='#ffff00'>%s</color>"),self.statusDesc[Status + 1])
    end
    if Status == 0 and GodsWarWorShipManager.Instance.model.isChampion == true then
        self.WatchBtnTxt.text = TI18N("开始挑战")
    else
        self.WatchBtnTxt.text = TI18N("观看挑战")
    end
end


--
function GodsWarChallengePanel:OnWatchBtnClick()
    local model = GodsWarManager.Instance.model
    local roleLev = RoleManager.Instance.RoleData.lev
    local Status = GodsWarWorShipManager.Instance.BossStatus
    if Status == 0 then
        if GodsWarWorShipManager.Instance.model.isChampion == true then
            --SceneManager.Instance:Send10100(55, 50)
            local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
            for k, v in pairs(units) do
                if v.baseid == 58501 then
                    MainUIManager.Instance:OpenDialog(v)
                    model:CloseMain()
                end
            end
        else
            NoticeManager.Instance:FloatTipsByString("活动将在21：15开启")
        end
    elseif Status == 1 then
        --观战
        if self.VideoId ~= nil then
            GodsWarManager.Instance:Send17959(self.VideoId)
            model:CloseMain()
        end
        
    elseif Status == 2 or Status == 3 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 1, group = GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)})
    elseif Status == 4 then
        NoticeManager.Instance:FloatTipsByString("没有玩家发起战斗，无法观看")
    end
end

function GodsWarChallengePanel:SetPreview()
    local data_unit = DataUnit.data_unit[58501]
    local modelData = {type = PreViewType.Npc, skinId = 71015, modelId = data_unit.res, animationId = data_unit.animation_id, scale = 1.7, effects = {{effect_id = 102820},{effect_id = 102830},{effect_id = 102840}}}
    --, effects = {{effect_id = 102820},{effect_id = 102830},{effect_id = 102840}}
    if modelData.scale == nil then
        modelData.scale = 1.1
    else
        modelData.scale = modelData.scale * 1.1
    end
    local callback = function(composite)
        LuaTimer.Add(1000, function()
            if composite ~= nil then
                local particleSystemList = composite.tpose.transform:GetComponentsInChildren(ParticleSystem, true)
                for i=1, (#particleSystemList - 2) do
                    local particleSystem = particleSystemList[i]
                    if particleSystem ~= nil then
                        particleSystem.startSize = particleSystem.startSize * 1.25
                    end
                end
            end
        end)
    end
    if self.previewComp == nil then
        local setting = {
            name = string.format("BossPreview_%s", 1)
            ,layer = "UI"
            ,parent = self.ModelParent
            ,localRot = Vector3(0, 0, 0)
            ,localPos = Vector3(0, -80, -150)
            ,usemask = false
            ,sortingOrder = 10
        }
        self.previewComp = PreviewmodelComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
    --self.previewComp:PlayAction(FighterAction.Stand)

end

function GodsWarChallengePanel:ShowEffect()
    local Status = GodsWarWorShipManager.Instance.BossStatus
    if Status ~= nil then
        if Status == 1 then
            if self.firstEffect == nil then
                self.firstEffect = BibleRewardPanel.ShowEffect(20053, self.WatchBtn.transform, Vector3(1.8,0.7,1), Vector3(-54.4, -16.6, -400))
                self.firstEffect:SetActive(false)
            end
            self.firstEffect:SetActive(true)
        else
            if self.firstEffect ~= nil then
                self.firstEffect:SetActive(false)
            end
        end
    end
end
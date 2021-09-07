-- 战斗录像
-- @author huangzefeng
-- @date 20160517
CombatLogWindow = CombatLogWindow or BaseClass(BaseWindow)

function CombatLogWindow:__init(model)
    self.model = model
    self.name = "CombatLogWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.winLinkType = WinLinkType.Single
    self.currpage = nil
    self.subargs = nil
    self.resList = {
        {file = AssetConfig.combatlog_window, type = AssetType.Main}
        -- ,{file = "prefabs/effect/20110.unity3d", type = AssetType.Main}
        -- ,{file = AssetConfig.agenda_textures, type = AssetType.Dep}
        -- -- ,{file = AssetConfig.dungeonbossname, type = AssetType.Dep}
        -- ,{file = AssetConfig.dungeonname, type = AssetType.Dep}
        -- ,{file = AssetConfig.dailyicon, type = AssetType.Dep}
    }
    CombatManager.Instance:Send10747()
    CombatManager.Instance:Send10748()
    CombatManager.Instance:Send10749()
    self.closefunc = function(cbtype)
        self.model:CloseWin()
    end
    self.openfunc = function(cbtype)
    print(CombatManager.Instance.isWatchRecorder)
        if  CombatManager.Instance.isWatchRecorder then
            self.model:OpenWindow()
        end
    end
    self.OnOpenEvent:AddListener(function() self:OnShow() end)
end

function CombatLogWindow:__delete()
    print("清理了")
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.openfunc)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.closefunc)
    self:ClearDepAsset()
    if self.selfpanel ~= nil then
        self.selfpanel:DeleteMe()
    end
    if self.rankpanel ~= nil then
        self.rankpanel:DeleteMe()
    end
end

function CombatLogWindow:OnShow()
    if self.gameObject ~= nil then
        self.transform:SetAsLastSibling()
    end
    -- print(self.agendaMgr.currTimeLimitID)
    CombatManager.Instance:Send10747()
    CombatManager.Instance:Send10748()
    CombatManager.Instance:Send10749()
end

function CombatLogWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.combatlog_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.MainCon = self.transform:Find("Main")
    self.selfpanel = CombatLogSelfPanel.New(self)
    self.rankpanel = CombatLogRankPanel.New(self)
    local go = self.transform:Find("Main/TabButtonGroup").gameObject
    self.tabgroup = TabGroup.New(go, function (tab) self:OnTabChange(tab) end, {notAutoSelect = true})
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseWin()
    end)
    EventMgr.Instance:AddListener(event_name.end_fight, self.openfunc)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.closefunc)
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.subargs = self.openArgs[2]
        self.tabgroup:ChangeTab(self.openArgs[1])
    else
        self.tabgroup:ChangeTab(1)
    end
end

function CombatLogWindow:OnTabChange(idnex)
    if idnex == 1 then
        if self.rankpanel.hasinit then
            self.rankpanel:Hiden()
        end
        self.selfpanel:Show(self.subargs)
        self.subargs = nil
    elseif idnex == 2 then
        if self.selfpanel.hasinit then
            self.selfpanel:Hiden()
        end
        self.rankpanel:Show(self.subargs)
        self.subargs = nil
    end
end

function CombatLogWindow:SetTabBtn(btnTrans, name)
    btnTrans:Find("Normal/Text"):GetComponent(Text).text = name
    btnTrans:Find("Select/Text"):GetComponent(Text).text = name
end
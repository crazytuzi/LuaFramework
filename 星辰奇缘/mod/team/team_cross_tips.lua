-- --------------------------------
-- 组队跨服提示
-- hosr
-- 2016-05-18-12-04
-- --------------------------------
TeamCrossTips = TeamCrossTips or BaseClass(BasePanel)

function TeamCrossTips:__init(main)
    self.main = main
    self.path = "prefabs/ui/team/teamcross.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
    }

    self.OnHideEvent:Add(function() self:OnHide() end)
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.init = false
end

function TeamCrossTips:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function TeamCrossTips:OnShow()
    self.toggle.isOn = (TeamManager.Instance.IsCross == 1)

    if RoleManager.Instance.RoleData.cross_type == 0 then
        self.button.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("进入跨服")
    else
        self.button.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("返回原服")
    end
end

function TeamCrossTips:OnHide()
end

function TeamCrossTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "TeamCrossTips"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.main.gameObject, self.gameObject)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Main/ToggleBtn"):GetComponent(Button).onClick:AddListener(function() self:ToggleChange() end)
    self.transform:Find("Main/Text"):GetComponent(Text).text = TI18N("组队进行<color='#ffff00'>悬赏任务、多人副本、天空之塔</color>时，如果<color='#ffff00'>30秒</color>内本服无法匹配到玩家，则自动<color='#ffff00'>跨服匹配</color>。\n\n<color='#ffff00'>（成功匹配至其他服队伍时，则自动跨服入队练级）</color>")
    self.toggle = self.transform:Find("Main/Toggle"):GetComponent(Toggle)
    self.button = self.transform:Find("Main/Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:OnClick() end)
    self.button.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("进入跨服")
    self.toggleMatch = self.transform:Find("Main/ToggleMatch"):GetComponent(Toggle)
    self.toggleMatch.isOn = TeamManager.Instance.crossAutoMatch
    self.toggleMatch.onValueChanged:AddListener(function(v) self:ToggleMatchChange(v) end)

    self.crossArenaButton = self.transform:Find("Main/CrossArenaButton"):GetComponent(Button)
    self.crossArenaButton.onClick:AddListener(function() self:OnCrossArenaButtonClick() end)

    self:OnShow()
    self.init = true
end

function TeamCrossTips:OnClick()

    if RoleManager.Instance.RoleData.cross_type == 0 then
        if TeamManager.Instance.TypeOptions[3] == nil and TeamManager.Instance.TypeOptions[4] == nil and TeamManager.Instance.TypeOptions[5] == nil and TeamManager.Instance.TypeOptions[7] == nil then
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[5] = 0
            TeamManager.Instance.LevelOption = 1
            EventMgr.Instance:Fire(event_name.team_info_update)
        end

        if TeamManager.Instance.crossAutoMatch then
            RoleManager.Instance.jump_over_call = function() TeamManager.Instance:AutoFind() end
        else
            RoleManager.Instance.jump_over_call = nil
        end
        local mapId = SceneManager.Instance:CurrentMapId()
        if mapId == ExquisiteShelfManager.Instance.readyMapId then
            SceneManager.Instance.enterCenter(mapId)
        else
            SceneManager.Instance.enterCenter()
        end
    else
        SceneManager.Instance.quitCenter()
    end
    
    self:Close()
end

function TeamCrossTips:OnCrossArenaButtonClick()
    CrossArenaManager.Instance:EnterScene()
    self:Close()
end

function TeamCrossTips:ToggleChange()
    if TeamManager.Instance.IsCross == 1 then
        self.toggle.isOn = false
        TeamManager.Instance:Send11737(0)
    else
        self.toggle.isOn = true
        TeamManager.Instance:Send11737(1)
    end
end

function TeamCrossTips:Close()
    self:Hiden()
end

function TeamCrossTips:ToggleMatchChange(value)
    TeamManager.Instance.crossAutoMatch = value
    if value then
        NoticeManager.Instance:FloatTipsByString(TI18N("进入跨服后将<color='#ffff00'>自动匹配</color>"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("进入跨服后将<color='#ffff00'>不自动</color>匹配"))
    end
end
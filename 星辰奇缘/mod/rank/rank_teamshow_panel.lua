-- @author ###
-- @date 2018年8月10日,星期五

RankTeamShowPanel = RankTeamShowPanel or BaseClass(BasePanel)

function RankTeamShowPanel:__init(model)
    self.model = model
    self.name = "RankTeamShowPanel"
    self.resList = {
        {file = AssetConfig.rank_team_panel, type = AssetType.Main}
        ,{file = AssetConfig.teamres, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.ItemList = {}
end

function RankTeamShowPanel:__delete()
    self.OnHideEvent:Fire()
    TipsManager.Instance.model.tipsCanvas.transform:GetComponent(Canvas).overrideSorting = false
    NoticeManager.Instance.model.noticeCanvas.transform:GetComponent(Canvas).overrideSorting = false

    if next(self.ItemList) ~= nil then
        for i,v in pairs(self.ItemList) do
            if v.go ~= nil then
                v.go:DeleteMe()
                v.go = nil
            end
        end
        self.ItemList = nil
    end

    if self.Layout ~= nil then
        self.Layout:DeleteMe()
        self.Layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RankTeamShowPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rank_team_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self.model:CloseRankTeamShowPanel() end)
    self.mainScrollRect = t:Find("Main/Scroll")
    self.mainScrollRect:GetComponent(Image).material = PreloadManager.Instance:GetMainAsset("textures/materials/uimask.unity3d")
    self.Container = t:Find("Main/Scroll/Container")
    self.item = t:Find("Main/Scroll/Container/Member1").gameObject
    self.item:SetActive(false)
    self.Layout = LuaBoxLayout.New(self.Container, {axis = BoxLayoutAxis.X, border = 2, cspacing = 4})

    self.TeamName = t:Find("Main/Name"):GetComponent(Text)
    self.FightNum = t:Find("Main/Fight")
    self.FightNum.gameObject:SetActive(false)

    self.leftButton = t:Find("Main/PrePageBtn"):GetComponent(Button)
    self.leftEnable = self.leftButton.transform:Find("Enable").gameObject
    self.leftDisable = self.leftButton.transform:Find("Disable").gameObject

    self.rightButton = t:Find("Main/NextPageBtn"):GetComponent(Button)
    self.rightEnable = self.rightButton.transform:Find("Enable").gameObject
    self.rightDisable = self.rightButton.transform:Find("Disable").gameObject

end

function RankTeamShowPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RankTeamShowPanel:OnOpen()
    self:RemoveListeners()
    TipsManager.Instance.model.tipsCanvas.transform:GetComponent(Canvas).overrideSorting = true
    NoticeManager.Instance.model.noticeCanvas.transform:GetComponent(Canvas).overrideSorting = true
    self.teamData = self.model.rankTeamShowList
    self.InfoList = self.teamData.mate_list
    --self.InfoList = TeamManager.Instance:GetMemberOrderList()
    self.doTween = false
    self:SetData()
    self:IsHideArrow()
end

function RankTeamShowPanel:OnHide()
    self:RemoveListeners()
    TipsManager.Instance.model.tipsCanvas.transform:GetComponent(Canvas).overrideSorting = false
    NoticeManager.Instance.model.noticeCanvas.transform:GetComponent(Canvas).overrideSorting = false
end

function RankTeamShowPanel:RemoveListeners()
end

function RankTeamShowPanel:SetData()
    for i,v in pairs(self.InfoList) do
        if self.ItemList[i] == nil then
            local item = {}
            item.go = RankTeamShowItem.New(GameObject.Instantiate(self.item), self)
            self.Layout:AddCell(item.go.gameObject)
            self.ItemList[i] = item
            self.ItemList[i].go:update_my_self(v,i)
        end
    end

    self.TeamName.text = string.format("%s(%s)",self.teamData.team_name,BaseUtils.GetServerNameMerge(self.InfoList[1].platform, self.InfoList[1].zone_id))
end

function RankTeamShowPanel:IsHideArrow()
    self.leftEnable:SetActive(false)
    self.leftDisable:SetActive(true)
    self.rightEnable:SetActive(false)
    self.rightDisable:SetActive(true)
end


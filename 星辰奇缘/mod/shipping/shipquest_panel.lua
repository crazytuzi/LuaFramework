ShipQuestPanel = ShipQuestPanel or BaseClass(BasePanel)

ShipMatchEumn ={
    [1] = 92,
    [2] = 93,
    [3] = 94,
}

function ShipQuestPanel:__init(quest_box)
    self.mgr = ShippingManager.Instance
    self.model = ShippingManager.Instance.model
    self.path = "prefabs/ui/shipping/shipquestwindow.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
        ,{file = AssetConfig.shiptextures, type = AssetType.Dep}
    }
    self.name = "ShipQuestWindow"
    self.qbox = quest_box
    self.update_item = function()
        self:LoadData()
    end
    self.shipicon = {
        [1001] = 1,
        [1002] = 2,
        [1003] = 3,
    }
end

function ShipQuestPanel:__delete()
    if self.TextEXT ~= nil then
        self.TextEXT:DeleteMe()
        self.TextEXT = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end
-- args {needid =1, rid = 1, platform = "dev", zone_id = zoenid, type = "求助类型"}
function ShipQuestPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseQuestPanel() end)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseQuestPanel() end)
    self.title = self.transform:Find("Main/Title"):GetComponent(Text)
    self.timestxt = self.transform:Find("Main/ItemCon/TimesText"):GetComponent(Text)
    self.timestxt.gameObject:SetActive(false)
    self.destxt = self.transform:Find("Main/ItemCon/descText"):GetComponent(Text)
    self.tipstxt = self.transform:Find("Main/ItemCon/tipsText"):GetComponent(Text)

    self:LoadData()
    self.LeftBtn = self.transform:Find("Main/ItemCon/Creatbtn"):GetComponent(Button)
    self.RightBtn = self.transform:Find("Main/ItemCon/Aceptbtn"):GetComponent(Button)
    self.LeftBtn.onClick:AddListener(function()
        self:OnCreat()
    end)
    self.RightBtn.onClick:AddListener(function()
        self:OnDo()
    end)
end

function ShipQuestPanel:LoadData()
    -- local Cycledata = DataShipping.data_quest[self.qbox.id]
    BaseUtils.dump(self.qbox)
    local Cycledata
    for k,v in pairs(DataShipping.data_quest_end) do
        if self.qbox.id == v.id then
            Cycledata = v
        end
    end
    self.title.text = Cycledata.qname
    -- self.timestxt.text = string.format("%s/%s", Cycledata.ring, Cycledata.max_ring)
    self.TextEXT = MsgItemExt.New(self.destxt, 220, 17, 25)
    self.TextEXT:SetData(Cycledata.desc)
    -- self.destxt.text = Cycledata.desc
    if self.shipicon[self.qbox.id] == 1 then
        self.tipstxt.text = TI18N("（<color='#ffff00'>多人组队</color>奖励更丰厚）")
    elseif self.shipicon[self.qbox.id] == 2 then
        self.tipstxt.text = TI18N("（组队<color='#ffff00'>人数越多</color>拾取<color='#fff00'>速度越快</color>喔）")
    else
        self.tipstxt.text = TI18N("（<color='#ffff00'>多人组队</color>奖励更丰厚）")
    end
    self.transform:Find("Main/ItemCon/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.shiptextures, self.shipicon[self.qbox.id])
    -- print(self.shipicon[self.qbox.id])
end

function ShipQuestPanel:OnCreat()
    -- local Cycledata = DataShipping.data_quest[self.qbox.quest_id]
    -- local Cycledata
    -- for k,v in pairs(DataShipping.data_quest_end) do
    --     if self.qbox.id == v.id then
    --         Cycledata = v
    --     end
    -- end
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
        NoticeManager.Instance:FloatTipsByString(TI18N("只有队长才能完成此任务"))
    else
        TeamManager.Instance:Send11701()
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[10] = ShipMatchEumn[self.shipicon[self.qbox.id]]
        TeamManager.Instance.LevelOption = 1
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
        -- NoticeManager.Instance:FloatTipsByString(TI18N("创建队伍成功，请招募队员"))
    end
end

function ShipQuestPanel:OnDo()
    if RoleManager.Instance.RoleData.cross_type == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("跨服暂不支持完成该远航任务"))
        return
    end
    self.model:CloseQuestPanel()
    self.model:CloseMain()
    if self.qbox.id == 1001 then
        local Qdata = QuestManager.Instance:GetQuest(self.qbox.quest_id)
        QuestManager.Instance:DoQuest(Qdata)
    elseif self.qbox.id == 1002 then
        local uid = "76510_0"
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_PathToTarget(uid)
        -- DungeonManager.Instance:Require12100(30001)
    elseif self.qbox.id == 1003 then
        ShippingManager.Instance:Req13715(self.qbox.id)
    end
end


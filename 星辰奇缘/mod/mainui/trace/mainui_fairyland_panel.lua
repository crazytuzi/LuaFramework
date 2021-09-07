-- --------------------------
--幻境追踪面板
-- --------------------------
MainuiFairyLandPanel = MainuiFairyLandPanel or BaseClass(BaseTracePanel)

function MainuiFairyLandPanel:__init(main)
    self.main = main
    self.isInit = false
    self.gameObject = nil
    self.mainObj = nil
    self.timer_id = 0
    self.my_time = 0

    self.descTips = {TI18N("1.在<color='#ffff00'>彩虹幻境</color>中roll点未抽中时，可能获得{assets_2,90035}")
                    , TI18N("2.{assets_2,90035}可在活动结束后于<color='#ffff00'>魔盒</color>中抽奖")
                    , TI18N("3.上次活动未使用完的{assets_2,90035}，会一直<color='#ffff00'>累积</color>")
                    , TI18N("4.彩虹魔盒<color='#ffff00'>持续1小时</color>，未抽奖的玩家可在下次活动结束时抽奖")}

    self._UpdateAsset = function()
        self:UpdateAsset()
    end

    self.resList = {
        {file = AssetConfig.fairyland_content, type = AssetType.Main}
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiFairyLandPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiFairyLandPanel:OnShow()
    FairyLandManager.Instance:request14603()
    self:UpdateAsset()

    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self._UpdateAsset)
end

function MainuiFairyLandPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._UpdateAsset)
end

function MainuiFairyLandPanel:OnHide()
    self:RemoveListeners()
end

function MainuiFairyLandPanel:__delete()
    self.OnHideEvent:Fire()
    self:stop_timer()
end

function MainuiFairyLandPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fairyland_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    self.rect = self.gameObject:GetComponent(RectTransform)

    --进入的逻辑
    self.Container = self.transform:Find("Container")
    self.ImgTitle = self.Container:Find("ImgTitle")
    self.TxtDesc = self.ImgTitle:Find("TxtDesc"):GetComponent(Text)

    self.taskItem = self.Container:Find("taskItem")
    self.TxtKey1 = self.taskItem:Find("TxtKey1"):GetComponent(Text)
    self.TxtKey2 = self.taskItem:Find("TxtKey2"):GetComponent(Text)
    self.TxtKey3 = self.taskItem:Find("TxtKey3"):GetComponent(Text)
    self.taskItem_btn = self.taskItem:GetComponent(Button)

    self.TxtKey1.text = "0"
    self.TxtKey2.text = "0"
    self.TxtKey3.text = "0"

    self.taskItem2 = self.Container:Find("taskItem2")
    self.TxtClockVal = self.taskItem2:Find("TxtClockVal"):GetComponent(Text)
    self.taskItem4 = self.Container:Find("taskItem4")
    self.numText = self.taskItem4:Find("NumText"):GetComponent(Text)
    self.descButton = self.taskItem4:Find("DescButton"):GetComponent(Button)
    self.BtnShou = self.Container:Find("BtnShou"):GetComponent(Button)
    self.BtnQuick = self.Container:Find("BtnQuick"):GetComponent(Button)

    --未进入逻辑
    self.Container_UnOpen = self.transform:Find("Container_UnOpen")
    self.taskItemClock = self.Container_UnOpen:Find("taskItemClock")
    self.TxtOpenClockVal = self.taskItemClock:Find("TxtClockVal"):GetComponent(Text)
    self.BtnGo = self.Container_UnOpen:Find("BtnGo"):GetComponent(Button)
    self.BtnTeam = self.Container_UnOpen:Find("BtnTeam"):GetComponent(Button)
    self.ImgExp = self.Container_UnOpen:Find("ImgExp")
    self.TxtExp = self.ImgExp:Find("TxtVal"):GetComponent(Text)
    self.BtnLeft = self.Container_UnOpen:Find("BtnLeft"):GetComponent(Button)
    -- self.TxtExp

    self.Container.gameObject:SetActive(false)
    self.Container_UnOpen.gameObject:SetActive(true)

    self.BtnShou.onClick:AddListener(function()
        self:on_click_btn()
    end)

    self.BtnQuick.onClick:AddListener(function()
        FairyLandManager.Instance:request14602(TI18N("退出彩虹冒险将清空所有钥匙，确定要退出活动吗？"))
    end)

    self.taskItem_btn.onClick:AddListener(function()
        self:on_click_key_btn()
    end)

    self.BtnLeft.onClick:AddListener(function()
        self:on_click_left_btn()
    end)
    self.BtnGo.onClick:AddListener(function()
        self:on_click_go_btn()
    end)
    self.BtnTeam.onClick:AddListener(function()
        self:on_click_team_btn()
    end)
    self.descButton.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.descButton.gameObject, itemData = self.descTips})
    end)

    FairyLandManager.Instance:request14603()
    self.on_transport_success = function()
        self:on_transport_finish()
    end
    EventMgr.Instance:AddListener(event_name.scene_load, self.on_transport_success)

    self.isInit = true
end

--------------------------------时间监听逻辑
--传送场景完成
function MainuiFairyLandPanel:on_transport_finish()
    if SceneManager.Instance:CurrentMapId() == DataFairy.data_layer[1].map then
        self.Container.gameObject:SetActive(true)
        self.Container_UnOpen.gameObject:SetActive(false)
    end
end

--查看钥匙
function MainuiFairyLandPanel:on_click_key_btn()
    FairyLandManager.Instance.model:InitKeyUI()
end

--幻境手札
function MainuiFairyLandPanel:on_click_btn()
    -- print("-------------------------------------幻境手札")
    FairyLandManager.Instance.model:InitLetterUI()
end

--退出幻境
function MainuiFairyLandPanel:on_click_left_btn()
    FairyLandManager.Instance:request14602()
end

--进入幻境
function MainuiFairyLandPanel:on_click_go_btn()
    --寻路到那个npc
    -- DataFairy.data_layer[0]
    -- [0] = {id = 0, map = 70012, neutral_unit = {79653}, neutral_location = {{2043,1513}}, enemy_unit = {}, box_unit = {}},
    local id_battle_id = BaseUtils.get_unique_npcid(DataFairy.data_layer[0].neutral_unit[1], 10)
    SceneManager.Instance.sceneElementsModel:Self_AutoPath(DataFairy.data_layer[0].map, id_battle_id, nil, nil, true)
end

--点击便捷组队
function MainuiFairyLandPanel:on_click_team_btn()
    TeamManager.Instance.TypeOptions = {}
    TeamManager.Instance.TypeOptions[6] = 62
    TeamManager.Instance.LevelOption = 1
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1,1})
end

--------------------------------各种更新逻辑
--更新总入口
function MainuiFairyLandPanel:update_info(data,_type)
    if self.isInit == false then
        return
    end

    if data.forward_envoys == nil or #data.forward_envoys == 1 then
        self.BtnShou.gameObject:SetActive(false)
        self.BtnQuick.gameObject.transform.localPosition = Vector3(115, -226.6, 0)
    else
        self.BtnShou.gameObject:SetActive(true)
        self.BtnQuick.gameObject.transform.localPosition = Vector3(58, -226.6, 0)
    end

    if FairyLandManager.Instance.model.status == 2 then
        self.taskItemClock.gameObject:SetActive(false)
        self.ImgExp.gameObject:SetActive(false)
        self.BtnGo.gameObject:SetActive(true)
        self.BtnTeam.gameObject:SetActive(true)
    else
        self.taskItemClock.gameObject:SetActive(true)
        self.ImgExp.gameObject:SetActive(true)
        self.BtnGo.gameObject:SetActive(false)
        self.BtnTeam.gameObject:SetActive(false)
    end

    if SceneManager.Instance:CurrentMapId() == DataFairy.data_layer[0].map then
        self.Container.gameObject:SetActive(false)
        self.Container_UnOpen.gameObject:SetActive(true)
    else
        self.Container.gameObject:SetActive(true)
        self.Container_UnOpen.gameObject:SetActive(false)
        if data.floor ~= nil then
            self.TxtDesc.text = string.format("%s<color='#8DE92A'>%s/%s</color>%s", TI18N("当前处于"), data.floor, 12, TI18N("层幻境"))
        end
        self.TxtKey1.text = "0"
        self.TxtKey2.text = "0"
        self.TxtKey3.text = "0"
        if data.keys ~= nil then
            for i=1,#data.keys do
                local key = data.keys[i]
                if key.type == 1 then
                    --铜
                    self.TxtKey1.text = tostring(key.num)
                elseif key.type == 2 then
                    --银
                    self.TxtKey2.text = tostring(key.num)
                elseif key.type == 3 then
                    --金
                    self.TxtKey3.text = tostring(key.num)
                end
            end
        end
    end
    if data.exp ~= nil then
        self.TxtExp.text = tostring(data.exp)
    end

    self.numText.text = tostring(RoleManager.Instance.RoleData.crystal)
    -- self.my_time = FairyLandManager.Instance.model.left_time
    -- self:start_timer()
end

function MainuiFairyLandPanel:UpdateAsset()
    self.numText.text = tostring(RoleManager.Instance.RoleData.crystal)
end

-----------------------计时器
--累计总耗时计时器
function MainuiFairyLandPanel:start_timer()
    self:stop_timer()
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function MainuiFairyLandPanel:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

function MainuiFairyLandPanel:timer_tick()
    if self.isInit == false then
        return
    end
    local _, _, my_minute, my_second = BaseUtils.time_gap_to_timer(FairyLandManager.Instance.model.left_time)
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
    self.TxtClockVal.text = string.format("%s:%s", my_minute, my_second)
    self.TxtOpenClockVal.text = string.format("%s:%s", my_minute, my_second)
end
--2016/11/4
--xjlong
--双十一活动
DoubleElevenManager = DoubleElevenManager or BaseClass(BaseManager)

function DoubleElevenManager:__init()
    if DoubleElevenManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    DoubleElevenManager.Instance = self
    self:InitHandler()
    self.model = DoubleElevenModel.New()

    self.redPointDataDic = {
        [1] = false,
        [2] = false,
    } --model.tab_data_list里面的{id=true/false,}

    --角色是否已加载完成
    self.isSelfLoaded = false

    self.singleDogIsOpen = false

    self.questGet = false

    self.canGetReward = true
    --self.questDone = false

    self.singleDogOpened = false

    self.christmasSceneListener = function() self:OnMapLoaded() end

    self.selfRoleLoaded = function()
        self.isSelfLoaded = true
    end

    self.snowmanEvent = EventLib.New()
    self.closeSingleDog = EventLib.New()
    EventMgr.Instance:AddListener(event_name.self_loaded, self.selfRoleLoaded)
end

function DoubleElevenManager:__delete()
    self.model:DeleteMe()
    self.model = nil

    EventMgr.Instance:RemoveListener(event_name.self_loaded, self.selfRoleLoaded)
end

function DoubleElevenManager:InitHandler()
    self:AddNetHandler(14045, self.On14045)
    self:AddNetHandler(14046, self.On14046)
    self:AddNetHandler(17819, self.On17819)
    self:AddNetHandler(17820, self.On17820)
    self:AddNetHandler(10258, self.On10258)
end

function DoubleElevenManager:RequestInitData()
    local baseTime = BaseUtils.BASE_TIME
    local timeData = DataCampaign.data_list[780].cli_end_time[1]
    local endTime = tonumber(os.time{year = timeData[1], month = timeData[2], day = timeData[3], hour = timeData[4], min = timeData[5], sec = timeData[6]})
    local timestamp = endTime - baseTime
    local curDay = math.modf(timestamp / 3600 / 24)
    local startQuest = 83670 - 10 * curDay

    QuestManager.Instance:Send10212(startQuest)

end



--双十一活动
function DoubleElevenManager:SetIcon()
    -- MainUIManager.Instance:DelAtiveIcon3(318)
    -- if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
    --     return
    -- end
    -- local systemIcon = DataCampaign.data_camp_ico[CampaignEumn.Type.DoubleEleven]
    -- if CampaignManager.Instance.campaignTree[CampaignEumn.Type.DoubleEleven] == nil then
    --     return
    -- end
    -- self.activeIconData = AtiveIconData.New()
    -- local iconData = DataSystem.data_daily_icon[318]
    -- self.activeIconData.id = iconData.id
    -- self.activeIconData.iconPath = iconData.res_name
    -- self.activeIconData.sort = iconData.sort
    -- self.activeIconData.lev = iconData.lev
    -- self.activeIconData.clickCallBack = function()
    --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.double_eleven_window)
    -- end
    -- MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
end

-- 圣诞
function DoubleElevenManager:SetIcon1()
    MainUIManager.Instance:DelAtiveIcon3(322)
    local systemIcon = DataCampaign.data_camp_ico[CampaignEumn.Type.Christmas]
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.Christmas] == nil then
        return
    end
    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[322]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.double_eleven_window)
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
end

----------------------检查是否显示红点
--各个自功能检查是否图标需要显示红点
function DoubleElevenManager:check_red_point()
    local state = false
    state = self.redPointDataDic[1]
    state = state or self.redPointDataDic[2]
    local cfg_data = DataSystem.data_daily_icon[318]
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(cfg_data.id, state)
    end
end

-------------------协议接收逻辑
function DoubleElevenManager:On14045(data)
    BaseUtils.dump(data, TI18N("<color=#FF0000>接收14045</color>"))
    self.model:SetGroupBuyData(data)
end

function DoubleElevenManager:On14046(data)
    BaseUtils.dump(data, TI18N("<color=#FF0000>接收14046</color>"))
    if data.flag == 1 then
        self.model:UpdateGroupBuyData(data)
    end

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function DoubleElevenManager:On17819(data)
    self.model.snowmanData = data
    self.snowmanEvent:Fire()
end

function DoubleElevenManager:On17820(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function DoubleElevenManager:On10258()
    --print(10258)
    NoticeManager.Instance:FloatTipsByString(TI18N("恭喜您成功帮他驱赶了恶习，并获得来自单身汪的回礼，收集齐还可以领取奖励哟{face_1,107}"))
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_uniwin, {780})
end

-------------------协议发送逻辑
function DoubleElevenManager:Send14045()
    -- print("发送14045")
    Connection.Instance:send(14045, { })
end

function DoubleElevenManager:Send14046(id, num)
  -- print("发送14046")
    Connection.Instance:send(14046, { id = id, num = num })
end

function DoubleElevenManager:Send17819()
    Connection.Instance:send(17819, {})
end

function DoubleElevenManager:Send17820(type)
    Connection.Instance:send(17820, {type = type})
end

function DoubleElevenManager:FindNpc(mapid, key)
    if SceneManager.Instance:CurrentMapId() ~= mapid then
        self.findingMapId = mapid
        self.findingKey = key
        EventMgr.Instance:RemoveListener(event_name.scene_load, self.christmasSceneListener)
        EventMgr.Instance:AddListener(event_name.scene_load, self.christmasSceneListener)
        SceneManager.Instance.sceneElementsModel:Self_Transport(mapid, 0, 0)
    else
        self.findingKey = nil
        self.findingMapId = nil
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(mapid, key)
    end
end

function DoubleElevenManager:OnMapLoaded()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.christmasSceneListener)
    self:FindNpc(self.findingMapId, self.findingKey)
    self.findingKey = nil
    self.findingMapId = nil
end


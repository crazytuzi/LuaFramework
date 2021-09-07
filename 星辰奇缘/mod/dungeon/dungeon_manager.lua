DungeonManager = DungeonManager or BaseClass(BaseManager)

TowerMap = {
    [1] = 41001,
    [2] = 41002,
    [3] = 41003,
    }
towernpc = {
    10026,10027,10028
}
function DungeonManager:__init()
    if DungeonManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    DungeonManager.Instance = self
    self.assetWrapper = nil
    self.model = DungeonModel.New()
    self.currdungeonID = 0
    self.currdungeonunit = nil
    self.BeginEffectres = "prefabs/effect/30020.unity3d"
    self.EndEffectres = "prefabs/effect/30019.unity3d"
    self.resList = {
        {file = "prefabs/effect/30020.unity3d", type = AssetType.Main}
        ,{file = "prefabs/effect/30019.unity3d", type = AssetConfig.Main}
    }
    self.traceing = false
    self.tower_floor = 0
    self.dungeon_status = false
    self.isFirstClick = false
    self.hasNoticeByFloor = {}
    self.autoExitTeam = false -- 完成后自动退队
    self.listener = function ()
        LuaTimer.Add(500, function() self:CheckOutStatus()end )
        -- self:CheckOutStatus()
        self:SetHelpIcon()
    end
    self.tower_85_max_floor = 9
    self.rankText = {}
    self.extraInfoDic = {}
    self:InitHandler()
    self.towerRewardList = {}
    self.lastReqTime = -10000
    self.retrytimes = 0
    self.InfoChangeEvent = EventLib.New()
    self.onTreasureBoxUpdate = EventLib.New()
    self.onKillTimes = EventLib.New()
    self.onUpdateExtra = EventLib.New()
end

function DungeonManager:__delete()
    self.model:DeleteMe()
end

function DungeonManager:InitHandler()
    self:AddNetHandler(12100, self.On12100)
    self:AddNetHandler(12101, self.On12101)
    self:AddNetHandler(12103, self.On12103)
    self:AddNetHandler(12104, self.On12104)
    self:AddNetHandler(12110, self.On12110)
    self:AddNetHandler(12111, self.On12111)
    self:AddNetHandler(12112, self.On12112)
    self:AddNetHandler(12114, self.On12114)
    self:AddNetHandler(12116, self.On12116)
    self:AddNetHandler(12117, self.On12117)
    self:AddNetHandler(12118, self.On12118)
    self:AddNetHandler(12119, self.On12119)
    self:AddNetHandler(12300, self.On12300)
    self:AddNetHandler(12301, self.On12301)
    self:AddNetHandler(12302, self.On12302)
    self:AddNetHandler(14300, self.On14300)
    self:AddNetHandler(14301, self.On14301)
    self:AddNetHandler(14302, self.On14302)
    self:AddNetHandler(14303, self.On14303)
    self:AddNetHandler(14304, self.On14304)
    self:AddNetHandler(14305, self.On14305)

    self:AddNetHandler(12320, self.On12320)
    self:AddNetHandler(12321, self.On12321)
    self:AddNetHandler(12120, self.On12120)
    self:AddNetHandler(12121, self.On12121)
    self:AddNetHandler(12122, self.On12122)
    self:AddNetHandler(12123, self.on12123)

    self:AddNetHandler(10172, self.On10172)

    -- EventMgr.Instance:AddListener(event_name.logined, self.listener)
    -- EventMgr.Instance:AddListener(event_name.self_loaded, self.listener)
    -- EventMgr.Instance:AddListener(event_name.role_status_change, function(st) self.listener() end)
    -- EventMgr.Instance:AddListener(event_name.self_loaded, function() print("<color='#FF0000'>自身加载请求@@@@@</color>") self.listener() end)
    EventMgr.Instance:AddListener(event_name.scene_load, self.listener)
    self:InitTowerData()
end

------------------------------------------------------------------------------------------------------------
--===================================协议处理====================================================
-------------------------------------------------------------------------------------------------------------

-- 进入
function DungeonManager:Require12100(ID, flag)
    self.currdungeonID = ID
    self.hasNoticeByFloor = {}
    self:BeginEffect()
    LuaTimer.Add(900, function () Connection.Instance:send(12100,{dun_id = ID, battle_flag = flag ~= nil and flag or 1 }) end)
end

function DungeonManager:On12100(data)
    if data.flag == 1 then
        self.traceing = true
        self.dungeon_status = true
        MainUIManager.Instance.mainuitracepanel:ChangeShowType(TraceEumn.ShowType.Dungeon)
        MainUIManager.Instance.mainuitracepanel.traceDun:SetId(self.currdungeonID)
    else
        self.currdungeonID = nil
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
    LuaTimer.Add(1200, function () self:EndEffect() end)
    self:ShowMsg(data.msg)
end

-- 退出
function DungeonManager:Require12101()
    Connection.Instance:send(12101, {})
end

function DungeonManager:On12101(data)
    -- BaseUtils.dump(data, "12101结果")
    if data.flag == 1 then
        TeamDungeonManager.Instance.dungeon_status = false
        self.dungeon_status = false
        self.traceing = false
        MainUIManager.Instance.mainuitracepanel:AutoShowType()
    end
    self:ShowMsg(data.msg)
end

--请求副本信息
function DungeonManager:Require12102()
    Connection.Instance:send(12102, {})
end

function DungeonManager:On12103(data)
    -- BaseUtils.dump(data, "基本副本信息")
    self.currdungeonID = data.id
    self.currdungeonunit = data.unit_id
    self.currextdata = data.extra
    -- if MainUIManager.Instance.mainuitracepanel.traceDun.isInit == true then
    --     MainUIManager.Instance.mainuitracepanel.traceDun:Update(self.currdungeonunit)
    -- else
    if MainUIManager.Instance.mainuitracepanel ~= nil then
        MainUIManager.Instance.mainuitracepanel:ChangeShowType(TraceEumn.ShowType.Dungeon)

        LuaTimer.Add(50, function() 
            if MainUIManager.Instance.mainuitracepanel.traceDun ~= nil then 
                MainUIManager.Instance.mainuitracepanel.traceDun:SetId(self.currdungeonID) 
            end
        end)
        self.retrytimes = 0
    elseif self.retrytimes < 20 then
        LuaTimer.Add(100, function() self.retrytimes = self.retrytimes + 1 self:On12103(data) end)
    end
    self.InfoChangeEvent:Fire()
    -- end
end

function DungeonManager:On12104(data)
    -- BaseUtils.dump(data, "塔信息")
    self.currdungeonID = data.id
    self.currdungeonunit = data.unit_id
end

-- 塔结算信息
function DungeonManager:On12110(data)
    self.towerend_data = data
end

-- 翻牌
function DungeonManager:Require12111(pos)
    Connection.Instance:send(12111, {pos = pos})
end

function DungeonManager:On12111(data)
    self.openCard_Data = data
end

-- 请求副本奖励状态,日程界面使用
function DungeonManager:Require12112(ID)
    Connection.Instance:send(12112, {id = ID})
end

function DungeonManager:On12112(data)
    -- BaseUtils.dump(data, "副本奖励状态")
    AgendaManager.Instance:SetDungeonStatus(data)
end



-- 普通副本结算奖励数据
function DungeonManager:On12118(data)
    -- BaseUtils.dump(data, "普通结算数据")
    self.endData = data
    -- LuaTimer.Add(3000, function() self.model:OpenEnd() end)
    self.model:OpenEnd()

end


function DungeonManager:Require12119(ID, floor)
    Connection.Instance:send(12119, {id = ID, floor = floor})
end

function DungeonManager:On12119(data)
    -- body
end

function DungeonManager:On12300(data)
    BaseUtils.dump(data, "roll数据")
    self.rollData = data
    if data.mode ~= 3 then
        self.model:OpenRoll()
    else
        --幻境宝箱
        FairyLandManager.Instance.model.roll_key = data.key
        FairyLandManager.Instance.model.roll_id = data.roll_item[1].base_id
        FairyLandManager.Instance.model.roll_type = nil
        FairyLandManager.Instance.model:InitBoxUI()
    end
end

function DungeonManager:On12301(data)
    -- BaseUtils.dump(data, "roll点结果")
    if self.model.rollwin ~= nil then
        self.model.rollwin:PraseUpdateData(data)
    end
end

function DungeonManager:On12302(data)
    -- BaseUtils.dump(data, "roll点结果")
end

function DungeonManager:Require12302(rollid, itemid)
    -- print(rollid)
    -- print(itemid)
    Connection.Instance:send(12302, {roll_id = rollid, item_id = itemid})
end

-- 请求塔击杀数据
function DungeonManager:Require14300()
    Connection.Instance:send(14300, {})
end

function DungeonManager:On14300(data)
    -- BaseUtils.dump(data, "<color=#FF0000>On14300点结果</color>")

    self.currdungeonID = 20001
    self.tower_status_data = data.pass_boss
    local currUinitList = {}
    for k,v in pairs(data.pass_boss) do
        if v.floor == self:GetCurrTowerfloor() then
            currUinitList = v.unit_list
        end
    end
    self.currdungeonunit = currUinitList
    self:CheckTowerReward()
    self:OnTowerUpdate()
    EventMgr.Instance:Fire(event_name.tower_reward_update)
    if self:GetCurrTowerfloor() == 0 then
        return
    end
    MainUIManager.Instance.mainuitracepanel:ChangeShowType(TraceEumn.ShowType.Dungeon)
    LuaTimer.Add(250, function()
        if MainUIManager.Instance.mainuitracepanel.traceDun ~= nil and MainUIManager.Instance.mainuitracepanel.traceDun.gameObject ~= nil then
            MainUIManager.Instance.mainuitracepanel.traceDun:SetId(self.currdungeonID)
        end
    end)
end
--进入塔
function DungeonManager:Require14301(floor)
    self.currEnter_floor = floor
    Connection.Instance:send(14301, {floor = floor})
end

function DungeonManager:On14301(data)
    -- BaseUtils.dump(data, "On14301点结果")
    if data.flag == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
        local unitData = {baseid = towernpc[DungeonManager.Instance:GetCurrTowerfloor()]}
        local base = BaseUtils.copytab(DataUnit.data_unit[towernpc[DungeonManager.Instance:GetCurrTowerfloor()]])
        if base == nil then
            return
        end
        base.buttons = {}
        base.plot_talk = data.msg
        local extra = {base = base}
        MainUIManager.Instance:OpenDialog(unitData, extra)
    elseif self.currEnter_floor == 1 then
        if not TeamManager.Instance:HasTeam() then
            local leader = function()
                TeamManager.Instance.TypeOptions = {}
                TeamManager.Instance.TypeOptions[7] = 71
                TeamManager.Instance.LevelOption = 1
                TeamManager.Instance:Send11701()
                LuaTimer.Add(200, function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1}) end)
            end
            local member = function()
                TeamManager.Instance.TypeOptions = {}
                TeamManager.Instance.TypeOptions[7] = 71
                TeamManager.Instance.LevelOption = 1
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
            end
            local info = {
                Desc = TI18N("天空之塔中BOSS比较凶猛，记得<color='#ffff00'>3人以上组队</color>再挑战！"),
                Ltxt = TI18N("我要当队长"),
                Mtxt = "",
                Rtxt = TI18N("我要当队员"),
                LGreen = true,
                MGreen = false,
                RGreen = false,
                LCallback = leader,
                MCallback = nil,
                RCallback = member,
            }
            LuaTimer.Add(800, function()
                TipsManager.Instance:ShowTeamUp(info)
            end)
        elseif TeamManager.Instance.teamNumber < 5 then
            local member = function()
                TeamManager.Instance.TypeOptions = {}
                TeamManager.Instance.TypeOptions[7] = 71
                TeamManager.Instance.LevelOption = 1
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
            end
            local info = {
                Desc = TI18N("天空之塔中BOSS比较凶猛，记得<color='#ffff00'>3人以上组队</color>再挑战！"),
                Ltxt = "",
                Mtxt = TI18N("招募队员"),
                Rtxt = "",
                LGreen = false,
                MGreen = true,
                RGreen = false,
                LCallback = nil,
                MCallback = member,
                RCallback = nil,
            }
            LuaTimer.Add(800, function()
                TipsManager.Instance:ShowTeamUp(info)
            end)
        end
    end
end
--领取通关奖励
function DungeonManager:Require14302(floor)
    Connection.Instance:send(14302, {floor = floor})
end

function DungeonManager:On14302(data)
    -- BaseUtils.dump(data, "On14302点结果")
    if data.flag == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("成功领取通关奖励"))
        self:Require14300()
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

-- 塔翻牌通知
function DungeonManager:On14303(data)
    -- BaseUtils.dump(data, "塔翻牌通知点结果")
    if data.order == 0 then
        DungeonManager.Instance.model:OpenTowerEnd({data.type})

    else
        DungeonManager.Instance.model:OpenBox(data)
        if data.gain_list[1].item_id1 ~= nil then
            local baseData = DataItem.data_get[data.gain_list[1].item_id1]
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("恭喜获得%s"), ColorHelper.color_item_name(baseData.quality, baseData.name)))
        end
    end
end

-- 塔翻牌请求
function DungeonManager:Require14304(order)
    Connection.Instance:send(14304, {order = order})
end

function DungeonManager:On14304(data)
    BaseUtils.dump(data, "塔翻牌请求点结果")
end

function DungeonManager:Require14305()
    Connection.Instance:send(14305, {})
end

function DungeonManager:On14305(data)
    self.model:SetTowerHelpNum(data.num)
end

-- 通用开箱子
function DungeonManager:Require12320(data)
	Connection.Instance:send(12320, {})
end

function DungeonManager:On12320(data)
	-- BaseUtils.dump(data, "<color=#88FF00>接收12320</color>")
	self.treasureBoxData = self.treasureBoxData or {}
	self.treasureBoxData[data.id] = BaseUtils.copytab(data)

	-- self.onTreasureBoxUpdate:Fire(data.id)
	self:OpenUniversalEnd({data.id, data.base_id})
end


function DungeonManager:Require12321(card_id, pos)
	Connection.Instance:send(12321, {card_id = card_id, pos = pos})
end

function DungeonManager:On12321(data)
	-- BaseUtils.dump(data, "<color=#FF8800>接收12321</color>")

	self.treasureBoxData = self.treasureBoxData or {}
	self.treasureBoxData[data.card_id] = self.treasureBoxData[data.card_id] or {}
	self.treasureBoxData[data.card_id].list = self.treasureBoxData[data.card_id].list or {}
	self.treasureBoxData[data.card_id].list[data.pos] = self.treasureBoxData[data.card_id].list[data.pos] or {}
	for k,v in pairs(data) do
		self.treasureBoxData[data.card_id].list[data.pos][k] = v
	end
	self.onTreasureBoxUpdate:Fire(data.card_id, data)
end
------------------------------------------------------------------------------------------------------------
--=================================功能调用===========================================================
-------------------------------------------------------------------------------------------------------------

function DungeonManager:InitTowerData()
    self.tower_data = {}
    for k,v in ipairs(DataDungeonTower.data_get) do
        if self.tower_data[v.floor] == nil then
            self.tower_data[v.floor] = {}
            self.tower_data[v.floor].unit_list = {}
            local basedata = DataUnit.data_unit[v.base_id]
            local temp = {unit_id = 1,unit_name = basedata.name ,unit_base_id = {v.base_id},unit_num = 1}
            table.insert( self.tower_data[v.floor].unit_list, temp )
            self.tower_data[v.floor].mapid = TowerMap[v.floor]
        else
            local basedata = DataUnit.data_unit[v.base_id]
            local temp = {unit_id = 1,unit_name = basedata.name ,unit_base_id = {v.base_id},unit_num = 1}
            table.insert( self.tower_data[v.floor].unit_list, temp )
        end
    end
    -- for k,v in pairs(self.tower_data) do
    --     table.sort( v.unit_list, function(a,b) return a.unit_base_id[1]<b.unit_base_id[1] end )
    -- end
end

function DungeonManager:ShowMsg(msg)
    NoticeManager.Instance:FloatTipsByString(TI18N(msg))
end

function DungeonManager:EnterDungeon(ID)
    self:Require12100(ID)
end

function DungeonManager:ExitDungeon()
    if self.activeType == 5 then
        if MainUIManager.Instance.mainuitracepanel.traceDun.allClear == true then
            self:Require12101()
        else
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            local dungeonMapData = DataDungeon.data_dungeon_map[tostring(self.currdungeonID).."_"..tostring(SceneManager.Instance:CurrentMapId())]
            if dungeonMapData ~= nil and dungeonMapData.floor > 0 then
                confirmData.content = TI18N("退出后再次进入如果<color='#ffff00'>全队都通关</color>了某一层，可直接<color='#ffff00'>从下一层</color>开始，确定退出吗？")
            else
                confirmData.content = TI18N("退出后重新挑战将从第一层开始，确定退出？")
            end
            confirmData.sureLabel = TI18N("取 消")
            confirmData.cancelLabel = TI18N("确 定")
            confirmData.blueSure = true
            confirmData.greenCancel = true
            confirmData.cancelCallback = function() self:Require12101() end
            LuaTimer.Add(500, function() NoticeManager.Instance:ConfirmTips(confirmData) end)
        end
    else
        local data = DataDungeon.data_get[self.currdungeonID]
        if data ~= nil and data.team_dungeon == 1 and TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            if #self.currdungeonunit == #data.unit_list then
                self:Require12101()
            else
                local confirmData = NoticeConfirmData.New()
                confirmData.type = ConfirmData.Style.Normal
                confirmData.content = TI18N("当前副本尚未通关，只能单人离开副本，是否离开队伍退出副本？")
                confirmData.sureLabel = TI18N("取 消")
                confirmData.cancelLabel = TI18N("退出副本")
                confirmData.cancelCallback = function()
                        TeamManager.Instance:Send11708()
                        self:Require12101()
                    end
                LuaTimer.Add(500, function() NoticeManager.Instance:ConfirmTips(confirmData) end)
            end
        else
            self:Require12101()
        end
    end
end

function DungeonManager:CheckOutStatus()
    if Time.time - self.lastReqTime < 0.5 then
        return
    end
    self.lastReqTime = Time.time
    self.traceing = false
    local get = false
    local mapid = SceneManager.Instance:CurrentMapId()
    local cfg_data = DataSystem.data_daily_icon[108]
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Dungeon --[[or self.dungeon_status == true]] then
        if MainUIManager.Instance.mainuitracepanel ~= nil then
            MainUIManager.Instance.mainuitracepanel:ChangeShowType(TraceEumn.ShowType.Dungeon)
        end
        self:Require12102()
        self.traceing = true
        get = true
        self.autoExitTeam = false
    elseif SceneManager.Instance:CurrentMapId() == 42000 then
        if MainUIManager.Instance.mainuitracepanel ~= nil then
            MainUIManager.Instance.mainuitracepanel:ChangeShowType(TraceEumn.ShowType.Dungeon)
        end
    end
    MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    -- self:Require14300()
    self.tower_floor = 0
    for i,v in ipairs(TowerMap) do
        if mapid == v then
            -- print("在塔内")
            self:Require14300()
            self.traceing = true
            get = true
            self.tower_floor = i
            local click_callback = function()
                if not BaseUtils.is_null(self.redpoint) then
                    self.redpoint.gameObject:SetActive(false)
                end
                DungeonManager.Instance.model:OpenTowerReward()
            end
            local iconData = AtiveIconData.New()
            iconData.id = cfg_data.id
            iconData.iconPath = cfg_data.res_name
            iconData.clickCallBack = click_callback
            iconData.sort = cfg_data.sort
            iconData.lev = cfg_data.lev
            self.icon = MainUIManager.Instance:AddAtiveIcon(iconData)
            if self.icon ~= nil then
                self.redpoint = self.icon.transform:Find("RedPointImage")
            end
            if self.isFirstClick == false then
                if not BaseUtils.is_null(self.redpoint) then
                    self.redpoint.gameObject:SetActive(true)
                end
                self.isFirstClick = true
            else
                self.rechargeIconEffect = nil
            end
        end
    end
    if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.traceDun ~= nil and MainUIManager.Instance.mainuitracepanel.traceDun.currId == 20001 then
        -- MainUIManager.Instance.mainuitracepanel:AutoShowType()
    end
    if self.traceing == false then
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    end
end

function DungeonManager:EnterTower(floor)
    self:Require14301(floor)
end

function DungeonManager:BeginEffect()
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
        -- Log.Error("[进入副本][Error]assetWrapper不可以重复使用")
    end
    self.assetWrapper = AssetBatchWrapper.New()
    local callback = function()
        self.enter_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.BeginEffectres))
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            self.tpose = SceneManager.Instance.sceneElementsModel.self_view.tpose
            -- self.enter_effect.gameObject:SetActive(false)
            self.enter_effect.transform:SetParent(self.tpose.transform)
            self.enter_effect.transform.localPosition = Vector3.zero
            self.enter_effect.transform.localRotation = Quaternion.identity
            -- self.enter_effect.gameObject:SetActive(true)
        end
        LuaTimer.Add(900, function () if not BaseUtils.is_null(self.enter_effect) then
            GameObject.Destroy(self.enter_effect)
        end end)
    end
    self.assetWrapper:LoadAssetBundle(self.resList, callback)
end

function DungeonManager:EndEffect()
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
        -- Log.Error("[进入副本][Error]assetWrapper不可以重复使用")
    end
    self.assetWrapper = AssetBatchWrapper.New()
    local callback = function()
        if not BaseUtils.isnull(self.assetWrapper) then
            self.end_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.EndEffectres))
            self.end_effect.transform:SetParent(self.tpose.transform)
            self.end_effect.transform.localPosition = Vector3.zero
            self.end_effect.transform.localRotation = Quaternion.identity
            self.assetWrapper:DeleteMe()
            LuaTimer.Add(900, function ()
                if not BaseUtils.is_null(self.end_effect) then
                    GameObject.Destroy(self.end_effect)
                end
            end)
        end
    end
    self.assetWrapper:LoadAssetBundle(self.resList, callback)
end

function DungeonManager:GetCurrTowerfloor()
    local mapid = SceneManager.Instance:CurrentMapId()
    local floor = 0
    for k,v in pairs(TowerMap) do
        if v == mapid then
            floor = k
        end
    end
    return floor
end


function DungeonManager:OnTowerUpdate()
    local mapid = SceneManager.Instance:CurrentMapId()
    for i,v in ipairs(TowerMap) do
        if mapid == v then
            for kk,vv in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
                if DataDungeonTower.data_get[vv.data.baseid] ~= nil then
                    SceneManager.Instance.sceneElementsModel.NpcView_List[kk].data.honorType = 1
                    if self.tower_status_data[i] ~= nil then
                        for iii,vvv in ipairs(self.tower_status_data[i].unit_list) do
                            if vvv.unit_id == vv.data.baseid then
                                SceneManager.Instance.sceneElementsModel.NpcView_List[kk].data.honorType = 0
                            end
                        end
                    end
                    vv:change_honor()
                end
            end
            for kk,vv in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
                if DataDungeonTower.data_get[vv.baseid] ~= nil then
                    SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List[kk].honorType = 1
                    if self.tower_status_data[i] ~= nil then
                        for iii,vvv in ipairs(self.tower_status_data[i].unit_list) do
                            -- print(vvv.unit_id)
                            if vvv.unit_id == vv.baseid then
                                SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List[kk].honorType = 0
                            end
                        end
                    end
                end
            end
        end
    end
end

function DungeonManager:CheckTowerReward()
    local killed = 0
    local is_pass_gain = 0
    local hasreward = false
    local data = self.tower_status_data
    if data == nil then
        return false
    else
        for k,v in pairs(data) do
            local canget = false
            killed = #v.unit_list
            is_pass_gain = v.is_pass_gain
            if killed == 4 and is_pass_gain == 0 then
                hasreward = true
                canget = true
            end
            self.towerRewardList[v.floor] = canget
        end
    end
    if hasreward then
        if not BaseUtils.isnull(self.icon) then
            self.redpoint = self.icon.transform:Find("RedPointImage")
            if not BaseUtils.is_null(self.redpoint) then
                self.redpoint.gameObject:SetActive(true)
            end
        end
    end
    self.model:UpdateTowerReward()
    return hasreward
end

function DungeonManager:ReqOnConnect()
    self.hasNoticeByFloor = {}
    self:Require14300()
    self:send12123()
end

function DungeonManager:IsDunMap()
    local mapid = SceneManager.Instance:CurrentMapId()
    for i,v in ipairs(DataDungeon.data_dungeon_map) do
        if mapid == v.map_id then
            return true
        end
    end
    return false
end


function DungeonManager:OpenUniversalEnd(args)
	self.model:OpenUniversalEnd(args)
end

function DungeonManager:CloseUniversalEnd()
	self.model:CloseUniversalEnd()
end

function DungeonManager:Require12120(list)
    list = list or {}
    local data = {list = list}
    BaseUtils.dump(data, "发送12120")
    Connection.Instance:send(12120, data)
end

function DungeonManager:On12120(data)
    BaseUtils.dump(data, "On12120")
    self.killlist = self.killlist or {}
    for _,v in pairs(data.list) do
        self.killlist[v.base_id] = v.num
    end
    self.onKillTimes:Fire(self.killlist)
end

function DungeonManager:Require12121(tower_id, floor)
  -- print("发送12121")
    self.moment12121 = BaseUtils.BASE_TIME
    self.dungeonData85 = data
    Connection.Instance:send(12121, {id = tower_id, floor = floor})
end

function DungeonManager:On12121(data)
    BaseUtils.dump(data, "接收12121")
    if self.moment12121 ~= nil and BaseUtils.BASE_TIME - self.moment12121 <= 10 and self.effigyNpcData ~= nil then
        self.moment12121 = nil
        local extra = {}
        local npcData = DataUnit.data_unit[self.effigyNpcData.baseid]
        local btn1 = BaseUtils.copytab(npcData.buttons[1])
        extra.base = BaseUtils.copytab(self.effigyNpcData)
        btn1.button_args = {4}
        extra.base.buttons = {btn1}
        -- local btn1 = {button_id = 53, button_args = {4}, button_desc = "通关攻略", button_show = ""}
        -- extra.base.buttons = {btn1}
        if #data.list > 0 then
            self.dungeonData85 = data
            local str1 = TI18N("以下玩家获得最优通关：\n")
            local str = ""
            local format1 = TI18N("%s小时%s分%s秒")
            local format2 = TI18N("%s分%s秒")
            local h = 0
            local m = 0
            local s = 0
            local t = 0
            local floor = math.floor
            for i=1,5 do
                if data.list[i] == nil then
                    break
                end
                str = str .. "<color='#00ff00'>" .. data.list[i].name .. "</color>"
                if i ~= #data.list then
                    str = str .. "、"
                end
            end

            -- if NoticeManager.Instance.model.calculator.magicText.preferredWidth > 451 then
                str = str .. "\n"
            -- else
            --     str = str .. "\n\n"
            -- end

            t = data.list[1].val1
            s = t % 60
            t = floor(t / 60)
            m = t % 60
            t = floor(t / 60)
            h = t

            local timeStr = nil

            if h > 0 then
                timeStr = string.format(format1, tostring(h), tostring(m), tostring(s))
            else
                timeStr = string.format(format2, tostring(m), tostring(s))
            end

            str = str1 .. str .. string.format(TI18N("其中<color='#00ff00'>%s</color>以<color='#00ff00'>%s</color>的最短时间通关，成为本层霸主！\n<color='#ffff00'>每周一、三、五、日24点，霸主可获得珍贵道具奖励</color>"), data.list[1].name, timeStr)
            extra.base.plot_talk = str
            self.rankText[data.floor] = str
            MainUIManager.Instance.dialogModel.dramaTalk:ChangeText(str)
        end
        -- BaseUtils.dump(self.effigyNpcData, "self.effigyNpcData")
        -- MainUIManager.Instance:OpenDialog(self.effigyNpcData, extra, true)
    end
end

function DungeonManager:Require10172(battle_id, id, base_id)
    -- print("发送12122")
    Connection.Instance:send(10172, {base_id = base_id, id = id, battle_id = battle_id})
end

function DungeonManager:On10172(data)
    BaseUtils.dump(data, "接收10172")

    local objectName = data.id .."_" .. data.battle_id
    local touchNpcView = SceneManager.Instance.sceneElementsModel.NpcView_List[objectName]
    -- BaseUtils.dump(touchNpcView)
    if touchNpcView then
        touchNpcView = BaseUtils.copytab(touchNpcView)
        touchNpcData = touchNpcView.data
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[data.base_id])
        if extra.base.buttons[1] ~= nil and extra.base.buttons[1].button_id == 53 then
            local mapid = SceneManager.Instance:CurrentMapId()
            local floor = DataDungeon.data_dungeon_map[self.currdungeonID.."_"..mapid].floor
            if self.hasNoticeByFloor[floor] == nil then
                extra.base.plot_talk = extra.base.buttons[1].button_show
                -- BaseUtils.dump(extra.base.buttons[1])
                extra.base.buttons = {}
                extra.base.classes = touchNpcData.classes
                extra.base.sex = touchNpcData.sex
                extra.base.looks = BaseUtils.copytab(touchNpcData.looks)
                MainUIManager.Instance:OpenDialog(touchNpcData, extra, true)
            end
        end
    end
end

function DungeonManager:Require12122(id)
  -- print("发送12122")
    Connection.Instance:send(12122, {id = id})
end

function DungeonManager:On12122(data)
    BaseUtils.dump(data, "接收12122")
    if self.request12122_id == data.id then
        if data.floor == 0 or data.floor == self.tower_85_max_floor then
            self:Require12100(data.id, 1)
        else
            local info = {
                Desc = string.format(TI18N("队伍全员已挑战过今日的第<color='#ffff00'>%s</color>层，是否直达第<color='#ffff00'>%s</color>层继续挑战？"), tostring(data.floor), tostring(data.floor + 1)),
                Ltxt = TI18N("重头开始"),
                -- Mtxt = "MMMMMMMMMMMMMMMMMMMMMMMMM",
                Rtxt = string.format(TI18N("继续第%s层"), tostring(data.floor + 1)),
                LCallback = function() self:Require12100(data.id, 1) end,
                RCallback = function() self:Require12100(data.id, 2) end,
                RGreen = true
            }
            TipsManager.Instance.model:ShowTeamUp(info)
        end
    end
end

function DungeonManager:OpenVideoWindow(args)
    self.model:OpenVideoWindow(args)
end

function DungeonManager:send12123()
  -- print("发送12123")
    Connection.Instance:send(12123, {})
end

function DungeonManager:on12123(data)
    BaseUtils.dump(data, "<color='#00ff00'>接收12123</color>")
    self.extraInfoDic = {}
    for i,v in ipairs(data.list) do
        self.extraInfoDic[v.key] = self.extraInfoDic[v.key] or {}
        table.insert(self.extraInfoDic[v.key], v)
    end
    self.onUpdateExtra:Fire()
end

function DungeonManager:OpenHelp(args)
    self.model:OpenHelp(args)
end

function DungeonManager:ShowHelpIcon()
    local mapid = SceneManager.Instance:CurrentMapId()
    if mapid == 42000 then
        return true
    else
        local id = self.currdungeonID
        local dungeonMapData = DataDungeon.data_dungeon_map[tostring(id).."_"..tostring(mapid)]
        local dungeonData = DataDungeon.data_get[id]
        if dungeonData ~= nil and dungeonMapData ~= nil and dungeonData.type == 5 then
            return true
        end
    end
    return false
end

function DungeonManager:SetHelpIcon()
    MainUIManager.Instance:DelAtiveIcon(310)

    if not self:ShowHelpIcon() then
        if self.activeIconData ~= nil then
            self.activeIconData:DeleteMe()
            self.activeIconData = nil
        end
        return
    end

    if self.activeIconData == nil then self.activeIconData = AtiveIconData.New() end
    local iconData = DataSystem.data_daily_icon[310]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.dungeonhelpwindow) end

    MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
end

function DungeonManager:OpenClearBuff(args)
    self.model:OpenClearBuff(args)
end



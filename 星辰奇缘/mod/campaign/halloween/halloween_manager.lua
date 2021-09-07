-- ----------------------------------------------------------
-- 逻辑模块 - 万圣节活动
-- ljh 20161019
-- ----------------------------------------------------------
HalloweenManager = HalloweenManager or BaseClass(BaseManager)

function HalloweenManager:__init()
    if HalloweenManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	HalloweenManager.Instance = self

    self.model = HalloweenModel.New()

    self.pumpkingoblinTimes = 2

    self:InitHandler()

    self.mapListener = function() self.model:UpdateMap() end

    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event) self.model:UpdateEvent(event, old_event) end)
    EventMgr.Instance:AddListener(event_name.scene_load, function() self.model:UpdateMap() end)
    EventMgr.Instance:AddListener(event_name.halloween_self_dead_tips, function() self.model:SelfDead() end)
end

function HalloweenManager:__delete()
end

function HalloweenManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(17800, self.On17800)
    self:AddNetHandler(17801, self.On17801)
    self:AddNetHandler(17802, self.On17802)
    self:AddNetHandler(17803, self.On17803)
    self:AddNetHandler(17804, self.On17804)
    self:AddNetHandler(17805, self.On17805)
    self:AddNetHandler(17806, self.On17806)
    self:AddNetHandler(17807, self.On17807)
    self:AddNetHandler(17808, self.On17808)
    self:AddNetHandler(17809, self.On17809)
    self:AddNetHandler(17810, self.On17810)
    self:AddNetHandler(17811, self.On17811)
    self:AddNetHandler(17833, self.on17833)
    self:AddNetHandler(17834, self.on17834)
    self:AddNetHandler(17835, self.on17835)
    self:AddNetHandler(17836, self.on17836)
    --驱除邪灵
    self:AddNetHandler(14042, self.On14042)
    self:AddNetHandler(14043, self.On14043)
    self:AddNetHandler(14044, self.On14044)
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------

function HalloweenManager:Send17800()
    Connection.Instance:send(17800, { })
    -- print("Send17800")
    -- print(debug.traceback())
end

function HalloweenManager:On17800(data)
    self.model:On17800(data)
end

function HalloweenManager:Send17801()
    Connection.Instance:send(17801, { })
    -- print(1)
end

function HalloweenManager:On17801(data)
    -- print(2)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HalloweenManager:Send17802()
    Connection.Instance:send(17802, { })
end

function HalloweenManager:On17802(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        self.model.match_time = 0
    end
end

function HalloweenManager:Send17803()
    Connection.Instance:send(17803, { })
end

function HalloweenManager:On17803(data)
    if #data.list > 0 then
        self.model.fire_times = data.list[1].times
        self.model.cooldowm = data.list[1].times_cd
    end
end

function HalloweenManager:Send17804()
    Connection.Instance:send(17804, { })
end

function HalloweenManager:On17804(data)
    self.model.rank_list = data.list
    self.model.red_score = data.green_score
    self.model.blue_score = data.blue_score
    self.model.end_time = data.end_time


    local roleData = RoleManager.Instance.RoleData
    for _,v in ipairs(data.list) do
        if roleData.id == v.rid and roleData.platform == v.platform and roleData.zone_id == v.r_zone_id then
            self.model.myCamp = data.camp
        end
    end

    EventMgr.Instance:Fire(event_name.halloween_rank_update)
end

function HalloweenManager:Send17805()
    Connection.Instance:send(17805, { })
end

function HalloweenManager:On17805(data)
    self.model.blue_list = data.win
    self.model.red_list = data.fail
    self.model.red_score = data.green_score
    self.model.blue_score = data.blue_score
    self.model.win_camp = data.is_win
    self.model.reward = data.show

    self.model:InitRankWindow()

    self.model.fire_times = 0
end

function HalloweenManager:Send17806(type, rid, platform, r_zone_id)
    Connection.Instance:send(17806, { type = type, rid = rid, platform = platform, r_zone_id = r_zone_id })
end

function HalloweenManager:On17806(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.op_code == 1 then
        self.model:ShowSuccessEffect()
    end
end

function HalloweenManager:Send17807()
    Connection.Instance:send(17807, { })
end

function HalloweenManager:On17807(data)
    self.model.less_times = data.times

    -- if self.model.less_times <= HalloweenManager.Instance.pumpkingoblinTimes then
    --     if self.model.selfIcon ~= nil then
    --         MainUIManager.Instance:DelAtiveIcon(121)
    --         self.model.selfIcon = nil
    --     end
    -- end
end

function HalloweenManager:Send17808()
    Connection.Instance:send(17808, { })
end

function HalloweenManager:On17808(data)
    self.model:On17808(data)
end

function HalloweenManager:Send17809()
    Connection.Instance:send(17809, { })
end

function HalloweenManager:On17809(data)
    self.model:On17809(data)
end

function HalloweenManager:Send17810()
    Connection.Instance:send(17810, { })
end

function HalloweenManager:On17810(data)
    self.model:On17810(data)
end

function HalloweenManager:Send17811()
    Connection.Instance:send(17811, { })
end

function HalloweenManager:On17811(data)
    self.model.killerName = data.name
end

--驱除邪灵翻牌通知
function HalloweenManager:On14042(data)
    -- print("------------收到14042")
    -- BaseUtils.dump(data)
    if data.order == 0 then
        self.model:InitKillEvilCardUI({data.type})
    else
        self.model:OpenKillEvilBox(data)
        if data.gain_list[1].item_id1 ~= nil then
            local baseData = DataItem.data_get[data.gain_list[1].item_id1]
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("恭喜获得%s"), ColorHelper.color_item_name(baseData.quality, baseData.name)))
        end
    end
end

--驱除邪灵翻牌请求
function HalloweenManager:Send14043(order)
    Connection.Instance:send(14043, {order = order})
end

--翻牌
function HalloweenManager:On14043(data)
    BaseUtils.dump(data, "塔翻牌请求点结果")
end

--请求单位刷新所在地图
function HalloweenManager:Send14044()
    Connection.Instance:send(14044, {})
end

--请求单位刷新所在地图
function HalloweenManager:On14044(data)
    -- print("------------------收到14044")
    -- BaseUtils.dump(data)
    self.model.killEvilMapData = data
    local touchNpcData = SceneManager.Instance.sceneElementsModel.touchNpcView.data
    local extra = {}
    extra.base = BaseUtils.copytab(DataUnit.data_unit[touchNpcData.baseid])
    extra.base.buttons = {}
    local buttons = {}

    local mapStr = ""
    if HalloweenManager.Instance.model.killEvilMapData ~= nil then
        for k, v in pairs(HalloweenManager.Instance.model.killEvilMapData.maps) do
            if mapStr == "" then
                mapStr = DataMap.data_list[v.map_id].name
            else
                mapStr = string.format("%s、%s",mapStr , DataMap.data_list[v.map_id].name)
            end
        end
    end
    extra.base.plot_talk = string.format(TI18N("1.每天<color='#00ff00'>09:00--23:00</color>为活动开启时间\n2.活动开始后每<color='#00ff00'>半小时</color>将随机刷新出邪灵部下\n（邪灵部下已出现在%s，准备就绪后速度前往吧！）"), mapStr)
    buttons.button_id = DialogEumn.ActionType.action999
    buttons.button_args = {}
    buttons.button_desc = TI18N("返回")
    table.insert(extra.base.buttons, buttons)
    MainUIManager.Instance:OpenDialog(touchNpcData, extra)
end

-------------------------------------------
-------------------------------------------
------------- 逻辑处理 -----------------
-------------------------------------------
-------------------------------------------

function HalloweenManager:RequestInitData()
    -- print("<color='#ff0000'>-------------------------初始化万圣节活动---------------------------</color>")
    CampaignManager.Instance.labourModel:Clear()

    self:Send17804()
    self:Send17807()
    self:Send17808()
    self:Send17800()
    self:send17833()
    AgendaManager.Instance:Require12004()
end

function HalloweenManager:Clear()
    self.model:Clear()
end

--图标
function HalloweenManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(329)
    if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
        return
    end
    local systemIcon = DataCampaign.data_camp_ico[CampaignEumn.Type.Halloween]
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.Halloween] == nil then
        return
    end
    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[329]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
        local count = 0
        for k,v in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.Halloween]) do
            if k ~= "count" then
                count = count + 1
            end
        end
        if count == 1 and CampaignManager.Instance.campaignTree[CampaignEumn.Type.Halloween][CampaignEumn.HalloweenType.Exchange] ~= nil then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.halloween_exchange)
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.halloweenwindow, { 1, 1 })
        end
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
end

function HalloweenManager:OpenExchange()
    self.model:OpenExchange()
end


function HalloweenManager:OpenDamaku()
    self.model:OpenDamaku()
end

-- 南瓜识别技能冷却
function HalloweenManager:send17833()
    Connection.Instance:send(17833, {})
end

function HalloweenManager:on17833(data)
    -- BaseUtils.dump(data, "<color='#00ff88'>on17833</color>")
    for _,v in pairs(data.skill) do
        self.model.skillStatusList[v.id] = v
    end
end

-- 南瓜识别使用技能1
function HalloweenManager:send17834()
    Connection.Instance:send(17834, {})
end

function HalloweenManager:on17834(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 南瓜识别使用技能2
function HalloweenManager:send17835()
    Connection.Instance:send(17835, {})
end

function HalloweenManager:on17835(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 南瓜识别弹幕
function HalloweenManager:send17836(type)
    self.model.danmakuMoment = BaseUtils.BASE_TIME
    Connection.Instance:send(17836, {type = type})
end

function HalloweenManager:on17836(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


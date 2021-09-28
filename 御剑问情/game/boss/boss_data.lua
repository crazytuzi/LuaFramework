BossData = BossData or BaseClass(BaseEvent)

BOSS_ENTER_TYPE = {
    TYPE_BOSS_WORLD = 0,
    TYPE_BOSS_FAMILY = 1,
    TYPE_BOSS_MIKU = 2,
    TYPE_BOSS_DABAO = 3,
    LEAVE_BOSS_SCENE = 4,
    TYPE_BOSS_ACTIVE = 5,
    TYPE_BOSS_PRECIOUS = 6,
    XIAN_JIE_BOSS = 7,
    GUA_JI_BOSS = 8,
    KUA_FU_BOSS = 9,
    TYPE_BOSS_BABY = 10,
    TYPE_BOSS_ENCOUNTER = 11,

    --方便调用，跨服的BOSS提醒写这里
    CROSS_SHENWU_BOSS = 12,
    CROSS_TIANJIANG_BOSS = 13,
    TIANSHENHUTI_BOSS = 14,
}

BOSS_FAMILY_OPERATE_TYPE =
{
    BOSS_FAMILY_BUY_MIKU_WEARY = 0,  -- 购买秘窟BOSS疲劳值
    BOSS_FAMILY_BUY_GATHER_TIMES = 1, -- 购买采集次数
}


BossData.Boss_State = {
    not_start = 0,
    ready = 1,
    death = 2,
    time_over = 3,
}

BossData.BossType = {
    WORLD_BOSS = 0,
    BOSS_HOME = 1,
    ELITE_BOSS = 2,
    DABAO_MAP = 3,
}

BossData.BossType = {
    WORLD_BOSS = 0,
    BOSS_HOME = 1,
    ELITE_BOSS = 2,
    DABAO_MAP = 3,
}

BossData.FOLLOW_BOSS_OPE_TYPE = {
    FOLLOW_BOSS = 0,                  --关注boss
    UNFOLLOW_BOSS = 1,                --取消关注
    GET_FOLLOW_LIST = 2,              --获取关注列表
}

--怪物平台位置
BossData.PingTai = {
    Vector3(-264.74, 485.13, 676.71),   --平台1
    Vector3(-267.12, 485.13, 678.94),   --平台2
    Vector3(-269.57, 485.13, 676.71),   --平台3
    Vector3(-267.11, 485.13, 672.96),   --平台4
}

BOSS_TYPE =
{
    FAMILY_BOSS = 0,
    MIKU_BOSS = 1,
}

BOSS_TYPE_INFO =
{
    RARE = 3,               --显示3星装备的BOSS
}

local DISPLAYNAME = {
    [3013001] = "boss_panel_1",
    [3002001] = "boss_panel_5",
    [3006001] = "boss_panel_4",
    [3025001] = "boss_panel_2",
    [3026001] = "boss_panel_3",
    [3001001] = "boss_panel_6"
}


BossData.DABAO_BOSS = "dabao_boss"
BossData.FAMILY_BOSS = "family_boss"
BossData.MIKU_BOSS = "miku_boss"
BossData.ACTIVE_BOSS = "active_boss"

BossData.FOCUS_WELFARE_LIMIT_LEVEL = 130
--福利boss刷新后 主界面福利boss图标显示1800秒
BossData.MAIN_SHOW_WELFARE_TIME_DIFF = 1800


function BossData:__init()
    if BossData.Instance then
        print_error("[BossData] Attempt to create singleton twice!")
        return
    end

    BossData.Instance = self
    self.boss_family_cfg = ConfigManager.Instance:GetAutoConfig("bossfamily_auto")

    self.other_cfg = self.boss_family_cfg.other[1]
    self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
    self.worldboss_auto = ConfigManager.Instance:GetAutoConfig("worldboss_auto")
    self.baby_boss_cfg = ConfigManager.Instance:GetAutoConfig("baby_boss_config_auto")
    self.precious_boss_other_cfg = self.boss_family_cfg.precious_boss_other[1]
    self.dabao_boss_cfg =  self.boss_family_cfg.dabao_boss
    self.active_boss_cfg = self.boss_family_cfg.active_boss
    self.miku_cost_cfg = self.boss_family_cfg.miku_weary_cost
    self.isclick = false
    self.all_boss_list = self.worldboss_auto.worldboss_list
    self.cur_boss_hurt_reward_cfg = ListToMapList(self.worldboss_auto.cur_boss_hurt_reward, "bossID")
    self.task_cfg = ListToMapList(self.boss_family_cfg.precious_boss_task, "task_id")

    self.secret_reward_cfg = ListToMapList(self.boss_family_cfg.precious_boss_reward,"level","reward_param")

    --自动关注列表
    self.auto_focus_cfg = self.boss_family_cfg.focus_level

    --进入条件表（由场景id划分）
    self.enter_condition_cfg = ListToMap(self.boss_family_cfg.enter_condition, "scene_id")

    --由关注等阶划分的精英boss列表
    self.focus_miku_boss_cfg = ListToMapList(self.boss_family_cfg.miku_boss, "is_cross", "focus_level")

    --由关注等阶划分的Vipboss列表
    self.focus_boss_family_cfg = ListToMapList(self.boss_family_cfg.boss_family, "is_cross", "focus_level")

    --仙戒boss相关本地表
    self.xianjie_boss_other_cfg = self.boss_family_cfg.xianjie_boss_other_cfg[1]
    self.xianjie_boss_pos_cfg = ListToMap(self.boss_family_cfg.xianjie_boss_pos_cfg, "boss_id")
    self.xianjie_boss_gather_cfg =ListToMap(self.boss_family_cfg.xianjie_boss_gather_cfg, "boss_id")

    -- 宝宝boss相关本地表
    self.baby_boss_enter_cost = ListToMap(self.baby_boss_cfg.enter_cost, "enter_times")
    self.baby_boss_angry_value = ListToMap(self.baby_boss_cfg.kill_angry_value, "monster_id")
    self.baby_boss_is_boss = ListToMap(self.baby_boss_cfg.scene_cfg, "monster_id")

    --活跃boss排行奖励
    self.active_boss_rank_reward = ListToMapList(self.boss_family_cfg.active_boss_rank_reward, "bossid")
    self.active_boss_layer_cfg = ListToMapList(self.active_boss_cfg, "layer")

    self.all_boss_info = {}
    self.worldboss_list = {}
    self.follow_boss_list = {}

    self.boss_family_id_cfg = ListToMap(self.boss_family_cfg.boss_family_client, "scene_id")

    for k,v in pairs(self.all_boss_list) do
        table.insert(self.worldboss_list, v)
    end

    local scene_id = 0
    self.active_boss_level_list = {}
    local active_boss_list = ListToMap(self.active_boss_cfg, "scene_id")
    for k,v in pairs(active_boss_list) do
        table.insert(self.active_boss_level_list, k)
    end

    local scene_id_family = 0
     self.family_boss_level_list = {}
    for k,v in ipairs(self.boss_family_cfg.boss_family) do
        if scene_id_family ~= v.scene_id then
            scene_id_family = v.scene_id
            table.insert(self.family_boss_level_list, v.scene_id)
        end
    end

    local scene_id_miku = 0
     self.miku_boss_level_list = {}
    for k,v in ipairs(self.boss_family_cfg.miku_boss_client) do
        if scene_id_miku ~= v.scene_id then
            scene_id_miku = v.scene_id
            table.insert(self.miku_boss_level_list, v.scene_id)
        end
    end

    local scene_id_miku = 0
     self.dabao_boss_level_list = {}
    for k,v in ipairs(self.boss_family_cfg.dabao_boss_client) do
        if scene_id_miku ~= v.scene_id then
            scene_id_miku = v.scene_id
            table.insert(self.dabao_boss_level_list, v.scene_id)
        end
    end

     self.baobao_boss_level_list = {}
    for k,v in pairs( self.baby_boss_cfg.scene_cfg) do
        self.baobao_boss_level_list[v.scene_id] = v.scene_id
    end

     local scene_id_xianjie = 0
     self.xianjie_boss_level_list = {}
    for k,v in ipairs(self.boss_family_cfg.xianjie_boss_pos_cfg) do
        if scene_id_xianjie ~= v.scene_id then
            scene_id_xianjie = v.scene_id
            table.insert(self.xianjie_boss_level_list, v.scene_id)
        end
    end

    self.worldboss_list[0] = table.remove(self.worldboss_list, 1)

    self.next_monster_invade_time = 0
    self.next_refresh_time = 0

    self.boss_active_hurt_info = {
        my_hurt = 0,
        my_rank = 0,
        rank_count = 0,
        rank_info_list = {},
    }

    self.boss_personal_hurt_info = {
        my_hurt = 0,
        self_rank = 0,
        rank_count = 0,
        rank_list = {},
    }

    self.boss_guild_hurt_info = {
        my_guild_hurt = 0,
        my_guild_rank = 0,
        rank_count = 0,
        rank_list = {},
    }

    self.boss_week_rank_info = {
        my_guild_kill_count = 0,
        my_guild_rank = 0,
        rank_count = 0,
        rank_list = {},
    }
    self.worldboss_weary = 0
    self.worldboss_weary_last_die_time = 0
    self.dabao_angry_value = 0
    self.dabao_enter_count = 0
    self.active_angry_value = 0
    self.active_enter_count = 0
    self.buy_miku_werary_count = 0
    self.boss_layer = -1

    self.xianjie_pos_x = 0
    self.xianjie_pos_y = 0
    self.xianjie_boss_day_count = 0

    self.family_boss_list = {}
    self.family_boss_list.boss_list = {}
    self.miku_boss_info = {
        miku_boss_weary = 0,
        boss_list = {}
    }
    --
    self.miku_isremaind = false
    self.active_isremaind = false
    self.miku_flushtime = 0
    self.xianjie_flushtime = 0
    self.check_kill_info_boss = 0

    --宝宝boss
    self.baby_boss_role_info = {}
    self.baby_boss_all_info = {}
    self.baby_boss_single_info = {}

    --BOSS提醒
    self.list_require = {}
    self.require_time = {[2] = {time = 0}, [5] = {time = 0}, [7] = {time = 0}, [8] = {time = 0}, [12] = {time = 0}, [13] = {time = 0}}
    self.require_priority = 999
    self.open_time = 0
    self.CD_list = {}

    --奇遇BOSS
    self.encounter_boss_info = {}

    self.is_openmiku = true
    self.has_open = false
    self.miku_remind_flag = true

    self.boss_list = {}
    self.dabao_flush_info = {}
    self.active_flush_info = {}
    self:AddEvent(BossData.DABAO_BOSS)
    self:AddEvent(BossData.FAMILY_BOSS)
    self:AddEvent(BossData.MIKU_BOSS)
    self:AddEvent(BossData.ACTIVE_BOSS)
    self.main_ui_is_open = false
    self.cur_is_open = false
    self.welfare_ui_is_show = false
    self.select_index_flag = false
    self.mainui_open_complete_handle = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
    self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.OpenFunCallBack, self))
    self.item_event = BindTool.Bind(self.ItemEvent, self)
    ItemData.Instance:NotifyDataChangeCallBack(self.item_event)
    RemindManager.Instance:Register(RemindName.Boss, BindTool.Bind(self.GetBossRemind, self))
    -- RemindManager.Instance:Register(RemindName.MikuBoss,BindTool.Bind(self.MikuBossCallBack, self))


    BOSS_SCENE_LIST = {
    [BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY] = self.family_boss_level_list,
    [BOSS_ENTER_TYPE.TYPE_BOSS_MIKU] = self.miku_boss_level_list,
    [BOSS_ENTER_TYPE.TYPE_BOSS_DABAO] = self.dabao_boss_level_list,
    [BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE] = self.active_boss_level_list,
    [BOSS_ENTER_TYPE.XIAN_JIE_BOSS] = self.xianjie_boss_level_list,
    [BOSS_ENTER_TYPE.TYPE_BOSS_BABY] = self.baobao_boss_level_list }

end

function BossData:__delete()
    RemindManager.Instance:UnRegister(RemindName.Boss)
    -- RemindManager.Instance:UnRegister(RemindName.MikuBoss)
    GlobalEventSystem:UnBind(self.mainui_open_complete_handle)
    GlobalEventSystem:UnBind(self.event_quest)
    self.nowpanelboss_num = nil

    if self.welfare_focus_time_quest then
        GlobalTimerQuest:CancelQuest(self.welfare_focus_time_quest)
        self.welfare_focus_time_quest = nil
    end

    if self.main_welfare_icon_time_quest then
        GlobalTimerQuest:CancelQuest(self.main_welfare_icon_time_quest)
        self.main_welfare_icon_time_quest = nil
    end

    if self.item_event then
        ItemData.Instance:UnNotifyDataChangeCallBack(self.item_event)
        self.item_event = nil
    end
    if self.time_quest then
        GlobalTimerQuest:CancelQuest(self.time_quest)
        self.time_quest = nil
    end

    self:CancelQuest()
    UnityEngine.PlayerPrefs.DeleteKey("XianJieBossView")
    self.main_ui_is_open = false
    self.cur_is_open = false
    self.welfare_ui_is_show = false
    self.select_index_flag = false
    BossData.Instance = nil
end

function BossData:GetOtherCfg()
    return self.other_cfg
end

function BossData:ClearCache()
    self.boss_personal_hurt_info = {
        my_hurt = 0,
        self_rank = 0,
        rank_count = 0,
        rank_list = {},
    }

    self.boss_guild_hurt_info = {
        my_guild_hurt = 0,
        my_guild_rank = 0,
        rank_count = 0,
        rank_list = {},
    }
end

function BossData:SetNextMonsterInvadeTime(time)
    self.next_monster_invade_time = time
end

function BossData:GetNextMonsterInvadeTime()
    return self.next_monster_invade_time
end

function BossData:OpenFunCallBack(name)
    if name == "boss" then
        RemindManager.Instance:Fire(RemindName.Boss)
    end
end

function BossData:GetBossState(boss_id)
    return BossData.Boss_State.ready
end

function BossData:OnSCFollowBossInfo(protocol)
    self.follow_boss_list = protocol.follow_boss_list
    if #self.follow_boss_list ~= 0 then
        self:CalToRemind()
    end
end

--获取关注列表
function BossData:GetFollowBossList()
    return self.follow_boss_list
end

--boss是否被关注 true被关注, false 没关注
function BossData:BossIsFollow(boss_id)
   for k,v in pairs(self.follow_boss_list) do
        if v.boss_id == boss_id then
            return true
        end
    end
    return false
end

function BossData:MikuBossCallBack()
    RemindManager.Instance:Fire(RemindName.Boss)
end

--boss提醒功能
function BossData:CalToRemind()
    local boss_id, timer = self:GetFocusBossFlush()
    if boss_id == 0 or timer == 0 then
        return
    end
    if self.time_quest then
        GlobalTimerQuest:CancelQuest(self.time_quest)
        self.time_quest = nil
    end

    self.forcus_boss = boss_id
    timer = timer - TimeCtrl.Instance:GetServerTime()
    if nil == self.time_quest then
        self.time_quest = GlobalTimerQuest:AddRunQuest(function()
            timer = timer - UnityEngine.Time.deltaTime
            if timer <= 0 then
                local ok_call_back = function()
                    if self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY and not BossData.Instance:GetFamilyBossCanGoByVip(self.foucs_boss_info.scene_id) then
                        local ok_fun = function ()
                            local vo = GameVoManager.Instance:GetMainRoleVo()
                            local _, cost_gold = BossData.Instance:GetBossVipLismit(self.foucs_boss_info.scene_id)

                            if vo.bind_gold >= cost_gold then
                                self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
                                self:SendToActtack()
                            else
                                if vo.gold + vo.bind_gold >= cost_gold then
                                    self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
                                    self:SendToActtack()
                                else
                                    TipsCtrl.Instance:ShowLackDiamondView()
                                end
                            end
                        end
                        TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, Language.Boss.BossFamilyLimit)

                    else
    					self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
                        self:SendToActtack()
                    end
                end
                if self.open_boss_id == nil or self.open_boss_id ~= boss_id and self:GetCanShowFocusTip() then
                    TipsCtrl.Instance:ShowBossFocusTip(boss_id, self.focus_boss_type, ok_call_back)
                    self.open_boss_id = boss_id
                end
                self.forcus_boss, timer = self:GetFocusBossFlush()
                if self.forcus_boss == 0 or timer == 0 then
                    GlobalTimerQuest:CancelQuest(self.time_quest)
                    self.time_quest = nil
                    self.open_boss_id = nil
                else
                    timer = timer - TimeCtrl.Instance:GetServerTime()
                end
            end
            local new_boss_id, new_timer = self:GetFocusBossFlush()
            if new_timer - TimeCtrl.Instance:GetServerTime() < timer and boss_id ~= new_boss_id and new_boss_id ~= 0 and new_timer ~= 0 then
                timer = new_timer - TimeCtrl.Instance:GetServerTime()
                boss_id = new_boss_id
            end
        end, 0)
    end
end

function BossData:SendToActtack()
    if self.is_cross == 1 then
        CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_COMMON_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
    else
        BossCtrl.SendEnterBossFamily(self.focus_boss_type, self.foucs_boss_info.scene_id, 0, self.foucs_boss_info.boss_id)
    end
end

function BossData:ItemEvent(change_item_id)
    if change_item_id == GameEnum.PILAO_CARD then
        RemindManager.Instance:Fire(RemindName.Boss)
    end
end

function BossData:FlushMainWelfareIcon()
    if not self.main_ui_is_open then
        return
    end

    local state = self:CheckMainWelfareBoss()

    if state == true and self.welfare_ui_is_show == false then
        self.welfare_ui_is_show = true
        MainUICtrl.Instance:FlushView("flush_welfare_icon", {[1] = true})
    elseif state == false and self.welfare_ui_is_show == true then
        self.welfare_ui_is_show = false
        MainUICtrl.Instance:FlushView("flush_welfare_icon", {[1] = false})
    end
end

function BossData:SetWorldBossWearyInfo(protocol)
    self.worldboss_weary = protocol.worldboss_weary
    self.worldboss_weary_last_die_time = protocol.worldboss_weary_last_die_time
    GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
end

function BossData:GetWroldBossWeary()
    return self.worldboss_weary
end

function BossData:GetWroldBossWearyLastDie()
    return self.worldboss_weary_last_die_time
end

--boss之家 密窟
function BossData:SetBossType(boss_type)
    self.boss_type = boss_type
end

--boss之家 密窟
function BossData:GetBossType()
    local scene_id = Scene.Instance:GetSceneId()
    if BossData.IsFamilyBossScene(scene_id) then
        return BOSS_TYPE.FAMILY_BOSS
    end
    if BossData.IsMikuBossScene(scene_id) then
        return BOSS_TYPE.MIKU_BOSS
    end
end

function BossData:SetAutoComeFlag(auto_come_flag)
    self.auto_come_flag = auto_come_flag
end

function BossData:GetAutoComeFlag()
    return self.auto_come_flag
end

function BossData:ToAttackBossFamily()
    if not self:GetCanGoAttack() then
        TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
        return
    end
    local ok_fun = function ()
        local vo = GameVoManager.Instance:GetMainRoleVo()
        local _, cost_gold = self:GetBossVipLismit(self.foucs_boss_info.scene_id)
        if vo.bind_gold >= cost_gold then
            ViewManager.Instance:CloseAll()
            self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
            self:SetBossType(0)
            self.auto_come_flag = true
            BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id)
        else
            if vo.gold + vo.bind_gold >= cost_gold then
                ViewManager.Instance:CloseAll()
                self:SetBossType(0)
                self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
                self.auto_come_flag = true
                BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id)
            else
                TipsCtrl.Instance:ShowLackDiamondView()
            end
        end
    end
    if self:GetFamilyBossCanGoByVip(self.foucs_boss_info.scene_id) then
        BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id)
    else
        TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, Language.Boss.BossFamilyLimit)
    end
end

function BossData:ToAttackBossMiKu()
    if not self:GetCanGoAttack() then
        TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
        return
    end
    if self.foucs_boss_info.scene_id == 0 then
        SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
        return
    end
    ViewManager.Instance:CloseAll()
    self:SetBossType(1)
    self.auto_come_flag = true
    self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
    BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.foucs_boss_info.scene_id)
end

--获得最快刷新的一个boss
function BossData:GetFocusBossFlush()
    if #self.follow_boss_list == 0 then
        return 0, 0
    end
    local list = {}
    for k,v in pairs(self.follow_boss_list) do
        local temp_list = {}
        if v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
            local status = self:GetBossFamilyStatusByBossId(v.boss_id, v.scene_id)
            if status == 0 then
                temp_list.boss_id = v.boss_id
                temp_list.flush_time = self:GetFamilyBossRefreshTime(v.boss_id, v.scene_id)
                temp_list.boss_type = v.boss_type
                temp_list.scene_id = v.scene_id
            end
        elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
            local status = self:GetBossMikuStatusByBossId(v.boss_id, v.scene_id)
            if status == 0 then
                temp_list.boss_id = v.boss_id
                temp_list.flush_time = self:GetMikuBossRefreshTime(v.boss_id, v.scene_id)
                temp_list.boss_type = v.boss_type
                temp_list.scene_id = v.scene_id
            end
        end
        if temp_list.flush_time and temp_list.flush_time > 0 then
            table.insert(list, temp_list)
        end
    end

    local boss_id = 0
    local min_value = 0
    local server_time = TimeCtrl.Instance:GetServerTime()
    if #list ~= 0 then
        min_value = list[1].flush_time
        for k,v in pairs(list) do
            if v.flush_time ~= 0 and v.flush_time <= min_value and v.flush_time - server_time > 30 then
                min_value = v.flush_time
                boss_id = v.boss_id
                self.focus_boss_type = v.boss_type
                self.foucs_boss_info = v
            end
        end
    end
    return boss_id, min_value
end
-----------------------------------世界Boss---------------------------------------------

-- 获取可击杀列表信息
function BossData:GetCanKillList()
    local role_level = GameVoManager.Instance:GetMainRoleVo().level
    local can_kill_list = {}
    for k,v in pairs(self.all_boss_info) do
        if 1 == v.status then
            local boss_cfg = self:GetBossCfgById(v.boss_id)
            local boss_level = self:GetWorldBossInfoById(v.boss_id).boss_level
            if nil ~= boss_cfg and boss_level <= role_level then
                local boss_info = {}
                boss_info.boss_type = boss_cfg.boss_tag
                boss_info.name = boss_cfg.boss_name
                boss_info.scene_id = boss_cfg.scene_id
                boss_info.x = boss_cfg.born_x
                boss_info.y = boss_cfg.born_y
                boss_info.boss_level = boss_level

                boss_info.status = v.status
                boss_info.boss_id = v.boss_id
                can_kill_list[#can_kill_list + 1] = boss_info
            end
        end
    end

    table.sort(can_kill_list, BossData.CanKillKeySort("boss_type", "boss_level"))

    return can_kill_list
end

-- 可击杀排序
function BossData.CanKillKeySort(sort_key_name1, sort_key_name2)
    return function(a, b)
        local order_a = 100000
        local order_b = 100000
        if a[sort_key_name1] < b[sort_key_name1] then
            order_a = order_a + 10000
        elseif a[sort_key_name1] > b[sort_key_name1] then
            order_b = order_b + 10000
        end

        if nil == sort_key_name2 then  return order_a < order_b end

        if a[sort_key_name2] > b[sort_key_name2] then
            order_a = order_a + 1000
        elseif a[sort_key_name2] < b[sort_key_name2] then
            order_b = order_b + 1000
        end

        return order_a > order_b
    end
end

function BossData:GetWorldBossNum()
    if 0 == #self.worldboss_list then
        return nil
    end
    return #self.worldboss_list
end

function BossData:GetBossCfg()
    return self.worldboss_list
end

-- 根据boss_id获取世界boss信息
function BossData:GetBossCfgById(boss_id)
    for k,v in pairs(self.all_boss_list) do
        if boss_id == v.bossID then
            return v
        end
    end
    return nil
end

-- 根据boss_id获取boss状态   1.可击杀   0.未刷新
function BossData:GetBossStatusByBossId(boss_id)
    if nil ~= self.all_boss_info[boss_id] then
        return self.all_boss_info[boss_id].status
    end
    return 0
end

-- 根据boss_id获取boss之家状态   1.可击杀   0.未刷新
function BossData:GetBossFamilyStatusByBossId(boss_id, scene_id)
    if nil ~= self.family_boss_list.boss_list[scene_id] then
        for k,v in pairs(self.family_boss_list.boss_list[scene_id]) do
            if v.boss_id == boss_id then
                return v.status
            end
        end
    end
    return 0
end

function BossData:GetDaBaoStatusByBossId(boss_id, scene_id)
    if nil ~= self.dabao_flush_info[scene_id] then
        for k,v in pairs(self.dabao_flush_info[scene_id]) do
            if v.boss_id == boss_id then
                return v.next_refresh_time
            end
        end
    end
    return 0
end

function BossData:GetActiveStatusByBossId(boss_id, scene_id)
    if nil ~= self.active_flush_info[scene_id] then
        for k,v in pairs(self.active_flush_info[scene_id]) do
            if v.boss_id == boss_id then
                return v.next_refresh_time
            end
        end
    end
    return 0
end

function BossData:GetActiveCurStatusByBossId(boss_id, scene_id)
    if nil ~= self.active_flush_info[scene_id] then
        for k,v in pairs(self.active_flush_info[scene_id]) do
            if v.boss_id == boss_id then
                return math.max(0, v.next_refresh_time - TimeCtrl.Instance:GetServerTime())
            end
        end
    end
    return 0
end

function BossData:GetBossMikuStatusByBossId(boss_id, scene_id)
    if nil ~= self.miku_boss_info.boss_list[scene_id] then
        for k,v in pairs(self.miku_boss_info.boss_list[scene_id]) do
            if v.boss_id == boss_id then
                return v.status
            end
        end
    end
    return 0
end


function BossData:SetBossInfo(protocol)
    self.next_refresh_time = protocol.next_refresh_time
    local boss_list = protocol.boss_list
    self.all_boss_info = {}
    for k,v in pairs(boss_list) do
        self.all_boss_info[v.boss_id] = v
    end
end

function BossData:FlushWorldBossInfo(protocol)
    for k,v in pairs(self.all_boss_info) do
        if k == protocol.boss_id then
            v.status = protocol.status
        end
    end
end

-- 获取世界boss列表
function BossData:GetWorldBossList()
    local boss_list = {}
    for i=0,#self.worldboss_list + 1 do
        if nil ~= self.worldboss_list[i] then
            boss_list[i + 1] = {}
            boss_list[i + 1].bossID = self.worldboss_list[i].bossID
            boss_list[i + 1].boss_type = self.worldboss_list[i].boss_tag
            boss_list[i + 1].status = self:GetBossStatusByBossId(self.worldboss_list[i].bossID)
            boss_list[i + 1].min_lv = self.worldboss_list[i].min_lv
            boss_list[i + 1].postion_x = self.worldboss_list[i].born_x
            boss_list[i + 1].postion_y = self.worldboss_list[i].born_y
        end
    end
    function sortfun(a, b)
        if a.status > b.status then
            return true
        elseif  a.status == b.status then
            local level_1 = self:GetWorldBossInfoById(a.bossID).boss_level
            local level_2 = self:GetWorldBossInfoById(b.bossID).boss_level
            return level_1 < level_2
        else
            return false
        end
    end
    table.sort(boss_list, sortfun)
    return boss_list
end

-- 获取世界boss列表(通过等级排序)
function BossData:GetWorldBossLevelList()
    local boss_list = {}
    for i=0,#self.worldboss_list + 1 do
        if nil ~= self.worldboss_list[i] then
            boss_list[i + 1] = {}
            boss_list[i + 1].bossID = self.worldboss_list[i].bossID
            boss_list[i + 1].boss_type = self.worldboss_list[i].boss_tag
            boss_list[i + 1].status = self:GetBossStatusByBossId(self.worldboss_list[i].bossID)
            boss_list[i + 1].min_lv = self.worldboss_list[i].min_lv
            boss_list[i + 1].postion_x = self.worldboss_list[i].born_x
            boss_list[i + 1].postion_y = self.worldboss_list[i].born_y
        end
    end
    function sortfun(a, b)
        local level_1 = self:GetWorldBossInfoById(a.bossID).boss_level
        local level_2 = self:GetWorldBossInfoById(b.bossID).boss_level
        return level_1 < level_2
    end
    table.sort(boss_list, sortfun)
    return boss_list
end

local SHOW_WORLD_BOSS_NUM = 5
function BossData:GetShowWorldBossList()
    local function CompareLevel(level, diff)
        return (diff >= 0 and diff <= 200)
    end

    local boss_list = self:GetWorldBossLevelList()
    local show_boss_list = {}
    local m_show_boss_list = {}
    if #boss_list > 0 then
        local game_vo = GameVoManager.Instance:GetMainRoleVo()
        for i,v in ipairs(boss_list) do
            local boss = self:GetWorldBossInfoById(v.bossID)
            local diff = game_vo.level - boss.boss_level
            if CompareLevel(game_vo.level, diff) then
                if #show_boss_list < SHOW_WORLD_BOSS_NUM then
                    table.insert(show_boss_list, v)
                else
                    table.remove(show_boss_list, 1)
                    table.insert(show_boss_list, v)
                end
            elseif game_vo.level < boss.boss_level then
                if #show_boss_list == SHOW_WORLD_BOSS_NUM then
                    table.remove(show_boss_list, 1)
                end
                table.insert(show_boss_list, v)
                if #show_boss_list == SHOW_WORLD_BOSS_NUM then
                    break
                end
            else
                if #m_show_boss_list < SHOW_WORLD_BOSS_NUM then
                   table.insert(m_show_boss_list, v)
                else
                    table.remove(m_show_boss_list, 1)
                    table.insert(m_show_boss_list, v)
                end
            end
        end
        if #show_boss_list < SHOW_WORLD_BOSS_NUM then
            local index = 0
            for i=#show_boss_list + 1, SHOW_WORLD_BOSS_NUM do
                local info = m_show_boss_list[#m_show_boss_list - index]
                if info then
                    table.insert(show_boss_list, info)
                else
                    break
                end
            end
        end
    end
    function sortfun(a, b)
        local level_1 = self:GetWorldBossInfoById(a.bossID).boss_level
        local level_2 = self:GetWorldBossInfoById(b.bossID).boss_level
        return level_1 < level_2
    end
    table.sort(show_boss_list, sortfun)
    return show_boss_list
end

function BossData:GetWorldBossRewardList(boss_id)
    local reward_list = nil
    local prof = GameVoManager.Instance:GetMainRoleVo().prof

    local cur_info = nil
    for _, v in pairs(self.worldboss_list) do
        if boss_id == v.bossID then
            cur_info = v
            break
        end
    end
    if nil == cur_info then
        return reward_list
    end

    local list = cur_info["show_item_id" .. prof] or {}
    for k, v in pairs(list) do
        if nil == reward_list then
            reward_list = {}
        end
        reward_list[k+1] = v
    end

    return reward_list
end

-- 根据索引获取boss信息
function BossData:GetWorldBossInfoById(boss_id)
    local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
    local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[boss_id]
    local id = main_role_vo.prof
    local cur_info = nil
    for k,v in pairs(self.worldboss_list) do
        if boss_id == v.bossID then
            cur_info = v
            break
        end
    end
    if nil == cur_info then return end

    local monster_info = self:GetMonsterInfo(boss_id) or {}

    local boss_info = {}
    boss_info.boss_name = cur_info.boss_name
    boss_info.boss_id = cur_info.bossID
    boss_info.scene_id = cur_info.scene_id
    boss_info.born_x = cur_info.born_x
    boss_info.born_y = cur_info.born_y
    local scene_config = ConfigManager.Instance:GetSceneConfig(boss_info.scene_id)
    boss_info.map_name = scene_config.name
    boss_info.refresh_time = cur_info.refresh_time
    boss_info.recommended_power = cur_info.recommended_power
    boss_info.boss_level = monster_cfg and monster_cfg.level or 0

    -- local item_list = {}
    -- local show_item_list = cur_info["show_item_id" .. id]
    -- for i = 0, 7 do
    --     local item_id = show_item_list[i].item_id
    --     if item_id then
    --         table.insert(item_list, item_id)
    --     end
    -- end

    -- boss_info.item_list = item_list
    boss_info.boss_capability = cur_info.boss_capability

    boss_info.resid = monster_info.resid

    if nil ~= self.all_boss_info[cur_info.bossID] then
        boss_info.status = self.all_boss_info[cur_info.bossID].status or 0
        boss_info.last_kill_name = self.all_boss_info[cur_info.bossID].last_killer_name or ""
        boss_info.next_refresh_time = self.all_boss_info[cur_info.bossID].next_refresh_time
    end

    return boss_info
end

function BossData:GetMonsterInfo(boss_id)
    return self.monster_cfg[boss_id]
end

function BossData:GetBossNextReFreshTime()
    return self.next_refresh_time
end

function BossData.KeyDownSort(sort_key_name1, sort_key_name2)
    return function(a, b)
        local order_a = 100000
        local order_b = 100000
        if a[sort_key_name1] > b[sort_key_name1] then
            order_a = order_a + 10000
        elseif a[sort_key_name1] < b[sort_key_name1] then
            order_b = order_b + 10000
        end

        if nil == sort_key_name2 then  return order_a < order_b end

        if a[sort_key_name2] > b[sort_key_name2] then
            order_a = order_a + 1000
        elseif a[sort_key_name2] < b[sort_key_name2] then
            order_b = order_b + 1000
        end

        return order_a < order_b
    end
end

function BossData:SetBossPersonalHurtInfo(protocol)
    self.boss_personal_hurt_info.my_hurt = protocol.my_hurt
    self.boss_personal_hurt_info.self_rank = protocol.self_rank
    self.boss_personal_hurt_info.rank_count = protocol.rank_count
    self.boss_personal_hurt_info.rank_list = protocol.rank_list
end

function BossData:SetBossGuildHurtInfo(protocol)
    self.boss_guild_hurt_info = {}
    for k,v in pairs(protocol) do
        self.boss_guild_hurt_info[k] = v
    end
end

function BossData:SetBossWeekRankInfo(protocol)
    for k,v in pairs(protocol) do
        self.boss_week_rank_info[k] = v
    end
end

function BossData:OnSCDabaoBossNextFlushInfo(protocol)
    self.dabao_flush_info[protocol.scene_id] = protocol.boss_list
end

function BossData:OnSCActiveBossNextFlushInfo(protocol)
    self.active_flush_info[protocol.scene_id] = protocol.boss_list
end

function BossData:OnMiKuWearyChange(buy_miku_werary_count)
    self.buy_miku_werary_count = buy_miku_werary_count
end

function BossData:ChangeOpenMiKu()
    local pilao_card_num = ItemData.Instance:GetItemNumInBagById(GameEnum.PILAO_CARD)
    if pilao_card_num > 0 and not self.has_open then
        self.is_openmiku = true
    else
        self.is_openmiku =false
    end
end

function BossData:GetBuyMiKuWearyCount()
    return self.buy_miku_werary_count or 0
end

function BossData:FlushDaBaoFlushInfo(protocol)
    local have_scene = false
    for k,v in pairs(self.dabao_flush_info) do
        if protocol.scene_id == k then
            have_scene = true
            for k,v in pairs(v) do
                if v.boss_id == protocol.boss_id then
                    v.next_refresh_time = protocol.next_refresh_time
                    return
                end
            end
        end
    end
    if have_scene then
        local list = {}
        list.boss_id = protocol.boss_id
        list.next_refresh_time = protocol.next_refresh_time
        table.insert(self.dabao_flush_info[protocol.scene_id], list)
    else
        self.dabao_flush_info[protocol.scene_id] = {}
        self.dabao_flush_info[protocol.scene_id][1] = {}
        self.dabao_flush_info[protocol.scene_id][1].boss_id = protocol.boss_id
        self.dabao_flush_info[protocol.scene_id][1].next_refresh_time = protocol.next_refresh_time
    end
end

function BossData:FlushActiveFlushInfo(protocol)
    local have_scene = false
    for k,v in pairs(self.active_flush_info) do
        if protocol.scene_id == k then
            have_scene = true
            for k,v in pairs(v) do
                if v.boss_id == protocol.boss_id then
                    v.next_refresh_time = protocol.next_refresh_time
                    return
                end
            end
        end
    end
    if have_scene then
        local list = {}
        list.boss_id = protocol.boss_id
        list.next_refresh_time = protocol.next_refresh_time
        table.insert(self.active_flush_info[protocol.scene_id], list)
    else
        self.active_flush_info[protocol.scene_id] = {}
        self.active_flush_info[protocol.scene_id][1] = {}
        self.active_flush_info[protocol.scene_id][1].boss_id = protocol.boss_id
        self.active_flush_info[protocol.scene_id][1].next_refresh_time = protocol.next_refresh_time
    end
end

function BossData:GetBossPersonalHurtInfo()
    return self.boss_personal_hurt_info
end

function BossData:GetBossGuildHurtInfo()
    return self.boss_guild_hurt_info
end

function BossData:GetBossWeekRankInfo()
    return self.boss_week_rank_info
end

function BossData:GetBossWeekRewardConfig()
    return self.worldboss_auto.week_rank_reward
end

function BossData:GetBossOtherConfig()
    return self.worldboss_auto.other[1]
end

function BossData:GetWorldBossIdBySceneId(scene_id)
    if not scene_id then return end
    local config = self:GetBossCfg()
    if config then
        for k,v in pairs(config) do
            if v.scene_id == scene_id then
                return v.bossID
            end
        end
    end
end

function BossData:SetDabaoBossInfo(protocol)
    self.dabao_angry_value  = protocol.dabao_angry_value
    self.dabao_enter_count  = protocol.dabao_enter_count
    self.dabao_kick_time = protocol.kick_time
    self:NotifyEventChange(BossData.DABAO_BOSS)
end

function BossData:SetActiveBossInfo(protocol)
    self.active_angry_value  = protocol.active_angry_value
    self.active_enter_count  = protocol.enter_count
    self.active_kick_time = protocol.kick_time
    self:NotifyEventChange(BossData.ACTIVE_BOSS)
end

function BossData:GetDabaoBossInfo()
    return self.dabao_angry_value
end

function BossData:GetActiveBossInfo()
    return self.active_angry_value
end

function BossData:GetDabaoBossCount()
    return self.dabao_enter_count
end

function BossData:GetActiveBossCount()
    return self.active_enter_count
end

function BossData:GetDabaoFreeTimes()
    return self.boss_family_cfg.other[1].dabao_free_times
end

function BossData:GetBossOtherCfg()
    return self.boss_family_cfg.other[1]
end

function BossData:GetDaBaoKickTime()
    return self.dabao_kick_time
end

function BossData:GetActiveKickTime()
    return self.active_kick_time
end

-- function BossData:GetActiveFirstEnter()
--     return self.active_first_enter or 0
-- end

function BossData:GetDabaoMaxValue()
    return self.boss_family_cfg.other[1].max_value
end

function BossData:GetActiveMaxValue()
    return self.boss_family_cfg.other[1].active_max_weary
end

function BossData:GetBuyWearyGold()
    -- return self.boss_family_cfg.other[1].buy_weary_gold
    local weary_count = BossData.Instance:GetBuyMiKuWearyCount()
    for k,v in pairs(self.miku_cost_cfg) do
        if v.buy_times == weary_count then
            return v.cost
        end
    end
    return 100
end

function BossData:GetDabaoEnterGold(count)
   for k,v in pairs(self.boss_family_cfg.dabao_cost) do
        if v.times == count then
            return v.cost_gold
        end
   end
   return self.boss_family_cfg.dabao_cost[#self.boss_family_cfg.dabao_cost].cost_gold
end

function BossData:CanGoActiveBoss()
    -- local _a, _b, item_id, num = self:GetBossVipLismit(scene_id)
    -- local my_count = ItemData.Instance:GetItemNumInBagById(item_id)
    -- local is_first_enter = self:GetActiveFirstEnter()
    -- local angry_val = self:GetActiveBossInfo()
    -- if is_first_enter == 0 and my_count >= num then
    --     return true
    -- elseif is_first_enter ~= 0 and angry_val < 100 then
    --     return true
    -- elseif is_first_enter ~= 0 and my_count >= num then
    --     return true
    -- else
    --     return false
    -- end
   -- return my_count >= num
   local angry_val = self:GetActiveBossInfo()
   local angry_max = self:GetActiveMaxValue()
   return angry_val < angry_max
end


function BossData:SetFamilyBossInfo(protocol)
    self.family_boss_list.boss_list[protocol.scene_id] = protocol.boss_list
    self:NotifyEventChange(BossData.FAMILY_BOSS)
end

function BossData:GetFamilyBossInfo(scene_id)
    return self.family_boss_list.boss_list[scene_id]
end

function BossData:OnSCBossInfoToAll(protocol)
    if protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
       for k,v in pairs(self.family_boss_list.boss_list) do
            if k == protocol.scene_id then
                for k1,v1 in pairs(v) do
                    if v1.boss_id == protocol.boss_id then
                        v1.status = protocol.status
                        v1.next_refresh_time = protocol.next_refresh_time
                    end
                end
            end
         end
    elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
         for k,v in pairs(self.miku_boss_info.boss_list) do
            if k == protocol.scene_id then
                for k1,v1 in pairs(v) do
                    if v1.boss_id == protocol.boss_id then
                        v1.status = protocol.status
                        v1.next_refresh_time = protocol.next_refresh_time
                    end
                end
            end
         end
    elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
        if self.dabao_flush_info then
            local data = {}
            data.boss_id = protocol.boss_id
            data.next_refresh_time = protocol.next_refresh_time
            table.insert(self.dabao_flush_info, data)
        end
    elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
        if self.active_flush_info then
            local data = {}
            data.boss_id = protocol.boss_id
            data.next_refresh_time = protocol.next_refresh_time
            table.insert(self.active_flush_info, data)
        end
    end
end

function BossData:GetFamilyBossRefreshTime(boss_id, scene_id)
    if self.family_boss_list.boss_list[scene_id] and #self.family_boss_list.boss_list[scene_id] ~= 0 then
        for k,v in pairs(self.family_boss_list.boss_list[scene_id]) do
            if v.boss_id == boss_id then
                return v.next_refresh_time, v.status
            end
        end
    end
    return 0, 0
end

function BossData:GetFamilyBossGatherTime(boss_id, scene_id)
    if self.family_boss_list.boss_list[scene_id] and #self.family_boss_list.boss_list[scene_id] ~= 0 then
        for k,v in pairs(self.family_boss_list.boss_list[scene_id]) do
            if v.boss_id == boss_id then
                if v.tombstone_disappear_timestamp > TimeCtrl.Instance:GetServerTime() then
                    return v.tombstone_left_gather_times
                else
                    return 0
                end
            end
        end
    end
    return 0
end

function BossData:GetCanShowFocusTip()
    local scene_id = Scene.Instance:GetSceneId()
    local scene_config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto")
    local can_go = true
    for k,v in pairs(scene_config) do
        if scene_id == v.scene_type then
            return v.pb_show_boss_tip == 0 -- 0表示显示
        end
    end
    return true
end

function BossData:SetMikuBossInfo(protocol)
    self.miku_boss_info.miku_boss_weary = protocol.miku_boss_weary
    self.miku_boss_info.boss_list[protocol.scene_id] = protocol.boss_list
    self:NotifyEventChange(BossData.MIKU_BOSS)
end

function BossData:SetMikuPiLaoInfo(protocol)
    self.miku_boss_info.miku_boss_weary = protocol.miku_boss_weary
    self.miku_boss_info.boss_family_left_gather_times = protocol.boss_family_left_gather_times
    self.miku_boss_info.boss_family_buy_gather_times = protocol.boss_family_buy_gather_times
    self:NotifyEventChange(BossData.MIKU_BOSS)
end

function BossData:GetMikuBossInfo()
    return self.miku_boss_info
end

function BossData:GetMikuBossNum()
    local info = self.boss_family_cfg.other[1] or {}

    return info.boss_family_daily_free_gather_times or 0
end

function BossData:GetMobeyNum()
    local info = self.boss_family_cfg.boss_family_gather_buy or {}
    local num = self.miku_boss_info.boss_family_buy_gather_times or 0
    if nill == next(info) then
        return 0
    end

    for k, v in pairs(info) do
        if num < v.buy_times or nil == info[k + 1] then
            return v.need_gold
        end
    end

    return 0
end

function BossData:GetMikuBossInfoList(scene_id)
    return self.miku_boss_info.boss_list[scene_id]
end

function BossData:GetMikuBossRefreshTime(boss_id, scene_id)
    if self.miku_boss_info.boss_list[scene_id] and #self.miku_boss_info.boss_list[scene_id] ~= 0 then
        for k,v in pairs(self.miku_boss_info.boss_list[scene_id]) do
            if v.boss_id == boss_id then
                return v.next_refresh_time, v.status
            end
        end
    end
    return 0, 0
end

function BossData:ChangeMikuEliteCount(scene_id, elite_count)
    if nil == self.miku_elite_count_list then
        self.miku_elite_count_list = {}
    end
    self.miku_elite_count_list[scene_id] = elite_count
end

function BossData:GetMikuBossWeary()
    return self.miku_boss_info.miku_boss_weary or 0
end

function BossData:BossFamilyListSort()
    return function(a, b)
        local state_a = self:GetBossFamilyStatusByBossId(a.bossID, a.scene_id)
        local state_b = self:GetBossFamilyStatusByBossId(b.bossID, b.scene_id)
        if state_a ~= state_b then
            return state_a > state_b
        else
            local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
            local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
            if level_a ~= level_b then
                return level_a < level_b
            else
                return a.is_cross < b.is_cross
            end
        end
    end
end
function BossData:GetBossFamilyList(scene_id, add_cross)
    local list = {}
    local kf_scene_id = self:GetBossFamilyKfScene(scene_id) or 0
    for k,v in pairs(self.boss_family_cfg.boss_family) do
        if v.scene_id == scene_id or (add_cross and v.scene_id == kf_scene_id) then
            table.insert(list, v)
        end
    end
    table.sort(list, self:BossFamilyListSort())
    return list
end

function BossData:GetDaBaoBossList(scene_id)
    local list = {}
    for k,v in pairs(self.boss_family_cfg.dabao_boss) do
        if v.scene_id == scene_id then
            table.insert(list, v)
        end
    end
    function sortfun(a, b)
        local state_a = self:GetDaBaoStatusByBossId(a.bossID, scene_id)
        local state_b = self:GetDaBaoStatusByBossId(b.bossID, scene_id)
        if state_a ~= state_b then
            return state_a < state_b
        else
            local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
            local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
            return level_a < level_b
        end
    end
    table.sort(list, sortfun)
    return list
end

function BossData:GetActiveBossList(scene_id)
    local list = {}
    for k,v in pairs(self.active_boss_cfg) do
        if v.scene_id == scene_id then
            table.insert(list, v)
        end
    end
    function sortfun(a, b)
        local state_a = self:GetActiveCurStatusByBossId(a.bossID, scene_id)
        local state_b = self:GetActiveCurStatusByBossId(b.bossID, scene_id)
        if state_a ~= state_b then
            return state_a < state_b
        else
            local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
            local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
            return level_a < level_b
        end
    end
    table.sort(list, sortfun)
    return list
end

function BossData:GetSingleLayerActiveBossList(layer)
    local list = {}
    if layer and self.active_boss_layer_cfg and self.active_boss_layer_cfg[layer] then
        for k,v in pairs(self.active_boss_layer_cfg[layer]) do
            table.insert(list, v)
        end
    end

    function sortfun(a, b)
        local state_a = self:GetActiveCurStatusByBossId(a.bossID, a.scene_id)
        local state_b = self:GetActiveCurStatusByBossId(b.bossID, b.scene_id)
        if state_a ~= state_b then
            return state_a < state_b
        else
            local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
            local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
            return level_a < level_b
        end
    end

    if #list > 1 then
        table.sort(list, sortfun)
    end

    return list or {}
end

function BossData:GetInitActiveBossID()
    local boss_id = 0
    local scene_id = 0

    local list = self.active_boss_cfg
    local single_list = self.active_boss_cfg and self.active_boss_cfg[1]
    if single_list then
        boss_id = single_list.bossID or 0
        scene_id = single_list.scene_id or 0
    end

    return boss_id, scene_id
end

function BossData:GetActiveBossLayerList()
    return self.active_boss_layer_cfg or {}
end

function BossData:GetMikuBossList(scene_id)
    local list = {}
    for k,v in pairs(self.boss_family_cfg.miku_boss) do
        if v.scene_id == scene_id then
            table.insert(list, v)
        end
    end
    function sortfun(a, b)
        local state_a = self:GetBossMikuStatusByBossId(a.bossID, scene_id)
        local state_b = self:GetBossMikuStatusByBossId(b.bossID, scene_id)
        if state_a ~= state_b then
            return state_a > state_b
        else
            local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
            local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
            return level_a < level_b
        end
    end
    table.sort(list, sortfun)
    return list
end

function BossData:GetBossFamilyFallList(boss_id)
    local list = {}
    local show_item_list = {}
    local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
    local id = main_role_vo.prof
    for k,v in pairs(self.boss_family_cfg.boss_family) do
        if v.bossID == boss_id then
            show_item_list = v["show_item_id" .. id]
        end
    end

    for i = 0, 7 do
        if show_item_list[i] then
            table.insert(list, show_item_list[i])
        end
    end

    return list
end

function BossData:GetMikuBossFallList(boss_id)
    local list = {}

    if nil == boss_id then
        return list
    end

    local show_item_list = {}
    local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
    local id = main_role_vo.prof
    local num = 0
    for k,v in pairs(self.boss_family_cfg.miku_boss) do
        if v.bossID == boss_id then
            show_item_list = v["show_item_id" .. id]
        end
    end

    for k,v in pairs(show_item_list) do
        list[k + 1] = v
    end

    return list
end

function BossData:GetBossFamilyListClient()
    return self.boss_family_cfg.boss_family_client
end

--获取boss之家跨服场景
function BossData:GetBossFamilyKfScene(scene_id)
    if self.boss_family_id_cfg[scene_id] then
        return self.boss_family_id_cfg[scene_id].kf_scene_id
    end
    return nil
end


--获取boss之家跨服场景
function BossData:IsBossFamilyKfScene(scene_id)
   scene_id = scene_id or Scene.Instance:GetSceneId()
    for k,v in pairs(self.boss_family_id_cfg) do
        if scene_id == v.kf_scene_id then
            return true
        end
    end
    return false
end

function BossData:GetBossSingleInfo(list ,scene_id, boss_id)
    for k,v in pairs(list) do
        if v.scene_id == scene_id and v.bossID == boss_id then
            return v
        end
    end
end

function BossData:GetBabyBossCurInfo(list ,scene_id, boss_id)
    for k,v in pairs(list) do
        if v.scene_id == scene_id and v.monster_id == boss_id then
            return v
        end
    end
end

function BossData:SetCurInfo(scene_id, boss_id)
    self.boss_scene_id = scene_id
    self.boss_id = boss_id
end

function BossData:GetCurBossInfo(enter_type)
    if enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
        return self:GetBossSingleInfo(self.boss_family_cfg.boss_family, self.boss_scene_id, self.boss_id)
    elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
        return self:GetBossSingleInfo(self.boss_family_cfg.miku_boss, self.boss_scene_id, self.boss_id)
    elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
        return self:GetBossSingleInfo(self.boss_family_cfg.dabao_boss, self.boss_scene_id, self.boss_id)
    elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
        return self:GetBossSingleInfo(self.active_boss_cfg, self.boss_scene_id, self.boss_id)
    elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_BABY then
        return self:GetBabyBossCurInfo(self.baby_boss_cfg.scene_cfg, self.boss_scene_id, self.boss_id)
    end
end

function BossData:GetMikuBossListClient()
    return self.boss_family_cfg.miku_boss_client
end

--获取下一秘窟场景
function BossData:GetNextMikuBossScene(scene_id)
    for i,v in ipairs(self.boss_family_cfg.miku_boss_client) do
        if v.scene_id == scene_id then
            if self.boss_family_cfg.miku_boss_client[i + 1] then
                return self.boss_family_cfg.miku_boss_client[i + 1].scene_id
            end
            break
        end
    end
    return nil
end

--获取上一秘窟场景
function BossData:GetUpperMikuBossScene(scene_id)
    for i,v in ipairs(self.boss_family_cfg.miku_boss_client) do
        if v.scene_id == scene_id then
            if self.boss_family_cfg.miku_boss_client[i - 1] then
                return self.boss_family_cfg.miku_boss_client[i - 1].scene_id
            end
            break
        end
    end
    return nil
end

function BossData:GetMikuBossMaxWeary()
    return self.boss_family_cfg.other[1].weary_upper_limit + self.buy_miku_werary_count
end

function BossData:GetBossVipLismit(scene_id)
    for k,v in pairs(self.boss_family_cfg.enter_condition) do
        if v.scene_id == scene_id then
            return v.free_vip_level, v.cost_gold, v.need_item_id, v.need_item_num
        end
    end
    return 0, 0, 0, 0
end

function BossData:GetDabaoBossRewards(boss_id)
    local list = {}
    local show_item_list = {}
    local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
    local id = main_role_vo.prof
    for k,v in pairs(self.boss_family_cfg.dabao_boss) do
        if v.bossID == boss_id then
            show_item_list = v["show_item_id" .. id]
        end
    end

    for i=0,#show_item_list do
        if show_item_list[i] then
            table.insert(list, show_item_list[i].item_id)
        end
    end

    return list
end

function BossData:GetActiveBossRewards(boss_id)
    local list = {}
    if nil == boss_id then
        return list
    end
    local show_item_list = {}
    local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
    local id = main_role_vo.prof
    local num = 0
    for k,v in pairs(self.active_boss_cfg) do
        if v.bossID == boss_id then
            show_item_list = v["show_item_id" .. id]
        end
    end

    for k,v in pairs(show_item_list) do
        list[k + 1] = v.item_id
    end

    return list
end

function BossData:GetActiveSceneList()
    return self.active_boss_level_list
end

function BossData:GetDabaoBossClientCfg()
    return self.boss_family_cfg.dabao_boss_client
end

function BossData.IsWorldBossScene(scene_id)
    return scene_id >= 200 and scene_id <= 239
end

-- 检测当前场景是否BOSS场景
function BossData:CheckCurBossScene(scene_id)
    local active_boss_cfg = self.boss_family_cfg.active_boss                 -- 活跃Boss
    local miku_boss_cfg = self.boss_family_cfg.miku_boss                     -- 精英Boss
    local xianjie_boss_pos_cfg = self.boss_family_cfg.xianjie_boss_pos_cfg   -- 仙戒Boss(仙缘)
    if active_boss_cfg then
        for k,v in pairs(active_boss_cfg) do
            if scene_id == v.scene_id then
                return true
            end
        end
    end
    if miku_boss_cfg then
        for k,v in pairs(miku_boss_cfg) do
            if scene_id == v.scene_id then
                return true
            end
        end
    end
    if xianjie_boss_pos_cfg then
        for k,v in pairs(xianjie_boss_pos_cfg) do
            if scene_id == v.scene_id then
                return true
            end
        end
    end
    if scene_id == FBScene.MIZANG then                                        -- 密藏Boss
        return true
    end
    return false
end

function BossData.IsDabaoBossScene(scene_id)
    local scene_list = BOSS_SCENE_LIST[BOSS_ENTER_TYPE.TYPE_BOSS_DABAO] or {}
    for _, v in ipairs(scene_list) do
        if v == scene_id then
            return true
        end
    end
    return false
end

function BossData.IsFamilyBossScene(scene_id)
    local scene_list = BOSS_SCENE_LIST[BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY] or {}
    for _, v in ipairs(scene_list) do
        if v == scene_id then
            return true
        end
    end
    return false
end

function BossData.IsMikuBossScene(scene_id)
    local scene_list = BOSS_SCENE_LIST[BOSS_ENTER_TYPE.TYPE_BOSS_MIKU] or {}
    for _, v in ipairs(scene_list) do
        if v == scene_id then
            return true
        end
    end
    return false
end

function BossData.GetActiveFirstFloorScene()
    local scene_list = BOSS_SCENE_LIST[BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE] or {}
    return scene_list[1]
end

function BossData.IsKfBossScene(scene_id)
    return scene_id >= 9030 and scene_id <= 9033
end

function BossData.IsActiveBossScene(scene_id)
    local scene_list = BOSS_SCENE_LIST[BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE] or {}
    for _, v in ipairs(scene_list) do
        if v == scene_id then
            return true
        end
    end
    return false
end

function BossData.IsSecretBossScene(scene_id)
    return scene_id == 1250
end

function BossData.IsBabyBossScene(scene_id)
    local scene_list = BOSS_SCENE_LIST[BOSS_ENTER_TYPE.TYPE_BOSS_BABY] or {}
    for _, v in pairs(scene_list) do
        if v == scene_id then
            return true
        end
    end
    return false
end

function BossData:GetBossFamilyRemainEnemyCount(boss_list, scene_id)
    local count = 0
    for k,v in pairs(boss_list) do
        local next_refresh_time = self:GetFamilyBossRefreshTime(v, scene_id)
        if next_refresh_time <= TimeCtrl.Instance:GetServerTime() then
            count = count + 1
        end
    end
    return count
end

function BossData:GetBossFamilyIdList()
    local cfg = self:GetBossFamilyListClient()
    local id_list = {}
    for k,v in pairs(cfg) do
       id_list[k] = {}
       for m,n in pairs(self:GetBossFamilyList(v.scene_id)) do
          id_list[k][#id_list[k] + 1] = n.bossID
       end
    end
    return id_list
end

function BossData:GetBossMikuRemainEnemyCount(boss_list, scene_id)
    local count = 0
    for k,v in pairs(boss_list) do
        local next_refresh_time = self:GetMikuBossRefreshTime(v, scene_id)
        if next_refresh_time <= TimeCtrl.Instance:GetServerTime() then
            count = count + 1
        end
    end
    return count
end

function BossData:GetBossMikuIdList()
    local cfg = self:GetMikuBossListClient()
    local id_list = {}
    for k,v in pairs(cfg) do
       id_list[k] = {}
       for m,n in pairs(self:GetMikuBossList(v.scene_id)) do
          id_list[k][#id_list[k] + 1] = n.bossID
       end
    end
    return id_list
end

function BossData:GetDaBaoBossCfg()
    return self.dabao_boss_cfg
end

function BossData:GetActiveBossCfg()
    return self.active_boss_cfg
end


function BossData.IsBossScene()
    local scene_id = Scene.Instance:GetSceneId()
    if BossData.IsDabaoBossScene(scene_id)
    or BossData.IsFamilyBossScene(scene_id)
    or BossData.IsMikuBossScene(scene_id)
    or BossData.IsWorldBossScene(scene_id)
    or BossData.IsKfBossScene(scene_id)
    or BossData.IsActiveBossScene(scene_id)
    or BossData.IsSecretBossScene(scene_id) then
        return true
    end
    return false
end


function BossData:GetCanGoAttack()
    local scene_id = Scene.Instance:GetSceneId()
    if BossData.IsDabaoBossScene(scene_id)
    or BossData.IsFamilyBossScene(scene_id)
    or BossData.IsMikuBossScene(scene_id)
    or BossData.IsWorldBossScene(scene_id)
    or BossData.IsKfBossScene(scene_id)
    or BossData.IsActiveBossScene(scene_id)
    or BossData.IsSecretBossScene(scene_id) then
        return false
    end
    return true
end

function BossData:GetCanToSceneLevel(scene)
    local level = GameVoManager.Instance:GetMainRoleVo().level
    for k,v in pairs(self.boss_family_cfg.enter_condition) do
        if v.scene_id == scene then
            return v.min_lv <= level, v.min_lv
        end
    end
    return true
end

function BossData:GetFamilyBossCanGoByVip(scene_id)
    local limit_vip = self:GetBossVipLismit(scene_id)
    local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
    return limit_vip <= my_vip
end

function BossData:GetBossHuDunScale(boss_id)
    for k,v in pairs(self.worldboss_auto.worldboss_list) do
        if boss_id == v.bossID then
            return v.scale
        end
    end
end

function BossData:ChangeHasOpenMiKuValue(is_on)
    self.has_open = is_on
end

function BossData:GetHasOpenMiKu()
    return self.has_open
end

function BossData:GetOpenMiKuValue(is_on)
    return self.is_openmiku
end

function BossData:GetMiKuRedPoint()
    if not OpenFunData.Instance:CheckIsHide("miku_boss") then return false end
    -- if pi_lao <= 0 then
    --     return false
    -- if self.is_openmiku then
    --     return false
    -- end
    -- end
    local flag = self:GetMiKuSmallRemindFlag() and self:GetAddRemind()
    if flag then
        return true
    end
    local weary = self:GetMikuBossWeary()
    local max_weary = self:GetMikuBossMaxWeary()
    local addcount = self:GetBuyMiKuWearyCount()
    local remind_weary = max_weary - (weary + addcount)
    if remind_weary <= 0 then
        return false
    end
    for k,v in pairs(self:GetMikuBossListClient()) do
        local can_go = BossData.Instance:GetCanToSceneLevel(v.scene_id)
        if can_go then
            if self.miku_boss_info.boss_list[v.scene_id] then
                for m,n in pairs(self.miku_boss_info.boss_list[v.scene_id]) do
                    if n.status > 0 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function BossData:GetVipRedPoint()
    if not OpenFunData.Instance:CheckIsHide("vip_boss") then return false end
    local weary = self:GetMikuBossWeary()
    local max_weary = self:GetMikuBossMaxWeary()
    local addcount = self:GetBuyMiKuWearyCount()
    local remind_weary = max_weary - (weary + addcount)
    if remind_weary <= 0 then
        return false
    end
    for k,v in pairs(self:GetBossFamilyListClient()) do
        local can_go = BossData.Instance:GetCanToSceneLevel(v.scene_id)
        if can_go then
            if self.family_boss_list.boss_list[v.scene_id] then
                for m,n in pairs(self.family_boss_list.boss_list[v.scene_id]) do
                    if n.status > 0 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function BossData:GetBabyRedPoint()
    if not OpenFunData.Instance:CheckIsHide("baby_boss") then return false end

    if self:GetBabyBossEnterTimes() < 2 then
        return true
    end

    return false
end

function BossData:GetDaBaoRedPoint()

    if not OpenFunData.Instance:CheckIsHide("dabao_boss") then return false end
    if self.dabao_enter_count < 1 then
        return true
    else
        return false
    end
end

function BossData:GetActiveRedPoint()

    if not OpenFunData.Instance:CheckIsHide("active_boss") then return false end
    for k,v in pairs(self.active_boss_level_list) do
        if self:CanGoActiveBoss(v) then
            return true
        end
    end
    return false
end
function BossData:GetBossRemind()
    return self:CheckRedPoint() and 1 or 0
end

function BossData:CheckRedPoint()
    if not OpenFunData.Instance:CheckIsHide("boss") then
     return false
    end
    if PlayerData.Instance.role_vo.level < 150 then
        return false
    end
    local list = {}
    list[1] = self:GetMiKuRedPoint()
    list[2] =self:GetDaBaoRedPoint()
    list[3] =self:GetActiveRedPoint()
    list[4] = self:GetSecretRedPoint()
    list[5] = self:GetVipRedPoint()

    for k,v in pairs(list) do
        if v == true then
            return true
        end
    end
    return false
end

function BossData:MainuiOpenCreate()
    self.main_ui_is_open = true
end

function BossData:GetActiveBossLayerBySceneId(scene_id)
    local list = self.active_boss_layer_cfg
    for k,v in pairs(self.active_boss_layer_cfg) do
        for k1,v1 in pairs(v) do
            if v1.scene_id == scene_id then
                return k
            end
        end
    end

    return 1
end

function BossData:GetCanGoLevel(boss_type)
    local scene_list = BOSS_SCENE_LIST[boss_type] or {}
    if boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
        scene_list = self:GetBossFamilyListClient()
    end

    local my_level = GameVoManager.Instance:GetMainRoleVo().level
    local recommend_level_list = {}
    local scene_id_list = {}
    for k,v in ipairs(self.boss_family_cfg.enter_condition) do
        for k1,v1 in pairs(scene_list) do
            if boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
                if v.scene_id == v1.scene_id then
                    table.insert(recommend_level_list, v.min_lv)
                end
            elseif v.scene_id == v1 then
                table.insert(recommend_level_list, v.min_lv)
                table.insert(scene_id_list, v.scene_id)
            end
        end
    end



    local index = 0
    if nil == next(recommend_level_list) then
        return index
    end

    for k,v in ipairs(recommend_level_list) do
        if my_level < v then
            if k ~= 1 then
                index = k - 1
            else
                index = 1
            end
            break
        end
    end

    if index == 0 then
        if my_level <= recommend_level_list[1] then
            index = 1
        elseif my_level >= recommend_level_list[#recommend_level_list] then
            index = #recommend_level_list
        end
    end

    if boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
        local scene_id = scene_id_list[index] or 0
        local layer = self:GetActiveBossLayerBySceneId(scene_id)
        return layer
    end

    -- if boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
    --     local vip_level_list = {}
    --     local vip_index = 0
    --     for k,v in pairs(scene_list) do
    --        local vip_limit = BossData.Instance:GetBossVipLismit(v)
    --        table.insert(vip_level_list, vip_limit)
    --     end
    --     local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
    --     for k,v in pairs(vip_level_list) do
    --         if my_vip < v then
    --             if k == 1 then
    --                 vip_index = 1
    --             else
    --                 vip_index = k - 1
    --             end
    --             break
    --         end
    --     end
    --     if vip_index == 0 then
    --         if my_vip <= vip_level_list[1] then
    --             vip_index = 1
    --         elseif my_level >= vip_level_list[#vip_level_list] then
    --             vip_index = #vip_level_list
    --         end
    --     end
    --     if index >= vip_index then
    --         index = vip_index
    --     end
    -- end
    return index
end

function BossData:GetCanBuyMikuWearry()
    local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
    local can_buy_count = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.BUY_DABAO_COUNT]
    return self.buy_miku_werary_count < can_buy_count
end

function BossData:GetWorldBossRewardItems(scene_id)
    local data_list = {}
    local item_list = {}
    local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
    local id = main_role_vo.prof
    for k,v in pairs(self.all_boss_list) do
       if v.scene_id == scene_id then
            data_list = v["scene_item_id"..id]
       end
    end
    for i = 0, 2 do
        if nil ~= data_list[i] then
            local data = {}
        -- 不知道为什么世界BOSS界面奖励物品写死显示红色三星(BossData:GetShowEquipItemList)，这里也一起写死
            data.param = {}
            local item_cfg, big_type = ItemData.Instance:GetItemConfig(data_list[i].item_id)
            if nil ~= item_cfg and nil ~= item_cfg.color and item_cfg.color == GameEnum.ITEM_COLOR_RED and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
                data.param.xianpin_type_list = {58, 59, 60}
            end
            --------------------------------------------------
            data.item_id = data_list[i].item_id
            data.num = 1
            data.is_bind = 0
            table.insert(item_list, data)
        end

    end

    return item_list
end

function BossData:GetWelfareBossFlushTimeCfg()
    local other_cfg = self:GetBossOtherConfig()
    local time_list = {}
    time_list[1] = other_cfg.refresh_time_one/100
    time_list[2] = other_cfg.refresh_time_two/100
    return time_list
end

--检查福利boss是否有存活
function BossData:CheckIsWelfareSurvival()
    for k,v in pairs(self.worldboss_auto.worldboss_list) do
        --存活
        if self:GetBossStatusByBossId(v.bossID) == 1 then
            return true
        end
    end
    return false
end

--检测主界面福利boss图标是否在显示时间内
--新一轮刷新时间点30分钟内
function BossData:CheckMainWelfareBossTime(next_refresh_time)
    local max_diff = 0
    local sever_time = TimeCtrl.Instance:GetServerTime()
    local limit_list = self:GetWelfareBossFlushTimeCfg()
    local hour = os.date("*t", sever_time).hour
    --距离30分钟,剩余时间
    local time_diff = 0
    --根据当前小时,获得刷新最大间隔
    if hour >= limit_list[1] and hour < limit_list[2] then
        max_diff = 21600
    else
        max_diff = 64800
    end
    local remain_time = next_refresh_time - sever_time

    --距离刷新时间x秒后则不需要显示图标
    if remain_time < max_diff - BossData.MAIN_SHOW_WELFARE_TIME_DIFF then
        return false
    end
    local time_diff = remain_time - (max_diff - BossData.MAIN_SHOW_WELFARE_TIME_DIFF)
    return true, time_diff
end

function BossData:SetBossHpInfo(protocol)
    self.boss_hp = protocol
end

function BossData:GetBossHpInfo()
    return self.boss_hp
end

-------------秘藏Boss数据------------

function BossData:GetSecretBossList()
    local list = {}
    local dead_boss = {}
    local world_level = RankData.Instance:GetWordLevel() or 0
    local data = self.boss_family_cfg.precious_boss_monster
    local range = GetDataRange(data, "world_level")
    local rank = GetRangeRank(range, world_level)
    for k,v in ipairs(data) do
        if v.world_level == rank and v.monster_type == 0 then
            if self.boss_list[v.monster_id] == 0 then
                table.insert(list, v)
            else
                table.insert(dead_boss,v)
            end
        end
    end
    for k,v in pairs(dead_boss) do
        table.insert(list,v)
    end
    return list,dead_boss
end

function BossData:GetSecretRedPoint()

    if not OpenFunData.Instance:CheckIsHide("secret_boss") then return false end
    if not self.task_map then
        return true
    end
    for k,v in pairs(self.task_map) do
        if self.task_map[k] and self.task_map[k].is_finish == 0 then
            return true
        end
    end
    return false
end

function BossData:SecretBossRedPointTimer(is_need)
    self.show_boss_red_point = is_need
end

function BossData:GetBossDataByID(data,id)
    for k,v in pairs(data) do
        if v.monster_id == id then
            return v
        end
    end
end

function BossData:GetSecretBossRefreshTime(boss_id, scene_id)
    if self.miku_boss_info.boss_list[scene_id] and #self.miku_boss_info.boss_list[scene_id] ~= 0 then
        for k,v in pairs(self.miku_boss_info.boss_list[scene_id]) do
            if v.boss_id == boss_id then
                return v.next_refresh_time, v.status
            end
        end
    end
    return 0, 0
end

function BossData:GetTaskInfo()
    if not self.task_scroller_data then
        self:FlushTombFBTaskInfo()
    end
    return self.task_scroller_data
end

function BossData:IsTaskAllDone()
    return false
end

function BossData:IsXianJieBossScene(scene_id)
    local cfg = ConfigManager.Instance:GetAutoConfig("bossfamily_auto").xianjie_boss_pos_cfg
    for k,v in pairs(cfg) do
        if scene_id == v.scene_id then
            return true
        end
    end
    return false
end

function BossData:FlushTombFBTaskInfo()
    self.task_scroller_data = {}
    local finish_task_list = {}
    local un_finish_task_list = {}

    for k,v in pairs(self.boss_family_cfg.precious_boss_task) do
            local text = ""
            if v.task_type == 2 then
            --采集
                local gather_cfg = v.target_name
                text = text..ToColorStr(gather_cfg, TEXT_COLOR.GREEN_3)
            else
            --打怪
                local monster_cfg = v.target_name
                text = text..ToColorStr(monster_cfg, TEXT_COLOR.GREEN_3)
            end
            local is_finish = 0
            if self.task_map and self.task_map[v.task_type] then
                is_finish = self.task_map[v.task_type].is_finish
            end
            if is_finish == 1 then
                --完成
                text = text..
                ToColorStr("(", TEXT_COLOR.GRAY_WHITE)..
                ToColorStr( v.task_condition, TEXT_COLOR.GRAY_WHITE)..
                ToColorStr(" / "..v.task_condition, TEXT_COLOR.GRAY_WHITE)..ToColorStr(")", TEXT_COLOR.GRAY_WHITE)
            else
            --未完成
                local task_condition = 0
                if self.task_map and self.task_map[v.task_type] then
                    task_condition = self.task_map[v.task_type].task_condition
                end
                text = text..
                ToColorStr("(", TEXT_COLOR.GRAY_WHITE)..
                ToColorStr( task_condition, TEXT_COLOR.GRAY_WHITE)..
                ToColorStr(" / "..v.task_condition, TEXT_COLOR.GRAY_WHITE)..ToColorStr(")", TEXT_COLOR.GRAY_WHITE)
            end

            local data = {}
            data.cfg = v
            data.target_text = text
            data.is_finish = (is_finish == 1)
            data.reward_target = self:GetRewardById(v.task_type)
            if data.is_finish then
                table.insert(finish_task_list, data)
            else
                table.insert(un_finish_task_list, data)
            end
        end
    for k,v in pairs(un_finish_task_list) do
        table.insert(self.task_scroller_data, v)
    end
    for k,v in pairs(finish_task_list) do
        table.insert(self.task_scroller_data, v)
    end
end

function BossData:GetTaskFinshInfo(id)
    for k,v in pairs(self.fb_data.task_list) do
        if v.task_id == id then
            return v.is_finish
        end
    end
    return 0
end

function BossData:GetCurParam(id)
    return 0
end

function BossData:GetTaskDataByID(id)
    local data = nil
    local s_data = self:GetTaskInfo()
    for k,v in pairs(s_data) do
        if v.cfg.task_id == id then
            return v
        end
    end
end

function BossData:GetParamById(id)
    return self.task_cfg[id][1].task_type
end

function BossData:NotifyTaskProcessChange(task_id, func)
    self.task_change_callback = func
    self.monitor_task_id = task_type
end

function BossData:UnNotifyTaskProcessChange()
    self.task_change_callback = nil
end

function BossData:TaskMonitor()
    if self.task_list and self.task_change_callback ~= nil then
        for k,v in pairs(self.fb_data.task_list) do
            if v.task_type == self.monitor_task_id then
                if v.task_condition > self.task_list[k].task_condition then
                    self.task_change_callback()
                end
                break
            end
        end
    end
end

function BossData:SetSecretTaskData(protocol)
    self.task_map = {}
    self.fb_data = {}
    self.fb_data.task_list = protocol.task_list
    for k,v in pairs(self.fb_data.task_list) do
        self.task_map[v.task_type] = {}
        self.task_map[v.task_type].task_condition = v.task_condition
        self.task_map[v.task_type].is_finish = v.is_finish
    end
    self:FlushTombFBTaskInfo()
    self:TaskMonitor()
    self.task_list = self.fb_data.task_list
end

function BossData:SetSecretBossInfo(protocol)
    self.boss_list = {}
    for k,v in pairs(protocol.boss_list) do
        self.boss_list[v.boss_id] = v.next_refresh_time
    end
end


function BossData:GetGatherPosition()
    local list = {}
    local data = self.boss_family_cfg.precious_boss_pos
    list.gathers = {}
    list.monsters = {}
    for k,v in pairs(data) do
        if v.pos_type == 2 then
            table.insert(list.gathers,v)
        else
            table.insert(list.monsters,v)
        end
    end
    return list
end

function BossData:GetItemStatusById(id)
    return self.boss_list[id] and self.boss_list[id] or 0
end

function BossData:GetCurTargetPos()
    return self.target.x, self.target.y, self.target.id
end

function BossData:GetRewardById(id)
    local level = GameVoManager.Instance:GetMainRoleVo().level

    for i,v in ipairs(self.boss_family_cfg.boss_reward_level) do
        if level <= v.level then
            if self.secret_reward_cfg and self.secret_reward_cfg[v.level] and self.secret_reward_cfg[v.level][id] then
                return self.secret_reward_cfg[v.level][id][1].reward_score
             end
        end
    end
    return 0
end

function BossData:SetTargetPos(protocol)
    self.target = {}
    self.target.x = protocol.pos_x
    self.target.y = protocol.pos_y
    self.target.id = protocol.param
end

--获取秘藏boss不可打架的范围半径
function BossData:GetSecretNotPkRadius()
    return self.precious_boss_other_cfg.forbid_pk_radius or 0
end

--获取秘藏boss不可攻击的范围中心点
function BossData:GetSecretNotPkCenterXY()
    local center_x = self.precious_boss_other_cfg.forbid_pk_pos_x or 0
    local center_y = self.precious_boss_other_cfg.forbid_pk_pos_y or 0

    return center_x, center_y
end

function BossData:SetSecretExchangeValue(value)
    self.secret_value = value
end

function BossData:GetSecretValue()
    return self.secret_value or 0
end

function BossData:GetSecretOtherCfg()
    return self.precious_boss_other_cfg
end

function  BossData:GetTaskNum()
    local num = 0

    for i,v in pairs(self:GetTaskInfo()) do
        if v.is_finish == false then
            num = num + 1
        end
    end

    return num
end

function BossData:DisplayName(id)
    local display_name = "boss_panel"
    local boss_id = tonumber(id)
    for k,v in pairs(DISPLAYNAME) do
        if k == boss_id then
            display_name = v
            return display_name
        end
    end
    return display_name
end

-- 红色装备转换下属性(强行写死)
function BossData:GetShowEquipItemList(item_id, boss_type)
    local data = {item_id = item_id}
    data.param = {}
    if 3 == boss_type then
        data.param.xianpin_type_list = {58, 59, 60}
    else
        data.param.xianpin_type_list = {58}
    end
    return data
end

-- 是否设置select_index
function BossData:SetSelectIndexFlag(flag)
    self.select_index_flag = flag
    return self.select_index_flag
end

function BossData:GetSelectIndexFlag()
    return self.select_index_flag
end

-- 加疲劳值按钮红点
function BossData:GetAddRemind()
    if ClickOnceRemindList[RemindName.MikuBoss] == 0 then
        return false
    end
    return self:GetPilaoRemind()
end

function BossData:GetPilaoRemind()
    -- 疲劳值
    local weary = self:GetMikuBossWeary()
    local max_weary = self:GetMikuBossMaxWeary()
    local addcount = self:GetBuyMiKuWearyCount()

    local remind_weary = max_weary - (weary + addcount)
    if remind_weary == 0 then
        if ItemData.Instance:GetItemNumInBagById(GameEnum.PILAO_CARD) > 0 then
            return true
        else
            return false
        end
    else
        return false
    end
end

    -- self.xianjie_boss_other_cfg = self.boss_family_cfg.xianjie_boss_other_cfg
    -- self.xianjie_boss_pos_cfg = ListToMap(self.boss_family_cfg.xianjie_boss_pos_cfg, "boss_id")
    -- self.xianjie_boss_gather_cfg =ListToMap(self.boss_family_cfg.xianjie_boss_gather_cfg, "boss_id")

function BossData:SetXianJieBossList(boss_list)
    self.xianjie_boss_list = boss_list
end

function BossData:GetXianJieBossInfoByBossId(boss_id)
    local boss_info = nil
    if nil == self.xianjie_boss_list then
        return boss_info
    end

    for k, v in ipairs(self.xianjie_boss_list) do
        if v.boss_id == boss_id then
            boss_info = v
            break
        end
    end

    return boss_info
end

function BossData:SetXianJieBossPos(protocol)
    self.xianjie_pos_x = protocol.pos_x
    self.xianjie_pos_y = protocol.pos_y
    -- self.xianjie_boss_id = protocol.pos_x
end

function BossData:SetXianJieBossDayCount(count)
    self.xianjie_boss_day_count = count
end

function BossData:GetXianJieBossDayCount()
    return self.xianjie_boss_day_count
end

function BossData:GetXianJieBossOtherCfg()
    return self.xianjie_boss_other_cfg
end

--获取仙戒boss列表
function BossData:GetXianJieBossCfg()
    return self.boss_family_cfg.xianjie_boss_pos_cfg
end

function BossData:GetXianJieBossPosCfgByBossId(boss_id)
    return self.xianjie_boss_pos_cfg[boss_id]
end


--获取仙戒boss奖励列表
function BossData:GetXianJieBossRewardList(boss_id)
    local reward_list = nil
    local boss_gather_info = self.xianjie_boss_gather_cfg[boss_id]

    if nil ~= boss_gather_info then
        local show_item_list = boss_gather_info.show_item_id1
        if nil ~= show_item_list then
            for k, v in pairs(show_item_list) do
                if nil == reward_list then
                    reward_list = {}
                end
                --由于导出的表是0开始的索引，因此索引加1
                reward_list[k+1] = v
            end
        end
    end

    return reward_list
end

function BossData:BossFlushTips(boss_type,flush_time)
    -- if boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
    --     self:CheckMiKuBoss(flush_time)
    -- elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
    --     self:CheckActiveBoss(flush_time)
    -- end
end


function BossData:CancelQuest()
    if self.miku_quest then
        GlobalTimerQuest:CancelQuest(self.miku_quest)
        self.miku_quest = nil
    end

    if self.active_quest then
        GlobalTimerQuest:CancelQuest(self.active_quest)
        self.active_quest = nil
    end
end

function BossData:CheckXianJieBoss(protocol)
    local boss_id = 0
    local scene_id = 0
    local xianjie_list_info = protocol.boss_list or {}
    local my_level = GameVoManager.Instance:GetMainRoleVo().level
    for i,v in ipairs(xianjie_list_info) do
        if v.status == BOSS_STATUS.EXISTENT then
            local cfg = self:GetXianJieBossPosCfgByBossId(v.boss_id)
            if cfg then
                scene_id = cfg.scene_id
            end
            boss_id = v.boss_id
            break
        end
    end

    if scene_id == 0 or boss_id == 0 then return end
    local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
    if scene_config and my_level >= scene_config.levellimit then
        local function callback()
            BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.XIAN_JIE_BOSS, scene_id, 0, boss_id)
        end
--        BossCtrl.Instance:SetOtherBossTips(boss_id, callback, "XianJieBossView", BOSS_ENTER_TYPE.XIAN_JIE_BOSS)
    end
end

function BossData:CheckMiKuBoss(flush_time)
    if self.miku_quest then
        GlobalTimerQuest:CancelQuest(self.miku_quest)
        self.miku_quest = nil
    end
    if not self.miku_quest then
        self.miku_quest = GlobalTimerQuest:AddRunQuest(
            function()
                local max_wearry = self:GetMikuBossMaxWeary()
                local x = self:GetMikuBossWeary()
                local weary = max_wearry - (x + self:GetBuyMiKuWearyCount())
                local is_break = false
                if weary <= 0 then
                    if self.miku_quest and self:IsBossScene() then
                        GlobalTimerQuest:CancelQuest(self.miku_quest)
                        self.miku_quest = nil
                    end
                end
                local time = self.require_time[BOSS_ENTER_TYPE.TYPE_BOSS_MIKU].time - TimeCtrl.Instance:GetServerTime()
                if time <=0 and weary > 0 then
                    self.miku_isremaind = false
                    local select_scene_id = 1
                    local select_boss_id = 0
                    local index = self:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)
                    for i=index,1,-1 do
                        select_scene_id = self.boss_family_cfg.miku_boss_client[i].scene_id
                        local boss_list = self:GetMikuBossList(select_scene_id)
                        for k1,v1 in pairs(boss_list) do
                            local time = self:GetMikuBossRefreshTime(v1.bossID, select_scene_id) - TimeCtrl.Instance:GetServerTime()
                            if time <= 0 then
                                select_boss_id = v1.bossID
                                is_break = true
                                break
                            end
                            local monster_cfg = monster_cfg or BossData.Instance:GetMonsterInfo(v1.bossID)
                            if monster_cfg then
                                local my_level = GameVoManager.Instance:GetMainRoleVo().level
                                if my_level - monster_cfg.level > 200 then
                                    is_break = true
                                    select_boss_id = 0
                                    break
                                end
                            end
                        end
                        if is_break then
                            break
                        end
                    end
                    local miku_callback = function()
                        self:SetCurInfo(scene_id,select_boss_id)
                        BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, select_scene_id, 0, select_boss_id)
                    end
                    if 0 ~= select_boss_id and time <= 0 and weary > 0 then
                        self.miku_isremaind = true
                        BossCtrl.Instance:SetOtherBossTips(select_boss_id, miku_callback, nil, BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)
                    end
                end
            end
        ,0)
    end
end

function BossData:CheckActiveBoss(flush_time)
    if self.active_quest then
        GlobalTimerQuest:CancelQuest(self.active_quest)
        self.active_quest = nil
    end
    if not self.active_quest then
        self.active_quest = GlobalTimerQuest:AddRunQuest(
            function()
                if not self:CanGoActiveBoss() and self:IsBossScene() then
                    if self.active_quest then
                        GlobalTimerQuest:CancelQuest(self.active_quest)
                        self.active_quest = nil
                    end
                end
                local time = self.require_time[BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE].time - TimeCtrl.Instance:GetServerTime()
                if time <=0 and self:CanGoActiveBoss() and not self:IsBossScene() then
                    self.active_isremaind = false
                    local select_scene_id = 1
                    local select_boss_id = 0
                    local index = self:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE)
                    local is_kill = false
                    local is_break = false
                    for i=index,1,-1 do
                        select_scene_id = self.active_boss_level_list[i]
                        local boss_list = self:GetActiveBossList(select_scene_id)
                        for k1,v1 in pairs(boss_list) do
                            if v1 and v1.bossID then
                                local reflash_time = self:GetActiveStatusByBossId(v1.bossID, select_scene_id) - TimeCtrl.Instance:GetServerTime()
                                if reflash_time <= 0 then
                                    is_kill = true
                                    is_break = true
                                    select_boss_id = v1.bossID
                                    break
                                end
                            end
                            local monster_cfg = monster_cfg or ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[v1.bossID]
                            if monster_cfg then
                                local my_level = GameVoManager.Instance:GetMainRoleVo().level
                                if my_level - monster_cfg.level > 200 then
                                    is_break = true
                                    is_kill = false
                                    break
                                end
                            end
                        end
                        if is_break then
                            break
                        end

                    end
                    local active_callback = function()
                        self:SetCurInfo(select_scene_id,select_boss_id)
                        BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, select_scene_id, 1, select_boss_id)
                    end
                    if true == is_kill and time <= 0 and self:CanGoActiveBoss() then
                        BossCtrl.Instance:SetOtherBossTips(select_boss_id, active_callback, nil, BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE)
                    end
                end
            end
        ,0)
    end
end

function BossData:SetRequireList(boss_type,param)
    self.list_require[boss_type] = param
end

function BossData:GetRequireList(boss_type)
    return self.list_require[boss_type]
end

function BossData:ReMoveRequireList(boss_type)
    if nil ~= self.list_require[boss_type] then
        self.list_require[boss_type] = nil
    end
end

function BossData:GetMaxPriorityInRequireList()
    local cur_key = 100
    for k,v in pairs(self.list_require) do
        if k < cur_key then
            cur_key = k
        end
    end
    return self.list_require[cur_key]
end

-- 设置下次打开时间戳
function BossData:SetRequireTime(boss_type, time)
    self.require_time[boss_type].time = time
end

function BossData:GetRequireTime(boss_type, time)
    return self.require_time[boss_type].time
end

function BossData:GetCDByType(boss_type)
    local cd = self.CD_list[boss_type] or 40
    return cd
end

function BossData:SetPriority(index)
    self.require_priority = index
end

function BossData:GetPriority()
    return self.require_priority
end

function BossData:SetOpenTime(time)
    self.open_time = time
end

function BossData:GetOpenTime()
    return self.open_time
end

function BossData:GetActiveBossAllLayer()
   return self.active_boss_layer_cfg and #self.active_boss_layer_cfg or 1
end

function BossData:GetBossFloorList(type, floor_num)
    local scene_num = #BOSS_SCENE_LIST[type]
    if type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
        scene_num = #self:GetBossFamilyListClient()
    elseif type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
        scene_num = self:GetActiveBossAllLayer()
    end

    local now_index = self:GetCanGoLevel(type)
    local list = {}
    if now_index < floor_num or (type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY and scene_num == floor_num) then
        for i = 1, floor_num do
            list[i] = i
        end
    elseif now_index > scene_num - 1 then
        for i = scene_num, 1, -1 do
            list[i] = i
        end
    else
        for i = 1, now_index + 1 do
            list[i] = i
        end
    end
    return list
end

function BossData:SetMiKuSmallRemindFlag(flag)
    self.miku_remind_flag = false
    RemindManager.Instance:Fire(RemindName.Boss)
end

function BossData:GetMiKuSmallRemindFlag()
    return self.miku_remind_flag
end

function BossData:ComBossKillerInfo(protocol)
    local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.check_kill_info_boss]
    if nil == monster_cfg then
        return nil
    end
    local kill_data = {}
    kill_data.killer_info = protocol
    kill_data.boss_name = monster_cfg.name or ""
    return kill_data
end

function BossData:SetCheckKillInfoBossID(boss_id)
    self.check_kill_info_boss = boss_id
end

-------------- 宝宝boss --------------
function BossData:SetBabyBossRoleInfo(protocol)
    self.baby_boss_role_info = protocol or {}
end

function BossData:SetBabyBossAllInfo(protocol)
    self.baby_boss_count = protocol.boss_count or 0
    self.baby_boss_all_info = protocol.boss_info_list or {}
end

function BossData:SetBabyBossSingleInfo(protocol)
    local baby_boss_single_info = protocol.boss_info or {}
    local boss_id = baby_boss_single_info.boss_id or 0
    if nil == next(self.baby_boss_all_info) then
        return
    end
    for k,v in ipairs(self.baby_boss_all_info) do
        if v.boss_id == boss_id then
            self.baby_boss_all_info[k] = baby_boss_single_info
            return
        end
    end
end

function BossData:GetBabyBossAngryValue()
    return self.baby_boss_role_info.angry_value or 0
end

function BossData:GetBabyBossEnterTimes()
    return self.baby_boss_role_info.enter_times or 0
end

function BossData:GetBabyBossKickTime()
    return self.baby_boss_role_info.kick_time or 0
end

function BossData:GetBabyBossMaxAngryValue()
    if nil == self.baby_boss_cfg then
        return 0
    end
    return self.baby_boss_cfg.other[1].angry_value_limit or 0
end

function BossData:GetBabyBosskillerInfo(boss_id)
    if nil == next(self.baby_boss_all_info) then
        return nil
    end
    for i,v in ipairs(self.baby_boss_all_info) do
        if v.boss_id == boss_id then
            return v.killer_info
        end
    end
    return nil
end

function BossData:GetBabyBossEnterCost()
    if nil == next(self.baby_boss_role_info) or nil == next(self.baby_boss_enter_cost) then
        return -1, true
    end

    local enter_times = self.baby_boss_role_info.enter_times or 0
    local max_enter_times = self:GetBabyBossEnterLimitTimes()
    if enter_times >= max_enter_times then
        return -1, true
    end
    if nil == self.baby_boss_enter_cost[enter_times] then
        return -1, true
    end

    local enter_cost = self.baby_boss_enter_cost[enter_times].cost or -1
    local is_bind = self.baby_boss_enter_cost[enter_times].is_bind == 1 and true or false
    return enter_cost, is_bind
end

function BossData:GetBabyBossEnterLimitTimes()
    if nil == self.baby_boss_enter_cost then
        return 0
    end
    return #self.baby_boss_enter_cost + 1
end

function BossData:GetBabyBossAliveNumByLayer(layer)
    if nil == self.baby_boss_all_info
        or nil == self.baby_boss_cfg
        or nil == self.baby_boss_cfg.layer_scene then
        return 0
    end

    local num = 0
    local scene_id = self.baby_boss_cfg.layer_scene[layer].scene_id or 0
    for i,v in ipairs(self.baby_boss_all_info) do
        if v.scene_id == scene_id and v.next_refresh_time == 0 then
            num = num + 1
        end
    end
    return num
end

function BossData:GetBabyBossFallList(boss_id)
    if nil == self.baby_boss_cfg or nil == self.baby_boss_cfg.scene_cfg then
        return {}
    end

    for i,v in ipairs(self.baby_boss_cfg.scene_cfg) do
        if v.monster_id == boss_id then
            return v.reward_item or {}
        end
    end
    return {}
end

function BossData:GetBabyBossListClient()
    if nil == self.baby_boss_cfg then
        return nil
    end
    return self.baby_boss_cfg.layer_scene or nil
end

function BossData:GetBabyBossCanToSceneLevel(scene_id)
    if nil == self.baby_boss_cfg or nil == self.baby_boss_cfg.scene_cfg then
        return false, 0
    end

    local my_level = GameVoManager.Instance:GetMainRoleVo().level
    for i,v in ipairs(self.baby_boss_cfg.scene_cfg) do
        local scene_cfg = ConfigManager.Instance:GetSceneConfig(v.scene_id)
        if nil == scene_cfg then
            return false, 0
        end
        if scene_id == v.scene_id and my_level < scene_cfg.levellimit then
            return false, scene_cfg.levellimit
        end
    end
    return true, 0
end

function BossData:GetBabyBossCanGoLevel()
    if nil == self.baby_boss_cfg then
        return 0
    end

    local min_level_list = self.baby_boss_cfg.scene_cfg
    if nil == min_level_list then
        return 0
    end

    local max_layer = #self:GetBabyBossFloorList()
    local my_level = GameVoManager.Instance:GetMainRoleVo().level
    local scene_id = 0
    for i,v in ipairs(min_level_list) do
        local scene_cfg = ConfigManager.Instance:GetSceneConfig(v.scene_id)
        if my_level < scene_cfg.levellimit then
            scene_id = v.scene_id
            break
        end
    end
    if scene_id == 0 then
        local first_scene_cfg = ConfigManager.Instance:GetSceneConfig(min_level_list[1].scene_id)
        local last_scene_cfg = ConfigManager.Instance:GetSceneConfig(min_level_list[#min_level_list].scene_id)
        if nil == first_scene_cfg or nil == last_scene_cfg then
            return 0
        end
        local first_level_limit = first_scene_cfg.levellimit
        local last_level_limit = last_scene_cfg.levellimit
        if my_level <= first_level_limit then
            return 1
        elseif my_level >= last_level_limit then
            return max_layer
        end
    end

    local layer = self:GetBabyBossLayerBySceneID(scene_id)
    return layer - 1
end

function BossData:GetBabyBossSceneIDByBossID(boss_id)
    if nil == self.baby_boss_cfg or nil == self.baby_boss_cfg.scene_cfg then
        return 0
    end

    for i,v in ipairs(self.baby_boss_cfg.scene_cfg) do
        if boss_id == v.monster_id then
            return v.scene_id or 0
        end
    end
    return 0
end

function BossData:GetBabyBossLayerBySceneID(scene_id)
    if nil == self.baby_boss_cfg or nil == self.baby_boss_cfg.layer_scene then
        return 0
    end

    for i,v in ipairs(self.baby_boss_cfg.layer_scene) do
        if scene_id == v.scene_id then
            return v.layer
        end
    end
    return 0
end

function BossData:GetBabyBossFloorList()
    if nil == self.baby_boss_cfg or nil == self.baby_boss_cfg.layer_scene then
        return {}
    end

    local layer_list = {}
    for i,v in ipairs(self.baby_boss_cfg.layer_scene) do
        layer_list[i] = v.layer
    end
    return layer_list
end

function BossData:GetBabyBossDataListByLayer(layer)
    local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
    if nil == next(self.baby_boss_all_info)
        or nil == self.baby_boss_cfg
        or nil == monster_cfg
        or nil == next(self.baby_boss_angry_value) then
        return {}
    end

    local layer_scene_auto = self.baby_boss_cfg.layer_scene[layer]
    if nil == layer_scene_auto then
        return {}
    end
    local scene_id = layer_scene_auto.scene_id or 0
    local boss_list = {}
    for i,v in ipairs(self.baby_boss_all_info) do
        if scene_id == v.scene_id then
            local temp_boss_item = {}
            temp_boss_item.boss_id = v.boss_id
            temp_boss_item.scene_id = v.scene_id
            temp_boss_item.next_refresh_time = v.next_refresh_time
            if monster_cfg[v.boss_id] then
                local temp_boss_info = {}
                temp_boss_info.level = monster_cfg[v.boss_id].level
                temp_boss_info.name = monster_cfg[v.boss_id].name
                temp_boss_info.headid = monster_cfg[v.boss_id].headid
                temp_boss_info.boss_type = monster_cfg[v.boss_id].boss_type
                if self.baby_boss_angry_value[v.boss_id] then
                    temp_boss_info.angry_value = self.baby_boss_angry_value[v.boss_id].angry_value or 0
                else
                    temp_boss_info.angry_value = 0
                end
                temp_boss_item.boss_info = temp_boss_info
            end
            table.insert(boss_list, temp_boss_item)
        end
    end

    function sortfun(a, b)
        local state_a = a.next_refresh_time > 0 and 1 or 0
        local state_b = b.next_refresh_time > 0 and 1 or 0
        if state_a ~= state_b then
            return state_a < state_b
        else
            local level_a = a.boss_info.level or 0
            local level_b = b.boss_info.level or 0
            return level_a < level_b
        end
    end
    table.sort(boss_list, sortfun)
    return boss_list
end

function BossData:GetBabyEliteList(layer)
    local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
    if nil == self.baby_boss_cfg
        or nil == self.baby_boss_cfg.layer_scene
        or nil == self.baby_boss_cfg.scene_cfg
        or nil == monster_cfg
        or nil == next(self.baby_boss_angry_value) then
        return {}
    end

    if nil == self.baby_boss_cfg.layer_scene[layer] then
        return {}
    end
    local scene_id = self.baby_boss_cfg.layer_scene[layer].scene_id or 0
    local elite_list = {}
    for i,v in ipairs(self.baby_boss_cfg.scene_cfg) do
        if scene_id == v.scene_id and v.is_boss == 0 then
            local temp_elite_list = {}
            temp_elite_list.boss_id = v.monster_id
            temp_elite_list.scene_id = v.scene_id
            temp_elite_list.next_refresh_time = 0       -- 宝宝boss精英怪的下一次刷新时间默认为0，即不显示刷新时间
            local monster_info = monster_cfg[v.monster_id]
            if monster_info then
                local temp_elite_info = {}
                temp_elite_info.level = monster_info.level
                temp_elite_info.name = monster_info.name
                if self.baby_boss_angry_value[v.monster_id] then
                    temp_elite_info.angry_value = self.baby_boss_angry_value[v.monster_id].angry_value or 0
                else
                    temp_elite_info.angry_value = 0
                end
                temp_elite_list.boss_info = temp_elite_info
            end
            table.insert(elite_list, temp_elite_list)
        end
    end
    return elite_list
end

function BossData:GetBabyBossLocationByBossID(scene_id, boss_id)
    if nil == self.baby_boss_cfg or nil == self.baby_boss_cfg.scene_cfg then
        return 0, 0
    end

    local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
    if nil == scene_cfg or nil == scene_cfg.monsters then
        return 0, 0
    end
    for i,v in ipairs(scene_cfg.monsters) do
        if boss_id == v.id then
            return v.x, v.y
        end
    end
    return 0, 0
end

function BossData:GetBossHurtRewardList(boss_id)
    return self.cur_boss_hurt_reward_cfg[boss_id] or {}
end

-------------- 奇遇boss --------------
function BossData:SetEncounterBossData(boss_id, ok_callback)
    self.encounter_boss_info.boss_id = boss_id or 0
    self.encounter_boss_info.boss_type = BOSS_ENTER_TYPE.TYPE_BOSS_ENCOUNTER
    self.encounter_boss_info.close_count_down = 12         -- 倒数时间写死为12秒
    self.encounter_boss_info.ok_callback = ok_callback
end

function BossData:GetEncounterBossData()
    return self.encounter_boss_info
end

function BossData:SetEncounterBossEnterTimes(time)
    self.encounter_boss_enter_times = time or 0
end

function BossData:GetEncounterBossEnterTimes()
    local encounter_boss_cfg = ConfigManager.Instance:GetAutoConfig("jingling_advantage_cfg_auto")
    local enter_times = encounter_boss_cfg and encounter_boss_cfg.other[1].boss_max_drop_times or 0
    if self.encounter_boss_enter_times then
        return enter_times - self.encounter_boss_enter_times
    end
    return 0
end

function BossData:SetDropLog(drop_list)
    self.drop_list = drop_list
end

function BossData:GetDropLog()
    return self.drop_list
end

function BossData:GetFocusGradeByLevel(level)
    local focus_level = 0
    for k, v in ipairs(self.auto_focus_cfg) do
        if level < v.role_level then
            break
        end
        focus_level = v.focus_level
    end

    return focus_level
end

--获取玩家的最大关注等阶
function BossData:GetMaxFocusGrade()
    local focus_level = 0
    local main_vo = GameVoManager.Instance:GetMainRoleVo()

    for k, v in ipairs(self.auto_focus_cfg) do
        if main_vo.level >= v.role_level and focus_level < v.focus_level then
            focus_level = v.focus_level
        end
    end

    return focus_level
end

--获取精英boss自动关注列表
function BossData:GetMiKuBossAutoFocusList()
    local focus_list = {}

    local main_vo = GameVoManager.Instance:GetMainRoleVo()

    if main_vo.vip_level <= 3 then
        local max_focus_level = self:GetMaxFocusGrade()

        --0不是跨服，1是跨服的
        local normal_cfg = self.focus_miku_boss_cfg[0]

        --当前等阶的boss列表
        local focus_boss_cfg_list = normal_cfg[max_focus_level] or {}
        for k, v in ipairs(focus_boss_cfg_list) do
            table.insert(focus_list, {boss_id = v.bossID, scene_id = v.scene_id})
        end

        --上一等阶的boss列表
        local last_focus_boss_cfg_list = normal_cfg[max_focus_level - 1] or {}
        for k, v in ipairs(last_focus_boss_cfg_list) do
            table.insert(focus_list, {boss_id = v.bossID, scene_id = v.scene_id})
        end
    end

    return focus_list
end

--获取Vipboss自动关注列表
function BossData:GetBossFamilyAutoFocusList()
    local focus_list = {}

    local main_vo = GameVoManager.Instance:GetMainRoleVo()
    local max_focus_level = self:GetMaxFocusGrade()

    --0不是跨服，1是跨服的
    local normal_cfg = self.focus_boss_family_cfg[0]
    local cross_cfg = self.focus_boss_family_cfg[1]

    local function GetFocusList(cfg, max_level)
        local list = {}

        if cfg[max_level] then
            for k, v in ipairs(cfg[max_level]) do
                if self.enter_condition_cfg[v.scene_id].vip_min <= main_vo.vip_level then
                    table.insert(list, v)
                end
            end
        end

        return list
    end

    local focus_boss_cfg_list = GetFocusList(normal_cfg, max_focus_level)
    local last_focus_boss_cfg_list = GetFocusList(normal_cfg, max_focus_level - 1)

    if main_vo.vip_level <= 3 then
        for k, v in ipairs(focus_boss_cfg_list) do
            table.insert(focus_list, {boss_id = v.bossID, scene_id = v.scene_id})
        end

        --上一等阶的boss列表
        for k, v in ipairs(last_focus_boss_cfg_list) do
            table.insert(focus_list, {boss_id = v.bossID, scene_id = v.scene_id})
        end
    else
        --当前等阶的boss列表
        for k, v in ipairs(focus_boss_cfg_list) do
            table.insert(focus_list, {boss_id = v.bossID, scene_id = v.scene_id})
        end
    end

    --处理跨服boss的情况
    focus_boss_cfg_list = GetFocusList(cross_cfg, max_focus_level)
    last_focus_boss_cfg_list = GetFocusList(cross_cfg, max_focus_level - 1)
    if main_vo.vip_level >= 3 and main_vo.vip_level <= 4 then
        --当前等阶的boss列表
        for k, v in ipairs(focus_boss_cfg_list) do
            table.insert(focus_list, {boss_id = v.bossID, scene_id = v.scene_id})
        end

        --上一等阶的boss列表
        for k, v in ipairs(last_focus_boss_cfg_list) do
            table.insert(focus_list, {boss_id = v.bossID, scene_id = v.scene_id})
        end
    else
        --当前等阶的boss列表
        for k, v in ipairs(focus_boss_cfg_list) do
            table.insert(focus_list, {boss_id = v.bossID, scene_id = v.scene_id})
        end
    end

    return focus_list
end

------------------------------------------------------------------------------------------
function BossData:GetActiveBossHurtRewardList(boss_id)
    local list = {}
    local cfg_list = self.active_boss_rank_reward[boss_id] or {}
    for k,v in pairs(cfg_list) do
       table.insert(list, v)
    end
    return list
end

function BossData:GetActiveBossIdBySceneId(scene_id)
    if nil == scene_id then
        return 0
    end

    local config = self.active_boss_layer_cfg
    if nil == config then
        return 0
    end

    for k,v in pairs(config) do
        for k1,v1 in pairs(v) do
            if v1.scene_id == scene_id then
                return v1.bossID
            end
        end
    end

    return 0
end

function BossData:SetActiveBossHurtInfo(protocol)
    self.boss_active_hurt_info.my_hurt = protocol.my_hurt
    self.boss_active_hurt_info.my_rank = protocol.my_rank
    self.boss_active_hurt_info.rank_count = protocol.rank_count
    self.boss_active_hurt_info.rank_info_list = protocol.rank_info_list
end

function BossData:GetActiveBossHurtInfo()
    return self.boss_active_hurt_info
end

function BossData:SetBossLayer(layer)
    self.boss_layer = layer or -1
end

function BossData:GetBossLayer()
    return self.boss_layer
end
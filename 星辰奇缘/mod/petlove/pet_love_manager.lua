PetLoveManager = PetLoveManager or BaseClass(BaseManager)

function PetLoveManager:__init()
    if PetLoveManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    PetLoveManager.Instance = self
    self.model = PetLoveModel.New()
    self:InitHandler()

    self.cur_type = 0
end

function PetLoveManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function PetLoveManager:InitHandler()
    self:AddNetHandler(15600,self.on15600)
    self:AddNetHandler(15601,self.on15601)
    self:AddNetHandler(15602,self.on15602)
    self:AddNetHandler(15603,self.on15603)
    self:AddNetHandler(15604,self.on15604)
    self:AddNetHandler(15605,self.on15605)

    self:AddNetHandler(15607,self.on15607)
    self:AddNetHandler(15608,self.on15608)
    self:AddNetHandler(15609,self.on15609)
    self:AddNetHandler(15610,self.on15610)

    -- self.on_mainui_loaded = function()
        -- self:request15600()
        -- self:request15608()
    -- end
    -- EventMgr.Instance:AddListener(event_name.trace_quest_loaded, self.on_mainui_loaded)


    self.teamUpdate = function()
        if self.cur_type == 1 then
            self:update_quest(self.cur_type)
        end
    end
end


----------------------------------监听协议返回了
--宠物情缘活动阶段
function PetLoveManager:on15600(data)
    -- print("---------------------------收到15600")

    -- {uint8, phase, "阶段， 1：空闲； 2：公告； 3：进行； 4：结束"}
    --            , {uint32, time, "剩余时间，单位(秒)"}
    self.model.pet_love_status_data = data
    local cfg_data = DataSystem.data_daily_icon[112]
    if RoleManager.Instance.RoleData.lev < cfg_data.lev then
        self.on_role_lev_change = function(data)
            EventMgr.Instance:RemoveListener(event_name.role_level_change, self.on_role_lev_change)
            self:request15600()
        end
        EventMgr.Instance:AddListener(event_name.role_level_change, self.on_role_lev_change)
        return
    end

    self:request15605()

    local state = (data.phase == 2 or data.phase == 3)
    AgendaManager.Instance:SetCurrLimitID(2016, state)
    MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    if data.phase == 1 then
        --空闲
    elseif data.phase == 2 then
        --公告
        self:request15601()

        local iconData = self:create_act_base_logic(cfg_data)
        iconData.clickCallBack = function()
            -- self:request15602()
            self:do_goto_npc()
        end
        iconData.text = TI18N("准备中")
        MainUIManager.Instance:AddAtiveIcon(iconData)
    elseif data.phase == 3 then
        --进行
        self:request15601()

        local iconData = self:create_act_base_logic(cfg_data)
        iconData.clickCallBack = function()
            -- self:request15602()
            self:do_goto_npc()
        end
        iconData.timestamp = data.time + Time.time
        iconData.timeoutCallBack = function()
            self:request15600()
        end
        MainUIManager.Instance:AddAtiveIcon(iconData)


        --弹确认框
        if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.pet_love) == false then
            --没有提示，则提示一下
            local str = TI18N("<color='#2fc823'>[宠物祝福]</color>活动正在进行中，是否前往参加")
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = str
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                --寻路到npc
                self:do_goto_npc()
            end
            NoticeManager.Instance:ConfirmTips(data)

            ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.pet_love)
        end

    elseif data.phase == 4 then
        --结束
        self:reset_task()
    end
end

--活动图标创建基础逻辑
function PetLoveManager:create_act_base_logic(cfg_data)
    local iconData = AtiveIconData.New()
    iconData.id = cfg_data.id
    iconData.iconPath = cfg_data.res_name
    iconData.sort = cfg_data.sort
    iconData.lev = cfg_data.lev
    return iconData
end

--获取NPC活动数据
function PetLoveManager:on15601(data)
    -- print("=======================--------------------------收到15601")
    self.cur_change_pet_ids = data.pet_base_id
    -- {array, single, pet_base_id, "宠物基础Id列表"
     -- , [{uint32, base_id, "宠物基础Id"}]
    -- }
end

--参加宠物情缘活动
function PetLoveManager:on15602(data)
    -- print("=======================--------------------------收到15602")
    if data.op_code == 0 then
        --失败
    else
        --成功
        self.model.has_sign = 2
        self.model.cur_pet_base_id = data.pet_base_id
        self:set_cur_type(1)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--完成宠物情缘活动
function PetLoveManager:on15603(data)
    -- print("=======================--------------------------收到15603")
    if data.op_code == 0 then
        --失败
    else
        --成功
        self:reset_task()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--退出宠物情缘活动
function PetLoveManager:on15604(data)
    -- print("=======================--------------------------收到15604")
    if data.op_code == 0 then
        --失败

    else
        --成功
        self:reset_task()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--自己宠物情缘活动状态
function PetLoveManager:on15605(data)
    -- print("=======================--------------------------收到15605")
    -- {uint8, status, "1：未报名，2：已报名，3：已提交", 4:已接受任务}
    self.model.has_sign = data.status
    self.model.cur_pet_base_id = data.pet_base_id
    if data.status == 2 then
        self:set_cur_type(1)
    elseif data.status == 4 then
        self:set_cur_type(2)
    end
end

--接受活动任务返回
function PetLoveManager:on15607(data)
    -- print("=======================--------------------------收到15607")
    if data.op_code == 0 then
        --失败

    else
        --成功
        self:set_cur_type(2)

        if TeamManager.Instance:HasTeam() then
            local data = nil
            for k, v in pairs(TeamManager.Instance.memberTab) do
                if v.rid ~= RoleManager.Instance.RoleData.id or v.platform ~= RoleManager.Instance.RoleData.platform or v.zone_id ~= RoleManager.Instance.RoleData.zone_id then
                    data = v
                    break
                end
            end

            --判断是否为好友，不是好友，则加好友
            if data ~= nil then
                if FriendManager.Instance:IsFriend(data.rid, data.platform, data.zone_id) == false then
                    local c_data = NoticeConfirmData.New()
                    c_data.type = ConfirmData.Style.Normal
                    c_data.content = string.format("%s<color='%s'>%s</color>%s", TI18N("添加"), ColorHelper.color[2], data.name, TI18N("为好友，完成情缘任务将获得亲密度"))
                    c_data.sureLabel = TI18N("添加好友")
                    c_data.cancelLabel = TI18N("残忍拒绝")
                    c_data.sureCallback = function()
                        FriendManager.Instance:AddFriend(data.rid, data.platform, data.zone_id)
                    end
                    NoticeManager.Instance:ConfirmTips(c_data)
                end
            end
        end
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--更新任务数据返回
function PetLoveManager:on15608(data)
    -- print("=======================--------------------------收到15608")
    self.model.act_data = data
    if data.status == 0 then
        self:set_cur_type(2)
        --自动寻路到怪那里
        self:do_goto_monster()
    else
        --已完成
        self:set_cur_type(3)
    end
end

--删除任务返回
function PetLoveManager:on15609(data)
    -- print("=======================--------------------------收到15609")
    -- {uint32, camp_id, "当前任务Id"}
    self:reset_task()
end

--返回变身另一只宠物
function PetLoveManager:on15610(data)
    -- print("=======================--------------------------收到15610")
    -- {uint32, camp_id, "当前任务Id"}
    if data.op_code == 0 then
        --失败

    else
        --成功
        self.model.cur_pet_base_id = data.pet_base_id
        self:set_cur_type(self.cur_type)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-----------------------------------协议发送逻辑
--登录游戏请求逻辑
function PetLoveManager:RequestInitData()

end

--请求宠物情缘活动阶段
function PetLoveManager:request15600()
    -- print("-------------------------------------------------请求15600")
    Connection.Instance:send(15600, {})
end

--请求可以变换的宠物形象
function PetLoveManager:request15601()
    -- print("-------------------------------------------------请求15601")
    Connection.Instance:send(15601, {})
end

--请求参加宠物情缘活动
function PetLoveManager:request15602()
    -- print("-------------------------------------------------请求15602")
    Connection.Instance:send(15602, {})
end

--请求完成宠物情缘活动
function PetLoveManager:request15603()
    -- print("-------------------------------------------------请求15603")
    Connection.Instance:send(15603, {})
end


--请求退出宠物情缘活动
function PetLoveManager:request15604()
    -- print("-------------------------------------------------请求15604")
    Connection.Instance:send(15604, {})
end

--请求自己宠物情缘活动状态
function PetLoveManager:request15605()
    -- print("-------------------------------------------------请求15605")
    Connection.Instance:send(15605, {})
end

--请求接受活动任务
function PetLoveManager:request15607()
    -- print("-------------------------------------------------请求15607")
    Connection.Instance:send(15607, {})
end

--请求接受活动任务
function PetLoveManager:request15608()
    -- print("-------------------------------------------------请求15608")
    Connection.Instance:send(15608, {})
end

--请求更新任务数据
function PetLoveManager:request15610()
    -- print("-------------------------------------------------请求15610")

    local data = NoticeConfirmData.New()
    local other_pet_id = 0
    for i=1,#self.cur_change_pet_ids do
        if self.cur_change_pet_ids[i].base_id ~= self.model.cur_pet_base_id then
            other_pet_id = self.cur_change_pet_ids[i].base_id
            break
        end
    end
    local cfg_pet_data = DataPet.data_pet[other_pet_id]
    data.type = ConfirmData.Style.Normal
    data.content = string.format("%s<color='#23F0F7'>[%s]</color>", TI18N("消耗50万{assets_2,90000}，变身"), cfg_pet_data.name)
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
        Connection.Instance:send(15610, {})
    end
    NoticeManager.Instance:ConfirmTips(data)
end

---------------------------------------------------任务逻辑
--重置任务
function PetLoveManager:reset_task()
    self.model.has_sign = 1
    self.cur_type = 0
    self:delete_quest()
end

--删除任务
function PetLoveManager:delete_quest()
    if self.quest_track then
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.quest_track.customId, true)
        self.quest_track = nil
    end
end

--寻路到要打的怪那里
function PetLoveManager:do_goto_monster()
    local cfg_data = DataMeetPet.data_camp_list[self.model.act_data.camp_id]
    local temp = BaseUtils.get_unique_npcid(cfg_data.battle_id, 0)
    SceneManager.Instance.sceneElementsModel:Self_AutoPath(cfg_data.map_base_id, temp)
end

--寻路到菲菲npc那里
function PetLoveManager:do_goto_npc()
    local temp = BaseUtils.get_unique_npcid(3, 1)
    SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, temp)
end

--设置当前状态
function PetLoveManager:set_cur_type(_type)
    self.cur_type = _type
    self:update_quest(self.cur_type)
    EventMgr.Instance:RemoveListener(event_name.team_update, self.teamUpdate)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.teamUpdate)
    if self.cur_type == 1 then
        EventMgr.Instance:AddListener(event_name.team_update, self.teamUpdate)
        EventMgr.Instance:AddListener(event_name.team_leave, self.teamUpdate)
    end
end

--更新任务
function PetLoveManager:update_quest(_type)
    if self.quest_track == nil then
        self.quest_track = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom(true)

        self.quest_track.callback = function ()
            if self.cur_type == 1 then
                --便捷组队
                local team_mem_num = 0
                if TeamManager.Instance:HasTeam() then
                    for k, v in pairs(TeamManager.Instance.memberTab) do
                        team_mem_num = team_mem_num + 1
                    end
                end
                if team_mem_num == 2 then
                    -- self:request15607()
                    self:do_goto_npc()
                else
                    --打开队伍面板
                    TeamManager.Instance.TypeOptions = {}
                    TeamManager.Instance.TypeOptions[6] = 66
                    TeamManager.Instance.LevelOption = 1
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team,{1})
                end
            elseif self.cur_type == 2 then
                --开始任务，寻路
                self:do_goto_monster()
            elseif self.cur_type == 3 then
                --提交任务
                self:do_goto_npc()
                -- self:request15603()
            end
        end
    end

    if _type == 1 then
        --便捷组队
        local team_mem_num = 0
        local color_str = ColorHelper.color[6]
        local pet_cfg_data = DataPet.data_pet[self.model.cur_pet_base_id]
        local pet_name = pet_cfg_data.name
        local desc = string.format("%s<color='%s'>%s</color>%s", TI18N("寻找"), ColorHelper.color[2], pet_name, TI18N("组队"))
        if TeamManager.Instance:HasTeam() then
            for k, v in pairs(TeamManager.Instance.memberTab) do
                team_mem_num = team_mem_num + 1
            end
        end
        if team_mem_num >= 2 then
            color_str = ColorHelper.color[1]
            desc = string.format("%s<color='%s'>%s</color>%s", TI18N("领取"), ColorHelper.color[1], TI18N("宠物祝福"), TI18N("任务"))
        end
        self.quest_track.title = string.format("%s<color='%s'>(%s/2)</color>", TI18N("[情缘]组队"), color_str,team_mem_num)
        self.quest_track.Desc = desc
        self.quest_track.fight = false
    elseif _type == 2 then
        --开始任务
        local cfg_data = DataMeetPet.data_camp_list[self.model.act_data.camp_id]
        local fenzi = 0
        local fenmu = 1
        self.quest_track.title = string.format("%s<color='%s'>%s/%s</color>", cfg_data.name, ColorHelper.color[6],fenzi,fenmu)
        self.quest_track.Desc = cfg_data.desc
        self.quest_track.fight = true
    elseif _type == 3 then
        --提交任务
        self.quest_track.title =TI18N("[情缘]情缘共鸣")
        self.quest_track.Desc = string.format("%s<color='%s'>%s</color>%s", TI18N("前往"), ColorHelper.color[1], TI18N("菲菲"),TI18N("处领取奖励"))
        self.quest_track.fight = false
    end
    self.quest_track.type = CustomTraceEunm.Type.Activity
    MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.quest_track)
end

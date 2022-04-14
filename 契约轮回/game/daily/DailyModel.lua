-- @Author: lwj
-- @Date:   2019-01-15 15:10:14
-- @Last Modified time: 2019-11-13 19:59:09


DailyModel = DailyModel or class("DailyModel", BaseBagModel)
local DailyModel = DailyModel

function DailyModel:ctor()
    DailyModel.Instance = self
    self:Reset()
end

function DailyModel:Reset()
    self.daily_info = nil
    self.isUpdatting = false
    self.illution_info = nil
    self.isOpenningShowPanel = false

    self.side_rd_list = {}
    self.all_act_list = {}
    self.daily_cf = {}
    self:GetLoadList()
    self.original_full_act_list = {}
    self.is_show_shape_rd = false
    self.is_show_daily_rewa_rd = false
    self.is_open = false

    self.weekly_info = nil
    self.cur_btn_anchored_pos = nil
    self.is_game_start = true
    self.findback_level = 0
    self.findback_floors = {}
    self.findback_info = {}
    self.findback_type = 1
    self.findback_total_money = 0
    self.findback_extra = false
end

function DailyModel.GetInstance()
    if DailyModel.Instance == nil then
        DailyModel()
    end
    return DailyModel.Instance
end

function DailyModel:SetDailyInfo(info)
    self.daily_info = info
end

function DailyModel:GetActTotal()
    if not self.daily_info then
        return
    end
    return self.daily_info.total
end

--处理多个活动id的问题
function DailyModel:GetLoadList()
    local conTbl = clone(Config.db_daily)
    local interator = table.pairsByKey(conTbl)
    for _, cf in interator do
        local tbl = String2Table(cf.windows)
        for i = 1, #tbl do
            cf.activity = tbl[i]
            self.daily_cf[#self.daily_cf + 1] = cf
        end
    end
end

function DailyModel:GetCurShowList(id)
    self.curActivityList = {}
    self.curActivityList.dailyList = {}
    self.curActivityList.limitList = {}
    local normal_times_list = {}
    local none_times_list = {}
    local curLv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local conTbl = self.daily_cf
    for i = 1, #conTbl do
        local conDat = conTbl[i]
        local data = {}
        data.conData = conDat
        --等级判断
        if String2Table(conDat.reqs)[1][2] <= curLv then
            data.isLock = false
        else
            data.isLock = true
        end
        if data.conData.act_type == 1 then
            --普通活动
            local taskInfo = self:GetTaskInfoById(conDat.id)
            local isAdd = true
            if taskInfo then
                data.taskInfo = taskInfo
                if taskInfo.progress >= data.conData.count then
                    none_times_list[data.conData.order] = data
                    isAdd = false
                end
            end
            if isAdd then
                normal_times_list[data.conData.order] = data
            end
        else
            --限时活动
            local today = LoginModel.GetInstance():GetOpenTime()
            local actConData = Config.db_activity[data.conData.activity]
            local weekTbl = String2Table(actConData.days)
            local isCanAdd = false
            local date = TimeManager.GetInstance():GetTimeDate(os.time())
            if date.wday == 1 then
                date.wday = 7
            else
                date.wday = date.wday - 1
            end
            if actConData.cycle == "daily" then
                --每天循环
                isCanAdd = true
            elseif actConData.cycle == "weekly" then
                --每周循环
                for i, v in pairs(weekTbl) do
                    if v == date.wday then
                        isCanAdd = true
                        break
                    end
                end
            elseif actConData.cycle == "monthly" then
                --每月循环
                for i, v in pairs(weekTbl) do
                    if v == date.day then
                        isCanAdd = true
                        break
                    end
                end
            end
            if isCanAdd then
                local tbl = String2Table(actConData.reqs)
                for i = 1, #tbl do
                    local sin_tbl = tbl[i]
                    if type(sin_tbl) == "table" and sin_tbl[1] == "opdays" then
                        if #sin_tbl > 2 then
                            if today < sin_tbl[2] or today > sin_tbl[3] then
                                --范围时间内有效
                                isCanAdd = false
                            else
                                --该天数之后
                                if today < sin_tbl[2] then
                                    isCanAdd = false
                                end
                            end
                        end
                        break
                    end
                end
                if isCanAdd then
                    local taskInfo = self:GetTaskInfoById(data.conData.id)
                    data.taskInfo = taskInfo
                    data.actData = actConData
                    self.curActivityList.limitList[data.conData.order] = data
                end
            end
        end
    end
    --整理日常任务排序
    self:GetInteratorAddToDailyList(normal_times_list)
    self:GetInteratorAddToDailyList(none_times_list)

    --整理限时活动排序
    local outDateList = {}
    local inDateList = {}
    local finalList = {}
    local interator = table.pairsByKey(self.curActivityList.limitList)
    for i, v in interator do
        v.timeData = {}
        local state = 1     --1:正在进行    2：未到开放时间    3：已过期
        --{{start_time,end_time},{start_time,end_time}}
        local time_tbl = self:GetTimeTblByStr(v.actData.time)
        local start_stamp_list = {}
        local stop_stamp_list = {}
        for i = 1, #time_tbl do
            start_stamp_list[#start_stamp_list + 1] = time_tbl[i][1]
            stop_stamp_list[#stop_stamp_list + 1] = time_tbl[i][2]
            local startStamp = TimeManager.GetInstance():GetStampByHMS(unpack(time_tbl[i][1]))
            local endStamp = TimeManager.GetInstance():GetStampByHMS(unpack(time_tbl[i][2]))
            if os.time() >= startStamp and os.time() < endStamp then
                --正在进行
                finalList[#finalList + 1] = v
                state = 1
                start_stamp_list.running_index = i
                break
            elseif os.time() < startStamp then
                --未到开放时间
                state = 2
                if not stop_stamp_list.target_index then
                    stop_stamp_list.target_index = i
                end
            elseif os.time() >= endStamp then
                --已过期
                state = 3
            end
        end
        if state == 2 then
            inDateList[#inDateList + 1] = v
        elseif state == 3 then
            outDateList[#outDateList + 1] = v
        end
        v.timeData.state = state
        v.timeData.startStamp = start_stamp_list
        v.timeData.endStamp = stop_stamp_list
    end
    for i = 1, #inDateList do
        finalList[#finalList + 1] = inDateList[i]
    end
    for i = 1, #outDateList do
        finalList[#finalList + 1] = outDateList[i]
    end
    self.curActivityList.limitList = finalList

    if not id then
        return self.curActivityList
    elseif id == 1 then
        return self.curActivityList.dailyList
    elseif id == 2 then
        return self.curActivityList.limitList
    end
end

function DailyModel:GetCurLimitList()
    local list = self:GetCurShowList(2)
    local final_list = self:GetSortedList(list)
    return final_list
end

function DailyModel:GetDailyTaskList()
    local list = self:GetCurShowList(1)
    local final_list = self:GetSortedList(list)
    return final_list
end

function DailyModel:GetInteratorAddToDailyList(list)
    local interator = table.pairsByKey(list)
    for i, v in interator do
        self.curActivityList.dailyList[#self.curActivityList.dailyList + 1] = v
    end
end

--获取与等级相关的处理后的列表
function DailyModel:GetSortedList(list)
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local preview_list = {}
    local interator = table.pairsByKey(list)
    local finalList = {}
    for i, v in interator do
        local data_lv = String2Table(v.conData.reqs)[1][2]
        --数据等级要求大于当前等级
        if data_lv > lv then
            --缓存表没有数据
            if not preview_list[1] then
                preview_list[1] = v
            else
                --有数据  比较缓存表的等级与当前数据等级的大小
                local vData = String2Table(preview_list[1].conData.reqs)[1][2]
                if data_lv == vData then
                    --等于  在后面加
                    preview_list[#preview_list + 1] = v
                elseif data_lv < vData then
                    preview_list = {}
                    preview_list[1] = v
                end
            end
        else
            finalList[#finalList + 1] = v
        end
    end
    for i = 1, #preview_list do
        finalList[#finalList + 1] = preview_list[i]
    end
    return finalList
end

function DailyModel:GetListWithoutSortByIndex(index)
    if not index then
        return self.curActivityList
    elseif index == 1 then
        return self.curActivityList.dailyList
    elseif index == 2 then
        return self.curActivityList.limitList
    end
end

function DailyModel:GetTaskInfoById(targetId)
    local result = nil
    for _, info in pairs(self.daily_info.list) do
        if info.id == targetId then
            result = info
            break
        end
    end
    return result
end

function DailyModel:AddPDailyToList(info)
    if self.daily_info then
        for infoKey, taskInfo in pairs(info) do
            if infoKey == "daily" then
                local isGet = false
                for listKey, listInfo in pairs(self.daily_info.list) do
                    if listInfo.id == taskInfo.id then
                        self.daily_info.list[listKey] = taskInfo
                        isGet = true
                        break
                    end
                end
                if not isGet then
                    table.insert(self.daily_info.list, taskInfo)
                end
            elseif infoKey == "total" then
                self.daily_info.total = taskInfo
            end
        end
    end
end

function DailyModel:AddRewardedToList(id)
    self.daily_info.rewarded[#self.daily_info.rewarded + 1] = id
end

function DailyModel:AddWeeklyReward(id)
    self.weekly_info.rewarded[#self.weekly_info.rewarded + 1] = id
end

function DailyModel:GetIsGetRewardResultById(id)
    local result = false
    if not self.daily_info then
        return false
    end
    for i = 1, #self.daily_info.rewarded do
        if self.daily_info.rewarded[i] == id then
            result = true
            break
        end
    end
    return result
end

function DailyModel:SetIllutionInfo(info)
    self.illution_info = info
end

function DailyModel:GetIllutionInfo()
    if self.illution_info.level == 0 then
        self.illution_info.level = 1
    end
    return self.illution_info
end

function DailyModel:GetillutionLevel()
    if self.illution_info.level == 0 then
        self.illution_info.level = 1
    end
    return self.illution_info.level
end

function DailyModel:ModifeidIllutionInfo(data)
    self.illution_info.level = data.level
    self.illution_info.show_id = data.show_id
    self.illution_info.exp = data.exp
end

function DailyModel:SetShowIdIllution(id)
    self.illution_info.show_id = id
end

--外形红点
function DailyModel:CheckIllutionRD()
    local lv = self.illution_info.level
    local cur_cf = Config.db_daily_show[lv]
    if not cur_cf then
        logError("DailyModel db_daily_show 没有该外形等级配置")
        return
    end
    local next_lv = lv + 1
    local next_cf = Config.db_daily_show[next_lv]
    local is_show = false
    if next_cf then
        --未满级
        local next_wanted = next_cf.activation
        if self.illution_info.exp >= next_wanted then
            is_show = true
        end
    end
    return is_show
end

--1:活跃奖励    2：外形
function DailyModel:CheckSideOneRDShow(is_show, rd_type)
    local is_can_show = is_show
    rd_type = rd_type or 1
    if not is_show then
        if rd_type == 1 and self.is_show_shape_rd then
            is_can_show = true
        elseif rd_type == 2 and self.is_show_daily_rewa_rd then
            is_can_show = true
        end
    end
    return is_can_show
end

function DailyModel:GetAllActivityWithoutToday()
    local list = {}
    local interator = table.pairsByKey(self.daily_cf)
    local date = TimeManager.GetInstance():GetTimeDate(os.time())
    if date.wday == 1 then
        date.wday = 7
    else
        date.wday = date.wday - 1
    end
    local stick_list = {}
    local load_list = {}
    local temp_list = {}
    for key, conValue in interator do
        if conValue.act_type == 2 then
            local act_id = conValue.activity
            local act_tbl = Config.db_activity[act_id]
            if act_tbl then
                local ori_info = self.original_full_act_list[act_id]
                if ori_info then
                    local stime = ori_info.stime
                    --dump(ori_info, "<color=#6ce19b>HandleMCInfo   HandleMCInfo  HandleMCInfo  HandleMCInfo</color>")
                    act_tbl.stime = stime
                    local is_dele_old = false
                    --有结束时间
                    local cur_time = os.time()
                    if stime and cur_time < stime then
                        local is_add = false
                        local group = act_tbl.group
                        local temp = temp_list[group]
                        --该活动组没有以缓存的
                        if not temp then
                            is_add = true
                            temp_list[group] = act_tbl
                        else
                            --有以缓存
                            if temp.stime > stime then
                                --当前开始时间早,覆盖
                                is_add = true
                                is_dele_old = true
                                temp_list[group] = act_tbl
                            end
                        end
                        if is_add then
                            local data = {}
                            data.dailyData = conValue
                            data.actData = act_tbl

                            --移除列表中的旧项
                            if is_dele_old then
                                local is_continue_serch = true
                                for i = 1, #stick_list do
                                    if stick_list[i].actData.group == group then
                                        table.remove(stick_list, i)
                                        is_continue_serch = false
                                        break
                                    end
                                end
                                if is_continue_serch then
                                    for i = 1, #load_list do
                                        if load_list[i].actData.group == group then
                                            table.remove(load_list, i)
                                            break
                                        end
                                    end
                                end
                            end
                            --插入新配置
                            if act_tbl.cycle == 1 then
                                stick_list[#stick_list + 1] = data
                            else
                                local isContain = false
                                local days = String2Table(act_tbl.days)
                                for i = 1, #days do
                                    if days[i] == date.wday then
                                        isContain = true
                                        break
                                    end
                                end
                                if not isContain then
                                    load_list[#load_list + 1] = data
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    for i = 1, #stick_list do
        list[#list + 1] = stick_list[i]
    end
    for i = 1, #load_list do
        list[#list + 1] = load_list[i]
    end
    return list
end

function DailyModel:SetWeeklyInfo(data)
    self.weekly_info = data
end

function DailyModel:GetWeeklyItemInfo()
    local list = {}
    local interator = table.pairsByKey(Config.db_weekly)
    local info_list = self.weekly_info.list
    local role_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    for key, conValue in interator do
        local temp = nil
        local data = {}
        if role_lv >= String2Table(conValue.reqs)[1][2] then
            data.isLock = false
        else
            data.isLock = true
        end
        for i = 1, #info_list do
            if info_list[i].id == conValue.id then
                temp = info_list[i]
                break
            end
        end
        data.conData = conValue
        if temp then
            data.serData = temp
        end
        list[#list + 1] = data
    end
    return list
end

function DailyModel:GetWeekTotalAct()
    return self.weekly_info.total
end

function DailyModel:GetWeekIsRewarded(id)
    local result = false
    for i = 1, #self.weekly_info.rewarded do
        if self.weekly_info.rewarded[i] == id then
            result = true
            break
        end
    end
    return result
end

function DailyModel:SetWeeklyTaskList(list)
    self.weekly_info.list = list
end

function DailyModel:AddPWeeklyToList(data)
    local isGet = false
    if self.weekly_info then
        for i = 1, #self.weekly_info.list do
            if self.weekly_info.list[i].id == data.weekly.id then
                self.weekly_info.list[i] = data.weekly
                isGet = true
                break
            end
        end
        if not isGet then
            self.weekly_info.list[#self.weekly_info.list + 1] = data.weekly
        end
        if data.total then
            self.weekly_info.total = data.total
        end
    end
end

--获得当前等级的挂机点，并前往
function DailyModel:GoCurHookPos(creep_id)
    local cur_creep_id = creep_id or self:GetCurHookCreepId()
    SceneManager:GetInstance():AttackCreepByTypeId(cur_creep_id)
end

function DailyModel:GetCurHookCreepId()
    local curLv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local cur_map_lv = 1
    local cur_map_id = nil
    for mapId, mapInfo in pairs(Config.db_afk_map) do
        if mapInfo.level > cur_map_lv and mapInfo.level <= curLv then
            cur_map_lv = mapInfo.level
            cur_map_id = mapInfo.creep
        end
    end
    return cur_map_id
end

function DailyModel:FlyCurHookPos()
    local tar_id = self:GetCurHookCreepId()
    local cf = Config.db_creep[tar_id]
    if not cf then
        return
    end
    local scene_id = cf.scene_id
    local target_pos = SceneConfigManager:GetInstance():GetCreepPosition(scene_id, tar_id)
    local is_free = true
    if RoleInfoModel.GetInstance():GetMainRoleVipLevel() == 0 then
        is_free = false
    end
    local function cb()
        self:GoCurHookPos(tar_id)
    end
    local is_success = SceneControler.GetInstance():UseFlyShoeToPos(scene_id, target_pos.x, target_pos.y, is_free, cb)
    return is_success
end

function DailyModel:GetHookConfigByid(type_id)
    if not self.hook_type_id_list then
        self.hook_type_id_list = {}
        for level, cf in pairs(Config.db_afk_map) do
            self.hook_type_id_list[cf.creep] = cf
        end
    end
    return self.hook_type_id_list[type_id]
end

function DailyModel:CheckIsRunningActById(id)
    local tar_cf = {}
    for i = 1, #self.daily_cf do
        if id == self.daily_cf[i].id then
            tar_cf = self.daily_cf[i]
            break
        end
    end
    return self.all_act_list[tar_cf.activity] == 2
end

function DailyModel:GetTimeTblByStr(time)
    local time_tbl = String2Table(time)
    local for_times = 1
    if time_tbl[1] then
        if time_tbl[1][1] and type(time_tbl[1][1]) == "table" then
            for_times = #time_tbl
        end
    end
    local list = {}
    for i = 1, for_times do
        list[i] = {}
        local start_time, stop_time
        if type(time_tbl[i][1]) == "table" then
            if #time_tbl[i] == 3 then
                stop_time = time_tbl[i][3]
            elseif #time_tbl[i] == 2 then
                stop_time = time_tbl[i][2]
            end
            start_time = time_tbl[i][1]
        else
            if #time_tbl == 3 then
                stop_time = time_tbl[3]
            elseif #time_tbl == 2 then
                stop_time = time_tbl[2]
            end
            start_time = time_tbl[1]
        end
        list[i][1] = start_time
        list[i][2] = stop_time
    end
    return list
end

function DailyModel:CheckDailyRewardRD()
    local is_show = false
    local cur_act = self:GetActTotal()
    local config = Config.db_daily_reward
    for i, v in pairs(config) do
        local cf_act = v.activation
        local is_got = self:GetIsGetRewardResultById(v.id)
        if cur_act >= cf_act and (not is_got) then
            is_show = true
            break
        end
    end
    return is_show
end

--------------------------------------找回
function DailyModel:SetFindbackInfo(data)
    if data.level > 0 then
        self.findback_level = data.level
    end
    if not table.isempty(data.floors) then
        self.findback_floors = data.floors
    end
    if not table.isempty(data.lists) then
        for i = 1, #data.lists do
            local item = data.lists[i]
            self.findback_info[item.key] = item
        end
    end
end

--获取找回次数
--extra:是否包含额外次数
function DailyModel:GetFindCount(key)
    local pfindback = self.findback_info[key]
    if self.findback_type == 1 then
        return pfindback.counts[1], 0
    else
        local counts = pfindback.counts
        local extra_counts = pfindback.extra_counts
        local num1, num2 = 0, 0
        for _, v in pairs(counts) do
            num1 = num1 + v
        end
        for _, v in pairs(extra_counts) do
            num2 = num2 + v
        end
        return num1, num2
    end
end

--是否有金币找回次数
function DailyModel:IsHaveCoinCount()
    for k, v in pairs(self.findback_info) do
        local count = v.counts[1] or 0
        if count > 0 then
            return true
        end
    end
    return false
end

----------红点
--检查主界面图标红点的显示与隐藏
function DailyModel:CheckMainIconRDShow(idx, is_show)
    self.side_rd_list[idx] = is_show
    local show_state = is_show
    if not is_show then
        for idx, show in pairs(self.side_rd_list) do
            if show then
                show_state = true
                break
            end
        end
    end
    return show_state
end
-------

--1：未开      2：正在进行  3:已结束
function DailyModel:SortAllActList(all_act_list)
    self.original_full_act_list = {}
    if (not all_act_list) or table.isempty(all_act_list) then
        return
    end
    self.all_act_list = {}
    local list = {}
    local cur_time = os.time()
    local type = 1
    --相同配置的活动，取即将开始的预告
    for i = 1, #all_act_list do
        local info = all_act_list[i]
        if cur_time < info.stime then
            --未开
        elseif cur_time >= info.stime and cur_time < info.etime then
            --进行中
            type = 2
        elseif cur_time > cur_time then
            --已过期
            type = 3
        end
        list[info.id] = type
        self.original_full_act_list[info.id] = info
    end
    self.all_act_list = list
end

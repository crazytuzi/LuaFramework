-- @Author: lwj
-- @Date:   2019-01-03 10:53:13
-- @Last Modified time: 2019-01-03 11:30:26

BookModel = BookModel or class("BookModel", BaseBagModel)
local BookModel = BookModel

function BookModel:ctor()
    BookModel.Instance = self
    self:Reset()
end

function BookModel:Reset()
    self.infoList = {}
    self.curTheme = 1
    self.fixedInfoList = {}       --处理过的信息列表
    self.curDefaultTheme = 1
    self.curIconId = 0
    self.curBossId = 0
    self.isOpenBookPanel = false
    self.isSetDefault = false
    self.isGettingReward = false
    self.cur_prog = nil
    self.cur_prog_list = {}
    self.jump_theme = nil
end

function BookModel.GetInstance()
    if BookModel.Instance == nil then
        BookModel()
    end
    return BookModel.Instance
end

function BookModel:GetCurThemeList()
    local list = {}
    local conList = Config.db_target
    local data = {}
    local conTaskList = {}
    local hadNotFinList = {}
    local hadGotList = {}
    local infoTargets = self.infoList.targets
    for conId = 1, #conList do
        if conList[conId].pb == 0 then
            data = {}
            if infoTargets[conId] then
                data.conData = conList[conId]
                data.state = infoTargets[conId]
                conTaskList = String2Table(data.conData.tasks)
                data.tasksInfo = {}
                hadNotFinList = {}
                hadGotList = {}
                local len = #conTaskList
                for i = 1, len do
                    local tasksIntera = table.pairsByKey(self.infoList.tasks)
                    for taskId, taskState in tasksIntera do
                        if conTaskList[i] == taskId then
                            if taskState.status == 2 then
                                hadGotList[#hadGotList + 1] = taskState
                            elseif taskState.status == 1 then
                                data.tasksInfo[#data.tasksInfo + 1] = taskState
                            else
                                hadNotFinList[#hadNotFinList + 1] = taskState
                            end
                            break
                        end
                    end
                end
                for i = 1, #hadNotFinList do
                    data.tasksInfo[#data.tasksInfo + 1] = hadNotFinList[i]
                end
                for i = 1, #hadGotList do
                    data.tasksInfo[#data.tasksInfo + 1] = hadGotList[i]
                end
                list[#list + 1] = data
            else
                data.open_data = String2Table(conList[conId].limit)
                data.pre_id = conList[conId].pre_id
                list[#list + 1] = data
            end
        end
    end
    self.fixedInfoList = list
    return list
end

function BookModel:AddTargetInfo(data)
    --if table.isempty(self.infoList.targets) then
    --    self.infoList = data
    --else
    if table.isempty(self.infoList.targets) then
        self.infoList.targets = data.targets
    else
        local isGetTarget = false
        for dTheme, dThemeValue in pairs(data.targets) do
            isGetTarget = false
            for sTheme, sThemeValue in pairs(self.infoList.targets) do
                if dTheme == sTheme then
                    self.infoList.targets[sTheme] = dThemeValue
                    isGetTarget = true
                    break
                end
            end
            if not isGetTarget then
                self.infoList.targets[dTheme] = dThemeValue
            end
        end
    end
    if table.isempty(self.infoList.tasks) then
        self.infoList.tasks = data.tasks
    else
        for dTaskId, dTaskInfo in pairs(data.tasks) do
            local isGetTarget = false
            for sTaskId, sTaskInfo in pairs(self.infoList.tasks) do
                if dTaskId == sTaskId then
                    self.infoList.tasks[sTaskId] = dTaskInfo
                    isGetTarget = true
                    break
                end
            end
            if not isGetTarget then
                self.infoList.tasks[dTaskId] = dTaskInfo
            end
        end
    end

    --end
end

function BookModel:GetThemeStateById(id)
    return self.infoList.targets[id]
end

function BookModel:GetTaskData(task_id)
    return self.infoList.tasks[task_id]
end

function BookModel:SetDeaultTheme()
    local fetch_reward_theme = nil
    local can_do_theme = nil
    local max_theme_idx = 0
    for i = 1, #self.fixedInfoList do
        --是否以开放
        local info = self.fixedInfoList[i]
        if info.conData then

            ---技能完成时
            if info.state == 1 then
                fetch_reward_theme = i
                break
                ---技能未完成时
            elseif info.state == 0 then
                --任务是否可领取
                for ii, v in pairs(info.tasksInfo) do
                    if v.status == 1 then
                        fetch_reward_theme = i
                        break
                    end
                end
                --任务中有可领取的
                if fetch_reward_theme then
                    break
                    --没有未完成的任务,设置首个未完成主题
                elseif not can_do_theme then
                    can_do_theme = i
                end
                ---技能已领取
            else
                max_theme_idx = i
            end

        end
    end
    --有可领领取主题
    if self.jump_theme then
        self.curDefaultTheme = self.jump_theme
    elseif fetch_reward_theme then
        self.curDefaultTheme = fetch_reward_theme
        --有未完成主题
    elseif can_do_theme then
        self.curDefaultTheme = can_do_theme
    else
        self.curDefaultTheme = max_theme_idx
    end
end

function BookModel:CheckRD()
    if not self.infoList.targets then
        return
    end
    self.skill_rd = {}
    self.task_rd = {}
    self.theme_rd = {}
    for i, v in pairs(self.infoList.targets) do
        local cf = Config.db_target[i]
        if cf and cf.pb == 0 then
            local tasks = String2Table(Config.db_target[i].tasks)
            local is_fetch_all = true
            for idx = 1, #tasks do
                for task_id, task_data in pairs(self.infoList.tasks) do
                    if task_id == tasks[idx] then
                        if task_data.status == 1 then
                            self.task_rd[task_id] = true
                            self.theme_rd[i] = true
                            is_fetch_all = false
                        end
                    end
                end
            end
            if v == 1 and is_fetch_all then
                self.skill_rd[i] = true
                self.theme_rd[i] = true
            end
        end
    end
end

function BookModel:IsShowMainRD()
    local is_show = true
    if table.nums(self.skill_rd) == 0 and table.nums(self.task_rd) == 0 then
        is_show = false
    end
    return is_show
end

function BookModel:IsHaveThemeRD(theme_id)
    return self.theme_rd[theme_id]
end

function BookModel:IsHaveTaskRD(task_id)
    return self.task_rd[task_id]
end

function BookModel:GetSequenceTasks(list)
    local tasks = {}
    local temp = {}
    local al_fetch = {}
    local task_info = self.infoList.tasks
    for i = 1, #list do
        local info = task_info[list[i]]
        if info and info.status == 1 then
            tasks[#tasks + 1] = list[i]
        elseif info and info.status == 2 then
            al_fetch[#al_fetch + 1] = list[i]
        else
            temp[#temp + 1] = list[i]
        end
    end
    for i = 1, #temp do
        tasks[#tasks + 1] = temp[i]
    end
    for i = 1, #al_fetch do
        tasks[#tasks + 1] = al_fetch[i]
    end
    return tasks
end

function BookModel:GetCurProgByThemeId(id)
    return self.cur_prog_list[id]
end

function BookModel:IsOpenTheme(id)
    local is_Open = false
    local list = self.fixedInfoList[id]
    if list.conData then
        is_Open = true
    end
    return is_Open
end

function BookModel:IsShowMainIcon()
    if table.isempty(self.infoList.targets) then
        return
    end
    local is_show = false
    local theme_cf = Config.db_target
    for theme_id, tbl in pairs(theme_cf) do
        if tbl.pb == 0 then
            local theme_info = self.infoList.targets[theme_id]
            if not theme_info then
                --没有主题信息,未开启
                is_show = true
                break
            else
                if theme_info == 0 or theme_info == 1 then
                    --已开启,未领取
                    is_show = true
                    break
                end
            end
            --任务
            local task_list = String2Table(tbl.tasks)
            for _, task_id in pairs(task_list) do
                local task_info = self.infoList.tasks[task_id]
                --该任务未开启
                if not task_info then
                    is_show = true
                    break
                else
                    if task_info.status == 0 or task_info.status == 1 then
                        is_show = true
                        break
                    end
                end
            end
        end
    end
    return is_show
end
MidAutumnTaskData  = MidAutumnTaskData  or BaseClass()
function MidAutumnTaskData:__init()
    if MidAutumnTaskData .Instance then
        ErrorLog("[MidAutumnTaskData ] attempt to create singleton twice!")
        return
    end
    MidAutumnTaskData.Instance =self
    self.fetch_reward_list = {}
    self.act_data_list = {}
    RemindManager.Instance:Register(RemindName.MidAutumnActTask, BindTool.Bind(self.GetRemind, self))
end

function MidAutumnTaskData:__delete()
    MidAutumnTaskData .Instance = nil
    RemindManager.Instance:UnRegister(RemindName.MidAutumnActTask)
end

function MidAutumnTaskData:GetRemind()
    local current_active =  self:GetCurrentActive()
    local temp_tab = MidAutumnTaskData.Instance:GetDayActiveDegreeInfoList()
    for i,v in pairs(temp_tab) do
        if v.need_active <= current_active and v.fetch_reward_flag == 0 then
            return 1
        end
    end
    return 0
end

function MidAutumnTaskData:SetExchangeInfo(protocol)
    self.active_degree = protocol.active_degree
    local fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
    for i=0,COMMON_CONSTS.RA_ACTIVE_TASK_TYPE_MAX_NUM do
        self.fetch_reward_list[i] = fetch_reward_flag[32-i]
    end
end

function MidAutumnTaskData:GetCurrentActive()
    return self.active_degree or 0
end

function MidAutumnTaskData:GetDayActiveDegreeInfoList() 
    local current_active =  self:GetCurrentActive()
    local data = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_active_degree_2
    for k,v in pairs(data) do
        local vo= {}  
        vo = TableCopy(v)
        vo.fetch_reward_flag = self.fetch_reward_list[vo.seq] or 0
        vo.sort = 0
        if vo.fetch_reward_flag == 1 then
           vo.sort = 2
        elseif vo.need_active <= current_active then
            vo.sort = 0
        else
            vo.sort = 1
        end
        self.act_data_list[vo.seq+1] = vo
    end
    table.sort(self.act_data_list,SortTools.KeyLowerSorters("sort", "seq"))
    return self.act_data_list 
end

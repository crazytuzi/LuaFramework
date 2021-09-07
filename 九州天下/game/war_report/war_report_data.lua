WarReportData = WarReportData or BaseClass()
WAR_REPORT_TYPE = {
    HONOR_REPORT = 1,               -- 荣誉战报
    NORMAL_REPORT = 2,              -- 前线战报
}
function WarReportData:__init()
    if WarReportData.Instance then
        print_error("[WarReportData] Attemp to create a singleton twice !")
    end
    WarReportData.Instance = self

    self.rank_list = {}             -- 排行榜
    self.honor_report_list = {}     -- 荣耀战报
    self.normal_report_list = {}    -- 前线战报
    self.my_kill_rank = 0           -- 自己排名
    self.my_kill_num = 0            -- 自己杀人数
    self.select_role_id = -1
end

function WarReportData:__delete()
    WarReportData.Instance = nil
end

function WarReportData:SetSCQueryBattleReportHonorList(protocol)
    self.my_kill_rank = protocol.my_kill_rank
    self.my_kill_num = protocol.my_kill_num
    self.honor_report_list = protocol.honor_report_list
end

function WarReportData:SetSCQueryBattleReportNormalList(protocol)
    self.my_kill_rank = protocol.my_kill_rank
    self.my_kill_num = protocol.my_kill_num
    self.normal_report_list = protocol.normal_report_list
end

function WarReportData:SetSCGetRoleCampRankListAck(protocol)
    self.rank_list = protocol.rank_list
end

function WarReportData:GetNonorList()
    return self.honor_report_list or {}
end

function WarReportData:GetNormalList()
    return self.normal_report_list or {}
end

function WarReportData:GetRankList()
    return self.rank_list or {}
end

function WarReportData:GetSelectRoleId()
    return self.select_role_id
end

function WarReportData:SetSelectRoleId(role_id)
    self.select_role_id = role_id
end

function WarReportData:GetHonorCount()
    local count = 0
    for k,v in pairs(self.honor_report_list) do
        if WAR_REPORT_ENUM.BATTLE_REPORT_TYPE_INVALID ~= v.type then
            count = count + 1
        end
    end
    return count
end

function WarReportData:GetNormalCount()
    local count = 0
    for k,v in pairs(self.normal_report_list) do
        if WAR_REPORT_ENUM.BATTLE_REPORT_TYPE_INVALID ~= v.type then
            count = count + 1
        end
    end
    return count
end

function WarReportData:GetMyRankAndNum()
    return self.my_kill_rank, self.my_kill_num
end
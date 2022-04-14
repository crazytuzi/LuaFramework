-- @Author: lwj
-- @Date:   2019-05-09 11:37:33
-- @Last Modified time: 2019-05-09 11:37:37

FPacketModel = FPacketModel or class("FPacketModel", BaseModel)
local FPacketModel = FPacketModel

function FPacketModel:ctor()
    FPacketModel.Instance = self
    self:Reset()
end

function FPacketModel:Reset()
    self.info_list = {}
    self.task_cf = {}
    self.reco_list = {}
    self:SortTaskCf()
    self.task_num = #self.task_cf
    self.is_open_ui_when_reci_data = false
    self.is_update_panel_when_reci_data = false
    self.update_mode = 1        --1：发红包     2：抢红包
    self.cur_update_uid = nil       --当前更新的红包uid
    self.can_rush_list = {}         --当前可以抢的红包
    self.is_first_reque = false     --是否首次登陆

    self.is_show_rd = false         --是否显示红包红点
    self.is_show_once_rd = true     --是否显示中间提示
    self.old_fp_uid_list = {}       --已提醒的红包id
end

function FPacketModel.GetInstance()
    if FPacketModel.Instance == nil then
        FPacketModel()
    end
    return FPacketModel.Instance
end

function FPacketModel:SortTaskCf()
    local cf = Config.db_guild_redenvelope_task
    for i = 1, #cf do
        local sin_cf = cf[i]
        self.task_cf[sin_cf.order] = sin_cf
    end
end

function FPacketModel:IsHavePacket()
    if table.nums(self.info_list) == 0 then
        return true
    else
        return false
    end
end

function FPacketModel:SetInfoList(list)
    --for i, v in pairs(list) do
    --    self.info_list[v.uid] = v
    --end
    self.info_list = {}
    self.info_list = list
end

function FPacketModel:GetInfoList()
    self.can_rush_list = {}
    local list = {}
    local al_send_not_get = {}
    local un_send = {}
    local al_fetch = {}
    local no_rest = {}
    local my_id = RoleInfoModel.GetInstance():GetMainRoleId()
    local info = self.info_list

    self.is_show_rd = false
    for i, v in pairs(info) do
        --自己的红包
        if v.state == enum.RED_ENVELOPE_STATE.RED_ENVELOPE_STATE_NEW then
            if my_id == v.role.id then
                --自己未发
                list[#list + 1] = v
                self.is_show_rd = true
                if not self.old_fp_uid_list[v.uid] then
                    self.old_fp_uid_list[v.uid] = true
                    self.is_show_once_rd = true
                end
            else
                --他人未发
                un_send[#un_send + 1] = v
            end
        elseif v.state == enum.RED_ENVELOPE_STATE.RED_ENVELOPE_STATE_SEND then
            --已发
            local result
            for i = 1, #v.gots do
                if v.gots[i].role.id == my_id then
                    result = v.gots[i]
                    break
                end
            end
            if result then
                --自己已领
                v.is_got = true
                al_fetch[#al_fetch + 1] = v
            else
                self.is_show_rd = true
                if not self.old_fp_uid_list[v.uid] then
                    self.old_fp_uid_list[v.uid] = true
                    self.is_show_once_rd = true
                end
                if v.role.id == my_id then
                    --自己的红包 未领
                    list[#list + 1] = v
                else
                    --他人的红包 未领
                    al_send_not_get[#al_send_not_get + 1] = v
                end
                self.can_rush_list[#self.can_rush_list + 1] = v
            end
        elseif v.state == enum.RED_ENVELOPE_STATE.RED_ENVELOPE_STATE_DONE then
            no_rest[#no_rest + 1] = v
        end
    end
    local function SortFunc(a, b)
        return a.time < b.time
    end
    table.sort(list, SortFunc)
    local function SortFunc(a, b)
        return a.time < b.time
    end
    table.sort(al_send_not_get, SortFunc)
    local function SortFunc(a, b)
        return a.time < b.time
    end
    table.sort(un_send, SortFunc)
    local function SortFunc(a, b)
        return a.time < b.time
    end
    table.sort(al_fetch, SortFunc)
    local function SortFunc(a, b)
        return a.time < b.time
    end
    table.sort(no_rest, SortFunc)
    for i = 1, #al_send_not_get do
        list[#list + 1] = al_send_not_get[i]
    end
    for i = 1, #un_send do
        list[#list + 1] = un_send[i]
    end
    for i = 1, #al_fetch do
        list[#list + 1] = al_fetch[i]
    end
    for i = 1, #no_rest do
        list[#list + 1] = no_rest[i]
    end
    --dump(list, "<color=#6ce19b>GetInfoList   GetInfoList  GetInfoList  GetInfoList</color>")
    return list
end

function FPacketModel:SetRecoList(list)
    self.reco_list = list
end
function FPacketModel:GetRecoList()
    local function sort_fun(a, b)
        return a.time > b.time
    end
    table.sort(self.reco_list, sort_fun)
    return self.reco_list
end

function FPacketModel:UpdateFPGots(data)
    local result = false
    for i, v in pairs(self.info_list) do
        if v.uid == data.uid then
            self.info_list[i] = data
            result = true
            break
        end
    end
    if not result then
        self.info_list[#self.info_list + 1] = data
    end
end

function FPacketModel:GetFPacket(uid)
    for i = 1, #self.info_list do
        if self.info_list[i].uid == uid then
            return self.info_list[i]
        end
    end
end

function FPacketModel:GetRPDataByUid(uid)
    for i, v in pairs(self.info_list) do
        if v.uid == uid then
            return v
        end
    end
end

function FPacketModel:IsCanRush()
    return #self.can_rush_list > 0
end

function FPacketModel:IsShowFPRD()
    return self.is_show_rd
end
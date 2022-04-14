-- @Author: lwj
-- @Date:   2019-02-15 19:30:49
-- @Last Modified time: 2019-02-15 19:31:16

CandyModel = CandyModel or class("CandyModel", BaseBagModel)
local CandyModel = CandyModel

function CandyModel:ctor()
    CandyModel.Instance = self
    self:Reset()
end

function CandyModel:Reset()
    self.is_in_candy_scene = false
    self.cur_rank_mode = 1        --1:前6    --2:前100
    self.chat_rank_list = {}        --糖果屋聊天界面排行
    self.pop_rank_list = {}         --排行榜排行
    self.targetPlayerId = nil
    self.targetPlayerName = nil
    self.cur_sel_gift = nil
    self.record_receive_list = {}
    self.record_give_list = {}
    self.isOpenningRecordPanel = false
    self.isOpenningChatPanel = false
    self.isOpenningPopRank = false
    self.isFiveMinBefo = true               --开启的前五分钟
    self.cur_act_id = nil                   --正在开启的活动id
    self.left_center_info = nil
    self.isOpenningLeftCenter = false
    self.inlineManagerScpButtom = nil
    self.give_gift_count = 0                --送礼次数

    self.per_second = 1 / 60                --骰子cd相关
    self.per_move = self.per_second / 10

    self.is_showing_chat_icon_rd = false
    self.is_showing_record_rd = false
    self.is_open_give_gift = false      --是否打开送礼界面

    self.curSelectTaskItem = nil
end

function CandyModel.GetInstance()
    if CandyModel.Instance == nil then
        CandyModel()
    end
    return CandyModel.Instance
end

function CandyModel:GetActvityTimeTbl()
    local interator = table.pairsByKey(Config.db_activity)
    self.startTime = self.startTime or {}
    self.endTime = self.endTime or {}
    self.act_id_list = self.act_id_list or {}
    for i, v in interator do
        --if v.type == 1 and v.group == 104 and ActivityModel.GetInstance():GetActivity(v.id) then
        if v.group == 104 and ActivityModel.GetInstance():GetActivity(v.id) then
            self.startTime[#self.startTime + 1] = String2Table(v.start_time)
            self.endTime[#self.endTime + 1] = String2Table(v.stop_time)
            self.act_id_list[#self.act_id_list + 1] = v.id
            self.cur_scene_id = v.scene
        end
    end
end

function CandyModel:GetActTime()
    local interator = table.pairsByKey(Config.db_activity)
    local time
    for act_id, cf in interator do
        if cf.type == 1 and cf.group == 104 then
            local tbl = String2Table(cf.time)
            --local start_stamp = TimeManager.GetInstance():GetStampByHMS(tbl[1][1], tbl[1][2], tbl[1][3])
            local end_stamp = TimeManager.GetInstance():GetStampByHMS(tbl[2][1], tbl[2][2], tbl[2][3])
            --time = end_stamp - start_stamp
            time = end_stamp
            break
        end
    end
    return time
end

function CandyModel:SetChatRankList(list)
    --local fixed_list={}
    --fixed_list=self.chat_rank_list
    --if self.chat_rank_list[1] then
    --    self.chat_rank_list[1], self.chat_rank_list[2] = self.chat_rank_list[2], self.chat_rank_list[1]
    --end
    if #self.chat_rank_list == 0 then
        self.chat_rank_list = list
    else
        --list[1], list[2] = list[2], list[1]
        local change_list = {}
        local isSame = true
        for i = 1, #list do
            if type(self.chat_rank_list[i]) == "table" then
                if list[i].id ~= self.chat_rank_list[i].id or list[i].pop ~= self.chat_rank_list[i].pop or list[i].name ~= self.chat_rank_list[i].name or list[i].rank ~= self.chat_rank_list[i].rank then
                    change_list[i] = list[i]
                    self.chat_rank_list[i] = list[i]
                    if isSame then
                        isSame = false
                    end
                end
            else
                change_list[i] = list[i]
                self.chat_rank_list[i] = list[i]
                if isSame then
                    isSame = false
                end
            end
        end
        if not isSame then
            self:Brocast(CandyEvent.UpdateChatRankPanel, change_list)
        end
    end
end

function CandyModel:GetChatRankList()
    local list = {}
    for i = 1, #self.chat_rank_list do
        list[i] = self.chat_rank_list[i]
    end
    return list
end

function CandyModel:SetPopRankList(list)
    self.pop_rank_list = list
end

function CandyModel:GetPopRankList()
    return self.pop_rank_list
end

function CandyModel:GetMyRankData()
    local id = RoleInfoModel.GetInstance():GetMainRoleId()
    local result = nil
    if not self.pop_rank_list then
        CandyController.GetInstance():RequestRankInfo()
    end
    for i, v in pairs(self.pop_rank_list) do
        if v.id == id then
            result = v
            break
        end
    end
    return result
end

function CandyModel:SetRecordListByType(type, list)
    if type == 1 then
        self.record_receive_list = list
    else
        self.record_give_list = list
    end
end

function CandyModel:GetRecordListByType(type)
    local result = {}
    if type == 1 then
        result = self.record_receive_list
    else
        result = self.record_give_list
    end
    return result
end

function CandyModel:SetLeftCenterInfo(info)
    self.left_center_info = info
end

function CandyModel:IsCross()
    return self.left_center_info.activity_id == 10122
end

function CandyModel:GetLeftCenterInfo()
    return self.left_center_info
end

function CandyModel:GetEndTime()
    return self.left_center_info.etime
end

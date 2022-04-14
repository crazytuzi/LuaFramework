-- @Author: lwj
-- @Date:   2019-02-12 16:39:58
-- @Last Modified time: 2019-02-12 16:40:05

WeeklyController = WeeklyController or class("WeeklyController", BaseController)
local WeeklyController = WeeklyController

function WeeklyController:ctor()
    WeeklyController.Instance = self
    self.model = DailyModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function WeeklyController:dctor()
end

function WeeklyController:GetInstance()
    if not WeeklyController.Instance then
        WeeklyController.new()
    end
    return WeeklyController.Instance
end

function WeeklyController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1115_weekly_pb"
    self:RegisterProtocal(proto.WEEKLY_INFO, self.HandleWeekInfo)
    self:RegisterProtocal(proto.WEEKLY_FINISH, self.HandleFetchWeekReward)
    self:RegisterProtocal(proto.WEEKLY_UPDATE, self.HandleWeeklyUpdate)
    self:RegisterProtocal(proto.WEEKLY_REWARD, self.HandleGetWeekActReward)
end

function WeeklyController:AddEvents()
    GlobalEvent:AddListener(DailyEvent.RequestWeeklyInfo, handler(self, self.RequestWeekInfo))
    GlobalEvent:AddListener(DailyEvent.RequestGetWeeklyReward, handler(self, self.RequestGetWeekActReward))
    self.model:AddListener(DailyEvent.RequestGetWeekTaskReward, handler(self, self.RequestFetchWeekReward))
end

-- overwrite
function WeeklyController:GameStart()

end

function WeeklyController:RequestWeekInfo()
    self:WriteMsg(proto.WEEKLY_INFO)
end

function WeeklyController:HandleWeekInfo()
    local data = self:ReadMsg("m_weekly_info_toc")
    dump(data, "HandleWeekInfo   HandleWeekInfo  HandleWeekInfo  HandleWeekInfo")
    self.model:SetWeeklyInfo(data)
end

function WeeklyController:RequestFetchWeekReward(id)
    local pb = self:GetPbObject("m_weekly_finish_tos")
    pb.id = id
    self:WriteMsg(proto.WEEKLY_FINISH, pb)
end

function WeeklyController:HandleFetchWeekReward()
    local data = self:ReadMsg("m_weekly_finish_toc")
    --dump(data, "<color=#6ce19b>HandleFetchWeekReward   HandleFetchWeekReward  HandleFetchWeekReward  HandleFetchWeekReward</color>")
    self.model:AddPWeeklyToList(data)
    GlobalEvent:Brocast(DailyEvent.WeeklyStartMoveStar)
end

function WeeklyController:HandleWeeklyUpdate()
    local data = self:ReadMsg("m_weekly_update_toc")
    dump(data, "HandleWeeklyUpdate   HandleWeeklyUpdate  HandleWeeklyUpdate  HandleWeeklyUpdate")
    self.model:AddPWeeklyToList(data)
    GlobalEvent:Brocast(DailyEvent.UpdateWeeklyItem)
end

function WeeklyController:RequestGetWeekActReward(id)
    local pb = self:GetPbObject("m_weekly_reward_tos")
    pb.id = id
    self:WriteMsg(proto.WEEKLY_REWARD, pb)
end

function WeeklyController:HandleGetWeekActReward()
    local data = self:ReadMsg("m_weekly_reward_toc")
    --dump(data, "<color=#6ce19b>HandleGetWeekActReward   HandleGetWeekActReward  HandleGetWeekActReward  HandleGetWeekActReward</color>")
    self.model:AddWeeklyReward(data.id)
    GlobalEvent:Brocast(DailyEvent.UpdateRewardItem)
end




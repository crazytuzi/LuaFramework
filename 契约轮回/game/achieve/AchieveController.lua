---
--- Created by  Administrator
--- DateTime: 2019/4/1 19:16
---
require('game.achieve.RequireAchieve')
AchieveController = AchieveController or class("AchieveController", BaseController)
local AchieveController = AchieveController

function AchieveController:ctor()
    AchieveController.Instance = self
    self.model = AchieveModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function AchieveController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function AchieveController:GetInstance()
    if not AchieveController.Instance then
        AchieveController.new()
    end
    return AchieveController.Instance
end

function AchieveController:AddEvents()
    GlobalEvent:AddListener(AchieveEvent.OpenAchievePanel, handler(self, self.HandleOpenAchievePanel))
end

function AchieveController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1128_achieve_pb"
    self:RegisterProtocal(proto.ACHIEVE_INFO, self.HandleAchieveInfo)
    self:RegisterProtocal(proto.ACHIEVE_REWARD, self.HandleRewardInfo)

end

-- overwrite
function AchieveController:GameStart()
    local function step()
        self:RequestAchieveInfo()
    end
    GlobalSchedule:StartOnce(step,Constant.GameStartReqLevel.Ordinary)
end

function AchieveController:HandleOpenAchievePanel()
    lua_panelMgr:GetPanelOrCreate(AchievePanel):Open()
end

function AchieveController:RequestAchieveInfo()
    local pb = self:GetPbObject("m_achieve_info_tos")
    self:WriteMsg(proto.ACHIEVE_INFO,pb)
end

function AchieveController:HandleAchieveInfo()
   -- print2("返回信息")
    local data = self:ReadMsg("m_achieve_info_toc")
   -- self.model.achieveList = data.achieves
  --  dump(data)
    self.model:GetChievesTab(data)
    self.model:Brocast(AchieveEvent.AchieveInfo,data)
    self:CheckRedPoint()
   -- dump(self.model.achieveList)
  --  self.model:AddActivity(data)
end

function AchieveController:RequsestReward(id)
 --   print2("领取奖励")
    local pb = self:GetPbObject("m_achieve_reward_tos")
    pb.id = id
    self:WriteMsg(proto.ACHIEVE_REWARD,pb)
end

function AchieveController:HandleRewardInfo()
  --  print2("返回领取奖励")
    local data = self:ReadMsg("m_achieve_reward_toc")
    GlobalEvent:Brocast(AchieveEvent.AchieveReward,data.id)
end

function AchieveController:CheckRedPoint()
    local isRed = false
    for i, v in pairs(self.model.achieveList) do
        if v.state == 1 then
            isRed = true
            break
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot,"achieve",isRed)

    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,21,isRed)

end




---
--- Created by R2D2.
--- DateTime: 2019/1/8 15:03
---

require("game.welfare.RequireWelfare")
WelfareController = WelfareController or class("WelfareController", BaseController)
local WelfareController = WelfareController

function WelfareController:ctor()
    WelfareController.Instance = self
    self.model = WelfareModel:GetInstance()

    self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    self.role_update_list = {}

    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()


end

function WelfareController:dctor()
    GlobalEvent:RemoveTabListener(self.events)

    if self.role_update_list and self.role_data then
        for _, event_id in pairs(self.role_update_list) do
            self.roleData:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end
end

function WelfareController:GetInstance()
    if not WelfareController.Instance then
        WelfareController.new()
    end
    return WelfareController.Instance
end

function WelfareController:AddEvents()
    self.events[#self.events + 1] = GlobalEvent:AddListener(WelfareEvent.Welfare_OpenEvent, handler(self, self.OnOpenWelfarePanel))
    self.events[#self.events + 1] = GlobalEvent:AddListener(DailyEvent.UpdateDailyValue, handler(self, self.OnUpdateDailyValue))
    --self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.CrossDay, handler(self, self.OnCrossDay))
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.CrossDayAfter, handler(self, self.OnCrossDayAfter))

    ---物品变化，用来刷新红点用
    local function call_back()
        self.model:RefreshMainRedPoint()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("money", call_back)
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("level", call_back)
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("power", call_back)
    self.events[#self.events + 1] = GlobalEvent:AddListener(WelfareEvent.Welfare_OnlineLocalCountDownEvent, call_back)
end

function WelfareController:RegisterAllProtocol()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1123_welfare_pb"

    --签到
    self:RegisterProtocal(proto.WELFARE_SIGN, self.HandleSignInfo)
    self:RegisterProtocal(proto.WELFARE_SIGN_REWARD, self.HandleSigned)
    --在线
    self:RegisterProtocal(proto.WELFARE_ONLINE, self.HandleOnlineInfo)
    self:RegisterProtocal(proto.WELFARE_ONLINE_REWARD, self.HandleOnlineReward)
    --等级
    self:RegisterProtocal(proto.WELFARE_LEVEL, self.HandleLevelInfo)
    self:RegisterProtocal(proto.WELFARE_LEVEL_REWARD, self.HandleLevelReward)
    --战力
    self:RegisterProtocal(proto.WELFARE_POWER, self.HandlePowerInfo)
    self:RegisterProtocal(proto.WELFARE_POWER_REWARD, self.HandlePowerReward)
    --公告
    self:RegisterProtocal(proto.WELFARE_NOTICE, self.HandleNoticeInfo)
    self:RegisterProtocal(proto.WELFARE_NOTICE_REWARD, self.HandleNoticeReward)
    --资源下载
    self:RegisterProtocal(proto.WELFARE_RES, self.HandleResInfo)
    self:RegisterProtocal(proto.WELFARE_RES_REWARD, self.HandleResReward)
    --祈福
    self:RegisterProtocal(proto.WELFARE_GRAIL, self.HandleGrailInfo)
    self:RegisterProtocal(proto.WELFARE_GRAIL_REWARD, self.HandleGrailReward)
    --礼品码
    self:RegisterProtocal(proto.WELFARE_GIFTCODE, self.HandleGiftCode)

    self:RegisterProtocal(proto.WELFARE_MISC, self.HandleMiscInfo)
    self:RegisterProtocal(proto.WELFARE_MISC_REWARD, self.HandleMiscRewardInfo)


    --小贵族在线奖励
    self:RegisterProtocal(proto.WELFARE_ONLINE2, self.HandleWelfareOnline2)
    self:RegisterProtocal(proto.WELFARE_ONLINE2_REWARD, self.HandleWelfareOnline2Reward)


end

-- overwrite
function WelfareController:GameStart()
    local function step1()
        self:RequestSignInfo()
        self:RequestOnlineInfo()
        self:RequestLevelInfo()
        self:RequestPowerInfo()
        self:RequestResInfo()
    end
    self.time_id = GlobalSchedule:StartOnce(step1, Constant.GameStartReqLevel.High)

    local function step2()
        local tab = self.model:GetNoticeModel():GetNoticeInfo()
        if tab then
            self:RequestNoticeInfo(tab.id)
        end
        self:RequestGrailInfo()
    end
    self.time_id2 = GlobalSchedule:StartOnce(step2, Constant.GameStartReqLevel.Ordinary)
end

function WelfareController:OnOpenWelfarePanel(id)
    lua_panelMgr:GetPanelOrCreate(WelfarePanel):Open(id)
end

function WelfareController:OnUpdateDailyValue(value)
    self.model:UpdateDailyValue(value)
end

--function WelfareController:OnCrossDay()
--    if AppConfig.GameStart then
--        self:GameStart()
--    end
--end

function WelfareController:OnCrossDayAfter()
    if AppConfig.GameStart then
        self:GameStart()
    end
end

--签到协议
function WelfareController:RequestSignInfo()
    local pb = self:GetPbObject("m_welfare_sign_tos")
    self:WriteMsg(proto.WELFARE_SIGN, pb)
end

function WelfareController:RequestSign()
    local pb = self:GetPbObject("m_welfare_sign_reward_tos")
    self:WriteMsg(proto.WELFARE_SIGN_REWARD, pb)
end

function WelfareController:HandleSignInfo()
    local data = self:ReadMsg("m_welfare_sign_toc")

    --dump(data)
    --data.signs = 28
    --data.max_days = 29
    --data.count = 0
    --data.is_sign = false
    self.model:SetSignData(data)
    self.model:RefreshMainRedPoint()
end

function WelfareController:HandleSigned()
    --print("-----------> 签到返回 ")
    --self.model:OnSigned()
    --GlobalEvent:Brocast(WelfareEvent.Welfare_SignedEvent);
end

--在线时长协议
function WelfareController:RequestOnlineInfo()
    local pb = self:GetPbObject("m_welfare_online_tos")
    self:WriteMsg(proto.WELFARE_ONLINE, pb)
end

function WelfareController:RequestOnlineReward(onlineId)
    local pb = self:GetPbObject("m_welfare_online_reward_tos")
    pb.id = onlineId
    self:WriteMsg(proto.WELFARE_ONLINE_REWARD, pb)
end

function WelfareController:HandleOnlineInfo()
    local data = self:ReadMsg("m_welfare_online_toc")
    self.model:GetOnlineModel():SetInfo(data)
    self.model:RefreshMainRedPoint()
end

function WelfareController:HandleOnlineReward()
    local data = self:ReadMsg("m_welfare_online_reward_toc")
    self.model:GetOnlineModel():OnlineReward(data.id)
    self.model:RefreshMainRedPoint()
    GlobalEvent:Brocast(WelfareEvent.Welfare_OnlineRewardEvent, data.id)
end

--等级协议
function WelfareController:RequestLevelInfo()
    local pb = self:GetPbObject("m_welfare_level_tos")
    self:WriteMsg(proto.WELFARE_LEVEL, pb)
end

function WelfareController:RequestLevelReward(level)
    local pb = self:GetPbObject("m_welfare_level_reward_tos")
    pb.level = level
    self:WriteMsg(proto.WELFARE_LEVEL_REWARD, pb)
end

function WelfareController:HandleLevelInfo()
    local data = self:ReadMsg("m_welfare_level_toc")
    self.model:GetLevelModel():SetInfo(data)
    self.model:RefreshMainRedPoint()
    GlobalEvent:Brocast(WelfareEvent.Welfare_LevelDataEvent)

end

function WelfareController:HandleLevelReward()
    local data = self:ReadMsg("m_welfare_level_reward_toc")
    self.model:GetLevelModel():Reward(data.level)
    self.model:RefreshMainRedPoint()
    GlobalEvent:Brocast(WelfareEvent.Welfare_LevelRewardEvent, data.level)
end

--战力协议
function WelfareController:RequestPowerInfo()
    local pb = self:GetPbObject("m_welfare_power_tos")
    self:WriteMsg(proto.WELFARE_POWER, pb)
end

function WelfareController:RequestPowerReward(power)
    local pb = self:GetPbObject("m_welfare_power_reward_tos")
    pb.power = power
    self:WriteMsg(proto.WELFARE_POWER_REWARD, pb)
end

function WelfareController:HandlePowerInfo()
    local data = self:ReadMsg("m_welfare_power_toc")
    self.model:GetPowerModel():SetInfo(data)
    self.model:RefreshMainRedPoint()
    GlobalEvent:Brocast(WelfareEvent.Welfare_PowerDataEvent)
end

function WelfareController:HandlePowerReward()
    local data = self:ReadMsg("m_welfare_power_reward_toc")
    self.model:GetPowerModel():Reward(data.power)
    self.model:RefreshMainRedPoint()
    GlobalEvent:Brocast(WelfareEvent.Welfare_PowerRewardEvent, data.power)
end

--公告协议
function WelfareController:RequestNoticeInfo(id)
    local pb = self:GetPbObject("m_welfare_notice_tos")
    pb.id = id
    self:WriteMsg(proto.WELFARE_NOTICE, pb)
end

function WelfareController:RequestNoticeReward(id)
    local pb = self:GetPbObject("m_welfare_notice_reward_tos")
    pb.id = id
    self:WriteMsg(proto.WELFARE_NOTICE_REWARD, pb)
end

function WelfareController:HandleNoticeInfo()
    local data = self:ReadMsg("m_welfare_notice_toc")
    if data.is_get then
        self.model:GetNoticeModel():SetInfo(data.id)
        --GlobalEvent:Brocast(WelfareEvent.Welfare_NoticeDataEvent)
    end
end

function WelfareController:HandleNoticeReward()
    local data = self:ReadMsg("m_welfare_notice_reward_tos")
    self.model:GetNoticeModel():SetInfo(data.id)
    GlobalEvent:Brocast(WelfareEvent.Welfare_NoticeRewardEvent)
end

--资源下载
function WelfareController:RequestResInfo()
    local pb = self:GetPbObject("m_welfare_res_tos")
    self:WriteMsg(proto.WELFARE_RES, pb)
end

function WelfareController:RequestResReward()
    local pb = self:GetPbObject("m_welfare_res_reward_tos")
    self:WriteMsg(proto.WELFARE_RES_REWARD, pb)
end

function WelfareController:HandleResInfo()
    local data = self:ReadMsg("m_welfare_res_toc")
    if data.is_get then
        self.model:GetDownloadModel():Reward()
    end
end

function WelfareController:HandleResReward()
    local data = self:ReadMsg("m_welfare_res_reward_toc")
    self.model:GetDownloadModel():Reward()
    GlobalEvent:Brocast(WelfareEvent.Welfare_ResRewardEvent)
end

--祈福
function WelfareController:RequestGrailInfo()
    local pb = self:GetPbObject("m_welfare_grail_tos")
    self:WriteMsg(proto.WELFARE_GRAIL, pb)
end

function WelfareController:RequestGrailReward()
    local pb = self:GetPbObject("m_welfare_grail_reward_tos")
    self:WriteMsg(proto.WELFARE_GRAIL_REWARD, pb)
end

function WelfareController:HandleGrailInfo()
    local data = self:ReadMsg("m_welfare_grail_toc")
    self.model:GetGrailModel().Count = data.count
    self.model:RefreshMainRedPoint()
end

function WelfareController:HandleGrailReward()
    --local data = self:ReadMsg("m_welfare_grail_reward_toc")
    self.model:GetGrailModel():Reward()
    self.model:RefreshMainRedPoint()
    GlobalEvent:Brocast(WelfareEvent.Welfare_GrailRefreshEvent)
end

function WelfareController:ReqeustGiftCode(code)
    local pb = self:GetPbObject("m_welfare_giftcode_tos")
    pb.code = code
    self:WriteMsg(proto.WELFARE_GIFTCODE, pb)
end

function WelfareController:HandleGiftCode()
    GlobalEvent:Brocast(WelfareEvent.Welfare_GiftCodeSuccessEvent)
end



function WelfareController:ReqeustMiscInfo()
    local pb = self:GetPbObject("m_welfare_misc_tos")
   -- logError("请求福利信息")
    self:WriteMsg(proto.WELFARE_MISC, pb)
end

function WelfareController:HandleMiscInfo()
    local data = self:ReadMsg("m_welfare_misc_toc")
    OtherWelfareModel:GetInstance():DealMiscInfo(data)
    OtherWelfareModel:GetInstance():CheckRedPoint()
    logError(Table2String(data))
    GlobalEvent:Brocast(OtherWelfareEvent.MiscInfo,data)
end


function WelfareController:ReqeustMiscRewardInfo(type)
    local pb = self:GetPbObject("m_welfare_misc_reward_tos")
    pb.type = type
    self:WriteMsg(proto.WELFARE_MISC_REWARD, pb)
end


function WelfareController:HandleMiscRewardInfo()
    local data = self:ReadMsg("m_welfare_misc_reward_toc")
    OtherWelfareModel:GetInstance():SetRewardState(data)
    OtherWelfareModel:GetInstance():CheckRedPoint()
    GlobalEvent:Brocast(OtherWelfareEvent.MiscRewardInfo,data)
end

--请求获取小贵族在线奖励信息
function WelfareController:RequestWelfareOnline2(  )
    local pb = self:GetPbObject("m_welfare_online2_tos")
    self:WriteMsg(proto.WELFARE_ONLINE2, pb)
    --logError("请求获取小贵族在线奖励信息")
end

--处理小贵族在线奖励信息返回
function WelfareController:HandleWelfareOnline2(  )
    local data = self:ReadMsg("m_welfare_online2_toc")
    --logError("处理小贵族在线奖励信息返回,data-"..Table2String(data))
    local ids = data.ids  --已领取过的在线奖励
    local online_time = data.online_time  --在线时长（秒）

    VipSmallModel.GetInstance().online_reward = ids
    VipSmallModel.GetInstance().online_time = online_time

    VipSmallModel.GetInstance():Brocast(VipSmallEvent.HandleWelfareOnline2)
    
    local show_icon_reddot = VipSmallModel.GetInstance():IsCanReceiveReward()
	GlobalEvent:Brocast(VipSmallEvent.VipSmallIconReddotChange,show_icon_reddot)
end

--请求领取小贵族在线奖励
function WelfareController:RequestWelfareOnline2Reward(id)
    local pb = self:GetPbObject("m_welfare_online2_reward_tos")
    pb.id = id --奖励表id
    self:WriteMsg(proto.WELFARE_ONLINE2_REWARD, pb)
    --logError("请求领取小贵族在线奖励,id-"..id)
end

--处理小贵族在线奖励领取返回
function WelfareController:HandleWelfareOnline2Reward(  )
    local data = self:ReadMsg("m_welfare_online2_reward_toc")
    --logError("处理小贵族在线奖励领取返回,data-"..Table2String(data))
    local id = data.id --领取完毕的奖励的奖励表id
    table.insert(VipSmallModel.GetInstance().online_reward,id )
    --VipSmallModel.GetInstance().online_reward[id] = id
    VipSmallModel.GetInstance():Brocast(VipSmallEvent.HandleWelfareOnline2Reward,id)

    local show_icon_reddot = VipSmallModel.GetInstance():IsCanReceiveReward()
	GlobalEvent:Brocast(VipSmallEvent.VipSmallIconReddotChange,show_icon_reddot)
end


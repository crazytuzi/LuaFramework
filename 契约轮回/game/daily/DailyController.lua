-- @Author: lwj
-- @Date:   2019-01-15 15:12:33
-- @Last Modified time: 2019-01-15 15:13:08

require("game.daily.RequireDaily")
DailyController = DailyController or class("DailyController", BaseController)
local DailyController = DailyController

function DailyController:ctor()
    DailyController.Instance = self
    self.model = DailyModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function DailyController:dctor()
end

function DailyController:GetInstance()
    if not DailyController.Instance then
        DailyController.new()
    end
    return DailyController.Instance
end

function DailyController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1114_daily_pb"
    self:RegisterProtocal(proto.DAILY_INFO, self.HandleDailyInfo)
    self:RegisterProtocal(proto.DAILY_UPDATE, self.HandeDailyUpdate)
    self:RegisterProtocal(proto.DAILY_REWARD, self.HandleDailyReward)
    self:RegisterProtocal(proto.DAILY_ILLUSION, self.HandleIllutionInfo)
    self:RegisterProtocal(proto.DAILY_ILLUSION_SELECT, self.HandleSelectShow)
    self:RegisterProtocal(proto.DAILY_ILLUSION_SHOW, self.HandleToggleShow)
    self:RegisterProtocal(proto.DAILY_ILLUSION_UPGRADE, self.HandleUpShowLevel)
    self:RegisterProtocal(proto.FINDBACK_INFO, self.HandleRefindInfo)
    self:RegisterProtocal(proto.FINDBACK_FIND, self.HandleRefindback)
    self:RegisterProtocal(proto.FINDBACK_FIND_ALL, self.HandleRefindbackAll)
end

function DailyController:AddEvents()
    local function call_back(index)
        lua_panelMgr:GetPanelOrCreate(DailyPanel):Open(index)
        self.model:Brocast(DailyEvent.RequestIllutionInfo)
    end
    GlobalEvent:AddListener(DailyEvent.OpenDailyPanel, call_back)

    self.model:AddListener(DailyEvent.RequestDailyInfo, handler(self, self.RequestDailyInfo))
    self.model:AddListener(DailyEvent.RequestGetReward, handler(self, self.RequestGetReward))
    self.model:AddListener(DailyEvent.RequestIllutionInfo, handler(self, self.RequestIllutionInfoFun))
    self.model:AddListener(DailyEvent.RequestSelectShow, handler(self, self.RequestSelectShow))
    self.model:AddListener(DailyEvent.RequestSetToggleShow, handler(self, self.RequestToggleShow))
    self.model:AddListener(DailyEvent.RequestUpDailyLevel, handler(self, self.RequestUpShowLevel))

    --资源找回
    self.model:AddListener(DailyEvent.RequestRefindInfo, handler(self, self.RequestRefindInfoList))

    local function call_back()
        self:RequestRefindInfoList()
    end
    GlobalEvent:AddListener(EventName.CrossDayAfter, call_back)

    local function call_back(isRed)
        --主宰神殿红点
        local is_show = self.model:CheckMainIconRDShow(3, isRed)
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "daily", is_show)
        self.model:Brocast(DailyEvent.UpdateGodTempleRD)
    end
    GlobalEvent:AddListener(FactionEvent.Faction_GuildWarRedPointEvent, call_back)
end

function DailyController:GameStart()
    local function step()
        self:RequestDailyInfo()
        self:RequestRefindInfoList()
        self:RequestIllutionInfoFun()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Ordinary)
end

function DailyController:RequestDailyInfo()
    self:WriteMsg(proto.DAILY_INFO)
end

function DailyController:HandleDailyInfo()
    local data = self:ReadMsg("m_daily_info_toc")
    self.model:SetDailyInfo(data)
    self.model.is_game_start = false
    GlobalEvent:Brocast(DailyEvent.UpdateDailyValue, data.total)
    self:CheckDailyRewaRD()
end

function DailyController:HandeDailyUpdate()
    local data = self:ReadMsg("m_daily_update_toc")
    self.model:AddPDailyToList(data)
    self.model:Brocast(DailyEvent.UpdatePanel)
    GlobalEvent:Brocast(DailyEvent.UpdateDailyValue, data.total)
    self:CheckDailyRewaRD()
    self:RequestIllutionInfoFun()
end

function DailyController:RequestGetReward(id)
    local pb = self:GetPbObject("m_daily_reward_tos")
    pb.id = id
    self:WriteMsg(proto.DAILY_REWARD, pb)
end

function DailyController:HandleDailyReward()
    local data = self:ReadMsg("m_daily_reward_toc")
    self.model:AddRewardedToList(data.id)
    self.model:Brocast(DailyEvent.UpdateRewardItem)
    self:CheckDailyRewaRD()
end

----外形
function DailyController:RequestIllutionInfoFun()
    self:WriteMsg(proto.DAILY_ILLUSION)
end

function DailyController:HandleIllutionInfo()
    local data = self:ReadMsg("m_daily_illusion_toc")
    self.model:SetIllutionInfo(data)

    self:CheckIllutionRD()
    if self.model.is_open then
        lua_panelMgr:GetPanelOrCreate(DailyShowPanel):Open()
        self.model.is_open = false
    end
end

function DailyController:RequestToggleShow(flag)
    local pb = self:GetPbObject("m_daily_illusion_show_tos")
    pb.show = flag
    self:WriteMsg(proto.DAILY_ILLUSION_SHOW, pb)
end

function DailyController:HandleToggleShow()
    local data = self:ReadMsg("m_daily_illusion_show_toc")
end

function DailyController:RequestUpShowLevel()
    self:WriteMsg(proto.DAILY_ILLUSION_UPGRADE)
end

function DailyController:HandleUpShowLevel()
    local data = self:ReadMsg("m_daily_illusion_upgrade_toc")
    self.model:ModifeidIllutionInfo(data)
    self.model:Brocast(DailyEvent.HandleShowUpLv)
    self:CheckIllutionRD()
end

--获取找回信息
function DailyController:RequestRefindInfoList()
    local pb = self:GetPbObject("m_findback_info_tos", "pb_1136_findback_pb");
    self:WriteMsg(proto.FINDBACK_INFO);
end

function DailyController:HandleRefindInfo()
    local data = self:ReadMsg("m_findback_info_toc", "pb_1136_findback_pb");
    self.model:SetFindbackInfo(data)

    self:CheckFindbackRedDot()
    self.model:Brocast(DailyEvent.UpdateFindBackPanel)
end

--日常活跃红点
function DailyController:CheckDailyRewaRD()
    --实际的显示状态
    local is_show = self.model:CheckDailyRewardRD()
    self.model.is_show_daily_rewa_rd = is_show
    --第一个标签栏的显示状态
    local is_can_show = self.model:CheckSideOneRDShow(is_show)
    --主界面图标的显示状态
    local show_state = self.model:CheckMainIconRDShow(1, is_can_show)

    self.model:Brocast(DailyEvent.UpdateDailyRD, is_can_show)
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "daily", show_state)
end

--外形红点
function DailyController:CheckIllutionRD()
    local is_show = self.model:CheckIllutionRD()
    self.model.is_show_shape_rd = is_show

    local is_can_show = self.model:CheckSideOneRDShow(is_show, 2)

    local is_show_main = self.model:CheckMainIconRDShow(1, is_can_show)

    self.model:Brocast(DailyEvent.UpdateShapeRD, is_show)
    self.model:Brocast(DailyEvent.UpdateDailyRD, is_can_show)
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "daily", is_show_main)
end

------找回
function DailyController:RequestRefindback(key, type_id, count)
    local pb = self:GetPbObject("m_findback_find_tos", "pb_1136_findback_pb")
    pb.key = key
    pb.type_id = type_id
    pb.count = count
    self:WriteMsg(proto.FINDBACK_FIND, pb);
end

function DailyController:HandleRefindback()
    local data = self:ReadMsg("m_findback_find_toc", "pb_1136_findback_pb");
    Notify.ShowText("Successfully retrieved")
    self:CheckFindbackRedDot()
    self.model:Brocast(DailyEvent.UpdateFindBackInfo)
end

--一键找回
function DailyController:RequestRefindbackAll(type_id, extra)
    local pb = self:GetPbObject("m_findback_find_all_tos", "pb_1136_findback_pb")
    pb.type_id = type_id
    pb.extra = extra
    self:WriteMsg(proto.FINDBACK_FIND_ALL, pb);
end

function DailyController:HandleRefindbackAll()
    local data = self:ReadMsg("m_findback_find_all_toc", "pb_1136_findback_pb");
    Notify.ShowText("Quick retrieval successful")
    self:CheckFindbackRedDot()
    self.model:Brocast(DailyEvent.UpdateFindBackInfo)
end

--检查找回红点
function DailyController:CheckFindbackRedDot()
    local flag = self.model:IsHaveCoinCount()
    local is_show = self.model:CheckMainIconRDShow(2, flag)
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "daily", is_show)
end

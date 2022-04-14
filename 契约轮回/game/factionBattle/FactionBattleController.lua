require("game.factionBattle.RequireFactionBattle")
FactionBattleController = FactionBattleController or class("FactionBattleController", BaseController)
local FactionBattleController = FactionBattleController

function FactionBattleController:ctor()
    FactionBattleController.Instance = self
    self.model = FactionBattleModel:GetInstance()

    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function FactionBattleController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function FactionBattleController:GetInstance()
    if not FactionBattleController.Instance then
        FactionBattleController.new()
    end
    return FactionBattleController.Instance
end

function FactionBattleController:AddEvents()
    self.events[#self.events + 1] = GlobalEvent:AddListener(ActivityEvent.ChangeActivity, handler(self, self.OnChangeActivity))
    local function call_back()
        self:RequestBattleWinner()
    end
    GlobalEvent:AddListener(EventName.CrossDayAfter,call_back)
end

function FactionBattleController:GameStart()
    local function Start_Call()
        self:RequestFieldsInfo()
        self:RequestBattleWinner()
        self:CheckShowTipPanel()
    end

    GlobalSchedule:StartOnce(Start_Call, Constant.GameStartReqLevel.Low)  
end

---活动变化
function FactionBattleController:OnChangeActivity(isOpen, activityId, startTime, endTime)

    local cf = Config.db_activity[activityId]
    if (cf and cf.group == 102) then

        self.model:SetActivityInfo(isOpen, activityId, startTime, endTime)
        self.model:Brocast(FactionBattleEvent.FactionBattle_Model_ActivityChange)
        if isOpen then
            lua_panelMgr:GetPanelOrCreate(FactionBattleTipsPanel):Open()
        end
    end

end

function FactionBattleController:RegisterAllProtocol()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1602_guild_war_pb"

    self:RegisterProtocal(proto.GUILD_WAR_FIELDS, self.HandleFieldsInfo)
    self:RegisterProtocal(proto.GUILD_WAR_BATTLE, self.HandleBattleInfo)
    self:RegisterProtocal(proto.GUILD_WAR_WINNER, self.HandleWinnerInfo)
    self:RegisterProtocal(proto.GUILD_WAR_FETCH, self.HandleMemberAward)
    self:RegisterProtocal(proto.GUILD_WAR_ALLOT, self.HandleAllotAward)
    self:RegisterProtocal(proto.GUILD_WAR_RANKLIST, self.HandleRankList)
end

function FactionBattleController:HandleRankList()
    local data = self:ReadMsg("m_guild_war_ranklist_toc")
    if (data) then
       self.model:SetRankData(data)
       self.model:Brocast(FactionBattleEvent.FactionBattle_Model_RankListEvent)
    end
end

function FactionBattleController:HandleAllotAward()
    local data = self:ReadMsg("m_guild_war_allot_toc")
    if (data and data.type) then
        if  data.type == 1 then
            self.model:AssignedWinAward()
            self.model:Brocast(FactionBattleEvent.FactionBattle_Model_AssignedWinAwardEvent)
        elseif data.type == 2 then
            self.model:AssignedTerminatorAward()
            self.model:Brocast(FactionBattleEvent.FactionBattle_Model_AssignedTerminatorAwardEvent)
        end
    end
end

function FactionBattleController:HandleMemberAward()
    local data = self:ReadMsg("m_guild_war_fetch_toc")
    if (data) then
        self.model:MemberAwardReceived()
    end
end

function FactionBattleController:HandleWinnerInfo()
    local data = self:ReadMsg("m_guild_war_winner_toc")
    if (data) then
        self.model:SetWinnerInfo(data)
        self.model:Brocast(FactionBattleEvent.FactionBattle_Model_BattleWinnerDataEvent)
    end
end

function FactionBattleController:HandleFieldsInfo()
    local data = self:ReadMsg("m_guild_war_fields_toc")
    if (data) then
        self.model:SetFieldInfo(data)
        GlobalEvent:Brocast(FactionBattleEvent.FactionBattle_FieldsDataEvent)
    end
end

function FactionBattleController:HandleBattleInfo()
    local data = self:ReadMsg("m_guild_war_battle_toc")
    if (data) then
        print("<color=#00ff00>------------HandleBattleInfo------------</color>")
        dump(data,"data")
        self.model:SetBattleInfo(data)
        GlobalEvent:Brocast(FactionBattleEvent.FactionBattle_BattleDataEvent)
    end
end

-------------------------请求协议-----------------------
---赛区信息
function FactionBattleController:RequestFieldsInfo()
    local pb = self:GetPbObject("m_guild_war_fields_tos")
    self:WriteMsg(proto.GUILD_WAR_FIELDS, pb)
end

---进入战场
function FactionBattleController:RequestGoBattle()
    SceneControler:GetInstance():RequestSceneChange(30301, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, self.model.ActivityId);
end

---主宰公会信息
function FactionBattleController:RequestBattleWinner()
    local pb = self:GetPbObject("m_guild_war_winner_tos")
    self:WriteMsg(proto.GUILD_WAR_WINNER, pb)
end

---领取主宰公会成员奖励
function FactionBattleController:RequestMemberAward()
    local pb = self:GetPbObject("m_guild_war_fetch_tos")
    self:WriteMsg(proto.GUILD_WAR_FETCH, pb)
end

---分配奖励（1=连胜; 2=击败）
function FactionBattleController:RequestAllotAward(roleId, typeId)
    local pb = self:GetPbObject("m_guild_war_allot_tos")
    pb.role = roleId
    pb.type = typeId
    self:WriteMsg(proto.GUILD_WAR_ALLOT, pb)
end

---请求战场信息
function FactionBattleController:RequestBattleInfo()
    local pb = self:GetPbObject("m_guild_war_battle_tos")
    self:WriteMsg(proto.GUILD_WAR_BATTLE, pb)
end


function FactionBattleController:CheckShowTipPanel()
    local act_id2 = 10201
    local act_id1 = 10203
    local end_act_id = 10204
    local end_actcfg = Config.db_activity[end_act_id]
    local open_days = LoginModel.GetInstance():GetOpenTime()
    local actcfg = Config.db_activity[act_id1]
    local actcfg2 = Config.db_activity[act_id2]
    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    local gname = RoleInfoModel:GetInstance():GetRoleValue("gname")
    if level < actcfg.level or gname == "" then
        return
    end
    local days = String2Table(actcfg.days)
    local timeTab = os.date("*t")
    local wday = timeTab.wday - 1
    wday = (wday == 0 and 7 or wday)
    local now = os.time()
    local end_time = String2Table(end_actcfg.time)[2]
    local endTimeTab = os.date("*t")
    endTimeTab.hour = end_time[1]
    endTimeTab.min = end_time[2]
    endTimeTab.sec = end_time[3]
    end_time = os.time(endTimeTab)

    local show_panel = false
    if table.containValue(days, open_days) then
        show_panel = true
    end
    if open_days >= 8 and not show_panel and wday == tonumber(actcfg2.days) and now < end_time then
        show_panel = true
    end

    if show_panel then
        lua_panelMgr:GetPanelOrCreate(FactionBattleTipsPanel):Open()
    end
end

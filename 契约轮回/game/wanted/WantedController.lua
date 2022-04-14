-- @Author: lwj
-- @Date:   2019-04-28 11:48:49
-- @Last Modified time: 2019-10-18 17:01:39

require("game/wanted/RequireWanted")
WantedController = WantedController or class("WantedController", BaseController)
local WantedController = WantedController

function WantedController:ctor()
    WantedController.Instance = self
    self.model = WantedModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
    self.pop_lv = 1
end

function WantedController:dctor()
    self:RemoveLvBind()
    GlobalSchedule:Stop(self.sche_1)
end

function WantedController:GetInstance()
    if not WantedController.Instance then
        WantedController.new()
    end
    return WantedController.Instance
end

function WantedController:RegisterAllProtocal()
    self.pb_module_name = "pb_1131_wanted_pb"
    self:RegisterProtocal(proto.WANTED_INFO, self.HandleInfo)
    self:RegisterProtocal(proto.WANTED_UPDATE, self.HandleUpdateInfo)
    self:RegisterProtocal(proto.WANTED_REWARD, self.HandleSuccessFetch)
end

function WantedController:AddEvents()
    GlobalEvent:AddListener(WantedEvent.OpenWantedPanel, handler(self, self.RequestInfo))
    GlobalEvent:AddListener(MainEvent.StrongerItemClick, handler(self, self.HandleStrongerItemClick))
    self.model:AddListener(WantedEvent.FetchReward, handler(self, self.RequestFetchReward))
end

-- overwrite
function WantedController:GameStart()
    local function step()
        self:CheckIsBindPopWin()
    end
    self.sche_1 = GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Super)
end

function WantedController:CheckIsBindPopWin()
    local my_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    self.pop_lv = Config.db_sysopen["405@1"].level
    if my_lv < self.pop_lv then
        self:BindLvUpPopWin()
    else
        self.model.is_open_ui = false
        self:RequestInfo()
    end
end

function WantedController:BindLvUpPopWin()
    self.role_update_list = self.role_update_list or {}
    local function call_back()
        local my_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        if my_lv >= self.pop_lv then
            self.model.is_open_ui = false
            self:RequestInfo()
            self:RemoveLvBind()
        end
    end
    self.role_update_list[#self.role_update_list + 1] = GlobalEvent:AddListener(EventName.ChangeLevel, call_back)
end

function WantedController:RemoveLvBind()
    if self.role_update_list then
        for k, event_id in pairs(self.role_update_list) do
            GlobalEvent:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end
end

function WantedController:HandleStrongerItemClick(id)
    if id == 20 then
        self.model.is_show_once = false
        self:CheckIconShow()
    end
end

function WantedController:CheckIconShow()
    local info = self.model:GetInfo()
    local is_show = false
    local is_show_main_icon = false
    local max_task = #Config.db_wanted
    if info.id ~= 0 then
        --最后一个任务，已经领取
        if info.id == max_task and info.state == 3 then
            is_show = false
        elseif info.state == 2 then
            is_show = true
        elseif self.model.is_show_once then
            is_show = true
        else
            is_show = false
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 20, is_show)
    if info.id ~= 0 then
        --最后一个任务，已经领取
        if info.id == max_task and info.state == 3 then
            is_show_main_icon = false
        else
            is_show_main_icon = true
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "wanted", is_show_main_icon)
end

function WantedController:RequestInfo()
    self:WriteMsg(proto.WANTED_INFO)
end

function WantedController:HandleInfo()
    local data = self:ReadMsg("m_wanted_info_toc")
    --dump(data, "<color=#6ce19b>HandleWantedInfo   HandleWantedInfo  HandleWantedInfo  HandleWantedInfo</color>")
    self.model:SetInfo(data.task)
    if self.model.is_open_ui then
        lua_panelMgr:GetPanelOrCreate(WantedPanel):Open()
    else
        self:CheckIconShow()
        self.model.is_open_ui = true
    end
    self:IsShowMainRD()
end

function WantedController:HandleUpdateInfo()
    local data = self:ReadMsg("m_wanted_update_toc")
    --dump(data, "<color=#6ce19b>HandleUpdateInfo   HandleUpdateInfo  HandleUpdateInfo  HandleUpdateInfo</color>")
    self.model:SetInfo(data.task)
    self.model:Brocast(WantedEvent.UpdateWantedPanel)
    self:CheckIconShow()
end

function WantedController:RequestFetchReward()
    self:WriteMsg(proto.WANTED_REWARD)
end

function WantedController:HandleSuccessFetch()
    local data = self:ReadMsg("m_wanted_reward_toc")
    --dump(data, "<color=#6ce19b>HandleSuccessFetch   HandleSuccessFetch  HandleSuccessFetch  HandleSuccessFetch</color>")
    self.model:SetInfo(data.next)
    self.model:Brocast(WantedEvent.UpdateWantedPanel)
    self:CheckIconShow()
    --if data.next.id == #Config.db_wanted then
    --    self.model.is_hide_icon_after_finish = false
    --end
    Notify.ShowText("Claimed")
end

function WantedController:IsShowMainRD()
    if not self.model.is_showing_rd then
        self.model.is_showing_rd = true
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "wanted", true)
    end
end
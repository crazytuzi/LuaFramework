-- @Author: lwj
-- @Date:   2019-04-23 16:41:16
-- @Last Modified time: 2019-10-29 20:17:35

require("game.freeGift.RequireFreeGift")
FreeGiftController = FreeGiftController or class("FreeGiftController", BaseController)
local FreeGiftController = FreeGiftController

function FreeGiftController:ctor()
    FreeGiftController.Instance = self
    self.model = FreeGiftModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function FreeGiftController:dctor()
    if self.game_start_sche then
        GlobalSchedule:Stop(self.game_start_sche)
        self.game_start_sche = nil
    end
    self:StopCheckingRD()
    if self.role_update_list then
        for k, event_id in pairs(self.role_update_list) do
            GlobalEvent:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end
end

function FreeGiftController:GetInstance()
    if not FreeGiftController.Instance then
        FreeGiftController.new()
    end
    return FreeGiftController.Instance
end

function FreeGiftController:RegisterAllProtocal()
    self.pb_module_name = ""
end

function FreeGiftController:AddEvents()
    local function callback()
        self.model.is_open_ui = true
        GlobalEvent:Brocast(OperateEvent.REQUEST_FREE_GIFT_INFO)
    end
    GlobalEvent:AddListener(FreeGiftEvent.OpenFreeGiftPanel, callback)
    GlobalEvent:AddListener(OperateEvent.DILIVER_FREE_GIFT_INFO, handler(self, self.HandleInfo))
    GlobalEvent:AddListener(OperateEvent.DILIVER_FREE_GIFT_REWARD_FETCH, handler(self, self.HandleSuccesFetch))
    local function callback()
        if self.model.is_game_start then
            GlobalEvent:Brocast(OperateEvent.REQUEST_FREE_GIFT_INFO)
        end
    end
    GlobalEvent:AddListener(EventName.CrossDay, callback)

    self.role_update_list = self.role_update_list or {}
    local function callback()
        self:CheckIsShowMainIcon()
    end
    self.role_update_list[#self.role_update_list + 1] = GlobalEvent:AddListener(EventName.ChangeLevel, callback)
end

function FreeGiftController:GameStart()
    self.model.is_game_start = true
    local function callback()
        GlobalEvent:Brocast(OperateEvent.REQUEST_FREE_GIFT_INFO)
    end
    self.game_start_sche = GlobalSchedule:StartOnce(callback, Constant.GameStartReqLevel.Super)
end

function FreeGiftController:HandleInfo(info)
    --dump(info, "<color=#6ce19b>HandleInfo   HandleInfo  HandleInfo  HandleInfo</color>")
    self.model:SetInfoList(info.list)
    self:CheckIsShowMainIcon()
    if self.model.is_open_ui then
        self.model:SetCurDefaultTheme()
        lua_panelMgr:GetPanelOrCreate(FreeGiftPanel):Open()
        self.model.is_open_ui = false
    end
end

function FreeGiftController:CheckIsShowMainIcon()
    if self.model:IsShowIcon() then
    	local etime=self.model:GetLongestEndTime()
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "freeGift", true,nil,etime,nil,false,false,true)
        if not self.model.is_runnging_sch then
            self:StartCheckingRD()
            self.model.is_runnging_sch = true
        end
    else
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "freeGift", false)
        if self.model.is_runnging_sch then
            self:StopCheckingRD()
            self.model.is_runnging_sch = false
        end
    end
end

function FreeGiftController:HandleSuccesFetch(data)
    self.model:ModifyInfoList(data.gift)
    self.model:RemoveRDByActId(data.gift.act_id)
    self.model:Brocast(FreeGiftEvent.UpdateSuccess, self.model.cur_rewa_con, self.model.cur_rebate_con)
    self:CheckIsShowMainIcon()
    self:CheckRD()
end

function FreeGiftController:CheckRD(is_check_level_rewarded)
    local is_show_main = false
    local list = self.model.info_list
    if not list[1] then
        return
    end
    local act_id = list[1].act_id
    for i = 1, #list do
        if i == 1 and (not is_check_level_rewarded) then
            if RoleInfoModel.GetInstance():GetMainRoleLevel() >= 150 and list[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
                is_show_main = true
                act_id = list[i].act_id
                self.model:AddRDByActId(list[i].act_id)
            end
        end
        if list[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
            if os.time() >= list[i].refund_time then
                is_show_main = true
                act_id = list[i].act_id
                self.model:AddRDByActId(list[i].act_id)
            end
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "freeGift", is_show_main)
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 26, is_show_main)
    return is_show_main, act_id
end

function FreeGiftController:StartCheckingRD()
    self:StopCheckingRD()
    self.check_rd_sche = GlobalSchedule.StartFun(handler(self, self.CheckRD), 5, -1)
end

function FreeGiftController:StopCheckingRD()
    if self.check_rd_sche then
        GlobalSchedule:Stop(self.check_rd_sche)
        self.check_rd_sche = nil
    end
end


-- @Author: lwj
-- @Date:   2018-11-29 19:17:11
-- @Last Modified time: 2019-11-06 21:25:25


require("game.vip.RequireVip")

VipController = VipController or class("VipController", BaseController)
local VipController = VipController

function VipController:ctor()
    VipController.Instance = self
    self.model = VipModel.GetInstance()
    self:AddEvent()
    self:RegisterAllProtocal()
end

function VipController:dctor()
    if self.role_update_list then
        for k, event_id in pairs(self.role_update_list) do
            self.role_data:RemoveListener(event_id)
        end
        self.role_update_list = {}
    end
    if self.crossday_delay_sche then
        GlobalSchedule:Stop(self.crossday_delay_sche)
        self.crossday_delay_sche = nil
    end
    if self.delay_update_panel_event_id then
        GlobalSchedule:Stop(self.delay_update_panel_event_id)
        self.delay_update_panel_event_id = nil
    end
end

function VipController:GetInstance()
    if not VipController.Instance then
        VipController.new()
    end
    return VipController.Instance
end

function VipController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1110_vip_pb"
    self:RegisterProtocal(proto.VIP_ACTIVE, self.HandleCardActivate)
    self:RegisterProtocal(proto.VIP_INFO, self.HandleVipInfo)
    self:RegisterProtocal(proto.VIP_FETCH, self.HandleAwardFetch)
    self:RegisterProtocal(proto.VIP_EXP_POOL, self.HandleExpPoolSave)
    self:RegisterProtocal(proto.GAME_PAYINFO, self.HandlePayInfo)
    self:RegisterProtocal(proto.GAME_PAYSUCC, self.HandlePaySucc)
    self:RegisterProtocal(proto.GAME_PAYLIST, self.HandleHavePayList)
    self:RegisterProtocal(proto.VIP_MCARD, self.HandleMCInfo)
    self:RegisterProtocal(proto.VIP_INVEST, self.HandleInvestInfo)
    self:RegisterProtocal(proto.VIP_INVEST_FETCH, self.HandleFetchInvestRewa)
    self:RegisterProtocal(proto.VIP_INVEST_NEXT, self.HandleNextInvest)
    self:RegisterProtocal(proto.VIP_REBATE_FETCH, self.HandleFetchRebate)
    self:RegisterProtocal(proto.VIP_REBATE_INFO, self.HandleRebateInfo)
    self:RegisterProtocal(proto.VIP_TASTE_INFO, self.HandleExperInfo)
    self:RegisterProtocal(proto.GAME_PAYTIMES, self.HandlePayTimes)
    self:RegisterProtocal(proto.VIP_INVEST2, self.HandleInvestInfo2)
end

function VipController:AddEvent()
    local function callback()
        local mainpanel = lua_panelMgr:GetPanelOrCreate(MainUIView)
        local is_show = mainpanel.main_top_left.is_can_show_vfour_btn
        if not is_show then
            return
        end
        lua_panelMgr:GetPanelOrCreate(VipVFourPanel):Open()
    end
    GlobalEvent:AddListener(VipEvent.OpenVFourPanel, callback)

    GlobalEvent:AddListener(VipEvent.OpenVipPanel, handler(self, self.OpenVipPanel))

    local function call_back(flag)
        self.model.isGetExpPool = flag
        self:RequestExpPoolSave()
    end
    GlobalEvent:AddListener(VipEvent.RequestOutDateSaveExp, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(VipTiyanPanel):Open()
    end
    GlobalEvent:AddListener(VipEvent.OpenVipTiyanPanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(VipExpirePanel):Open()
    end
    GlobalEvent:AddListener(VipEvent.OpenVipExpirePanel, call_back)

    local function callback()
        local function step()
            self:RequestVipInfo()
            self:RequestMCInfo()
        end
        self.crossday_delay_sche = GlobalSchedule:StartOnce(step, 60)
    end
    GlobalEvent:AddListener(EventName.CrossDay, callback)

    self.model:AddListener(VipEvent.ActivateVipCard, handler(self, self.RequestActivateCard))
    self.model:AddListener(VipEvent.SetAutoGetExp, handler(self, self.RequestAutoGetExp))
    self.model:AddListener(VipEvent.FetchAward, handler(self, self.RequestVipAward))
    self.model:AddListener(VipEvent.RequestVipInfo, handler(self, self.RequestVipInfo))
    self.model:AddListener(VipEvent.PopToolTips, handler(self, self.PopingNotEnoughTips))
    self.model:AddListener(VipEvent.BuyMC, handler(self, self.RequestBuyMC))
    self.model:AddListener(VipEvent.FetchMCReward, handler(self, self.RequestFetchMCRewrd))
    self.model:AddListener(VipEvent.Invest, handler(self, self.RequestBuyInvest))
    self.model:AddListener(VipEvent.FetchIncestReward, handler(self, self.RequestFetchInvesetReward))

    self.role_update_list = self.role_update_list or {}
    local function call_back()
        self:RequestVipInfo()
    end
    self.role_update_list[#self.role_update_list + 1] = RoleInfoModel.GetInstance():GetMainRoleData():BindData("viplv", call_back)
    local function call_back()
        self:RequestInvestInfo()
        self:RequestInvestInfo2()
    end
    self.role_update_list[#self.role_update_list + 1] = RoleInfoModel.GetInstance():GetMainRoleData():BindData("level", call_back)
end

function VipController:OpenVipPanel(default_tag)
    --打开时 去取得RoleInfoModel(lv,exp,end)
    --有vip时，在Switch请求角色vipInfo
    self:RequestMCInfo()
    lua_panelMgr:GetPanelOrCreate(VipPanel):Open(default_tag)
    local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    self.model.roleData = roleData
end

function VipController:PopingNotEnoughTips(data)
    local typeName = String2Table((Config.db_mall[data.mallId]).price)[1]
    local name = Config.db_item[typeName].name
    local tips = string.format(ConfigLanguage.Shop.BalanceNotEnough, name)
    if typeName ~= 90010003 then
        tips = string.format(ConfigLanguage.Shop.OtherNotEnough, name)
        local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Red), tips)
        Notify.ShowText(str)
    else
        local function callback()
            GlobalEvent:Brocast(VipEvent.CloseVipPanel)
            self:OpenVipPanel(2)
        end
        Dialog.ShowTwo("Tip", tips, "Confirm", callback, nil, "Cancel", nil, nil, nil, false, false);
    end

    --充值跳转

end

-- overwrite
function VipController:GameStart()
    local function step()
        self.model.roleData = RoleInfoModel.GetInstance():GetMainRoleData()
        self:RequestVipInfo()
        self:RequestExpPoolSave()
        self:RequestMCInfo()
        self:RequestInvestInfo()
        self:RequestInvestInfo2()
        self:RequestHavePayList()
        self:CheckVipGiftRD()
        self:RequestRebateInfo()
        self:RequestExperInfo()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Best)
end

--激活Vip卡
function VipController:RequestActivateCard(data)
    local money = RoleInfoModel.GetInstance():GetRoleValue(Constant.GoldType.Gold)
    if money >= tonumber(data.curPrice) then
        local pb = self:GetPbObject("m_vip_active_tos")
        pb.type = tonumber(data.typeId)
        self:WriteMsg(proto.VIP_ACTIVE, pb)
    else
        self:PopingNotEnoughTips(data)
    end
end

function VipController:HandleCardActivate()
    self:RequestVipInfo()
    Notify.ShowText("Activated!")
    self.model:Brocast(VipEvent.CloseRenewPanel)
    local function step()
        self.model:Brocast(VipEvent.SucessActivate)
        self:OpenVipPanel(1)
        local role_data = RoleInfoModel.GetInstance():GetMainRoleData()
        role_data:ChangeData("vipend", role_data.icon)
        self:CheckVipGiftRD()
    end
    self.delay_update_panel_event_id = GlobalSchedule:StartOnce(step, 0.5)
end

--设置自动领取经验
function VipController:RequestAutoGetExp(isCheck)
    local pb = self:GetPbObject("m_vip_auto_fetch_tos")
    pb.is_auto = isCheck
    self:WriteMsg(proto.VIP_AUTO_FETCH, pb)
end

--vip信息
function VipController:RequestVipInfo()
    self:WriteMsg(proto.VIP_INFO)
end

function VipController:HandleVipInfo(isNeed)
    local data = self:ReadMsg("m_vip_info_toc")
    --dump(data, "<color=#6ce19b>HandleVipInfo   HandleVipInfo  HandleVipInfo  HandleVipInfo</color>")
    self.model.vipInfo = data
    self:CheckLevelGift()
    self:CheckVipPanelRD()
end

--领取奖励
function VipController:RequestVipAward(awardType, level)
    local pb = self:GetPbObject("m_vip_fetch_tos")
    pb.type = awardType
    pb.level = level
    self:WriteMsg(proto.VIP_FETCH, pb)
end

function VipController:HandleAwardFetch()
    local data = self:ReadMsg("m_vip_fetch_toc")
    --self:RequestVipInfo()
    if data.type ~= 1 and data.type ~= 4 then
        self.model:Brocast(VipEvent.AlredyGetGift, data)
    end
    if data.type == 4 then
        Notify.ShowText("Claimed")
        GlobalEvent:Brocast(VipEvent.SuccessToGetExpPool)
        self.model.isFirstOpen = true
        self:RequestExpPoolSave()
    end
    --每日经验
    if data.type == 1 then
        --先手动设置数据
        self.model.vipInfo.daily_exp = true
    end
    self:CheckLevelGift()
    self:CheckVipPanelRD()
end

function VipController:RequestExpPoolSave()
    self:WriteMsg(proto.VIP_EXP_POOL)
end

function VipController:HandleExpPoolSave()

    local data = self:ReadMsg("m_vip_exp_pool_toc")
    --dump(data, "<color=#6ce19b>HandleExpPoolSave   HandleExpPoolSave  HandleExpPoolSave  HandleExpPoolSave</color>")
    if not self.model.isFirstOpen then
        local valueStr = tostring(data.exp) .. "/" .. Config.db_role_level[self.model.roleData.level].pool
        local str = ""
        if not self.model.isGetExpPool then
            str = ConfigLanguage.Vip.SequelLogText .. valueStr .. "\n" .. ConfigLanguage.Vip.IsBecomeVip
            local function call_back()
                --OpenLink(180, 1, 2, 1, 2100)
                lua_panelMgr:GetPanelOrCreate(VipRenewPanel):Open()
                --self.model:Brocast(VipEvent.CloseVipPanel)
            end
            Dialog.ShowTwo(ConfigLanguage.Vip.GetDailyExpLogTitle, str, "Confirm", call_back, nil, "Cancel", nil, nil, nil, false, true)
        else
            str = ConfigLanguage.Vip.GetExpPoolText .. valueStr .. "\n" .. ConfigLanguage.Vip.isGetExpPoolAftInDate
            local function call_back()
                self:RequestVipAward(4, self.model.roleData.viplv)
            end
            Dialog.ShowTwo(ConfigLanguage.Vip.GetDailyExpLogTitle, str, "Confirm", call_back, nil, "Cancel", nil, nil, nil, false, true)
        end
    else
        self.model.isFirstOpen = false
    end
    self.model:SetVipExpPool(data.exp)
end

function VipController:CheckLevelGift()
    local cur_lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel()
    if cur_lv == 0 then
        return
    end
    local is_show = false
    for i = 1, cur_lv do
        if not self.model:CheckIsFetchedByLv(i) then
            is_show = true
            break
        end
    end
    if not is_show then
        is_show = not self.model:IsFetchWeek()
    end
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 25, is_show)
end

function VipController:CheckVipPanelRD()
    local is_show_side_rd = false
    local cur_level = RoleInfoModel.GetInstance():GetMainRoleVipLevel()
    if self.model.curLv and self.model.curLv > cur_level then
        is_show_side_rd = false
    else
        if not self.model:IsOutOfDate() and RoleInfoModel.GetInstance():GetRoleValue("viptype") ~= enum.VIP_TYPE.VIP_TYPE_TASTE then
            local is_show_exp_btn_rd = false
            local info = self.model.vipInfo
            if not info.auto_fetch and not info.daily_exp then
                is_show_side_rd = true
                is_show_exp_btn_rd = true
            end
            local cur_lv = RoleInfoModel.GetInstance():GetRoleValue("viplv")
            local is_show_gift_rd = false
            for i = 1, cur_lv do
                local is_fetch = self.model:CheckIsFetchedByLv(i)
                if not is_fetch then
                    is_show_gift_rd = true
                    is_show_side_rd = true
                    break
                end
            end
            if not is_show_gift_rd then
                if not self.model:IsFetchWeek() then
                    is_show_side_rd = true
                    is_show_gift_rd = true
                end
            end
            self.model.is_show_gift_rd = is_show_gift_rd
            self.model:Brocast(VipEvent.UpdateDailyExpGetRD, is_show_exp_btn_rd)
            self.model:Brocast(VipEvent.UpdateGiftBtnRD, is_show_gift_rd)
        end
    end
    if is_show_side_rd then
        self.model:AddSideRD(1)
    else
        self.model:RemoveSideRD(1)
    end
    local is_hide_main_rd = self.model:IsCanHideMainIconRD()
    --小于六十级 显示红点时
    if (not is_hide_main_rd) and RoleInfoModel.GetInstance():GetMainRoleLevel() < 60 then
        is_hide_main_rd = true
    end
    GlobalEvent:Brocast(VipEvent.ShowMainVipRD, not is_hide_main_rd)
    local is_can_show_vip_stronger = self.model:GetSideRD(1)
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 25, is_can_show_vip_stronger)
    self.model:Brocast(VipEvent.UpdateVipSideRD)
end

---充值
--请求
function VipController:RequestPayInfo(goods_id)
    local pb = self:GetPbObject("m_game_payinfo_tos", "pb_1000_game_pb")
    pb.goods_id = goods_id
    self:WriteMsg(proto.GAME_PAYINFO, pb)
end

--返回 
function VipController:HandlePayInfo()
    local data = self:ReadMsg("m_game_payinfo_toc", "pb_1000_game_pb")
    DebugLog('--LaoY VipController.lua,line 323--', Table2String(data))
    GlobalEvent:Brocast(EventName.REQ_PAYINFO, data)
end

--返回  充值成功
function VipController:HandlePaySucc()
    local data = self:ReadMsg("m_game_paysucc_toc", "pb_1000_game_pb")

    local buy_data = PlatformManager:GetInstance():GetBuyData(data.app_order)
    DebugLog("=========HandlePaySucc==================", buy_data)
    if buy_data then
        TDManager:GetInstance():OnChargeRequest(data.sdk_order, buy_data.productName, buy_data.realPayMoney / 100, "CNY", buy_data.diamand_num, "")
        TDManager:GetInstance():OnChargeSuccess(data.sdk_order)
    end

    SevenDayActiveModel:GetInstance():Brocast(SevenDayActiveEvent.PaySucc)
    GlobalEvent:Brocast(EventName.PaySucc, data)
    self:RequestHavePayList()
    self:RequestPayTimes()    
    VipSmallController.GetInstance():RequestVip2Info()
    --logError("充值成功返回")
end

--已经冲过的列表
function VipController:RequestHavePayList()
    local pb = self:GetPbObject("m_game_paylist_tos", "pb_1000_game_pb")
    self:WriteMsg(proto.GAME_PAYLIST, pb)
end

function VipController:HandleHavePayList()
    local data = self:ReadMsg("m_game_paylist_toc", "pb_1000_game_pb")
    self.model.have_pay_list = data.paid
    self.model:Brocast(VipEvent.HandlePaidList)
end

----月卡
function VipController:RequestMCInfo()
    self:WriteMsg(proto.VIP_MCARD)
end

function VipController:HandleMCInfo()
    local data = self:ReadMsg("m_vip_mcard_toc")
    self.model:SetMCInfo(data)
    if self.model:IsBuyMC() or self.model.is_buy_when_begin then
        self:CheckMCRD()
        self.model.is_buy_when_begin = true
        self.model.is_first_rd = false
    elseif self.model.is_first_rd then
        self.model.is_first_rd = false
        self:CheckShowRDOnece()
    end
    self.model:Brocast(VipEvent.UpdateMCPanel)
    if self.model.is_buying then
        self.model.is_buying = false
        Notify.ShowText("Purchased")
    elseif self.model.is_fetching_mc_rewa then
        self.model.is_fetching_mc_rewa = false
        Notify.ShowText("Claimed")
    end
    --dump(data, "<color=#6ce19b>HandleMCInfo   HandleMCInfo  HandleMCInfo  HandleMCInfo</color>")
end

function VipController:RequestBuyMC()
    self:WriteMsg(proto.VIP_MCARD_BUY)
end

function VipController:RequestFetchMCRewrd(day)
    local pb = self:GetPbObject("m_vip_mcard_fetch_tos")
    pb.day = day
    self:WriteMsg(proto.VIP_MCARD_FETCH, pb)
end

function VipController:CheckShowRDOnece()
    self.model.is_show_mc_once = true
    if RoleInfoModel.GetInstance():GetMainRoleLevel() >= 60 then
        GlobalEvent:Brocast(VipEvent.ShowMainVipRD, true)
    end
    self.model:AddSideRD(4)
end

function VipController:CheckMCRD()
    self.model:GetMCCanFetchList()
    local is_can_fetch = self.model:IsCanFetchMC()
    if is_can_fetch then
        self.model:AddSideRD(4)
    else
        self.model:RemoveSideRD(4)
    end
    local is_hide_main_rd = self.model:IsCanHideMainIconRD()
    if (not is_hide_main_rd) and RoleInfoModel.GetInstance():GetMainRoleLevel() < 60 then
        GlobalEvent:Brocast(VipEvent.ShowMainVipRD, not is_hide_main_rd)
    end
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 37, is_can_fetch)
    self.model:Brocast(VipEvent.UpdateVipSideRD)
end

----------投资计划
function VipController:RequestInvestInfo()
    self:WriteMsg(proto.VIP_INVEST)
end

function VipController:HandleInvestInfo()
    local data = self:ReadMsg("m_vip_invest_toc")
    --dump(data, "<color=#6ce19b>Hand leInvestInfo   HandleInvestInfo  HandleInvestInfo  HandleInvestInfo</color>")
    --logError("投资信息返回处理")
    --logError(Table2String(data))
    self.model:SetInvesInfo(data)
    self:CheckInvesRD()
    self.model:Brocast(VipEvent.UpdateInvesetPanel, self.model.cur_sel_grade)
    --self.model:Brocast(VipEvent.HandleInvestInfo2, data.type,data.grade,data.list)

end

function VipController:RequestInvestInfo2()

    local type = 3
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    if lv >= 371 then
        type = 4
    end
    local pb = self:GetPbObject("m_vip_invest2_tos")
    pb.type = type
    self:WriteMsg(proto.VIP_INVEST2,pb)
end

function VipController:HandleInvestInfo2()
    local data = self:ReadMsg("m_vip_invest2_toc")
   
    --logError("投资信息2返回处理")
    --logError(Table2String(data))

    self.model:Brocast(VipEvent.HandleInvestInfo2, data.type,data.grade,data.list)

end

function VipController:HandleNextInvest()
    local data = self:ReadMsg("m_vip_invest_next_toc")
    self.model.is_show_rd_after_close = true
end

function VipController:CheckInvesRD()
    local is_show_stronger = false
    if self.model:IsInvested() and (not self.model.is_show_rd_after_close) then
        --已投资
        local grade = self.model:GetInvestGrade()
        local list = self.model:GetInverstCFByGrade(grade)
        local result = false
        local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        for i = 1, #list do
            local data = list[i]
            local info = self.model:GetInvestRewaInfoById(data.id)
            if info then
                if info.state == 1 then
                    result = true
                    break
                end
            else
                --等级是否达到，是否可领取
                if cur_lv >= data.level then
                    result = true
                end
                break
            end
        end
        if result then
            self:ShowOutSideRD()
            self.model:Brocast(VipEvent.UpdateVipSideRD)
            is_show_stronger = true
        else
            self.model:RemoveSideRD(4)
            self.model:Brocast(VipEvent.UpdateVipSideRD)
            if self.model:IsCanHideMainIconRD() then
                GlobalEvent:Brocast(VipEvent.ShowMainVipRD, false)
            end
        end
    else
        if not self.model.is_had_invesrd_showed then
            self.model.is_show_rd_after_close = false
            self:ShowOutSideRD()
            if RoleInfoModel.GetInstance():GetMainRoleLevel() >= 60 then
                GlobalEvent:Brocast(VipEvent.ShowMainVipRD, true)
            end
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 38, is_show_stronger)
end

function VipController:ShowOutSideRD()
    if RoleInfoModel.GetInstance():GetMainRoleLevel() >= 60 then
        GlobalEvent:Brocast(VipEvent.ShowMainVipRD, true)
    end
    self.model:AddSideRD(5)
end

function VipController:RequestBuyInvest()
    local pb = self:GetPbObject("m_vip_invest_buy_tos")
    pb.grade = self.model.cur_sel_grade
    pb.type = self.model:GetInvestType()
    self:WriteMsg(proto.VIP_INVEST_BUY, pb)
end

function VipController:RequestFetchInvesetReward(id,type)
    local pb = self:GetPbObject("m_vip_invest_fetch_tos")
    pb.id = id
    pb.type = type or self.model:GetInvestType()
    self:WriteMsg(proto.VIP_INVEST_FETCH, pb)
end

function VipController:HandleFetchInvestRewa()
    local data = self:ReadMsg("m_vip_invest_fetch_toc")
    --dump(data, "<color=#6ce19b>HandleFetchInvestRewa   HandleFetchInvestRewa  HandleFetchInvestRewa  HandleFetchInvestRewa</color>")
    self.model:UpdateInveRewaInfo(data.item)
    Notify.ShowText("Claimed")
    self.model:Brocast(VipEvent.SuccessFetchInveRewa,data.item)
    self:CheckInvesRD()
end

---Vip礼包
function VipController:CheckVipGiftRD()
    local is_show = false
    if self.model:CheckIsShowGiftFirstRD() then
        is_show = true
    end
    if is_show then
        self.model:AddSideRD(3)
    else
        self.model:RemoveSideRD(3)
    end
    if is_show then
        self.model.is_showed_first_rd = true
    end
    local is_hide_main_rd = self.model:IsCanHideMainIconRD()
    if (not is_hide_main_rd) and RoleInfoModel.GetInstance():GetMainRoleLevel() < 60 then
        GlobalEvent:Brocast(VipEvent.ShowMainVipRD, not is_hide_main_rd)
    end
    self.model:Brocast(VipEvent.UpdateVipSideRD)
end


--Vip4返利
function VipController:RequestRebateInfo()
    self:WriteMsg(proto.VIP_REBATE_INFO)
end

function VipController:HandleRebateInfo()
    local data = self:ReadMsg("m_vip_rebate_info_toc")
    self.model.rebate_info = data
end

function VipController:RequestFetchRebate()
    self:WriteMsg(proto.VIP_REBATE_FETCH)
end

function VipController:HandleFetchRebate()
    local data = self:ReadMsg("m_vip_rebate_fetch_toc")
    self.model.rebate_info.time = 0
    self.model.rebate_info.fetch = true
    GlobalEvent:Brocast(VipEvent.SuccessFetchRebate)
    local is_can_fetch = self.model:IsCanFetchRebate()
    GlobalEvent:Brocast(VipEvent.ChangeVFourRD, is_can_fetch)
end

--体验过期
function VipController:RequestExperInfo()
    self:WriteMsg(proto.VIP_TASTE_INFO)
end

function VipController:HandleExperInfo()
    local data = self:ReadMsg("m_vip_taste_info_toc")
    self.model.taste_stime = data.stime
    self.model.taste_etime = data.etime
end

---请求已充值次数
function VipController:RequestPayTimes()
    local pb = self:GetPbObject("m_game_paytimes_tos", "pb_1000_game_pb")
    self:WriteMsg(proto.GAME_PAYTIMES, pb)
end

--处理已充值次数返回
function VipController:HandlePayTimes()
    local data = self:ReadMsg("m_game_paytimes_toc", "pb_1000_game_pb")
    local times = data.times
    --logError(Table2String(times))
    self.model:Brocast(VipEvent.HandlePayTimes,times)
end
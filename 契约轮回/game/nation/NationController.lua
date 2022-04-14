-- @Author: lwj
-- @Date:   2019-09-04 16:53:27 
-- @Last Modified time: 2019-10-22 16:33:27

require("game.nation.RequireNation")
NationController = NationController or class("NationController", BaseController)
local NationController = NationController

function NationController:ctor()
    NationController.Instance = self
    self.model = NationModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function NationController:dctor()
    if self.crossday_delay_sche then
        GlobalSchedule:Stop(self.crossday_delay_sche)
        self.crossday_delay_sche = nil
    end
    for i, v in pairs(self.global_event) do
        GlobalEvent:RemoveListener(v)
    end
    self.global_event = {}
end

function NationController:GetInstance()
    if not NationController.Instance then
        NationController.new()
    end
    return NationController.Instance
end

function NationController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = ""
    -- self:RegisterProtocal(35025, self.RequestLoginVerify)
end

function NationController:AddEvents()
    self.global_event = {}
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, handler(self, self.HandleYYInfo))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(NationEvent.OpenNationPanel, handler(self, self.HandleOpenNationPanel))
    local function callback()
        --检查红点
        local data = {}
        data.act_id = OperateModel.GetInstance():GetActIdByType(401)
        if data.act_id ~= 0 then
            self:CheckNaitonRD(data)
            self.model:Brocast(NationEvent.CheckExchangeItemRest, data)
        end
        --检查是否够锤子它的蛋
        local data = {}
        data.act_id = OperateModel.GetInstance():GetActIdByType(406)
        if data.act_id ~= 0 then
            self:CheckNaitonRD(data)
        end
        --烟花
        local data = {}
        data.act_id = OperateModel.GetInstance():GetActIdByType(730)
        if data.act_id ~= 0 then
            self:CheckNaitonRD(data)
        end
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, callback)
    --self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(BagEvent.AddItems, callback)
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandleSuceesFetch))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.DILIVER_LOTTERY_INFO, handler(self, self.HandleCrackEggInfo))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_CRACK_EGG, handler(self, self.HandleSucessCrackEgg))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.HANDLE_REFRESH_EGG, handler(self, self.HandleRefreshEggPool))
    local function callback()
        local function step()
            local list = self.model.act_id_list
            for i, v in pairs(list) do
                local id = OperateModel.GetInstance():GetActIdByType(v)
                if id ~= 0 then
                    GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO, id)
                    local end_time = OperateModel.GetInstance():GetActEndTimeByActId(id)
                    self.model:SetEndTimeByActId(id, end_time)
                end
            end

            local list = self.model.illact_id_list
            for i, v in pairs(list) do
                local id = OperateModel.GetInstance():GetActIdByType(v)
                if id ~= 0 then
                    GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO, id)
                    local end_time = OperateModel.GetInstance():GetActEndTimeByActId(id)
                    self.model:SetEndTimeByActId(id, end_time)
                end
            end

            local id = OperateModel.GetInstance():GetActIdByType(406)
            local id2 = OperateModel.GetInstance():GetActIdByType(745)
            if id == 0 and id2 == 0 then
                return
            end
            GlobalEvent:Brocast(OperateEvent.REQUEST_LOTTERY_INFO, id)
        end
        self.crossday_delay_sche = GlobalSchedule:StartOnce(step, 2)
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(EventName.CrossDay, callback)
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.ACT_START, callback)

    --烟火
    local function callback(id, data)
        local self_id = OperateModel.GetInstance():GetActIdByType(730)
        if self_id == 0 then
            return
        end
        if id ~= self_id then
            return
        end
        local panel = lua_panelMgr:GetPanel(FirworksResultPanel)
        if not panel then
            panel = lua_panelMgr:GetPanelOrCreate(FirworksResultPanel)
            panel:Open(data)
        end
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_FIRE, callback)

    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.DILIVER_SHOP_INFO, handler(self, self.HandleShopInfo))

    --打开扭蛋机界面
    local function call_back(  )
        local panel = lua_panelMgr:GetPanelOrCreate(EggMachinePanel)
        panel:Open()

        local data = {}
        panel:SetData(data)
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(NationEvent.OpenEggMachinePanel,call_back)
end

-- overwrite
function NationController:GameStart()
    local function step()
        local id = OperateModel.GetInstance():GetActIdByType(406)
        if id ~= 0 then
            GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO, id)
            GlobalEvent:Brocast(OperateEvent.REQUEST_LOTTERY_INFO, id)
        end

        local id = OperateModel.GetInstance():GetActIdByType(730)
        if id ~= 0 then
            local data = {}
            data.act_id = id
            self:CheckNaitonRD(data)
        end
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.VLow)
end

function NationController:HandleOpenNationPanel(act_type)
    local list = self.model.act_id_list
    for i, v in pairs(list) do
        local id = OperateModel.GetInstance():GetActIdByType(v)
        if id ~= 0 then
            GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO, id)
            local end_time = OperateModel.GetInstance():GetActEndTimeByActId(id)
            self.model:SetEndTimeByActId(id, end_time)
        end
    end
    local is_have_act_open = false
    for i, v in pairs(list) do
        local act_id = OperateModel.GetInstance():GetActIdByType(v)
        if not self.model:IsActOutDate(act_id) then
            is_have_act_open = true
            break
        end
    end
    if not is_have_act_open then
        Notify.ShowText(ConfigLanguage.Nation.ActivityIsOver)
        return
    end
    self.model.is_open_panel = true
    local act_id = OperateModel.GetInstance():GetActIdByType(act_type)
    if not self.model:IsActOutDate(act_id) then
        self.model.default_sel_menu = act_id
        self.model:Brocast(NationEvent.UpdatePageShow, act_id)
    else
        local list = self.model:GetNationThemeList()
        if list and (not table.isempty(list)) then
            self.model.default_sel_menu = list[1].id
        end
    end
    if act_id == 0 then
        return
    end
    GlobalEvent:Brocast(OperateEvent.REQUEST_LOTTERY_INFO, act_id)
end

function NationController:HandleYYInfo(data)
    self:HandleIllInfo(data)
    if not self.model:IsSelfAct(data.id) then
        return
    end
    self.model:SetActInfo(data)
    --dump(data, "<color=#6ce19b>OpenHighController   OpenHighController  OpenHighController  OpenHighController</color>")
    if self.model.is_open_panel then
        self.model.is_open_panel = false
        lua_panelMgr:GetPanelOrCreate(NationPanel):Open()
    else
        self.model:Brocast(NationEvent.UpdateTaskPro)
    end
    self.model:Brocast(NationEvent.UpdateRewardInfo)
    data.act_id = data.id
    self:CheckNaitonRD(data)
end

function NationController:HandleIllInfo(data)
    if data.id == 174200 or data.id == 174201 then
        self.model:SetActIllInfo(data)
        self:CheckIllRD(data)
        GlobalEvent:Brocast(NationEvent.UpdateRewardInfo)
    end
    if data.id == 174300 then
        self:CheckIllRD(data)
    end
end

function NationController:CheckIllRD(data)
    local is_show = false
    if self.model.is_red then
        is_show = true
    else
        for i, v in pairs(data.tasks) do
            if v.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                self.model.is_red = true
                is_show = true
                break
            end
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "cardcele", is_show)
end

function NationController:CheckNaitonRD(data)
    local is_show_rd
    if self.model:IsActOutDate(data.act_id) then
        self.model.side_rd_list[data.act_id] = false
    else
        --道具兑换
        if data.act_id == OperateModel.GetInstance():GetActIdByType(401) then
            is_show_rd = self.model:CheckExchangeRD()
            self.model.side_rd_list[OperateModel.GetInstance():GetActIdByType(401)] = is_show_rd

            --狂嗨
        elseif data.act_id == OperateModel.GetInstance():GetActIdByType(403) then
            is_show_rd = self.model:CheckRDNormal(OperateModel.GetInstance():GetActIdByType(403))
            self.model.side_rd_list[OperateModel.GetInstance():GetActIdByType(403)] = is_show_rd

            --砸蛋
        elseif data.act_id == OperateModel.GetInstance():GetActIdByType(406) then
            is_show_rd = self.model:CheckCrackEggRD()
            self.model.side_rd_list[OperateModel.GetInstance():GetActIdByType(406)] = is_show_rd

            --连充成就
        elseif data.act_id == OperateModel.GetInstance():GetActIdByType(404) then
            self.model.is_show_achi_rd = self.model:CheckRDNormal(OperateModel.GetInstance():GetActIdByType(404))
            --缓存实际的对应活动的红点显示情况
            is_show_rd = self.model.is_show_achi_rd

            if (not self.model.is_show_achi_rd) and self.model.side_rd_list[OperateModel.GetInstance():GetActIdByType(405)] then
                is_show_rd = true
            end
            self.model.side_rd_list[OperateModel.GetInstance():GetActIdByType(404)] = is_show_rd

            --连充每日
        elseif data.act_id == OperateModel.GetInstance():GetActIdByType(405) then
            is_show_rd = self.model:CheckRDNormal(OperateModel.GetInstance():GetActIdByType(405))
            --先保存实际每日连充的红点情况
            self.model.side_rd_list[OperateModel.GetInstance():GetActIdByType(405)] = is_show_rd

            local is_other_show_rd = self.model.is_show_achi_rd
            if (not is_show_rd) and is_other_show_rd then
                is_show_rd = true
            end
            self.model.side_rd_list[OperateModel.GetInstance():GetActIdByType(404)] = is_show_rd

        elseif data.act_id == OperateModel.GetInstance():GetActIdByType(407) then
            local id = OperateModel.GetInstance():GetActIdByType(407)
            is_show_rd = self.model:CheckRDNormal(id)
            self.model.side_rd_list[id] = is_show_rd

            --烟花
        elseif data.act_id == OperateModel.GetInstance():GetActIdByType(730) then
            is_show_rd = self.model:CheckHanabiRD()
            self.model.side_rd_list[data.act_id] = is_show_rd

            --跨服云购
        elseif data.act_id == OperateModel.GetInstance():GetActIdByType(780) then

        end
    end
    self.model:Brocast(NationEvent.UpdateMenuRD)
    if not is_show_rd and (not self.model:IsCanHide()) then
        return
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "nation", is_show_rd)
end

function NationController:HandleSuceesFetch(data)
    if data.act_id == OperateModel.GetInstance():GetActIdByType(401) then
        Notify.ShowText('has been exchanged')
    end
    if data.act_id == 174201 then
        Notify.ShowText('Claimed')
    end
    self:CheckNaitonRD(data)
end

---------------砸蛋
function NationController:HandleCrackEggInfo(act_id, data)
    if act_id ~= OperateModel.GetInstance():GetActIdByType(406) then
        return
    end
    --dump(data, "<color=#6ce19b>HandleCrackEggInfo   HandleCrackEggInfo  HandleCrackEggInfo  HandleCrackEggInfo</color>")
    self.model:SetEggCrackInfo(data)
    data.act_id = act_id
    self:CheckNaitonRD(data)
end

function NationController:HandleSucessCrackEgg(act_id, data)
    if act_id ~= OperateModel.GetInstance():GetActIdByType(406) then
        return
    end
    --dump(data, "<color=#6ce19b>HandleSucessCrackEgg   HandleSucessCrackEgg  HandleSucessCrackEgg  HandleSucessCrackEgg</color>")
    self.model:SetSingleEggInfo(data)
    self.model:Brocast(NationEvent.SuccessCrackEgg, data)
end

function NationController:HandleRefreshEggPool(act_id, data)
    if act_id ~= OperateModel.GetInstance():GetActIdByType(406) then
        return
    end
    self.model:SetRefreshEggInfo(data)
    self.model:Brocast(NationEvent.RefreshEggPool, data)
    Notify.ShowText(ConfigLanguage.Nation.RefreshSuccess)
end

---跨服云购
function NationController:HandleShopInfo(id, info)
    if id ~= OperateModel.GetInstance():GetActIdByType(780) then
        return
    end
    --dump(info, "<color=#6ce19b>HandleShopInfo   HandleShopInfo  HandleShopInfo  HandleShopInfo</color>")
    local new_info = clone(info)
    self.model.shop_info = new_info
    local list = self.model:DealShopItemList(info.act_id, info.list)
    info.list = list
    self.model:Brocast(NationEvent.HandleShopInfo, info)
end
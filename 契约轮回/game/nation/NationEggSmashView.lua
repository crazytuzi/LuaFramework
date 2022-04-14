-- @Author: lwj
-- @Date:   2019-09-24 11:08:41 
-- @Last Modified time: 2019-09-24 11:08:44

NationEggSmashView = NationEggSmashView or class("NationEggSmashView", BaseItem)
local NationEggSmashView = NationEggSmashView

function NationEggSmashView:ctor()
    self.abName = "nation"
    self.assetName = "NationEggSmashView"
    self.layer = "UI"

    self.top_item_list = {}
    self.reco_item_list = {}
    self.model_event = {}
    self.global_event = {}

    self.model = NationModel.GetInstance()
    self.single_reco_height = 47
    self.start_y = 0
    self.is_init_icon_show = false
    self.time = 0.5
    self.is_reco_scolling = true
    self.delay_scroll_time = 5
    self.is_first_load_reco = true
    self.single_move_duration = 0.1       --移动到顶点的时间
    self.is_playing_anim = false            --是否正在播放砸蛋动画

    BaseItem.Load(self)
end

function NationEggSmashView:dctor()
    if self.CDT then
        self.CDT:destroy()
        self.CDT = nil
    end
    if self.delay_scroll_schdule then
        GlobalSchedule:Stop(self.delay_scroll_schdule)
        self.delay_scroll_schdule = nil
    end
    if self.all_crack_red_dot then
        self.all_crack_red_dot:destroy()
        self.all_crack_red_dot = nil
    end
    if self.free_crack_red_dot then
        self.free_crack_red_dot:destroy()
        self.free_crack_red_dot = nil
    end
    if not table.isempty(self.addup_item_list) then
        for i, v in pairs(self.addup_item_list) do
            if v then
                v:destroy()
            end
        end
        self.addup_item_list = {}
    end
    if not table.isempty(self.reco_item_list) then
        for i, v in pairs(self.reco_item_list) do
            if v then
                v:destroy()
            end
        end
        self.reco_item_list = {}
    end
    for i, v in pairs(self.global_event) do
        GlobalEvent:RemoveListener(v)
    end
    self.global_event = {}
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}
    for i, v in pairs(self.top_item_list) do
        if v then
            v:destroy()
        end
    end
    self.top_item_list = {}
    for i, v in pairs(self.egg_item_list) do
        if v then
            v:destroy()
        end
    end
    self.egg_item_list = {}
end

function NationEggSmashView:LoadCallBack()
    GlobalEvent:Brocast(OperateEvent.REQUEST_YY_LOG, OperateModel.GetInstance():GetActIdByType(406))
    self.nodes = {
        "Top/TopScroll/Viewport/top_con", "Middle/egg_con/NationEggItem", "Top/remain", "Top/icon",
        "Middle/normal/btn_refresh/refresh_free", "Middle/normal/btn_refresh/refresh_cost_con/refresh_cost", "Middle/normal/btn_refresh",
        "Middle/normal/btn_refresh/refresh_cost_con/refresh_icon", "Middle/normal/btn_refresh/refresh_cost_con",
        "Middle/normal/btn_crack/con/crack_free", "Middle/normal/btn_crack/con/crack_one_icon",
        "Middle/normal/btn_crack_all/crack_all_text", "Middle/normal/btn_crack_all/crack_all_icon", "Middle/normal/btn_crack_all",
        "Middle/normal", "Middle/btn_force_refresh", "Middle/normal/btn_crack",
        "Right/RecoScroll/Viewport/reco_con", "Right/RecoScroll",
        "Right/rewa_con/NationEggRewaItem", "Right/rewa_con", "Right/daily_count",
        "Right/RecoScroll/Viewport/reco_con/NationEggRecoItem", "Middle/normal/free_crack_red_con",
        "Top/tip_icon", "Middle/normal/btn_crack_all/crack_all_red_con", "Top/time_con",
    }
    self:GetChildren(self.nodes)
    self.egg_obj = self.NationEggItem.gameObject
    self.top_icon = GetImage(self.icon)
    self.remain = GetText(self.remain)
    self.refresh_cost_text = GetText(self.refresh_cost)
    self.refresh_icon_img = GetImage(self.refresh_icon)
    self.crack_one_txt = GetText(self.crack_free)
    self.crack_one_icon = GetImage(self.crack_one_icon)
    self.crack_all_text = GetText(self.crack_all_text)
    self.crack_all_icon = GetImage(self.crack_all_icon)
    self.reco_obj = self.NationEggRecoItem.gameObject
    self.rewa_obj = self.NationEggRewaItem.gameObject
    self.daily_count = GetText(self.daily_count)
    self.reco_con_rect = GetRectTransform(self.reco_con)

    self:AddEvent()
    self.theme_cf = self.model:GetThemeCfById()
    self:InitPanel()

    local cost_id = self.cost_tbl[1]
    GoodIconUtil.GetInstance():CreateIcon(self, self.top_icon, cost_id, true)
    GoodIconUtil.GetInstance():CreateIcon(self, self.crack_one_icon, self.cost_tbl[1], true)
    GoodIconUtil.GetInstance():CreateIcon(self, self.crack_all_icon, self.cost_tbl[1], true)

    self:LoadAddUpItem()
    self:UpdateAddUpCount()

    local time = TimeManager.GetInstance():GetZeroTime(os.time() + TimeManager.GetInstance().DaySec)
    local param = {}
    param.isShowSec = true
    param.isShowMin = true
    param.isShowHour = true
    param.formatText = "Event time left: %s"
    self.CDT = CountDownText(self.time_con, param)
    local function call_back()
        Notify.ShowText("Egg Smash is over")
        self.model:Brocast(NationEvent.CloseNationPanel)
        SetVisible(self.CDT, false)
    end
    self.CDT:StartSechudle(time, call_back)
    SetVisible(self.btn_refresh, false)
end

function NationEggSmashView:AddEvent()
    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.SuccessCrackEgg, handler(self, self.HandleSuccessCrack))
    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.RefreshEggPool, handler(self, self.InitPanel))
    local function callback()
        self:UpdateTopRemainShow()
        self:UpdateBtns()
    end
    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.CheckExchangeItemRest, callback)

    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.UPDATE_YY_LOG, handler(self, self.HandleSingleRecoUpdate))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.DELIVER_YY_LOG, handler(self, self.HandleEggLog))

    local function callback()
        if self.is_playing_anim then
            return
        end
        local cost_id = self.cost_tbl[1]
        local cost_num = self.cost_tbl[2]
        local is_can, _, have_num = self:IsEnoughToCrackOne()
        if is_can then
            self:CrackEgg()
        else
            --弹窗消费钻石提示
            local item_name = Config.db_item[cost_id].name
            local lack_num = cost_num - have_num
            local price = Config.db_voucher[cost_id].price * lack_num
            if not RoleInfoModel.GetInstance():CheckGold(price, Config.db_voucher[cost_id].type) then
                return
            end
            local message = string.format(ConfigLanguage.Nation.HammerNotEnough, item_name, price, item_name, lack_num)
            if self.model.is_check then
                self:CrackEgg()
            else
                local function ok_fun(is_check)
                    self.model.is_check = is_check
                    self:CrackEgg()
                end
                Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false)
            end
        end
    end
    AddButtonEvent(self.btn_crack.gameObject, callback)

    AddButtonEvent(self.btn_force_refresh.gameObject, handler(self, self.RequestRefreshEgg))
    AddButtonEvent(self.btn_refresh.gameObject, handler(self, self.RequestRefreshEgg))

    -----全砸
    local function callback()
        if self.is_playing_anim then
            return
        end
        local cost_id = self.cost_tbl[1]
        local is_can, cost_num, have_num = self:IsEnoughToCrackAll()
        if is_can then
            self:CrackAll()
        else
            --弹窗消费钻石提示
            local item_name = Config.db_item[cost_id].name
            local remain_crack_count = self.model:GetCanCrackNum()
            cost_num = self.cost_tbl[2] * remain_crack_count
            local lack_num = cost_num - have_num
            local price = Config.db_voucher[cost_id].price * lack_num
            if not RoleInfoModel.GetInstance():CheckGold(price, Config.db_voucher[cost_id].type) then
                return
            end
            local message = string.format(ConfigLanguage.Nation.HammerNotEnough, item_name, price, item_name, lack_num)
            if self.model.is_check then
                self:CrackAll()
            else
                local function ok_fun(is_check)
                    self.model.is_check = is_check
                    self:CrackAll()
                end
                Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false)
            end
        end
    end
    AddButtonEvent(self.btn_crack_all.gameObject, callback)

    local function callback()
        lua_panelMgr:GetPanelOrCreate(ProbaTipPanel):Open(11)
    end
    AddButtonEvent(self.tip_icon.gameObject, callback)


    --拖拽记录
    local function begin_call()
        if #self.reco_item_list > 3 and (self.is_reco_scolling) then
            self:StopRecoMove()
            self:ResetRecoCon()
        end
    end
    AddDragBeginEvent(self.RecoScroll.gameObject, begin_call)

    local function end_call()
        if #self.reco_item_list > 3 and (self.is_reco_scolling) then
            self:RestartRecoMove()
            self:GetDisAndAdjustPos()
        end
    end
    AddDragEndEvent(self.RecoScroll.gameObject, end_call)
end

function NationEggSmashView:InitPanel()
    --这里取得cost_id
    self:UpdateTopRemainShow()
    if table.isempty(self.top_item_list) then
        self:LoadTopReward()
    end
    self:LoadEgg()

    --这里结束初始化消耗图标
    self:UpdateBtns()
end

function NationEggSmashView:LoadTopReward()
    local theme_cf = self.model:GetThemeCfById(OperateModel.GetInstance():GetActIdByType(406))
    local tbl = String2Table(theme_cf.sundries)
    local list = {}
    local w_lv = RoleInfoModel.GetInstance().world_level
    for i = 1, #tbl do
        local data = tbl[i]
        if data[1] == "show" then
            local lv_list = data[2]
            if w_lv >= lv_list[1] and w_lv <= lv_list[2] then
                list = data[3]
            end
        end
    end
    self.top_item_list = self.top_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.top_item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.top_con)
            self.top_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local item_id = list[i]
        local param = {}
        local operate_param = {}
        param["item_id"] = item_id
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 70, y = 70 }
        param.bind = 2
        --local color = Config.db_item[id].color - 1
        --param["color_effect"] = color
        --param["effect_type"] = 2  --活动特效：2
        item:SetIcon(param)
    end
    for i = len + 1, #self.top_item_list do
        local item = self.top_item_list[i]
        item:SetVisible(false)
    end
end

function NationEggSmashView:LoadEgg()
    local egg_info = self.model:GetEggCrackInfo()
    local list = egg_info.items
    self.egg_item_list = self.egg_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.egg_item_list[i]
        if not item then
            item = NationEggItem(self.egg_obj, self.egg_con)
            self.egg_item_list[i] = item
        else
            item:SetVisible(true)
        end
        list[i].pos = i
        item:SetData(list[i])
    end
    for i = len + 1, #self.egg_item_list do
        local item = self.egg_item_list[i]
        item:SetVisible(false)
    end
end

function NationEggSmashView:UpdateTopRemainShow()
    local cf = self.model:GetThemeCfById(OperateModel.GetInstance():GetActIdByType(406))
    self.req_tbl = String2Table(cf.reqs)
    for _, tbl in pairs(self.req_tbl) do
        if tbl[1] == "cost" then
            self.cost_tbl = tbl[2][1]
            break
        end
    end
    local cost_id = self.cost_tbl[1]
    self.model.cost_tbl = self.cost_tbl
    local remain = BagModel.GetInstance():GetItemNumByItemID(cost_id)
    self.remain.text = remain
end

function NationEggSmashView:UpdateBtns()
    local egg_info = self.model:GetEggCrackInfo()
    local remain_refresh = egg_info.free_refresh
    local remain_crack = egg_info.free_crack
    local uncrack_pos = self.model:GetHaventCrackedPos()
    SetVisible(self.normal, uncrack_pos)
    SetVisible(self.btn_force_refresh, not uncrack_pos)
    if uncrack_pos then
        --刷新
        self.is_free_refresh = remain_refresh > 0
        SetVisible(self.refresh_free, self.is_free_refresh)
        SetVisible(self.refresh_cost_con, not self.is_free_refresh)
        if not self.is_free_refresh then
            local refresh_cost = {}
            for _, tbl in pairs(self.req_tbl) do
                if tbl[1] == "refresh" then
                    refresh_cost = tbl[2][1]
                    break
                end
            end
            GoodIconUtil.GetInstance():CreateIcon(self, self.refresh_icon_img, refresh_cost[1], true)
            self.refresh_cost_text.text = refresh_cost[2]
        end
        --免费砸蛋
        local is_show_free_crack_rd = false
        if remain_crack > 0 then
            is_show_free_crack_rd = true
        end
        --文字显示
        local str = string.format(ConfigLanguage.Nation.CostShow, self.cost_tbl[2])
        if is_show_free_crack_rd then
            str = ConfigLanguage.Nation.Free
        end
        self.crack_one_txt.text = string.format(ConfigLanguage.Nation.CrackOneTxt, str)

        --全砸
        local remain_crack_count = self.model:GetCanCrackNum()
        self.all_cost = self.cost_tbl[2] * remain_crack_count
        self.crack_all_text.text = string.format(ConfigLanguage.Nation.CostShow, self.all_cost)

        --红点检查
        self:CheckBtnsRD(is_show_free_crack_rd)
    end
end

function NationEggSmashView:CrackEgg()
    local pos = self.model:GetHaventCrackedPos()
    local egg = self.egg_item_list[pos]
    if not egg then
        Notify.ShowText("No egg is available for smash")
        return
    end
    egg:PlayCrackAnimate()
    self.is_playing_anim = true
    local function call_back()
        self.is_playing_anim = false
    end
    --self.crack_one_schedule = GlobalSchedule:StartOnce(call_back, self.time + 0.3)
    GlobalSchedule:StartOnce(call_back, self.time + 1)
end

function NationEggSmashView:CrackAll()
    for i = 1, #self.egg_item_list do
        local item = self.egg_item_list[i]
        if item and item.data.reward_id == 0 then
            item:PlayCrackAnimate(true)
        end
    end
    self.is_playing_anim = true
    local function call_back()
        GlobalEvent:Brocast(OperateEvent.REQUEST_CRACK_EGG, OperateModel.GetInstance():GetActIdByType(406), 0)
    end
    GlobalSchedule:StartOnce(call_back, self.time + 0.3)
    local function call_back()
        self.is_playing_anim = false
    end
    GlobalSchedule:StartOnce(call_back, self.time + 1)
end

function NationEggSmashView:HandleSuccessCrack()
    self:UpdateBtns()
    self:UpdateAddUpCount()
    self.model:Brocast(NationEvent.UpdateEggRewaShow)
end

function NationEggSmashView:RequestRefreshEgg()
    if self.is_playing_anim then
        return
    end
    local info = self.model:GetEggCrackInfo()
    local remian_times = info.free_refresh
    if remian_times > 0 then
        --有免费刷新次数
        GlobalEvent:Brocast(OperateEvent.REQUEST_REFRESH_EGG, OperateModel.GetInstance():GetActIdByType(406))
    else
        local refresh_cost = {}
        for _, tbl in pairs(self.req_tbl) do
            if tbl[1] == "refresh" then
                refresh_cost = tbl[2][1]
                break
            end
        end
        if RoleInfoModel.GetInstance():CheckGold(refresh_cost[2], refresh_cost[1]) then
            GlobalEvent:Brocast(OperateEvent.REQUEST_REFRESH_EGG, OperateModel.GetInstance():GetActIdByType(406))
        end
    end
end

-----记录
function NationEggSmashView:HandleEggLog(act_id, data)
    if act_id ~= OperateModel.GetInstance():GetActIdByType(406) then
        return
    end
    self.model.egg_reco_info = data
    self:LoadReco()
    local con_len = self.single_reco_height * #self.reco_item_list
    SetSizeDelta(self.reco_con_rect, self.reco_con_rect.sizeDelta.x, con_len)
    if #self.reco_item_list > 3 and self.is_first_load_reco then
        local function step()
            self.model:Brocast(NationEvent.StartMoveReco)
            self.is_first_load_reco = false
        end
        GlobalSchedule:StartOnce(step, 1)
    end
end

function NationEggSmashView:LoadReco()
    local is_can_operate = #self.reco_item_list > 3 and (self.is_reco_scolling)
    if is_can_operate then
        self:StopRecoMove()
    end
    local list = self.model.egg_reco_info
    self.reco_item_list = self.reco_item_list or {}
    local len = #list
    local cur_start_y = self.start_y
    for i = 1, len do
        local item = self.reco_item_list[i]
        if not item then
            item = NationEggRecoItem(self.reco_obj, self.reco_con)
            self.reco_item_list[i] = item
        else
            item:SetVisible(true)
        end
        list[i].idx = i
        item:SetData(list[i], self.single_reco_height, cur_start_y, len)
        cur_start_y = cur_start_y - self.single_reco_height
    end
    for i = len + 1, #self.reco_item_list do
        local item = self.reco_item_list[i]
        item:SetVisible(false)
    end
    if is_can_operate then
        self:ResetRecoCon()
        self:RestartRecoMove(1)
        self:GetDisAndAdjustPos()
    end
end

--取得出于最上面的记录的位置
function NationEggSmashView:GetMostTopRecoChild()
    local temp_y
    for _, item in pairs(self.reco_item_list) do
        local child_y = item:GetYPos()
        if (not temp_y) or child_y > temp_y then
            temp_y = child_y
        end
    end
    return temp_y
end

function NationEggSmashView:AdjustRecoPos(offset)
    if table.isempty(self.reco_item_list) then
        return
    end
    for _, item in pairs(self.reco_item_list) do
        item:AdjustPos(offset)
    end
end

function NationEggSmashView:HandleSingleRecoUpdate(act_id, p_log)
    if act_id ~= OperateModel.GetInstance():GetActIdByType(406) then
        return
    end
    self.model:SetSingleReco(p_log)
    self:LoadReco()
end

function NationEggSmashView:StopRecoMove()
    if not table.isempty(self.reco_item_list) then
        for _, item in pairs(self.reco_item_list) do
            item:StopMove()
        end
    end
end

function NationEggSmashView:ResetRecoCon()
    local item_count = #self.reco_item_list
    local con_len = item_count * self.single_reco_height
    SetSizeDelta(self.reco_con_rect, self.reco_con_rect.sizeDelta.x, con_len)
end

--重新开始移动记录
function NationEggSmashView:RestartRecoMove(delay_time)
    local time = delay_time or self.delay_scroll_time
    if self.delay_scroll_schdule then
        GlobalSchedule:Stop(self.delay_scroll_schdule)
        self.delay_scroll_schdule = nil
    end
    local function step()
        self.model:Brocast(NationEvent.StartMoveReco)
        self.is_reco_scolling = true
    end
    self.delay_scroll_schdule = GlobalSchedule:StartOnce(step, time)
end

--调整位置
function NationEggSmashView:GetDisAndAdjustPos()
    local top_child_y = self:GetMostTopRecoChild()
    if not top_child_y then
        return
    end
    local top_item_pos = Vector2(0, top_child_y)
    local target_pos = Vector2(0, 0)
    local offset = Vector2.Distance(top_item_pos, target_pos)
    if top_child_y > 0 then
        offset = -offset
    end
    self:AdjustRecoPos(offset)
    self.is_reco_scolling = false
end

-------累计
function NationEggSmashView:LoadAddUpItem()
    local list = self.model:GetRewaCfByActId(OperateModel.GetInstance():GetActIdByType(406))
    self.addup_item_list = self.addup_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.addup_item_list[i]
        if not item then
            item = NationEggRewaItem(self.rewa_obj, self.rewa_con)
            self.addup_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.addup_item_list do
        local item = self.addup_item_list[i]
        item:SetVisible(false)
    end
end

function NationEggSmashView:UpdateAddUpCount()
    local info = self.model:GetEggCrackInfo()
    if not info.crack then
        return
    end
    self.daily_count.text = string.format(ConfigLanguage.Nation.DailyAddUpCountText, info.crack)
end

function NationEggSmashView:SetFreeCrackRedDot(isShow)
    if not self.free_crack_red_dot then
        self.free_crack_red_dot = RedDot(self.free_crack_red_con, nil, RedDot.RedDotType.Nor)
    end
    self.free_crack_red_dot:SetPosition(0, 0)
    self.free_crack_red_dot:SetRedDotParam(isShow)
end

function NationEggSmashView:SetAllCrackRD(isShow)
    if not self.all_crack_red_dot then
        self.all_crack_red_dot = RedDot(self.crack_all_red_con, nil, RedDot.RedDotType.Nor)
    end
    self.all_crack_red_dot:SetPosition(0, 0)
    self.all_crack_red_dot:SetRedDotParam(isShow)
end

function NationEggSmashView:IsEnoughToCrackOne()
    local cost_tbl = self.model.cost_tbl
    local cost_id = cost_tbl[1]
    local cost_num = cost_tbl[2]
    local is_can_crack = false
    local info = self.model:GetEggCrackInfo()
    local have_num = BagModel.GetInstance():GetItemNumByItemID(cost_id, cost_num)
    local is_have_enough_hammer = have_num >= cost_num
    if info.free_crack > 0 then
        is_can_crack = true
    elseif is_have_enough_hammer then
        is_can_crack = true
    end
    return is_can_crack, is_have_enough_hammer, have_num
end

function NationEggSmashView:IsEnoughToCrackAll()
    local is_enough = false
    local cost_tbl = self.model.cost_tbl
    local cost_id = cost_tbl[1]
    local remain_count = self.model:GetCanCrackNum()
    local cost_num = cost_tbl[2] * remain_count
    local have_num = BagModel.GetInstance():GetItemNumByItemID(cost_id)
    if self.model:IsHaveFreeCrack() then
        have_num = have_num + 1
    end
    if have_num >= cost_num then
        is_enough = true
    end
    return is_enough, cost_num, have_num
end

function NationEggSmashView:CheckBtnsRD(is_show_free_crack_rd)
    if not is_show_free_crack_rd then
        local _, is_enough_to_crack_one = self:IsEnoughToCrackOne()
        is_show_free_crack_rd = is_enough_to_crack_one
    end
    self:SetFreeCrackRedDot(is_show_free_crack_rd)
    self:SetAllCrackRD(self:IsEnoughToCrackAll())
end

function NationEggSmashView:ComboAction(action1, action2)
    if action1 and action2 then
        return cc.Sequence(action1, action2)
    elseif not action1 then
        return action2
    elseif not action2 then
        return action1
    end
end

--over write
function NationEggSmashView:OnEnable()

    for k,v in pairs(self.addup_item_list) do
        v:RegistEvent()
    end
end

--over write
function NationEggSmashView:OnDisable()

    for k,v in pairs(self.addup_item_list) do
        v:UnregistEvent()
    end
end
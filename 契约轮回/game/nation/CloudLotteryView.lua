-- @Author: lwj
-- @Date:   2019-12-20 11:13:59 
-- @Last Modified time: 2019-12-20 11:14:02
--SearchTreasureModel:GetYYLotteryRewards(act_id)
CloudLotteryView = CloudLotteryView or class("CloudLotteryView", BaseItem)
local CloudLotteryView = CloudLotteryView

function CloudLotteryView:ctor(parent_node, layer)
    self.abName = "nation"
    self.assetName = "CloudLotteryView"
    self.layer = layer

    self.act_id = OperateModel.GetInstance():GetActIdByType(780)
    self.openData = OperateModel:GetInstance():GetAct(self.act_id)
    self.cf = OperateModel.GetInstance():GetConfig(self.act_id)
    self.rewa_tbl = self.cf and String2Table(self.cf.reward) or {}
    self.req_tbl = self.cf and String2Table(self.cf.reqs) or {}
    self.model = NationModel.GetInstance()
    self.model:SortShopList()
    self.reco_list = {}
    self.tog_list = {}
    self.group = {}
    self:GetReqList()
    self.is_need_init_shop = false

    self.global_event = {}
    self.model_event = {}
    CloudLotteryView.super.Load(self)
end

function CloudLotteryView:dctor()
    if self.RecoStencilMask then
        destroy(self.RecoStencilMask)
        self.RecoStencilMask = nil
    end
    if self.success_buy_event_id then
        GlobalEvent:RemoveListener(self.success_buy_event_id)
        self.success_buy_event_id = nil
    end
    destroySingle(self.CDT)
    if self.item_list then
        destroyTab(self.item_list, true)
    end
    self.model.cur_buy_times = 1
    self.model.lot_shop_type = 1
    self.model.defa_top_idx = 1
    destroyTab(self.grade_item_list, true)
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
    if self.ItemStencilMask then
        destroy(self.ItemStencilMask)
        self.ItemStencilMask = nil
    end
    destroyTab(self.rewa_item_list, true)
    if not table.isempty(self.model_event) then
        for i, v in pairs(self.model_event) do
            self.model:RemoveListener(v)
        end
        self.model_event = {}
    end
    for i = 1, #self.tog_list do
        if self.tog_list[i] then
            self.tog_list[i]:destroy()
            self.tog_list[i] = nil
        end
    end
    self.tog_list = {}
    destroySingle(self.scrollView)
    if not table.isempty(self.global_event) then
        for i, v in pairs(self.global_event) do
            GlobalEvent:RemoveListener(v)
        end
        self.global_event = {}
    end
end

function CloudLotteryView:GetReqList()
    if not self.req_tbl then
        return
    end
    for _, value in pairs(self.req_tbl) do
        if value[1] == "cost" then
            self.group = value[2] or {}
            break
        end
    end
end

function CloudLotteryView:LoadCallBack()
    self.nodes = {
        "recoScroll/recoView",
        "recoScroll/recoView/reco_con", "Tog_Group/CloudTopItem", "Tog_Group",
        "recoScroll", "rewaScoll/rewa_viewp/rewa_con", "rewaScoll/rewa_viewp",
        "tog_con", "tog_con/CloudLotTogItem", "time_con/countdowntext", "time_con",
        "time_head", "btn_que", "btn_reco",
        "item_scroll/item_viewp", "item_scroll/item_viewp/item_con", "item_scroll/item_viewp/item_con/CloudLotItem",
    }
    self:GetChildren(self.nodes)
    self:SetMask()
    self:SetItemMask()
    self.reco_scroll_rext = GetRectTransform(self.recoScroll)
    self.tog_obj = self.CloudTopItem.gameObject
    self.grade_obj = self.CloudLotTogItem.gameObject
    self.item_obj = self.CloudLotItem.gameObject
    self.countdt = GetText(self.countdowntext)
    self.time_head = GetText(self.time_head)

    self.reco_con_rect = GetRectTransform(self.reco_con)
    SetSizeDelta(self.reco_con_rect, 345.2, 0)

    self:AddEvent()
    GlobalEvent:Brocast(OperateEvent.REQUEST_SHOP_INFO, self.act_id)
    self:InitPanel()
    self:SetRecoMask()
end

function CloudLotteryView:SetRecoMask()
    self.RecoStencilId = GetFreeStencilId()
    self.RecoStencilMask = AddRectMask3D(self.recoView.gameObject)
    self.RecoStencilMask.id = self.RecoStencilId
end

function CloudLotteryView:AddEvent()
    local function callback()
        lua_panelMgr:GetPanelOrCreate(CloudShopRewardPanel):Open(self.act_id)
    end
    AddButtonEvent(self.btn_reco.gameObject, callback)

    local function callback()
        ShowHelpTip(HelpConfig.nation.CloundShopDesc, true)
    end
    AddButtonEvent(self.btn_que.gameObject, callback)

    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.CloundTogClick, handler(self, self.HandleTogClick))
    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.HandleShopInfo, handler(self, self.InitShopPart))
    self.success_buy_event_id = GlobalEvent:AddListener(OperateEvent.DILIVER_BUY_RESULT, handler(self, self.HandleBuyResult))
end

function CloudLotteryView:CreateScroll(data)
    self.reco_list = {}
    self.reco_list = self.model:DealShopRecoList(data)
    local len = #self.reco_list
    if self.scrollView then
        self.scrollView:OnDestroy()
        self.scrollView = nil
    end
    local param = {}
    local cellSize = { width = 346, height = 47.05 }  --列表项宽高
    param["scrollViewTra"] = self.reco_scroll_rext
    param["cellParent"] = self.reco_con
    param["cellSize"] = cellSize
    param["cellClass"] = CloundLotRecoItem
    param["begPos"] = Vector2(0, 0)
    param["spanX"] = 0
    param["spanY"] = 0
    param["createCellCB"] = handler(self, self.SetItemData)
    param["updateCellCB"] = handler(self, self.SetItemData)
    param["cellCount"] = len
    self.scrollView = ScrollViewUtil.CreateItems(param)
end

function CloudLotteryView:SetItemData(itemCls)
    local index = itemCls.__item_index
    local info = self.reco_list[index]
    itemCls:SetData(info)
end

function CloudLotteryView:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.rewa_viewp.gameObject)
    self.StencilMask.id = self.StencilId
end

function CloudLotteryView:SetItemMask()
    self.ItemStencilId = GetFreeStencilId()
    self.ItemStencilMask = AddRectMask3D(self.item_viewp.gameObject)
    self.ItemStencilMask.id = self.ItemStencilId
end

function CloudLotteryView:InitPanel()
    self:LoadTogItem()
end

function CloudLotteryView:LoadTogItem()
    for i = 1, #self.tog_list do
        if self.tog_list[i] then
            self.tog_list[i]:destroy()
            self.tog_list[i] = nil
        end
    end
    self.tog_list = {}
    for i = 1, 2 do
        local item = CloudTopItem(self.tog_obj, self.Tog_Group)
        self.tog_list[i] = item
        item:SetData(i)
    end
end

function CloudLotteryView:HandleTogClick(idx, is_click, cost)
    self.model.lot_shop_type = idx
    self:LoadRewa(idx)
    self:LoadGrade(idx)
    if is_click then
        local list = self.model:DealShopItemList(self.act_id, self.model.shop_info.list)
        self:LoadItem(list)
    end
end

function CloudLotteryView:LoadRewa(idx)
    local list = self.rewa_tbl[idx][2]
    if not list then
        return
    end
    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.rewa_con)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local rewa_data = list[i]
        local param = {}
        local operate_param = {}
        param["item_id"] = rewa_data[1]
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 59, y = 59 }
        param["num"] = rewa_data[2]
        param.bind = rewa_data[3]
        local color = Config.db_item[rewa_data[1]].color - 1
        param["color_effect"] = color
        param["effect_type"] = 2  --活动特效：2
        param["stencil_id"] = self.StencilId
        param["stencil_type"] = 3
        item:SetIcon(param)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function CloudLotteryView:LoadGrade(idx)
    if not self.group then
        return
    end
    local list = self.group[idx][2]
    if not list then
        return
    end
    self.grade_item_list = self.grade_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.grade_item_list[i]
        if not item then
            item = CloudLotTogItem(self.grade_obj, self.tog_con)
            self.grade_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.grade_item_list do
        local item = self.grade_item_list[i]
        item:SetVisible(false)
    end
end

---接收到Info之后再干活
function CloudLotteryView:InitShopPart(info)
    self:CreateScroll(info.logs)
    self:InitTimeShow(info.reward_time)
    self:LoadItem(info.list)
end

function CloudLotteryView:InitTimeShow(e_time)
    local param = {}
    param.isShowMin = true
    param.isShowHour = true
    param.isShowDay = true
    param.isChineseType = true
    param.formatText = "%s"

    if not self.CDT then
        --self.CDT:StopSchedule()
        --else
        self.CDT = CountDownText(self.time_con, param)
    end

    local cur_time = os.time()
    local target_time = os.time()
    --未开奖
    if cur_time < e_time then
        target_time = e_time
        self.time_head.text = "Countdown:"
        local function call_back()
            self:InitTimeShow(e_time)
        end
        self.CDT:ResetParam(param)
        self.CDT:StartSechudle(target_time, call_back)

    else
        local end_time = self.openData.act_etime
        --已开奖
        if end_time - cur_time <= TimeManager.GetInstance().DaySec then
            --开奖后，到结束时间不够一天，gameover
            self.countdt.text = "<color=#eb0000>Event has ended</color>"
        else
            --有下一期
            -- self.time_head.text = "Next phase result coming out in:"
            self.time_head.text = "Event is over"
            local zero_time = TimeManager.GetInstance():GetTomorZeroTime()
            target_time = zero_time
            local function call_back()
                GlobalEvent:Brocast(OperateEvent.REQUEST_SHOP_INFO, self.act_id)
            end
            -- self.CDT:ResetParam(param)
            -- self.CDT:StartSechudle(target_time, call_back)
            if self.CDT.countdowntext then
                self.CDT.countdowntext.text = ""
            end
        end
    end
end

function CloudLotteryView:LoadItem(list)
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = CloudLotItem(self.item_obj, self.item_con)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i], self.ItemStencilId, self.act_id)
    end
    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
end

function CloudLotteryView:HandleBuyResult(act_id, data, log_list)
    if act_id ~= self.act_id or log_list == nil then
        return
    end
    local list = self.model:UpdateBuyReco(log_list)
    self:CreateScroll(list)
end
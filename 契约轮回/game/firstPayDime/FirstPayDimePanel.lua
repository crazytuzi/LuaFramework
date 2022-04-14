--首充0.1元界面
FirstPayDimePanel = FirstPayDimePanel or class("FirstPayDimePanel",BasePanel)

function FirstPayDimePanel:ctor()
    self.abName = "firstPayDime"
    self.assetName = "FirstPayDimePanel"
    self.layer = "UI"

    self.panel_type = 2
    self.is_hide_other_panel = true

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.fp_model = FirstPayModel.GetInstance()
    self.fp_model_events = {}

    self.vip_model = VipModel.GetInstance()
    self.vip_model_events = {}

    self.global_events = {}

    self.reward_items = {}  --奖励物品item列表

    self.pay_goods_id = 15  --充值商品id

    self.state = 1 --状态 1.未充值 2.已充值
end

function FirstPayDimePanel:dctor()
    destroyTab(self.reward_items,true)

    self.fp_model:RemoveTabListener(self.fp_model_events)
    self.fp_model_events = nil

    self.vip_model:RemoveTabListener(self.vip_model_events)
    self.vip_model_events = nil

    GlobalEvent:RemoveTabListener(self.global_events)
    self.global_events = nil

end

function FirstPayDimePanel:LoadCallBack(  )
    self.nodes = {
        "btn_close","rewards_parent","txt_price","btn_recharge","txt_btn_tip",
        "btn_help",
    }

    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if self.need_update_view then
       self:UpdateView()
    end

    local role_create_time = RoleInfoModel.GetInstance():GetRoleValue("ctime")  --角色创建时间
    local end_time = role_create_time + TimeManager.DaySec  --结束时间
    GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "firstPayDime", true,nil,nil,end_time)

    --隐藏红点
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "firstPayDime", false)
end

function FirstPayDimePanel:InitUI(  )
   self.txt_price = GetText(self.txt_price)
   self.txt_btn_tip = GetText(self.txt_btn_tip)

  
end

function FirstPayDimePanel:AddEvent(  )

    --关闭界面
    local function callback(  )
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject,callback)

    --问号按钮
    local function callback(  )
        lua_panelMgr:GetPanelOrCreate(WorthWelfareTipPanel):Open()
    end
    AddClickEvent(self.btn_help.gameObject,callback)

    --充值按钮
    local function callback(  )
        if self.state == 1 then
            --请求充值
            VipController.GetInstance():RequestPayInfo(self.pay_goods_id)
        end
    end
    AddClickEvent(self.btn_recharge.gameObject,callback)

    --已充值信息返回
    local function callback()
        --刷新状态
        self:UpdateState()
    end
    self.vip_model_events[#self.vip_model_events + 1] = self.vip_model:AddListener(VipEvent.HandlePaidList,callback)

    local function call_back(data)
        if data.goods_id == self.cf.id then
            local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
            if not AppConfig.Debug or true then
                local productCount = self.cf_diamand_num or 1
                local id = self.cf.id
                local AppStoreid = self.cf.AppStoreid or id
                local game_channel_id = PlatformManager:GetInstance():GetChannelID()
                local cf = Config.db_appstore and Config.db_appstore[game_channel_id]
                if cf and cf[id] then
                    AppStoreid = cf[id].AppStoreid
                    DebugLog("===========RechargeItem============.",self.cf.AppStoreid,cf[id].AppStoreid)
                end
                PlatformManager:GetInstance():buy(data.order_id, role_data.id, role_data.name, role_data.suid, "Pack", id, "Pack", productCount, self.cf.price, data.pay_back, productCount, AppStoreid, data.goods_id)
            end
        end
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(EventName.REQ_PAYINFO, call_back)

    --充值成功事件监听
    -- local function callback(data)
        
    -- end
    -- self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(EventName.PaySucc, callback)
end

--data
function FirstPayDimePanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function FirstPayDimePanel:UpdateView()
    self.need_update_view = false

    self:UpdateRewards()
    self:UpdatePrice()
    self:UpdateState()
end

--刷新展示奖励
function FirstPayDimePanel:UpdateRewards(  )
    self.cf = Config.db_recharge[self.pay_goods_id]
    local rewards_cfg = String2Table(self.cf.diamand_num)
    if type(rewards_cfg[1]) == "table" then
        for k,v in pairs(rewards_cfg) do
            local goods = GoodsIconSettorTwo(self.rewards_parent)
            local param = {}
            param.item_id = v[1]
            param.num = v[2]
            param.bind = v[3]
            param.can_click = true
            param.size = {x = 75,y = 75}
            goods:SetIcon(param)
            table.insert( self.reward_items, goods )
        end
    else
        local goods = GoodsIconSettorTwo(self.rewards_parent)
        local param = {}
        param.item_id = rewards_cfg[1]
        param.num = rewards_cfg[2]
        param.bind = rewards_cfg[3]
        param.can_click = true
        param.size = {x = 75,y = 75}
        goods:SetIcon(param)
        table.insert( self.reward_items, goods )
    end

    
end

--刷新原价
function FirstPayDimePanel:UpdatePrice(  )
    local price = Config.db_firstpay_dime[1].org
    self.txt_price.text = price
end

--刷新当前状态
function FirstPayDimePanel:UpdateState(  )

    local pay_list = self.vip_model.have_pay_list
    self.state = 1
    for k,v in ipairs(pay_list) do
        if v == self.pay_goods_id then
            self.state = 2
        end
    end

    if self.state == 2 then
        --已领取
        self.txt_btn_tip.text = "Claimed"
        ShaderManager.GetInstance():SetImageGray(GetImage(self.btn_recharge))
    end
end
--多倍投资界面
WorthWelfareInvestmentPanel = WorthWelfareInvestmentPanel or class("WorthWelfareInvestmentPanel",BaseItem)

function WorthWelfareInvestmentPanel:ctor()
    self.abName = "WorthWelfare"
    self.assetName = "WorthWelfareInvestmentPanel"
    self.layer = "UI"


    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
    
    self.vip_model = VipModel.GetInstance()
    self.vip_model_events = {}

    self.global_events = {}

    self.invest_items = {}  --投资Items列表

    self.is_pay = false --是否已购买当前档位多倍投资

    --根据等级判断是哪一档
    self.pay_id = 16  --充值id
    self.min_cfg_id = 200  --最小配置表id
    self.max_cfg_id = 300  --最大配置表id
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    if lv >= 371 then
        self.pay_id = 17
        self.min_cfg_id = 300
        self.max_cfg_id = 400
    end

    self.btn_effect = nil --按钮特效

    self:Load()
end

function WorthWelfareInvestmentPanel:dctor()
    self.vip_model:RemoveTabListener(self.vip_model_events)
    self.vip_model_events = nil

    GlobalEvent:RemoveTabEventListener(self.global_events)
    self.global_events = nil

    destroyTab(self.invest_items,true)

    destroySingle(self.btn_effect)
    self.btn_effect = nil
end

function WorthWelfareInvestmentPanel:LoadCallBack(  )
    self.nodes = {
        "scrollview/viewport/content","btn_recharge","txt_price",

        "scrollview/viewport/content/WorthWelfareInvestmentItem",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

   
end

function WorthWelfareInvestmentPanel:InitUI(  )
    self.txt_price = GetText(self.txt_price)
    self.img_recharge = GetImage(self.btn_recharge)
    self.go_item = self.WorthWelfareInvestmentItem.gameObject
end

function WorthWelfareInvestmentPanel:AddEvent(  )
    --购买投资
    local function callback(  )
        if not self.is_pay then
            VipController.GetInstance():RequestPayInfo(self.pay_id)
        end
    end
    AddClickEvent(self.btn_recharge.gameObject,callback)

    --已充值信息返回
    local function callback()
        self:UpdateState()
        VipController.GetInstance():RequestInvestInfo2()
    end
    self.vip_model_events[#self.vip_model_events + 1] = self.vip_model:AddListener(VipEvent.HandlePaidList,callback)

    --投资计划信息返回
    local function callback(type,grade,list)
        
        if table.nums(self.invest_items) == 0 then
            self:CreateInvestmentItems(list)
        else
            self:UpdateInvestmentItemsState(list)
        end
    end
    self.vip_model_events[#self.vip_model_events + 1] = self.vip_model:AddListener(VipEvent.HandleInvestInfo2,callback)

    local function call_back(data)
        DebugLog('--LaoY WorthWelfareInvestmentPanel.lua,line 98--',self.pay_id)
        if data.goods_id == self.pay_id then
            local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
            if not AppConfig.Debug or true then
                local productCount = self.cf_diamand_num or 1
                local recharge_cf = Config.db_recharge[self.pay_id]
                local id = recharge_cf.id
                local AppStoreid = recharge_cf.AppStoreid or id
                local game_channel_id = PlatformManager:GetInstance():GetChannelID()
                local cf = Config.db_appstore and Config.db_appstore[game_channel_id]
                if cf and cf[id] then
                    AppStoreid = cf[id].AppStoreid
                    DebugLog("===========RechargeItem============.",recharge_cf.AppStoreid,cf[id].AppStoreid)
                end
                PlatformManager:GetInstance():buy(data.order_id, role_data.id, role_data.name, role_data.suid, "Pack", id, "Pack", productCount, recharge_cf.price, data.pay_back, productCount, AppStoreid, data.goods_id)
            end
        end
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(EventName.REQ_PAYINFO, call_back)
end

--data
function WorthWelfareInvestmentPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function WorthWelfareInvestmentPanel:UpdateView()
    self.need_update_view = false

    self:UpdatePrice()

    self:UpdateState()
    VipController.GetInstance():RequestInvestInfo2()
end

--刷新价格
function WorthWelfareInvestmentPanel:UpdatePrice(  )
    self.txt_price.text = string.format( "$%s",Config.db_recharge[self.pay_id].price )
end

--刷新状态
function WorthWelfareInvestmentPanel:UpdateState(  )

    --判断是否已购买当前档位的投资计划
    self.is_pay = WorthWelfareModel.GetInstance():IsPayInvestment()
    if self.is_pay then
        ShaderManager.GetInstance():SetImageGray(self.img_recharge)
        destroySingle(self.btn_effect)
        self.btn_effect = nil
    else
        if not self.btn_effect then
            self.btn_effect = UIEffect(self.btn_recharge,20424)
            local config = {}
            config.scale = {x = 1.278,y = 0.345,z = 0.213}
            config.rotation = {x= 0,y=0,z = 7.6}
            self.btn_effect:SetConfig(config)
        end
    end

end

--创建投资Item列表
function WorthWelfareInvestmentPanel:CreateInvestmentItems(list)

    local new_list = {}
    for k,v in pairs(list) do
         new_list[v.id] = v
    end

    local invest_reward_cfg = WorthWelfareModel.GetInstance().invest_reward_cfg
    for i=self.min_cfg_id,self.max_cfg_id - 1 do

        local cfg = invest_reward_cfg[i]
        if not cfg then
            break
        end

        local item = WorthWelfareInvestmentItem(self.go_item,self.content)

        local data = {}
        data.id = cfg.id  --投资奖励配置表id
        data.type = cfg.type --投资奖励类型
        data.icon_id = cfg.desc  --图标id
        local reward = String2Table(cfg.reward)
        data.count = reward[1][2] --可领取钻石数量
        data.is_pay = self.is_pay  --是否购买
        if new_list[data.id] then
            data.invest_state = new_list[data.id].state  --投资状态
        else
            data.invest_state = nil
        end
        data.target_lv = cfg.level  --目标等级
        
        item:SetData(data)

        table.insert( self.invest_items,item )
    end

    local function callback(  )
        --滚动到第一个可领取的投资item的地方
        local reddot,id = WorthWelfareModel.GetInstance():CheckInvestmentReddot(list)
        if id then
            self:ScrollToItemById(id)
        end
        
    end
    GlobalSchedule:StartOnce(callback)
end

--刷新投资Item状态
function WorthWelfareInvestmentPanel:UpdateInvestmentItemsState(list)

    local new_list = {}
    for k,v in pairs(list) do
         new_list[v.id] = v
    end
    for k,v in pairs(self.invest_items) do
        local data = v.data
        data.is_pay = self.is_pay  --是否购买
        if new_list and new_list[data.id] then
            data.invest_state = new_list[data.id].state  --投资状态
        else
            data.invest_state = nil
        end
        v:UpdateState()
    end
end

--滚动到指定id的item那里
function WorthWelfareInvestmentPanel:ScrollToItemById(target_id)
    local num = target_id - self.min_cfg_id

    --计算行数index 从0开始的
    local row_index = Mathf.Floor(num / 2 )

    local row_height = 100  --列高

    SetLocalPositionY(self.content,row_height * row_index)

end


--超值礼包Item
WorthWelfareGiftItem = WorthWelfareGiftItem or class("WorthWelfareGiftItem",BaseCloneItem)

function WorthWelfareGiftItem:ctor(obj,parent_node)
    self.abName = "WorthWelfare"
    self.assetName = "WorthWelfareGiftItem"
    self.layer = "UI"

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.reward_items = {}  --奖励items

    self.vip_model = VipModel.GetInstance()
    self.vip_model_events = {}

    self.global_events = {}

    self:Load()
end

function WorthWelfareGiftItem:dctor()
    destroyTab(self.reward_items,true)

    self.vip_model:RemoveTabListener(self.vip_model_events)
    self.vip_model_events = nil

    GlobalEvent:RemoveTabListener(self.global_events)
    self.global_events = nil
end

function WorthWelfareGiftItem:LoadCallBack(  )
    self.nodes = {
        "txt_count","txt_gift_name",
        "reward_parent2","reward_parent3","reward_parent1",
        "txt_cur_price","txt_orignal_price",
        "btn_buy",
    }

    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function WorthWelfareGiftItem:InitUI(  )
    self.txt_gift_name = GetText(self.txt_gift_name)
    self.txt_count = GetText(self.txt_count)
    self.txt_orignal_price = GetText(self.txt_orignal_price)
    self.txt_cur_price = GetText(self.txt_cur_price)
    self.img_buy = GetImage(self.btn_buy)
end

function WorthWelfareGiftItem:AddEvent(  )
    --购买按钮
    local function callback(  )
        if self.data.count > 0 then
            VipController.GetInstance():RequestPayInfo(self.data.pay_id)
        end
    end
    AddClickEvent(self.btn_buy.gameObject,callback)

     --已充值次数返回
     local function callback(times)
        self.data.count = self.data.limit_num - (times[self.data.pay_id] or 0)
        --logError( self.data.pay_id.."-"..self.data.count)
        self:UpdateCount()
    end
    self.vip_model_events[#self.vip_model_events + 1] = self.vip_model:AddListener(VipEvent.HandlePayTimes,callback)

    local function call_back(data)
        DebugLog('--LaoY WorthWelfareGiftItem.lua,line 98--',self.data.pay_id)
        if data.goods_id == self.data.pay_id then
            local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
            if not AppConfig.Debug or true then
                local productCount = self.cf_diamand_num or 1
                local recharge_cf = Config.db_recharge[self.data.pay_id]
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
--pay_id 充值id
--name 礼包名字
--limit_num 总限购次数
--count 剩余限购次数
--rewards 奖励
--currency 币种字符
--orignal_price --原价
--cur_price --现价
function WorthWelfareGiftItem:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function WorthWelfareGiftItem:UpdateView()
    self.need_update_view = false

    self:UpdateName()
    self:UpdateCount()
    self:UpdateRewards()
    self:UpdatePrice()
end

--刷新礼包名字
function WorthWelfareGiftItem:UpdateName(  )
    self.txt_gift_name.text = self.data.name
end

--刷新礼包剩余限购次数
function WorthWelfareGiftItem:UpdateCount(  )
    self.txt_count.text = string.format( "Can buy \n<color=#FDE783>%s</color> times",self.data.count)

    if self.data.count == 0 then
        --没次数了
        ShaderManager.GetInstance():SetImageGray(self.img_buy)
    end
end

--刷新奖励
function WorthWelfareGiftItem:UpdateRewards(  )
    local index = 1
    for k,v in pairs(self.data.rewards) do
        local goods = GoodsIconSettorTwo(self["reward_parent"..index])
        local param = {}
        param.item_id = v[1]
        param.num = v[2]
        param.bind = v[3]
        param.can_click = true
        param.size = {x = 60,y = 60}
        goods:SetIcon(param)
        table.insert( self.reward_items, goods )
        index = index + 1
    end
end

--刷新价格
function WorthWelfareGiftItem:UpdatePrice(  )
    self.txt_orignal_price.text = string.format( "Orig. Price: %s%s",self.data.currency,self.data.orignal_price )
    self.txt_cur_price.text = string.format( "$%s",self.data.cur_price)
end


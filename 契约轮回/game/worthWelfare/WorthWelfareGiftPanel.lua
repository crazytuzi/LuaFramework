--超值礼包界面
WorthWelfareGiftPanel = WorthWelfareGiftPanel or class("WorthWelfareGiftPanel",BaseItem)

function WorthWelfareGiftPanel:ctor()
    self.abName = "WorthWelfare"
    self.assetName = "WorthWelfareGiftPanel"
    self.layer = "UI"


    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.vip_model = VipModel.GetInstance()
    self.vip_model_events = {}

    self.gift_items = {}  --礼包items 

    self:Load()
end

function WorthWelfareGiftPanel:dctor()
    if self.vip_model_events then
        self.vip_model:RemoveTabListener(self.vip_model_events)
        self.vip_model_events = nil
    end
   

    destroyTab(self.gift_items,true)
end

function WorthWelfareGiftPanel:LoadCallBack(  )
    self.nodes = {
        "scrollview/viewport/content",
        "scrollview/viewport/content/WorthWelfareGiftItem",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    VipController.GetInstance():RequestPayTimes()
end

function WorthWelfareGiftPanel:InitUI(  )
    self.go_item = self.WorthWelfareGiftItem.gameObject
end

function WorthWelfareGiftPanel:AddEvent(  )
    --已充值次数
    local function callback(times)
        self:UpdateGiftItems(times)
        self.vip_model:RemoveTabListener(self.vip_model_events)
        self.vip_model_events = nil
    end
    self.vip_model_events[#self.vip_model_events + 1] = self.vip_model:AddListener(VipEvent.HandlePayTimes,callback)
end

--data
function WorthWelfareGiftPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function WorthWelfareGiftPanel:UpdateView()
    self.need_update_view = false

   
end

--刷新礼包Item
function  WorthWelfareGiftPanel:UpdateGiftItems(times)
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()

    for i,v in ipairs(Config.db_direct_purchase) do

        if lv >= v.min_level and lv <= v.max_level then
            local item =  WorthWelfareGiftItem(self.go_item,self.content)
        
            local data = {}
            data.pay_id = v.recharge_id  --充值id
            data.name = v.name  --礼包名字
            data.limit_num = v.limit_num
            data.count = v.limit_num - (times[v.recharge_id] or 0)  --剩余限购次数
            data.rewards = String2Table(Config.db_recharge[v.recharge_id].diamand_num)  --奖励
            data.currency = v.currency  --币种符号
            data.orignal_price = v.original_price  --原价
            data.cur_price = v.price

            item:SetData(data)
            
            table.insert( self.gift_items, item )
        end

      
    end
end
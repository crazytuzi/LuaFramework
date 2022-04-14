VipSmallWelfarePanel = VipSmallWelfarePanel or class("VipSmallWelfarePanel",BaseItem)

function VipSmallWelfarePanel:ctor()
    self.abName = "VipSmall"
    self.assetName = "VipSmallWelfarePanel"
    self.layer = "UI"


    self.data = nil
    self.need_update_view = true  --是否需要刷新UI
   
    self.welfare_items = {}  --小贵族在线奖励items

    self.vip_small_model = VipSmallModel:GetInstance()
    self.vip_small_model_events = {}
    
    self.global_events = {}

    self:Load()
end

function VipSmallWelfarePanel:dctor()

    self.vip_small_model:RemoveTabListener(self.vip_small_model_events)
    self.vip_small_model_events = nil
    
    GlobalEvent:RemoveTabListener(self.global_events)
    self.global_events = nil

    destroyTab(self.welfare_items)
    self.welfare_items = nil
end

function VipSmallWelfarePanel:LoadCallBack(  )
    self.nodes = {
        "scrollview/viewport/content/VipSmallWelfareItem","scrollview/viewport/content",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    WelfareController.GetInstance():RequestWelfareOnline2()
end

function VipSmallWelfarePanel:InitUI(  )
    self.welfare_item_go = self.VipSmallWelfareItem.gameObject
end

function VipSmallWelfarePanel:AddEvent(  )

    --处理小贵族在线奖励信息返回
    local function callback(  )
        if table.nums(self.welfare_items )== 0 then
            self:UpdateWelfareItems()
        else
            self:UpdateWelfareItemsState()
        end
        
    end
    self.vip_small_model_events[#self.vip_small_model_events + 1] = self.vip_small_model:AddListener(VipSmallEvent.HandleWelfareOnline2,callback)

    --处理小贵族在线奖励领取返回
    local function callback(id)
        if self.welfare_items[id] then
            self.welfare_items[id]:UpdateState()
        end
    end
    self.vip_small_model_events[#self.vip_small_model_events + 1] = self.vip_small_model:AddListener(VipSmallEvent.HandleWelfareOnline2Reward,callback)

    --跨天处理
    local function callback(  )

        destroyTab(self.welfare_items)
        self.welfare_items = {}

        WelfareController.GetInstance():RequestWelfareOnline2()
    end
    GlobalEvent:AddListener(EventName.CrossDay, callback)
end

--data
function VipSmallWelfarePanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function VipSmallWelfarePanel:UpdateView()
    self.need_update_view = false

   
end

--刷新小贵族在线奖励item
function VipSmallWelfarePanel:UpdateWelfareItems(  )
    local opdays = LoginModel.GetInstance():GetOpenTime()
    local cfgs = self.vip_small_model.welfare_online2_cfg[opdays]

    for k,v in table.pairsByKey(cfgs) do
        local item = VipSmallWelfareItem(self.welfare_item_go,self.content)
        local data = {}
        data.id = v.id
        data.online_time = self.vip_small_model.online_time
        data.target_time = v.time
        data.reward = String2Table(v.reward)
        item:SetData(data)
        self.welfare_items[v.id] = item
    end
end

--刷新小贵族在线奖励item状态
function VipSmallWelfarePanel:UpdateWelfareItemsState(  )
    for k,v in pairs(self.welfare_items) do
        v.data.online_time = self.vip_small_model.online_time
        v:UpdateOnlineTime()
        v:UpdateState()
    end
end

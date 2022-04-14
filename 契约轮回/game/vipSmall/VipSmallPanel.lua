VipSmallPanel = VipSmallPanel or class("VipSmallPanel",WindowPanel)

function VipSmallPanel:ctor()
    self.abName = "vipSmall"
    self.assetName = "VipSmallPanel"
    self.layer = "UI"

    self.panel_type = 7
    self.is_show_indepen_title_bg = true
          

    self.vip_small_model = VipSmallModel.GetInstance()
    self.vip_small_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.show_sidebar = true
    self.sidebar_data = {}
    -- self.sidebar_data = {
    --    { text = "充值", id = 1},
    --     { text = "福利", id = 2},
    -- }

    local vip_lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel()
    if vip_lv == 0 or not self.vip_small_model:IsReceiveCurVipLvReward() then
        --没激活vip 或者 还有等级奖励未领取
        table.insert( self.sidebar_data,{ text = "Top Up", id = 1})
    end

    local opdays = LoginModel.GetInstance():GetOpenTime()
    if opdays <= 7 then
        --开服天数7天内
        table.insert( self.sidebar_data,{ text = "Privilege", id = 2} )
    end

    self.main_panel = nil  --主界面
    self.welfare_panel = nil --福利界面
   
end

function VipSmallPanel:dctor()
    if table.nums(self.vip_small_model_events) > 0 then
        self.vip_small_model:RemoveTabListener(self.vip_small_model_events)
        self.vip_small_model_events = nil
    end

    destroySingle(self.main_panel)
    self.main_panel = nil

    destroySingle(self.welfare_panel)
    self.welfare_panel = nil
end

function VipSmallPanel:LoadCallBack(  )
    self.nodes = {
      
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

   
end

function VipSmallPanel:InitUI(  )

    self.vip_small_model.is_first_open_panle = false

    self:SetTileTextImage("vipSmall_image", "img_vipSmall_text7", false)

    local is_show1 = self.vip_small_model:IsCanReceiveLvReward()
    self:SetIndexRedDotParam(1,is_show1)

    local is_show2 = self.vip_small_model:IsCanReceiveWefareReward()
    self:SetIndexRedDotParam(2,is_show2)
end

function VipSmallPanel:AddEvent(  )
     --小贵族等级礼包领取返回
     local function callback(  )
        local is_show = self.vip_small_model:IsCanReceiveLvReward()
        self:SetIndexRedDotParam(1,is_show)
    end
    self.vip_small_model_events[#self.vip_small_model_events + 1] = self.vip_small_model:AddListener(VipSmallEvent.HandleVip2Fetch,callback)

     --小贵族在线奖励信息返回
    local function callback(  )
        local is_show = self.vip_small_model:IsCanReceiveWefareReward()
        self:SetIndexRedDotParam(2,is_show)
    end
    self.vip_small_model_events[#self.vip_small_model_events + 1] = self.vip_small_model:AddListener(VipSmallEvent.HandleWelfareOnline2,callback)

    --小贵族在线奖励领取返回
    local function callback(id)
        local is_show = self.vip_small_model:IsCanReceiveWefareReward()
        self:SetIndexRedDotParam(2,is_show)
    end
    self.vip_small_model_events[#self.vip_small_model_events + 1] = self.vip_small_model:AddListener(VipSmallEvent.HandleWelfareOnline2Reward,callback)
end

--data
function VipSmallPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function VipSmallPanel:UpdateView()
    self.need_update_view = false

   
end

function VipSmallPanel:SwitchCallBack(index)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    --logError("SwitchCallBack,index-"..index)
    if index == 1 then
        --显示主界面
        self.main_panel = self.main_panel or VipSmallMainPanel(self.child_transform, "UI")
        self:PopUpChild(self.main_panel)
    elseif index ==2 then
        --显示福利界面
        self.welfare_panel = self.welfare_panel or VipSmallWelfarePanel(self.child_transform, "UI")
        self:PopUpChild(self.welfare_panel)
    end
end
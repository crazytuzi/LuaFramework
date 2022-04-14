VipSmallMainPanel = VipSmallMainPanel or class("VipSmallMainPanel",BaseItem)

function VipSmallMainPanel:ctor()
    self.abName = "VipSmall"
    self.assetName = "VipSmallMainPanel"
    self.layer = "UI"


    self.data = nil
    self.need_update_view = true  --是否需要刷新UI
   
    self.vip_small_model = VipSmallModel:GetInstance()
	self.vip_small_model_events = {}

    self.show_vip_lv = nil --当前显示特权的小贵族等级
    self.is_first_show_vip_rights = true  --是否是首次显示特权
    self.privilege_items = {}  --小贵族特权items

    self.vip_lv_reward_items = {}  --小贵族等级礼包items

    self.is_receive_cur_lv_rewards = false  --是否已领取当前小贵族等级及之前等级的所有奖励

    self.btn_red_dot = nil  --领取按钮红点

    self:Load()
end

function VipSmallMainPanel:dctor()
    self.vip_small_model:RemoveTabListener(self.vip_small_model_events)
	self.vip_small_model_events = {}

    destroyTab(self.privilege_items,true)
    destroyTab(self.vip_lv_reward_items,true)

    destroySingle(self.btn_red_dot)
    self.btn_red_dot = nil
end

function VipSmallMainPanel:LoadCallBack(  )
   
    self.nodes = {
        "left/btn_buy",

        "right_top/txt_vip_lv","right_top/txt_progress","right_top/img_progress",

        "right_mid/left_vip/btn_left_arrow","right_mid/left_vip/txt_left_vip_lv",
        "right_mid/mid_vip/txt_mid_vip_lv",
        "right_mid/right_vip/txt_right_vip_lv","right_mid/right_vip/btn_right_arrow",
        "right_mid/right_vip","right_mid/left_vip",

        "right_mid/scrollview_privilege/viewport_privilege/content_privilege",
        "right_mid/scrollview_privilege/viewport_privilege/content_privilege/VipSmallPrivilegeItem",

        "right_buttom/txt_vip_gift_lv",
        "right_buttom/scrollview_rewards/viewport_rewards/content_rewards",
        "right_buttom/btn_receive/txt_receive","right_buttom/btn_receive",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    --请求小贵族信息
    VipSmallController.GetInstance():RequestVip2Info()
end

function VipSmallMainPanel:InitUI(  )
    self.privilege_item_go = self.VipSmallPrivilegeItem.gameObject

    self.txt_vip_lv = GetText(self.txt_vip_lv)
    self.img_progress = GetImage(self.img_progress)
    self.txt_progress = GetText(self.txt_progress)

    self.txt_left_vip_lv = GetText(self.txt_left_vip_lv)
    self.txt_mid_vip_lv = GetText(self.txt_mid_vip_lv)
    self.txt_right_vip_lv = GetText(self.txt_right_vip_lv)
    
    self.txt_vip_gift_lv = GetText(self.txt_vip_gift_lv)
    self.txt_receive = GetText(self.txt_receive)
    self.img_receive = GetImage(self.btn_receive)
end

function VipSmallMainPanel:AddEvent(  )

    --前往购买按钮
    local function callback(  )
        --跳转到vip界面
        lua_panelMgr:GetPanel(VipSmallPanel):Close()
        GlobalEvent:Brocast(VipEvent.OpenVipPanel)
    end
    AddClickEvent(self.btn_buy.gameObject,callback)

    --小贵族特权一览左箭头按钮
    local function callback(  )
        self.show_vip_lv = self.show_vip_lv - 1
        self:UpdatePrivilegeItems()
    end
    AddClickEvent(self.btn_left_arrow.gameObject,callback)

    --小贵族特权一览右箭头按钮
    local function callback(  )
        self.show_vip_lv = self.show_vip_lv + 1
        self:UpdatePrivilegeItems()
    end
    AddClickEvent(self.btn_right_arrow.gameObject,callback)

    --小贵族等级礼包领取按钮
    local function callback(  )
        if not self.is_receive_cur_lv_rewards then
            local vip_lv = self.vip_small_model:CanReceiveVipLvRewardLv()
            VipSmallController.GetInstance():RequestVip2Fetch(vip_lv)
        end
    end
    AddClickEvent(self.btn_receive.gameObject,callback)

    --小贵族信息返回
    local function callback(  )
        self:UpdateVipProgress()

        local vip_lv = self.vip_small_model.vip_small_lv
        if not self.show_vip_lv and vip_lv == 0 then
            self.show_vip_lv = 1
        end

        self.show_vip_lv = self.show_vip_lv or self.vip_small_model.vip_small_lv
        
        self:UpdatePrivilegeItems()

        if table.nums(self.vip_lv_reward_items) == 0 then
            self:UpdateVipLvReward()
        end

        self:UpdateBtnReceive()
    end
    self.vip_small_model_events[#self.vip_small_model_events + 1] = self.vip_small_model:AddListener(VipSmallEvent.HandleVip2Info,callback)

    --小贵族等级礼包领取返回
    local function callback(  )
        self:UpdateBtnReceive()
        self:UpdateVipLvReward()
    end
    self.vip_small_model_events[#self.vip_small_model_events + 1] = self.vip_small_model:AddListener(VipSmallEvent.HandleVip2Fetch,callback)
end

--data
function VipSmallMainPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function VipSmallMainPanel:UpdateView()
    self.need_update_view = false
    
end

--刷新小贵族等级与进度
function VipSmallMainPanel:UpdateVipProgress(  )
    local vip_lv = self.vip_small_model.vip_small_lv
    local cur_exp = self.vip_small_model.vip_small_exp

    local target_exp = cur_exp
    if vip_lv < self.vip_small_model.max_vip_lv then
        target_exp = self.vip_small_model.vip2_level_cfg[vip_lv + 1].exp
    end

    self.txt_vip_lv.text = vip_lv
    self.txt_progress.text = string.format( "%s/%s",cur_exp,target_exp )
    self.img_progress.fillAmount = cur_exp / target_exp
end

--刷新小贵族特权Item
function VipSmallMainPanel:UpdatePrivilegeItems()

    if tonumber(self.txt_mid_vip_lv.text) == self.show_vip_lv then
        --当前显示的和要显示的小贵族特权等级相同就不处理了
        return
    end

    local max_vip_lv = self.vip_small_model.max_vip_lv
    if self.show_vip_lv == 0 then
       SetVisible(self.left_vip,false) 
       SetVisible(self.right_vip,true) 
    elseif self.show_vip_lv == max_vip_lv then
        SetVisible(self.left_vip,true) 
        SetVisible(self.right_vip,false) 
    else
        SetVisible(self.left_vip,true) 
        SetVisible(self.right_vip,true) 
    end

    self.txt_left_vip_lv.text = string.format( "Mini VIP %s",self.show_vip_lv - 1 )
    self.txt_mid_vip_lv.text = self.show_vip_lv
    self.txt_right_vip_lv.text =  string.format( "Mini VIP %s",self.show_vip_lv + 1 )

    --特权描述
    local privilege = self.vip_small_model.vip2_level_cfg[self.show_vip_lv].privilege
    privilege = string.split(privilege,"\\n")
    local count = 0
    for i,v in ipairs(privilege) do
        count = count + 1
        self.privilege_items[i] = self.privilege_items[i] or VipSmallPrivilegeItem(self.privilege_item_go,self.content_privilege)
        local data = {}
        data.desc = v
        self.privilege_items[i]:SetData(data)
        SetVisible(self.privilege_items[i],true)
    end

    for i=count + 1,#self.privilege_items do
        SetVisible(self.privilege_items[i],false)
    end
end

--刷新小贵族等级奖励
function VipSmallMainPanel:UpdateVipLvReward(  )
    
    local vip_lv = self.vip_small_model:CanReceiveVipLvRewardLv()
    --local vip_lv = 4
    
    self.txt_vip_gift_lv.text = vip_lv

    --加载奖励
    local reward = self.vip_small_model.vip2_level_cfg[vip_lv].reward
    reward = String2Table(reward)

    if type(reward[1]) == "number" then
        reward = {{reward[1],reward[2],reward[3]}}
    end

    local index = 1
    for k,v in pairs(reward) do
        self.vip_lv_reward_items[index] = self.vip_lv_reward_items[index] or GoodsIconSettorTwo(self.content_rewards)
        local icon = {}
        icon.item_id = v[1]
        icon.num = v[2]
        icon.bind = v[3]
        icon.can_click = true
        self.vip_lv_reward_items[index]:SetIcon(icon)
        SetVisible(self.vip_lv_reward_items[index],true)
        index = index + 1
    end
    for i=index,#self.vip_lv_reward_items do
        SetVisible(self.vip_lv_reward_items[i],false)
    end
end

--刷新小贵族等级奖励领取按钮
function VipSmallMainPanel:UpdateBtnReceive(  )
    if self.vip_small_model.vip_small_lv == 0 then
        --小贵族等级为0 置灰掉领取按钮
        self.is_receive_cur_lv_rewards = true
    else
        self.is_receive_cur_lv_rewards = self.vip_small_model:IsReceiveCurVipLvReward()
    end

    --self.is_receive_cur_lv_rewards = self.vip_small_model:IsReceiveCurVipLvReward()
    
    if self.is_receive_cur_lv_rewards then
        ShaderManager.GetInstance():SetImageGray(self.img_receive)
        --self.txt_receive.text = "已领取"
        self:UpdateBtnReddot(false)
    else
        ShaderManager.GetInstance():SetImageNormal(self.img_receive)
        self:UpdateBtnReddot(true)
        --self.txt_receive.text = "领 取"
    end
end

--刷新领取按钮红点
function VipSmallMainPanel:UpdateBtnReddot(is_show)
    
    if not is_show and not self.btn_red_dot then
        return
    end
    
    if not self.btn_red_dot then
        self.btn_red_dot = RedDot(self.btn_receive)
    end
    SetVisible(self.btn_red_dot.transform,is_show)
    SetLocalPosition(self.btn_red_dot.transform,44,15,0)
end


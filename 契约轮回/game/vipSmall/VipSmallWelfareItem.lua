VipSmallWelfareItem = VipSmallWelfareItem or class("VipSmallWelfareItem",BaseCloneItem)

function VipSmallWelfareItem:ctor(obj,parent_node)

    self.data = nil
   
    self.state = 1  --状态 1-未达成 2-可领取 3-已领取

    self.reward_items = {}  --奖励items

    self.btn_red_dot = nil  --领取按钮红点

    self:Load()
end

function VipSmallWelfareItem:dctor()
    destroyTab(self.reward_items)
    self.reward_items = nil

    destroySingle(self.btn_red_dot)
    self.btn_red_dot = nil
end

function VipSmallWelfareItem:LoadCallBack(  )
    self.nodes = {
      "txt_time","rewards_parent","btn_receive","btn_receive/txt_receive"
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()

end

function VipSmallWelfareItem:InitUI(  )
    self.txt_time = GetText(self.txt_time)
    self.txt_receive = GetText(self.txt_receive)
    self.img_receive = GetImage(self.btn_receive)
end

function VipSmallWelfareItem:AddEvent(  )

    --领取按钮
    local function callback(  )
        if self.state == 2 then
            WelfareController.GetInstance():RequestWelfareOnline2Reward(self.data.id)
        end
    end
    AddClickEvent(self.btn_receive.gameObject,callback)


end

--data
--id
--target_time 目标时长（秒）
--reward 奖励表
function VipSmallWelfareItem:SetData(data)
    self.data = data

    self:UpdateView()
end

function VipSmallWelfareItem:UpdateView()
    self:UpdateOnlineTime()
    self:UpdateReward()
    self:UpdateState()
end

--刷新在线时长
function VipSmallWelfareItem:UpdateOnlineTime( )
    local online_time = Mathf.Floor(self.data.online_time / 60)
    local target_time = Mathf.Floor(self.data.target_time / 60)
    local str = string.format( "Total online %s mins (%s/%s)",target_time,online_time,target_time )
    self.txt_time.text = str
end

--刷新奖励
function VipSmallWelfareItem:UpdateReward( )
    for k,v in pairs(self.data.reward) do
        local goods_icon = GoodsIconSettorTwo(self.rewards_parent)
        local icon = {}
        icon.item_id = v[1]
        icon.num = v[2]
        icon.bind = v[3]
        icon.can_click = true
        goods_icon:SetIcon(icon)
        table.insert( self.reward_items,goods_icon )
    end
end

--刷新领取按钮状态
function VipSmallWelfareItem:UpdateState( )
    if self.data.online_time < self.data.target_time then
        --未达成目标累计在线时间
        self.state = 1
        ShaderManager.GetInstance():SetImageGray(self.img_receive)
        self.txt_receive.text = "Not Reached"
        self:UpdateBtnReddot(false)
        return
    end

    if VipSmallModel.GetInstance():IsReceiveOnlineReward(self.data.id) then
        --已领取
        self.state = 3
        ShaderManager.GetInstance():SetImageGray(self.img_receive)
        self.txt_receive.text = "Claimed"
        self:UpdateBtnReddot(false)
        return
    end

    self.state = 2
    ShaderManager.GetInstance():SetImageNormal(self.img_receive)
    self.txt_receive.text = "Claim"
    self:UpdateBtnReddot(true)
end

--刷新领取按钮红点
function VipSmallWelfareItem:UpdateBtnReddot(is_show)
    
    if not is_show and not self.btn_red_dot then
        return
    end
    
    if not self.btn_red_dot then
        self.btn_red_dot = RedDot(self.btn_receive)
    end
    SetVisible(self.btn_red_dot.transform,is_show)
    SetLocalPosition(self.btn_red_dot.transform,44,15,0)
end





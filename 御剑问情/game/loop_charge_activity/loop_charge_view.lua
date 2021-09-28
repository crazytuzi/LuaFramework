LoopChargeView = LoopChargeView or BaseClass(BaseView)

local VIEW_STATE = {
    NORMAL = 1,
    CAN_GET_REWARD_FLAG = 2
}
function LoopChargeView:__init()
    self.ui_config = {"uis/views/loopview_prefab", "LoopChargeView"}
end

function LoopChargeView:__delete()
    
end

function LoopChargeView:LoadCallBack()
    self.view_state = VIEW_STATE.NORMAL
    self.charge = self:FindVariable("charge")
    self.total_charge = self:FindVariable("total_charge")
    self.need_charge = self:FindVariable("need_charge")
    self.item_root = self:FindObj("item_root")
    self.view_flag = self:FindVariable("view_flag")
    self.gift_num = self:FindVariable("giftNum")
    self.progress = self:FindVariable("progress")
    self.item_list = {}
    
    self:ListenEvent("close", BindTool.Bind(self.Close, self))
    self:ListenEvent("ClickGetReward", BindTool.Bind(self.ClickGetReward, self))
end

function LoopChargeView:ReleaseCallBack()
    self.charge = nil
    self.total_charge = nil
    self.item_root = nil
    self.view_flag = nil
    self.need_charge = nil
    self.gift_num = nil
    self.progress = nil
    
    for k, v in pairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = {}
end

function LoopChargeView:OpenCallBack()
    LoopChargeCtrl.Instance.red_flag = false
    LoopChargeCtrl.Instance:FlushInfo()
end

function LoopChargeView:CloseCallBack()
    
end

function LoopChargeView:OnFlush()
    LoopChargeData.Instance:ShowData()
    self:ConstructData()
    self:ShowReward()
    self:ShowCharge()
    self:SetFlag()
end

function LoopChargeView:ConstructData()
    self.item_num = LoopChargeData.Instance:GetItemNum()
    self.reward_list = LoopChargeData.Instance:GetRewardList()
    self.charge_value = LoopChargeData.Instance:GetCharge()
    self.total_charge_value = LoopChargeData.Instance:GetTotalCharge()
    self.need_charge_value = LoopChargeData.Instance:GetNeedCharge()
    self.can_get_reward_flag = LoopChargeData.Instance:CanGetRewardFlag()
    if self.can_get_reward_flag then
        self.view_state = VIEW_STATE.CAN_GET_REWARD_FLAG
    else
        self.view_state = VIEW_STATE.NORMAL
    end
    
end

-------------------展示部分----------------------
function LoopChargeView:ShowReward()
	if CheckInvalid(self.reward_list) then
		return
	end
    for i = 1, self.item_num do
        if self.item_list[i] then
            self.item_list[i]:SetData(self.reward_list[i - 1])
        else
            self.item_list[i] = ItemCell.New()
            self.item_list[i]:SetInstanceParent(self.item_root)
            self.item_list[i]:SetData(self.reward_list[i - 1])
        end
    end
    for k, v in pairs(self.item_list) do
        if next(v:GetData()) == nil then
            v:SetActive(false)
        else
            v:SetActive(true)
        end
    end
end

function LoopChargeView:ShowCharge()
    if CheckInvalid(self.charge_value) and CheckInvalid(self.need_charge_value) then
        return
    end
    local str = self.charge_value .. "/" .. self.need_charge_value
    self.charge:SetValue(str)
    self.gift_num:SetValue(math.floor(self.charge_value / self.need_charge_value))
    self.need_charge:SetValue(self.need_charge_value)
    self.progress:SetValue(self.charge_value / self.need_charge_value)
end

function LoopChargeView:SetFlag()
    self.view_flag:SetValue(self.view_state)
end

-------------------点击事件----------------------
function LoopChargeView:ClickGetReward()
    if self.view_state == VIEW_STATE.NORMAL then
        VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
        ViewManager.Instance:Open(ViewName.VipView)
    end
    if self.view_state == VIEW_STATE.CAN_GET_REWARD_FLAG then
        KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2,
                CIRCULATION_CHONGZHI_OPERA_TYPE.CIRCULATION_CHONGZHI_OPEAR_TYPE_FETCH_REWARD, 0, 0)
    end
end
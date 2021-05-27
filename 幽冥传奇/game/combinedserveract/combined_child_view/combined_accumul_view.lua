CombinedServerActView = CombinedServerActView or BaseClass(BaseView)

function CombinedServerActView:LoadAccumulView()
--	self.node_t_list.btn_d_guaji.node:addClickEventListener(BindTool.Bind(self.OnClickGuajiHandler, self))
--    self.node_t_list.img_top_bg.node:loadTexture(ResPath.GetBigPainting("open_service_acitivity_bg2"))
    self:CreateList()
    self.accumul_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateAccumulLastTime, self), 1)
end
function CombinedServerActView:UpdateAccumulLastTime()
    local act_id = CombinedServerActData.GetActIdByIndex(TabIndex.combinedserv_accumulative)
	local act_cfg = CombinedServerActData.GetCombinedServActCfg(act_id)
	local act_info = CombinedServerActData.Instance:GetActInfo(act_id)
	if nil ~= act_cfg or nil ~= act_info then
	    local has_time = math.max(0, act_info.end_time - TimeCtrl.Instance:GetServerTime())
        self.node_t_list.lbl_left_day.node:setString(TimeUtil.FormatSecond2Str(has_time))
    end
end
function CombinedServerActView:DeleteAccumulView()
    if self.charge_gift_list then
		self.charge_gift_list:DeleteMe()
		self.charge_gift_list = nil
	end
    GlobalTimerQuest:CancelQuest(self.accumul_timer)
end

function CombinedServerActView:FlushAccumulView(param_t)
   

    local item_list = CombinedServerActData.Instance:GetAccumulInfo()
    
	local accumulated_recharge_text = string.format(Language.OpenServiceAcitivity.AccumulatedRecharge, item_list.charge_money)
	self.node_t_list.lbl_accumulated_recharge.node:setString(accumulated_recharge_text)
	local sort_list = CombinedServerActData.Instance:SortList(item_list.item_list)
    self.charge_gift_list:SetDataList(sort_list)
end


function CombinedServerActView:CreateList()
	if self.charge_gift_list then return end
	local ph = self.ph_list.ph_charge_list
	self.charge_gift_list = ListView.New()
	self.charge_gift_list:Create(ph.x, ph.y, ph.w, ph.h, nil, AccumulAwardListRender, nil, nil, self.ph_list.ph_charge_item)
	self.charge_gift_list:GetView():setAnchorPoint(0, 0)
	self.node_t_list.layout_accumul.node:addChild(self.charge_gift_list:GetView(), 100)
	self.charge_gift_list:SetItemsInterval(1)
	self.charge_gift_list:SetJumpDirection(ListView.Top)
	-- self.charge_gift_list:SetSelectCallBack(BindTool.Bind1(self.SelectSkillCallBack, self))
end



----------------------------------------------
-- 奖励列表item
----------------------------------------------

AccumulAwardListRender = AccumulAwardListRender or BaseClass(BaseRender)

function AccumulAwardListRender:__init()
end

function AccumulAwardListRender:__delete()
end

function AccumulAwardListRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateAwardScroll()
	self:CreateNeedChargeNum()
	XUI.AddClickEventListener(self.node_tree.btn_receive.node, BindTool.Bind(self.OnClickReceive, self))
	self.node_tree.btn_receive.node:setVisible(true)
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.btn_receive.remind_eff = RenderUnit.CreateEffect(23, self.node_tree.btn_receive.node, 1)
end

function AccumulAwardListRender:OnFlush()
	if nil == self.data then return end

	self.need_charge_num:SetNumber(self.data.need_money)
	self:CreateAwardList()
	if self.data.btn_state == 0 then
		self.node_tree.btn_receive.node:setEnabled(false)
		self.node_tree.btn_receive.node:setTitleText("未完成")
		self.node_tree.btn_receive.remind_eff:setVisible(false)
	elseif self.data.btn_state == 1 then
		self.node_tree.btn_receive.node:setEnabled(true)
		self.node_tree.btn_receive.node:setTitleText("领    取")
		self.node_tree.btn_receive.remind_eff:setVisible(true)
	else
		self.node_tree.btn_receive.node:setVisible(false)
		self.node_tree.img_stamp.node:setVisible(true)
	end
end

function AccumulAwardListRender:CreateAwardList()
	if self.award_cell_list then 
		for k, v in pairs(self.award_cell_list) do
			v:GetView():removeFromParent()
			v:DeleteMe()
			v = nil
		end
		self.award_cell_list = {}
	end
	self.award_cell_list = {}
	local x, y = 0, 0
	local x_interval = 85
	for k, v in pairs(self.data.award_list) do
		local award_cell = BaseCell.New()
		award_cell:SetAnchorPoint(0, 0)
		self.reward_list_view:addChild(award_cell:GetView(), 99)
		award_cell:SetPosition(x, y)
		award_cell:SetData(v)
		x = x + x_interval
		table.insert(self.award_cell_list, award_cell)
	end
	local w = #self.data.award_list * x_interval
	self.reward_list_view:setInnerContainerSize(cc.size(w, 80))
end

function AccumulAwardListRender:CreateAwardScroll()
	self.reward_items = {}
	self.reward_list_view = self.node_tree.scroll_award_view.node
	self.reward_list_view:setScorllDirection(ScrollDir.Horizontal)
end

-- 创建需要充值数字显示
function AccumulAwardListRender:CreateNeedChargeNum()
	if self.need_charge_num ~= nil then return end
	local ph = self.ph_list.ph_need_charge_num
	local x, y = ph.x, ph.y
	local charge_num = NumberBar.New()
	charge_num:SetRootPath(ResPath.GetCommon("num_150_"))
	charge_num:SetPosition(x, y - 10)
	charge_num:SetSpace(-1)
	self.need_charge_num = charge_num
	self.need_charge_num:SetGravity(NumberBarGravity.Center)
	self:GetView():addChild(charge_num:GetView(), 100, 100)
end

-- 创建选中特效
function AccumulAwardListRender:CreateSelectEffect()
end

-- 领取奖励按钮回调
function AccumulAwardListRender:OnClickReceive()
	local act_id = CombinedServerActData.GetActIdByIndex(TabIndex.combinedserv_accumulative)
	CombinedServerActCtrl.SendSendCombinedReq(act_id,self.data.index)
end
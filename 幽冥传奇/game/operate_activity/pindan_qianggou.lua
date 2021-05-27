-- 拼单抢购界面
PinDanQiangGouPage = PinDanQiangGouPage or BaseClass()

function PinDanQiangGouPage:__init()
	self.view = nil

end

function PinDanQiangGouPage:__delete()
	self:RemoveEvent()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	if self.pindan_list then
		self.pindan_list:DeleteMe()
		self.pindan_list = nil 
	end

	if self.my_pindan_list then
		self.my_pindan_list:DeleteMe()
		self.my_pindan_list = nil 
	end

	self.view = nil
end



function PinDanQiangGouPage:InitPage(view)
	self.view = view
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnDiscountTreasureEvent()
end

function PinDanQiangGouPage:InitEvent()
	-- self.view.node_t_list.rich_pd_qianggou_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	-- XUI.AddClickEventListener(self.view.node_t_list.btn_recharge_1.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)
	self.discount_treasure_event = GlobalEventSystem:Bind(OperateActivityEventType.PIN_DAN_DATA_CHANGE, BindTool.Bind(self.OnDiscountTreasureEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
	-- self:FlushTime()
end

function PinDanQiangGouPage:RemoveEvent()
	if self.discount_treasure_event then
		GlobalEventSystem:UnBind(self.discount_treasure_event)
		self.discount_treasure_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function PinDanQiangGouPage:CreateAwarInfoList()
	if self.tabbar == nil then
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.view.node_t_list.layout_pd_tabbar.node, 0, 0, BindTool.Bind(self.OnSelectCallback, self), 
			Language.OperateActivity.PinDanTabGroup, 
			is_vertical, ResPath.GetCommon("toggle_104_normal"), 18)
	end
	local ph = self.view.ph_list.ph_pd_qianggou_list
	self.pindan_list = ListView.New()
	self.pindan_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperActPinDanRender, nil, nil, self.view.ph_list.ph_pd_qianggou_item)
	self.pindan_list:SetItemsInterval(10)

	self.pindan_list:SetJumpDirection(ListView.Top)
	self.view.node_t_list.layout_pindan_qianggou.node:addChild(self.pindan_list:GetView(), 200)

	self.my_pindan_list = ListView.New()
	self.my_pindan_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperActMyPinDanRender, nil, nil, self.view.ph_list.ph_my_pd_qianggou_item)
	self.my_pindan_list:SetItemsInterval(10)

	self.my_pindan_list:SetJumpDirection(ListView.Top)
	self.view.node_t_list.layout_pindan_qianggou.node:addChild(self.my_pindan_list:GetView(), 200)

end

function PinDanQiangGouPage:OnSelectCallback(index)
	if self.pindan_list and self.my_pindan_list then
		self.pindan_list:GetView():setVisible(index == 1)
		self.my_pindan_list:GetView():setVisible(index == 2)
	end
end

function PinDanQiangGouPage:OnDiscountTreasureEvent()
	self:FlushTime()
	local data = OperateActivityData.Instance:GetCurPinDanList()
	-- PrintTable(data)
	self.pindan_list:SetDataList(data)
	data = OperateActivityData.Instance:GetMyPinDanList()
	self.my_pindan_list:SetDataList(data)
end

-- 倒计时
function PinDanQiangGouPage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.text_pd_qianggou_time then
		self.view.node_t_list.text_pd_qianggou_time.node:setString(time_str)
	end
end

function PinDanQiangGouPage:OnClickChongzhiHandler()
	-- if self.view then
	-- 	self.view:Close()
	-- 	ViewManager.Instance:Open(ViewName.ChargePlatForm)
	-- end
end

function PinDanQiangGouPage:UpdateData(param_t)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU)
	end
	local des = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU).act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_pd_qianggou_des.node, des, 24, COLOR3B.YELLOW)

	self.pindan_list:GetView():setVisible(true)
	self.my_pindan_list:GetView():setVisible(false)
	self.tabbar:ChangeToIndex(1)
end



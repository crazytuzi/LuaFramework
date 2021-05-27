-- 运营活动竞技类活动页面
OperateSportsActPage = OperateSportsActPage or BaseClass()

function OperateSportsActPage:__init()
	self.view = nil
	self.last_act_id = 1
end	

function OperateSportsActPage:__delete()
	self:RemoveEvent()

	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	self.last_act_id = 1
	self.view = nil
end	

--初始化页面接口
function OperateSportsActPage:InitPage(view)
	--绑定要操作的元素
	if self.view then return end
	self.view = view
	self:CreateAwardList()
	self:InitEvent()
	XUI.RichTextSetCenter(self.view.node_t_list.rich_get_exp.node)
end	

--初始化事件
function OperateSportsActPage:InitEvent()
	self.exp_evt = GlobalEventSystem:Bind(OperateActivityEventType.SPORTS_TYPE_DATA_CHANGE, BindTool.Bind(self.OnExpSportsDataChange, self))
 	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

--移除事件
function OperateSportsActPage:RemoveEvent()
	if self.exp_evt then
		GlobalEventSystem:UnBind(self.exp_evt)
		self.exp_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

end

function OperateSportsActPage:CreateAwardList()
	if not self.list_view then
		local ph = self.view.ph_list.ph_item_list_1
		self.list_view = ListView.New()
		self.list_view:Create(ph.x, ph.y, ph.w, ph.h, direction, OperateSportsItem, nil, false, self.view.ph_list.ph_list_item_1)
		self.list_view:SetItemsInterval(2)
		self.list_view:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_exp_sports.node:addChild(self.list_view:GetView(), 100)
	end
end

--更新视图界面
function OperateSportsActPage:UpdateData(data)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(self.view.selec_act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, self.view.selec_act_id)
	end
end

function OperateSportsActPage:OnExpSportsDataChange()
	local data = OperateActivityData.Instance:GetStandardSportsDataByActId(self.view.selec_act_id)
	if nil == data then return end
	self:SetGetAttrVal(data)
	self:FlushRemainTime()
	if self.list_view then
		self.list_view:SetDataList(data.awards_info)
		if self.last_act_id ~= self.view.selec_act_id then
			self.last_act_id = self.view.selec_act_id
			self.list_view:JumpToTop(true)
		end
	end
end

function OperateSportsActPage:SetGetAttrVal(data)
	local attr_name = OperateActivityData.GetAttrNameByActID(self.view.selec_act_id)
	local val = data.value or 0
	local content = string.format(Language.OperateActivity.HasSome, val, attr_name)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_get_exp.node, content, 20)
end

function OperateSportsActPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(self.view.selec_act_id)

	if self.view.node_t_list.lbl_exp_remain_time then
		self.view.node_t_list.lbl_exp_remain_time.node:setString(time)
	end
end

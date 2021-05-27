	-- 累计登陆界面
OperateActAddupLoginPage = OperateActAddupLoginPage or BaseClass()

function OperateActAddupLoginPage:__init()
	self.view = nil

end

function OperateActAddupLoginPage:__delete()
	self:RemoveEvent()

	if self.can_reward_avtivity_list then
		self.can_reward_avtivity_list:DeleteMe()
		self.can_reward_avtivity_list = nil 
	end

	self.view = nil
end



function OperateActAddupLoginPage:InitPage(view)
	self.view = view
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnAddupLoginEvent()
end

function OperateActAddupLoginPage:InitEvent()
	self.addup_login_event = GlobalEventSystem:Bind(OperateActivityEventType.ADDUP_LOGIN_DATA_CHANGE, BindTool.Bind(self.OnAddupLoginEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

function OperateActAddupLoginPage:RemoveEvent()
	if self.addup_login_event then
		GlobalEventSystem:UnBind(self.addup_login_event)
		self.addup_login_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function OperateActAddupLoginPage:CreateAwarInfoList()
	local ph = self.view.ph_list.ph_list_addup_login
	self.can_reward_avtivity_list = ListView.New()
	self.can_reward_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperateActAddupLoginRender, nil, nil, self.view.ph_list.ph_addup_login_award_item)
	self.can_reward_avtivity_list:SetItemsInterval(10)

	self.can_reward_avtivity_list:SetJumpDirection(ListView.Top)
	self.view.node_t_list.layout_addup_login.node:addChild(self.can_reward_avtivity_list:GetView(), 20)

end

function OperateActAddupLoginPage:OnAddupLoginEvent()
	self:FlushTime()
	local data = TableCopy(OperateActivityData.Instance:GetAddupLoginData())
	local function sort_func()
		return function(a, b)
			if a.state == b.state then
				return a.idx < b.idx
			else
				if a.state ~= 2 and b.state ~= 2 then
					return a.state > b.state
				else
					local order_a = 1000
					local order_b = 1000
					if a.state == 2 then
						order_b = order_b + 100
					else
						order_a = order_a + 100
					end

					return order_a > order_b
				end
			end
		end
	end
	table.sort(data, sort_func())
	self.can_reward_avtivity_list:SetDataList(data)
end

-- 倒计时
function OperateActAddupLoginPage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.ADDUP_LOGIN)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.txt_addup_login_time then
		self.view.node_t_list.txt_addup_login_time.node:setString(time_str)
	end
end

function OperateActAddupLoginPage:UpdateData(param_t)
	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.ADDUP_LOGIN)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_addup_login_des.node, content, 24, COLOR3B.YELLOW)
end



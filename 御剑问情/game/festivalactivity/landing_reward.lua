LandingReward = LandingReward or BaseClass(BaseRender)

function LandingReward:__init(instance)
	self.reward_list = {}
	self.list_view = self:FindObj("ListView")
	self.list_view_delegate = self.list_view.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.rest_time = self:FindVariable("rest_time")
end

function LandingReward:__delete()
	if self.reward_list then
		for k,v in pairs(self.reward_list) do
			v:DeleteMe()
		end
		self.reward_list = {}
	end
	self.rest_time = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function LandingReward:OpenCallBack()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LANDINGF_REWARD,RA_LOGIN_ACTIVE_GIFT_REQ_TYPE.RA_LOGIN_ACTIVE_GIFT_REQ_TYPE_INFO)
end

function LandingReward:CloseCallBack()
end

function LandingReward:OnFlush(param_list)
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function LandingReward:GetNumberOfCells()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().login_active_gift
	local reward_list = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LANDINGF_REWARD) or {}
	return #reward_list or 0
end

function LandingReward:RefreshView(cell, data_index)
	local index = data_index + 1
	local itemcell = self.reward_list[cell]

    if nil == itemcell then
        itemcell = LandingRewardItemCell.New(cell.gameObject)
        self.reward_list[cell] = itemcell
    end
    local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().login_active_gift
    local reward_list = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LANDINGF_REWARD) or {}
    local login_fetch_flag = LandingRewardData.Instance:GetLoginFetchFlag()
	local vip_fetch_flag = LandingRewardData.Instance:GetVipFetchFlag()
	local total_login_fetch_flag = LandingRewardData.Instance:GetTotalLoginFetchFlag()
	table.sort(reward_list, function(a,b)
		local order_a = 0
		local order_b = 0
		local order_c = 0
		local order_d = 0
		if a.gift_type == 0 then
			order_a = login_fetch_flag[32 - a.seq]
			order_c = a.gift_type
		elseif a.gift_type == 1 then
			order_a = vip_fetch_flag[32 - a.seq]
			order_c = a.gift_type
		elseif a.gift_type == 2 then
			order_a = total_login_fetch_flag[32 - a.seq]
			order_c = a.gift_type
		end
		if b.gift_type == 0 then
			order_b = login_fetch_flag[32 - b.seq]
			order_d = b.gift_type
		elseif b.gift_type == 1 then
			order_b = vip_fetch_flag[32 - b.seq]
			order_d = b.gift_type
		elseif b.gift_type == 2 then
			order_b = total_login_fetch_flag[32 - b.seq]
			order_d = b.gift_type
		end
		-- return order_a <= order_b
		if order_a < order_b then
			return order_a < order_b
		elseif order_a == order_b then
			if order_c < order_d then
				return order_c < order_d
			end
		end
	end )
    self.reward_list[cell]:SetData(reward_list[index])
    self.reward_list[cell]:Flush()
    -- self.reward_list[cell]:SetIndex(data_index)
end

function LandingReward:FlushView()

end

function LandingReward:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LANDINGF_REWARD)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_type = 1
	if time > 3600 * 24 then
		time_type = 7
	elseif time > 3600 then
		time_type = 1
	else
		time_type = 4
	end

	self.rest_time:SetValue(TimeUtil.FormatSecond(time, time_type))
end

function LandingReward:CloseCallBack()
	-- body
end

----------------------------LandingRewardItemCell---------------
LandingRewardItemCell = LandingRewardItemCell or BaseClass(BaseCell)
function LandingRewardItemCell:__init()
	self.item_cell_list = {}
	self.item_cell_obj_list = {}
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end
	self.show_interactable = self:FindVariable("show_interactable")
	self.show_text = self:FindVariable("show_text")
	self.can_lingqu = self:FindVariable("can_lingqu")
	self.image = self:FindVariable("image")
	-- show_interactable:SetValue(true)
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
end

function LandingRewardItemCell:__delete()
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	self.show_interactable = nil
	self.show_text = nil
	self.can_lingqu = nil
	self.image = nil
end

function LandingRewardItemCell:SetData(data)
	self.data = data
end

function LandingRewardItemCell:OnFlush()
	local reward_list = {}
	if self.data == nil or next(self.data) == nil then return end
	if (#self.data.reward_item + 1) <= 1 then
		reward_list = ServerActivityData.Instance:GetCurrentRandActivityRewardCfg(self.data.reward_item, true)
	else
		-- if #self.data.reward_item == 0 then return end
		for k = 0 ,#self.data.reward_item do
			table.insert(reward_list,self.data.reward_item[k])
		end
	end
	for i = 1, 4 do
		if reward_list[i] and i <= #reward_list then
			self.item_cell_list[i]:SetData(reward_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end
	local is_today_login = LandingRewardData.Instance:GetIsTodayLogin()
	local total_login_days = LandingRewardData.Instance:GetTotalLoginDays()
	local login_fetch_flag = LandingRewardData.Instance:GetLoginFetchFlag()
	local vip_fetch_flag = LandingRewardData.Instance:GetVipFetchFlag()
	local total_login_fetch_flag = LandingRewardData.Instance:GetTotalLoginFetchFlag()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	if self.data.gift_type == 0 then
		self.image:SetAsset(ResPath.GetLoginRewardTypeName(self.data.gift_type))
		if is_today_login == 1 and login_fetch_flag[32 - self.data.seq] == 0 then
			self.show_interactable:SetValue(true)
			self.can_lingqu:SetValue(true)
		elseif is_today_login == 1 and login_fetch_flag[32 - self.data.seq] == 1 then
			self.show_text:SetValue(Language.Common.YiLingQu)
			self.show_interactable:SetValue(false)
			self.can_lingqu:SetValue(false)
		else
			self.show_interactable:SetValue(false)
			self.can_lingqu:SetValue(false)
		end
	elseif self.data.gift_type == 1 then
		self.image:SetAsset(ResPath.GetLoginRewardTypeName(self.data.gift_type))
		if main_role_vo.vip_level >= self.data.condition_param and is_today_login == 1 and vip_fetch_flag[32 - self.data.seq] == 0  then
			self.show_interactable:SetValue(true)
			self.can_lingqu:SetValue(true)
		elseif main_role_vo.vip_level >= self.data.condition_param and is_today_login == 1 and vip_fetch_flag[32 - self.data.seq] == 1 then
			self.show_interactable:SetValue(false)
			self.can_lingqu:SetValue(false)
			self.show_text:SetValue(Language.Common.YiLingQu)
		else
			self.show_interactable:SetValue(false)
			self.can_lingqu:SetValue(false)
		end
	elseif self.data.gift_type == 2 then
		self.image:SetAsset(ResPath.GetLoginRewardTypeName(self.data.gift_type))
		if total_login_days >= self.data.condition_param and total_login_fetch_flag[32 - self.data.seq] == 0 then
			self.show_interactable:SetValue(true)
			self.can_lingqu:SetValue(true)
		elseif total_login_days >= self.data.condition_param and total_login_fetch_flag[32 - self.data.seq] == 1 then
			self.show_interactable:SetValue(false)
			self.can_lingqu:SetValue(false)
			self.show_text:SetValue(Language.Common.YiLingQu)
		else
			self.show_interactable:SetValue(false)
			self.can_lingqu:SetValue(false)
		end
	end
end

function LandingRewardItemCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LANDINGF_REWARD,RA_LOGIN_ACTIVE_GIFT_REQ_TYPE.RA_LOGIN_ACTIVE_GIFT_REQ_TYPE_FETCH,self.data.gift_type,self.data.seq)
end
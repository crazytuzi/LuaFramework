HeFuPVPView = HeFuPVPView or BaseClass(BaseRender)

function HeFuPVPView:__init()
	self.hefu_cur_day = 1
end

function HeFuPVPView:__delete()

end


function HeFuPVPView:LoadCallBack()
	self.content = self:FindVariable("Content")
	self.cur_day = self:FindVariable("CurDay")
	self.title_bg = self:FindVariable("Title_bg")

	self.cell_list = {}	
	self.pvp_activity_list = self:FindObj("HeFuActivityEnter")
	self.list_view_delegate = self.pvp_activity_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self:Flush()

end

function HeFuPVPView:ReleaseCallBack()
	self.content = nil
	self.cur_day = nil
	self.title_bg = nil
	self.pvp_activity_list = nil

	self.cell_list = {}
end

function HeFuPVPView:RefreshView(cell,data_index)
	--data_index = data_index + 1

	local pvp_activity_item_cell = self.cell_list[cell]
	if pvp_activity_item_cell == nil then
		pvp_activity_item_cell = PvpActivityCell.New(cell.gameObject,data_index)  
		self.cell_list[cell] = pvp_activity_item_cell
	end
	pvp_activity_item_cell:SetIndex(data_index)
	if next(HefuActivityData.Instance:GetPvpActivity()) then
		local data = HefuActivityData.Instance:GetPvpActivity()
		pvp_activity_item_cell:SetCurDay(self.hefu_cur_day)
		pvp_activity_item_cell:SetData(data[data_index]) --调用Onflush

	end
end

--合服活动创建的条数
function HeFuPVPView:GetNumberOfCells()
	return #HefuActivityData.Instance:GetPvpActivity() + 1
end

function HeFuPVPView:OnFlush()
	self:SetHeFuCurDay()
	local data = HefuActivityData.Instance:GetPvpActivity()[self.hefu_cur_day]
	if data ~= nil then
		local bundle, asset = ResPath.GetKaiFuActivityRes("combine_pvp_" .. data.seq)
		self.title_bg:SetAsset(bundle, asset)
		self.content:SetValue(data.describe)
		self.cur_day:SetValue(Language.Common.NumToChs[data.seq + 1])
	end
end


function  HeFuPVPView:SetHeFuCurDay()
	local cur_day = HefuActivityData.Instance:GetCombineDays()
	if cur_day >= 3 then
		cur_day = cur_day % 3
	end
	self.hefu_cur_day = cur_day
end

----------------------pvp活动item--------------------------------------

PvpActivityCell = PvpActivityCell or BaseClass(BaseCell)
function PvpActivityCell:__init(instance) --根据排名来获取格子里面该显示什么
	self.cur_day = -1
	self.hefu_day = self:FindVariable("HeFuDay")
	self.title = self:FindVariable("Title")
	self.btn_text = self:FindVariable("BtnText")
	self.enter_btn_enble = self:FindVariable("BtnEnble")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self:ListenEvent("OnClickEnter", BindTool.Bind(self.OnClickEnter, self))
end

function PvpActivityCell:__delete()
	self.parent_view = nil
end

function PvpActivityCell:LoadCallBack()
	self.rank_reward_list = {}
	for i = 1, 5 do
		self.rank_reward_list[i] = ItemCell.New()
		self.rank_reward_list[i]:SetInstanceParent(self:FindObj("RewardItemCell" .. i))
		self.rank_reward_list[i]:SetActive(false) 
	end
	self:Flush() 
end

function PvpActivityCell:ReleaseCallBack()
	for _,v in pairs(self.rank_reward_list) do
		v:DeleteMe()
		v = nil
	end
	self.rank_reward_list = {}
 end

function PvpActivityCell:OnFlush()
	if nil == self.data then return end

	self.hefu_day:SetValue(Language.Common.NumToChs[self.data.seq + 1])
	self.title:SetValue(self.data.activityname)
	self.enter_btn_enble:SetValue(self.cur_day == self.data.seq)
	if self.cur_day == self.data.seq then
		self.btn_text:SetValue(Language.Common.QianWang)
		local activity_info = ActivityData.Instance:GetActivityStatuByType(self.data.open_param)
		if activity_info  then
			if activity_info.status == ACTIVITY_STATUS.OPEN then
				self.show_red_point:SetValue(true)
			else
				self.show_red_point:SetValue(false)
			end
		end
	elseif self.cur_day > self.data.seq then
		self.btn_text:SetValue(Language.Activity.YiJieShuDes)
	else
		self.btn_text:SetValue(Language.Activity.YiJieShu)
	end

	--放入奖励
	if self.data.reward_item then
		for k,v in pairs(self.data.reward_item) do
			self.rank_reward_list[k + 1]:SetActive(true)
			self.rank_reward_list[k + 1]:SetData(v)
		end
	end

end

function PvpActivityCell:SetCurDay(cur_day)
	self.cur_day = cur_day
end

--点击进入pvp活动
function PvpActivityCell:OnClickEnter()
	ActivityCtrl.Instance:ShowDetailView(self.data.open_param)
end

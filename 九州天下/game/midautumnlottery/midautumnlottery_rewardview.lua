MidAutumnLotteryRewardView = MidAutumnLotteryRewardView or BaseClass(BaseView)

function MidAutumnLotteryRewardView:__init()
	self.ui_config = {"uis/views/midautumn","MidAutumnRewardView"}
	self.play_audio = true
	self.is_async_load = false
	self:SetMaskBg(true)
end

function MidAutumnLotteryRewardView:__delete()

end

function MidAutumnLotteryRewardView:ReleaseCallBack()
	self.draw_times = nil
	self.max_draw_times = nil 

	self.display = nil
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end 

	self.reward_list = nil
	for _,v in pairs(self.reward_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.reward_cell_list = {}
end 

function MidAutumnLotteryRewardView:LoadCallBack()
	self.draw_times = self:FindVariable("draw_times")
	self.max_draw_times = self:FindVariable("max_draw_times")
	self.display = self:FindObj("Display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	self.reward_cell_list = {}
	self.reward_list = self:FindObj("RewarList")
	local list_view_delegate = self.reward_list.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self:ListenEvent("OnCloseBtnClick", BindTool.Bind(self.OnCloseBtnClick, self)) 

	self:Flush()
end

function MidAutumnLotteryRewardView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY,
		RA_HAPPY_DRAW2_OPERA_TYPE.RA_HAPPY_DRAW2_OPERA_TYPE_INFO)
	self:Flush()
end 

function MidAutumnLotteryRewardView:GetNumberOfCells() 
	 return MidAutumnLotteryData.Instance:GetBaoDiRewardCfgLength() or 5
end

function MidAutumnLotteryRewardView:RefreshView(cell,data_index) 
	data_index =  data_index + 1
	local reward_cell = self.reward_cell_list[cell]
	if reward_cell == nil then
		reward_cell = MidAutumnRewardItem.New(cell.gameObject)
		self.reward_cell_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
end

function MidAutumnLotteryRewardView:OnFlush()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if self.model then
		local clothing = FashionData.Instance:GetClothingConfig(22)
		local wuqi = FashionData.Instance:GetWuqiConfig(22)
		if clothing ~= nil and wuqi ~= nil then
			self.model:SetRoleResid(clothing["resouce" .. vo.prof .. vo.sex])
			self.model:SetWeaponResid(wuqi["resouce" .. vo.prof .. vo.sex])
		end
	end
	self.draw_times:SetValue(MidAutumnLotteryData.Instance:GetDrawTimes()) 
	self.max_draw_times:SetValue(MidAutumnLotteryData.Instance:GetMaxDrawTimes())

	if self.reward_list.scroller.isActiveAndEnabled then
		self.reward_list.scroller:RefreshAndReloadActiveCellViews(true)
	end  
end

function MidAutumnLotteryRewardView:OnCloseBtnClick()
	self:Close()
end

-- ------------------------------------------------------------------------------------------
-- MidAutumnRewardItem = MidAutumnRewardItem or BaseClass(BaseCell)
-- function MidAutumnRewardItem:__init()
-- 	self.draw_times = self:FindVariable("draw_times")
-- 	self.is_received = self:FindVariable("is_received")

-- 	self.item_cell_list = {} 
-- 	for i = 1, 2 do
-- 		self.item_cell_list[i] = ItemCell.New()
-- 		self.item_cell_list[i]:SetInstanceParent(self:FindObj("item_cell" .. i))
-- 	end
-- 	self.data_index = 0
-- end

-- function MidAutumnRewardItem:__delete()
-- 	self.draw_times = nil
-- 	self.is_received = nil

-- 	for i = 1, 2 do
-- 		if self.item_cell_list[i] then
-- 			self.item_cell_list[i]:DeleteMe()
-- 		end
-- 	end
-- 	self.item_cell_list = {}
-- end 

-- function MidAutumnRewardItem:SetIndex(index)
-- 	self.data_index = index
-- 	self.reward_cfg = MidAutumnLotteryData.Instance:GetHappydraw2BaoDiSortRewardCfg()[self.data_index]   
-- 	self:Flush()
-- end

-- function MidAutumnRewardItem:OnFlush() 
-- 	if self.reward_cfg ~= nil then 
-- 		self.draw_times:SetValue(self.reward_cfg.draw_times)
-- 		self.is_received:SetValue(self.reward_cfg.is_received == 1)
-- 		local gift_item_list = ItemData.Instance:GetGiftItemList(self.reward_cfg.reward.item_id)
-- 		for i=1,#gift_item_list do
-- 			self.item_cell_list[i]:SetData({item_id = gift_item_list[i].item_id,num = gift_item_list[i].num})
-- 		end
-- 	end 
-- end
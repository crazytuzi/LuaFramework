TipsPetAttributeView = TipsPetAttributeView or BaseClass(BaseView)
function TipsPetAttributeView:__init()
	self.ui_config = {"uis/views/tips/pettips", "ShowPetAttributeTips"}
	self.view_layer = UiLayer.Pop
	self.contain_cell_list = {}
	self.play_audio = true
end

function TipsPetAttributeView:__delete()
end

function TipsPetAttributeView:LoadCallBack()
	self:InitListView()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
end

function TipsPetAttributeView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipsPetAttributeView:GetNumberOfCells()
	return math.ceil(PetData.Instance:GetAllInfoList().pet_count/3)
end

function TipsPetAttributeView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TipsPetAttributeContent.New(cell.gameObject)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetAllPetInfo(PetData.Instance:GetShowPetInfoList(cell_index))
end

function TipsPetAttributeView:OnCloseClick()
	self:Close()
end

function TipsPetAttributeView:CloseCallBack()
	for k,v in pairs(self.contain_cell_list) do
		v:CancelAllQuest()
	end
end

function TipsPetAttributeView:Reload()
	self.list_view.scroller:ReloadData(0)
end

function TipsPetAttributeView:OnFlushAll()
	for k,v in pairs(self.contain_cell_list) do
		v:OnFlushAll()
	end
end
-----------------------------------------------------------------
TipsPetAttributeContent = TipsPetAttributeContent  or BaseClass(BaseCell)

function TipsPetAttributeContent:__init()
	self.attribute_item_list = {}
	for i = 1, 3 do
		self.attribute_item_list[i] = TipsPetAttributeItem.New(self:FindObj("item_" .. i))
	end
end

function TipsPetAttributeContent:SetAllPetInfo(pet_info_list)
	for i = 1, 3 do
		self.attribute_item_list[i]:SetPetInfo(pet_info_list[i])
	end
end

function TipsPetAttributeContent:OnFlushAll()
	for i = 1, 3 do
		self.attribute_item_list[i]:OnFlush()
	end
end

function TipsPetAttributeContent:CancelAllQuest()
	for i = 1, 3 do
		self.attribute_item_list[i]:CancelCalTime()
	end
end
-----------------------------------------------------------------
TipsPetAttributeItem = TipsPetAttributeItem  or BaseClass(BaseCell)

function TipsPetAttributeItem:__init()
	self.qixue_text = self:FindVariable("qixue_text")
	self.gongji_text = self:FindVariable("gongji_text")
	self.fangyu_text = self:FindVariable("fangyu_text")
	self.mingzhong_text = self:FindVariable("mingzhong_text")
	self.shanbi_text = self:FindVariable("shanbi_text")
	self.baoji_text = self:FindVariable("baoji_text")
	self.kangbao_text = self:FindVariable("kangbao_text")
	self.power_text = self:FindVariable("power_text")
	self.countdown_text = self:FindVariable("countdown_text")
	self.add_gongji_text = self:FindVariable("add_gongji_text")
	self.add_fangyu_text = self:FindVariable("add_fangyu_text")
	self.add_qixue_text = self:FindVariable("add_qixue_text")
	self.add_mingzhong_text = self:FindVariable("add_mingzhong_text")
	self.add_shanbi_text = self:FindVariable("add_shanbi_text")
	self.add_baoji_text = self:FindVariable("add_baoji_text")
	self.add_kangbao_text = self:FindVariable("add_kangbao_text")
	self.name_text = self:FindVariable("name_text")
	self.state_text = self:FindVariable("state_text")
	self.pet_info = pet_info
end

function TipsPetAttributeItem:SetPetInfo(pet_info)
	if not next(pet_info) then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	self.pet_info = pet_info
	self:OnFlush()
end

function TipsPetAttributeItem:OnFlush()
	local pet_data = PetData.Instance
	self.name_text:SetValue(pet_data:GetPetQualityName(self.pet_info))
	self.qixue_text:SetValue(self.pet_info.maxhp)
	self.gongji_text:SetValue(self.pet_info.gongji)
	self.fangyu_text:SetValue(self.pet_info.fangyu)
	self.mingzhong_text:SetValue(self.pet_info.mingzhong)
	self.shanbi_text:SetValue(self.pet_info.shanbi)
	self.baoji_text:SetValue(self.pet_info.baoji)
	self.kangbao_text:SetValue(self.pet_info.kangbao)
	local is_rich_feed = pet_data:IsRichFeed(self.pet_info.id, self.pet_info.feed_degree)

	local jia_cheng = pet_data:GetSingleQuality(self.pet_info.id).add_attr_percent /100
	if is_rich_feed then
		self.add_gongji_text:SetValue(self.pet_info.gongji * jia_cheng)
		self.add_fangyu_text:SetValue(self.pet_info.fangyu * jia_cheng)
		self.add_qixue_text:SetValue(self.pet_info.maxhp * jia_cheng)
		self.add_mingzhong_text:SetValue(self.pet_info.mingzhong * jia_cheng)
		self.add_shanbi_text:SetValue(self.pet_info.shanbi * jia_cheng)
		self.add_baoji_text:SetValue(self.pet_info.baoji * jia_cheng)
		self.add_kangbao_text:SetValue(self.pet_info.kangbao * jia_cheng)
	else
		self.add_gongji_text:SetValue(0)
		self.add_fangyu_text:SetValue(0)
		self.add_qixue_text:SetValue(0)
		self.add_mingzhong_text:SetValue(0)
		self.add_shanbi_text:SetValue(0)
		self.add_baoji_text:SetValue(0)
		self.add_kangbao_text:SetValue(0)
	end
	if self.pet_info.info_type == 1 then
		self.state_text:SetValue("自己")
	else
		self.state_text:SetValue("伴侣")
	end
	self.power_text:SetValue(CommonDataManager.GetCapability(self.pet_info))
	local max_feed_degree = PetData.Instance:GetSingleQuality(self.pet_info.id).max_feed_degree
	if self.pet_info.feed_degree < max_feed_degree then
		self.countdown_text:SetValue("暂未达到饱食")
	else
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self:FlushTime()
	end
	-- self.kangbao_text:SetValue(self.pet_info.)
	-- self.power_text:SetValue()
	-- self.countdown_text:SetValue()
end

function TipsPetAttributeItem:FlushTime()
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		local feed_clear_interval_h = PetData.Instance:GetOtherCfg()[1].feed_clear_interval_h
		local can_chest_time = self.pet_info.baoshi_active_time

		can_chest_time = can_chest_time + (feed_clear_interval_h * 3600)
		local remain_time = can_chest_time - math.floor(TimeCtrl.Instance:GetServerTime())

		if remain_time < 0 then
			self.countdown_text:SetValue("暂未达到饱食")
			GlobalTimerQuest:CancelQuest(self.timer_quest)
		else
			local remain_hour = tostring(math.floor(remain_time / 3600))
			local remain_min = tostring(math.floor((remain_time - remain_hour * 3600) / 60))
			local remain_sec = tostring(math.floor(remain_time - remain_hour * 3600 - remain_min * 60))
			local show_time = remain_hour .. ":" .. remain_min .. ":" .. remain_sec
			self.countdown_text:SetValue(show_time)
		end
	end, 0)
end

function TipsPetAttributeItem:CancelCalTime()
	GlobalTimerQuest:CancelQuest(self.timer_quest)
end
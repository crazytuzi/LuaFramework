SlaughterDevilContent = SlaughterDevilContent or BaseClass(BaseRender)

function SlaughterDevilContent:__init()
	self.cur_select_index = 0
	self.init_scorller_num = 0
	self.name = self:FindVariable("Name")
	self.introduce = self:FindVariable("IntroduceText")
	self.level = self:FindVariable("level")
	self.total_num = self:FindVariable("total_num")
	self.cur_num = self:FindVariable("cur_num")
	self.slider_num = self:FindVariable("slider_num")
	self.first_name = self:FindVariable("first_name")
	self.title = self:FindVariable("title")
	self.title_obj = self:FindObj("title_obj")
	self.chapter = self:FindVariable("chapter")
	self.bg_chapter = self:FindVariable("bg_chapter")
	self.show_next1 = self:FindVariable("show_next1")
	self.show_next2 = self:FindVariable("show_next2")
	self.star_num = self:FindVariable("star_num")
	self.next_red1 = self:FindVariable("next_red1")
	self.next_red2 = self:FindVariable("next_red2")
	self.item_icon = self:FindVariable("item_icon")
	self.item_num = self:FindVariable("item_num")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.show_tips = true

	self.turntable_info = TurntableInfoCell.New(self:FindObj("Turntable"))

	self:InitMapList()
	self:InitRewardList()
	
	self.fight_power = self:FindVariable("fight_power")

	self:ListenEvent("ClickAdd", BindTool.Bind(self.ClickAdd, self))
	for i=1, 2 do
		self:ListenEvent("ClickNext_" .. i, BindTool.Bind2(self.ClickNext, self, i))
	end
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
end

function SlaughterDevilContent:InitMapList()
	self.map_list = self:FindObj("MapList")
	self.cell_list = {}
	self.scroller = self.map_list.scroller
	self.map_list.scroll_rect.horizontal = false
	local list_delegate = self.map_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMapNumberOfCell, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMapCell, self)
end
 
function SlaughterDevilContent:GetMapNumberOfCell()
	return SlaughterDevilData.Instance:GetMapListNum()
end

function SlaughterDevilContent:RefreshMapCell(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.cell_list[cell]
	local data_list = SlaughterDevilData.Instance:GetMapList()
	if not item_cell then
		item_cell = SlaughterFBMapChapter.New(cell.gameObject)
		self.cell_list[cell] = item_cell
	end
	item_cell:SetIndex(cell_index)
	if data_list[cell_index - 1] then
		item_cell:SetData(data_list[cell_index - 1])
		item_cell:SetClickCallBack(function (data)
			self:OnClickMapItem(data)
		end)
	end
end

function SlaughterDevilContent:OnClickMapItem(data)
	self:Flush()
	local data_list = SlaughterDevilData.Instance:GetMapList()
	SlaughterDevilCtrl.Instance:SetDataAndOpenTipsView(data_list[self.cur_select_index][data - 1])
end

function SlaughterDevilContent:InitRewardList()
	self.reward_list = self:FindObj("RewardList")
	self.reward_cell_list = {}
	local num = self:GetRewardNumberOfCell()
	for i = 1, num do
		local item_cell = SlaghterMapReward.New(self:FindObj("reward" .. i))
		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickRewardItem, self))
		table.insert(self.reward_cell_list, item_cell)
	end
end

function SlaughterDevilContent:CloseCallBack()
	
end
 
function SlaughterDevilContent:GetRewardNumberOfCell()
	return SlaughterDevilData.Instance:GetRewardListNum(self.cur_select_index)
end


function SlaughterDevilContent:OnClickRewardItem(data, can_open)
	if can_open then
		SlaughterDevilCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_FETCH_STAR_REWARD, data.chapter, data.seq)
	else
		TipsCtrl.Instance:ShowRewardView(data.reward)
	end
end

function SlaughterDevilContent:OpenCallBack()
	SlaughterDevilData.Instance:CloseInitRed()
	RemindManager.Instance:Fire(RemindName.SlaughterDevil)
	-- SlaughterDevilCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_GETNAME)
	local view_data = SlaughterDevilData.Instance:GetViewData()
	local position = (view_data.pass_chapter + 1) / self:GetMapNumberOfCell()

	self.cur_select_index = view_data.pass_chapter + 1
	if view_data.pass_chapter == SlaughterDevilData.Instance:GetMaxChapter() then
		self.cur_select_index = view_data.pass_chapter
	end
	-- self:JumpToIndex(view_data.pass_chapter + 1)
	self.scroller:ReloadData(1)
	self:Flush()
end

function SlaughterDevilContent:IsShowEffect()
	self.turntable_info:SetShowEffect(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
end

function SlaughterDevilContent:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil

	for k, v in pairs(self.reward_cell_list) do
		v:DeleteMe()
	end
	self.reward_cell_list = nil

	if self.turntable_info ~= nil then
		self.turntable_info:DeleteMe()
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SlaughterDevilContent:OnFlush(param_list)
	self:ConstructData()
	self:SetFlag()
	for k,v in pairs(param_list) do
		
	end
	self:SetModel()
	self:SetInfo()
	self:FLushReward()
	self:IsShowEffect()
end

function SlaughterDevilContent:ConstructData()
	self.construct = true
	local data_instance = SlaughterDevilData.Instance
	local data = data_instance:GetData(self.cur_select_index)
	if data == nil then
		self.construct = false
		return
	end
	self.name_value = data[0].fb_name 
	self.introduce_value = data[0].introduce
	self.level_value = data[0].chapter
	self.fight_power_value = data[0].fight_power
	local view_data = data_instance:GetViewData()
	self.total_num_value = view_data.total_num
	self.cur_num_value = view_data.cur_num
	self.slider_value = view_data[self.cur_select_index].cur_star / view_data[self.cur_select_index].total_star
	self.first_name_value = view_data[self.cur_select_index].title_name
	self.card_id = view_data.card_id
	if view_data[self.cur_select_index].title_id then
		self.title_res = view_data[self.cur_select_index].title_id
	else
		self.title_res = view_data[0].title_id
	end
	self.next_red2_value = false
	self.star_num_value = view_data[self.cur_select_index].cur_star
	for i = 0, self.cur_select_index - 1 do
		if view_data[i].red then
			self.next_red2_value = true
			break
		end
	end
	self.next_red1_value = false
	if self.cur_select_index + 1 <= data_instance:GetMaxChapter() then
		for i = self.cur_select_index + 1,data_instance:GetMaxChapter() do
			if view_data[i].red then
				self.next_red1_value = true
				break
			end
		end
	end
    self.item_cell:SetData({item_id = self.card_id})
	self.item_num_value = ItemData.Instance:GetItemNumInBagById(self.card_id)
end

function SlaughterDevilContent:SetFlag()
	self.show_next1:SetValue(self.cur_select_index + 1 ~= self:GetMapNumberOfCell())
	self.show_next2:SetValue(self.cur_select_index ~= 0)
	self.next_red2:SetValue(self.next_red2_value)
	self.next_red1:SetValue(self.next_red1_value)
end

function SlaughterDevilContent:SetModel()
	if self.construct == nil  then
		return
	end
end


function SlaughterDevilContent:SetInfo()
	if self.construct == nil  then
		return
	end
	self.total_num:SetValue(self.total_num_value)
	self.cur_num:SetValue(self.cur_num_value)
	self.name:SetValue(self.name_value)
	self.level:SetValue(self.level_value)
	self.slider_num:SetValue(self.slider_value)
	self.first_name:SetValue(self.first_name_value)
	self.title:SetAsset(ResPath.GetTitleIcon(self.title_res))
	self.chapter:SetAsset(ResPath.GetChapterIcon(self.cur_select_index))
	self.bg_chapter:SetAsset(ResPath.GetBgChapter(self.cur_select_index % 3 + 1))
	self.star_num:SetValue(self.star_num_value)
	self.item_num:SetValue(self.item_num_value)
	self.item_icon:SetAsset(ResPath.GetItemIcon(self.card_id))
	self.scroller:RefreshAndReloadActiveCellViews(false)
end

function SlaughterDevilContent:ClickAdd()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local flag = SlaughterDevilData.Instance:CheckAdd(vip_level)
	local max_count = SlaughterDevilData.Instance:GetMaxCount()
	local buy_count = SlaughterDevilData.Instance:GetBuyCount()

	local num = ItemData.Instance:GetItemNumInBagById(self.card_id)
	if num > 0 then
		SlaughterDevilCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_BUY_TIMES, 0, 1)
		return
	end
	if buy_count >= max_count then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.MaxManyFB)
		return
	end
	if not flag then
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.PUSH_COMMON)
		return
	end
	-- if num > 0 then
	-- 	SlaughterDevilCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_BUY_TIMES, 0, 1)
	-- 	return
	-- end
	local des = Language.FuBen.BuySlaughterFB
	local cost = SlaughterDevilData.Instance:GetBuyCost()
	des = string.format(des, cost)
	local ok_callback = function ()
		SlaughterDevilCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_BUY_TIMES, 0, 1)
	end
	if self.show_tips then
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
	else
		ok_callback(false)
	end
end

function SlaughterDevilContent:FLushReward()
	local data_list = SlaughterDevilData.Instance:GetRewardList(self.cur_select_index)
	for k, v in ipairs(self.reward_cell_list) do
		v:SetIndex(k)
		v:SetData(data_list[k - 1])
	end
end

function SlaughterDevilContent:ClickNext(flag)
	local scroller = self.map_list.scroller
	local position = scroller.ScrollPosition
	local index = self.cur_select_index
	index = flag == 1 and index + 1 or index - 1
	self:JumpToIndex(index)
end

function SlaughterDevilContent:JumpToIndex(index)
	local max_count = self:GetMapNumberOfCell()
	index = index >= max_count and max_count - 1 or index
	if index < 0 then
		index = 0
	end
	local width = self.scroller.transform:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.x
	local space = self.scroller.spacing
	-- 当前页面可以显示的数量
	-- local count = 1
	-- print_error(max_count)
	-- print_error(count)
	-- if max_count <= count or index + count > max_count then
	-- 	print_error(max_count)
	-- 	print_error(count)
	-- 	print_error(index)
	-- 	return
	-- end
	if index >= max_count then
		return
	end
	self.cur_select_index = index
	local jump_index = index
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = BindTool.Bind(self.Flush, self)
	
	self.scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function SlaughterDevilContent:GetCellSize()
	local def_value = 0
	local data = {}
	return 524.3
end

function SlaughterDevilContent:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(270)
end
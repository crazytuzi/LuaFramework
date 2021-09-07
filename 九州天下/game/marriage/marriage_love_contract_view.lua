MarriageLoveContractView = MarriageLoveContractView or BaseClass(BaseRender)

local PageLeft = 1
local PageRight = 2
local RewardItemIndex = {
	[1] = 2, [2] = 3, [3] = 2, [4] = 3, [5] = 2, [6] = 1, [7] = 1
}

function MarriageLoveContractView:__init()

	self.btn_wish = self:FindObj("ButtonWish")
	self.contract_edit_text = self:FindObj("ContractEditText")
	self.left_edit_text = self:FindVariable("ShowEditText")
	self.is_reward_gray = self:FindVariable("IsRewardGray")
	self.reward_btn_text = self:FindVariable("RewardBtnText")
	self.day_index = self:FindVariable("DayIndex")
	self.reward_show = self:FindVariable("RewardShow")
	self.get_reward_gary = self:FindVariable("GetRewardGray")
	self.reward_img = self:FindObj("RewardImg")

	self.reward_item_list = {}
	self.reward_node_list = {}

	self.show_node_list = {}
	self.show_item_list = {}
	for i = 1, 2 do
		self.reward_node_list[i] = self:FindObj("RewardItem" .. i)
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.reward_node_list[i])

		self.show_node_list[i] = self:FindObj("ShowItem" .. i)
		self.show_item_list[i] = ItemCell.New()
		self.show_item_list[i]:SetInstanceParent(self.show_node_list[i])
	end

	self.contract_item_list = {}
	for i = 1, 7 do
		self.contract_item_list[i] = ContractItemRender.New(self:FindObj("ContractItem" .. i))
		self.contract_item_list[i].index = i
		self.contract_item_list[i]:SetClickCallBack(BindTool.Bind1(self.ClickContractHandler, self))
	end

	----------------------------------------------------
	-- 聊天列表生成滚动条
	self.leaveword_cell_list = {}
	self.leaveword_listview_data = {}
	self.leaveword_list = self:FindObj("LeaveWordtList")
	local leaveword_list_delegate = self.leaveword_list.list_simple_delegate
	--生成数量
	leaveword_list_delegate.NumberOfCellsDel = function()
		return #self.leaveword_listview_data or 0
	end
	--刷新函数
	leaveword_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshLeaveWordListView, self)
	-- 移动scrollerview的时候调用
	-- self.leaveword_list.scroller.scrollerScrollingChanged = function ()
	-- end
	----------------------------------------------------

	self:ListenEvent("ClickWish", BindTool.Bind1(self.ClickWishHandler, self))
	self:ListenEvent("ClickContractTips", BindTool.Bind1(self.ClickContractTipsHandler, self))
	-- self:ListenEvent("ButtonRight", BindTool.Bind2(self.ButtonChangePage, self, PageRight))

	self:ListenEvent("ClickEditTextClose", BindTool.Bind1(self.ClickEditTextCloseHandler, self))
	self:ListenEvent("ClickReward", BindTool.Bind1(self.ClickRewardHandler, self))
end

function MarriageLoveContractView:__delete()
	for k,v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}
	for k,v in pairs(self.show_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	for k,v in pairs(self.contract_item_list) do
		v:DeleteMe()
	end
	self.contract_item_list = {}
	for k,v in pairs(self.leaveword_cell_list) do
		v:DeleteMe()
	end
	self.leaveword_cell_list = {}
	self.reward_node_list = {}
end

function MarriageLoveContractView:OpenLoveContaractView()
	self.contract_item_list[MarriageData.Instance:GetLoveContractSelectIndex()]:OnClick()
end

-- 物品奖励列表选择回调函数处理
function MarriageLoveContractView:ClickContractHandler(cell)
	if not cell or not cell.data then return end

	local index = cell.index
	local data = cell.data

	self.day_index:SetValue(string.format(Language.Marriage.DayCount, Language.Common.NumToChs[index]))
	self.reward_show:SetAsset(ResPath.GetMarryImage("Reward_Item_" .. RewardItemIndex[cell.index]))

	-- 保存选择的格子下标
	MarriageData.Instance:SetLoveContractSelectIndex(index)

	-- local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num
	-- local reward_flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(index - 1)
	-- local is_open = reward_flag == 0 and data.day <= can_receive_day_num
	

	local gift_cfg = {}
	if data.reward_item[0] and data.reward_item[0].item_id then
		local _, big_type = ItemData.Instance:GetItemConfig(data.reward_item[0].item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			gift_cfg = ItemData.Instance:GetGiftItemList(data.reward_item[0].item_id)
		end
	end

	for i = 1, 2 do
		self.reward_node_list[i]:SetActive(false)
		self.show_node_list[i]:SetActive(false)
	end

	if next(gift_cfg) then
		for i = 1, 2 do
			if gift_cfg[i] then
				self.reward_node_list[i]:SetActive(true)
				self.reward_item_list[i]:SetData(gift_cfg[i])

				self.show_node_list[i]:SetActive(true)
				self.show_item_list[i]:SetData(gift_cfg[i])
			else
				self.reward_node_list[i]:SetActive(false)
				self.show_node_list[i]:SetActive(false)
			end
		end
	else
		for i = 1, 2 do
			if data.reward_item[i - 1] then
				self.reward_node_list[i]:SetActive(true)
				self.reward_item_list[i]:SetData(data.reward_item[i - 1])

				self.show_node_list[i]:SetActive(true)
				self.show_item_list[i]:SetData(data.reward_item[i - 1])
			else
				self.reward_node_list[i]:SetActive(false)
				self.show_node_list[i]:SetActive(false)
			end
		end
	end

	self:Flush()
	-- self.left_edit_text:SetValue(true)
end

-- 聊天列表listview
function MarriageLoveContractView:RefreshLeaveWordListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local leaveword_cell = self.leaveword_cell_list[cell]
	if leaveword_cell == nil then
		leaveword_cell = LeaveWordItemRender.New(cell.gameObject)
		-- leaveword_cell:SetClickCallBack(BindTool.Bind1(self.ClickLeaveWordHandler, self))
		-- leaveword_cell.root_node.toggle.group = self.leaveword_list.toggle_group
		self.leaveword_cell_list[cell] = leaveword_cell
	end

	leaveword_cell:SetIndex(data_index)
	leaveword_cell:SetData(self.leaveword_listview_data[data_index])
end


function MarriageLoveContractView:FlushLoveContractView()
	local love_contract_info = MarriageData.Instance:GetQingyuanLoveContractInfo()
	local contract_cfg = MarriageData.Instance:GetQingyuanLoveContractCfg()
	for i = 1, 7 do
		if self.contract_item_list[i] and contract_cfg[i] then
			self.contract_item_list[i]:SetData(contract_cfg[i])
		end
	end

	-- 设置聊天数据
	self.leaveword_listview_data = love_contract_info.leaveword_list
	-- if self.leaveword_list.scroller.isActiveAndEnabled then
		GlobalTimerQuest:AddDelayTimer(function()
			self.leaveword_list.scroller:ReloadData(1)
		end, 0)
	-- end

	self:Flush()
end

function MarriageLoveContractView:OnFlush()
	local love_contract_info = MarriageData.Instance:GetQingyuanLoveContractInfo()
	local day = MarriageData.Instance:GetLoveContractSelectIndex() - 1
	local reward_flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(day)
	self.is_open = reward_flag == 0 and day <= love_contract_info.can_receive_day_num


	local btn_text = ""
	if self.is_open then
		btn_text = Language.Common.LingQu
		self.get_reward_gary:SetValue(true)
	else
		if love_contract_info.lover_love_contract_timestamp <= 0 then
			btn_text = Language.Marriage.WishLover
			self.get_reward_gary:SetValue(true)
		else
			btn_text = Language.Common.LingQu
			self.get_reward_gary:SetValue(false)
		end
	end
	self.reward_btn_text:SetValue(btn_text)
	self.is_reward_gray:SetValue(not self.is_open)

	GlobalTimerQuest:AddDelayTimer(function()
		self.reward_img.animator:SetBool("stop", not self.is_open)
	end, 0)
end

function MarriageLoveContractView:ClickWishHandler()
	-- if not self.is_open then return end
	local love_contract_info = MarriageData.Instance:GetQingyuanLoveContractInfo()
	if love_contract_info.lover_love_contract_timestamp > 0 or self.is_open then
		self.left_edit_text:SetValue(true)
	else
		local des = string.format(Language.Marriage.BuyLoveContractTips, MarriageData.Instance:GetQingyuanLoveContractPrice())
		TipsCtrl.Instance:ShowCommonAutoView(nil, des, function ()
			MarriageCtrl.Instance:SendQingyuanBuyLoveContract()
		end)
	end
end

function MarriageLoveContractView:ClickContractTipsHandler()
	-- 爱情契约Tips
	TipsCtrl.Instance:ShowHelpTipView(154)
end

function MarriageLoveContractView:ClickEditTextCloseHandler()
	self.left_edit_text:SetValue(false)
end

function MarriageLoveContractView:ClickRewardHandler()
	if self.contract_edit_text.input_field.text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ContentNotNull)
		return
	end

	local select_index = MarriageData.Instance:GetLoveContractSelectIndex()
	MarriageCtrl.Instance:SendQingyuanFetchLoveContract(select_index - 1, self.contract_edit_text.input_field.text)

	self.left_edit_text:SetValue(false)
end

function MarriageLoveContractView:ClickShowItem()
	self.show_reward_item:SetValue(true)
end

function MarriageLoveContractView:ClickCloseShowItem()
	self.show_reward_item:SetValue(false)
end

----------------------------------------------------------------------------
--ContractItemRender	爱情契约itemrender
----------------------------------------------------------------------------
ContractItemRender = ContractItemRender or BaseClass(BaseCell)

function ContractItemRender:__init()
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.icon_gray = self:FindVariable("IconGray")

	-- 这里调用的是basecell里面的回调函数
	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClick, self))
end

function ContractItemRender:__delete()
end

function ContractItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	self.name:SetValue(string.format(Language.Marriage.LoveContractDay, CommonDataManager.GetDaXie(self.data.day+ 1)))
	local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num

	-- 等于7的时候表示的是称号的
	local bundle, asset
	-- if self.index == 7 then
	-- 	local other_cfg = MarriageData.Instance:GetMarriageConditions()
	-- 	bundle, asset = ResPath.GetTitleIcon(PlayerData.Instance.role_vo.sex == 1 
	-- 		and other_cfg.c_title_boy or other_cfg.c_title_girl)
	-- else
	bundle, asset = ResPath.GetMarryImage("bg_start_01")
	if self.data.day <= can_receive_day_num then
		bundle, asset = ResPath.GetMarryImage("bg_start_02")
	end
	-- end
	self.icon:SetAsset(bundle, asset)
	self:FlushAnimatorData(can_receive_day_num)
end

-- 刷新animator动画数据
function ContractItemRender:FlushAnimatorData(can_receive_day_num)
	local reward_flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(self.data.day)
	local is_stop = true
	if self.data.day <= can_receive_day_num and reward_flag == 0 then
		is_stop = false
		self:OnClick()
	end
	
	GlobalTimerQuest:AddDelayTimer(function()
		local animator = self.root_node:GetComponent(typeof(UnityEngine.Animator))
		animator:SetBool("stop", is_stop)
	end, 0)

end

----------------------------------------------------------------------------
--LeaveWordItemRender	爱情契约聊天留言itemrender
----------------------------------------------------------------------------
LeaveWordItemRender = LeaveWordItemRender or BaseClass(BaseCell)

function LeaveWordItemRender:__init()
	self.day_label = self:FindVariable("Day")
	self.content_label = self:FindVariable("Content")
end

function LeaveWordItemRender:__delete()
end

function LeaveWordItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	self.day_label:SetValue(string.format(Language.Marriage.LoveContractDay, self.data.day_num + 1))
	self.content_label:SetValue(ToColorStr(self.data.user_name, COLOR.GREEN) .. ":" .. self.data.contract_notice)
end
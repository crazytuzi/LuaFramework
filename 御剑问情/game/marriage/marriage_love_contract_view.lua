MarriageLoveContractView = MarriageLoveContractView or BaseClass(BaseView)

local PageLeft = 1
local PageRight = 2
local ContractDay = 7 -- 领取的天数 

function MarriageLoveContractView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","LoveContract"}
	self.play_audio = true
end

function MarriageLoveContractView:__delete()

end

function MarriageLoveContractView:LoadCallBack()
	self.btn_wish = self:FindObj("ButtonWish")
	self.contract_edit_text = self:FindObj("ContractEditText")
	self.ani = self:FindObj("Ani")
	self.left_edit_text = self:FindVariable("ShowEditText")
	self.is_reward_gray = self:FindVariable("IsRewardGray")
	self.is_remind_gray = self:FindVariable("IsRemindGray")
	self.is_empty = self:FindVariable("IsEmpty")
	self.is_buy = self:FindVariable("IsBuy")
	self.is_seven = self:FindVariable("IsSeven")
	self.day = self:FindVariable("Day")
	self.how_day = self:FindVariable("HowDay")
	self.return_gold = self:FindVariable("ReturnGold")
	self.all_return_gold = self:FindVariable("AllReturnGold")
	self.title_sex = self:FindVariable("TitleSex")
	self.is_reward_text = self:FindVariable("IsRewardText")

	self.reward_item_list = {}
	self.reward_node_list = {}
	for i = 1, 4 do
		self.reward_node_list[i] = self:FindObj("RewardItem" .. i)
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.reward_node_list[i])
	end
	self.contract_toggle_list = {}
	self.contract_item_list = {}
	for i = 1, 7 do
		self.contract_toggle_list[i] = self:FindObj("ContractItem" .. i)
		self.contract_item_list[i] = ContractItemRender.New(self.contract_toggle_list[i])
		self.contract_item_list[i].index = i
		self.contract_item_list[i]:SetClickCallBack(BindTool.Bind1(self.ClickContractHandler, self))
	end

	-- self.title = ContractTitleRender.New(self:FindObj("Title"))
	-- self.title:SetClickCallBack(BindTool.Bind1(self.ClickContractHandler, self))

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
	self:ListenEvent("ClickEditTextClose", BindTool.Bind1(self.ClickEditTextCloseHandler, self))
	self:ListenEvent("ClickReward", BindTool.Bind1(self.ClickRewardHandler, self))
	self:ListenEvent("ClickClose", BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("ClickFetchTitle", BindTool.Bind(self.ClickFetchTitle, self))
	self:ListenEvent("ClickDemand", BindTool.Bind(self.ClickDemand, self))
	self:ListenEvent("ClickTitle", BindTool.Bind(self.ClickTitle, self))

	self.select_day = 1
end

function MarriageLoveContractView:ReleaseCallBack()
	for k,v in pairs(self.contract_item_list) do
		v:DeleteMe()
	end
	self.contract_item_list = {}
	self.reward_node_list = {}
	self.contract_toggle_list = {}
	self.btn_wish = nil
	self.contract_edit_text = nil
	self.left_edit_text = nil
	self.is_reward_gray = nil
	self.is_remind_gray = nil
	self.leaveword_list = nil
	self.ani = nil
	self.title = nil
	self.is_empty = nil
	self.is_buy = nil
	self.is_seven = nil
	self.day = nil
	self.how_day = nil
	self.return_gold = nil
	self.all_return_gold = nil
	self.title_sex = nil
	self.is_reward_text = nil
end

function MarriageLoveContractView:OpenCallBack()
	self:FlushLoveContractView()
	local day = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num or 1
	day = day < 0 and 1 or day + 1 -- 没有购买的时候要默认选第一个。。
	if self.contract_toggle_list[day] then
		local cell = {data = {},}
		cell.index = day
		cell.data.day = day - 1
		self.contract_toggle_list[day].toggle.isOn = true
		self:ClickContractHandler(cell)
	end
end

-- 物品奖励列表选择回调函数处理
function MarriageLoveContractView:ClickContractHandler(cell)
	if not cell or not cell.data then return end

	local index = cell.index
	local data = cell.data
	self.select_day = data.day

	-- 保存选择的格子下标
	MarriageData.Instance:SetLoveContractSelectIndex(index)

	local contract_cfg = MarriageData.Instance:GetQingyuanLoveContractCfgByDay(index - 1)
	if contract_cfg then
		self.how_day:SetValue(index)
		self.return_gold:SetValue(contract_cfg.return_bind_gold)
	end

	local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num
	local reward_flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(index - 1)
	local is_open = reward_flag == 0 and data.day <= can_receive_day_num
	self.is_reward_gray:SetValue(is_open)
	self.is_reward_text:SetValue(reward_flag == 0 and Language.Common.LingQu or Language.Common.YiLingQu)
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
	-- 设置按钮是否隐藏
	-- self.btn_wish:SetActive(love_contract_info.self_love_contract_timestamp <= 0)
	self.btn_wish.grayscale.GrayScale = love_contract_info.self_love_contract_timestamp <= 0 and 0 or 255
	self.btn_wish.button.interactable = love_contract_info.self_love_contract_timestamp <= 0

	-- 空白列表显示
	local empty = #love_contract_info.leaveword_list
	self.is_empty:SetValue(empty <= 0)
	-- 为我购买后不显示
	local day = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num or -1
	if day > 0 then
		self.is_seven:SetValue(false)
		self.day:SetValue(day)
	elseif day == 0 then
		self.is_seven:SetValue(true)
	end

	local contract_cfg = MarriageData.Instance:GetQingyuanLoveContractCfg()
	local role_sex = GameVoManager.Instance:GetMainRoleVo().sex
	local reward_flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(self.select_day)
	local is_open = reward_flag == 0 and self.select_day <= day
	
	if contract_cfg == nil or next(contract_cfg) == nil then return end
	for i = 1, 7 do
		if self.contract_item_list[i] and contract_cfg[i] then
			self.contract_item_list[i]:SetData(contract_cfg[i])
		end
	end

	if self.is_buy and self.all_return_gold and self.title_sex and self.is_reward_gray and self.is_reward_text then
		self.is_buy:SetValue(day >= 0)
		self.title_sex:SetValue(role_sex)
		self.is_reward_gray:SetValue(is_open)
		self.all_return_gold:SetValue(MarriageData.Instance:GetQingyuanLoveContractReturnGold())
		self.is_reward_text:SetValue(reward_flag == 0 and Language.Common.LingQu or Language.Common.YiLingQu)
		-- self.is_remind_gray:SetValue(contract_info.today_remind_times > 0)
	end

	--设置称号
	-- self.title:SetData(contract_cfg[7])

	-- 设置聊天数据
	self.leaveword_listview_data = love_contract_info.leaveword_list
	-- if self.leaveword_list.scroller.isActiveAndEnabled then
		GlobalTimerQuest:AddDelayTimer(function()
			self.leaveword_list.scroller:ReloadData(1)
		end, 0)
	-- end
end

function MarriageLoveContractView:ClickWishHandler()
	ViewManager.Instance:Open(ViewName.LoveContractFrame, nil, "Wish")
end

function MarriageLoveContractView:ClickContractTipsHandler()
	-- 爱情契约Tips
	TipsCtrl.Instance:ShowHelpTipView(154)
end

function MarriageLoveContractView:ClickEditTextCloseHandler()
	self.ani.animator:SetBool("show", false)
	GlobalTimerQuest:AddDelayTimer(function()
		self.left_edit_text:SetValue(false)
	end, 0.12)
end

function MarriageLoveContractView:ClickRewardHandler()
	if self.contract_edit_text.input_field.text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ContentNotNull)
		return
	end

	local select_index = MarriageData.Instance:GetLoveContractSelectIndex()
	MarriageCtrl.Instance:SendQingyuanFetchLoveContract(select_index - 1, self.contract_edit_text.input_field.text)

	if select_index >= ContractDay then
		self:ClickFetchTitle()
	end
	self:ClickEditTextCloseHandler()
end

function MarriageLoveContractView:ClickClose()
	self:Close()
end

function MarriageLoveContractView:ClickFetchTitle()
	MarriageCtrl.Instance:SendQingyuanLoveContractFetchTitleReq()
end

function MarriageLoveContractView:ClickDemand()
	local contract_info = MarriageData.Instance:GetQingyuanLoveContractInfo()
	local lover_uid = GameVoManager.Instance:GetMainRoleVo().lover_uid
	MarriageCtrl.Instance:SendQingyuanLoveContractRemindLover()
	if contract_info.today_remind_times <= 0 then
		ChatCtrl.SendSingleChat(lover_uid, Language.Marriage.ContractDemand, CHAT_CONTENT_TYPE.TEXT)
	end
end

function MarriageLoveContractView:ClickTitle()
	local title_info = MarriageData.Instance:GetTitleInfo()
	if title_info == nil or next(title_info) == nil then return end
	local data = {item_id = title_info.item_id, title_info.is_bind, title_info.num}
	TipsCtrl.Instance:OpenItem(data)
end

----------------------------------------------------------------------------
--ContractItemRender	爱情契约itemrender
----------------------------------------------------------------------------
ContractItemRender = ContractItemRender or BaseClass(BaseCell)

function ContractItemRender:__init()
	self.icon = self:FindVariable("Icon")
	--self.name = self:FindVariable("Name")
	self.icon_gray = self:FindVariable("IconGray")
	self.show_effect = self:FindVariable("ShowEffect")

	-- 这里调用的是basecell里面的回调函数
	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClick, self))
end

function ContractItemRender:__delete()
end

function ContractItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	--self.name:SetValue(string.format(Language.Marriage.LoveContractDay, self.data.day + 1))
	local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num

	local bundle, asset
	bundle, asset = ResPath.GetMarryImage("contract_heart_01")
	if self.data.day <= can_receive_day_num then
		bundle, asset = ResPath.GetMarryImage("contract_heart")
	end
	self.icon:SetAsset(bundle, asset)

	local reward_flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(self.index - 1)
	local is_open = reward_flag == 0 and self.data.day <= can_receive_day_num

	self.show_effect:SetValue(is_open)
	
end

-- 刷新animator动画数据
function MarriageLoveContractView:FlushAnimatorData(can_receive_day_num)
	-- local reward_flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(self.data.day)
	local is_stop = false
	-- if self.data.day <= can_receive_day_num and reward_flag == 0 or self.index == 7 then
	-- 	is_stop = false
	-- end
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
	self.content_label:SetValue(self.data.user_name .. ":" .. self.data.contract_notice)
end

----------------------------------------------------------------------------
--ContractTitleRender	爱情契约称号
----------------------------------------------------------------------------
ContractTitleRender = ContractTitleRender or BaseClass(BaseCell)

function ContractTitleRender:__init()
	self.icon = self:FindVariable("Icon")

	-- 这里调用的是basecell里面的回调函数
	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClick, self))
end

function ContractTitleRender:__delete()
end

function ContractTitleRender:OnFlush()
	if not self.data or not next(self.data) then return end

	local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num

	local other_cfg = MarriageData.Instance:GetMarriageConditions()
	local bundle, asset = ResPath.GetTitleIcon(PlayerData.Instance.role_vo.sex == 1 
		and other_cfg.c_title_boy or other_cfg.c_title_girl)
	self:FlushAnimatorData(can_receive_day_num)
	self.icon:SetAsset(bundle, asset)
	
end

-- 刷新animator动画数据
function ContractTitleRender:FlushAnimatorData(can_receive_day_num)
	-- local reward_flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(self.data.day)
	local is_stop = false
	-- if self.data.day <= can_receive_day_num and reward_flag == 0 or self.index == 7 then
	-- 	is_stop = false
	-- end
	GlobalTimerQuest:AddDelayTimer(function()
		local animator = self.root_node:GetComponent(typeof(UnityEngine.Animator))
		animator:SetBool("stop", is_stop)
	end, 0)
end
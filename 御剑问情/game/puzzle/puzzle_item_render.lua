-----------------翻翻转格子------------------
PuzzleFlipCellItemRender = PuzzleFlipCellItemRender or BaseClass(BaseCell)

function PuzzleFlipCellItemRender:__init()
	self.is_front = false
	self.is_select_effect = false
	self.index = 1
	self.show_word = self:FindVariable("ShowWord")
	self.show_item = self:FindVariable("ShowItem")
	self.bg = self:FindVariable("Bg")
	self.word = self:FindVariable("Word")
	self.item_node = self:FindObj("Item")
	self.bg_obj = self:FindObj("Bg")
	self.flip_cell = ItemCell.New()
	self.flip_cell:SetInstanceParent(self.item_node)
end

function PuzzleFlipCellItemRender:__delete()
	self.flip_cell:DeleteMe()
end

function PuzzleFlipCellItemRender:OnFlush()
	if nil == self.data or nil == self.data.seq_type then return end

	if self.data.seq_type == 0 then
		self.flip_cell:SetData({})
		self.show_item:SetValue(false)
		self.show_word:SetValue(false)
		self.is_front = false
		self.bg:SetAsset("uis/views/randomact/puzzle/images_atlas", "PuzzleCard" .. self.index)
	elseif self.data.seq_type == 1 then
		self.flip_cell:SetData(self.data.info)
		self.flip_cell:SetData(self.data.info)
		self.show_item:SetValue(true)
		self.show_word:SetValue(false)
		self.is_front = true
		self.bg:SetAsset("uis/views/randomact/puzzle/images_atlas", "bg_04")
	elseif self.data.seq_type == 2 then
		self.flip_cell:SetData({})
		self.flip_cell:ShowGetEffect(true)
		self.show_item:SetValue(true)
		self.word:SetAsset("uis/views/randomact/puzzle/images_atlas", "PuzzleWord" .. self.data.info + 1)
		self.show_word:SetValue(true)
		self.is_front = true
		self.bg:SetAsset("uis/views/randomact/puzzle/images_atlas", "bg_04")
	end
end
function PuzzleFlipCellItemRender:ShowHighLight(value)
	self.flip_cell:ShowHighLight(value)
end

function PuzzleFlipCellItemRender:SetIndex(index)
	self.index = index
end

-- 翻转动画
function PuzzleFlipCellItemRender:RunFilpAnim()
	if IsNil(self.bg_obj.rect) then return end
	self.bg_obj.rect:SetLocalScale(1, 1, 1)
	local target_scale = Vector3(0, 1, 1)
	local target_scale2 = Vector3(1, 1, 1)
	self.tweener1 = self.bg_obj.rect:DOScale(target_scale, 0.1)

	local func2 = function()
		self.tweener2 = self.bg_obj.rect:DOScale(target_scale2, 0.1)
		self.is_rotation = false
	end
	self.tweener1:OnComplete(func2)
end

-----------------兑换奖励Item------------------
RewardExchangeItemRender = RewardExchangeItemRender or BaseClass(BaseCell)

function RewardExchangeItemRender:__init()
	self.remind_num = self:FindVariable("RemindNum")
	self.words_list = {}
	for i = 1, GameEnum.RA_FANFAN_LETTER_COUNT_PER_WORD do
		self.words_list[i] = self:FindVariable("Word" .. i)
	end
	self.item_node = self:FindObj("Item")
	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self.item_node)

	self:ListenEvent("OnClickExchange",BindTool.Bind(self.OnClickBtnExchange, self))
end

function RewardExchangeItemRender:__delete()
	self.reward_cell:DeleteMe()
end

function RewardExchangeItemRender:OnClickBtnExchange()
	if nil == self.data then return end
	PuzzleCtrl.Instance:SendReq(RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_WORD_EXCHANGE, self.data.index)
end

function RewardExchangeItemRender:OnFlush()
	if self.data.index == nil then return end

	local flip_word_info = PuzzleData.Instance:GetFlipWordInfo()
	local word_info = PuzzleData.Instance:GetWrodInfo(self.data.index)
	local word_act_info = PuzzleData.Instance:GetWrodActiveInfo(self.data.index)
	self.remind_num:SetValue(self.data.exchange_num)
	if word_info == nil or word_act_info == nil then return end

	local cur_index = PuzzleData.Instance:GetCurWrodGroupIndex()
	for i=1, GameEnum.RA_FANFAN_LETTER_COUNT_PER_WORD do
		local word_img = self.words_list[i]
		word_img:SetAsset("uis/views/randomact/puzzle/images_atlas", "PuzzleWord" .. (self.data.index * 4 + i))
	end
	self.reward_cell:SetData(word_info.exchange_item)
end

function RewardExchangeItemRender:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function RewardExchangeItemRender:ShowHighLight(value)
	self.reward_cell:ShowHighLight(value)
end

---------------PuzzleBaoDiItemRender--------------------
PuzzleBaoDiItemRender = PuzzleBaoDiItemRender or BaseClass(BaseCell)
function PuzzleBaoDiItemRender:__init()
	self.times = self:FindVariable("Times")
	self.has_reward = self:FindVariable("HasGet")

	self.item_node = self:FindObj("Item")
	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self.item_node)
	self.reward_cell.root_node.transform:SetAsFirstSibling()

	self.cur_open_day = -1
end

function PuzzleBaoDiItemRender:__delete()
	self.reward_cell:DeleteMe()
end

function PuzzleBaoDiItemRender:OnFlush()
	if nil == self.data then return end
	self.root_node:SetActive(next(self.data) ~= nil)
	if next(self.data) == nil then
		return
	end

	self.times:SetValue(self.data.choujiang_times)
	self:SetItemData()
	local is_giveout_reward = PuzzleData.Instance:IsGiveoutReward(self.data.index)
	local info_baodi_total = PuzzleData.Instance:GetBaodiTotal() or 0
	if is_giveout_reward then
		self.has_reward:SetValue(true)
		self.reward_cell:ShowGetEffect(false)
		self.reward_cell:ListenClick()
	elseif info_baodi_total >= self.data.choujiang_times then
		self.has_reward:SetValue(false)
		self.reward_cell:ShowGetEffect(true)
		self.reward_cell:ListenClick(BindTool.Bind(self.OnClickBaoDiItem, self))
	else
		self.has_reward:SetValue(false)
		self.reward_cell:ShowGetEffect(false)
		self.reward_cell:ListenClick()--BindTool.Bind(self.OnClickBaoDiItem, self)为什么条件不满足是发协议呢？
	end
end

function PuzzleBaoDiItemRender:SetItemData()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay() or 0
	if self.cur_open_day ~= cur_day then
		self.reward_cell:SetData(self.data.reward_item)
		self.cur_open_day = cur_day
	end
end

function PuzzleBaoDiItemRender:ShowHighLight(value)
	self.reward_cell:ShowHighLight(value)
end

function PuzzleBaoDiItemRender:OnClickBaoDiItem()
	if nil == self.data then return end

	local info_baodi_total = PuzzleData.Instance:GetBaodiTotal()
	local is_giveout_reward = PuzzleData.Instance:IsGiveoutReward(self.data.index)
	if not is_giveout_reward and info_baodi_total >= self.data.choujiang_times then
		PuzzleCtrl.Instance:SendGetBaoDi(self.data.index)
	end
end
-----------------翻翻转格子------------------
FanfanzhuanFlipCellItemRender = FanfanzhuanFlipCellItemRender or BaseClass(BaseRender)

function FanfanzhuanFlipCellItemRender:__init()
	self.is_front = false
	self.is_select_effect = false
	local item_config = FanfanzhuanCtrl.Instance.view.ph_list.ph_flip_cell
	self:SetUiConfig(item_config, true)

	self.flip_cell = BaseCell.New()
	local cell_node = self.flip_cell:GetView()
	cell_node:setVisible(false)
	self:GetView():addChild(cell_node, 200)
	cell_node:setPosition(self:GetView():getContentSize().width/2 - 8,self:GetView():getContentSize().height/2 - 5)
	cell_node:setAnchorPoint(0.5,0.5)
	cell_node:setScale(0.95,0.95)

	local cell_size = cell_node:getContentSize()
	self.flip_img = XUI.CreateImageView(cell_size.width / 2, cell_size.height / 2, "", true)
	self.flip_img:setTouchEnabled(true)
	self:GetView():addChild(self.flip_img, 100)
	XUI.AddClickEventListener(self.flip_img, BindTool.Bind1(self.OnClick, self), true)

	self.flip_word = XUI.CreateImageView(cell_size.width / 2, cell_size.height / 2, "", true)
	self:GetView():addChild(self.flip_word, 300)
end

function FanfanzhuanFlipCellItemRender:__delete()
	self.flip_cell:DeleteMe()
	self.flip_img = nil
end

function FanfanzhuanFlipCellItemRender:OnFlush()
	if nil == self.data or nil == self.data.seq_type then return end

	if self.data.seq_type == 0 then
		self.flip_cell:SetData({})
		self.flip_cell:GetView():setVisible(false)
		self.flip_word:setVisible(false)
		self.is_front = false
	elseif self.data.seq_type == 1 then
		self.flip_cell:SetData(self.data.info)
		self.flip_cell:GetView():setVisible(true)
		self.flip_word:setVisible(false)
		self.is_front = true
	elseif self.data.seq_type == 2 then
		self.flip_cell:SetData({})
		self.flip_cell:SetFulingEffect(true)
		self.flip_cell:GetView():setVisible(true)
		self.flip_word:loadTexture(ResPath.GetFanfanzhuan("flip_word_" .. self.data.info))
		self.flip_word:setVisible(true)
		self.is_front = true
	end
end

function FanfanzhuanFlipCellItemRender:SetIndex(index)
	self.index = index
	self.flip_img:loadTexture(ResPath.GetFanfanzhuan("fanfanzhuan_flip_" .. index))
end

-- 翻转动画
function FanfanzhuanFlipCellItemRender:RunFilpAnim()
	local flip_begin = cc.ScaleTo:create(0.1, 0, 1)
	local flip_end = cc.ScaleTo:create(0.1, 1, 1)
	self:GetView():runAction(cc.Sequence:create(flip_begin, flip_end))
end

-----------------兑换奖励Item------------------
RewardExchangeItemRender = RewardExchangeItemRender or BaseClass(BaseRender)

function RewardExchangeItemRender:__init()
	local item_config = FanfanzhuanCtrl.Instance.view.ph_list.ph_reward_item
	self:SetUiConfig(item_config, true)

	self.words_list = {}
	for i=0, GameEnum.RA_FANFAN_LETTER_COUNT_PER_WORD - 1 do
		local param = self.ph_list["ph_flip_word_" .. i]

		local word_img = XUI.CreateImageView(param.x, param.y, "", true)
		word_img:setGrey(false)
		self:GetView():addChild(word_img, 100)
		self.words_list[i] = word_img
	end


	local param = self.ph_list.ph_reward_item_icon
	self.reward_cell = BaseCell.New()
	self.reward_cell:GetView():setPosition(param.x, param.y)
	self:GetView():addChild(self.reward_cell:GetView(), 999)

	XUI.AddClickEventListener(self.node_tree.btn_exchange.node, BindTool.Bind1(self.OnClickBtnExchange, self))
end

function RewardExchangeItemRender:__delete()
	self.reward_cell:DeleteMe()
end

function RewardExchangeItemRender:OnClickBtnExchange()
	if RewardExchangeItemRender.OnClickBtnExchangeHandler ~= nil then
		RewardExchangeItemRender.OnClickBtnExchangeHandler(self)
	end
end

function RewardExchangeItemRender:OnFlush()
	if self.data.index == nil then return end

	local flip_word_info = FanfanzhuanData.Instance:GetFlipWordInfo()
	local word_info = FanfanzhuanData.Instance:GetWrodInfo(self.data.index)
	local word_act_info = FanfanzhuanData.Instance:GetWrodActiveInfo(self.data.index)
	local exchange_num = FanfanzhuanData.Instance:GetWrodExchangeNum(self.data.index)
	if word_info == nil or word_act_info == nil then return end

	local cur_index = FanfanzhuanData.Instance:GetCurWrodGroupIndex()
	for i=0, GameEnum.RA_FANFAN_LETTER_COUNT_PER_WORD - 1 do
		local word_img = self.words_list[i]
		word_img:loadTexture(ResPath.GetFanfanzhuan("flip_word_" .. (self.data.index * 4 + i)))
		word_img:setGrey(exchange_num <= 0)
	end

	local label = self.node_tree.lbl_exchange_num.node
	label:setString(exchange_num)

	local btn_exchange = self.node_tree.btn_exchange.node
	if exchange_num ~= 0 then
		label:setVisible(true)
		btn_exchange:setEnabled(true)
		XUI.SetButtonEnabled(btn_exchange, true)
		if exchange_num > 9 then
			self.node_tree.img_remind_0.node:setVisible(false)
			self.node_tree.img_remind_1.node:setVisible(true)
		else
			self.node_tree.img_remind_0.node:setVisible(true)
			self.node_tree.img_remind_1.node:setVisible(false)
		end
	else
		label:setVisible(false)
		self.node_tree.img_remind_0.node:setVisible(false)
		self.node_tree.img_remind_1.node:setVisible(false)
		btn_exchange:setEnabled(false)
		XUI.SetButtonEnabled(btn_exchange, false)
	end

	self.reward_cell:SetData(word_info.exchange_item)
end

---------------FanfanzhuanBaoDiItemRender--------------------
FanfanzhuanBaoDiItemRender = FanfanzhuanBaoDiItemRender or BaseClass(BaseRender)
function FanfanzhuanBaoDiItemRender:__init()
	local item_config = FanfanzhuanCtrl.Instance.view.ph_list.ph_baodi_cell
	self:SetUiConfig(item_config, true)
	self.cfg = FanfanzhuanData.Instance:GetBaoDiListCfg()
	self.baodi_index = 1

	for i=1, #self.cfg do
		local ph = self.ph_list["ph_baodi_cell_" .. i]
		self["baodi_cell_" .. i] = BaseCell.New()
		self["baodi_cell_" .. i]:GetCell():setPosition(ph.x, ph.y)
		self["baodi_cell_" .. i]:SetData(self.cfg[i].reward_item)
		self["baodi_cell_" .. i]:AddClickEventListener(BindTool.Bind2(self.OnClickBaoDiItem, self, i))
		self:GetView():addChild(self["baodi_cell_" .. i]:GetView())

		local yilingqu_ph = self.ph_list["ph_is_reward_" .. i]
		self["yilingqu_img_" .. i] = XUI.CreateImageView(yilingqu_ph.x, yilingqu_ph.y, ResPath.GetFuBenPanel("exp_img_yilingqu"), true)
		self["yilingqu_img_" .. i]:setScale(0.8)
		self:GetView():addChild(self["yilingqu_img_" .. i], 999)
		self["yilingqu_img_" .. i]:setVisible(false)

		local lbl_choujiang_times = string.format(Language.Fanfanzhuan.BaodiNum, self.cfg[i].choujiang_times)
		self.node_tree["label_baodi_num_" .. i].node:setString(lbl_choujiang_times)
	end
end

function FanfanzhuanBaoDiItemRender:__delete()
	for i=1, #self.cfg do
		self["baodi_cell_" ..i]:DeleteMe()
		self["baodi_cell_" ..i] = nil
	end
end

function FanfanzhuanBaoDiItemRender:OnFlush()
	if nil == self.cfg then return end
	local info_baodi_total = FanfanzhuanData.Instance:GetBaodiTotal()
	local lbl_baodi_total = string.format(Language.Fanfanzhuan.BaodiTotal, info_baodi_total)
	local is_giveout_reward
	self.baodi_index = 1

	self.node_tree.label_baodi_total.node:setString(lbl_baodi_total)
	for i=1, #self.cfg do
		self.baodi_index = i
		is_giveout_reward = FanfanzhuanData.Instance:IsGiveoutReward(self.cfg[i].index)
		if is_giveout_reward then
			self["yilingqu_img_" .. i]:setVisible(true)
			self["baodi_cell_" .. i]:MakeGray(true)
			self["baodi_cell_" .. i]:SetIsShowTips(true)
			if self["select_effect_" .. i] then
				self["select_effect_" .. i]:removeFromParent()
				self["select_effect_" .. i] = nil
			end
		elseif info_baodi_total >= self.cfg[i].choujiang_times then
			self["baodi_cell_" .. i]:SetIsShowTips(false)
			self:CreateSelectEffect()
		else
			self["baodi_cell_" .. i]:SetIsShowTips(true)
			self["yilingqu_img_" .. i]:setVisible(false)
			self["baodi_cell_" .. i]:MakeGray(false)
			if self["select_effect_" .. i] then
				self["select_effect_" .. i]:removeFromParent()
				self["select_effect_" .. i] = nil
			end
		end
	end
end

function FanfanzhuanBaoDiItemRender:CreateSelectEffect()
	if nil == self["select_effect_" .. self.baodi_index] then
		self["select_effect_" .. self.baodi_index] = AnimateSprite:create()
		local size = self["baodi_cell_" .. self.baodi_index]:GetView():getContentSize()
		self["select_effect_" .. self.baodi_index]:setPosition(size.width / 2, size.height / 2)
		self["select_effect_" .. self.baodi_index]:setScale(1.5)
		self["baodi_cell_" .. self.baodi_index]:GetView():addChild(self["select_effect_" .. self.baodi_index], 999)
		local path, name = ResPath.GetEffectAnimPath(3037)
		self["select_effect_" .. self.baodi_index]:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end
end

function FanfanzhuanBaoDiItemRender:OnClickBaoDiItem(cfg_index)
	if nil == self.cfg and nil == self.cfg[cfg_index] then return end

	local info_baodi_total = FanfanzhuanData.Instance:GetBaodiTotal()
	local is_giveout_reward = FanfanzhuanData.Instance:IsGiveoutReward(self.cfg[cfg_index].index)
	if not is_giveout_reward and info_baodi_total >= self.cfg[cfg_index].choujiang_times then
		FanfanzhuanCtrl.Instance:SendGetBaoDi(self.cfg[cfg_index].index)
	end
end
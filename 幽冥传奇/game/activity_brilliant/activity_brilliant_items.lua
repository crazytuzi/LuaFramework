------------------------
--运营活动render
------------------------
local function FlushButtonState(node, is_lingqu, can_get_reward)
	if nil == node or nil == node.img_charge_reward_state or nil == node.btn_award_lingqu then return end
	if is_lingqu == true then
		node.img_charge_reward_state.node:setVisible(true)
		node.btn_award_lingqu.node:setVisible(false)
		node.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
	else
		if can_get_reward then
			node.img_charge_reward_state.node:setVisible(false)
			node.btn_award_lingqu.node:setVisible(true)
		else
			node.img_charge_reward_state.node:setVisible(true)
			node.btn_award_lingqu.node:setVisible(false)
			node.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
		end
	end
end

local function CreateCellList(data)
	local cell_list = {}
	for i = 1, data.num do
		local cell = ActBaseCell.New()
		local ph = data.ph_list[data.ph_name .. i]
		cell:SetPosition(ph.x or 0, ph.y or 0)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		data.node:addChild(cell:GetView(), 300)
		table.insert(cell_list, cell)
	end
	return cell_list
end

local function SetCellData(list, data)
	-- 奖励
	for k, v in pairs(list) do
		local item_data = {}
		if nil ~= data[k] then
			item_data.item_id = data[k].id
			item_data.num = data[k].count
			item_data.is_bind = data[k].bind
			item_data.effectId = data[k].effectId
			v:SetData(item_data)
		else
			v:SetData(nil)
		end
		v:SetVisible(data[k] ~= nil)
	end
end

DengluItemRender = DengluItemRender or BaseClass(BaseRender)
function DengluItemRender:__init()
	
end

function DengluItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function DengluItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local size = self.view:getContentSize()
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(size.width / 2, size.height / 2, size.width, size.height, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	
	self.view:addChild(self.cell_charge_list:GetView(), 10)
end

function DengluItemRender:OnFlush()
	if nil == self.data then return	end
	
	-- 奖励
	local data_list = {}
	for k, v in pairs(self.data) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.InitItemDataByCfg(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetCenter()
end

--极品兑换列表render
SuperExchangeRender = SuperExchangeRender or BaseClass(BaseRender)
function SuperExchangeRender:__init()
end

function SuperExchangeRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end

	if nil ~= self.awrad_cell then
		self.awrad_cell:DeleteMe()
		self.awrad_cell = nil
	end
end

function SuperExchangeRender:CreateChild()
	BaseRender.CreateChild(self)

	-- --兑换所需列表
	-- self.cell_charge_list = ListView.New()
	-- self.cell_charge_list:Create(10, 0, 390, 101.9, ScrollDir.Horizontal, SuperExchangeAwardRender, 0, nil, self.ph_list.ph_sp_exc_item)
	-- self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	-- self.cell_charge_list:SetItemsInterval(10)
	-- self.view:addChild(self.cell_charge_list:GetView(), 10)
	
	self.awrad_cell = ActBaseCell.New()
	local ph = self.ph_list.ph_reard_cell11
	self.awrad_cell:SetPosition(ph.x, ph.y)
	self.awrad_cell:SetIndex(i)
	self.awrad_cell:SetAnchorPoint(0, 0)
	self.view:addChild(self.awrad_cell:GetView(), 300)

	XUI.AddClickEventListener(self.node_tree.btn_duihuan_65.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)

	self.node_tree.rich_person_num.node:setHorizontalAlignment(RichHAlignment.HA_LEFT)
	self.node_tree.rich_person_num.node:setIgnoreSize(true)
	-- self.node_tree.rich_qf_num.node:setHorizontalAlignment(RichHAlignment.HA_LEFT)
	-- self.node_tree.rich_qf_num.node:setIgnoreSize(true)
end

function SuperExchangeRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.JPDH, self:GetIndex())	
end

function SuperExchangeRender:OnFlush()
	if nil == self.data then
		return
	end
	-- -- 根据奖励数量判断显示方式 2种
	-- self.data.consume[#self.data.consume].is_last = #self.data.consume > 1 and true
	-- self.data.consume[1].is_only_one = #self.data.consume == 1

	-- -- self.cell_charge_list:SetDataList(self.data.consume)
	-- -- self.cell_charge_list:SetJumpDirection(ListView.Left)

	self.awrad_cell:SetData({item_id = self.data.award[1].id, is_bind = self.data.award[1].bind})

	local cfg = ItemData.Instance:GetItemConfig(self.data.award[1].id)
	if nil == cfg then return end
	self.node_tree.text_name.node:setString(cfg.name)
	local color = string.format("%06x",cfg.color)
	self.node_tree.text_name.node:setColor(Str2C3b(color))


	local consume = self.data.consume[1]

	
	
	local text1 = "现价："
	if consume.type > 0 then
		local item_id = tagAwardItemIdDef[consume.type]
		local path =  RoleData.GetMoneyTypeIconByAwardType(consume.type)
		local is_show_tips = consume.type > 0 and 0 or 1
		local scale = consume.type > 0 and 1 or 0.5

		local num_s = consume.count
		text1 = text1 .. string.format(Language.Bag.ComposeTip3, path,"20,20", scale, consume.id, 0, num_s)
	else
		local item_cfg = ItemData.Instance:GetItemConfig(consume.id)
		local path = ResPath.GetItem(item_cfg.icon)
		local num_s = consume.count
		text1 = text1 .. string.format(Language.Bag.ComposeTip3, path,"20,20", 0.5, consume.id, 1, num_s)
	end
	RichTextUtil.ParseRichText(self.node_tree.rich_consume.node, text1, 18)

	--可兑换数量显示
	if self.data.gr_num and self.data.personLimit > 0 then
		local color = self.data.gr_num >= self.data.personLimit and "DC143C" or "1eff00"
		self.node_tree.btn_duihuan_65.node:setEnabled(not(self.data.gr_num >= self.data.personLimit))
		local remain_num = (self.data.personLimit - self.data.gr_num) or 0 > 0 and (self.data.personLimit - self.data.gr_num) or 0
		local txt_1 = Language.ActivityBrilliant.ExcTip2..": " .. string.format(Language.ActivityBrilliant.NumTip2, color, remain_num)
		RichTextUtil.ParseRichText(self.node_tree.rich_person_num.node, txt_1, 18)
	end
	if self.data.qf_num and self.data.systemLimit > 0 then
		local color = self.data.qf_num >= self.data.systemLimit and "DC143C" or "1eff00"
		self.node_tree.btn_duihuan_65.node:setEnabled(not (self.data.qf_num >= self.data.systemLimit))
		local num =  (self.data.systemLimit - self.data.qf_num) or 0 > 0 and (self.data.systemLimit - self.data.qf_num) or 0
		local txt_2 = Language.ActivityBrilliant.ExcTip..": " .. string.format(Language.ActivityBrilliant.NumTip2, color, num)
		RichTextUtil.ParseRichText(self.node_tree.rich_person_num.node, txt_2, 16)
	end

	if self.data.personLimit < 0 and self.data.systemLimit < 0 then
		RichTextUtil.ParseRichText(self.node_tree.rich_person_num.node, "个人限兑:无限制", 16)
	end

	-- --是否满足兑换条件
	-- for i,v in ipairs(self.data.consume) do
	-- 	local num = BagData.Instance:GetItemNumInBagById(v.id)
	-- 	if num < v.count then
			
		
	-- 	end
	-- end
	local consume_id = self.data.consume[1].id
	local num = BagData.Instance:GetItemNumInBagById(consume_id)
	local count = self.data.consume[1].count or 0
	self.node_tree.btn_duihuan_65.node:setEnabled(num >= count)
end

--兑换所需展示render
-- SuperExchangeAwardRender = SuperExchangeAwardRender or BaseClass(BaseRender)
-- function SuperExchangeAwardRender:__init()
	
-- end

-- function SuperExchangeAwardRender:__delete()
-- 	if nil ~= self.cell then
-- 		self.cell:DeleteMe()
-- 		self.cell = nil
-- 	end
-- end

-- function SuperExchangeAwardRender:CreateChild()
-- 	BaseRender.CreateChild(self)
-- 	self.cell = ActBaseCell.New()
-- 	local ph = self.ph_list.ph_cell
-- 	self.cell:SetPosition(ph.x, ph.y)
-- 	self.cell:SetIndex(i)
-- 	self.cell:SetAnchorPoint(0.5, 0.5)
-- 	self.view:addChild(self.cell:GetView(), 300)



-- 	self.node_tree.rich_num_tip.node:setHorizontalAlignment(RichHAlignment.HA_RIGHT)
-- 	self.node_tree.rich_item_name.node:setHorizontalAlignment(RichHAlignment.HA_LEFT)
-- 	self.node_tree.rich_item_name.node:setIgnoreSize(true)
-- 	-- XUI.RichTextSetCenter(self.node_tree.rich_item_name.node)

-- 	self.node_tree.rich_num_tip.node:setLocalZOrder(301)
-- end

-- function SuperExchangeAwardRender:CreateNumber()
-- 	if nil == self.num_bar then
-- 		self.num_bar = NumberBar.New()
-- 		self.num_bar:SetRootPath(ResPath.GetActivityBrilliant("img_num_"))
-- 		self.num_bar:SetPosition(140, 43)
-- 		self.view:addChild(self.num_bar:GetView(), 300, 300)
-- 	end
-- end

-- function SuperExchangeAwardRender:OnFlush()
-- 	if nil == self.data then
-- 		return
-- 	end
-- 	if self.data.is_last then
-- 		self.node_tree.img_sign.node:setVisible(false)
-- 	end

-- 	if self.data.is_only_one then
-- 		self.node_tree.img_sign.node:loadTexture(ResPath.GetActivityBrilliant("img_multiply"))
-- 		self:CreateNumber()
-- 		self.num_bar:SetNumber(self.data.count)
-- 	end
-- 	local item_data = {}
-- 	item_data.item_id = self.data.id
-- 	item_data.is_bind = 0
-- 	item_data.effectId = self.data.effectId
-- 	self.cell:SetData(item_data)

-- 	local num = BagData.Instance:GetItemNumInBagById(item_data.item_id)
-- 	local cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
-- 	if nil == cfg then return end
-- 	local color = num >= self.data.count and "FFFFFF" or "8B0000"
-- 	local text = string.format(Language.ActivityBrilliant.Text16, color, num, self.data.count)
-- 	RichTextUtil.ParseRichText(self.node_tree.rich_num_tip.node, text, 16)

-- 	RichTextUtil.ParseRichText(self.node_tree.rich_item_name.node, cfg.name, 16)
-- end

-- function SuperExchangeAwardRender:CreateSelectEffect()
-- end

LeichongItemRender = LeichongItemRender or BaseClass(BaseRender)
function LeichongItemRender:__init()
	
end

function LeichongItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end

	if nil ~= self.money then
		self.money:DeleteMe()
		self.money = nil
	end
end

function LeichongItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list["ph_money"]
	local path = ResPath.GetActivityBrilliant("act_2_money_")
	local parent = self.view
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
	number_bar:SetSpace(-7)
	number_bar:SetGravity(NumberBarGravity.Center)
	parent:addChild(number_bar:GetView(), 99)
	self.money = number_bar

	local ph = self.ph_list["ph_award_list"]
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree.btn_award_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
end


function LeichongItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	if self.can_get_reward then
		ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.LC, self.data.index)
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	end
end


function LeichongItemRender:OnFlush()
	if nil == self.data then
		return
	end
	local index = ActivityBrilliantData.Instance:GetOperActViewIndex(ACT_ID.QG)
	local view_def = ViewDef["ActivityBrilliant" .. index]
	local view = ViewManager.Instance:GetView(view_def)
	local index = view:GetShowIndex()
	local str = self.data.money
	self.can_get_reward = ActivityBrilliantData.Instance:GetTodayRecharge() >= str
	local is_lingqu = self.data.sign > 0
	self.money:SetNumber(self.data.money or 0)

	-- 奖励
	local data_list = {}
	for k, v in pairs(self.data.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)
	
	if is_lingqu == true then
		self.node_tree.img_charge_reward_state.node:setVisible(true)
		self.node_tree.btn_award_lingqu.node:setVisible(false)
		self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
	else

		self.node_tree.img_charge_reward_state.node:setVisible(false)
		self.node_tree.btn_award_lingqu.node:setVisible(true)
		if self.can_get_reward then
			self.node_tree.btn_award_lingqu.node:setTitleText(Language.Common.LingQuJiangLi)
			-- 需要显示才创建红点
			if nil == self.node_tree["btn_award_lingqu"].node.UpdateReimd then
				XUI.AddRemingTip(self.node_tree["btn_award_lingqu"].node)
			end
		else
			self.node_tree.btn_award_lingqu.node:setTitleText(Language.Common.Recharge)
		end

		if self.node_tree["btn_award_lingqu"].node.UpdateReimd then
			self.node_tree["btn_award_lingqu"].node:UpdateReimd(self.can_get_reward)
		end
	end
end

-- 创建选中特效
function LeichongItemRender:CreateSelectEffect()
	-- local size = self.node_tree["bg_1"].node:getContentSize()
	-- local x, y = self.node_tree["bg_1"].node:getPosition()
	-- self.select_effect = XUI.CreateImageViewScale9(x, y, size.width, size.height, ResPath.GetCommon("img9_285"), true)
	-- if nil == self.select_effect then
	-- 	ErrorLog("BaseRender:CreateSelectEffect fail")
	-- 	return
	-- end

	-- self.view:addChild(self.select_effect, 999)
end

QianggouItemRender = QianggouItemRender or BaseClass(BaseRender)
function QianggouItemRender:__init()
	
end

function QianggouItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function QianggouItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list["ph_award_list"]
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree.btn_buy.node, BindTool.Bind(self.OnClickBuyBtn, self), true)
end

function QianggouItemRender:OnClickBuyBtn()
	if self.data == nil then return end
	local act_id = ACT_ID.QG
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index)
end

function QianggouItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function QianggouItemRender:OnFlush()
	if nil == self.data then
		return
	end
	local is_buy = self.data.sign > 0

	local data_list = {}
	for k, v in pairs(self.data.award) do
		table.insert(data_list, ItemData.InitItemDataByCfg(v))
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)

	local money_icon = ActivityBrilliantData.Instance.GetMoneyTypeIcon(self.data.money_type)
	self.node_tree.lbl_gold_cost.node:setString(self.data.money)
	self.node_tree.money_type_icon.node:loadTexture(money_icon)
	
	if not is_buy then
		self.node_tree.img_charge_reward_state.node:setVisible(false)
		self.node_tree.btn_buy.node:setVisible(true)
	else
		self.node_tree.img_charge_reward_state.node:setVisible(true)
		self.node_tree.btn_buy.node:setVisible(false)
	end

	local discount = self.data.discount or 0
	self.node_tree["lbl_discount"].node:setString(discount)
end

JiejingItemRender = JiejingItemRender or BaseClass(BaseRender)
function JiejingItemRender:__init()
	
end

function JiejingItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function JiejingItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(195, 5, 375, 90, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree.btn_award_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
end

function JiejingItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	ActivityBrilliantCtrl.Instance.ActivityReq(4, self.data.act_id, self.data.index)
end


function JiejingItemRender:OnFlush()
	if nil == self.data then
		return
	end
	
	
	local count = self.data.count
	local is_lingqu = self.data.sign > 0
	self.can_get_reward = count <= ActivityBrilliantData.Instance.jiejing_num[self.data.act_id]
	self.node_tree.txt_baoshi_count.node:setString(count)
	-- 奖励
	local data_list = {}
	for k, v in pairs(self.data.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)
	
	if is_lingqu == true then
		self.node_tree.img_charge_reward_state.node:setVisible(true)
		self.node_tree.btn_award_lingqu.node:setVisible(false)
		self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
	else
		if self.can_get_reward then
			self.node_tree.img_charge_reward_state.node:setVisible(false)
			self.node_tree.btn_award_lingqu.node:setVisible(true)
		else
			self.node_tree.img_charge_reward_state.node:setVisible(true)
			self.node_tree.btn_award_lingqu.node:setVisible(false)
			self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
		end
	end
	
end




XunbaoItemRender = XunbaoItemRender or BaseClass(BaseRender)
function XunbaoItemRender:__init()
	
end

function XunbaoItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function XunbaoItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(195, 5, 375, 90, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree.btn_award_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
end

function XunbaoItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	local act_id = ACT_ID.XB
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index)
end
function XunbaoItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function XunbaoItemRender:OnFlush()
	if nil == self.data then return end
	local str = self.data.count
	local is_lingqu = self.data.sign > 0
	self.can_get_reward = str < ActivityBrilliantData.Instance.xunbao_num + 1
	self.node_tree.txt_xunbao_count.node:setString(string.format(Language.ActivityBrilliant.XunbaoTip, str))
	-- 奖励
	
	local data_list = {}
	for k, v in pairs(self.data.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)
	
	if is_lingqu == true then
		self.node_tree.img_charge_reward_state.node:setVisible(true)
		self.node_tree.btn_award_lingqu.node:setVisible(false)
		self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
	else
		if self.can_get_reward then
			self.node_tree.img_charge_reward_state.node:setVisible(false)
			self.node_tree.btn_award_lingqu.node:setVisible(true)
		else
			self.node_tree.img_charge_reward_state.node:setVisible(true)
			self.node_tree.btn_award_lingqu.node:setVisible(false)
			self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
		end
	end
	
end


ActRankItemRender = ActRankItemRender or BaseClass(BaseRender)
function ActRankItemRender:__init()
	
end

function ActRankItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function ActRankItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list["ph_award_list"] or {x = 0, y = 0, w = 0, h = 0}
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	-- self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree.btn_gift_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
end

function ActRankItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function ActRankItemRender:OnFlush()
	if nil == self.data then
		return
	end
	
	local r_index = self:GetIndex()
	local act_cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.data.act_id)
	local mine_num = ActivityBrilliantData.Instance.mine_num[self.data.act_id]
	if nil == act_cfg then return end
	local reward = nil
	local text1 = ""
	local text2 = ""
	local path = ""
	if act_cfg.config.join_award and r_index == #act_cfg.config.rankings + 1 then
		local can_get_reward = mine_num >= act_cfg.config.join_award.count
		local is_lingqu = self.data[3] > 0
		-- text1 = Language.ActivityBrilliant.Text4 --参与奖
		reward = act_cfg.config.join_award
		if is_lingqu == true then
			self.node_tree.img_charge_reward_state.node:setVisible(true)
			self.node_tree.btn_gift_lingqu.node:setVisible(false)
			self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
		else
			if can_get_reward then
				self.node_tree.img_charge_reward_state.node:setVisible(false)
				self.node_tree.btn_gift_lingqu.node:setVisible(true)
			else
				self.node_tree.img_charge_reward_state.node:setVisible(true)
				self.node_tree.btn_gift_lingqu.node:setVisible(false)
				self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
			end
		end
		path = ResPath.GetActivityBrilliant("act_17_1")
	else
		text1 = self.data[2]
		text2 = text1 == Language.Common.XuWenYiDai and "%s钻石上榜" or "%s钻石"
		text2 = string.format(text2, self.data[3])

		reward = act_cfg.config.rankings[r_index]
		self.node_tree.img_charge_reward_state.node:setVisible(false)
		self.node_tree.btn_gift_lingqu.node:setVisible(false)
		path = ResPath.GetActivityBrilliant("act_17_ranking_" .. self.data[1])
	end
	self.node_tree["img_ranking"].node:loadTexture(path)
	self.node_tree["lbl_gift_rolename"].node:setString(text1)
	self.node_tree["lbl_act_count"].node:setString(text2)
	-- 奖励
	local data_list = {}
	for k, v in pairs(reward.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)	
end

function ActRankItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	ActivityBrilliantCtrl.Instance.ActivityReq(4, self.data.act_id)
end

LeijiItemRender = LeijiItemRender or BaseClass(BaseRender)
function LeijiItemRender:__init()
	
end

function LeijiItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function LeijiItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph  = self.ph_list["ph_award_list"]
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree.btn_award_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)

	XUI.RichTextSetCenter(self.node_tree["rich_all_charge"].node)
end

function LeijiItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	if self.can_get_reward then
		local act_id = ACT_ID.LJ
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index)
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	end
end

function LeijiItemRender:OnFlush()
	if nil == self.data then return	end
	
	local money = self.data.money or 0
	local all_charge = self.data.all_charge or 0
	self.can_get_reward = all_charge >= money
	local is_lingqu = self.data.sign > 0
	self.node_tree.txt_charge_money_count.node:setString(money .. Language.Common.Diamond)

	local color = self.can_get_reward and COLORSTR.GREEN or COLORSTR.RED
	local text = string.format("({color;%s;%s}/%s)", color, all_charge, money)
	local rich = self.node_tree["rich_all_charge"].node
	rich = RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.GREEN)
	rich:refreshView()

	-- 奖励
	local data_list = {}
	for k, v in pairs(self.data.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)
	
	if is_lingqu == true then
		self.node_tree.img_charge_reward_state.node:setVisible(true)
		self.node_tree.btn_award_lingqu.node:setVisible(false)
		self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_21"))
		self.node_tree["rich_all_charge"].node:setVisible(false)
	else
		self.node_tree.img_charge_reward_state.node:setVisible(false)
		self.node_tree.btn_award_lingqu.node:setVisible(true)
		self.node_tree["rich_all_charge"].node:setVisible(true)
		if self.can_get_reward then
			self.node_tree.btn_award_lingqu.node:setTitleText(Language.Common.LingQuJiangLi)
		else
			self.node_tree.btn_award_lingqu.node:setTitleText(Language.Common.Recharge)
		end
	end	

end


--------------------------
-----豪礼
--------------------------
GiftItemRender = GiftItemRender or BaseClass(BaseRender)
function GiftItemRender:__init()
end

function GiftItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function GiftItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list["ph_award_list"] or {x = 0, y = 0, w = 0, h = 0}
	self.cell_charge_list = {}
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	-- self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree.btn_gift_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
end

function GiftItemRender:OnFlush()
	if nil == self.data then
		return
	end
	local index = ActivityBrilliantData.Instance:GetOperActViewIndex(self.act_id)
	local view_def = ViewDef["ActivityBrilliant" .. index]
	local view = ViewManager.Instance:GetView(view_def)
	local index = view:GetShowIndex()
	
	local r_index = self:GetIndex()
	local act_cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.data.act_id)
	local mine_num = ActivityBrilliantData.Instance.mine_num[self.data.act_id]
	if nil == act_cfg then return end
	local reward = nil
	local text1 = ""
	local text2 = ""
	local path = ""
	if act_cfg.config.join_award and r_index == #act_cfg.config.rankings + 1 then
		local can_get_reward = mine_num >= act_cfg.config.join_award.count
		local is_lingqu = self.data[3] > 0
		-- text1 = Language.ActivityBrilliant.Text4 --参与奖
		reward = act_cfg.config.join_award
		if is_lingqu == true then
			self.node_tree.img_charge_reward_state.node:setVisible(true)
			self.node_tree.btn_gift_lingqu.node:setVisible(false)
			self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
		else
			if can_get_reward then
				self.node_tree.img_charge_reward_state.node:setVisible(false)
				self.node_tree.btn_gift_lingqu.node:setVisible(true)
			else
				self.node_tree.img_charge_reward_state.node:setVisible(true)
				self.node_tree.btn_gift_lingqu.node:setVisible(false)
				self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
			end
		end
		path = ResPath.GetActivityBrilliant("act_17_1")
	else
		text1 = self.data[2]
		text2 = text1 == Language.Common.XuWenYiDai and "%s钻石上榜" or "%s钻石"
		text2 = string.format(text2, self.data[3])

		reward = act_cfg.config.rankings[r_index]
		self.node_tree.img_charge_reward_state.node:setVisible(false)
		self.node_tree.btn_gift_lingqu.node:setVisible(false)
		path = ResPath.GetActivityBrilliant("act_17_ranking_" .. self.data[1])
	end
	self.node_tree["img_ranking"].node:loadTexture(path)
	self.node_tree["lbl_gift_rolename"].node:setString(text1)
	self.node_tree["lbl_act_count"].node:setString(text2)

	-- 奖励
	local data_list = {}
	for k, v in pairs(reward.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.InitItemDataByCfg(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)
end

function GiftItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	ActivityBrilliantCtrl.Instance.ActivityReq(4, self.data.act_id)
end


-------------------
---回馈
-------------------
HuikuiItemRender = HuikuiItemRender or BaseClass(BaseRender)
function HuikuiItemRender:__init()
	
end

function HuikuiItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function HuikuiItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_charge_list = {}
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(240, 15, 256, 90, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree.btn_award_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
end


function HuikuiItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function HuikuiItemRender:OnFlush()
	if nil == self.data then
		return
	end
	local count = self.data.count
	local is_lingqu = self.data.sign > 0
	self.can_get_reward = count <= ActivityBrilliantData.Instance.jiejing_num[self.data.act_id]
	if self.data.act_id == 31 then
		self.node_tree.lbl_conusm_num.node:setString(string.format(Language.ActivityBrilliant.HKWing, self.data.count))
	else
		self.node_tree.lbl_conusm_num.node:setString(string.format(Language.ActivityBrilliant.HKJiejing, self.data.count))
	end

	local data_list = {}
	for k, v in pairs(self.data.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)
	
	
	if is_lingqu == true then
		self.node_tree.img_charge_reward_state.node:setVisible(true)
		self.node_tree.btn_award_lingqu.node:setVisible(false)
		self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
	else
		if self.can_get_reward then
			self.node_tree.img_charge_reward_state.node:setVisible(false)
			self.node_tree.btn_award_lingqu.node:setVisible(true)
		else
			self.node_tree.img_charge_reward_state.node:setVisible(true)
			self.node_tree.btn_award_lingqu.node:setVisible(false)
			self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
		end
	end
end


function HuikuiItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	ActivityBrilliantCtrl.Instance.ActivityReq(4, self.data.act_id, self.data.index)
end

ActBaseCell = ActBaseCell or BaseClass(BaseCell)

function ActBaseCell:OnFlush()
	BaseCell.OnFlush(self)
	self:SetQualityEffect(self.data and self.data.effectId or 0)
end

function ActBaseCell:CreateSelectEffect()
end

SecretShopItemRender = SecretShopItemRender or BaseClass(BaseRender)
function SecretShopItemRender:__init()
	
end

function SecretShopItemRender:__delete()
	if nil ~= self.qianggou_cell then
		self.qianggou_cell:DeleteMe()
		self.qianggou_cell = nil
	end
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function SecretShopItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell = ActBaseCell.New()
	local ph = self.ph_list["ph_item_cell"]
	self.cell:SetPosition(ph.x, ph.y)
	self.cell:SetIndex(i)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.view:addChild(self.cell:GetView(), 300)
	XUI.AddClickEventListener(self.node_tree.layout_buy.node, BindTool.Bind(self.OnClickBuyBtn, self), true)
	self.node_tree.img_charge_reward_state.node:setVisible(false)
end

function SecretShopItemRender:OnClickBuyBtn()
	if self.data == nil then return end
	
	self.alert = self.alert or Alert.New()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data[1].id)
	if item_cfg then
		local color = string.format("%06x", item_cfg.color)
		local str = string.format(Language.Shop.BuyTips, self.data.money, ShopData.GetMoneyTypeName(self.data.money_type), color, item_cfg.name, self.data[1].count)
		self.alert:SetLableString(str)
		self.alert:SetOkFunc(function()
			local act_id = ACT_ID.SHOP
			ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index)
		end)
		self.alert:Open()
	end
end

function SecretShopItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function SecretShopItemRender:OnFlush()
	if nil == self.data then
		return
	end
	local item_config = ItemData.Instance:GetItemConfig(self.data[1].id)
	if nil == item_config then
		return
	end
	local is_buy = self.data.sign > 0
	local item_data = {}
	if nil ~= self.data[1] then
		item_data.item_id = self.data[1].id
		item_data.num = self.data[1].count
		item_data.is_bind = self.data[1].bind
		item_data.effectId = self.data[1].effectId
		self.cell:SetData(item_data)
	else
		self.cell:SetData(nil)
	end
	self.cell:SetVisible(self.data[1] ~= nil)
	local money_icon = ActivityBrilliantData.Instance.GetMoneyTypeIcon(self.data.money_type)
	self.node_tree.lbl_item_sale_cost.node:setString(self.data.money)
	self.node_tree.lbl_item_cost.node:setString(self.data.old_money)
	self.node_tree.lbl_item_name.node:setString(item_config.name)
	self.node_tree.img_cost.node:loadTexture(money_icon)
	self.node_tree.img_cost_2.node:loadTexture(money_icon)
	if self.data.old_money > 1000 then
		self.node_tree.text_1.node:setScaleX(3)
	else
		self.node_tree.text_1.node:setScaleX(2)
	end
	
	if not is_buy then
		self.node_tree.img_charge_reward_state.node:setVisible(false)
		self.node_tree.layout_buy.node:setVisible(true)
	else
		self.node_tree.img_charge_reward_state.node:setVisible(true)
		self.node_tree.layout_buy.node:setVisible(false)
		self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_5"))
	end
end

function SecretShopItemRender:CreateSelectEffect()
end


QmQianggouItemRender = QmQianggouItemRender or BaseClass(BaseRender)
function QmQianggouItemRender:__init()
	
end

function QmQianggouItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function QmQianggouItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list["ph_award_list"]
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	-- self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)

	self.node_tree["img9_line"].node:setAnchorPoint(0, 0.5)
	
	XUI.AddClickEventListener(self.node_tree.btn_buy.node, BindTool.Bind(self.OnClickBuyBtn, self), true)
end

function QmQianggouItemRender:OnClickBuyBtn()
	if self.data == nil then return end
	local act_id = ACT_ID.QMQG
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index, self.data.act_day)
end

function QmQianggouItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function QmQianggouItemRender:OnFlush()
	if nil == self.data then
		return
	end
	local is_buy = self.data.sign > 0
	local data_list = {}
	for k, v in pairs(self.data.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.InitItemDataByCfg(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)

	local money_icon = ActivityBrilliantData.Instance.GetMoneyTypeIcon(self.data.money_type)
	self.node_tree.lbl_gold_cost.node:setString(self.data.money_value)
	self.node_tree.lbl_sale_num.node:setString(self.data.str)
	self.node_tree.lbl_buy_num.node:setString(string.format(Language.ActivityBrilliant.Text5, self.data.buy_num))
	self.node_tree["money_type_icon_1"].node:loadTexture(money_icon)
	self.node_tree["money_type_icon_2"].node:loadTexture(money_icon)
	
	if not is_buy then
		self.node_tree.img_charge_reward_state.node:setVisible(false)
		self.node_tree.btn_buy.node:setVisible(true)
	else
		self.node_tree.img_charge_reward_state.node:setVisible(true)
		self.node_tree.btn_buy.node:setVisible(false)
		self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_5"))
		self.node_tree.lbl_buy_num.node:setVisible(false)
	end

	if self.data.viptype > 0 then
		local _type = math.floor(self.data.viptype / 5) + 1
		local lv = self.data.viptype % 5
		local path
		path = ResPath.GetActivityBrilliant("act_37_diamond_" .. _type)
		self.node_tree["img_diamond_type"].node:loadTexture(path)
		path = ResPath.GetActivityBrilliant("act_37_lv_" .. lv)
		self.node_tree["img_diamond_lv"].node:loadTexture(path)

		self.node_tree["img_all"].node:setVisible(false)
		self.node_tree["img_diamond_type"].node:setVisible(true)
		self.node_tree["img_diamond_lv"].node:setVisible(true)
		self.node_tree["img_text"].node:setVisible(true)
	else
		self.node_tree["img_all"].node:setVisible(true)
		self.node_tree["img_diamond_type"].node:setVisible(false)
		self.node_tree["img_diamond_lv"].node:setVisible(false)
		self.node_tree["img_text"].node:setVisible(false)
	end

	local original_price = self.data.original_price or 0
	self.node_tree["lbl_old_gold_cost"].node:setString(original_price)
	self.node_tree["img9_line"].node:setContentWH(80 + string.len(original_price)*12, 5)
end

function QmQianggouItemRender:CreateSelectEffect()
end

JieriItemRender = JieriItemRender or BaseClass(BaseRender)
function JieriItemRender:__init()
	
end

function JieriItemRender:__delete()
	if nil ~= self.cell_charge_list then
		for k, v in pairs(self.cell_charge_list) do
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_charge_list = {}
	
	if nil ~= self.reward then
		self.reward:DeleteMe()
		self.reward = nil
	end
end

function JieriItemRender:CreateChild()
	BaseRender.CreateChild(self)

	
	self.reward = ActBaseCell.New()
	local ph = self.ph_list["ph_award_cell"]
	self.reward:SetPosition(ph.x, ph.y)
	self.reward:SetAnchorPoint(0.5, 0.5)
	self.view:addChild(self.reward:GetView(), 300)
	
	XUI.AddClickEventListener(self.node_tree.btn_duihuan.node, BindTool.Bind(self.OnClickBuyBtn, self), true)

	local ph = self.ph_list["ph_jieri_cell_list"]
	self.scroll_view = XScrollView:create(ScrollDir.Horizontal)
	self.scroll_view:setAnchorPoint(0, 0)
	self.scroll_view:setPosition(ph.x, ph.y)
	self.scroll_view:setContentWH(ph.w, ph.h)
	self.view:addChild(self.scroll_view, 2)
end

function JieriItemRender:OnClickBuyBtn()
	if self.data == nil then return end
	local act_id = ACT_ID.JR
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index)
end

function JieriItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function JieriItemRender:OnFlush()
	if nil == self.data then
		return
	end
	self.node_tree.btn_duihuan.node:setEnabled(self.data.can_lingqu)
	local parent = self.scroll_view:getInnerContainer()
	local parent_size = parent:getContentSize()
	local y = parent_size.height / 2
	local cell_width = BaseCell.SIZE + 10

	local cell_count = 0
	self.cell_charge_list = self.cell_charge_list or {}
	for index, item in ipairs(self.data.consume or {}) do
		local item_data = ItemData.InitItemDataByCfg(item)
		local cell = self.cell_charge_list[index]
		if not self.cell_charge_list[index] then
			local x = cell_width * (index - 1)
			cell = ActBaseCell.New()
			cell:GetView():setAnchorPoint(0, 0.5)
			cell:GetView():setPosition(x, y)
			parent:addChild(cell:GetView())
			self.cell_charge_list[index] = cell
		end
		cell:SetData(item_data)

		local num = BagData.Instance:GetItemNumInBagById(item_data.item_id)
		local consume = self.data.consume and self.data.consume[index] or {}
		local consume_count = consume.count or 0
		local text = string.format("%d/%d", num, consume_count)
		local color = num >= consume_count and COLOR3B.GREEN or COLOR3B.RED 
		cell:SetRightBottomText(text, color)
		cell_count = cell_count + 1
	end
	parent:setContentWH(cell_width*cell_count, parent_size.height)

	local ph = self.ph_list["ph_jieri_cell_list"]
	local width = math.min(cell_width*cell_count, ph.w) -- 限制 self.scroll_view 的最大宽度
	self.scroll_view:setContentWH(width, parent_size.height)
	self.scroll_view:jumpToTop()

	local award = self.data.award and self.data.award[1] or {}
	self.reward:SetData(ItemData.InitItemDataByCfg(award))
end


DuihuanItemRender = DuihuanItemRender or BaseClass(BaseRender)
function DuihuanItemRender:__init()
end

function DuihuanItemRender:__delete()
	if nil ~= self.cell_charge_list then
		for k, v in pairs(self.cell_charge_list) do
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_charge_list = {}
	
	if nil ~= self.reward then
		self.reward:DeleteMe()
		self.reward = nil
	end
	
	if nil ~= self.item_config_bind then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
		self.item_config_bind = nil
	end
end

function DuihuanItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_charge_list = {}
	self.reward = nil
	
	self.reward = ActBaseCell.New()
	local ph = self.ph_list["ph_duihuan_cell"]
	self.reward:SetPosition(ph.x, ph.y)
	self.reward:SetAnchorPoint(0.5, 0.5)
	self.view:addChild(self.reward:GetView(), 300)
	
	XUI.AddClickEventListener(self.node_tree.btn_duihuan.node, BindTool.Bind(self.OnClickBuyBtn, self), true)
end

function DuihuanItemRender:OnClickBuyBtn()
	if self.data == nil then return end
	local act_id = ACT_ID.DH
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index)
end

function DuihuanItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function DuihuanItemRender:OnFlush()
	if nil == self.data then
		return
	end
	self.node_tree.btn_duihuan.node:setEnabled(self.data.can_duihuan)
	local item_data = {item_id = self.data.award[1].id, num = self.data.award[1].count, is_bind = self.data.award[1].id}
	self.reward:SetData(item_data)
	
	local text = ""
	local text_2 = ""
	if 0 == self.data.personal then
		text = Language.ActivityBrilliant.Text17
	else
		text = string.format(Language.ActivityBrilliant.Text13, self.data.my_num .. "/" .. self.data.personal)
	end
	
	if 0 == self.data.fullDress then
		text_2 = Language.ActivityBrilliant.Text17
	else
		text_2 = self.data.fullDress - self.data.all_num
	end
	self.node_tree.lbl_tip.node:setString(text)
	self.node_tree.lbl_conusm_num.node:setString(text_2 .. Language.Common.UnitName[6])
	
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.award[1].id, item_data)
	if nil == item_cfg then
		if nil == self.item_config_bind then
			self.item_config_bind = BindTool.Bind(self.ItemConfigCallBack, self)
			ItemData.Instance:NotifyItemConfigCallBack(self.item_config_bind)
		end
		return
	else
		if nil ~= self.item_config_bind then
			ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
			self.item_config_bind = nil
		end
	end
	-- local color = Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6))
	-- self.node_tree.lbl_item_name.node:setString(ItemData.Instance:GetItemName(self.data.award[1].id))
	-- self.node_tree.lbl_item_name.node:setColor(color)

	local item_icon = ResPath.GetItem(self.data.icon_id or 1)
	local text = string.format(Language.ActivityBrilliant.Text15, item_icon, self.data.cost)
	local rich = self.node_tree["rich_consume"].node
	rich = RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.WHITE)
	rich:refreshView()
end

function DuihuanItemRender:ItemConfigCallBack(item_config_t)
	if nil ~= self.data and nil ~= self.data.award then
		for k, v in pairs(item_config_t) do
			if v.item_id == self.data.award[1].id then
				self:Flush()
				return
			end
		end
	end
end

--------------------------
-----连续充值
--------------------------
LXChargeItemRender = LXChargeItemRender or BaseClass(BaseRender)
function LXChargeItemRender:__init()
	
end

function LXChargeItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function LXChargeItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list["ph_award_list"]
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:SetItemsInterval(2)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree["btn_gift_lingqu"].node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
end

function LXChargeItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	local title_text = self.node_tree["btn_gift_lingqu"].node:getTitleText()
	if Language.Common.Recharge == title_text then
		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	elseif Language.Common.LingQuJiangLi == title_text then
		local act_id = self.data.act_id or 0
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index)
	end
end

function LXChargeItemRender:OnFlush()
	if nil == self.data then return	end

	local data_list = {}
	for k, v in pairs(self.data) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)

	local keepday = self.data.keepday
	local payday = self.data.payday
	if payday >= keepday then
		payday = keepday
	end
	local cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.data.act_id)
	local pay = cfg and cfg.config and cfg.config.pay or 0
	self.node_tree["lbl_need_day"].node:setString(keepday .. Language.Common.TimeList.d)

	local is_lingqu = self.data.sign > 0
	
	if payday < keepday then
		self.node_tree.img_charge_reward_state.node:setVisible(false)
		self.node_tree["btn_gift_lingqu"].node:setVisible(true)
		self.node_tree["btn_gift_lingqu"].node:setTitleText(Language.Common.Recharge)
		self.node_tree["lbl_pay_day"].node:setVisible(true)
		self.node_tree["lbl_pay_day"].node:setString(string.format(Language.ActivityBrilliant.Text41, payday, keepday))
	else
		if is_lingqu == true then
			self.node_tree["btn_gift_lingqu"].node:setVisible(false)
			self.node_tree["lbl_pay_day"].node:setVisible(false)
			self.node_tree.img_charge_reward_state.node:setVisible(true)
			self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_21"))
		else
			self.node_tree.img_charge_reward_state.node:setVisible(false)
			self.node_tree["lbl_pay_day"].node:setVisible(true)
			self.node_tree["lbl_pay_day"].node:setString(string.format(Language.ActivityBrilliant.Text41, payday, keepday))
			self.node_tree["btn_gift_lingqu"].node:setVisible(true)
			self.node_tree["btn_gift_lingqu"].node:setTitleText(Language.Common.LingQuJiangLi)
		end
	end
end

--------------------------
-----特惠礼包 44 ACT_ID.THLB
--------------------------
THlibaoItemRender = THlibaoItemRender or BaseClass(BaseRender)
function THlibaoItemRender:__init()
	
end

function THlibaoItemRender:__delete()
	if nil ~= self.th_cell then
		self.th_cell:DeleteMe()
		self.th_cell = nil
	end
end

function THlibaoItemRender:CreateChild()
	BaseRender.CreateChild(self)

	self.th_cell = ActBaseCell.New()
	local ph = self.ph_list["ph_libao_cell"]
	self.th_cell:SetPosition(ph.x, ph.y)
	self.th_cell:SetAnchorPoint(0.5, 0.5)
	self.view:addChild(self.th_cell:GetView(), 300)
	XUI.AddClickEventListener(self.node_tree.btn_libao_buy.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)

	local rich = self.node_tree["rich_libao_price"].node
	XUI.RichTextSetCenter(rich)
end

function THlibaoItemRender:OnFlush()
	if nil == self.data then return end
	local cfg = self.data.cfg
	local item = cfg.commodity and cfg.commodity[1]
	local item_data = ItemData.InitItemDataByCfg(item)
	self.th_cell:SetData(item_data) -- 抢购物品图标

	-- 抢购物品名称
	local item_cfg = ItemData.Instance:GetItemConfig(item.id)
	local str = ItemData.Instance:GetItemName(item.id)
	local color = Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6))
	self.node_tree.lbl_libao_name.node:setString(str)
	self.node_tree.lbl_libao_name.node:setColor(color)

	-- 抢购价格
	local consume = cfg.consume and cfg.consume[1] or {}
	local count = BagData.GetConsumesCount(consume.id, consume.type)
	local cfg_count = consume.count or 0
	local bool = count >= cfg_count
	local color = bool and COLORSTR.GREEN or COLORSTR.RED
	-- 抢购价的图标
	local award_type = consume.type or 0
	local money_icon = RoleData.GetMoneyTypeIconByAwardType(award_type)
	local text = string.format(Language.ActivityBrilliant.Text36, money_icon, color, cfg_count)
	local rich = self.node_tree["rich_libao_price"].node
	rich = RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.WHITE)
	rich:refreshView()
	self.node_tree["btn_libao_buy"].node:setEnabled(bool)

	-- "已售完"标签 和 "购买"按钮
	local can_buy_times = cfg.buyCount or 0
	if can_buy_times == 0 then
		-- 为0时,不限制购买
		self.node_tree.btn_libao_buy.node:setVisible(true)
		self.node_tree.img_had_buy.node:setVisible(false)
		self.node_tree["lbl_can_buy_times"].node:setVisible(false)
	else
		local can_buy = can_buy_times > self.data.is_buy -- 可购买
		self.node_tree.btn_libao_buy.node:setVisible(can_buy)
		self.node_tree.img_had_buy.node:setVisible(not can_buy)

		local times = math.max(can_buy_times - self.data.is_buy, 0) 
		--例 可购买次数：2
		local text = Language.ActivityBrilliant.Text30 .. times
		self.node_tree["lbl_can_buy_times"].node:setString(text)
		self.node_tree["lbl_can_buy_times"].node:setVisible(true)
	end
end

function THlibaoItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	local act_id = ACT_ID.THLB
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index)
end 

function THlibaoItemRender:SetLeftTime(time)
	if self.node_tree["lbl_left_time"] then
		self.node_tree["lbl_left_time"].node:setString(time)
	end
end

--------------------------
-----单笔充值
--------------------------
SingleChargeItemRender = SingleChargeItemRender or BaseClass(BaseRender)
function SingleChargeItemRender:__init()
end
--资源释放
function SingleChargeItemRender:__delete()
	if nil ~= self.cell_award_list then
		for k,v in pairs(self.cell_award_list) do
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_award_list = {}
end
--item创建
function SingleChargeItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list["ph_award_list"] or {x = 0, y = 0, w = 10, h = 10}
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree.btn_award_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)


	local ph = self.ph_list["ph_money"] or {x = 0, y = 0, w = 10, h = 10}
	local path = ResPath.GetActivityBrilliant("act_2_money_")
	local parent = self.view
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x - 9, ph.y, 0, 0, path) -- x 偏移一个数字宽度的一半,以达到居中的效果
	number_bar:SetSpace(-4)
	number_bar:SetGravity(NumberBarGravity.Right) -- 数字从右往左排列
	parent:addChild(number_bar:GetView(), 99)
	self.money = number_bar

	local number_bar = NumberBar.New()
	number_bar:Create(ph.x - 9, ph.y, 0, 0, path) -- x 偏移一个数字宽度的一半,以达到居中的效果
	number_bar:SetSpace(-4)
	number_bar:SetGravity(NumberBarGravity.Left) -- 数字从左往右排列
	parent:addChild(number_bar:GetView(), 99)
	self.money2 = number_bar
end
--点击监听
function SingleChargeItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	local lingqu_times = self.data.lingqu_times
	local sign_times = self.data.sign_times
	if lingqu_times > sign_times then
		local act_id = ACT_ID.DBCZ
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index)
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	end
end
--item请求后刷新
function SingleChargeItemRender:OnFlush()
	if nil == self.data then
		return
	end
	--设置格子数据
	local data_list = {}
	for k, v in pairs(self.data.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.InitItemDataByCfg(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)

	local times = self.data.times
	local lingqu_times = self.data.lingqu_times
	local sign_times = self.data.sign_times
	
	local show_money = self.data.show_money or {0, 0}
	self.money:SetNumber(show_money[1])
	self.money2:SetNumber(- show_money[2])
	
	self.node_tree.lbl_charge_times.node:setString(string.format(Language.ActivityBrilliant.Text20, lingqu_times, times))
	-- 判断是否可领取、已领取、未达成
	if times == sign_times then
		self.node_tree.img_charge_reward_state.node:setVisible(true)
		self.node_tree.btn_award_lingqu.node:setVisible(false)
		self.node_tree.lbl_charge_times.node:setColor(COLOR3B.RED)
		self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
	else
		self.node_tree.img_charge_reward_state.node:setVisible(false)
		self.node_tree.btn_award_lingqu.node:setVisible(true)

		if lingqu_times > sign_times then
			self.node_tree.lbl_charge_times.node:setColor(COLOR3B.GREEN)
			self.node_tree["btn_award_lingqu"].node:setTitleText(Language.Common.LingQuJiangLi)
		else
			self.node_tree.lbl_charge_times.node:setColor(COLOR3B.RED)
			self.node_tree["btn_award_lingqu"].node:setTitleText(Language.Common.Recharge)
		end
	end
end

----------------------------------------------
-- 翻牌记录 render
----------------------------------------------
BrandRecordRender = BrandRecordRender or BaseClass(BaseRender)
function BrandRecordRender:__init(w, h, list_view)
	self.view_size = cc.size(268, 20)
	self.view:setContentSize(self.view_size)
	self.list_view = list_view
end

function BrandRecordRender:__delete()
end

function BrandRecordRender:CreateChild()
	BrandRecordRender.super.CreateChild(self)

	self.rich_text = RichTextUtil.ParseRichText(nil, "", 20, nil, 0, 0, self.view_size.width, self.view_size.height)
	self.rich_text:setAnchorPoint(0, 0)
	self.rich_text:setIgnoreSize(true)
	self.view:addChild(self.rich_text, 9)
end

function BrandRecordRender:OnFlush()
	if nil == self.data then
		return
	end

	local item_str = RichTextUtil.CreateItemStr(self.data.item_data)
	if nil == item_str then
		return
	end

	local content = string.format(Language.ActivityBrilliant.BrandRecordRichFormat, "0xffff00", self.data.role_name, self.data.role_id or 0) .. item_str
	RichTextUtil.ParseRichText(self.rich_text, content, 18)
	self.rich_text:refreshView()
	local inner_size = self.rich_text:getInnerContainerSize()
	local size = {
		width = math.max(inner_size.width, self.view_size.width),
		height = math.max(inner_size.height, self.view_size.height),
	}
	self.rich_text:setContentSize(size)
	self.view:setContentSize(size)
	self.list_view:requestRefreshView()
end

function BrandRecordRender:CreateSelectEffect()
end

----------------------------------------------
-- 牌 render
----------------------------------------------
local BRAND_STATE = {
	NONE = -1,
	OPEN = 1,
	CLOSE = 0,
	START = 2,
	PACK_UP = 3,
	DEAL = 4,
}

BrandRender = BaseClass(BaseRender)
function BrandRender:__init()
	self.is_turning = false
	self.brand_state = BRAND_STATE.NONE
	self.eff_node = nil
	self.end_pos = cc.p(0, 0)
	self.start_pos = cc.p(0, 0)
	self.turn_end_callback = nil
end

function BrandRender:__delete()
	self.is_turning = false
	self.eff_node = nil
	self.card_img = nil
end

function BrandRender:CreateChild()
	BrandRender.super.CreateChild(self)

	self.node_tree.layout_brand1.node:setVisible(false)
	self.node_tree.layout_brand0.node:setVisible(false)

	local size = self.node_tree.layout_brand1.node:getContentSize()
	self.card_img = XUI.CreateImageView(size.width / 2, size.height / 2, "")
	self.node_tree.layout_brand1.node:addChild(self.card_img, 0)

	self.rich_attrs = RichTextUtil.ParseRichText(nil, "", nil, nil, size.width / 2 + 100 / 2 + 9, 75, size.width + 100, 1)
	self.node_tree.layout_brand1.node:addChild(self.rich_attrs, 10)
end

function BrandRender:OnFlush()
	if nil == self.data then
		return
	end

	-- 正面的内容
	local item_data = self.data.item_data
	local item_id = item_data.item_id
	if item_id > 0 then
		local res_path = ResPath.GetCardHandlebookImg(item_id)
		self.card_img:loadTexture(res_path, true)
		local img_size = self.card_img:getContentSize()
		local bg_size = self.node_tree.layout_brand1.node:getContentSize()
		self.card_img:setScale((bg_size.width - 10) / img_size.width, (bg_size.height - 10) / img_size.height)

		-- local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		-- local item_name = item_cfg and string.format("{wordcolor;%s;%s}", string.sub(string.format("%06x", item_cfg.color), 1, 6), item_cfg.name) or ""
		-- RichTextUtil.ParseRichText(self.node_tree.layout_brand1.rich_item_name.node, item_name)

		local attrs = CardHandlebookData.Instance:GetAttrByItemId(item_id)
		local rich_content = RoleData.FormatAttrContent(attrs or {}, {prof_ignore = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)})
		RichTextUtil.ParseRichText(self.rich_attrs, rich_content, 18)
		self.rich_attrs:refreshView()
	end

	-- 背面的内容
end

function BrandRender:CanRunAction()
	if self.brand_state == BRAND_STATE.DEAL
		or self.brand_state == BRAND_STATE.PACK_UP then
		return false
	end
	return true
end

function BrandRender:PackUp(action)
	if action then
		if not self:CanRunAction() then
			return false
		end

		self.brand_state = BRAND_STATE.PACK_UP
		self.view:stopAllActions()
		self.view:runAction(cc.Sequence:create(cc.EaseExponentialOut:create(cc.MoveTo:create(0.6, self.start_pos)),
			cc.CallFunc:create(BindTool.Bind(self.PackUp, self, false))))
	else
		self.view:stopAllActions()
		self.view:setPosition(self.start_pos)
		self:ReadyBrand()
	end
	return true
end

function BrandRender:DealBrand(action)
	if action then
		if not self:CanRunAction() then
			return false
		end

		self.brand_state = BRAND_STATE.DEAL
		self.view:stopAllActions()
		self.view:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.MoveTo:create(0.6, self.end_pos)),
			cc.CallFunc:create(BindTool.Bind(self.DealBrand, self, false))))
	else
		self.view:stopAllActions()
		self.view:setPosition(self.end_pos)
		self:ReadyBrand()
	end
	return true
end

function BrandRender:SetMoveStartPos(x, y)
	self.start_pos = cc.p(x, y)
end

function BrandRender:SetMoveEndPos(x, y)
	self.end_pos = cc.p(x, y)
end

function BrandRender:StopShakeAction()
	self.view:setRotation(0)
	self.view:stopAllActions()
end

function BrandRender:RunShakeAction()
	if not self:CanRunAction() then
		return
	end

	local shake_rotate_param = {
		{0.05, 10},
		{0.05, -10},
		{0.03, 4},
		{0.03, -4},
		{0.03, 0},
	}
	local act_t = {}
	for k, v in pairs(shake_rotate_param) do
		act_t[k] = cc.RotateTo:create(v[1], v[2])
	end
	act_t[#act_t + 1] = cc.DelayTime:create(0.7)
	self.view:setRotation(0)
	self.view:stopAllActions()
	self.view:runAction(cc.RepeatForever:create(cc.Sequence:create(unpack(act_t))))
end

function BrandRender:SetEffect(eff_id)
	if eff_id > 0 then
		if nil == self.eff_node then
			self.eff_node = RenderUnit.CreateEffect(eff_id, self.view, 999, nil, nil, nil, nil)
		else
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
			self.eff_node:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			self.eff_node:setVisible(true)
		end
	elseif nil ~= self.eff_node then
		self.eff_node:setStop()
		self.eff_node:setVisible(false)
	end
	return self.eff_node
end

function BrandRender:FlushByState()
	local brand1_vis = false
	local brand0_vis = false
	if self.brand_state == BRAND_STATE.NONE then
	elseif self.brand_state == BRAND_STATE.OPEN then
		brand1_vis = true
		brand0_vis = false
	elseif self.brand_state == BRAND_STATE.CLOSE then
		brand1_vis = false
		brand0_vis = true
	elseif self.brand_state == BRAND_STATE.START then
		brand1_vis = false
		brand0_vis = true
	end
	self.node_tree.layout_brand1.node:setVisible(brand1_vis)
	self.node_tree.layout_brand0.node:setVisible(brand0_vis)
	self.node_tree.layout_brand1.node:setScale(1, 1)
	self.node_tree.layout_brand0.node:setScale(1, 1)
end

-- 设置为开始牌
function BrandRender:SetIsStartBrand()
	self.brand_state = BRAND_STATE.START
	self:FlushByState()
end

function BrandRender:ReadyBrand(data)
	if data then
		self.brand_state = data.is_open and BRAND_STATE.OPEN or BRAND_STATE.CLOSE
		self:SetData(data)
	else
		self.brand_state = BRAND_STATE.CLOSE 
	end
	self:FlushByState()
end

function BrandRender:IsTurning()
	return self.is_turning
end

function BrandRender:CanTurnOpen()
	if self.is_turning or self.brand_state ~= BRAND_STATE.CLOSE then
		return false
	end
	return true
end

function BrandRender:TurnToClose(data)
	if data then
		self:SetData(data)
	end
	if self.is_turning or self.brand_state ~= BRAND_STATE.OPEN then
		return
	end
	self.brand_state = BRAND_STATE.CLOSE
	self:OnTurn(false)
end

function BrandRender:TurnToOpen(data)
	if data then
		self:SetData(data)
	end
	if self.is_turning or self.brand_state ~= BRAND_STATE.CLOSE then
		return
	end
	self.brand_state = BRAND_STATE.OPEN
	self:OnTurn(true)
end

function BrandRender:TurnStart(is_open)
	self.node_tree.layout_brand1.node:setVisible(not is_open)
	self.node_tree.layout_brand0.node:setVisible(is_open)
end

function BrandRender:TurnShowChange(is_open)
	self.node_tree.layout_brand1.node:setVisible(is_open)
	self.node_tree.layout_brand0.node:setVisible(not is_open)
end

function BrandRender:SetTurnEndCallback(func)
	self.turn_end_callback = func
end

function BrandRender:TurnEnd()
	self.is_turning = false
	self:FlushByState()
end

function BrandRender:OnTurn(is_open)
	if nil == is_open then
		is_open = true
	end

	self.is_turning = true
	local act_time = 0.8

	self.node_tree.layout_brand1.node:stopAllActions()
	self.node_tree.layout_brand0.node:stopAllActions()

	local end_callback = cc.CallFunc:create(function()
		if nil ~= self.turn_end_callback then
			self.turn_end_callback()
		end
		self:TurnEnd(is_open)
	end)

	if is_open then
		self.node_tree.layout_brand1.node:setScale(-1, 1)
		self.node_tree.layout_brand1.node:setVisible(false)
		local front_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Show:create())
		local front_scale = cc.ScaleTo:create(act_time, 1, 1)
		self.node_tree.layout_brand1.node:runAction(cc.Spawn:create(front_seq, front_scale))

		self.node_tree.layout_brand0.node:setScale(1, 1)
		self.node_tree.layout_brand0.node:setVisible(true)
		local back_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Hide:create())
		local back_scale = cc.ScaleTo:create(act_time, -1, 1)
		self.node_tree.layout_brand0.node:runAction(cc.Sequence:create(cc.Spawn:create(back_seq, back_scale), end_callback))
	else
		self.node_tree.layout_brand1.node:setScale(1, 1)
		self.node_tree.layout_brand1.node:setVisible(true)
		local front_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Hide:create())
		local front_scale = cc.ScaleTo:create(act_time, -1, 1)
		self.node_tree.layout_brand1.node:runAction(cc.Spawn:create(front_seq, front_scale))

		self.node_tree.layout_brand0.node:setScale(-1, 1)
		self.node_tree.layout_brand0.node:setVisible(false)
		local back_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Show:create())
		local back_scale = cc.ScaleTo:create(act_time, 1, 1)
		self.node_tree.layout_brand0.node:runAction(cc.Sequence:create(cc.Spawn:create(back_seq, back_scale), end_callback))
	end
end

------------------------------
-- 名字牌 render
ActBrandRender = ActBrandRender or BaseClass(BrandRender)

function ActBrandRender:OnFlush()
	if nil == self.data then
		return
	end

	-- 正面的内容
	local item_data = self.data.item_data
	local item_id = item_data.item_id
	if item_id > 0 then
		local res_path = ResPath.GetCardHandlebookImg(item_id)
		self.card_img:loadTexture(res_path, true)
		local img_size = self.card_img:getContentSize()
		local bg_size = self.node_tree.layout_brand1.node:getContentSize()
		self.card_img:setScale((bg_size.width - 10) / img_size.width, (bg_size.height - 10) / img_size.height)

		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		self.rich_attrs:setPosition(80, 50)
		XUI.RichTextSetCenter(self.rich_attrs)

		local item_name = item_cfg and string.format("{wordcolor;%s;%s}", string.sub(string.format("%06x", item_cfg.color), 1, 6), item_cfg.name) or ""
		RichTextUtil.ParseRichText(self.rich_attrs, item_name)
	end
end

----------------------------
-- 超值连充

SupervalueChargeRender = SupervalueChargeRender or BaseClass(BaseRender)
function SupervalueChargeRender:__init()
	
end

function SupervalueChargeRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end

	if self.number then
		self.number:DeleteMe()
		self.number = nil 
	end
end

function SupervalueChargeRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_awards_cell71
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, 90, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree.btn_lingqu_71.node, BindTool.Bind(self.OnClickGetReward1Btn, self), true)
	self.node_tree.btn_lingqu_71.node:setLocalZOrder(999)
	if self.number == nil then
		local ph = self.ph_list.ph_number
		self.number = NumberBar.New()
		self.number:SetRootPath(ResPath.GetCommon("num_8_"))
		self.number:SetSpace(-5)
		self.number:SetScale(0.5)
		self.number:SetPosition(ph.x +20, ph.y - 10)
		self.number:SetGravity(NumberBarGravity.Center)
		self.view:addChild(self.number:GetView(), 99, 300)
	 end
end


function SupervalueChargeRender:OnClickGetReward1Btn()
	ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.CZLC, self.data.index, self.data.cur_index)
end


function SupervalueChargeRender:OnFlush()
	if nil == self.data then
		return
	end
	-- local str = string.format(self.data.index == 1 and Language.ActivityBrilliant.DayChargeFormat or Language.ActivityBrilliant.ActivityChargeFormat, self.data.paymoney)
	-- RichTextUtil.ParseRichText(self.node_tree.rich_charge_type.node, str, 19, COLOR3B.ORANGE)
	
	-- local str = string.format(Language.ActivityBrilliant.HasChargeFormat, self.data.charge >= self.data.paymoney and COLORSTR.GREEN or COLORSTR.RED, self.data.charge, self.data.paymoney)
	-- RichTextUtil.ParseRichText(self.node_tree.rich_charge_money.node, str, 20)
	--self.node_tree.rich_charge_money.node:setHorizontalAlignment(RichHAlignment.HA_RIGHT)
	
	-- 奖励
	local data_list = {}
	for k, v in pairs(self.data.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)

	self.node_tree.btn_lingqu_71.node:setVisible(true)
	self.node_tree.img_stamp.node:setVisible(false)
	self.number:SetNumber(self.data.paymoney)
	if self.data.charge >= self.data.paymoney then
		if self.data.sign == 1 then 
			self.node_tree.btn_lingqu_71.node:setVisible(false)
			self.node_tree.img_stamp.node:setVisible(true)
		else
			self.node_tree.btn_lingqu_71.node:setEnabled(true)
			self.node_tree.btn_lingqu_71.node:setTitleText(Language.Common.LingQu)
		end
	else
		self.node_tree.btn_lingqu_71.node:setEnabled(false)
		self.node_tree.btn_lingqu_71.node:setTitleText(Language.Common.WeiDaCheng)
	end
end

function SupervalueChargeRender:CreateSelectEffect()
end
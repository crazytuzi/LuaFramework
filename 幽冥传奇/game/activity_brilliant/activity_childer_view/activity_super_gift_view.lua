---------------------------------------------
-- 运营活动 48 特惠礼包
---------------------------------------------

SuperGiftView = SuperGiftView or BaseClass(ActBaseView)
SuperGiftView.GiftGridCount = 7

function SuperGiftView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function SuperGiftView:__delete()
	if nil ~= self.gift_grid then
		self.gift_grid:DeleteMe()
		self.gift_grid = nil
	end

	if nil ~= self.cell_gift_list then
		self.cell_gift_list:DeleteMe()
		self.cell_gift_list = nil
	end

	if nil ~= self.gold_num then
		self.gold_num:DeleteMe()
		self.gold_num = nil
	end

	if nil ~= self.OpenGitf_alert then
		self.OpenGitf_alert:DeleteMe()
		self.OpenGitf_alert = nil
	end

	self.gift_view_is_open = false
	self.gift_grid_select_index = nil
	self.load_gift_view_call_back = nil

	self:RemoveAllItemConfigCallback()
end

function SuperGiftView:InitView()
	if self.gift_view_is_open then return end
	self:CreateRewardCell()
	self:CreateYuanbaoNumberBar()
	self:CreateCell()
	self.node_t_list.btn_buy_gift.node:addClickEventListener(BindTool.Bind1(self.OnClickBuyGiftHandler, self))

	self.gift_view_is_open = true
	self.itemconfig_callback_list = {}

	if self.load_gift_view_call_back then
		self.load_gift_view_call_back()
		self.load_gift_view_call_back = nil
	end

	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id)
	local time = cfg.end_time
	if time == nil then
		time = cfg.end_openday or cfg.end_combineday
	end
	local open_days = OtherData.Instance:GetOpenServerDays()
	local combind_days = OtherData.Instance:GetCombindDays()
	if cfg.end_openday ~= nil then
		time = (cfg.end_openday-open_days) * 86400 + (TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime()))
	elseif cfg.end_combineday then
		time = (cfg.end_combineday-combind_days) * 86400 + (TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime()))
	end
	self:UpdateSpareTime(time)
end

function SuperGiftView:RefreshView(param_list)
	-- 物品
	if nil == self.gift_grid_select_index then return end
	local index = self.gift_grid_select_index

	local temp_index = nil
	if ActivityBrilliantData.Instance:GetGiftGridCanSelect(index) then
		-- 礼包类型
		local gift_grid_data_list = ActivityBrilliantData.Instance:GetGiftGridData()
		self.gift_grid:SetDataList(gift_grid_data_list or {})
		self.gift_grid:GetView():jumpToLeft()
		temp_index = 1
	else
		local gift_grid_data_list = ActivityBrilliantData.Instance:GetGiftGridData()
		for k,v in pairs(gift_grid_data_list) do
			if v.index == index then temp_index = k end
		end
	end

	self.gift_grid:SelectIndex(temp_index)
end

function SuperGiftView:CreateYuanbaoNumberBar()
	if not self.ph_list.ph_gold_count then return end
	local ph_num = self.ph_list.ph_gold_count
	self.gold_num = NumberBar.New()
	self.gold_num:SetRootPath(ResPath.GetCommon("num_13_"))
	self.gold_num:SetPosition(ph_num.x, ph_num.y)
	self.gold_num:SetGravity(NumberBarGravity.Center)
	self.gold_num:SetSpace(-4)
	self.tree.node:addChild(self.gold_num:GetView(), 301, 301)
end

function SuperGiftView:OnClickBuyGiftHandler()
	if self.OpenGitf_alert == nil then
		self.OpenGitf_alert = Alert.New()
	end

	if nil == self.gift_grid_select_index then return end
	local index = self.gift_grid_select_index
	local msg, data_list = ActivityBrilliantData.Instance:GetGiftMsgByIndex(index)
	if nil == msg then return end

	-- if msg.level_max > 1 then
	-- 	local str=string.format(Language.OpenServiceAcitivity.BuyGift1,msg.need_yuanbao,msg.level + 1,msg.giftName)
	-- 	self.OpenGitf_alert:SetLableString(str)
	-- else
		local str=string.format(Language.OpenServiceAcitivity.BuyGift3,msg.need_yuanbao)
		self.OpenGitf_alert:SetLableString(str)
	-- end

	self.OpenGitf_alert:SetOkFunc(function ()
		local act_id = ACT_ID.THGIFT
	    ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, index, msg.level + 1)
	end)

	self.OpenGitf_alert:Open()
end

function SuperGiftView:CreateRewardCell()
	local ph = self.ph_list["ph_award_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE,}
	local parent = self.tree.node
	local item_render = ActBaseCell
	local line_dis = ph_item.w + 20
	local direction = ScrollDir.Horizontal -- 滑动方向-横向
	
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, item_render, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 999)
	-- grid_scroll:SetSelectCallBack(BindTool.Bind((function, self))
	self.cell_gift_list = grid_scroll
end

function SuperGiftView:CreateCell()
	if not self.ph_list.ph_item_grid or not self.ph_list.ph_gift_grid_cell then return end
	local ph_grid = self.ph_list.ph_item_grid

	local grid_list_view = ListView.New()
	grid_list_view:Create(ph_grid.x, ph_grid.y, ph_grid.w, ph_grid.h, 2, ActivityGiftRender, nil, false, self.ph_list.ph_gift_grid_cell)
	grid_list_view:SetMargin(2)
	grid_list_view:SetItemsInterval(4)
	
	self.node_t_list.layout_acitivity_gift.node:addChild(grid_list_view:GetView(), 999)
	self.gift_grid = grid_list_view
	self.gift_grid:SetSelectCallBack(BindTool.Bind(self.OnGiftGridSelectCallBack, self))

	local data_list = ActivityBrilliantData.Instance:GetGiftGridData()
	self.gift_grid:SetDataList(data_list)
	if data_list ~= nil then
		self.gift_grid:SelectIndex(1)
	end
end

function SuperGiftView:OnGiftGridSelectCallBack(item, index)
	item = item or self.gift_grid:GetItemAt(index)
	if nil == item or nil == item:GetData() or nil == item:GetData().index then return end
	self.gift_grid_select_index = item:GetData().index
	self:SetGiftDataList(item:GetData().index)
end

function SuperGiftView:SetGiftDataList(index)
	if not self.node_t_list.layout_acitivity_gift then return end

	index = index or self.gift_grid_select_index
	if nil == self.gift_grid or index == nil or index <= 0 or index > ActivityBrilliantData.Instance:GetGiftGridMaxCount() then return end
	local msg, data_list = ActivityBrilliantData.Instance:GetGiftMsgByIndex(index)
	if msg == nil then return end

	if nil == self.cell_gift_list then return end
	self.cell_gift_list:SetDataList(data_list)

	self.gold_num:SetNumber(msg.need_yuanbao)
	self.node_t_list.img_gift_name_1.node:loadTexture(ResPath.GetActivityBrilliant("act_48_name_" .. msg.id))
	self.node_t_list.btn_buy_gift.node:setEnabled(msg.can_buy)
	self.node_t_list.btn_buy_gift.node:setTitleText(msg.can_buy and "立即购买" or Language.Common.SoldOut)

	local effect_cfg = msg.effect_cfg
	if effect_cfg then
		local img_effect = "act_48_" .. msg.id
		-- local img_effect = effect_cfg.img_effect or ("gift_effect_" .. msg.id)
		self:CreateGiftEffect(img_effect, effect_cfg.txt_effect,
			effect_cfg.img_pos_shift, effect_cfg.txt_pos_shift)
		local jie_t = effect_cfg.jie
		local show_level = msg.level + 1
		if msg.level == msg.level_max then 
			show_level = msg.level_max
		end
	end

	local cfg_zs_lv = msg.zslv or 1
	local zs_order = math.floor((cfg_zs_lv - 1) / 3) + 1
	local zs_lv = cfg_zs_lv % 3 == 0 and 3 or cfg_zs_lv % 3
	self.node_t_list["img_zs_order"].node:loadTexture(ResPath.GetZsVip("txt_" .. zs_order))
	self.node_t_list["img_zs_lv"].node:loadTexture(ResPath.GetZsVip("hz_" .. zs_lv))
end

function SuperGiftView:RemoveAllItemConfigCallback()
	if nil ~= self.itemconfig_callback_list then
		for k,v in pairs(self.itemconfig_callback_list) do
			ItemData.Instance:UnNotifyItemConfigCallBack(v)
		end
		self.itemconfig_callback_list = nil
	end
end

function SuperGiftView:UpdateSpareTime(end_time)
	local now_time = TimeCtrl.Instance:GetServerTime()
	-- 剩余12天14时15分
	local str = Language.Chat.Wait .. TimeUtil.FormatSecond2Str(end_time - now_time)
	self.node_t_list["lbl_activity_spare_time"].node:setString(str)
end

-----------------------------------
-- 礼包图片
function SuperGiftView:CreateGiftEffect(img_effect_id, txt_effect_id, img_pos_shift, txt_pos_shift)
	if not self.node_t_list.layout_gift_effect
		or not self.ph_list.ph_gift_img
		or not self.ph_list.ph_txt_effect then return end
	self.node_t_list.layout_gift_effect.node:removeAllChildren()

	if img_effect_id then
		local effect
		if tonumber(img_effect_id) then
			effect = RenderUnit.CreateEffect(img_effect_id, self.node_t_list.layout_gift_effect.node)
		else
			effect = XUI.CreateImageView(0, 0, ResPath.GetBigPainting(img_effect_id), true)
			self.node_t_list.layout_gift_effect.node:addChild(effect)
		end
		
		if effect then
			local ph = self.ph_list.ph_gift_img
			img_pos_shift = img_pos_shift or {0, 0}
			effect:setPosition(ph.x + img_pos_shift[1], ph.y + img_pos_shift[2])
			CommonAction.ShowJumpAction(effect, 10)
		end
	end
end

-----------------------------------
-- ActivityGiftRender
-----------------------------------
ActivityGiftRender = ActivityGiftRender or BaseClass(BaseRender)
function ActivityGiftRender:__init()
	self:AddClickEventListener()
end

function ActivityGiftRender:__delete()
end

function ActivityGiftRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.stamp_had_buy_1.node:setVisible(false)
end

function ActivityGiftRender:OnFlush()
	if nil == self.data or nil == self.data.index then return end
	self.node_tree.img_gift_grid_cell.node:loadTexture(ResPath.GetBigPainting( "act_48_gift_"..(self.data.msg.id)))
	self.node_tree.stamp_had_buy_1.node:setVisible(not self.data.msg.can_buy)
	self.node_tree["img_gift_grid_cell"].node:setGrey(not self.data.msg.can_buy)
end

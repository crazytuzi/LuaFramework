--特惠礼包
OpenServiceAcitivityGiftPage = OpenServiceAcitivityGiftPage or BaseClass(XuiBaseView)

function OpenServiceAcitivityGiftPage:__init()
    self.gift_type = 1
    self.cur_gift_data = nil
    self.select_idx = 1
end	

function OpenServiceAcitivityGiftPage:__delete()
	self:RemoveEvent()
	self.cur_gift_data = nil
	self.select_idx = 1
	self.view = nil
end	

--初始化页面接口
function OpenServiceAcitivityGiftPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:InitEvent()
	self:CreateNumBar()
	self:OnOpenServerGiftRechargeEvent()
	self.view.node_t_list.rich_openser_gift_rest_buy_cnt.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	CommonAction.ShowJumpAction(self.view.node_t_list.img_gift_bg.node, 18)
end	

--初始化事件
function OpenServiceAcitivityGiftPage:InitEvent()
	self:CreateCell()
	self:CreateRewardCell()

	XUI.AddClickEventListener(self.view.node_t_list.btn_buy_gift.node, BindTool.Bind1(self.OnClickBuyGiftHandler, self), true)
	self.view.node_t_list.btn_buy_gift.node:setHittedScale(1.05)
	self.openserver_gift_recharge_event = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_GIFT_GIRD_BACK, BindTool.Bind(self.OnOpenServerGiftRechargeEvent, self))

	-- self.view.itemconfig_callback_list = {}
	-- self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

--移除事件
function OpenServiceAcitivityGiftPage:RemoveEvent()
	if nil ~= self.gift_grid then
		self.gift_grid:DeleteMe()
		self.gift_grid = nil
	end

	if nil ~= self.cell_gift_list then
		for k, v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end

	if self.openserver_gift_recharge_event then
		GlobalEventSystem:UnBind(self.openserver_gift_recharge_event)
		self.openserver_gift_recharge_event = nil
	end

	if self.gift_need_yb then
		self.gift_need_yb:DeleteMe()
		self.gift_need_yb = nil
	end
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	self:RemoveAllItemConfigCallback()
end

function OpenServiceAcitivityGiftPage:OnOpenServerGiftRechargeEvent()
	self:FlushData()
	-- self:FlushReward()
end

function OpenServiceAcitivityGiftPage:OnClickBuyGiftHandler()
	local type = self.gift_type
	if type and self.cur_gift_data then	
		-- print("type, cur_idx", type, self.cur_gift_data.idx)
		OpenServiceAcitivityCtrl.Instance:SendBuyOpenServerGiftReq(type,self.cur_gift_data.idx)
	end
end

function OpenServiceAcitivityGiftPage:CreateRewardCell()
	self.cell_gift_list = {}
	for i = 1, 7 do
		local cell = BaseCell.New()
		local ph = self.view.ph_list["ph_gift_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.view.node_t_list.layout_gift_cells.node:addChild(cell:GetView(), 300)

		local cell_effect = AnimateSprite:create()
		cell_effect:setPosition(ph.x, ph.y)
		self.view.node_t_list.layout_gift_cells.node:addChild(cell_effect, 300)
		cell_effect:setVisible(false)
		cell.cell_effect = cell_effect

		table.insert(self.cell_gift_list, cell)
	end
end

function OpenServiceAcitivityGiftPage:CreateCell()
	if self.gift_grid then return end
	local ph = self.view.ph_list.ph_item_grid
	local item_ui_cfg = self.view.ph_list.ph_gift_grid_cell
	self.gift_grid = GridScroll.New()
	-- self.gift_grid:SetIsUseStepCalc(false)
	local gap = (ph.w - item_ui_cfg.w * 3)	/ 2
	self.gift_grid:Create(ph.x, ph.y, ph.w, ph.h, 2, item_ui_cfg.w + gap - 8, GiftRender, ScrollDir.Horizontal, false, item_ui_cfg)
	self.view.node_t_list.layout_gift.node:addChild(self.gift_grid:GetView(), 999)
	self.gift_grid:SetSelectCallBack(BindTool.Bind(self.OnGiftGridSclectCallBack, self))
	
end

function OpenServiceAcitivityGiftPage:OnGiftGridSclectCallBack(item)
	if nil == item or nil == item:GetData() then return end
	local data = item:GetData()
	self.select_idx = item:GetIndex()
	self.gift_type = data.gift_type
	self.cur_gift_data = data.gift
	self.view.node_t_list.img_gift_bg.node:loadTexture(ResPath.GetBigPainting("gift_effect_" .. data.gift.effec_id))
	self.view.node_t_list.img_gift_name.node:loadTexture(ResPath.GetOpenServerActivities("gift_txt_" .. data.gift.name_id))

	local need_money = data.gift.cost
	self.gift_need_yb:SetNumber(need_money)
	local total_cnt = OpenServiceAcitivityData.Instance:GetOneTypeGiftTotalCnt(data.gift_type)
	if data.gift.is_day_open then
		if total_cnt then
			local rest_buy_time = total_cnt - data.gift.idx + 1
			local content = string.format(Language.OpenServiceAcitivity.GiftRestBuy, rest_buy_time)
			RichTextUtil.ParseRichText(self.view.node_t_list.rich_openser_gift_rest_buy_cnt.node, content, 22, COLOR3B.GREEN)
		end
	else
		item:SetSelect(false)
		local content = string.format(Language.OpenServiceAcitivity.AthleticNotOpenTip[2], data.gift.openDay)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_openser_gift_rest_buy_cnt.node, content, 22, COLOR3B.RED)
	end
	XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_buy_gift.node, not data.gift.is_day_open, true)

	self:FlushReward()
end

function OpenServiceAcitivityGiftPage:FlushReward()
	-- local is_can_get,index,info = OpenServiceAcitivityData.Instance:GetCanGiftDataByType(self.gift_type)
	if not self.cur_gift_data then return end
	local data = self.cur_gift_data.awards or {}
	for i,v in ipairs(data) do
		if self.cell_gift_list[i] then
			if v.level == 1 then
				local path, name = ResPath.GetEffectUiAnimPath(920)
				if path and name then
					self.cell_gift_list[i].cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
					self.cell_gift_list[i].cell_effect:setVisible(true)
				end
			else
				self.cell_gift_list[i].cell_effect:setVisible(false)
			end
			self.cell_gift_list[i]:SetData(v)
		end
	end
	
	-- if not is_can_get then
	-- 	self.view.node_t_list.btn_buy_gift.node:setEnabled(false)
	-- else
	-- 	self.view.node_t_list.btn_buy_gift.node:setEnabled(true)
	-- end
end

function OpenServiceAcitivityGiftPage:FlushData()
	local data = OpenServiceAcitivityData.Instance:GetGiftData()
	self.gift_grid:SetDataList(data)
	self.select_idx = math.min(#data, self.select_idx)
	if next(data) then
		self.gift_grid:SelectItemByIndex(self.select_idx)
	end
end

function OpenServiceAcitivityGiftPage:CreateNumBar()
	local ph = self.view.ph_list.img_money
	self.gift_need_yb = NumberBar.New()
	self.gift_need_yb:SetRootPath(ResPath.GetMainui("num_"))
	self.gift_need_yb:SetPosition(ph.x, ph.y)
	self.gift_need_yb:SetSpace(-8)
	self.view.node_t_list.layout_gift.node:addChild(self.gift_need_yb:GetView(), 90)
	self.gift_need_yb:SetNumber(0)
	self.gift_need_yb:SetGravity(NumberBarGravity.Center)
end

function OpenServiceAcitivityGiftPage:RemoveAllItemConfigCallback()
	-- if nil ~= self.view.itemconfig_callback_list then
	-- 	for k, v in pairs(self.view.itemconfig_callback_list) do
	-- 		ItemData.Instance:UnNotifyItemConfigCallBack(v)
	-- 	end
	-- 	self.view.itemconfig_callback_list = nil
	-- end
end

function OpenServiceAcitivityGiftPage:UpdateData(data)
	for k,v in pairs(data) do
		if k == "SelectData" then
			if v.key ~= 0 then
				self.gift_grid:SelectItemByIndex(v.key)
			end
		end
	end

	-- self:FlushTime()
end

-- 倒计时
local gift_end_time = 24 * 3600
function OpenServiceAcitivityGiftPage:FlushTime()
	local now_time = ActivityData.GetNowShortTime()
	local rest_time = gift_end_time - now_time
	local time_str = TimeUtil.FormatSecond2Str(rest_time, 1, true)
	time_str = Language.Common.RemainTime.."：".. time_str
	self.view.node_t_list.open_gift_rest_time.node:setString(time_str)
end


GiftRender = GiftRender or BaseClass(BaseRender)

function GiftRender:__init()

end

function GiftRender:__delete()
	
end

function GiftRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.gift_img.node:setLocalZOrder(3)
end

function GiftRender:OnFlush()
	if not self.data then return end
	self:MakeGray(not self.data.gift.is_day_open)
	self.node_tree.gift_img.node:loadTexture(ResPath.GetBigPainting("gift_bg_" .. self.data.gift.picture_id))
	self.node_tree.img_title.node:loadTexture(ResPath.GetOpenServerActivities("name_" .. self.data.gift.name_id))
end

-- 创建选中特效
function GiftRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetOpenServerActivities("bg_select"), true)
	if nil == self.select_effect then
		ErrorLog("GiftRender:CreateSelectEffect fail")
		return
	end
	local effec = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetOpenServerActivities("bg_select_eff"), true)
	self.select_effect:addChild(effec, 1)
	self.view:addChild(self.select_effect, 2)
end


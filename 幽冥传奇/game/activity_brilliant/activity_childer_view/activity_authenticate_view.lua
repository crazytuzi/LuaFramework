----------------------------------------
-- 运营活动 84 原石鉴定
----------------------------------------

AuthenticateView = AuthenticateView or BaseClass(ActBaseView)

function AuthenticateView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function AuthenticateView:__delete()

	if nil~=self.draw_record_list then
		self.draw_record_list:DeleteMe()
	end
	self.draw_record_list = nil
	
	if self.cell_list then
		for k , v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end

	if nil ~= self.box_grid then
		self.box_grid:DeleteMe()
		self.box_grid = nil
	end
end

function AuthenticateView:InitView()
	self.cell_list = {}
	self:RecordList()
	self:CreateBoxGridScroll()
	self:UpdateSpareTime()

	for i = 1, 8 do
		XUI.AddClickEventListener(self.node_t_list["btn_auth_" .. i].node, BindTool.Bind(self.OnClickOneListener, self, i), false)
	end
end

function AuthenticateView:RefreshView(param_list)
	self.draw_record_list:SetData(ActivityBrilliantData.Instance:GetYSJDDrawRecord())

	local page = self:GetJumpToPage()
	self.box_grid:SetDataList(ActivityBrilliantData.Instance:GetGiftList())
	self.box_grid:ChangeToPage(page)

	self:ProgView()

	self.open_count = 0
	self.node_t_list.btn_free.node:setVisible(false)
	self.node_t_list.btn_all.node:setVisible(true)
	self.node_t_list.btn_refresh.node:setVisible(true)
	self.node_t_list.img_gold_500.node:setVisible(true)
	self.node_t_list.lbl_num_500.node:setVisible(true)
	self.node_t_list.img_gold_1600.node:setVisible(true)
	self.node_t_list.lbl_num_1600.node:setVisible(true)
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.YSJD)
	local All_open_count = Language.Guild.Nothing
	local cell_list_index = ActivityBrilliantData.Instance:GetCellList()
	if ActivityBrilliantData.Instance:GetMationList() then
		All_open_count = ActivityBrilliantData.Instance:GetMationList().All_open_count or ""
	end

	if nil ~= cell_list_index then
		for i = 1 , cell_list_index.shone_num do
			if nil == self.cell_list[i] then 
				local cell = ActBaseCell.New()
				local ph = self.ph_list["ph_auth_cell" .. i]
				cell:SetPosition(ph.x, ph.y)
				cell:SetAnchorPoint(0.5,0.5)
				self.cell_list[i] = cell
				self.node_t_list.layout_act_authenticate.node:addChild(cell:GetView(),300)	
			end
			self.cell_list[i]:GetView():setVisible(false)
			if 0 ~= cell_list_index[i] then
				local award = cfg.config.awards[cell_list_index[i]].award
				self.cell_list[i]:SetData({item_id = award.id, num = award.count,is_bind = 0 })
				self.cell_list[i]:GetView():setVisible(true)
				self.node_t_list["btn_auth_" .. i].node:setVisible(false)
			else
				if cell_list_index[i] == 0 then
					self.cell_list[i]:GetView():setVisible(false)
					self.node_t_list["btn_auth_" .. i].node:setVisible(true)
				end
			end
		end
	end
	for i ,v in ipairs(cell_list_index) do
		if v ~= 0 then
			self.open_count = self.open_count + 1
		end
		if self.open_count == 8 then
			self.node_t_list.btn_all.node:setVisible(false)
			self.node_t_list.btn_refresh.node:setVisible(false)
			self.node_t_list.btn_free.node:setVisible(true)
			self.node_t_list.img_gold_500.node:setVisible(false)
			self.node_t_list.lbl_num_500.node:setVisible(false)
			self.node_t_list.img_gold_1600.node:setVisible(false)
			self.node_t_list.lbl_num_1600.node:setVisible(false)
			XUI.AddClickEventListener(self.node_t_list.btn_free.node,BindTool.Bind(self.OnClickAuthReBtn, self), true)
		end
	end 
	XUI.AddClickEventListener(self.node_t_list.btn_all.node,BindTool.Bind(self.OnClickAuthAllBtn, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_refresh.node,BindTool.Bind(self.OnClickAuthReBtn, self), true)	
	self.node_t_list.lbl_now_num.node:setString(All_open_count)

	local beg_time = os.date("*t", cfg.beg_time)
	local end_time = os.date("*t", cfg.end_time)
	local str_time = string.format(Language.ActivityBrilliant.AboutTime, beg_time.month, beg_time.day, beg_time.hour, beg_time.min)
	local str_time_2 = string.format(Language.ActivityBrilliant.AboutTime, end_time.month, end_time.day, end_time.hour, end_time.min)
	self.node_t_list.lbl_act_time.node:setString(str_time .. "-" .. str_time_2)

	self.node_t_list.lbl_num_500.node:setString(cfg.config.nRefresh)
	self.node_t_list.lbl_num_1600.node:setString(cfg.config.nConsume * cfg.config.nMaxStone)
end

function AuthenticateView:ProgView()
	local all_open_count = ActivityBrilliantData.Instance:GetMationList().All_open_count
	local openCount = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.YSJD).config.openCount
	-- for i=1,(#openCount -1) do
	-- 	if All_open_count >= openCount[i] and All_open_count < openCount[i + 1] then
	-- 		the_count = (All_open_count - openCount[i]) / (openCount[i + 1] - openCount[i]) 
	-- 		show = 100*(i-1)/(#openCount-1) +  the_count * 100/(#openCount - 1) 	-- 占进度条的数量100满
	-- 		self.node_t_list.prog9_sign_in.node:setPercent(show)
	-- 	end
	-- end

	-- 大于最大值直接给满
	local max_open_count = openCount[#openCount]
	if all_open_count > max_open_count then
		self.node_t_list.prog9_sign_in.node:setPercent(100)
	else
		local percent = all_open_count / max_open_count * 100
		self.node_t_list.prog9_sign_in.node:setPercent(percent)
	end
end

function AuthenticateView:OnClickOneListener(index)
	local mation_list = ActivityBrilliantData.Instance:GetMationList()
	if mation_list and mation_list.Free_open_count < 1 then
		local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id) or {}
		local consume = cfg.config and cfg.config.Reel or {}
		local num = BagData.GetConsumesCount(consume.id, consume.type)
		local consume_num = consume.count or 0
		local item = ItemData.InitItemDataByCfg(consume)
		local consume_id = item.item_id or 0
		if num >= consume_num then -- 需要消耗物品弹出提示
			local item_cfg = ItemData.Instance:GetItemConfig(consume_id)
			local color = string.sub(string.format("%06x", item_cfg.color), 1, 6)
			local str = string.format("是否消耗{color;%s;%s×%s}，鉴定1次原石", color, item_cfg.name or "", consume_num)
			local ok_func = function()
				ActivityBrilliantCtrl.ActivityReq(4, self.act_id, 3 ,index)
			end

			self:OpenTip(str, ok_func)
		else
			ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.YSJD, 3 ,index)
		end
	else
		ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.YSJD, 3 ,index)
	end
end

function AuthenticateView:OpenTip(str, ok_func)
	if nil == self.alert then
		self.alert = Alert.New()
		self:AddObj("alert")
	end

	self.alert:SetLableString(str)
	self.alert:SetOkFunc(ok_func)
	self.alert:Open()
end

function AuthenticateView:UpdateSpareTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id)
	local Free_open_count = Language.Guild.Nothing
	if ActivityBrilliantData.Instance:GetMationList() then
		Free_open_count = ActivityBrilliantData.Instance:GetMationList().Free_open_count or ""
	end
	if nil == cfg or nil == cfg.config then return end
	local add_count_time = cfg.config.addCountTime
	local max_free_times = cfg.config.nMaxFree			--最大免费次数
	local re_onlone = ActivityBrilliantData.Instance:GetOnlineTime()
	if re_onlone < add_count_time then 
		re_onlone = re_onlone + 1 
	end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time
	local spare_time = end_time - now_time 
	local remain_time = add_count_time - re_onlone
	if remain_time <= 0 then
		 ActivityBrilliantCtrl.ActivityReq(3,ACT_ID.YSJD)
		 remain_time = 0
	end
	if ActivityBrilliantData.Instance:GetMationList().Free_open_count >= max_free_times then
		self.node_t_list.layout_act_authenticate.lbl_re_online.node:setString("")
	else
		self.node_t_list.layout_act_authenticate.lbl_re_online.node:setString(TimeUtil.FormatSecond2Str(remain_time) .. Language.ActivityBrilliant.AddOneCount)
	end
	self.node_t_list.layout_act_authenticate.lbl_rec_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
	self.node_t_list.layout_act_authenticate.lbl_rec_time.node:setColor(COLOR3B.GREEN)
	self.node_t_list.lbl_free_num.node:setString(Free_open_count)
end

function AuthenticateView:OnClickAuthReBtn() 
	ActivityBrilliantCtrl.ActivityReq(4,ACT_ID.YSJD, 1)
end

function AuthenticateView:OnClickAuthAllBtn()
	local cell_list_index = ActivityBrilliantData.Instance:GetCellList()

	local times = 0 -- 本次鉴定的次数
	if nil ~= cell_list_index then
		for i = 1 , cell_list_index.shone_num do
			if cell_list_index[i] == 0 then
				times = times + 1
			end
		end
	end

	local mation_list = ActivityBrilliantData.Instance:GetMationList()
	local Free_open_count = mation_list and mation_list.Free_open_count or 0
	if Free_open_count < times then
		local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id) or {}
		local consume = cfg.config and cfg.config.Reel or {}
		local num = BagData.GetConsumesCount(consume.id, consume.type)
		local consume_num = consume.count or 0
		local item = ItemData.InitItemDataByCfg(consume)
		local consume_id = item.item_id or 0
		if consume_num > 0 and num >= consume_num then -- 需要消耗物品弹出提示
			local item_cfg = ItemData.Instance:GetItemConfig(consume_id)
			local color = string.sub(string.format("%06x", item_cfg.color), 1, 6)
			local consume_times = math.min(math.floor(num / consume_num), times) -- 消耗物品进行鉴定的次数
			local consume_count = consume_num * consume_times -- 物品的消耗数量
			local money_times = times - consume_times
			local money_str = ""
			if money_times > 0 then
				local n_consume = cfg.config and cfg.config.nConsume or 0
				money_str = string.format("和{color;%s;%s×%s}", COLORSTR.RED, Language.Common.Diamond,  n_consume * money_times)
			end

			local str = string.format("是否消耗{color;%s;%s×%s}%s，鉴定%d次原石", color, item_cfg.name or "", consume_count, money_str, times)
			local ok_func = function()
				ActivityBrilliantCtrl.ActivityReq(4,ACT_ID.YSJD, 2)
			end

			self:OpenTip(str, ok_func)
		else
			ActivityBrilliantCtrl.ActivityReq(4,ACT_ID.YSJD, 2)
		end
	else
		ActivityBrilliantCtrl.ActivityReq(4,ACT_ID.YSJD, 2)
	end
end

function AuthenticateView:RecordList()
	if nil == self.draw_record_list then
		local ph = self.ph_list.ph_record_list
		self.draw_record_list = ListView.New()
		self.draw_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, self.YSDrawRecordRender, nil, nil, nil)
		self.draw_record_list:GetView():setAnchorPoint(0.5, 0.5)
		self.draw_record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_act_authenticate.node:addChild(self.draw_record_list:GetView(), 100)
	end
end

function AuthenticateView:CreateBoxGridScroll()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id)
	local max_per_page = cfg.config.max_per_page or 6

	local ph = self.ph_list["ph_box_list"]
	local ph_item = self.ph_list["ph_box_item"]
	local data_list = ActivityBrilliantData.Instance:GetGiftList()
	local cell_num = #data_list + 1
	local grid = BaseGrid.New() 
	local grid_node = grid:CreateCells({w = ph.w, h = ph.h, itemRender = self.BoxItemRender, ui_config = ph_item, cell_count = cell_num, col = max_per_page, row = 1})
	self.tree.node:addChild(grid_node, 300)
	grid:GetView():setPosition(ph.x, ph.y)
	grid:SetPageChangeCallBack(BindTool.Bind(self.OnBoxPageChangeCallBack, self))
	grid:SelectCellByIndex(0)

	grid:SetDataList(data_list)
	local cur_page = 1
	local max_page_count = grid:GetPageCount()
	local text = string.format(Language.ActivityBrilliant.FudaiTip, cur_page, max_page_count)
	self.node_t_list.lbl_page_tip.node:setString(text)

	self.box_grid = grid
end

function AuthenticateView:OnBoxPageChangeCallBack()
	local cur_page = self.box_grid:GetCurPageIndex()
	local max_page_count = self.box_grid:GetPageCount()
	local text = string.format(Language.ActivityBrilliant.FudaiTip, cur_page, max_page_count)
	self.node_t_list.lbl_page_tip.node:setString(text)
end

function AuthenticateView:GetJumpToPage()
	local list = ActivityBrilliantData.Instance:GetGiftList()
	local count = self.box_grid:GetPageCellCount()
	local page_count = self.box_grid:GetPageCount()
	local num = 0
	for k,v in pairs(list) do
		num = num + 1
		if v.sign == 0 then
			return math.floor(num / count) + 1
		end
	end

	return page_count
end


----------------------------------------
-- 全服抽记录Render
----------------------------------------
AuthenticateView.YSDrawRecordRender = BaseClass(BaseRender)
local YSDrawRecordRender = AuthenticateView.YSDrawRecordRender

function YSDrawRecordRender:__init(w, h, list_view)	
	self.view_size = cc.size(310, 48)
	self.view:setContentSize(self.view_size)
	self.list_view = list_view
end

function YSDrawRecordRender:__delete()	
end

function YSDrawRecordRender:CreateChild()
	BaseRender.CreateChild(self)
	self.rich_text = RichTextUtil.ParseRichText(nil, "", 20, nil, 10, 0, self.view_size.width, self.view_size.height)
	self.rich_text:setAnchorPoint(0, 0)
	self.view:addChild(self.rich_text, 9)
end

function YSDrawRecordRender:OnFlush()
	if self.data == nil then return end
	local content = string.format(Language.ActivityBrilliant.AuthValueRecord,self.data.name,self.data.item_name)
	RichTextUtil.ParseRichText(self.rich_text, content, 18)
	self.rich_text:refreshView()
	local inner_size = self.rich_text:getInnerContainerSize()
	local size = {
		width = math.max(inner_size.width, self.view_size.width),
		height = math.max(inner_size.height, self.view_size.height),
	}
	self.rich_text:setContentSize(size)
	self.view:setContentSize(size)
	if self.index == self.data.max_count then
		self.list_view:requestRefreshView()
	end
end

function YSDrawRecordRender:CreateSelectEffect()
end

----------------------------------------
-- 宝箱ItemRender
----------------------------------------

AuthenticateView.BoxItemRender = BaseClass(BaseRender)
local BoxItemRender = AuthenticateView.BoxItemRender
function BoxItemRender:__init()

end

function BoxItemRender:__delete()

end

function BoxItemRender:CreateChild()
	BaseRender.CreateChild(self)
	
	local index = self.index + 1
	XUI.AddClickEventListener(self.node_tree["btn_box"].node, BindTool.Bind(self.OnClickRewardListener, self, index))
end

function BoxItemRender:OnFlush()
	if nil == self.data then return end

	local index = self.data.show_index or 1
	local path = ResPath.GetAct_84_93("act_84_box" .. index)
	self.node_tree["btn_box"].node:loadTextures(path)

	if self.data.sign == 1 then
		self.node_tree["img_stamp"].node:setVisible(true)
		self.node_tree["btn_box"].node:setEnabled(false)
		self.node_tree["img_remiand_flag"].node:setVisible(false)
	elseif self.data.sign == 0 then
		self.node_tree["img_stamp"].node:setVisible(false)
		self.node_tree["btn_box"].node:setEnabled(true)

		local all_open_count = ActivityBrilliantData.Instance:GetMationList().All_open_count
		self.node_tree["img_remiand_flag"].node:setVisible(all_open_count >= self.data.times)
	end

	self.node_tree["lbl_bx_num"].node:setString(self.data.times .. Language.Common.UnitName[6])
end

function BoxItemRender:OnClickRewardListener(index)
	local gift_index = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.YSJD).config.openCount
	local can_lingqu = ActivityBrilliantData.Instance:GetMationList().All_open_count >= gift_index[index]
	if can_lingqu then
		ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.YSJD ,4, index)
	else
		self:OpenAwardShowTip()
	end
end

function BoxItemRender:OpenAwardShowTip()
	local show_list = {}
	for i, item in ipairs(self.data.gift_box) do
		show_list[#show_list + 1] = ItemData.InitItemDataByCfg(item)
	end

	local text = ""
	local num = ActivityBrilliantData.Instance:GetMationList().All_open_count
	local bool = num >= self.data.times
	local cur_times = bool and self.data.times or num
	local color = bool and COLORSTR.GREEN or COLORSTR.RED

	-- 例 "累计鉴定原石，0/5次可免费领取"
	local text = string.format(Language.ActivityBrilliant.AwardShowText2, color, cur_times, self.data.times)

	TipCtrl.Instance:OpenAwardShowTip(text, show_list)
end

function BoxItemRender:CreateSelectEffect()
	return
end

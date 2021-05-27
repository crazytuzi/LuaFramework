PracticeWinView = PracticeWinView or BaseClass(BaseView)

function PracticeWinView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/fuben_cl.png',
	}
	self.config_tab = {
        {"practice_result_ui_cfg", 1, {0}, nil, 999},
	}

	self.fb_id = 0
end

function PracticeWinView:__delete()

end

function PracticeWinView:ReleaseCallBack()
	if self.req_doble then
		self.req_doble:DeleteMe()
		self.req_doble = nil
	end
end

function PracticeWinView:LoadCallBack(index, loaded_times)
	XUI.AddClickEventListener(self.node_t_list.btn_get_award.node, BindTool.Bind(self.OnExit, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_get_doble.node, BindTool.Bind(self.OnDoble, self), true)

	RenderUnit.CreateEffect(1124, self.node_t_list.ph_eff.node, 10, nil, nil, 80, 20)
end

function PracticeWinView:ShowIndexCallBack(index)
	self:Flush()
end

function PracticeWinView:OnExit()
	DungeonCtrl.EnterFubenReq(4, self.fb_id, 0)
	self:Close()
end

function PracticeWinView:OnDoble()
	local gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	local color = gold >= self.needYb and COLOR3B.GREEN or COLOR3B.RED
	if gold >= self.needYb then
		DungeonCtrl.EnterFubenReq(4, self.fb_id, 1)
		self:Close()
	else
		self.req_doble = self.req_doble or Alert.New()
		self.req_doble:SetShowCheckBox(false)
		self.req_doble:SetLableString(Language.Fuben.FubenResultDesc)
		self.req_doble:SetOkString(Language.Fuben.FubenWinBtns[2])
		self.req_doble:SetCancelString(Language.Fuben.FubenWinBtns[1])
		self.req_doble:SetOkFunc(function()
			DungeonCtrl.EnterFubenReq(4, self.fb_id, 1)
			self:Close()
		end)
		self.req_doble:SetCancelFunc(function()
			ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
		end)
		self.req_doble:Open()
	end
end

--awards  需要显示的物品 time 倒计时 callback 倒计时结束的回调
function PracticeWinView:SetData(awards, id, callback)
	self.awards = awards	
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local fuben_id = main_role_vo.scene_id

	for k, v in pairs(FubenZongGuanCfg.fubens) do
		if v.senceid == fuben_id then
			self.fb_id = v.static_id
			self.needYb = v.awardConsumeYb or 0
		end
	end

	-- if time > 0 then
	-- 	function cd_callback(elapse_time, total_time)
	-- 		if elapse_time >= total_time then
	-- 			self:Close();
	-- 		else
	-- 			local c = math.ceil(total_time - elapse_time)
	-- 			if self.node_t_list.btn_get_award then
	-- 				self.node_t_list.btn_get_award.node:setTitleText("确定("..c.."s)")
	-- 			end
	-- 		end
	-- 	end
	-- 	self.cd_key = CountDown.Instance:AddCountDown(time, 1, cd_callback)
	-- end
	self.close_callback = callback
end

function PracticeWinView:OnFlush()
	
	if not self.awards then return end
	self.awards = self:PraseAward(self.awards)
	
	local each_row_num = 4		-- 一行多少个item
	local row_jianju = 5		-- 每一行之间的间距
	local ph = self.ph_list.ph_practice_win_grid
	local item_h = 100
	local row_size = math.ceil(#self.awards / each_row_num)		-- 总行数
	row_size = row_size < 3 and 3 or row_size
	local height = (item_h + row_jianju) * row_size								-- scroll_view真实高度
	local column_jianju = 5	-- 每一列之间的间距
	if not self.grid_view then
		self.grid_view = XUI.CreateLayout(ph.x+ph.w/2, ph.y+ph.h/2, ph.w, ph.h)
		self.node_t_list.layout_practice_win.node:addChild(self.grid_view, 300)
	end
	if not self.scroll_view then
		self.scroll_view = XUI.CreateScrollView(0, 0, ph.w, ph.h, ScrollDir.Vertical)
		self.scroll_view:setAnchorPoint(cc.p(0, 0))
		self.scroll_view:setBounceEnabled(true)
		self.scroll_view:setTouchEnabled(true)
		self.scroll_view:setContentSize(cc.size(ph.w, ph.h))
		self.scroll_view:setInnerContainerSize(cc.size(ph.w, height))
		self.grid_view:addChild(self.scroll_view,300)
	end
	self.grid_items = self.grid_items or {}
	for i,v in pairs(self.awards) do
		if not self.grid_items[i] then
			local item = BaseCell.New()
			local cur_row = math.ceil(i / each_row_num)	                                     -- 判断当前item在第哪一行
			local cur_column = i % each_row_num	== 0 and each_row_num or i % each_row_num	 -- 判断当前item在第哪一列
			local size = item:GetView():getContentSize()
			local x = (cur_column - 1) * (size.width + column_jianju)
			local y = height - (size.height + row_jianju) * (cur_row)
			item:SetPosition(x, y)
			item:SetIndex(i)
			self.grid_items[i] = item
			self.scroll_view:addChild(self.grid_items[i].view,300)
		end
		self.grid_items[i]:SetData(ItemData.FormatItemData(v))
	end
	self.scroll_view:jumpToTop()

	local gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	local color = gold >= self.needYb and COLOR3B.GREEN or COLOR3B.RED

	self.node_t_list.lbl_doble_yb.node:setString(self.needYb)
	self.node_t_list.lbl_doble_yb.node:setColor(color)
end

function PracticeWinView:PraseAward(awards)
	local list = {}
	for k,v in pairs(awards) do
		--奖励10个一组显示 最后一组显示余数
		local ten_num = math.floor(v.count / 10)
		local unit_num = v.count % 10
		for i = 1, ten_num do
			local vo = DeepCopy(v)
			vo.count = 10
			table.insert(list, vo)
		end

		if unit_num > 0 then
			local vo = DeepCopy(v)
			vo.count = unit_num
			table.insert(list, vo)
		end
	end
	return list
end

function PracticeWinView:CloseCallBack(is_all)
	CountDown.Instance:RemoveCountDown(self.cd_key)
	if self.close_callback then
		self.close_callback()
	end
	if self.scroll_view then
		self.scroll_view:removeFromParent()
		self.scroll_view = nil
	end
	if self.grid_items then
		for __,v in ipairs(self.grid_items) do
			v:DeleteMe()
			v = nil
		end
	end
	self.grid_view = nil
	self.grid_items = nil
	self.close_callback = nil
	self.awards = nil
end
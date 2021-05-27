--------------------------------------------------------
-- 探索宝藏 配置 Dmkj dream 寻宝图ID:3526
--------------------------------------------------------

local ExploreXunBaoView = BaseClass(SubView)

function ExploreXunBaoView:__init()
	self.texture_path_list[1] = 'res/xui/explore.png'
	self.texture_path_list[2] = 'res/xui/bag.png'
	self.texture_path_list[3] = 'res/xui/welfare.png'
	self.config_tab = {
		{"explore_ui_cfg", 2, {0}},	
	}

	self.world_record_list = nil 	-- 全服公告列表
	self.alert_window = nil 		-- 提示充值的窗口
	self.item_cell_list = nil 		-- 储存物品图标的列表
	-- self.time_num = nil 		-- 祝福值
	self.treasure_map_num = nil 	-- 背包的寻宝图数量
	self.remind_bg_sprite = {}		-- 寻宝按钮的红点提示

	self.dh_falg = nil
	self.last_show_group_id = 0
end

function ExploreXunBaoView:__delete()
end

--释放回调
function ExploreXunBaoView:ReleaseCallBack()
	if self.world_record_list then
		self.world_record_list:DeleteMe()
		self.world_record_list = nil
	end

	if self.my_record_list then
		self.my_record_list:DeleteMe()
		self.my_record_list = nil
	end

	if self.alert_window then
		self.alert_window:DeleteMe()
  		self.alert_window = nil
	end

	if self.item_cell_list then
		for _, v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = nil
	end

	-- if self.time_num then
	-- 	self.time_num:DeleteMe()
	-- 	self.time_num = nil
	-- end

	-- if nil ~= self.time_progressbar then
	-- 	self.time_progressbar:DeleteMe()
	-- 	self.time_progressbar = nil
	-- end

	self.treasure_map_num = nil
	self.remind_bg_sprite = {}
	self.dh_falg = nil
	self.is_nolonger_tips = false

	if self.treasure_cell_list then
		for k,v in pairs(self.treasure_cell_list) do
			v:DeleteMe()
		end
		self.treasure_cell_list = nil
	end

	self.is_changing_show = false
	GlobalTimerQuest:CancelQuest(self.next_change_show_timer)
end

function ExploreXunBaoView:LoadCallBack(index, loaded_times)
	self:CreateTreasureView()	--创建物品视图
	self:CreateWorldRecord()	--创建全服寻宝记录
	-- self:CreateWorldTime()  	--创建全服次数
	self:CreateLinkText()
	self:ChangeXunbaoShowItems()


	-- 次数进度条
	-- self.time_progressbar = ProgressBar.New()
	-- self.time_progressbar:SetView(self.node_t_list.prog9_explore.node)
	-- self.time_progressbar:SetTotalTime(0)
	-- self.time_progressbar:SetTailEffect(991, nil, true)
	-- self.time_progressbar:SetEffectOffsetX(-20)
	-- self.time_progressbar:SetPercent(0)

	-- RenderUnit.CreateEffect(1100, self.node_t_list.img_eff.node, 10, nil, nil, 44, 28)
	self.node_t_list.img_nohint_hook.node:setVisible(self.is_nolonger_tips)
	self.node_t_list.btn_nohint_checkbox.node:addClickEventListener(BindTool.Bind1(self.OnClickCheckBox, self))

	-- 监听寻宝按钮
	XUI.AddClickEventListener(self.node_t_list.btn_xunbao_1.node, BindTool.Bind(self.OnClickXunBaoHandler, self, 1), true)
	XUI.AddClickEventListener(self.node_t_list.btn_xunbao_10.node, BindTool.Bind(self.OnClickXunBaoHandler, self, 2), true)
	XUI.AddClickEventListener(self.node_t_list.btn_xunbao_50.node, BindTool.Bind(self.OnClickXunBaoHandler, self, 3), true)

	EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.EXPLORE_SCORE_CHANGE, BindTool.Bind(self.FlushScoreView, self))
	EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.EXPLORE_RECORD_CHANGE, BindTool.Bind(self.FlushWorldRecord, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.FlushScoreView, self))

end

function ExploreXunBaoView:OnClickCheckBox()
	local is_visible = self.node_t_list.img_nohint_hook.node:isVisible()
	self.node_t_list.img_nohint_hook.node:setVisible(not is_visible)

	self.is_nolonger_tips = not is_visible
end

-- 文本创建
function ExploreXunBaoView:CreateLinkText()
	-- 探宝仓库
	-- local text = RichTextUtil.CreateLinkText("探宝仓库", 19, COLOR3B.GREEN, nil, true)
	-- text:setPosition(815, 58)
	-- self.node_t_list.layout_xunbao.node:addChild(text, 100)
	-- XUI.AddClickEventListener(text, BindTool.Bind(self.OnStorage, self), true)

	-- 积分兑换
	-- local text = RichTextUtil.CreateLinkText("积分兑换", 19, COLOR3B.GREEN, nil, true)
	-- text:setPosition(815, 25)
	-- self.node_t_list.layout_xunbao.node:addChild(text, 100)
	-- XUI.AddClickEventListener(text, BindTool.Bind(self.OnExchange, self), true)

	-- self.dh_falg = XUI.CreateImageView(75, 15, ResPath.GetCommon("remind_bg_1"), true)
	-- text:addChild(self.dh_falg, 0, 0)
end

function ExploreXunBaoView:OnStorage()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Storage)
end

function ExploreXunBaoView:OnExchange()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Exchange)
end

function ExploreXunBaoView:ShowIndexCallBack(index)
	self:FlushWorldRecord()		--刷新全服寻宝记录显示
	self:FlushScoreView()	    --刷新积分
	self:FlushBtnPromptText()	--刷新按钮的提示文本
	self:FlushRemind()			--刷新寻宝按钮红点提示
end

function ExploreXunBaoView:OnFlush(param_list)
	if param_list.bag_data_change then
		self:FlushBtnPromptText()
		self:FlushRemind()
	end
end

function ExploreXunBaoView:OnBagItemChange()
	self:Flush(0, "bag_data_change")
end

----------创建----------

function ExploreXunBaoView:CreateTreasureView()
	-- self.item_cell_list = {}
	-- local data_list = ExploreData.Instance:GetDreamData()
	
	-- for i = 1, 13 do
	-- 	local cell_ph = self.ph_list["ph_cell_" .. i]
	-- 	local cell = BaseCell.New()
	-- 	cell:SetIsUseStepCalc(true)
	-- 	cell:SetPosition(cell_ph.x, cell_ph.y)
	-- 	cell:SetAnchorPoint(0.5, 0.5)
	-- 	cell:SetData(data_list[i])
	-- 	self.node_t_list.layout_xunbao.node:addChild(cell:GetView(), 10)
	-- 	-- 设置热血装备边框
	-- 	cell:SetCellSpecialBg(ResPath.GetCommon("cell_108"))
	-- 	-- if i == 13 then
	-- 	-- 	cell:SetCellBg(ResPath.GetCommon("cell_113"))
	-- 	-- end
	-- 	self.item_cell_list[i] = cell
	-- end
	self.treasure_cell_list = {}
	for i = 1, 13 do
		local cell_ph = self.ph_list["ph_cell_" .. i]
		-- local Path = ResPath.GetCommon("cell_100")
		
		local cell = BaseCell.New()
		cell:SetPosition(cell_ph.x, cell_ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		-- cell:SetCellBg(Path)
		-- 设置热血装备边框
		cell:SetCellSpecialBg(ResPath.GetCommon("cell_108"))
		self.node_t_list.layout_xunbao.node:addChild(cell:GetView(), 103)
		table.insert(self.treasure_cell_list, cell)
		-- local act_eff = RenderUnit.CreateEffect(929, self.node_t_list.layout_bg_common.node, nil, nil, nil,  100, 100)
	end
end

function ExploreXunBaoView:ChangeXunbaoShowItems()
	if nil == self.treasure_cell_list or not self:IsOpen() then
		GlobalTimerQuest:CancelQuest(self.next_change_show_timer)
		return
	end

	GlobalTimerQuest:CancelQuest(self.next_change_show_timer)
	self.next_change_show_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.ChangeXunbaoShowItems, self), 10)

	if self.is_changing_show then
		return
	end
	self.is_changing_show = true

	if self.last_show_group_id == 0 then
		self.last_show_group_id = 1
	else
		self.last_show_group_id = self.last_show_group_id + 1
		local _, max_group_index = ExploreData.GetDreamList()
		if self.last_show_group_id > max_group_index then
			self.last_show_group_id = 1
		end
	end
	local list = ExploreData.GetDreamList(self.last_show_group_id)
	
	local act_time = 1
	for k, v in pairs(self.treasure_cell_list) do
		if list[k] then
			local item_data = {item_id = list[k].id, num = list[k].count, is_bind = list[k].bind}
			if v.item_icon then
				v.item_icon:runAction(cc.FadeOut:create(0.7))
			end
			v:GetView():stopAllActions()
			v:GetView():runAction(cc.Sequence:create(
				cc.OrbitCamera:create(act_time / 2, 1, 0, 0, -90, 0, 0),
				cc.CallFunc:create(function()
					v:SetData(item_data)
				end),
				cc.CallFunc:create(function()
					if v.item_icon then
						v.item_icon:stopAllActions()
						v.item_icon:setOpacity(0)
						v.item_icon:runAction(cc.FadeIn:create(0.6))
					end
				end),
				cc.OrbitCamera:create(act_time / 2, 1, 0, -270, -90, 0, 0),
				cc.CallFunc:create(function()
					self.is_changing_show = false
				end)
			))
		end
	end
end

-- function ExploreXunBaoView:CreateWorldTime()
-- 	if nil == self.time_num then
-- 		local ph = self.ph_list.ph_blessing_value
-- 		self.time_num = NumberBar.New()
-- 		self.time_num:SetRootPath(ResPath.GetCommon("num_100_"))
-- 		self.time_num:SetPosition(ph.x+23, ph.y-2)
-- 		self.time_num:SetGravity(NumberBarGravity.Center)
-- 		self.time_num:GetView():setScale(1.2)
-- 		self.node_t_list.layout_xunbao.node:addChild(self.time_num:GetView(), 10)
-- 	end
-- end

function ExploreXunBaoView:CreateWorldRecord()
	if nil == self.world_record_list then
		local ph = self.ph_list.ph_world_records_list
		self.world_record_list = ListView.New()
		self.world_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, WorldRecordRender, nil, nil, self.ph_list.ph_wordrecord_item)
		-- self.world_record_list:GetView():setAnchorPoint(0, 0)
		self.world_record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_xunbao.node:addChild(self.world_record_list:GetView(), 10)
	end

	if nil == self.my_record_list then
		local ph = self.ph_list.ph_my_records_list
		self.my_record_list = ListView.New()
		self.my_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, WorldRecordRender, nil, nil, self.ph_list.ph_myrecord_item)
		-- self.my_record_list:GetView():setAnchorPoint(0, 0)
		self.my_record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_xunbao.node:addChild(self.my_record_list:GetView(), 10)
	end
end

----------刷新----------
function ExploreXunBaoView:FlushBtnPromptText()
	local item_num = BagData.Instance:GetItemNumInBagById(DmkjConfig.Treasure[1].item.id, nil)	--获取背包的寻宝图数量

	if self.treasure_map_num == item_num then return end	--寻宝图数量未改变时,跳出
	self.treasure_map_num = item_num

	local item_num_str = nil --物品数量
	local content = nil 	--文本内容
	local image = "{image;res/xui/explore/img_xb_27.png;23,27}" 	--插入文本中的图片

	--设置寻宝按钮说明文本
	item_num_str = item_num < DmkjConfig.Treasure[1].count and "{color;ff2828;" .. item_num .. "}" or item_num --当寻宝图数量小于1时，改变成红色
	content = string.format(Language.XunBao.Consume, image, item_num_str, DmkjConfig.Treasure[1].count)
	RichTextUtil.ParseRichText(self.node_t_list.rich_xb_1.node, content, 20, COLOR3B.GOLD)	--传入和解析富文本配置

	item_num_str = item_num < DmkjConfig.Treasure[2].count and "{color;ff2828;" .. item_num .. "}" or item_num --当寻宝图数量小于10时，改变成红色
	content = string.format(Language.XunBao.Consume, image, item_num_str, DmkjConfig.Treasure[2].count)
	RichTextUtil.ParseRichText(self.node_t_list.rich_xb_10.node, content, 20, COLOR3B.GOLD)

	item_num_str = item_num < DmkjConfig.Treasure[3].count and "{color;ff2828;" .. item_num .. "}" or item_num --当寻宝图数量小于10时，改变成红色
	content = string.format(Language.XunBao.Consume, image, item_num_str, DmkjConfig.Treasure[3].count)
	RichTextUtil.ParseRichText(self.node_t_list.rich_xb_50.node, content, 20, COLOR3B.GOLD)

	--设置文本居中
	XUI.RichTextSetCenter(self.node_t_list.rich_xb_1.node)
	XUI.RichTextSetCenter(self.node_t_list.rich_xb_10.node)
	XUI.RichTextSetCenter(self.node_t_list.rich_xb_50.node)
end

function ExploreXunBaoView:FlushScoreView()
	local data = ExploreData.Instance:GetXunBaoData()
	local gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
	local exp_num = ExploreData.Instance:GetWorldTime()
	self.node_t_list.lbl_zshi.node:setString(gold)
	self.node_t_list.lbl_bz_score.node:setString(data.bz_score)

	local num_item = ExploreData.Instance:GetExploreTime()

	-- local pro = 0
	-- for k,v in pairs(num_item) do
	-- 	self.node_t_list["flag_" .. k].node:setVisible(exp_num >= v)

	-- 	if exp_num >= v then
	-- 		pro = k
	-- 	end
	-- end

	-- self.time_num:SetNumber(exp_num)
	-- 次数进度条
	-- local pro_num = exp_num < DmkjConfig.fullSvrAwards[#DmkjConfig.fullSvrAwards].dmTimes and exp_num or DmkjConfig.fullSvrAwards[#DmkjConfig.fullSvrAwards].dmTimes
	-- self.time_progressbar:SetPercent(pro/#num_item * 100)

	-- local vis = false
	-- for i = 1, #TreasureIntegral do
	-- 	vis = ExploreData.Instance:GetTabbarremind(i)
	-- 	if vis then break end
	-- end
	-- self.dh_falg:setVisible(vis)
end

function ExploreXunBaoView:FlushWorldRecord()
	local xunbao = ExploreData.Instance:GetXunBaoRecord()
	self.world_record_list:SetDataList(xunbao.world_record_list)
	self.my_record_list:SetDataList(ExploreData.Instance:GetOwnRewardList())
end

-- 刷新寻宝按钮红点提示
function ExploreXunBaoView:FlushRemind()
	local vis
	local node
	vis = ExploreData.Instance.GetXunbaoRemindIndex() > 0
	node = self.node_t_list.btn_xunbao_1.node
	self:SetRemind(node, 1, vis)

	vis = ExploreData.Instance.GetXunbaoRemindIndex() > 1
	node = self.node_t_list.btn_xunbao_10.node
	self:SetRemind(node, 2, vis)

	vis = ExploreData.Instance.GetXunbaoRemindIndex() > 2
	node = self.node_t_list.btn_xunbao_50.node
	self:SetRemind(node, 3, vis)
end

-- 设置提醒
function ExploreXunBaoView:SetRemind(node, index, vis, path, x, y)
	path = path or ResPath.GetMainui("remind_flag")
	local size = node:getContentSize()
	x = x or size.width - 15
	y = y or size.height - 17
	if vis and nil == self.remind_bg_sprite[index] then		
		self.remind_bg_sprite[index] = XUI.CreateImageView(x, y, path, true)
		node:addChild(self.remind_bg_sprite[index], 1, 1)
	elseif self.remind_bg_sprite[index] then
		self.remind_bg_sprite[index]:setVisible(vis)
	end
end

--------------------

--点击寻宝按钮处理程序
function ExploreXunBaoView:OnClickXunBaoHandler(explore_type)
	local item_num = BagData.Instance:GetItemNumInBagById(DmkjConfig.Treasure[1].item.id, nil)
	local playergold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)

	--元宝和寻宝图加在一起都不满足时,打开充值窗口
	local num = item_num * 200 + playergold
	-- if explore_type == 1 and num <  DmkjConfig.Treasure[explore_type].needYb then
	-- 	self:OpenTipView()
	-- elseif explore_type == 2 and num < DmkjConfig.Treasure[explore_type].needYb then
	-- 	self:OpenTipView()
	-- elseif explore_type == 3 and num < DmkjConfig.Treasure[explore_type].needYb then
	-- 	self:OpenTipView()
	-- end
	if self.is_nolonger_tips then
		ExploreCtrl.Instance:SendXunbaoReq(explore_type, 1)
	else
		if explore_type == 1 and item_num < DmkjConfig.Treasure[explore_type].count then
			self:OpenTipView(DmkjConfig.Treasure[explore_type].count - item_num, 1)
		elseif explore_type == 2 and item_num < DmkjConfig.Treasure[explore_type].count then
			self:OpenTipView(DmkjConfig.Treasure[explore_type].count - item_num, 10)
		elseif explore_type == 3 and item_num < DmkjConfig.Treasure[explore_type].count then
			self:OpenTipView(DmkjConfig.Treasure[explore_type].count - item_num, 50)
		else
			ExploreCtrl.Instance:SendXunbaoReq(explore_type, 0)
		end
	end

end

-- 次数奖励预览
-- function ExploreXunBaoView:OnClickBoxReward(index)
-- 	local data = {}
-- 	data.item_data = DmkjConfig.fullSvrAwards[index].awards
-- 	WelfareCtrl.Instance:SetDataWefare(data)
-- end

--打开提示视图
function ExploreXunBaoView:OpenTipView(count, num)
	--创建提示充值的窗口
	-- if self.alert_window == nil then
	-- 	self.alert_window = Alert.New()
	-- 	self.alert_window:SetOkString(Language.Common.BtnRechargeText)
	-- 	self.alert_window:SetLableString(Language.Common.RechargeAlertText)
	-- 	self.alert_window:SetOkFunc(BindTool.Bind(self.OnChargeRightNowHandler, self))
	-- end
	-- self.alert_window:Open()
	TipCtrl.Instance:OpenQuickTipItem(self.is_nolonger_tips, {833, 3, count, num})
end

--充值
function ExploreXunBaoView:OnChargeRightNowHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

-----------------------------------------
-- 全服寻宝记录render
-----------------------------------------
WorldRecordRender = WorldRecordRender or BaseClass(BaseRender)
function WorldRecordRender:__init()
end

function WorldRecordRender:__delete()
end

function WorldRecordRender:CreateChild()
	BaseRender.CreateChild(self)
end

function WorldRecordRender:OnFlush()
	if self.data == nil then return end

	--区分玩家本人与其它玩家的名字颜色
	local playername = Scene.Instance:GetMainRole():GetName()
	self.rolename_color = playername == self.data.role_name and COLORSTR.YELLOW or COLORSTR.BLUE

	local text = string.format(Language.XunBao.Txt, self.rolename_color, self.data.role_name, Language.XunBao.Prefix, RichTextUtil.CreateItemStr(self.data.item_data))
	local rich = RichTextUtil.ParseRichText(self.node_tree.rich_explore_attr.node, text, 18)
	-- rich:setIgnoreSize(true)
end

function WorldRecordRender:CreateSelectEffect()
end

return ExploreXunBaoView

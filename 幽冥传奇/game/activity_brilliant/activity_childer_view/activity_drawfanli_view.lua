-----------------------------------
-- 运营活动 46 消费返利
-----------------------------------

DrawFanliView = DrawFanliView or BaseClass(ActBaseView)

function DrawFanliView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function DrawFanliView:__delete()
	if self.fanli_cap ~= nil then
		self.fanli_cap:DeleteMe()
		self.fanli_cap = nil
	end
	if self.qf_record_list ~= nil then
		self.qf_record_list:DeleteMe()
		self.qf_record_list = nil
	end	
	if self.gr_record_list ~= nil then
		self.gr_record_list:DeleteMe()
		self.gr_record_list = nil
	end	
	self.dzp_count = 0

	self.node_t_list.img_46_arrow.node:stopAllActions()
end

function DrawFanliView:InitView()
	self:InitWorldFLRecord()
	self:CreateFanliNum()
	self:CreateFLZPReward()

	self.node_t_list["img_46_arrow"].node:setAnchorPoint(0.5, 0.36)
	self.node_t_list.btn_46_draw.node:addClickEventListener(BindTool.Bind(self.OnClickFanLiHandler, self))
	self.node_t_list.layout_46_auto_hook.btn_nohint_checkbox.node:addClickEventListener(BindTool.Bind(self.OnClickFLAutoUse, self))
	XUI.AddClickEventListener(self.node_t_list.layout_look.node, BindTool.Bind(self.OnClickLookTipHandler, self), true)
	
	self.node_t_list.layout_46_auto_hook.img_hook.node:setVisible(false)
end

local in_play_action = false -- 播放动作中 用于判断是否刷新按钮的启用
function DrawFanliView:RefreshView(param_list)
	for k,v in pairs(param_list) do
		if k == "flush_view" and v.result then
			self.node_t_list.img_46_arrow.node:stopAllActions()
			local rotate = self.node_t_list.img_46_arrow.node:getRotation() % 360
			local to_rotate = 720 - rotate + 360 / self.dzp_count / 2 + 360 / self.dzp_count * (v.result - 1)
			local rotate_by = cc.RotateBy:create(2, to_rotate)
			local callback = cc.CallFunc:create(function ()
				local times = ActivityBrilliantData.Instance:GetFanliNum() or 0
				self.node_t_list["btn_46_draw"].node:setEnabled(times > 0)

				self.qf_record_list:SetDataList(ActivityBrilliantData.Instance:GetQFFanliRecord())
				self.gr_record_list:SetDataList(ActivityBrilliantData.Instance:GetGRFanliRecord())
				in_play_action = false
			end)

			--是否创建旋转动作（跳过动画）
			if self.node_t_list.layout_46_auto_hook.img_hook.node:isVisible() then
				self.node_t_list.img_46_arrow.node:runAction(callback)
			else
				in_play_action = true
				local sequence = cc.Sequence:create(rotate_by, callback)
				self.node_t_list.img_46_arrow.node:runAction(sequence)
			end
		else
			if self.node_t_list.btn_46_draw.node:isEnabled() then
				self.qf_record_list:SetDataList(ActivityBrilliantData.Instance:GetQFFanliRecord())
				self.gr_record_list:SetDataList(ActivityBrilliantData.Instance:GetGRFanliRecord())
			end
		end
	end

	local times = ActivityBrilliantData.Instance:GetFanliNum() or 0
	self.node_t_list.lbl_46_num.node:setString(times)
	if in_play_action == false then
		self.node_t_list["btn_46_draw"].node:setEnabled(times > 0)
	end
	self.fanli_cap:SetNumber(ActivityBrilliantData.Instance:GetFanliGold() or 0)
end

function DrawFanliView:OnClickFLAutoUse()
	local vis = self.node_t_list.layout_46_auto_hook.img_hook.node:isVisible()
	self.node_t_list.layout_46_auto_hook.img_hook.node:setVisible(not vis)
end

function DrawFanliView:InitWorldFLRecord()
	local ph = self.ph_list.ph_qf_record
	self.qf_record_list = ListView.New()
	self.qf_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, WorldRecordFanliRender, nil, nil, self.ph_list.ph_46_text_item)
	self.qf_record_list:GetView():setAnchorPoint(0, 0)
	self.qf_record_list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_fanli.node:addChild(self.qf_record_list:GetView(), 100)

	local ph = self.ph_list.ph_gr_list
	self.gr_record_list = ListView.New()
	self.gr_record_list:Create(ph.x + 2, ph.y, ph.w, ph.h, nil, WorldRecordFanliRender, nil, nil, self.ph_list.ph_46_text_item)
	self.gr_record_list:GetView():setAnchorPoint(0, 0)
	self.gr_record_list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_fanli.node:addChild(self.gr_record_list:GetView(), 100)

	self.qf_record_list:SetDataList(ActivityBrilliantData.Instance:GetQFFanliRecord())
	self.gr_record_list:SetDataList(ActivityBrilliantData.Instance:GetGRFanliRecord())
end

function DrawFanliView:CreateFLZPReward()
	self.fl_cap_reward_t = {}
	local l_r = 70
	local w_r = 110
	local x, y = self.node_t_list.img_46_arrow.node:getPosition()
	local list = ActivityBrilliantData.Instance:GetFanliNumList()
	if nil == list then return end 
	self.dzp_count = #list
	for i = 1, self.dzp_count do
		local angle = 360 / self.dzp_count * (i - 0.5)
		local rad = math.rad(angle)
		local l_x = x + l_r * math.sin(rad)
		local l_y = y + l_r * math.cos(rad)
		local w_x = x + w_r * math.sin(rad)
		local w_y = y + w_r * math.cos(rad)

		local text = XUI.CreateText(l_x, l_y, 100, 30, nil, list[i].giverate .. "%" , nil, 18, COLOR3B.BLACK, nil)
		text:setRotation(angle)
		self.node_t_list.layout_fanli.node:addChild(text, 1)

		local fl_cap, fl_cap_parent = self:CreateFLNumBar()
		fl_cap:SetNumber(list[i].reward or 0)
		fl_cap_parent:setPosition(w_x, w_y)
		fl_cap_parent:setRotation(angle)
		table.insert(self.fl_cap_reward_t, fl_cap)

		local y_x = 9 -- 每个数字一半间距
		if list[i].reward >= 1000 then
			y_x = y_x * 4
		elseif list[i].reward >= 100 then
			y_x = y_x * 3
		elseif list[i].reward >= 10 then
			y_x = y_x * 2
		end
		
		local img_yuan = XUI.CreateImageView(y_x, 13, ResPath.GetCommon("money_type_1"), true)
		self.tree.node:addChild(fl_cap_parent, 300, 300)
		fl_cap_parent:addChild(img_yuan, 300, 300)
	end
end

function DrawFanliView:CreateFLNumBar()
	local layout = XUI.CreateLayout(0, 0, 0, 0)
	local fl_cap = NumberBar.New()
	fl_cap:SetRootPath(ResPath.GetCommon("num_12_"))
	fl_cap:SetGravity(NumberBarGravity.Center)
	fl_cap:SetSpace(-5)
	fl_cap:SetPosition(-13.5, 0) -- x轴效准"money_type_1"宽度的一半,以达到居中的效果
	layout:addChild(fl_cap:GetView(), 1)
	return fl_cap, layout
end

function DrawFanliView:CreateFanliNum()
	local cap_x, cap_y = self.node_t_list.lbl_46_gold_num.node:getPosition()
	self.fanli_cap = NumberBar.New()
	self.fanli_cap:SetRootPath(ResPath.GetCommon("num_11_"))
	self.fanli_cap:SetPosition(cap_x + 50, cap_y - 30)
	self.fanli_cap:SetSpace(-5)
	self.fanli_cap:SetGravity(NumberBarGravity.Center)
	self.node_t_list.layout_fanli.node:addChild(self.fanli_cap:GetView(), 300, 300)
end

function DrawFanliView:OnClickFanLiHandler()
	local act_id = ACT_ID.DRAWFL
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 0)
	self.node_t_list.btn_46_draw.node:setEnabled(ActivityBrilliantData.Instance:GetFanliNum() <= 0)
end

function DrawFanliView:GetNumDesc()
	local str = ""
	local color = "1eff00"
	local list = ActivityBrilliantData.Instance:GetFanliNumList()
	if nil == list then return "" end
	for k,v in pairs(list) do
		if v.times > 0 then
			color = "1eff00"
		else
			color = "FF0000"
		end
		str = str .. string.format(Language.ActivityBrilliant.FanLiNum, v.reward, v.giverate, color, v.times)
	end
	return str
end

function DrawFanliView:OnClickLookTipHandler()
	DescTip.Instance:SetContent(self:GetNumDesc(), Language.ActivityBrilliant.FanLiNumTitle)
end

function DrawFanliView:UpdateSpareTime(end_time)
	local now_time = TimeCtrl.Instance:GetServerTime()
	local spare_time = end_time - now_time 
	self.node_t_list["lbl_46_timer"].node:setString(Language.Chat.Wait .. TimeUtil.FormatSecond2Str(spare_time))
end

---------------------------
--WorldRecordFanliRender
---------------------------
WorldRecordFanliRender = WorldRecordFanliRender or BaseClass(BaseRender)
function WorldRecordFanliRender:__init()
end

function WorldRecordFanliRender:__delete()	
end

function WorldRecordFanliRender:CreateChild()
	BaseRender.CreateChild(self)
end

function WorldRecordFanliRender:OnFlush()
	if self.data == nil then return end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.DRAWFL)
	if nil == cfg then return end
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername == self.data.name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end
	local name = self.data.is_per and Language.ActivityBrilliant.Text19 or self.data.name
	local text_qf = string.format(Language.ActivityBrilliant.FanLiRecord_1, self.rolename_color, name)
	local text_gr = string.format(Language.ActivityBrilliant.FanLiRecord_3, name)
	local text_item = string.format(Language.ActivityBrilliant.FanLiRecord_2, self.data.gold, self.data.rate)

	local text = self.data.is_per and text_gr or text_qf
	local rich = RichTextUtil.ParseRichText(self.node_tree.rich_tip_1.node, text, 20)
	local rich_2 = RichTextUtil.ParseRichText(self.node_tree.rich_tip_2.node, text_item, 20)
end

function WorldRecordFanliRender:CreateSelectEffect()
end
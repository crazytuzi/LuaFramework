WelfareTurnbelView = WelfareTurnbelView or BaseClass(BaseView)
local RecordTurntableRender =  BaseClass(BaseRender)

function WelfareTurnbelView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/welfare_turnbel.png'
	}
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		-- {"common_ui_cfg", 2, {0}, nil, 999},
		{"welfare_turnbel_ui_cfg", 1, {0}},
	}
	
	-- 管理自定义对象
	self._objs = {}
	self.table_reward_t = {}
	-- require("scripts/game/welfare_turnbel/name").New(ViewDef.WelfareTurnbel.name)
end

function WelfareTurnbelView:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack WelfareTurnbelView") end
		v:DeleteMe()
	end

	for k, v in pairs(self.table_reward_t) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack WelfareTurnbelView") end
		v:DeleteMe()
	end
	
	self._objs = {}
	self.table_reward_t = {}
end

function WelfareTurnbelView:LoadCallBack(index, loaded_times)
	self.data = WelfareTurnbelData.Instance				--数据
	if loaded_times <= 1 then	
		-- self._objs.test_list = ListView.New()
		self:CreateNumber()
		self:InitWorldRecord()
		self:CreateTurntableReward()

		-- 初始化转盘
		self:InitTurnbel()
	end

	EventProxy.New(WelfareTurnbelData.Instance, self):AddEventListener(WelfareTurnbelData.INFO_CHANGE, function ()
		self:FlushView()
	end)
	EventProxy.New(WelfareTurnbelData.Instance, self):AddEventListener(WelfareTurnbelData.GET_AWARD, function (vo)
		self:ArrowRotateTo(vo.idx)
	end)

	--领取在线奖励
	XUI.AddClickEventListener(self.node_t_list.btn_lingqu_1.node, function ()
		WelfareTurnbelCtrl.SendGetOnlineAwardReq()
	end, true)
	XUI.AddRemingTip(self.node_t_list.btn_lingqu_1.node, function ()
		return self.data:IsCanLqOnline()
	end)

	--领取击杀boss奖励
	XUI.AddClickEventListener(self.node_t_list.btn_lingqu_2.node, function ()
		WelfareTurnbelCtrl.SendGetBossAwardReq()
	end, true)
	XUI.AddRemingTip(self.node_t_list.btn_lingqu_2.node, function ()
		return self.data:IsCanLqBoss()
	end)

	XUI.AddRemingTip(self.node_t_list.btn_draw.node, function ()
		return self.data:IsCanDraw()
	end)

	--领取击杀boss奖励
	XUI.AddClickEventListener(self.node_t_list.btn_draw.node, function ()
		-- self:ArrowRotateTo(math.random(1, 8))
		-- self:ArrowRotateTo(1)
		if nil == self.data:GetCurrDrawIdx() then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.WelfareTurnbel.DrawTip2)
			return 
		end
		if self.data.score >= WelfareTable.points[self.data:GetCurrDrawIdx()] then
			self:BeforRotate()
			WelfareTurnbelCtrl.SendDrawReq()				
		else
			SysMsgCtrl.Instance:FloatingTopRightText(Language.WelfareTurnbel.DrawTip)
		end
	end, true)

	XUI.AddClickEventListener(self.node_t_list.btn_charge.node, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	end, true)

	XUI.AddClickEventListener(self.node_t_list.btn_help.node, function ()
		DescTip.Instance:SetContent(Language.WelfareTurnbel.ActTip.content, Language.WelfareTurnbel.ActTip.title)
	end, true)
end

function WelfareTurnbelView:ShowIndexCallBack()
	WelfareTurnbelCtrl.SendInfoReq() 	--请求数据 更新数据
	self:FlushView()
	
	self._objs["world_record_list"]:SetDataList(self.data.records)
	self._objs["world_record_list"]:GetView():jumpToBottom()
end

function WelfareTurnbelView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function WelfareTurnbelView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:AfterRotate()
end

function WelfareTurnbelView:FlushNumberBar()
	self._objs["draw_tip_number"]:SetNumber(self.data:GetCurrDrawIdx() and WelfareTable.points[self.data:GetCurrDrawIdx()] or 0)
	self._objs["get_score_tip1_number"]:SetNumber(WelfareTable.MoneyPoint.money)
	self._objs["get_score_tip2_number"]:SetNumber(WelfareTable.MoneyPoint.points)
	self._objs["score_tip_number"]:SetNumber(self.data.score)
end

function WelfareTurnbelView:FlushTxtTip()
	local can_lingqu_boss = self.data.kill_boss_num >= WelfareTable.BossPoint.bosscount
	self.node_t_list.lbl_online_tip.node:setString(string.format(
		Language.WelfareTurnbel.OnlineTip, WelfareTable.OnlineDura.itmes / 3600, 
		WelfareTable.OnlineDura.points)
	)

	RichTextUtil.ParseRichText(self.node_t_list.rich_kill_boss_tip.node, 
		string.format(
			Language.WelfareTurnbel.KillBossTip, 
			can_lingqu_boss and COLORSTR.GREEN or COLORSTR.RED, self.data.kill_boss_num, WelfareTable.BossPoint.bosscount, WelfareTable.BossPoint.points
		), 
		18, Str2C3b("e6bc25")
	)
end

function WelfareTurnbelView:OnDataChange(vo)
	self:FlushView()
end

function WelfareTurnbelView:FlushView()
	self:FlushTxtTip()
	self:FlushNumberBar()
	self.node_t_list.btn_lingqu_1.node:UpdateReimd()
	self.node_t_list.btn_lingqu_2.node:UpdateReimd()
	self.node_t_list.btn_draw.node:UpdateReimd()

	self.node_t_list.btn_lingqu_1.node:setEnabled(self.data:IsCanLqOnline())
	self.node_t_list.btn_lingqu_2.node:setEnabled(self.data:IsCanLqBoss())
end



---------------------------------------------------
-- 转盘逻辑

function WelfareTurnbelView:InitTurnbel()
	local a_y = 1 - ((180 - 55) / 2 + 55) / 180
	self.node_t_list.img_arrow.node:setAnchorPoint(0.5, a_y)
	self.node_t_list.img_arrow.node:setPositionY(self.node_t_list.img_arrow.node:getPositionY() - 180 * (0.5 - a_y))
end

function WelfareTurnbelView:FlushAwardIsDraw()
	for i,v in ipairs(self.table_reward_t) do
		if self.data.flags.is_draw[i] then
			if nil == v.img_is_lingqu then
				v.img_is_lingqu = XUI.CreateImageView(40, 40, ResPath.GetCommon("stamp_14"), true)
				v:GetView():addChild(v.img_is_lingqu, 999)
			end
		end
	end
end

function WelfareTurnbelView:AfterRotate()
	ItemData.Instance:SetDaley(false)
	self.node_t_list.btn_draw.node:setEnabled(true)
	self.node_t_list.img_draw_txt.node:setGrey(false)
	self._objs["world_record_list"]:SetDataList(self.data.records)
	self._objs["world_record_list"]:GetView():jumpToBottom()
	self:FlushAwardIsDraw()
	-- if not self.data:IsShow() then
	-- 	self:Close()
	-- end
end

function WelfareTurnbelView:BeforRotate()
	ItemData.Instance:SetDaley(true)
	self.node_t_list.btn_draw.node:setEnabled(false)
	self.node_t_list.img_draw_txt.node:setGrey(true)
	self.node_t_list.img_arrow.node:setRotation(0)
end

function WelfareTurnbelView:ArrowRotateTo(idx)
	local circle = 2
	local to_rotate = 360 / 8 * (idx - 1) + 360 * circle
	local rotate_time = 0.1 * idx + 0.8 * circle
	local rotate_by = cc.RotateBy:create(rotate_time, to_rotate)
	local sequence = cc.Sequence:create(rotate_by, cc.CallFunc:create(function () self:AfterRotate() end))
	self.node_t_list.img_arrow.node:runAction(sequence)
end

local t_count = 8
function WelfareTurnbelView:CreateTurntableReward()
	if next(self.table_reward_t) then return end
	local r = 146
	local x, y = 256, 310
	for i = 1, t_count do
		local cell = ActBaseCell.New()
		cell:SetPosition(x + r * math.cos(math.rad(90 - 360 / t_count * (i - 1))),y  + r * math.sin(math.rad(90 - 360 / t_count * (i - 1))))
		cell:SetCellBgVis(false)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_turnble.node:addChild(cell:GetView(), 8)
		table.insert(self.table_reward_t, cell)
	end
	local act_cfg = WelfareTable.awards
	if act_cfg then	
		for i,v in ipairs(self.table_reward_t) do
			local data = act_cfg[i] and act_cfg[i].award
			if data then
				if data.type == tagAwardType.qatEquipment then
					-- v:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = 0 , effectId = data.effectId})
					v:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = 0 , effectId = 0})
				else
					local virtual_item_id = ItemData.GetVirtualItemId(data.type)
					if virtual_item_id then
						v:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind =  0})
					end
				end
			else
				v:SetData()
			end
		end
	end

	self:FlushAwardIsDraw()
end

-- end
-------------------------------


function WelfareTurnbelView:CreateNumber()
	local ph = {x = self.node_t_list.img_draw_tip.node:getPositionX(), y = self.node_t_list.img_draw_tip.node:getPositionY()}
	self._objs["draw_tip_number"] = NumberBar.New()
	self._objs["draw_tip_number"]:SetGravity(NumberBarGravity.Center)
	self._objs["draw_tip_number"]:SetRootPath(ResPath.GetWelfareTurnble("w_t_num_"))
	self._objs["draw_tip_number"]:SetPosition(ph.x, ph.y - 8)
	self.node_t_list.layout_turnble.node:addChild(self._objs["draw_tip_number"]:GetView(), 300, 300)
	self._objs["draw_tip_number"]:SetNumber(0)
	-- self._objs["draw_tip_number"]:GetView():setLocalZOrder(3)

	local ph = {x = self.node_t_list.img_charge_tip.node:getPositionX(), y = self.node_t_list.img_charge_tip.node:getPositionY()}
	self._objs["get_score_tip1_number"] = NumberBar.New()
	self._objs["get_score_tip1_number"]:SetRootPath(ResPath.GetWelfareTurnble("w_t_num_"))
	self._objs["get_score_tip1_number"]:SetPosition(ph.x - 84, ph.y - 8)
	self.node_t_list.layout_turnble.node:addChild(self._objs["get_score_tip1_number"]:GetView(), 300, 300)
	self._objs["get_score_tip1_number"]:SetNumber(0)
	
	self._objs["get_score_tip2_number"] = NumberBar.New()
	self._objs["get_score_tip2_number"]:SetRootPath(ResPath.GetWelfareTurnble("w_t_num_"))
	self._objs["get_score_tip2_number"]:SetPosition(ph.x + 70, ph.y - 8)
	self.node_t_list.layout_turnble.node:addChild(self._objs["get_score_tip2_number"]:GetView(), 300, 300)
	self._objs["get_score_tip2_number"]:SetNumber(0)

	local ph = {x = self.node_t_list.img_spare_score_tip.node:getPositionX(), y = self.node_t_list.img_spare_score_tip.node:getPositionY()}
	self._objs["score_tip_number"] = NumberBar.New()
	self._objs["score_tip_number"]:SetRootPath(ResPath.GetWelfareTurnble("w_t_num_"))
	self._objs["score_tip_number"]:SetPosition(ph.x + 90, ph.y - 8)
	self.node_t_list.layout_turnble.node:addChild(self._objs["score_tip_number"]:GetView(), 300, 300)
	self._objs["score_tip_number"]:SetNumber(0)
end

function WelfareTurnbelView:InitWorldRecord()
	local ph = self.ph_list.ph_turntable_record_list
	self._objs["world_record_list"] = ListView.New()
	self._objs["world_record_list"]:Create(ph.x, ph.y, ph.w, ph.h, nil, RecordTurntableRender, nil, nil, self.ph_list.ph_world_item)
	self._objs["world_record_list"]:GetView():setAnchorPoint(0, 0)
	self._objs["world_record_list"]:SetJumpDirection(ListView.Bottom)
	self.node_t_list.layout_turnble.node:addChild(self._objs["world_record_list"]:GetView(), 100)
	-- self:FlushWorldRecord()
end

function RecordTurntableRender:__init()	
end

function RecordTurntableRender:__delete()	
end

function RecordTurntableRender:CreateChild()
	BaseRender.CreateChild(self)
end

function RecordTurntableRender:OnFlush()
	if self.data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local color = string.format("%06x", item_cfg.color)
	local playername = Scene.Instance:GetMainRole():GetName()
	local text = {}
	if playername == self.data.name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end
	local item_name = ItemData.Instance:GetItemName(self.data.item_id)
	local str = "{wordcolor;%s;[}{rolename;%s;%s}{wordcolor;%s;]}{wordcolor;DCD7C4;%s}{eq;%s;%s;%s}"
	local text_1 = string.format(str, self.rolename_color, self.rolename_color, self.data.name, 
		self.rolename_color, Language.XunBao.Prefix, color, item_cfg.name ,self.data.item_id)
	local rich_1 = RichTextUtil.ParseRichText(self.node_tree.rich_turntable_record.node,text_1, 18)
end

function RecordTurntableRender:CreateSelectEffect()
end

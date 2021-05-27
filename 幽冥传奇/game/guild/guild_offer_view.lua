-- 行会悬赏
local GuildOfferView = GuildOfferView or BaseClass(SubView)

function GuildOfferView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		{"guild_ui_cfg", 20, {0}},
	}

	self.task_data = {}
	self.task_idx = 1
end

function GuildOfferView:LoadCallBack()
	GuildCtrl.SendGuildOfferReq(1, 0)
	self:CreateItemList()
	self:CreateOfferList()
	self:OfferScoreNum()
	self:CreateRewardCells()
	
	XUI.AddClickEventListener(self.node_t_list.btn_accept.node, BindTool.Bind1(self.OnClickAccept, self)) 		-- 接受任务
	XUI.AddClickEventListener(self.node_t_list.btn_reward.node, BindTool.Bind1(self.OnClickReward, self)) 		-- 领取奖励
	XUI.AddClickEventListener(self.node_t_list.btn_quick.node, BindTool.Bind1(self.OnClickQuick, self)) 		-- 快速完成
	XUI.AddClickEventListener(self.node_t_list.btn_go.node, BindTool.Bind1(self.OnClickGoTask, self))  		-- 立即前往

	EventProxy.New(GuildData.Instance, self):AddEventListener(GuildData.GuildOffer, BindTool.Bind(self.OnFlushOfferView, self))

	self.offer_progressbar = ProgressBar.New()
	self.offer_progressbar:SetView(self.node_t_list.prog9_offer.node)
	self.offer_progressbar:SetTotalTime(0)
	self.offer_progressbar:SetTailEffect(991, nil, true)
	self.offer_progressbar:SetEffectOffsetX(-20)
	self.offer_progressbar:SetPercent(0)
end

function GuildOfferView:OnClickAccept()
	GuildCtrl.SendGuildOfferReq(2, self.task_data.task_id)
end

function GuildOfferView:OnClickReward()
	GuildCtrl.SendGuildOfferReq(4, self.task_data.task_id)
end

function GuildOfferView:OnClickQuick()
	local gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	local need_zs = GuildRewardCfg.tasks[self.task_data.task_id].onkeyFinish.consumes[1].count

	self.quick_tip = self.quick_tip or Alert.New()
	self.quick_tip:SetShowCheckBox(false)
	self.quick_tip:SetLableString(string.format(Language.Guild.QuickCompelteTask, need_zs))
	self.quick_tip:SetOkFunc(function()
		if gold >= need_zs then
			GuildCtrl.SendGuildOfferReq(5, self.task_data.task_id)
		else
			ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
		end
	end)
	self.quick_tip:Open()
end

function GuildOfferView:OnClickGoTask()
	if not self.task_data.open_btn then return end
	if self.task_data.open_btn.view_def ~= nil then
		ViewManager.Instance:OpenViewByDef(self.task_data.open_btn.view_def)
	elseif self.task_data.open_btn.npc_id ~= nil then
		Scene.SendQuicklyTransportReqByNpcId(self.data.npcid)
	elseif self.task_data.open_btn.boss_cfg ~= nil then
		BossCtrl.CSChuanSongBossScene(self.task_data.open_btn.boss_cfg.type, self.task_data.open_btn.boss_cfg.boss_id)
	end
end

function GuildOfferView:ReleaseCallBack()
	if self.offer_list then
		self.offer_list:DeleteMe()
		self.offer_list = nil
	end

	if self.offer_num then
		self.offer_num:DeleteMe()
		self.offer_num = nil
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if nil ~= self.xs_award_list then
		self.xs_award_list:DeleteMe()
		self.xs_award_list = nil
	end

	if nil ~= self.offer_progressbar then
		self.offer_progressbar:DeleteMe()
		self.offer_progressbar = nil
	end

	if self.quick_tip then
		self.quick_tip:DeleteMe()
		self.quick_tip = nil
	end
end

function GuildOfferView:ShowIndexCallBack()
	self:OnFlushOfferView()
end

function GuildOfferView:OnFlushOfferView()
	self:ShowOfferList()
	self:FlushShowItem()
end

function GuildOfferView:OfferScoreNum()
	if self.offer_num == nil then
		local ph = self.ph_list.ph_score_num
		self.offer_num = NumberBar.New()
		self.offer_num:Create(ph.x-1, ph.y+3, 80, 40, ResPath.GetCommon("num_100_"))
		self.offer_num:SetGravity(NumberBarGravity.Center)
		self.offer_num:SetSpace(0)
		self.node_t_list.layout_guild_offer.node:addChild(self.offer_num:GetView(), 300, 300)
	end
end

function GuildOfferView:CreateRewardCells()
	self.cell_list = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_item_cell" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetCellBgVis(false)
		self.node_t_list.layout_guild_offer.node:addChild(cell:GetView(), 9)
		table.insert(self.cell_list, cell)

		local cfg = GuildRewardCfg.integralawards[i]
		self.node_t_list["lbl_score_" .. i].node:setString(cfg.integral .. "积分")
		self.cell_list[i]:SetData(ItemData.FormatItemData(cfg.awards[1]))

		XUI.AddClickEventListener(self.node_t_list["layout_rew_" .. i].node, BindTool.Bind(self.OnClickRewScore, self, i), true)
	end
end

function GuildOfferView:OnClickRewScore(index)
	GuildCtrl.SendGuildOfferReq(3, index)
end

function GuildOfferView:CreateItemList()
	local ph = self.ph_list["ph_rew_list"]
	local ph_item = {w = BaseCell.SIZE, h = BaseCell.SIZE}
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, BaseCell, ScrollDir.Horizontal, false, ph_item)
	self.node_t_list.layout_guild_offer.node:addChild(grid_scroll:GetView(), 99)
	self.xs_award_list = grid_scroll
end

function GuildOfferView:CreateOfferList()
	if self.offer_list ~= nil then return end

	local ph = self.ph_list.ph_offer_task_list
	local list = ListView.New()
	list:Create(ph.x+2, ph.y, ph.w, ph.h, nil, GuildOfferItem, nil, nil, self.ph_list.ph_offer_task_item)
	self.node_t_list.layout_guild_offer.node:addChild(list:GetView(), 100)
	list:SetItemsInterval(5)
	list:SetAutoSupply(true)
	list:SetMargin(1)
	list:SetJumpDirection(ListView.Top)
	list:SetSelectCallBack(BindTool.Bind(self.OfferTaskCallback, self))
	self.task_data = GuildData.Instance:SetOfferTaskData()[1]

	self.offer_list = list
end

function GuildOfferView:OfferTaskCallback(item, index)
	local data = item:GetData()
	self.task_data = data
	self.task_idx = index

	self:FlushShowItem()
end

function GuildOfferView:ShowOfferList()
	if self.offer_list == nil then return end

	local offer_list = GuildData.Instance:SetOfferTaskData()
	self.offer_list:SetDataList(offer_list)
	self.offer_list:ChangeToIndex(self.task_idx)
	self.task_data = offer_list[self.task_idx]

	local score, rew_data = GuildData.Instance:GetOfferScore()
	self.offer_num:SetNumber(score)
	
	for i = 1, 4 do
		self.node_t_list["img_stmp_" .. i].node:setVisible(rew_data[33-i] == 1)
		local need_score = GuildRewardCfg.integralawards[i].integral
		local is_remid = score >= need_score and rew_data[33-i] == 0
		self.cell_list[i]:SetRemind(is_remid, nil, 50, 50)
		self.node_t_list["layout_rew_" .. i].node:setVisible(score >= need_score)
	end
	self.offer_progressbar:SetPercent(score / GuildRewardCfg.integralawards[#GuildRewardCfg.integralawards].integral * 100)

	self:SetBtnShow()
end

function GuildOfferView:FlushShowItem()
	local data = self.task_data
	local color = data.complete_num >= data.max_num and "55ff00" or "ff0000"
	local txt = data.desc .. string.format("{wordcolor;%s;(%d/%d)}", color, data.complete_num, data.max_num)
	RichTextUtil.ParseRichText(self.node_t_list.rich_offer_desc.node, txt, 18, COLOR3B.GREEN)

	local item_data = {}
	for k, v in pairs(data.reward) do
		if v.type == 0 then
			item_data[k] = {item_id = v.id, num = v.count, is_bind = v.is_bind}
		else
			item_data[k] = ItemData.FormatItemData(v)
		end
	end
	self.xs_award_list:SetDataList(item_data)

	if data.is_reward == 0 then
		if data.task_state == 0 then
			self.node_t_list.btn_accept.node:setVisible(true)
			self.node_t_list.layout_quick.node:setVisible(false)
			self.node_t_list.btn_reward.node:setVisible(false)
		elseif data.task_state == 1 then
			self.node_t_list.btn_accept.node:setVisible(false)
			self.node_t_list.layout_quick.node:setVisible(true)
			self.node_t_list.btn_reward.node:setVisible(false)
		elseif data.task_state == 2 then
			self.node_t_list.btn_accept.node:setVisible(false)
			self.node_t_list.layout_quick.node:setVisible(false)
			self.node_t_list.btn_reward.node:setVisible(true)
		end
	elseif data.is_reward == 1 then
		self.node_t_list.btn_accept.node:setVisible(false)
		self.node_t_list.layout_quick.node:setVisible(false)
		self.node_t_list.btn_reward.node:setVisible(false)
	end
end

-- 根据开服天数设置快速完成按钮显示
function GuildOfferView:SetBtnShow()
	local open_day = OtherData.Instance:GetOpenServerDays()
	self.node_t_list.btn_quick.node:setVisible(open_day >= self.task_data.btn_days)	
	local pos_x = open_day >= self.task_data.btn_days and 220 or 135
	
	self.node_t_list.btn_go.node:setPositionX(pos_x)
end

----------------------------------------------------
-- GuildOfferItem
----------------------------------------------------
GuildOfferItem = GuildOfferItem or BaseClass(BaseRender)

function GuildOfferItem:__init()
end

function GuildOfferItem:__delete()
	self.com_eff = nil
end

function GuildOfferItem:CreateChild()
	BaseRender.CreateChild(self)

	self.com_eff = RenderUnit.CreateEffect(23, self.node_tree.img9_bg.node, 10)
	self.com_eff:setScaleX(3.7)
	self.com_eff:setScaleY(1.2)
end

function GuildOfferItem:OnFlush()
	if self.data == nil then return end

	local color = self.data.complete_num >= self.data.max_num and "55ff00" or "ff0000"
	local txt = self.data.desc .. string.format("{wordcolor;%s;(%d/%d)}", color, self.data.complete_num, self.data.max_num)
	RichTextUtil.ParseRichText(self.node_tree.rich_task_desc.node, txt, 17, COLOR3B.G_W2)
	
	local txt = {"未领取", "进行中", "已完成"}
	local color = {COLOR3B.RED, COLOR3B.GREEN, COLOR3B.G_W2}
	self.node_tree.lbl_score.node:setString(txt[self.data.task_state+1])
	self.node_tree.lbl_score.node:setColor(color[self.data.task_state+1])
	self.com_eff:setVisible(self.data.task_state == 2 and self.data.is_reward == 0)
end

function GuildOfferItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2,  size.height / 2, size.width + 10, size.height + 10, ResPath.GetCommon("img9_286"), true, cc.rect(8, 9, 13, 11))
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 999)
end

return GuildOfferView
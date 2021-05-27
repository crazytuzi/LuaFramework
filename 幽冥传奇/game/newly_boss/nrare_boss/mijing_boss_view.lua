--------------------------------------------------------
-- 秘境boss 配置DmkjConfig
--------------------------------------------------------

local MijingBossView = MijingBossView or BaseClass(SubView)

function MijingBossView:__init()
	self.texture_path_list[1] = 'res/xui/explore.png'
	self:SetModal(true)
	self.config_tab = {
		{"new_boss_ui_cfg", 7, {0}},
	}
	
end

function MijingBossView:__delete()
end

function MijingBossView:ReleaseCallBack()
	self.eff = nil

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

--加载回调
function MijingBossView:LoadCallBack(index, loaded_times)
	self:CreateAwardList()
	self:CreateBossList()
	self:CreateTextBtn()

	XUI.EnableOutline(self.node_t_list["lbl_need_level"].node)
	XUI.EnableOutline(self.node_t_list["lbl_flush_left_time"].node)
	XUI.EnableOutline(self.node_t_list["lbl_boss_name"].node)
	XUI.EnableOutline(self.node_t_list["lbl_boss_level"].node)

	XUI.AddClickEventListener(self.node_t_list["btn_challenge"].node, BindTool.Bind(self.OnChallenge, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_tip"].node, BindTool.Bind(self.OnTip, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_tx.node, BindTool.Bind(self.OnClickBossTixing, self))

	EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.EXPLORE_SCORE_CHANGE, BindTool.Bind(self.FlushTimes, self))
	EventProxy.New(BossData.Instance, self):AddEventListener(BossData.UPDATE_BOSS_DATA, BindTool.Bind(self.OnUpdateBossData, self))
	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.NEWLY_BOSS_REMIND, BindTool.Bind(self.Flush, self))
end

function MijingBossView:OpenCallBack()
	ExploreCtrl:SendFirstPageDataReq()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MijingBossView:CloseCallBack(is_all)
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

--显示指数回调
function MijingBossView:ShowIndexCallBack(index)
	self.select_data = nil
	self.select_index = nil
	self:Flush()
end

function MijingBossView:OnFlush(param_list)
	-- local _, data_list = ExploreData.GetRareplaceCfg()
	local boss_data = NewlyBossData.Instance:GetLonghunData()

	self.boss_list:SetDataList(boss_data)
	self.boss_list:SelectItemByIndex(1)
	self.boss_list:JumpToTop()

	self:FlushTimes()
	self:FlushConsume()
end

function MijingBossView:OnClickBossTixing()
	local boss_list = NewBossData.Instance:SetRareBossInfo(5)
	ViewManager.Instance:OpenViewByDef(ViewDef.BossRefreshRemind)
	ViewManager.Instance:FlushViewByDef(ViewDef.BossRefreshRemind, 0, nil, {data = boss_list})
end

-- 刷新剩余次数
function MijingBossView:FlushTimes()
	local cfg, data_list = ExploreData.GetRareplaceCfg()
	local rareplace_data = ExploreData.Instance:GetRareplaceData()
	local max_free_times = cfg.maxFreeTms or 0
	local buy_num = rareplace_data.lhmb_buy_num or 0
	local enter_num = rareplace_data.lhmb_enter_num or 0
	local left_times = max_free_times + buy_num - enter_num
	local color = left_times >= 1 and COLOR3B.GREEN or COLOR3B.RED
	self.can_enter = left_times > 0
	self.node_t_list["lbl_left_times"].node:setString(string.format("剩余次数：%d/%d", left_times, max_free_times + buy_num))
	self.node_t_list["lbl_left_times"].node:setColor(color)
end

-- 刷新"Boss刷新时间"
function MijingBossView:ResetBossFlushTime()
	local boss_id = self.select_data.boss_id or 0
	local boss_list = BossData.Instance:GetSceneBossListByType(BossData.BossTypeEnum.SECRET_BOSS)
	local cur_boss = boss_list[boss_id] or {}
	local left_time = (cur_boss.now_time or 0) + (cur_boss.refresh_time or 0) - Status.NowTime

	if left_time > 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end

		self.node_t_list["lbl_flush_left_time"].node:setVisible(true)
		local callback = function()
			local boss_id = self.select_data and self.select_data.boss_id or 0
			local boss_list = BossData.Instance:GetSceneBossListByType(BossData.BossTypeEnum.SECRET_BOSS)
			local cur_boss = boss_list[boss_id] or {}
			local left_time = (cur_boss.now_time or 0) + (cur_boss.refresh_time or 0) - Status.NowTime
			if self:IsOpen() and left_time > 0 then
				self.node_t_list["lbl_flush_left_time"].node:setString(TimeUtil.FormatSecond(left_time, 3) .. "后复活")
			else
				if self.timer then
					GlobalTimerQuest:CancelQuest(self.timer)
					self.timer = nil
				end
			end
		end
		callback()
		self.timer = GlobalTimerQuest:AddTimesTimer(callback, 1, left_time)
	else
		self.node_t_list["lbl_flush_left_time"].node:setVisible(false)
	end
end

function MijingBossView:CreateBossList()
	local ph = self.ph_list["ph_boss_list"]
	local ph_item = self.ph_list["ph_boss_item"]
	local parent = self.node_t_list["layout_dragon_boss"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h, self.BossListRender, ScrollDir.Vertical, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	grid_scroll:SetSelectCallBack(BindTool.Bind(self.SelectBossCallBack, self))
	grid_scroll:JumpToTop() -- 跳至开头
	self.boss_list = grid_scroll
	self:AddObj("boss_list")
end

function MijingBossView:SelectBossCallBack(item)
	if self.select_index == item:GetIndex() then return end

	self.select_data = item:GetData()
	self.select_index = item:GetIndex()

	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local str
	if self.select_data.circle > 0 then
		str = self.select_data.circle .. Language.Common.Zhuan .. self.select_data.level .. Language.Common.Ji
	else
		str = self.select_data.level .. Language.Common.Ji
	end
	self.conditions = role_circle >= self.select_data.circle and role_lv >= self.select_data.level
	local color = self.conditions and COLOR3B.GREEN or COLOR3B.RED
	local data = BossData.GetMosterCfg(self.select_data.boss_id)
	self.node_t_list["lbl_need_level"].node:setString(str)
	self.node_t_list["lbl_need_level"].node:setColor(color)
	self.node_t_list["lbl_boss_name"].node:setString(self.select_data.boss_name)

	self.node_t_list["lbl_boss_level"].node:setString(self.select_data.boss_level .. Language.Common.Ji)

	local awards = self.select_data.awards or {}
	self:FlushCellList(awards)
	self:FlusEff()
	self:ResetBossFlushTime()
	self:FlushConsume()
end

function MijingBossView:FlushConsume()
	local rich = self.node_t_list["rich_consume"].node
	local bz_score = ExploreData.Instance:GetXunBaoData().bz_score or 0
	local consume_score = self.select_data.costDmValue or 0
	local score_color = bz_score >= consume_score and COLORSTR.GREEN or COLORSTR.RED
	-- 示例: "寻宝积分9999/999"
	local text = string.format("{color;%s;%s}{color;%s;%d/%d}", "cc9e45", "寻宝积分", score_color,  bz_score, consume_score)
	rich = RichTextUtil.ParseRichText(rich, text, 22, COLOR3B.OLIVE)
	rich:setVisible(true)
	rich:refreshView()
end

function MijingBossView:CreateAwardList()
	local ph = self.ph_list["ph_award_list"]
	local ph_item = {w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_dragon_boss"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, BaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.award_list = grid_scroll
	self:AddObj("award_list")
end

function MijingBossView:FlushCellList(show_list)
	self.award_list:SetDataList(show_list)

	-- 居中处理
	local view = self.award_list:GetView()
	local inner = view:getInnerContainer()
	local size = view:getContentSize()
	local ph_item = {w = BaseCell.SIZE, h = BaseCell.SIZE}
	local inner_width = ph_item.w * (#show_list) + (#show_list - 1) * 10 + 20
	local view_width = math.min(self.ph_list["ph_award_list"].w, inner_width)
	view:setContentSize(cc.size(view_width, size.height))
	view:setInnerContainerSize(cc.size(inner_width, size.height))
	view:jumpToTop()
end

function MijingBossView:CreateTextBtn()
	local ph, text
	local parent = self.node_t_list["layout_dragon_boss"].node

	ph = self.ph_list["ph_text_btn_1"]
	text = RichTextUtil.CreateLinkText("购买次数", 20, COLOR3B.GREEN)
	text:setPosition(ph.x, ph.y)
	parent:addChild(text, 99)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnTextBtn, self, 1), true)
end

function MijingBossView:FlusEff()
	local boss_cfg = BossData.GetMosterCfg(self.select_data.boss_id)
	local entityid = boss_cfg.modelid or 0
	local path, name = ResPath.GetMonsterAnimPath(entityid, SceneObjState.Stand, 4)

	if nil == self.eff then
		local ph = self.ph_list["ph_boss"]
		self.eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Stand, false)
		self.eff:setPosition(ph.x, ph.y)
		self.node_t_list["layout_dragon_boss"].node:addChild(self.eff, 1)
	else
		self.eff:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Stand, false)
	end
end

----------------------------------------

function MijingBossView:OnTip()
	DescTip.Instance:SetContent(Language.DescTip.LongHuangMiJingContent, Language.DescTip.LongHuangMiJingTitle)
end

function MijingBossView:OnChallenge()
	if not self.timer then
		ExploreCtrl.EnterRareplaceReq(self.select_data.layer)
	else
		SystemHint.Instance:FloatingTopRightText("BOSS未刷新")
	end

	if not self.timer and self.can_enter and self.conditions then
		ViewManager.Instance:CloseViewByDef(ViewDef.NewlyBossView)
	end
end

function MijingBossView:OnTextBtn(index)
	if index == 1 then
		if nil == self.bug_times_alert then
			self.bug_times_alert = Alert.New()
			self.bug_times_alert:SetOkFunc(function()
				ExploreCtrl.BuyRareplaceTimesReq()
			end)
			self:AddObj("bug_times_alert")
		end

		local rareplace_data = ExploreData.Instance:GetRareplaceData()
		local buy_num = rareplace_data.lhmb_buy_num or 0
		local cfg = ExploreData.GetRareplaceCfg()
		local consume = cfg.buyTmsConsumes[buy_num+1] and cfg.buyTmsConsumes[buy_num+1][1] or {}
		self.bug_times_alert:SetLableString(string.format("是否花费{color;ff2828;%d钻石}购买次数", consume.count or 0))
		self.bug_times_alert:Open()
	end
end

-- boss击杀状态改变
function MijingBossView:OnUpdateBossData()
	self.boss_list:RefreshItems()

	-- self.select_index 改变才能调用到 SelectBossCallBack
	local select_index = self.select_index
	self.select_index = nil
	self.boss_list:SelectItemByIndex(select_index)
end

----------------------------------------
-- BOSS列表渲染
----------------------------------------
MijingBossView.BossListRender = BaseClass(BaseRender)
local BossListRender = MijingBossView.BossListRender
function BossListRender:__init()

end

function BossListRender:__delete()
end

function BossListRender:CreateChild()
	BaseRender.CreateChild(self)
end

function BossListRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)

	local boss_id = self.data.boss_id or 0
	local boss_cfg = BossData.GetMosterCfg(boss_id)
	self.node_tree["lbl_name"].node:setString(self.data.boss_name)
	self.node_tree["lbl_level"].node:setString(self.data.boss_level .. Language.Common.Ji)

	----------秘境状态----------
	local own_all_num = ExploreData.Instance:GetXunBaoData().own_all_num or 0
	local boor = own_all_num >= (self.data.openDmTms or 0)
	local state_str = ""
	if boor then
		-- 判断boss是否已刷新
		local boss_list = BossData.Instance:GetSceneBossListByType(5)
		local cur_boss = boss_list[boss_id] or {}
		local left_time = (cur_boss.now_time or 0) + (cur_boss.refresh_time or 0) - Status.NowTime
		boor = left_time <= 0
		state_str = boor and "\n已刷新" or "\n未刷新"
	else
		state_str = string.format("累积寻宝%d次\n永久开启", self.data.openDmTms)
	end
	local color = boor and COLOR3B.GREEN or COLOR3B.RED
	self.node_tree["lbl_state"].node:setString(state_str)
	self.node_tree["lbl_state"].node:setColor(color)
	self.node_tree["lbl_name"].node:setColor(color)
	self.node_tree["lbl_level"].node:setColor(color)
	----------end----------
end

return MijingBossView
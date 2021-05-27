--------------------------------------------------------
-- 寻宝-龙皇秘宝  配置 DmkjConfig.LoongDmCfg
--------------------------------------------------------

local ExploreRareTreasureView = ExploreRareTreasureView or BaseClass(SubView)

function ExploreRareTreasureView:__init()
	self.texture_path_list[1] = 'res/xui/explore.png'
	self:SetModal(true)
	self.config_tab = {
		{"explore_ui_cfg", 9, {0}}
	}
	
end

function ExploreRareTreasureView:__delete()
end

--释放回调
function ExploreRareTreasureView:ReleaseCallBack()

end

--加载回调
function ExploreRareTreasureView:LoadCallBack(index, loaded_times)
	self.data = ExploreData.Instance:GetRareTreasureData()

	self:CreateCellList()
	self:CreateRecordList()
	self:CreateItemList()

	self.node_t_list['img_pointer'].node:setAnchorPoint(0.5, 0.365)
	XUI.EnableOutline(self.node_t_list["lbl_time"].node)

	local cfg = DmkjConfig and DmkjConfig.LoongDmCfg or {}
	self.node_t_list["lbl_tip"].node:setString(string.format("寻宝满%d次可开启1次龙族秘宝", cfg.maxDmTms or 0))

	XUI.AddClickEventListener(self.node_t_list["btn_tip"].node, BindTool.Bind(self.OnTip, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_start"].node, BindTool.Bind(self.OnStart, self), true)

	XUI.AddRemingTip(self.node_t_list["btn_start"].node, nil, nil, 105, 100)

	-- EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_GOLD, BindTool.Bind(self.OnRoleAttrChange, self))
	EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.RARE_REASURE, BindTool.Bind(self.OnRareTreasure, self))
	EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.EXPLORE_SCORE_CHANGE, BindTool.Bind(self.FlushRewList, self))
end

function ExploreRareTreasureView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	ExploreCtrl.Instance:SendFirstPageDataReq()
end

function ExploreRareTreasureView:CloseCallBack(is_all)
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

--显示指数回调
function ExploreRareTreasureView:ShowIndexCallBack(index)
	self:CreateTimer()
	self:Flush()
	self:FlushCellList()
	self.node_t_list["btn_start"].node:setEnabled(true)
end

function ExploreRareTreasureView:OnFlush(param_list)
	local cfg = ExploreData.Instance:GetRareTreasureCfg()
	local cur_cfg = cfg[self.data.award_pools_index or 1] or {}
	local path = ResPath.GetExplore("img_dragon_treasure_text_" .. (cur_cfg.img_index or 1))
	self.node_t_list["img_dragon_treasure_text"].node:loadTexture(path)

	self.pro_item_list:SetDataList(ExploreData.Instance:GetWorldRewItem())
end

function ExploreRareTreasureView:FlushRewList()
	self.pro_item_list:SetDataList(ExploreData.Instance:GetWorldRewItem())
end

function ExploreRareTreasureView:CreateTimer()
	local callback = function()
		if self:IsOpen() and self.node_t_list["lbl_time"] then
			local day_left_time = TimeUtil.NowDayTimeEnd(os.time()) - os.time()
			-- 垮天时间更正
			if day_left_time < 30 or day_left_time > 86370 then
				OtherData.Instance:PassDay()
			end

			local open_days = OtherData.Instance:GetOpenServerDays()
			local left_days = self.data.end_time - open_days - 1
			local time = day_left_time + left_days * 86400
			self.node_t_list["lbl_time"].node:setString(string.format("活动时间：剩余%s", TimeUtil.FormatSecond2Str(time)))
		else
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
	end

	callback() -- 创建记时器之前,先调用一次刷新显示.
	self.timer = GlobalTimerQuest:AddRunQuest(callback, 1)
end

function ExploreRareTreasureView:CreateItemList()
	local ph = self.ph_list.ph_pro_reward_list
	self.pro_item_list = ListView.New()
	self.pro_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, RewardRender, nil, nil, self.ph_list.ph_pro_reward_item)
	-- self.pro_item_list:GetView():setAnchorPoint(0, 0)
	-- self.pro_item_list:SetItemsInterval(5)
	self.pro_item_list:SetMargin(0)
	self.pro_item_list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_dragon_treasure.node:addChild(self.pro_item_list:GetView(), 100)
	self:AddObj("pro_item_list")
end

function ExploreRareTreasureView:CreateCellList()
	local cfg = ExploreData.Instance:GetRareTreasureCfg()
	local cur_cfg = cfg[self.data.award_pools_index or 1] or {}
	local parent = self.node_t_list["layout_dragon_treasure"].node

	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local award_list = cur_cfg.awardpool and cur_cfg.awardpool[sex] or {}
	
	self.cell_list = {}
	for i, v in pairs(award_list) do
		local award = v.awards and v.awards[1]
		local item_data = ItemData.InitItemDataByCfg(award)
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_item_" .. i]
		-- cell:SetData(item_data)
		cell:GetView():setPosition(ph.x, ph.y)
		parent:addChild(cell:GetView(), 1)
		self.cell_list[i] = cell
	end

	self:AddObj("cell_list")
end
function ExploreRareTreasureView:CreateRecordList()
	local ph = self.ph_list["ph_record_list"]
	self.record_list = ListView.New()
	self.record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, self.RecordRender, nil, nil, self.ph_list["ph_record_item"])
	self.record_list:SetJumpDirection(ListView.Top)
	self.node_t_list["layout_dragon_treasure"].node:addChild(self.record_list:GetView(), 10)
	self:AddObj("record_list")
	
	self.record_list:SetDataList(self.data.record_list)
end

function ExploreRareTreasureView:FlushCellList()
	local cfg = ExploreData.Instance:GetRareTreasureCfg()
	local cur_cfg = cfg[self.data.award_pools_index or 1] or {}
	local parent = self.node_t_list["layout_dragon_treasure"].node
	local text = "已全部获得"

	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local award_list = cur_cfg.awardpool and cur_cfg.awardpool[sex] or {}
	local have_award = false -- 转盘还有奖励
	for i, v in pairs(award_list) do
		local award = v.awards and v.awards[1]
		local item_data = ItemData.InitItemDataByCfg(award)
		self.cell_list[i]:SetData(item_data)
		local path = ResPath.GetCommon("img_gou")
		local boor = self.data.award_tag[33-i] == 1
		self.cell_list[i]:SetSpecilImgVisible(boor, path, 40, 40)
		self.cell_list[i]:MakeGray(boor)
		if not boor then
			have_award = true
			text = string.format("可抽奖次数:%d次", self.data.award_times)
		end
	end

	-- 刷新按钮红点
	self.node_t_list["btn_start"].node:UpdateReimd(have_award and self.data.award_times > 0)
	self.node_t_list["lbl_times"].node:setString(text)
end

-- 转盘动作
function ExploreRareTreasureView:FlushAction()
	if self.data.award_index == 0 then return end
	self.node_t_list["btn_start"].node:setEnabled(false)

	local item_index = self.data.award_index or 1
	self.node_t_list['img_pointer'].node:stopAllActions()
	local act_info = {{0.5, 0.5}, {0.3, 0.5}, {0.2, 0.5}, {1.5, 5}} -- 启动动作
	local act_info_item ={{0.18, 0.6}, {0.16, 0.4}, {0.2, 0.4}, {0.25, 0.4}, {0.15, 0.2}, {0.25, 0.25}, {0.4, 0.2}, {0.15, 0.05}} -- 停止前的缓冲动作

	local current_angle = self.node_t_list['img_pointer'].node:getRotation() -- 获取当前角度
	local item_Angle = (item_index * 360 / 8 - 18 - current_angle%360 + 360)%360 -- 算出需旋转的角度

	 -- 900 为缓冲动作的旋转角度,算出缓冲动作需要改变的"比例"
	local ratio = (item_Angle  + 900) / 900
	-- 根据"比例"改变缓冲动作每一步的时间和"角度比例"
	for k,v in pairs(act_info_item) do
		table.insert(act_info, {(v[1] * ratio), (v[2] * ratio)})
	end
	-- 创建动作
	local act_t = {}
	for i, v in pairs(act_info) do
		act_t[i] = cc.RotateBy:create(v[1], v[2] * 360)
	end

	local seq_act = cc.Sequence:create(unpack(act_t)) -- 合并动作
	local seq_act = cc.Sequence:create(seq_act, cc.CallFunc:create(BindTool.Bind(self.OnTableActionChange, self))) -- 绑定动作回调
	self.node_t_list['img_pointer'].node:runAction(seq_act) -- 运行操作
end


function ExploreRareTreasureView:OnTableActionChange()
	local item_index = self.data.award_index or 1
	local cell = self.cell_list[item_index]
	if cell then
		local cell_data = cell:GetData()
		ExploreCtrl.Instance:StartFlyItem(cell_data.item_id or 0)
	end
	
	if self:IsOpen() then
		self.node_t_list["btn_start"].node:setEnabled(true)
	end

	self:FlushCellList()
	self.record_list:SetDataList(self.data.record_list)
end


function ExploreRareTreasureView:OnTip()
	DescTip.Instance:SetContent(Language.DescTip.LongHuangMiBaoContent, Language.DescTip.LongHuangMiBaoTitle)
end

function ExploreRareTreasureView:OnStart()
	if self.data.award_times > 0 then
		BagData.Instance:SetDaley(true)
		self.node_t_list["btn_start"].node:setEnabled(false)
	end

	ExploreCtrl.RareTreasureReq()
end


function ExploreRareTreasureView:OnRareTreasure()
	if self.data.award_index >= 0 then
		self:FlushAction()
	end

	self:Flush()
end

----------------------------------------
-- 项目渲染命名
----------------------------------------
ExploreRareTreasureView.RecordRender = BaseClass(BaseRender)
local RecordRender = ExploreRareTreasureView.RecordRender
function RecordRender:__init()
	--self.item_cell = nil
end

function RecordRender:__delete()
	-- if self.item_cell then
	-- 	self.item_cell:DeleteMe()
	-- 	self.item_cell = nil
	-- end
end

function RecordRender:CreateChild()
	BaseRender.CreateChild(self)
end

function RecordRender:OnFlush()
	if nil == self.data then return end
	local playername = Scene.Instance:GetMainRole():GetName()
	local rolename_color = playername == self.data.role_name and COLORSTR.YELLOW or COLORSTR.BLUE

	local item_data = {item_id = self.data.item_id, type = self.data.item_type, num = self.data.item_num}
	local text = string.format(Language.XunBao.Txt, rolename_color, self.data.role_name, Language.XunBao.Prefix, RichTextUtil.CreateItemStr(item_data))
	local rich = RichTextUtil.ParseRichText(self.node_tree["rich_record"].node, text, 18)
end

function RecordRender:CreateSelectEffect()
	return
end

function RecordRender:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end

-- 列表Item
RewardRender = RewardRender or BaseClass(BaseRender)
function RewardRender:__init()
end

function RewardRender:__delete()
	
end

function RewardRender:CreateChild()
	BaseRender.CreateChild(self)
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 103)
	end	

	XUI.AddClickEventListener(self.node_tree.btn_rew.node, BindTool.Bind1(self.OnClickReward, self))
end

function RewardRender:OnClickReward()
	
	local vis = self.data.own_xb_num >= self.data.num and self.data.own_state == 0
	if vis then
		ExploreCtrl.Instance:SendOwnNumRewardReq(self.data.index)
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Xunbao)
	end
end

function RewardRender:OnFlush()
	if nil == self.data then return end

	self.cell:SetData(self.data.item)
	self.node_tree.lbl_xb_num.node:setString(string.format(Language.ActivityBrilliant.XunbaoTip, self.data.num))

	local txt = Language.StrenfthFb.ChestBtnState[1]
	local remind = true
	if self.data.own_state == 1 then
		txt = Language.StrenfthFb.ChestBtnState[2]
		remind = false
	elseif self.data.own_xb_num < self.data.num  then
		txt = Language.Common.BtnRechargeGo
		remind = false
	end

	self.node_tree.btn_rew.node:setTitleText(txt)
	self.node_tree.img_rew_falg.node:setVisible(remind)
	XUI.SetButtonEnabled(self.node_tree.btn_rew.node, self.data.own_state == 0)
end

function RewardRender:CreateSelectEffect()
end

return ExploreRareTreasureView
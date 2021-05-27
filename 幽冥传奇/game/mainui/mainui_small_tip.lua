----------------------------------------------------
-- 主ui小提示图标
----------------------------------------------------
MainuiSmallTip = MainuiSmallTip or BaseClass()

-- 小图标
-- 资源目录 client\tools\uieditor\ui_res\mainui
-- 资源命名 tip_xx.png	例如队伍：tip_1.png
MAINUI_TIP_TYPE = {
	TEAM = 1,				-- 队伍
	SOCIETY = 2,			-- 社交
	EXCHANGE = 3,			-- 交易
	MAIL = 4,				-- 邮件
	EXPBALL = 5,			-- 经验珠
	GUILD_LEAGUE = 6,		-- 行会联盟
	CALL_GUILD_MEMBER = 7,	-- 行会召唤
	GUILD_APPLY = 8,		-- 行会申请
	GUILD_INVITE = 9,		-- 行会邀请
	REQUEST_MARRY = 10,		-- 求婚
	OFFLINE_GUAJI = 11,		-- 离线挂机
	NGBALL = 12,			-- 内功珠
	GUILD_HONGBAO = 13,		-- 行会红包
	PLAY_PK_REQ = 14,		-- 激情叫嚣
	CALL_BOSS = 15,			-- boss召唤令
	RED_ENVELOPES = 16,		-- 天降红包
	LOSER = 17,				-- 屌丝逆袭
	FREE_CROSSBRAND = 100,	-- 跨服翻牌

	BUY_DRUG = 34,			-- 药品不足
	BUY_LOTUS = 35,			-- 莲花不足
	ENCHANTMENT = 36,		-- 蚩尤结界
	RE_XUE = 37,			-- 热血霸者
	LACK_OF_STONE = 38,		-- 石头不足
	SUMMON = 39,			-- 召唤

	-- 日常活动
	DAILY_ACT_1 = 18,		-- 闭关修炼
	DAILY_ACT_2 = 29,		-- 夺宝奇兵
	DAILY_ACT_3 = 27,		-- 行会闯关
	DAILY_ACT_4 = 28,		-- 攻城战
	DAILY_ACT_5 = 22,		-- 膜拜城主
	DAILY_ACT_6 = 23,		-- 武林争霸
	DAILY_ACT_7 = 24,		-- 元宝嘉年华
	DAILY_ACT_8 = 21,		-- 多倍押送
	DAILY_ACT_9 = 30,		-- 行会boss
	DAILY_ACT_10 = 31,		-- 阵营战
	DAILY_ACT_11 = 32,		-- 世界boss
	ROB_RED_PACKAGE = 33,	-- 抢红包
}

local tip_interval = 80     --每个tip之间的间距
function MainuiSmallTip:__init()
	self.tip_icon_list = {}
	self.mt_layout_tip = nil
	self.mt_layout_root = nil

	GlobalEventSystem:Bind(MainUIEventType.TASK_BAR_VIS, BindTool.Bind(self.OnTaskBarVisChange, self))
	GlobalEventSystem:Bind(MainUIEventType.BONFIRE_BAR_VIS, BindTool.Bind(self.OnBonfireBarVisChange, self))
	GlobalEventSystem:Bind(MainUIEventType.SET_TIPS_UI_VIS, BindTool.Bind(self.OnSetTipsUiVis, self))
end

function MainuiSmallTip:__delete()
	for k,v in pairs(self.tip_icon_list) do
		v:DeleteMe()
	end
	self.tip_icon_list = nil
	self.mt_layout_root = nil
end

function MainuiSmallTip:OnTaskBarVisChange(vis)
	self:UpdateAllTipIconPos()
end

-- 未知暗殿双倍篝火显示改变
function MainuiSmallTip:OnBonfireBarVisChange(index)
	if nil ~= self.mt_layout_tip and index then
		self.mt_layout_tip:stopAllActions()
		local pos = self:NormalRootPos()
		self.mt_layout_tip:setPosition(pos.x, pos.y + (index == 1 and 120 or 85))
	end
end

-- 进入日常活动
function MainuiSmallTip:OnSetTipsUiVis(vis)
	self:SetTipsUiVisible(vis)
end


function MainuiSmallTip:NormalRootPos()
	local root_size = self.mt_layout_root:getContentSize()
	return cc.p(root_size.width / 2 - 140, 120)
end

function MainuiSmallTip:Init(mt_layout_root)
	self.mt_layout_root = mt_layout_root
	self.mt_layout_tip = MainuiMultiLayout.CreateMultiLayout(0, 0, cc.p(0, 0), cc.size(500, 60), mt_layout_root)

	self:UpdateAllTipIconPos()
end

function MainuiSmallTip:SetTipsUiVisible(value)
	if self.mt_layout_tip then
		self.mt_layout_tip:setVisible(value)
	end
end

function MainuiSmallTip:UpdateAllTipIconPos()
	if nil ~= self.mt_layout_tip then
		self.mt_layout_tip:stopAllActions()
		local pos = self:NormalRootPos()
		local task_vis = MainuiCtrl.Instance:IsMainTaskVis()
		self.mt_layout_tip:setPosition(pos.x, pos.y + (task_vis and 90 or 0))
	end
end

-- 添加tip图标
function MainuiSmallTip:AddTipIcon(tip_type, callback, num, param)

	local tip_list = self:GetTipIconList(tip_type)
	local icon = nil

	if #tip_list == 0 then
		icon = MainuiTipIcon.New(tip_type, self.mt_layout_tip, self.tip_icon_list)
		icon:PlayIconEffect(400, {x = icon.width/2, y = icon.height/2 + 6}, 9999, 0.7)
		local is_close = false
		icon:AddClickEventListener(BindTool.Bind(self.ClickTipIconHandler, self, icon))
		table.insert(self.tip_icon_list, icon)

		function icon.CloseOnceEffect()
			if is_close then return end
			icon:RemoveIconEffect()
			is_close = true
			icon.CloseOnceEffect = nil
		end
	else
		for k,v in pairs(tip_list) do
			if nil == icon then
				icon = v
			end
			if not v:IsVaild() then
				icon = v
				break
			end
		end
	end
	if nil ~= icon then
		icon:SetVisible(true)
		icon:SetVaild(true)
		local data = {tip_type = tip_type, callback = callback, tip_index = #self.tip_icon_list, param = param}
		icon:SetData(data)
		icon:SetRemindNumTxt(num)
	end	
	self:UpdateTipIconPos()

	return icon
end

-- 移除tips图标
function MainuiSmallTip:RemoveTipIcon(tip_type)
	local icon_list = self:GetTipIconList(tip_type)
	for k, v in pairs(icon_list) do
		v:SetVisible(false)
		v:InitVaild()
	end
	self:UpdateTipIconPos()
end

function MainuiSmallTip:RemoveTipIconByIconObj(icon)
	for k, v in pairs(self.tip_icon_list) do
		if v == icon then
			icon:SetVisible(false)
			v:InitVaild()
			self:UpdateTipIconPos()
			return
		end
	end
end

function MainuiSmallTip:GetTipIcon(tip_type, is_vaild)
	for k,v in pairs(self.tip_icon_list) do
		if v:GetData() and v:GetData().tip_type == tip_type and (not is_vaild or v:IsVaild()) then
			return v
		end
	end
	return nil
end

function MainuiSmallTip:GetTipIconList(tip_type)
	local icon_list = {}
	for k,v in pairs(self.tip_icon_list) do
		if v:GetData() and v:GetData().tip_type == tip_type then
			table.insert(icon_list, v)
		end
	end
	return icon_list
end

function MainuiSmallTip:GetTipIconByIndex(tip_index)
	for k, v in pairs(self.tip_icon_list) do
		if v:GetData() and v:GetData().tip_index == tip_index then
			return v
		end
	end
	return nil
end

function MainuiSmallTip:UpdateTipIconPos()
	for _, v in pairs(self.tip_icon_list) do
		if v:IsVaild() then
			v:UpdateIconPos()
		end
	end
end

function MainuiSmallTip:ClickTipIconHandler(icon)
	local data = icon:GetData()
	if nil ~= data and nil ~= data.callback then
		data.callback(icon)
	end
	if icon.CloseOnceEffect then icon.CloseOnceEffect() end
end

------------------------------------------------
-- MainuiTipIcon 提示小图标
------------------------------------------------
MainuiTipIcon = MainuiTipIcon or BaseClass(MainUiIcon)

function MainuiTipIcon:__init(tip_type, parent_node, list)
	self.list = list
	self.width = 52
	self.height = 52
	self.tip_type = tip_type
	self.action_end_timer = nil
	self.move_speed = 500 / 1.5	-- 移动速度

	self:Create(parent_node)
	self:SetIconPath(ResPath.GetMainui("tip_" .. self.tip_type))
	self:InitVaild()
end

function MainuiTipIcon:__delete()
	self.list = nil
	self.action_end_timer = nil
end

function MainuiTipIcon:InitVaild()
	self.is_vaild = false
	self.finally_pos = cc.p(0, 0)
	
	local parent = self:GetView():getParent()
	local parent_node
	if parent.AnyLayout then
		parent_node = parent:AnyLayout()
	else
		parent_node = parent
	end
	local pos = parent_node:convertToNodeSpace(cc.p(0, 0))
	-- self:PlayIconEffect(924, anim_pos or {x = 23, y = 24}, nil, 0.7)
	self:StopMoveAction()
	-- 无效的图标在屏幕左侧外“等待”
	self:SetPosition(pos.x - 30, self.height / 2)
end

function MainuiTipIcon:SetVaild(vaild)
	self.is_vaild = vaild
end

function MainuiTipIcon:IsVaild()
	return self.is_vaild
end

function MainuiTipIcon:IsTipType(type)
	return self.tip_type == type
end

-- 根据列表得出最终坐标，并返回最终坐标是否有变化
function MainuiTipIcon:SetFinallyPos()
	if not self:IsVaild() then
		return false
	end

	local index = 1
	for i, v in ipairs(self.list) do
		if v == self then
			local tmp_pox = self.finally_pos
			self.finally_pos = cc.p((index - 1) * tip_interval + self.width / 2, self.height / 2)
			return tmp_pox.x ~= self.finally_pos.x
		end
		if v:IsVaild() then
			index = index + 1
		end
	end

	return false
end

function MainuiTipIcon:StopMoveAction()
	self:GetView():stopAllActions()
	if self.action_end_timer then
		GlobalTimerQuest:CancelQuest(self.action_end_timer)
	end
end

function MainuiTipIcon:UpdateIconPos()
	-- 最终坐标有变化才移动坐标
	local is_change = self:SetFinallyPos()
	if not is_change then
		return
	end

	local cur_x, cur_y = self:GetPosition()
	if self.finally_pos.x ~= cur_x then
		local move_x = math.abs(self.finally_pos.x - cur_x)
		local action_time = move_x / self.move_speed
		self:StopMoveAction()
		self:GetView():MoveTo(action_time, self.finally_pos.x, self.finally_pos.y)
		self.action_end_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.action_end_timer = nil
			-- 延时设置坐标，防卡帧时坐标不准确
			self:StopMoveAction()
			self:SetPosition(self.finally_pos.x, self.finally_pos.y)
		end, action_time + 1)
	end
end

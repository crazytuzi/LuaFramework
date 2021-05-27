--------------------------------------------------------
-- 运营活动-竞技类 活动ID：8/9/19/20/21/22/23/24/30
--------------------------------------------------------

JingJiView = JingJiView or BaseClass(ActBaseView)

local AwardCellRender = BaseClass(BaseRender)

function JingJiView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function JingJiView:__delete()
	if nil ~= self.gear_list then
		self.gear_list:DeleteMe()
		self.gear_list = nil
	end

	if nil ~= self.award_list then
		for i,v in ipairs(self.award_list) do
			v:DeleteMe()
		end
		self.award_list = nil
	end

	self.first_role_head = nil
end

-- 初始化视图
function JingJiView:InitView()
	if nil == self.tree.node then return end

	self:CreateGridScroll()
	self:CreateAwardList()
end

-- 注册通用点击事件
function JingJiView:AddActCommonClickEventListener()

end

-- 视图关闭回调
function JingJiView:CloseCallback() 
end

-- 选中当前视图回调
function JingJiView:ShowIndexView()
end

-- 切换当前视图回调
function JingJiView:SwitchIndexView()
end

-- 刷新当前视图
function JingJiView:RefreshView(param_list)
	if nil == self.tree.node then return end

	for k,v in pairs(param_list) do
		if k == "flush_view" then
			self:FlushView()
		end
	end
end

----------------------------------------
-- 视图函数
----------------------------------------

function JingJiView:FlushView()
	local data_list = ActivityBrilliantData.Instance:GetJingJiGearList(self.act_id, true) -- true 表示要排序
	self.gear_list:SetDataList(data_list)
	self.gear_list:JumpToTop()

	local data = ActivityBrilliantData.Instance or {} 
	local my_ranking = data.mine_rank and  data.mine_rank[self.act_id] or Language.RankingList.MyRanking -- 未上榜
	self.node_t_list["lbl_my_ranking"].node:setString(my_ranking)

	local ranking_list = ActivityBrilliantData.Instance:GetJingJiRankingList(self.act_id)
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id)
	local cfg = act_cfg.config or {}
	local rank_awards = cfg.rank_awards or {}
	for i = 1, 3 do -- 显示前三档
		local cur_rank_awards = rank_awards[i] or {}
		local rank_count = cur_rank_awards.rank_count or 0
		if rank_count == 1 then -- 前三名的显示
			local text = ranking_list[i] and ranking_list[i][2] or Language.Common.XuWenYiDai -- 虚位以待
			self.node_t_list["lbl_role_name_" .. i].node:setString(text)
			self.node_t_list["img_bg_" .. i].node:setVisible(true)
		elseif rank_count > 1 then -- 前三档的显示 未处理
			local text = ""
			self.node_t_list["lbl_role_name_" .. i].node:setString(text)
		else -- 配置异常
			local text = ""
			self.node_t_list["lbl_role_name_" .. i].node:setString(text)
			self.node_t_list["img_bg_" .. i].node:setVisible(false)
		end
	end

	-- [1]排名 [2]玩家名 [3]值 [4]玩家角色ID [5]玩家职业 [6]玩家性别
	local first_data = ranking_list[1] -- 第一名的数据
	if type(first_data) == "table" then
		local prof = first_data[5]	 -- 职业
		local is_big = false 		 -- 小头像
		local sex = first_data[6]	 -- 性别
		local path = AvatarManager.GetDefAvatar(prof, is_big, sex)
		if self.first_role_head then
			self.first_role_head:loadTexture(path)
		else
			local x, y = self.node_t_list["img_head_portrait"].node:getPosition()
			self.first_role_head = XUI.CreateImageView(x, y + 10, path, XUI.IS_PLIST)
			self.tree.node:addChild(self.first_role_head, 20)
		end
	else
		if self.first_role_head then
			self.first_role_head:setVisible(false)
		end
	end
end


function JingJiView:CreateGridScroll()
	local ph = self.ph_list["ph_gear_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = self.ph_list["ph_gear_item"] or {x = 0, y = 0, w = 1, h = 1,}
	local parent = self.tree.node
	local line_dis = ph_item.h + 2
	local direction = ScrollDir.Vertical -- 滑动方向
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, self.GearAwardRender, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.gear_list = grid_scroll
end

function JingJiView:CreateAwardList()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id)
	local cfg = act_cfg.config or {}
	local rank_awards = cfg.rank_awards or {}

	self.award_list = {}
	for i = 1, 3 do -- 显示前三档
		local ph = self.ph_list["ph_award_list_" .. i] or {x = 0, y = 0, w = 1, h = 1,}
		local ph_item = {x = 0, y = 0, w = 64, h = 64,}
		local parent = self.tree.node
		local item_render = AwardCellRender
		local line_dis = ph_item.w
		local direction = ScrollDir.Horizontal -- 滑动方向-横向
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, item_render, direction, false, ph_item)
		parent:addChild(grid_scroll:GetView(), 99)
		self.award_list[i] = grid_scroll
		
		local data_list = rank_awards[i] and rank_awards[i].awards or {}
		grid_scroll:SetDataList(data_list)

		grid_scroll:SetCenter()
	end
end

----------------------------------------
-- 档位奖励渲染
----------------------------------------
JingJiView.GearAwardRender = BaseClass(BaseRender)
local GearAwardRender = JingJiView.GearAwardRender

function GearAwardRender:__init()
	self.award_list = nil
end

function GearAwardRender:__delete()
	if self.award_list then
		self.award_list:DeleteMe()
		self.award_list = nil
	end
end

function GearAwardRender:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list["ph_award_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = {x = 0, y = 0, w = 64, h = 64,}
	local parent = self.view
	local item_render = AwardCellRender
	local line_dis = ph_item.w
	local direction = ScrollDir.Horizontal -- 滑动方向-横向
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, item_render, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 3)
	self.award_list = grid_scroll

	-- 不换行
	self.node_tree["rich_conditions"].node:setIgnoreSize(true)

	XUI.AddClickEventListener(self.node_tree["btn_get"].node, BindTool.Bind(self.OnBtnGet, self))
end

function GearAwardRender:OnFlush()
	if nil == self.data then return end
	local cfg = self.data.cfg or {}
	local awards = cfg.awards or {}
	self.award_list:SetDataList(awards)

	self.node_tree["img_stamp"].node:setVisible(self.data.sign == 1)

	-- 档位名额
	local receive_count = self.data.receive_count or 0
	local max_count = cfg.count or 0
	local left_count = max_count - receive_count
	local color = left_count > 0 and COLOR3B.GREEN or COLOR3B.RED
	-- 例 "名额：20份"
	local text = string.format(Language.ActivityBrilliant.Text31, left_count)
	self.node_tree["lbl_count"].node:setString(text)
	self.node_tree["lbl_count"].node:setColor(color)

	------------ 档位条件 ------------
	local act_id = self.data.act_id or 0
	local condition_1 = self.data.condition_1 or 0
	local condition_2 = self.data.condition_2 or 0
	local cfg_value1, cfg_value2, cfg_value = ActivityBrilliantData.GetJingJiGearValue(act_id, cfg)
	local conditions_text = ""
	local jingji_unit = Language.ActivityBrilliant.JingJiUnit[act_id] or {"%s%s", "%s"} -- 活动条件的单位
	if cfg_value2 > 0 then -- 不显示0转
		-- 例 "[3转]"
		conditions_text = string.format(jingji_unit[2], cfg_value2)
	end
	if cfg_value1 > 0 then -- 不显示0级
		-- 例 "[3转]100级" or "100级"
		local value = 0
		if cfg_value1 >= 10000 then
			value = math.floor(cfg_value1 / 10000) .. Language.Common.Wan
		else
			value = cfg_value1
		end
		conditions_text = string.format(jingji_unit[1], conditions_text, value)
	end
	if jingji_unit[3] then
		-- 例 "9阶5星翅膀"
		conditions_text = conditions_text .. jingji_unit[3]
	end

	local achieve = false
	if cfg_value and self.data.condition then
		achieve = self.data.condition >= cfg_value
	else
		achieve = condition_1 >= cfg_value1 and condition_2 >= cfg_value2 -- 已达标
	end

	local color = achieve and COLORSTR.GREEN or COLORSTR.RED
	local show_cfg_value = cfg_value2 > 0 and cfg_value2 or cfg_value1
	local show_attr_value = cfg_value2 > 0 and condition_2 or condition_1
	if show_cfg_value >= 10000 then
		show_cfg_value = math.floor(show_cfg_value / 10000) .. Language.Common.Wan
	end
	if show_attr_value >= 10000 then
		show_attr_value = math.floor(show_attr_value / 10000) .. Language.Common.Wan
	end
	-- 例 "达到[3转]100级可领取(0/3)"
	local text = string.format(Language.ActivityBrilliant.Text32, COLORSTR.GREEN, conditions_text, color, show_attr_value, show_cfg_value)
	local rich = self.node_tree["rich_conditions"].node
	rich = RichTextUtil.ParseRichText(rich, text, 18, Str2C3b("f9ec7d"))
	rich:refreshView()
	------------档位条件end------------

	-- 领取按钮处理
	local btn_get = self.node_tree["btn_get"].node
	if self.data.sign == 0 then
		-- "领取" or "未达成"
		local title_text = achieve and Language.Common.LingQu or Language.Common.WeiDaCheng
		-- "已领完"
		title_text = left_count > 0 and title_text or Language.Common.YiLingWan
		btn_get:setTitleText(title_text)
		btn_get:setEnabled(left_count > 0 and achieve)
		btn_get:setVisible(true)

		-- 红点提示 不用显示时,不创建
		if left_count > 0 and achieve and nil == btn_get.UpdateReimd then
			XUI.AddRemingTip(btn_get)
		end
		if btn_get.UpdateReimd then
			btn_get:UpdateReimd(left_count > 0 and achieve)
		end
	else
		btn_get:setVisible(false)
	end
end

function GearAwardRender:OnBtnGet()
	local act_id = self.data.act_id or 0
	local index = self.data.index or 0
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, index)
end

function GearAwardRender:CreateSelectEffect()
	return
end

function GearAwardRender:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end

----------------------------------------
-- 项目渲染命名
----------------------------------------
function AwardCellRender:__init()
	self.cell = nil
end

function AwardCellRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function AwardCellRender:CreateChild()
	BaseRender.CreateChild(self)

	local cell = ActBaseCell.New()
	cell:GetView():setScale(0.8)
	self.view:addChild(cell:GetView())
	self.cell = cell
end

function AwardCellRender:OnFlush()
	if nil == self.data then return end

	self.cell:SetData(ItemData.InitItemDataByCfg(self.data))
end

function AwardCellRender:CreateSelectEffect()
	return
end

function AwardCellRender:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end
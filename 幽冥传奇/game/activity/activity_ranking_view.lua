--------------------------------------------------------
-- 日常任务积分榜 (阵营战 世界boss 行会boss)
--------------------------------------------------------

ActivityRankingView = ActivityRankingView or BaseClass(BaseView)

function ActivityRankingView:__init()
	self.texture_path_list[1] = 'res/xui/activity.png'
	self.config_tab = {
		{"act_ranking_ui_cfg", 1, {0}}
	}
end

function ActivityRankingView:__delete()

end

--释放回调
function ActivityRankingView:ReleaseCallBack()
	if nil ~= self.act_ranking_list then
		self.act_ranking_list:DeleteMe()
		self.act_ranking_list = nil
	end

	self.rich_my_score = nil
end

--加载回调
function ActivityRankingView:LoadCallBack(index, loaded_times)
	self:CreateRankingView()

	local right_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local w, h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

----------更换父节点----------
	local node = self.real_root_node
	node:retain()
	node:removeFromParent()
	node:setParent(nil)
	right_top:TextLayout():addChild(node)
	node:release()
-------------end--------------
	local size = self.node_t_list["layout_act_ranking"].node:getContentSize()

	self.root_node:setPosition(w - size.width - 252, h - size.height - 165)
	self.root_node:setAnchorPoint(0, 0)

	EventProxy.New(ActivityData.Instance, self):AddEventListener(ActivityData.RANKING_DATA_CHANGE, BindTool.Bind(self.OnRankingDataChange, self))
	EventProxy.New(ActivityData.Instance, self):AddEventListener(ActivityData.MY_SCORE_CHANGE, BindTool.Bind(self.OnMyScoreChange, self))
end

function ActivityRankingView:OpenCallBack()
end

function ActivityRankingView:CloseCallBack()
end

--显示指数回调
function ActivityRankingView:ShowIndexCallBack(index)
	self:FlushView()
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChangeComplete, self))
end

function ActivityRankingView:FlushView()
	local data = ActivityData.Instance:GetRankingData()
	local my_score = data.my_score or 0
	local act_id = ActivityData.Instance:GetActivityID() or DAILY_ACTIVITY_TYPE.SHI_JIE_BOSS
	if act_id == DAILY_ACTIVITY_TYPE.HANG_HUI_BOSS then
		local guide_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID)
		for i,v in ipairs(data.rakning_list or {}) do
			if guide_id == v.id then
				my_score = v.score or 0
			end
		end
	end
	local node = self.rich_my_score or self.node_t_list["rich_my_score"].node
	my_score = MainuiHeadBar.FormatMonsterVal(my_score)
	local text = string.format(Language.Activity.MyScore[act_id], my_score)

	node = RichTextUtil.ParseRichText(node, text, 17, COLOR3B.GREEN)
	XUI.RichTextSetCenter(node)
	self.rich_my_score = node

	self.act_ranking_list:SetDataList(data.rakning_list)
end
----------视图函数----------

-- 创建"积分榜"视图
function ActivityRankingView:CreateRankingView()
	local ph_item = self.ph_list["ph_ranking_item"]
	local ph = self.ph_list["ph_ranking_list"]
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h + 1, self.RankingItem, ScrollDir.Vertical, false, ph_item)
	-- grid_scroll:GetView():setAnchorPoint(0.5, 0.5)
	self.node_t_list["layout_act_ranking"].node:addChild(grid_scroll:GetView(), 20)
	self.act_ranking_list = grid_scroll
end

----------end----------

function ActivityRankingView:OnRankingDataChange()
	self:FlushView()
end

function ActivityRankingView:OnSceneChangeComplete()
	local boor = false
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local scene_id = main_role_vo.scene_id
	if StdActivityCfg[DAILY_ACTIVITY_TYPE.ZHEN_YING].sceneId == scene_id then return end

	if nil ~= self.scene_change then
		GlobalEventSystem:UnBind(self.scene_change)
		self.scene_change = nil
	end
	ViewManager.Instance:CloseViewByDef(ViewDef.ActRanking)
	GlobalEventSystem:FireNextFrame(MainUIEventType.SET_TIPS_UI_VIS, true)
end

function ActivityRankingView:OnMyScoreChange()
	local act_id = ActivityData.Instance:GetActivityID() or DAILY_ACTIVITY_TYPE.SHI_JIE_BOSS
	local my_score = ActivityData.Instance:GetWorldBossMyScore()
	my_score = MainuiHeadBar.FormatMonsterVal(my_score)

	local node = self.rich_my_score or self.node_t_list["rich_my_score"].node
	local text = string.format(Language.Activity.MyScore[act_id], my_score)

	node = RichTextUtil.ParseRichText(node, text, 17, COLOR3B.GREEN)
	XUI.RichTextSetCenter(node)
	self.rich_my_score = node
end

--------------------

----------------------------------------
-- 积分榜项目渲染
----------------------------------------
ActivityRankingView.RankingItem = ActivityRankingView.RankingItem or BaseClass(BaseRender)
local RankingItem = ActivityRankingView.RankingItem
function RankingItem:__init()
end

function RankingItem:__delete()
	self.rich_ranking_item = nil
end

function RankingItem:CreateChild()
	BaseRender.CreateChild(self)
end

function RankingItem:OnFlush()
	if nil == self.data then return end

	self:FlushItemText()
end

function RankingItem:FlushItemText()
	local node = self.rich_ranking_item or self.node_tree["rich_ranking_item"].node
	local name = self.data.name or ""
	local score = self.data.score or 0
	score = MainuiHeadBar.FormatMonsterVal(score)
	local text = string.format(Language.Activity.Ranking, name, score)

	local order = tostring(self.index)
	local order_text = ""
	for num in string.gmatch(order, "%d") do
		order_text = order_text .. string.format("{image;res/xui/common/num_100_%d.png;}", num)
	end
	text = order_text.. "  " .. text
	node = RichTextUtil.ParseRichText(node, text, 17, COLOR3B.OLIVE)
	XUI.RichTextSetCenter(node)
	self.rich_ranking_item = node
end

function RankingItem:CreateSelectEffect()
	return
end

function RankingItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end

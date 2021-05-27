MainuiSmallParts = MainuiSmallParts or BaseClass()
local ReXueBossGuideRender = BaseClass(BaseRender)

function MainuiSmallParts:ClearReXueBossGuid()
	self.ph_item_ui = nil
end

function MainuiSmallParts:FlushReXueBoss()
	if nil == self.ph_item_ui then
		self.ph_item_ui = {}
		for k, v in pairs(ConfigManager.Instance:GetUiConfig("main_ui_cfg")) do
			if v.n == "layout_other_guide" then
				XUI.ParsePh(v, self.ph_item_ui)
				break
			end
		end

	end


	local ph = self.ph_item_ui.ph_rexue_boss_guide_item
	local is_in_rexue_boss_scene = Scene.Instance:GetSceneId() == ReXueBaZheBossCfg.boss.sceneid
	-- self.task_ui_node_list.layout_task.node:setVisible(not is_in_rexue_boss_scene)
	if not is_in_rexue_boss_scene and self.rexue_boss_guide_render then
		self.rexue_boss_guide_render:DeleteMe()
		NodeCleaner.Instance:AddNode(self.rexue_boss_guide_render:GetView())
		self.rexue_boss_guide_render = nil
	elseif is_in_rexue_boss_scene and nil == self.rexue_boss_guide_render then
		self.rexue_boss_guide_render = ReXueBossGuideRender.New()
		self.rexue_boss_guide_render:SetUiConfig(ph, true)
		self.rexue_boss_guide_render:SetPosition(10, 210)
		-- self.rexue_boss_guide_render:SetData(ExperimentData.Instance:GetBaseInfo())
		self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.LEFT_TOP):TextureLayout():addChild(self.rexue_boss_guide_render:GetView())
	end
end

function ReXueBossGuideRender:__init()
	--挖矿信息改变
	self.change_call = NewlyBossData.Instance:AddEventListener(NewlyBossData.RX_BOSS_RANK_LIST_CHANGE, function (data)
		self.rank_list:SetData(data)
	end)

	--挖矿信息改变
	self.change_call2 = NewlyBossData.Instance:AddEventListener(NewlyBossData.RX_BOSS_SELF_RANK_CHANGE, function ()
		-- self.rank_list:SetData(data)

		self.node_tree.lbl_myrank.node:setString(NewlyBossData.Instance:GetReXueBossInfo().rank)
		self.node_tree.lbl_myscore.node:setString(NewlyBossData.Instance:GetReXueBossInfo().score)
	end)
end

function ReXueBossGuideRender:__delete()
	if nil ~= self.rank_list then
		self.rank_list:DeleteMe()
		self.rank_list = nil
	end
	NewlyBossData.Instance:RemoveEventListener(self.change_call)
	NewlyBossData.Instance:RemoveEventListener(self.change_call2)
	self.change_call = nil
end

function ReXueBossGuideRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_exit.node, function ()
		Scene.SendTransmitSceneReq(2, 42, 54)
	end)

	XUI.AddClickEventListener(self.node_tree.btn_reward_view.node, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.ReXueBossRank)
	end)

	XUI.AddClickEventListener(self.node_tree.btn_help.node, function ()
		DescTip.Instance:SetContent(Language.DescTip.ReXueRankContent, Language.DescTip.ReXueRankTitle)
	end)
	self:CreateList()

	self.node_tree.lbl_myrank.node:setString(NewlyBossData.Instance:GetReXueBossInfo().rank)
	self.node_tree.lbl_myscore.node:setString(NewlyBossData.Instance:GetReXueBossInfo().score)
end


function ReXueBossGuideRender:CreateList()
	local ph = self.ph_list.ph_list
	self.rank_list = ListView.New()
	self.rank_list:Create(ph.x, ph.y, ph.w, ph.h, direction, RexueRankRecordRender, nil, false, self.ph_list.ph_item)
	self.rank_list:SetItemsInterval(3)
	self.rank_list:SetJumpDirection(ListView.Top)
	-- self.rank_list:SetSelectCallBack(BindTool.Bind(self.SelectActivityTypeCallback, self))
	self.view:addChild(self.rank_list:GetView(), 100)
	self.rank_list:SetData(NewlyBossData.Instance:GetReXueBossRankList())
end

-- 创建选中特效
function ReXueBossGuideRender:CreateSelectEffect()
end

function ReXueBossGuideRender:OnFlush()
	if nil == self.data then
		return
	end
end

RexueRankRecordRender = RexueRankRecordRender or BaseClass(BaseRender)
function RexueRankRecordRender:__init()	
	
end

function RexueRankRecordRender:__delete()	
end

function RexueRankRecordRender:CreateChild()
	BaseRender.CreateChild(self)
end

local idx2color = {COLOR3B.YELLOW, COLOR3B.PURPLE, COLOR3B.BLUE}
function RexueRankRecordRender:OnFlush()
	if self.data == nil then return end
	local color = idx2color[self:GetIndex()] or COLOR3B.WHITE
	self.node_tree.lbl_rank.node:setColor(color)
	self.node_tree.lbl_name.node:setColor(color)
	self.node_tree.lbl_score.node:setColor(color)

	self.node_tree.lbl_rank.node:setString(self.data.rank)
	self.node_tree.lbl_name.node:setString(self.data.name)
	self.node_tree.lbl_score.node:setString(self.data.score)
end

function RexueRankRecordRender:CreateSelectEffect()
end
--跨服联盟奖励面板
CrossUnionFightAwarView = CrossUnionFightAwarView or BaseClass(XuiBaseView)

function CrossUnionFightAwarView:__init()
	self:SetModal(true)
	--self.texture_path_list[1] = "res/xui/activity.png"
	self.config_tab = {
		{"cross_union_fight_ui_cfg", 2, {0}},
	}
end

function CrossUnionFightAwarView:__delete()

end

function CrossUnionFightAwarView:ReleaseCallBack()
	if self.award_list then
		self.award_list:DeleteMe()
		self.award_list = nil
	end

	if self.team_awar_cells_list then
		for k, v in pairs(self.team_awar_cells_list) do
			v:DeleteMe()
		end
		self.team_awar_cells_list = {}
	end

end

function CrossUnionFightAwarView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		self:CreateAwarList()
		-- XUI.AddClickEventListener(self.node_t_list.btn_get_reward1.node, BindTool.Bind1(self.OnGetReward, self))
		XUI.AddClickEventListener(self.node_t_list.btn_get_reward2.node, BindTool.Bind1(self.OnGetReward, self))
	end
end

function CrossUnionFightAwarView:OpenCallBack()
	 MagicCityCtrl.Instance:HeroesFightAwarDataReq()
end

function CrossUnionFightAwarView:ShowIndexCallBack(index)
	self:Flush(index)
end

function CrossUnionFightAwarView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CrossUnionFightAwarView:OnFlush(param_list, index)
	if self.award_list then
		local personal_awar_data, team_awar_data =  MagicCityData.Instance:GetHeroesFightAwarData()
		self.award_list:SetData(personal_awar_data)
		self.node_t_list.my_team_score.node:setString(team_awar_data.score)
		self.node_t_list.btn_get_reward2.node:setEnabled(team_awar_data.fetch_state == 1)
		for i = 1, 3 do
			self.team_awar_cells_list[i]:GetView():setVisible(false)
		end

		for k, v in ipairs(team_awar_data.awards) do
			local data = {item_id = v.id, num = v.count, is_bind = v.bind}
			if v.type > 0 then
				data.item_id = ItemData.Instance:GetVirtualItemId(v.type)
				if ItemData.Instance:CalcuSpecialExpVal(v) then
					data.num = ItemData.Instance:CalcuSpecialExpVal(v)
				end
			end
			if self.team_awar_cells_list[k] then
				self.team_awar_cells_list[k]:GetView():setVisible(true)
				self.team_awar_cells_list[k]:SetData(data)
			end
		end
	end
end

function CrossUnionFightAwarView:CreateAwarList()
	if not self.award_list then
		local ph = self.ph_list.ph_ranking_list
		self.award_list = ListView.New()
		self.award_list:Create(ph.x, ph.y, ph.w, ph.h, nil, HeroesFightAwarRender, nil, nil, self.ph_list.ph_rankinglist_item)
		self.award_list:GetView():setAnchorPoint(0, 0)
		self.award_list:SetMargin(2)
		self.award_list:SetItemsInterval(9)
		self.award_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_heroes_award.node:addChild(self.award_list:GetView(), 100)
	end

	self.team_awar_cells_list = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_award" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_heroes_award.node:addChild(cell:GetView(), 100)
		self.team_awar_cells_list[i] = cell
	end
end

function CrossUnionFightAwarView:OnGetReward()	
	MagicCityCtrl.Instance:HeroesFightGetAwarReq(2)
end

HeroesFightAwarRender = HeroesFightAwarRender or BaseClass(BaseRender)
function HeroesFightAwarRender:__init()
	self.cells_list = {}
	self.cells_view_container = nil
end

function HeroesFightAwarRender:__delete()
	for k, v in pairs(self.cells_list) do
		v:DeleteMe()
	end
	self.cells_list = {}
	self.cells_view_container:removeFromParent()
	self.cells_view_container = nil	
end

function HeroesFightAwarRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateCellsContainer()
	-- self.property_inspector_layout = XUI.CreateLayout(20, 30, 400, 40)
	-- self.view:addChild(self.property_inspector_layout, 200)
	XUI.AddClickEventListener(self.node_tree.btn_get_reward1.node, BindTool.Bind1(self.OnFetchAwar, self))
	-- self:AddClickEventListener(BindTool.Bind1(self.OnClickTipsHandler, self))
	if self.index <= 3 then
		self.img_bg = XUI.CreateImageView(66, 45, ResPath.GetCommon("stage_"..self.index),true)
		self.view:addChild(self.img_bg, 100)
	end
end

function HeroesFightAwarRender:OnFlush()
	if self.data == nil then return end
	if self.index > 3 then
		local stage_str = string.format(Language.DesertKillGod.StageStr, Language.DesertKillGod.ChnNum[self.index])
		self.node_tree.txt_stage.node:setString(stage_str)
	end
	local path = "img9_158"
	if self.index % 2 == 0 then
		path = "img9_200"
	end
	self.node_tree.img9_bg.node:loadTexture(ResPath.GetCommon(path))
	local rank_str = ""
	if self.data.condition[1] == self.data.condition[2] then
		rank_str = string.format(Language.DesertKillGod.RankStr[1], self.data.condition[1])
	else	
		rank_str = string.format(Language.DesertKillGod.RankStr[2], self.data.condition[1], self.data.condition[2])
	end
	self.node_tree.txt_rank.node:setString(rank_str)
	self.node_tree.btn_get_reward1.node:setVisible(self.data.fetch_state == 1)
	local txt = ""
	if self.data.fetch_state == 0 then
		txt = Language.MagicCity.AwarFetchTxts[1]
	elseif self.data.fetch_state == 2 then
		txt = Language.MagicCity.AwarFetchTxts[2]
	end
	self.node_tree.txt_awar_fetch_tip.node:setString(txt)
	self:SetAwardCells(self.data.awards)
end

function HeroesFightAwarRender:CreateCellsContainer()
	if not self.cells_view_container then
		local ph = self.ph_list.ph_cells_container
		self.cells_view_container = XLayout:create(0, 80)
		self.cells_view_container:setAnchorPoint(0.5, 0)
		self.cells_view_container:setPosition(ph.x, ph.y)
		self.view:addChild(self.cells_view_container, 100)
	end
end

function HeroesFightAwarRender:SetAwardCells(awards_data)
	if not awards_data or not next(awards_data) then return end

	local gap = 2
	local award_cnt = #awards_data
	local need_width = (80 * award_cnt) + (award_cnt - 1) * gap
	self.cells_view_container:setContentWH(need_width, 80)
	-- 多余的删除掉
	if #self.cells_list > award_cnt then
		local no_need_cnt = #self.cells_list - award_cnt
		for i = 1, no_need_cnt do
			local cell = table.remove(self.cells_list, #self.cells_list)
			if cell then
				cell:GetView():removeFromParent()
				cell:DeleteMe()
			end
		end
	end

	for i, v in ipairs(awards_data) do
		local awar = {
							item_id = v.id,
							num = v.count,
							is_bind = v.bind,
						}
		--虚拟物品
		if v.type > 0 then
			awar.item_id = ItemData.Instance:GetVirtualItemId(v.type)
			if ItemData.Instance:CalcuSpecialExpVal(v) then
				awar.num = ItemData.Instance:CalcuSpecialExpVal(v)
			end
		end
		if not self.cells_list[i] then
			local cell = BaseCell.New()
			cell:SetPosition((i - 1) * (80 + gap), 0)
			cell:SetData(awar)
			self.cells_view_container:addChild(cell:GetView(), 100)
			self.cells_list[i] = cell
		else
			local cell = self.cells_list[i]
			cell:GetView():setPositionX((i - 1) * (80 + gap))
			cell:SetData(awar)
		end
	end
end

function HeroesFightAwarRender:OnFetchAwar()
	MagicCityCtrl.Instance:HeroesFightGetAwarReq(1)
end

-- 创建选中特效
function HeroesFightAwarRender:CreateSelectEffect()

end
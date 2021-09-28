
ElementBattleFightView = ElementBattleFightView or BaseClass(BaseView)

function ElementBattleFightView:__init()
	self.ui_config = {"uis/views/elementbattle_prefab","ElementBattleFightView"}
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.active_close = false
	self.fight_info_view = true
end

function ElementBattleFightView:__delete()

end

function ElementBattleFightView:LoadCallBack()
	self.score_info = ElementScoreInfoView.New(self:FindObj("ScorePerson"))
	self.score_rank = ElementRankView.New(self:FindObj("ScoreRank"))
	self.ShowPanel = self:FindVariable("ShowPanel")--隐藏任务面板
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.MianUIOpenComlete, self))
	if self.show_or_hide_other_button == nil then
		self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonStates, self))
	end
end

function ElementBattleFightView:ReleaseCallBack()
	if self.score_info then
		self.score_info:DeleteMe()
		self.score_info = nil
	end
	if self.score_rank then
		self.score_rank:DeleteMe()
		self.score_rank = nil
	end
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	self.ShowPanel = nil
end

function ElementBattleFightView:OpenCallBack()
	MainUICtrl.Instance.view:SetViewState(false)

	self:Flush()
end

function ElementBattleFightView:CloseCallBack()
	MainUICtrl.Instance.view:SetViewState(true)
end

function ElementBattleFightView:MianUIOpenComlete()
	MainUICtrl.Instance.view:SetViewState(false)
	self:Flush()
end

function ElementBattleFightView:SwitchButtonStates(enable)
	self.ShowPanel:SetValue(enable)
end

function ElementBattleFightView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "rank" then
			self.score_rank:Flush()
		elseif k == "info" then
			self.score_info:Flush()
		else
			self.score_rank:Flush()
			self.score_info:Flush()
		end
	end
end

----------------------任务View----------------------
ElementScoreInfoView = ElementScoreInfoView or BaseClass(BaseRender)
function ElementScoreInfoView:__init()
	self.kill = self:FindVariable("Kill")
	self.my_score = self:FindVariable("MyScore")
	self.reward = self:FindVariable("Reward")
	self.score_1 = self:FindVariable("Score1")
	self.score_2 = self:FindVariable("Score2")
	self.score_3 = self:FindVariable("Score3")
	self.color_1 = self:FindVariable("Color1")
	self.color_2 = self:FindVariable("Color2")
	self.color_3 = self:FindVariable("Color3")
	self.camp_1 = self:FindVariable("Camp1")
	self.camp_2 = self:FindVariable("Camp2")
	self.camp_3 = self:FindVariable("Camp3")
	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New(self:FindObj("Reward" .. i))
	end

	self:Flush()
end

function ElementScoreInfoView:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function ElementScoreInfoView:Flush()
	local baseinfo = ElementBattleData.Instance:GetBaseInfo()
	self.kill:SetValue(baseinfo.kills or 0)
	local rolejifen = ElementBattleData.Instance:GetRoleScore()
	self.my_score:SetValue(rolejifen)
	local nextconfig = ElementBattleData.Instance:GetNextHonorForScore(rolejifen)
	if nextconfig then
		self.reward:SetValue(string.format(Language.Activity.JiFenToRongYu, nextconfig.need_score_min))
		for k,v in pairs(self.reward_list) do
			v.root_node:SetActive(nextconfig.reward_item[k - 1] ~= nil)
			v:SetData(nextconfig.reward_item[k - 1])
		end
	end
	local sideinfo = ElementBattleData.Instance:GetSideInfo()
	if sideinfo.scores then
		for k,v in pairs(sideinfo.scores) do
			if self["score_" .. k] then
				self["score_" .. k]:SetValue(v.score)
				self["color_" .. k]:SetValue(CAMP_COLOR[v.side + 1])
				self["camp_" .. k]:SetValue(Language.ElementBattleSideName[v.side])
			end
		end
	end
end

----------------------积分View----------------------
ElementRankView = ElementRankView or BaseClass(BaseRender)
function ElementRankView:__init()
	-- 获取控件
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t = {}
	self:Flush()
end

function ElementRankView:__delete()
	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function ElementRankView:BagGetNumberOfCells()
	local data_list = ElementBattleData.Instance:GetRankList() or {}
	return math.max(#data_list, 8)
end

function ElementRankView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = ElementRankItem.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	local data_list = ElementBattleData.Instance:GetRankList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	else
		item:SetData({name = "--", score = "--"})
	end
end

function ElementRankView:Flush()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

ElementRankItem = ElementRankItem or BaseClass(BaseRender)

function ElementRankItem:__init()
	self.rank = self:FindVariable("Rank")
	self.name = self:FindVariable("Name")
	self.score = self:FindVariable("Score")
end

function ElementRankItem:SetIndex(index)
	self.rank:SetValue(index)
end

function ElementRankItem:SetData(data)
	self.data = data
	self:Flush()
end

function ElementRankItem:Flush()
	if nil == self.data then
		return
	end
	self.name:SetValue(self.data.name)
	self.score:SetValue(self.data.score)
end

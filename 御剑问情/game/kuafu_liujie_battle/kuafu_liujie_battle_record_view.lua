KuafuGuildBattleRecordView = KuafuGuildBattleRecordView or BaseClass(BaseView)

SCENE_ID = {
	[1] = 1450,
	[2] = 1460,
	[3] = 1461,
	[4] = 1462,
	[5] = 1463,
	[6] = 1464,
}

function KuafuGuildBattleRecordView:__init()
	self.ui_config = {"uis/views/kuafuliujie_prefab","GuildBattleRecord"}

	self.cur_index = 1
	self.type_list_view = nil
	self.item_listview_list = nil
	self.def_index = 1
	self.rank_list_count = 0
	self.rank_list = {}
end

function KuafuGuildBattleRecordView:__delete()
end

function KuafuGuildBattleRecordView:ReleaseCallBack()
	for k,v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
	self.my_rank = nil
	self.my_guild = nil
	self.my_sever = nil
	self.my_score = nil
	self.list_view = nil
	self.toggle_list = nil
end

function KuafuGuildBattleRecordView:LoadCallBack()
	self.item_cell = {}
	self.my_rank = self:FindVariable("MyRank")
	self.my_guild = self:FindVariable("MyGUild")
	self.my_sever = self:FindVariable("SeverId")
	self.my_score = self:FindVariable("Score")
	self:CreateTypeList()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.Close,self))
end

function KuafuGuildBattleRecordView:OpenCallBack()
	self:SetToggle()
	self:Flush()
end

function KuafuGuildBattleRecordView:CreateTypeList()
	for i=1,6 do
		self:ListenEvent("OnClickRankType" .. i, BindTool.Bind(self.OnClickRankType, self, i))
	end
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function KuafuGuildBattleRecordView:SetToggle()
	self.toggle_list = {}
	for i=1, 6 do
		self.toggle_list[i] = self:FindObj("Toggle" .. i)
	end
	local local_scene_id = Scene.Instance:GetSceneId()
	for i=1, 6 do
		if  local_scene_id == SCENE_ID[i] then
			KuafuGuildBattleCtrl.Instance:OpenBattleRecordScene(SCENE_ID[i])
			self.toggle_list[i].toggle.isOn = true
			self.cur_index = i
			return
		end
	end
end

function KuafuGuildBattleRecordView:SetRankInfo()
	local data_list = KuafuGuildBattleData.Instance:GetBattleRankInfo()
	self.rank_list_count = data_list.rank_list_count
	self.rank_list = {}
	if next(data_list.rank_list) then
		for i,v in ipairs(data_list.rank_list) do
			local temp_list = {}
			temp_list.rank = i
			temp_list.server_id = v.server_id
			temp_list.get_score = v.score
			temp_list.guild_name = v.guild_name
			self.rank_list[i] = temp_list
		end
	end
end

function KuafuGuildBattleRecordView:GetNumberOfCells()
	return self.rank_list_count
end

function KuafuGuildBattleRecordView:RefreshCell(cell, data_index, cell_index)

	local item = self.item_cell[cell]
	if nil == item then
		item  = KuafuBattleRankItem.New(cell)
		self.item_cell[cell] = item
	end
	self.item_cell[cell]:SetIndex(cell_index)

	if self.rank_list and next(self.rank_list) then
		self.item_cell[cell]:SetData(self.rank_list[cell_index + 1])
	end
end

--点击排行榜回调
function KuafuGuildBattleRecordView:OnClickRankType(index)

	if nil == index then
		return
	end
	
	self.cur_index = index   -- list回调
	KuafuGuildBattleCtrl.Instance:OpenBattleRecordScene(SCENE_ID[self.cur_index])

	self:Flush()
end

function KuafuGuildBattleRecordView:GetSceneId()
	return SCENE_ID[self.cur_index] or 0
end

function KuafuGuildBattleRecordView:OnFlush()
	self:SetRankInfo()
	self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	self:MyGuildRank()
end

function KuafuGuildBattleRecordView:MyGuildRank()
	local cur_index = self.cur_index

	local myguild_name = GameVoManager.Instance:GetMainRoleVo().guild_name or ""
	local server_id = KuafuGuildBattleCtrl.Instance.server_id
	self.my_rank:SetValue(Language.Rank.NoInRank)
	self.my_sever:SetValue(server_id)
	self.my_score:SetValue(0)
	self.my_guild:SetValue(myguild_name)

	for i,v in ipairs(self.rank_list) do
		if myguild_name == v.guild_name then
			self.my_rank:SetValue(v.rank)
			self.my_sever:SetValue(server_id)
			self.my_score:SetValue(v.get_score)
			self.my_guild:SetValue(myguild_name)
		end
	end
end

----------------------------------------------------
-- 日志排行榜帮派item
----------------------------------------------------
KuafuBattleRankItem = KuafuBattleRankItem or BaseClass(BaseRender)
function KuafuBattleRankItem:__init()
	self.rank = self:FindVariable("Rank")
	self.server_id = self:FindVariable("ServerId")
	self.score = self:FindVariable("Score")
	self.guild_name = self:FindVariable("GuildName")
end

function KuafuBattleRankItem:__delete()

end

function KuafuBattleRankItem:OnFlush()
	if nil == self.data then return end

	self.rank:SetValue(self.data.rank)
	self.server_id:SetValue(self.data.server_id)
	self.score:SetValue(self.data.get_score)
	self.guild_name:SetValue(self.data.guild_name)
end

function KuafuBattleRankItem:FlushMmedal(rank)
	if rank <= 3 then
		self.medal:SetAsset(ResPath.GetRankResPath("rank_" .. rank))
	end
end

function KuafuBattleRankItem:SetIndex(index)
	self.index = index
end

function KuafuBattleRankItem:SetData(data)
	self.data = data
	self:Flush()
end
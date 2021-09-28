KuafuGuildRecordView = KuafuGuildRecordView or BaseClass(BaseView)

function KuafuGuildRecordView:__init()
	self.ui_config = {"uis/views/kuafuliujie_prefab","GuildRecord"}

	self.cur_index = 1
	self.type_list_view = nil
	self.item_listview_list = nil
	self.def_index = 1
end

function KuafuGuildRecordView:__delete()
end

function KuafuGuildRecordView:ReleaseCallBack()
	for k,v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
	self.my_rank = nil
	self.my_guild = nil
	self.my_sever = nil
	self.my_score = nil
	self.list_view = nil
end

function KuafuGuildRecordView:LoadCallBack()
	self.item_cell = {}
	self.my_rank = self:FindVariable("MyRank")
	self.my_guild = self:FindVariable("MyGUild")
	self.my_sever = self:FindVariable("SeverId")
	self.my_score = self:FindVariable("Score")
	self:CreateTypeList()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.Close,self))
end




function KuafuGuildRecordView:OpenCallBack()
	self:Flush()
end

function KuafuGuildRecordView:CreateTypeList()
	for i=1,6 do
		self:ListenEvent("OnClickRankType" .. i, BindTool.Bind(self.OnClickRankType, self, i))
	end
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function KuafuGuildRecordView:GetNumberOfCells()
	local data_list = KuafuGuildBattleData.Instance:GetGuildBattleRankInfoResp()
	if data_list and next(data_list) then
		return #data_list[self.cur_index]
	else
		return 0
	end
end

function KuafuGuildRecordView:RefreshCell(cell, data_index, cell_index)
	local data_list = KuafuGuildBattleData.Instance:GetGuildBattleRankInfoResp()
	local item = self.item_cell[cell]
	if nil == item then
		item  = KuafuRankRoleItem.New(cell)
		self.item_cell[cell] = item
	end
	self.item_cell[cell]:SetIndex(cell_index)
	if data_list and next(data_list) then
		self.item_cell[cell]:SetData(data_list[self.cur_index][cell_index + 1])
	end
end



--点击排行榜回调
function KuafuGuildRecordView:OnClickRankType(index)

	if nil == index then
		return
	end

	self.cur_index = index   -- list回调

	self:Flush()
end

function KuafuGuildRecordView:OnFlush()
	self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	self:MyGuildRank()
end

function KuafuGuildRecordView:MyGuildRank()
	local cur_index = self.cur_index

	local myguild_name = GameVoManager.Instance:GetMainRoleVo().guild_name or ""
	local server_id = KuafuGuildBattleCtrl.Instance.server_id
	self.my_rank:SetValue(Language.Rank.NoInRank)
	self.my_sever:SetValue(server_id)
	self.my_score:SetValue(0)
	local camp_color = CAMP_COLOR[0]
	self.my_guild:SetValue(myguild_name)

	local data_list = KuafuGuildBattleData.Instance:GetGuildBattleRankInfoResp()

	for i,v in ipairs(data_list) do
		if i == cur_index then
			for x,z in ipairs(v) do
				if myguild_name == z.guild_name then
					self.my_rank:SetValue(z.rank)
					self.my_sever:SetValue(server_id)
					self.my_score:SetValue(z.get_score)
					self.my_guild:SetValue(myguild_name)
				end
			end
		end
	end
end

----------------------------------------------------
-- 日志排行榜帮派item
----------------------------------------------------
KuafuRankRoleItem = KuafuRankRoleItem or BaseClass(BaseRender)
function KuafuRankRoleItem:__init()
	self.rank = self:FindVariable("Rank")
	self.server_id = self:FindVariable("ServerId")
	self.score = self:FindVariable("Score")
	self.guild_name = self:FindVariable("GuildName")
end

function KuafuRankRoleItem:__delete()

end

function KuafuRankRoleItem:OnFlush()
	if nil == self.data then return end

	self.rank:SetValue(self.data.rank)
	self.server_id:SetValue(self.data.server_id)
	self.score:SetValue(self.data.get_score)
	self.guild_name:SetValue(self.data.guild_name)
end

function KuafuRankRoleItem:FlushMmedal(rank)
	if rank <= 3 then
		self.medal:SetAsset(ResPath.GetRankResPath("rank_" .. rank))
	end
end

function KuafuRankRoleItem:SetIndex(index)
	self.index = index
end

function KuafuRankRoleItem:SetData(data)
	self.data = data
	self:Flush()
end
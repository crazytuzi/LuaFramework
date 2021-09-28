GodTempleRankView = GodTempleRankView or BaseClass(BaseView)

function GodTempleRankView:__init()
	self.ui_config = {"uis/views/godtemple_prefab", "PaTaRankView"}
	self.rank_list_change = BindTool.Bind(self.RankListChange, self)
end

function GodTempleRankView:__delete()
end

function GodTempleRankView:ReleaseCallBack()
	if self.my_rank_item then
		self.my_rank_item:DeleteMe()
		self.my_rank_item = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil

	self.rank = nil
	self.show_rank_img = nil
	self.rank_res = nil
	self.name = nil
	self.layer = nil
	self.list_view = nil
end

function GodTempleRankView:LoadCallBack()
	self.rank = self:FindVariable("rank")
	self.show_rank_img = self:FindVariable("show_rank_img")
	self.rank_res = self:FindVariable("rank_res")
	self.name = self:FindVariable("name")
	self.layer = self:FindVariable("layer")

	self.rank_data = {}
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local simple_delegate = self.list_view.list_simple_delegate
	simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCell, self)
	simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
end

function GodTempleRankView:OnClickClose()
	self:Close()
end

function GodTempleRankView:NumberOfCell()
	return #self.rank_data
end

function GodTempleRankView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local rank_cell = self.cell_list[cell]
	if rank_cell == nil then
		rank_cell = GodTempleRankItem.New(cell.gameObject)
		self.cell_list[cell] = rank_cell
	end

	rank_cell:SetIndex(data_index)
	rank_cell:SetData(self.rank_data[data_index])
end

function GodTempleRankView:OpenCallBack()
	--请求排行榜信息
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_GOD_TEMPLE)

	self.rank_list_event = GlobalEventSystem:Bind(OtherEventType.RANK_CHANGE, self.rank_list_change)
end

function GodTempleRankView:CloseCallBack()
	if self.rank_list_event then
		GlobalEventSystem:UnBind(self.rank_list_event)
		self.rank_list_event = nil
	end
end

function GodTempleRankView:FlushList()
	self.rank_data = GodTempleData.Instance:GetRankList()
	self.list_view.scroller:ReloadData(0)
end

function GodTempleRankView:FlushMyRank()
	local pass_layer = GodTemplePataData.Instance:GetPassLayer()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local is_set = false
	for k, v in ipairs(self.rank_data) do
		if main_vo.role_id == v.user_id then
			if k <= 3 then
				self.show_rank_img:SetValue(true)
				--前三名用特殊图片代替
				local bundle, asset = ResPath.GetRankNewIcon(k)
				self.rank_res:SetAsset(bundle, asset)
			else
				self.show_rank_img:SetValue(false)
				self.rank:SetValue(k)
			end

			is_set = true
			break
		end
	end

	if not is_set then
		self.show_rank_img:SetValue(false)
		self.rank:SetValue(Language.Common.NoRank)
	end

	self.name:SetValue(main_vo.name)
	self.layer:SetValue(pass_layer)
end

function GodTempleRankView:OnFlush()
	self:FlushList()
	self:FlushMyRank()
end

function GodTempleRankView:RankListChange(rank_type)
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_GOD_TEMPLE then
		self:Flush()
	end
end


GodTempleRankItem = GodTempleRankItem or BaseClass(BaseCell)
function GodTempleRankItem:__init()
	self.rank = self:FindVariable("rank")
	self.show_rank_img = self:FindVariable("show_rank_img")
	self.rank_res = self:FindVariable("rank_res")
	self.name = self:FindVariable("name")
	self.layer = self:FindVariable("layer")
end

function GodTempleRankItem:__delete()
	
end

function GodTempleRankItem:OnFlush()
	if self.data == nil then
		return
	end

	if self.index <= 3 then
		self.show_rank_img:SetValue(true)
		--前三名用特殊图片代替
		local bundle, asset = ResPath.GetRankNewIcon(self.index)
		self.rank_res:SetAsset(bundle, asset)
	else
		self.show_rank_img:SetValue(false)
		self.rank:SetValue(self.index)
	end

	self.name:SetValue(self.data.user_name)
	self.layer:SetValue(self.data.rank_value)
end
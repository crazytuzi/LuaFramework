ArenaTupoView = ArenaTupoView or BaseClass(BaseRender)

function ArenaTupoView:__init()
	self.maxhp = self:FindVariable("Hp")
	self.gongji = self:FindVariable("Gongji")
	self.fangyu = self:FindVariable("Fangyu")

	self.n_maxhp = self:FindVariable("HpN")
	self.n_gongji = self:FindVariable("GongjiN")
	self.n_fangyu = self:FindVariable("FangyuN")
	self.has_rank = self:FindVariable("HasRank")
	self.has_next_rank = self:FindVariable("HasNextRank")
	self.cur_cap = self:FindVariable("CurCap")
	self.next_cap = self:FindVariable("NextCap")
	self.can_up_grade = self:FindVariable("CanUpGrade")
	self.red_point = self:FindVariable("RedPoint")
	self.best_rank = self:FindVariable("BestRank")
	self.stuff = ItemCell.New()
	self.stuff_obj = self:FindObj("NeedItem")
	self.stuff:SetInstanceParent(self.stuff_obj)
	self.icon_list = {}
	PrefabPool.Instance:Load(AssetID("uis/views/arena_prefab", "ArenaTupoIcon"), function (prefab)
		if nil == prefab then
			return
		end
		for i = 1, 10 do
			local obj = GameObject.Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self:FindObj("Icon" .. i).transform, false)
			local item_cell = ArenaTupoIcon.New(obj)
			self.icon_list[i] = item_cell
			if i == 10 then
				self:Flush()
			end
		end
		PrefabPool.Instance:Free(prefab)
	end)
	self:ListenEvent("OnClickUp",
		BindTool.Bind(self.OnUpGrade, self))
end

function ArenaTupoView:__delete()
	for k,v in pairs(self.icon_list) do
		v:DeleteMe()
	end
	if self.stuff then
		self.stuff:DeleteMe()
		self.stuff = nil
	end
	self.icon_list = {}
end

function ArenaTupoView:OpenCallBack()
	self:Flush()
end

function ArenaTupoView:OnFlush()
	local data = ArenaData.Instance
	local cur_rank_cfg = data:GetHistoryRankCfg()
	local next_index = 1
	if cur_rank_cfg then
		next_index = cur_rank_cfg.index + 1
		self.maxhp:SetValue(cur_rank_cfg.maxhp)
		self.gongji:SetValue(cur_rank_cfg.gongji)
		self.fangyu:SetValue(cur_rank_cfg.fangyu or 0)
		self.cur_cap:SetValue(CommonDataManager.GetCapability(cur_rank_cfg))
	end
	local next_rank_cfg = data:GetHistoryRankCfg(next_index)
	if next_rank_cfg then
		self.n_maxhp:SetValue(next_rank_cfg.maxhp)
		self.n_gongji:SetValue(next_rank_cfg.gongji)
		self.n_fangyu:SetValue(next_rank_cfg.fangyu or 0)
		self.next_cap:SetValue(CommonDataManager.GetCapability(next_rank_cfg))
		local item_id = next_rank_cfg.reward_show and next_rank_cfg.reward_show[0].item_id or 0
		self.stuff:SetData({item_id = item_id, num = next_rank_cfg.reward_guanghui})
	else
		self.stuff.root_node:SetActive(false)
	end
	self.has_rank:SetValue(cur_rank_cfg ~= nil)
	self.has_next_rank:SetValue(next_rank_cfg ~= nil)
	for k,v in pairs(self.icon_list) do
		v:SetData(data:GetHistoryRankCfg(k))
	end
	local str = "<color=#00ff00>%d</color>"
	self.best_rank:SetValue(string.format(str, data:GetBestRank()))
	self.can_up_grade:SetValue(data:GetArenaTupoRemind() > 0)
	self.red_point:SetValue(data:GetArenaTupoRemind() > 0)
end

function ArenaTupoView:OnUpGrade()
	ArenaCtrl.SendChallengeFieldBestRankBreakReq(1)
end

ArenaTupoIcon = ArenaTupoIcon or BaseClass(BaseCell)
function ArenaTupoIcon:__init(instance)
	self.icon = self:FindVariable("Icon")
	self.level = self:FindVariable("Level")
	self.name = self:FindVariable("Name")
	self.is_gray = self:FindVariable("IsGray")
	self.is_select = self:FindVariable("IsSelect")
end

function ArenaTupoIcon:__delete()

end

function ArenaTupoIcon:OnFlush()
	if nil == self.data then return end
	local cur_index = ArenaData.Instance:GetBestRankIndex()
	self.icon:SetAsset("uis/views/arena/images_atlas", "tp_icon_" .. self.data.index)
	local str = self.data.best_rank_pos > 2 and Language.Field1v1.FormerRank or Language.Field1v1.FormerRank2
	self.level:SetValue(string.format(str, self.data.best_rank_pos + 1))
	self.name:SetValue(self.data.best_rank_name)
	self.is_gray:SetValue(self.data.index > cur_index)
	self.is_select:SetValue(self.data.index == cur_index)
end
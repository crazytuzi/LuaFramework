GodTemplePaTaView = GodTemplePaTaView or BaseClass(BaseRender)

function GodTemplePaTaView:__init()
	self.model = RoleModel.New("display_god_temple_pata_shenqi")
	self.model:SetDisplay(self:FindObj("model_display").ui3d_display)

	self.first_item_list = {}
	for i = 1, 2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("first_item_" .. i))
		item:SetSiblingIndex(0)
		table.insert(self.first_item_list, item)
	end

	self.day_item_list = {}
	for i = 1, 2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("day_item_" .. i))
		table.insert(self.day_item_list, item)
	end

	self.monster_cell_list = {}
	for i = 1, 3 do
		local cell_obj = GodTempleMonsterItem.New(self:FindObj("monster_cell_" .. i))
		cell_obj:SetClickCallBack(BindTool.Bind(self.OnClickMonster, self))
		table.insert(self.monster_cell_list, cell_obj)
	end

	self.best_name = self:FindVariable("best_name")
	self.have_best = self:FindVariable("have_best")
	self.best_layer = self:FindVariable("best_layer")
	self.layer = self:FindVariable("layer")
	self.shenqi_power = self:FindVariable("shenqi_power")
	self.can_onekey = self:FindVariable("can_onekey")
	self.model_level = self:FindVariable("model_level")
	self.show_first_fetch = self:FindVariable("show_first_fetch")

	self:ListenEvent("ClickRank", BindTool.Bind(self.ClickRank, self))
	self:ListenEvent("ClickOneKey", BindTool.Bind(self.ClickOneKey, self))
	self:ListenEvent("ClickChallenge", BindTool.Bind(self.ClickChallenge, self))
end

function GodTemplePaTaView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for _, v in ipairs(self.first_item_list) do
		v:DeleteMe()
	end
	self.first_item_list = nil

	for _, v in ipairs(self.day_item_list) do
		v:DeleteMe()
	end
	self.day_item_list = nil

	for _, v in ipairs(self.monster_cell_list) do
		v:DeleteMe()
	end
	self.monster_cell_list = nil
end

function GodTemplePaTaView:OnClickMonster(cell)
	local data = cell:GetData()
	if data == nil then
		return
	end

	local today_layer = GodTemplePataData.Instance:GetTodayLayer()
	if data.level == today_layer + 1 then
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_GOD_TEMPLE)
	end
end

function GodTemplePaTaView:ClickRank()
	ViewManager.Instance:Open(ViewName.GodTempleRankView)
end

function GodTemplePaTaView:ClickChallenge()
	local today_layer = GodTemplePataData.Instance:GetTodayLayer()
	local next_layer_info = GodTemplePataData.Instance:GetLayerCfgInfo(today_layer + 1)
	if next_layer_info == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Daily.MaxTiaoZhanLevel)
		return
	end

	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_GOD_TEMPLE)
end

function GodTemplePaTaView:ClickOneKey()
	FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_GOD_TEMPLE)
end

function GodTemplePaTaView:InitView()
	--请求顶级玩家信息
	RankCtrl.Instance:SendGetPersonRankTopUserReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_GOD_TEMPLE)

	self:FlushView()
end

function GodTemplePaTaView:CloseView()
end

function GodTemplePaTaView:FlushMonsterList()
	local show_list = GodTemplePataData.Instance:GetShowLayerList()
	for k, v in ipairs(show_list) do
		if self.monster_cell_list[k] then
			self.monster_cell_list[k]:SetData(v)
		end
	end
end

function GodTemplePaTaView:FlushLeftContent()
	local best_rank_info = GodTemplePataData.Instance:GetBestRankInfo()
	if best_rank_info == nil or best_rank_info.user_id < 0 then
		self.have_best:SetValue(false)
	else
		self.have_best:SetValue(true)
		self.best_name:SetValue(best_rank_info.user_name)
		self.best_layer:SetValue(best_rank_info.rank_value)
	end
end

function GodTemplePaTaView:FlushLeft()
	self:FlushLeftContent()
	self:FlushMonsterList()
end

function GodTemplePaTaView:FlushRightModel(level)
	local shenqi_cfg_info = GodTempleShenQiData.Instance:GetShenQiCfgInfoByLevel(level)
	if shenqi_cfg_info == nil then
		return
	end

	self.model_level:SetValue(level)
	local power = CommonDataManager.GetCapabilityCalculation(shenqi_cfg_info)
	self.shenqi_power:SetValue(power)

	local bundle, asset = ResPath.GetGodTempleShenQiModel(shenqi_cfg_info.res_id)
	self.model:SetMainAsset(bundle, asset)
end

function GodTemplePaTaView:FlushRight()
	local pass_layer = GodTemplePataData.Instance:GetPassLayer()
	local active_layer_cfg_info = GodTemplePataData.Instance:GetNextActiveShenQiLayerInfoByLayer(pass_layer + 1)
	if active_layer_cfg_info == nil then
		active_layer_cfg_info = GodTemplePataData.Instance:GetNextActiveShenQiLayerInfoByLayer(pass_layer)
	end

	if active_layer_cfg_info ~= nil then
		self.layer:SetValue(active_layer_cfg_info.level)
		--设置模型展示
		self:FlushRightModel(active_layer_cfg_info.level_up)
	end

	local today_layer = GodTemplePataData.Instance:GetTodayLayer()
	local now_layer_cfg_info = GodTemplePataData.Instance:GetLayerCfgInfo(today_layer + 1)
	if now_layer_cfg_info == nil then
		now_layer_cfg_info = GodTemplePataData.Instance:GetLayerCfgInfo(today_layer)
	end

	if now_layer_cfg_info == nil then
		return
	end

	--是否已通关
	local is_through_layer = GodTemplePataData.Instance:IsThroughLayer(today_layer + 1)

	--设置首次奖励展示
	local first_reawrd_list = now_layer_cfg_info.first_reward
	for k, v in ipairs(self.first_item_list) do
		local reward_info = first_reawrd_list[k-1]
		if reward_info == nil then
			v:SetParentActive(false)
		else
			v:SetParentActive(true)
			v:SetData(reward_info)

			v:SetIconGrayVisible(is_through_layer)
			self.show_first_fetch:SetValue(is_through_layer)
		end
	end

	--设置每日奖励展示
	local normal_reward_list = now_layer_cfg_info.show_reward
	for k, v in ipairs(self.day_item_list) do
		local reward_info = normal_reward_list[k-1]
		if reward_info == nil then
			v:SetParentActive(false)
		else
			v:SetParentActive(true)
			v:SetData(reward_info)
		end
	end

	--能否一键完成副本
	self.can_onekey:SetValue(pass_layer > today_layer)
end

function GodTemplePaTaView:FlushView()
	self:FlushLeft()
	self:FlushRight()
end

function GodTemplePaTaView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "rank" then
			self:FlushLeftContent()
		else
			self:FlushView()
		end
	end
end

-------------------------------GodTempleMonsterItem-------------------------------------
GodTempleMonsterItem = GodTempleMonsterItem or BaseClass(BaseCell)
function GodTempleMonsterItem:__init()
	self.model = RoleModel.New("display_god_temple_monster")
	self.model:SetDisplay(self:FindObj("display").ui3d_display)

	self.power = self:FindVariable("power")
	self.layer = self:FindVariable("layer")
	self.power_color = self:FindVariable("power_color")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function GodTempleMonsterItem:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function GodTempleMonsterItem:FlushModel()
	if self.data == nil then
		return
	end

	local monster_cfg_info = BossData.Instance:GetMonsterInfo(self.data.boss_id)
	if monster_cfg_info == nil then
		return
	end

	local bundle, asset = ResPath.GetMonsterModel(monster_cfg_info.resid)
	self.model:SetMainAsset(bundle, asset)
end

function GodTempleMonsterItem:OnFlush()
	if self.data == nil then
		return
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local color = TEXT_COLOR.WHITE
	if main_vo.capability < self.data.capability then
		color = TEXT_COLOR.RED
	end
	self.power_color:SetValue(color)
	self.power:SetValue(self.data.capability)
	self.layer:SetValue(self.data.level)

	self:FlushModel()
end
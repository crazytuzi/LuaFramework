GodTemplePataData = GodTemplePataData or BaseClass()

function GodTemplePataData:__init()
	if GodTemplePataData.Instance then
		print_error("[GodTemplePataData] Attempt to create singleton twice!")
		return
	end
	GodTemplePataData.Instance = self

	self.pass_layer = -1
	self.today_layer = -1

	RemindManager.Instance:Register(RemindName.GodTemple_PaTa, BindTool.Bind(self.CalcRemind, self))
end

function GodTemplePataData:__delete()
	RemindManager.Instance:UnRegister(RemindName.GodTemple_PaTa)

	GodTemplePataData.Instance = nil
end

function GodTemplePataData:SetInfo(protocol)
	self.pass_layer = protocol.pass_layer
	self.today_layer = protocol.today_layer
end

function GodTemplePataData:GetPassLayer()
	return self.pass_layer
end

function GodTemplePataData:GetTodayLayer()
	return self.today_layer
end

function GodTemplePataData:CalcRemind()
	local layer_info = self:GetLayerCfgInfo()
	if layer_info == nil then
		return 0
	end

	--推荐战力达到增加提醒
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if layer_info.capability <= main_vo.capability then
		return 1
	end

	return 0
end

--获取顶级玩家排名信息
function GodTemplePataData:GetBestRankInfo()
	local info = RankData.Instance:GetBestRankInfo(PERSON_RANK_TYPE.PERSON_RANK_TYPE_GOD_TEMPLE)
	return info
end

--获取对应层数的信息
function GodTemplePataData:GetLayerCfgInfo(layer)
	layer = layer or self.today_layer + 1
	local layer_cfg = GodTempleData.Instance:GetLayerCfg()
	return layer_cfg[layer]
end

--获取当前展示的等级列表信息（只显示3层）
function GodTemplePataData:GetShowLayerList()
	local layer_cfg = GodTempleData.Instance:GetLayerCfg()
	local max_show_layer = 3
	local layer = self.today_layer + 1
	local max_layer = #layer_cfg
	local show_list = {}
	if layer <= 0 then
		return show_list
	end

	if max_layer - layer < max_show_layer then
		for i = max_layer - max_show_layer + 1, max_layer do
			table.insert(show_list, layer_cfg[i])
		end
	else
		for i = layer, layer + max_show_layer - 1 do
			table.insert(show_list, layer_cfg[i])
		end
	end

	return show_list
end

--根据对应层数获取最近有激活神器的层数信息
function GodTemplePataData:GetNextActiveShenQiLayerInfoByLayer(layer)
	layer = layer or self.pass_layer + 1
	local layer_cfg = GodTempleData.Instance:GetLayerCfg()
	local max_layer = #layer_cfg
	for i = layer, max_layer do
		local info = layer_cfg[i]
		if info and info.level_up > 0 then
			return info
		end
	end

	return nil
end

function GodTemplePataData:IsThroughLayer(layer)
	return self.pass_layer >= layer
end

function GodTemplePataData:CanChallange()
	if not OpenFunData.Instance:FunIsUnLock("godtempleview") then
		return false
	end

	return self:CalcRemind() > 0
end
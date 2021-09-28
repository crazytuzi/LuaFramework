FamousGeneralPotentialData = FamousGeneralPotentialData or BaseClass()

function FamousGeneralPotentialData:__init()
	FamousGeneralPotentialData.Instance = self
end

function FamousGeneralPotentialData:__delete()
	FamousGeneralPotentialData.Instance = nil
end

function FamousGeneralPotentialData:SetData()

end

----------------------------------初始化数据-------------------------------

function FamousGeneralPotentialData:InitData()
	local cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto").level
	self.level_cfg = ListToMap(cfg, "seq", "level")
end

function FamousGeneralPotentialData:InitLevelList()
	local cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto").greate_soldier
	for i,v in ipairs(cfg) do
		local level_data = self:InitLevelData(v)
	end

	self.general_level_data = {}
end

function FamousGeneralPotentialData:InitLevelData(value)
	local level_data = {}

	level_data.id = value.seq
	
end

----------------------------------获取数据---------------------------------
function FamousGeneralPotentialData:GetAttr(index, types)

end

function FamousGeneralPotentialData:GetNextAttr(index, types)

end
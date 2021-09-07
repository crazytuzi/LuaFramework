KuaFuFlowerRankData = KuaFuFlowerRankData or BaseClass()

function KuaFuFlowerRankData:__init()
	if KuaFuFlowerRankData.Instance ~= nil then
		print_error("[KuaFuFlowerRankData] Attemp to create a singleton twice !")
		return
	end
	KuaFuFlowerRankData.Instance = self

	self.rank_type = 0
	self.rank_list = {}
	self.cross_rank_male = {}
	self.cross_rank_female = {}

	RemindManager.Instance:Register(RemindName.CrossFlowerRank, BindTool.Bind(self.GetCrossFlowerRankRemind, self))
end

function KuaFuFlowerRankData:__delete()
	RemindManager.Instance:UnRegister(RemindName.CrossFlowerRank)

	KuaFuFlowerRankData.Instance = nil
end

function KuaFuFlowerRankData:SetCrossRARankGetRankACK(protocol)
	self.rank_type = protocol.rank_type
	self.rank_list = protocol.rank_list

	if protocol.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_FLOWER_RANK_MALE then
		self.cross_rank_male = protocol.rank_list
	elseif protocol.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_FLOWER_RANK_FEMALE then
		self.cross_rank_female = protocol.rank_list
	end
end

function KuaFuFlowerRankData:GetRankList()
	return self.rank_list
end

function KuaFuFlowerRankData:GetCrossRankMaleList()
	return self.cross_rank_male
end

function KuaFuFlowerRankData:GetCrossRankFeMaleList()
	return self.cross_rank_female
end

function KuaFuFlowerRankData:GetKuaFuRechargeRankConfig()
	return ConfigManager.Instance:GetAutoConfig("cross_randactivity_cfg_1_auto") or {}
end

function KuaFuFlowerRankData:GetCrossFlowerRankRemind()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CROSS_FLOWER_RANK) then
		if ClickOnceRemindList[RemindName.CrossFlowerRank] and ClickOnceRemindList[RemindName.CrossFlowerRank] == 1 then
			return 1
		end
	end

	return 0
end

RoleCycleData = RoleCycleData or BaseClass()

CYCLE_ITEM = {648, 649}
CycleOpenLvCond = ReincarnationCfg.activeLevel
PerCycleLvStep = ReincarnationCfg.stepNum
function RoleCycleData:__init()
	if RoleCycleData.Instance then
		ErrorLog("[RoleCycleData] attempt to create singleton twice!")
		return
	end
	RoleCycleData.Instance = self
end

function RoleCycleData:__delete()
	RoleCycleData.Instance = nil
end


function RoleCycleData.GetCycleAttrAddServerCfg()
	if cc.FileUtils:getInstance():isFileExist("scripts/config/server/config/attr/ReincarnationAttrsConfig" .. ".lua") then
		return ConfigManager.Instance:GetServerConfig("attr/ReincarnationAttrsConfig")[1][1]
	end
end

--轮回属性增加配置
function RoleCycleData.GetCycleAttrAddCfgByProf()
	local serverCfg = RoleCycleData.GetCycleAttrAddServerCfg() and RoleCycleData.GetCycleAttrAddServerCfg() or {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local cfg = {}
	for i_1,v_1 in ipairs(serverCfg) do
		local tmp_1 = {}
		for i_2,v_2 in ipairs(v_1) do
			if v_2.job == prof then
				local tmp_2 = {type = v_2.type, value = v_2.value}
				table.insert(tmp_1, tmp_2)
			end
		end
		table.insert(cfg, tmp_1)
	end

	return cfg
end

--当前人物等级兑换修为配置
function RoleCycleData.GetCurRoleLvExchanCultivaCfg(curRoLv)
	local exchanCfg = nil
	for _, v in pairs(ReincarnationCfg.ReincarnationSoulExchange) do
		if v.reqLevel == curRoLv then
			exchanCfg = v
			break
		end
	end

	return exchanCfg
end

--升级到下一级轮回消耗修为配置
function RoleCycleData.GetCycleUpgradeConsumCfg(nxLv)
	return ReincarnationCfg.ReincarnationConsumes[nxLv] and ReincarnationCfg.ReincarnationConsumes[nxLv].consumes or nil
end

function RoleCycleData:SetExchanRestTime(protocol)
	self.rest_excha_time = protocol.rest_excha_time
end

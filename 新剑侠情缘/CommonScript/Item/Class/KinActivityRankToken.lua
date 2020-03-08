local tbItem = Item:GetClass("KinActivityRankToken")

function tbItem:OnUse(it)
	if not version_tx then
		return 1
	end

	local game_id = 1217
	local source = "xy_games"
	local role_id = me.dwID
	local role_name = Lib:UrlEncode(me.szName)
	local area_id = Sdk:GetAreaId()
	local partition_id = Sdk:GetServerId()
	local tbOsTypeToSysId = {
		[Sdk.eOSType_iOS] = 0,
		[Sdk.eOSType_Android] = 1,
		[Sdk.eOSType_Windows] = 2,
	}
	local system_id = tbOsTypeToSysId[Sdk:GetOsType() or Sdk.eOSType_Windows]
	local plat_id = Sdk:IsLoginByWeixin() and 1 or 2
	local szUrl = string.format("http://www.jxqy.org",
		game_id, source, role_id, role_name, area_id, partition_id, system_id, plat_id)
	Sdk:OpenUrl(szUrl)
	Log("KinActivityRankToken:OnUse", me.dwKinId, role_id, szUrl)
	return 1
end
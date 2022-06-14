function SyncPlunderTargetHandler( plunderTargets )
	
	--dump(plunderTargets);
	
	dataManager.idolBuildData:setPlunderTargets(plunderTargets);
	
	eventManager.dispatchEvent({name = global_event.IDOLSTATUSROB_SHOW, });
	eventManager.dispatchEvent({name = global_event.IDOLSTATUSROB_UPDATE, });
	
-- data struct
--[==[
[[
	data['units'] = {};
	data['primals'] = {};
-- 名字
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 排名
	data['rank'] = networkengine:parseInt();
-- 头像
	data['icon'] = networkengine:parseInt();
-- 对应的玩家id
	data['playerID'] = networkengine:parseInt();
-- 对应的玩家战斗力
	data['playerPower'] = networkengine:parseInt();
-- 国王信息
	data['kingInfo'] = ParseKingInfo();
-- 兵团信息列表
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['units'][i] = ParseUnitInfo();
	end
-- 是否在防守战斗中
	data['status'] = networkengine:parseInt();
-- 源生货币
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['primals'][i] = networkengine:parseInt();
	end
-- 掠夺保护时间
	data['plunderTime'] = networkengine:parseUInt64();
]]
--]==]

end

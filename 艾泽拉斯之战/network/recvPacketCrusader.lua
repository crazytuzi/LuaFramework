-- 远征阵容配置

function packetHandlerCrusader()
	local tempArrayCount = 0;
	local units = {};
	local kingInfo = {};

-- 远征军团配置
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		units[i] = ParseUnitInfo();
	end
-- 远征国王信息
	kingInfo = ParseKingInfo();

	CrusaderHandler( units, kingInfo );
end


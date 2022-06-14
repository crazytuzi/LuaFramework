-- 玩家属性同步

function packetHandlerSyncPlayer()
	local tempArrayCount = 0;
	local attr = {};
	local timeAttr = {};
	local attrString = {};

-- 属性数组
	local __optional_flag__attr = GameClient.Bitset:new(64);
 	networkengine:parseBitset(64, __optional_flag__attr);
	tempArrayCount = 64;
	for i=1, tempArrayCount do
		if __optional_flag__attr:isSetbit(i-1) then
			attr[i] = networkengine:parseInt();
		end
	end
-- 时间属性数组
	local __optional_flag__timeAttr = GameClient.Bitset:new(64);
 	networkengine:parseBitset(64, __optional_flag__timeAttr);
	tempArrayCount = 64;
	for i=1, tempArrayCount do
		if __optional_flag__timeAttr:isSetbit(i-1) then
			timeAttr[i] = networkengine:parseUInt64();
		end
	end
-- 字符串属性数组
	local __optional_flag__attrString = GameClient.Bitset:new(64);
 	networkengine:parseBitset(64, __optional_flag__attrString);
	tempArrayCount = 64;
	for i=1, tempArrayCount do
		if __optional_flag__attrString:isSetbit(i-1) then
		local strlength = networkengine:parseInt();
	if strlength > 0 then
				attrString[i] = networkengine:parseString(strlength);
	else
				attrString[i] = "";
	end
		end
	end

	SyncPlayerHandler( __optional_flag__attr,  attr, __optional_flag__timeAttr,  timeAttr, __optional_flag__attrString,  attrString );
	__optional_flag__attr:delete();
	__optional_flag__timeAttr:delete();
	__optional_flag__attrString:delete();
end


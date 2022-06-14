-- 测试变长包

function sendTestVariant(len, value)
	networkengine:beginsend(14);
-- 测试数据长度
	networkengine:pushInt(len);
-- 测试数据
	local arrayLength = #value;
	if arrayLength > 256 then arrayLength = 256 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(value) do
		networkengine:pushInt(v);
	end

	networkengine:send();
end


-- 下发支付订单

function packetHandlerOrder()
	local tempArrayCount = 0;
	local rechargeID = nil;
	local orderID = nil;

-- 充值id
	rechargeID = networkengine:parseInt();
-- 订单号
	local strlength = networkengine:parseInt();
if strlength > 0 then
		orderID = networkengine:parseString(strlength);
else
		orderID = "";
end

	OrderHandler( rechargeID, orderID );
end


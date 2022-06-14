-- 金矿升级通知

function packetHandlerNotifyShakeCount()
	local tempArrayCount = 0;
	local addShakeCount = nil;

-- 当前增加的额外次数
	addShakeCount = networkengine:parseInt();

	NotifyShakeCountHandler( addShakeCount );
end


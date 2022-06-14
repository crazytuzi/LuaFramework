-- 摇红包信息

function packetHandlerSyncShakeInfo()
	local tempArrayCount = 0;
	local shakeCount = nil;
	local addShakeCount = nil;
	local shakeMoney = nil;
	local redEnvelopMoney = nil;

-- 目前已经摇的次数
	shakeCount = networkengine:parseInt();
-- 分享额外增加的次数
	addShakeCount = networkengine:parseInt();
-- 摇到的钱
	shakeMoney = networkengine:parseInt64();
-- 红包的当前总金额
	redEnvelopMoney = networkengine:parseInt64();

	SyncShakeInfoHandler( shakeCount, addShakeCount, shakeMoney, redEnvelopMoney );
end


-- 冥想结果

function packetHandlerMeditateResult()
	local tempArrayCount = 0;
	local magic = {};
	local overflowExp = nil;

-- 冥想最终选择的结果
	magic = ParseMagicChoose();
-- 溢出到魔法书的exp
	overflowExp = networkengine:parseInt();

	MeditateResultHandler( magic, overflowExp );
end


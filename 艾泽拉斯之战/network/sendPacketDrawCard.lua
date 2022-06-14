-- ³é¿¨

function sendDrawCard(drawType)
	networkengine:beginsend(17);
-- ³é¿¨ÀàĞÍ
	networkengine:pushInt(drawType);
	networkengine:send();
end


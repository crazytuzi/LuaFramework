-- ´¬¸ÄÔì

function sendShipRemould(shipIndex)
	networkengine:beginsend(85);
-- ´¬µÄindex
	networkengine:pushInt(shipIndex);
	networkengine:send();
end


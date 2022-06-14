-- ´¬Éý¼¶

function sendShipUpgrade(shipIndex)
	networkengine:beginsend(26);
-- ´¬µÄindex
	networkengine:pushInt(shipIndex);
	networkengine:send();
end


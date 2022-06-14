-- ¸ÄÍ·Ïñ

function sendChangeIcon(icon)
	networkengine:beginsend(79);
-- Í·Ïñ
	networkengine:pushInt(icon);
	networkengine:send();
end


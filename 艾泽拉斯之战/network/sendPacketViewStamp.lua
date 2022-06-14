-- 关闭图鉴标签

function sendViewStamp(stampType, id)
	networkengine:beginsend(94);
-- 类型，参照typedef的viewStampType
	networkengine:pushInt(stampType);
-- 需要关闭的ID
	networkengine:pushInt(id);
	networkengine:send();
end


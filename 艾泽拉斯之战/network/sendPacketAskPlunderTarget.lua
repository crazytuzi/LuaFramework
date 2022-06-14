-- 请求掠夺对象

function sendAskPlunderTarget(primalsType)
	networkengine:beginsend(116);
-- 所要掠夺的原生资源类型
	networkengine:pushInt(primalsType);
	networkengine:send();
end


--[[
内部消息处理类,全局注册,全局发送
]]

_G.Notifier = {}

Notifier.SetNotification = {}
Notifier.tempPort = {};
Notifier.enabled = true;

--注册消息
function Notifier:registerNotification(name, func)
	if not self.SetNotification[name] then
		self.SetNotification[name] = {}
	end
	--debug下检查是否有重复注册.
	if isDebug then
		for i,f in ipairs(self.SetNotification[name]) do
			if f == func then
				print("Error:Notifier,发现重复的注册");
				print(debug.traceback());
				return;
			end
		end
	end
	table.push(self.SetNotification[name],func);
end

--取消注册消息
function Notifier:unregisterNotification(name, func)
	if not self.SetNotification[name] then
		return;
	end
	for i=#self.SetNotification[name], 1, -1 do
		local f = self.SetNotification[name][i];
		if f == func then
			table.remove(self.SetNotification[name], i, 1);
			break;
		end
	end
end


--发送消息
function Notifier:sendNotification(name, body)
	if not self.enabled then
		return;
	end

	if not self.SetNotification[name] then
		return;
	end
	--这里使用templist,防止在send消息的同时SetNotification被修改了
	local list = self.SetNotification[name];
	local templist = self:GetTempList();
	for i,func in ipairs(list) do
		table.push(templist,func);
	end
	for i,func in ipairs(templist) do
		func(name,body);
	end
	self:BackTempList(templist);
end

function Notifier:GetTempList()
	if #self.tempPort > 0 then
		return table.remove(self.tempPort,1,1);
	end
	return {};
end

function Notifier:BackTempList(t)
	for i,func in ipairs(t) do
		t[i] = nil;
	end
	table.push(self.tempPort,t)
end

function Notifier:SetEnabled(enabled)
	self.enabled = enabled;
end

function Notifier:GetEnabled()
	return self.enabled;
end

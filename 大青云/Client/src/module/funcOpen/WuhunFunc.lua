--[[
技能功能
lizhuangzhuang
2015年2月26日15:21:56
]]

_G.WuhunFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.FaBao,WuhunFunc);
WuhunFunc.Items = {140624001,140624002}
function WuhunFunc:OnBtnInit()
	self.button.mcLvlUp._visible = false;
	self:SetLvlUp()
	self:UnRegisterNotification()
	self:RegisterNotification()
end

function WuhunFunc:SetLvlUp()
	-- if self.state == FuncConsts.State_Open then
		-- if SpiritsUtil:HasActWuhun() then
			-- self.button.mcLvlUp._visible = true;
		-- else
			-- self.button.mcLvlUp._visible = false;
		-- end
	-- end
end

--处理消息
function WuhunFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	if name == NotifyConsts.WuhunListUpdate then
		self:SetLvlUp()
	elseif name == NotifyConsts.BagItemNumChange then
		if self:CheckItemId(body.id) then
			self:SetLvlUp()
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaLevel then
			self:SetLvlUp()
		end
	end
end

--消息处理
function WuhunFunc:RegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then
		self.notifierCallBack = function(name,body)
			self:HandleNotification(name, body);
		end
	end
	for i,name in pairs(setNotificatioin) do
		Notifier:registerNotification(name, self.notifierCallBack)
	end
end

--取消消息注册
function WuhunFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function WuhunFunc:ListNotificationInterests()
	return {
		NotifyConsts.BagItemNumChange,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.WuhunListUpdate,
	} 
end

function WuhunFunc:CheckItemId(itemId)
	for k,v in pairs(self.Items) do
		if v == itemId then
			return true
		end
	end
	return false
end
--[[
	2015年12月22日16:14:16
	wangyanwei
	圣诞活动按钮
]]
_G.ChristmasBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_Christmas,ChristmasBtn);

function ChristmasBtn:GetStageBtnName()
	return "christmas";
end

function ChristmasBtn:IsShow()
	return false
end

function ChristmasBtn:OnBtnClick()
	if UIChristmasBasic:IsShow() then
		UIChristmasBasic:Hide();
	else
		UIChristmasBasic:Show();
	end
end

-- 处理消息
-- function ChristmasBtn:HandleNotification(name, body)
	-- if not self:IsShow() then return end
	-- if name == NotifyConsts.PlayerAttrChange then
		-- if body.type == enAttrType.eaVIPLevel then
			-- UIMainYunYingFunc:DrawLayout();
		-- end
	-- end
-- end

-- 消息处理
-- function ChristmasBtn:RegisterNotification()
	-- local setNotificatioin = self:ListNotificationInterests();
	-- if not setNotificatioin then return; end
	-- if not self.notifierCallBack then
		-- self.notifierCallBack = function(name,body)
			-- self:HandleNotification(name, body);
		-- end
	-- end
	-- for i,name in pairs(setNotificatioin) do
		-- Notifier:registerNotification(name, self.notifierCallBack)
	-- end
-- end

-- 取消消息注册
-- function ChristmasBtn:UnRegisterNotification()
	-- local setNotificatioin = self:ListNotificationInterests();
	-- if not setNotificatioin then return; end
	-- if not self.notifierCallBack then return end
	-- for i,name in pairs(setNotificatioin) do
		-- Notifier:unregisterNotification(name, self.notifierCallBack)
	-- end
-- end

-- 监听消息
-- function ChristmasBtn:ListNotificationInterests()
	-- return {
		-- NotifyConsts.PlayerAttrChange,
	-- } 
-- end
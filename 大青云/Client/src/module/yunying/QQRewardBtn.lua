--[[

]]

_G.QQRewardBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_QQReward,QQRewardBtn);

function QQRewardBtn:GetStageBtnName()
	return "qqReward";
end
function QQRewardBtn:IsShow()
	-- local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	-- local cfg = t_consts[346]
	-- if not cfg then return false end
	
	-- if curRoleLvl >=cfg.val1 then 
		-- return true
	-- end
	return false

end
function QQRewardBtn:OnBtnClick()
    
	if UIQQReward:IsShow() then
		UIQQReward:Hide();
	else
		if self.button then
			--UIVplanMain.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UIQQReward:Show();
		--VplanController:ReqVplan();
	end
end
--处理消息
function QQRewardBtn:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.GetCodeReward then
		self:OnGetCodeReward();
	end
end

--消息处理
function QQRewardBtn:RegisterNotification()
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


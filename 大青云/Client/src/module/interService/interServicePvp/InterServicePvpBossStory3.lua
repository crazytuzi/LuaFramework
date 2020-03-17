--[[
跨服副本面板
liyuan
]]

_G.UIInterServiceBossStory3 = BaseUI:new("UIInterServiceBossStory3");
UIInterServiceBossStory3.timeId = nil
function UIInterServiceBossStory3:Create()
	self:AddSWF("interBossStory2Panel.swf", true, "interserver");
end

function UIInterServiceBossStory3:OnLoaded(objSwf)
	objSwf.btnExit.click = function()
		local exitfunc = function ()
			InterServicePvpController:ReqQuitCrossBoss()
			self:Hide()
		end
		UIConfirm:Open(StrConfig["interServiceDungeon6"],exitfunc);
	end
end

-----------------------------------------------------------------------
function UIInterServiceBossStory3:IsTween()
	return false;
end

function UIInterServiceBossStory3:GetPanelType()
	return 0;
end

function UIInterServiceBossStory3:IsShowSound()
	return false;
end

function UIInterServiceBossStory3:Update()
	
end

function UIInterServiceBossStory3:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
end

function UIInterServiceBossStory3:OnHide()
	-- if self.timeId then
		-- TimerManager:UnRegisterTimer(self.timeId)
		-- self.timeId = nil
	-- end
	-- if self.confirmID then
		-- UIConfirm:Close(self.confirmID);
	-- end
end

function UIInterServiceBossStory3:GetWidth()
	return 247;
end

function UIInterServiceBossStory3:GetHeight()
	return 327;
end

function UIInterServiceBossStory3:OnBtnCloseClick()
	self:Hide();
end

function UIInterServiceBossStory3:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterServiceBossStory3:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterServiceBossStory3:HandleNotification(name, body)
	
end


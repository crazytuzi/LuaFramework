--[[
跨服副本面板
liyuan
]]

_G.UIInterServiceBossStory1 = BaseUI:new("UIInterServiceBossStory1");
UIInterServiceBossStory1.timeId = nil
UIInterServiceBossStory1.showCount = 10

UIInterServiceBossStory1.countDownTimeId = nil

function UIInterServiceBossStory1:Create()
	self:AddSWF("interBossStory1Panel.swf", true, "interserver");
end

function UIInterServiceBossStory1:OnLoaded(objSwf)
	objSwf.mcStory.btnExit.click = function()
		local exitfunc = function ()
			InterServicePvpController:ReqQuitCrossBoss()
			self:Hide()
		end
		UIConfirm:Open(StrConfig["interServiceDungeon6"],exitfunc);
	end
	
	objSwf.mcZhuizong.click = function() 
		objSwf.mcZhuizong.visible = false
		objSwf.mcStory._visible = true
		objSwf.mcStory.hitTestDisable = false
	end
	
	objSwf.mcStory.btnColse.click = function() 
		objSwf.mcZhuizong.visible = true
		objSwf.mcStory._visible = false
		objSwf.mcStory.hitTestDisable = true
	end
	objSwf.mcStory.txtInfo.text = StrConfig['interServiceDungeon36']
	
	objSwf.mcStory.numLoaderFight.loadComplete = function ()		
		objSwf.mcStory.numLoaderFight._x = objSwf.mcStory.rankPos._x - objSwf.mcStory.numLoaderFight._width * 0.5;
		objSwf.mcStory.numLoaderFight._y = objSwf.mcStory.rankPos._y - objSwf.mcStory.numLoaderFight._height * 0.5;
	end
end

-----------------------------------------------------------------------
function UIInterServiceBossStory1:IsTween()
	return false;
end

function UIInterServiceBossStory1:GetPanelType()
	return 0;
end

function UIInterServiceBossStory1:IsShowSound()
	return false;
end

function UIInterServiceBossStory1:Update()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	if not InterServicePvpModel.bossStatus then return end
	objSwf.mcStory.actTime.text = DungeonUtils:ParseTime(InterServicePvpModel.bossStatus.remainsec)
end

function UIInterServiceBossStory1:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	objSwf.mcZhuizong.visible = false
	objSwf.mcStory._visible = true
	objSwf.mcStory.hitTestDisable = false
	
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end
	
	self.showCount = 10
	objSwf.mcStory.numLoaderFight.num = self.showCount
	self.timeId = TimerManager:RegisterTimer(function()
					if self.showCount <= 0 then 
						TimerManager:UnRegisterTimer(self.timeId)
						self.timeId = nil
						return 
					end
					self.showCount = self.showCount - 1		
					objSwf.mcStory.numLoaderFight.num = self.showCount
				end,1000,10)	
end

function UIInterServiceBossStory1:OnHide()
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end	
end

function UIInterServiceBossStory1:GetWidth()
	return 369;
end

function UIInterServiceBossStory1:GetHeight()
	return 541;
end

function UIInterServiceBossStory1:OnBtnCloseClick()
	self:Hide();
end

function UIInterServiceBossStory1:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterServiceBossStory1:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterServiceBossStory1:HandleNotification(name, body)
	
end


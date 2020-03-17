--[[
跨服擂台预选赛追踪面板
liyuan
]]

_G.UIInterContestStory = BaseUI:new("UIInterContestStory");
UIInterContestStory.timeId = nil

function UIInterContestStory:Create()
	self:AddSWF("interContestStory.swf", true, "interserver");
end

function UIInterContestStory:OnLoaded(objSwf)
	objSwf.mcStory.btnExit.click = function()
		local exitfunc = function ()
			InterContestController:ReqCrossArenaQuit()
			self:Hide()
		end
		UIConfirm:Open(StrConfig["interServiceDungeon91"],exitfunc);
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
end

-----------------------------------------------------------------------
function UIInterContestStory:IsTween()
	return false;
end

function UIInterContestStory:GetPanelType()
	return 0;
end

function UIInterContestStory:IsShowSound()
	return false;
end

function UIInterContestStory:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	objSwf.mcZhuizong.visible = false
	objSwf.mcStory._visible = true
	objSwf.mcStory.hitTestDisable = false
	
	self:ResetCountDownTime()	
end

function UIInterContestStory:ResetCountDownTime()
	local objSwf = self.objSwf;
	if not objSwf then return; end	

	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end
	
	objSwf.mcStory.numLoaderFight.num = InterContestModel.power or 0
	objSwf.mcStory.txtName.text = InterContestModel.name or ''
	objSwf.mcStory.txtCnt.text = InterContestModel.guwucnt or 0
	if InterContestModel.time then
		objSwf.mcStory.txtCountdown.text = DungeonUtils:ParseTime(InterContestModel.time)
		self.timeId = TimerManager:RegisterTimer(function()
						if InterContestModel.time <= 0 then 
							TimerManager:UnRegisterTimer(self.timeId)
							self.timeId = nil
							return 
						end
						
						InterContestModel.time = InterContestModel.time - 1		
						objSwf.mcStory.txtCountdown.text = DungeonUtils:ParseTime(InterContestModel.time)
					end,1000,InterContestModel.time)
	end
end

function UIInterContestStory:OnHide()
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end	
end

function UIInterContestStory:GetWidth()
	return 249;
end

function UIInterContestStory:GetHeight()
	return 325;
end

function UIInterContestStory:OnBtnCloseClick()
	self:Hide();
end

function UIInterContestStory:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterContestStory:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterContestStory:HandleNotification(name, body)
	
end


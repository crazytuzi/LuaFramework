--[[
跨服擂台预选赛追踪面板
liyuan
]]

_G.UIInterContestPreStory = BaseUI:new("UIInterContestPreStory");
UIInterContestPreStory.timeId = nil

UIInterContestPreStory.countDownTimeId = nil

function UIInterContestPreStory:Create()
	self:AddSWF("interContestPreStory.swf", true, "interserver");
end

function UIInterContestPreStory:OnLoaded(objSwf)
	objSwf.mcStory.btnExit.click = function()
		local exitfunc = function () 
			InterContestController:ReqCrossPreArenaQuit()
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
	objSwf.mcStory.txtInfo.text = StrConfig['interServiceDungeon57']
	objSwf.mcStory.btnRule.rollOver = function () TipsManager:ShowBtnTips(StrConfig['interServiceDungeon58'],TipsConsts.Dir_RightDown); end
	objSwf.mcStory.btnRule.rollOut = function () TipsManager:Hide(); end
	
	objSwf.mcStory.btnzige.click = function()
		InterContestController:ReqCrossPreArenaRank()
	end
	objSwf.mcStory.btnjiangli.click = function()
		if UIInterContestAward:IsShow() then
			UIInterContestAward:Hide()
		else
			UIInterContestAward:Show(2)	
		end
	end
	
	objSwf.mcStory.numLoaderFight.loadComplete = function ()		
		objSwf.mcStory.numLoaderFight._x = objSwf.mcStory.rankPos._x - objSwf.mcStory.numLoaderFight._width * 0.5;
		objSwf.mcStory.numLoaderFight._y = objSwf.mcStory.rankPos._y - objSwf.mcStory.numLoaderFight._height * 0.5;
	end
end

-----------------------------------------------------------------------
function UIInterContestPreStory:IsTween()
	return false;
end

function UIInterContestPreStory:GetPanelType()
	return 0;
end

function UIInterContestPreStory:IsShowSound()
	return false;
end

function UIInterContestPreStory:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	objSwf.mcZhuizong.visible = false
	objSwf.mcStory._visible = true
	objSwf.mcStory.hitTestDisable = false
	
	self:ResetCountDownTime()	
end

function UIInterContestPreStory:ResetCountDownTime()
	local objSwf = self.objSwf;
	if not objSwf then return; end	

	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end
	
	objSwf.mcStory.numLoaderFight.num = InterContestModel.preScore or 0
	objSwf.mcStory.txtCountdown.text = DungeonUtils:ParseTime(InterContestModel.preRemainsec)
	self.timeId = TimerManager:RegisterTimer(function()
					if InterContestModel.preRemainsec <= 0 then 
						TimerManager:UnRegisterTimer(self.timeId)
						self.timeId = nil
						return 
					end
					
					InterContestModel.preRemainsec = InterContestModel.preRemainsec - 1		
					objSwf.mcStory.txtCountdown.text = DungeonUtils:ParseTime(InterContestModel.preRemainsec)
				end,1000,InterContestModel.preRemainsec)
end

function UIInterContestPreStory:OnHide()
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end	
end

function UIInterContestPreStory:GetWidth()
	return 369;
end

function UIInterContestPreStory:GetHeight()
	return 541;
end

function UIInterContestPreStory:OnBtnCloseClick()
	self:Hide();
end

function UIInterContestPreStory:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterContestPreStory:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterContestPreStory:HandleNotification(name, body)
	
end


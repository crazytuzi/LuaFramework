--[[
跨服擂台淘汰赛结果
liyuan
]]

_G.UIInterContestResult = BaseUI:new("UIInterContestResult");
UIInterContestResult.timeId = nil
UIInterContestResult.showCount = 30

function UIInterContestResult:Create()
	self:AddSWF("interContestResultspanel.swf", true, "interserver");
end

function UIInterContestResult:OnLoaded(objSwf)
	objSwf.out_btn.click = function()
		InterContestController:ReqCrossArenaQuit()
	end
	objSwf.txtTuichu.text = StrConfig['interServiceDungeon35']
end

-----------------------------------------------------------------------
function UIInterContestResult:IsTween()
	return false;
end

function UIInterContestResult:GetPanelType()
	return 0;
end

function UIInterContestResult:IsShowSound()
	return false;
end

function UIInterContestResult:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end
	
	self.showCount = 30
	objSwf.txt_time.text = self.showCount
	self.timeId = TimerManager:RegisterTimer(function()
					if self.showCount <= 0 then 
						TimerManager:UnRegisterTimer(self.timeId)
						self.timeId = nil	
						InterServicePvpController:ReqQuitCrossBoss()
						self:Hide()
						return 
					end
					self.showCount = self.showCount - 1		
					objSwf.txt_time.text = self.showCount
				end,1000,30)
				
	self:UpdateInfo()	
end

function UIInterContestResult:UpdateInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	if InterContestModel.resultResult and InterContestModel.resultResult == 0 then
		objSwf.failure._visible = false
		objSwf.victory._visible = true
		if InterContestModel.resultRank then
			if InterContestModel.resultRank == 1 then
				objSwf.victory.txtInfo.htmlText = StrConfig['interServiceDungeon72']
			elseif InterContestModel.resultRank == 2 then
				objSwf.victory.txtInfo.htmlText = StrConfig['interServiceDungeon78']
			else			
				objSwf.victory.txtInfo.htmlText = string.format(StrConfig['interServiceDungeon61'], InterContestModel.resultRank)
			end
		end
	else
		objSwf.failure._visible = true
		objSwf.victory._visible = false
		objSwf.failure.txtInfo.htmlText = StrConfig['interServiceDungeon62']
	end
	
end

function UIInterContestResult:OnHide()
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end	
end

function UIInterContestResult:GetWidth()
	return 789;
end

function UIInterContestResult:GetHeight()
	return 332;
end

function UIInterContestResult:OnBtnCloseClick()
	self:Hide();
end

function UIInterContestResult:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterContestResult:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterContestResult:HandleNotification(name, body)
	
end


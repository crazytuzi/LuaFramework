--[[
跨服擂台预选赛排行第一
liyuan
]]

_G.UIInterContestPreResult = BaseUI:new("UIInterContestPreResult");
UIInterContestPreResult.timeId = nil
UIInterContestPreResult.showCount = 30

function UIInterContestPreResult:Create() 
	self:AddSWF("interContestPreResultPanel.swf", true, "interserver");
end

function UIInterContestPreResult:OnLoaded(objSwf)
	objSwf.btn_out.click = function()
		InterContestController:ReqCrossPreArenaQuit()
	end	
	objSwf.txtTuichu.text = StrConfig['interServiceDungeon35']
	objSwf.txt_diyi.text = StrConfig['interServiceDungeon92']
	objSwf.txt_youjian.text = StrConfig['interServiceDungeon93']
end

-----------------------------------------------------------------------
function UIInterContestPreResult:IsTween()
	return false;
end

function UIInterContestPreResult:GetPanelType()
	return 0;
end

function UIInterContestPreResult:IsShowSound()
	return false;
end

function UIInterContestPreResult:OnShow()
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

function UIInterContestPreResult:UpdateInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	if InterContestModel.preResultIsFirst and InterContestModel.preResultIsFirst == 1 then
		objSwf.txt_diyi._visible = true
	else
		objSwf.txt_diyi._visible = false
	end
	local reward = InterContestModel:GetPreAwardByScore(InterContestModel.preResultScore)
	objSwf.rewardList.dataProvider:cleanUp()
	objSwf.rewardList.dataProvider:push( unpack( RewardManager:Parse( reward ) ) )
	objSwf.rewardList:invalidateData()
end

function UIInterContestPreResult:OnHide()
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end	
end

function UIInterContestPreResult:GetWidth()
	return 938;
end

function UIInterContestPreResult:GetHeight()
	return 473;
end

function UIInterContestPreResult:OnBtnCloseClick()
	self:Hide();
end

function UIInterContestPreResult:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterContestPreResult:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterContestPreResult:HandleNotification(name, body)
	
end


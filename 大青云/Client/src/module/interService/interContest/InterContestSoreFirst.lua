--[[
跨服擂台预选赛排行第一
liyuan
]]

_G.UIInterContestScoreFirst = BaseUI:new("UIInterContestScoreFirst");


function UIInterContestScoreFirst:Create()
	self:AddSWF("interContestScoreFirst.swf", true, "interserver");
end

function UIInterContestScoreFirst:OnLoaded(objSwf)
	objSwf.btnExit.click = function()
		self:Hide()
	end	
	objSwf.tfjifen.text = StrConfig['interServiceDungeon94']
end

-----------------------------------------------------------------------
function UIInterContestScoreFirst:IsTween()
	return false;
end

function UIInterContestScoreFirst:GetPanelType()
	return 0;
end

function UIInterContestScoreFirst:IsShowSound()
	return false;
end

function UIInterContestScoreFirst:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	self:UpdateInfo()	
end

function UIInterContestScoreFirst:UpdateInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	FPrint('UIInterContestScoreFirst:UpdateInfo')
	if InterContestModel.firstProf and InterContestModel.firstProf >= 1 and InterContestModel.firstProf <= 4 then
		objSwf.iconHead.source = ResUtil:GetHeadIcon(InterContestModel.firstProf)	
	end
	objSwf.txtName.text = InterContestModel.firstName or ''
	objSwf.numLoaderFight.num = InterContestModel.firstScore or 0
end

function UIInterContestScoreFirst:OnHide()
end

function UIInterContestScoreFirst:GetWidth()
	return 289;
end

function UIInterContestScoreFirst:GetHeight()
	return 337;
end

function UIInterContestScoreFirst:OnBtnCloseClick()
	self:Hide();
end

function UIInterContestScoreFirst:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterContestScoreFirst:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterContestScoreFirst:HandleNotification(name, body)
	
end


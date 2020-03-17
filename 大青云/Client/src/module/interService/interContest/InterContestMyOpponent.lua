--[[
跨服擂台鼓舞
liyuan
]]

_G.InterContestMyOpponent = BaseUI:new("InterContestMyOpponent");


function InterContestMyOpponent:Create()
	self:AddSWF("interContestMyOpponent.swf", true, "top");
end

function InterContestMyOpponent:OnLoaded(objSwf)
	
end

-----------------------------------------------------------------------
function InterContestMyOpponent:IsTween()
	return false;
end

function InterContestMyOpponent:GetPanelType()
	return 0;
end

function InterContestMyOpponent:IsShowSound()
	return false;
end

function InterContestMyOpponent:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	self:UpdateInfo()	
end

function InterContestMyOpponent:UpdateInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	if InterContestModel.myOpponentProf >= 1 and InterContestModel.myOpponentProf <= 4 then
		objSwf.iconHead.source = esUtil:GetHeadIcon60(InterContestModel.myOpponentProf)
	else
		objSwf.iconHead.source = nil
	end
	objSwf.txtName.text = InterContestModel.myOpponentRoleName or ''
	objSwf.numLoaderFight.num = InterContestModel.myOpponentFight or 0
end

function InterContestMyOpponent:OnHide()
end

function InterContestMyOpponent:GetWidth()
	return 320;
end

function InterContestMyOpponent:GetHeight()
	return 491;
end

function InterContestMyOpponent:OnBtnCloseClick()
	self:Hide();
end

function InterContestMyOpponent:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function InterContestMyOpponent:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function InterContestMyOpponent:HandleNotification(name, body)
	
end


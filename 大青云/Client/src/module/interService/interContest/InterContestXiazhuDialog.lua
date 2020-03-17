--[[
跨服擂台鼓舞
liyuan
]]

_G.UIInterContestXiazhuDialog = BaseUI:new("UIInterContestXiazhuDialog");
UIInterContestXiazhuDialog.canSend = false
UIInterContestXiazhuDialog.xiazhudanwei = 10000
function UIInterContestXiazhuDialog:Create()
	self:AddSWF("interContestXiazhuDialog.swf", true, "top");
end

function UIInterContestXiazhuDialog:OnLoaded(objSwf)
	objSwf.btnOK.click = function()
		if not self.canSend then return end
		if objSwf.inputXiazhu.text == '' then
			FloatManager:AddNormal( StrConfig["interServiceDungeon203"]);
			return	
		end
		objSwf.inputXiazhu.text = _G.strtrim(objSwf.inputXiazhu.text)
		local textInputNum = toint(objSwf.inputXiazhu.text)*UIInterContestXiazhuDialog.xiazhudanwei
		if textInputNum <=0 then return end 		
		local moneyNum = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
		if textInputNum > moneyNum then 
			FloatManager:AddNormal( StrConfig["interServiceDungeon86"]);
			return	
		end--数量不足
		local gold = textInputNum
		InterContestController:ReqCrossArenaXiaZhu(UIInterContestGuwu.xiazhuId,gold)
		self.canSend = false
	end	
	objSwf.btnClose.click = function()
		self:Hide()
	end
	objSwf.btnCancel.click = function()
		self:Hide()
	end	
	objSwf.inputXiazhu.textChange = function() 
		objSwf.inputXiazhu.text = _G.strtrim(objSwf.inputXiazhu.text)
		local moneyNum = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
	
		if objSwf.inputXiazhu.text == "" or toint(objSwf.inputXiazhu.text) == nil then 
			objSwf.inputXiazhu.text = "10" 
		end
		local textInputNum = toint(objSwf.inputXiazhu.text)
		if textInputNum*UIInterContestXiazhuDialog.xiazhudanwei > moneyNum then 
			local xiazhu = math.floor(moneyNum/UIInterContestXiazhuDialog.xiazhudanwei)
			objSwf.inputXiazhu.text = xiazhu
		end
		if textInputNum > 1000 then objSwf.inputXiazhu.text = '1000' end
		if textInputNum < 10 then objSwf.inputXiazhu.text = '10' end
		if textInputNum <= 0 then 
			objSwf.btnOK.disabled = true else objSwf.btnOK.disabled = false 
		end
	end
	
	objSwf.txt1.text = StrConfig['interServiceDungeon87']
	objSwf.txt2.text = StrConfig['interServiceDungeon88']
	objSwf.txt3.text = StrConfig['interServiceDungeon89']
end

-----------------------------------------------------------------------
function UIInterContestXiazhuDialog:IsTween()
	return false;
end

function UIInterContestXiazhuDialog:GetPanelType()
	return 0;
end

function UIInterContestXiazhuDialog:IsShowSound()
	return false;
end

function UIInterContestXiazhuDialog:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	self.canSend = true
	self:UpdateInfo()	
end

function UIInterContestXiazhuDialog:UpdateInfo()
	
end

function UIInterContestXiazhuDialog:OnHide()
end

function UIInterContestXiazhuDialog:GetWidth()
	return 287;
end

function UIInterContestXiazhuDialog:GetHeight()
	return 212;
end

function UIInterContestXiazhuDialog:OnBtnCloseClick()
	self:Hide();
end

function UIInterContestXiazhuDialog:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterContestXiazhuDialog:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterContestXiazhuDialog:HandleNotification(name, body)
	
end


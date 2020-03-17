--[[
跨服擂台鼓舞
liyuan
]]

_G.UIInterContestGuwuDialog = BaseUI:new("UIInterContestGuwuDialog");
UIInterContestGuwuDialog.canSend = false

function UIInterContestGuwuDialog:Create()
	self:AddSWF("interContestGuwuDialog.swf", true, "top");
end

function UIInterContestGuwuDialog:OnLoaded(objSwf)
	objSwf.btnOK.click = function()
		if not self.canSend then return end
	
		local cut = InterContestModel:GetGuwuCount()
		if cut >= 10 then 
			FloatManager:AddNormal( StrConfig["interServiceDungeon84"]);
			return			
		end
		
		local needYuanbao = UIInterContestGuwuDialog:GetGuwuYuanbaoNum()		
		local myMoney = MainPlayerModel.humanDetailInfo.eaUnBindMoney
		if needYuanbao > myMoney then
			FloatManager:AddNormal( StrConfig["interServiceDungeon85"]);
			return 
		end		

		InterContestController:ReqCrossArenaGuWu()
		self.canSend = false
	end
	objSwf.btnCancel.click = function()
		self:Hide()
	end
	objSwf.btnClose.click = function()
		self:Hide()
	end
	
	
	objSwf.txt1.text = StrConfig['interServiceDungeon79']
	objSwf.txt2.text = StrConfig['interServiceDungeon80']
	objSwf.txt3.text = StrConfig['interServiceDungeon81']
	objSwf.txt4.text = StrConfig['interServiceDungeon82']
	
end

function UIInterContestGuwuDialog:GetGuwuYuanbaoNum()
	local constCfg = t_consts[180]
	if constCfg then
		local cut = InterContestModel:GetGuwuCount()
		-- if cut < 1 then cut = 1 end
		if cut >= 10 then 
			return 0
		end
	
		local zhuweiArr = split(constCfg.param, ',')
		return toint(zhuweiArr[cut + 1])
	end
	return 0
end

-----------------------------------------------------------------------
function UIInterContestGuwuDialog:IsTween()
	return false;
end

function UIInterContestGuwuDialog:GetPanelType()
	return 0;
end

function UIInterContestGuwuDialog:IsShowSound()
	return false;
end

function UIInterContestGuwuDialog:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	self.canSend = true
	self:UpdateInfo()	
end

function UIInterContestGuwuDialog:UpdateInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local cut = InterContestModel:GetGuwuCount()
	objSwf.txtCount.text = cut
	local needYuanbao = UIInterContestGuwuDialog:GetGuwuYuanbaoNum()
	objSwf.txt5.text = string.format(StrConfig['interServiceDungeon83'], needYuanbao)	
end

function UIInterContestGuwuDialog:OnHide()
end

function UIInterContestGuwuDialog:GetWidth()
	return 287;
end

function UIInterContestGuwuDialog:GetHeight()
	return 212;
end

function UIInterContestGuwuDialog:OnBtnCloseClick()
	self:Hide();
end

function UIInterContestGuwuDialog:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterContestGuwuDialog:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterContestGuwuDialog:HandleNotification(name, body)
	
end


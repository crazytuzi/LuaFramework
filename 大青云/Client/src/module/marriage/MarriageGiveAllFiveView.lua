
--[[
新人送玩家红包
wangshuai
]]

_G.MarryGiveAllFive = BaseUI:new("MarryGiveAllFive")

function MarryGiveAllFive:Create()
	self:AddSWF("marryMeRedPanel.swf",true,"center")
end;

function MarryGiveAllFive:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.yesBtn.click = function() self:SendClick() end;
	objSwf._buttonGroup_moneyType.change = function(e) self:OnMoneyTypeChange(e); end
	objSwf.rbYuanBao.selected = true

	objSwf.num_input.restrict = "0-9"
	objSwf.money_input.restrict = "0-9"

	objSwf.num_input.textChange = function() self:OnTextChange(); end
	objSwf.money_input.textChange = function() self:OnTextChangeMoney(); end
	objSwf.lblType.text = StrConfig['marriage914']
	objSwf.lbHBNum.text = StrConfig['marriage915']
	objSwf.rbYuanBao.label = StrConfig['marriage918']
	objSwf.rbYinLiang.label = StrConfig['marriage919']
	objSwf.txtMoney.autoSize = "left"
end;

function MarryGiveAllFive:OnShow()
	self:ShowMoney()
end

function MarryGiveAllFive:OnMoneyTypeChange()
	self:ShowMoneyType()
end

function MarryGiveAllFive:OnTextChange()
	local objSwf =self.objSwf;
	if not objSwf then return end;
	local txt = toint(objSwf.num_input.text) or 0;
	if 9999999 < txt then 
		objSwf.num_input.text = 9999999;
	end;
	self:ShowMoney()
end;

function MarryGiveAllFive:OnTextChangeMoney()
	local objSwf =self.objSwf;
	if not objSwf then return end;
	local txt = toint(objSwf.money_input.text) or 0;
	if 99999999 < txt then 
		objSwf.money_input.text = 99999999;
	end;
	self:ShowMoney()
end;

-- 显示前的判断，每个show方法第一步
function MarryGiveAllFive:ShowJudge()
	local isMyMarry = MarryUtils:GetIsIngMyMarry()
	if not isMyMarry then 
		FloatManager:AddNormal( StrConfig["marriage042"]);
		return 
	end;
	self:Show();
end

function MarryGiveAllFive:GetMoneyType()
	local objSwf =self.objSwf
	if not objSwf then return end
	if objSwf.rbYuanBao.selected then
		return enAttrType.eaUnBindMoney
	end
	if objSwf.rbYinLiang.selected then
		return enAttrType.eaUnBindGold
	end
end

function MarryGiveAllFive:ShowMoneyType()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local moneyType = self:GetMoneyType()
	local moneyName = enAttrTypeName[moneyType]
	objSwf.lblMoneyNum.text = string.format( StrConfig["marriage916"], moneyName )
	local frameName = (moneyType == enAttrType.eaUnBindMoney) and "yb" or "yl"
	objSwf.mcMoneyType:gotoAndStop(frameName)
end

function MarryGiveAllFive:ShowMoney()
	local objSwf =self.objSwf
	if not objSwf then return end
	objSwf.txtMoney.text = self:GetInputMoney()
end

function MarryGiveAllFive:GetInputMoney()
	local objSwf = self.objSwf;
	local textInput = objSwf and objSwf.money_input
	return tonumber( textInput.text ) or 0
end

function MarryGiveAllFive:GetInputNum()
	local objSwf = self.objSwf;
	local textInput = objSwf and objSwf.num_input
	return tonumber( textInput.text ) or 0
end

function MarryGiveAllFive:SendClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local num = self:GetInputNum()
	local money = self:GetInputMoney()
	if num <= 0 then --
		FloatManager:AddNormal( StrConfig["marriage205"]);
		return 
	end;	

	if money <= 0 then --marriage205
		FloatManager:AddNormal( StrConfig["marriage017"]);
		return 
	end;	

	if num > money then 
		FloatManager:AddNormal( StrConfig["marriage210"]);
		return 
	end;
	local moneyType = self:GetMoneyType()
	local myMoney = MainPlayerModel.humanDetailInfo[moneyType] or 0
	if money > myMoney then 
		local moneyName = enAttrTypeName[moneyType]
		local str = string.format( StrConfig['marriage917'], moneyName )
		FloatManager:AddNormal( str )
		return 
	end;
	
	RedPacketController:ReqSendRedPacket(1,money,num,moneyType)
end;

-- 是否缓动
function MarryGiveAllFive:IsTween()
	return true;
end

--面板类型
function MarryGiveAllFive:GetPanelType()
	return 1;
end
--是否播放开启音效
function MarryGiveAllFive:IsShowSound()
	return true;
end

function MarryGiveAllFive:IsShowLoading()
	return true;
end
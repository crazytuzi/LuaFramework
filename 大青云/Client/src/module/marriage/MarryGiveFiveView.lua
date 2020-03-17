
--[[
玩家送新人红包
wangshuai
]]

_G.MarryGiveFive = BaseUI:new("MarryGiveFive")
MarryGiveFive.DesLengthLimit = 48

function MarryGiveFive:Create()
	self:AddSWF("marryGiveFivePanel.swf",true,"center")
end;

function MarryGiveFive:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.yesBtn.click = function() self:SendClick() end;

	objSwf.num_input.restrict = "0-9"

	objSwf.num_input.textChange = function() self:OnTextChange(); end
	objSwf.desc_input.textChange = function(e) self:OnDescTextChange(e); end
end;

function MarryGiveFive:OnDescTextChange(e)
	local textInput = e.target
	if not textInput then return end
	local content = textInput.text or ""
	if string.len(content) > MarryGiveFive.DesLengthLimit then
		textInput.text = string.sub( content, 1, MarryGiveFive.DesLengthLimit )
	end
end

function MarryGiveFive:OnTextChange()
	local objSwf =self.objSwf;
	if not objSwf then return end;
	local txt = toint(objSwf.num_input.text) or 0;
	if 99999999 < txt then 
		objSwf.num_input.text = 99999999;
	end;

end;

-- 显示前的判断，每个show方法第一步
function MarryGiveFive:ShowJudge()
	local isMyMarry = MarryUtils:GetIsIngMyMarry()
	if isMyMarry then 
		FloatManager:AddNormal( StrConfig["marriage043"]);
		return 
	end;
	self:Show();
end;

function MarryGiveFive:OnShow()

end;

function MarryGiveFive:OnHide()

end;


MarryGiveFive.lastSendTime = 0;

function MarryGiveFive:SendClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local type = 11 
	local num = toint(objSwf.num_input.text) or 0;
	local blessing = objSwf.desc_input.text or "";
	if num <= 0 then 
		FloatManager:AddNormal( StrConfig["marriage017"]);
		return 
	end;
	local myMoney = MainPlayerModel.humanDetailInfo.eaUnBindGold;
	if num > myMoney then 
		FloatManager:AddNormal(StrConfig['marriage208'])
		return 
	end;
	--点击间隔
	if GetCurTime() - self.lastSendTime < 3000 then
		return;
	end
	self.lastSendTime = GetCurTime();
	MarriagController:ReqGiveRedPacket(type,num,blessing)
end;

-- 是否缓动
function MarryGiveFive:IsTween()
	return true;
end

--面板类型
function MarryGiveFive:GetPanelType()
	return 1;
end
--是否播放开启音效
function MarryGiveFive:IsShowSound()
	return true;
end

function MarryGiveFive:IsShowLoading()
	return true;
end
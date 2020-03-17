--[[
离婚，单方强制
wangshuai
]]

_G.UIDivorceOne = BaseUI:new("UIDivorceOne")

function UIDivorceOne:Create()
	self:AddSWF("marryDivorceOnePanle.swf",true,"center")
end;

function UIDivorceOne:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;

	objSwf.okBtn.click = function() self:OnOkClick()end;
	objSwf.noBtn.click = function() self:OnNoClick()end;
end;

-- 显示前的判断，每个show方法第一步
function UIDivorceOne:ShowJudge()
	local state = MarriageModel:GetMyMarryState();
	if state == MarriageConsts.marrySingle or state == MarriageConsts.marryLeave then 
		FloatManager:AddNormal( StrConfig['marriage020']);
		return 
	end;
	if state == MarriageConsts.marrySingle then 
		FloatManager:AddNormal( StrConfig['marriage020']);
		return 
	end;
	self:Show();
end;

function UIDivorceOne:OnShow()
	local cfgVal = t_consts[185].val2;

	local objSwf = self.objSwf;
	if not objSwf then return end;

	local color = "#00ff00";
	local myNum = MainPlayerModel.humanDetailInfo.eaUnBindGold;
	if myNum < cfgVal then 
		color = "#ff0000"
	end;
	objSwf.reps.htmlText = "<font color='"..color.."'>" .. 	enAttrTypeName[11] .. cfgVal .. "</font>";
end;

function UIDivorceOne:OnHide()

	

end;

function UIDivorceOne:OnOkClick()
	local cfgVal = t_consts[185].val2;
	local myNum = MainPlayerModel.humanDetailInfo.eaUnBindGold;
	if myNum < cfgVal then 
		FloatManager:AddNormal(StrConfig["marriage109"])
	return 
	end;
	MarriagController:ReqDivorce(2)
end;

function UIDivorceOne:OnNoClick()
	self:Hide()
end;


-- 是否缓动
function UIDivorceOne:IsTween()
	return true;
end

--面板类型
function UIDivorceOne:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIDivorceOne:IsShowSound()
	return true;
end

function UIDivorceOne:IsShowLoading()
	return true;
end


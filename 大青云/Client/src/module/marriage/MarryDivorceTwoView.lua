--[[
离婚，双方协议
wangshuai
]]

_G.UIDivorceTwo = BaseUI:new("UIDivorceTwo")

function UIDivorceTwo:Create()
	self:AddSWF("marryDivorceTwopanel.swf",true,"center")
end;

function UIDivorceTwo:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;

	objSwf.okBtn.click = function() self:OnOkClick()end;
	objSwf.noBtn.click = function() self:OnNoClick()end;
end;

-- 显示前的判断，每个show方法第一步
function UIDivorceTwo:ShowJudge()
	local state = MarriageModel:GetMyMarryState();
	if state == MarriageConsts.marrySingle or state == MarriageConsts.marryLeave then 
		FloatManager:AddNormal( StrConfig['marriage020']);
		return 
	end;
	--是否组队
	local isTeam = TeamModel:IsInTeam();
	if not isTeam then 
		FloatManager:AddNormal( StrConfig['marriage094']);
		return 
	end;
	
	--是否队长
	local mytema = TeamUtils:MainPlayerIsCaptain();
	if not mytema then 
		FloatManager:AddNormal( StrConfig['marriage076']);
		return 
	end;

	self:Show();
end;

function UIDivorceTwo:OnShow()
	local cfgVal = t_consts[185].val1;

	local objSwf = self.objSwf;
	if not objSwf then return end;

	local color = "#00ff00";
	local myNum = MainPlayerModel.humanDetailInfo.eaUnBindGold;
	if myNum < cfgVal then 
		color = "#ff0000"
	end;
	objSwf.reps.htmlText = "<font color='"..color.."'>" .. 	enAttrTypeName[11] .. cfgVal .. "</font>";

end;

function UIDivorceTwo:OnHide()

end;

function UIDivorceTwo:OnOkClick()
	local cfgVal = t_consts[185].val1;
	local myNum = MainPlayerModel.humanDetailInfo.eaUnBindGold;
	if myNum < cfgVal then 
		FloatManager:AddNormal(StrConfig["marriage109"])
		return 
	end;

	MarriagController:ReqDivorce(1)
end;

function UIDivorceTwo:OnNoClick()
	self:Hide()
end;




-- 是否缓动
function UIDivorceTwo:IsTween()
	return true;
end

--面板类型
function UIDivorceTwo:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIDivorceTwo:IsShowSound()
	return true;
end

function UIDivorceTwo:IsShowLoading()
	return true;
end

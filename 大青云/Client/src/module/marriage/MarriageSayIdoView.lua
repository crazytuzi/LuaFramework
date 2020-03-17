--[[
结婚是否同意
wangshuai
]]

_G.UIMarrySayIdo = BaseUI:new("UIMarrySayIdo")

function UIMarrySayIdo:Create()
	self:AddSWF("marrySayIdo.swf",true,"center")
end;

function UIMarrySayIdo:OnLoaded(objSwf)
	objSwf.yesBtn.click = function() self:YesBtn()end;
	objSwf.noBtn.click = function() self:NoBtn()end;
end;

function UIMarrySayIdo:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local name = TeamModel:GetMemberName(MarriageModel.OpenMarryRoleId)
	objSwf.tfName.htmlText = name;
	local prof = MainPlayerModel.humanDetailInfo.eaProf;
	local infoCfg = t_playerinfo[prof];
	if not infoCfg then return; end
	if infoCfg.sex == 0 then
		objSwf.text1.label = StrConfig["marriage088"];
		objSwf.text2.label = StrConfig["marriage089"];
		objSwf.text3.label = StrConfig["marriage090"];
	else
		objSwf.text1.label = StrConfig["marriage091"];
		objSwf.text2.label = StrConfig["marriage092"];
		objSwf.text3.label = StrConfig["marriage093"];
	end
end

function UIMarrySayIdo:OnHide()

end;

function UIMarrySayIdo:YesBtn()

	--是否组队
	local isTeam = TeamModel:IsInTeam();
	if not isTeam then 
		FloatManager:AddNormal( StrConfig['marriage094']);
		return 
	end;
	
	MarriagController:ReqMarry(1)
	self:Hide();
end;

function UIMarrySayIdo:NoBtn()
	local func = function() 
		local func2 = function() 
			MarriagController:ReqMarry(2)
			self:Hide();
		end;
		UIConfirm:Open( StrConfig['marriage083'],func2)
	end;
	UIConfirm:Open( StrConfig['marriage082'],func)
end;


-- 是否缓动
function UIMarrySayIdo:IsTween()
	return true;
end


function UIMarrySayIdo:IsShowLoading()
	return true;
end
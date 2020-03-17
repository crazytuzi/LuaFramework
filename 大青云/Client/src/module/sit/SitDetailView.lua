--[[
打坐详情查看
2015年5月21日21:36:21
haohu
]]

_G.UISitDetail = BaseUI:new('UISitDetail')

function UISitDetail:Create()
	self:AddSWF('sitDetailPanel.swf', true, nil)
end

function UISitDetail:OnLoaded( objSwf )
	objSwf.btnClose.click       = function() self:OnBtnCloseClick() end
	objSwf.btnGoCity.click      = function() self:OnBtnGoCityClick() end
	objSwf.btnGoFormation.click = function() self:OnBtnGoFormationClick() end
end

function UISitDetail:OnShow()
	self:UpdateShow()
	self:UpdateLayout()
end

function UISitDetail:OnHide()
	self:UpdateLayout()
end

function UISitDetail:UpdateLayout()
	self.parent:UpdateLayout()
end

function UISitDetail:UpdateShow()
	self:ShowFormationSitInfo()
	self:ShowMajorCitySitInfo()
end

function UISitDetail:ShowFormationSitInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local numRole = SitModel:GetRoleNum();
	objSwf.txtFormBunus.htmlText = self:GetFormationDes(numRole)
end

function UISitDetail:ShowMajorCitySitInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.txtCityBonus.htmlText = self:GetMajorCitySitDes()
end

-- 根据打坐人数获取相关阵法描述
function UISitDetail:GetFormationDes(roleNum)
	local name = SitUtils:GetFormationName(roleNum)
	local bonus = SitUtils:GetFormationBonus(roleNum)
	return string.format( StrConfig['sit005'], name, bonus )
end

-- 根据是否主城打坐区打坐获取相关描述
function UISitDetail:GetMajorCitySitDes()
	local isInSitArea = SitController:IsInSitArea()
	local bonus = SitUtils:GetMajorCityBonus( isInSitArea )
	return string.format( StrConfig['sit006'], bonus )
end

function UISitDetail:OnBtnCloseClick()
	self:Hide()
end

function UISitDetail:OnBtnGoCityClick()
	if SitController:IsInSitArea() then
		FloatManager:AddNormal( StrConfig['sit203'] )
		return
	end
	if not MapUtils:CanTeleport() then
		FloatManager:AddNormal( StrConfig['sit204'] )
		return
	end
	local vecTarget = SitController:GetSitAreaVec()
	local completeFunc = function()
		SitController:ReqSit(sitId, index)
	end
	MainPlayerController:DoAutoRun( MapPath.MainCity, vecTarget, completeFunc )
end

function UISitDetail:OnBtnGoFormationClick()
	if UISitNearby:IsShow() then
		UISitNearby:Hide()
	else
		UISitNearby:Show()
	end
end

---------------------------消息处理---------------------------------
--监听消息列表
function UISitDetail:ListNotificationInterests()
	return {
		NotifyConsts.SitFormationChange,
	}
end

--处理消息
function UISitDetail:HandleNotification(name, body)
	if name == NotifyConsts.SitFormationChange then
		self:ShowFormationSitInfo()
	end
end
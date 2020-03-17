--[[
	2015年10月23日20:35:04
	wangyanwei
	天降福神notice
]]

_G.UIMoscotComeNotice = BaseUI:new('UIMoscotComeNotice');

function UIMoscotComeNotice:Create()
	self:AddSWF('mascotComeNotice.swf',true,'bottom');
end

function UIMoscotComeNotice:OnLoaded(objSwf)
	objSwf.btn_close.click = function () self:HidePanel(); end
end

function UIMoscotComeNotice:OnShow()
	self:PortalDate();
end

function UIMoscotComeNotice:GetWidth()
	return 237
end

function UIMoscotComeNotice:GetHeight()
	return 265
end

function UIMoscotComeNotice:OnCloseHandler()
	
end

function UIMoscotComeNotice:PortalDate()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local portalNum = ActivityMascotCome:GetPortalNum();
	objSwf.portalNum.num = portalNum;
end

function UIMoscotComeNotice:HidePanel()
	local portalMapID = ActivityMascotCome:GetPortalMapID();
	MascotComeNoticeManager:CloseMapId(portalMapID);
	self:Hide();
end

function UIMoscotComeNotice:OnHide()
	
end

function UIMoscotComeNotice:UpDateNotice()

	local activity = ActivityModel:GetActivity(ActivityConsts.MascotCome);
	if not activity then return end

	local isOpen = activity:IsOpen();
	if not isOpen then self:Hide(); return end

	
	local mapID = CPlayerMap:GetCurMapID();
	if not t_map[mapID] then return end
	
	local portalMapID = ActivityMascotCome:GetPortalMapID();
	if portalMapID == 0 then return end
	if mapID ~= portalMapID then return end
	
	local activityLevel = t_activity[ActivityConsts.MascotCome].needLvl;
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	
	if level < activityLevel then
		return 
	end
	
	if not MascotComeNoticeManager:GetHaveId(portalMapID) then
		MascotComeNoticeManager:AddMapId(portalMapID);
	end
	
	if MascotComeNoticeManager:GetIDCfg(portalMapID) then
		if self:IsShow() then
			self:OnShow();
		else
			self:Show();
		end
	end
end

function UIMoscotComeNotice:HandleNotification(name,body)
	if name == NotifyConsts.MascotComeNotice then
		self:UpDateNotice();
	end
end
function UIMoscotComeNotice:ListNotificationInterests()
	return {
		NotifyConsts.MascotComeNotice,
	}
end
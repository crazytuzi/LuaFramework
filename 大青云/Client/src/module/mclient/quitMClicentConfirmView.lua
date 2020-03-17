_G.UIQuitMClicentConfirmView = BaseUI:new("UIQuitMClicentConfirmView")

function UIQuitMClicentConfirmView:Create()
	self:AddSWF("quitMClicentConfirmPanel.swf", true, "center")
end

function UIQuitMClicentConfirmView:OnLoaded(objSwf)

	objSwf.btnClose.click = function() self:Hide(); end
	objSwf.tfWorldBossTime.htmlText = " "
	objSwf.txtWorldboss.htmlText = " "
end
function UIQuitMClicentConfirmView:OnShow()
	self:ShowHuoYueDuInfo()
	self:ShowWorldBoss()
end
--显示活跃度信息
function UIQuitMClicentConfirmView:ShowHuoYueDuInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local datalist = MClientUtil:GetHuoYueDuList();
	objSwf.listtask.dataProvider:cleanUp();
	objSwf.listtask.dataProvider:push(unpack(datalist));
	objSwf.listtask:invalidateData();
	objSwf.listtask:scrollToIndex(0);
end
--显示世界boss时间
function UIQuitMClicentConfirmView:ShowWorldBoss()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local datalist = MClientUtil:GetHuoYueDuList();
	local lenDatalist = #datalist
	if lenDatalist >4 then
		lenDatalist = 4
	end
	local hour,min,sec = self:OnBackNowLeaveTime()
	if toint(hour)<23 and toint(min)<31 then--22:30半之前显示
		objSwf.tfWorldBossTime._y = lenDatalist*30 + 148
		objSwf.txtWorldboss._y = lenDatalist*30 + 148
		objSwf.tfWorldBossTime.htmlText = string.format( StrConfig['mclient108'], MClientUtil:GetTimeStr() )
		objSwf.txtWorldboss.htmlText = StrConfig['mclient109']
	end
end
--换算时间
function UIQuitMClicentConfirmView:OnBackNowLeaveTime()
	local hour,min,sec = CTimeFormat:sec2format(GetDayTime());
	return hour,min,sec
end

function UIQuitMClicentConfirmView:HandleNotification(name, body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.HuoYueDuListRefresh then
		self:ShowHuoYueDuInfo()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:ShowHuoYueDuInfo()
		end
	end
end
function UIQuitMClicentConfirmView:ListNotificationInterests()
	return {
		NotifyConsts.HuoYueDuListRefresh,
		NotifyConsts.PlayerAttrChange
	};
end











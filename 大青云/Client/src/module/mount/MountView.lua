--[[
坐骑界面主面板
zhangshuhui
2014年11月05日17:20:20
]]

_G.UIMount = BaseUI:new("UIMount");

UIMount.tabButton = {};

UIMount.isopenpanel = false;

function UIMount:Create()
	self:AddSWF("mountMainPanel.swf", true, "center");
	
	self:AddChild(UIMountBasic, MountConsts.TABMOUNT);
	self:AddChild(UIMountSkin, MountConsts.TABMOUNTSKIN);
	-- self:AddChild(UIMountLingShou, FuncConsts.MountLingShou);
	
	self:AddChild(UIMountFirstDay, MountConsts.TAB_MountFirstDay);
end

function UIMount:OnLoaded(objSwf, name)
	
	self:GetChild(MountConsts.TABMOUNT):SetContainer(objSwf.childPanel);
	self:GetChild(MountConsts.TABMOUNTSKIN):SetContainer(objSwf.childPanel);
	-- self:GetChild(FuncConsts.MountLingShou):SetContainer(objSwf.childPanel);
	--
	self:GetChild(MountConsts.TAB_MountFirstDay):SetContainer( objSwf.childPanel_yunying );

	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	--
	self.tabButton[MountConsts.TABMOUNT] = objSwf.btnBasic;
	self.tabButton[MountConsts.TABMOUNTSKIN] = objSwf.btnSkin;
	objSwf.btnSkin._x = objSwf.btnBasic._x +objSwf.btnBasic._width;
	-- self.tabButton[FuncConsts.MountLingShou] = objSwf.btnLingShou;
	for name,btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(name); end;
	end
end

function UIMount:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function UIMount:IsShowLoading()
	return true;
end

function UIMount:IsTween()
	return true;
end

function UIMount:GetPanelType()
	return 1;
end

function UIMount:IsShowSound()
	return true;
end

function UIMount:GetWidth()
	return 1397;
end

function UIMount:GetHeight()
	return 823;
end

function UIMount:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
--	self:UpdateMask()
	self:UpdateCloseButton()
end

function UIMount:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 100
	objSwf.mcMask._height = wHeight + 100
end

function UIMount:WithRes()
	local withResList = {};
	table.push(withResList,"mountBasicPanel.swf");
	return withResList;
end

function UIMount:OnShow(name)
	self.isopenpanel = true;
	--显示参数
	-- if self.args and #self.args > 0 then
	-- 	if self.args[1] and self.args[1] > 0 then
	-- 		self:OnTabButtonClick(FuncConsts.MountLingShou);
	-- 	end
	-- else
		self:OnTabButtonClick(MountConsts.TABMOUNT);
	-- end

	-- if MountFirstDay:GetActive() == true then
		-- self:ShowChild( MountConsts.TAB_MountFirstDay, false );
		-- self:UpdateOperActPanelPos();
	-- end
	
	self.isopenpanel = false;
	
	--self:UpdateMask()
	
	self:UpdateCloseButton()
	self:InitRedPoint()
	self:RegisterTimes()
end

UIMount.timerKey = nil;
function UIMount:InitRedPoint( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	if MountUtil:CheckCanLvUp(  ) then
		PublicUtil:SetRedPoint(objSwf.btnBasic, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnBasic, nil, 0)
	end
end

function UIMount:RegisterTimes( )
	self.timerKey = TimerManager:RegisterTimer(function()
		self:InitRedPoint()
	end,1000,0); 	
end

function UIMount:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize() 
	--objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1360 ), 1360 )
end
-- 更新运营活动面板x位置
function UIMount:UpdateOperActPanelPos()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not UIMountFirstDay:IsShow() then
		return
	end
	local mcYunYing = objSwf.childPanel_yunying;
	
	mcYunYing._x = self:GetWidth();
end

--点击标签
function UIMount:OnTabButtonClick(name)
	if not self.tabButton[name] then
		return;
	end
	for uiname, btn in pairs(self.tabButton) do
		local childPanel = self:GetChild(uiname);
		if childPanel then
			if uiname == name then
				childPanel:Show();
			else
				childPanel:Hide();
			end
		end
	end
	self.tabButton[name].selected = true;
end

--点击关闭按钮
function UIMount:OnBtnCloseClick()
	self:Hide();
end

function UIMount:OnHide()
	RemindController:ClearRemind(RemindConsts.Type_MountUp);
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
end
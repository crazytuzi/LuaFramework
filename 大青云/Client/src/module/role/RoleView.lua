--[[
角色界面主面板
lizhuangzhuang
2014年7月21日10:32:06
]]

_G.UIRole = BaseUI:new("UIRole");

UIRole.tabButton = {};

UIRole.BASIC      = "basic"
UIRole.TITLE      = "title"
UIRole.BOGEY_PILL = "bogeypill"
UIRole.INFO       = "info"
UIRole.SUPER      = "super"
UIRole.MARRY      = "marry"
-- UIRole.Jinjie      = "jinjie"


function UIRole:Create()
	self:AddSWF("roleMainPanelV.swf", true, "center");
	
	self:AddChild( UIRoleBasic, UIRole.BASIC )
	self:AddChild( UITitle, UIRole.TITLE )
	self:AddChild( UIBogeyPill, UIRole.BOGEY_PILL )
	self:AddChild( UIRoleInfo, UIRole.INFO )
	self:AddChild( UIRoleSuper, UIRole.SUPER )
	self:AddChild( UIMarryMain, UIRole.MARRY )
	-- self:AddChild( UIRealmMainView, UIRole.Jinjie )
end

function UIRole:OnLoaded(objSwf, name)
	self:GetChild( UIRole.BASIC ):SetContainer( objSwf.childPanel )
	self:GetChild( UIRole.TITLE ):SetContainer( objSwf.childPanel )
	self:GetChild( UIRole.BOGEY_PILL ):SetContainer( objSwf.childPanel )
	self:GetChild( UIRole.INFO ):SetContainer( objSwf.childPanel )
	self:GetChild( UIRole.SUPER ):SetContainer( objSwf.childPanel )
	self:GetChild( UIRole.MARRY ):SetContainer( objSwf.childPanel )
	-- self:GetChild( UIRole.Jinjie ):SetContainer( objSwf.childPanel )
	--
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	--
	self.tabButton[ UIRole.BASIC ]      = objSwf.btnBasic
	self.tabButton[ UIRole.TITLE ]      = objSwf.btnTitle
	self.tabButton[ UIRole.BOGEY_PILL ] = objSwf.btnAttribute
	self.tabButton[ UIRole.INFO ]       = objSwf.btnInfo
	self.tabButton[ UIRole.SUPER ]       = objSwf.btnSuper
	self.tabButton[ UIRole.MARRY ]       = objSwf.btnMarry
	objSwf.btnJinjie._visible = false     -- 屏蔽境界
	-- self.tabButton[ UIRole.Jinjie ]       = objSwf.btnJinjie
	objSwf.btnMarry._visible = false     -- 暂时屏蔽结婚 changer:houxudong
	for name, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(name); end;
	end
	objSwf.btnSuper._visible = false
end

function UIRole:OnShow()
	-- self:InitPageBtn()-- 丹药
	self:InitRedPoint()
	self:RegisterTimes()
	if #self.args > 0 then
		if self.tabButton[self.args[1]] then
			self:OnTabButtonClick(self.args[1]);
			return;
		end
	end
	if UIMainXiuweiPool.isDanyao then
		self:OnTabButtonClick( UIRole.BOGEY_PILL  );
	else
		self:OnTabButtonClick( UIRole.BASIC  );
	end
	-- self:InitRedPoint()
	

end

function UIRole:InitPageBtn( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	-- 境界
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	local cfg = t_funcOpen[FuncConsts.XiuweiPool];
	if not cfg then return false; end
	local openLevel = cfg.open_prama
	if not openLevel then return false end
	if curRoleLvl >= toint(openLevel) then
		objSwf.btnAttribute._visible = true
	else
		objSwf.btnAttribute._visible = false
	end
end
--丹药红点提示 
UIRole.timeKey = nil;
UIRole.pillLoader = nil;
function UIRole:InitRedPoint()
	local objSwf = self.objSwf
	if not objSwf then return; end
	if RoleUtil:GetBogeyPillList(false) or HeChengUtil:CheckCanUsePill( ) then
		PublicUtil:SetRedPoint(objSwf.btnAttribute,nil,1)
	else
		PublicUtil:SetRedPoint(objSwf.btnAttribute)
	end
	-- if RealmUtil:CheckCanOperation() then
		-- PublicUtil:SetRedPoint(objSwf.btnJinjie,nil,1)
	-- else
		-- PublicUtil:SetRedPoint(objSwf.btnJinjie)
	-- end
end

function UIRole:RegisterTimes()
	self.timeKey = TimerManager:RegisterTimer(function()
		-- print("是否可以使用丹药",RoleUtil:GetBogeyPillList(false))
		self:InitRedPoint()
	end,1000,0); 
end

function UIRole:OnDelete()
	for k, v in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

--人物面板中详细信息为隐藏面板，不计算到总宽度内
function UIRole:GetWidth()
	return 1146;
end

function UIRole:GetHeight()
	return 687;
end

function UIRole:IsTween()
	return true;
end

function UIRole:GetPanelType()
	return 0;
end

function UIRole:ESCHide()
	return true;
end

function UIRole:IsShowLoading()
	return true;
end

function UIRole:IsShowSound()
	return true;
end

function UIRole:WithRes()
	return { "roleBasicPanelV.swf","pointAddPanel.swf","bagQuickEquitPanel.swf"};
end

--点击标签
function UIRole:OnTabButtonClick(name)
	self:TurnToSubpanel(name)
	if UIBogeyPilluseListView:IsShow() then
		UIBogeyPilluseListView:Hide()
	end
end

function UIRole:TurnToSubpanel(name)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self.tabButton[name].selected = true;
	self:ShowChild(name);
end

--获取妖丹按钮
function UIRole:GetPillBtn()
	if not self:IsShow() then return; end
	return self.objSwf.btnAttribute;
end

--点击关闭按钮
function UIRole:OnBtnCloseClick()
	self:Hide();
	if UIBogeyPilluseListView:IsShow() then
		UIBogeyPilluseListView:Hide()
	end
end

function UIRole:OnHide()
	UIXiuweiPool.isDanyao = false
	RoleController:RemindAddPoint()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	if self.pillLoader then  
		self:RemoveRedPoint(self.pillLoader)
		self.pillLoader = nil;
	end
	UIMainXiuweiPool.isDanyao = false
end
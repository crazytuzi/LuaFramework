--[[
帮派操作面板
liyuan
2014年11月25日8:21:55
]]

_G.UIUnionOper = BaseUI:new("UIUnionOper");

UIUnionOper.btnName = nil;	--名称
UIUnionOper.targetDuty = 0;	--目标帮派职位
UIUnionOper.targetRoleId = 0;--目标的id
UIUnionOper.targetRoleName = ''--目标名
UIUnionOper.targetRoleIcon = 0
UIUnionOper.targetRoleVipLv = 0
UIUnionOper.targetRoleLv = 0
UIUnionOper.operList = nil;--操作列表

function UIUnionOper:Create()
	self:AddSWF("bagOperPanel.swf",true,"top");
end

function UIUnionOper:OnLoaded(objSwf,name)
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end;
end

function UIUnionOper:OnShow(name)
	self:DoShowPanel();
end

function UIUnionOper:OnHide()
	self.btnName = nil;
end

--在目标位置打开操作面板
function UIUnionOper:Open(btnName,targetDuty,targetRoleId,targetRoleName,roleLv,roleVipLv,roleIcon)
	self.btnName = btnName
	self.targetDuty = targetDuty
	self.targetRoleId = targetRoleId
	self.targetRoleName = targetRoleName
	self.targetRoleLv = roleLv
	self.targetRoleVipLv = roleVipLv
	self.targetRoleIcon = roleIcon
	if self:IsShow() then
		self:DoShowPanel();
	else
		self:Show();
	end
end

function UIUnionOper:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self:GetSWF("UIUnionOper");
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		if not self.btnName then
			self:Hide();
			return;
		end
		local slotTarget = string.gsub(self.btnName._target,"/",".");
		local listTarget = string.gsub(objSwf._target, "/",".");
		if string.find(body.target,slotTarget) or string.find(body.target,listTarget) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end

function UIUnionOper:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end

function UIUnionOper:DoShowPanel()
	local objSwf = self:GetSWF("UIUnionOper");
	if not objSwf then return; end
	local pos = nil;
	if self.btnName then
		pos = UIManager:GetMcPos(self.btnName);
		local width = self.btnName.width or self.btnName._width;
		local height = self.btnName.height or self.btnName._height;
		pos.x = pos.x + width/2;
		pos.y = pos.y + height;
	else
		pos = _sys:getRelativeMouse();
	end
	objSwf._x = pos.x;
	objSwf._y = pos.y-5;
	
	-- FPrint('UIUnionOper:DoShowPanel()')
	self.operList = UnionUtils:GetOperList(self.targetRoleId, self.targetDuty)
	if not self.operList then self:Hide() return end
	-- FPrint('self.operList = UnionUtils:GetOperList')
	local len = #self.operList;
	if len <= 0 then
		self:Hide();
		return;
	end
	objSwf.list.dataProvider:cleanUp();
	for i=1,len do
		objSwf.list.dataProvider:push(self.operList[i].name);
	end
	objSwf.list.height = len*20+10;
	objSwf.bg.height = len*20+10;
	objSwf.list:invalidateData();
end

--点击操作列表
function UIUnionOper:OnListItemClick(e)
	self:Hide();
	if not self.operList[e.index+1] then
		return;
	end
	
	local operId = self.operList[e.index+1].oper
	local unionCommand = UnionCommandManager:GetCommand(operId)
	
	if unionCommand then 
		local data = {operId = operId, targetRoleId = self.targetRoleId, targetRoleName = self.targetRoleName,roleLv = self.targetRoleLv,roleVipLv = self.targetRoleVipLv,roleIcon = self.targetRoleIcon}
		unionCommand:ExecuteCommand(data) 
	else
		FPrint('没有找到操作对应的命令'..operId)
		return
	end
end




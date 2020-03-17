--[[
GM操作
lizhuangzhuang
2015年10月16日15:01:45
]]

_G.UIGMRoleOper = BaseUI:new("UIGMRoleOper");

UIGMRoleOper.operlist = nil;

UIGMRoleOper.tarUid = nil;--目标uid

function UIGMRoleOper:Create()
	self:AddSWF("chatRoleOper.swf",true,"center");
end

function UIGMRoleOper:OnLoaded(objSwf)
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
end

function UIGMRoleOper:OnShow()
	self:ShowList();
end

function UIGMRoleOper:Open(uid)
	self.tarUid = uid;
	if self:IsShow() then
		self:ShowList();
	else
		self:Show();
	end
end

function UIGMRoleOper:HandleNotification(name,body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		local target = string.gsub(objSwf._target, "/",".");
		if string.find(body.target,target) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end

function UIGMRoleOper:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end

function UIGMRoleOper:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.operlist = {};
	for i,oper in ipairs(GMConsts.AllOper) do
		local vo = {};
		vo.name = GMConsts:GetOperName(oper);
		vo.oper = oper;
		table.push(self.operlist,vo);
	end
	--
	local len = #self.operlist;
	if len <= 0 then
		self:Hide();
		return;
	end
	objSwf.list.dataProvider:cleanUp();
	for i,vo in ipairs(self.operlist) do
		objSwf.list.dataProvider:push(vo.name);
	end
	local height = len*20+10;
	objSwf.list.height = height;
	objSwf.bg.height = height;
	objSwf.list:invalidateData();
	
	local pos = _sys:getRelativeMouse();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf._x = pos.x+15;
	local y = pos.y - 30;
	if y+height > wHeight then
		y = wHeight-height;
	end
	objSwf._y = y;
end

function UIGMRoleOper:OnListItemClick(e)
	if not self.operlist[e.index+1] then
		return;
	end
	local oper = self.operlist[e.index+1].oper;
	for _,p in ipairs(GMConsts.AllOper) do
		if p == oper then
			GMController:DoGMOper(oper,self.tarUid);
			break;
		end
	end
	self:Hide();
end

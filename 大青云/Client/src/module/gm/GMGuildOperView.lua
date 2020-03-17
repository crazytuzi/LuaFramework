--[[
GM帮派操作
lizhuangzhuang
2015年10月16日15:01:45
]]

_G.UIGMGuildOper = BaseUI:new("UIGMGuildOper");

UIGMGuildOper.operlist = nil;

UIGMGuildOper.tarUid = nil;--目标uid
UIGMGuildOper.guildUid = nil;

function UIGMGuildOper:Create()
	self:AddSWF("chatRoleOper.swf",true,"center");
end

function UIGMGuildOper:OnLoaded(objSwf)
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
end

function UIGMGuildOper:OnShow()
	self:ShowList();
end

function UIGMGuildOper:Open(uid,guildUid)
	self.tarUid = uid;
	self.guildUid = guildUid;
	if self:IsShow() then
		self:ShowList();
	else
		self:Show();
	end
end

function UIGMGuildOper:HandleNotification(name,body)
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

function UIGMGuildOper:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end

function UIGMGuildOper:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.operlist = {};
	for i,oper in ipairs(GMConsts.AllGOper) do
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

function UIGMGuildOper:OnListItemClick(e)
	if not self.operlist[e.index+1] then
		return;
	end
	local oper = self.operlist[e.index+1].oper;
	for _,p in ipairs(GMConsts.AllGOper) do
		if p == oper then
			GMController:DoGMGuildOper(oper,self.tarUid,self.guildUid);
			break;
		end
	end
	self:Hide();
end
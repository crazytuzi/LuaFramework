--[[
副本排行榜左键菜单
2015年4月10日12:15:21
haohu
]]

_G.UIDungeonRankOper = BaseUI:new("UIDungeonRankOper");

function UIDungeonRankOper:Create()
	self:AddSWF( "chatRoleOper.swf", true, "center" );
end

function UIDungeonRankOper:OnLoaded( objSwf )
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
end

function UIDungeonRankOper:OnShow()
	self:UpdateShow();
end

function UIDungeonRankOper:OnHide()
	self.rankVO = nil;
end

function UIDungeonRankOper:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.list;
	self.operlist = self:GetOperList( self.rankVO );
	local len = #self.operlist;
	if len <= 0 then
		self:Hide();
		return;
	end
	list.dataProvider:cleanUp();
	for i, vo in ipairs( self.operlist ) do
		list.dataProvider:push(vo.name);
	end
	-- 高度调整
	local height = len * 20 + 10;
	list.height = height;
	objSwf.bg.height = height;
	list:invalidateData();
	-- 位置调整
	local pos = _sys:getRelativeMouse();
	objSwf._x = pos.x + 15;
	objSwf._y = pos.y + 15;
end

function UIDungeonRankOper:GetOperList(rankVO)
	local list = {};
	for _, oper in ipairs( DungeonConsts.AllROper ) do
		local show = self:CheckOper(oper, rankVO);
		if show then
			local vo = {};
			vo.name = DungeonConsts:GetOperName(oper);
			vo.oper = oper;
			table.push(list, vo);
		end
	end
	return list;
end

-- 检查菜单中是否出现某项oper
function UIDungeonRankOper:CheckOper( oper, rankVO )
	if oper == DungeonConsts.ROper_ShowInfo then
		return true;
	end
end

function UIDungeonRankOper:OnListItemClick(e)
	if not self.operlist[e.index + 1] then
		return;
	end
	local oper = self.operlist[e.index + 1].oper;
	if oper == DungeonConsts.ROper_ShowInfo then
		RoleController:ViewRoleInfo( self.rankVO.id );
	end
	self:Hide();
end

function UIDungeonRankOper:ListNotificationInterests()
	return { NotifyConsts.StageClick, NotifyConsts.StageFocusOut };
end

function UIDungeonRankOper:HandleNotification(name,body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		local target = string.gsub( objSwf._target, "/", "." );
		if string.find( body.target, target ) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end

function UIDungeonRankOper:Open(dungeonId, rank)
	self.rankVO = DungeonModel:GetRankVO(dungeonId, rank);
	self:Show();
end
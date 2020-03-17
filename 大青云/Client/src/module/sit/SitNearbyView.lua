--[[
附近的打坐列表
郝户
2014年11月12日12:00:06
]]

_G.UISitNearby = BaseUI:new("UISitNearby");

function UISitNearby:Create()
	self:AddSWF( "sitNearbyPanel.swf", true, nil );
end

function UISitNearby:OnLoaded(objSwf)
	objSwf.txtTittle.text  = StrConfig['sit101'];
	objSwf.tableHead1.text = StrConfig['sit102'];
	objSwf.tableHead2.text = StrConfig['sit103'];
	objSwf.tableHead3.text = StrConfig['sit104'];
	objSwf.txtPrompt.text  = StrConfig['sit105'];
	--
	objSwf.list.itemClick = function(e) self:OnSitItemClick(e); end
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
end

function UISitNearby:OnShow()
	self:UpdateShow()
	self:UpdateLayout()
	self:StartTimer()
end

function UISitNearby:OnHide()
	self:UpdateLayout()
	self:StopTimer()
end

function UISitNearby:UpdateLayout()
	self.parent:UpdateLayout()
end

function UISitNearby:UpdateShow()
	local list = self.objSwf and self.objSwf.list;
	if not list then return; end
	list.dataProvider:cleanUp();
	local nearbySitUIDataList = self:GetNearbySitUIDataList();
	for i = 1, #nearbySitUIDataList do
		list.dataProvider:push( nearbySitUIDataList[i] );
	end
	list:invalidateData();
end

-- 获取附近打坐阵法列表UIData
function UISitNearby:GetNearbySitUIDataList()
	local list = {};
	local nearbySit = SitModel:GetNearbySit()
	for _, srcVO in ipairs( nearbySit ) do
		local vo = {};
		vo.id       = srcVO.id;
		vo.roleNum  = srcVO.roleNum;
		vo.index    = srcVO.index;
		vo.posX     = srcVO.x;
		vo.posY     = srcVO.y;
		vo.roleName = srcVO.roleName;
		vo.formationTxt = SitUtils:GetFormationName( vo.roleNum );
		table.push( list, UIData.encode(vo) );
	end
	return list;
end

function UISitNearby:OnSitItemClick(e)
	local formationInfo = e.item;
	if not formationInfo then return; end
	local sitId = formationInfo.id;
	if not sitId then return end
	--取消当前打坐
	SitController:ReqCancelSit();
	--寻路过去参加别人的打坐阵法
	local formationX = formationInfo.posX;
	local formationY = formationInfo.posY;
	local index      = formationInfo.index;
	local desX, desY;
	if index == 0 then
		desX = formationX;
		desY = formationY;
	elseif index == 1 then
		desX = formationX + SitConsts.FormationW;
		desY = formationY;
	elseif index == 2 then
		desX = formationX;
		desY = formationY + SitConsts.FormationH;
	elseif index == 3 then
		desX = formationX + SitConsts.FormationW;
		desY = formationY + SitConsts.FormationH;
	end
	local desVec = _Vector3.new( desX, desY, 0 );
	SitController:AutoRunToSit( desVec, sitId, index );
end

function UISitNearby:OnBtnCloseClick()
	self:Hide()
end

---------------------------消息处理---------------------------------
--监听消息列表
function UISitNearby:ListNotificationInterests()
	return {
		NotifyConsts.SitNearby,
		NotifyConsts.SitFormationChange,
	};
end

--处理消息
function UISitNearby:HandleNotification(name, body)
	if name == NotifyConsts.SitNearby then
		self:UpdateShow()
	elseif name == NotifyConsts.SitFormationChange then
		self:UpdateShow()
	end
end

---------------------------每分钟请求附近打坐列表处理---------------------------------
local time
local timerKey
function UISitNearby:StartTimer()
	time = 0
	local cb = function() self:OnTimer() end
	timerKey = TimerManager:RegisterTimer( cb, SitConsts.QueryNearbySitInterval, 0 );
	self:QueryNearBySit()
end

function UISitNearby:OnTimer()
	time = time + 1
	self:QueryNearBySit()
end

function UISitNearby:QueryNearBySit()
	SitController:ReqNearBySit()
end

function UISitNearby:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
		time = 0;
	end
end
--[[
	2015年7月15日, PM 02:57:05
	主宰之路扫荡完成提醒
	wangyanwei
]]

_G.RemindDominateRouteQueue = setmetatable({},{__index=RemindQueue});

RemindDominateRouteQueue.isShow = true;
function RemindDominateRouteQueue:GetType()
	return RemindConsts.Type_DominateRoute;
end

function RemindDominateRouteQueue:GetLibraryLink()
	return "RemindDominate";
end

function RemindDominateRouteQueue:GetPos()
	return 2;
end

--是否显示
function RemindDominateRouteQueue:GetIsShow()
	return self.isShow;
end

function RemindDominateRouteQueue:GetShowIndex()
	return 14;
end

function RemindDominateRouteQueue:GetBtnWidth()
	return 60;
end

RemindDominateRouteQueue.dominateRoutedata = {};
function RemindDominateRouteQueue:AddData(data)
	self.dominateRoutedata = data;
	self.isShow = true
	self:RefreshData();
end

function RemindDominateRouteQueue:DoClick()
	local data = self.dominateRoutedata;
	UIDominateRouteMopupInfo:Open(data.id,data.num);
	self.dominateRoutedata = {};
	self.isShow = false;
	self:RefreshData();
end

--鼠标移上
function RemindDominateRouteQueue:DoRollOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["remind010"]));
end
--鼠标移出处理
function RemindDominateRouteQueue:DoRollOut()
	TipsManager:Hide();
end
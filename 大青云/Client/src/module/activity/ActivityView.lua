--[[
活动主面板
lizhuangzhuang
2014年12月3日16:35:30
]]

_G.UIActivity = BaseUI:new("UIActivity");

UIActivity.activityList = nil;
UIActivity.currId = 0;--当前显示的活动id

function UIActivity:Create()
	self:AddSWF("activityPanel.swf",true,"center");
	
	self:AddChild(UIActivityDefault,"default");
end

function UIActivity:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.list.itemClick = function(e) self:OnItemClick(e); end
end

function UIActivity:WithRes()
	return {"activityDefault.swf"};
end

function UIActivity:IsTween()
	return true;
end

function UIActivity:GetPanelType()
	return 1;
end

function UIActivity:IsShowSound()
	return true;
end

function UIActivity:GetHeight()
	return 650;
end

function UIActivity:IsShowLoading()
	return true;
end


function UIActivity:OnShow()
	self:ShowList();
	if self.args and #self.args > 0 then
		for i,vo in ipairs(self.activityList) do
			if vo.id == self.args[1] then
				self.objSwf.list.selectedIndex = i-1;
				self:ShowActivity(self.args[1]);
				break;
			end
		end
	end
end

function UIActivity:OnHide()
	self.currId = 0;
	--是否有组队提示
	TeamUtils:UnRegisterNotice(self:GetName())
end

--显示活动列表
function UIActivity:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.activityList = self:GetList();
	objSwf.list.dataProvider:cleanUp();
	for i,vo in ipairs(self.activityList) do
		objSwf.list.dataProvider:push(UIData.encode(vo));
	end
	objSwf.list:invalidateData();
	objSwf.list:scrollToIndex(0);
	if #self.activityList > 0 then
		objSwf.list.selectedIndex = 0;
		self:ShowActivity(self.activityList[1].id);
	end
end

--注册一个特殊面板
function UIActivity:RegisterChild(type,ui)
	if self:GetChild(type) then   --获取UI子界面
		Debug("Error:has find a activity child panel.Type=",type);
		return;
	end
	self:AddChild(ui,type);
end

--显示活动
function UIActivity:ShowActivity(id)
	if id == self.currId then return; end
	local cfg = t_activity[id];
	if not cfg then return; end
	local childName = cfg.type;
	local child = self:GetChild(cfg.type);
	if not child then
		child = self:GetChild("default");
		childName = "default";
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not child.swfCfg.container then
		child:SetContainer(objSwf.childPanel);
	end
	self.currId = id;
	child.activityId = id;
	if child:IsShow() then
		child:OnShow();
	else
		self:ShowChild(childName);
	end
end

--获取活动列表
function UIActivity:GetList()
	local list = {};
	local now = GetDayTime();
	for i,cfg in pairs(t_activity) do
		if cfg.show then  --显示
			local vo = {};
			vo.id = cfg.id; 
			local activity = ActivityModel:GetActivity(cfg.id);
			if activity== nil then
				print("有活动没有注册.....:",cfg.id)
			end
			if activity then
				local timeVO = nil;
				local openTimeList = activity:GetOpenTime();
				if now > openTimeList[#openTimeList].endTime then
					vo.gray = true;
					vo.showSort = 1000 + cfg.showIndex;
					timeVO = openTimeList[#openTimeList];
					-- vo.rewardIconUrl = ResUtil:GetActivityUrl(cfg.reward_type,true);
				else
					vo.gray = false;
					vo.showSort = cfg.showIndex;
					for i,openTime in ipairs(openTimeList) do
						if now<openTime.startTime or (now>=openTime.startTime and now<=openTime.endTime) then
							timeVO = openTime;
							break;
						end
					end
					-- vo.rewardIconUrl = ResUtil:GetActivityUrl(cfg.reward_type);
				end
				vo.bgUrl = ResUtil:GetActivityUrl(cfg.icon);
				
				vo.nameUrl = ResUtil:GetActivityUrl(cfg.nameIcon);
				vo.isClose = false;
				if vo.gray then
					vo.bgUrl = ImgUtil:GetGrayImgUrl(vo.bgUrl);
					vo.nameUrl = ImgUtil:GetGrayImgUrl(vo.nameUrl);
					vo.isClose = true;
				end
				vo.timeVO = timeVO;
				local startHour,startMin = CTimeFormat:sec2format(timeVO.startTime);
				local endHour,endMin = CTimeFormat:sec2format(timeVO.endTime);


				local rolelvl = MainPlayerModel.humanDetailInfo.eaLevel;
				
				if cfg.openTime == '00:00:00' and cfg.duration == 0 and cfg.enter_time == 0 then			--全天判断
					vo.timeStr = StrConfig['worldBoss501'];
				else
					vo.timeStr = string.format("%02d:%02d-%02d:%02d",startHour,startMin,endHour,endMin);
				end
				
				if cfg.needLvl > rolelvl then 
					vo.needlvl = string.format(StrConfig["activity003"],"#cc0000",cfg.needLvl);
				else
					vo.needlvl = string.format(StrConfig["activity001"],cfg.needLvl);
				end;
				vo.isopen = activity:IsOpen();
				table.push(list,vo);
			end
		end
	end
	--[[
	for i,v in ipairs(list) do
		if v.isopen then
			self.activityOpenNum = self.activityOpenNum + 1
		end
	end
	--]]
	--按照活动是否开启过顺序来！
--[[	table.sort(list,function(A,B)
		if A.showSort < B.showSort then
			return true;
		else
			return false;
		end
	end);]]
	--按照活动是否开启->开启时间来进行排序
	table.sort(list, function(A, B)
		local openA = 0;
		if A.isopen then openA = 1; end
		local openB = 0;
		if B.isopen then openB = 1; end
		if openA ~= openB then return (openA - openB) > 0; end

		local closeA = 0;
		if A.isClose then closeA = 1; end
		local closeB = 0;
		if B.isClose then closeB = 1; end
		if closeA ~= closeB then return (closeA - closeB) < 0; end

		local openTimeA = A.timeVO and A.timeVO.startTime or 0;
		local openTimeB = B.timeVO and B.timeVO.startTime or 0;
		if openTimeA ~= openTimeB then
			return (openTimeA - openTimeB) < 0;
		end
		return (A.showSort - B.showSort) < 0;
	end);
	return list;
end


--用来计算活动开启的数量，暂时没有调用
UIActivity.activityOpenNum = 0;
function UIActivity:GetActivityOpenNum( )
	return self.activityOpenNum;
end

--用来检测活动是否有开启的活动
--adder：hoxudong
--date : 2016年8月3日 16:46:52
function UIActivity:GetActivityOpen()
	local ActivityIsOpen = false;
	local list = {};
	local now = GetDayTime();
	for i,cfg in pairs(t_activity) do
		if cfg.show then  --显示
			local vo = {};
			vo.id = cfg.id; 
			local activity = ActivityModel:GetActivity(cfg.id);
			if activity then
				vo.isopen = activity:IsOpen();
				if vo.isopen then
					ActivityIsOpen = true;
					return true;
				end
			end
		end
	end
	return ActivityIsOpen;
end
function UIActivity:OnItemClick(e)
	self:ShowActivity(e.item.id);  --活动id
end

function UIActivity:OnBtnCloseClick()
	if UIBeicangjieShop:IsShow() then
		UIBeicangjieShop:Hide();
	end
	self:Hide();
end

	-- notifaction
function UIActivity:ListNotificationInterests()
	return {
		NotifyConsts.ActivityState,
		}
end;
function UIActivity:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.ActivityState then
		self:ShowList();
	end;
end;

--面板中详细信息为隐藏面板，不计算到总宽度内
function UIRole:GetWidth()
	return 1146;
end

function UIRole:GetHeight()
	return 687;
end
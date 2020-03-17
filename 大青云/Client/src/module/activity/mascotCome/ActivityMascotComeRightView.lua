--[[
	副本降临右侧面板
	2015年10月22日22:05:41
	wangyanwei
]]
_G.UIMascotComeRight = BaseUI:new('UIMascotComeRight');

UIActivity:RegisterChild(ActivityConsts.T_MascotCome,UIMascotComeRight)


UIMascotComeRight.activityId = 0;
function UIMascotComeRight:Create()
	self:AddSWF("mascotComeRight.swf", true, nil);
end

function UIMascotComeRight:OnLoaded(objSwf)
	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver() end;
	objSwf.btnRule.rollOut = function() TipsManager:Hide()end;
	
	objSwf.rewardlist.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardlist.itemRollOut = function () TipsManager:Hide(); end
	
	objSwf.btn_goon.click = function() self:ClickGoon(); end
	objSwf.btnTeleport.click    = function() self:OnBtnTeleportClick(); end
	objSwf.btnTeleport.rollOver = function() self:OnBtnTeleportRollOver(); end
	objSwf.btnTeleport.rollOut  = function() self:OnBtnTeleportRollOut(); end
end

function UIMascotComeRight:OnShow()
	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
	local cfg = activity:GetCfg();
	if not cfg then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bgLoader.source = ResUtil:GetActivityJpgUrl(cfg.bg);
	objSwf.nameLoader.source = ResUtil:GetActivityUrl(cfg.nameIcon.."_b");
	objSwf.explainLoader.source = ResUtil:GetActivityUrl(cfg.explain);
	local openTimeList = activity:GetOpenTime();
	
	--[[objSwf.tfTime.text = StrConfig["activitytime"..self.activityId];
	if cfg.needLvl <= MainPlayerModel.humanDetailInfo.eaLevel then
		objSwf.tfLevel.htmlText = string.format(StrConfig["activity001"],cfg.needLvl);
	else
		objSwf.tfLevel.htmlText = string.format(StrConfig["activity002"],cfg.needLvl);
	end]]
	objSwf.result.htmlText = StrConfig["activity"..self.activityId];
	objSwf.rewardlist.dataProvider:cleanUp();
	local rewardStr = "";
	local rewardlist = activity:GetRewardList();
	if rewardlist then
		for i,vo in ipairs(rewardlist) do
			rewardStr = rewardStr .. vo.id .. "," .. vo.count;
			if i < #rewardlist then
				rewardStr = rewardStr .. "#";
			end
		end
	end

	local enterNum = activity:GetDailyTimes();
	local activityCfg = t_activity[activity:GetId()];
	objSwf.txt_num.htmlText = string.format(StrConfig['mascotCome0100'],activityCfg.dailyJoin - enterNum);

	local rewardStrList = RewardManager:Parse(rewardStr);
	objSwf.rewardlist.dataProvider:push(unpack(rewardStrList));
	objSwf.rewardlist:invalidateData();

	self:ShowMapBtn();
end

function UIMascotComeRight:ShowMapBtn()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
	
	objSwf.btn_goon.visible = activity:IsOpen();
	objSwf.btnTeleport.visible = activity:IsOpen();
	
	local mapID = activity:GetActivityMapID();
	local mapCfg = t_map[mapID];
	if not mapCfg then return end
	
end

--点击前往
function UIMascotComeRight:ClickGoon()
	ActivityMascotCome.currentChooseMascotComeActivityID = self.activityId;
	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
	local mapID = activity:GetActivityMapID();
	local mapCfg = t_map[mapID];
	if not mapCfg then return end
	
	local doorCfg = nil;
	for i , v in pairs(t_doorposition) do
		if v.mapid == mapID then
			doorCfg = v;
		end
	end
	if not doorCfg then return end
	
	local pointCfg = split(doorCfg.position,'#');
	local point = pointCfg[math.random(#pointCfg)]
	if not point then return end
	point = split(point,',')

	--前往到地点后，遍历下传送门，找到离自己最近的，如果走到的地方没有 那么找到的距离会大于10 所以为了避免走到空地还弹出确认框。加了判断
	--为的是完成运营提出的寻路到终点后自动弹出确认框 不用玩家手动点击传送门了
	local completeFuc = function()
		local nd = 1000000;
		local p;
		for k, v in pairs(CPlayerMap:GetMapPortals()) do
			if v then
				local pos = _Vector2.new(v.x, v.y)
				local selfPlayer = MainPlayerController:GetPlayer();
				local selfPos = selfPlayer:GetPos();
				local dis = GetDistanceTwoPoint(selfPos, pos);
				if dis < nd and dis<10 then
					nd = dis;
					p = v;
				end
			end
		end
		if p then
			PortalController.currPickPortal = p.cid;
			CPlayerMap:OnEnterMascotCome(p)
		end
	end
	MainPlayerController:DoAutoRun(doorCfg.mapid,_Vector3.new(toint(point[1]),toint(point[2]),0), completeFuc);
end
--直飞
function UIMascotComeRight:OnBtnTeleportClick()
	
	local point = split(t_consts[328].param,',');
	
	local teleportType = MapConsts.Teleport_Map
	local onfoot = function() self:ClickGoon() end
	MapController:Teleport( teleportType, onfoot, toint(t_consts[328].val1) , toint(point[1]) , toint(point[2]) )
end
function UIMascotComeRight:OnBtnTeleportRollOver()
	MapUtils:ShowTeleportTips()
end

function UIMascotComeRight:OnBtnTeleportRollOut()
	TipsManager:Hide()
end
function UIMascotComeRight:OnHide()
	
end

--检查是否可进入
function UIMascotComeRight:CheckCanIn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
end

function UIMascotComeRight:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if StrConfig["activityru"..self.activityId] then
		TipsManager:ShowBtnTips(StrConfig["activityru"..self.activityId],TipsConsts.Dir_RightDown);
	end
end

function UIMascotComeRight:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.ActivityState then
		if body.id == self.activityId then
			self:CheckCanIn();
		end
	end
end

function UIMascotComeRight:ListNotificationInterests()
	return {NotifyConsts.ActivityState};
end

function UIMascotComeRight:SignUpPhase()

end
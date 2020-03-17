--[[
	2015年12月22日15:20:15
	wangyanwei
	雪人入侵
]]
_G.UIChristmasIntrusion = BaseUI:new('UIChristmasIntrusion');

function UIChristmasIntrusion:Create()
	self:AddSWF('christmasIntrusion.swf',true,nil);
end

function UIChristmasIntrusion:OnLoaded(objSwf)
	for i = 1 , 7 do
		objSwf['txt_' .. i].text = StrConfig['christmas11' .. i];
	end
	local cfg = t_consts[177];
	if not cfg then return end
	local itemCfg = t_item[cfg.val2];
	if not itemCfg then return end
	objSwf.btn_item1.htmlLabel = string.format(StrConfig['christmas151'],itemCfg.name .. 'x1');
	objSwf.btn_item2.htmlLabel = string.format(StrConfig['christmas151'],itemCfg.name);
	objSwf.btn_item1.rollOver = function () TipsManager:ShowItemTips(cfg.val2); end
	objSwf.btn_item1.rollOut = function () TipsManager:Hide(); end
	objSwf.btn_item2.rollOver = function () TipsManager:ShowItemTips(cfg.val2); end
	objSwf.btn_item2.rollOut = function () TipsManager:Hide(); end
	local npcCfg = t_npc[cfg.val3];
	if not npcCfg then return end
	objSwf.btn_npc.htmlLabel = string.format(StrConfig['christmas150'],npcCfg.name);
	objSwf.btn_npc.click = function () self:NpcClick(); end
end

function UIChristmasIntrusion:OnShow()
	self:TimeText();
	self:ShowActivityData();
end

function UIChristmasIntrusion:OnHide()
	
end

--寻路
function UIChristmasIntrusion:NpcClick()
	local cfg = t_consts[177];
	local posID = cfg.fval;
	QuestController:DoRunToNpc( QuestUtil:GetQuestPos(posID), cfg.val3 );
end

--活动是否已开启
function UIChristmasIntrusion:ShowActivityData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local activity = ActivityModel:GetActivity(ActivityConsts.ChristamIntrusion);
	if not activity then return end
	objSwf.icon_update._visible = activity:IsOpen();
	objSwf.txt_map._visible = activity:IsOpen();
	if activity:IsOpen() then
		objSwf.txt_map.htmlText = string.format(StrConfig['christmas118'],activity:GetLine());
	end
end

--时间文本
function UIChristmasIntrusion:TimeText()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local activityCfg = t_activity[ActivityConsts.ChristamIntrusion];
	if not activityCfg then return end
	
	local openTimeList = self:GetOpenTime();
	local str = "";
	for i,openTime in ipairs(openTimeList) do
		local startHour,startMin = CTimeFormat:sec2format(openTime.startTime);
		local endHour,endMin = CTimeFormat:sec2format(openTime.endTime);
		str = str .. string.format("%02d:%02d-%02d:%02d",startHour,startMin,endHour,endMin);
		str = i >= #openTimeList and str or str .. ",";
	end
	objSwf.txt_time.htmlText = str;
end

--获取活动开启时间
function UIChristmasIntrusion:GetOpenTime()
	if not self.activityOpenTime then
		self.activityOpenTime = {};
		local cfg = t_activity[ActivityConsts.ChristamIntrusion];
		if cfg then
			if cfg.openType == 1 then
				local vo = {};
				vo.startTime = 0;
				vo.endTime = 3600*24;
				table.push(self.activityOpenTime,vo);
			else
				local startT = split(cfg.openTime,"#");
				for i,startStr in ipairs(startT) do
					local vo = {};
					vo.startTime = CTimeFormat:daystr2sec(startStr);
					vo.endTime = vo.startTime + cfg.duration*60;
					table.push(self.activityOpenTime,vo);
				end
			end
		end
		table.sort( self.activityOpenTime, function(A,B) return A.startTime < B.startTime end );
	end
	return self.activityOpenTime;
end
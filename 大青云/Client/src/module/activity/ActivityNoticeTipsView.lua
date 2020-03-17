--[[
活动提醒tips
wangshaui
]]

_G.UIActivityNoticeTips = BaseUI:new('UIActivityNoticeTips')
UIActivityNoticeTips.activityId = 0;
function UIActivityNoticeTips:Create()
	self:AddSWF("activityNoticeTips.swf",true,"top")
end;

function UIActivityNoticeTips:OnLoaded(objSwf)

end;
function UIActivityNoticeTips:ShowTips(id)
	self.activityId = id
	self:Show()
end;
function UIActivityNoticeTips:OnShow()
	self:SetXY()
	self:OnSetTipsData();
end;
function UIActivityNoticeTips:OnSetTipsData()
	local objSwf = self.objSwf;
	local cfg = t_activity[self.activityId];

	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
	-- local openTimeList = activity:GetOpenTime();
	-- local str = "";
	-- for i,openTime in ipairs(openTimeList) do
	-- 	local startHour,startMin = CTimeFormat:sec2format(openTime.startTime);
	-- 	local endHour,endMin = CTimeFormat:sec2format(openTime.endTime);
	-- 	str = str .. string.format("%02d:%02d-%02d:%02d",startHour,startMin,endHour,endMin);
	-- 	str = str .. " ";
	-- end
	-- objSwf.tfTime.text = string.format(StrConfig["activityNoticeTips001"],str);
	if cfg.openTime == '00:00:00' and cfg.duration == 0 and cfg.enter_time == 0 then
		objSwf.tfTime.text = StrConfig['worldBoss501'];
	else
		objSwf.tfTime.text = activity:GetNoticeOpenTimeStr()
	end
	objSwf.actName.text = cfg.name;
	objSwf.desc.text = cfg.noticdesc;


	objSwf.rewardlist.dataProvider:cleanUp();
	local rewardStr = "";
	local rewardlist = activity:GetRewardList();
	local nameTxt = "";
	if rewardlist then
		local leng = #rewardlist;
		for i,vo in ipairs(rewardlist) do
			rewardStr = rewardStr .. vo.id .. "," .. vo.count;
			local cfg = t_equip[vo.id] or t_item[vo.id];
			if cfg then
				if i == leng then
					nameTxt = nameTxt..cfg.name.."。"
				else
					nameTxt = nameTxt..cfg.name.."、"
				end;
				if i < #rewardlist then
					rewardStr = rewardStr .. "#";
				end
			else
				print("UIActivityNoticeTips not found reward", vo.id);
			end
		end
	end
	local rewardStrList = RewardManager:Parse(rewardStr);
	objSwf.rewardlist.dataProvider:push(unpack(rewardStrList));
	objSwf.rewardlist:invalidateData();
	objSwf.rewardName.text = nameTxt
end;

function UIActivityNoticeTips:SetXY()
	local objSwf = self.objSwf;
	local toX ,toY =  TipsUtils:GetTipsPos(objSwf._width,objSwf._height,TipsConsts.Dir_RightUp,nil)
	objSwf._x = toX;
	objSwf._y = toY;
end;

function UIActivityNoticeTips:OnHide()
	self.activityId = 0;
end;

function UIActivityNoticeTips:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local tipsX,tipsY = TipsUtils:GetTipsPos(objSwf.bg._width,objSwf.bg._height,self.tipsDir);
		objSwf._x = tipsX;
		objSwf._y = tipsY;
	end
end

function UIActivityNoticeTips:ListNotificationInterests()
	return {NotifyConsts.StageMove};
end


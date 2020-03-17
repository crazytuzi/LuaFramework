--[[
活动提醒tips
wangshaui
]]

_G.UIUnionActivityNoticeTips = BaseUI:new('UIUnionActivityNoticeTips')
UIUnionActivityNoticeTips.activityId = 0;
function UIUnionActivityNoticeTips:Create()
	self:AddSWF("activityNoticeTips.swf",true,"top")
end;

function UIUnionActivityNoticeTips:OnLoaded(objSwf)

end;
function UIUnionActivityNoticeTips:ShowTips(id)
	self.activityId = id
	self:Show()
end;
function UIUnionActivityNoticeTips:OnShow()
	self:SetXY()
	self:OnSetTipsData();
end;
function UIUnionActivityNoticeTips:OnSetTipsData()
	local objSwf = self.objSwf;
	local cfg = t_guildActivity[self.activityId];


	local startTime = CTimeFormat:daystr2sec(cfg.openTime);
	local endTime = startTime + cfg.duration*60;

	local startHour,startMin = CTimeFormat:sec2format(startTime);
	local endHour,endMin = CTimeFormat:sec2format(endTime);
	local str = ""
	str = str .. string.format("%02d:%02d-%02d:%02d",startHour,startMin,endHour,endMin);

	objSwf.tfTime.text = string.format(StrConfig["unionActivity002"],str);--activity:GetNoticeOpenTimeStr()
	objSwf.actName.text = cfg.name;
	objSwf.desc.text = cfg.tipdes;


	objSwf.rewardlist.dataProvider:cleanUp();
	local rewardStr = "";
	local rewardlist = split(cfg.reward,"#")
	local nameTxt = "";
	if rewardlist then
		for i,vo in ipairs(rewardlist) do
			local id =  toint(vo)
			rewardStr = rewardStr .. id .. ",0";
			local cfg = t_equip[id] or t_item[id];
			nameTxt = nameTxt..cfg.name.."、"
			if i < #rewardlist then
				rewardStr = rewardStr .. "#";
			end
		end
	end
	local rewardStrList = RewardManager:Parse(rewardStr);
	objSwf.rewardlist.dataProvider:push(unpack(rewardStrList));
	objSwf.rewardlist:invalidateData();
	objSwf.rewardName.text = nameTxt
end;

function UIUnionActivityNoticeTips:SetXY()
	local objSwf = self.objSwf;
	local toX ,toY =  TipsUtils:GetTipsPos(objSwf._width,objSwf._height,TipsConsts.Dir_RightUp,nil)
	objSwf._x = toX;
	objSwf._y = toY;
end;

function UIUnionActivityNoticeTips:OnHide()
	self.activityId = 0;
end;

function UIUnionActivityNoticeTips:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local tipsX,tipsY = TipsUtils:GetTipsPos(objSwf.bg._width,objSwf.bg._height,self.tipsDir);
		objSwf._x = tipsX;
		objSwf._y = tipsY;
	end
end

function UIUnionActivityNoticeTips:ListNotificationInterests()
	return {NotifyConsts.StageMove};
end


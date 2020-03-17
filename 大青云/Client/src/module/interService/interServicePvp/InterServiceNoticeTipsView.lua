--[[
活动提醒tips
wangshaui
]]

_G.UIInterServiceNoticeTips = BaseUI:new('UIInterServiceNoticeTips')
UIInterServiceNoticeTips.activityId = 0;
function UIInterServiceNoticeTips:Create()
	self:AddSWF("activityNoticeTips.swf",true,"top")
end;

function UIInterServiceNoticeTips:OnLoaded(objSwf)

end;
function UIInterServiceNoticeTips:ShowTips(id)
	self.activityId = id
	self:Show()
end;
function UIInterServiceNoticeTips:OnShow()
	self:SetXY()
	self:OnSetTipsData();
end;
function UIInterServiceNoticeTips:OnSetTipsData()
	local objSwf = self.objSwf;
	local cfg = t_kuafuactivity[self.activityId];


	local startTime = CTimeFormat:daystr2sec(cfg.openTime);
	local endTime = startTime + cfg.duration*60;

	local startHour,startMin = CTimeFormat:sec2format(startTime);
	local endHour,endMin = CTimeFormat:sec2format(endTime);
	local str = ""
	str = str .. string.format("%02d:%02d-%02d:%02d",startHour,startMin,endHour,endMin);

	objSwf.tfTime.text = string.format(StrConfig["unionActivity002"],str);--activity:GetNoticeOpenTimeStr()
	objSwf.actName.text = cfg.name;
	objSwf.desc.text = cfg.des;


	objSwf.rewardlist.dataProvider:cleanUp();
	local rewardStr = "";
	local rewardlist = nil
	
	if self.activityId == 1 then
		local constsCfg = t_consts[165]
		if constsCfg then
			rewardlist = split(t_consts[165].param,"#")	
		end	
	else
		if cfg.reward_show then
			rewardlist = split(cfg.reward_show,"#")	
		end
	end
	local nameTxt = "";
	if rewardlist then
		for i,vo in ipairs(rewardlist) do
			local itemIdArr = split(vo, ',')
		
			local id =  toint(itemIdArr[1])
			rewardStr = rewardStr .. id .. ",0";
			local cfg = t_equip[id] or t_item[id];
			if not cfg.name then
				cfg.name = nil;
			end
			nameTxt = nameTxt..cfg.name.."、"
			if i < #rewardlist then
				rewardStr = rewardStr .. "#";
			end
		end
	end
	local rewardStrList = RewardManager:Parse(rewardStr);
	objSwf.rewardlist.dataProvider:push(unpack(rewardStrList));
	objSwf.rewardlist:invalidateData();
	nameTxt = string.sub(nameTxt,1,-2)
	objSwf.rewardName.text = nameTxt
end;

function UIInterServiceNoticeTips:SetXY()
	local objSwf = self.objSwf;
	local toX ,toY =  TipsUtils:GetTipsPos(objSwf._width,objSwf._height,TipsConsts.Dir_RightUp,nil)
	objSwf._x = toX;
	objSwf._y = toY;
end;

function UIInterServiceNoticeTips:OnHide()
	self.activityId = 0;
end;

function UIInterServiceNoticeTips:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local tipsX,tipsY = TipsUtils:GetTipsPos(objSwf.bg._width,objSwf.bg._height,self.tipsDir);
		objSwf._x = tipsX;
		objSwf._y = tipsY;
	end
end

function UIInterServiceNoticeTips:ListNotificationInterests()
	return {NotifyConsts.StageMove};
end


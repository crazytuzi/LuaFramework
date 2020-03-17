
_G.ActivityChristmasIntrusion = BaseActivity:new(ActivityConsts.ChristamIntrusion);
ActivityModel:RegisterActivity(ActivityChristmasIntrusion);

function ActivityChristmasIntrusion:DoNoticeClick()
	UIChristmasBasic:Open('christmasIntrusion');
end

function ActivityChristmasIntrusion:GetNoticeOpenTimeStr()
	return '';
end

--检查活动提醒
--@return 0不提醒,1即将开启提醒,2进行中提醒
function ActivityChristmasIntrusion:DoNoticeCheck()
	if not FuncManager:GetFuncIsOpen(FuncConsts.Activity) then
		return 0;
	end
	if self:GetCfg().openType == 1 then
		return 0;
	end
	if self.isNoticeClosed then
		return 0;
	end
	--关闭时,提前5分钟提醒
	if self.state == 0 then
		return 0;
	else
		if self.isIn then
			return 0;
		end
		return 2;
	end
end
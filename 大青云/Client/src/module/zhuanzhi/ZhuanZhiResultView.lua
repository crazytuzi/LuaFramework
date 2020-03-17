--[[
转职
yujia
]]
_G.ZhuanZhiResultView=BaseUI:new("ZhuanZhiResultView")
ZhuanZhiResultView.ShowTime = 30 --界面显示时间为30秒

function ZhuanZhiResultView:Create()
	self:AddSWF("zhuanzhiResult.swf",true,"center")
end
function ZhuanZhiResultView:OnLoaded(objSwf)
    objSwf.btn_out.click = function() ZhuanZhiController:AskOutDup() end

    objSwf.costList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.costList.itemRollOut = function () TipsManager:Hide(); end
end

function ZhuanZhiResultView:OnShow()
	self.StartTime = GetCurTime(true)
	self:ShowZhuanZhiInfo()
	self:StartTimer()
	self:ShowTimeInfo()
	return true
end

function ZhuanZhiResultView:StartTimer()
	if self.timerKey then return end;
	self.timerKey = TimerManager:RegisterTimer( function()
		self:ShowTimeInfo();
	end, 1000, 0 );
end

function ZhuanZhiResultView:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

function ZhuanZhiResultView:OnHide()
	self:StopTimer()
end

function ZhuanZhiResultView:ShowZhuanZhiInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local slots = {}
	for i = 1, 6 do
		table.push(slots, objSwf["attr" ..i])
	end

	local cfg = t_transferattr[ZhuanZhiModel:GetLv()]
	local att = AttrParseUtil:Parse(cfg.attr)
	PublicUtil:ShowProInfoForUI(att, slots)

	if cfg.item and cfg.item ~= 0 then
		local randomList = RewardManager:Parse(cfg.item .. ",1");
		objSwf.costList.dataProvider:cleanUp();
		objSwf.costList.dataProvider:push(unpack(randomList));
		objSwf.costList:invalidateData()
	else
		objSwf.costList.dataProvider:cleanUp();
		objSwf.costList:invalidateData()
	end
	if ZhuanZhiModel:GetLv() == 2 then
		objSwf.icon111._visible = true
	else
		objSwf.icon111._visible = false
	end
	return true
end

function ZhuanZhiResultView:ShowTimeInfo()
	local time = self.ShowTime - (GetCurTime(true) - self.StartTime)
	if time <= 0 then
		self.objSwf.txtTime.htmlText = string.format(StrConfig['zhuanzhi12'], 0)
		ZhuanZhiController:AskOutDup()
		return
	end
	self.objSwf.txtTime.htmlText = string.format(StrConfig['zhuanzhi12'], time)
	return true
end
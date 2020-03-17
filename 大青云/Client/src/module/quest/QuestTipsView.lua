--[[
主线任务tips
lizhuangzhuang
2014年8月28日11:13:13

修改为可以供其他类型任务展示奖励物品的tips界面
yanghongbin
2016-7-21
]]

_G.UIQuestTips = BaseUI:new("UIQuestTips")

function UIQuestTips:Create()
	self:AddSWF("taskTips.swf", true, "top" )
end

function UIQuestTips:OnResize(wWidth,wHeight)
	self:SetUIPos()
end

function UIQuestTips:SetUIPos()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	local monsePos = _sys:getRelativeMouse()
	if UIFengYao.isUIFengYaoBoxTips or UIQuestDay.isUIQuestDayTips then
		objSwf._x      = monsePos.x - 20
	else
		objSwf._x      = wWidth - 280
	end
	objSwf._y      = monsePos.y + 20
end

function UIQuestTips:OnShow()
	local questName = self.args[1];
	local rewardList = self.args[2];
	self:SetUIPos()
	local objSwf = self.objSwf
	if not objSwf then return end
	if UIFengYao.isUIFengYaoBoxTips then
		objSwf.labelName._visible = false;
		objSwf.labelFengyao._visible = true;
		objSwf.labelFengyao.htmlText = string.format( StrConfig["fengyao306"], questName);
		objSwf.textField.text = StrConfig["fengyao307"]
	elseif UIQuestDay.isUIQuestDayTips then
		objSwf.labelName._visible = false;
		objSwf.labelFengyao._visible = true;
		objSwf.labelFengyao.htmlText = string.format( StrConfig["quest916"], questName);
		objSwf.textField.text = StrConfig["fengyao307"]
	else
		objSwf.labelFengyao._visible = false;
		objSwf.labelName._visible = true;
		objSwf.textField.text = StrConfig["fengyao308"]
		objSwf.labelName.text = questName;
	end
	objSwf.list.dataProvider:cleanUp()
	objSwf.list.dataProvider:push( unpack(rewardList) )
	objSwf.list:invalidateData()
	--设置背景高度
	local bgHeight = 0
	bgHeight = bgHeight + 80;
	bgHeight = bgHeight + toint( #rewardList/5 , 1 ) * 50
	objSwf.bg._height = bgHeight
end


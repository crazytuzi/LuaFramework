--[[
    Created by IntelliJ IDEA.
    功能按钮的提醒tips框显示
    User: Hongbin Yang
    Date: 2016/10/4
    Time: 14:09
   ]]

_G.RemindFuncTipsView = BaseUI:new("UIRemindFuncTipsView");

RemindFuncTipsView.SYMBOLNAME_IN_LIB = "funcRemindTipsFrame";
RemindFuncTipsView.showList = {};
RemindFuncTipsView.isShowing = false;
function RemindFuncTipsView:Create()
	self:AddSWF("funcRemindTips.swf", true, "bottomFloat");
end

function RemindFuncTipsView:ShowTip(frame)
	if self:IsShow() then
		self:ShowOne(frame);
	else
		self:Show(frame);
	end
end

function RemindFuncTipsView:OnShow()
	if #self.args > 0 then
		self:ShowOne(self.args[1]);
	end
end

function RemindFuncTipsView:ShowOne(frame)
	local id = frame:GetId();
	if id <= 0 then return; end
	if not self.objSwf then return; end
	if self.showList and self.showList[id] then
		return;
	end

	if not self.showList then
		self.showList = {};
	end
	self.showList[id] = frame;
	self:ShowNext();
end

function RemindFuncTipsView:ShowNext()
	if self.isShowing then return; end
	if not self.showList then return; end
	local frame;
	for k, v in pairs(self.showList) do
		if v then
			frame = v;
			break;
		end
	end
	if not frame then return; end
	local id = frame:GetId();
	if id <= 0 then return; end
	if not self.objSwf then return; end
	--生成显示
	local objSwf = self.objSwf;
	local depth = objSwf:getNextHighestDepth();
	local mc = objSwf:attachMovie(RemindFuncTipsView.SYMBOLNAME_IN_LIB, RemindFuncTipsView.SYMBOLNAME_IN_LIB .. id, depth);
	--初始化界面
	local closeCB = function() self:CloseOne(frame:GetId(), true); end
	frame:InitView(mc, closeCB);
	self.isShowing = true;
end

function RemindFuncTipsView:CloseOne(id, checkNext)
	if not self.showList[id] then return; end
	RemindFuncTipsController.remindList[id]:DoPromptTimer();
	local frame = self.showList[id];
	frame:RemoveView();
	self.showList[id] = nil;
	if checkNext then
		TimerManager:RegisterTimer(function()
			self.isShowing = false;
			self:ShowNext();
		end, RemindFuncTipsConsts.SHOW_NEXT_INTERVAL, 1)
	end
	self:CheckClose();
end

function RemindFuncTipsView:CloseAll()
	if not self.showList then return; end
	for k, v in pairs(self.showList) do
		self:CloseOne(k, false);
	end
	self.isShowing = false;
end


function RemindFuncTipsView:CheckClose()
	local hasShow = false;
	for k, v in pairs(self.showList) do
		if self.showList[k] then
			hasShow = true;
			break;
		end
	end
	if not hasShow then
		self:Hide();
	end
end

function RemindFuncTipsView:OnHide()
	self.showList = nil;
end

function RemindFuncTipsView:IsTween()
	return false;
end

function RemindFuncTipsView:NeverDeleteWhenHide()
	return true;
end

function RemindFuncTipsView:Update(dwInterval)
	if not self.showList then return; end
	if not self:IsShow() then return; end
	for k, v in pairs(self.showList) do
		if self.showList[k] then
			v:Update();
		end
	end
	return true;
end
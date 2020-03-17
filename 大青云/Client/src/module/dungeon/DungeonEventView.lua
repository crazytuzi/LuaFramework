--[[
副本 随机事件面板
2015年1月6日16:05:29
haohu
]]

_G.UIDungeonEvent = BaseUI:new("UIDungeonEvent");

UIDungeonEvent.eventInfo = nil;-- msg{ id, state, param1, param2, params }

function UIDungeonEvent:Create()
	self:AddSWF("dungeonEventPanel.swf", true, "center");
end

function UIDungeonEvent:OnLoaded(objSwf)
	objSwf.item1.visible = false;
end

function UIDungeonEvent:OnShow()
	self:InitShow();
end

function UIDungeonEvent:OnHide()
	self:StopTimer();
end

function UIDungeonEvent:GetWidth()
	return 349;
end

function UIDungeonEvent:GetHeight()
	return 164;
end

function UIDungeonEvent:InitShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local eventInfo = self.eventInfo;
	if not eventInfo then return; end
	local eventId = eventInfo.id;
	local cfg = t_dungeonevent[eventId];
	if not cfg then return; end
	objSwf.txtTitle.text  = string.format( StrConfig["dungeon601"], cfg.name );
	objSwf.txtDes.text    = cfg.notice;
	objSwf.txtTime.text   = self:GetCountDownTxt(cfg.timeLimit);
	local numItem = split( cfg.reward_item, "," )[2];
	local numExp = cfg.reward_exp;
	local rewardExpStr = string.format( StrConfig["dungeon603"], numExp );
	local rewardItemStr = string.format( StrConfig["dungeon604"], numItem );
	objSwf.txtReward.text = rewardExpStr .. "  " .. rewardItemStr;
end

local timerKey;
local time;
function UIDungeonEvent:StartTimer()
	local eventInfo = self.eventInfo;
	local eventId = eventInfo and eventInfo.id;
	local cfg = t_dungeonevent[eventId];
	if not cfg then return; end
	time = cfg.timeLimit;
	local cb = function()
		self:CountDown();
	end
	timerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
end

function UIDungeonEvent:GetCountDownTxt(time)
	local timeStr = SitUtils:ParseTime(time);
	return string.format( StrConfig["dungeon602"], timeStr );
end

function UIDungeonEvent:CountDown()
	time = time - 1;
	if time == 0 then
		self:StopTimer();
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime.text = self:GetCountDownTxt(time);
end

function UIDungeonEvent:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer(timerKey);
		timerKey = nil;
	end
end

function UIDungeonEvent:HandleEvent(eventInfo)
	self.eventInfo = eventInfo;
	local state = eventInfo.state;
	if state == DungeonConsts.EventNotify then
		self:OnGetNotify(eventInfo);
	elseif state == DungeonConsts.EventStart then
		self:OnStartNotify(eventInfo);
	elseif state == DungeonConsts.EventComplete then
		self:OnCompleteNotify(eventInfo);
	elseif state == DungeonConsts.EventFail then
		self:OnFailNotify(eventInfo);
	end
end

function UIDungeonEvent:OnGetNotify(eventInfo)
	self:Show();
end

function UIDungeonEvent:OnStartNotify(eventInfo)
	if not self:IsShow() then
		self:Show();
	end
	if not timerKey then
		self:StartTimer();
	end
end

function UIDungeonEvent:OnCompleteNotify(eventInfo)
	self:Hide();
end

function UIDungeonEvent:OnFailNotify(eventInfo)
	self:Hide();
end

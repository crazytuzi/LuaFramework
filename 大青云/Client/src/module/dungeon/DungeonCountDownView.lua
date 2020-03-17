--[[
副本倒计时提示框
2014年11月24日09:59:54
郝户
]]

_G.UIDungeonCountDown = BaseUI:new("UIDungeonCountDown");

UIDungeonCountDown.timerKey  = nil;
UIDungeonCountDown.time      = nil;
UIDungeonCountDown.dungeonId = nil;
UIDungeonCountDown.line      = nil;

function UIDungeonCountDown:Create()
	self:AddSWF("dungeonCountDownPanel.swf", true, "center");
end

function UIDungeonCountDown:OnLoaded(objSwf)
	objSwf.txtDmTitle.text    = StrConfig["dungeon402"];
	objSwf.txtName._visible   = false;
	objSwf.btnEnter.visible   = false;
	objSwf.btnAbstain.visible = false;

	objSwf.btnDM.select     = function(e) self:OnBtnDmSelect(e); end
	objSwf.btnEnter.click   = function() self:OnBtnEnterClick(); end
	objSwf.btnAbstain.click = function() self:OnBtnAbstainClick(); end
end

function UIDungeonCountDown:OnShow()
	self:UpdateShow();
	self:StartTimer();
	self:UpdateLayout()
end

function UIDungeonCountDown:OnHide()
	self:StopTimer();
end

--点击下拉按钮
function UIDungeonCountDown:OnBtnDmSelect(e)
	self:ShowDropDown(e.selected);
end

function UIDungeonCountDown:ShowDropDown(selected)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtName._visible   = selected;
	objSwf.btnEnter.visible   = selected;
	objSwf.btnAbstain.visible = selected;
	self:UpdateLayout()
end

function UIDungeonCountDown:UpdateLayout()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.bg._height = objSwf.btnDM.selected and 116 or 67;
end

--点击进入按钮
function UIDungeonCountDown:OnBtnEnterClick()
	if not MapUtils:CanTeleport() then
		FloatManager:AddNormal( StrConfig['map207'] )
		return
	end
	if CPlayerMap:GetCurLineID() == self.line then
		self:ContinueDungeon();
		return;
	end
	if MainPlayerController:ReqChangeLine(self.line) then
		DungeonController.afterLineChange = function()
			self:ContinueDungeon();
		end
	end
end

--点击放弃按钮
function UIDungeonCountDown:OnBtnAbstainClick()
	if not MapUtils:CanTeleport() then
		FloatManager:AddNormal( StrConfig['map207'] )
		return
	end
	local content = StrConfig["dungeon501"];
	local confirmFunc = function() self:AbstainDungeon(); end
	local confirmLabel = StrConfig["dungeon503"];
	local cancelLabel  = StrConfig["dungeon504"];
	UIConfirm:Open( content, confirmFunc, nil, confirmLabel, cancelLabel );
end

--继续副本
function UIDungeonCountDown:ContinueDungeon()
	local cfg = t_dungeons[self.dungeonId];
	if not cfg then return; end
	if cfg.type == DungeonConsts.SinglePlayer then
		if TeamModel:IsInTeam() then
			FloatManager:AddCenter( StrConfig['dungeon405'] );--单人副本不可组队进入
			return;
		end
	end
	DungeonController:ReqEnterDungeon( self.dungeonId, 2 );
end

function UIDungeonCountDown:AbstainDungeon()
	if not self.dungeonId then return; end
	if not self.timerKey then return; end
	DungeonController:ReqLeaveDungeon( self.dungeonId );
	self:Hide();
end

function UIDungeonCountDown:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_dungeons[self.dungeonId];
	if not cfg then return; end
	local dungeonFormat = "<font color='#B19A70'>%s</font><font color='#00FF00'>%s</font>";
	local typeName = cfg.type == 1 and StrConfig["dungeon403"] or StrConfig["dungeon404"];
	objSwf.txtName.htmlText = string.format(dungeonFormat, cfg.name, typeName);
end

function UIDungeonCountDown:StartTimer()
	local func = function() self:OnTimer(); end
	self.timerKey = TimerManager:RegisterTimer( func, 1000, 0 );
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtCountDown.text = string.format( StrConfig["dungeon401"], DungeonUtils:ParseTime(self.time) );
end

function UIDungeonCountDown:OnTimer()
	self.time = self.time - 1;
	if self.time <= 0 then
		self:OnTimeUp();
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtCountDown.text = string.format( StrConfig["dungeon401"], DungeonUtils:ParseTime(self.time) );
end

function UIDungeonCountDown:OnTimeUp()
	self:AbstainDungeon();
	self:StopTimer();
end

function UIDungeonCountDown:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
		self.time = nil;
	end
end

--打开面板
--@param dungeonId: 副本id
--@param time:倒计时的时间
function UIDungeonCountDown:Open( dungeonId, time, line )
	self.dungeonId = dungeonId;
	self.time = time;
	self.line = line;
	if not self:IsShow() then
		self:Show();
	else
		self:UpdateShow();
	end
end
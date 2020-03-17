--[[
    Created by IntelliJ IDEA.
    无操作控制
    User: Hongbin Yang
    Date: 2016/9/1
    Time: 18:36
   ]]
_G.NoOperationController = setmetatable({},{__index=IController})
NoOperationController.name = "NoOperationController"
NoOperationController.interval = 0;
NoOperationController.lastTime = 0;
NoOperationController.isShow = false;
NoOperationController.enabled = false;
function NoOperationController:OnEnterGame()
	CControlBase:RegControl(self, true)
	self.interval = t_consts[312].val1 * 1000;
	self.lastTime = GetCurTime();
end

function NoOperationController:Update(e)
	if not self.enabled then return; end
	if self.isShow then
		return;
	end
	if GetCurTime() - self.lastTime < self.interval then
		return;
	end
	self.lastTime = GetCurTime();
	if not self.isShow then
		self.isShow = true;
		local func = function()
			self.isShow = false;
			self.lastTime = GetCurTime();
			SetSystemController:SetDisplayQuality(SetSystemModel.SetModel:GetDrawLevel())
		end
		NoOperationView:Show(StrConfig["noop1"], StrConfig["noop2"], func);
		SetSystemController:SetDisplayQuality(DisplayQuality.lowQuality);
	end
end

function NoOperationController:OnMouseMove(nXPos,nYPos)
	self.lastTime = GetCurTime();
end
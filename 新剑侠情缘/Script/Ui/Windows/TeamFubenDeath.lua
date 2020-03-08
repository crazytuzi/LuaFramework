
local tbUi = Ui:CreateClass("TeamFubenDeath");

function tbUi:OnOpen(nTime)
	self.nTime = nTime or 5;
	self:Update();
end

function tbUi:Update()
	self.pPanel:Label_SetText("Msg", string.format("剩余复活时间 %d 秒", self.nTime));
	self.nTime = self.nTime - 1;
	if self.nTime > 0 then
		Timer:Register(Env.GAME_FPS * 1, self.Update, self);
	end
end
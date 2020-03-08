
local tbFBRankEffect = Ui:CreateClass("FactionBattleRankEffect");

local tbTypeEffect = 
{
	["16强赛"] = {effectCtrl="GameObject_L", titleCtrl="ranking", spriteName="round_of_16"},
	["8强赛"] = {effectCtrl="GameObject_L", titleCtrl="ranking", spriteName="round_of_8"},
	["半决赛"] = {effectCtrl="GameObject_L", titleCtrl="ranking", spriteName="round_of_4"},
	["决赛"] = {effectCtrl="GameObject_L", titleCtrl="ranking", spriteName="finalists"},
	["冠军"] = {effectCtrl="GameObject", titleCtrl="ranking2", spriteName="newking"},
}
function tbFBRankEffect:OnOpen(nType)

	local tbTypeInfo = tbTypeEffect[nType];
	if not tbTypeInfo then
		return 0;
	end

	self.pPanel:SetActive("ranking", false);
	self.pPanel:SetActive("ranking2", false);
	self.pPanel:SetActive("GameObject", false);
	self.pPanel:SetActive("GameObject_L", false);

	self.pPanel:SetActive(tbTypeInfo.effectCtrl, true);
	self.pPanel:SetActive(tbTypeInfo.titleCtrl, true);
	self.pPanel:Sprite_SetSprite(tbTypeInfo.titleCtrl, tbTypeInfo.spriteName);

	self.nTimer = Timer:Register(Env.GAME_FPS * 2, self.OnTimer, self)
end

function tbFBRankEffect:OnTimer()
	self.nTimer = nil;
	Ui:CloseWindow(self.UI_NAME);
end

function tbFBRankEffect:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end


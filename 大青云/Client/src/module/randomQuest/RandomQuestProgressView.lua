--[[
	2015年9月14日, PM 10:26:53
	wangyanwei
	奇遇进度
]]

_G.UIRamdomQuestProGress = BaseUI:new('UIRamdomQuestProGress');

function UIRamdomQuestProGress:Create()
	self:AddSWF('randomResult.swf',true,'bottom');
end

function UIRamdomQuestProGress:OnLoaded(objSwf)
	objSwf.btn_quit.click = function () RandomQuestController:ReqRandomDungeonExit() end
end

function UIRamdomQuestProGress:OnShow()
	self:OnChangePanel();
end

function UIRamdomQuestProGress:GetWidth()
	return 487
end

function UIRamdomQuestProGress:OnChangePanel()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local cfg = t_qiyuzu[self.questId];
	local nextCfg = t_qiyuzu[self.questId + 1];
	if not nextCfg then
		objSwf.icon_end._visible = true;
		objSwf.icon_index._visible = false;
	else
		local index = cfg.step;
		objSwf.icon_end._visible = false;
		objSwf.icon_index._visible = true;
		objSwf.icon_index.txt_index.num = index;
	end
end

function UIRamdomQuestProGress:Open()
	self:Show();
end

UIRamdomQuestProGress.questId = nil;
function UIRamdomQuestProGress:SetQuestID(id)
	local cfg = t_qiyuzu[id];
	if not cfg then return end
	self.questId = id;
end

function UIRamdomQuestProGress:OnHide()

end
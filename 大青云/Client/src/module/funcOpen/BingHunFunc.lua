--[[
兵魂功能
lizhuangzhuang
2015年10月9日16:58:09
]]

_G.BingHunFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.BingHun,BingHunFunc);

BingHunFunc.waitOpenShow = false;

function BingHunFunc:OnFuncOpen()
	MainPlayerController:DeleteBinghun()
	SkillModel:SetShortCut(18,0);
	Notifier:sendNotification(NotifyConsts.SkillShortCutChange,{pos=18,skillId=0});
	local cfg = t_binghun[999];
	if cfg then
		AutoBattleModel:RemoveSkill(cfg.skill);
	end
	--
	local modelId = 0;
	if MainPlayerModel.humanDetailInfo.eaProf == enProfType.eProfType_Sickle then
		modelId = 20010999;
	elseif MainPlayerModel.humanDetailInfo.eaProf == enProfType.eProfType_Sword then
		modelId = 20020999;
	elseif MainPlayerModel.humanDetailInfo.eaProf == enProfType.eProfType_Human then
		modelId = 20030999;
	else
		modelId = 20040999;
	end
	if CPlayerMap:GetCurMapID() == 10340005 then
		self.waitOpenShow = true;
		self.modelId = modelId;
	else
		UIBingHunShow:Open(modelId)
	end
end

function BingHunFunc:OnChangeSceneMap()
	if self.waitOpenShow then
		TimerManager:RegisterTimer(function()
			UIBingHunShow:Open(self.modelId);
		end,200,1)
		self.waitOpenShow = false;
	end
end

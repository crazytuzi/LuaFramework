--[[
TipsTool显示VO
lizhuangzhuang
2014年10月14日11:09:15
]]

_G.TipsToolInfoVO = {};

TipsToolInfoVO.width = 0;
TipsToolInfoVO.tipsStr = "";
TipsToolInfoVO.showIcon = false;
TipsToolInfoVO.iconUrl = "";
TipsToolInfoVO.iconPos = {x=0,y=0};
TipsToolInfoVO.showEquiped = false;
TipsToolInfoVO.qualityUrl = "";
TipsToolInfoVO.tipsEffectUrl = ""; 
TipsToolInfoVO.modelDraw = nil;
TipsToolInfoVO.modelDrawArgs = nil;
TipsToolInfoVO.superStar = 0;
TipsToolInfoVO.showBiao = "";
TipsToolInfoVO.iconLevelUrl = "";

function TipsToolInfoVO:new()
	local obj = {};
	for k,v in pairs(TipsToolInfoVO) do
		obj[k] = v;
	end
	return obj;
end

function TipsToolInfoVO:CopyDataFromTips(tips)
	self.itemID = tips:GetItemID()
	self.width = tips:GetWidth();
	self.tipsStr = tips:GetStr();
	self.showIcon = tips:GetShowIcon();
	self.iconUrl = tips:GetIconUrl();
	self.iconPos = tips:GetIconPos();
	self.showEquiped = tips:GetShowEquiped();
	self.qualityUrl = tips:GetQualityUrl();
	self.tipsEffectUrl = tips:GetTipsEffectUrl();
	self.quality = tips:GetQuality();
	self.modelDraw = tips:GetModelDraw();
	self.modelDrawArgs = tips:GetModelDrawArgs();
	self.superStar = tips:GetSuperStar();
	self.showBiao = tips:GetShowBiao();
	self.iconLevelUrl = tips:GetIconLevelUrl();
	self.debugInfo = tips:GetDebugInfo();
	self.showType = tips:GetTipsType();
	self.relicIcon = tips:GetRelicIcon()
end

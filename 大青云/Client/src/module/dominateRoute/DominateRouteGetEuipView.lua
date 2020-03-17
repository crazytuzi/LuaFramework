--[[
	获得新装备位
	2015年6月8日, PM 09:15:24
	wangyanwei
]]

_G.UIDominateRouteGetEuip = BaseUI:new('UIDominateRouteGetEuip');

function UIDominateRouteGetEuip:Create()
	self:AddSWF('dominateRouteGetEquip.swf',true,'top');
end

function UIDominateRouteGetEuip:OnLoaded(objSwf)
	objSwf.btn_quit.click = function () self:Hide(); end
	objSwf.item.rollOver = function () self:OnFirstOver(); end
	objSwf.item.rollOut = function () TipsManager:Hide(); end
	objSwf.effect.complete = function () objSwf.effect.visible = false; objSwf.effect:stopEffect(); end
end

function UIDominateRouteGetEuip:OnShow()
	self:OnChangeReward();
	self:OnChangeTxt();
	self:OnPlayEffect();
end

--播放特效
function UIDominateRouteGetEuip:OnPlayEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.effect.visible = true;
	objSwf.effect:playEffect(1);
end

function UIDominateRouteGetEuip:GetWidth()
	return 290
end

function UIDominateRouteGetEuip:GetHeight()
	return 230
end

--首通奖励移入
function UIDominateRouteGetEuip:OnFirstOver()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not self.euipID then return end
	local cfg = t_zhuzairoad[self.euipID];
	if not cfg then return end
	TipsManager:ShowBtnTips(cfg.firstTipStr,TipsConsts.Dir_RightDown);
end

function UIDominateRouteGetEuip:OnChangeReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local iconCfg = t_equip[t_zhuzairoad[self.euipID].firstIcon];
	if not iconCfg then print('Error----------装备表没有此ID-----' .. t_zhuzairoad[self.euipID].firstIcon) return end
	local rewardSlotVO = RewardSlotVO:new();
	rewardSlotVO.id = iconCfg.id;
	rewardSlotVO.count = 0;
	objSwf.item:setData(rewardSlotVO:GetUIData());
end

function UIDominateRouteGetEuip:OnChangeTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local euipID = t_zhuzairoad[self.euipID].firstReward;
	local euipCfg = t_equipcreate[euipID];
	objSwf.txt_name.text = euipCfg.name;
end

UIDominateRouteGetEuip.euipID = 0;
function UIDominateRouteGetEuip:Open(id)
	self.euipID = id;
	local cfg = t_zhuzairoad[self.euipID];
	if not cfg then return end
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIDominateRouteGetEuip:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.effect:stopEffect();
end
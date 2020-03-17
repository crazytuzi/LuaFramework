--[[
神兵
wangshuai
]]

_G.UIRanklistRightNewTianShen = BaseSlotPanel:new("UIRanklistRightNewTianShen")

UIRanklistRightNewTianShen.SlotTotalNum = 4;

UIRanklistRightNewTianShen.skilllist = {};

function UIRanklistRightNewTianShen:Create()
	self:AddSWF("RanklistRightNewTianShenPanel.swf",true,nil)
end;

function UIRanklistRightNewTianShen:OnLoaded(objSwf)
	objSwf.listSkill.itemRollOver    = function(e) self:OnSkillRollOver(e); end
	objSwf.listSkill.itemRollOut     = function() TipsManager:Hide() end

	objSwf.list.itemRollOver = function(e) self:ItemOver(e)end;
	objSwf.list.itemRollOut = function() self:ItemOut()end;

	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end;
end;

function UIRanklistRightNewTianShen:OnShow()
	self:RefreshData();
end;

function UIRanklistRightNewTianShen:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIRanklistRightNewTianShen:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self:RemoveAllSlotItem()
end;

function UIRanklistRightNewTianShen:RefreshData()
	self:DrawModel();
	self:SetInfo();
	self:SetSkillInfo();
	
end;

function UIRanklistRightNewTianShen:SetSkillInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local sbList = RankListModel:GetOtherRoleShengBing().skillList;

	-- 被动技能
	local list = RankListUtils:GetPassiveSkill(SkillConsts.ShowType_MagicWeapon,sbList);
	local listSkill = objSwf.listSkill;
	listSkill.dataProvider:cleanUp();
	for i, vo in ipairs(list) do
		local listVO = RankListUtils:GetSkillListVO(vo.skillId, vo.lvl);
		table.push( self.skilllist, listVO );
		listSkill.dataProvider:push( UIData.encode(listVO) );
	end
	listSkill:invalidateData();

end;

function UIRanklistRightNewTianShen:SetInfo()
	local objSwf = self.objSwf;
	local level = RankListModel:GetOtherRoleNewTianShen().level

	--objSwf.nameLoader.source= ResUtil:GetRankMagicWeaponNameImg(level)
end;

local viewPort;
function UIRanklistRightNewTianShen:DrawModel()
	local objSwf = self.objSwf;
	local tianshenId = RankListModel:GetOtherRoleNewTianShen().level;
	if not objSwf then return; end
	local uiCfg = t_newtianshen[tianshenId]
	if not uiCfg then
		Error("Cannot find config of tianshen ID:"..tianshenId);
		return;
	end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1000, 1000); end
		self.objUIDraw = UISceneDraw:new( "MagicWeaponRanklist", objSwf.modelload, viewPort );
	end
	self.objUIDraw:SetUILoader( objSwf.modelload );
	local sen = uiCfg.rank_ui_up_sen;
	if sen and sen ~= "" then
		self.objUIDraw:SetScene( uiCfg.rank_ui_up_sen );
		self.objUIDraw:SetDraw( true );
	end
end;

-- 显示正常的tips
function UIRanklistRightNewTianShen:OnSkillRollOver(e)
	local skillInfo = e.item or e.target.data;
	if not skillInfo then return; end
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = skillInfo.skillId, condition = false,unShowLvlUpPrompt =true, get = skillInfo.lvl > 0 };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end
function UIRanklistRightNewTianShen:ItemOver(e)
	if not e.item.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetMagicWeaponEquipNameByPos(e.item.pos));
		return;
	end

	local itemTipsVO = self:GetEquipTipVO(e.item.tid);
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

function UIRanklistRightNewTianShen:ItemOut()
	TipsManager:Hide();
end;
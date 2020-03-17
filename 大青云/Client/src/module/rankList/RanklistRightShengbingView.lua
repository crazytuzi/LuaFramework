--[[
神兵
wangshuai
]]

_G.UIRanklistRightShengbing = BaseSlotPanel:new("UIRanklistRightShengbing")

UIRanklistRightShengbing.SlotTotalNum = 4;

UIRanklistRightShengbing.skilllist = {};

function UIRanklistRightShengbing:Create()
	self:AddSWF("RanklistRightShengbingPanel.swf",true,nil)
end;

function UIRanklistRightShengbing:OnLoaded(objSwf)
	objSwf.listSkill.itemRollOver    = function(e) self:OnSkillRollOver(e); end
	objSwf.listSkill.itemRollOut     = function() TipsManager:Hide() end

	objSwf.list.itemRollOver = function(e) self:ItemOver(e)end;
	objSwf.list.itemRollOut = function() self:ItemOut()end;

	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end;
end;

function UIRanklistRightShengbing:OnShow()
	self:RefreshData();
end;

function UIRanklistRightShengbing:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIRanklistRightShengbing:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self:RemoveAllSlotItem()
end;

function UIRanklistRightShengbing:RefreshData()
	self:DrawSB()
	self:SetInfo();
	self:SetSkillInfo()
	self:ShowEquips()
end;

function UIRanklistRightShengbing:SetSkillInfo()
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

function UIRanklistRightShengbing:SetInfo()
	local objSwf = self.objSwf;
	local level = RankListModel:GetOtherRoleShengBing().level
	local cfg = t_shenbing[level];
	local lvl = level;
	lvl = RankListUtils:GetlvlSource(lvl)
	objSwf.lvlLoader.num = lvl;

	local nameUrl = ResUtil:GetRankMagicWeaponNameImg(level)
	objSwf.nameLoader.source = nameUrl;
end;

local viewPort;
function UIRanklistRightShengbing:DrawSB()
	local objSwf = self.objSwf;
	local shengblvl = RankListModel:GetOtherRoleShengBing().level;
	if not objSwf then return; end
	local uiCfg = t_shenbing[shengblvl]
	if not uiCfg then
		Error("Cannot find config of shenbing level:"..shengblvl);
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
function UIRanklistRightShengbing:OnSkillRollOver(e)
	local skillInfo = e.item or e.target.data;
	if not skillInfo then return; end
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = skillInfo.skillId, condition = false,unShowLvlUpPrompt =true, get = skillInfo.lvl > 0 };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIRanklistRightShengbing:ShowEquips()
	local equipList = RankListModel:GetOtherRoleShengBing().equipList;
	local listvo = self:GetEquipUIList(equipList)
	self.objSwf.list.dataProvider:cleanUp();
	self.objSwf.list.dataProvider:push(unpack(listvo));
	self.objSwf.list:invalidateData();
end


function UIRanklistRightShengbing:ItemOver(e)
	if not e.item.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetMagicWeaponEquipNameByPos(e.item.pos));
		return;
	end

	local itemTipsVO = self:GetEquipTipVO(e.item.tid);
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

function UIRanklistRightShengbing:ItemOut()
	TipsManager:Hide();
end;

--获取坐骑装备VO
function UIRanklistRightShengbing:GetEquipUIList(list)
	local UIDatalist = {};
	for k, v in pairs(list) do
		table.push(UIDatalist,v:GetUIData());
	end
	return UIDatalist;
end

--获取坐骑装备tip信息
function UIRanklistRightShengbing:GetEquipTipVO(tid)
	--他人信息中个数是1  绑定状态为1
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid,1,1);
	local equipList = RankListModel:GetOtherRoleShengBing().equipList;
	local vo = nil;
	for k, v in pairs(equipList) do
		if v.tid == tid then
			vo = v;
			break;
		end
	end

	if vo then
		if vo.bind == 0 then
			itemTipsVO.bindState = BagConsts.Bind_None;
		else
			itemTipsVO.bindState = BagConsts.Bind_Bind;
		end
	end
	return itemTipsVO;
end
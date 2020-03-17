--[[
玉佩
wangshuai
]]

_G.UIRanklistRightMingYu = BaseSlotPanel:new("UIRanklistRightMingYu")

UIRanklistRightMingYu.SlotTotalNum = 4;

UIRanklistRightMingYu.skilllist = {};

function UIRanklistRightMingYu:Create()
	self:AddSWF("RanklistRightMingYuPanel.swf",true,nil)
end;

function UIRanklistRightMingYu:OnLoaded(objSwf)
	objSwf.listSkill.itemRollOver    = function(e) self:OnSkillRollOver(e); end
	objSwf.listSkill.itemRollOut     = function() TipsManager:Hide() end

	objSwf.list.itemRollOver = function(e) self:ItemOver(e)end;
	objSwf.list.itemRollOut = function() self:ItemOut()end;

	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end;

	for i = 1, 6 do
		objSwf["skill"..i]._visible = false;
	end
end;

function UIRanklistRightMingYu:OnShow()
	self:RefreshData();
end;

function UIRanklistRightMingYu:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIRanklistRightMingYu:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self:RemoveAllSlotItem()
end;

function UIRanklistRightMingYu:RefreshData()
	self:DrawSB()
	self:SetInfo();
--	self:SetSkillInfo()
	self:ShowEquips()
end;

function UIRanklistRightMingYu:SetSkillInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local sbList = RankListModel:GetOtherRoleMingYu().skillList;
	-- 被动技能
	local list = RankListUtils:GetPassiveSkill(SkillConsts.ShowType_MingYu,sbList);
	local listSkill = objSwf.listSkill;
	listSkill.dataProvider:cleanUp();
	for i, vo in ipairs(list) do
		local listVO = RankListUtils:GetSkillListVO(vo.skillId, vo.lvl);
		table.push( self.skilllist, listVO );
		listSkill.dataProvider:push( UIData.encode(listVO) );
	end
	listSkill:invalidateData();

end;

function UIRanklistRightMingYu:SetInfo()
	local objSwf = self.objSwf;
	local level = RankListModel:GetOtherRoleMingYu().level
	local cfg = t_mingyu[level];
	local lvl = level;
	lvl = RankListUtils:GetlvlSource(lvl)
	objSwf.lvlLoader.num = lvl;

	local nameUrl = ResUtil:GetRankMingYuNameImg(level)
	objSwf.nameLoader.source = nameUrl;
end;

local viewPort;
function UIRanklistRightMingYu:DrawSB()
	local objSwf = self.objSwf;
	local shengblvl = RankListModel:GetOtherRoleMingYu().level;
	if not objSwf then return; end
	local uiCfg = t_mingyu[shengblvl]
	if not uiCfg then
		Error("Cannot find config of mingyu level:"..shengblvl);
		return;
	end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1000, 1000); end
		self.objUIDraw = UISceneDraw:new( "MingYuRanklist", objSwf.modelload, viewPort );
	end
	self.objUIDraw:SetUILoader( objSwf.modelload );
	local sen = uiCfg.rank_ui_up_sen;
	if sen and sen ~= "" then
		self.objUIDraw:SetScene( uiCfg.rank_ui_up_sen );
		self.objUIDraw:SetDraw( true );
	end
end;

-- 显示正常的tips
function UIRanklistRightMingYu:OnSkillRollOver(e)
	local skillInfo = e.item or e.target.data;
	if not skillInfo then return; end
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = skillInfo.skillId, condition = false,unShowLvlUpPrompt =true, get = skillInfo.lvl > 0 };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIRanklistRightMingYu:ShowEquips()
	local equipList = RankListModel:GetOtherRoleMingYu().equipList;
	local listvo = self:GetEquipUIList(equipList)
	self.objSwf.list.dataProvider:cleanUp();
	self.objSwf.list.dataProvider:push(unpack(listvo));
	self.objSwf.list:invalidateData();
end


function UIRanklistRightMingYu:ItemOver(e)
	if not e.item.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetMingYuEquipNameByPos(e.item.pos));
		return;
	end

	local itemTipsVO = self:GetEquipTipVO(e.item.tid);
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

function UIRanklistRightMingYu:ItemOut()
	TipsManager:Hide();
end;

--获取坐骑装备VO
function UIRanklistRightMingYu:GetEquipUIList(list)
	local UIDatalist = {};
	for k, v in pairs(list) do
		table.push(UIDatalist,v:GetUIData());
	end
	return UIDatalist;
end

--获取坐骑装备tip信息
function UIRanklistRightMingYu:GetEquipTipVO(tid)
	--他人信息中个数是1  绑定状态为1
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid,1,1);
	local equipList = RankListModel:GetOtherRoleMingYu().equipList;
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
--[[
法宝 灵器
wangshuai
]]

_G.UIRanklistRightLingQi = BaseSlotPanel:new("UIRanklistRightLingQi")

UIRanklistRightLingQi.SlotTotalNum = 4;

UIRanklistRightLingQi.skilllist = {};
UIRanklistRightLingQi.zhudongSkillId = 0;
function UIRanklistRightLingQi:Create()
	self:AddSWF("RanklistRightLingQiPanel.swf",true,nil)
end;

function UIRanklistRightLingQi:OnLoaded(objSwf)
	objSwf.listSkill.itemRollOver    = function(e) self:OnSkillRollOver(e); end
	objSwf.listSkill.itemRollOut     = function() TipsManager:Hide() end

	objSwf.list.itemRollOver = function(e) self:ItemOver(e)end;
	objSwf.list.itemRollOut = function() self:ItemOut()end;

	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end;

	--主动技能
	objSwf.skill.rollOver = function(e) self:OnSkillItemOver(); end
	objSwf.skill.rollOut  = function() self:OnSkillItemOut();  end
end;

function UIRanklistRightLingQi:OnShow()
	self:RefreshData();
end;

function UIRanklistRightLingQi:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIRanklistRightLingQi:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self:RemoveAllSlotItem()
end;

function UIRanklistRightLingQi:RefreshData()
	self:DrawSB()
	self:SetInfo();
	self:SetSkillInfo()
	self:ShowEquips()
end;

function UIRanklistRightLingQi:SetSkillInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local sbList = RankListModel:GetOtherRoleLingQi().skillList;
	-- 被动技能
	local list = RankListUtils:GetPassiveSkill(SkillConsts.ShowType_LingQi,sbList);
	local listSkill = objSwf.listSkill;
	listSkill.dataProvider:cleanUp();
	for i, vo in ipairs(list) do
		local listVO = RankListUtils:GetSkillListVO(vo.skillId, vo.lvl);
		table.push( self.skilllist, listVO );
		listSkill.dataProvider:push( UIData.encode(listVO) );
	end
	listSkill:invalidateData();

	--获取主动VO
	local zhudongVO;
	for k, v in pairs(sbList) do
		if v:GetCfg().type ~= 3 then
			zhudongVO = v;
		end
	end
	objSwf.skill._visible = false;
	if zhudongVO then
		local skillZhudong = {}
		skillZhudong.iconUrl = ResUtil:GetSkillIconUrl(zhudongVO:GetCfg().icon, "54")
		skillZhudong.isUpdate = 0
		skillZhudong.skillId = zhudongVO:GetID()
		self.zhudongSkillId = skillZhudong.skillId;
		-- 主动技能
		if skillZhudong then
			objSwf.skill._visible = true
			objSwf.skill.btnPlus.visible = false
			objSwf.skill.btnskill.visible = true
			objSwf.skill.iconLoader.visible = true
			if objSwf.skill.iconLoader.source ~= skillZhudong.iconUrl then
				objSwf.skill.iconLoader.source = skillZhudong.iconUrl
			end
		end
	end
end;

function UIRanklistRightLingQi:SetInfo()
	local objSwf = self.objSwf;
	local level = RankListModel:GetOtherRoleLingQi().level
	local cfg = t_lingqi[level];

	local lvl = level;
	lvl = RankListUtils:GetlvlSource(lvl)
	objSwf.lvlLoader.num = lvl;

	local nameUrl = ResUtil:GetRankLingQiNameImg(level)
	objSwf.nameLoader.source = nameUrl;
end;

local viewPort;
function UIRanklistRightLingQi:DrawSB()
	local objSwf = self.objSwf;
	local shengblvl = RankListModel:GetOtherRoleLingQi().level;
	if not objSwf then return; end
	local uiCfg = t_lingqi[shengblvl]
	if not uiCfg then
		Error("Cannot find config of lingqi level:"..shengblvl);
		return;
	end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1000, 1000); end
		self.objUIDraw = UISceneDraw:new( "LingQiRanklist", objSwf.modelload, viewPort );
	end
	self.objUIDraw:SetUILoader( objSwf.modelload );
	local sen = uiCfg.rank_ui_up_sen;
	if sen and sen ~= "" then
		self.objUIDraw:SetScene( uiCfg.rank_ui_up_sen );
		self.objUIDraw:SetDraw( true );
	end
end;

-- 显示正常的tips
function UIRanklistRightLingQi:OnSkillRollOver(e)
	local skillInfo = e.item or e.target.data;
	if not skillInfo then return; end
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = skillInfo.skillId, condition = false,unShowLvlUpPrompt =true, get = skillInfo.lvl > 0 };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIRanklistRightLingQi:ShowEquips()
	local equipList = RankListModel:GetOtherRoleLingQi().equipList;
	local listvo = self:GetEquipUIList(equipList)
	self.objSwf.list.dataProvider:cleanUp();
	self.objSwf.list.dataProvider:push(unpack(listvo));
	self.objSwf.list:invalidateData();
end


function UIRanklistRightLingQi:ItemOver(e)
	if not e.item.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetLingQiEquipNameByPos(e.item.pos));
		return;
	end

	local itemTipsVO = self:GetEquipTipVO(e.item.tid);
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

function UIRanklistRightLingQi:ItemOut()
	TipsManager:Hide();
end;

--获取坐骑装备VO
function UIRanklistRightLingQi:GetEquipUIList(list)
	local UIDatalist = {};
	for k, v in pairs(list) do
		table.push(UIDatalist,v:GetUIData());
	end
	return UIDatalist;
end

--获取坐骑装备tip信息
function UIRanklistRightLingQi:GetEquipTipVO(tid)
	--他人信息中个数是1  绑定状态为1
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid,1,1);
	local equipList = RankListModel:GetOtherRoleLingQi().equipList;
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

--技能鼠标移上
function UIRanklistRightLingQi:OnSkillItemOver()
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = self.zhudongSkillId, condition = false,unShowLvlUpPrompt =true, get = true };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

--技能鼠标移出
function UIRanklistRightLingQi:OnSkillItemOut(e)
	TipsManager:Hide();
end
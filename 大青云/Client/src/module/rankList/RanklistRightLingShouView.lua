--[[
	灵兽right
	wangshuai
]]

_G.UIRanklistRightLingShou = BaseUI:new("UIRanklistRightLingShou")

UIRanklistRightLingShou.roleRender = {} 

UIRanklistRightLingShou.skillicon = {}
UIRanklistRightLingShou.skilllist = {}
UIRanklistRightLingShou.skillTotalNum = 4;--UI上技能总数

UIRanklistRightLingShou.zhudongskillicon = {}
UIRanklistRightLingShou.zhudongskilllist = {}
UIRanklistRightLingShou.zhudongskillTotalNum = 2

UIRanklistRightLingShou.wuhunId = 0;


function UIRanklistRightLingShou:Create()
	self:AddSWF("RanklistRightLingshouPanel.swf",true,nil)
end;

function UIRanklistRightLingShou:OnLoaded(objSwf)
	self.roleRender = RoleDrawRender:New(objSwf.rolemodeLoad, 'UIzhanshouRanklist',true)

	--被动技能
	for i=1,self.skillTotalNum do
		self.skillicon[i] = objSwf["skill"..i]
		self.skillicon[i].btnskill.rollOver = function(e) self:SkillBidongRollOver(i); end
		self.skillicon[i].btnskill.rollOut  = function() TipsManager:Hide(); end
	end
	
	--主动技能
	for i=1,self.zhudongskillTotalNum do
		self.zhudongskillicon[i] = objSwf["skillZhudong"..i]
		self.zhudongskillicon[i].btnskill.rollOver = function(e) self:OnSkillItemOver(i); end
		self.zhudongskillicon[i].btnskill.rollOut  = function() TipsManager:Hide();  end
	end

	objSwf.swapBtn.click = function() self:ShowZhanshi()end;
	
	objSwf.list.itemRollOver = function(e) self:ItemOver(e)end;
	objSwf.list.itemRollOut = function() self:ItemOut()end;
end;

function UIRanklistRightLingShou:OnShow()
	self:RefreshData()
	self:OnShowZhanshouMoxin()
	self:ShowEquip();
end;

UIRanklistRightLingShou.isZhanshi = false;
function UIRanklistRightLingShou:ShowZhanshi()
	self.isZhanshi = not self.isZhanshi;
	self:OnShowZhanshouMoxin();
end;

function UIRanklistRightLingShou:OnShowZhanshouMoxin()
	local objSwf = self.objSwf;
	local wuhunCfg = t_wuhun[self.wuhunId];
	local cfg = t_lingshouui[wuhunCfg.ui_id];
	if self.isZhanshi then 
		self:SetRoleRender();
		local dataArr = split(cfg.ui_node,"#");
		for k,v in pairs (dataArr) do
			self.objUIDraw:NodeVisible(v,false)
		end
	else
		self.roleRender:OnHide();
		local dataArr = split(cfg.ui_node,"#");
		for k,v in pairs (dataArr) do
			self.objUIDraw:NodeVisible(v,true)
		end
	end;
	-- objSwf.modeLoad._visible =self.isZhanshi;
	-- objSwf.rolemodeLoad._visible = not self.isZhanshi;
end;

function UIRanklistRightLingShou:RefreshData()
	local infodata = RankListModel:GetOtherRoleLingshow()
	self.wuhunId = infodata.wuhunId
	self:Show3DWeapon()
	self:SetRoleRender()
	self:UpdateSkill();
	local cfg = t_wuhun[self.wuhunId];
	local ccfg = t_lingshouui[cfg.ui_id]
	local order = cfg.order
	order = RankListUtils:GetlvlSource(order)
	self.objSwf.imgLevel.num = order
	self.objSwf.nameLoader.source = ResUtil:GetWuhunIcon(ccfg.rank_name_icon)
end;

function UIRanklistRightLingShou:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	if self.roleRender then 
		self.roleRender:OnHide()
	end
end;


function UIRanklistRightLingShou:UpdateSkill(wuhunId)
	local objSwf = self.objSwf;
	local wuhunId = self.wuhunId
	local cfg = t_wuhun[wuhunId]
	-- 被动技能
	for i=1, self.skillTotalNum do
		self.skillicon[i].visible = true
		self.skillicon[i].btnskill.visible = false
		self.skillicon[i].imgup.visible = false
		self.skillicon[i].iconLoader.visible = false
	end
	
	local listvoc = RankListModel:GetOtherRoleLingshow().skillList
	local list = RankListUtils:GetPassiveSkill(SkillConsts.ShowType_WuHun,listvoc)
	local templist = {};
	for i, voi in pairs(list) do 
		for c,cvo in pairs(listvoc) do
			if voi.skillId == cvo.skillId then 
				table.push(templist,list[i])
				break;
			end;
		end;
	end;

	for i= 1, self.skillTotalNum do
		local listvo = SpiritsUtil:GetSkillListVO(templist[i].skillId,templist[i].lvl)
		if listvo then
			self.skillicon[i].btnskill.visible = true
			self.skillicon[i].iconLoader.visible = true
			if cfg.order < templist[i].cfg.needSpecail then
				self.skillicon[i].iconLoader.source = ImgUtil:GetGrayImgUrl(listvo.iconUrl)
			else
				self.skillicon[i].iconLoader.source = listvo.iconUrl
			end
			
			self.skilllist[i] = listvo
		end
	end
	
	-- 主动技能
	local skillZhudongs = SpiritsUtil:GetWuhunSkillZhudong(wuhunId)
	for i=1, self.zhudongskillTotalNum do
		self.zhudongskillicon[i].visible = true
		self.zhudongskillicon[i].btnskill.visible = false
		self.zhudongskillicon[i].imgup.visible = false
		self.zhudongskillicon[i].iconLoader.visible = false
	end
	
	for i= 1, self.zhudongskillTotalNum do
		self.zhudongskillicon[i].btnskill.visible = true
		self.zhudongskillicon[i].iconLoader.visible = true
		local listvo = skillZhudongs[i]
		self.zhudongskillicon[i].iconLoader.source = listvo.iconUrl
		self.zhudongskilllist[i] = listvo
	end	
end

function UIRanklistRightLingShou:SetRoleRender()
	local wuhunId = self.wuhunId;
	local data = RankListModel.roleDetaiedinfo 
	self.roleVO = {}
	self.roleVO.prof = data.prof
	self.roleVO.arms = data.arms
	self.roleVO.dress = data.dress
	self.roleVO.fashionsHead = data.fashionsHead
	self.roleVO.fashionsArms = data.fashionsArms
	self.roleVO.fashionsDress = data.fashionsDress
	self.roleVO.sex = data.sex
	self.roleVO.wuhunId = wuhunId
	self.roleRender:DrawRole(self.roleVO, true)
end


local viewPort;
function UIRanklistRightLingShou:Show3DWeapon()
	local objSwf = self.objSwf;
	local wuhunId = self.wuhunId
	if not objSwf then return; end
	local cfg = t_wuhun[wuhunId]
	
	if not cfg then return end
	if not cfg.order_next then return end
	-- local currentShowLevel = cfg.order_next
	local uiCfg = t_lingshouui[cfg.ui_id]
	
	if not uiCfg then
		Error("Cannot find config of shenbing level:"..level);
		return;
	end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1920, 1080); end
		self.objUIDraw = UISceneDraw:new( "SpiritsLvlUpUI", objSwf.modeLoad, viewPort );
	end
	self.objUIDraw:SetUILoader( objSwf.modeLoad );
	local sen = uiCfg.ui_list;
	if sen and sen ~= "" then
		self.objUIDraw:SetScene( uiCfg.ui_list, function()
			self:OnShowZhanshouMoxin()
		end );
		self.objUIDraw:SetDraw( true );
	end
end


function UIRanklistRightLingShou:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	if self.roleRender then
		self.roleRender:OnDelete()
		self.roleRender = nil;
	end
end

function UIRanklistRightLingShou:SkillBidongRollOver(i)
	local objSwf = self.objSwf;
	local skillId = self.skilllist[i].skillId;
	local cfg = t_wuhun[self.wuhunId]
	self.skilllist[i].lvl = cfg.order
	local get = self.skilllist[i].lvl > 0;
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillId,condition=false,get=false,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end;

--技能鼠标移上
function UIRanklistRightLingShou:OnSkillItemOver(i)
	local objSwf = self.objSwf;
	if not self.zhudongskilllist or not self.zhudongskilllist[i] then return end
	local skillId = self.zhudongskilllist[i].skillId;
	if not skillId then return end
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=tonumber(skillId), condition = false,unShowLvlUpPrompt =true, get = false},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end

function UIRanklistRightLingShou:ShowEquip()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local uilist = OtherRoleUtil:GetLingShouEquipUIList(RankListModel.lingShouEquip);
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(uilist));
	objSwf.list:invalidateData();
end

function UIRanklistRightLingShou:ItemOver(e)
	if not e.item then return end
	if not e.item.hasItem then
		if not e.item.pos then return end
		TipsManager:ShowBtnTips(BagConsts:GetLingShouEquipNameByPos(e.item.pos));
		return;
	end
	local itemTipsVO = RankListUtils:GetLingShouEquipTipVO(e.item.tid);
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end	

function UIRanklistRightLingShou:ItemOut()
	TipsManager:Hide();
end
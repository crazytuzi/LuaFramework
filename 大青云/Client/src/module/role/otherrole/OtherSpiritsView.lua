--[[查看他人战兽面板
zhangshuhui
2015年5月6日10:33:06
]]

_G.UIOtherSpirits = BaseUI:new("UIOtherSpirits")

UIOtherSpirits.roleRender = nil
UIOtherSpirits.isShowRole = false
UIOtherSpirits.roleVO = nil

--技能列表
UIOtherSpirits.skilllist = {}
UIOtherSpirits.skillTotalNum = 4;--UI上技能总数

UIOtherSpirits.zhudongskilllist = {}
UIOtherSpirits.zhudongskillTotalNum = 2

UIOtherSpirits.isShowDes = false

function UIOtherSpirits:Create()
	self:AddSWF("otherspiritsPanel.swf", true, "center")
end


function UIOtherSpirits:OnLoaded(objSwf,name)
	--close button
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	
	self.roleRender = RoleDrawRender:New(objSwf.roleLoader, 'UIOtherSpirits',true)
	
	--objSwf.incrementFight._visible = false
	-- objSwf.fight.numFight.loadComplete = function()	
										-- objSwf.fight.numFight.x = 580 + (230 - objSwf.fight.numFight.width)/2
										-- objSwf.mcUpArrowZhanDouLi._x = objSwf.fight.numFight.x + objSwf.fight.numFight.width + 25;
										-- objSwf.txtUpZhanDouLi._x = objSwf.mcUpArrowZhanDouLi._x + 5
								   -- end
	objSwf.imgName.loaded = function()
	end
	
	local skillBeidongRollOver = function(i)
		local skillId = self.skilllist[i].skillId;
		local get = self.skilllist[i].lvl > 0;
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillId,condition=false,get=get},TipsConsts.ShowType_Normal,
							TipsConsts.Dir_RightUp);
	end
	--被动技能
	for i=1,self.skillTotalNum do
		objSwf["skill"..i].btnskill.rollOver = function(e) skillBeidongRollOver(i); end
		objSwf["skill"..i].btnskill.rollOut  = function() TipsManager:Hide();  end
	end
	
	--主动技能
	for i=1,self.zhudongskillTotalNum do
		objSwf["skillZhudong"..i].btnskill.rollOver = function(e) self:OnSkillItemOver(i); end
		objSwf["skillZhudong"..i].btnskill.rollOut  = function() TipsManager:Hide();  end
	end
	
	
	objSwf.btnRadioLinshou.click = function() 
		if not OtherRoleModel:GetWuhunId() or OtherRoleModel:GetWuhunId() == 0 then return end
		local wid = OtherRoleModel:GetWuhunId()
		self:ShowViewWuhunInfo( wid )
		
		local wuhunCfg = t_wuhun[wid]
		if not wuhunCfg then
			return
		end
		
		local cfg = t_lingshouui[wuhunCfg.ui_id];
		if not cfg then
			return;
		end
		objSwf.roleLoader._visible = false
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,true)
			end
		end
	end
	objSwf.btnRadioShenshou.click = function() 
		if not OtherRoleModel:GetWuhunId() or OtherRoleModel:GetWuhunId() == 0 then return end
		local wid = OtherRoleModel:GetWuhunId()
		self:ShowViewWuhunInfo( wid )
		
		local wuhunCfg = t_wuhun[wid]
		if not wuhunCfg then
			return
		end
		
		local cfg = t_lingshouui[wuhunCfg.ui_id];
		if not cfg then
			return;
		end
		
		self:SetRoleRender(wid)
		objSwf.roleLoader._visible = true
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,false)
			end
		end
	end
	objSwf.iconDes._alpha = 0
	objSwf.btnDesShow.rollOver = function()
		if self.isShowDes then return end
		local wuhunId = OtherRoleModel:GetWuhunId()
		if not wuhunId or wuhunId <= 0 then
			FPrint("要显示的武魂id不正确")
			return
		end
		local cfg = t_wuhun[wuhunId]
		if not cfg then return end
		local uiCfg = t_lingshouui[cfg.ui_id]
		if uiCfg and uiCfg.des_icon then
			objSwf.iconDes.desLoader.source = ResUtil:GetWuhunDesIcon(uiCfg.des_icon)
		end
		Tween:To(objSwf.iconDes,5,{_alpha=100});
		self.isShowDes = true
	end

	objSwf.btnDesShow.rollOut = function()
		if not self.isShowDes then return end
		
		Tween:To(objSwf.iconDes,1,{_alpha=0});
		self.isShowDes = false
	end
	--
	objSwf.list.itemRollOver = function(e) self:OnLingShouEquipRollOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
end

function UIOtherSpirits:OnDelete()
	if self.roleRender then
		self.roleRender:OnDelete()
		self.roleRender = nil;
	end
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIOtherSpirits:IsShowLoading()
	return true;
end

function UIOtherSpirits:GetWidth(szName)
	return 1489 
end

function UIOtherSpirits:GetHeight(szName)
	return 744
end

function UIOtherSpirits:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	self:UpdateCloseButton()
end

function UIOtherSpirits:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 100
	objSwf.mcMask._height = wHeight + 100
end

function UIOtherSpirits:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1280 ), 1380 )
end

function UIOtherSpirits:IsShowSound()
	return true;
end

function UIOtherSpirits:OnBtnCloseClick()
	self:Hide()
end

function UIOtherSpirits:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	self:InitUI();
	self:SetRoleRender(OtherRoleModel:GetWuhunId());
	self:ShowWuhunInfo()
	self:SetZhanshouAndLingshou()
	
	self:UpdateMask()
	
	self:UpdateCloseButton()
	self:ShowEquip();
end

function UIOtherSpirits:InitUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if OtherRoleModel:GetWuhunState() == 0 then
		objSwf.btnRadioLinshou.selected = true;
		objSwf.btnRadioShenshou.selected = false;
	else
		objSwf.btnRadioLinshou.selected = false;
		objSwf.btnRadioShenshou.selected = true;
	end
end

function UIOtherSpirits:SetZhanshouAndLingshou()
	local objSwf = self.objSwf
	if not objSwf then return end

	local wuhunCfg = t_wuhun[OtherRoleModel:GetWuhunId()]
	if not wuhunCfg then
		return
	end
	
	local cfg = t_lingshouui[wuhunCfg.ui_id];
	if not cfg then
		Error("Cannot find config of t_lingshouui. level:"..level);
		return;
	end
	
	if objSwf.btnRadioLinshou.selected then
		objSwf.roleLoader._visible = false
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,true)
			end
		end
	else
		objSwf.roleLoader._visible = true
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,false)
			end
		end
	end
end

function UIOtherSpirits:OnFullShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	if OtherRoleModel:GetWuhunId() then
		self:SetRoleRender(OtherRoleModel:GetWuhunId())
	end
	self.firstOpenState = false
end

function UIOtherSpirits:OnHide()
	self.firstOpenState = true
	if self.roleRender then 
		self.roleRender:OnHide()
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

---------------------------------ui事件处理------------------------------------

--技能鼠标移上
function UIOtherSpirits:OnSkillItemOver(i)
	local skillId = self.zhudongskilllist[i].skillId;
	if not skillId then return end
	local get = true;
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillId,condition=false,get=get},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end

--技能鼠标移出
function UIOtherSpirits:OnSkillItemOut(e)
	TipsManager:Hide();
end

---------------------------------ui逻辑------------------------------------

-- 显示武魂详细信息
function UIOtherSpirits:ShowWuhunInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local wuhunId = OtherRoleModel:GetWuhunId();
	if not wuhunId or wuhunId <= 0 then
		FPrint("要显示的武魂id不正确")
		return
	end

	local cfg = t_wuhun[wuhunId]
	if not cfg then return end
	
	self.currentShowLevel = wuhunId
	if not self.firstOpenState then
		self:SetRoleRender(wuhunId)
	end
	
	local uiCfg = t_lingshouui[cfg.ui_id]
	if uiCfg then
		objSwf.imgName.source = ResUtil:GetWuhunIcon(uiCfg.name_icon)
	end
	
	objSwf.lvlLoader.source = ResUtil:GetFeedUpLvlImg(cfg.order);
	
	self:UpdateFeed();
	
	-- 被动技能
	self:UpdateSkill(wuhunId, objSwf, cfg) 
	
	self:Show3DWeapon(wuhunId, false);
end

-- 技能
function UIOtherSpirits:UpdateSkill(wuhunId, objSwf, cfg)
	local cfg = t_wuhun[wuhunId]
	-- 被动技能
	for i=1, self.skillTotalNum do
		objSwf["skill"..i].visible = true
		objSwf["skill"..i].btnskill.visible = false
		objSwf["skill"..i].imgup.visible = false
		objSwf["skill"..i].iconLoader.visible = false
	end
	
	local listvoc = OtherRoleUtil:GetWuHunBeiDongSkill()
	local templist = RankListUtils:GetPassiveSkill(SkillConsts.ShowType_WuHun,listvoc)
	local list = {};
	for i, voi in pairs(listvoc) do
		for j, voj in pairs(templist) do
			if voi.skillId == voj.skillId then
				table.push(list,templist[j]);
				break;
			end
		end
	end
	for i= 1, self.skillTotalNum do
		local listvo = SpiritsUtil:GetSkillListVO(list[i].skillId,list[i].lvl)
		if listvo then
			objSwf["skill"..i].btnskill.visible = true
			objSwf["skill"..i].iconLoader.visible = true
			if cfg.order < list[i].cfg.needSpecail then
				objSwf["skill"..i].iconLoader.source = ImgUtil:GetGrayImgUrl(listvo.iconUrl)
			else
				objSwf["skill"..i].iconLoader.source = listvo.iconUrl
			end
			
			self.skilllist[i] = listvo
		end
	end
	
	-- 主动技能
	local skillZhudongs = SpiritsUtil:GetWuhunSkillZhudong(wuhunId)
	for i=1, self.zhudongskillTotalNum do
		objSwf["skillZhudong"..i].visible = true
		objSwf["skillZhudong"..i].btnskill.visible = false
		objSwf["skillZhudong"..i].imgup.visible = false
		objSwf["skillZhudong"..i].iconLoader.visible = false
	end
	
	for i= 1, self.zhudongskillTotalNum do
		objSwf["skillZhudong"..i].btnskill.visible = true
		objSwf["skillZhudong"..i].iconLoader.visible = true
		local listvo = skillZhudongs[i]
		objSwf["skillZhudong"..i].iconLoader.source = listvo.iconUrl
		self.zhudongskilllist[i] = listvo
	end
end

-- 属性
function UIOtherSpirits:UpdateProperty(wuhunId, objSwf, cfg)
	local vipUPRate = VipController:GetVipPowerPersentByIndexFlag(OtherRoleModel.otherhumanBSInfo.eaVIPLevel,302)/100;
	local addP = 0--属性加成
	local atttype = ''
	local att, def, hp, hit, dodge, critical, defcri = 0,0,0,0,0,0,0;
	local str = ""
	str = str .. "<textformat leading='16'><p>"	
	
	local addPro = 0
	atttype = AttrParseUtil.AttMap['att'];
	if OtherRoleModel.otherattrXlist[atttype] then
		addPro = toint(OtherRoleModel.otherattrXlist[atttype]);
	end
	str = str .. StrConfig["wuhun7"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	att = addPro
	
	addPro = 0
	atttype = AttrParseUtil.AttMap['def'];
	if OtherRoleModel.otherattrXlist[atttype] then
		addPro = toint(OtherRoleModel.otherattrXlist[atttype]);
	end
	str = str .. StrConfig["wuhun8"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	def = addPro
	
	addPro = 0
	atttype = AttrParseUtil.AttMap['hp'];
	if OtherRoleModel.otherattrXlist[atttype] then
		addPro = toint(OtherRoleModel.otherattrXlist[atttype]);
	end
	str = str .. StrConfig["wuhun9"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	hp = addPro
	
	addPro = 0
	atttype = AttrParseUtil.AttMap['cri'];
	if OtherRoleModel.otherattrXlist[atttype] then
		addPro = toint(OtherRoleModel.otherattrXlist[atttype]);
	end
	str = str .. StrConfig["wuhun10"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	critical = addPro
	
	addPro = 0
	atttype = AttrParseUtil.AttMap['dodge'];
	if OtherRoleModel.otherattrXlist[atttype] then
		addPro = toint(OtherRoleModel.otherattrXlist[atttype]);
	end
	str = str .. StrConfig["wuhun11"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	dodge = addPro
	
	addPro = 0
	atttype = AttrParseUtil.AttMap['hit'];
	if OtherRoleModel.otherattrXlist[atttype] then
		addPro = toint(OtherRoleModel.otherattrXlist[atttype]);
	end
	str = str .. StrConfig["wuhun12"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	hit = addPro
	
	addPro = 0
	atttype = AttrParseUtil.AttMap['defcri'];
	if OtherRoleModel.otherattrXlist[atttype] then
		addPro = toint(OtherRoleModel.otherattrXlist[atttype]);
	end
	str = str .. StrConfig["wuhun50"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	defcri = addPro
		
	str = str .. "</p></textformat>"
	
	objSwf.labProShow.htmlText = str
	-- 战斗力显示
	local list = {}
	
	if att ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaGongJi;
		vo.val = att;
		table.push(list,vo);
	end
	
	if def ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaFangYu;
		vo.val = def;
		table.push(list,vo);
	end
	
	if hp ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaMaxHp;
		vo.val = hp;
		table.push(list,vo);
	end
	
	if hit ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaMingZhong;
		vo.val = hit;
		table.push(list,vo);
	end
	
	if dodge ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaShanBi;
		vo.val = dodge;
		table.push(list,vo);
	end
	
	if critical ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaBaoJi;
		vo.val = critical;
		table.push(list,vo);
	end
	
	if  defcri ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaRenXing;
		vo.val = defcri;
		table.push(list,vo);
	end
	
	-- SpiritsUtil:Trace(list)
	objSwf.numLoaderFight.num = EquipUtil:GetFight(list);
end

-- 显示武魂详细信息
function UIOtherSpirits:ShowViewWuhunInfo(wuhunId)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if not OtherRoleModel:GetWuhunId() or OtherRoleModel:GetWuhunId() == 0 then return end
	local curwuhunId = OtherRoleModel:GetWuhunId()
	if not wuhunId or wuhunId <= 0 then
		FPrint("要显示的武魂id不正确")
		return
	end
	
	local curCfg = t_wuhun[curwuhunId]
	if not curCfg then return end

	local cfg = t_wuhun[wuhunId]	
	if not cfg then return end
	
	local uiCfg = t_lingshouui[cfg.ui_id]
	if uiCfg then
		objSwf.imgName.source = ResUtil:GetWuhunIcon(uiCfg.name_icon)
		-- if uiCfg.des_icon then
			-- objSwf.desLoader.source = ResUtil:GetWuhunDesIcon(uiCfg.des_icon)
		-- end
	end
		
	-- local lvlStr = tostring(cfg.order);
	-- if cfg.order == 10 then lvlStr = "a" end;
	-- objSwf.imgLevel:drawStr( lvlStr );
	objSwf.lvlLoader.source = ResUtil:GetFeedUpLvlImg(cfg.order);
	self:SetRoleRender(wuhunId)
	self:Show3DWeapon(wuhunId, false);
end

function UIOtherSpirits:UpdateFeed()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local wuhunId = OtherRoleModel:GetWuhunId();
	local cfg = t_wuhun[wuhunId]
	
	-- 属性
	self:UpdateProperty(wuhunId, objSwf, cfg)
end

function UIOtherSpirits:SetRoleRender(wuhunId)
	-- if self.roleVO and self.roleVO.wuhunId == wuhunId and not firstOpenState then
		-- return
	-- end

	self.roleVO = {}
	local info = OtherRoleModel.otherhumanBSInfo;
	self.roleVO.prof = OtherRoleModel.otherhumanBSInfo.prof
	self.roleVO.arms = info.arms
	self.roleVO.dress = info.dress
	self.roleVO.fashionsHead = info.fashionshead
	self.roleVO.fashionsArms = info.fashionsarms
	self.roleVO.fashionsDress = info.fashionsdress
	self.roleVO.wing = info.wing
	self.roleVO.suitflag = info.suitflag
	self.roleVO.sex = info.sex
	self.roleVO.wuhunId = wuhunId
	self.roleRender:DrawRole(self.roleVO, true)
end

-- 显示等级为level的3d神兵模型
-- showActive: 是否播放激活动作
local otherspiritesviewPort;
function UIOtherSpirits:Show3DWeapon(wuhunId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local wuhunCfg = t_wuhun[wuhunId]
	if not wuhunCfg then
		return
	end
	
	local cfg = t_lingshouui[wuhunCfg.ui_id];
	if not cfg then
		Error("Cannot find config of t_lingshouui. level:"..level);
		return;
	end
	
	if not self.objUIDraw then
		if not otherspiritesviewPort then otherspiritesviewPort = _Vector2.new(1333, 732); end
		self.objUIDraw = UISceneDraw:new( "UIOtherSpiritsScene", objSwf.loader, otherspiritesviewPort );
	end
	self.objUIDraw:SetUILoader(objSwf.loader);
	
	self.objUIDraw:SetScene( cfg.ui_sen, function()
		self:SetZhanshouAndLingshou()
	end );
	
	self.objUIDraw:SetDraw( true );
end
---------------------------以下是装备处理----------------------------
function UIOtherSpirits:ShowEquip()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = OtherRoleUtil:GetLingShouEquipUIList(OtherRoleModel.lingShouEquiplist);
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(list));
	objSwf.list:invalidateData();
end

function UIOtherSpirits:OnLingShouEquipRollOver(e)
	if not e.item.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetLingShouEquipNameByPos(e.item.pos));
		return;
	end
	local itemTipsVO = OtherRoleUtil:GetLingShouEquipTipVO(e.item.tid);
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end
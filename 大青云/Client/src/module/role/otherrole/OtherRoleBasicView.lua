--[[
角色：查看基础信息界面
2015年5月7日8:24:59
haohu
]]

_G.UIOtherRoleBasic = BaseUI:new("UIOtherRoleBasic");

UIOtherRoleBasic.objUIDraw = nil;--3d渲染器
UIOtherRoleBasic.objAvatar = nil;--人物模型
UIOtherRoleBasic.meshDir = 0; --模型的当前方向
UIOtherRoleBasic.roleTurnDir = 0; --模型的当前旋转方向

function UIOtherRoleBasic:Create()
	self:AddSWF('otherroleBasicPanel.swf', true, nil);
end

function UIOtherRoleBasic:OnLoaded( objSwf )
	self:Init( objSwf );
	self:RegisterEvents( objSwf );
end

function UIOtherRoleBasic:Init( objSwf )
	objSwf.roleLoader.hitTestDisable = true;
	-- objSwf.otherfun.btnmount.click = function() self:OnBtnMountClick(); end;
	-- objSwf.otherfun.btnspirite.click = function() self:OnBtnSpiriteClick(); end;
	
	objSwf.list.itemRollOver = function(e) self:OnItemRollOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	
	objSwf.itemlist.itemRollOver = function(e) self:OnWingItemRollOver(e); end
	objSwf.itemlist.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.btnLovelyPet._visible = true;
	-- 初始化属性label
	-- objSwf.btnHp.data        = enAttrType.eaMaxHp;
	-- objSwf.btnAtk.data       = enAttrType.eaGongJi;
	-- objSwf.btnDef.data       = enAttrType.eaFangYu;

	-- objSwf.btnHit.data       = enAttrType.eaMingZhong;
	-- objSwf.btnDodge.data     = enAttrType.eaShanBi;
	-- objSwf.btnCrit.data      = enAttrType.eaBaoJi;
	-- objSwf.btnTenacity.data  = enAttrType.eaRenXing;

	-- objSwf.btnMoveSpeed.data = enAttrType.eaMoveSpeed;
end

function UIOtherRoleBasic:RegisterEvents( objSwf )
	objSwf.btnTurn1.stateChange = function(e) self:OnBtnTurnLeftStateChange(e.state); end
	objSwf.btnTurn2.stateChange = function(e) self:OnBtnTurnRightStateChange(e.state); end
	self:ShowLovelyPetHeadInfo();
	-- self:RegisterAttrTips( objSwf );
end

--显示宠物信息
function UIOtherRoleBasic:ShowLovelyPetHeadInfo()
	-- print('------------------------------UIOtherRoleBasic:ShowLovelyPetHeadInfo()-')
	-- print('------------------------------UIOtherRoleBasic:ShowLovelyPetHeadInfo()-:'..OtherRoleModel.petId)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if OtherRoleModel.petId==0 then
		objSwf.btnLovelyPet._visible = false;
		return
	end
	for i=1,4 do
		objSwf.btnLovelyPet["iconLoader"..i].source = ResUtil:GetLovelyPetIcon("pet"..OtherRoleModel.petId.."_title"..i);
	end
	
end

function UIOtherRoleBasic:RegisterAttrTips( objSwf )
	--注册属性值鼠标悬浮划离事件
	objSwf.btnHp.rollOver        = function(e) self:OnAttrLblRollOver(e) end
	objSwf.btnAtk.rollOver       = function(e) self:OnAttrLblRollOver(e) end
	objSwf.btnDef.rollOver       = function(e) self:OnAttrLblRollOver(e) end
	objSwf.btnHit.rollOver       = function(e) self:OnAttrLblRollOver(e) end
	objSwf.btnDodge.rollOver     = function(e) self:OnAttrLblRollOver(e) end
	objSwf.btnCrit.rollOver      = function(e) self:OnAttrLblRollOver(e) end
	objSwf.btnTenacity.rollOver  = function(e) self:OnAttrLblRollOver(e) end
	objSwf.btnMoveSpeed.rollOver = function(e) self:OnAttrLblRollOver(e) end
	objSwf.btnLovelyPet.rollOver = function(e) self:OnLovelyPetRollOver(e) end
	
	objSwf.btnHp.rollOut         = function() self:OnAttrLblRollOut() end
	objSwf.btnAtk.rollOut        = function() self:OnAttrLblRollOut() end
	objSwf.btnDef.rollOut        = function() self:OnAttrLblRollOut() end
	objSwf.btnHit.rollOut        = function() self:OnAttrLblRollOut() end
	objSwf.btnDodge.rollOut      = function() self:OnAttrLblRollOut() end
	objSwf.btnCrit.rollOut       = function() self:OnAttrLblRollOut() end
	objSwf.btnTenacity.rollOut   = function() self:OnAttrLblRollOut() end
	objSwf.btnMoveSpeed.rollOut  = function() self:OnAttrLblRollOut() end
	objSwf.btnLovelyPet.rollOut  = function() self:OnLovelyPetRollOut() end
end

function UIOtherRoleBasic:OnShow()
	self:UpdateShow();
	self:StartTimer();
	self:ShowLovelyPetHeadInfo();
end

function UIOtherRoleBasic:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
end

function UIOtherRoleBasic:OnDelete()
	self.objUIDraw:SetUILoader(nil);
end

function UIOtherRoleBasic:UpdateShow()
	self:Show3DRole();
	self:ShowRoleEquip();
	self:ShowRoleItem();
	self:ShowRoleName();
	self:ShowRoleProf();
	self:ShowRoleFight();
	self:ShowRoleAttr();
	-- self:ShowOtherFunc();
end

function UIOtherRoleBasic:Show3DRole()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local uiLoader = objSwf.roleLoader;
	local vo = {};
	local info = OtherRoleModel.otherhumanBSInfo;
	vo.prof = info.prof
	vo.arms = info.arms
	vo.dress = info.dress
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.fashionshead
	vo.fashionsArms = info.fashionsarms
	vo.fashionsDress = info.fashionsdress
	vo.wuhunId = info.wuhunId
	vo.wing = info.wing--OtherRoleUtil:GetWingId();
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);
	--
	local prof = info.prof; --取玩家职业
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("otherrolePanelPlayer", self.objAvatar, uiLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
	--播放特效
	local sex = info.sex;
	local pfxName = "ui_role_sex" ..sex.. ".pfx";
	local name,pfx = self.objUIDraw:PlayPfx(pfxName);
	-- 微调参数
	pfx.transform:setRotationX(UIDrawRoleCfg[prof].pfxRotationX);

	SoundManager:PlaySfx(8018 + vo.prof)
	TimerManager:RegisterTimer(function()
		if self.objAvatar then
			self.objAvatar:PlayLeisureAction();
		end
	end,1000,1);
end
local timerKey;
function UIOtherRoleBasic:StartTimer()
	if timerKey then 
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
	end
	timerKey = TimerManager:RegisterTimer( function()
		self:OnTimer();
	end, 20000, 0); -- 20s 播放一次动作
end

function UIOtherRoleBasic:OnTimer()	
	if not self.objAvatar then return end;
	self.objAvatar:PlayLeisureAction();
end

function UIOtherRoleBasic:ShowRoleEquip()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local datalist = {};
	for i,pos in ipairs(EquipConsts.EquipStrenType) do
		table.push(datalist,OtherRoleUtil:GetEquipUIVO(pos):GetUIData());
	end
	local uiList = objSwf.list;
    uiList.dataProvider:cleanUp();
	uiList.dataProvider:push( unpack(datalist) );
	uiList:invalidateData();
end

function UIOtherRoleBasic:ShowRoleItem()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.itemlist = OtherRoleUtil:GetBodyToolList();
	objSwf.itemlist.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.itemlist) do
		objSwf.itemlist.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.itemlist:invalidateData();
end

function UIOtherRoleBasic:ShowRoleName()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playerInfo = OtherRoleModel.otherhumanBSInfo;
	objSwf.txtName.text = playerInfo.eaName;
	objSwf.txtGuild.text = playerInfo.eaGuildName;
	objSwf.vipIndicator._visible = playerInfo.eaVIPLevel > 0;
end

function UIOtherRoleBasic:ShowRoleProf()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playerInfo = OtherRoleModel.otherhumanBSInfo;
	objSwf.lvlLoader.num = playerInfo.eaLevel;
	local profUrl = ResUtil:GetProfImg( playerInfo.prof );
	if objSwf.profLoader.source ~= profUrl then
		objSwf.profLoader.source = profUrl;
	end
end

function UIOtherRoleBasic:ShowRoleFight()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playerInfo = OtherRoleModel.otherhumanBSInfo;
	local fight = playerInfo.eaFight;
	if fight < 0 then
		fight = 0;
	end
	objSwf.fightLoader.num = playerInfo.eaFight;
end

local s_proStr = "<font color = '#a97a42'>%s   </font><font color = '#c8c8c8'>%s</font>"
function UIOtherRoleBasic:ShowRoleAttr()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playerInfo = OtherRoleModel.otherhumanBSInfo;
	objSwf.txt_pro1.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["att"], playerInfo.eaGongJi) --playerInfo.eaMaxHp;
	objSwf.txt_pro2.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["def"], playerInfo.eaFangYu)--playerInfo.eaGongJi;
	objSwf.txt_pro3.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["hp"], playerInfo.eaMaxHp)--playerInfo.eaFangYu;
	objSwf.txt_pro4.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["hit"], playerInfo.eaMingZhong)--playerInfo.eaMingZhong;
	objSwf.txt_pro5.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["dodge"], playerInfo.eaShanBi)--playerInfo.eaShanBi;
	objSwf.txt_pro6.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["cri"], playerInfo.eaBaoJi)--playerInfo.eaBaoJi;
	objSwf.txt_pro7.htmlText  	 	= string.format(s_proStr, PublicAttrConfig.roleProName["defcri"], playerInfo.eaRenXing)--playerInfo.eaRenXing;
end

--显示其他功能按钮
function UIOtherRoleBasic:ShowOtherFunc()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.otherfun.btnmount.disabled = true;
	objSwf.otherfun.btnspirite.disabled = true;
	
	--坐骑
	if OtherRoleModel.otherhumanBSInfo.mountState == 1 then
		objSwf.otherfun.btnmount.disabled = false;
	end
	
	--武魂
	if OtherRoleModel.otherhumanBSInfo.wuhunState == 1 then
		objSwf.otherfun.btnspirite.disabled = false;
	end
end

function UIOtherRoleBasic:OnBtnMountClick()
	local typemount = bit.band(255, OtherRoleConsts.OtherRole_Mount);
	RoleController:ViewRoleInfo(OtherRoleModel.otherhumanBSInfo.dwRoleID, typemount)
end

function UIOtherRoleBasic:OnBtnSpiriteClick()
	local typespirite = bit.band(255, OtherRoleConsts.OtherRole_Spirits);
	RoleController:ViewRoleInfo(OtherRoleModel.otherhumanBSInfo.dwRoleID, typespirite)
end

------------------------------------- 鼠标事件处理 ----------------------------------------

function UIOtherRoleBasic:OnBtnTurnLeftStateChange(state)
	self.roleTurnDir = state == "down" and 1 or 0;
end

function UIOtherRoleBasic:OnBtnTurnRightStateChange(state)
	self.roleTurnDir = state == "down" and -1 or 0;
end

function UIOtherRoleBasic:OnAttrLblRollOver(e)
	local attrType = e.target and e.target.data;
	if not attrType then return end;
	local tipsTxt = "";
	if attrType == enAttrType.eaMaxHp then
		tipsTxt = StrConfig["role101"];
	elseif attrType == enAttrType.eaGongJi then
		tipsTxt = StrConfig["role103"];
	elseif attrType == enAttrType.eaFangYu then
		tipsTxt = StrConfig["role104"];
	elseif attrType == enAttrType.eaMingZhong then
		tipsTxt = StrConfig["role105"];
	elseif attrType == enAttrType.eaShanBi then
		tipsTxt = StrConfig["role106"];
	elseif attrType == enAttrType.eaBaoJi then
		tipsTxt = StrConfig["role107"];
	elseif attrType == enAttrType.eaRenXing then
		tipsTxt = StrConfig["role108"];
	elseif attrType == enAttrType.eaMoveSpeed then
		tipsTxt = StrConfig["role121"];
	elseif attrType == enAttrType.eaLeftPoint then
		tipsTxt = StrConfig["role126"];
	end
	TipsManager:ShowTips( TipsConsts.Type_Normal, tipsTxt, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

function UIOtherRoleBasic:OnAttrLblRollOut()
	TipsManager:Hide();
end

function UIOtherRoleBasic:OnLovelyPetRollOver()
	TipsManager:ShowBtnTips("宠物");
end

function UIOtherRoleBasic:OnLovelyPetRollOut()
	TipsManager:Hide();
end
-- @param dir:1 or -1;
function UIOtherRoleBasic:Rotate3DRole(dir)
	local avatar = self.objAvatar;
	if not avatar then return end
	self.meshDir = self.meshDir + dir * math.pi / 40;
	avatar.objMesh.transform:setRotation( 0, 0, 1, self.meshDir );
end

function UIOtherRoleBasic:Update(interval)
	if not self.bShowState then return end;
	if self.roleTurnDir == 0 then
		return;
	end
	self:Rotate3DRole(self.roleTurnDir);
end

------------------------------- 装备处理 -------------------------------

function UIOtherRoleBasic:OnItemRollOver(e)
	local data = e.item;
	
	if not data.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetEquipName(data.pos));
		return;
	end
	
	local itemTipsVO = nil;
	itemTipsVO = OtherRoleUtil:GetEquipTipVO(data.tid, data.pos);
	if not itemTipsVO then return; end
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end
function UIOtherRoleBasic:OnWingItemRollOver(e)
	local data = e.item;
	
	if not data.hasItem then
		TipsManager:ShowBtnTips("翅膀");
		return;
	end
	
	local itemTipsVO = nil;
	itemTipsVO = OtherRoleUtil:GetWingTipVO(data.tid,data.showBind);
	
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end
function UIOtherRoleBasic:OnItemRollOut(item)
	TipsManager:Hide();
end
---------------------------以上是装备处理--------------------------------------
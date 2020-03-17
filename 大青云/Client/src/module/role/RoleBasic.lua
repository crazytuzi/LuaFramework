--[[
角色：基础信息界面
2015年5月5日18:24:59
haohu
]]

_G.UIRoleBasic = BaseSlotPanel:new("UIRoleBasic");

UIRoleBasic.ADD_POINT = "addPoint"

UIRoleBasic.objUIDraw = nil;--3d渲染器
UIRoleBasic.objAvatar = nil;--人物模型
UIRoleBasic.petAvatar = nil;--宠物模型
UIRoleBasic.SlotTotalNum = 11;--UI上格子总数
UIRoleBasic.ItemSlotTotalNum = 1;--道具背包总格子数
UIRoleBasic.list = {};--当前格子
UIRoleBasic.itemlist = {};
UIRoleBasic.meshDir = 0; --模型的当前方向
UIRoleBasic.roleTurnDir = 0; --模型的当前旋转方向
--当前的强化连锁id
UIRoleBasic.strenLinkId = -1;
--卓越连锁按钮
UIRoleBasic.superLinkBtn = nil;
--当前的卓越连锁id
UIRoleBasic.superLinkId = -1;
-- 宝石连锁按钮
UIRoleBasic.gemLinkBtn = nil;
-- 当前宝石连锁id
UIRoleBasic.gemLinkId = -1;
-- 炼化连锁按钮
UIRoleBasic.refinLinkBtn = nil;
-- 当前炼化连锁id
UIRoleBasic.refinLinkId = -1;
-- 先练连锁id
UIRoleBasic.washLinkId = -1

local s_linkBtn = {}

function UIRoleBasic:Create()
	self:AddSWF('roleBasicPanelV.swf', true, "top");
	self:AddChild( UIRolePointAdd, UIRoleBasic.ADD_POINT );
end

function UIRoleBasic:OnLoaded( objSwf )
	self:Init( objSwf );
	self:RegisterEvents( objSwf );
end

function UIRoleBasic:Init( objSwf )
	objSwf.roleLoader.hitTestDisable = true;
	self:GetChild( UIRoleBasic.ADD_POINT ):SetContainer( objSwf.childPanel );
	--初始化格子
	for i = 1, self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new( objSwf["item"..i] ), i );
	end
	for i = 1, self.ItemSlotTotalNum do
	self:AddSlotItem(BaseItemSlot:new( objSwf["roleItem"..i]), self.SlotTotalNum+i);
	end
	for i = 1, 3 do
		self:AddSlotItem(BaseItemSlot:new(objSwf["relicItem" ..i]), self.ItemSlotTotalNum + self.SlotTotalNum + i)
	end
	--初始化属性label
	-- objSwf.btnHp.data        = enAttrType.eaMaxHp;
	-- objSwf.btnAtk.data       = enAttrType.eaGongJi;
	-- objSwf.btnDef.data       = enAttrType.eaFangYu;

	-- objSwf.btnHit.data       = enAttrType.eaMingZhong;
	-- objSwf.btnDodge.data     = enAttrType.eaShanBi;
	-- objSwf.btnCrit.data      = enAttrType.eaBaoJi;
	-- objSwf.btnTenacity.data  = enAttrType.eaRenXing;

	-- objSwf.btnMoveSpeed.data = enAttrType.eaMoveSpeed;
	-- objSwf.btnAttrPoint.data = enAttrType.eaLeftPoint;
end

function UIRoleBasic:RegisterEvents( objSwf )
	-- objSwf.siExp.rollOver            = function(e) self:OnSiExpRollOver(e); end
	-- objSwf.siExp.rollOut             = function() self:OnSiExpRollOut(); end
	-- objSwf.btnLvlUp.click            = function() self:OnBtnLvlUpClick(); end
	-- objSwf.btnLvlUp.rollOver         = function() self:OnBtnLvlUpRollOver();end
	-- objSwf.btnLvlUp.rollOut          = function() self:OnBtnLvlUpRollOut(); end;
	objSwf.btnTurn1.stateChange      = function(e) self:OnBtnTurnLeftStateChange(e.state); end
	objSwf.btnTurn2.stateChange      = function(e) self:OnBtnTurnRightStateChange(e.state); end
	objSwf.btnFashion.click          = function() self:OnBtnFashionClick(); end;
	objSwf.btnFashion.rollOver       = function() self:OnBtnFashionRollOver();end
	objSwf.btnFashion.rollOut        = function() self:OnBtnFashionRollOut(); end;
	objSwf.ButtonDescribe.rollOver   = function() self:ShowEquipDescribeLink() end
	objSwf.ButtonDescribe.rollOut    = function() TipsManager:Hide() end
	objSwf.ButtonDescribe.click = function() FuncManager:OpenFunc(FuncConsts.equipCollect) end
	-- objSwf.btnbinghun.click          = function() self:OnBtnBingHunClick(); end;
	objSwf.btnAttrAdd.click          = function() self:OnBtnAttrAddClick(); end;
	-- objSwf.btnHuiZhang.click         = function() self:OnBtnHuiZhangClick(); end;
	-- objSwf.btnHuiZhang.rollOver      = function() self:OnBtnHuiZhangRollOver();end
	-- objSwf.btnHuiZhang.rollOut       = function() self:OnBtnHuiZhangRollOut(); end;
	-- objSwf.btnAttrPill.click         = function() UIRole:TurnToSubpanel( UIRole.BOGEY_PILL ) end
	-- objSwf.btnAttrPill.rollOver      = function() self:OnBtnAttrPillRollOver(); end
	-- objSwf.btnAttrPill.rollOut       = function() TipsManager:Hide(); end
	-- objSwf.btnGuildAddition.rollOver = function() if not UnionModel:GetMyUnionId() then TipsManager:ShowBtnTips(StrConfig['union179'],TipsConsts.Dir_RightDown); return end UIUnionAidTips:Show(); end
	-- objSwf.btnGuildAddition.rollOut  = function() if not UnionModel:GetMyUnionId() then TipsManager:Hide(); return end UIUnionAidTips:Hide(); end
	-- objSwf.btnGuildAddition.click    = function() if not UnionModel:GetMyUnionId() then FloatManager:AddNormal( StrConfig["union178"] ); return end 
												-- UIUnionAidPanel:Show(); 
			--								end
	-- objSwf.btnBossHuizhang.rollOver = function() self:OnBtnBossHuizhangRollOver() end
	-- objSwf.btnBossHuizhang.rollOut  = function() self:OnBtnBossHuizhangRollOut() end
	-- objSwf.btnBossHuizhang.click    = function() self:OnBtnBossHuizhangClick() end
	--objSwf.btnAttrPoint.click = function(e) self:OnAttrLblRollOver(e) end
	--self:RegisterAttrTips( objSwf );
	
	-- objSwf.btnChongwu.rollOver = function() self:OnBtnLovelyPetOver(); end
	-- objSwf.btnChongwu.rollOut  = function() self:OnBtnLovelyPetOut(); end
	objSwf.btnWing.doubleClickEnabled = true;
	objSwf.btnWing.doubleClick = function() self:OnDoubleClick(); end;
	objSwf.btnWing.click = function() self:OnBtnWingSlot(); end
	-- objSwf.roleItem1.click = function() self:OnBtnWingSlot(); end
	self:ShowLovelyPetHeadInfo();
end

function UIRoleBasic:OnDoubleClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	TipsManager:Hide();
	-- local data = item:GetData();
	-- if not data.hasItem  then
		-- return;
	-- end
	-- print('--------------------------- not objSwf.roleItem1')
	if objSwf.roleItem1 then
		-- print('--------------------------- objSwf.roleItem1')
		objSwf.btnWing.click =nil;
		BagController:UnEquipItem(4, 0);
		return
	end
end

function UIRoleBasic:OnBtnWingSlot()
	local objSwf = self.objSwf;
	if not objSwf then return end
	-- local itemData = objSwf.roleItem1:GetData();
	-- if not itemData.opened then
		-- return;
	-- end
	UIChibangPickView:Open(4, 0);
end

function UIRoleBasic:OnBtnLovelyPetClick()
	-- local lovelypetvo = t_lovelypet[1];
	-- local playerinfo = MainPlayerModel.humanDetailInfo;
	-- if playerinfo.eaLevel < LovelyPetUtil:GetNiuNiuLevel() then
		-- return;
	-- end
	FuncManager:OpenFunc( FuncConsts.LovelyPet, true );
end

--显示信息
function UIRoleBasic:ShowLovelyPetHeadInfo()

	local objSwf = self.objSwf
	if not objSwf then return end
	
	
	-- local id, state = LovelyPetUtil:GetCurLovelyPetState();
	-- local lovelypetvo = t_lovelypet[id];
	-- if state==2 then
	-- 	objSwf.btnChongwu._visible = false;
	-- 	objSwf.btnLovelyPet._visible = true;
	-- 	objSwf.zhan._visible = true;
	-- 	for i=1,4 do
	-- 		objSwf.btnLovelyPet["iconLoader"..i].source = ResUtil:GetLovelyPetIcon("pet"..id.."_title"..i);
	-- 	end
	-- 	objSwf.btnLovelyPet.click    = function() self:OnBtnLovelyPetClick(); end
	-- else
		objSwf.btnChongwu._visible = true;
		objSwf.zhan._visible = false;
		objSwf.btnChongwu.click    = function() self:OnBtnLovelyPetClick(); end
		objSwf.btnLovelyPet._visible = false;
	-- end
end

function UIRoleBasic:RegisterAttrTips( objSwf )
	--注册属性值鼠标悬浮划离事件
	-- objSwf.btnHp.rollOver        = function(e) self:OnAttrLblRollOver(e) end
	-- objSwf.btnAtk.rollOver       = function(e) self:OnAttrLblRollOver(e) end
	-- objSwf.btnDef.rollOver       = function(e) self:OnAttrLblRollOver(e) end
	-- objSwf.btnHit.rollOver       = function(e) self:OnAttrLblRollOver(e) end
	-- objSwf.btnDodge.rollOver     = function(e) self:OnAttrLblRollOver(e) end
	-- objSwf.btnCrit.rollOver      = function(e) self:OnAttrLblRollOver(e) end
	-- objSwf.btnTenacity.rollOver  = function(e) self:OnAttrLblRollOver(e) end
	-- objSwf.btnMoveSpeed.rollOver = function(e) self:OnAttrLblRollOver(e) end
	-- objSwf.btnAttrPoint.rollOver = function(e) self:OnAttrLblRollOver(e) end
	
	-- objSwf.btnHp.rollOut         = function() self:OnAttrLblRollOut() end
	-- objSwf.btnAtk.rollOut        = function() self:OnAttrLblRollOut() end
	-- objSwf.btnDef.rollOut        = function() self:OnAttrLblRollOut() end
	-- objSwf.btnHit.rollOut        = function() self:OnAttrLblRollOut() end
	-- objSwf.btnDodge.rollOut      = function() self:OnAttrLblRollOut() end
	-- objSwf.btnCrit.rollOut       = function() self:OnAttrLblRollOut() end
	-- objSwf.btnTenacity.rollOut   = function() self:OnAttrLblRollOut() end
	-- objSwf.btnMoveSpeed.rollOut  = function() self:OnAttrLblRollOut() end
	-- objSwf.btnAttrPoint.rollOut  = function() self:OnAttrLblRollOut() end
end

function UIRoleBasic:OnShow()
	
	self:DrawScene();
	
	-- self:Show3DRole();
	self:ShowRoleEquip();
	self:ShowRoleItem();
	self:ShowRelicItem()
	-- self:ShowRoleName();
	-- self:ShowRoleProf();
	 self:ShowRoleFight();
	 self:ShowRoleAttr();
	-- self:ShowRoleExp();
	-- self:ShowFashionBtn();
	-- self:ShowBingHunBtn();
	-- self:ShowLingLiHuiZhang()
	self:ShowStrenLink(true);
	self:ShowWashLink(true);
	self:ShowGemLink(true);
	self:ShowGuildLink(true)

	--这里每次要重置一次按钮位置
	self:ResetLinkBtn()
	-- self:ShowRefinLink()
	-- self:ShowAddPointEffect();
	--self:ShowStove();
	self:StartTimer();
	self:InitRedPoint();
	self:RegisterTimes();
	self.objSwf.txt_qianneng.htmlText = UIStrConfig['rolev8']
end


--adder:houxudong
--date:2016/8/1
--加点红点提示 
UIRoleBasic.AddTimeKey = nil;
UIRoleBasic.addLoader = nil;
function UIRoleBasic:InitRedPoint()
	local objSwf = self.objSwf
	if not objSwf then return; end
	if RoleUtil:CheckIsHavePoint( ) then
		PublicUtil:SetRedPoint(objSwf.btnAttrAdd,nil,1)
	else
		PublicUtil:SetRedPoint(objSwf.btnAttrAdd)
	end
end

--- 新加的玩家穿戴神铸装备连锁
function UIRoleBasic:ShowEquipDescribeLink()
	local objSwf = self.objSwf
	if not objSwf then return end
	local str = ""
	local lv = self:GetRoleEquipMinLv()
	if lv == 0 then
		--一个都未激活
		str = self:GetDescribeLinkStr(1)
	elseif t_equipdescribe[lv + 1] then
		--激活中途
		str = self:GetDescribeLinkStr(lv, true)
		str = str .. "\n"
		str = str .. "<p><img height='".. 0 .."'/></p><p><img width='".. 320 .."' height='1' align='baseline' vspace='".. 10 .."' src='" .. ResUtil:GetTipsLineUrl() .."'/></br></p>"
		str = str .. self:GetDescribeLinkStr(lv + 1)
	else
		--全部激活
		str = self:GetDescribeLinkStr(lv, true)
	end
	TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown)
end

function UIRoleBasic:GetRoleEquipMinLv()
	local lv = 10
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role)
	for i = 0, 10 do
		local equip = bagVO:GetItemByPos(i)
		if not equip then
			return 0
		else
			local cfg = equip:GetCfg()
			if cfg.quality >= 5 and cfg.quality <= 7 then
				if cfg.level < lv then
					lv = equip:GetCfg().level
				end
			else
				return 0
			end
		end
	end
	return lv
end

function UIRoleBasic:IsEquipDescribeLink(i, lv)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role)
	local equip = bagVO:GetItemByPos(i)
	if not equip then
		return false
	end
	local cfg = equip:GetCfg()
	if cfg.quality < 5 or cfg.quality > 7 then
		return false
	end
	return cfg.level >= lv
end

local s_str = "<font size='%s' color='%s'>%s</font>"
function UIRoleBasic:GetDescribeLinkStr(lv, bActive)
	local str = ""
	local cfg = t_equipdescribe[lv]
	str = str .. "<textformat leading='20' leftmargin='6'>"
	str = str .. "              " .. string.format(s_str, 18, "#ff6c00", cfg.name) .. "\n"
	str = str .. "</textformat>"
	local acStr
	if bActive then
		acStr = string.format(s_str, 14, "#00ff00", "已激活")
	else
		acStr = string.format(s_str, 14, "#ff0000", "未激活")
	end
	str = str .. "<textformat leading='20' leftmargin='6'>"; 
	str = str .. " " .. string.format(s_str, 14, "#feaf05", cfg.describe .. "--") .. acStr .. "\n"
	str = str .. "</textformat>";
	str = str .. "  "
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role)
	for i = 0, 5 do
		local equip = bagVO:GetItemByPos(i)
		str = str .. "<textformat leading='20' leftmargin='6'>"; 
		if bActive or equip and UIRoleBasic:IsEquipDescribeLink(i, lv) then
			str = str .. string.format(s_str, 14, "#feaf05", StrConfig['commonEquipName' .. (i + 1)]) .. "  "
		else
			str = str .. string.format(s_str, 14, "#8f8e8f", StrConfig['commonEquipName' .. (i + 1)]) .. "  "
		end
		str = str .. "</textformat>"
	end
	str = str .. "\n" .. "  "
	for i = 6, 10 do
		local equip = bagVO:GetItemByPos(i)
		str = str .. "<textformat leading='20' leftmargin='6'>"; 
		if bActive or equip and UIRoleBasic:IsEquipDescribeLink(i, lv) then
			str = str .. string.format(s_str, 14, "#feaf05", StrConfig['commonEquipName' .. (i + 1)]) .. "  "
		else
			str = str .. string.format(s_str, 14, "#8f8e8f", StrConfig['commonEquipName' .. (i + 1)]) .. "  "
		end
		str = str .. "</textformat>"
	end
	str = str .. "\n" .. "  "
	local list = AttrParseUtil:Parse(cfg.baseAttr)
	local count = 0
	local tab = "  "
	for k, v in pairs(list) do
		count = count + 1
		if count > 3 then
			str = str .. "\n" .. "  "
		end
		str = str .. "<textformat leading='20' leftmargin='6'>"; 
		if bActive then
			str = str .. string.format(s_str, 14, "#feaf05", PublicAttrConfig.proName[v.name] .. "：") .. string.format(s_str, 14, "#ffffff", "+".. v.val) .. tab
		else
			str = str .. string.format(s_str, 14, "#feaf05", PublicAttrConfig.proName[v.name] .. "：") .. string.format(s_str, 14, "#ffffff", "+".. v.val) .. tab
		end
		str = str .. "</textformat>"
	end
	return str
end

function UIRoleBasic:InitRelicPoint()
	local objSwf = self.objSwf
	if not objSwf then return end
	for i = 1, 3 do
		if EquipUtil:IsRelicCanLvUp(i) then
			PublicUtil:SetRedPoint(objSwf['relicItem' ..i],nil,1)
		else
			PublicUtil:SetRedPoint(objSwf['relicItem' ..i])
		end
	end
end

function UIRoleBasic:RegisterTimes()
	self.AddTimeKey = TimerManager:RegisterTimer(function()
		self:InitRedPoint()
		self:InitRelicPoint()
	end,1000,0); 
end

UIRoleBasic.scene = nil;
local s_UIPos = {{4, -178}, {1, -178}, {-22, -153}, {-301, -153}}
function UIRoleBasic:DrawScene()
	local swf = self.objSwf;
	--debug.debug();
	local prof = MainPlayerModel.humanDetailInfo.eaProf; 
	if prof == 4 then
		if not self.viewPort then self.viewPort = _Vector2.new(2000, 795); end  --795
	else
		if not self.viewPort then self.viewPort = _Vector2.new(1300, 815); end  --795
	end
	swf.roleLoader._x = s_UIPos[prof][1]
	swf.roleLoader._y = s_UIPos[prof][2]
	if not self.scene then
		self.scene = UISceneDraw:new('RoleBasic', swf.roleLoader, self.viewPort, false);
	end
	self.scene:SetUILoader(swf.roleLoader)
	
	local src = Assets:GetRolePanelSen(MainPlayerModel.humanDetailInfo.eaProf);
	self.scene:SetScene(src, function()
		self:DrawRole(true);
	end );
	self.scene:SetDraw( true );
end

UIRoleBasic.avatars = {};
function UIRoleBasic:DrawRole(bFirst)
	local swf = self.objSwf;
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	
	if self.petAvatar then
		self.petAvatar:ExitMap();
		self.petAvatar = nil;
	end
	
	
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
--trace(info)
	-- debug.debug()
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf;
	vo.arms = info.dwArms;
	vo.dress = info.dwDress;
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.dwFashionsHead;
	vo.fashionsArms = info.dwFashionsArms;
	vo.fashionsDress = info.dwFashionsDress;
	vo.wuhunId = SpiritsModel:GetFushenWuhunId();
	vo.wing = info.dwWing;
	vo.suitflag = info.suitflag;
	vo.shenwuId = info.shenwuId;
	
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar.bIsAttack = false;
	self.objAvatar:CreateByVO(vo);
	
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	--播放特效
	local sex = MainPlayerModel.humanDetailInfo.eaSex;
	-- local pfxName = "ui_role_sex" ..sex.. ".pfx";
	-- local name,pfx = self.scene:PlayPfx(pfxName);
	
	self:OnTimer();
	
	local markers = self.scene:GetMarkers();
	local indexc = "marker2";
	self.objAvatar:EnterUIScene(self.scene.objScene,markers[indexc].pos,markers[indexc].dir,markers[indexc].scale, enEntType.eEntType_Player);
	if bFirst then
		--播放音效
		SoundManager:PlaySfx(8018 + vo.prof)
	end
	-- self.petAvatar = LovelyPetAvatar:Create(20010003);
	-- indexc = "marker1";
	-- self.petAvatar:EnterUIScene(self.scene.objScene,markers[indexc].pos,markers[indexc].dir,markers[indexc].scale, enEntType.eEntType_Player);
	-- self.petAvatar.objMesh.transform:setRotation(0,0,1,math.pi);
	
end

function UIRoleBasic:ShowAddPointEffect()
	local objSwf = self.objSwf
	local hasLeftPoint = MainPlayerModel.humanDetailInfo.eaLeftPoint > 0
	--objSwf.atbAddF._visible = hasLeftPoint and not UIRolePointAdd:IsShow()
end

function UIRoleBasic:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if self.scene then 
		self.scene:SetDraw(false)
	end
	
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objPetUIDraw then
		self.objPetUIDraw:SetDraw(false);
		self.objPetUIDraw:SetMesh(nil);
	end
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	if self.petAvatar then
		self.petAvatar:ExitMap();
		self.petAvatar = nil;
	end
	self.roleTurnDir = 0;
	-- self:OnDelete()
	if self.addLoader then 
		self:RemoveRedPoint(self.addLoader)
		self.addLoader = nil
	end
	if self.AddTimeKey then
		TimerManager:UnRegisterTimer(self.AddTimeKey);
		self.AddTimeKey = nil;
	end

	for k, v in pairs(s_linkBtn) do
		v:removeMovieClip();
		v = nil;
	end
	s_linkBtn = {};
end

function UIRoleBasic:OnDelete()
	self:RemoveAllSlotItem();
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	s_linkBtn = {}
	self.strenLinkId  = -1;
	self.superLinkId  = -1;
	self.washLinkId = -1
	self.gemLinkId    = -1;
	self.refinLinkBtn   = nil;
	self.refinLinkId    = -1;
end

function UIRoleBasic:Show3DRole()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local uiLoader = objSwf.roleLoader;
	
	--local uiPetLoader = objSwf.petLoader;
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = info.dwArms
	vo.dress = info.dwDress
	vo.fashionsHead = info.dwFashionsHead
	vo.fashionsArms = info.dwFashionsArms
	vo.fashionsDress = info.dwFashionsDress
	vo.wuhunId = SpiritsModel:GetFushenWuhunId()
	vo.wing = info.dwWing
	vo.suitflag = info.suitflag
	vo.shenwuId = info.shenwuId
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar.bIsAttack = true;
	--self.objAvatar:SetAttackAction(true);
	self.objAvatar:CreateByVO(vo);
	--
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("rolePanelPlayer", self.objAvatar, uiLoader,
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
	local sex = MainPlayerModel.humanDetailInfo.eaSex;
	local pfxName = "ui_role_sex" ..sex.. ".pfx";
	local name,pfx = self.objUIDraw:PlayPfx(pfxName);
	-- 微调参数
	-- pfx.transform:setRotationX(UIDrawRoleCfg[prof].pfxRotationX);
	-- TimerManager:RegisterTimer(function()
		-- if self.objAvatar then
			-- self.objAvatar:PlayLeisureAction();
		-- end
	-- end,1000,1);
	
	--萌宠
	--print('------------------11111111111-----------------')
	self.petAvatar = LovelyPetAvatar:Create(20010003)
	--self.objAvatar:InitAvatar();
	--print('------------------22222222222-----------------')
	if not self.objPetUIDraw then
		self.objPetUIDraw = UIDraw:new("RoleBasic111qqqqqqq1",self.petAvatar,objSwf.petLoader,_Vector2.new(200,700),_Vector3.new(0,40,25),_Vector3.new(1,0,20),0x00000000);
	else
		self.objPetUIDraw:SetUILoader(objSwf.petLoader);
		self.objPetUIDraw:SetMesh(self.petAvatar);
	end
	self.petAvatar.objMesh.transform:setRotation(0,0,1,math.pi);
	self.objPetUIDraw:SetDraw(true);
end

local timerKey;
function UIRoleBasic:StartTimer()
	if timerKey then 
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
	end
	timerKey = TimerManager:RegisterTimer( function()
		self:OnTimer();
	end, 20000, 0); -- 20s 播放一次动作
end

function UIRoleBasic:OnTimer()	
	if not self.objAvatar then return end;
	self.objAvatar:PlayLeisureAction();
end

function UIRoleBasic:ShowRoleEquip()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.list = BagUtil:GetBagItemList( BagConsts.BagType_Role, BagConsts.ShowType_All );
    objSwf.list.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.list) do
		objSwf.list.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.list:invalidateData();
end

function UIRoleBasic:ShowRoleItem()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.itemlist = BagUtil:GetBagItemList(BagConsts.BagType_RoleItem,BagConsts.ShowType_All);
	objSwf.itemlist.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.itemlist) do
		objSwf.itemlist.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.itemlist:invalidateData();
end


function UIRoleBasic:ShowRelicItem()
	local objSwf = self.objSwf
	if not objSwf then return end
	self.relicList = BagUtil:GetBagItemList(BagConsts.BagType_RELIC,BagConsts.ShowType_All)
	objSwf.relicList.dataProvider:cleanUp()
	for i, v in ipairs(self.relicList) do
		objSwf.relicList.dataProvider:push(v:GetUIData())
	end
	objSwf.relicList:invalidateData()
end

--显示时装衣柜
function UIRoleBasic:ShowFashionBtn()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btnFashion._visible = FuncManager:GetFuncIsOpen( FuncConsts.Fashions );
end

--显示圣器
function UIRoleBasic:ShowBingHunBtn()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btnbinghun._visible = FuncManager:GetFuncIsOpen( FuncConsts.BingHun );
	if BingHunModel:GetBingHunSelect() == 0 then
		objSwf.btnbinghun.iconLoader:unload();
		objSwf.btnbinghun.imgzbw._visible = true;
	else
		objSwf.btnbinghun.imgzbw._visible = false;
		local binghuncfg = t_binghun[BingHunModel:GetBingHunSelect()];
		if binghuncfg then
			local iconres = ResUtil:GetBingHunIconName(BingHunUtil:GetBingHunHeadIcon(binghuncfg.item_icon,MainPlayerModel.humanDetailInfo.eaProf));
			objSwf.btnbinghun.iconLoader.source = iconres;
		end
	end
end

--显示灵力徽章
function UIRoleBasic:ShowLingLiHuiZhang()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btnHuiZhang._visible = FuncManager:GetFuncIsOpen( FuncConsts.HuiZhang );
end

function UIRoleBasic:ShowRoleName()
	local objSwf = self.objSwf
	if not objSwf then return end
	local playerInfo = MainPlayerModel.humanDetailInfo
	local vipType = VipController:GetVipType()
	local vipIconUrl = VipController:GetVipIcon( vipType, playerInfo.eaVIPLevel )
	objSwf.txtName.htmlText = string.format( "<img src='%s'/>%s", vipIconUrl, RoleUtil:TailorName( playerInfo.eaName ) )

	if UnionModel:GetMyUnionId() ~= nil then
		objSwf.txtGuild.text = UnionModel.MyUnionInfo.guildName
	else
		objSwf.txtGuild.text = ""
	end
end

function UIRoleBasic:ShowRoleProf()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playerInfo = MainPlayerModel.humanDetailInfo;
	objSwf.lvlLoader.num = playerInfo.eaLevel;
	local profUrl = ResUtil:GetProfImg( playerInfo.eaProf );
	if objSwf.profLoader.source ~= profUrl then
		objSwf.profLoader.source = profUrl;
	end
end

function UIRoleBasic:ShowRoleFight()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local fight = playerInfo.eaFight
	if fight < 0 then
		fight = 0;
	end
	objSwf.fightLoader.num = fight;
end

function UIRoleBasic:ShowRoleAttr()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local s_proStr = "<font color = '"..PublicStyle.COLOR_ATTR_NAME.."'>%s   </font><font color = '"..PublicStyle.COLOR_ATTR_Val.."'>%s</font>"
	objSwf.txt_pro1.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["att"], playerInfo.eaGongJi) --playerInfo.eaMaxHp;
	objSwf.txt_pro2.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["def"], playerInfo.eaFangYu)--playerInfo.eaGongJi;
	objSwf.txt_pro3.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["hp"], playerInfo.eaMaxHp)--playerInfo.eaFangYu;
	objSwf.txt_pro4.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["hit"], playerInfo.eaMingZhong)--playerInfo.eaMingZhong;
	objSwf.txt_pro5.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["dodge"], playerInfo.eaShanBi)--playerInfo.eaShanBi;
	objSwf.txt_pro6.htmlText        = string.format(s_proStr, PublicAttrConfig.roleProName["cri"], playerInfo.eaBaoJi)--playerInfo.eaBaoJi;
	objSwf.txt_pro7.htmlText  	 	= string.format(s_proStr, PublicAttrConfig.roleProName["defcri"], playerInfo.eaRenXing)--playerInfo.eaRenXing;

	objSwf.txtAttrPoint.text = playerInfo.eaLeftPoint;
end

function UIRoleBasic:ShowRoleExp()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local exp = playerInfo.eaExp;
	local maxExp = self:GetExpCeiling( playerInfo.eaLevel ) or exp;
	objSwf.siExp.maximum = maxExp;
	objSwf.siExp.value = exp;
end

function UIRoleBasic:GetExpCeiling(level)
	local lvlUpCfg = t_lvup[level];
	return lvlUpCfg and lvlUpCfg.exp;
end

function UIRoleBasic:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.PlayerModelChange,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.BagRefresh,
		NotifyConsts.WuhunFushenChanged,
		NotifyConsts.VipPeriod,
		NotifyConsts.BingHunUpdate,
		NotifyConsts.LovelyPetStateUpdata
	}
end

function UIRoleBasic:HandleNotification( name, body )
	if name == NotifyConsts.PlayerAttrChange then
		-- if body.type == enAttrType.eaName then
		-- 	self:ShowRoleName();
		-- elseif body.type == enAttrType.eaLevel or body.type == enAttrType.eaProf then
		-- 	self:ShowRoleProf();
		-- elseif body.type == enAttrType.eaExp then
		-- 	self:ShowRoleExp()
		self:ShowLovelyPetHeadInfo();
		if body.type == enAttrType.eaFight then
			self:ShowRoleFight();
		elseif body.type == enAttrType.eaMaxHp or body.type == enAttrType.eaGongJi or
				body.type == enAttrType.eaFangYu or body.type == enAttrType.eaMingZhong or
				body.type == enAttrType.eaShanBi or body.type == enAttrType.eaBaoJi or
				body.type == enAttrType.eaRenXing or body.type == enAttrType.eaMoveSpeed or
				body.type == enAttrType.eaLeftPoint then
			self:ShowRoleAttr();
		-- elseif body.type == enAttrType.eaVIPLevel then
		-- 	self:ShowRoleName()
		end
		if body.type == enAttrType.eaLeftPoint then
			self:ShowAddPointEffect()
		end
	elseif name == NotifyConsts.PlayerModelChange then
		self:DrawRole()
	elseif name == NotifyConsts.WuhunFushenChanged then
		-- self:Show3DRole();
	elseif name == NotifyConsts.BagAdd then
		if body.type==BagConsts.BagType_Role or body.type==BagConsts.BagType_RoleItem or body.type == BagConsts.BagType_RELIC then
			self:DoAddItem(body.type,body.pos);
		end
		if body.type == BagConsts.BagType_Role then
			self:ShowStrenLink();
		end
	elseif name == NotifyConsts.BagRemove then
		if body.type==BagConsts.BagType_Role or body.type==BagConsts.BagType_RoleItem or body.type == BagConsts.BagType_RELIC then
			self:DoRemoveItem(body.type,body.pos);
		end
		if body.type == BagConsts.BagType_Role then
			self:ShowStrenLink();
		end
	elseif name == NotifyConsts.BagUpdate then
		if body.type==BagConsts.BagType_Role or body.type==BagConsts.BagType_RoleItem or body.type == BagConsts.BagType_RELIC then
			self:DoUpdateItem(body.type,body.pos);
		end
		if body.type == BagConsts.BagType_Role then
			self:ShowStrenLink();
		end
	-- elseif name == NotifyConsts.VipPeriod then
	-- 	self:ShowRoleName()
	-- elseif name == NotifyConsts.BingHunUpdate then
	-- 	self:ShowBingHunBtn();
	elseif name == NotifyConsts.LovelyPetStateUpdata then
		self:ShowLovelyPetHeadInfo();
	end
end

------------------------------------- 鼠标事件处理 ----------------------------------------


function UIRoleBasic:OnSiExpRollOver(e)
	local info = MainPlayerModel.humanDetailInfo;
	TipsManager:ShowBtnTips( string.format( "%s/%s", info.eaExp, t_lvup[info.eaLevel].exp) );
end

function UIRoleBasic:OnSiExpRollOut()
	TipsManager:Hide();
end

function UIRoleBasic:OnBtnLvlUpRollOver()
	local manulLevelUp = PlayerConsts:GetManulLevel()
	TipsManager:ShowBtnTips( string.format( StrConfig["role122"], manulLevelUp, manulLevelUp ), TipsConsts.Dir_RightDown );
end

function UIRoleBasic:OnBtnLvlUpRollOut()
	TipsManager:Hide();
end

function UIRoleBasic:OnBtnLvlUpClick()
	RoleController:HandLvlUp();
end

function UIRoleBasic:OnBtnTurnLeftStateChange(state)
	self.roleTurnDir = state == "down" and 1 or 0;
end

function UIRoleBasic:OnBtnTurnRightStateChange(state)
	self.roleTurnDir = state == "down" and -1 or 0;
end

function UIRoleBasic:OnBtnFashionClick()
	FuncManager:OpenFunc( FuncConsts.Fashions, true );
end

function UIRoleBasic:OnBtnBingHunClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	UIBingHunShortCutSet:Open(objSwf.btnbinghun);
end

function UIRoleBasic:OnBtnFashionRollOver()
	UIFashionsTip:Show();
end

function UIRoleBasic:OnBtnFashionRollOut()
	UIFashionsTip:Hide();
end

function UIRoleBasic:OnBtnHuiZhangClick()
	FuncManager:OpenFunc( FuncConsts.Homestead, true);
end

function UIRoleBasic:OnBtnHuiZhangRollOver()
	UILingLiHuiZhangTip.showtype = 0;
	UILingLiHuiZhangTip:Show();
end

function UIRoleBasic:OnBtnHuiZhangRollOut()
	UILingLiHuiZhangTip:Hide();
end

function UIRoleBasic:OnBtnBossHuizhangRollOver()
	BossMedalController:ShowBossMedalTips(true)
end

function UIRoleBasic:OnBtnBossHuizhangRollOut()
	BossMedalController:ShowBossMedalTips(false)
end

function UIRoleBasic:OnBtnBossHuizhangClick()
	FuncManager:OpenFunc( FuncConsts.BossHuizhang, true )
end

function UIRoleBasic:OnBtnAttrPillRollOver()
	local attrlist = RoleBoegeyPillUtil:GetBogyePillAttr();
	local att = attrlist[1];
	if not att then
		att = 0;
	end
	
	local def = attrlist[2];
	if not def then
		def = 0;
	end
	
	local hp = attrlist[3];
	if not hp then
		hp = 0;
	end
	TipsManager:ShowBtnTips(string.format( StrConfig["role424"],att,def,hp),TipsConsts.Dir_RightDown);
end

function UIRoleBasic:OnBtnAttrAddClick()
	if self.parent then
		self.parent:Top()
	end
	self:ToggleAttrAddPanel()
end

function UIRoleBasic:ToggleAttrAddPanel()
	if UIRolePointAdd:IsShow() then
		UIRolePointAdd:Hide()
	else
		UIRolePointAdd:Show()
	end
	--self:ShowAddPointEffect()
end

function UIRoleBasic:OnAttrLblRollOver(e)
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

function UIRoleBasic:OnAttrLblRollOut()
	TipsManager:Hide();
end

-- @param dir:1 or -1;
function UIRoleBasic:Rotate3DRole(dir)
	local avatar = self.objAvatar;
	if not avatar then return end
	self.meshDir = self.meshDir + dir * math.pi / 40;
	avatar.objMesh.transform:setRotation( 0, 0, 1, self.meshDir );
end

function UIRoleBasic:Update(interval)
	if not self.bShowState then return end;
	if self.roleTurnDir == 0 then
		return;
	end
	self:Rotate3DRole(self.roleTurnDir);
end

------------------------------- 装备处理 -------------------------------


--获取指定位置的Item,飞图标用
function UIRoleBasic:GetItemAtPos(pos)
	if not self.isFullShow then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local uiSlot = objSwf.list:getRendererAt(pos);
	return uiSlot;
end

--添加Item
function UIRoleBasic:DoAddItem(bagType,pos)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = nil;
	local uilist = nil;
	if bagType == BagConsts.BagType_Role then
		list = self.list;
		uilist = objSwf.list;
	elseif bagType == BagConsts.BagType_RoleItem then
		list = self.itemlist;
		uilist = objSwf.itemlist;
	elseif bagType == BagConsts.BagType_RELIC then
		list = self.relicList
		uilist = objSwf.relicList
	end
	if not list then return; end
	if not uilist then return; end
	--
	local bagSlotVO = list[pos+1];
	bagSlotVO.hasItem = true;
	bagSlotVO.id = item:GetId();
	bagSlotVO.tid = item:GetTid();
	bagSlotVO.count = item:GetCount();
	if BagUtil:IsRelic(item:GetTid()) then
		bagSlotVO.relicLv = item:GetParam()
	end
	bagSlotVO.bindState = item:GetBindState();
	uilist.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = uilist:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--移除Item
function UIRoleBasic:DoRemoveItem(bagType,pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	local list = nil;
	local uilist = nil;
	if bagType == BagConsts.BagType_Role then
		list = self.list;
		uilist = objSwf.list;
	elseif bagType == BagConsts.BagType_RoleItem then
		list = self.itemlist;
		uilist = objSwf.itemlist;
	elseif bagType == BagConsts.BagType_RELIC then
		list = self.relicList;
		uilist = objSwf.relicList;
	end
	if not list then return; end
	if not uilist then return; end
	--
	local bagSlotVO = list[pos+1];
	bagSlotVO.hasItem = false;
	uilist.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = uilist:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--更新Item
function UIRoleBasic:DoUpdateItem(bagType,pos)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = nil;
	local uilist = nil;
	if bagType == BagConsts.BagType_Role then
		list = self.list;
		uilist = objSwf.list;
	elseif bagType == BagConsts.BagType_RoleItem then
		list = self.itemlist;
		uilist = objSwf.itemlist;
	elseif bagType == BagConsts.BagType_RELIC then
		list = self.relicList;
		uilist = objSwf.relicList;
	end
	if not list then return; end
	if not uilist then return; end
	--
	local bagSlotVO = list[pos+1];
	bagSlotVO.id = item:GetId();
	bagSlotVO.tid = item:GetTid();
	bagSlotVO.count = item:GetCount();
	bagSlotVO.bindState = item:GetBindState();
	if BagUtil:IsRelic(item:GetTid()) then
		bagSlotVO.relicLv = item:GetParam()
	end
	uilist.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = uilist:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

function UIRoleBasic:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		if data.bagType == BagConsts.BagType_Role then
			TipsManager:ShowBtnTips(BagConsts:GetEquipName(data.pos));
		elseif data.bagType == BagConsts.BagType_RoleItem then
			TipsManager:ShowBtnTips( StrConfig['role425'] );
		elseif data.bagType == BagConsts.BagType_RELIC then
			TipsManager:ShowBtnTips( StrConfig['role' ..(445 +data.pos)] );
		end
		return;
	end
	TipsManager:ShowBagTips(data.bagType,data.pos);
end

function UIRoleBasic:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIRoleBasic:OnItemDragIn(fromData,toData)
	Debug('拖拽,fromBag:'..fromData.bagType..",fromPos"..fromData.pos..",toBag:"..toData.bagType..",toPos:"..toData.pos);
	--人物界面内的不处理
	if fromData.bagType==BagConsts.BagType_Role or fromData.bagType==BagConsts.BagType_RoleItem or fromData.bagType == BagConsts.BagType_RELIC then
		return;
	end
	--来自背包的
	if fromData.bagType == BagConsts.BagType_Bag then
		--判断是否是装备
		if BagUtil:GetItemShowType(fromData.tid) == BagConsts.ShowType_Equip then
			--判断装备位是否相同
			if BagUtil:GetEquipType(fromData.tid) ~= BagUtil:GetEquipAtBagPos(BagConsts.BagType_Role,toData.pos) then
				return;
			end
			--判断是否可穿戴
			if BagUtil:GetEquipCanUse(fromData.tid) < 0 then
				return;
			end
			BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
		end
		--是否是翅膀
		if BagUtil:IsWing(fromData.tid) then
			--翅膀就一个格子,先不判断格子
			--是否可使用
			if BagUtil:GetItemCanUse(fromData.tid) < 0 then
				return;
			end
			BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
		end
		--是否是圣物
		if BagUtil:IsRelic(fromData.tid) then
				--判断装备位是否相同
			if BagUtil:GetRelicPos(fromData.tid) ~= BagUtil:GetEquipAtBagPos(BagConsts.BagType_RELIC,toData.pos) then
				return;
			end
			if BagUtil:GetItemCanUse(fromData.tid) < 0 then
				return
			end
			BagController:SwapItem(fromData.bagType, fromData.pos,toData.bagType,toData.pos)
		end
		return;
	end
end

--左键菜单
function UIRoleBasic:OnItemClick(item)
	TipsManager:Hide();
	
	--todo
	--如果快速装备面板当前显示，则关闭
	if UIChibangPickView:IsShow() then
		UIChibangPickView:Hide();
	end

	if UIBagQuickEquitView:IsShow() then
		UIBagQuickEquitView:Hide();
		return;
	end
	local itemData = item:GetData();
	if not itemData.opened then
		return;
	end
	
	if itemData.bagType == BagConsts.BagType_RELIC then
		local bagVO = BagModel:GetBag(itemData.bagType)
		item = bagVO:GetItemByPos(itemData.pos)
		if not item then
			return
		end
		--如果是圣物，这里的左键菜单直接弹出升级
		UIRelicView:OpenView(item)
		return
	end
	
	if _sys:isKeyDown(_System.KeyCtrl) then
		ChatQuickSend:SendItem(itemData.bagType,itemData.pos);
		return;
	end
	if itemData.bagType ~= BagConsts.BagType_Role then 
		return;
	end 
	
	if not itemData.hasItem then
		UIBagQuickEquitView:Open(item.mc, itemData.bagType, itemData.pos, itemData.pos);
		return;
	end
	UIBagQuickEquitView:Open(item.mc, itemData.bagType, itemData.pos, itemData.pos, itemData.hasItem);
end

--双击卸载
function UIRoleBasic:OnItemDoubleClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem  then
		return;
	end
	BagController:UnEquipItem(data.bagType,data.pos);
end

--右键卸载
function UIRoleBasic:OnItemRClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	BagController:UnEquipItem(data.bagType,data.pos);
end
---------------------------以上是装备处理--------------------------------------

---------------------------以下是徽章处理--------------------------------------
--强化连锁徽章
function UIRoleBasic:ShowStrenLink(bInit)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local currLinkId = EquipModel:GetStrenLinkId();
	local btn = s_linkBtn[1]
	if btn then
		btn:removeMovieClip();
		s_linkBtn[1] = nil;
	end
	if currLinkId ~= 0 then
		self.strenLinkId = currLinkId;
		local depth = objSwf.mcLink:getNextHighestDepth();
		s_linkBtn[1] = objSwf.mcLink:attachMovie("StrenLinkButton"..self.strenLinkId,"linkBtn1",depth);
		btn = s_linkBtn[1]
		btn.disabled = false;
		btn.alwaysRollEvent = true;
		btn.rollOut = function() TipsManager:Hide(); end
		btn.rollOver = function() self:OnStrenLinkRollOver(); end
		btn.click = function() FuncManager:OpenFunc(FuncConsts.EquipStren) end
	end
	if not bInit then
		self:ResetLinkBtn()
	end
end

function UIRoleBasic:OnStrenLinkRollOver()
	if self.strenLinkId == 0 then
		local tipsVO = {};
		tipsVO.linkId = 1;
		tipsVO.activeNum = EquipModel:GetAllStrenLvl()
		TipsManager:ShowTips(TipsConsts.Type_StrenLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
		return;
	end
	local tipsVO = {};
	tipsVO.linkId = self.strenLinkId;
	tipsVO.activeNum = t_strenlink[self.strenLinkId].level
	TipsManager:ShowTips(TipsConsts.Type_StrenLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

function UIRoleBasic:ResetLinkBtn()
	local x = 1
	for i = 1, 4 do
		local btn = s_linkBtn[i]
		if btn then
			btn._y = (x - 1) * 40
			x = x + 1
			if i == 4 then
				btn._x = 14
				btn._y = btn._y + 13
			end
		end
	end
end

--- 洗练连锁
function UIRoleBasic:ShowWashLink(bInit)
	local objSwf = self.objSwf
	if not objSwf then
		return
	end
	local currLinkId = EquipModel:GetWashLinkID()
	local btn = s_linkBtn[2]
	if btn then
		btn:removeMovieClip()
		s_linkBtn[2] = nil
	end
	if currLinkId ~= 0 then
		self.washLinkId = currLinkId;
		local depth = objSwf.mcLink:getNextHighestDepth();
		s_linkBtn[2] = objSwf.mcLink:attachMovie("StrenWashButton"..self.washLinkId,"linkBtn2",depth);
		btn = s_linkBtn[2]
		btn.disabled = false;
		btn.alwaysRollEvent = true;
		btn.rollOut = function() TipsManager:Hide(); end
		btn.rollOver = function() self:OnWashLinkRollOver(); end
		btn.click = function() FuncManager:OpenFunc(FuncConsts.SmithingWash) end
	end
	if not bInit then
		self:ResetLinkBtn()
	end
end

function UIRoleBasic:OnWashLinkRollOver()
	local linkCfg = t_extrachain[self.washLinkId];
	if not linkCfg then return; end
	local tipsVO = {};
	tipsVO.linkId = self.washLinkId;
	tipsVO.activeNum = EquipModel:GetWashAllLv()
	TipsManager:ShowTips(TipsConsts.Type_WashLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

--宝石连锁装备
function UIRoleBasic:ShowGemLink(bInit)
	local objSwf = self.objSwf
	if not objSwf then
		return
	end
	local currLinkId = SmithingModel:GetGemLinkId();
	local btn = s_linkBtn[3]
	if btn then
		btn:removeMovieClip();
		s_linkBtn[3] = nil;
	end
	if currLinkId ~= 0 then
		self.gemLinkId = currLinkId;
		local depth = objSwf.mcLink:getNextHighestDepth();
		s_linkBtn[3] = objSwf.mcLink:attachMovie("GemLinkButton"..self.gemLinkId,"linkBtn3",depth);
		btn = s_linkBtn[3]
		btn.disabled = false;
		btn.alwaysRollEvent = true;
		btn.rollOut = function() TipsManager:Hide(); end
		btn.rollOver = function() self:OnGemLinkRollOver(); end
		btn.click = function() FuncManager:OpenFunc(FuncConsts.EquipGem) end
	end
	if not bInit then
		self:ResetLinkBtn()
	end
end

function UIRoleBasic:OnGemLinkRollOver()
	local tipsVO = {}
	tipsVO.linkId = self.gemLinkId;
	tipsVO.activeNum = SmithingModel:GetAllEquipGemLv()
	TipsManager:ShowTips(TipsConsts.Type_GemLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

function UIRoleBasic:ShowGuildLink(bInit)
	local objSwf = self.objSwf
	if not objSwf then 
		return 
	end
	local btn = s_linkBtn[4]
	if btn then
		btn:removeMovieClip();
		s_linkBtn[4] = nil;
	end
	if UnionModel:GetMyUnionId() then
		local depth = objSwf.mcLink:getNextHighestDepth();
		s_linkBtn[4] = objSwf.mcLink:attachMovie("GuildLinkButton", "linkBtn4",depth);
		btn = s_linkBtn[4]
		btn.disabled = false;
		btn.alwaysRollEvent = true;
		btn.rollOut = function() UIUnionAidTips:Hide() end
		btn.rollOver = function() UIUnionAidTips:Show() end
		btn.click = function() UIUnionAidPanel:Show() end
	end
	if not bInit then
		self:ResetLinkBtn()
	end
end

--炼化连锁徽章
function UIRoleBasic:ShowRefinLink()
	local currLinkId = EquipModel:GetRefinLinkId()
	if currLinkId == self.refinLinkId then return; end
	if self.refinLinkBtn then
		self.refinLinkBtn:removeMovieClip();
		self.refinLinkBtn = nil;
	end
	self.refinLinkId = currLinkId;
	local objSwf = self.objSwf;
	local depth = objSwf:getNextHighestDepth();
	if self.refinLinkId == 0 then
		self.refinLinkBtn = objSwf:attachMovie("StrenLinkButton1","linkBtn",depth);
		self.refinLinkBtn.disabled = true;
	else
		self.refinLinkBtn = objSwf:attachMovie("StrenLinkButton"..self.refinLinkId,"linkBtn",depth);
		self.refinLinkBtn.disabled = false;
	end
	self.refinLinkBtn.alwaysRollEvent = true;
	self.refinLinkBtn.rollOut = function() TipsManager:Hide(); end
	self.refinLinkBtn.rollOver = function() self:OnRefinLinkRollOver(); end
end

function UIRoleBasic:OnRefinLinkRollOver()
	if self.refinLinkId == 0 then
		local tipsVO = {};
		tipsVO.linkId = 1;
		tipsVO.activeNum = self:GetRefinLinkActiveNum(1);
		TipsManager:ShowTips(TipsConsts.Type_RefinLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
		return;
	end
	local tipsVO = {};
	tipsVO.linkId = self.refinLinkId;
	tipsVO.activeNum = self:GetRefinLinkActiveNum(self.refinLinkId);
	if t_refinlink[self.refinLinkId+1] then
		tipsVO.nextLinkId = self.refinLinkId+1;
		tipsVO.nextActiveNum = self:GetRefinLinkActiveNum(self.refinLinkId+1);
	end
	TipsManager:ShowTips(TipsConsts.Type_RefinLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

--获取炼化连锁激活的数量
function UIRoleBasic:GetRefinLinkActiveNum(id)
	local linkCfg = t_refinlink[id];
	if not linkCfg then return 0; end
	local num = 0;
	for i,pos in ipairs(EquipConsts.EquipStrenType) do
		if EquipModel:GetRefinLvlByPos(pos)>=linkCfg.openlvl then
			num = num + 1;
		end
	end
	return num;
end
---------------------------以上是徽章处理---------------------------------------

--------------------------神炉的显示图标处理-----------------------------------------
--显示神炉装备
--[[
--策划说将这个屏蔽因为主角面板位置不够  jianghaoran 2016-8-11
function UIRoleBasic:ShowStove()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--找出对应的VO
	local xuanbingVO = EquipModel:GetStoveInfoVOByType(StovePanelView.XUANBING);
	local baojiaVO = EquipModel:GetStoveInfoVOByType(StovePanelView.BAOJIA);
	local mingyuVO = EquipModel:GetStoveInfoVOByType(StovePanelView.MINGYU);
	local icon = "";
	if xuanbingVO then
		icon = ResUtil:GetStoveIcon(StoveUtil:GetStoveIcon(xuanbingVO.type, xuanbingVO.currentLevel));
		objSwf.btnXuanBing.iconLoader.source = icon;
		objSwf.btnXuanBing.click = function() self:OpenStovePanel(xuanbingVO.type) end
	else
		objSwf.btnXuanBing.click = nil;
	end

	if baojiaVO then
		icon = ResUtil:GetStoveIcon(StoveUtil:GetStoveIcon(baojiaVO.type, baojiaVO.currentLevel));
		objSwf.btnBaoJia.iconLoader.source = icon;
		objSwf.btnBaoJia.click = function() self:OpenStovePanel(baojiaVO.type) end
	else
		objSwf.btnBaoJia.click = nil;
	end

	if mingyuVO then
		icon = ResUtil:GetStoveIcon(StoveUtil:GetStoveIcon(mingyuVO.type, mingyuVO.currentLevel));
		objSwf.btnMingYu.iconLoader.source = icon;
		objSwf.btnMingYu.click = function() self:OpenStovePanel(mingyuVO.type) end
	else
		objSwf.btnMingYu.click = nil;
	end
end

function UIRoleBasic:OpenStovePanel(type)
	StovePanelView:Show(type);
end
]]
---------------------------以下是功能引导的接口---------------------------------
function UIRoleBasic:PlayWingSlotEff()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.effWingSlot:playEffect(1);
end

function UIRoleBasic:GetWingSlotPos()
	local objSwf = self.objSwf;
	if not objSwf then return {x=0,y=0}; end
	return UIManager:PosLtoG(objSwf.roleItem1,0,0);
end
function UIRoleBasic:GetWuqiSlotPos()
	local objSwf = self.objSwf;
	if not objSwf then return {x=0,y=0}; end
	return UIManager:PosLtoG(objSwf.item1,0,0);
end
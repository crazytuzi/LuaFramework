--[[坐骑界面主面板
zhangshuhui
2014年11月05日17:20:20
]]

_G.UIOtherMountBasic = BaseUI:new("UIOtherMountBasic");

UIOtherMountBasic.slotTotalNum = 4;--UI上格子总数
UIOtherMountBasic.skillTotalNum = 6;--UI上技能总数
UIOtherMountBasic.numFightx = 0;--战斗力x坐标

UIOtherMountBasic.curModel = nil;

--技能列表
UIOtherMountBasic.skillicon = {}
UIOtherMountBasic.skilllist = {}

function UIOtherMountBasic:Create()
	self:AddSWF("othermountBasicPanel.swf", true, "center")
end

local isShowMountDes = false
local mountmouseMoveX = 0
function UIOtherMountBasic:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	objSwf.list.itemRollOver = function(e) self:OnMountEquipRollOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	
	objSwf.btnRoleLeft.stateChange = function(e) 
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleLeftStateChange(e.state);
		end
	end;
	objSwf.btnRoleLeft.visible = false
	objSwf.btnRoleRight.stateChange = function(e)
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleRightStateChange(e.state);
		end
	end;
	objSwf.btnRoleRight.visible = false
	
	--技能
	for i=1,self.skillTotalNum do
		self.skillicon[i] = objSwf["skill"..i]
		self.skillicon[i].btnskill.rollOver = function(e) self:OnMountSkillTipRollOver(i); end
		self.skillicon[i].btnskill.rollOut  = function() self:OnMountSkillTipRollOut();  end
	end
								
	--战斗力值居中
	self.numFightx = objSwf.numFight._x
	objSwf.numFight.loadComplete = function()
									objSwf.numFight._x = self.numFightx - objSwf.numFight.width / 2
								end
								
	--模型防止阻挡鼠标
	objSwf.modelload.hitTestDisable = true;
	
	objSwf.btnDesShow.press = function() 		
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		mountmouseMoveX = monsePosX;   		       
		self.isMouseDrag = true
	end

	objSwf.btnDesShow.release = function()
		self.isMouseDrag = false
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleRightStateChange("release"); 				
		end
	end
end

function UIOtherMountBasic:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	for k,_ in pairs(self.skillicon)do
		self.skillicon[k] = nil;
	end
end


function UIOtherMountBasic:Update()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not self.bShowState then return end
	
	if self.isMouseDrag then
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		if mountmouseMoveX<monsePosX then
			local speed = monsePosX - mountmouseMoveX
			if self.objUIDraw then
				self.objUIDraw:OnBtnRoleRightStateChange("down",speed); 
			end
		elseif mountmouseMoveX>monsePosX then 
			local speed = mountmouseMoveX - monsePosX
			if self.objUIDraw then
				self.objUIDraw:OnBtnRoleLeftStateChange("down",speed); 
			end
		end
		mountmouseMoveX = monsePosX;
	end
	
	local cfg = {};
	if OtherRoleModel.rideSelect < MountConsts.SpecailDownid then
		cfg = t_horse[OtherRoleModel.rideSelect];
		
		if not cfg then
			Error("Cannot find config of horse. level:"..OtherRoleModel.rideSelect);
			return;
		end
	elseif OtherRoleModel.rideSelect < MountConsts.LingShouSpecailDownid then
		cfg = t_horseskn[OtherRoleModel.rideSelect];
		
		if not cfg then
			Error("Cannot find config of t_horseskn. level:"..OtherRoleModel.rideSelect);
			return;
		end
	else
		cfg = t_horse[OtherRoleModel.rideLevel];
		
		if not cfg then
			Error("Cannot find config of horse. level:"..OtherRoleModel.rideLevel);
			return;
		end
	end
	
	
	local ui_node =  MountUtil:GetMountSen(cfg.ui_node,OtherRoleModel.otherhumanBSInfo.prof);
	
	if self.objUIDraw then
		self.objUIDraw:Update(ui_node);
	end
end

function UIOtherMountBasic:OnShow(name)
	self:InitData();
	--坐骑装备
	self:ShowEquip();
	--坐骑信息
	self:ShowMountInfo();
	--属性丹
	self:ShowShuXingDanInfo();
	--技能
	self:ShowSkillList();
	
	self:UpdateMask();
	
	self:UpdateCloseButton();
end

function UIOtherMountBasic:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

function UIOtherMountBasic:IsShowLoading()
	return true;
end

function UIOtherMountBasic:GetPanelType()
	return 0;
end

function UIOtherMountBasic:IsShowSound()
	return true;
end

function UIOtherMountBasic:GetWidth()
	return 1489;
end

function UIOtherMountBasic:GetHeight()
	return 760;
end

function UIOtherMountBasic:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	self:UpdateCloseButton()
end

function UIOtherMountBasic:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 100
	objSwf.mcMask._height = wHeight + 100
end

function UIOtherMountBasic:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1280 ), 1380 )
end

--初始化数据
function UIOtherMountBasic:InitData()
end

--点击关闭按钮
function UIOtherMountBasic:OnBtnCloseClick()
	self:Hide();
end

---------------------------------ui事件处理------------------------------------

function UIOtherMountBasic:OnMountSkillTipRollOver(i)
	local skillId = self.skilllist[i].skillId;
	local get = self.skilllist[i].lvl > 0;
	
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillId,condition=false,get=get},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end

function UIOtherMountBasic:OnMountSkillTipRollOut()
	TipsManager:Hide();
end
---------------------------------ui逻辑------------------------------------

--显示信息
function UIOtherMountBasic:ShowMountInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local playerinfo = OtherRoleModel.otherhumanBSInfo;
	
	--模型
	if OtherRoleModel.rideSelect < MountConsts.LingShouSpecailDownid then
		if OtherRoleModel.rideSelect > 0 then
			self:DrawMount(OtherRoleModel.rideSelect)
			local iconname = MountUtil:GetMountIconName(OtherRoleModel.rideSelect, "nameIcon", playerinfo.prof)
			objSwf.nameLoader.source =  ResUtil:GetMountIconName(iconname)
		end
	else
		if OtherRoleModel.rideLevel > 0 then
			self:DrawMount(OtherRoleModel.rideLevel)
			local iconname = MountUtil:GetMountIconName(OtherRoleModel.rideLevel, "nameIcon", playerinfo.prof)
			objSwf.nameLoader.source =  ResUtil:GetMountIconName(iconname)
		end
	end
	
	objSwf.lvlLoader.source = ResUtil:GetFeedUpLvlImg(OtherRoleModel.rideLevel);
	
	objSwf.imgordermax._visible = false;
	if OtherRoleModel.rideLevel >= MountConsts.MountLevelMax then
		objSwf.imgordermax._visible = true;
	end
	
	--基本信息
	local info = OtherRoleUtil:GetMountAttribute(OtherRoleModel.rideLevel,OtherRoleModel.rideStar)
	if info == nil then
		return
	end

	for i,vo in ipairs(info) do
		if vo.type == enAttrType.eaFight then
			objSwf.numFight.num = vo.val
		elseif vo.type == enAttrType.eaGongJi then
			objSwf.tfGongJi.text = vo.val
		elseif vo.type == enAttrType.eaFangYu then
			objSwf.tfFangYu.text = vo.val
		elseif vo.type == enAttrType.eaBaoJi then
			objSwf.tfBaoJi.text = vo.val
		elseif vo.type == enAttrType.eaRenXing then
			objSwf.tfRenXing.text = vo.val
		elseif vo.type == enAttrType.eaMingZhong then
			objSwf.tfMingZhong.text = vo.val
		elseif vo.type == enAttrType.eaShanBi then
			objSwf.tfShanBi.text = vo.val
		elseif vo.type == enAttrType.eaMaxHp then
			objSwf.tfShengMing.text = vo.val
		elseif vo.type == enAttrType.eaMoveSpeed then
			objSwf.tfSuDu.text = vo.val
		end
	end
end

--显示属性丹信息
function UIOtherMountBasic:ShowShuXingDanInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

function UIOtherMountBasic:ShowSkillList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for i=1, self.skillTotalNum do
		self.skillicon[i].visible = true
		self.skillicon[i].btnskill.visible = false
		self.skillicon[i].imgup.visible = false
		self.skillicon[i].iconLoader.visible = false
	end
	
	local list = OtherRoleUtil:GetOtherMountSortSkill();
	for i= 1, self.skillTotalNum do
		local listvo = OtherRoleUtil:GetSkillListVO(list[i].skillId,list[i].lvl)
		if listvo then
			self.skillicon[i].btnskill.visible = true
			self.skillicon[i].iconLoader.visible = true
			
			if listvo.lvl == 0 then
				self.skillicon[i].iconLoader.source = ImgUtil:GetGrayImgUrl(listvo.iconUrl)
			else
				self.skillicon[i].iconLoader.source = listvo.iconUrl
			end
			
			self.skilllist[i] = listvo
		end
	end
end

-- 显示等级为level的3d坐骑模型
-- showActive: 是否播放激活动作
local viewOtherMountPort;
function UIOtherMountBasic : DrawMount( level, showActive )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not level then
		level = MountModel:GetMountLvl();
	end
	local cfg = {};
	--普通坐骑
	if level < MountConsts.SpecailDownid then
		cfg = t_horse[level];
		
		if not cfg then
			Error("Cannot find config of horse. level:"..level);
			return;
		end
	--特殊坐骑
	else
		cfg = t_horseskn[level];
		
		if not cfg then
			Error("Cannot find config of t_horseskn. level:"..level);
			return;
		end
	end
	
	local modelId = MountUtil:GetPlayerMountModelId(level)
	
	local modelCfg = t_mountmodel[modelId];
	if not modelCfg then
		Error("Cannot find config of MountModel. id:"..modelId);
		return;
	end
	if not self.objUIDraw then
		if not viewOtherMountPort then viewOtherMountPort = _Vector2.new(1279, 732); end
		self.objUIDraw = UISceneDraw:new( "OtherMountBaseUI", objSwf.modelload, viewOtherMountPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);
	
	-- local setUIPfxFunc = function()
		-- if modelCfg.effect and modelCfg.effect ~= ""then
			-- self.objUIDraw:PlayNodePfx( cfg.ui_node, modelCfg.effect);
		-- end
	-- end
	
	local ui_sen = MountUtil:GetMountSen(cfg.ui_sen,OtherRoleModel.otherhumanBSInfo.prof);
	local ui_node =  MountUtil:GetMountSen(cfg.ui_node,OtherRoleModel.otherhumanBSInfo.prof);
	
	if showActive then
		self.objUIDraw:SetScene( ui_sen, function()
			local aniName = modelCfg.san_show;
			if not aniName or aniName == "" then return end
			if not cfg.ui_node then return end
			local nodeName = split(ui_node, "#")
			if not nodeName or #nodeName < 1 then return end
				
			for k,v in pairs(nodeName) do
				self.objUIDraw:NodeAnimation( v, aniName );
			end
		end );
	else
		self.objUIDraw:SetScene( ui_sen, nil );
	end
	self.objUIDraw:NodeVisible(ui_node,true);
	self.objUIDraw:SetDraw( true );
	
	--播放音效
	self:PlayMountSound(level);
end;

function UIOtherMountBasic:PlayMountSound(level)
	local soundid = MountUtil:GetMountSound(level,OtherRoleModel.otherhumanBSInfo.prof);
	if soundid > 0 then
		SoundManager:PlaySfx(soundid);
	end
end

---------------------------以下是装备处理--------------------------------------
--显示装备
function UIOtherMountBasic:ShowEquip()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = OtherRoleUtil:GetMountEquipUIList(OtherRoleModel.othermountequiplist);
    objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(list));
	objSwf.list:invalidateData();
end

function UIOtherMountBasic:OnMountEquipRollOver(e)
	if not e.item.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetHorseEquipNameByPos(e.item.pos));
		return;
	end
	
	--他人信息中个数是1  绑定状态为1
	local itemTipsVO = OtherRoleUtil:GetMountEquipTipVO(e.item.tid);
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end
---------------------------以上是装备处理--------------------------------------
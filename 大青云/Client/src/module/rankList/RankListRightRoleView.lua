--[[
排行榜右侧 人物基础信息面吧，
wangshuai
]]

_G.UIRankListRightRole = BaseUI:new("UIRankListRightRole");

UIRankListRightRole.roleTurnDir = 0;--人物旋转方向 0,不旋转;1左;-1右
UIRankListRightRole.pfxName = nil;
function UIRankListRightRole:Create()
	self:AddSWF("RanklistRightRolePanel.swf",true,nil)
end;

function UIRankListRightRole:OnLoaded(objSwf)
	objSwf.list.itemRollOver = function(e) self:OnItemRollOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	
	objSwf.itemlist.itemRollOver = function(e) self:OnWingItemRollOver(e); end
	objSwf.itemlist.itemRollOut = function(e) TipsManager:Hide(); end

	objSwf.closebtn.click = function() self:ClosePanle()end;
	objSwf.btnRoleRight.stateChange = function(e) self:RoleModelRightBtn(e.state) end;
	objSwf.btnRoleLeft.stateChange = function(e) self:RoleModelLeftgBtn(e.state) end;
	objSwf.roleload.hitTestDisable = true;
end;

function UIRankListRightRole:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIRankListRightRole:OnShow()
	local objSwf = self.objSwf;
	--objSwf.fight.fightCapacityEffect:playEffect(0); --播放战斗力背景特效
	self:ShowEquipList();
	self:ShowRoleItem();
	self:DrawRole();
end;

function UIRankListRightRole:OnHide()
	local objSwf = self.objSwf;
	--objSwf.fight.fightCapacityEffect:stopEffect();--停止战斗力背景特效
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil)
	end
	if self.objAvatar then 
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end;
end;

function UIRankListRightRole:ClosePanle()
	self:Hide();
end;

function UIRankListRightRole:ShowEquipList()
	local objSwf = self.objSwf;
	local listVo = RankListUtils:GetRoleEquipItemList()
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(listVo));
	objSwf.list:invalidateData();
	-- 设置人物 名称，战斗力
	local infoVo = RankListModel.roleDetaiedinfo;
	objSwf.labelName.text = infoVo.eaName
	objSwf.Unionname.text = infoVo.eaGuildName;
	--objSwf.fight.num = infoVo.eaFight
end;

function UIRankListRightRole:ShowRoleItem()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.itemlist = RankListUtils:GetBodyToolList();
	objSwf.itemlist.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.itemlist) do
		objSwf.itemlist.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.itemlist:invalidateData();
end

function UIRankListRightRole:OnItemRollOver(e)
	local data = e.item;
	
	if not data.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetEquipName(data.pos));
		return;
	end
	
	local itemTipsVO = nil;
	itemTipsVO = RankListUtils:GetEquipTipVO(data.tid, data.pos);
	if not itemTipsVO then return; end
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end

function UIRankListRightRole:OnWingItemRollOver(e)
	local data = e.item;
	
	if not data.hasItem then
		TipsManager:ShowBtnTips("翅膀");
		return;
	end
	
	local itemTipsVO = nil;
	itemTipsVO = RankListUtils:GetWingTipVO(data.tid,data.showBind);
	
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end

function UIRankListRightRole:RefreshData()
	-- 刷新数据就行
	self:ShowEquipList();
	self:ShowRoleItem();
	self:DrawRole();
end;


function UIRankListRightRole:DrawRole()
	local info = RankListModel.roleDetaiedinfo
	--info.wing = RankListUtils:GetWingId();

	local uiLoader = self.objSwf.roleload;
	local prof = info.prof;


	if self.objAvatar then 
		self.objAvatar:ExitMap()
		self.objAvatar = nil;
	end;
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(info);

	--
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("RankListRightRolePanel",self.objAvatar, uiLoader,
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
	if self.pfxName ~= nil then 
		self.objUIDraw:StopPfx(self.pfxName)
	end;
	local sex = info.sex
	local pfxName = "ui_role_sex" ..sex.. ".pfx";
	local name,pfx = self.objUIDraw:PlayPfx(pfxName);
	self.pfxName = name;
	-- 微调参数
	pfx.transform:setRotationX(UIDrawRoleCfg[prof].pfxRotationX);

end;

--模型旋转
function UIRankListRightRole:RoleModelLeftgBtn(state)
	if state == "down" then
		self.roleTurnDir = 1;
	elseif state == "release" then
		self.roleTurnDir = 0;
	elseif state == "out" then
		self.roleTurnDir = 0;
	end
end
function UIRankListRightRole:RoleModelRightBtn(state)
	if state == "down" then
		self.roleTurnDir = -1;
	elseif state == "release" then
		self.roleTurnDir = 0;
	elseif state == "out" then
		self.roleTurnDir = 0;
	end
end

function UIRankListRightRole:Update()
	if not self.bShowState then return end;
	if self.roleTurnDir == 0 then
		return;
	end
	if not self.objAvatar then
		return;
	end
	self.meshDir = self.meshDir + math.pi/40*self.roleTurnDir;
	if self.meshDir < 0 then
		self.meshDir = self.meshDir + math.pi*2;
	end
	if self.meshDir > math.pi*2 then
		self.meshDir = self.meshDir - math.pi*2;
	end
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
end
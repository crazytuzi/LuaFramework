--[[
装备卓越面板
lizhuangzhuang
2015年1月27日11:26:22
]]

_G.UIEquipSuper = BaseUI:new("UIEquipSuper");

--孔总数
UIEquipSuper.TotalHoleNum = 3;
--当前选中装备格子
UIEquipSuper.currPos = 0;
--当前选中的卓越孔
UIEquipSuper.currSuperHoleIndex = 1;
--当前孔的配置
UIEquipSuper.currHoleCfg = nil;

function UIEquipSuper:Create()
	self:AddSWF("equipSuperPanel.swf",true,nil);
end

function UIEquipSuper:OnLoaded(objSwf)
	--设置模型不接受事件
	objSwf.roleLoaderSuper.hitTestDisable = true;
	for i=1,11 do
		objSwf["roleItem"..i].click = function() self:OnRoleItemClick(i-1); end
		objSwf["roleItem"..i].rollOver = function() self:OnRoleItemRollOver(i-1); end
		objSwf["roleItem"..i].rollOut = function() UIEquipSuperTips:Hide(); end
	end
	for i=1,self.TotalHoleNum do
		objSwf["btnHole"..i].click = function() self:SelectSuperHole(i); end
	end
	objSwf.btnRule.rollOver = function() TipsManager:ShowBtnTips(StrConfig['equip501'],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function() TipsManager:Hide(); end
	objSwf.btnLvlUp.rollOver = function() self:OnBtnLvlUpRollOver(); end
	objSwf.btnLvlUp.rollOut = function() self:OnBtnLvlUpRollOut(); end
	objSwf.btnLvlUp.click = function() self:OnBtnLvlUpClick(); end
	objSwf.btnNeedItem.rollOver = function() self:OnBtnNeedItemOver(); end
	objSwf.btnNeedItem.rollOut = function() TipsManager:Hide(); end
	objSwf.btnNeedMoney.rollOver = function() 
										TipsManager:ShowBtnTips(StrConfig['tips50'],TipsConsts.Dir_RightDown);
										end
	objSwf.btnNeedMoney.rollOut = function() TipsManager:Hide(); end
	self:ShowRoleList();
end

function UIEquipSuper:OnShow()
	self:ShowRight(0);
	self:DrawRole();
end

--显示左侧列表
function UIEquipSuper:ShowRoleList()
	local objSwf = self.objSwf;
	for i=1,11 do
		objSwf["roleItem"..i].iconLoader.source = ResUtil:GetEquipPosUrl(i-1);
		objSwf["roleItem"..i].tfLvl.text = "Lv." .. self:GetTotalLvlAtPos(i-1);
	end
end

--获取某个位置的总等级
function UIEquipSuper:GetTotalLvlAtPos(pos)
	local lvl = 0;
	for i=1,self.TotalHoleNum do
		lvl = lvl + EquipModel:GetSuperHoleAtIndex(pos,i);
	end
	return lvl;
end

--点击左侧列表
function UIEquipSuper:OnRoleItemClick(pos)
	if pos == self.currPos then return; end
	self:ShowRight(pos);
end

--左侧tips
function UIEquipSuper:OnRoleItemRollOver(pos)
	UIEquipSuperTips:Show(pos);
end

--显示右侧
function UIEquipSuper:ShowRight(pos)
	self.currPos = pos;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf["roleItem"..(pos+1)].selected = true;
	objSwf.roleRightItem.iconLoader.source = ResUtil:GetEquipPosUrl(pos,"54");
	for i=1,self.TotalHoleNum do
		self:ShowHole(i,false);
	end
	self:SelectSuperHole(1);
end

--显示某个孔
--@param up  是否显示升级提示
function UIEquipSuper:ShowHole(index,up)
	local objSwf = self.objSwf;
	local holeLevel = EquipModel:GetSuperHoleAtIndex(self.currPos,index);
	local cfg = t_superHoleUp[holeLevel];
	local nextCfg = t_superHoleUp[holeLevel+1];
	if not nextCfg then
		objSwf["btnHole"..index].iconLoader.source = ResUtil:GetSuperHoleIconUrl(cfg.icon);
		objSwf["tfHole"..index].htmlText = string.format(StrConfig["equip503"],holeLevel,cfg.addPercent);
		return;
	end
	--
	local iconUrl = "";
	if up then
		iconUrl = ResUtil:GetSuperHoleIconUrl(nextCfg.icon);
	else
		if cfg then
			iconUrl = ResUtil:GetSuperHoleIconUrl(cfg.icon);
		else
			iconUrl = ResUtil:GetSuperHoleDefault();
		end
	end
	objSwf["btnHole"..index].iconLoader.source = iconUrl;
	local str = "";
	if not cfg then
		str = StrConfig["equip502"];
	else
		str = string.format(StrConfig["equip503"],holeLevel,cfg.addPercent);
	end
	if up then
		str = str .. string.format("<font color='#29CC00'>   ↑%s%%</font>",nextCfg.addPercent);
	end
	objSwf["tfHole"..index].htmlText = str;
end

--选中某个卓越孔
function UIEquipSuper:SelectSuperHole(index)
	self.currSuperHoleIndex = index;
	local objSwf = self.objSwf;
	objSwf["btnHole"..index].selected = true;	
	self:ShowCondition();
end

--显示条件
function UIEquipSuper:ShowCondition()
	local objSwf = self.objSwf;
	local holeLevel = EquipModel:GetSuperHoleAtIndex(self.currPos,self.currSuperHoleIndex);
	local cfg = t_superHoleUp[holeLevel+1];
	if not cfg then
		objSwf.btnNeedItem.label = "";
		objSwf.btnNeedMoney.label = "";
		return;
	end
	local needItemCfg = t_item[cfg.itemId];
	if needItemCfg then
		local name = needItemCfg.name;
		if BagModel:GetItemNumInBag(cfg.itemId) < cfg.itemNum then
			objSwf.btnNeedItem.htmlLabel = string.format(StrConfig["equip114"],name,cfg.itemNum);
		else
			objSwf.btnNeedItem.htmlLabel = string.format(StrConfig["equip103"],name,cfg.itemNum);
		end
	end
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < cfg.gold then
		objSwf.btnNeedMoney.htmlLabel = string.format(StrConfig['equip115'],cfg.gold);
	else
		objSwf.btnNeedMoney.htmlLabel = string.format(StrConfig['equip104'],cfg.gold);
	end
end

--需要道具
function UIEquipSuper:OnBtnNeedItemOver()
	local holeLevel = EquipModel:GetSuperHoleAtIndex(self.currPos,self.currSuperHoleIndex);
	local cfg = t_superHoleUp[holeLevel+1];
	if not cfg then return; end
	TipsManager:ShowItemTips(cfg.itemId);
end

--升级移入
function UIEquipSuper:OnBtnLvlUpRollOver()
	self.overBtnLvlUp = true;
	self:ShowHole(self.currSuperHoleIndex,true);
end

--升级移出
function UIEquipSuper:OnBtnLvlUpRollOut()
	self.overBtnLvlUp = false;
	self:ShowHole(self.currSuperHoleIndex,false);
end

--点击升级
function UIEquipSuper:OnBtnLvlUpClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	EquipController:SuperHoleLevelUp(self.currPos,self.currSuperHoleIndex,objSwf.cbAutoBuy.selected);
end

--升级成功
function UIEquipSuper:OnHoleLvlUp(index)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf["btnHole"..index].eff:playEffect(1);
end

function UIEquipSuper:HandleNotification(name,body)
	if name == NotifyConsts.BagItemNumChange then
		local holeLevel = EquipModel:GetSuperHoleAtIndex(self.currPos,self.currSuperHoleIndex);
		local cfg = t_superHoleUp[holeLevel+1];
		if not cfg then return; end
		if body.id == cfg.itemId then
			self:ShowCondition();
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:ShowCondition();
		end
	elseif name == NotifyConsts.SuperHoleLvlUp then
		if body.pos==self.currPos and body.index==self.currSuperHoleIndex then
			SoundManager:PlaySfx(2018);
			self:ShowHole(self.currSuperHoleIndex,self.overBtnLvlUp);
			self:OnHoleLvlUp(self.currSuperHoleIndex);
			self:ShowCondition();
			local objSwf = self.objSwf;
			if objSwf then
				objSwf["roleItem"..(self.currPos+1)].tfLvl.text = "Lv." .. self:GetTotalLvlAtPos(self.currPos);
			end
		end
	end
end
function UIEquipSuper:OnDelete()
	if self.objUIDraw then 
		self.objUIDraw:SetUILoader(nil);
	end;
end;
function UIEquipSuper:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
end;

function UIEquipSuper:ListNotificationInterests()
	return {NotifyConsts.BagItemNumChange,NotifyConsts.PlayerAttrChange,NotifyConsts.SuperHoleLvlUp};
end

--画模型
function UIEquipSuper:DrawRole()
	local uiLoader = self.objSwf.roleLoaderSuper;

	
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = info.dwArms
	vo.dress = info.dwDress
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.dwFashionsHead
	vo.fashionsArms = info.dwFashionsArms
	vo.fashionsDress = info.dwFashionsDress
	vo.wuhunId = 0;--SpiritsModel:GetFushenWuhunId()
	vo.wing = info.dwWing
	vo.suitflag = info.suitflag
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;	
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);
	--
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("rolePanelPlayerSuper", self.objAvatar, uiLoader,
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
	self.objAvatar:PlayLianhualuAction()

end



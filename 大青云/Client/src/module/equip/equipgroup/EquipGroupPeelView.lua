--[[
装备套装剥离
wangshuai
2015年10月31日16:48:06
]]

_G.UIEquipGroupPeel = BaseUI:new("UIEquipGroupPeel");

UIEquipGroupPeel.curPos = 0;

function UIEquipGroupPeel:Create()
	self:AddSWF("equipGroupPeelpanle.swf",true,nil)
end;

function UIEquipGroupPeel:OnLoaded(objSwf)
	objSwf.roleLoader.hitTestDisable = true;

	objSwf.list.itemClick = function(e) self:OnRoleEquipClick(e); end
	objSwf.list.itemRollOver = function(e) self:OnRoleEquipRollOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end

	objSwf.btnSrcEquip.rollOver = function() self:OnBtnSrcEquipRollOver(); end
	objSwf.btnSrcEquip.rollOut = function() TipsManager:Hide(); end

	objSwf.cailiao1_item.rollOver = function() self:OnEquipOver()end;
	objSwf.cailiao1_item.rollOut = function()TipsManager:Hide();end;

	objSwf.cailiao2_item.rollOver = function() self:OnCailiaoOver()end;
	objSwf.cailiao2_item.rollOut = function()TipsManager:Hide();end;

	objSwf.sure_btn.click = function() self:SureClick()end;

	objSwf.rule_btn.rollOver = function() self:RuleOver() end
	objSwf.rule_btn.rollOut = function() TipsManager:Hide(); end
end;

function UIEquipGroupPeel:RuleOver()
	TipsManager:ShowBtnTips(StrConfig["equipgroup010"],TipsConsts.Dir_RightDown);
end;

function UIEquipGroupPeel:OnShow()
	self:DrawRole()
	self:ShowRoleEquip();
	self:ShowUICurEquip();
end;

function UIEquipGroupPeel:OnHied()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	UIEquipGroupPeel.curPos = 1;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
end;

function UIEquipGroupPeel:OnDelete()
	if self.objUIDraw then 
		self.objUIDraw:SetUILoader(nil);
	end;
end;

--updataUI
function UIEquipGroupPeel:UpdataUI()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:ShowRoleEquip()	
	self:ShowUICurEquip();
end;

--确认剥离
function UIEquipGroupPeel:SureClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.curPos);
	if not item then return end
	local grouid2 = EquipModel:GetGroupId2(item:GetId())
	if not grouid2 or grouid2 <= 0 then 
		--没有可剥离的套装
		FloatManager:AddNormal(StrConfig['equipgroup006']);
		return 
	end; 
	EquipController:OnRepEquipGroupPeel(item:GetId())
end;

--剥离后装备tips效果
function UIEquipGroupPeel:OnEquipOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.curPos);
	if not item then return end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.curPos);
	if not itemTipsVO then return; end
	itemTipsVO.groupId2 = 0;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

--剥离后的材料
function UIEquipGroupPeel:OnCailiaoOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.curPos);
	if not item then return end
	local grouid2 = EquipModel:GetGroupId2(item:GetId())
	local itemCfgId = t_equipgroup[grouid2]
	if itemCfgId then 
		local itemCfg = split(itemCfgId.itemId,',')
		TipsManager:ShowItemTips(toint(itemCfg[1]));
	end;
end;

--装备tips
function UIEquipGroupPeel:OnBtnSrcEquipRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.curPos < 0 then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.curPos);
	if not itemTipsVO then return; end
	if itemTipsVO.id <= 0 then return end;
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

--显示当前操作装备
function UIEquipGroupPeel:ShowUICurEquip()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.curPos);
	if not item then 
			objSwf.cailiao1_item:setData({})
			objSwf.cailiao2_item:setData({})
			objSwf.btnSrcEquip:setData({})
			objSwf.nameLoad._visible = false;
			objSwf.nogroup_mc._visible = true
		return end;

	local vo = EquipUtil:GetEquipUIVO(self.curPos,true);
	vo.iconUrl = ResUtil:GetItemIconUrl(t_equip[item:GetTid()].icon,"54");
	vo.qualityUrl = ResUtil:GetSlotQuality(t_equip[item:GetTid()].quality, 54);
	objSwf.btnSrcEquip:setData(UIData.encode(vo));	

	local equipCfg = EquipModel:GetEquipInfo(item:GetId())
	if equipCfg then
		local groupCfg = t_equipgroup[equipCfg.groupId2];
		if groupCfg then 
			--装备	
			local itemvo = RewardSlotVO:new();
			itemvo.id = item:GetTid();
			itemvo.bind = item:GetBindState();
			objSwf.cailiao1_item:setData(itemvo:GetUIData());

			--套装物品
			local itemCfg = split(groupCfg.itemId,',')
			local group2Level = equipCfg.group2Level
			local cailiaoId, cailiaoBind, cailiaoCount = EquipUtil:GetGroupPeelBackItem( item:GetId() )
			local itemvo2 = RewardSlotVO:new();
			itemvo2.id = cailiaoId
			itemvo2.count = cailiaoCount
			itemvo2.bind = cailiaoBind == 1 and BagConsts.Bind_Bind or BagConsts.Bind_None

			-- itemvo2.id = toint(itemCfg[1]);
			-- itemvo2.count = toint(itemCfg[2]);
			-- itemvo2.bind = equipCfg.groupId2Bind == 1 and BagConsts.Bind_Bind or BagConsts.Bind_None

			objSwf.cailiao2_item:setData(itemvo2:GetUIData());
			objSwf.nameLoad.source = ResUtil:GetNewEquipGrouNameIcon(groupCfg.nameicon,true)
			objSwf.nameLoad._visible = true;
			objSwf.nogroup_mc._visible = false
			return
		end
	end
	objSwf.cailiao1_item:setData({})
	objSwf.cailiao2_item:setData({})
	objSwf.nameLoad._visible = false;
	objSwf.nogroup_mc._visible = true
end;

--显示玩家装备
function UIEquipGroupPeel:ShowRoleEquip()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local list = {};
	for i,pos in ipairs(EquipConsts.EquipStrenType) do
		table.push(list,UIData.encode(EquipUtil:GetEquipUIVO(pos)));
	end
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(list));
	objSwf.list:invalidateData();
end

--玩家装备click
function UIEquipGroupPeel:OnRoleEquipClick(e)
	local pos = e.item.pos;
	if self.curPos == pos then 
		return 
	end;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return end

	self.curPos = pos;
	self:ShowUICurEquip();
end;	

--玩家装备tips
function UIEquipGroupPeel:OnRoleEquipRollOver(e)
	local pos = e.item.pos;
	if not pos then return end;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end

--画模型
function UIEquipGroupPeel:DrawRole()
	local uiLoader = self.objSwf.roleLoader;

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
		self.objUIDraw = UIDraw:new("equipGroupPeelpanle", self.objAvatar, uiLoader,
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
	-- --播放特效
	-- local sex = MainPlayerModel.humanDetailInfo.eaSex;
	-- local pfxName = "ui_role_sex" ..sex.. ".pfx";
	-- local name,pfx = self.objUIDraw:PlayPfx(pfxName);
	-- 微调参数
	--pfx.transform:setRotationX(UIDrawRoleCfg[prof].pfxRotationX);
end

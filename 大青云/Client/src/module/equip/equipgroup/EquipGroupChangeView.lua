--[[
套装更改
wangshuai
2015年10月31日16:42:38
]]

_G.UIEquipGroupChange = BaseUI:new("UIEquipGroupChange");

UIEquipGroupChange.curPos = 1;
UIEquipGroupChange.curGroupList = {};
UIEquipGroupChange.curIndex = 1;
UIEquipGroupChange.cailiaomax = 3;
UIEquipGroupChange.oldindex = 0;

function UIEquipGroupChange:Create()
	self:AddSWF("equipGroupChange.swf",true,nil)
end;

function UIEquipGroupChange:OnLoaded(objSwf)
	objSwf.roleLoader.hitTestDisable = true;

	objSwf.list.itemClick = function(e) self:OnRoleEquipClick(e); end
	objSwf.list.itemRollOver = function(e) self:OnRoleEquipRollOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	
	for i=1,self.cailiaomax do
		objSwf["btnTool1"..i].click = function() self:OnClickTool(i)end;
		objSwf["btnTool2"..i].click = function() self:OnClickTool(self.cailiaomax+i)end;
	end

	objSwf.cailiao_item.rollOver = function() self:OnCailiaoOver()end;
	objSwf.cailiao_item.rollOut = function()TipsManager:Hide();end;

	objSwf.btnSrcEquip.rollOver = function() self:OnBtnSrcEquipRollOver(); end
	objSwf.btnSrcEquip.rollOut = function() TipsManager:Hide(); end

	objSwf.btnNbEquip.rollOver = function() self:OnBtnNbEquipRollOver(); end
	objSwf.btnNbEquip.rollOut = function() TipsManager:Hide(); end

	objSwf.getPath.rollOver = function() self:OnShowGetPath() end;
	objSwf.getPath.rollOut = function() TipsManager:Hide(); end;

	objSwf.sure_btn.click = function() self:OnSureClick() end;

	objSwf.isBind.click = function() self:OnClickBind()end;
	objSwf.noBind.click = function() self:OnClickBind()end;

	objSwf.rule_btn.rollOver = function() self:RuleOver() end
	objSwf.rule_btn.rollOut = function() TipsManager:Hide(); end
end;

function UIEquipGroupChange:RuleOver()
	TipsManager:ShowBtnTips(StrConfig["equipgroup009"],TipsConsts.Dir_RightDown);
end;

function UIEquipGroupChange:OnClickBind()
	self:SetCailiaoNum();
end;

function UIEquipGroupChange:GetBind()
	local objSwf = self.objSwf
	if not objSwf then return end
	local bind = objSwf.isBind.selected
	local nobind = objSwf.noBind.selected
	if not bind and nobind then
		return 0
	end
	if bind and not nobind then
		return 1
	end
	if bind and nobind then
		return 2
	end
	if not bind and not nobind then
		return nil
	end
end

function UIEquipGroupChange:PlayCompleteFpx()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.bao_fpx:gotoAndPlay(2);
	self:ShowRoleEquip()
end;

function UIEquipGroupChange:OnShow()
	self:DrawRole();
	self:ShowRoleEquip();
	self:SetCurItemData();
	self:OnClickBind(1)
	self:SetCailiaoNum()
	self:OnShowGroupDdList();
	self:ShowCaiLiaoEffect(1);
end;

function UIEquipGroupChange:OnHide() 
	local objSwf = self.objSwf;
	if not objSwf then return end;

	UIEquipGroupChange.curPos = 1;
	UIEquipGroupChange.curGroupList = {};
	UIEquipGroupChange.curIndex = 1;
	UIEquipGroupChange.oldindex = 1;

	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self:ClosePrompt()
end;

function UIEquipGroupChange:OnDelete()
	if self.objUIDraw then 
		self.objUIDraw:SetUILoader(nil);
	end;
end;

--设置材料数量
function UIEquipGroupChange:SetCailiaoNum()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local groupList = EquipUtil:GetGroupList(self.curPos);
	local groupData = groupList[self.curIndex];
	
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.curPos);
	if not item then
		objSwf.cailiao_txt.htmlText = ""
		return;
	end
	if groupData then
		local itemID, needItemNum = self:GetConsume(groupData.id)
		local Maxnum = self:GetPlayerItemNum(itemID)
		local color = "#00ff00";
		if needItemNum > Maxnum then 
			--不够
			color = "#ff0000"
		end;
		objSwf.cailiao_txt.htmlText = "<font color='".. color .."'>(".. Maxnum .. "/" .. needItemNum .. ")</font>"
	else
		objSwf.cailiao_txt.htmlText = ""
	end;
end;

function UIEquipGroupChange:GetConsume(groupId2)
	local cfg = t_equipgroup[groupId2]
	if not cfg then return end
	local itemCfg = split(cfg.itemId,',')
	return tonumber( itemCfg[1] ), tonumber( itemCfg[2] )
end

function UIEquipGroupChange:GetPlayerItemNum(itemId)
	local playerHasNum = 0
	local isBind = self:GetBind()
	if isBind == 0 then --不绑定
		playerHasNum = EquipBuildUtil:GetBindStateItemNumInBag( itemId, 0 )
	elseif isBind == 1 then --绑定
		playerHasNum = EquipBuildUtil:GetBindStateItemNumInBag( itemId, 1 )
	elseif isBind == 2 then -- 不限
		playerHasNum = BagModel:GetItemNumInBag(itemId)
	end
	return playerHasNum
end

--确认更改
function UIEquipGroupChange:OnSureClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;


	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bagVO:GetItemByPos(self.curPos);
	if not item then return; end

	local groupList = EquipUtil:GetGroupList(self.curPos);
	local groupData = groupList[self.curIndex];
	if groupData then 
		-- local cfg = t_equipgroup[groupData.id]
		-- local itemCfg = split(cfg.itemId,',')
		--EquipController:ChangEquipGroup(item:GetId(),toint(itemCfg[1]))
		local groupId2 = EquipModel:GetGroupId2(item:GetId())
		if groupId2 and groupId2 > 0 then 
			--已有套装
			FloatManager:AddNormal(StrConfig['equipgroup004']);
			return 
		end;
		local isBind = self:GetBind()
		if isBind == nil then
			FloatManager:AddNormal(StrConfig['equipgroup019'])
			return
		end
		local needItem, needNum = self:GetConsume(groupData.id)
		local playerHasNum = self:GetPlayerItemNum(needItem)
		if playerHasNum < needNum then
			FloatManager:AddNormal(StrConfig['equipgroup020'])
			return
		end
		local func = function()
			EquipController:ChangeEquipGroup2(item:GetId(),groupData.id, isBind)
			self:ClosePrompt()
		end
		if self:IsConsumeBindAndNoBind() then
			self:PromptChangeEquipGroup( func )
			return
		end
		func()
	end;
end;

local confirmUID
function UIEquipGroupChange:PromptChangeEquipGroup(callback)
	self:ClosePrompt()
	confirmUID = UIConfirm:Open( StrConfig['equipgroup023'], callback )
end

function UIEquipGroupChange:ClosePrompt()
	if confirmUID then
		UIConfirm:Close( confirmUID )
		confirmUID = nil
	end
end

function UIEquipGroupChange:IsConsumeBindAndNoBind()
	local isBind = self:GetBind()
	if isBind == 2 then
		local groupList = EquipUtil:GetGroupList(self.curPos);
		local groupData = groupList[self.curIndex];
		if groupData then
			local needItem, needNum = self:GetConsume(groupData.id)
			local bindItem = EquipBuildUtil:GetBindStateItemNumInBag(needItem, 1)
			return bindItem > 0 and bindItem < needNum and BagModel:GetItemNumInBag(needItem) >= needNum
		end
	end
	return false
end

--装备套装预览tips
function UIEquipGroupChange:OnBtnNbEquipRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.curPos < 0 then return end;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.curPos);
	if not itemTipsVO then return; end
	if itemTipsVO.id <= 0 then return end;
	local groupList = EquipUtil:GetGroupList(self.curPos);
	local groupData = groupList[self.curIndex];

	if groupData then 
		itemTipsVO.groupId2 = groupData.id
		itemTipsVO.groupId2Bind = self:GetNbEquipGroupBind()
		itemTipsVO.group2Level = 0
		local cfg = t_equipgroup[groupData.id];
		local posCfg = split(cfg.groupPos,'#');
		local bagVO = BagModel:GetBag(BagConsts.BagType_Role);


		local listVo = {};
		if itemTipsVO.groupEList then 
			listVo = itemTipsVO.groupEList;
		else
			for i,info in ipairs(posCfg) do
				local item = bagVO:GetItemByPos(toint(info));
				if item then 
					local vo = {};
					vo.pos = toint(info);
					vo.id = item:GetTid();
					vo.groupId = 0;
					table.push(listVo,vo)
				end;
			end;
		end;
		for i,info in ipairs(posCfg) do
			local cpos = toint(info);
			for ppc,ppv in ipairs(listVo) do 
				if ppv.pos == cpos then 
					ppv.groupId2 = groupData.id
					break;
				end;
			end;
		end;
		itemTipsVO.groupEList = listVo
	end;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);

end;

function UIEquipGroupChange:GetNbEquipGroupBind()
	local isBind = self:GetBind()
	if isBind == 2 then
		local groupList = EquipUtil:GetGroupList(self.curPos);
		local groupData = groupList[self.curIndex];
		if groupData then
			local needItem, needNum = self:GetConsume(groupData.id)
			local bindItem = EquipBuildUtil:GetBindStateItemNumInBag(needItem, 1)
			local unbindItem = EquipBuildUtil:GetBindStateItemNumInBag(needItem, 0)
			if bindItem == 0 and unbindItem > needNum then
				return 0
			end
			return 1
		end
		return 1
	end
	return isBind or 1
end

--装备tips
function UIEquipGroupChange:OnBtnSrcEquipRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.curPos < 0 then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.curPos);
	if not itemTipsVO then return; end
	if itemTipsVO.id <= 0 then return end;
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

--材料获取途径
function UIEquipGroupChange:OnShowGetPath()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local groupList = EquipUtil:GetGroupList(self.curPos);
	local groupData = groupList[self.curIndex];
	if groupData then 
		local cfg = t_equipgroup[groupData.id]
		if cfg then 
			TipsManager:ShowBtnTips(cfg.laiyuan,TipsConsts.Dir_RightDown)
		end;
	end;
end;

--材料tips
function UIEquipGroupChange:OnCailiaoOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local groupList = EquipUtil:GetGroupList(self.curPos);
	local groupData = groupList[self.curIndex];
	if groupData then 
		local cfg = t_equipgroup[groupData.id]
		local itemCfg = split(cfg.itemId,',')
		TipsManager:ShowItemTips(toint(itemCfg[1]));
	end;
end;

--设置当前itemUIdata
function UIEquipGroupChange:SetCurItemData()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.curPos);
	if not item then 
		objSwf.cailiao_item._visible = false;
		objSwf.getPath._visible = false;
		objSwf.btnSrcEquip._visible = false;
		objSwf.btnNbEquip._visible = false;
		return 
	end


	local vo = EquipUtil:GetEquipUIVO(self.curPos,true);
	vo.iconUrl = ResUtil:GetItemIconUrl(t_equip[item:GetTid()].icon);
	vo.qualityUrl = ResUtil:GetSlotQuality(t_equip[item:GetTid()].quality,54);
	objSwf.btnSrcEquip:setData(UIData.encode(vo));
	objSwf.btnSrcEquip._visible = true;


	

	local groupList = EquipUtil:GetGroupList(self.curPos);
	local groupData = groupList[self.curIndex];
	if groupData then 
		local cfg = t_equipgroup[groupData.id]

		vo.groupBsUrl = ResUtil:GetNewEquipGrouNameIcon(cfg.nameicon,nil,true)
		objSwf.btnNbEquip:setData(UIData.encode(vo))
		objSwf.btnNbEquip._visible = true;

		local itemCfg = split(cfg.itemId,',')
		local itemvo = RewardSlotVO:new();
		itemvo.id = toint(itemCfg[1]);
		itemvo.count = 0;
		objSwf.cailiao_item:setData(itemvo:GetUIData());
		objSwf.nameLoad.source = ResUtil:GetNewEquipGrouNameIcon(cfg.nameicon,true) 
		objSwf.cailiao_item._visible = true;
		objSwf.getPath._visible = true;
	else
		objSwf.cailiao_item._visible = false;
		objSwf.cailiao_item:setData({});
		objSwf.btnNbEquip:setData({})
		objSwf.nameLoad.source = ""
		objSwf.getPath._visible = true;
	end;


end;

--显示套装list
function UIEquipGroupChange:OnShowGroupDdList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local GroupList = EquipUtil:GetGroupList(self.curPos);
	objSwf.nogroup_mc._visible = false;
	objSwf.nameLoad._visible = true;
	if #GroupList == 0 then 
		objSwf.nogroup_mc._visible = true;
		objSwf.nameLoad._visible = false;
	end;
end;

function UIEquipGroupChange:ShowCaiLiaoEffect(index)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	for i=1,6 do
		objSwf["cailiaoEffectback"..i]._visible = false;
		objSwf["cailiaoEffectup"..i]._visible = false;
	end
	if not index then
		if self.oldindex <= self.cailiaomax then
			if self.curPos > 6 then
				objSwf["cailiaoEffectback"..(self.cailiaomax+self.curIndex)]._visible = true;
				objSwf["cailiaoEffectup"..(self.cailiaomax+self.curIndex)]._visible = true;
				self.oldindex = self.cailiaomax+self.curIndex;
			end
		else
			if self.curPos <= 6 then
				objSwf["cailiaoEffectback"..self.curIndex]._visible = true;
				objSwf["cailiaoEffectup"..self.curIndex]._visible = true;
				self.oldindex = self.curIndex;
			end
		end
	else
		objSwf["cailiaoEffectback"..index]._visible = true;
		objSwf["cailiaoEffectup"..index]._visible = true;
	end
end

function UIEquipGroupChange:OnClickTool(index)
	local curindex = index;
	if index > self.cailiaomax then
		curindex = index - self.cailiaomax;
	end
	self.curIndex = curindex;
	self.oldindex = index;
	
	if self.curPos <= 6 and index > 3 then
		FloatManager:AddNormal( StrConfig["equipgroup024"]);
		return;
	end
	if self.curPos > 6 and index < 3 then
		FloatManager:AddNormal( StrConfig["equipgroup025"]);
		return;
	end
	
	self:SetCurItemData()	
	self:SetCailiaoNum();
	self:ShowCaiLiaoEffect(index);
end

--显示玩家装备
function UIEquipGroupChange:ShowRoleEquip()
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
	self:ShowCaiLiaoEffect(index);
end

--玩家装备click
function UIEquipGroupChange:OnRoleEquipClick(e)
	local pos = e.item.pos;
	if not pos then return end;
	if self.curPos == pos then 
		return 
	end;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return end
	self.curPos = pos;
	self:SetCurItemData();
	self:SetCailiaoNum();
	self:OnShowGroupDdList();
	self:ShowCaiLiaoEffect();
end;

--玩家装备tips
function UIEquipGroupChange:OnRoleEquipRollOver(e)
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
function UIEquipGroupChange:DrawRole()
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
		self.objUIDraw = UIDraw:new("equipGroupChange", self.objAvatar, uiLoader,
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

--------------------------Notification
function UIEquipGroupChange:ListNotificationInterests()
	return {NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.BagUpdate,
			};
end

function UIEquipGroupChange:HandleNotification(name,body)
	if not self.bShowState then return; end
	if not self.objSwf then return; end

	if name==NotifyConsts.BagAdd or name==NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		if body.type==BagConsts.BagType_Role  then

			--and body.pos==self.currPos
			self:ShowRoleEquip();
			self:SetCurItemData();
		
		end
		self:SetCailiaoNum();
	end;
end;
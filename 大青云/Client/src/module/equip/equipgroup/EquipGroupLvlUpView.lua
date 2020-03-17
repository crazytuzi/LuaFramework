--[[
套装升级
haohu
2015年12月1日16:47:04
]]

_G.UIEquipGroupLvlUp = BaseUI:new("UIEquipGroupLvlUp")

UIEquipGroupLvlUp.curPos = nil
UIEquipGroupLvlUp.objAvatar = nil
UIEquipGroupLvlUp.objUIDraw = nil
UIEquipGroupLvlUp.meshDir = nil

function UIEquipGroupLvlUp:Create()
	self:AddSWF("equipGroupLvlUp.swf", true, nil)
end

function UIEquipGroupLvlUp:OnLoaded( objSwf )
	objSwf.roleLoader.hitTestDisable = true;
	objSwf.txtEquipName1.autoSize = "center"
	objSwf.txtEquipName2.autoSize = "center"
	objSwf.btnLevelUp.label = StrConfig['equipgroup013']
	objSwf.btnTujing.htmlLabel = StrConfig['equipgroup014']

	objSwf.list.itemClick = function(e) self:OnRoleEquipClick(e); end
	objSwf.list.itemRollOver = function(e) self:OnRoleEquipRollOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.btnLevelUp.click = function() self:OnBtnLevelUpClick() end

	objSwf.itemConsume.rollOver = function() self:OnCailiaoOver()end;
	objSwf.itemConsume.rollOut = function() TipsManager:Hide();end;

	objSwf.equip1.rollOver = function() self:OnBtnEquip1RollOver(); end
	objSwf.equip1.rollOut = function() TipsManager:Hide(); end

	objSwf.equip2.rollOver = function() self:OnBtnEquip2RollOver(); end
	objSwf.equip2.rollOut = function() TipsManager:Hide(); end

	objSwf.btnTujing.rollOver = function() self:OnTujingOver()end;
	objSwf.btnTujing.rollOut = function() TipsManager:Hide();end;

	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver()end;
	objSwf.btnRule.rollOut = function() TipsManager:Hide();end;

	objSwf.chkboxBind.click = function() self:OnBindChoose() end
	objSwf.chkboxNoBind.click = function() self:OnBindChoose() end
end

function UIEquipGroupLvlUp:OnShow()
	self:InitData();
	self:ShowRoleEquip()
	self:ShowRole()
	self:ShowBind()
	self:ShowLvlUp()
	self:UpdateShow();
end

function UIEquipGroupLvlUp:InitData()
	self.groupId = nil;
end

function UIEquipGroupLvlUp:ShowLvlUp()
	self:ShowEquipLvlUp()
	self:ShowConsume()
end

function UIEquipGroupLvlUp:OnHide()
	self.curPos = nil
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self:ClosePrompt()
end

function UIEquipGroupLvlUp:OnDelete()
	if self.objUIDraw then 
		self.objUIDraw:SetUILoader(nil)
	end
end

--显示玩家装备
function UIEquipGroupLvlUp:ShowRoleEquip()
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

function UIEquipGroupLvlUp:PlayCompleteFpx()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.bao_fpx:gotoAndPlay(2);
	objSwf.upsuc_fpx:gotoAndPlay(2);
end;

--玩家装备click
function UIEquipGroupLvlUp:OnRoleEquipClick(e)
	local pos = e.item.pos;
	if not pos then return end;
	if pos == self.curPos then
		return
	end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return end
	local groupId2 = EquipModel:GetGroupId2( item:GetId() )
	if groupId2 <= 0 then
		FloatManager:AddNormal(StrConfig['equipgroup016'])
		return
	end
	self.curPos = pos
	self:ShowLvlUp()
end;

--玩家装备tips
function UIEquipGroupLvlUp:OnRoleEquipRollOver(e)
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

function UIEquipGroupLvlUp:ShowRole()
	local objSwf = self.objSwf
	if not objSwf then return end
	local uiLoader = objSwf.roleLoader;

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
		self.objUIDraw = UIDraw:new("equipGroupLvlUp", self.objAvatar, uiLoader,
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

function UIEquipGroupLvlUp:ShowEquipLvlUp()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.equip1._visible = false
	objSwf.equip2._visible = false
	objSwf.txtEquipName1._visible = false
	objSwf.txtEquipName2._visible = false
	objSwf.lvlLoader1._visible = false
	objSwf.lvlLoader2._visible = false
	local equipId = self:GetCurrentEquipId()
	if not equipId then return end

	local bagVO = BagModel:GetBag(BagConsts.BagType_Role)
	if not bagVO then return; end
	local item = bagVO:GetItemById(equipId)
	if not item then
		return
	end
	local vo = EquipUtil:GetEquipUIVO( self.curPos, true )
	local equipCfg = t_equip[item:GetTid()]
	if not equipCfg then return end
	vo.iconUrl = ResUtil:GetItemIconUrl( equipCfg.icon, "54" )
	vo.qualityUrl = ResUtil:GetSlotQuality( equipCfg.quality, 54 )
	local itemUIData = UIData.encode(vo)
	objSwf.equip1:setData( itemUIData )
	objSwf.equip1._visible = true
	local groupId2, groupLevel = self:GetGroupInfo()
	objSwf.txtEquipName1.htmlText = self:GroupNameLabel( groupId2, self.curPos, groupLevel )
	objSwf.txtEquipName1._visible = true
	objSwf.lvlLoader1.num = groupLevel
	objSwf.lvlLoader1._visible = true
	--
	self:UpdateShow()
	--
	local maxLevel = self:GetMaxLevel(groupId2)
	if groupLevel >= maxLevel then return end
	if groupId2 and groupId2 > 0 then
		local groupLevel2 = groupLevel + 1
		objSwf.equip2:setData( itemUIData )
		objSwf.equip2._visible = true;
		objSwf.txtEquipName2.htmlText = self:GroupNameLabel( groupId2, self.curPos, groupLevel2 )
		objSwf.txtEquipName2._visible = true
		objSwf.lvlLoader2.num = groupLevel2
		objSwf.lvlLoader2._visible = true
	end
end

function UIEquipGroupLvlUp:GroupNameLabel( groupId, pos, groupLevel )
	local str = ""
	local cfg = t_equipgroup[groupId]
	if cfg then
		str = str .. string.format( "<img vspace='-8' src='%s'/>", ResUtil:GetNewEquipGrouNameIcon(cfg.nameicon) )
		str = str .. string.format( "<font color='#FF0000'>LV.%s </font>", groupLevel )
		local posCfg = self:GetGroupPosCfg(groupId, pos)
		if posCfg then
			local attrInfo = AttrParseUtil:Parse(posCfg.attr)
			if #attrInfo > 0 then
				local attrName = enAttrTypeName[ attrInfo[1].type ] or "missing!"
				local groupLvlCfg = self:GetGroupLevelCfg( groupId, groupLevel )
				local poseattr = groupLvlCfg and groupLvlCfg.poseattr * 0.01 or 0
				local attrValue = math.floor( attrInfo[1].val * (1 + poseattr) )
				str = str .. string.format( "<font color='#FF0000'>%s +%s </font>", attrName, attrValue )
			end
		end
	end
	return str
end

function UIEquipGroupLvlUp:ShowConsume()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.itemConsume._visible = false
	objSwf.btnTujing._visible = false
	objSwf.txtNum._visible = false
	local itemId, num = self:GetCurrConsume()
	if not itemId then return end
	local slotVO = RewardSlotVO:new();
	slotVO.id = itemId
	slotVO.count = 0
	objSwf.itemConsume:setData( slotVO:GetUIData() )
	local playerHasNum = self:GetPlayerItemNum(itemId)
	local color = playerHasNum < num and "#FF0000" or "#00FF00"
	objSwf.txtNum.htmlText = string.format( "<font color='%s'>(%s/%s)</font>", color, playerHasNum, num )
	objSwf.itemConsume._visible = true
	objSwf.btnTujing._visible = true
	objSwf.txtNum._visible = true
end

function UIEquipGroupLvlUp:GetPlayerItemNum(itemId)
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

function UIEquipGroupLvlUp:GetGroupInfo()
	local equipId = self:GetCurrentEquipId()
	if not equipId then return end
	local equipInfo = EquipModel:GetEquipInfo(equipId)
	if not equipInfo then return end
	return equipInfo.groupId2, equipInfo.group2Level
end

function UIEquipGroupLvlUp:GetCurrConsume()
	local groupId, groupLevel = self:GetGroupInfo()
	if not groupId or not groupLevel then
		return
	end
	local maxLevel = self:GetMaxLevel(groupId)
	if groupId <= 0 or groupLevel + 1 > maxLevel then
		return
	end
	return self:GetLvlUpConsume(groupId, groupLevel + 1)
end

function UIEquipGroupLvlUp:GetMaxLevel(groupId)
	local max = 0
	for _, cfg in pairs(t_equipgrouphuizhang) do
		if cfg.groupid == groupId then
			max = math.max( max, cfg.level )
		end
	end
	return max
end

-- 套装groupId升级到groupLevel所需的消耗
function UIEquipGroupLvlUp:GetLvlUpConsume(groupId, groupLevel)
	local cfg = self:GetGroupLevelCfg(groupId, groupLevel)
	if not cfg then return end
	local info = split(cfg.item,',')
	return tonumber(info[1]), tonumber(info[2])
end

function UIEquipGroupLvlUp:GetGroupLevelCfg(groupId, groupLevel)
	return EquipUtil:GetGroupLevelCfg(groupId, groupLevel)
end

function UIEquipGroupLvlUp:GetGroupPosCfg(groupId, pos)
	return EquipUtil:GetGroupPosCfg(groupId, pos)
end

function UIEquipGroupLvlUp:ShowBind()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.chkboxBind.selected = true
	objSwf.chkboxNoBind.selected = true
end

function UIEquipGroupLvlUp:GetBind()
	local objSwf = self.objSwf
	if not objSwf then return end
	local bind = objSwf.chkboxBind.selected
	local nobind = objSwf.chkboxNoBind.selected
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

function UIEquipGroupLvlUp:GetCurrentEquipId()
	if not self.curPos then return end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bagVO:GetItemByPos(self.curPos);
	if not item then return; end
	return item:GetId()
end

function UIEquipGroupLvlUp:OnCailiaoOver()
	local itemId = self:GetCurrConsume()
	TipsManager:ShowItemTips( itemId )
end

function UIEquipGroupLvlUp:ShowEquipTips(groupLevel)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if not self.curPos then return end
	if self.curPos < 0 then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.curPos);
	if not itemTipsVO then return; end
	if itemTipsVO.id <= 0 then return end;
	itemTipsVO.isInBag = false
	if groupLevel > 0 then
		itemTipsVO.groupId2Bind = 1
	end
	itemTipsVO.groupId2Level = groupLevel
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end

function UIEquipGroupLvlUp:OnBtnEquip1RollOver()
	local groupId, groupLevel = self:GetGroupInfo()
	if not groupId or not groupLevel then
		return
	end
	local maxLevel = self:GetMaxLevel(groupId)
	if groupId <= 0 or groupLevel > maxLevel then
		return
	end
	self:ShowEquipTips(groupLevel)
end
function UIEquipGroupLvlUp:OnBtnEquip2RollOver()
	local groupId, groupLevel = self:GetGroupInfo()
	if not groupId or not groupLevel then
		return
	end
	local maxLevel = self:GetMaxLevel(groupId)
	if groupId <= 0 or groupLevel + 1 > maxLevel then
		return
	end
	self:ShowEquipTips(groupLevel + 1)
end

function UIEquipGroupLvlUp:OnBtnRuleOver()
	TipsManager:ShowBtnTips(StrConfig["equipgroup011"],TipsConsts.Dir_RightDown);
end

function UIEquipGroupLvlUp:OnTujingOver()
	local objSwf = self.objSwf
	if not objSwf then return end
	local groupId, groupLevel = self:GetGroupInfo()
	local cfg = t_equipgroup[groupId]
	if not cfg then return end
	TipsManager:ShowBtnTips(cfg.laiyuan,TipsConsts.Dir_RightDown)
end

function UIEquipGroupLvlUp:OnBindChoose()
	self:ShowConsume()
end

local confirmUID
function UIEquipGroupLvlUp:PromptLvlUp(callback)
	self:ClosePrompt()
	confirmUID = UIConfirm:Open( StrConfig['equipgroup022'], callback )
end

function UIEquipGroupLvlUp:ClosePrompt()
	if confirmUID then
		UIConfirm:Close( confirmUID )
		confirmUID = nil
	end
end

function UIEquipGroupLvlUp:OnBtnLevelUpClick()
	self:CheckLevelUp()
end

function UIEquipGroupLvlUp:CheckLevelUp()
	local equipId = self:GetCurrentEquipId()
	if not equipId then
		FloatManager:AddNormal(StrConfig['equipgroup017'])
		return
	end
	local groupId, groupLevel = self:GetGroupInfo()
	local maxLevel = self:GetMaxLevel(groupId)
	if groupLevel >= maxLevel then
		FloatManager:AddNormal(StrConfig['equipgroup018'])
		return
	end
	local isBind = self:GetBind()
	if isBind == nil then
		FloatManager:AddNormal(StrConfig['equipgroup019'])
		return
	end
	local itemId, num = self:GetCurrConsume()
	if not itemId then return end
	local playerHasNum = self:GetPlayerItemNum(itemId)
	if playerHasNum < num then
		FloatManager:AddNormal(StrConfig['equipgroup020'])
		return
	end
	local func = function()
		EquipController:ReqEquipGroupLevelUp(equipId, isBind)
		self:ClosePrompt()
	end
	local _, nowIsBind = EquipModel:GetGroupId2(equipId)
	if nowIsBind == 0 then
		self:PromptLvlUp( func )
		return
	end
	func()
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIEquipGroupLvlUp:ListNotificationInterests()
	return {
		NotifyConsts.EquipGroupLevel,
		NotifyConsts.BagItemNumChange,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
	};
end

--处理消息
function UIEquipGroupLvlUp:HandleNotification(name, body)
	if name == NotifyConsts.EquipGroupLevel then
		self:ShowLvlUp()
	elseif name == NotifyConsts.BagItemNumChange then
		local itemId = self:GetCurrConsume()
		if itemId == body.id then
			self:ShowConsume()
		end
	elseif name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Role then
			self:ShowRoleEquip()
		end
	end
end











function UIEquipGroupLvlUp:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local groupId, _ = self:GetGroupInfo()
	if self.groupId ~= groupId then
		self.groupId = groupId
		objSwf.textArea.htmlText = self:GetHtml()
	else
		objSwf.textArea.htmlText = self:GetHtml()
	end
end

--[==[
function UIEquipGroupLvlUp:GetHtml()
	local str = ""
	local groupId = self.groupId
	if groupId then
		local groupCfg = t_equipgroup[groupId]
		if groupCfg then
			local quaColor = TipsConsts:GetItemQualityColor(groupCfg.quality)
			local groupLevel = UIEquipGroupLvlUp:GetMaxLevel(groupId)
			--
			str = str .."<textformat leading='-20' leftmargin='6'><p>";
			str = str .. "<img width='78' height='26' src='" .. ResUtil:GetNewEquipGrouNameIcon(groupCfg.nameicon) .. "'/>";
			str = str .. "</p></textformat>";
			str = str .. "<textformat leading='-15' leftmargin='84'><p>";
			str = str .. string.format( "<font color='#00FF00' size='16'>%sLV.%s</font>", StrConfig['equipgroup021'], groupLevel )
			str = str .. "</p></textformat><br/>";
			str = str .. self:GetVGap(5);
			local skiIndex = 0;
			for i=2,11 do
				local attrCfg = groupCfg["attr"..i];
				if attrCfg ~= "" then
					str = str .. "<textformat leading='7' leftmargin='11'><p>";
					str = str .. self:GetHtmlText(string.format("(%s)%s <font color='#00FF00'>LV.%s</font>",i,groupCfg.name, groupLevel),quaColor,TipsConsts.Default_Size,false);
					str = str .. "</p></textformat>";
					local attrStr = "";
					local attrlist = AttrParseUtil:Parse(attrCfg);
					local attrName, attrValue
					local groupLvlCfg = EquipUtil:GetGroupLevelCfg(groupId, groupLevel)
					local gruopattr = groupLvlCfg and groupLvlCfg.gruopattr * 0.01 or 0
					---[[
					for i=1,#attrlist do
						attrName = enAttrTypeName[attrlist[i].type]
						attrValue = getAtrrShowVal( attrlist[i].type, math.floor( attrlist[i].val * (1 + gruopattr) ) )
						attrStr = attrStr .. attrName .. " +" .. attrValue .. "   ";
					end
					--]]
					attrStr = attrStr .. "<textformat leading='-30' leftmargin='15'><p>";
					attrStr = attrStr .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
					attrStr = attrStr .. "</p></textformat>";
					--技能描述
					skiIndex = skiIndex + 1;
					if groupLvlCfg then
						local skillStr = groupLvlCfg.skill
						local list1 = split(skillStr,'#');
						local skillId = tonumber( list1[skiIndex] )
						if skillId then
							attrStr = attrStr .. "<br/>"
							attrStr = attrStr .. SkillTipsUtil:GetSkillEffectStr(skillId)
						end
					else
						local SkiDescCfg = groupCfg["skill"..skiIndex];
						if SkiDescCfg then 
							local list = split(SkiDescCfg,'#');
							for i,ino in ipairs(list) do 
								local skillEffStr = SkillTipsUtil:GetSkillEffectStr(tonumber(ino));
								attrStr = attrStr .. "<br/>"
								attrStr = attrStr .. skillEffStr
							end;
						end
					end
					attrStr = self:GetHtmlText(attrStr,quaColor,TipsConsts.Default_Size,true);
					str = str .. "<textformat leading='-18' leftmargin='15'><p>";
					str = str .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
					str = str .. "</p></textformat>";
					str = str .. "<textformat leading='7' leftmargin='35'><p>" .. attrStr .. "</p></textformat>";
				end
			end
			return str;
		end
	else
		str = ""
	end
	return str
end
--]==]

--获取一个竖向的间隙
function UIEquipGroupLvlUp:GetVGap(gap)
	return "<p><img height='" .. gap .. "' align='baseline' vspace='0'/></p>";
end

--获取Html文本
--@param text 显示的内容
--@param color 字体颜色
--@param size 字号
--@param withBr 是否换行,默认true
--@param bold 	是否加粗,默认false
function UIEquipGroupLvlUp:GetHtmlText(text,color,size,withBr,bold)
	if not color then color = TipsConsts.Default_Color; end
	if not size then size = TipsConsts.Default_Size; end
	if withBr==nil then withBr = true; end
	if bold==nil then bold = false; end
	local str = "<font color='" .. color .."' size='" .. size .. "'>";
	if bold then
		str = str .. "<b>" .. text .. "</b>";
	else
		str = str .. text;
	end
	str = str .. "</font>";
	if withBr then
		str = str .. "<br/>";
	end
	return str;
end

-- 预览所有等级
---[=[
function UIEquipGroupLvlUp:GetHtml()
	local str = ""
	local groupId = self.groupId
	if groupId then
		local groupCfg = t_equipgroup[groupId]
		if groupCfg then
			local quaColor = TipsConsts:GetItemQualityColor(groupCfg.quality)
			for groupLevel = 0, UIEquipGroupLvlUp:GetMaxLevel(groupId) do
				--
				str = str .."<textformat leading='-20' leftmargin='6'><p>";
				str = str .. "<img width='78' height='26' src='" .. ResUtil:GetNewEquipGrouNameIcon(groupCfg.nameicon) .. "'/>";
				str = str .. "</p></textformat>";
				str = str .. "<textformat leading='-15' leftmargin='84'><p>";
				str = str .. string.format( "<font color='#00FF00' size='16'>%sLV.%s</font>", StrConfig['equipgroup021'], groupLevel )
				str = str .. "</p></textformat><br/>";
				str = str .. self:GetVGap(5);
				local skiIndex = 0;
				for i=2,11 do
					local attrCfg = groupCfg["attr"..i];
					if attrCfg ~= "" then
						str = str .. "<textformat leading='7' leftmargin='11'><p>";
						str = str .. self:GetHtmlText(string.format("(%s)%s <font color='#00FF00'>LV.%s</font>",i,groupCfg.name, groupLevel),quaColor,TipsConsts.Default_Size,false);
						str = str .. "</p></textformat>";
						local attrStr = "";
						local attrlist = AttrParseUtil:Parse(attrCfg);
						local attrName, attrValue
						local groupLvlCfg = EquipUtil:GetGroupLevelCfg(groupId, groupLevel)
						local gruopattr = groupLvlCfg and groupLvlCfg.gruopattr * 0.01 or 0
						---[[
						for i=1,#attrlist do
							attrName = enAttrTypeName[attrlist[i].type]
							attrValue = getAtrrShowVal( attrlist[i].type, math.floor( attrlist[i].val * (1 + gruopattr) ) )
							attrStr = attrStr .. attrName .. " +" .. attrValue .. "   ";
						end
						--]]
						--[[
						for i=1,#attrlist do
							local leftmargin = 30 + ((i + 1) % 2) * 21
							-- local leading = (i == #attrlist) and 10 or -32
							local leading = ((i + 1) % 2) * -45
							attrName = enAttrTypeName[attrlist[i].type]
							attrValue = getAtrrShowVal( attrlist[i].type, math.floor( attrlist[i].val * (1 + gruopattr) ) )
							attrStr = attrStr .. string.format( "<textformat leading='%s' leftmargin='%s'><p>%s +%s</p></textformat>",leading,
								leftmargin,	attrName, attrValue )
						end
						--]]
						attrStr = attrStr .. "<textformat leading='-30' leftmargin='15'><p>";
						attrStr = attrStr .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
						attrStr = attrStr .. "</p></textformat>";
						--技能描述
						skiIndex = skiIndex + 1;
						if groupLevel > 0 and groupLvlCfg then
							local skillStr = groupLvlCfg.skill
							local list1 = split(skillStr,'#');
							local skillId = tonumber( list1[skiIndex] )
							if skillId then
								attrStr = attrStr .. "<br/>"
								attrStr = attrStr .. SkillTipsUtil:GetSkillEffectStr(toint(skillId))
							end
						else
							local SkiDescCfg = groupCfg["skill"..skiIndex];
							if SkiDescCfg then 
								local list = split(SkiDescCfg,'#');
								for i,ino in ipairs(list) do 
									local skillEffStr = SkillTipsUtil:GetSkillEffectStr(toint(ino));
									attrStr = attrStr .. "<br/>"
									attrStr = attrStr .. skillEffStr
								end;
							end
						end
						attrStr = self:GetHtmlText(attrStr,quaColor,TipsConsts.Default_Size,true);
						-- str = str .. self:GetVGap(2);
						str = str .. "<textformat leading='-18' leftmargin='15'><p>";
						str = str .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
						str = str .. "</p></textformat>";
						str = str .. "<textformat leading='7' leftmargin='35'><p>" .. attrStr .. "</p></textformat>";
					end
				end
				-- str = str .. self:GetLine()
				str = str .. self:GetVGap(2);
			end
			return str;
		end
	else
		str = ""
	end
	return str
end

--]=]
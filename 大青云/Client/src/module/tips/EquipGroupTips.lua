--[[
套装tips
wangshuai
]]

_G.EquipGroupTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_EquipGroup,EquipGroupTips);

EquipGroupTips.tipsVO = nil;

function EquipGroupTips:Parse(tipsInfo)
	self.tipsVO = tipsInfo;
	--
	self.str = "";
	--新套装单件属性
	local groupAtb = self:GetGroupBaseAttr();
	if groupAtb ~= "" then 
		self.str = self.str .. self:GetVGap(5);
		self.str = self.str .. groupAtb
	end;

	local group = self:GetGroupInfo2();
	if group ~= "" then 
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. self:GetVGap(5);
		self.str = self.str .. group;
	end;
end

--获取是否显示Icon
function EquipGroupTips:GetShowIcon()
	return false;
end

function EquipGroupTips:GetWidth()
	return 421;
end

--新套装属性，套装单个加成
function EquipGroupTips:GetGroupBaseAttr()
	local str = "";
	if not self.tipsVO.groupId2 then 
		return str;
	end;
	local groupCfg = t_equipgroup[self.tipsVO.groupId2];
	local atbCfg = {};
	local posCfg = self.tipsVO.groupId2 * 100000 + self.tipsVO.pos;
	local lvlUpAttr = 0
	if t_equipgrouppos[posCfg] then 
		local cfg = t_equipgrouppos[posCfg];
		local att = split(cfg.attr,",")
		local groupLvlCfg = EquipUtil:GetGroupLevelCfg( self.tipsVO.groupId2, self.tipsVO.lvl )
		local poseattr = groupLvlCfg and groupLvlCfg.poseattr * 0.01  or 0
		atbCfg.type = AttrParseUtil.AttMap[att[1]];
		-- atbCfg.val  = toint( att[2] * (1 + poseattr), -1 )
		atbCfg.val  = toint( att[2], -1 )
		lvlUpAttr  = toint( att[2] * poseattr, -1 )
	else
		return str;
	end;
	if not groupCfg then return str; end
	local quaColor = TipsConsts:GetItemQualityColor(groupCfg.quality)

	-- str = str .. "<textformat leading='-21' leftmargin='6'><p>";
	-- str = str .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
	-- str = str .. "</p></textformat>";
	--
	str = str .."<textformat leading='-20' leftmargin='6'><p>";
	str = str .. "<img width='78' height='26' src='" .. ResUtil:GetNewEquipGrouNameIcon(groupCfg.nameicon,nil,nil,true) .. "'/>";
	str = str .. "</p></textformat>";

	--
	local lead = 4;
	if self.tipsVO.groupId2Bind then
		lead = -14
	end;
	str = str ..  "<textformat leading='"..lead.."' leftmargin='100'><p>";
	local bassAttrStr = self:GetHtmlText(enAttrTypeName[atbCfg.type] .. "+" .. getAtrrShowVal(atbCfg.type,atbCfg.val),quaColor,TipsConsts.Default_Size,false)
	local lvlUpAttrStr = lvlUpAttr > 0 and self:GetHtmlText(StrConfig['tips1342']..lvlUpAttr,quaColor,TipsConsts.Default_Size,false) or ""
	if not self.tipsVO.hideLvl then  
		str = str ..  string.format( "lv.%s  %s %s", self.tipsVO.lvl, bassAttrStr, lvlUpAttrStr )
	else
		str = str ..  string.format( "       %s %s", bassAttrStr, lvlUpAttrStr )
	end
	str = str .. "</p></textformat>";

	--绑定状态
	if self.tipsVO.groupId2Bind then 
		str = str ..  "<textformat leading='4' leftmargin='342'><p>";
		if self.tipsVO.groupId2Bind == 0 then 
			str = str ..  self:GetHtmlText(StrConfig['tips1330'],quaColor,TipsConsts.Default_Size,false);
		elseif self.tipsVO.groupId2Bind == 1 then 
			str = str ..  self:GetHtmlText(StrConfig['tips1331'],quaColor,TipsConsts.Default_Size,false);
		end
		str = str .. "</p></textformat>";
	end;
	str = self:GetHtmlText(str,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	return str;
end



--套装2信息
function EquipGroupTips:GetGroupInfo2()
	local str = "";
	if self.tipsVO.groupId2 == 0 then
		return str;
	end
	local groupCfg = t_equipgroup[self.tipsVO.groupId2];
	if not groupCfg then return str; end
	local quaColor = TipsConsts:GetItemQualityColor(groupCfg.quality)
	local totalNum = 0;--套装总数量
	local num = 0;--拥有套装数量
	local group2Level = -1; --全身套装2等级
	local equipType = split(groupCfg.groupPos,'#')
	for eq,epo in ipairs(equipType) do
		totalNum = totalNum + 1;
	end;
	local hasEquipList = {};
	for i,vo in ipairs(self.tipsVO.groupEList) do
		if vo.groupId2 == self.tipsVO.groupId2 then
			num = num + 1;
			-- local equipCfg = t_equip[vo.id];
			-- if equipCfg then
				hasEquipList[vo.pos] = vo.lvl or 0;
			--end
		end
	end
	if num >= totalNum then
		for _, lvl in pairs(hasEquipList) do
			if group2Level < 0 then
				group2Level = lvl
			else
				group2Level = math.min(group2Level, lvl)
			end
		end
	else
		group2Level = 0;
	end
	--
	str = str .."<textformat leading='-20' leftmargin='6'><p>";
	str = str .. "<img width='78' height='26' src='" .. ResUtil:GetNewEquipGrouNameIcon(groupCfg.nameicon) .. "'/>";
	str = str .. "</p></textformat>";
	str = str .. "<textformat leading='-15' leftmargin='84'><p>"; 
	str = str .. self:GetHtmlText(string.format(" Lv.%s （%s/%s）",group2Level,num,totalNum),quaColor,TipsConsts.Default_Size);
	str = str .. "</p></textformat>";
	str = str .. self:GetVGap(7);
	for pa,ca in ipairs(equipType) do 
		local ca = toint(ca)
		if hasEquipList[ca] then
			str = str .. "  " .. self:GetHtmlText(BagConsts:GetEquipName(ca),quaColor,TipsConsts.Default_Size,false);
		else
			str = str .. "  " .. self:GetHtmlText(BagConsts:GetEquipName(ca),"#5a5a5a",TipsConsts.Default_Size,false);
		end
		if ca == 6 then
			str = str .. "<br/>";
		else
			str = str .. "    ";
		end
	end;
	str = str .. self:GetVGap(11);
	local quaColor = TipsConsts:GetItemQualityColor(groupCfg.quality)
	local skiIndex = 0;
	for i=2,11 do
		local attrCfg = groupCfg["attr"..i];
		if attrCfg ~= "" then
			str = str .. self:GetVGap(3);
			str = str .. "<textformat leading='7' leftmargin='11'><p>";
			if num >= i then
				str = str .. self:GetHtmlText(string.format("(%s)%s",i,groupCfg.name),quaColor,TipsConsts.Default_Size,false);
			else
				str = str .. self:GetHtmlText(string.format("(%s)%s",i,groupCfg.name),"#5a5a5a",TipsConsts.Default_Size,false);
			end
			str = str .. "</p></textformat>";
			local attrStr = "";
			local attrlist = AttrParseUtil:Parse(attrCfg);
			local attrName, attrValue
			local groupLvlCfg = EquipUtil:GetGroupLevelCfg(self.tipsVO.groupId2, group2Level)
			local gruopattr = groupLvlCfg and groupLvlCfg.gruopattr * 0.01 or 0
			--
			for i=1,#attrlist do
				attrName = enAttrTypeName[attrlist[i].type]
				attrValue = getAtrrShowVal( attrlist[i].type, math.floor( attrlist[i].val * (1 + gruopattr) ) )
				attrStr = attrStr .. attrName .. " +" .. attrValue .. "   ";
			end
			--
			attrStr = attrStr .. "<textformat leading='-30' leftmargin='15'><p>";
			attrStr = attrStr .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			attrStr = attrStr .. "</p></textformat>";
			--技能描述
			skiIndex = skiIndex + 1;
			if group2Level > 0 and groupLvlCfg then
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
			if num >= i then
				attrStr = self:GetHtmlText(attrStr,quaColor,TipsConsts.Default_Size,false);
			else
				attrStr = self:GetHtmlText(attrStr,"#5a5a5a",TipsConsts.Default_Size,false);
			end
			str = str .. self:GetVGap(5);
			str = str .. "<textformat leading='-18' leftmargin='15'><p>";
			str = str .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			str = str .. "</p></textformat>";
			str = str .. "<textformat leading='7' leftmargin='35'><p>" .. attrStr .. "</p></textformat>";
		end
	end
	return str;
end

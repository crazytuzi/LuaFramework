--[[
装备Tips
lizhuangzhuang
2014年8月18日11:23:48
]]

_G.EquipTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_Equip,EquipTips);

EquipTips.tipsVO = nil;

--@说明:这里属性出现的次序决定了他在tips中二级标签的位置
function EquipTips:Parse(tipsInfo)
	-- trace(tipsInfo)
	self.tipsVO = tipsInfo;
	--头标题
	self.str = "";
	-- self.str = self.str .. self:GetTitleBg();
	self.str = self.str .. self:GetTitle();    --装备最顶层名字信息
	self.str = self.str .. self:GetTitleTwo(); --五条文本属性
	self.str = self.str .. self:GetLine(5);
	--
	if self:GetModelDrawClz() then
		self.str = self.str .. self:GetVGap(self:GetModelDrawClz():GetHeight());
		self.str = self.str .. self:GetLine(10);
	end
	--基础属性
	local equipType = BagUtil:GetEquipPutBagPos(self.tipsVO.id);
	if equipType == BagConsts.BagType_Role then
		self.str = self.str .. self:GetBaseAttr();   ---获取人身上的基础属性
	else
		self.str = self.str .. self:GetBaseAttrS();
	end
	--戒指
	-- local ringStr = self:GetRingStr()
	-- if ringStr and ringStr ~= "" then
	-- 	self.str = self.str .. self:GetLine(5)
	-- 	self.str = self.str .. ringStr
	-- end
	--洗练
	local washStr = self:GetWashStr()
	if washStr and washStr ~= "" then
		self.str = self.str .. self:GetLine(5)
		self.str = self.str .. washStr
	end
	--神武
	local shenwuStr = self:GetShenWuAttr();
	if shenwuStr ~= "" then 
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. self:GetVGap(5);
		self.str = self.str .. shenwuStr
	end;
	-- --新套装单件属性
	-- local groupAtb = self:GetGroupBaseAttr();
	-- if groupAtb ~= "" then 
	-- 	self.str = self.str .. self:GetLine(5);
	-- 	self.str = self.str .. self:GetVGap(5);
	-- 	self.str = self.str .. groupAtb
	-- end;
	--
	if self.tipsVO.extraLvl > 0 then
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. self:GetExtraAttr();
	end

	--@不要看函数名字，卓越属性和新卓越属性是反的....
	--卓越属性
	local newSuperAttrStr = self:GetNewSuperAttr();
	if newSuperAttrStr ~= "" then
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. newSuperAttrStr;
	end

	--新卓越属性
	local superAttrStr = "";
	--superAttrStr = self:GetSuperAttr();   ---屏蔽新卓越属性  changer:houxudong date:2016/6/1
	if superAttrStr ~= "" then
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. superAttrStr;
	end

	-- 宝石属性
	local gemAttrStr =  self:GetGemAttr();
	if gemAttrStr ~= "" and gemAttrStr then  -- changer:hoxudong reason:nil
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. gemAttrStr;
	end
	--
	-- local groupStr2 = self:GetGroupInfo2();
	local extraGroupStr = self:GetExtraGroupInfo();
	local groupStr = self:GetGroupInfo();
	-- if extraGroupStr~="" or groupStr~="" or groupStr2 ~= "" then
	-- 	self.str = self.str .. self:GetLine(5);
	-- end
	--1旧套装
	if groupStr ~= "" then
		groupStr = self:SetLeftMargin(groupStr,11);
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. groupStr;
	end
	--2新套装
	-- if groupStr2 ~= "" then 
	-- 	groupStr2 = self:SetLeftMargin(groupStr2,11);
	-- 	self.str = self.str .. self:GetLine(5);
	-- 	self.str = self.str .. groupStr2;
	-- end;
	--神武等阶星级
	local shenWuLevelStr = self:GetShenWuLevelStr();
	if shenWuLevelStr ~= "" then 
		shenWuLevelStr = self:SetLeftMargin(shenWuLevelStr,11);
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. self:GetVGap(5);
		self.str = self.str .. shenWuLevelStr;
	end;
	--3附加套装
	if extraGroupStr ~= "" then
		extraGroupStr = self:SetLeftMargin(extraGroupStr,11);
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. self:GetVGap(5);
		self.str = self.str .. extraGroupStr;
	end

	-- self.str = self.str .. self:GetNewGroupStr()这里是新套装  大爷们做了又不要了

	--获取方式
	local fromStr = self:GetFrom();
	if fromStr ~= "" then
		fromStr = self:SetLeftMargin(fromStr,11);
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. fromStr;
	end
	--对比属性
	local compareStr = self:GetCompareInfo();
	if compareStr ~= "" then
		compareStr = self:SetLeftMargin(compareStr,11);
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. compareStr;
	end
	--debug模式下显示id
	if isDebug then
		self.str = self.str .. self:GetLine(10);
		self.str = self.str .. "<textformat leading='-22' leftmargin='6'><p>";
		self.str = self.str .. self:GetHtmlText(StrConfig["tips14"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
		self.str = self.str .. "</p></textformat>";
		self.str = self.str .."<textformat></br>".."<br></textformat>"
		self.str = self.str .. self:GetHtmlText(self.tipsVO.id);
	end
	--
	if self.tipsVO.isUnionContr == true then 
		self.str = self.str .. self:OnGetUnionContr();
	end
end

function EquipTips:GetModelDrawClz()
	return nil;
	-- if self.tipsVO.cfg.modelDraw == "" then
		-- return nil;
	-- end
	-- return EquipTipsDraw;
end

function EquipTips:GetModelDraw()
	return nil;
	-- if self.tipsVO.cfg.modelDraw == "" then
		-- return nil;
	-- end
	-- return EquipTipsDraw:new();
end

function EquipTips:GetModelDrawArgs()
	return {self.tipsVO.cfg.id};
end

function EquipTips:GetIconUrl()
	return self.tipsVO.iconUrl;
end

function EquipTips:GetShowBiao()
	if self.tipsVO.cfg.identifying == "" then return ""; end
	local t = split(self.tipsVO.cfg.identifying,"#");
	for _,s in ipairs(t) do
		if s:lead("lable") then
			return ResUtil:GetTipsBiaoShiUrl(s);
		end
	end
	return "";
end

function EquipTips:GetIconLevelUrl()
	if self.tipsVO.cfg.identifying == "" then return ""; end
	local t = split(self.tipsVO.cfg.identifying,"#");
	for _,s in ipairs(t) do
		if s:lead("num") then
			return ResUtil:GetBiaoShiUrl(s);
		end
	end
	return "";
end

function EquipTips:GetIconPos()
	local equipType = BagUtil:GetEquipPutBagPos(self.tipsVO.id);
	if equipType == BagConsts.BagType_Role then
		return {x=35,y=35};
	else
		return {x=35,y=35};
	end
end

function EquipTips:GetWidth()
	return 421;
end

function EquipTips:GetShowEquiped()
	return self.tipsVO.equiped;
end

function EquipTips:GetQualityUrl()
	return ResUtil:GetSlotQuality(self.tipsVO.cfg.quality, 54);
end

function EquipTips:GetQuality()
	return self.tipsVO.cfg.quality;
end

function EquipTips:GetTipsEffectUrl()
	-- return ResUtil:GetTipsQuality(self.tipsVO.cfg.quality);
end

function EquipTips:GetSuperStar()
	if self.tipsVO.cfg.pos > 10 then
		return 0
	end
	if self.tipsVO.cfg.quality == BagConsts.Quality_Green1 then
		return 1;
	elseif self.tipsVO.cfg.quality == BagConsts.Quality_Green2 then
		return 2;
	elseif self.tipsVO.cfg.quality == BagConsts.Quality_Green3 then
		return 3;
	end
	return 0;
end

function EquipTips:GetDebugInfo()
	if isDebug then
		return "/createitem/"..self.tipsVO.cfg.id.."/1";
	end
	return nil;
end

function EquipTips:GetTitleBg( )
	local str = "";
	str = str .. "<textformat leading='-32'><p>";  --</p>前面创建空白区域
	str = str .. "<img width='387' height='0' src='" .. ResUtil:GetTipsNameBgUrl() .. "'/>";
	str = str .. "</p></textformat>";
	return str;
end

--第一级标题
function EquipTips:GetTitle()
	local str = "";
	str = str .. self:GetVGap(13);  --居中

	local name = self.tipsVO.cfg.name;   --配置名字
	local lens = 0;
	lens = string.len(name)/2*25
	--新卓越
	if self.tipsVO.newSuperList then
		for i,vo in ipairs(self.tipsVO.newSuperList) do
			if vo.id > 0 then
				lens = string.len(name)/2*TipsConsts.BlackNew_Size +2*TipsConsts.BlackNew_Size+TipsConsts.BlackNew_Size
				name = string.format(StrConfig['tips1317']).. name;    --神的   卓越属性名字
			end
			break;
		end
	end
	local pos = self:GetWidth()/2 - lens/2
	pos = math.ceil(pos)
	str = str .. "<textformat leftmargin ='"..pos.. "'leading='0'><p>";
	

	-- --新套装名
	-- local newGroupCfg = t_equipgroup[self.tipsVO.groupId2];
	-- if newGroupCfg then 
	-- 	local quaColor = TipsConsts:GetItemQualityColor(newGroupCfg.quality)
	-- 	local newGname = self:GetHtmlText(newGroupCfg.name,quaColor,TipsConsts.TitleSize_One,false);
	-- 	name = newGname .. "lv." .. self.tipsVO.groupId2Level .. " "  .. name;
	-- else
	-- 	--套装名
	local groupCfg = t_equipgroup[self.tipsVO.groupId];
	if groupCfg then
		name = groupCfg.name .. " " .. name
	end
	-- end;

	--卓越属性
	if self.tipsVO.superVO and self.tipsVO.superVO.superNum>0 then
		local superNum = 0;
		for i=1,self.tipsVO.superVO.superNum do
			local vo = self.tipsVO.superVO.superList[i];
			if vo.id > 0 then
				superNum = superNum + 1;
			end
		end
		if superNum == 5 then
			name = name .. StrConfig["tips1318"];
		elseif superNum == 6 then
			name = name .. StrConfig["tips1319"];
		elseif superNum == 7 then
			name = name .. StrConfig["tips1320"];
		end
	end
	--炼化等级
	if self.tipsVO.refinLvl > 0 then
		name = name .. self:GetRefinNum(self.tipsVO.refinLvl);
	end
	-- if self.tipsVO.strenLvl>0 then
	-- 	name = name .."     +"..self.tipsVO.strenLvl
	-- end
	--  TipsConsts.orangeColor
	str = str .. self:GetHtmlText(name,TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality),TipsConsts.BlackNew_Size,false);
	if self.tipsVO.strenLvl > 0 then
		str = str .. "<align='right'>"..self:GetHtmlText('  +'..self.tipsVO.strenLvl,TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality),TipsConsts.BlackNew_Size,false).."</>";
	end
	str = str .."</p></textformat>"
	-- TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality)  --更具物品的品质框决定名字的颜色
	-- local equipType = BagUtil:GetEquipPutBagPos(self.tipsVO.id);
	-- if equipType == BagConsts.BagType_Role then
	-- 	str = str .. self:GetVGap(12);
	-- 	str = str .. "<textformat leftmargin='34'>";   --星星评级
	-- 	str = str .. self:GetStar(self.tipsVO.strenLvl, self.tipsVO.emptystarnum);
	-- 	str = str .. "</textformat>";
	-- end
	-- str = str .. self:GetLine(10);
	return str;
end

--获取武器职业等信息,包括icon，职业，评分等信息
--leading : 行间距
function EquipTips:GetTitleTwo()
	local str = "";
	str = str .. self:GetVGap(18);
	--
	-- 之前5个文本状态是左间距98px
	str = str .."<p><textformat leftmargin='115' leading='7'>"

	-- str = str .. "</textformat>";
	--[[
	local isEquip = self.tipsVO.equiped                             --装备状态
	if isEquip then
		str = str .. self:GetHtmlText(StrConfig['tips1350'],"#00ff00",TipsConsts.Default_Size,false);		
	else
		str = str .. self:GetHtmlText(StrConfig['tips1351'],TipsConsts.redColor,TipsConsts.Default_Size,false);	
	end
	str = str .."     "
	--]]
	-- str = str .. "<p><textformat leftmargin='88' leading='7'>";   ---阶
	local posName = UISpiritsSkillTips:GetNum(self.tipsVO.cfg.level)..StrConfig['tips1321'] .." ".. BagConsts:GetEquipName(self.tipsVO.cfg.pos);
	-- 根据装备的品质决定装备名字的颜色
	str = str .. self:GetHtmlText(posName,TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality),TipsConsts.TitleSize_Two);  --这个不要动
	str = str .. "</textformat>";
	--
	str = str .. "<textformat leftmargin='115' leading='7'>";       --绑定状态
	local bindStr = BagConsts:GetBindName(self.tipsVO.bindState);
	str = str .. self:GetHtmlText(string.format(StrConfig["tips1370"],bindStr),TipsConsts.greenColor,TipsConsts.Small_Size);
	str = str .. "</textformat>";
	--装备评分
	local zhandouli = self.tipsVO:GetFight();
	str = str .. "<textformat leftmargin='115' leading='7'>";
	str = str ..  self:GetHtmlText(string.format(StrConfig['tips1352'],zhandouli),TipsConsts.BlindColor,TipsConsts.Small_Size);
	str = str .. "</textformat>";
	--
	str = str .. "<textformat leftmargin='115' leading='7'>";
	local profStr = "";                                            --职业限制
	if self.tipsVO.profAccord then
		profStr = self:GetHtmlText(PlayerConsts:GetProfName(self.tipsVO.prof),TipsConsts.BlindColor,TipsConsts.Small_Size, false);
	else
		profStr = self:GetHtmlText(PlayerConsts:GetProfName(self.tipsVO.prof),TipsConsts.ForbidColor,TipsConsts.Small_Size, false);
	end
	str = str .. self:GetHtmlText(string.format(StrConfig["tips2"],profStr),TipsConsts.BlindColor,TipsConsts.Small_Size, false);

	local equipType = BagUtil:GetEquipPutBagPos(self.tipsVO.id);
	if equipType == BagConsts.BagType_Horse or
			equipType == BagConsts.BagType_MingYu or
			equipType == BagConsts.BagType_Armor or
			equipType == BagConsts.BagType_MagicWeapon or
			equipType == BagConsts.BagType_LingQi
		then
		str = str .. self:GetHtmlText("",TipsConsts.BlindColor,TipsConsts.Small_Size);
		str = str .. "</textformat>";
		str = str .. "<textformat leftmargin='115' leading='7'>";
		str = str .. self:GetHtmlText(string.format("%s：%s",StrConfig["tips" .. 1600 + equipType], StrConfig["tips" .. 1500 + self.tipsVO.cfg.step]),TipsConsts.BlindColor,TipsConsts.Small_Size,false);
	end
	str = str .. "</textformat></p>";
	--
	if self.tipsVO.needAttr == 0 then    ---只有一条属性         控制变态的界面布局显示   ---adder:houxudong date:2015/5/28
		str = str .. "<textformat leftmargin='115' leading='-80'>"; 
	else
		str = str .. "<textformat leftmargin='115' leading='7'>";  -- -80
	end

	--坐骑或人
	local equipType = BagUtil:GetEquipPutBagPos(self.tipsVO.id);             
	if self.tipsVO.cfg.can_use then--true为不可穿
		str = str .. self:GetHtmlText(StrConfig['tips1322']);
	else
		local levelStr = "";
		local name  = "";
		local attType = "";
		if self.tipsVO.needAttrOne == 0 then  --needLevel
			levelStr = StrConfig['tips1323'];
		else
			levelStr = self.tipsVO.needAttrOne;
			name,attType = self:CheckAttr(split(self.tipsVO.needAttrOne,'#')[1])
			levelStr = toint(split(self.tipsVO.needAttrOne,'#')[2]);
		end
		if attType >= levelStr then    ---根据条件来显示颜色
			levelStr = self:GetHtmlText(levelStr,TipsConsts.BlindColor,TipsConsts.Small_Size,false);
		else
			levelStr = self:GetHtmlText(levelStr,TipsConsts.redColor,TipsConsts.Small_Size,false);
		end
		if equipType == BagConsts.BagType_Role then
			local attrtypes = toint(split(self.tipsVO.needAttr,'#')[1]) ;
			if attrtypes == 1 then   --转生
			else
				str = str .. self:GetHtmlText(string.format(StrConfig['tips1324'],name,levelStr),TipsConsts.BlindColor,TipsConsts.Small_Size);      ---需要的境界%s
			end
		end
	end
	--
	--str = str .. "<textformat leftmargin='88' leading='-80'>";  --leftmargin='88' leading='7'
	--新加基础属性     ---adder:houxudong date:2015/5/28
	str = str .. "</textformat>";
	local attStr=""
	local num = toint(split(self.tipsVO.needAttr,'#')[2]);
	if self.tipsVO.needAttr == 0 then 
		attStr = "";
	else
		str = str .. "<textformat leftmargin='115' leading='10'>"; 
		attStr = self.tipsVO.needAttr; 
		local attrtypes = toint(split(self.tipsVO.needAttr,'#')[1]) ;
		if attrtypes == 1 then   --转生
			local num =toint(split(self.tipsVO.needAttr,'#')[2]);
			local defaultNum = toint(ZhuanZhiModel:GetLv()) or 0    --当前玩家的转生阶段
			local color = TipsConsts.BlindColor
			if num > defaultNum then
				color = TipsConsts.redColor
			else
				color = TipsConsts.BlindColor
			end
			num = self:CheckZhuanSheng(num)
			num = self:GetHtmlText(num,color,TipsConsts.Small_Size,false);
			str = str ..  self:GetHtmlText(string.format(StrConfig['tips1353'],num),TipsConsts.BlindColor,TipsConsts.Small_Size);
			str = str .. "</textformat>";
		else                     --基础属性
			local atts,attType = self:CheckAttr(split(self.tipsVO.needAttr,'#')[1])
			if attType >= num then    ---根据条件来显示颜色
				num = self:GetHtmlText(num,TipsConsts.BlindColor,TipsConsts.Small_Size,false);
			else
				num = self:GetHtmlText(num,TipsConsts.redColor,TipsConsts.Small_Size,false);
			end
			if equipType == BagConsts.BagType_Role then
				str = str ..  self:GetHtmlText(string.format(StrConfig['tips1348'],atts, num),TipsConsts.BlindColor);  --需要的属性值
			end
			str = str .. "</textformat>";
		end
		
	end

	str = str .."<textformat leftmargin='225' leading='-80'><p></p></textformat>";  

	if self.tipsVO.cfg.quality > 4 then--装备战力，品质为5,6，7的装备tips换大的装备战力图片
		str = str .. "<textformat leftmargin='250' leading='2'><p><img width='113' height='34' src='" .. ResUtil:GetTipsZhandouliUrlMax() .. "'/></p></textformat>";
	else	
		str = str .. "<textformat leftmargin='250' leading='2'><p><img width='71' height='25' src='" .. ResUtil:GetTipsZhandouliUrlSmall() .. "'/></p></textformat>";
	end

	--装备评分战斗力
	local BaseScore = self.tipsVO:GetTotalFight()
	if BaseScore < 99999 then
		str = str .. "<textformat leftmargin='260' leading='7'><p>".. self:GetBaseFightNum(BaseScore) .."</textformat>";
	elseif BaseScore < 999999 then
		str = str .. "<textformat leftmargin='240' leading='7'><p>".. self:GetBaseFightNum(BaseScore) .."</textformat>";
	else
		str = str .. "<textformat leftmargin='220' leading='7'><p>".. self:GetBaseFightNum(BaseScore) .."</textformat>";
	end
	str = str .. "</p></textformat>";

	--星星评级
	local equipType = BagUtil:GetEquipPutBagPos(self.tipsVO.id);
	if equipType == BagConsts.BagType_Role then
		if SmithingModel:GetMaxStarCount(self.tipsVO.id) == 0 then
			return str
		end
		str = str .. self:GetVGap(12);
		str = str .. "<textformat leftmargin='15'>";   
		str = str .. self:GetStar(self.tipsVO.strenLvl, self.tipsVO.emptystarnum);
		str = str .. "</textformat>";
	end
	return str;
end

function EquipTips:CheckZhuanSheng(num)
	if num == 0 then
		return StrConfig['tips1382']
	elseif num == 1 then
		return StrConfig['tips1383']
	elseif num == 2 then
		return StrConfig['tips1384']
	elseif num == 3 then
		return StrConfig['tips1385']
	elseif num == 4 then
		return StrConfig['tips1386']
	elseif num == 5 then
		return StrConfig['tips1387']
	end
	return " ";
end
--adder：侯旭东 date:2016/7/18 
--@reason: 用检测属性类型
function EquipTips:CheckAttr(attrType)
	local tipsTxt = "**";
	local eaAttrs = 0;   --属性值
	local info = MainPlayerModel.humanDetailInfo
	if AttrParseUtil.AttMap[attrType] == enAttrType.eaGongJi           then
		 tipsTxt = UIStrConfig["gongji"];
		 eaAttrs = info.eaGongJi
	elseif AttrParseUtil.AttMap[attrType]  == enAttrType.eaFangYu       then
		 tipsTxt = UIStrConfig["fangyu"];
		 eaAttrs = info.eaFangYu
	elseif AttrParseUtil.AttMap[attrType]  == enAttrType.eaMingZhong    then
		 tipsTxt = UIStrConfig["mingzhon"];
		 eaAttrs = info.eaMingZhong
	elseif AttrParseUtil.AttMap[attrType] == enAttrType.eaBaoJi        then
		 tipsTxt =UIStrConfig["baoji"];
		 eaAttrs = 'eaBaoJi'
	elseif AttrParseUtil.AttMap[attrType]  == enAttrType.eaHp           then
		 tipsTxt = UIStrConfig["xueliang"];
		  eaAttrs = info.eaHp
	elseif AttrParseUtil.AttMap[attrType] == enAttrType.eaRenXing      then
		 tipsTxt =UIStrConfig["rengxin"];
		  eaAttrs = info.eaRenXing
	elseif AttrParseUtil.AttMap[attrType] == enAttrType.eaBaoJiHurt    then
		 tipsTxt = UIStrConfig["baojishanghai"];
		 eaAttrs = info.eaBaoJiHurt
	elseif AttrParseUtil.AttMap[attrType] == enAttrType.eaBaoJiDefense then
		 tipsTxt =UIStrConfig["baojifangyu"];
		 eaAttrs = info.eaBaoJiDefense
	elseif AttrParseUtil.AttMap[attrType] == enAttrType.eaChuanCiHurt  then
		 tipsTxt = UIStrConfig["chuangcishanghai"];
		 eaAttrs = info.eaChuanCiHurt
	elseif AttrParseUtil.AttMap[attrType] == enAttrType.eaChuanTou     then
		 tipsTxt =UIStrConfig["gedangdengji"];
		 eaAttrs = info.eaChuanTou
	elseif AttrParseUtil.AttMap[attrType] == enAttrType.eaGeDang       then
		 tipsTxt =UIStrConfig["gedangdeng"];
		 eaAttrs = info.eaGeDang
	elseif AttrParseUtil.AttMap[attrType] == enAttrType.eaHurtAdd      then
		 tipsTxt = UIStrConfig["shanghaizengjia"];
		 eaAttrs = info.eaHurtAdd
	elseif AttrParseUtil.AttMap[attrType] == enAttrType.eaHurtSub      then
		 tipsTxt = UIStrConfig["shanghaijianshao"];
		 eaAttrs = info.eaHurtSub
	elseif AttrParseUtil.AttMap[attrType] == enAttrType.eaHunLi      then
		 tipsTxt = UIStrConfig["hunli"];
		 eaAttrs = info.eaHunLi
	elseif AttrParseUtil.AttMap[attrType] == enAttrType.eaTiPo      then
		 tipsTxt = UIStrConfig["tipo"];
		 eaAttrs = info.eaTiPo
	end
	return tipsTxt,eaAttrs;
end

--获取战斗力num
function EquipTips:GetFightNum(num)
	local str = "";
	if num < 99999 then
		-- str = "<p>";
	else
		-- str = "<p align='right'>";
	end
	local numStr = tostring(num);
	if not numStr then return""; end
	for i=1,#numStr do
		local img = ResUtil:GetNewSmTipsNum(string.sub(numStr,i,i))
		str = str .. "<img src='" .. ResUtil:GetNewSmTipsNum(string.sub(numStr,i,i)) .. "'/>";
	end
	-- str = str .. "</p>";
	return str;
end

--获取基础评分num
function EquipTips:GetBaseFightNum(num)
	local str = "";
	if num < 9999 then
		str = "<align='right'>";    		 -- "<p align='center'>"
	else
		str = "<align='right'>";             -- "<p align='right'>" 
	end
	local numStr = tostring(num);
	if not numStr then return""; end
	for i=1,#numStr do 
		str = str .. "<img vspace='-3' src='" .. ResUtil:GetNewTipsNum(string.sub(numStr,i,i)) .. "'/>";
	end
	str = str.."</>";
	return str;
end


--获取炼化num
function EquipTips:GetRefinNum(num)
	local str = "";
	local numStr = "+" .. tostring(num);
	for i=1,#numStr do
		str = str .. "<img vspace='-2' src='" .. ResUtil:GetTipsRefinNum(string.sub(numStr,i,i)) .. "'/>";
	end
	str = str .. "</p>";
	return str;
end
--------------------------------------------------------Data----------------------------------------------


--基础属性  adder: houxudong date:2016/6/25 
function EquipTips:GetBaseAttr()
	local str = "";
	local list = self.tipsVO:GetEquipBaseAttr();
	if #list == 0 then return ""; end
	--@二级标签
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText(StrConfig["tips11"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);

	--装备状态
	--[[
	local isEquip = self.tipsVO.equiped                           
	str = str .. "<textformat leading='-16' leftmargin='300'><p></p><font>";
	if isEquip then
		str = str .. self:GetHtmlText(StrConfig['tips1350'],"#00ff00",TipsConsts.BlackNew_Size,true);		
	elseif self.tipsVO.isInBag then
		str = str .. self:GetHtmlText(StrConfig['tips1351'],TipsConsts.redColor,TipsConsts.BlackNew_Size,true);	
	end
	--]]
	str = str .. "</font></textformat>";
	
	for i=1,#list do   --支持多种基础属性显示
		str = str .. "<textformat leading='-16' leftmargin='6'><p>";  --</p>前面创建空白区域
		str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		str = str .. "</p></textformat>";
		local leading = 4;
		if self.tipsVO.refinLvl>0 or self.tipsVO.strenLvl>0 then
			leading = -14;
		end
		str = str ..  "<textformat leading='" .. leading .."' leftmargin='23'><p>";
		str = str .. string.format( "<font color='#eeb462'>%s</font>",enAttrTypeName[list[i].type]..":")
		-- str = str ..":";
		local add = " +";
		str = str .. string.format( "<font color='#d8d8d8'>%s</font><font color='#d8d8d8'>%s</font>", 
			 add,getAtrrShowVal(list[i].type,list[i].val))
		str = str .. "</p></textformat>";
		if self.tipsVO.refinLvl > 0 then  -- 强化
			local refinlist = self.tipsVO:GetEquipRefinAttr();
			local leading = 4;
			if self.tipsVO.strenLvl > 0 then
				leading = -14;
			end
			str = str .. "<textformat leading='" ..leading.. "' leftmargin='179'><p><font color='#33ff00'>";
			str = str .. StrConfig['tips1328'] ..":" .." +".. getAtrrShowVal(refinlist[1].type,refinlist[1].val);
			str = str .. "</font></p></textformat>";
		end
		--
		if self.tipsVO.strenLvl > 0 then  --升星
			local strenlist = self.tipsVO:GetEquipStrenAttr();
			str = str .. "<textformat leading='4' leftmargin='180'><p><font color='#33ff00'>";
			str = str .. StrConfig['tips1329']..":" .." +" .. getAtrrShowVal(strenlist[1].type,strenlist[1].val);
			str = str .. "</font></p></textformat>";
		end
		str = self:GetHtmlText(str,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	end
	
	return str;
end

--神武属性
function EquipTips:GetShenWuAttr()
	local str = "";
	if self.tipsVO.shenWuLevel and self.tipsVO.shenWuLevel > 0 then
		str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
		str = str .. self:GetHtmlText(StrConfig["tips17"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
		str = str .. "</p></textformat>";
		str = str .."<textformat></br>".."<br></textformat>"
		str = str .. "<textformat leading='-16' leftmargin='6'><p>";
		str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		str = str .. "</p></textformat>";
		--
		local leading = -14
		str = str ..  "<textformat leading='" .. leading .."' leftmargin='23'><p>";
		str = str .. string.format( "<font color='#5e3eff'>%s</font> <font color='#00FF00'>Lv.%s</font>", StrConfig['shenwu10'], self.tipsVO.shenWuLevel)
		str = str .. "</p></textformat>";
		str = str ..  "<textformat leading='4' leftmargin='230'><p>";
		local cfg = ShenWuUtils:GetStarCfg(self.tipsVO.shenWuLevel, self.tipsVO.shenWuStar)
		str = str .. string.format( "<font color='#5e3eff'>%s%d%%</font>", StrConfig['shenwu11'], cfg.promote * 0.01)
		str = str .. "</p></textformat>";
	end
	if str ~= "" then str = self:GetHtmlText(str,TipsConsts.Default_Color,TipsConsts.Default_Size,false); end
	return str
end

--新套装属性，套装单个加成
function EquipTips:GetGroupBaseAttr()
	local str = "";
	if not self.tipsVO.groupId2 then 
		return str;
	end;
	local groupCfg = t_equipgroup[self.tipsVO.groupId2];
	local atbCfg = {};
	local posCfg = self.tipsVO.groupId2 * 100000 + self.tipsVO.cfg.pos;
	local lvlUpAttr = 0
	if t_equipgrouppos[posCfg] then 
		local cfg = t_equipgrouppos[posCfg];
		local att = split(cfg.attr,",")
		local groupLvlCfg = EquipUtil:GetGroupLevelCfg( self.tipsVO.groupId2, self.tipsVO.groupId2Level )
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

	str = str .. "<textformat leading='-21' leftmargin='6'><p>";
	str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
	str = str .. "</p></textformat>";
	--
	str = str .."<textformat leading='-20' leftmargin='20'><p>";
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
	str = str ..  string.format( "lv.%s  %s %s", self.tipsVO.groupId2Level, bassAttrStr, lvlUpAttrStr )
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


--坐骑灵兽的基础属性,是双属性
function EquipTips:GetBaseAttrS()
	local str = "";
	local list = self.tipsVO:GetEquipBaseAttr();
	if #list == 0 then return ""; end
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText(StrConfig["tips11"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	for i,vo in ipairs(list) do
		str = str .. "<textformat leading='-16' leftmargin='6'><p>";
		str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		str = str .. "</p></textformat>";
		str = str ..  "<textformat leading='5' leftmargin='23'><p>";
		str = str .. enAttrTypeName[vo.type] .. " +" .. getAtrrShowVal(vo.type,vo.val);
		str = str .. "</p></textformat>";
	end
	return str;
end

--追加属性
function EquipTips:GetExtraAttr()
	local str = "";
	local list = self.tipsVO:GetExtraBaseAttr();
	if #list == 0 then return ""; end
	str = str .. "<textformat leading='-16' leftmargin='6'><p>";
	str = str .. "<img width='13' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
	str = str .. "</p></textformat>";
	--
	local leading = 4;
	if self.tipsVO.refinLvl>0 or self.tipsVO.strenLvl>0 then
		leading = -14;
	end
	str = str ..  "<textformat leading='" .. leading .."' leftmargin='23'><p>";
	str = str .. enAttrTypeName[list[1].type] .. " +" .. getAtrrShowVal(list[1].type,list[1].val);
	str = str .. string.format(StrConfig['tips1332'],self.tipsVO.extraLvl);
	str = str .. "</p></textformat>";
	--
	if self.tipsVO.refinLvl > 0 then
		local extraRefinList = self.tipsVO:GetExtraRefinAttr();
		local leading = 4;
		if self.tipsVO.strenLvl > 0 then
			leading = -14;
		end
		str = str .. "<textformat leading='" ..leading.. "' leftmargin='179'><p><font color='#33ff00'>";
		str = str .. StrConfig['tips1328'] .. getAtrrShowVal(extraRefinList[1].type,extraRefinList[1].val);
		str = str .. "</font></p></textformat>";
	end
	--
	if self.tipsVO.strenLvl > 0 then
		local extraStrenList = self.tipsVO:GetExtraStrenAttr();
		str = str .. "<textformat leading='4' leftmargin='289'><p><font color='#33ff00'>";
		str = str .. StrConfig['tips1329'] .. getAtrrShowVal(extraStrenList[1].type,extraStrenList[1].val);
		str = str .. "</font></p></textformat>";
	end
	str = self:GetHtmlText(str,"#0dc1f8",TipsConsts.Default_Size,false);
	return str;
end

--卓越属性(目前是神铸属性)
function EquipTips:GetNewSuperAttr()
	if self.tipsVO.cfg.pos>BagConsts.Equip_JieZhi2 or self.tipsVO.cfg.pos<BagConsts.Equip_WuQi then
		return "";
	end
	local newSuperNum = toint(EquipConsts:DefaultNewSuperNum(self.tipsVO.cfg.quality))
	if not newSuperNum then
		return ""
	end
	--显示随机新卓越属性
	local str = "";
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText(StrConfig["tips12"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);  --神铸属性
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"

	str = str .. self:GetVGap(5);
	if not self.tipsVO.newSuperList then
		self.tipsVO.newSuperList = {}
	end
	local superCount = 0
	for i,vo in ipairs(self.tipsVO.newSuperList) do
		if vo.id > 0 then
			local cfg = t_zhuoyueshuxing[vo.id];
			local attrStr = "";
			-- attrStr = attrStr .. "<textformat leading='-16' leftmargin='6'><p>"; 
			-- attrStr = attrStr .. self:GetHtmlText(StrConfig["tips12"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
			-- attrStr = attrStr .. "</p></textformat>";
			-- attrStr = attrStr .."<textformat></br>".."<br></textformat>"
			attrStr = attrStr .. "<textformat leading='-14' leftmargin='6'><p>";
			attrStr = attrStr .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			attrStr = attrStr .. "</p></textformat>";
			if cfg.isBest then
				attrStr = attrStr .. "<textformat leading='-15' leftmargin='21'><p>";
			else
				attrStr = attrStr .. "<textformat leading='4' leftmargin='21'><p>";
			end
			attrStr = attrStr .. StrConfig['tips1341'] .. "";  --【神】
			if not vo.wash then 
				vo.wash = 0 ;
			end;
			local typeStr,val = formatAttrStrForTips(cfg.attrType,vo.wash);
			attrStr = attrStr .. typeStr..":".." +"..val

			attrStr = attrStr .. "";
			attrStr = attrStr .. "</p></textformat>";
			if cfg.isBest then
				attrStr = attrStr .. "<textformat leading='-16' leftmargin='250'><p>";
				attrStr = attrStr .. "<img width='35' height='21' vspace='17' src='" .. ResUtil:GetTipsSuperBestUrl() .. "'/>";
				attrStr = attrStr .. "</p></textformat>";
			end
			str = str .. self:GetHtmlText(attrStr,TipsConsts.NewSuperColor,TipsConsts.Default_Size,false);
			superCount = superCount + 1
		end
	end
	
	if superCount < newSuperNum then
		local defStr = string.format(StrConfig['tips1333'])
		for i=superCount + 1,newSuperNum do
			str = str .. "<textformat leading='-20' leftmargin='6'><p>";
			str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			str = str .. "</p></textformat>";
			-- if self.tipsVO.newSuperDetailStr and self.tipsVO.newSuperDetailStr~="" then
			-- 	str = str .. self:GetVGap(5);
			-- 	str = str .. "<textformat leading='10' leftmargin='23'><p>";
			-- 	str = str .. self:GetHtmlText(self.tipsVO.newSuperDetailStr,TipsConsts.NewSuperColor,TipsConsts.Default_Size,false);
			-- 	str = str .. "</p></textformat>";
			-- else
				str = str .. self:GetVGap(5);
				str = str .. "<textformat leading='10' leftmargin='23'><p>";
				str = str .. self:GetHtmlText(defStr,TipsConsts.NewSuperColor,TipsConsts.Default_Size,false);
				str = str .. "</p></textformat>";
			-- end
		end
	end
	return str;
end


--卓越属性
function EquipTips:GetSuperAttr()
	--显示随机卓越属性
	local str = "";
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText(StrConfig["tips18"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	if not self.tipsVO.superVO then
		if not self.tipsVO.superDefStr or self.tipsVO.superDefStr=="" then
			return "";
		end
		local defSuperStr = string.format(StrConfig['tips1334'],self.tipsVO.superDefStr);
		str = str .. "<textformat leading='-16' leftmargin='6'><p>";
		str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		str = str .. "</p></textformat>";
		str = str .. "<textformat leftmargin='23'><p>"; 
		str = str .. self:GetHtmlText(defSuperStr,TipsConsts.SuperColor,TipsConsts.Default_Size,false) .. "</p></textformat>";
		if self.tipsVO.superDetailStr and self.tipsVO.superDetailStr~="" then
			str = str .. self:GetVGap(5);
			str = str .. "<textformat leftmargin='23'><p>";
			str = str .. self:GetHtmlText(self.tipsVO.superDetailStr,TipsConsts.SuperColor,TipsConsts.Default_Size,false);
			str = str .. "</p></textformat>";
		end
		return str;
	end
	--
	if self.tipsVO.superVO.superNum == 0 then
		return "";
	end
	--
	local str = "";
	str = str .. self:GetVGap(5);
	for i=1,self.tipsVO.superVO.superNum do
		local vo = self.tipsVO.superVO.superList[i];
		if vo.id == 0 then
			str = str .. "<textformat leading='-16' leftmargin='6'><p>";
			str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			str = str .. "</p></textformat>";
			str = str .. "<textformat leading='7' leftmargin='23'><p>";
			str = str .. self:GetHtmlText(StrConfig['tips1335'],"#5a5a5a",TipsConsts.Default_Size,false);
			str = str .. "</p></textformat>"; 
		else
			local cfg = t_fujiashuxing[vo.id];
			local attrStr = "";

			attrStr = attrStr .. "<textformat leading='-16' leftmargin='6'><p>";
			attrStr = attrStr .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			attrStr = attrStr .. "</p></textformat>";

			if cfg.best == 1 then
				attrStr = attrStr .. "<textformat leading='-16' leftmargin='28'><p>";
			else
				attrStr = attrStr .. "<textformat leading='4' leftmargin='23'><p>";
			end
			attrStr = attrStr .. string.format("「%s」",cfg.name);
			attrStr = attrStr .. formatAttrStr(cfg.attrType,vo.val1);
			attrStr = attrStr .. "</p></textformat>";
			if cfg.best == 1 then
				attrStr = attrStr .. "<textformat leading='-16' leftmargin='250'><p>";
				attrStr = attrStr .. "<img width='35' height='21' vspace='17' src='" .. ResUtil:GetTipsSuperBestUrl() .. "'/>";
				attrStr = attrStr .. "</p></textformat>";
			end

			str = str .. self:GetHtmlText(attrStr,TipsConsts.SuperColor,TipsConsts.Default_Size,false);
		end
	end
	return str;
end

--戒指属性
function EquipTips:GetRingStr()
	local str = ""
	local ringLv = self.tipsVO.ring
	if not ringLv or ringLv < 1 then
		return
	end
	local ringAttrList, ringSkillList = self.tipsVO:GetEquipRingAttr()
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText(StrConfig["tips19"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"

	local maxAttr, attrInfo, maxSkill, skillInfo = UISmithingRing:GetMaxValueInfo()
	for i = 1, maxAttr do
		local info = ringAttrList[i]
		str = str .. "<textformat leading='-16' leftmargin='6'><p>";
		str = str .. "<img width='9' height='15' vspace='-4' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		str = str .. "</p></textformat>"
		str = str .. "<textformat leading='5' leftmargin='23'><p>"; 
		if info then
			local str1 = enAttrTypeName[info.type] .. "：+" .. info.val
			if i == 1 then
				for i = 1, 15 - string.len(tostring(info.val)) do
					str1 = str1 .. SmithingConsts.ringTipsStr
				end
			end
			str = str .. self:GetHtmlText(str1, "#feaf05", TipsConsts.Default_Size, false)
			if i == 1 then
				str = str .. self:GetHtmlText(string.format(StrConfig['tips1381'], ringLv), "#feaf05", SmithingConsts.ringTipsSize, false)
			end
		else
			str = str .. self:GetHtmlText(string.format(StrConfig['tips1380'],attrInfo[i]), "#5a5a5a", TipsConsts.Default_Size, false)
		end
		str = str .. "</p></textformat>"
	end

	for i = 1, maxSkill do
		local info = ringSkillList[i]
		str = str .. "<textformat leading='-16' leftmargin='6'><p>";
		str = str .. "<img width='9' height='15' vspace='-4' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		str = str .. "</p></textformat>"
		str = str .. "<textformat leading='5' leftmargin='23'><p>"; 
		if info then
			str = str .. self:GetHtmlText(t_passiveskill[info].effectStr, "#feaf05", TipsConsts.Default_Size, false)
		else
			str = str .. self:GetHtmlText(string.format(StrConfig['tips1380'],skillInfo[i]), "#5a5a5a", TipsConsts.Default_Size, false)
		end
		str = str .. "</p></textformat>"
	end
	return str
end

--洗练属性
function EquipTips:GetWashStr()
	if self.tipsVO.cfg.pos>BagConsts.Equip_JieZhi2 or self.tipsVO.cfg.pos<BagConsts.Equip_WuQi then
		return "";
	end
	local str = ""
	local washAttrList = self.tipsVO:GetEquipWashAttr()
	local qualityConfig = t_extraquality[self.tipsVO.cfg.quality]
	if not washAttrList or not qualityConfig then return str end
	-- changer:houxudong  date:2016/8/15 23:44
	-- reason: 洗练属性没有的时候不再显示在tips上
	local isHaveWash = false;
	if qualityConfig.num > 0 then
		isHaveWash = true
	end
	-- for i = 1, qualityConfig.num do
	-- 	local info = washAttrList[i]
	-- 	if info then
	-- 		isHaveWash = true;
	-- 	end
	-- end
	if isHaveWash then
		str = str .. "<textformat leading='-20' leftmargin='6'><p>"; 
		str = str .. self:GetHtmlText(StrConfig["tips13"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);  --洗练属性
		str = str .. "</p></textformat>";
		str = str .."<textformat></br>".."<br></textformat>"
	end
	for i = 1, qualityConfig.num do
		local info = washAttrList[i]
		if info then
			local attrStr = ''
			attrStr = attrStr .. "<textformat leading='-16' leftmargin='6'><p>";
			attrStr = attrStr .. "<img width='9' height='15' vspace='-4' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			attrStr = attrStr .. "</p></textformat>";
			--
			attrStr = attrStr .. "<textformat leading='5' leftmargin='23'><p>"; 
			local value = string.format( "<font color='#d4d4d4'>%s</font>", "+"..info.val..'「'.. 'lv.' .. info.lv .. "」")
			local strs = enAttrTypeName[info.type]..": "..value; --使用特殊符号

			--[[
			str = str .. "<textformat leading='-16' leftmargin='215'><p><font color='#33ff00'>";
			str = str .. " +" ..info.val;
			str = str .. "</font></p></textformat>";
			--]]

			-- string.format( "<font color='#5e3eff'>%s·%s  </font>", StrConfig['shenwu10'], cfg.name)
			attrStr = attrStr .. self:GetHtmlText(strs,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
			attrStr = attrStr .. "</p></textformat>";
			str = str .. attrStr;
		else
			if isHaveWash then
				str = str .. "<textformat leading='-16' leftmargin='6'><p>";
				str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
				str = str .. "</p></textformat>";
				str = str .. "<textformat leading='5' leftmargin='23'><p>"; 
				str = str .. self:GetHtmlText(StrConfig['tips1336'],"#5a5a5a",TipsConsts.Default_Size,false);  --未激活
				str = str .. "</p></textformat>";
			end
		end
	end
	return str
end

--宝石属性
function EquipTips:GetGemAttr()
	if self.tipsVO.cfg.pos>BagConsts.Equip_JieZhi2 or self.tipsVO.cfg.pos<BagConsts.Equip_WuQi then
		return "";
	end
	local str = "";
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText(StrConfig["tips15"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);

	local gemlist = self.tipsVO:GetEquipGem();
	local gemattrlist = self.tipsVO:GetEquipGemAttr();
	if not gemlist then return ""; end
	local index = 0
	for i=1,#gemlist do
		index = index + 1
		if gemlist[i].used then
			local attrStr = "";
			local cfg = t_gemgroup[gemlist[i].id];
			if not cfg then return; end
			attrStr = attrStr .. "<textformat leading='-16' leftmargin='6'><p>";
			-- ResUtil:GetTipsGemIconUrl(cfg.tipsIcon.."_"..gemlist[i].level)
			attrStr = attrStr .. "<img width='9' height='15' vspace='-4' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			attrStr = attrStr .. "</p></textformat>";
			--
			attrStr = attrStr .. "<textformat leading='5' leftmargin='23'><p>"; 
			local s = cfg.name .. "：";
			s = s .. enAttrTypeName[gemattrlist[i].type] .. " +" .. getAtrrShowVal(gemattrlist[i].type,gemattrlist[i].val);
			attrStr = attrStr .. self:GetHtmlText(s,TipsConsts.SuperColor,TipsConsts.Default_Size,false);
			attrStr = attrStr .. "</p></textformat>";
			str = str .. attrStr;
		else
			str = str .. "<textformat leading='-16' leftmargin='6'><p>";
			-- ResUtil:GetTipsGemIconUrl("tipsGem_def")
			str = str .. "<img width='9' height='15' vspace='-4' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			str = str .. "</p></textformat>";
			str = str .. "<textformat leading='5' leftmargin='23'><p>"; 
			local pos = self.tipsVO.cfg.pos;
			if not pos then return; end
			local gemCfg = t_equipgem[pos]
			if not gemCfg then return; end
			local condition = "未激活";
			local limitLv = gemCfg['lv' ..i]
			local name = "宝石空位" .. i .. ": "
			local playerlv = MainPlayerModel.humanDetailInfo.eaLevel
			if toint(limitLv) > playerlv then
				condition = limitLv.."级开启"
			end
			if not limitLv or not name then return; end
			--StrConfig['tips1336']
			name = string.format("<font color='#8152e1'>%s</font>",name)
			str = str .. self:GetHtmlText(name..condition,"#8f8e8f",TipsConsts.Default_Size,false);
			str = str .. "</p></textformat>";
		end
	end
	for i=index+1, 5 do
		str = str .. "<textformat leading='-16' leftmargin='3'><p>";
		-- ResUtil:GetTipsGemIconUrl("tipsGem_def")
		str = str .. "<img width='9' height='15' vspace='-4' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		str = str .. "</p></textformat>";
		str = str .. "<textformat leading='5' leftmargin='23'><p>"; 
		-- str = str .. self:GetHtmlText(StrConfig['tips1336'],"#5a5a5a",TipsConsts.Default_Size,false);
			local pos = self.tipsVO.cfg.pos;
			if not pos then return; end
			local gemCfg = t_equipgem[pos]
			if not gemCfg then return; end
		
			local condition = "未激活";
			local limitLv = gemCfg['lv' ..i]
			local name = "宝石空位" .. i .. ": "
			local playerlv = MainPlayerModel.humanDetailInfo.eaLevel
			if toint(limitLv) > playerlv then
				condition = limitLv.."级开启"
			end
			if not limitLv or not name then return; end
			--StrConfig['tips1336']
			name = string.format("<font color='#8152e1'>%s</font>",name)
			str = str .. self:GetHtmlText(name..condition,"#8f8e8f",TipsConsts.Default_Size,false);
			
		str = str .. "</p></textformat>";
	end
	return str;
end

--附带技能

--套装2信息
function EquipTips:GetGroupInfo2()
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
			local equipCfg = t_equip[vo.id];
			if equipCfg then
				hasEquipList[equipCfg.pos] = vo.groupId2Level or 0;
			end
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
			str = str .. self:GetHtmlText(BagConsts:GetEquipName(ca),quaColor,TipsConsts.Default_Size,false);
		else
			str = str .. self:GetHtmlText(BagConsts:GetEquipName(ca),"#5a5a5a",TipsConsts.Default_Size,false);
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
			attrStr = attrStr .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
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
			str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			str = str .. "</p></textformat>";
			str = str .. "<textformat leading='7' leftmargin='35'><p>" .. attrStr .. "</p></textformat>";
		end
	end
	return str;
end

function EquipTips:GetShenWuLevelStr()
	local str = "";
	if self.tipsVO.shenWuLevel and self.tipsVO.shenWuLevel > 0 then
		-- 神武星级
		str = str .. "<textformat leading='-16' leftmargin='6'><p>";
		str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		str = str .. "</p></textformat>";
		--
		str = str ..  "<textformat leading='4' leftmargin='23'><p>";
		local cfg = t_shenwu[self.tipsVO.shenWuLevel]
		str = str .. string.format( "<font color='#5e3eff'>%s·%s  </font>", StrConfig['shenwu10'], cfg.name)
		local starNum = self.tipsVO.shenWuStar
		for i = 1, starNum do
			str = str .. "<img vspace='-2' width='17' height='17' src='" .. ResUtil:GetTipsStarUrl() .. "'/>";
		end
		str = str .. "</p></textformat>";
		-- 神武属性
		local cfg = ShenWuUtils:GetStarCfg(self.tipsVO.shenWuLevel, self.tipsVO.shenWuStar)
		local attrStr = "";
		local attrlist = AttrParseUtil:Parse(cfg.property);
		local attrName, attrValue
		--
		for i=1,#attrlist do
			local tab = attrlist[i]
			attrName = enAttrTypeName[tab.type]
			attrValue = getAtrrShowVal( tab.type, tab.val )
			attrStr = attrStr .. attrName .. "+" .. attrValue .. "  ";
		end

		str = str .. "<textformat leading='-16' leftmargin='6'><p>";
		str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		str = str .. "</p></textformat>";
		str = str .. "<textformat leading='4' leftmargin='23'><p>";
		str = str .. attrStr
		str = str .. "</p></textformat>"
		--技能描述
		local skillStr = ""
		local skills = self.tipsVO.shenWuSkills or {} --{ 1220001008, 1220002001, 0 }
		for index = 3, 1, -1 do
			local skillId = skills[index]
			if skillId == 0 then
				table.remove(skills, index)
			end
		end
		table.sort( skills, function(A, B)
			local cfgA = t_passiveskill[A]
			local cfgB = t_passiveskill[B]
			local groupA = t_skillgroup[cfgA.group_id];
			local groupB = t_skillgroup[cfgB.group_id];
			return groupA.index < groupB.index;
		end)
		for i, skillId in ipairs(skills) do
			if skillId and skillId > 0 then
				skillStr = skillStr .. "<textformat leading='-16' leftmargin='6'><p>";
				skillStr = skillStr .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
				skillStr = skillStr .. "</p></textformat>";
				local skillEffStr = SkillTipsUtil:GetSkillEffectStr(skillId);
				skillStr = skillStr .. "<textformat leading='4' leftmargin='23'><p>";
				skillStr = skillStr .. skillEffStr
				skillStr = skillStr .. "</p></textformat>";
			end
		end
		str = str .. skillStr
		--
		str = self:GetHtmlText( str, "#5e3eff", TipsConsts.Default_Size, false );
	end

	if str ~= "" then str = self:GetHtmlText(str,TipsConsts.Default_Color,TipsConsts.Default_Size,false); end
	return str
end

--套装信息
function EquipTips:GetGroupInfo()
	local str = "";
	if self.tipsVO.groupId == 0 then
		return str;
	end
	local groupCfg = t_equipgroup[self.tipsVO.groupId];
	if not groupCfg then return str; end
	local totalNum = 0;--套装总数量
	local num = 0;--拥有套装数量
	local equipType = BagUtil:GetEquipPutBagPos(self.tipsVO.id);
	if equipType == BagConsts.BagType_Role then
		totalNum = 11;
	elseif equipType == BagConsts.BagType_LingZhenZhenYan then
		totalNum = 3;
	elseif equipType == BagConsts.BagType_QiZhan then
		totalNum = 3;	
	-- elseif equipType == BagConsts.BagType_ShenLing then
	-- 	totalNum = 3;
	else
		totalNum = 4;
	end
	--
	local hasEquipList = {};
	for i,vo in ipairs(self.tipsVO.groupEList) do
		if vo.groupId == self.tipsVO.groupId then
			num = num + 1;
			local equipCfg = t_equip[vo.id];
			if equipCfg then
				hasEquipList[equipCfg.pos] = true;
			end
		end
	end
	--
	str = str .. self:GetHtmlText(string.format("%s（%s/%s）",groupCfg.name,num,totalNum),"#00ff00",TipsConsts.Default_Size);
	str = str .. self:GetVGap(7);
	--如果有新套装，旧套装折叠显示
	-- if self.tipsVO.groupId2 and self.tipsVO.groupId2 ~= 0 then
	-- 	str = "";
	-- 	str = str .. self:GetVGap(5);
	-- 	str = str .. "<textformat leading='-17' leftmargin='6'><p>";
	-- 	str = str .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
	-- 	str = str .. "</p></textformat>";

	-- 	str = str .. "<textformat leading='-15' leftmargin='28'><p>"; 
	-- 	str = str .. self:GetHtmlText(string.format(StrConfig['tips1337'],groupCfg.name,num,totalNum),"#00ff00",TipsConsts.Default_Size);
	-- 	str = str .. "</p></textformat>";
	-- 	str = str .. self:GetVGap(5);
	-- 	return str;
	-- end
	local startPos,endPos;
	if equipType == BagConsts.BagType_Role then
		startPos = BagConsts.Equip_WuQi;
		endPos = BagConsts.Equip_JieZhi2;
	elseif equipType == BagConsts.BagType_Horse then
		startPos = BagConsts.Equip_H_AnJu;
		endPos = BagConsts.Equip_H_DengJu;
	elseif equipType == BagConsts.BagType_LingShou then
		startPos = BagConsts.Equip_L_XiangQuan;
		endPos = BagConsts.Equip_L_TouShi;
	elseif equipType == BagConsts.BagType_LingShouHorse then
		startPos = BagConsts.Equip_LH_ZhuangJiao;
		endPos = BagConsts.Equip_LH_XiongJia;
	elseif equipType == BagConsts.BagType_LingZhenZhenYan then
		local equipCfg = t_equip[self.tipsVO.id];
		if equipCfg then
			if equipCfg.pos >= BagConsts.Equip_LZ_ZhenYan0 and equipCfg.pos <= BagConsts.Equip_LZ_ZhenYan2 then
				startPos = BagConsts.Equip_LZ_ZhenYan0;
				endPos = BagConsts.Equip_LZ_ZhenYan2;
			elseif equipCfg.pos >= BagConsts.Equip_LZ_ZhenYan3 and equipCfg.pos <= BagConsts.Equip_LZ_ZhenYan5 then
				startPos = BagConsts.Equip_LZ_ZhenYan3;
				endPos = BagConsts.Equip_LZ_ZhenYan5;
			elseif equipCfg.pos >= BagConsts.Equip_LZ_ZhenYan6 and equipCfg.pos <= BagConsts.Equip_LZ_ZhenYan8 then
				startPos = BagConsts.Equip_LZ_ZhenYan6;
				endPos = BagConsts.Equip_LZ_ZhenYan8;
			end
		end
	elseif equipType == BagConsts.BagType_QiZhan then
		local equipCfg = t_equip[self.tipsVO.id];
		if equipCfg then
			if equipCfg.pos >= BagConsts.Equip_QZ_ZhenYan0 and equipCfg.pos <= BagConsts.Equip_QZ_ZhenYan2 then
				startPos = BagConsts.Equip_QZ_ZhenYan0;
				endPos = BagConsts.Equip_QZ_ZhenYan2;
			elseif equipCfg.pos >= BagConsts.Equip_QZ_ZhenYan3 and equipCfg.pos <= BagConsts.Equip_QZ_ZhenYan5 then
				startPos = BagConsts.Equip_QZ_ZhenYan3;
				endPos = BagConsts.Equip_QZ_ZhenYan5;
			elseif equipCfg.pos >= BagConsts.Equip_QZ_ZhenYan6 and equipCfg.pos <= BagConsts.Equip_QZ_ZhenYan8 then
				startPos = BagConsts.Equip_QZ_ZhenYan6;
				endPos = BagConsts.Equip_QZ_ZhenYan8;
			end
		end
	-- elseif equipType == BagConsts.BagType_ShenLing then
	-- 	local equipCfg = t_equip[self.tipsVO.id];
	-- 	if equipCfg then
	-- 		if equipCfg.pos >= BagConsts.Equip_SL_ZhenYan0 and equipCfg.pos <= BagConsts.Equip_SL_ZhenYan2 then
	-- 			startPos = BagConsts.Equip_SL_ZhenYan0;
	-- 			endPos = BagConsts.Equip_SL_ZhenYan2;
	-- 		elseif equipCfg.pos >= BagConsts.Equip_SL_ZhenYan3 and equipCfg.pos <= BagConsts.Equip_SL_ZhenYan5 then
	-- 			startPos = BagConsts.Equip_SL_ZhenYan3;
	-- 			endPos = BagConsts.Equip_SL_ZhenYan5;
	-- 		elseif equipCfg.pos >= BagConsts.Equip_SL_ZhenYan6 and equipCfg.pos <= BagConsts.Equip_SL_ZhenYan8 then
	-- 			startPos = BagConsts.Equip_SL_ZhenYan6;
	-- 			endPos = BagConsts.Equip_SL_ZhenYan8;
	-- 		end
	-- 	end	
	end

	
	for i=startPos,endPos,1 do
		if hasEquipList[i] then
			str = str .. self:GetHtmlText(BagConsts:GetEquipName(i),"#00ff00",TipsConsts.Default_Size,false);
		else
			str = str .. self:GetHtmlText(BagConsts:GetEquipName(i),"#5a5a5a",TipsConsts.Default_Size,false);
		end
		if i == 6 then
			str = str .. "<br/>";
			str = str .. self:GetVGap(5);
		else
			str = str .. "    ";
		end
	end
	str = str .. "<br/>";
	str = str .. self:GetVGap(17);
	for i=2,11 do
		local attrCfg = groupCfg["attr"..i];
		if attrCfg ~= "" then
			str = str .. "<textformat leading='-14' leftmargin='11'><p>";
			if num >= i then
				str = str .. self:GetHtmlText(string.format(StrConfig['tips1338'],i),"#00ff00",TipsConsts.Default_Size,false);
			else
				str = str .. self:GetHtmlText(string.format(StrConfig['tips1338'],i),"#5a5a5a",TipsConsts.Default_Size,false);
			end
			str = str .. "</p></textformat>";
			local attrStr = "";
			local attrlist = AttrParseUtil:Parse(attrCfg);
			for i=1,#attrlist do
				attrStr = attrStr .. enAttrTypeName[attrlist[i].type] .. " +" .. getAtrrShowVal(attrlist[i].type,attrlist[i].val) .. " ";
				if i%2==0 and i<#attrlist then
					attrStr = attrStr .. "<br/>";
				end
			end
			if num >= i then
				attrStr = self:GetHtmlText(attrStr,"#00ff00",TipsConsts.Default_Size,false);
			else
				attrStr = self:GetHtmlText(attrStr,"#5a5a5a",TipsConsts.Default_Size,false);
			end
			str = str .. "<textformat leading='7' leftmargin='103'><p>" .. attrStr .. "</p></textformat>";
		end
	end
	return str;
end

--附属套装信息
function EquipTips:GetExtraGroupInfo()
	local str = "";
	if self.tipsVO.cfg.extraGroupId == 0 then
		return str;
	end
	local groupCfg = t_equipgroup[self.tipsVO.cfg.extraGroupId];
	if not groupCfg then return str; end
	local totalNum = 0;
	local num = 0;
	local strlist = split(groupCfg.equips,"#");
	local equipList = {};
	local hasEquipList = {};
	for _,s in ipairs(strlist) do
		local id = toint(s);
		table.push(equipList,id);
		for i,vo in ipairs(self.tipsVO.groupEList) do
			if vo.id == id then
				num = num + 1;
				hasEquipList[id] = true;
			end
		end
	end
	totalNum = #equipList;
	--
	str = str .. self:GetHtmlText(string.format(StrConfig['tips1339'],groupCfg.name,num,totalNum),"#00ff00",TipsConsts.Default_Size);
	str = str .. self:GetVGap(7);
	for i,equipId in ipairs(equipList) do
		local equipCfg = t_equip[equipId];
		if hasEquipList[equipId] then
			str = str .. self:GetHtmlText(BagConsts:GetEquipName(equipCfg.pos),"#00ff00",TipsConsts.Default_Size,false);
		else
			str = str .. self:GetHtmlText(BagConsts:GetEquipName(equipCfg.pos),"#5a5a5a",TipsConsts.Default_Size,false);
		end
		if i == 6 then
			str = str .. "<br/>";
			str = str .. self:GetVGap(5);
		else
			str = str .. "    ";
		end
	end
	--
	str = str .. "<br/>";
	str = str .. self:GetVGap(17);
	for i=2,11 do
		local attrCfg = groupCfg["attr"..i];
		if attrCfg ~= "" then
			str = str .. "<textformat leading='-14' leftmargin='11'><p>";
			if num >= i then
				str = str .. self:GetHtmlText(string.format(StrConfig['tips1338'],i),"#00ff00",TipsConsts.Default_Size,false);
			else
				str = str .. self:GetHtmlText(string.format(StrConfig['tips1338'],i),"#5a5a5a",TipsConsts.Default_Size,false);
			end
			str = str .. "</p></textformat>";
			local attrStr = "";
			local attrlist = AttrParseUtil:Parse(attrCfg);
			for i=1,#attrlist do
				attrStr = attrStr .. enAttrTypeName[attrlist[i].type] .. " +" .. getAtrrShowVal(attrlist[i].type,attrlist[i].val) .. " ";
				if i%2==0 and i<#attrlist then
					attrStr = attrStr .. "<br/>";
				end
			end
			if num >= i then
				attrStr = self:GetHtmlText(attrStr,"#00ff00",TipsConsts.Default_Size,false);
			else
				attrStr = self:GetHtmlText(attrStr,"#5a5a5a",TipsConsts.Default_Size,false);
			end
			str = str .. "<textformat leading='7' leftmargin='103'><p>" .. attrStr .. "</p></textformat>";
		end
	end
	return str;
end

--装备对比
function EquipTips:GetCompareInfo()
	local str = "";
	if not self.tipsVO.compareTipsVO then
		return str;
	end
	-- str = str .. self:GetHtmlText(StrConfig['tips1340'],"#be8c44",TipsConsts.TitleSize_Two);
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText(StrConfig["tips1340"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	-- str = str .. self:GetVGap(5);
	local attrChangeList = self.tipsVO:GetCompareAttrList();
	local index = 1;
	local len = #attrChangeList;
	for i,vo in pairs(attrChangeList) do
		local attrStr = "";
		if vo.val == 0 then
			attrStr = self:GetHtmlText(enAttrTypeName[vo.type].." +"..getAtrrShowVal(vo.type,vo.val),"#d5b772",TipsConsts.Default_Size,false);
		elseif vo.val > 0 then
			attrStr = self:GetHtmlText(enAttrTypeName[vo.type].." <font color='#29cc00'>+"..getAtrrShowVal(vo.type,vo.val).."</font>","#d5b772",TipsConsts.Default_Size,false);
		else
			attrStr = self:GetHtmlText(enAttrTypeName[vo.type].." <font color='#cc0000'>"..getAtrrShowVal(vo.type,vo.val).."</font>","#d5b772",TipsConsts.Default_Size,false);
		end
		local leading = 0;
		local leftmargin = 11;
		if index == len then
			leading = 0;
			if index%2 == 1 then
				leftmargin = 11;
			else
				leftmargin = 190;
			end
		else
			if index%2 == 1 then
				leading = -16;
				leftmargin = 11;
			else
				leading = 7;
				leftmargin = 190;
			end
		end
		attrStr = "<textformat leading='".. leading .."' leftmargin='".. leftmargin .."'><p>" .. attrStr .. "</p></textformat>";
		str = str .. attrStr;
		index = index + 1;
	end
	return str;
end

--获取方式
function EquipTips:GetFrom()
	if self.tipsVO.cfg.from == "" then return ""; end
	local str = "";

	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText(StrConfig["tips8"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(2);

	str = str .. "<textformat leading='-16' leftmargin='6'><p>";
	str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
	str = str .. "</p></textformat>";
	-- str = str .. self:GetVGap(3);
	-- str = str .. self:GetHtmlText(StrConfig["tips8"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	-- str = str .. self:GetVGap(2);
	local leading = 4;
	str = str ..  "<textformat leading='" .. leading .."' leftmargin='23'>";
	str = str .. self:GetHtmlText(self.tipsVO.cfg.from,TipsConsts.GetPathColor,TipsConsts.Default_Size,false);
	str = self:SetLineSpace(str,5);
	return str;
end

--展示信息
function EquipTips:GetShowInfo()
	if not self.tipsVO.isInBag then return ""; end
	return self:GetHtmlText(StrConfig["tips3"],TipsConsts.Default_Color,TipsConsts.Default_Size,false);
end

--出售信息
function EquipTips:GetSellInfo()
	if not self.tipsVO.isInBag then return ""; end
	local str = "";
	if self.tipsVO.cfg.sell then
		str = str .. self:GetHtmlText(StrConfig["tips4"],"#d2a930",TipsConsts.Default_Size,false);
		local s = string.format(StrConfig["tips5"],self.tipsVO.count,self.tipsVO.count*self.tipsVO.cfg.price);
		str = str .. self:GetHtmlText(s,"#d2a930",TipsConsts.Default_Size,false);
	else
		str = str .. self:GetHtmlText(StrConfig["tips6"],"#d2a930",TipsConsts.Default_Size,false);
	end
	str = "<textformat rightmargin='11'><p align='right'>" .. str .. "</p></textformat>";
	return str;
end

function EquipTips:OnGetUnionContr()
	local str = "";
	str = str .. self:GetVGap(5);
	if self.tipsVO.contrState == 1 then --取出
		str = str .. self:GetHtmlText(StrConfig["tips902"]..self.tipsVO.contrVla,"#ffffff",TipsConsts.Default_Size);
	elseif self.tipsVO.contrState == 2 then --存入
		str = str .. self:GetHtmlText(StrConfig["tips901"]..self.tipsVO.contrVla,"#ffffff",TipsConsts.Default_Size);
	end;
	return str
end

--得到tips显示类型
function EquipTips:GetTipsType(  )
	return TipsConsts.Type_Equip
end


local s_groupAtt = {"att", "def", "hp"}
local groupColor = "#feaf05"
--- 新套装属性
function EquipTips:GetNewGroupStr()
	if not self.tipsVO.newGroupInfo then
		return ""
	end
	if self.tipsVO.cfg.pos>BagConsts.Equip_JieZhi2 or self.tipsVO.cfg.pos<BagConsts.Equip_WuQi then
		return "";
	end
	local str = self:GetLine(5)
	local newGroupInfo = self.tipsVO.newGroupInfo
	
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText(StrConfig["tips20"] .. "(" .. newGroupInfo[1]  .. "/11)",TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);



	str = str .. "<textformat leading='5' leftmargin='6'><p>"
	for i = 1, 8 do
		if newGroupInfo[2][i - 1] then
			str = str .. self:GetHtmlText(StrConfig['commonEquipName' .. (i)], groupColor, TipsConsts.Default_Size, false)
		else
			str = str .. self:GetHtmlText(StrConfig['commonEquipName' .. (i)], "#5a5a5a", TipsConsts.Default_Size, false)
		end
		if i ~= 8 then
			str = str .. "  "
		else
			str = str .. "</p></textformat>"
		end
	end
	str = str .. "<textformat leading='5' leftmargin='6'><p>"
	for i = 9, 11 do
		if newGroupInfo[2][i - 1] then
			str = str .. self:GetHtmlText(StrConfig['commonEquipName' .. (i)], groupColor, TipsConsts.Default_Size, false)
		else
			str = str .. self:GetHtmlText(StrConfig['commonEquipName' .. (i)], "#5a5a5a", TipsConsts.Default_Size, false)
		end
		if i ~= 11 then
			str = str .. "  "
		else
			str = str .. "</p></textformat>"
		end
	end
	local func = function()
		local tab = "  "
		local atrStr = ""
		for k, v in pairs(s_groupAtt) do
			local pro = newGroupInfo[3][v]
			if pro then
				atrStr = atrStr .. PublicAttrConfig.proName[v] .. "：".. pro.val .. tab
			else
				atrStr = atrStr .. PublicAttrConfig.proName[v] .. "：".. "0" .. tab
			end
		end
		return atrStr
	end
	
	local valueInfo = t_consts[324]
	str = str .. "<textformat leading='5' leftmargin='6'><p>"
	if newGroupInfo[1] == 11 then
	 	str = str .. self:GetHtmlText(string.format(StrConfig['tips1401'], 11, valueInfo["val3"]), groupColor, TipsConsts.Default_Size, true)
	 	str = str ..  self:GetHtmlText(func(), groupColor, TipsConsts.Default_Size, false)
	elseif newGroupInfo[1] < 6 then
		str = str .. self:GetHtmlText(string.format(StrConfig['tips1401'], 6, valueInfo["val1"]), "#5a5a5a", TipsConsts.Default_Size, false)		
	elseif newGroupInfo[1] < 9 then
		str = str .. self:GetHtmlText(string.format(StrConfig['tips1401'], 6, valueInfo["val1"]), groupColor, TipsConsts.Default_Size, true)
	 	str = str .. self:GetHtmlText(func(), groupColor, TipsConsts.Default_Size, true)
	 	str = str .. self:GetHtmlText(string.format(StrConfig['tips1401'], 9, valueInfo["val2"]), "#5a5a5a", TipsConsts.Default_Size, false)	
	else
		str = str .. self:GetHtmlText(string.format(StrConfig['tips1401'], 9, valueInfo["val2"]), groupColor, TipsConsts.Default_Size, true)
	 	str = str .. self:GetHtmlText(func(), groupColor, TipsConsts.Default_Size, true)
	 	str = str .. self:GetHtmlText(string.format(StrConfig['tips1401'], 11, valueInfo["val3"]), "#5a5a5a", TipsConsts.Default_Size, false)
	end
	str = str .. "</p></textformat>"
	return str;
end
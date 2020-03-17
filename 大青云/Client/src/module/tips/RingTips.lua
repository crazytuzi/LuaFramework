--[[
物品Tips
lizhuangzhuang
2014年8月15日15:53:25
]]

_G.RingTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_Ring,RingTips);

RingTips.tipsVO = nil;

function RingTips:Parse(tipsInfo)
	self.tipsVO = tipsInfo;
	--
	self.str = "";
	self.str = self.str .. self:GetTitle();
	self.str = self.str .. self:GetLine(70,10);
	--
	if self:GetModelDrawClz() then
		self.str = self.str .. self:GetVGap(self:GetModelDrawClz():GetHeight());
		self.str = self.str .. self:GetLine(10);
	end
	--
	self.str = self.str .. self:SetLeftMargin(self:GetDes(),9);
	--
	local superStr = self:GetSuper();
	if superStr ~= "" then
		superStr = self:SetLeftMargin(superStr,9);
		self.str = self.str .. superStr;
	end
	--
	local cdStr = self:GetCD();
	if cdStr then
		cdStr = self:SetLeftMargin(cdStr,9);
		self.str = self.str .. cdStr;
	end
	local useNumStr = self:GetUseNum();
	if useNumStr ~= "" then
		useNumStr = self:SetLeftMargin(useNumStr,9);
		self.str = self.str .. useNumStr;
	end
	local reuseStr = self:GetReuse();
	if reuseStr ~= "" then
		reuseStr = self:SetLeftMargin(reuseStr,9);
		self.str = self.str .. reuseStr;
	end
	--
	local fromStr = self:GetFrom();
	if fromStr ~= "" then
		fromStr = self:SetLeftMargin(fromStr,9);
		self.str = self.str .. self:GetLine();
		self.str = self.str .. fromStr;
	end
	--
	local storyStr = self:GetStory();
	if storyStr then
		storyStr = self:SetLeftMargin(storyStr,9);
		self.str = self.str .. self:GetLine();
		self.str = self.str .. storyStr;
	end
	--
	local showStr = self:GetShowInfo();
	local sellStr = self:GetSellInfo();
	if showStr~="" and sellStr~="" then
		self.str = self.str .. self:GetLine();
	end
	if showStr ~= "" then
		showStr = self:SetLeftMargin(showStr,9);
		self.str = self.str .. showStr;
		self.str = self.str .. self:GetVGap(10);
	end
	if sellStr ~= "" then
		self.str = self.str .. self:GetSellInfo();
	end
	
	if isDebug then
		self.str = self.str .. self:GetLine();
		self.str = self.str .. self:GetHtmlText(self.tipsVO.id);
	end
end

function RingTips:GetIconUrl()
	return self.tipsVO.iconUrl;
end

function RingTips:GetShowBiao()
	if self.tipsVO.cfg.identifying == "" then return ""; end
	local t = split(self.tipsVO.cfg.identifying,"#");
	for _,s in ipairs(t) do
		if s:lead("lable") then
			return ResUtil:GetTipsBiaoShiUrl(s);
		end
	end
	return "";
end

function RingTips:GetIconLevelUrl()
	if self.tipsVO.cfg.identifying == "" then return ""; end
	local t = split(self.tipsVO.cfg.identifying,"#");
	for _,s in ipairs(t) do
		if s:lead("num") then
			return ResUtil:GetBiaoShiUrl(s);
		end
	end
	return "";
end

function RingTips:GetWidth()
	return 318;
end

function RingTips:GetIconPos()
	return {x=26,y=23};
end

function RingTips:GetQualityUrl()
	local surl = BagUtil:GetSSlotQuality(self.tipsVO.id, 54);
	if surl then return surl; end
	return ResUtil:GetSlotQuality(self.tipsVO.cfg.quality, 54);
end

function RingTips:GetQuality()
	return self.tipsVO.cfg.quality;
end

function RingTips:GetModelDrawClz()
	if BagUtil:IsItemFashion(self.tipsVO.cfg.id) then
		return ItemFashionTipsDraw;
	end
	if self.tipsVO.cfg.modelDraw == "" then
		return nil;
	end
	return RingTipsDraw;
end

function RingTips:GetModelDraw()
	if BagUtil:IsItemFashion(self.tipsVO.cfg.id) then
		return ItemFashionTipsDraw:new();
	end
	if self.tipsVO.cfg.modelDraw == "" then
		return nil;
	end
	return RingTipsDraw:new();
end

function RingTips:GetModelDrawArgs()
	if BagUtil:IsItemFashion(self.tipsVO.cfg.id) then
		return {self.tipsVO.cfg.fashion};
	end
	return {self.tipsVO.cfg.id};
end

function RingTips:GetDebugInfo()
	if isDebug then
		return "/createitem/"..self.tipsVO.cfg.id.."/99"
	end
	return nil;
end

--标题
function RingTips:GetTitle()
	local str = "";
	str = str .. self:GetVGap(13);
	str = str .. "<textformat leftmargin='100' leading='7'>";
	str = str .. self:GetHtmlText(self.tipsVO.cfg.name,TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality),TipsConsts.TitleSize_One,true);
	if self.tipsVO.cfg.sub ~= 7 then
		local bindStr = BagConsts:GetBindName(self.tipsVO.bindState);
		if bindStr == "" then
			str = str .. "<br/>";
		else
			bindStr = self:GetHtmlText(bindStr,"#3bde1b",TipsConsts.Default_Size,false);
			str = str .. bindStr .."<br/>";
		end
		local levelStr = "";
		if self.tipsVO.levelAccord then
			levelStr = self:GetHtmlText(self.tipsVO.needLevel,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
		else
			levelStr = self:GetHtmlText(self.tipsVO.needLevel,TipsConsts.ForbidColor,TipsConsts.Default_Size,false);
		end
		str = str .. self:GetHtmlText(string.format(StrConfig["tips1"],levelStr));  --需要等级
	else
		str = str .. "<br/><br/>";
	end
	str = str .. "</p></textformat>"
	return str;
end

--描述
function RingTips:GetDes()
	local str = "";
	if self.tipsVO.cfg.summary ~= "" then
		str = str .. self:GetHtmlText(self.tipsVO.cfg.summary,"#ffcc33",TipsConsts.Default_Size);
	end
	str = str .. self:GetHtmlText(self.tipsVO.cfg.detail, TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	str = self:SetLineSpace(str,5);

	local lvl = self.tipsVO.ringLvl;
	if not lvl then 
		lvl = 0;
	end;
	if not self.tipsVO.ringType or self.tipsVO.ringType == 0 then 
		for i,info in ipairs(t_marryRing) do 
			if info.itemId == self.tipsVO.id then 
				self.tipsVO.ringType = info.id;
			end;
		end;
	end;
	local ringCfg = t_marryRing[self.tipsVO.ringType];
	if not ringCfg then 
		--print(self.tipsVO.ringType,debug.traceback())
		return str;
	end;

	local atbl = AttrParseUtil:Parse(ringCfg.attr)
	if lvl > 0 then 
		local addVal = t_marryIntimate[lvl].attrExtraPercent;
		for cc,pp in pairs(atbl) do 
			pp.val = pp.val * (1 + addVal /100)
		end;
	end;

	local strenCfg = t_marrystren[self.tipsVO.ringStren];
	if not strenCfg then 
		strenCfg = {};
	end;
	local strenList = AttrParseUtil:Parse(strenCfg.attr);
	local baseAtb = AttrParseUtil:Parse(ringCfg.attr)

	local addVal =strenCfg.times / 100;
	for ba,vao in pairs(baseAtb) do
		vao.val = vao.val * addVal;
		for sv,sa in pairs(strenList) do 
			if sa.type == vao.type then 
				vao.val = vao.val + sa.val;
				break;
			end;
		end;
	end;
	str = str .. self:GetVGap(5);
	for i,vo in pairs(atbl) do
		local attrStr = "";
		attrStr = attrStr .. "<textformat leading='-16' leftmargin='6'><p>";
		attrStr = attrStr .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		attrStr = attrStr .. "</p></textformat>";
		attrStr = attrStr .. "<textformat leading='-14' leftmargin='28'><p>";
		attrStr = attrStr .. enAttrTypeName[vo.type] .. " +" .. getAtrrShowVal(vo.type,vo.val)
		for ad,bas in pairs(baseAtb) do 
			if bas.type == vo.type then
				attrStr = attrStr .. "<textformat leading='-8' leftmargin='120'><p>";
				attrStr = attrStr ..  "强化+"..bas.val;
				attrStr = attrStr .. "</p></textformat>";
				break;
			end;
		end;
		attrStr = attrStr .. "</p></textformat>";
		str = str .. self:GetHtmlText(attrStr,"#3ed866",TipsConsts.Default_Size,false);
	end;
	return str;
end

--卓越属性
function RingTips:GetSuper()
	if not self.tipsVO.itemSuperVO then
		return "";
	end
	local vo = self.tipsVO.itemSuperVO;
	local cfg = t_fujiashuxing[vo.id];
	local attrStr = self:GetVGap(5);
	attrStr = attrStr .. "<textformat leading='-14' leftmargin='9'><p>";
	attrStr = attrStr .. string.format("「%s」",cfg.name);
	attrStr = attrStr .. "</p></textformat>";
	attrStr = attrStr .. "<textformat leftmargin='95'><p>";
	attrStr = attrStr .. formatAttrStr(cfg.attrType,vo.val1);
	attrStr = attrStr .. "</p></textformat>";
	attrStr = self:GetHtmlText(attrStr,TipsConsts.SuperColor,TipsConsts.Default_Size);
	attrStr = attrStr .. "<textformat leading='7'>";
	attrStr = attrStr .. self:GetHtmlText(StrConfig['tips1311']);
	attrStr = attrStr .. "</p></textformat>";
	attrStr = attrStr .. self:GetHtmlText(StrConfig['tips1312']);
	return attrStr;
end

--CD
function RingTips:GetCD()
	if self.tipsVO.cfg.cd == 0 then
		return nil;
	end
	local cd = toint(self.tipsVO.cfg.cd/1000,-1);
	local str = self:GetVGap(20-5);
	str = str .. self:GetHtmlText(string.format(StrConfig['tips1313'],cd));
	return str;
end

--物品使用数量
function RingTips:GetUseNum()
	if self.tipsVO.cfg.limit_show ~= 0 then
		return "";
	end
	local str = "";
	if BagModel:GetDailyLimit(self.tipsVO.cfg.id) > 0 then
		str = str .. self:GetVGap(15);
		local dailyUseNum = BagModel:GetDailyUseNum(self.tipsVO.cfg.id);
		local totalNumNoVip = BagModel:GetDailyTotalWithOutVipNum(self.tipsVO.cfg.id)
		local vipUseNum = 0
		
		if dailyUseNum > totalNumNoVip then
			vipUseNum = dailyUseNum - totalNumNoVip
			dailyUseNum = totalNumNoVip
		end
		
		local vipNumTips = BagModel:GetDailyExtraNumTips(self.tipsVO.cfg.id, vipUseNum)
		str = str .. self:GetHtmlText(string.format(StrConfig["tips9"],dailyUseNum,totalNumNoVip),"#b86f11");
		if vipNumTips ~= '' then
			str = str .. self:GetHtmlText(vipNumTips,"#00ff00");
		end
		str = self:SetLineSpace(str,5);
	end
	-- if self.tipsVO.cfg.life_limit > 0 then
		-- str = str .. self:GetVGap(15);
		-- local lifeUseNum = BagModel:GetLifeUseNum(self.tipsVO.cfg.id);
		-- str = str .. self:GetHtmlText(string.format(StrConfig["tips10"],lifeUseNum,self.tipsVO.cfg.life_limit),"#b86f11");
	-- end
	return str;
end

--可重复使用的物品
function RingTips:GetReuse()
	local str = "";
	if self.tipsVO.cfg.reuse_all == 0 then
		return str;
	end
	str = str .. self:GetVGap(15);
	local totalNum = self.tipsVO.cfg.reuse_all;
	str = str .. self:GetHtmlText(string.format(StrConfig['tips1314'],self.tipsVO.reuseNum,totalNum),"#00ff00");
	if self.tipsVO.cfg.limit_show == 0 then
		local dayNum = self.tipsVO.cfg.reuse_day;
		str = str .. self:GetHtmlText(string.format(StrConfig['tips1315'],self.tipsVO.reuseDayNum,dayNum),"#00ff00");
		str = self:SetLineSpace(str,5);
	end
	return str;
end

--获取方式
function RingTips:GetFrom()
	if self.tipsVO.cfg.from == "" then
		return "";
	end
	local str = "";
	str = str .. self:GetHtmlText(StrConfig["tips8"],"#e59607",TipsConsts.TitleSize_Two);
	str = str .. self:GetHtmlText(self.tipsVO.cfg.from,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	str = self:SetLineSpace(str,5);
	return str;
end

--剧情
function RingTips:GetStory()
	if self.tipsVO.cfg.story == "" then
		return nil;
	end
	local str = self:GetHtmlText(self.tipsVO.cfg.story,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	str = self:SetLineSpace(str,5);
	return str;
end

--展示信息
function RingTips:GetShowInfo()
	if not self.tipsVO.isInBag then return ""; end
	return self:GetHtmlText(StrConfig["tips3"],"#d5b772",TipsConsts.Default_Size,false);
end

--出售信息
function RingTips:GetSellInfo()
	if not self.tipsVO.isInBag then return ""; end
	local str = "";
	if self.tipsVO.cfg.sell then
		str = str .. self:GetHtmlText(StrConfig["tips4"],"#e59507",TipsConsts.Default_Size,false);
		local s = string.format(StrConfig["tips5"],self.tipsVO.count,self.tipsVO.count*self.tipsVO.cfg.price);
		str = str .. self:GetHtmlText(s,"#e59507",TipsConsts.Default_Size,false);
	else
		str = str .. self:GetHtmlText(StrConfig["tips6"],"#e59507",TipsConsts.Default_Size,false);
	end
	str = "<textformat rightmargin='11'><p align='right'>" .. str .. "</p></textformat>";
	return str;
end

--得到tips显示类型
function RingTips:GetTipsType(  )
	return TipsConsts.Type_Ring
end



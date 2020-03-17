--[[
物品Tips
lizhuangzhuang
2014年8月15日15:53:25
]]

_G.ItemTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_Item,ItemTips);

ItemTips.tipsVO = nil;

function ItemTips:Parse(tipsInfo)
	self.tipsVO = tipsInfo;
	--
	self.str = "";
	self.str = self.str .. self:GetTitle0();
	self.str = self.str .. self:GetTitle();
	self.str = self.str .. self:GetLine(45,10);
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
	if self.tipsVO.cfg.sub == 30 then
		local reuseStr = self:GetUseNum1();
		if reuseStr ~= "" then
			reuseStr = self:SetLeftMargin(reuseStr,9);
			self.str = self.str .. reuseStr;
		end
	else
		local reuseStr = self:GetReuse();
		if reuseStr ~= "" then
			reuseStr = self:SetLeftMargin(reuseStr,9);
			self.str = self.str .. reuseStr;
		end
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

function ItemTips:GetIconUrl()
	return self.tipsVO.iconUrl;
end

function ItemTips:GetShowBiao()
	if self.tipsVO.cfg.identifying == "" then return ""; end
	local t = split(self.tipsVO.cfg.identifying,"#");
	for _,s in ipairs(t) do
		if s:lead("lable") then
			return ResUtil:GetTipsBiaoShiUrl(s);
		end
	end
	return "";
end

function ItemTips:GetIconLevelUrl()
	if self.tipsVO.cfg.identifying == "" then return ""; end
	local t = split(self.tipsVO.cfg.identifying,"#");
	for _,s in ipairs(t) do
		if s:lead("num") then
			return ResUtil:GetBiaoShiUrl(s);
		end
	end
	return "";
end

function ItemTips:GetWidth()
	return 318;
end

function ItemTips:GetIconPos()
	return {x=26,y=28};
end

function ItemTips:GetQualityUrl()
	local surl = BagUtil:GetSSlotQuality(self.tipsVO.id, 54);
	if surl then return surl; end
	return ResUtil:GetSlotQuality(self.tipsVO.cfg.quality, 54);
end

function ItemTips:GetQuality()
	return self.tipsVO.cfg.quality;
end

function ItemTips:GetModelDrawClz()
	if BagUtil:IsItemFashion(self.tipsVO.cfg.id) then
		return ItemFashionTipsDraw;
	end
	if self.tipsVO.cfg.modelDraw == "" then
		return nil;
	end
	return ItemTipsDraw;
end

function ItemTips:GetModelDraw()
	if BagUtil:IsItemFashion(self.tipsVO.cfg.id) then
		return ItemFashionTipsDraw:new();
	end
	if self.tipsVO.cfg.modelDraw == "" then
		return nil;
	end
	return ItemTipsDraw:new();
end

function ItemTips:GetModelDrawArgs()
	if BagUtil:IsItemFashion(self.tipsVO.cfg.id) then
		return {self.tipsVO.cfg.fashion};
	end
	return {self.tipsVO.cfg.id};
end

function ItemTips:GetDebugInfo()
	if isDebug then
		return "/createitem/"..self.tipsVO.cfg.id.."/99"
	end
	return nil;
end

--changer：houxudong  date：2016/8/15 23:09:05
function ItemTips:GetTitle0()
	local str = "";
	str = str .. self:GetVGap(10);
	local lens = math.floor(string.len(self.tipsVO.cfg.name)/2)*TipsConsts.BlackNew_Size
	local pos = self:GetWidth()/2 - lens/2
	if string.len(self.tipsVO.cfg.name)/2 <= 5 then
		pos = pos - 15;
	end
	pos = math.floor(pos)
	str = str .. "<textformat leftmargin='"..pos.."' leading='5'><p>";
	str = str .. self:GetHtmlText(self.tipsVO.cfg.name,TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality),TipsConsts.BlackNew_Size,true);
	str = str .. "</p></textformat>"
	return str;
end

--标题
function ItemTips:GetTitle()
	local str = "";
	str = str .. self:GetVGap(13);
	str = str .. "<textformat leftmargin='100' leading='10'>";
	--str = str .. self:GetHtmlText(self.tipsVO.cfg.name,TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality),TipsConsts.TitleSize_One,true);
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
		str = str .. self:GetHtmlText(string.format(StrConfig["tips1"],levelStr));   --需要等级
	else
		str = str .. "<br/><br/><br></br>";
	end
	str = str .. "</p></textformat>"
	return str;
end

--描述
function ItemTips:GetDes()
	local str = "";
	if self.tipsVO.cfg.summary ~= "" then
		str = str .. self:GetHtmlText(self.tipsVO.cfg.summary,"#ffcc33",TipsConsts.Default_Size);
	end
	str = str .. self:GetHtmlText(self.tipsVO.cfg.detail, TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	str = self:SetLineSpace(str,5);
	return str;
end

--卓越属性
function ItemTips:GetSuper()
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
function ItemTips:GetCD()
	if self.tipsVO.cfg.cd == 0 then
		return nil;
	end
	local cd = toint(self.tipsVO.cfg.cd/1000,-1);
	local str = self:GetVGap(20-5);
	str = str .. self:GetHtmlText(string.format(StrConfig['tips1313'],cd));
	return str;
end

--物品使用数量
function ItemTips:GetUseNum()
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
		-- 今日使用
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

--按天使用的物品
function ItemTips:GetUseNum1()
	local str = "";
	if self.tipsVO.cfg.reuse_all == 0 then
		return str;
	end
	str = str .. self:GetVGap(15);
	local totalNum = self.tipsVO.cfg.reuse_all; -- 7
	str = str .. self:GetHtmlText(string.format(StrConfig['tips1314'],self.tipsVO.reuseNum,totalNum),"#00ff00");
	if self.tipsVO.cfg.limit_show == 0 then
		local dayNum = self.tipsVO.reuse_day or 1;
		if dayNum > totalNum then
			dayNum = totalNum
		end
		str = str .. self:GetHtmlText(string.format(StrConfig['tips1315'],self.tipsVO.reuseDayNum,dayNum - self.tipsVO.reuseNum + self.tipsVO.reuseDayNum),"#00ff00");
		str = self:SetLineSpace(str,5);
	end
	return str;
end

--可重复使用的物品
function ItemTips:GetReuse()
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
function ItemTips:GetFrom()
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
function ItemTips:GetStory()
	if self.tipsVO.cfg.story == "" then
		return nil;
	end
	local str = self:GetHtmlText(self.tipsVO.cfg.story,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	str = self:SetLineSpace(str,5);
	return str;
end

--展示信息
function ItemTips:GetShowInfo()
	if not self.tipsVO.isInBag then return ""; end
	return self:GetHtmlText(StrConfig["tips3"],"#d5b772",TipsConsts.Default_Size,false);
end

--出售信息
function ItemTips:GetSellInfo()
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
function ItemTips:GetTipsType(  )
	return TipsConsts.Type_Item
end

function ItemTips:GetItemID()
	return self.tipsVO.itemID
end




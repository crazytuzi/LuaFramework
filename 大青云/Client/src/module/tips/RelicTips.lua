--[[
	装备Tips
	chenyujia
	2016年11月14日11:23:48
]]

_G.RelicTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_Relic,RelicTips);

RelicTips.tipsVO = nil;

function RelicTips:Parse(tipsInfo)
	-- trace(tipsInfo)
	self.tipsVO = tipsInfo;
	--头标题
	self.str = "";
	self.str = self.str .. self:GetTitle();    --装备最顶层名字信息
	self.str = self.str .. self:GetTitleTwo(); --五条文本属性
	self.str = self.str .. self:GetLine(5);

	if self:GetModelDrawClz() then
		self.str = self.str .. self:GetVGap(self:GetModelDrawClz():GetHeight());
		self.str = self.str .. self:GetLine(10);
	end

	self.str = self.str .. self:SetLeftMargin(self:GetDes(), 6);
	self.str = self.str .. self:GetLine(10)

	--获取基础属性
	self.str = self.str .. self:GetBaseAttr();   ---获取基础属性

	--获取方式
	local fromStr = self:GetFrom();
	if fromStr ~= "" then
		fromStr = self:SetLeftMargin(fromStr,11);
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. fromStr;
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

	local storyStr = self:GetStory();
	if storyStr then
		storyStr = self:SetLeftMargin(storyStr,9);
		self.str = self.str .. self:GetLine();
		self.str = self.str .. storyStr;
	end
end

--描述
function RelicTips:GetDes()
	local str = "";
	if self.tipsVO.cfg.summary ~= "" then
		str = str .. self:GetHtmlText(self.tipsVO.cfg.summary, TipsConsts.TwoTitleColor, TipsConsts.TitleSize_Three);
	end
	str = str .. self:GetHtmlText(self.tipsVO.cfg.detail, TipsConsts.Default_Color,TipsConsts.Default_Size,true);
	str = self:SetLineSpace(str,5);
	return str;
end

function RelicTips:GetModelDrawArgs()
	return {self.tipsVO.cfg.id, 375, 215};
end

function RelicTips:GetIconUrl()
	return self.tipsVO.iconUrl;
end

function RelicTips:GetIconPos()
	return {x=35,y=35}
end

function RelicTips:GetRelicIcon()
	local lv = 0
	for k, v in pairs(t_newequip) do
		if v.itemid == self.tipsVO.id and v.lv == 1 then
			return ResUtil:GetRelicIconUrl(v.icon)
		end
	end
end

function RelicTips:GetWidth()
	return 421;
end

function RelicTips:GetShowBiao()
	if self.tipsVO.cfg.identifying == "" then return ""; end
	local t = split(self.tipsVO.cfg.identifying,"#");
	for _,s in ipairs(t) do
		if s:lead("lable") then
			return ResUtil:GetTipsBiaoShiUrl(s);
		end
	end
	return "";
end

function RelicTips:GetIconLevelUrl()
	if self.tipsVO.cfg.identifying == "" then return ""; end
	local t = split(self.tipsVO.cfg.identifying,"#");
	for _,s in ipairs(t) do
		if s:lead("num") then
			return ResUtil:GetBiaoShiUrl(s);
		end
	end
	return "";
end

function RelicTips:GetModelDraw()
	if self.tipsVO.cfg.modelDraw == "" then
		return nil;
	end
	return ItemTipsDraw:new()
end

function RelicTips:GetQualityUrl()
	return ResUtil:GetSlotQuality(self.tipsVO.cfg.quality, 54);
end

function RelicTips:GetQuality()
	return self.tipsVO.cfg.quality;
end

function RelicTips:GetTipsEffectUrl()
	-- return ResUtil:GetTipsQuality(self.tipsVO.cfg.quality);
end

function RelicTips:GetModelDrawClz()
	if self.tipsVO.cfg.modelDraw == "" then
		return nil;
	end
	return ItemTipsDraw;
end


function RelicTips:GetDebugInfo()
	if isDebug then
		return "/createitem/"..self.tipsVO.cfg.id.."/1";
	end
	return nil;
end

function RelicTips:GetTitleBg( )
	local str = "";
	str = str .. "<textformat leading='-32'><p>";  --</p>前面创建空白区域
	str = str .. "<img width='387' height='0' src='" .. ResUtil:GetTipsNameBgUrl() .. "'/>";
	str = str .. "</p></textformat>";
	return str;
end

--第一级标题
function RelicTips:GetTitle()
	local str = "";
	str = str .. self:GetVGap(13);  --居中

	local name = self.tipsVO.cfg.name;   --配置名字
	local param1 = self.tipsVO.param1
	if not param1 or param1 == 0 then
		param1 = BagUtil:GetRelicId(self.tipsVO.id)
	end

	name = name .. " +" .. t_newequip[param1].lv

	local lens = string.len(name)/2*25
	local pos = self:GetWidth()/2 - lens/2
	pos = math.ceil(pos)
	str = str .. "<textformat leftmargin ='"..pos.. "'leading='0'><p>"

	str = str .. self:GetHtmlText(name,TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality),TipsConsts.BlackNew_Size,false);

	str = str .."</p></textformat>"
	return str;
end

--获取武器职业等信息,包括icon，职业，评分等信息
--leading : 行间距
function RelicTips:GetTitleTwo()
	local str = "";
	str = str .. self:GetVGap(18);
	--
	str = str .. "<textformat leftmargin='115' leading='7'>";       --绑定状态
	local bindStr = BagConsts:GetBindName(self.tipsVO.bindState);
	str = str .. self:GetHtmlText(bindStr,TipsConsts.greenColor,TipsConsts.Small_Size);
	str = str .. "</textformat>";

	if self.tipsVO.cfg.quality>4 then
		str = str .. "<textformat leftmargin='250' leading='2'><p><img width='113' height='34' src='" .. ResUtil:GetTipsZhandouliUrlMax() .. "'/></p></textformat>";
	else	
		str = str .. "<textformat leftmargin='250' leading='2'><p><img width='71' height='25' src='" .. ResUtil:GetTipsZhandouliUrlSmall() .. "'/></p></textformat>";
	end

	--装备评分战斗力
	local BaseScore = self.tipsVO:GetTotalFight();
	if BaseScore < 99999 then
		str = str .. "<textformat leftmargin='260' leading='7'><p>".. self:GetBaseFightNum(BaseScore) .."</textformat>";
	else
		str = str .. "<textformat leftmargin='200' leading='7'><p>".. self:GetBaseFightNum(BaseScore) .."</textformat>";
	end
	str = str .. "</p></textformat>";
	local param1 = self.tipsVO.param1
	if not param1 or param1 == 0 then
		param1 = BagUtil:GetRelicId(self.tipsVO.id)
	end
	-- str = str .. self:GetVGap(12);
	str = str .. "<textformat leftmargin='15' leading='7'>";   
	str = str .. self:GetHtmlText("当前精炼等级：" .. "+" .. t_newequip[param1].lv,"#00ff00",TipsConsts.Default_Size)
	str = str .. "</textformat>";
	return str;
end

--获取战斗力num
function RelicTips:GetFightNum(num)
	local str = "";
	local numStr = tostring(num);
	if not numStr then return""; end
	for i=1,#numStr do
		local img = ResUtil:GetNewSmTipsNum(string.sub(numStr,i,i))
		str = str .. "<img src='" .. ResUtil:GetNewSmTipsNum(string.sub(numStr,i,i)) .. "'/>";
	end
	return str;
end

--获取基础评分num
function RelicTips:GetBaseFightNum(num)
	local str = "";
	if num < 9999 then
		str = "<align='right'>";
	else
		str = "<align='right'>";
	end
	local numStr = tostring(num);
	if not numStr then return""; end
	for i=1,#numStr do 
		str = str .. "<img vspace='-3' src='" .. ResUtil:GetNewTipsNum(string.sub(numStr,i,i)) .. "'/>";
	end
	str = str.."</>";
	return str;
end
--------------------------------------------------------Data----------------------------------------------


--基础属性  adder: houxudong date:2016/6/25 
function RelicTips:GetBaseAttr()
	local str = "";
	local list = self.tipsVO:GetRelicAttr();
	if #list == 0 then return ""; end
	--@二级标签
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText("精炼属性：",TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);

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
	end
	
	return str;
end

--获取方式
function RelicTips:GetFrom()
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
	local leading = 4;
	str = str ..  "<textformat leading='" .. leading .."' leftmargin='23'>";
	str = str .. self:GetHtmlText(self.tipsVO.cfg.from,TipsConsts.GetPathColor,TipsConsts.Default_Size,false);
	str = self:SetLineSpace(str,5);
	return str;
end

--展示信息
function RelicTips:GetShowInfo()
	if not self.tipsVO.isInBag then return ""; end
	return self:GetHtmlText(StrConfig["tips3"],TipsConsts.Default_Color,TipsConsts.Default_Size,false);
end

--出售信息
function RelicTips:GetSellInfo()
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

--剧情
function RelicTips:GetStory()
	if self.tipsVO.cfg.story == "" then
		return nil;
	end
	local str = self:GetHtmlText(self.tipsVO.cfg.story,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	str = self:SetLineSpace(str,5);
	return str;
end

function RelicTips:OnGetUnionContr()
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
function RelicTips:GetTipsType()
	return TipsConsts.Type_Relic
end
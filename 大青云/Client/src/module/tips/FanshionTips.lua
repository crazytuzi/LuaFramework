--[[
时装Tips
lizhuangzhuang
2015年3月16日17:02:00
]]

_G.FanshionTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_Fanshion,FanshionTips);

FanshionTips.tipsVO = nil;

function FanshionTips:Parse(tipsInfo)
	self.tipsVO = tipsInfo;
	--
	self.str = "";
	self.str = self.str .. self:SetLeftMargin(self:GetTitle(),11);
	self.str = self.str .. self:GetVGap(45,10);
	self.str = self.str .. self:GetTitle2();
	self.str = self.str .. self:GetVGap(5);
	self.str = self.str .. self:GetLine(10);
	--
	self.str = self.str .. self:SetLeftMargin(self:GetAttr(),11);
	self.str = self.str .. self:GetVGap(5);
	self.str = self.str .. self:SetLeftMargin(self:GetGroupStr(),11);
	self.str = self.str .. self:GetLine(10);
	--
	local timeStr = self:GetLastTime();
	if timeStr ~= "" then
		timeStr = self:SetLeftMargin(timeStr,11);
		self.str = self.str .. timeStr;
		self.str = self.str .. self:GetLine(10);
	end
	--
	self.str = self.str .. self:SetLeftMargin(self:GetFrom(),11);
end

function FanshionTips:GetIconUrl()
	local stricon = MountUtil:GetListString(self.tipsVO.cfg.icon, MainPlayerModel.humanDetailInfo.eaProf);
	return ResUtil:GetFanshionsIconImg(stricon,"54");
end

function FanshionTips:GetIconPos()
	return {x=26,y=26};
end

function FanshionTips:GetWidth()
	return 403;
end

function FanshionTips:GetShowEquiped()
	return false;
end

function FanshionTips:GetTitle()
	local str = "";
	str = str .. self:GetVGap(13);
	str = str .. self:GetHtmlText(self.tipsVO.cfg.name,"#b400ff",TipsConsts.TitleSize_One,false);
	return str;
end

function FanshionTips:GetTitle2()
	local str = "";
	str = str .. self:GetVGap(5);
	--
	str = str .. "<p><textformat leftmargin='100' leading='5'>";
	if self.tipsVO.cfg.pos == 1 then
		str = str .. self:GetHtmlText(StrConfig["tips801"],"#8cbbd3",TipsConsts.TitleSize_Two);
	elseif self.tipsVO.cfg.pos == 2 then
		str = str .. self:GetHtmlText(StrConfig["tips802"],"#8cbbd3",TipsConsts.TitleSize_Two);
	else
		str = str .. self:GetHtmlText(StrConfig["tips803"],"#8cbbd3",TipsConsts.TitleSize_Two);
	end
	str = str .. "</textformat>";
	--
	str = str .. "<textformat leftmargin='100' leading='5'>";
	str = str .. self:GetHtmlText(StrConfig["tips805"],TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	str = str .. "</textformat></p>";
	--
	str = str .. "<textformat leftmargin='100' leading='-55'>";
	str = str .. self:GetHtmlText(StrConfig["tips804"]);
	str = str .. "</textformat>";
	--
	str = str .. "<textformat leftmargin='240' leading='3'><p><img width='71' height='25' src='" .. ResUtil:GetTipsZhandouliUrlSmall() .. "'/></p></textformat>";
	--
	local attrlist = AttrParseUtil:Parse(self.tipsVO.cfg.attr);
	local zhandouli = EquipUtil:GetFight(attrlist);
	if zhandouli < 9999 then
		str = str .. "<textformat leftmargin='240' leading='0'>".. self:GetFightNum(zhandouli) .."</textformat>";
	else
		str = str .. "<textformat leftmargin='200' leading='0'>".. self:GetFightNum(zhandouli) .."</textformat>";
	end
	return str;
end

--获取战斗力num
function FanshionTips:GetFightNum(num)
	local str = "";
	if num < 9999 then
		str = "<p>";
	else
		str = "<p align='right'>";
	end
	local numStr = tostring(num);
	if not numStr then return""; end
	for i=1,#numStr do
		str = str .. "<img src='" .. ResUtil:GetTipsNum(string.sub(numStr,i,i)) .. "'/>";
	end
	str = str .. "</p>";
	return str;
end

--获取属性
function FanshionTips:GetAttr()
	local str = "";
	str = str .. self:GetHtmlText(StrConfig["tips806"],"#8cbbd3",TipsConsts.TitleSize_Two);
	str = str .. self:GetVGap(5);
	local list = AttrParseUtil:Parse(self.tipsVO.cfg.attr);
	for i=1,#list do
		local attrStr = "";
		attrStr = enAttrTypeName[list[i].type] .. " +" .. getAtrrShowVal(list[i].type,list[i].val);
		attrStr = self:GetHtmlText(attrStr,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
		attrStr = "<textformat leading='7' leftmargin='11'><p>" .. attrStr .. "</p></textformat>";
		str = str .. attrStr;
	end
	return str;
end

--获取套装信息
function FanshionTips:GetGroupStr()
	local str = "";
	local groupCfg = t_fashiongroup[self.tipsVO.cfg.suit];
	local list = {};
	local num = 0;
	for id,cfg in pairs(t_fashions) do
		if cfg.suit == self.tipsVO.cfg.suit then
			if FashionsUtil:GetisHaveFashions(id) then
				list[id] = true;
				num = num + 1;
			else
				list[id] = false;
			end
		end
	end
	--
	str = str .. self:GetHtmlText(string.format(StrConfig["tips807"],groupCfg.name,num,3),"#65c47e");
	str = str .. self:GetVGap(5);
	--
	for id,v in pairs(list) do
		local cfg = t_fashions[id];
		local s = "";
		if v then
			s = self:GetHtmlText(cfg.name,"#65c47e",TipsConsts.Default_Size,false);
		else
			s = self:GetHtmlText(cfg.name,"#5a5a5a",TipsConsts.Default_Size,false);
		end
		str = str .. "<textformat leading='5' leftmargin='11'><p>" .. s .. "</p></textformat>";
	end
	--
	local attrStr = "";
	local attrlist = AttrParseUtil:Parse(groupCfg.Attr);
	for i=1,#attrlist do
		attrStr = attrStr .. enAttrTypeName[attrlist[i].type] .. " +" .. getAtrrShowVal(attrlist[i].type,attrlist[i].val);
		attrStr = attrStr .. " ";
	end
	if num == 3 then
		str = str .. self:GetHtmlText(string.format(StrConfig['tips808'],attrStr),"#65c47e",TipsConsts.Default_Size);
	else
		str = str .. self:GetHtmlText(string.format(StrConfig['tips808'],attrStr),"#5a5a5a",TipsConsts.Default_Size);
	end
	return str;
end

--获取描述信息
function FanshionTips:GetFrom()
	return self:GetHtmlText(self.tipsVO.cfg.from,"#b86f11",TipsConsts.Default_Size,false);
end

--获取剩余时间
function FanshionTips:GetLastTime()
	if not self.tipsVO.cfg.lastTime then
		return "";
	end
	if self.tipsVO.cfg.lastTime < 0 then
		return "";
	end
	local str = "";
	local hour,min,sec =  CTimeFormat:sec2format(self.tipsVO.cfg.lastTime);
	str = str .. self:GetHtmlText(string.format(StrConfig["tips809"],hour,min,sec),"#dc2f2f",TipsConsts.Default_Size,false);
	return str;
end

--得到tips显示类型
function FanshionTips:GetTipsType(  )
	return TipsConsts.Type_Fanshion
end

--[[
卓越连锁tips
lizhuangzhuang
2015年2月11日17:55:27
]]

_G.NewSuperLinkTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_NewSuperLink,NewSuperLinkTips);

NewSuperLinkTips.tipsVo = nil;

function NewSuperLinkTips:Parse(tipsInfo)
	self.tipsVo = tipsInfo;
	--当前等级
	self.str = "";
	self.str = self.str .. self:GetTitle(self.tipsVo.linkId,self.tipsVo.linkNum);
	self.str = self.str .. self:GetVGap(13);
	self.str = self.str .. self:SetLeftMargin(self:GetAttr(self.tipsVo.linkId,self.tipsVo.linkNum),5);
	--下级
	if self.tipsVo.nextLinkId then
		self.str = self.str .. self:GetVGap(15);
		self.str = self.str .. self:GetTitle(self.tipsVo.nextLinkId,self.tipsVo.nextLinkNum);
		self.str = self.str .. self:GetVGap(13);
		self.str = self.str ..self:SetLeftMargin(self:GetAttr(self.tipsVo.nextLinkId,self.tipsVo.nextLinkNum),5);
	end
end

function NewSuperLinkTips:GetShowIcon()
	return false;
end

function NewSuperLinkTips:GetWidth()
	return 180;
end

function NewSuperLinkTips:GetTitle(linkId,linkNum)
	local cfg = t_zhuoyuelink[linkId];
	if not cfg then return ""; end
	local str = "";
	str = str .. self:GetVGap(5);
	str = str .. "<textformat leftmargin='5'>";
	str = str .. self:GetHtmlText(cfg.name,"#ffcc33",TipsConsts.TitleSize_Two,false);
	str = str .. "</textformat>";
	str = str .. self:GetLine(10,13);
	--
	str = str .. "<textformat leftmargin='5'>";
	str = str .. self:GetHtmlText(StrConfig['tips1310'],"#e59607",TipsConsts.Default_Size);
	str = str .. self:GetVGap(7);
	if linkNum < cfg.num then
		str = str .. self:GetHtmlText(string.format(StrConfig['tips1307'],linkNum,cfg.num),"#ff0000");
	else
		str = str .. self:GetHtmlText(string.format(StrConfig['tips1306'],linkNum,cfg.num),"#00ff00");
	end
	str = str .. "</textformat>";
	return str;
end

function NewSuperLinkTips:GetAttr(linkId,linkNum)
	local cfg = t_zhuoyuelink[linkId];
	if not cfg then return ""; end
	local str = "";
	str = str .. self:GetHtmlText(StrConfig['tips1308'],"#e59607",TipsConsts.TitleSize_Two);
	str = str .. self:GetVGap(5);
	local list = AttrParseUtil:Parse(cfg.attr);
	local attrStr = "";
	for i=1,#list do
		local attrStr = "";
		attrStr = enAttrTypeName[list[i].type];
		if linkNum >= cfg.num then
			attrStr = self:GetHtmlText(attrStr,"#d5b772",TipsConsts.Default_Size,false);
		else
			attrStr = self:GetHtmlText(attrStr,"#5a5a5a",TipsConsts.Default_Size,false);
		end
		attrStr = "<textformat leading='-14' leftmargin='5'><p>" .. attrStr .. "</p></textformat>";
		str = str .. attrStr;
		local leading = 0;
		if i < #list then
			leading = 5;
		end
		if attrIsPercent(list[i].type) then
			attrStr = "+" .. getAtrrShowVal(list[i].type,list[i].val);
		else
			attrStr = "+" .. getAtrrShowVal(list[i].type,list[i].val);
		end
		if linkNum >= cfg.num then
			attrStr = self:GetHtmlText(attrStr,"#00ff00",TipsConsts.Default_Size,false);
		else
			attrStr = self:GetHtmlText(attrStr,"#5a5a5a",TipsConsts.Default_Size,false);
		end
		attrStr = "<textformat leading='"..leading.."' leftmargin='100'><p>" .. attrStr .. "</p></textformat>";
		str = str .. attrStr;
	end
	return str;
end
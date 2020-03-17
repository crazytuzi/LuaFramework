--[[
翅膀tips
lizhuangzhuang
2015年7月7日15:52:35
]]

_G.WingTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_Wing,WingTips);

WingTips.tipsVO = nil;
WingTips.wingCfg = nil;

function WingTips:Parse(tipsInfo)
	self.tipsVO = tipsInfo;
	self.wingCfg = t_wing[self.tipsVO.cfg.link_param];
	if not self.wingCfg then
		return "";
	end
	--
	self.str = "";
	self.str = self.str .. self:GetTitle();
	self.str = self.str .. self:GetLine(10);
	--
	if self:GetModelDrawClz() then
		self.str = self.str .. self:GetVGap(self:GetModelDrawClz():GetHeight());
	end
	--
	self.str = self.str .. self:SetLeftMargin(self:GetTitle2(),11);
	self.str = self.str .. self:GetLine(10);
	--
	if self.tipsVO.wingAttrFlag then
		self.str = self.str .. self:GetSAttr();
		self.str = self.str .. self:GetLine(10);
	end
	self.str = self.str .. self:GetAttr();
	--
	local timeOutStr = self:GetTimeOut();
	if timeOutStr ~= "" then
		timeOutStr = self:SetLeftMargin(timeOutStr,9);
		self.str = self.str .. self:GetLine();
		self.str = self.str .. timeOutStr;
	end
	--对比属性
	local compareStr = self:GetCompareInfo();
	if compareStr ~= "" then
		compareStr = self:SetLeftMargin(compareStr,11);
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. compareStr;
	end
	
	--获取方式
	local fromStr = self:GetFrom();
	if fromStr ~= "" then
		fromStr = self:SetLeftMargin(fromStr,9);
		self.str = self.str .. self:GetLine();
		self.str = self.str .. fromStr;
	end
	
	if isDebug then
		self.str = self.str .. self:GetLine();
		self.str = self.str .. self:GetHtmlText(self.tipsVO.id);
	end
end

function WingTips:GetModelDrawClz()
	return WingTipsDraw;
end

function WingTips:GetModelDraw()
	return WingTipsDraw:new();
end

function WingTips:GetModelDrawArgs()
	return {self.tipsVO.cfg.link_param,self.tipsVO.cfg.id};
end

function WingTips:GetShowIcon()
	return false;
end

function WingTips:GetWidth()
	return 347;
end


function WingTips:GetTitle()
	local str = "";
	str = str .. self:GetVGap(13);
	local leading = 0;
	if self.tipsVO.equiped or self.tipsVO.wingStarLevel then
		leading = -18;
	end
	str = str .. "<textformat leftmargin='11' leading='".. leading .."'><p>";
	local name = string.format(StrConfig['tips1301'],self.tipsVO.cfg.name,UISpiritsSkillTips:GetNum(self.wingCfg.level));
	str = str .. self:GetHtmlText(name,TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality),
									TipsConsts.TitleSize_One,false);
	str = str .."</p></textformat>"
	
	if self.tipsVO.wingStarLevel then
		if self.tipsVO.equiped then
			str = str .. "<textformat leftmargin='160' leading='".. leading .."'><p>";
		else
			str = str .. "<textformat leftmargin='160'><p>";
		end
		local wingStarLevelStr = string.format(StrConfig['tips1343'],self.tipsVO.wingStarLevel);
		str = str .. self:GetHtmlText(wingStarLevelStr,TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality),
								TipsConsts.TitleSize_One,false);
		str = str .."</p></textformat>";
	end
	
	if self.tipsVO.equiped then
		str = str .. "<textformat leading='0' rightmargin='0'><p align='right'>";
		str = str ..  "<img width='71' height='22' src='" .. ResUtil:GetTipsEquipedUrl() .. "'/>";
		str = str .. "</p></textformat>";
	end
	return str;
end

function WingTips:GetTitle2()
	local str = "";
	local posName = UISpiritsSkillTips:GetNum(self.wingCfg.level)..StrConfig['tips1302'];
	str = str .. self:GetHtmlText(posName,"#ffffff",TipsConsts.Default_Size);
	str = str .. self:GetVGap(5);
	local bindStr = BagConsts:GetBindName(self.tipsVO.bindState);
	str = str .. self:GetHtmlText(bindStr,"#3bde1b",TipsConsts.Default_Size);
	return str;
end

--特殊属性
function WingTips:GetSAttr()
	local list = AttrParseUtil:Parse(self.wingCfg.sattr);
	local str = "";
	str = str .. self:GetVGap(5);
	for i,vo in ipairs(list) do
		local attrStr = "";
		attrStr = attrStr .. "<textformat leading='-16' leftmargin='6'><p>";
		attrStr = attrStr .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		attrStr = attrStr .. "</p></textformat>";
		attrStr = attrStr .. "<textformat leading='4' leftmargin='28'><p>";
		attrStr = attrStr .. enAttrTypeName[vo.type] .. " +" .. getAtrrShowVal(vo.type,vo.val);
		attrStr = attrStr .. "</p></textformat>";
		str = str .. self:GetHtmlText(attrStr,"#9967ff",TipsConsts.Default_Size,false);
	end
	return str;
end

--翅膀增加的属性
function WingTips:GetAttr()
	local list = AttrParseUtil:Parse(self.wingCfg.attr);
	local wingStarAttrList = nil;
	if self.tipsVO.wingStarLevel then
		wingStarAttrList = AttrParseUtil:Parse(t_wingequip[self.tipsVO.wingStarLevel].attr);
		local vo = wingStarAttrList[#wingStarAttrList];
		for i,vo in ipairs(wingStarAttrList) do
			local inType = false;
			for j , k in ipairs(list) do
				if k.type == vo.type then
					inType = true;
				end
			end
			if not inType then
				local _vo = {};
				_vo.type = vo.type;
				_vo.val = 0;
				table.push(list,_vo)
			end
		end
		wingStarAttrList = WingStarUtil:GetAllParseWingStarAttr(self.tipsVO.wingStarLevel,self.tipsVO.wingID,self.tipsVO.ismyself);
	end
	
	local str = "";
	str = str .. self:GetVGap(5);
	for i,vo in ipairs(list) do
		local attrStr = "";
		local leading = 4;
		local starattrvo = nil
		if wingStarAttrList then
			for j , _vo in ipairs(wingStarAttrList) do
				if _vo.type == vo.type then
					leading = -16;
					starattrvo = _vo;
				end
			end
		end
		attrStr = attrStr .. "<textformat leading='-16' leftmargin='6'><p>";
		attrStr = attrStr .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		attrStr = attrStr .. "</p></textformat>";
		attrStr = attrStr .. "<textformat leading='" .. leading .. "' leftmargin='28'><p>";
		attrStr = attrStr .. enAttrTypeName[vo.type] .. " +" .. getAtrrShowVal(vo.type,vo.val);
		attrStr = attrStr .. "</p></textformat>";
		
		if starattrvo then
			attrStr = attrStr .. "<textformat leading='4' leftmargin='160'><p>";
			attrStr = attrStr .. string.format(StrConfig['tips1344'],getAtrrShowVal(starattrvo.type,starattrvo.val));
			attrStr = attrStr .. "</p></textformat>";
		end
		
		str = str .. self:GetHtmlText(attrStr,"#3ed866",TipsConsts.Default_Size,false);
	end
	return str;
end
--获取翅膀的属性对比
function WingTips:GetCompareAttrList()
	if not self.tipsVO.compareTipsVO then
		return {};
	end
	
	--翅膀本身属性
	local list = AttrParseUtil:Parse(self.wingCfg.attr);
	local wingStarAttrList = nil;
	if self.tipsVO.wingStarLevel then
		wingStarAttrList = AttrParseUtil:Parse(t_wingequip[self.tipsVO.wingStarLevel].attr);
		local vo = wingStarAttrList[#wingStarAttrList];
		for i,vo in ipairs(wingStarAttrList) do
			local inType = false;
			for j , k in ipairs(list) do
				if k.type == vo.type then
					inType = true;
				end
			end
			if not inType then
				local _vo = {};
				_vo.type = vo.type;
				_vo.val = 0;
				table.push(list,_vo)
			end
		end
	end
	
	--对比翅膀属性
	local listC = AttrParseUtil:Parse(self.CWingCfg.attr);
	local wingStarAttrListC = nil;
	if self.tipsVO.compareTipsVO.wingStarLevel then
		wingStarAttrListC = AttrParseUtil:Parse(t_wingequip[self.tipsVO.compareTipsVO.wingStarLevel].attr);
		local vo = wingStarAttrListC[#wingStarAttrListC];
		for i,vo in ipairs(wingStarAttrListC) do
			local inType = false;
			for j , k in ipairs(listC) do
				if k.type == vo.type then
					inType = true;
				end
			end
			if not inType then
				local _vo = {};
				_vo.type = vo.type;
				_vo.val = 0;
				table.push(listC,_vo)
			end
		end
	end
	
	return EquipUtil:CompareAttr(list,listC);
end
--属性对比
--返回A相对B的属性变化
function WingTips:CompareAttr(attrListA,attrListB)
	local list = {};
	for i,attrA in ipairs(attrListA) do
		local hasFind = false;
		for j,attrB in ipairs(attrListB) do
			if attrA.type == attrB.type then
				local vo = {};
				vo.type = attrA.type;
				vo.val = attrA.val - attrB.val;
				table.push(list,vo);
				table.remove(attrListB,j,1);
				hasFind = true;
				break;
			end
		end
		if not hasFind then
			local vo = {};
			vo.type = attrA.type;
			vo.val = attrA.val;
			table.push(list,vo);
		end
	end
	for i,attrB in ipairs(attrListB) do
		local vo = {};
		vo.type = attrB.type;
		vo.val = -attrB.val;
		table.push(list,vo);
	end
	return list;
end
--翅膀到期
function WingTips:GetTimeOut()
	local str = "";
	if not self.tipsVO.wingTime then return ""; end
	if self.tipsVO.wingTime == -1 then return ""; end
	local now = GetServerTime();
	if self.tipsVO.wingTime > now then
		local hour,min,sec = CTimeFormat:sec2format(self.tipsVO.wingTime-now);
		str = str .. string.format(StrConfig['tips1303'],hour,min,sec);
		str = self:GetHtmlText(str,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	else
		str = self:GetHtmlText(StrConfig['tips1304'],TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	end
	return str;
end
--翅膀对比
function WingTips:GetCompareInfo()
	local str = "";
	if not self.tipsVO.compareTipsVO then
		return str;
	end
	if self.tipsVO.compareTipsVO.cfg.link_param == self.tipsVO.cfg.link_param then
		return str;
	end
	self.CWingCfg = t_wing[self.tipsVO.compareTipsVO.cfg.link_param];

	-- str = str .. self:GetHtmlText(StrConfig['tips1340'],"#be8c44",TipsConsts.TitleSize_Two);
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText(StrConfig["tips1340"],TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	-- str = str .. self:GetVGap(5);
	local attrChangeList = self:GetCompareAttrList();
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
				leftmargin = 150;
			end
		else
			if index%2 == 1 then
				leading = -16;
				leftmargin = 11;
			else
				leading = 7;
				leftmargin = 150;
			end
		end
		attrStr = "<textformat leading='".. leading .."' leftmargin='".. leftmargin .."'><p>" .. attrStr .. "</p></textformat>";
		str = str .. attrStr;
		index = index + 1;
	end
	return str;
end


--获取方式
function WingTips:GetFrom()
	if self.tipsVO.cfg.from == "" then
		return "";
	end
	local str = "";
	str = str .. self:GetHtmlText(self.tipsVO.cfg.from,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	str = self:SetLineSpace(str,5);
	return str;
end
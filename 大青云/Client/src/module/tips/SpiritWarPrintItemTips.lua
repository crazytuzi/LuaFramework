--[[
灵兽装备tips
wangshuai
]]

_G.SpiritWarprintItem = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_SpiritWarPrint,SpiritWarprintItem);


SpiritWarprintItem.tipsVo = nil;
SpiritWarprintItem.titleSizi = 15;

function SpiritWarprintItem:Parse(tipsInfo)
	self.tipsVO = tipsInfo;

	self.str = "";
	if self.tipsVO.cfg.ifequip == 1 then
		-- 经验丹
		self.str = self.str .. self:GetExpTitle();
		self.str = self.str .. self:GetLvl();
		self.str = self.str .. self:GetLine(75,5);
		self.str = self.str .. self:GetExpprint();

	else -- 装备
		self.str = self.str .. self:GetTitle();
		self.str = self.str .. self:GetLvl();
		self.str = self.str .. self:GetLine(75,5);
		self.str = self.str .. self:GetCurItemExp();
		self.str = self.str .. self:GetVGap(5)
		self.str = self.str .. self:GetCurLvlAtb();
		self.str = self.str .. self:GetVGap(5)
		self.str = self.str .. self:GetNextLvlAtb();
		self.str = self.str .. self:GetVGap(5)
		--self.str = self.str .. self:GetMaxLvlAtb();
	end;
end;

--经验战印tips
function SpiritWarprintItem:GetExpprint()
	local cfg = self.tipsVO.cfg
	local str = "";
	str = str .. self:GetHtmlText(string.format(StrConfig["tips1107"],cfg.swallow_exp),"#ff8f43",self.titleSizi)
	return str
end;

function SpiritWarprintItem:GetExpTitle()
	local str = "";
	str = str .. self:GetVGap(13)
	str = str .. "<textformat leftmargin='80' leading='5'>";
	str = str .. self:GetHtmlText(self.tipsVO.cfg.name,TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality),TipsConsts.TitleSize_One,true);
	str = str .. "</textformat><br/>";
	return str
end;

function SpiritWarprintItem:GetIconUrl()
	return self.tipsVO.iconUrl
end;

function SpiritWarprintItem:GetIconPos()
	return {x=26,y=26};
end

function SpiritWarprintItem:GetQualityUrl()
	return ResUtil:GetSlotQuality(self.tipsVO.cfg.quality, 54);
end

function SpiritWarprintItem:GetQuality()
	return self.tipsVO.cfg.quality;
end

function SpiritWarprintItem:GetTitle()
	local str = "";
	str = str .. self:GetVGap(13)
	str = str .. "<textformat leftmargin='80' leading='5'>";
	str = str .. self:GetHtmlText(self.tipsVO.cfg.name,TipsConsts:GetItemQualityColor(self.tipsVO.cfg.quality),TipsConsts.TitleSize_One,true);
	str = str .. "</textformat><br/>";
	return str
end;

function SpiritWarprintItem:GetLvl()
	local str = "";
	str = str .. "<textformat leftmargin ='100' leading='5'>";
	str = str .. "lv."..self:GetHtmlText(self.tipsVO.cfg.lvl,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	str = str .. "</textformat>";
	return str;
end;

function SpiritWarprintItem:GetCurItemExp()
	local str = "";
	if self.tipsVO.cfg.nextlvlid < 1 then
		str = str .. self:GetHtmlText(StrConfig["tips1101"],"#ffffff",TipsConsts.Default_Size);
		return str;
	end;
	str = str .. self:GetHtmlText(StrConfig["tips1102"],"#ffffff",TipsConsts.Default_Size,false);
	local maxexp = self.tipsVO.cfg.up_exp;
	local curexp = self.tipsVO.value;
	if not curexp then return "" end;
	str = str .. self:GetHtmlText(curexp.."/"..maxexp,"#ffffff",TipsConsts.Default_Size)
	return str
end;

function SpiritWarprintItem:GetCurLvlAtb()
	local str = "";
	str = str .. self:GetHtmlText(StrConfig["tips1103"],"#ff8f43",self.titleSizi)--TipsConsts.Default_Size);
	for i,info in pairs(self.tipsVO.curlvlatblist) do
		str = str .. self:GetVGap(5)
		str = str .. self:GetHtmlText(enAttrTypeName[i].."    ","#D1C0A5",TipsConsts.Default_Size,false);
		if attrIsPercent(i) then
			str = str .. self:GetHtmlText(string.format("%.2f%%",info * 100),"#ffffff",TipsConsts.Default_Size,true);
		else
			str = str .. self:GetHtmlText(info,"#ffffff",TipsConsts.Default_Size,true);
		end;
	end;
	return str;
end;

function SpiritWarprintItem:GetNextLvlAtb()
	local str = "";
	if self.tipsVO.cfg.nextlvlid < 1 then
		return str;
	end;
	str = str .. self:GetHtmlText(StrConfig["tips1104"],"#ff8f43",self.titleSizi)--TipsConsts.Default_Size);
	for i,info in pairs(self.tipsVO.nextlvlatblist) do
		str = str .. self:GetVGap(5)
		str = str .. self:GetHtmlText(enAttrTypeName[i].."    ","#D1C0A5",TipsConsts.Default_Size,false);
		--随后显示满级的属性 yanghongbin/yaochunlong 2016-8-9
		local maxInfo;
		maxInfo = self.tipsVO.MaxLvlAtbList[i];
		local maxStr = "";
		if maxInfo then
			if attrIsPercent(i) then
				maxStr = self:GetHtmlText(string.format(StrConfig["tips1108"], string.format("%.2f%%",maxInfo * 100)),"#ffffff",TipsConsts.Default_Size,true);
			else
				maxStr = self:GetHtmlText(string.format(StrConfig["tips1108"], maxInfo),"#ffffff",TipsConsts.Default_Size,true);
			end
		end
		--下一级属性
		if attrIsPercent(i) then
			str = str .. self:GetHtmlText(string.format("%.2f%%",info * 100),"#ffffff",TipsConsts.Default_Size, false);
		else
			str = str .. self:GetHtmlText(info,"#ffffff",TipsConsts.Default_Size, false);
		end;
		str = str .. self:GetHtmlText("<pre>&#009;&#009;" .. maxStr .. "</pre>","#ffffff",TipsConsts.Default_Size,false);
	end
	return str;
end;
--[[
--策划将满级属性放到下一级属性后面显示了   yanghongbin/yaochunlong 2016-8-9
function SpiritWarprintItem:GetMaxLvlAtb()
	local str = "";
	if self.tipsVO.cfg.nextlvlid < 1 then
		return str;
	end;
	str = str .. self:GetHtmlText(StrConfig["tips1105"],"#ff8f43",self.titleSizi)--TipsConsts.Default_Size);
	str = str .. self:GetVGap(5)
	for i,info in pairs(self.tipsVO.MaxLvlAtbList) do
		str = str .. self:GetHtmlText(enAttrTypeName[i].."    ","#D1C0A5",TipsConsts.Default_Size,false);
		if attrIsPercent(i) then
			str = str .. self:GetHtmlText(string.format("%.2f%%",info * 100),"#ffffff",TipsConsts.Default_Size,true);
		else
			str = str .. self:GetHtmlText(info,"#ffffff",TipsConsts.Default_Size,true);
		end;
	end;
	return str;
end;
]]
function SpiritWarprintItem:GetSenditem()
	local str = "";
	str = str .. self:GetHtmlText(StrConfig["tips1106"],"#ff8f43",TipsConsts.Default_Size);
	return str
end;

--得到tips显示类型
function SpiritWarprintItem:GetTipsType(  )
	return TipsConsts.Type_SpiritWarPrint
end
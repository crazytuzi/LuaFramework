--[[
	装备Tips
	chenyujia
	2016年11月14日11:23:48
]]

_G.NewTianshenTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_NewTianshen,NewTianshenTips);

NewTianshenTips.tipsVO = nil;

function NewTianshenTips:Parse(tipsInfo)
	-- trace(tipsInfo)
	self.tipsVO = tipsInfo;
	--头标题
	self.str = "";
	self.str = self.str .. self:GetTitle();    --装备最顶层名字信息
	self.str = self.str .. "\n\n"
	
	if self:GetModelDrawClz() then
		self.str = self.str .. self:GetVGap(self:GetModelDrawClz():GetHeight());
		self.str = self.str .. self:GetLine(10);
	end
	
	if self.tipsVO.isTianshen then
		self.str = self.str .. self:GetTianshenAttr()
		self.str = self.str .. self:GetLine(10)
	else
		self.str = self.str .. self:GetCardAttr()
		self.str = self.str .. self:GetLine(10)
	end
	self.str = self.str .. self:GetEffect()

	local passSkillStr = self:GetPassEffect()
	if passSkillStr then
		self.str = self.str .. self:GetLine(10)
		self.str = self.str .. passSkillStr
	end

	if self.tipsVO.isTianshen then

	else
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
	end
end

--获取星星
function NewTianshenTips:GetStar(star, maxStar)
	local str = " "
	for i = 1, maxStar do
		if i <= star then
			str = str .. "<img width='20' height='18' src='" .. ResUtil:GetTipsStarUrl() .. "'/>"..""
		else
			str = str .. "<img width='20' height='18' src='" .. ResUtil:GetTipsGrayStarUrl() .."'/>"..""
		end
	end
	str = str .. " "
	return str
end

local s_pro = {"att", "def", "hp", "hit", "dodge", "cri", "defcri"}
--获取天神属性
function NewTianshenTips:GetTianshenAttr()
	local str = "";
	--星级
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText("星级" .. self:GetStar(self.tipsVO.tianshen:GetStar(), self.tipsVO.tianshen:GetMaxStar()),TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	str = str .. "</font></textformat>";
	--资质
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText("资质 " .. self:GetHtmlText(self.tipsVO.tianshen:GetZizhi(), TipsConsts:GetItemQualityColor(self.tipsVO.tianshen:GetShowQuality()), TipsConsts.TitleSize_Three, false),TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	str = str .. "</font></textformat>";
	--等级
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText("等级 " .. self:GetHtmlText(self.tipsVO.tianshen:GetLv(), "#ffffff", TipsConsts.TitleSize_Three, false),TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	str = str .. "</font></textformat>";
	--@二级标签
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText("天神属性：",TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	str = str .. "</font></textformat>";
	local list = self.tipsVO.tianshen:GetPro();
	for i, v in ipairs(s_pro) do
		local pro = list[v]
		if pro then
			str = str .. "<textformat leading='-16' leftmargin='6'><p>";  --</p>前面创建空白区域
			str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			str = str .. "</p></textformat>";
		
			str = str ..  "<textformat leading='" .. 8 .."' leftmargin='23'><p>";
			str = str .. string.format( "<font color='#eeb462'>%s</font>",enAttrTypeName[pro.type]..":")
			-- str = str ..":";
			local add = " +";
			str = str .. string.format( "<font color='#d8d8d8'>%s</font><font color='#d8d8d8'>%s</font>", 
				 add,getAtrrShowVal(pro.type,pro.val))
			str = str .. "</p></textformat>";
			
			str = self:GetHtmlText(str,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
		end
	end
	--@初始战力
	str = str .. "<textformat leading='-40' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText("战斗力：" .. self:GetHtmlText(PublicUtil:GetFigthValue(list), "#ffff00", TipsConsts.TitleSize_Three),TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	str = str .. "</font></textformat>";
	return str;
end

--获取天神卡属性
function NewTianshenTips:GetCardAttr()
	local zizhi = self.tipsVO.param1
	local zizhi1 = nil
	if not zizhi or zizhi == 0 then
		zizhi, zizhi1 = NewTianshenUtil:GetTianshenCardZizhi(self.tipsVO.id)
	end
	local str = "";
	local star, lv = NewTianshenUtil:GetTianshenCardStarLv(self.tipsVO.id)
	--秒睡
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText("使用后可获得天神 " .. self:GetHtmlText(NewTianshenUtil:GetTianshenName(self.tipsVO.id) , 
					TipsConsts:GetItemQualityColor(NewTianshenUtil:GetShowQuality(zizhi)),TipsConsts.TitleSize_Three, false),TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	str = str .. "</font></textformat>";
	--星级
	if star and star > 0 then
		str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
		str = str .. self:GetHtmlText("星级" .. self:GetStar(star, NewTianshenUtil:GetAttrXishuCfg(NewTianshenUtil:GetQualityByZizhi(zizhi)).maxstar),TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
		str = str .. "</p></textformat>";
		str = str .."<textformat></br>".."<br></textformat>"
		str = str .. self:GetVGap(5);
		str = str .. "</font></textformat>";
	end
	--资质
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	local zizhiStr = zizhi
	if zizhi1 and zizhi ~= zizhi1 then
		zizhiStr = zizhi1 .. "-" ..zizhi
	end
	str = str .. self:GetHtmlText("资质 " .. self:GetHtmlText(zizhiStr, TipsConsts:GetItemQualityColor(NewTianshenUtil:GetShowQuality(zizhi)), 
				TipsConsts.TitleSize_Three, false),TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	str = str .. "</font></textformat>";
	--等级
	if lv and lv > 0 then
		str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
		str = str .. self:GetHtmlText("等级 " .. self:GetHtmlText(lv, "#ffffff", TipsConsts.TitleSize_Three, false),TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
		str = str .. "</p></textformat>";
		str = str .."<textformat></br>".."<br></textformat>"
		str = str .. self:GetVGap(5);
		str = str .. "</font></textformat>";
	end
	--@二级标签
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText("初始属性：",TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	str = str .. "</font></textformat>";
	local list = NewTianshenUtil:GetTianshenCardPro(self.tipsVO.id, zizhi)
	for i, v in ipairs(s_pro) do
		local pro = list[v]
		if pro then
			str = str .. "<textformat leading='-16' leftmargin='6'><p>";  --</p>前面创建空白区域
			str = str .. "<img width='9' height='15' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
			str = str .. "</p></textformat>";
		
			str = str ..  "<textformat leading='" .. 8 .."' leftmargin='23'><p>";
			str = str .. string.format( "<font color='#eeb462'>%s</font>",enAttrTypeName[pro.type]..":")
			-- str = str ..":";
			local add = " +";
			str = str .. string.format( "<font color='#d8d8d8'>%s</font><font color='#d8d8d8'>%s</font>", 
				 add,getAtrrShowVal(pro.type,pro.val))
			str = str .. "</p></textformat>";
			
			str = self:GetHtmlText(str,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
		end
	end
	--@初始战力
	str = str .. "<textformat leading='-40' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText("初始战力：" .. self:GetHtmlText(PublicUtil:GetFigthValue(list), "#ffff00", TipsConsts.TitleSize_Three),TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	str = str .. "</font></textformat>";
	return str;
end

--技能
function NewTianshenTips:GetEffect()
	local str = "";
	local skill = {}
	if self.tipsVO.isTianshen then
		skill = self.tipsVO.tianshen:GetSkill()
	elseif self.tipsVO.param1 and self.tipsVO.param1 > 0 then
		skill = NewTianshenUtil:GetSKill(self.tipsVO.id, NewTianshenUtil:GetQualityByZizhi(self.tipsVO.param1))
	else
		skill = NewTianshenUtil:GetSKill(self.tipsVO.id, NewTianshenUtil:GetQualityByZizhi(NewTianshenUtil:GetTianshenCardZizhi(self.tipsVO.id)))
	end

	--资质
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText("主动技能：",TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	str = str .. "</font></textformat>";

	for k, v in pairs(skill) do
		str = str .. "<textformat leftmargin='6' leading='5'><p>";
		str = str .. self:GetHtmlText(t_skill[v].name,TipsConsts:GetSkillQualityColor(t_skill[v].quality),TipsConsts.Default_Size,false) .. "："
		str = str .. self:GetHtmlText(SkillTipsUtil:GetSkillEffectStr(v),TipsConsts.Default_Color,TipsConsts.Default_Size,false);
		str = str .. "</p></textformat>"
	end
	return str
end

-- 被动技能
function NewTianshenTips:GetPassEffect()
	if not self.tipsVO.isTianshen then
		return nil
	end
	local str = ""
	local skill = self.tipsVO.tianshen:GetPassSkill()
	
	--资质
	str = str .. "<textformat leading='-25' leftmargin='6'><p>"; 
	str = str .. self:GetHtmlText("被动技能：",TipsConsts.TwoTitleColor,TipsConsts.TitleSize_Three);
	str = str .. "</p></textformat>";
	str = str .."<textformat></br>".."<br></textformat>"
	str = str .. self:GetVGap(5);
	str = str .. "</font></textformat>";

	for k, v in pairs(skill) do
		str = str .. "<textformat leftmargin='6' leading='5'><p>";
		str = str .. self:GetHtmlText(t_passiveskill[v].name,TipsConsts:GetSkillQualityColor(t_passiveskill[v].quality),TipsConsts.Default_Size,false) .. "："
		str = str .. self:GetHtmlText(SkillTipsUtil:GetSkillEffectStr(v),TipsConsts.Default_Color,TipsConsts.Default_Size,false);
		str = str .. "</p></textformat>"
	end
	return str
end

--描述
function NewTianshenTips:GetDes()
	local str = "";
	if self.tipsVO.cfg.summary ~= "" then
		str = str .. self:GetHtmlText(self.tipsVO.cfg.summary, TipsConsts.TwoTitleColor, TipsConsts.TitleSize_Three);
	end
	str = str .. self:GetHtmlText(self.tipsVO.cfg.detail, TipsConsts.Default_Color,TipsConsts.Default_Size,true);
	str = self:SetLineSpace(str,5);
	return str;
end

function NewTianshenTips:GetModelDrawArgs()
	if self.tipsVO.isTianshen then
		return {self.tipsVO.tianshen:GetCardID(), 375, 215};
	end
	return {self.tipsVO.cfg.id, 375, 215};
end

function NewTianshenTips:GetIconUrl()
	if self.tipsVO.isTianshen then
		return BagUtil:GetItemIcon(self.tipsVO.tianshen:GetCardID(), true)
	end
	return self.tipsVO.iconUrl;
end

function NewTianshenTips:GetIconPos()
	return {x=35,y=35}
end

function NewTianshenTips:GetWidth()
	return 421;
end

function NewTianshenTips:GetShowBiao()
	if self.tipsVO.isTianshen then
		return ""
	end
	if self.tipsVO.cfg.identifying == "" then return ""; end
	local t = split(self.tipsVO.cfg.identifying,"#");
	for _,s in ipairs(t) do
		if s:lead("lable") then
			return ResUtil:GetTipsBiaoShiUrl(s);
		end
	end
	return "";
end

function NewTianshenTips:GetIconLevelUrl()
	if self.tipsVO.isTianshen then
		return ""
	end
	if self.tipsVO.cfg.identifying == "" then return ""; end
	local t = split(self.tipsVO.cfg.identifying,"#");
	for _,s in ipairs(t) do
		if s:lead("num") then
			return ResUtil:GetBiaoShiUrl(s);
		end
	end
	return "";
end

function NewTianshenTips:GetModelDraw()
	return ItemTipsDraw:new()
end

function NewTianshenTips:GetQualityUrl()
	return ResUtil:GetSlotQuality(self:GetQuality(), 54);
end

function NewTianshenTips:GetQuality()
	if self.tipsVO.param1 and self.tipsVO.param1 > 0 then
		return NewTianshenUtil:GetShowQuality(self.tipsVO.param1)
	elseif self.tipsVO.isTianshen then
		return self.tipsVO.tianshen:GetShowQuality()
	end
	return NewTianshenUtil:GetShowQuality(NewTianshenUtil:GetTianshenCardZizhi(self.tipsVO.id))
end

function NewTianshenTips:GetTipsEffectUrl()
	-- return ResUtil:GetTipsQuality(self.tipsVO.cfg.quality);
end

function NewTianshenTips:GetModelDrawClz()
	return ItemTipsDraw;
end


function NewTianshenTips:GetDebugInfo()
	if isDebug then
		if not self.tipsVO.isTianshen then
			return "/createitem/"..self.tipsVO.cfg.id.."/11";
		end
	end
	return nil;
end

function NewTianshenTips:GetTitleBg( )
	local str = "";
	str = str .. "<textformat leading='-32'><p>";  --</p>前面创建空白区域
	str = str .. "<img width='387' height='0' src='" .. ResUtil:GetTipsNameBgUrl() .. "'/>";
	str = str .. "</p></textformat>";
	return str;
end

--第一级标题
function NewTianshenTips:GetTitle()
	local str = "";
	str = str .. self:GetVGap(13);  --居中

	local name = "";   --配置名字
	local quality = 0
	if self.tipsVO.isTianshen then
		name = self.tipsVO.tianshen:GetHtmlName() .. "+" ..self.tipsVO.tianshen:GetStar()
		quality = self.tipsVO.tianshen:GetShowQuality()
	else
		name = self.tipsVO.cfg.name;   --配置名字
		quality = 0
		if self.tipsVO.param1 and self.tipsVO.param1 > 0 then
			quality = NewTianshenUtil:GetShowQuality(self.tipsVO.param1)
		else
			quality = NewTianshenUtil:GetShowQuality(NewTianshenUtil:GetTianshenCardZizhi(self.tipsVO.id))
		end
	end
	
	local lens = string.len(name)/3*25
	local pos = 10
	pos = math.ceil(pos)
	str = str .. "<textformat leftmargin ='"..pos.. "'leading='0'><p>"

	str = str .. self:GetHtmlText(name,TipsConsts:GetItemQualityColor(quality),TipsConsts.BlackNew_Size,false);

	str = str .."</p></textformat>"
	return str;
end

--获取战斗力num
function NewTianshenTips:GetFightNum(num)
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
function NewTianshenTips:GetBaseFightNum(num)
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

--获取方式
function NewTianshenTips:GetFrom()
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
function NewTianshenTips:GetShowInfo()
	if not self.tipsVO.isInBag then return ""; end
	return self:GetHtmlText(StrConfig["tips3"],TipsConsts.Default_Color,TipsConsts.Default_Size,false);
end

--剧情
function NewTianshenTips:GetStory()
	if self.tipsVO.cfg.story == "" then
		return nil;
	end
	local str = self:GetHtmlText(self.tipsVO.cfg.story,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	str = self:SetLineSpace(str,5);
	return str;
end

function NewTianshenTips:OnGetUnionContr()
	local str = "";
	str = str .. self:GetVGap(5);
	if self.tipsVO.contrState == 1 then --取出
		str = str .. self:GetHtmlText(StrConfig["tips902"]..self.tipsVO.contrVla,"#ffffff",TipsConsts.Default_Size);
	elseif self.tipsVO.contrState == 2 then --存入
		str = str .. self:GetHtmlText(StrConfig["tips901"]..self.tipsVO.contrVla,"#ffffff",TipsConsts.Default_Size);
	end;
	return str
end

function NewTianshenTips:GetShowIcon()
	return not self.tipsVO.isTianshen
end

--得到tips显示类型
function NewTianshenTips:GetTipsType()
	return TipsConsts.Type_NewTianshen
end
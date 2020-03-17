--[[
技能Tips
lizhuangzhuang
2014年8月26日20:11:27
]]

_G.SkillTips = BaseTips:new();
TipsManager:AddParseClass(TipsConsts.Type_Skill,SkillTips);

SkillTips.tipsVO = nil;
SkillTips.skillId = 0;--技能id
SkillTips.cfg = nil;--配表
SkillTips.skillType = 1;--1主动技能,2被动技能

function SkillTips:Parse(tipsInfo)
	self.tipsVO = tipsInfo;
	self.skillId = tipsInfo.skillId;
	self.cfg = t_skill[self.skillId];
	self.additiveType = SkillUtil.additiveType;
	self.additiveId = SkillUtil.additiveId;
	self.skillType = 1;
	if not self.cfg then
		self.cfg = t_passiveskill[self.skillId];
		self.skillType = 2;
	end
	if not self.cfg then
		self.str = "";
		return;
	end
	--
	self.str = "";
	self.str = self.str .. self:GetTitle();  --名字
	--
	self.str = self.str .. self:GetTitle2(); --简单描述 
	self.str = self.str .. self:GetLine(10,10);  --获取一条线
	--
	local effectStr = self:GetEffect();
	if effectStr ~= "" then
		self.str = self.str .. effectStr;
	end
	
	if self.additiveType == SkillConsts.ENUM_ADDITIVE_TYPE.TIANSHEN then
		self.str = self.str..self:GetTianshenAdditive();
	end
	
	--
	local desStr = self:GetDes();
	if desStr ~= "" then
		desStr = self:SetLeftMargin(desStr,5);
		self.str = self.str .. self:GetLine(5);
		self.str = self.str .. desStr;
	end
	--
	local conditionStr = self:GetCondition();
	if conditionStr ~= "" then
		conditionStr = self:SetLeftMargin(conditionStr,5);
		self.str = self.str .. self:GetLine();
		self.str = self.str .. conditionStr;
	end
end

function SkillTips:GetIconUrl()
	if not self.cfg then return "";end
	return ResUtil:GetSkillIconUrl(self.cfg.icon,"54")
end

function SkillTips:GetIconPos()
	return {x=26,y=30}
end

function SkillTips:GetWidth()
	return 350;
end

--标题
function SkillTips:GetTitle()
	local str = "";
	str = str .. self:GetVGap(13);
	str = str .. "<textformat leftmargin='5' leading='-16'><p>";
	str = str .. self:GetHtmlText(self.cfg.name,TipsConsts:GetSkillQualityColor(self.cfg.quality),TipsConsts.TitleSize_One,false,false);
	str = str .."</p></textformat>"
	--技能等级
	local maxLvl = self.cfg.level;
	if t_skillgroup[self.cfg.group_id] then
		maxLvl = t_skillgroup[self.cfg.group_id].maxLvl;
	end
	local lvlStr = string.format(StrConfig['skill9'],self.cfg.level,maxLvl);   --多少级多少重
	lvlStr = self:GetHtmlText(lvlStr,"#00ff00",TipsConsts.Default_Size,false);
	lvlStr = "<textformat leading='0' rightmargin='4'><p align='right'>" .. lvlStr .. "</p></textformat>";
	str = str .. lvlStr;
	return str;
end

--技能类型等描述
function SkillTips:GetTitle2()
	local str = "";
	str = str .. self:GetVGap(18);
	str = str .. "<textformat leading='5'><p>";
	str = str .. "</p></textformat>";
	
	str = str .. "<textformat leftmargin='95' leading='10'><p>";
	--技能类型
	if self.cfg.type == SKILL_TYPE.PASSIVE then
		str = str .. self:GetHtmlText(SkillConsts:GetSkillTypeName(self.cfg.type,self.cfg.showtype),"#e59607",TipsConsts.Default_Size);
		str = str .. "</p></textformat>";
		str = str .. self:GetVGap(25);
		return str;
	end
	str = str .. self:GetHtmlText(StrConfig['skill1'].."：","#e59607",TipsConsts.Default_Size,false);
	str = str .. self:GetHtmlText(SkillConsts:GetSkillTypeName(self.cfg.type),TipsConsts.Default_Color,TipsConsts.Default_Size);
	--冷却时间
	str = str .. self:GetHtmlText(StrConfig['skill2'].."：","#e59607",TipsConsts.Default_Size,false);
	str = str .. self:GetHtmlText(string.format(StrConfig['skill10'],self.cfg.cd/1000),TipsConsts.Default_Color,TipsConsts.Default_Size); 
	--伤害范围
	str = str .. self:GetHtmlText(StrConfig['skill3'].."：","#e59607",TipsConsts.Default_Size,false);
	str = str .. self:GetHtmlText(SkillConsts:GetSkillHurtTypeName(self.cfg.type),TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	--技能消耗
	if self.cfg.consume_type>0 and self.cfg.consume_type ~= SKILL_CONSUM_TYPE.MP then
		str = str .. "<br/>";
		str = str .. self:GetHtmlText(StrConfig['skill4'].."：","#e59607",TipsConsts.Default_Size,false);
		str = str .. self:GetHtmlText(SkillConsts:GetSkillConsumStr(self.skillId),TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	end
	str = str .. "</p></textformat>";
	return str;
end

--技能效果
function SkillTips:GetEffect()
	if self.cfg.effectStr=="" then return ""; end
	local str = "";
	str = str .. "<textformat leftmargin='0' leading='5'><p>";
	--本级效果
	str = str .. self:GetHtmlText(StrConfig['skill11'].."：","#e59607",TipsConsts.TitleSize_Two);  --技能效果
	str = str .. self:GetHtmlText(SkillTipsUtil:GetSkillEffectStr(self.skillId),TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	if not self.tipsVO.get then
		str = str .. "</p></textformat>"
		return str;
	end
	local nextCfg;
	if self.skillType == 1 then
		nextCfg = t_skill[self.cfg.next_lv];
	else
		nextCfg = t_passiveskill[self.cfg.next_lv];
	end
	if not nextCfg then
		str = str .. "</p></textformat>"
		return str;
	end
	--下级效果
	str = str .. self:GetVGap(1);
	str = str .. self:GetHtmlText(StrConfig['skill12'].."：","#e59607",TipsConsts.TitleSize_Two);
	str = str .. self:GetHtmlText(SkillTipsUtil:GetSkillEffectStr(self.cfg.next_lv),"#65c47e",TipsConsts.Default_Size,false);
	str = str .. "</p></textformat>";
	return str;
end

function SkillTips:GetTianshenAdditive()
	local str = SkillTipsUtil:GetAdditiveDesc(self.skillId,self.additiveType,self.additiveId)
	if str == "" then
		return ""
	end
	str = self:GetHtmlText(str,"#65c47e",TipsConsts.Default_Size,false);
	return self:GetLine() .. self:GetVGap(1) .. "<textformat leftmargin='0' leading='5'><p>" .. str .. "</p></textformat>";
end

--技能升级学习条件
function SkillTips:GetCondition()
	if not self.tipsVO.condition then
		return "";
	end
	local str = "";
	str = str .. "<textformat leading='5'><p>";
	if self.tipsVO.get then
		local maxLvl = self.cfg.level;
		if t_skillgroup[self.cfg.group_id] then
			maxLvl = t_skillgroup[self.cfg.group_id].maxLvl;
		end
		if self.cfg.level == maxLvl then return ""; end
		str = str .. self:GetHtmlText(StrConfig["tips701"],"#e59607",TipsConsts.Default_Size);
	else
		str = str .. self:GetHtmlText(StrConfig["tips702"],"#e59607",TipsConsts.Default_Size);
	end
	
	
--修改于2016/10/15 16:21:35 houxudong 调用大主宰--处理技能tips
	local conditionlist = SkillUtil:GetLvlUpConditionForSkill(self.skillId,not self.tipsVO.get);
	for i=#conditionlist,1,-1 do
		local vo = conditionlist[i];
		local name,num = SkillUtil:GetConditionStr(vo);
		if vo.state then
			str = str .. self:GetHtmlText(string.format(StrConfig["tips703"],name,num),"#29cc00",TipsConsts.Default_Size,false);
		else
			str = str .. self:GetHtmlText(string.format(StrConfig["tips704"],name,num),"#dc2f2f",TipsConsts.Default_Size,false);
		end
		if i > 1 then
			str = str .. "<br/>";
		end
	end
	str = str .. "</p></textformat>";
	if not self.tipsVO.unShowLvlUpPrompt then
		str = str .. self:GetLine();
		str = str .. self:GetHtmlText( StrConfig['tips705'] );
	end
	return str;
end

--技能描述
function SkillTips:GetDes()
	local str = "";
	if self.cfg.des=="" then return str; end
	str = str .. self:GetHtmlText(self.cfg.des,"#b86f11",TipsConsts.Default_Size,false);
	return str;
end

--得到tips显示类型
function SkillTips:GetTipsType(  )
	return TipsConsts.Type_Skill
end



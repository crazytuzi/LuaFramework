--[[
帮派技能Tips
liyuan
2014年8月26日20:11:27
]]

_G.GuildSkillTips = BaseTips:new()
TipsManager:AddParseClass(TipsConsts.Type_GuildSkill,GuildSkillTips)

GuildSkillTips.tipsVO = nil
--技能id
GuildSkillTips.skillGroupId = 0
GuildSkillTips.skillId = 0
--配表
GuildSkillTips.groupCfg = nil
GuildSkillTips.cfg = nil

function GuildSkillTips:Parse(tipsInfo)
	self.tipsVO = tipsInfo
	self.skillGroupId = tipsInfo.skillGroupId
	self.skillId = UnionUtils:GetSkillIdByGroup(self.skillGroupId)
	self.cfg = t_guildskill[self.skillId]
	if not self.cfg then 
		self.str = ""
		return 
	end
	self.groupCfg = t_guildskillgroud[self.skillGroupId]
	self.str = ""	
	self.str = self.str .. self:GetTitle2()
	self.str = self.str .. self:GetLine(10)
	self.str = self.str .. self:GetEffect()
end

function GuildSkillTips:GetIconUrl()
	if not self.groupCfg then return ""end
	return ResUtil:GetSkillIconUrl(self.groupCfg.icon)
end

function GuildSkillTips:GetIconPos()
	return {x=26,y=18}
end

function GuildSkillTips:GetWidth()
	return 220
end

--技能类型等描述
function GuildSkillTips:GetTitle2()
	local str = ""
	str = str .. self:GetVGap(22)
	str = str .. "<textformat leftmargin='74' leading='10'><p>"
	-- 技能名 等级 
	str = str .. self:GetHtmlText(self.groupCfg.groupname,"#b400ff",16)
	str = str .. self:GetHtmlText(StrConfig['union53'].."：","#8cbbd3",TipsConsts.Default_Size,false)
	str = str .. self:GetHtmlText(string.format(StrConfig['union31'], self.tipsVO.level..'/'..UIUnionSkill:GetSkillMaxLevel(self.skillGroupId) ),"#29CC00",TipsConsts.Default_Size)
	str = str .. "</p></textformat>"
	return str
end

--技能效果
function GuildSkillTips:GetEffect()
	local str = ""
	str = str .. "<textformat leading='10'><p>"
	--本级效果
	str = str .. self:GetHtmlText(StrConfig['union54'].."：","#8cbbd3",TipsConsts.TitleSize_Two,false)
	if not self.cfg.att or self.cfg.att == "" then
		str = str .. self:GetHtmlText('',"#29CC00",TipsConsts.Default_Size)
	else
		str = str .. self:GetHtmlText(UnionUtils:GetAttrStr(self.cfg.att),"#29CC00",TipsConsts.Default_Size,false)
	end
	
	-- 下级技能
	str = str .. self:GetHtmlText(StrConfig['union55'].."：","#8cbbd3",TipsConsts.TitleSize_Two,false)
	if self.cfg.nextlv == 0 then
		str = str .. self:GetHtmlText('',"#29CC00",TipsConsts.Default_Size)
	else
		local nextSkillCfg = t_guildskill[self.cfg.nextlv]
		if nextSkillCfg then 
			if not nextSkillCfg.att or nextSkillCfg.att == "" then
				str = str .. self:GetHtmlText('',"#29CC00",TipsConsts.Default_Size)
			else
				str = str .. self:GetHtmlText(UnionUtils:GetAttrStr(nextSkillCfg.att),"#29CC00",TipsConsts.Default_Size,false)
			end
		else
			str = str .. self:GetHtmlText('',"#29CC00",TipsConsts.Default_Size)
		end
	end
	
	--消耗贡献
	str = str .. self:GetHtmlText(StrConfig['union56'].."：","#8cbbd3",TipsConsts.TitleSize_Two,false)
	local colorStr = '#29cc00'
	local bReachedStr = StrConfig['union210']
	if self.cfg.need_contribute then
		if UnionModel.MyUnionInfo.contribution < self.cfg.need_contribute then
			colorStr = '#780000'
			bReachedStr = StrConfig['union211']
		end
		str = str .. self:GetHtmlText(self.cfg.need_contribute..bReachedStr,colorStr,TipsConsts.Default_Size,false)
	else
		str = str .. self:GetHtmlText('',"#29CC00",TipsConsts.Default_Size,false)
	end
	
	str = str .. "</p></textformat>"
	return str
end

--得到tips显示类型
function GuildSkillTips:GetTipsType(  )
	return TipsConsts.Type_GuildSkill
end


--[[
新套装tips
yujia
]]

_G.EquipNewGroupTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_NewEquipGroup,EquipNewGroupTips);

EquipNewGroupTips.tipsVO = nil;

local s_size = 14
local s_color = "#af8a33"
local s_gray = "#5a5a5a"

local s_attr = {nil, "two_attr", "three_attr", "four_attr" , nil, "six_attr"} --不知道那个傻叉 这么起名字
local s_skill = {nil, "skill1", "skill2", "skill3" , nil, "skill4"} 

function EquipNewGroupTips:Parse(tipsInfo)
	self.str = "";
	self.tipsVO = tipsInfo;

	if tipsInfo.pos then
		self.str = self.str .. self:GetSlotInfo()
	end

	self.str = self.str .. self:GetGroupInfo()
end

--获取是否显示Icon
function EquipNewGroupTips:GetShowIcon()
	return false;
end

function EquipNewGroupTips:GetWidth()
	return 390;
end

function EquipNewGroupTips:GetSlotInfo()
	local vo = self.tipsVO
	local str = ""
	str = str .. "<textformat leading='-18' leftmargin='3'><p>";
	str = str .. "<img vspace='-4' src='" .. ResUtil:GetNewEquipGrouNameIcon(t_equipgroup[vo.id].nameicon,nil,nil,true) .. "'/>";
	str = str .. "</p></textformat>";
	if self.tipsVO.lv == -1 then
		str = str ..self:GetHtmlText("            (".. StrConfig['smithinggroup3'] ..")","#FF0000",s_size,false)
	else
		local cfg = t_equipgrouppos[vo.id * 100000 + vo.pos + 100 * vo.lv]
		str = str .. self:GetHtmlText("            Lv." .. vo.lv,"#ffffff",s_size,false)

		local pro = AttrParseUtil:Parse(cfg.attr)
		str = str .. self:GetHtmlText(" " .. enAttrTypeName[pro[1].type] .. "+" .. pro[1].val,s_color,s_size,true)
	end
	str = str .. "<p><img height='".. 5 .."'/></p><p><img width='".. 350 .."' height='1' align='baseline' vspace='".. 
		8 .."' src='" .. ResUtil:GetTipsLineUrl() .."'/></p>"
	return str
end

function EquipNewGroupTips:GetSlotIsActive(slot)
	for k, v in pairs(self.tipsVO.group) do
		if v[1] == slot then
			return v[2] > 0
		end
	end
end

function EquipNewGroupTips:GetGroupInfo()
	local str = ""
	local vo = self.tipsVO
	local groupCfg = t_equipgroup[vo.id]
	str = str .. "<textformat leading='-14' leftmargin='3'><p>";
	str = str .. "<img vspace='-4' src='" .. ResUtil:GetNewEquipGrouNameIcon(groupCfg.nameicon) .. "'/>";
	str = str .. "</p></textformat>" .. "<br>";

	str = str .. "<textformat leading='5' leftmargin='5'>";

	local namelist = {}
	for k, v in pairs(t_equipgroupextra) do
		local groupid = split(v.groupId, ",")
		for k1, v1 in pairs(groupid) do
			if toint(v1) == vo.id then
				table.insert(namelist, {k, BagConsts:GetEquipName(k)})
				break
			end
		end
	end
	for k, v in pairs(namelist) do
		str = str .. self:GetHtmlText(v[2], self:GetSlotIsActive(v[1]) and s_color or s_gray ,s_size,false)
		if k ~= #namelist then
			str = str .. "		"
		else
			str = str .. "<br>"
		end
	end
	str = str .. "</textformat>";

	local group = vo.group
	local num = 0
	for k, v in pairs(group) do
		if v[2] > 0 then
			num = num + 1
		else
			break
		end
	end

	local list = {}
	if #group == 4 then
		list = {2, 4}
	else
		list = {3, 6}
	end
	for i = 1, 2 do
		str = str .. "<textformat leading='5' leftmargin='5'>";
		str = str .. self:GetHtmlText(groupCfg.name, s_color, s_size, false)
		str = str .. "    " .. self:GetHtmlText("Lv." .. (num >= list[i] and group[list[i]][2] or 0), s_color, s_size, false)
		str = str .. " " .. self:GetHtmlText("(" .. (num >= list[i] and list[i] or num) .. "/" .. list[i] .. ")", s_color, s_size, true)
		str = str .. "</textformat>";

		local lv = 0
		if num > list[i] then
			lv = group[list[i][2]]
		else
			lv = 1
		end
		local config = t_equipgrouphuizhang[100*vo.id + lv]

		str = str .. "<textformat leading='-16' leftmargin='6'><p>";
		str = str .. "<img width='13' height='16' vspace='-4' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		str = str .. "</p></textformat>";

		local pro = AttrParseUtil:Parse(config[s_attr[list[i]]])
		str = str .. "<textformat leading='5' leftmargin='20'>";

		for k, v in pairs(pro) do
			str = str .. self:GetHtmlText(enAttrTypeName[v.type] .. " +" .. v.val,num >= list[i] and s_color or s_gray,s_size,false)
			if k ~= #pro then
				str = str .. "	 "
			end
		end
		str = str .. "</textformat>";
		str = str .. "<br>"

		str = str .. "<textformat leading='-16' leftmargin='6'><p>";
		str = str .. "<img width='13' height='16' vspace='-4' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
		str = str .. "</p></textformat>";

		local skillId = config[s_skill[list[i]]]
		str = str .. "<textformat leading='5' leftmargin='20'>";
		str = str .. self:GetHtmlText(t_passiveskill[skillId].effectStr, num >= list[i] and s_color or s_gray,s_size,true)
		str = str .. "</textformat>"
	end
	return str
end


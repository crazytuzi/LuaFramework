--[[
技能格子VO（显示VO）
lizhuangzhuang
2014年8月22日16:21:00
]]
_G.classlist['SkillSlotVO'] = 'SkillSlotVO'
_G.SkillSlotVO = {};
SkillSlotVO.objName = 'SkillSlotVO'
SkillSlotVO.skillId = 0;--技能id
SkillSlotVO.pos = 0;--技能的装备位置
SkillSlotVO.hasSkill = false;--格子上是否有技能
SkillSlotVO.consumEnough = true;--消耗是否充足
SkillSlotVO.frameType = -1;
SkillSlotVO.sizeIcon="";
function SkillSlotVO:new()
	local obj = {};
	for k,v in pairs(SkillSlotVO) do
		obj[k] = v;
	end
	return obj;
end

function SkillSlotVO:SetSkillId(id)
	self.skillId = id;
	if SkillController:CheckConsume(self.skillId) == 1 then
		self.consumEnough = true;
	else
		self.consumEnough = false;
	end
end

--获取技能图标
function SkillSlotVO:GetIconUrl(bTeamDup)
	if not self.hasSkill then return ""; end
	if not t_skill[self.skillId] then return ""; end
	local url = ResUtil:GetSkillIconUrl(t_skill[self.skillId].icon,self.sizeIcon);
	if not self.consumEnough then
		if bTeamDup then
			url = ImgUtil:GetGrayImgUrl(url);
		else
			url = ImgUtil:GetRedImgUrl(url);
		end
	end
	return url;
end

--获取快捷键
function SkillSlotVO:GetKey()
	if not self.key then
		local cfg = SkillConsts.KeyMap[self.pos];
		for i , v in pairs(SetSystemConsts.KeyStrConsts) do
			if i == cfg.keyCode then
				return v;
			end
		end
	end
	return self.key;
end

--CD
function SkillSlotVO:GetCD()
	if not self.hasSkill then return 0; end
	return SkillModel:GetSkillCD(self.skillId);
end

--total CD
function SkillSlotVO:GetTotalCD()
	if not self.hasSkill then return 0; end
	return SkillModel:GetSkillTotalCD(self.skillId);
end

function SkillSlotVO:GetFrameUrl()
	return ResUtil:GetSkillFrameEffect(self.frameType,self.skillId);
end

function SkillSlotVO:GetPointUrl()
	return ResUtil:GetSkillPointEffect(self.frameType,self.skillId);
end

--获取编码后的UI数据
function SkillSlotVO:GetUIData(bTeamDup)
	local data = {};
	data.hasSkill = self.hasSkill;
	data.hideSet = self.hideSet;
	data.skillId = self.skillId;
	data.pos = self.pos;
	data.iconUrl = self:GetIconUrl(bTeamDup);
	data.key = self:GetKey();
	data.sizeIcon=self.sizeIcon;
	data.lastCd = self:GetCD();
	data.totalCd = self:GetTotalCD();
	data.pointUrl = self:GetPointUrl();
	data.edgeUrl = self:GetFrameUrl();
	return UIData.encode(data);
end


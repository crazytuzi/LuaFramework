--[[
武魂技能tips
]]

_G.UISpiritsSkillTips = BaseUI:new("UISpiritsSkillTips");

UISpiritsSkillTips.wuhunId = 0;

function UISpiritsSkillTips:Create()
	self:AddSWF("wunHunTips.swf",true,"float");
end


function UISpiritsSkillTips:Open(wuhunId)
	self.wuhunId = wuhunId;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show()
	end
end

function UISpiritsSkillTips:Close()
	self:Hide();
end

function UISpiritsSkillTips:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsX,tipsY = TipsUtils:GetTipsPos(objSwf.bg._width,objSwf.bg._height,self.tipsDir);
	objSwf._x = tipsX;
	objSwf._y = tipsY;
	--
	local cfg = t_wuhun[self.wuhunId];
	local islinshou = true
	if not cfg then
		cfg = t_wuhunachieve[self.wuhunId]
		islinshou = false
	end
	if not cfg then
		self:Hide()
		return 
	end
	--
	if islinshou then
		objSwf.tfTitle.htmlText = StrConfig['wuhun53'];
		objSwf.tfTitle2.htmlText = "<font color='#f9680c'>" .. cfg.name .. "</font>";
	else
		objSwf.tfTitle.htmlText = StrConfig['wuhun54'];
		objSwf.tfTitle2.htmlText = "<font color='#b400ff'>" .. cfg.name .. "</font>";
	end
	--
	local level = cfg.order;
	if level and level > 0 then
		objSwf.tfLvl.htmlText = string.format(StrConfig['wuhun51'],self:GetNum(level));
	else
		objSwf.tfLvl.htmlText = "";
	end
	objSwf.tfTitle3.htmlText = StrConfig['wuhun52'];
	--
	local skillList = {}
	if t_wuhun[cfg.id] then
		skillList = t_wuhun[cfg.id].active_skill
	elseif t_wuhunachieve[cfg.id] then
		skillList = t_wuhunachieve[cfg.id].active_skill
	end
	if not skillList or #skillList <= 0 then return end
	for k,v in pairs (skillList) do 
		local skillVO = t_skill[v]
		if skillVO then
			-- 技能名 等级 
			local str = "";
			str = str .. "<font color='#ff6600'>" .. skillVO.name .. "</font><br/>";
			str = str .. "<font size='14' color='#d5b772'>" .. skillVO.keyword .. "</font>";
			objSwf["skill"..k].tf.htmlText = str;
			objSwf["skill"..k].loader.source = ResUtil:GetSkillIconUrl(skillVO.icon,"54");
		end
	end
end

function UISpiritsSkillTips:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local tipsX,tipsY = TipsUtils:GetTipsPos(objSwf.bg._width,objSwf.bg._height,TipsConsts.Dir_RightUp);
		objSwf._x = tipsX;
		objSwf._y = tipsY;
	end
end

function UISpiritsSkillTips:ListNotificationInterests()
	return {NotifyConsts.StageMove};
end

function UISpiritsSkillTips:GetNum(num)
	if num == 1 then return '一' 
	elseif num == 2 then return '二'
	elseif num == 3 then return '三'
	elseif num == 4 then return '四'	
	elseif num == 5 then return '五'
	elseif num == 6 then return '六'
	elseif num == 7 then return '七'
	elseif num == 8 then return '八'
	elseif num == 9 then return '九'
	elseif num == 10 then return '十'
	elseif num == 11 then return '十一'
	elseif num == 12 then return '十二'
	elseif num == 13 then return '十三'
	elseif num == 14 then return '十四'
	else return tostring(num);
	end
end
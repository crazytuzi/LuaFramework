--[[
天神技能tips
]]

_G.UITransforSkillTips = BaseUI:new("UITransforSkillTips");

UITransforSkillTips.tansformodel = nil;

function UITransforSkillTips:Create()
	self:AddSWF("TransforSkillTips.swf",true,"float");
end


function UITransforSkillTips:Open(tansformodel)
	self.tansformodel = tansformodel;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show()
	end
end

function UITransforSkillTips:Close()
	self:Hide();
end

function UITransforSkillTips:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsX,tipsY = TipsUtils:GetTipsPos(objSwf.bg._width,objSwf.bg._height,self.tipsDir);
	objSwf._x = tipsX;
	objSwf._y = tipsY;
	--
	local cfg = t_tianshen[self.tansformodel.tid];

	local iszhantianshen = true
	if not cfg then
		--cfg = t_wuhunachieve[self.tansformodel]
		iszhantianshen = false
	end
	if not cfg then
		self:Hide()
		return 
	end
	
	if iszhantianshen then
		objSwf.tfTitle.htmlText ="<font color='#f9680c'>" .. cfg.name .. "</font>";
		--objSwf.tfTitle2.htmlText = StrConfig['tianshen028'];	
	end
	
	local skillList = {}
	local skills=t_tianshenlv[self.tansformodel.step]
	if not skills then return end
	local skillList=GetCommaTable(skills.skill)
   
	if not skillList or #skillList <= 0 then return end
	for k,v in pairs (skillList) do
		
		local skillVO = t_skill[toint(v)]
	
		if skillVO then
			-- 技能名 等级 
			local str = "";
			str = str .. "<font size='14' color='#ff6600'>" .. skillVO.name .. "</font><br/>";
			str = str .. "<font size='12' color='#d5b772'>" .. skillVO.keyword .. "</font>";
			objSwf["skill"..k].tf.htmlText = str;
			objSwf["skill"..k].loader.source = ResUtil:GetSkillIconUrl(skillVO.icon,"54");
		end
	end
end

function UITransforSkillTips:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local tipsX,tipsY = TipsUtils:GetTipsPos(objSwf.bg._width,objSwf.bg._height,TipsConsts.Dir_RightUp);
		objSwf._x = tipsX;
		objSwf._y = tipsY;
	end
end

function UITransforSkillTips:ListNotificationInterests()
	return {NotifyConsts.StageMove};
end

function UITransforSkillTips:GetNum(num)
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
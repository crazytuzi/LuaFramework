--[[
	家园技能tips
	wangshuai
]]

_G.UIHomesSkillTips = BaseUI:new("UIHomesSkillTips")

UIHomesSkillTips.curCfg = {}
UIHomesSkillTips.canRestrainSkill = 17;

function UIHomesSkillTips:Create()
	self:AddSWF("homesteadSkillTips.swf",true,"top")
end;

function UIHomesSkillTips:OnLoaded(objSwf)
	objSwf.ddsc.htmlText = StrConfig['homestead049']
end;

function UIHomesSkillTips:OnShow()
	local objSwf = self.objSwf;
	local toX ,toY =  TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),TipsConsts.Dir_RightDown,nil)
	objSwf._x = toX;
	objSwf._y = toY;
	self:UpUIdata();
end;

function UIHomesSkillTips:OnHide()
	self.curCfg = {};
end;

function UIHomesSkillTips:UpUIdata()
	local objSwf = self.objSwf;
	local cfg = self.curCfg;
	objSwf.skill_name.htmlText = HomesteadUtil:GetQualityColor(cfg.quaility,cfg.skillName) --"<font color = '".. .. "'>"..cfg.skillName.."</font>";
	local cfgc = t_homeskillcom[cfg.group];
	if not cfgc then 
		return
	end;
	local beSkillList = {};
	for i=1,self.canRestrainSkill do
		local beskill = cfgc["skillResist"..i];
		if beskill > 0 then 
			--table.push(beSkillList,i)
			beSkillList[i] = 1;

		end;
	end;
	local bestr = ""
	for i,info in pairs(t_homepupilskill) do 
		if info.id < 10000 then 
			if beSkillList[info.group] then 
				beSkillList[info.group] = nil;
				if bestr == "" then 
					bestr = info.skillName;
				else
					bestr = bestr .. "、" ..info.skillName;
				end;
			end;
		end;
	end;
	-- for i,info in pairs(beSkillList) do 
	-- 	local bec = t_homepupilskill[info];
	-- 	if bec then 
	-- 		if bestr == "" then 
	-- 			bestr = bec.skillName;
	-- 		else
	-- 			bestr = bestr .. "、" ..bec.skillName;
	-- 		end;
	-- 	end;
	-- end;
	objSwf.ddsc.htmlText = cfg.skillTxt or "error cfg is nil"

	local id = cfg.id;
	if id > 10000 then 
		objSwf.skill_desc.htmlText = bestr or "error cfg is nil"
		objSwf.be_mc._visible = false
		objSwf.ke_mc._visible = true
	else
		objSwf.skill_desc.htmlText = cfg.skillResistTxt or "error cfg is nil"
		objSwf.be_mc._visible = true
		objSwf.ke_mc._visible = false
	end
end;

function UIHomesSkillTips:SetSkillId(id)
	local cfg = t_homepupilskill[id]
	if not cfg then 
		print("ERROR: cur skill id  error",id)
		return 
	end;

	self.curCfg = cfg;
	if not self:IsShow() then 
		self:Show();
	else
		self:UpUIdata();
	end;
end;

function UIHomesSkillTips:Update()
	if not self.bShowState then return end;
	local objSwf = self.objSwf;
	local toX ,toY =  TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),TipsConsts.Dir_RightDown,nil)
	objSwf._x = toX;
	objSwf._y = toY;
end;


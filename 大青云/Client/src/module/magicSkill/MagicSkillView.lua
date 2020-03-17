--[[
绝学主面板
zhangshuhui
2015年9月11日14:20:20
]]
_G.classlist['UIMagicSkill'] = 'UIMagicSkill'
_G.UIMagicSkill = BaseUI:new("UIMagicSkill");
UIMagicSkill.objName = 'UIMagicSkill'
UIMagicSkill.tabButton = {};
UIMagicSkill.currSelect = nil;
UIMagicSkill.selectPage = 0;

function UIMagicSkill:Create()
	self:AddSWF("magicskillMainPanel.swf",true,"center");
	-- self:AddChild(UIMagicSkillBasic,"basic");
	self:AddChild(UIMagicSkillBasic,FuncConsts.MagicSkill);  --绝学
	self:AddChild(UIXinfaSkillBasic,FuncConsts.XinfaSkill);  --心法
end

function UIMagicSkill:OnLoaded(objSwf,name)
	-- self:GetChild("basic"):SetContainer(objSwf.childPanel);
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	-- self:GetChild(FuncConsts.Skill):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.MagicSkill):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.XinfaSkill):SetContainer(objSwf.childPanel);
	---设置分页按钮----
	-- self.tabButton[FuncConsts.Skill] = objSwf.btnJineng;
	self.tabButton[FuncConsts.MagicSkill] = objSwf.btnJuexue;
	self.tabButton[FuncConsts.XinfaSkill] = objSwf.btnXinfa; 

	for name,btn in pairs(self.tabButton) do
		btn.click = function() if name~=self.selectPage then self:OnTabButtonClick(name); end end
	end
	-- self.btnJinengWidth = objSwf.btnJineng._width;
	self.btnJuexueWidth = objSwf.btnJuexue._width;
	self.btnXinfaWidth = objSwf.btnXinfa._width;
end

function UIMagicSkill:IsTween()
	return true;
end

function UIMagicSkill:GetPanelType()
	return 1;
end

function UIMagicSkill:WithRes()
	return {"magicskillBasicPanel.swf","xinfaskillBasicPanel.swf"};
end

function UIMagicSkill:IsShowSound()
	return true;
end

function UIMagicSkill:GetWidth()
	return 1110
end;
function UIMagicSkill:GetHeight()
	return 676
end;

function UIMagicSkill:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return; end
	self:InitSkillRedPoint()
	self:RegisterTimes()
	self:InitPageBtn()
	-- trace(self.args)
	-- print("+++++__________________")
	-- 查看args中第一位的参数有没有，如果有的话，说明是要直接跳转到某一个tab
	if self.args and #self.args > 0 then
		local args1 = tonumber(self.args[1]);
		if self.tabButton[args1] then
			self:OnTabButtonClick(args1);
			return;
		end
	end
	--默认打开绝技页面
	self:OnTabButtonClick(FuncConsts.MagicSkill);
end
function UIMagicSkill:OnTabButtonClick(name)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	
	self.tabButton[name].selected = true;
	self:ShowChild(name);
	self.selectPage = name;

	if name == FuncConsts.MagicSkill then
		RemindController:AddRemind(RemindConsts.Type_SkillJueXue, 0);
	end
end
function UIMagicSkill:OnBtnCloseClick()
	self:Hide();
end

--技能红点提示
UIMagicSkill.skillTimerKey = nil;

function UIMagicSkill:RegisterTimes(  )
	self.skillTimerKey = TimerManager:RegisterTimer(function()
		self:InitSkillRedPoint()
	end,1000,0); 
end

UIMagicSkill.skillLoader = nil;
function UIMagicSkill:InitSkillRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return; end
	--技能
	-- if SkillFunc:CheckCanLvlUp() then
		-- PublicUtil:SetRedPoint(objSwf.btnJineng,nil,1)
	-- else
		-- PublicUtil:SetRedPoint(objSwf.btnJineng)
	-- end
	--绝学
	if SkillUtil:CheckJuexueCanLvlUp() then
		PublicUtil:SetRedPoint(objSwf.btnJuexue,nil,1)
	else
		PublicUtil:SetRedPoint(objSwf.btnJuexue)
	end
	--心法
	if SkillUtil:CheckXinfaCanLvlUp() then
		PublicUtil:SetRedPoint(objSwf.btnXinfa,nil,1)
	else
		PublicUtil:SetRedPoint(objSwf.btnXinfa)
	end
end
function UIMagicSkill:OnHide()
	RemindController:AddRemind(RemindConsts.Type_Skill, 0);
	if self.skillTimerKey then
		TimerManager:UnRegisterTimer(self.skillTimerKey);
		self.skillTimerKey = nil;
	end
end
function UIMagicSkill:InitPageBtn( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	-- 绝学
	local magicOpen,openLv = SkillUtil:CheckSkillsFunc(61)
	if magicOpen then
		objSwf.btnJuexue.disabled = false
		objSwf.btnjuexueAdd._visible = false
		objSwf.btnjuexueAdd.disabled = true
	else
		objSwf.btnJuexue.disabled = true
		objSwf.btnjuexueAdd._visible = true
		objSwf.btnjuexueAdd.disabled = false
		objSwf.btnjuexueAdd.rollOver = function() TipsManager:ShowBtnTips(openLv .. "级开启") end
		objSwf.btnjuexueAdd.rollOut = function() TipsManager:Hide() end
	end
	-- 心法
	local xinfaOpen,openLv = SkillUtil:CheckSkillsFunc(114)
	if xinfaOpen then
		objSwf.btnXinfa.disabled = false
		objSwf.btnxinfaAdd._visible = false
	else
		objSwf.btnXinfa.disabled = true
		objSwf.btnxinfaAdd._visible = true
		objSwf.btnxinfaAdd.disabled = false
		objSwf.btnxinfaAdd.rollOver = function() TipsManager:ShowBtnTips(openLv .. "级开启") end
		objSwf.btnxinfaAdd.rollOut = function() TipsManager:Hide() end	
	end

end
function UIMagicSkill:HandleNotification(name,body)
	if name == NotifyConsts.PlayerAttrChange then
		self:InitPageBtn()
	end
end

function UIMagicSkill:ListNotificationInterests()

	return {NotifyConsts.PlayerAttrChange};
end
--[[
技能主面板
lizhuangzhuang
2014年10月9日13:56:14
]]
_G.classlist['UISkill'] = 'UISkill'

_G.UISkill = BaseUI:new("UISkill");

UISkill.tabButton = {};
UISkill.currSelect = nil;
UISkill.selectPage = 0;

UISkill.objName = 'UISkill'

function UISkill:Create()
	self:AddSWF("skillMainPanel.swf",true,"center");
	self:AddChild(UISkillBasic,FuncConsts.Skill);            --技能
	-- self:AddChild(UIMagicSkillBasic,FuncConsts.MagicSkill);  --绝学
	-- self:AddChild(UIXinfaSkillBasic,FuncConsts.XinfaSkill);  --心法
end

function UISkill:OnLoaded(objSwf,name)
	--self:GetChild("basic"):SetContainer(objSwf.childPanel);
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	self:GetChild(FuncConsts.Skill):SetContainer(objSwf.childPanel);
	-- self:GetChild(FuncConsts.MagicSkill):SetContainer(objSwf.childPanel);
	-- self:GetChild(FuncConsts.XinfaSkill):SetContainer(objSwf.childPanel);
	---设置分页按钮----
	self.tabButton[FuncConsts.Skill] = objSwf.btnJineng;
	-- self.tabButton[FuncConsts.MagicSkill] = objSwf.btnJuexue;
	objSwf.btnJuexue._visible = false
	objSwf.btnjuexueAdd._visible = false
	objSwf.btnXinfa._visible = false
	objSwf.btnxinfaAdd._visible = false
	-- self.tabButton[FuncConsts.XinfaSkill] = objSwf.btnXinfa;  
	for name,btn in pairs(self.tabButton) do
		btn.click = function() if name~=self.selectPage then self:OnTabButtonClick(name); end end
	end
	self.btnJinengWidth = objSwf.btnJineng._width;
	-- self.btnJuexueWidth = objSwf.btnJuexue._width;
	--self.btnXinfaWidth = objSwf.btnXinfa._width;
end

--获取技能页签的初始坐标
function UISkill:GetBtnJinengY( )
	return self.btnJinengY
end

function UISkill:GetBtnJuexueY( )
	return self.btnJuexueY
end

function UISkill:GetBtnJinengY( )
	return self.btnXinfaY
end

--技能红点提示
UISkill.skillTimerKey = nil;

function UISkill:RegisterTimes(  )
	self.skillTimerKey = TimerManager:RegisterTimer(function()
		self:InitSkillRedPoint()
	end,1000,0); 
end

UISkill.skillLoader = nil;
function UISkill:InitSkillRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return; end
	--技能
	if SkillFunc:CheckCanLvlUp() then
		PublicUtil:SetRedPoint(objSwf.btnJineng,nil,1)
	else
		PublicUtil:SetRedPoint(objSwf.btnJineng)
	end
	--绝学
	-- if SkillUtil:CheckJuexueCanLvlUp() then
		-- PublicUtil:SetRedPoint(objSwf.btnJuexue,nil,1)
	-- else
		-- PublicUtil:SetRedPoint(objSwf.btnJuexue)
	-- end
	--心法
	-- if SkillUtil:CheckXinfaCanLvlUp() then
		-- PublicUtil:SetRedPoint(objSwf.btnXinfa,nil,1)
	-- else
		-- PublicUtil:SetRedPoint(objSwf.btnXinfa)
	-- end
end

function UISkill:OnHide()
	RemindController:AddRemind(RemindConsts.Type_Skill, 0);
	if self.skillTimerKey then
		TimerManager:UnRegisterTimer(self.skillTimerKey);
		self.skillTimerKey = nil;
	end
end


function UISkill:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return; end
	self:InitSkillRedPoint()
	self:RegisterTimes()
	self:InitPageBtn()
	-- trace(self.args)
	-- print("+++++__________________")
	-- 查看args中第一位的参数有没有，如果有的话，说明是要直接跳转到某一个tab
	-- if #self.args > 0 then
		-- local args1 = tonumber(self.args[1]);
		-- if self.tabButton[args1] then
			-- self:OnTabButtonClick(args1);
			-- return;
		-- end
	-- end
	--默认打开技能页面
	self:OnTabButtonClick(FuncConsts.Skill);
end

function UISkill:InitPageBtn( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	-- 绝学
	local magicOpen,openLv = SkillUtil:CheckSkillsFunc(61)
	-- if magicOpen then
		-- objSwf.btnJuexue.disabled = false
		-- objSwf.btnjuexueAdd._visible = false
		-- objSwf.btnjuexueAdd.disabled = true
	-- else
		-- objSwf.btnJuexue.disabled = true
		-- objSwf.btnjuexueAdd._visible = true
		-- objSwf.btnjuexueAdd.disabled = false
		-- objSwf.btnjuexueAdd.rollOver = function() TipsManager:ShowBtnTips(openLv .. "级开启") end
		-- objSwf.btnjuexueAdd.rollOut = function() TipsManager:Hide() end
	-- end
	-- 心法
	-- local xinfaOpen,openLv = SkillUtil:CheckSkillsFunc(114)
	-- if xinfaOpen then
		-- objSwf.btnXinfa.disabled = false
		-- objSwf.btnxinfaAdd._visible = false
		-- objSwf.btnxinfaAdd.disabled = true
	-- else
		-- objSwf.btnXinfa.disabled = true
		-- objSwf.btnxinfaAdd._visible = true
		-- objSwf.btnxinfaAdd.disabled = false
		-- objSwf.btnxinfaAdd.rollOver = function() TipsManager:ShowBtnTips(openLv .. "级开启") end
		-- objSwf.btnxinfaAdd.rollOut = function() TipsManager:Hide() end
	-- end

end
function UISkill:OnTabButtonClick(name)
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
end


function UISkill:HandleNotification(name,body)
	if name == NotifyConsts.PlayerAttrChange then
		self:InitPageBtn()
	end
end

function UISkill:ListNotificationInterests()

	return {NotifyConsts.PlayerAttrChange};
end

function UISkill:IsTween()
	return true;
end

function UISkill:GetPanelType()
	return 1;
end

function UISkill:WithRes()
	return {"skillBasicPanel.swf"};
end

function UISkill:IsShowSound()
	return true;
end

function UISkill:GetWidth()
	return 1146
end;
function UISkill:GetHeight()
	return 687
end;

function UISkill:OnBtnCloseClick()
	self:Hide();
end


--[[
创建角色界面
lizhuangzhuang
2014年9月2日16:43:13
]]

_G.UICreateRole = BaseUI:new("UICreateRole");

UICreateRole.maxNameLength = 12;--名字最大长度
UICreateRole.prof = _G.enCreateRoleDefaultProf;--职业
UICreateRole.headIcon = _G.enCreateRoleDefaultProf;--头像
UICreateRole.AutoCreateTime = 300000
UICreateRole.clickCreateTime = 0
function UICreateRole:Create()
	self:AddSWF("createRolePanel.swf",true,"story");
end

function UICreateRole:OnLoaded(objSwf)
	--在fla中有做输入限制
	objSwf.bottom.mc.btnCreate.click = function() 
		if GetCurTime() - self.clickCreateTime > 1000 then
			self.clickCreateTime = GetCurTime()
			self:OnBtnCreateClick(); 
		end		
	end
	
	objSwf.bottom.mc.btnName.click = function() self:OnBtnNameClick(); end
	objSwf.bottomBtn.btnLeft.stateChange = function(e) CLoginScene:OnBtnRoleRightStateChange(e.state); end;
	objSwf.bottomBtn.btnRight.stateChange = function(e) CLoginScene:OnBtnRoleLeftStateChange(e.state); end;
	
	self:ResetMc(false)
	for i=1,4 do
		local profBtn = objSwf.right["btnProf"..i];
		if profBtn then
			profBtn.click = function() self:OnBtnProfClick(i, true); end
			
			profBtn.rollOver = function() 
				if self.prof == i then return end
				self:ResetMc(true)
				local profmc = objSwf.right["mcProf"..i];
				if profmc then
					profmc:gotoAndStopEffect(3)
				end
			end
			profBtn.rollOut = function() 
				if self.prof == i then return end
				self:ResetMc(true)
			end
		end
	end
	
	objSwf.bottom.mc.inputName.textChange = function()
								local name = objSwf.bottom.mc.inputName.text;
								if string.getLen(name) > self.maxNameLength then
									FloatManager:AddCenter(StrConfig['login1']);
									objSwf.bottom.mc.inputName.text = string.sub(name,1,-2)
								end
							end
	ChatUtil:InitFilter();
	self:UIHide()
end

function UICreateRole:ResetMc(curProf)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	for i=1,4 do
		local profmc = objSwf.right["mcProf"..i];
		if profmc then
			if curProf and self.prof == i then
				profmc:gotoAndStopEffect(5)
			else
				profmc:gotoAndStopEffect(1)
			end
		end
	end
end


function UICreateRole:DeleteWhenHide()
	return true;
end

function UICreateRole:OnResize(wWidth,wHeight)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.right._x = wWidth - 289
	objSwf.right._y = 0
	objSwf.left._x = 0
	objSwf.left._y = 0
	objSwf.bottom._x = wWidth - objSwf.bottom._width
	if wHeight <= 840 then
		objSwf.bottom._y = wHeight - objSwf.bottom._height + 100
		-- objSwf.bottom._x = (wWidth - objSwf.bottom._width)/2
	else
		objSwf.bottom._y = wHeight - objSwf.bottom._height
	end
	
	-- objSwf.bg._x = (wWidth-objSwf.bg._width)/2;
	-- objSwf.bg._y = (wHeight-objSwf.bg._height)/2;
	
	objSwf.bottomBtn._y = wHeight - 190
	objSwf.bottomBtn._x = (wWidth-objSwf.bottomBtn._width)/2;
end
local isShowUIAni = true
function UICreateRole:UIShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.left._visible = true
	objSwf.right._visible = true
	objSwf.bottom._visible = true
	objSwf.bottomBtn._visible = true
	
	if isShowUIAni then
		objSwf.left:gotoAndPlay(1)
		objSwf.right:gotoAndPlay(1)
		objSwf.bottom:gotoAndPlay(1)
		objSwf.bottomBtn:gotoAndPlay(1)
		isShowUIAni = false
	end
end

function UICreateRole:UIHide()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if isShowUIAni then
		objSwf.left._visible = false
		objSwf.right._visible = false
		objSwf.bottom._visible = false
		objSwf.bottomBtn._visible = false
	end	
end

function UICreateRole:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
		
	local wWidth,wHeight = UIManager:GetWinSize();
	self:OnResize(wWidth,wHeight);
	self:RandomName();
	objSwf.left.mc.mc_zhiyehuizhang:gotoAndStopEffect(_G.enCreateRoleDefaultProf)
	self:ResetMc(false)
	local profmc = objSwf.right["mcProf".._G.enCreateRoleDefaultProf];
	if profmc then
		profmc:gotoAndStopEffect(5)
	end
	self:OnBtnProfClick(_G.enCreateRoleDefaultProf, false);
	-- self:ResetAutoTimer()
end

--点击职业
function UICreateRole:OnBtnProfClick(prof, isChange)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.prof == prof then return end
	
	-- StoryController:OnStorySkip()	
	self.prof = prof;
	self:ResetMc(false)
	local profmc = objSwf.right["mcProf"..prof];
	if profmc then
		profmc:gotoAndStopEffect(5)
	end
	
    -- for i=1,3 do
		-- local headBtn = objSwf.right["btnHead"..i];
		-- if headBtn then
			-- headBtn.loader.source = ResUtil:GetHeadIcon(prof*10+i);
		-- end
	-- end
	-- objSwf.right.btnHead1.selected = true;
	self.headIcon = self.prof;
	self:RandomName();
	objSwf.left.mc.mc_zhiyehuizhang:gotoAndStopEffect(self.prof)
	if isChange then
		CLoginScene:SelectPlayer(prof)
	end
end

--点击头像
function UICreateRole:OnBtnHeadClick(index)
	self.headIcon = self.prof*10+index;
end

--点击创建
 function UICreateRole:OnBtnCreateClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local name = objSwf.bottom.mc.inputName.text;
	if name == "" then
		UIConfirm:Open(StrConfig['login3']);
		return;
	end
	if string.getLen(name) > self.maxNameLength then
		UIConfirm:Open(StrConfig['login1']);
		return;
	end
	if name:find('[%p*%s*]')==1 then
		UIConfirm:Open(StrConfig['login2']);
		return;
	end
	local filterName = ChatUtil.filter:filter(name);
	if filterName:find("*") then
		UIConfirm:Open(StrConfig['login2']);
		return;
	end
	objSwf.bottom.mc.btnCreate.disabled = true
	LoginController:CreateRole(name,self.prof,self.headIcon);
end
 
--点击随机名字
function UICreateRole:OnBtnNameClick()
	self:RandomName();
end

--随机名字
function UICreateRole:RandomName()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local sex = 0;
	if self.prof==enProfType.eProfType_Sword or self.prof==enProfType.eProfType_Human then
		sex = 1;
	else
		sex = 0;
	end
	local surname,name;
	if sex == 0 then
		surname = t_womansurname[math.random(#t_womansurname)].name;
		name = t_womanname[math.random(#t_womanname)].name;
	else
		surname = t_mansurname[math.random(#t_mansurname)].name;
		name = t_manname[math.random(#t_manname)].name;
	end
	objSwf.bottom.mc.inputName.text = surname..name;
end

--随机职业
function UICreateRole:RandomProf()
	-- FPrint( '随机职业'..math.random(4))
	self.prof = math.random(4)
	self.headIcon = self.prof;
	return self.prof
end

--监听消息
function UICreateRole:ListNotificationInterests()
	return {
		NotifyConsts.CreateRoleShowUIEffect, 
		NotifyConsts.CreateRoleHideUIEffect,
		NotifyConsts.CreateRoleBtnStateChanged,
		NotifyConsts.StageClick
	} 
end

--处理消息
function UICreateRole:HandleNotification(name, body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if name == NotifyConsts.CreateRoleShowUIEffect then
		self:UIShow()
	elseif name == NotifyConsts.CreateRoleHideUIEffect then
		self:UIHide()
	elseif name == NotifyConsts.CreateRoleBtnStateChanged then
		objSwf.bottom.mc.btnCreate.disabled = false
		self:ResetAutoTimer()
	elseif name == NotifyConsts.StageClick then
		self:ResetAutoTimer()
	end
	
end

local orbitTimeId = nil

function UICreateRole:ResetAutoTimer()
	if orbitTimeId then TimerManager:UnRegisterTimer(orbitTimeId) end
	-- self:RandomProf()
	-- FPrint('点击舞台')
	orbitTimeId = TimerManager:RegisterTimer(function()
		if orbitTimeId then TimerManager:UnRegisterTimer(orbitTimeId) end
		self:RandomName();
		self:RandomProf()
		if GetCurTime() - self.clickCreateTime > 1000 then
			self.clickCreateTime = GetCurTime()
			LoginController.isAutoCreate = true
			self:OnBtnCreateClick(); 
		end	
	end,
UICreateRole.AutoCreateTime, 1)	
end


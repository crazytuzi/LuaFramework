--[[
创建角色界面
lizhuangzhuang
2014年9月2日16:43:13
]]

_G.UICreateRole = BaseUI:new("UICreateRole");

UICreateRole.maxNameLength = 12;--名字最大长度
UICreateRole.prof = _G.enCreateRoleDefaultProf;--职业
UICreateRole.headIcon = _G.enCreateRoleDefaultProf;--头像
UICreateRole.AutoCreateTime = 30000
-- UICreateRole.AutoSeleteTime = 100

--ui缓动特效
UICreateRole.leftOffsetX = 0
UICreateRole.rightOffsetX = 0
UICreateRole.bottomOffsetY = 100
UICreateRole.leftRightWidth = 290
UICreateRole.leftWidth = 160    --360
UICreateRole.bottomHeight = 270
UICreateRole.uiState = 0		--0无1显示动画2隐藏动画3隐藏
UICreateRole.speed = 6
UICreateRole.clickCreateTime = 0
UICreateRole.loaded = {[_G.enCreateRoleDefaultProf]=true};

function UICreateRole:Create()
	self:AddSWF("createRolePanelOld.swf",true,"story");
end

function UICreateRole:OnLoaded(objSwf)
	--在fla中有做输入限制
	objSwf.bottom.btnCreate.click = function() 
		if GetCurTime() - self.clickCreateTime > 1000 then
			self.clickCreateTime = GetCurTime()
			self:OnBtnCreateClick(); 
		end		
	end
	objSwf.bottom.btnName.click = function() self:OnBtnNameClick(); end
	objSwf.bottom.bottomBtn.btnLeft.stateChange = function(e) CLoginScene:OnBtnRoleRightStateChange(e.state); end;
	objSwf.bottom.bottomBtn.btnRight.stateChange = function(e) CLoginScene:OnBtnRoleLeftStateChange(e.state); end;
	
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
	objSwf.bottom.inputName.textChange = function()
								local name = objSwf.bottom.inputName.text;
								if string.getLen(name) > self.maxNameLength then
									FloatManager:AddCenter(StrConfig['login1']);
									objSwf.bottom.inputName.text = string.sub(name,1,-2)
								end
	end
	
	ChatUtil:InitFilter();
	
	self.uiState = 0
	self.leftOffsetX = 0 ---self.leftWidth
	self.rightOffsetX = 0 --self.leftRightWidth
	self.bottomOffsetY = 0 --self.bottomHeight
	
	objSwf.bottom._visible = false;
	objSwf.right._visible = false;
	objSwf.strengthTip._visible = false;
	objSwf.warningLabel._visible = false;
	objSwf.blackPanel._visible = false;
	self.objSwf.warningLabel.htmlText = UIStrConfig['login9'];
	
	objSwf.loading._visible = false;
	objSwf.loading.gotoAndStop(1);
	
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
	objSwf.right._x = wWidth - self.leftRightWidth + self.rightOffsetX;
	objSwf.right._y = toint((wHeight - (objSwf.right._height -510))/2);  --change 侯旭东 old: 200 new: -200,wqn:old: -200 new: -510
	objSwf.left._x = 0 + self.leftOffsetX;
	objSwf.left._y = (wHeight - objSwf.left._height)/2;
	objSwf.bottom._y = wHeight - (objSwf.bottom._height - 50) + self.bottomOffsetY;
	objSwf.bottom._x = (wWidth - 358)/2 + 40
	
	objSwf.strengthTip._x = (wWidth - objSwf.strengthTip._width)/2;
	objSwf.strengthTip._y = wHeight - 25;
	
	objSwf.blackPanel._x = 0;
	objSwf.blackPanel._y = 0;
	objSwf.blackPanel._width = wWidth;
	objSwf.blackPanel._height = wHeight;
	
	objSwf.warningLabel._x = (wWidth - objSwf.warningLabel._width)/2;
	objSwf.warningLabel._y = (wHeight - objSwf.warningLabel._height)/2;
	
	-- objSwf.bg._x = (wWidth-objSwf.bg._width)/2;
	-- objSwf.bg._y = (wHeight-objSwf.bg._height)/2;
	
	objSwf.loading._x = (wWidth - objSwf.loading._width)/2;
	objSwf.loading._y = (wHeight - objSwf.loading._height)/2;
	
end

function UICreateRole:Update()
	if not self.bShowState then return end
	if self.uiState == 0 then return end 
	local wWidth,wHeight = UIManager:GetWinSize();
	if self.uiState == 1 then
		self.leftOffsetX = self.leftOffsetX + self.speed
		self.rightOffsetX = self.rightOffsetX - self.speed
		self.bottomOffsetY = self.bottomOffsetY - self.speed
		local isEnd = true
		if self.leftOffsetX >= 0 then
			self.leftOffsetX = 0
		else	
			isEnd = false
		end
		if self.rightOffsetX <= 0 then
			self.rightOffsetX = 0
		else	
			isEnd = false
		end
		if self.bottomOffsetY <= 0 then
			self.bottomOffsetY = 0
		else	
			isEnd = false
		end
		UICreateRole:OnResize(wWidth,wHeight)
		if isEnd then
			self.uiState = 0
		end
	elseif self.uiState == 2 then
		self.leftOffsetX = self.leftOffsetX - self.speed
		self.rightOffsetX = self.rightOffsetX + self.speed
		self.bottomOffsetY = self.bottomOffsetY + self.speed
		local isEnd = true
		if self.leftOffsetX <= -self.leftWidth then
			self.leftOffsetX = -self.leftWidth
		else	
			isEnd = false
		end
		if self.rightOffsetX >= self.leftRightWidth then
			self.rightOffsetX = self.leftRightWidth
		else	
			isEnd = false
		end
		if self.bottomOffsetY >= self.bottomHeight then
			self.bottomOffsetY = self.bottomHeight
		else	
			isEnd = false
		end
		UICreateRole:OnResize(wWidth,wHeight)
		if isEnd then
			self.uiState = 0
		end
	end
end

function UICreateRole:UIShow()
	if self.uiState == 1 then return end
	self.uiState = 1
	
	self.leftOffsetX = 0 ---self.leftWidth
	self.rightOffsetX = 0 --self.leftRightWidth
	self.bottomOffsetY = 0 --self.bottomHeight
end

function UICreateRole:UIHide()
	if self.uiState == 2 or self.uiState == 3 then return end
	self.uiState = 2
	
	self.leftOffsetX = 0
	self.rightOffsetX = 0
	self.bottomOffsetY = 0
end

function UICreateRole:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local wWidth,wHeight = UIManager:GetWinSize();
	
	self:OnResize(wWidth,wHeight);

	-- TimerManager:RegisterTimer(function()
	-- 	if not self:IsShow() then return end
	-- 	if self.prof ~= 0 then return end
	-- 	self:OnBtnProfClick(_G.enCreateRoleDefaultProf, true)
	-- end, UICreateRole.AutoSeleteTime, 1)	

	self.objSwf.bottom._visible = true;
	self.objSwf.right._visible = true;
	self.objSwf.strengthTip._visible = true;
	self.objSwf.warningLabel._visible = false;
	self.objSwf.blackPanel._visible = false;

	self:RandomName();
	self:ResetMc(false)
	if self.prof ~= 0 then
		objSwf.left.mc.mc_zhiyehuizhang:gotoAndStopEffect(_G.enCreateRoleDefaultProf)
		objSwf.right["btnProf" .. self.prof].selected = true

		local profmc = objSwf.right["mcProf".._G.enCreateRoleDefaultProf];
		if profmc then
			profmc:gotoAndStopEffect(5)
		end

		-- self:OnBtnProfClick(_G.enCreateRoleDefaultProf, false);
	end
	self:UIShow();
--[[
	Tween:To(self.objSwf.blackPanel,4,{_alpha=100},{onComplete=function()
			Tween:To(self.objSwf.blackPanel,2,{_alpha=0});
			Tween:To(self.objSwf.warningLabel,2,{_alpha=0},
					{onComplete=function()
						onCompleteHandler()
					end},true);
			end},true);
	]]
	-- onCompleteHandler();
	ShampublicityModel:Enter(1)
end

function UICreateRole:OnHide()
	UIConfirm:Hide()
	ShampublicityModel:Enter(2)
end

--点击职业
function UICreateRole:OnBtnProfClick(prof, isChange)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.prof == prof then return end
	if CLoginScene.isJump then
		objSwf.right["btnProf"..self.prof].selected = true
		return
	end
	objSwf.right["btnProf" .. prof].selected = true
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
		local loaded = self.loaded[prof];
		if not loaded then
			objSwf.loading._visible = true;
			objSwf.loading:gotoAndPlay(1);
			objSwf.loading.txt.text = "0%"
			UILoaderManager:LoadGroup("createprof"..prof,false,function()
					self.loaded[prof] = true;
					if self.prof == prof then
						CLoginScene:CreatePlayer(prof)

						if objSwf and objSwf.loading then
							objSwf.loading._visible = false;
							objSwf.loading:gotoAndStop(1);
						end
					end
				end, function(e)
					if self.prof == prof then
						if objSwf and objSwf.loading then
							objSwf.loading.txt.text = toint(e*100,0.5) .. "%"
						end
					end
				end);
		else
			CLoginScene:CreatePlayer(prof)
			objSwf.loading._visible = false;
			objSwf.loading:gotoAndStop(1);
		end
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
	if self.timeID then
		TimerManager:UnRegisterTimer(self.timeID)
		objSwf.bottom.txt_time.text = ""
	end
	if self.prof == 0 then 
		print("没选择角色！")
		return 
	end
	local name = objSwf.bottom.inputName.text;
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
	objSwf.bottom.btnCreate.disabled = true
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
	local surname,name;
	while true do
		if self.prof==enProfType.eProfType_Woman or self.prof==enProfType.eProfType_Human then
			sex = 1;
		else
			sex = 0;
		end
		if sex == 0 then
			surname = t_womansurname[math.random(#t_womansurname)].name;
			name = t_womanname[math.random(#t_womanname)].name;
		else
			surname = t_mansurname[math.random(#t_mansurname)].name;
			name = t_manname[math.random(#t_manname)].name;
		end
		local allName = surname..name
		local filterName = ChatUtil.filter:filter(allName);
		if not filterName:find("*") then
			break
		end
	end
	objSwf.bottom.inputName.text = surname..name
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
		objSwf.bottom.btnCreate.disabled = false
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
	if self.StartTime then
		if UICreateRole.AutoCreateTime + self.StartTime - GetCurTime() < 15000 then
			UICreateRole.AutoCreateTime = 15000
		else
			UICreateRole.AutoCreateTime = UICreateRole.AutoCreateTime + self.StartTime - GetCurTime()
		end
	end
	orbitTimeId = TimerManager:RegisterTimer(function()
		if orbitTimeId then TimerManager:UnRegisterTimer(orbitTimeId) end
		-- self:RandomName();
		-- self:RandomProf()
		if GetCurTime() - self.clickCreateTime > 1000 then
			self.clickCreateTime = GetCurTime()
			LoginController.isAutoCreate = true
			self:OnBtnCreateClick(); 
		end	
	end,
	UICreateRole.AutoCreateTime, 1)
	if self.timeID then
		TimerManager:UnRegisterTimer(self.timeID)
	end

	self.StartTime = GetCurTime()
	self.timeID = TimerManager:RegisterTimer(function()
		if not self.objSwf then return end
		self.objSwf.bottom.txt_time.text = PublicUtil.GetString("login58", math.ceil((UICreateRole.AutoCreateTime + self.StartTime - GetCurTime())/1000)) end
	, 1000)
end


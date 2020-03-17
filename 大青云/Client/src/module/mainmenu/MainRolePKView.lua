--[[
	PK状态选择界面
	2014年12月5日, PM 03:16:38
	wangyanwei
]]
--peace team union servicer camp goodEvil allRole custom

_G.UIMainRolePKPanel = BaseUI:new("UIMainRolePKPanel");

UIMainRolePKPanel.func = nil;

UIMainRolePKPanel.PKStateIndex = 0; --我对模式的选择

UIMainRolePKPanel.defined = 0;

function UIMainRolePKPanel:Create()
	self:AddSWF("mainPagePK.swf", true, "top");
end

function UIMainRolePKPanel:OnLoaded(objSwf)
	local mainObj =  UIMainHead:GetSWF("UIMainHead");
	
	objSwf.bg.rollOver = function () self:OnBgOverHandler();	end
	
end

function UIMainRolePKPanel:Open(func)
	self.func = func;
	self:Show();
end
function UIMainRolePKPanel:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self.PKStateIndex = MainRolePKModel:GetPKIndex();
	objSwf["statePK_" .. self.PKStateIndex].selected = true;
	
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then self:Hide(); return end
	local pkSelectCfg = split(mapCfg.can_changePK,',');
	
	local stateObj = MainRolePKModel:GetStatePKData();
	for i = 0 , 7 do
		local pkStateBoolean = false;
		for q , p in pairs (stateObj[i + 1]) do
			pkStateBoolean = p;
		end
		if pkStateBoolean then
			objSwf["statePK_" .. i].label = UIStrConfig["mainmenuPK0" .. (i+1)];
			objSwf["statePK_" .. i].disabled = pkStateBoolean;
		else
			local state = false;
			for index , pkState in ipairs(pkSelectCfg) do
				if i == toint(pkState) then
					state = false;
					break;
				end
				if index >= #pkSelectCfg then
					state = true;
				end
			end
			objSwf["statePK_" .. i].disabled = state;
			if objSwf["statePK_" .. i].disabled then
				objSwf["statePK_" .. i].label = UIStrConfig["mainmenuPK0" .. (i+1)];
			else
				objSwf["statePK_" .. i].htmlLabel = UIStrConfig["mainmenuPK00" .. (i+1)];
			end
		end
		objSwf["statePK_" .. i].click = function () self:OnPKStateClickHandler(i); end
		objSwf["statePK_" .. i].rollOver = function () self:OnBgOverHandler(); end
	end
	
	for i = 1 , 6 do
		objSwf["custom_" .. i].disabled = objSwf.statePK_7.disabled;
		objSwf["custom_" .. i].htmlLabel = UIStrConfig["mainmenuDefined00" .. i];
		objSwf["custom_" .. i].selected = MainRolePKModel.PKData[i].pkBoolean;
		objSwf["custom_" .. i].click = function () self:OnCustomClickHandler(); end;
		objSwf["custom_" .. i].rollOver = function () self:OnBgOverHandler(); end
	end
end
--背景移入事件
function UIMainRolePKPanel:OnBgOverHandler()
	if UIMainHead.timeKey ~= nil then
		TimerManager:UnRegisterTimer(UIMainHead.timeKey);
	end
	if self.timeKey ~=nil then
		TimerManager:UnRegisterTimer(self.timeKey);
	end
end
--item点击事件
function UIMainRolePKPanel:OnPKStateClickHandler(eName)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if UIMainHead.timeKey ~= nil then
		TimerManager:UnRegisterTimer(UIMainHead.timeKey);
	end
	if self.timeKey ~=nil then
		TimerManager:UnRegisterTimer(self.timeKey);
	end
	if self.PKStateIndex == eName then return end   --如果此次点击的Index与上次的记录Index一致 return；
	self.PKStateIndex = eName;
	
	
		
	if self.PKStateIndex ~= 7 then
		if self.PKStateIndex == MainRolePKModel:GetPKIndex() then return end;  --如果与上一次选择一样且不是自定义 return；
		MainMenuController:OnSendPkState(self.PKStateIndex);
	end
	if self.PKStateIndex == 7 then
		MainRolePKModel:SetPKStateHandler(self.PKStateIndex,self.defined)
	end
end
--自定义子按钮点击事件
function UIMainRolePKPanel:OnCustomClickHandler()
	local objSwf = self.objSwf;
	if objSwf.statePK_7.disabled then return end
	self.defined = 0;
	for i = 1 , 6 do
		if objSwf["custom_" .. i].selected == true then
			local mathPowNum = math.pow(2,(6-i));
			self.defined = self.defined + mathPowNum;
		end
	end
	self.PKStateIndex = 7;
	objSwf["statePK_" .. 7].selected = true;
	
	if self.PKStateIndex ~= 7 then
		if self.PKStateIndex == MainRolePKModel:GetPKIndex() then return end;  --如果与上一次选择一样且不是自定义 return；
		MainMenuController:OnSendPkState(self.PKStateIndex);
	end
	if self.PKStateIndex == 7 then
		MainRolePKModel:SetPKStateHandler(self.PKStateIndex,self.defined)
	end
end

UIMainRolePKPanel.hideBoolean = false;  --做个是否已经移入到面板的判断
function UIMainRolePKPanel:Update()
	if not self.bShowState then return; end
	local objSwf  = self.objSwf ;
	if not objSwf then return end;
	if self.hideBoolean == false then
		if objSwf._xmouse>0 and objSwf._xmouse<self:GetWidth() and objSwf._ymouse>0 and objSwf._ymouse<self:GetHeight() then
			self.hideBoolean = not self.hideBoolean;
		end
	end
	if self.hideBoolean then
		if objSwf._xmouse>0 and objSwf._xmouse<self:GetWidth() and objSwf._ymouse>0 and objSwf._ymouse<self:GetHeight() then
			return;
		end
		self:func();
		self.hideBoolean = not self.hideBoolean;
	end
end

--[[
	2015年6月17日, PM 03:03:35
	击杀信息
	wangyanwei
]]

_G.UIMainKillRecord = BaseUI:new('UIMainKillRecord');

-- UIMainKillRecord.KillConsts = {
	-- [KillMe] = 1,
	-- [KillOther] = 2,
-- }

UIMainKillRecord.KillMe = 1;
UIMainKillRecord.KillOther = 2;

--//所有在线击杀信息储存
UIMainKillRecord.killData = {
	[UIMainKillRecord.KillMe] = {},
	[UIMainKillRecord.KillOther] = {},
}

function UIMainKillRecord:Create()
	self:AddSWF('killRecord.swf',true,'bottom')
end

function UIMainKillRecord:OnLoaded(objSwf)
	objSwf.infoPanel.btn_killMe.click = function () self:OnTableClickHandler(self.KillMe); end
	objSwf.infoPanel.btn_killOther.click = function () self:OnTableClickHandler(self.KillOther); end
	objSwf.infoPanel.btn_close.click = function () self:Hide(); end
	objSwf.infoPanel.btn_quit.click = function () self:Hide(); end
	objSwf.infoPanel.btn_killMe.selected = true;
	objSwf.infoPanel.visible = false;
	
	objSwf.btn_killRecord.click = function () self:OnShowInfoPanelClick(); end
end

function UIMainKillRecord:OnShowInfoPanelClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_killRecord.visible = false;
	objSwf.infoPanel.visible = true;
end

UIMainKillRecord.tabIndex = nil;
function UIMainKillRecord:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_killRecord.visible = true;
	objSwf.infoPanel.visible = false;
	self:OnTableClickHandler(self.tabIndex);
end

function UIMainKillRecord:Open(tabConsts)
	if not tabConsts then return end
	self.tabIndex = tabConsts;
		
	if ActivityController:InActivity() then
		local activityID = ActivityController:GetCurrId();
		for i , v in pairs(MainMenuConsts.HideActivityConsts) do
			if activityID == v.id then
				return
			end
		end
	end
	if UnionWarModel:GetIsAtUnionActivity() then return end			--帮派战
	if UnionCityWarModel:GetIsAtUnionActivity() then return end		--帮派王城战
	
	local mapId =  CPlayerMap:GetCurMapID();
	for i , v in ipairs(MainMenuConsts.HideMapConsts) do
		if mapId == v.id then
			return
		end
	end
	
	if self:IsShow() then
		self:OnTableClickHandler(self.tabIndex);
	else
		self:Show();
	end
end

function UIMainKillRecord:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_killRecord.visible = true;
	objSwf.infoPanel.visible = false;
	objSwf.infoPanel._x = 0;
	objSwf.infoPanel._y = 0;
	UIMainKillRecord.tabIndex = nil;
end

function UIMainKillRecord:OnTableClickHandler(tabConsts)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local data = nil;
	if tabConsts == self.KillMe then
		data = self:OnGetKillMeData();
		objSwf.infoPanel.btn_killMe.selected = true;
	elseif tabConsts == self.KillOther then
		data = self:OnGetKillOtherData();
		objSwf.infoPanel.btn_killOther.selected = true;
	end
	if not data then return end
	objSwf.infoPanel.list.dataProvider:cleanUp();
	for i , v in ipairs(data) do
		local cfg = data[#data - i + 1];
		local obj = {};
		obj.rollID = cfg.roleID;
		obj.roleName = cfg.roleName;
		obj.roleLevel = cfg.roleLevel;
		obj.killTime = cfg.killTime;
		obj.killMap = cfg.killMap;
		objSwf.infoPanel.list.dataProvider:push(UIData.encode(obj));
	end
	objSwf.infoPanel.list:invalidateData();
	self:OnChangeTopTxt();
end

--更换list上部文本内容
function UIMainKillRecord:OnChangeTopTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if objSwf.infoPanel.btn_killMe.selected then
		objSwf.infoPanel.tf1.text = StrConfig['killRecord1'];
		objSwf.infoPanel.tf2.text = StrConfig['killRecord2'];
		objSwf.infoPanel.tf3.text = StrConfig['killRecord3'];
		objSwf.infoPanel.tf4.text = StrConfig['killRecord4'];
	else
		objSwf.infoPanel.tf1.text = StrConfig['killRecord6'];
		objSwf.infoPanel.tf2.text = StrConfig['killRecord7'];
		objSwf.infoPanel.tf3.text = StrConfig['killRecord8'];
		objSwf.infoPanel.tf4.text = StrConfig['killRecord9'];
	end
end 

--获取自己死亡的信息
function UIMainKillRecord:OnGetKillMeData()
	return self.killData[self.KillMe];
end

--获取击杀别人的信息
function UIMainKillRecord:OnGetKillOtherData()
	return self.killData[self.KillOther];
end

function UIMainKillRecord:GetWidth()
	return 81
end

function UIMainKillRecord:GetHeight()
	return 51
end

------------///////////////push data\\\\\\\\\\\\\\-------------

--击杀提醒打开  自己死亡
function UIMainKillRecord:OpenKillMe(killerCid,killerName,killerLevel)
	local playerData = self:OnKillMeData(killerCid,killerName,killerLevel);
	table.push(self.killData[self.KillMe],playerData);
	if #self.killData[self.KillMe] > 10 then
		table.remove(self.killData[self.KillMe],1);
	end
	self:Open(self.KillMe);
end

--击杀提醒打开  别人死亡
function UIMainKillRecord:OpenKillOther(roleID)
	local playerData = self:OnGetPlayerData(roleID);
	table.push(self.killData[self.KillOther],playerData);
	if #self.killData[self.KillOther] > 10 then
		table.remove(self.killData[self.KillOther],1);
	end
	self:Open(self.KillOther);
end

--自己死亡判断
function UIMainKillRecord:OnKillMeData(killerCid,killerName,killerLevel)
	local playerKillData = {};
	playerKillData.rollID = killerCid;					--击杀ID
	playerKillData.roleName = killerName;		--击杀名称
	playerKillData.roleLevel = killerLevel;		--击杀等级
	playerKillData.killTime = self:OnGetNowLeaveTime();				--击杀时间
	playerKillData.killMap = self:OnGetDeadMapName();				--击杀地点
	-- trace(playerKillData)
	return playerKillData
end

--人物判断
function UIMainKillRecord:OnGetPlayerData(roleID)
	local player = CPlayerMap:GetPlayer(roleID);
	if not player then return end
	local playerData = player:GetPlayerShowInfo();
	local playerKillData = {};
	local playerInfo = player:GetPlayerInfo();
	playerKillData.rollID = player:GetRoleID();					--击杀ID
	playerKillData.roleName = playerInfo[enAttrType.eaName];		--击杀名称
	playerKillData.roleLevel = playerInfo[enAttrType.eaLevel];		--击杀等级
	playerKillData.killTime = self:OnGetNowLeaveTime();				--击杀时间
	playerKillData.killMap = self:OnGetDeadMapName();				--击杀地点
	
	return playerKillData
end

--获取死亡地点
function UIMainKillRecord:OnGetDeadMapName()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end
	return mapCfg.name;
end

--获取时间 年月日时分秒 a-a-a b:b:b
function UIMainKillRecord:OnGetNowLeaveTime()
	local timeData = CTimeFormat:todate(GetServerTime(), false);
	local cfg = split(timeData,' ');
	local str1 = split(cfg[1],'-');
	local str2 = split(cfg[2],':');
	return string.format(StrConfig['killRecord20'],str1[2],str1[3],str2[1],str2[2]);
end
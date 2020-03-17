--[[
他人任务详细信息面板
2015年2月10日11:33:14
zhangshuhui
]]

_G.UIOtherRoleInfo = BaseUI:new("UIOtherRoleInfo");

local s_roleInfo = {"姓    名：","等    级：","结    拜：","荣    誉：","帮    派：","PK    值：","功    勋：","声    望：","配    偶：",};

function UIOtherRoleInfo:Create()
	self:AddSWF("roleInfoPanel.swf", true, nil);
end

function UIOtherRoleInfo:OnLoaded( objSwf )
	-- return true
end

function UIOtherRoleInfo:OnShow()
	self:ClearUI();
	local objSwf = self.objSwf
	if OtherRoleModel.otherhumanXXInfo then
		self:ShowInfo();
	else
		self:ShowProInfo()
		if OtherRoleModel.otherhumanBSInfo and OtherRoleModel.otherhumanBSInfo.dwRoleID then
			local typeinfo = bit.band(255, OtherRoleConsts.OtherRole_Info);
			RoleController:ViewRoleInfo(OtherRoleModel.otherhumanBSInfo.dwRoleID, typeinfo)
		end
	end
	for i = 1, 9 do
		objSwf["RollBtn"..i].label = "" --s_roleInfo[i]
	end
	for i = 1, 40 do
		local btn = objSwf["ProBtn" ..i]
		local text = objSwf["proText" ..i].text
		btn.visible = true
	end
end

function UIOtherRoleInfo:ShowInfo()
	self:ShowRoleInfo()
	self:ShowProInfo()
end

function UIOtherRoleInfo:ShowRoleInfo()
	--- 基础信息
	local objSwf = self.objSwf
	if not objSwf then return end
	local info = OtherRoleModel.otherhumanBSInfo;
	local xxInfo = OtherRoleModel.otherhumanXXInfo;
	objSwf.RollText1.text.text = getAtrrShowVal( enAttrType.eaName, info.eaName)

	local guildName = info.eaGuildName;
	objSwf.RollText5.text.text = guildName and guildName ~= "" and guildName or StrConfig['role301']

	local marryName = MarryUtils:GetTitleName()
	objSwf.RollText9.text.text = marryName and marryName ~= "" and marryName or StrConfig['role429']

	objSwf.RollText2.text.text = getAtrrShowVal( enAttrType.eaLevel, info.eaLevel)
	objSwf.RollText3.text.text = StrConfig['role426']
	local i = 0
	for key,value in pairs(enAttrType) do
		if key=='eaPKVal' then
			i = value;
			objSwf.RollText6.text.text = getAtrrShowVal( enAttrType.eaPKVal, xxInfo[i])
		end
		if key=='eaHonor' then
			i = value;
			objSwf.RollText4.text.text = getAtrrShowVal( enAttrType.eaHonor, xxInfo[i])
		end
	end
	objSwf.RollText7.text.text = 0
	objSwf.RollText8.text.text = 0
end

function UIOtherRoleInfo:ShowProInfo()
	print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
	local objSwf = self.objSwf
	local allValue = #PublicAttrConfig.pro
	local info = OtherRoleModel.otherhumanBSInfo or {};
	local xxInfo = OtherRoleModel.otherhumanXXInfo or {};

	for i = 1, 4 do
		local btn = objSwf["sProlBtn" ..i]
		local text = objSwf["sProText" ..i].text
		local proStr = PublicAttrConfig.pro[allValue + 1 -i]
		btn.label = PublicAttrConfig.roleProName[proStr]
		btn.rollOver = function() TipsManager:ShowTips(TipsConsts.Type_Normal, PublicAttrConfig.TipsStr[proStr] or "属性TIPS未填", TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown) end
		btn.rollOut = function() TipsManager:Hide() end
		local typeStr = AttrParseUtil:GetTypeStr(proStr)
		text.text = getAtrrShowVal(enAttrType[typeStr], info[typeStr] or 0)
	end

	for i = 1, 40 do
		local btn = objSwf["ProBtn" ..i]
		local text = objSwf["proText" ..i].text
		if i > (allValue - 4) then
			btn.visible = false
			btn.label = ""
			text.text = ""
		else
			btn.visible = true
			local proStr = PublicAttrConfig.pro[i]
			btn.label = PublicAttrConfig.roleProName[proStr]
			btn.rollOver = function() TipsManager:ShowTips(TipsConsts.Type_Normal, PublicAttrConfig.TipsStr[proStr] or "属性TIPS未填", TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown) end
			btn.rollOut = function() TipsManager:Hide() end
			local typeStr = AttrParseUtil:GetTypeStr(proStr)
			-- print('-----------------------------typeStr:'..typeStr)
			local j = 0
			for key,value in pairs(enAttrType) do
				if key==typeStr then
					j = value;
				end
			end
			if typeStr == 'eaMingZhong' or
			   typeStr == 'eaShanBi' or
			   typeStr == 'eaBaoJi' or
			   typeStr == 'eaHp' or
			   typeStr == 'eaGongJi' or
			   typeStr == 'eaFangYu' or
			   typeStr == 'eaMaxHp' or
			   typeStr == 'eaRenXing' then
			   xxInfo[j] = math.ceil(xxInfo[j] or 0);
			 end
			text.text = getAtrrShowVal(enAttrType[typeStr], xxInfo[j] or 0)
		end
	end
end
function UIOtherRoleInfo:ClearUI()
	local objSwf = self.objSwf;
	for i = 1, 40 do
		local btn = objSwf["ProBtn" ..i]
		local text = objSwf["proText" ..i].text
		btn.visible = false
		text.text = ""
	end
end
---------------------------------消息处理------------------------------------
function UIOtherRoleInfo:HandleNotification(name,body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.OtherRoleXXInfo then
		self:ShowInfo();
	end
end

function UIOtherRoleInfo:ListNotificationInterests()
	return {NotifyConsts.OtherRoleXXInfo};
end
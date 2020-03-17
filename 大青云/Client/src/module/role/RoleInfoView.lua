--[[
任务详细信息面板
2015年2月4日11:57:14
haohu
]]

_G.UIRoleInfo = BaseUI:new("UIRoleInfo");

local s_roleInfo = {"姓    名：","等    级：","结    拜：","荣    誉：","帮    派：","PK    值：","功    勋：","声    望：","配    偶：",};

function UIRoleInfo:Create()
	self:AddSWF("roleInfoPanel.swf", true, nil);
end

function UIRoleInfo:OnLoaded( objSwf )
	return true
end

function UIRoleInfo:OnShow()
	local objSwf = self.objSwf
	for i = 1, 9 do
		objSwf["RollBtn"..i].label = "" --s_roleInfo[i]
	end
	self:ShowInfo()
end

function UIRoleInfo:ShowInfo()
	self:ShowRoleInfo()
	self:ShowProInfo()
end

function UIRoleInfo:ShowRoleInfo()
	--- 基础信息
	local objSwf = self.objSwf
	if not objSwf then return end
	local info = MainPlayerModel.humanDetailInfo
	objSwf.RollText1.text.text = getAtrrShowVal( enAttrType.eaName, info.eaName)

	local guildName = UnionModel.MyUnionInfo.guildName
	objSwf.RollText5.text.text = guildName and guildName ~= "" and guildName or StrConfig['role301']

	local marryName = MarryUtils:GetTitleName()
	objSwf.RollText9.text.text = marryName and marryName ~= "" and marryName or StrConfig['role429']

	objSwf.RollText2.text.text = getAtrrShowVal( enAttrType.eaLevel, info.eaLevel)
	objSwf.RollText3.text.text = StrConfig['role426']
	objSwf.RollText6.text.text = getAtrrShowVal( enAttrType.eaPKVal, info.eaPKVal)
	objSwf.RollText4.text.text = MainPlayerModel.humanDetailInfo.eaHonor or 0
	objSwf.RollText7.text.text = 0
	objSwf.RollText8.text.text = 0
end

function UIRoleInfo:ShowProInfo()
	local objSwf = self.objSwf
	local allValue = #PublicAttrConfig.pro
	local info = MainPlayerModel.humanDetailInfo

	for i = 1, 4 do
		local btn = objSwf["sProlBtn" ..i]
		local text = objSwf["sProText" ..i].text
		local proStr = PublicAttrConfig.pro[allValue -4 +i]
		btn.htmlLabel = PublicStyle:GetAttrNameStr(PublicAttrConfig.roleProName[proStr], "#e4b752")
		btn.rollOver = function() TipsManager:ShowTips(TipsConsts.Type_Normal, PublicAttrConfig.TipsStr[proStr] or "属性TIPS未填", TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown) end
		btn.rollOut = function() TipsManager:Hide() end
		local typeStr = AttrParseUtil:GetTypeStr(proStr)
		text.htmlText = PublicStyle:GetAttrValStr(getAtrrShowVal(enAttrType[typeStr], info[typeStr] or 0), "#e4e4e4")
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
			btn.htmlLabel = PublicStyle:GetAttrNameStr(PublicAttrConfig.roleProName[proStr], "#e4b752");
			btn.rollOver = function() TipsManager:ShowTips(TipsConsts.Type_Normal, PublicAttrConfig.TipsStr[proStr] or "属性TIPS未填", TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown) end
			btn.rollOut = function() TipsManager:Hide() end
			local typeStr = AttrParseUtil:GetTypeStr(proStr)
			text.htmlText = PublicStyle:GetAttrValStr(getAtrrShowVal(enAttrType[typeStr], info[typeStr] or 0), "#e4e4e4")
		end
	end
end

function UIRoleInfo:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.KillValueChange,
		NotifyConsts.ArenaUpMyInfo
	};
end

function UIRoleInfo:HandleNotification( name, body )
	self:ShowInfo()
end
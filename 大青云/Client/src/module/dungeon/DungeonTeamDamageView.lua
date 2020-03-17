--[[
组队副本伤害统计
2015年1月15日18:16:39
haohu
]]

_G.UIDungeonTeamDamage = BaseUI:new("UIDungeonTeamDamage");

UIDungeonTeamDamage.damageInfo = nil;

function UIDungeonTeamDamage:Create()
	self:AddSWF("dungeonDamagePanel.swf", true, "center");
end

function UIDungeonTeamDamage:OnLoaded( objSwf )
	objSwf.btnL.click = function() self:OnBtnHideClick(); end
	objSwf.btnS.click = function() self:OnBtnShowClick(); end
end

function UIDungeonTeamDamage:OnShow()
	self:ShowTitle();
	self:ShowDamage();
end

function UIDungeonTeamDamage:OnHide()
	self.damageInfo = nil;
end

--点击隐藏按钮
function UIDungeonTeamDamage:OnBtnHideClick()
	self:HideList();
end

--点击显示按钮
function UIDungeonTeamDamage:OnBtnShowClick()
	self:ShowList();
end

local titleTxt;
function UIDungeonTeamDamage:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.isHide then
		self:ShowDamage();
		objSwf.listContainer.visible = true;
		objSwf.btnL._visible = true;
		objSwf.btnS._visible = false;
		objSwf.txtTitle.text = titleTxt;
		self.isHide = false;
	end
end

function UIDungeonTeamDamage:HideList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.isHide then
		objSwf.listContainer.visible = false;
		objSwf.btnL._visible = false;
		objSwf.btnS._visible = true;
		titleTxt = objSwf.txtTitle.text;
		objSwf.txtTitle.text = string.format( "%s...", string.sub(titleTxt, 1, 6) );
		self.isHide = true;
	end
end

function UIDungeonTeamDamage:ShowTitle()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local dungeonId = DungeonModel.currentDungeonId;
	if not dungeonId then return; end
	local cfg = t_dungeons[dungeonId];
	if not cfg then return; end
	local rewardTypeTxt = DungeonConsts:GetDungeonRewardTypeTxt(cfg.reward_type);
	objSwf.txtTitle.text = string.format( "%s%s", cfg.name, rewardTypeTxt );
end

function UIDungeonTeamDamage:ShowDamage()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.listContainer.list;
	list.dataProvider:cleanUp();
	local listUIData = self:GetListProvider();
	for i = 1, #listUIData do
		list.dataProvider:push( listUIData[i] );
	end
	list:invalidateData();
end

function UIDungeonTeamDamage:GetListProvider()
	local list = {};
	local damageRankList = self:GetSortedDamageInfo();
	for rank, vo in ipairs( damageRankList ) do
		vo.rank = rank
		table.push( list, UIData.encode(vo) );
	end
	return list;
end

function UIDungeonTeamDamage:Refresh( damageInfo )
	if not self:IsShow() then return end
	self.damageInfo = damageInfo;
	if self.IsShow then
		self:ShowDamage();
	end
end

-- 需求:06-15 11:49:30 之前是按第一名的百分比来显示，改成按总伤害的百分比来显示
function UIDungeonTeamDamage:GetSortedDamageInfo()
	local damageDetailInfo = {};
	local damageMap, totalDamage = self:GetPlayerDamageMap()
	local members = TeamModel:GetMemberList();
	for _, memberVO in pairs(members) do
		local vo = {};
		vo.maxDamage = totalDamage
		local damage = damageMap[ memberVO.roleID ] or 0
		vo.damage    = damage
		vo.online    = memberVO.online;
		vo.level     = memberVO.level;
		vo.name      = memberVO.roleName;
		local proportion = totalDamage > 0 and (damage / totalDamage) or 0
		local damagePer = toint( proportion * 100, 0.5 ) .. "%";
		vo.damageTxt = string.format( StrConfig["dungeon701"], toint( damage, 0.5 ), damagePer );
		table.push( damageDetailInfo, vo );
	end
	table.sort( damageDetailInfo, function(A, B) return A.damage > B.damage; end );
	return damageDetailInfo;
end

-- @return damageMap : 伤害字典，key = roleId, value = damage
-- @return totalDamage : 伤害总量
function UIDungeonTeamDamage:GetPlayerDamageMap()
	local damageInfo = self.damageInfo or {}
	local totalDamage = 0
	local damageMap = {}
	for _, damageVO in pairs(damageInfo) do
		damageMap[damageVO.roleId] = damageVO.damage
		totalDamage = totalDamage + damageVO.damage
	end
	return damageMap, totalDamage
end

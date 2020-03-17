--[[
当前选中目标-怪物
haohu
2014年8月19日19:55:04
]]

_G.UITargetMonster = UITarget:new("UITargetMonster");

function UITargetMonster:GetSwfName()
	return "targetMonster.swf";
end

function UITargetMonster:HandleEvents( objSwf )
	local btnView = objSwf.btnView;
	btnView._visible = false
	btnView.click    = function(e) self:OnBtnViewClick(e) end
	btnView.rollOver = function(e) self:OnBtnViewRollOver(e) end
	btnView.rollOut  = function() self:OnBtnViewRollOut() end
end

function UITargetMonster:OnBtnViewClick(e)
	local monsterId = TargetModel:GetId();
	UITargetDropInfoDetail:Open( monsterId, e.target );
end

function UITargetMonster:OnBtnViewRollOver(e)
	UITargetDropInfo:Open( e.target );
end

function UITargetMonster:OnBtnViewRollOut(e)
	UITargetDropInfo:Hide();
end

function UITargetMonster:GetWidth()
	return 349;
end

function UITargetMonster:GetIconUrl()
	local monsterId = TargetModel:GetId();
	local cfg = t_monster[monsterId];
	if not cfg then return end;
	local modelCfg = t_model[ cfg.modelId ];
	local iconName = modelCfg and modelCfg.icon;
	if not iconName or iconName == "" then return end;
	return ResUtil:GetMonsterIconName(iconName);
end

function UITargetMonster:GetName()
	local monsterId = TargetModel:GetId()
	local name      = TargetModel:GetName()
	-- local realmName = TargetUtils:GetRealName(monsterId)
	local CId = TargetModel:GetCId()
	if _G.isDebug then
		name = string.format("%s Lv.%s ID:%s Cid:%s", name, self:GetLevel(), monsterId, printguid(CId));
	else
		name = string.format("%s Lv.%s", name, self:GetLevel());
	end
	return name
end

function UITargetMonster:GetLevel()
	local monsterId = TargetModel:GetId();
	local cfg = t_monster[monsterId];
	return cfg and cfg.level;
end
function UITargetMonster:UpdateIcon()
	
end
--等级和名字显示在一起了
function UITargetMonster:UpdateLvl()
	self:UpdateName();
end

function UITargetMonster:NeverDeleteWhenHide()
	return true;
end
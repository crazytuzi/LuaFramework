--[[
选中目标头像工具类
2014年12月16日16:26:31
haohu
]]

_G.TargetUtils = {};


-- 获取掉落类型文本
function TargetUtils:GetDropTypeName(dropType)
	local dropTypeName = "";
	if dropType == TargetConsts.DropType_NoneOwn then
		dropTypeName = StrConfig['tips601'];
	elseif dropType == TargetConsts.DropType_LastHitOwn then
		dropTypeName = StrConfig['tips602'];
	elseif dropType == TargetConsts.DropType_MaxDamageOwn then
		dropTypeName = StrConfig['tips603'];
	elseif dropType == TargetConsts.DropType_FirstHitOwn then
		dropTypeName = StrConfig['tips604'];
	end
	return dropTypeName;
end
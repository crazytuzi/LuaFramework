--[[
buff工具类
郝户
2014年10月30日15:52:31
]]
_G.classlist['BuffUtils'] = 'BuffUtils'
_G.BuffUtils = {};
BuffUtils.objName = 'BuffUtils'
-- 检查列表中是否用相同配表id并且相同施法者的buff(用于效果叠加)
function BuffUtils:HasSameCasterBuffInList(list, buffTid, caster)
	for _, vo in pairs(list) do
		if vo.tid == buffTid and vo.caster == caster then
			return vo;
		end
	end
	return nil;
end

--从所有buff中区分获取用于显示的buff\debuff列表
function BuffUtils:DivideBuffList(allBuff)
	local buffList = {};
	local debuffList = {};
	for _, buff in ipairs( allBuff ) do
		local buffCfg = t_buff[ buff.tid ];
		if buffCfg then
			if buffCfg.buff_type == BuffConsts.Type_buff then
				table.insert( buffList, buff );
			elseif buffCfg.buff_type == BuffConsts.Type_debuff then
				table.insert( debuffList, buff );
			end
		end
	end
	--多删少补到6个(最多显示六个)
	while #buffList > 0 and #buffList < 6 do table.insert( buffList, {} ); end
	while #buffList > 6 do table.remove( buffList ); end
	while #debuffList > 0 and #debuffList < 6 do table.insert( debuffList, {} ); end
	while #debuffList > 6 do table.remove( debuffList ); end
	return buffList, debuffList;
end
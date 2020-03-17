--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/11/13
    Time: 3:32
   ]]

_G.ZiZhiUtil = {}

function ZiZhiUtil:GetOpenLvByCFG(cfg)
	for k, v in pairs(cfg) do
		if v.zizhi_dan > 0 then
			return k
		end
	end
	return 0;
end


--得到资质丹数量 1、保甲 2 命玉 3神兵 4 法宝  5境界 6坐骑
function ZiZhiUtil:GetZZItemNum(type)
	local itemid = 0;
	if type == 1 then --宝甲
	itemid = t_consts[336].val1
	elseif type == 2 then --命玉
	itemid = t_consts[337].val1
	elseif type == 3 then --神兵
	itemid = t_consts[338].val1
	elseif type == 4 then --法宝
	itemid = t_consts[339].val1
	elseif type == 5 then --境界
	itemid = t_consts[340].val1
	elseif type == 6 then --坐骑
	itemid = t_consts[335].val1
	end
	if itemid == nil then
		return
	end

	local intemNum = BagModel:GetItemNumInBag(itemid)
	return intemNum
end

--得到资质丹总加成百分比 1、保甲 2 命玉 3神兵 4 法宝  5境界 6坐骑
function ZiZhiUtil:GetZZTotalAddPercent(type)
	local p = 0;
	if type == 1 then --宝甲
	p = t_consts[336].val2
	elseif type == 2 then --命玉
	p = t_consts[337].val2
	elseif type == 3 then --神兵
	p = t_consts[338].val2
	elseif type == 4 then --法宝
	p = t_consts[339].val2
	elseif type == 5 then --境界
	p = t_consts[340].val2
	elseif type == 6 then --坐骑
	p = t_consts[335].val2
	end

	return p * ZiZhiModel:GetZZNum(type) / 100;
end
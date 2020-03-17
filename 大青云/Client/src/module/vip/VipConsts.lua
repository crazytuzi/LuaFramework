--[[
VIP Constants
2015-7-23 14:20:42
2015年7月23日14:20:46
]]
--------------------------------------------------------

_G.VipConsts = {}

---------------VIP类型-------------------------
VipConsts.TYPE_SUPREME = 1 -- 白银VIP
VipConsts.TYPE_GOLD    = 2 -- 黄金VIP
VipConsts.TYPE_DIAMOND = 3 -- 钻石VIP
VipConsts.TYPE_NAME = {StrConfig['vip110'],StrConfig['vip111'],StrConfig['vip112']}
---------------VIP等级上限--------------------
local maxVipLevel
function VipConsts:GetMaxVipLevel()
	if not maxVipLevel then
		maxVipLevel = 0
		for vipLevel, _ in pairs(t_vip) do
			maxVipLevel = math.max( maxVipLevel, vipLevel )
		end
	end
	return maxVipLevel
end

---------------VIP返还类型-------------------------
--1返还坐骑升阶消耗的灵力2返还灵兽进阶的道具3装备强化灵力返还
VipConsts.TYPE_MOUNT  = 1 -- 
VipConsts.TYPE_LINGSHOU = 2 -- 
VipConsts.TYPE_QIANGHUA = 3 -- 
VipConsts.TYPE_REALM = 4 --

function VipConsts:GetVipTypeName(vipType)
	return VipConsts.TYPE_NAME[vipType] or ""
end

VipConsts.BackLingShou = 101010 --
VipConsts.BackMount = 9 --
VipConsts.LingLiPrice = 0.00075 --
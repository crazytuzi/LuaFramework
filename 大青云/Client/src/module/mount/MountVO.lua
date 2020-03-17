--[[
坐骑VO
zhangshuhui
2014年11月05日17:20:20
]]

_G.MountVO = {}

function MountVO:new()
	local obj = {};
	obj.ridedId = 0;--当前骑乘id
	obj.mountId = 0;--坐骑id
	obj.mountState = 0;--状态
	obj.mountLevel = 0;--坐骑阶位
	obj.mountStar = 0;--坐骑星级
	obj.starProgress = 0;--星级进度
	obj.nextId = 0;--下一阶坐骑
	obj.nameIcon = ''--名称图标
	obj.shuzi_nameIcon = ''--竖名称图标
	obj.pillNum = 0;--属性丹数量
	obj.zizhiNum=0;--资质丹数量
	obj.time = 0;--特色坐骑时限 -1永久  0错误不让骑  >0 剩余时间
	return obj
end
--RideConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  RideConstant.lua
 --* Author:  seezon
 --* Modified: 2014年6月9日
 --* Purpose: 坐骑常量定义
 -------------------------------------------------------------------*/

RIDE_PROMOTE_MATERIAL_ID = 1101 --坐骑进阶材料ID

ZHAN_FIRST_RIDE_ID = 3001	--战士初始坐骑ID
FA_FIRST_RIDE_ID = 3002		--法师初始坐骑ID
DAO_FIRST_RIDE_ID = 3003	--道士初始坐骑ID


--坐骑存数据库的对应字段ID
RIDEOPTYPE = {
	onRide			= 1,	--上坐骑
	offRide			= 0,	--下坐骑
}

--定义坐骑相关提示
RIDE_ERR_CFG_ERR = -1	    --配置错误，不可购买
RIDE_ERR_NOT_ENOUGH_LEVEL = -2          --等级不足，不可购买
RIDE_ERR_NOT_ALLOW_RIDE = -3         --该地图不允许骑乘坐骑
RIDE_ERR_HAS_SAME = -4		--已经拥有此坐骑
RIDE_ERR_PK_NOT_ALLOW_RIDE = -5 --PK状态不能骑马
RIDE_ERR_CHANGE_NOT_ALLOW_RIDE = -6 --变身状态不能骑马
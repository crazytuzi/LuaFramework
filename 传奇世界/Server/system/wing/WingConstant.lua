--WingConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  WingConstant.lua
 --* Author:  seezon
 --* Modified: 2014年6月9日
 --* Purpose: 光翼常量定义
 -------------------------------------------------------------------*/

WING_PROMOTE_MATERIAL_ID = 1100 --光翼进阶材料ID
WING_PROMOTE_MATERIAL_PRICE = 40 --光翼进阶材料价格
WING_SKILL_MAX_NUM = 4 --光翼技能空最大个数
ZHAN_FIRST_WING_ID = 4011	--战士初始光翼ID
FA_FIRST_WING_ID = 5011		--法师初始光翼ID
DAO_FIRST_WING_ID = 6011	--道士初始光翼ID


--穿戴和取下光翼
WINGOPTYPE = {
	onWing			= 1,	--穿上光翼
	offWing			= 0,	--取下光翼
}

--定义光翼相关提示
WING_ERR_NOT_ENOUGH_MATERIAL = -1	    --材料不足，不可进阶
WING_ERR_NOT_ENOUGH_MONEY = -2  	    --金钱不足，不可进阶
WING_ERR_NOT_ENOUGH_YUANBAO = -3	    --元宝不足，无法购买进阶材料，不可进阶
WING_ERR_MAX_LEVEL = -4                 --已经是最高阶了，不能进阶
WING_ERR_NOT_ENOUGH_LEVEL = -5          --等级不足，不可进阶
WING_ERR_PROMOTE_FAIL = -6          --进阶失败，获得祝福值【XX】
WING_ERR_NO_WING = -7          --没有光翼，不能使用技能书
WING_ERR_NO_WING_SKILL = -8          --没有技能孔，不能使用技能书
WING_ERR_NO_SKILL_BOOK = -9          --技能书不足，无法操作
WING_ERR_MAX_SKILL = -10	          --该技能已经是最高等级，无法操作
WING_ERR_UP_SUC = -11	          --升级成功，XX提升为X级

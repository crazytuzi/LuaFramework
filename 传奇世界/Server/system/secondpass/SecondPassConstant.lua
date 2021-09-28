--SecondPassConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  SecondPassConstant.lua
 --* Author:  zhaofengguo
 --* Modified: 2016年5月21日 
 --* Purpose: Implementation of the class SecondPassConstant
 -------------------------------------------------------------------*/


SECOND_PASS_ERR_PASSFORMAT		    = -1 	--密码格式错误
SECOND_PASS_ERR_REPEATREST      	= -2 	--已经重置过密码
SECOND_PASS_ERR_PASS_ERR			= -3 	--二次密码验证错误
SECOND_PASS_ERR_HAS_NOT_SET_PASS	= -4 	--还没有设置二级密码
SECOND_PASS_ERR_TIME_LIMIT	        = -5 	--时间未到不能设置密码
SECOND_PASS_ERR_OLDPASS_ERR	        = -6 	--旧密码错误
SECOND_PASS_ERR_INVALID_OP	        = -7 	--非法操作时未验证二次密码
SECOND_PASS_ERR_SET_REPEAT	        = -8 	--二次密码重复设置
SECOND_PASS_ERR_TIME_INVALID	    = -9 	--二次密码已过期


--[[
buff相关常量
郝户
2014年10月20日13:57:09
]]
_G.classlist['BuffConsts'] = 'BuffConsts'
_G.BuffConsts = {};
BuffConsts.objName = 'BuffConsts'
-----buff类型--------------
--增益buff
BuffConsts.Type_buff = 1; 
--减益buff
BuffConsts.Type_debuff = 2;

-- adder:houxudong date:2016/11/18 10:09:26
-- 经验丹Buff
BuffConsts.Type_Exp_One   = 1012001
BuffConsts.Type_Exp_Two   = 1012002
BuffConsts.Type_Exp_Three = 1012003
BuffConsts.Type_Exp_Four  = 1012004
BuffConsts.Type_Exp_Five  = 1012005

-- 经验丹id
BuffConsts.Type_Exp_One_Id = 160000006

_G.ExpBuffList = {BuffConsts.Type_Exp_One,BuffConsts.Type_Exp_Two,BuffConsts.Type_Exp_Three,BuffConsts.Type_Exp_Four,BuffConsts.Type_Exp_Five}

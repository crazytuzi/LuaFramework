local notice={
[1]={1,1,1,'内测公告','[b]亲爱的奥飞er：[/b]\n      感谢参加本次《魔天记3D》的公司内测！\n      在这里，有瑰丽奇幻的修仙世界，有多职业多天赋自由组合的爽快战斗，役鬼通灵，御剑飞行，逆天改命……轻点指尖，即刻开启！\n温馨提示：\n1、 本次测试时间为[b]12月27日10:00~12月30日23:59[-]，测试重点在于数值成长、核心玩法、游戏画面的体验和反馈[/b]，测试期间每天[b]11:00[/b]点全服发放[b]15000仙玉[/b]用于体验，[b]欢迎大家踊跃提出意见和建议, 珍藏版四驱车、400元现金等你来拿！（内测QQ群：　222647417）[-][/b]\n2、 本次测试为开发中游戏版本，不代表游戏最终品质，体验过程中可能出现服务器关闭、登录失败、程序Bug等异常情况，欢迎各位小伙伴积极反馈，捉虫也能拿现金！\n3、 活动及奖励详情请查看邮件。                                                          \n                                        [b]《魔天记3Ｄ》产品组 [/b]','2016-12-22 09:00:00','2017-09-21 09:00:00'}
}
local ks={id=1,type=2,order=3,label=4,desc=5,begin_time=6,end_time=7}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(notice)do setmetatable(v,base)end base.__metatable=false
return notice

--[[
帮派:常量
liyuan
2014年11月13日12:24:23
]]
_G.UnionConsts = {};
UnionConsts.UnionMaxLevel = 15--帮派最高等级
---------------------------------------------
--			帮派面板标签页名称
---------------------------------------------
--帮派信息
UnionConsts.TabUnionInfo = "TabUnionInfo";
--帮派成员
UnionConsts.TabUnionMember = "TabUnionMember";
--帮派技能
UnionConsts.TabUnionSkill = "TabUnionSkill";
--帮派活动
UnionConsts.TabUnionActive = "TabUnionActive";
--帮派列表
UnionConsts.TabUnionList = "TabUnionList";
--帮派创建列表
UnionConsts.TabUnionCreateList = "TabUnionCreateList";
--帮派外交
UnionConsts.TabUnionDip = "TabUnionDip";
--帮派属性
UnionConsts.TabUnionAid = "TabUnionAid";
--帮派副本
UnionConsts.TabUnionDungeon = "TabUnionDungeon";
--帮派仓库
UnionConsts.TabUnionWarehouse = "TabUnionWarehouse";

---------------------------------------------
--			帮派成员列表标签页名称
---------------------------------------------
--帮派成员列表
UnionConsts.TabUnionMemberList = "TabUnionMemberList";
--帮派事件
UnionConsts.TabUnionMemberEvent = "TabUnionMemberEvent";
--帮派申请列表
UnionConsts.TabUnionMemberApplyList = "TabUnionMemberApplyList";
UnionConsts.TabUnionMemberActivityList = "TabUnionMemberActivityList";

---------------------------------------------
--			已加入 未加入帮派
---------------------------------------------
UnionConsts.UINoUnion = "UINoUnion"
UnionConsts.UIHasUnion = "UIHasUnion"

---------------------------------------------
--			帮派搜索类型
---------------------------------------------
UnionConsts.SearchTypeUnionName = {['searchType'] = 1, ['searchName'] = StrConfig['unionDiGong024']}
UnionConsts.SearchTypeMasterName = {['searchType'] = 2, ['searchName'] = StrConfig['unionDiGong025']}

---------------------------------------------
--			帮派捐献下拉框 自动同意等级下拉框
---------------------------------------------

UnionConsts.ContrbutionList = nil
UnionConsts.AutoAgreeList = nil

---------------------------------------------
--			帮派祈福列表
---------------------------------------------

UnionConsts.PrayListCount = 5 --祈福列表最多显示5条

---------------------------------------------
--			职位
---------------------------------------------
UnionConsts.DutyLeader 				= 5	--帮主
UnionConsts.DutySubLeader 			= 4	--副帮主
UnionConsts.DutyElder 				= 3	--长老
UnionConsts.DutyElite 				= 2	--精英
UnionConsts.DutyCommon 				= 1	--帮众

---------------------------------------------
--			菜单操作
---------------------------------------------
UnionConsts.Oper_View 				= 1;--查看资料
UnionConsts.Oper_Talk 				= 2;--私聊窗口
UnionConsts.Oper_AddFriend 			= 3;--添加好友
UnionConsts.Oper_ChangeLeader 		= 4;--转让帮主
UnionConsts.Oper_AppointSubLeader 	= 5;--任副帮主
UnionConsts.Oper_AppointElder 		= 6;--任命长老
UnionConsts.Oper_AppointElite 		= 7;--任命精英
UnionConsts.Oper_AppointCommon 		= 8;--任命帮众
UnionConsts.Oper_KickOut 			= 9;--踢出帮派

				--不同职位的操作

-- 帮主的操作
UnionConsts.LeaderOperList = {UnionConsts.Oper_View,
							UnionConsts.Oper_Talk,
							UnionConsts.Oper_AddFriend,
							UnionConsts.Oper_ChangeLeader}
							--踢出帮派根据不同的职位来添加
							
-- 副帮主的操作
UnionConsts.SubLeaderOperList = {UnionConsts.Oper_View,
							UnionConsts.Oper_Talk,
							UnionConsts.Oper_AddFriend}
							--踢出帮派根据不同的职位来添加
							
-- 长老的操作
UnionConsts.ElderOperList = {UnionConsts.Oper_View,
							UnionConsts.Oper_Talk,
							UnionConsts.Oper_AddFriend}
							--踢出帮派根据不同的职位来添加

-- 精英的操作
UnionConsts.EliteOperList = {UnionConsts.Oper_View,
							UnionConsts.Oper_Talk,
							UnionConsts.Oper_AddFriend}
							
-- 帮众的操作
UnionConsts.CommonOperList = {UnionConsts.Oper_View,
							UnionConsts.Oper_Talk,
							UnionConsts.Oper_AddFriend}
-- 资源id
UnionConsts.QingtongTokenId = nil				
UnionConsts.BaiyingTokenId = nil
UnionConsts.HuangjinTokenId = nil
UnionConsts.MoneyId = nil
UnionConsts.QingtongTokenContribution = nil			
UnionConsts.BaiyingTokenContribution = nil
UnionConsts.HuangjinTokenContribution = nil
-- 银两
UnionConsts.MoneyNeed = nil
UnionConsts.MoneyContribution = nil
UnionConsts.MoneyUnionMoney = nil
UnionConsts.MoneyList = nil

---------------------------------------------
--			权限配表中对应的字段名
---------------------------------------------							
UnionConsts.appointment = 'appointment'--职务任免							
UnionConsts.invitation = 'invitation'--帮派邀请
UnionConsts.invitation_verify = 'invitation_verify'--申请审核
UnionConsts.expel = 'expel'--踢人
UnionConsts.mod_notice = 'mod_notice'--修改公告
UnionConsts.war = 'war'--帮战报名
UnionConsts.reward = 'reward'--奖励发放
UnionConsts.skill_lv = 'skill_lv'--帮派技能升级
UnionConsts.dismiss = 'dismiss'--解散帮派
UnionConsts.activity = 'activity'--开启军团活动
UnionConsts.auto_verify = 'auto_verify'--自动同意申请
UnionConsts.levelup = 'levelup'--帮派升级
UnionConsts.impeachment = 'impeachment'--弹劾权限
UnionConsts.bankApprove = 'bankApprove'--帮派仓库审批
							
---------------------------------------------
--			事件id
---------------------------------------------	
UnionConsts.EventAll = {1,2,3,4,5,6}
UnionConsts.EventMemChanged = {1,2,3}						
UnionConsts.EventLevelUp = {4,5}
UnionConsts.EventContribution = {6}

UnionConsts.AgreeJoinGuild = 0
UnionConsts.RejectJoinGuild = 1
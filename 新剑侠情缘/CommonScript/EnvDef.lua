Env.GAME_FPS = 15;
Env.LOGIC_MAX_DIR = 64;
Env.INT_MAX = 2147483647;

Env.Cross_Activity_Open = true;

if version_vn then
	Env.Cross_Activity_Open = false;
end

Env.LogRound_FAIL 	 = 0  -- 失败
Env.LogRound_SUCCESS = 1  -- 成功
Env.LogRound_DRAW   =  2

local tbLogWayDesc = {}

local tbLogWaySet = LoadTabFile("Setting/LogWay.tab", "sds", nil, {"WayName", "Value", "Desc"  });
for i,v in ipairs(tbLogWaySet) do
	Env[v.WayName] = v.Value
	tbLogWayDesc[v.Value] = v.Desc
end

Env.tbLogWayDesc = tbLogWayDesc

Env.emHANDSHAKE_SUCCESS = 0;					--// 握手成功
Env.emHANDSHAKE_UNKNOW_ERROR = 1;				--// 未知错误
Env.emHANDSHAKE_KEY_ERROR = 2;				--// 登录验证码不正确
Env.emHANDSHAKE_ACC_ROLE_ERROR = 3;			--// 角色与账号不匹配
Env.emHANDSHAKE_ACC_REPLACE = 4;				--// 被顶号
Env.emHANDSHAKE_VERSION_ERROR = 5;			--// 版本号
Env.emHANDSHAKE_ONCEGAME_FORCE_LOGOUT = 6;	--// 防沉迷，连续游戏强制休息
Env.emHANDSHAKE_ACCUMU_FORCE_LOGOUT = 7;		--// 防沉迷，每日累计时长强制休息
Env.emHANDSHAKE_ADDICTION_CURFEW = 8;			--// 防沉迷，宵禁
Env.emHANDSHAKE_ADDICTION_BAN = 9;			--// 防沉迷，禁玩

Env.QQTLog_Page_Kin        = 1002; -- 家族
Env.QQTLog_Page_Game       = 1001; -- 游戏
Env.QQTLog_Page_NoneKin    = 1003; -- 非家族
Env.QQTLog_Page_Friend     = 1004; -- 好友
Env.QQTLog_Page_Accounting = 1005; -- 结算
Env.QQTLog_Page_Promote    = 1006; -- 推广
Env.QQTLog_Page_FriendPage = 1008; -- 推广

Env.QQTLog_Obj_GroupBind   = 10001; -- 绑群
Env.QQTLog_Obj_GroupUnBind = 10002; -- 解绑
Env.QQTLog_Obj_GroupList   = 10003; -- 群列表
Env.QQTLog_Obj_NotifyBind  = 10004; -- 提醒族长绑群
Env.QQTLog_Obj_JoinGroup   = 10005; -- 加入群
Env.QQTLog_Obj_CreateKin   = 10006; -- 创建家族
Env.QQTLog_Obj_DestroyKin  = 10007; -- 解散家族
Env.QQTLog_Obj_JoinKin     = 10008; -- 加入家族
Env.QQTLog_Obj_QuitKin     = 10009; -- 退出家族
Env.QQTLog_Obj_Login       = 10010; -- 登入游戏
Env.QQTLog_Obj_Share       = 10014; -- 分享
Env.QQTLog_Obj_FriendApply = 10016; -- 申请好友

Env.QQTLog_Operat_BindGroup       = 100001; -- 绑群
Env.QQTLog_Operat_UnBindGroup     = 100002; -- 解绑
Env.QQTLog_Operat_BindExistGroup  = 100003; -- 选择已有群绑定
Env.QQTLog_Operat_BindNewGroup    = 100004; -- 新建群绑定
Env.QQTLog_Operat_NotifyBind      = 100005; -- 提醒会长绑群
Env.QQTLog_Operat_JoinGoup        = 100006; -- 加群
Env.QQTLog_Operat_CreateKin       = 100007; -- 成功创建公会
Env.QQTLog_Operat_DestroyKin      = 100008; -- 成功解散公会
Env.QQTLog_Operat_JoinKin         = 100009; -- 成功加入公会
Env.QQTLog_Operat_QuitKin         = 100010; -- 成功退出公会
Env.QQTLog_Operat_Login           = 100011; -- 登陆
Env.QQTLog_Operat_Recall          = 100015; -- 召回
Env.QQTLog_Operat_SendGold        = 100016; -- 送金币
Env.QQTLog_Operat_SendGift        = 100017; -- 送礼物
Env.QQTLog_Operat_FriendShare     = 100018; -- 好友分享
Env.QQTLog_Operat_QZoneShare      = 100019; -- 空间分享
Env.QQTLog_Operat_SavePhoto       = 100020; -- 保存相册
Env.QQTLog_Operat_Share           = 100021; -- 分享
Env.QQTLog_Operat_SendInvite      = 100022; -- 发送邀请
Env.QQTLog_Operat_SendFriendApply = 100023; -- 发送验证
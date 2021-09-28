-- 登录模块的一些常量
LoginConst = LoginConst or {}
LoginConst.ROLE_SELECT_MAX_CNT = 3 --当前拥有最多角色
LoginConst.ROLE_CREATE_MAX_CNT = 4 
LoginConst.ROLE_MODEL_RES = {
	[1] = "1001",
	[2] = "1002",
	[3] = "1003",
	[4] = "1004",
	[5] = "1005",
	[6] = "1006",
	[7] = "1007",
	[8] = "1008"
}
LoginConst.ROLE_PROFESSION_NOT_SELECTED_URL = 
{
	[1] = UIPackage.GetItemURL("RoleCreateSelect" , "cl10"), --zs
	[2] = UIPackage.GetItemURL("RoleCreateSelect" , "cl20"), --fs
	[3] = UIPackage.GetItemURL("RoleCreateSelect" , "cl30") --aw
}

LoginConst.ROLE_PANEL_TYPE = 
{
	NONE = 0,
	CREATE_ROLE = 1,
	SELECT_ROLE = 2
}
LoginConst.ROLE_ATTR_DESC =
{
	[1] = "战士·肉盾",
	[2] = "法术·控制",
	[3] = "暗巫·辅助"
}
LoginConst.PANEL_OPEN_SOURCE = 
{
	NONE = 0,
	LOGIN_PANEL = 1,
	SELECT_PANEL = 2,
	CREATE_PANEL = 3
}
LoginConst.Effect = {
	["1001"] = {appear = "11001",showidle = "11002"},
	["1002"] = {appear = "12001",showidle = "12002"},
	["1003"] = {appear = "13001",showidle = "13002"},
}
LoginConst.DefaultWeapon = {
	[1] = 1110500,
	[2] = 1210500,
	[3] = 1310500
}

LoginConst.ShowWeapon = { --创角界面展示武器外形
	[1] = 1151009,
	[2] = 1251009,
	[3] = 1300200
}

LoginConst.ShowWing = { --创角界面展示翅膀外形
	[1] = 61203,
	[2] = 61501,
	[3] = 61302
}

LoginConst.ShowFashion = { --创角界面展示时装外形
	[1] = 1014,
	[2] = 1012,
	[3] = 1003
}



LoginConst.LOGIN_STATE_CHANGE = "0" -- 登录状态改变
LoginConst.LOGIN_KICK_CHANGE = "1" -- 踢下线状态改变

LoginConst.SelectAccountItem = "LoginConst.SelectAccountItem" --选中某个账号Item

LoginConst.LoginKey = "QYQDGAMEDshEFWOKE7Y6GAEDE-WAN-0668-2625-7DGAMESZEFovDDe777"

LoginConst.AccountListKey = "LoginConst.AccountListKey"
LoginConst.AccountKey = "LoginConst.AccountKey"
LoginConst.AccountCntKey = "LoginConst.AccountCntKey"

LoginConst.RegistServerTips = {
	["0"] = "注册成功",
	["1"] = "账号为空",
	["2"] = "密码为空",
	["3"] = "密码长度有误",
	["4"] = "账号已被注册",
	["5"] = "注册失败"
}

LoginConst.LoginServerTips = {
	["0"] = "登录成功",
	["1"] = "账号为空",
	["2"] = "密码为空",
	["3"] = "密码长度有误",
	["4"] = "账号未注册",
	["5"] = "密码错误",
	["6"] = "登录失败"
}

LoginConst.VisitorBindTips = {
	["0"] = "绑定成功" ,
	["1"] = "参数有误" ,
	["2"] = "密码长度有误" ,
	["3"] = "账号有误",
	["4"] = "该手机号已绑定过"
}

LoginConst.GetbackPasswordTips = {
	["0"] = "发送成功",
	["1"] = "参数有误",
	["2"] = "电话号码有误",
	["3"] = "账号有误",
	["4"] = "找回密码短信发送有误",
	["5"] = "账号尚未绑定手机号"
}

--返回json：result 0：成功  1: 参数有误 2：账号有误  3：旧密码有误 4：新密码不合法
LoginConst.ResetPasswordTips = {
	["0"] = "成功",
	["1"] = "参数有误",
	["2"] = "账号有误",
	["3"] = "旧密码有误",
	["4"] = "新密码不合法"
}

--severType：服务器类型(0.普通 1.新服 2.推荐)
LoginConst.ServerType = {
	General = 0 ,
	New = 1,
	Recommend = 2
}

--severState：服务器状态 (0.测试 1.流畅2：拥挤3.火爆  4.维护中 5.关闭)
LoginConst.ServerState = {
	Test = 0 ,
	Smooth = 1,
	Crowd = 2,
	Hot = 3,
	Maintenance = 4,
	Close = 5
}

--loginFlag：是否登录过  1：是  0：否
LoginConst.HasLogin = {
	Yes = 1,
	No = 0
}

--server tab type:选服界面的服务器类型
LoginConst.ServerTabType = {
	My = 0,
	Recommend = 1,
	Other = 2
}

--最近登录的服务器数据Key
LoginConst.LastServerKey = "LoginConst.LastServerKey"

--最近登录的账号数据Key
LoginConst.LastAccountDataKey = "LoginConst.LastAccountDataKey"

LoginConst.OnAccountItemDelect = "LoginConst.OnAccountItemDelect"

LoginConst.RoleDeleteLimitLev = 30

LoginConst.DefaultMainTainTimeContent = "1分钟"

--某个账号最近选择的的角色信息
LoginConst.LastSelectRoleKey = "LoginConst.LastSelectRoleKey"

LoginConst.RoleCreateShowSound = {
	[1] = "73021" ,
	[2] = "73022" ,
	[3] = "73023"
}
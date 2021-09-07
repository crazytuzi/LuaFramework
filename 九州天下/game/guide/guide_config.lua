------------------------------------------------------
--引导

--剧情说明：
--1.用||号代表多个演员和对应的动作，用#代表多个参数 用&&代表1个演员具有n个动作
--如actor = "1#monster||2#monster"  action = "born#44#212#1#100||born#33#212#1#100"
--代表分别在指定位置生成id为1和2的怪物类型演员
--actor = "1#monster||2#monster",  action = "move#30#228#200||move#32#228#200",
--代表id为1，2的怪物分别移动到指定位置
--actor = "0#combat", action = "change_blood#999#1#154#1#-200&&change_blood#999#2#154#1#-200",
--2个战斗包。
--动作参数参照动作表
------------------------------------------------------
GuideTriggerType = {
	AcceptTask = 1,									--接受任务后
	CommitTask = 2,									--提交任务后
	LevelUp = 3,									--升级后
	OutFb = 4,										--退出副本后
	Born = 5,										--主角出生时
	Opening = 6,									--开场动画
	ClickUi = 7,							 		--点击Ui触发
	CanCommintTask = 8,								--达到可提交任务时
	FirstEnterFb = 9,								--第一次进入副本
}

GuideStepType = {
	Arrow = 1,										--箭头指引
	AutoOpenView = 2,								--自动打开面板	参数 面板名字（参考GuideModuleName）
	AutoCloseView = 3,								--自动关闭面板  参数 面板名字（参考GuideModuleName）
	Gesture = 4,									--手势指引 		参数 (方向 0123==上右下左)
	DragUi = 5,										--拖动ui 		参数 (从uiname1拖到uiname2)
	Introduce = 6,									--美女介绍      参数 无（注：介绍内容放在arrowtip字段,应策划要求）
	GirlGuide = 7,									--美女指引
	FindUi = 8,										--查找ui
}

FunOpenType = {
	Visible = 1,									--直接可视
	Fly = 2,										--飞行出现
	TabOpen = 3,									--选项卡开启方式（即标签栏里开始某一项，后面的功能都得自适应）
	FlyTabOpen = 4,									--飞行出现 + 选项卡开启方式 open_param为：标签索引#所在模块#主属主功能
	OpenView = 5,									--弹出面板
	Born = 6,										--生长（如用于场景上对象的出现）
	FlyToUI = 7,									--飞行出现,指定目标ui
	OpenModel = 8,									--弹出模型
	OpenTipView = 9,								--弹出界面（但是不飞行）
}

--功能所在的位置 1:右上, 2:左下, 3:其他
FunWithType = {
	Up = 1,
	Down = 2,
	Other = 3,
}
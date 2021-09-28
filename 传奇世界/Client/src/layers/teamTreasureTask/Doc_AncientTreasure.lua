--Author:		bishaoqing
--DateTime:		2016-05-18 16:17:11
--Region:		帮助文档

--[[
	远古宝藏组队系统（AncientTreasureTeamXXX)组成：

	(队伍管理器)
	AncientTreasureTeamCtr:
		逻辑层。
		用来管理AncientTreasureTeam对象，例如存储team对象、删除team对象、
		对对象进行一系列服务器请求操作等

	(队伍对象)
	AncientTreasureTeam:
		逻辑层。
		用来存储单条藏宝队伍数据（单支队伍数据），负责管理数据，处理数据，例如
		更新指定数据、对外提供数据获取接口

	(队伍界面)
	AncientTreasurePanel:
		显示层。
		通过ctr获取team对象，然后创建node组件展现在屏幕上，多用于展示信息，不应该处理逻辑操作
	
	(远古宝藏配置)
	AncientTreasureCfg:
		配置数据。

]]
--Author:		bishaoqing
--DateTime:		2016-05-18 16:27:45
--Region:		黑市文档

--[[
	黑市系统（BlackMarketXXX)组成：

	(黑市管理器)
	BlackMarketCtr:
		逻辑层。
		用来管理BlackMarketItem对象，例如存储item对象、删除item对象、
		对对象进行一系列服务器请求操作等

	(黑市商品对象)
	BlackMarketItem:
		逻辑层。
		用来存储单条黑市商品数据（单支队伍数据），负责管理数据，处理数据，例如
		更新指定数据、对外提供数据获取接口

	(黑市界面)
	BlackMarketPanel:
		显示层。
		通过ctr获取item对象，然后创建node组件展现在屏幕上，多用于展示信息，不应该处理逻辑操作

	(黑市配置)
	BlackMarketCfg:
		配置属性。
]]
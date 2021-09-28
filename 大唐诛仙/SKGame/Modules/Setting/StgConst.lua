-- 设置常量
StgConst = {}

-- 面板类型
StgConst.PANELTYPE = {
	setting = 0 -- 设置
}

StgConst.KeyType = {
	Music = 0, -- 设置音乐
	Effect = 1, -- 设置音效
	AcceptChat = 2, -- 设置陌生人消息
	AcceptApply = 3, -- 设置好友申请
	ShowBar = 4, -- 设置血条
	ShowName = 5, -- 设置名字
	MiniMap = 6, -- 设置小地图
	AutoHp = 7, -- 自动喝血
	AutoMp = 8, -- 自动喝魔
}

-- 设置变化
StgConst.DATA_CHANGED = "StgConst.DATA_CHANGED"
-- 设置初始化完成
StgConst.DATA_INITED = "StgConst.DATA_INITED"
-- 获取了社交设置
StgConst.DATA_CONTACT = "StgConst.DATA_CONTACT"
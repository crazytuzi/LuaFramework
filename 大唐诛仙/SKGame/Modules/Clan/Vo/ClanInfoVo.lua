-- 都护府信息
ClanInfoVo = BaseClass()
function ClanInfoVo:__init( data )
	self.guildId = 0 --都护府编号

	self.headerId = 0 --都护主玩家编号

	self.guildName = "" --都护府名称	
	self.headerName = "" --都护名称
	self.notice = "" --都护府公告
	self.level = 0 --都护府等级
	self.memberNum = 0 --成员人数
	self.battleValue = 0 --战斗力
	self.money = 0 --资金
	self.buildNum = 0 --建设度
	self.createTime = 0 --创建时间搓

	self.autoJoin = 0 --是否勾选自动加入 1：是
	self.autoMinLv = 0 --最小设定等级
	self.autoMaxLv = 0 --最大设定等级

	self.applyFlag = 0 --是否已申请  1：是

	self:Update(data)
end
function ClanInfoVo:Update( data )
	if not data then return end
	self.guildId = data.guildId or self.guildId or 0
	self.guildName = data.guildName or self.guildName or ""
	self.notice = data.notice or self.notice or ""
	self.level = data.level or self.level or 0
	self.memberNum = data.memberNum or self.memberNum or 0
	self.headerId = data.headerId or self.headerId or 0
	self.headerName = data.headerName or self.headerName or ""
	self.battleValue = data.battleValue or self.battleValue or 0
	self.autoJoin = data.autoJoin or self.autoJoin or 0
	self.autoMinLv = data.autoMinLv or self.autoMinLv or 0
	self.autoMaxLv = data.autoMaxLv or self.autoMaxLv or 0
	self.money = data.money or self.money or 0
	self.buildNum = data.buildNum or self.buildNum or 0
	self.createTime = data.createTime or self.createTime or 0
	self.applyFlag = data.applyFlag or self.applyFlag or 0
end
function ClanInfoVo:Clear()
	self.guildId = 0
	self.headerId = 0
	self.guildName = ""
	self.headerName = ""
	self.notice = ""
	self.level = 0
	self.memberNum = 0
	self.battleValue = 0
	self.money = 0
	self.buildNum = 0
	self.createTime = 0
	self.autoJoin = 0
	self.autoMinLv = 0
	self.autoMaxLv = 0
	self.applyFlag = 0
end

-- 联盟信息
UnionInfo = BaseClass()
function UnionInfo:__init( data )
	self:Update(data)
end
function UnionInfo:Update( data )
	if not data then
		self.myUnionId = 0
		self.unions = {}
		self.applys = {}
		return
	end
	self.myUnionId = data.myUnionId
	self.unions = CollectProtobufList( data.unions )
	self.applys = CollectProtobufList( data.applys )
end
function UnionInfo:Clear()
	self.myUnionId = 0
	self.unions = {}
	self.applys = {}
end
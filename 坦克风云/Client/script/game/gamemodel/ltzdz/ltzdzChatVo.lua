ltzdzChatVo={}
function ltzdzChatVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzChatVo:initWithData(data,height,width)
	self.cType=data[1] -- 类型1 世界  2：私聊
	self.senderId=data[2] -- 发送这uid
	self.receiverId=data[3] -- 接受玩家id(公共为0)
	self.msg=data[4] or "" -- 内容
	self.ts=data[5] -- 时间
	if data[6] then
		self.pic=data[6][1] or 1 -- 头像id
		if self.pic==0 then
			self.pic=1
		end
		self.nickname=data[6][2] -- 名字
		self.rpoint=data[6][3] -- 段位分
		self.record=data[6][4] or {} -- 战绩
		self.defeat=data[6][5] or 0 -- 击败势力
		self.most=data[6][6] or 0 -- 常用部队
		self.fc=data[6][7] or 0 -- 战斗力
		self.zid=data[6][8] or base.curZoneID
	end
	if data[7] then
		self.receiverName=data[7][1] or ""
	end

	self.height=height
	self.width=width
end
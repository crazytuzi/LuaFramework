
alienMinesEmailVo={}
function alienMinesEmailVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function alienMinesEmailVo:initWithData(eid,sender,from,to,title,content,time,isRead,reportType,attackData)
	self.eid=eid  		--消息ID
	self.sender=sender	--发件人ID
	self.from=from		--发件人名字
	self.to=to			--收件人名字
	self.title=title
	self.content=content
	self.time=time
	self.isRead=isRead
	self.reportType=reportType 	--战报的类型
	self.attackData=attackData
	-- self.gift=gift			--是否是奖励邮件，>=1是，0否，-1是军团邮件
	-- self.reward=reward		--奖励
	-- self.isReward=isReward	--是否领取过奖励，1是，0否
	-- self.flick=flick 		--是否闪光

	-- --是否是军团全体邮件，0：否，1：是
	-- if self.isAllianceEmail==nil then
	-- 	self.isAllianceEmail=0
	-- end
	-- if gift and gift==-1 then
	-- 	self.isAllianceEmail=1
	-- end
end
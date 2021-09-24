ltzdzVo={}
function ltzdzVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzVo:initWithData(param)
	if param.point then -- 总的功勋值(功勋值用于商店兑换)
		self.point=param.point
	end
	if param.cpoint then --已经消耗的功勋值
		self.cpoint=param.cpoint
	end
	if param.rpoint then -- 排名积分
		self.rpoint=param.rpoint
	end
	if param.record then  -- 战绩
		self.record=param.record
	end
	if param.defeat then -- 击败势力数量
		self.defeat=param.defeat
	end
	if param.most then -- 常用部队信息
		self.most=param.most
	end

	if param.praise then  -- 点赞数量
		self.praise=param.praise
	end
	if param.st then -- 本场战斗开始时间
		self.st=param.st
	end
	if param.et then -- 本场战斗结束时间
		self.et=param.et
	end
	if param.roomid then -- 房间号
		self.roomid=param.roomid
	end
	if param.host then -- 本场战斗连接host
		self.host=param.host
	end
	if param.port then -- 本场战斗连接port
		self.port=param.port
	end
	if param.troops then  -- 可以使用部队类型
		self.troops=param.troops
	end
	if param.ally then -- 盟友id
		self.ally=param.ally
	end
	if param.invite then -- 邀请uid
		self.invite=param.invite
	end
	if param.invitelist then -- 被邀请列表
		self.invitelist=param.invitelist
	end
	if param.tid then -- 验证需要用
		self.tid=param.tid
	end
	if param.buynum then --功勋商店购买数据
		self.buynum=param.buynum
	end
	if param.httphost then --请求战报的url地址
		self.httphost=param.httphost
	end
	if param.bnum then -- 定级赛判断 bnum<2
		self.bnum=param.bnum
	end
	if param.season then -- 赛季
		self.season=param.season
	end
	if param.cwhost then -- 赛季
		self.cwhost=param.cwhost
	end
	if param.killnum then --击杀的部队数量
		self.killnum=param.killnum
	end
	if param.citynum then --占领的城市数量
		self.citynum=param.citynum
	end
	if param.sinfo then
		--sinfo.stask 赛季任务数据，sinfo.r 任务领取数据
		self.sinfo=param.sinfo
	end
	if param.state then -- 是否延时结算
		self.state=param.state
	end
	if param.info and param.info.n then --已使用的组队次数
		self.useTeamNum=param.info.n
	end
	
end
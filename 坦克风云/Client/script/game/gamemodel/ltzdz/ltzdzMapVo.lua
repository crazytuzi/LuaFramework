ltzdzMapVo={}
function ltzdzMapVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzMapVo:initWithData(param)
	if param.st then -- 本场开始时间
		self.st=param.st
	end
	if param.et then -- 本场结束时间
		self.et=param.et
	end
	if param.type then -- 暂无用
		self.type=param.type
	end
	if param.city then  -- 城市信息（可能需要单个更新某个城市的信息，效率高）{a1={n=100,b={},oid=}} oid可能为nil
		-- a1={b={1,1,1380000000,{b1={3,1}},{{btype,et,bid,}}},n=5000,oid="3000401",d={{{"a10001",100},{},},{"h1","h2",},"e1",1},}
		-- b：建筑{主基地类型,主基地等级,主基地升级结束时间,地块建筑 bid={类型,等级,升级或建造结束时间},n：预备役，oid：占领玩家，d：防守部队
		self.city=param.city
	end
	if param.battle_at then -- 实际结束时间
		self.battle_at=param.battle_at
	end
	if param.roomid then -- 房间号
		self.roomid=param.roomid
	end
	if param.tqueue then -- 队列
		self.tqueue=param.tqueue
	end
	if param.chat then -- 队列
		self.chat=param.chat
	end
	if param.user then
		self.user=param.user
	end

end
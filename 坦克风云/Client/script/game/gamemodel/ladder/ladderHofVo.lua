ladderHofVo={}
function ladderHofVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.season=1--第几赛季
    nc.t=0--赛季结算时间
    nc.ranklist={}--排名数据
    return nc
end

--season：第几赛季，rank：排名，pic:玩家头像，name:玩家名称，sid:服务器id,et:赛季结束时间，fight:战斗力
function ladderHofVo:initWithData(data)
	if data and data.bid then
		self.season=data.bid
	end
	if data and data.t then
		self.t=data.t
	end
	-- id,得分，名称，战力，区服，头像(军团名人堂没有头像)
	if data and data.info then
		for i=1,3 do
			if data.info[i] then
				local itemvo = {}
				itemvo.rank=i
				itemvo.id=data.info[i][1]
				itemvo.score=data.info[i][2]
				itemvo.name=data.info[i][3]
				itemvo.fight=data.info[i][4]
				itemvo.sid=data.info[i][5]
				if data.info[i][6] then
					itemvo.pic=data.info[i][6]
				end
				table.insert(self.ranklist,itemvo)
			end
		end
		-- local function sortA(a,b)
		-- 	if a and b and a.rank and b.rank then
		-- 		return a.rank<b.rank
		-- 	end
		-- end
	end
end

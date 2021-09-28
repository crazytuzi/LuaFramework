TiantiVo = BaseClass()

function TiantiVo:__init( data )
	self.rank = 0 -- 排名
	self.playerId = 0 -- 玩家编号
	self.playerName = 0 -- 玩家名称
	self.career = 0 -- 玩家职业
	self.level = 0 -- 玩家等级
	self.stage = 0 -- 段位
	self.star = 0 -- 星级
	self:Update( data )
end
function TiantiVo:Update( data )
	if not data then return end
	for k,v in pairs(self) do
		if data[k] and self[k] ~= data[k] then
			self[k] = data[k]
			-- if self.callback then
			-- 	self.callback(self)
			-- end
		end
	end
end
-- function TiantiVo:SetChangeCallback( callback )
-- 	self.callback = callback
-- end
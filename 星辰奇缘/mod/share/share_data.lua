-- --------------------------
-- 分享数据结构
-- hosr
-- --------------------------
ShareData = ShareData or BaseClass()

function ShareData:__init()
	self.init = nil          --"是否初始化"}
	self.key = nil           --"当前使用key"}
	self.key_time = nil      --"当前key申请时间"}
	self.shipsTab = {}    --"邀请列表"
	self.rid = nil      --"邀请人id"}
	self.platform = nil --"邀请人平台"}
	self.zone_id = nil  --"邀请人区服"}
	self.apply_key = nil    --"邀请时使用key"}
	self.apply_name = nil -- 邀请人名称
	self.day_score = nil --每日星钻
end

function ShareData:SetData(data)
	self.init = data.init
	self.key = data.key
	self.key_time = data.key_time
	self.rid = data.rid
	self.platform = data.platform
	self.zone_id = data.zone_id
	self.apply_key = data.apply_key
	self.apply_name = data.apply_name
	self.day_score = data.day_score

	self:UpdateShips(data.ships)
end

function ShareData:UpdateShips(ships)
	for i,ship in ipairs(ships) do
		local id = string.format("%s_%s_%s", ship.rid_1, ship.platform_1, ship.zone_id_1)
		self.shipsTab[id] = ship
	end
end

function ShareData:ShipCount()
	local count = 0
	for k,v in pairs(self.shipsTab) do
		if v.key == self.key then
			count = count + 1
		end
	end
	return count
end
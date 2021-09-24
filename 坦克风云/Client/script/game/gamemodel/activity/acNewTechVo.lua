acNewTechVo=activityVo:new()

function acNewTechVo:updateSpecialData(data)
	if self.pool == nil then
		self.pool = {}
	end

	if data.pool ~= nil then
		self.pool = data.pool
	end

	if self.pa == nil then
		self.pa = {}
	end

	if data.pa ~= nil then
		self.pa = data.pa
	end

	if self.pb == nil then
		self.pb = {}
	end

	if data.pb ~= nil then
		self.pb = data.pb
	end
	
	-- -- 配置
	-- self.pool = {p68,p69,p70,p71} -- 后台使用的随机奖励池,超强道具

 --    -- {道具，道具需要的个数，得到道具}
	-- self.pa = {{"p11",5,"p21"},{"p12",5,"p22"},{"p13",5,"p23"},{"p14",5,"p24"},{"p15",5,"p25"},{"p16",5,"p26"}}
    
 --    -- {道具，道具需要的个数}得到奖励池pool1或pool2中得某种道具
	-- self.pb = {{"p11",3},{"p12",3},{"p13",6},{"p14",2},{"p15",2},{"p16",2},{"p17",4}}
end
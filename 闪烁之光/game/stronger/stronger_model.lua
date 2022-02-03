-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
StrongerModel = StrongerModel or BaseClass()

function StrongerModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function StrongerModel:config()
	self.scroe_list = {} -- 我的伙伴评分数据
    self.max_list = {}   -- 本服最强评分数据
end

--设置伙伴的评分数据
function StrongerModel:setDataByBid( data )
	if self.scroe_list[data.partner_bid] == nil then 
		self.scroe_list[data.partner_bid] = {}	
	end
	self.scroe_list[data.partner_bid] = data.partner_score --伙伴评分

	if self.max_list[data.partner_bid] == nil then 
		self.max_list[data.partner_bid] = {}	
	end
	self.max_list[data.partner_bid] = data.stronger_partner_score --最强伙伴评分
end

-- 根据英雄bid获取变强相关数据
function StrongerModel:getStrongerValByBid( bid, stronger_id )
	local scroe_data = self.scroe_list[bid] or {}
	local max_data = self.max_list[bid] or {}
	local scroe_val = 0
	local max_val = 0
	for k,v in pairs(scroe_data) do
		if v.id_2 == stronger_id then
			scroe_val = v.val
		end
	end
	for k,v in pairs(max_data) do
		if v.id_2 == stronger_id then
			max_val = v.val
		end
	end
	return scroe_val, max_val
end

--返回英雄的总评/本服最强
function StrongerModel:getTotalAndMaxValByBid( bid )
	local total = 0
	if self.scroe_list[bid] then 
		for k,v in pairs(self.scroe_list[bid]) do
			total = total + v.val
		end
	end

	local max = 0
	if self.max_list[bid] then 
		for k,v in pairs(self.max_list[bid]) do
			max = max + v.val
		end
	end

	return total,max
end

-- 判断变强item是否开启
function StrongerModel:checkStrongItemIsOpen( data )
	local is_open = false
	if data then
        if data[1] and data[1] == 'dugeon' then --关卡的
            local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
            if drama_data and data[2] then
                local dungeon_id = data[2]
                if drama_data.max_dun_id >= dungeon_id then
                    is_open = true
                end
            end
        elseif data[1] and data[1] == 'lev' then -- 等级的
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo and data[2] then
                local lev = data[2]
                if role_vo.lev >= lev then
                    is_open = true
                end
            end
        elseif data[1] and data[1] == 'guild' then --公会等级
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo and role_vo.gid ~= 0 and role_vo.gsrv_id ~= '' then --表示有公会
                local guild_info = GuildController:getInstance():getModel():getMyGuildInfo()
                if guild_info then
                    local lev = data[2]
                    if guild_info.lev >= lev then
                        is_open = true
                    end
                end
            end
        end
    end
    return is_open
end

function StrongerModel:__delete()
end
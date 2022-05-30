-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会远航订单服务器数据
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildvoyageOrderVo = GuildvoyageOrderVo or BaseClass(EventDispatcher) 

function GuildvoyageOrderVo:__init(order_bid)
    self.order_id = 0                   -- 订单唯一id
    self.order_bid = order_bid or 0     -- 订单基础id,配置表里面的id
    self.type = 0                       -- 订单类型 1：普通订单，2：付费订单
    self.status = 0                     -- 订单状态 1:待执行 2:正在执行 3:待领取 4:已领取
    self.loss_id = 0                    -- 消耗id,配置表消耗id
    self.end_time = 0                   -- 结束时间
    self.assign_ids = {}                -- 派遣宝可梦id的列表,   partner_id 
    self.cond_ids = {}                  -- 满足的条件ID列表, cond_id
    self.is_success = 0                 -- 是否是100%成功,是的话,就表示玩家勾选了花钻石
    self.is_double = 0                  -- 是否双倍奖励
    self.success_rate = 0               -- 最终成功率
    self.line_id = 0                    -- 线路id

    self.refresh_count = 0              -- 该订单已刷新次数
    self.is_gain = 0                    -- 能否领取概率奖励

    -- 配置表数据
    self.config = Config.GuildShippingData.data_order(self.order_bid)
    self.quality = self.config.quality or 0
end

function GuildvoyageOrderVo:updateData(data)
    for key, value in pairs(data) do
        if type(value) ~= "table" then
            self:setBaseData(key, value)
        else
            -- 满足条件的事件id直接按照key区储存.方便查找吧
            if key == "cond_ids" then
                for i, info in ipairs(value) do
                    self.cond_ids[info.cond_id] = true
                end
            else
                self[key] = value
            end
        end
    end
end

function GuildvoyageOrderVo:setBaseData(key, value)
	if self[key] ~= value then
		self[key] = value

        -- 如果是订单基础id变化了,那么就是被刷新了
        if key == "order_bid" then
            self.config = Config.GuildShippingData.data_order(value)
            if self.config == nil then
                print("远航订单有误,id为 ", value)
            else
                self.quality = self.config.quality or 0
            end
        end
	end
end 
-- 盗梦，抽奖(返回 36 2)
-- 36 2
CSXunbaoReq = CSXunbaoReq or BaseClass(BaseProtocolStruct)
function CSXunbaoReq:__init()
	self:InitMsgType(36, 2)
	self.type_index = 0  -- 寻宝类型索引, 1=1次, 2=10次 查看寻宝配置 Dmkj.lua
	self.is_replace = 0  			-- 是否钻石替代，1是，0不是
end

function CSXunbaoReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type_index)
	MsgAdapter.WriteUChar(self.is_replace)
end

-- 界面首页数据(返回 36 8)
-- 36 3
-- 空数据
CSFirstPageDataReq = CSFirstPageDataReq or BaseClass(BaseProtocolStruct)
function CSFirstPageDataReq:__init()
	self:InitMsgType(36, 3)
end

function CSFirstPageDataReq:Encode()
	self:WriteBegin()
end

-- 仓库数据(返回 36 4)
-- 36 4
-- 空数据
CSReturnWarehouseDataReq = CSReturnWarehouseDataReq or BaseClass(BaseProtocolStruct)
function CSReturnWarehouseDataReq:__init()
	self:InitMsgType(36, 4)
end

function CSReturnWarehouseDataReq:Encode()
	self:WriteBegin()
end

-- 积分兑换物品
CSExchangeItemReq = CSExchangeItemReq or BaseClass(BaseProtocolStruct)
function CSExchangeItemReq:__init()
	self:InitMsgType(36, 5)
	self.exc_type = 0 				-- uchar 兑换类型
	self.exc_index = 0 				-- ushort 
end

function CSExchangeItemReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.exc_type)
	MsgAdapter.WriteUShort(self.exc_index)
end

-- 移动到背包(返回 36 9)
-- 36 9
-- (long long)物品guid
CSMovetoBagReq = CSMovetoBagReq or BaseClass(BaseProtocolStruct)
function CSMovetoBagReq:__init()
	self:InitMsgType(36, 9)
	self.series = 0
end

function CSMovetoBagReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

-- 宝藏积分兑换物品 (返回 36 10)
-- 36 10
-- (uchar)类型索引, 对应该 TreasureIntegralCfg.lua -- type字段
-- (char)查看 TreasureIntegralCfg.lua -- ExChangeData表的id, 如果是月度活动id为负数
CSIntegralExchangeBagReq = CSIntegralExchangeBagReq or BaseClass(BaseProtocolStruct)
function CSIntegralExchangeBagReq:__init()
	self:InitMsgType(36, 10)
	self.type_index = 0 
	self.index_id = 0
end

function CSIntegralExchangeBagReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type_index)
	MsgAdapter.WriteChar(self.index_id)
end

-- 获取积分兑换的全服公告信息
-- 36 11
-- 空数据
CSGetFullScaleAnnouncementInfReq = CSGetFullScaleAnnouncementInfReq or BaseClass(BaseProtocolStruct)
function CSGetFullScaleAnnouncementInfReq:__init()
	self:InitMsgType(36, 11)
end

function CSGetFullScaleAnnouncementInfReq:Encode()
	self:WriteBegin()
end

-- 获取合区全服奖记录(返回 36 16)
-- 空数据
CSGetCombinedServDZPLogReq = CSGetCombinedServDZPLogReq or BaseClass(BaseProtocolStruct)
function CSGetCombinedServDZPLogReq:__init()
	self:InitMsgType(36, 12)
end

function CSGetCombinedServDZPLogReq:Encode()
	self:WriteBegin()
end

-- 请求全服奖励信息
CSWorldRewardInfoReq = CSWorldRewardInfoReq or BaseClass(BaseProtocolStruct)
function CSWorldRewardInfoReq:__init()
	self:InitMsgType(36, 13)
end

function CSWorldRewardInfoReq:Encode()
	self:WriteBegin()
end

-- 请求领取寻宝个人次数奖
CSRewardXunbaoOwnNumReq = CSRewardXunbaoOwnNumReq or BaseClass(BaseProtocolStruct)
function CSRewardXunbaoOwnNumReq:__init()
	self:InitMsgType(36, 14)
	self.rew_index = 0 				-- 奖励索引
end

function CSRewardXunbaoOwnNumReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.rew_index)
end

-- 请求龙皇宝藏寻宝
CSRareTreasureReq = CSRareTreasureReq or BaseClass(BaseProtocolStruct)
function CSRareTreasureReq:__init()
	self:InitMsgType(36, 15)
	self.rew_index = 0 				-- 奖励索引
end

function CSRareTreasureReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.rew_index)
end

-- 请求进入龙皇秘境
CSEnterRareplaceReq = CSEnterRareplaceReq or BaseClass(BaseProtocolStruct)
function CSEnterRareplaceReq:__init()
	self:InitMsgType(36, 16)
	self.index = 0 				-- 进入层数, 从1开始
end

function CSEnterRareplaceReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

-- 购买龙皇秘境次数
CSBuyRareplaceTimesReq = CSBuyRareplaceTimesReq or BaseClass(BaseProtocolStruct)
function CSBuyRareplaceTimesReq:__init()
	self:InitMsgType(36, 17)
end

function CSBuyRareplaceTimesReq:Encode()
	self:WriteBegin()
end


--========================================下发=============================
-- 寻宝祝福值
SCXunBaoBlessingInfo = SCXunBaoBlessingInfo or BaseClass(BaseProtocolStruct)
function SCXunBaoBlessingInfo:__init()
	self:InitMsgType(36, 1)
	self.blessing_value = 0 	--祝福值
	self.blessing_gear = 0 		--命中档位
	self.bz_score = 0 			-- 宝藏积分
	self.own_rew_num = 0 		-- 每天个人寻宝次数领取奖励标记，按位取，1已领取，0没领取
	self.own_xb_num = 0 		-- 每天个人寻宝次数
	self.own_all_num = 0 		-- 个人寻宝总次数（不会被重置）
	self.lhmb_enter_num = 0 	-- 每天龙皇秘宝已进入次数
	self.lhmb_buy_num = 0 		-- 每天龙皇秘宝购买次数
end

function SCXunBaoBlessingInfo:Decode()
	self.blessing_value = MsgAdapter.ReadInt()
	self.blessing_gear = MsgAdapter.ReadUChar()
	self.bz_score = MsgAdapter.ReadInt()
	self.own_rew_num = MsgAdapter.ReadUInt()
	self.own_xb_num = MsgAdapter.ReadUInt()
	self.own_all_num = MsgAdapter.ReadUInt()
	self.lhmb_enter_num = MsgAdapter.ReadUChar()
	self.lhmb_buy_num = MsgAdapter.ReadUChar()
end

-- 盗梦的结果
SCXunBaoResult = SCXunBaoResult or BaseClass(BaseProtocolStruct)
function SCXunBaoResult:__init()
	self:InitMsgType(36, 2)
	self.bz_score = 0 			-- 宝藏积分
	self.blessing_value = 0 	-- 祝福值
	self.blessing_gear = 0 		-- 命中的祝福档位
	self.own_all_num = 0 		-- 个人寻宝总次数（不会被重置）
	self.warehouse_spare = 0 	-- 仓库空余格子数量
	self.item_num = 0 			-- 物品数量
	self.xunbao_item_list = {}	-- 物品列表
end

function SCXunBaoResult:Decode()
	self.bz_score = MsgAdapter.ReadUInt()
	self.blessing_value = MsgAdapter.ReadUInt()
	self.blessing_gear = MsgAdapter.ReadUChar()
	self.own_all_num = MsgAdapter.ReadUInt()
	self.warehouse_spare = MsgAdapter.ReadUShort()
	self.item_num = MsgAdapter.ReadUShort()
	self.xunbao_item_list = {}
	for i = 1, self.item_num do
		self.xunbao_item_list[i] = {
			item_id = MsgAdapter.ReadUShort(),		--物品id
			item_num = MsgAdapter.ReadInt(),		--数量
			bind = MsgAdapter.ReadUChar(),			--绑定状态
			best_attr = MsgAdapter.ReadUShort(),	--极品属性
		}
	end
end

--仓库数据
SCWearHouseDataFrom = SCWearHouseDataFrom or BaseClass(BaseProtocolStruct)
function SCWearHouseDataFrom:__init()
	self:InitMsgType(36, 4)
	self.page_index = 0
	self.count = 0
	self.storage_list = {}
end

function SCWearHouseDataFrom:Decode()
	self.page_index = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadUShort()
	self.storage_list = {}
	for i = 1, self.count do
		self.storage_list[i] = CommonReader.ReadItemData()
	end
end

-- 积分兑换物品结果
SCExchangeResult = SCExchangeResult or BaseClass(BaseProtocolStruct)
function SCExchangeResult:__init()
	self:InitMsgType(36, 5)
	self.xb_score = 0 			-- uint寻宝积分
	self.dh_type = 0 			-- uchar兑换类型
	self.dh_index = 0 			-- ushort兑换索引
end

function SCExchangeResult:Decode()
	self.xb_score = MsgAdapter.ReadUInt()
	self.dh_type = MsgAdapter.ReadUChar()
	self.dh_index = MsgAdapter.ReadUShort()
end

--寻宝日志
SCXunBaoRecord = SCXunBaoRecord or BaseClass(BaseProtocolStruct)
function SCXunBaoRecord:__init()
	self:InitMsgType(36, 6)
	self.record = 0  -- 1本人 2全服
	self.bool_add = 0  --(uchar)1增加, 2,重置, 0删除, 如果是本人，只增加或删除本人的记录, 如果是全服就要加增到所有玩家,或删除所有玩家的记录
	self.record_list = {}
end

function SCXunBaoRecord:Decode()
	self.record = MsgAdapter.ReadUChar()
	self.bool_add = MsgAdapter.ReadUChar()
	local count = MsgAdapter.ReadUShort()
	self.record_list = {}
	for i = 1, count do
		local v = {}
		v.reward_type = MsgAdapter.ReadUChar()
		v.item_data = CommonStruct.ItemDataWrapper()
		v.item_data.item_id = MsgAdapter.ReadUShort()
		v.quality_grade = MsgAdapter.ReadUChar()
		v.shuxing = MsgAdapter.ReadInt()
		v.item_data.type = MsgAdapter.ReadUChar()
		for i = 1, 4 do
			MsgAdapter.ReadInt()
		end
		v.role_name = MsgAdapter.ReadStr()				--角色名称
		v.need_broadcast = MsgAdapter.ReadUShort()		--需要广播
		self.record_list[i] = v
	end
end

-- 宝藏仓库回收返回通知
-- SCWearHouseRecycleNotify = SCWearHouseRecycleNotify or BaseClass(BaseProtocolStruct)
-- function SCWearHouseRecycleNotify:__init()
-- 	self:InitMsgType(36, 7)
-- end

-- function SCWearHouseRecycleNotify:Decode()
-- 	self:WriteBegin()
-- end

--下发相关配置的信息
-- 36 8
-- (uint)寻宝积分
-- (uchar)配置参数数量
-- for(配置参数数量)
-- {
-- 	(int)元宝数量
-- }
SCXunBaoConfigInfo = SCXunBaoConfigInfo or BaseClass(BaseProtocolStruct)
function SCXunBaoConfigInfo:__init()
	self:InitMsgType(36, 8)
	self.xunbao_jifen = 0 -- 寻宝积分
	self.config_count = {} --配置参数数量
end

function SCXunBaoConfigInfo:Decode()
	-- self:WriteBegin()
	self.xunbao_jifen = MsgAdapter.ReadUInt()
	local count = MsgAdapter.ReadUChar()
	self.config_count = {}
	for i = 1, count do
		local v = {} 
		v.yuanbao_count = MsgAdapter.ReadInt()
		self.config_count[i] = v
	end
end

-- 移动到背包
-- 36 9
-- (long long)物品guid
SCMoveToBag = SCMoveToBag or BaseClass(BaseProtocolStruct)
function SCMoveToBag:__init()
	self:InitMsgType(36, 9)
	self.item_list = {} 
	self.result = 0
end

function SCMoveToBag:Decode()
	self:WriteBegin()
	self.item_list = {}
	local count = MsgAdapter.ReadUShort()
	for i = 1, count do
		self.item_list[i] = CommonReader.ReadSeries()
	end
	self.result = MsgAdapter.ReadUChar()
end

-- 下发全服公告信息
-- 36 12
-- (int)全服兑换信息数量
-- for(全服兑换信息数量)
-- {
-- 	(string)公告信息
-- }
SCFullScaleInfo = SCFullScaleInfo or BaseClass(BaseProtocolStruct)
function SCFullScaleInfo:__init()
	self:InitMsgType(36, 12)
	self.info_list = {}
end

function SCFullScaleInfo:Decode()
	self:WriteBegin()
	local count = MsgAdapter.ReadInt()
	self.info_list = {}
	for i = 1, count do
		self.info_list[i] = MsgAdapter.ReadStr() 
	end
end

--添加全服公告信息
SCAddAllServerInfo = SCAddAllServerInfo or BaseClass(BaseProtocolStruct)
function SCAddAllServerInfo:__init()
	self:InitMsgType(36, 13)
	self.info = ""
end

function SCAddAllServerInfo:Decode()
	self:WriteBegin()
	self.info = MsgAdapter.ReadStr() 
end


-- 清除合区的全服抽奖记录
-- 36 15
SCClearCombinedServDZPLog = SCClearCombinedServDZPLog or BaseClass(BaseProtocolStruct)
function SCClearCombinedServDZPLog:__init()
	self:InitMsgType(36, 15)
	self.info = ""
end

function SCClearCombinedServDZPLog:Decode()
	self:WriteBegin()
	self.info = MsgAdapter.ReadStr() 
end

-- 下发合区全服所有记录
-- 36 16
SCombinedServDZPLog = SCombinedServDZPLog or BaseClass(BaseProtocolStruct)
function SCombinedServDZPLog:__init()
	self:InitMsgType(36, 16)
	self.dzp_log = {}
end

function SCombinedServDZPLog:Decode()
	self.dzp_log = {}
	local count = MsgAdapter.ReadUShort()
	for i = 1, count do
		local vo = {}
		vo.type = MsgAdapter.ReadUChar()
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadInt()
		vo.name = MsgAdapter.ReadStr()
		table.insert(self.dzp_log, vo)
	end
end

-- 下发合区抽奖的当前记录
SCOneCombinedServDZPLog = SCOneCombinedServDZPLog or BaseClass(BaseProtocolStruct)
function SCOneCombinedServDZPLog:__init()
	self:InitMsgType(36, 17)
	self.type = 0
	self.item_id = 0
	self.num = 0
	self.name = ""
end

function SCOneCombinedServDZPLog:Decode()
	self:WriteBegin()
	self.type = MsgAdapter.ReadUChar()
	self.item_id = MsgAdapter.ReadUShort()
	self.num = MsgAdapter.ReadInt()
	self.name = MsgAdapter.ReadStr() 
end

-- 下发全服奖励信息
SCWorldRewardData = SCWorldRewardData or BaseClass(BaseProtocolStruct)
function SCWorldRewardData:__init()
	self:InitMsgType(36, 18)
	self.index = 0 				-- uchar当前档次
	self.xb_time = 0 			-- int 当前全服寻宝次数
	self.xb_count = 0 			-- int 当前寻宝次数记录数量
	self.xb_list = {}
	self.rew_num = 0 			-- uchar 已中奖记录数量
	self.rew_data = {}
end

function SCWorldRewardData:Decode()
	self.index = MsgAdapter.ReadUChar()
	self.xb_time = MsgAdapter.ReadInt()
	self.xb_count = MsgAdapter.ReadInt()
	self.xb_list = {}
	for i = 1, self.xb_count do
		local vo = {
			role_id = MsgAdapter.ReadInt(),
			role_name = MsgAdapter.ReadStr(),
			level = MsgAdapter.ReadInt(),
			guild_name = MsgAdapter.ReadStr(),
			xb_num = MsgAdapter.ReadInt(),
		}
		table.insert(self.xb_list, vo)
	end

	self.rew_num = MsgAdapter.ReadUChar()
	self.rew_data = {}
	for t = 1, self.rew_num do
		local vp = {
			rew_type = MsgAdapter.ReadUChar(),  		--中奖档次
			role_id = MsgAdapter.ReadInt(),
			role_name = MsgAdapter.ReadStr(),
			level = MsgAdapter.ReadInt(),
			guild_name = MsgAdapter.ReadStr(),
			xb_num = MsgAdapter.ReadInt(),
		}
		table.insert(self.rew_data, vp)
	end
end

-- 接收龙皇宝藏数据
SCRareTreasureData = SCRareTreasureData or BaseClass(BaseProtocolStruct)
function SCRareTreasureData:__init()
	self:InitMsgType(36, 19)

	self.end_time = 0 			 -- 活动天数
	self.award_pools_index = 0 	 -- 奖池索引, 第几轮回, 从1开始
	self.record_list = {} 		 -- 抽奖日志
	self.explore_times = 0 		 -- 已寻宝次数
	self.award_times = 0 		 -- 龙皇秘宝抽奖次数
	self.award_tag = 0 			 -- 已中奖标记, 按位取, 从0开始
	self.award_index = 0 		 -- 当前中奖索引, 从1开始, 0为当前没中奖
end

function SCRareTreasureData:Decode()
	self.end_time = MsgAdapter.ReadUInt()
	self.award_pools_index = MsgAdapter.ReadUChar()
	local count = MsgAdapter.ReadUChar() -- 抽奖记录数量
	self.record_list = {}
	for i = 1, count do
		self.record_list[i] = {
			role_name = MsgAdapter.ReadStr(),   -- 角色名
			item_type = MsgAdapter.ReadUChar(), -- 物品类型
			item_id = MsgAdapter.ReadUShort(), -- 物品id
			item_num = MsgAdapter.ReadUShort(), -- 物品数量
		}
	end
	self.explore_times = MsgAdapter.ReadInt()
	self.award_times = MsgAdapter.ReadInt()
	self.award_tag = MsgAdapter.ReadInt()
	self.award_index = MsgAdapter.ReadUChar()
end

-- 寻宝仓库增加物品
SCExploreStorageAddItem = SCExploreStorageAddItem or BaseClass(BaseProtocolStruct)
function SCExploreStorageAddItem:__init()
	self:InitMsgType(36, 20)
	self.item = {} 			 -- 物品数据
end

function SCExploreStorageAddItem:Decode()
	MsgAdapter.ReadUChar()
	self.item = CommonReader.ReadItemData()
end


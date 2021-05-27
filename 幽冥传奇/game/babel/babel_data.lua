BabelData  = BabelData or BaseClass()

OperateType = {
	Fighting = 1, --挑战
	Sweep = 2,		--扫荡
	BuyNum = 3,		--购买次数
	Choujiang = 4,	--4：抽奖
	ReqRankingList = 5,	--5：申请排行榜数据
} 

function BabelData:__init()
	if BabelData.Instance then
		ErrorLog("[BabelData] attempt to create singleton twice!")
		return
	end
	BabelData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	-- self.left_exchange_times = 0
	-- self.left_points = 0
	-- self.opt_point_list = {}
	-- self.attr_point_list = {}
	-- self.zhuansheng_item_cfg = CircleExp or {}
	-- self.base_attr_list = {}
	-- self:InitBaseAttrList()
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CanZhuansheng)
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CanExchangeZhuanSheng)

	self.had_fight_num = 0
    self.add_fight_num = 0
    self.had_buy_num = 0
    self.sweep_num = 0
    self.togguang_level = 0
    self.chingjiang_num = 0
    self.had_chou_num = 0
    self.reward_index = 0
    self.ranking_list_data= {}
    self.my_rank = 0
    self.reward_data = {} 
    self.cur_reward_data = {}
    self.layerlist = self:InitLayerList()
    self.reward_item_data = {}
end

function BabelData:__delete()
	BabelData.Instance = nil

end


function BabelData:SetBabelData(protocol)
	self.had_fight_num = protocol.had_fight_num
    self.add_fight_num = protocol.add_fight_num
 
    self.had_buy_num = protocol.had_buy_num
    self.sweep_num = protocol.sweep_num
    self.togguang_level = protocol.togguang_level
    self.chingjiang_num = protocol.chingjiang_num
    self.had_chou_num = protocol.had_chou_num

    local list1 =  bit:d2b(protocol.reward_index)
 	for i=1, #list1 do
		self.reward_data[i] = list1[#list1 - i + 1]
	end
   	local list2 = bit:d2b(self.reward_index)


   	for i = 1, #list2 do
		self.cur_reward_data[i] = list2[#list2 - i + 1]
	end

	for i = 1, 10 do
		if self.reward_data[i] == 1 and self.cur_reward_data[i] == 0 then
			GlobalEventSystem:Fire(BABEL_EVENET.CHOUJIANG_DATA_CHANGE, i)
			break
		end
	end

	if self.reward_index ~= protocol.reward_index then
    	self.reward_index = protocol.reward_index
    end
   -- PrintTable(self.reward_data)

    GlobalEventSystem:Fire(BABEL_EVENET.DATA_CHANGE)
end


function BabelData:GetRewardData()
	return self.reward_data
end

function BabelData:GetSweepNum()
	return self.sweep_num
end

function BabelData:GetCanSweep()
	if not ViewManager.Instance:CanOpen(ViewDef.Experiment.Babel) then
		return false
	end
	if  self.togguang_level <= 0 then
		return false
	end
	if (BabelTowerFubenConfig.sweepCount -  self.sweep_num) > 0 then
		return true
	end
	return false
end



function BabelData:SetBabelRankingListData(protocol)
	self.ranking_list_data= protocol.ranking_list_data
    self.my_rank = protocol.my_rank

    GlobalEventSystem:Fire(BABEL_EVENET.RANKING_DATA_CHANGE)
end

--得到已购买的次数
function BabelData:GetBuyNum()
	return self.had_buy_num
end



--得到通关等级
function BabelData:GetTongguangLevel()
	return self.togguang_level
end

--得到我的排行
function BabelData:GetMyRank()
	return self.my_rank
end

function BabelData:GetRemianNum()
	local total_num = BabelTowerFubenConfig.freeDayCount +  self.add_fight_num + self.had_buy_num
	local remain_num = total_num - self.had_fight_num
	return remain_num, total_num
end

--得到我的排行榜数据
function BabelData:GetRanlikListData()
	return self.ranking_list_data
end

--显示奖励
function BabelData:GetSweepRewardByLevel(level)
	local cfg = BabelTowerFubenConfig.layerlist[level] or  BabelTowerFubenConfig.layerlist[1]
	return cfg.sweepAward
end

--推荐秒伤
function BabelData:GetRecondmonsFs(level)
	local cfg = BabelTowerFubenConfig.layerlist[level] or  BabelTowerFubenConfig.layerlist[1]
	return cfg.recommend_dps
end

function BabelData:GetBossIdBylevel(level)
	local cfg = BabelTowerFubenConfig.layerlist[level] or  BabelTowerFubenConfig.layerlist[1]
	return cfg.boss.monId
end


function BabelData:InitLayerList()
	local data = {}
	for i, v in ipairs(BabelTowerFubenConfig.layerlist) do
		data[ #BabelTowerFubenConfig.layerlist - i + 1] = {
			index = i,
			awards = v.awards,
			sweepAward = v.sweepAward,
		}
	end
	return data
end

function BabelData:GetDataList()
	return self.layerlist
	--return BabelTowerFubenConfig.layerlist
end

--剩余抽奖次数
function BabelData:GetRemianChoujiangNum()
	if not ViewManager.Instance:CanOpen(ViewDef.Experiment.Babel) then
		return 0
	end
	local had_num = math.floor(self.togguang_level/BabelTowerFubenConfig.needLayer)
	local remian_num = (had_num -  self.chingjiang_num) > 0 and (had_num -  self.chingjiang_num) or 0
	return remian_num
end

function BabelData:GetCurShowList()
	local had_lun = self.had_chou_num + 1
	if had_lun > #BabelTowerFubenConfig.Roulette then
		had_lun = #BabelTowerFubenConfig.Roulette
	end
	return BabelTowerFubenConfig.Roulette[had_lun]
end


function BabelData:CurShowTopIndex()
	if self.togguang_level  + 2  <= 5 then
		local index = #BabelTowerFubenConfig.layerlist - 4
		return  index
	end
	local index = #BabelTowerFubenConfig.layerlist - self.togguang_level - 2 
	if index <= 0 then
		index = 1
	end
	return index
end

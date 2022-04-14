YYSmallRModel = YYSmallRModel or class('YYSmallRModel', BaseModel)
local YYSmallRModel = YYSmallRModel

function YYSmallRModel:ctor()
    YYSmallRModel.Instance = self
    self:Reset()

   

end

function YYSmallRModel:Reset()

    self:ClearData()

    --奖励库id-是否已获得珍稀奖励
    self.have_rare_tab = {}
end

function YYSmallRModel.GetInstance()
    if YYSmallRModel.Instance == nil then
        YYSmallRModel.new()
    end
    return YYSmallRModel.Instance
end

function YYSmallRModel:SetActIdList(id_list)
    self.act_id_list = id_list
    self.max_reward_lib_index = table.nums(id_list)
end

function YYSmallRModel:ClearData(  )
     --小R活动id列表
     self.act_id_list = nil

     --当前奖励库id
     self.cur_reward_lib_id = 0
 
     --奖励库珍稀奖励配置
     self.rare_reward_lib = nil
 
     --当前奖励库index
     self.cur_reward_lib_index = 0
 
     --最大奖励库index
     self.max_reward_lib_index = 0
 
     --代币物品id
     self.cost_item_id = nil
     
     --抽奖需要的代币物品数量
     self.cost_item_num = nil
 
     --是否自动抽奖 
     self.is_auto_lottery_draw = false
 
     --自动抽奖定时器的id
     self.auto_lottery_draw_scheld_id = nil
 
     --奖励库索引与抽取次数的映射
     self.lib_index_count_map = nil
 
     --当前抽取次数
     self.cur_count = 0
 
     --最大抽取次数
     self.sum_count = 0
end





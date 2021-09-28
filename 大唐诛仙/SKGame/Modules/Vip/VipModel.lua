VipModel = BaseClass(LuaModel)
--VipModel.isDailyLQ = 0   --每日奖励领取状态


VipModel.VipStrName = {
	"青铜",
	"白银",
	"黄金"
}
function VipModel:__init( ... )
	self:Reset()
	self:AddEvent()
end

function VipModel:Reset()
	self.lqStateTab = {0,0,0}
	self.vipId = 0
	self.playerVipId = 0
	self.timeStr = " "
	self.isDailyLQ = 0
	self.isWelfareDaily = 1
	self.vipLevel = 0
	self.isFirstLq = 0
end

function VipModel:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()  --全局事件
		self:Reset()
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function()
		VipController:GetInstance():C_GetDailyRewardState()
	end)
end

function VipModel:ShowRed()
	local isRed = false
	local isFirRed = false
	for i,v in ipairs(self.lqStateTab) do
		if v == 1 then
			isFirRed = true
			break
		end
	end
	if self.isDailyLQ == 0 or (self.vipId > 0 and self.isWelfareDaily == 0) and isFirRed then
		isRed = true
	end
	GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.store , state = isRed})

end

function VipModel:GetVipName(i)
	return self.VipStrName[i]
end

function VipModel:GetPlayerVipLV()
	return VipModel:GetInstance().vipLevel
end

function VipModel:GetInstance()
	if VipModel.inst == nil then
		VipModel.inst = VipModel.New()
	end
	return VipModel.inst
end

function VipModel:GetTequanDesListCfgData(i)              --获取特权描述配置数据
	local cfgData = GetCfgData("vip"):Get(i).des
	local desTab = {}
	for k, v in pairs(cfgData) do
		table.insert(desTab,v)
	end         
	return desTab
end

function VipModel:GetDailyRewardCfgData()                  --获取每日奖励列表
	local dailyList = {}
	local data = GetCfgData("reward")
	for k , v in pairs(data) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.VIPDailyWelfare then
			dailyList = v.reward
			break
		end
	end
	return dailyList
end

function VipModel:GetFirstRewardCfgData(i)                 --获取各vip等级首次激活奖励列表
	local cfgData = GetCfgData("vip"):Get(i)
	local rewTab = {}
	for k,v in pairs(cfgData.activateReward) do 
		table.insert(rewTab,v)
	end
	return rewTab
end

function VipModel:GetPayNumListData(i)
	local list = GetCfgData("charge")
	local tab = {}
	for k , v in pairs(list) do
		if type(v) ~= 'function' and v and v.type == 3 then
			table.insert(tab, v)
		end
	end
	table.sort(tab , function(a , b)
		return a.price < b.price
	end)
	if tab[i] then
		return tab[i].price
	else
		return 0
	end
end

function VipModel:__delete()                                --清除
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	VipModel.inst = nil
end

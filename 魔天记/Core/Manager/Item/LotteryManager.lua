
LotteryManager = {}

local _lotteryConfig = {}
local _cdTime = - 1             -- 免费次数
local _luckyPoint = 0           -- 幸运值
local _getLotteryReward = {}    -- 得到的奖励
local _itemConfig = nil
local _previewReward = nil
local insert = table.insert
local _item = nil
local _curTime = nil
local _recorder = {}
LotteryManager.LOTTERY_REDPOINT = "LOTTERY_REDPOINT"
LotteryManager.LOTTERY_RECORDER = "LOTTERY_RECORDER"
function LotteryManager.Init()
	_recorder = {}
	_cdTime = - 1
	_previewReward = nil
	_lotteryConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_LOTTERY) [1]
end

function LotteryManager.GetLotteryConfig()
	return _lotteryConfig
end

function LotteryManager.SetCdTime(cd)
	
	if(cd) then
		_curTime = GetTime()
		_cdTime = cd	
	end
	MessageManager.Dispatch(LotteryManager, LotteryManager.LOTTERY_REDPOINT)
	
end

function LotteryManager.GetCdTime()
	return _cdTime
end

function LotteryManager.SetLuckyPoint(point)
	_luckyPoint = point
end

function LotteryManager.GetLuckyPoint()
	return _luckyPoint
end

function LotteryManager.GetLuckyPointUpper()
	return _lotteryConfig.double_upper
end

function LotteryManager.SetGetLotteryReward(reward)
	_getLotteryReward = {}
	
	for k, v in ipairs(reward) do
		local item = ProductInfo:New()
		item:Init({spId = tonumber(v.spId), am = v.am})
		insert(_getLotteryReward, item)
	end
end

function LotteryManager.GetGetLotteryReward()
	return _getLotteryReward
end

function LotteryManager.GetGetLotteryRewardNum()
	return table.getCount(_getLotteryReward)
end

function LotteryManager.GetSpendGoldOneLottery()
	return _lotteryConfig.need_gold
end

function LotteryManager.GetSpendGoldFiftyLottery()
	return _lotteryConfig.fifty_gold
end

function LotteryManager.GetShowItemConfig()
	if(_itemConfig == nil) then
		_itemConfig = {}
		for k, v in ipairs(_lotteryConfig.show) do
			_itemConfig[k] = ProductManager.GetProductById(v)	
		end	
	end
	return _itemConfig
end

function LotteryManager.GetItemConfig()
	if(_item == nil) then
		_item = ProductManager.GetProductById(_lotteryConfig["item_id"])
	end
	return _item
end

-- 获取十连抽消耗上限
function LotteryManager.GetSpendGoldTenLottery()
	return _lotteryConfig.spend_gold
end

-- 获取抽奖界面显示的道具
function LotteryManager.GetLotteryShowReward()
	if(_previewReward == nil) then
		
		_previewReward = {}
		local career = PlayerManager.GetPlayerKind()
		local config = _lotteryConfig["show_" .. career]		
		
		for key, value in ipairs(config) do
			local o = ProductManager.GetProductById(value)			
			insert(_previewReward, o)
		end
	end
	return _previewReward
end

-- 设置抽奖结束后信息
function LotteryManager.OnSetLotteryInfo(reward, cd, luckyPoint)
	if reward ~= nil then
		LotteryManager.SetGetLotteryReward(reward)
	end
	if cd ~= nil then
		LotteryManager.SetCdTime(cd)
	end
	if luckyPoint ~= nil then
		LotteryManager.SetLuckyPoint(luckyPoint)
	end
end

function LotteryManager.GetIsFree()
	if(_cdTime == - 1) then return false end
	return(_cdTime -(GetTime() - _curTime)) <= 0
end

function LotteryManager.SetLotteryRecorder(recorder)
	_recorder = {}
	if(recorder) then
		local cfg = MsgUtils.GetMsgCfgById(1050);	
		
		for k, v in ipairs(recorder) do
			local p = {a = v.pi, b = v.pn, c = v.spId, d = v.am}
			local msg = LanguageMgr.ApplyFormat(cfg and cfg.msgStr or "", p, true)		
			
			insert(_recorder, msg)
		end		
	end
	
end

function LotteryManager.GetLotteryRecorder()
	return _recorder	
end 
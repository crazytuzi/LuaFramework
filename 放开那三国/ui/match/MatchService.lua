-- FileName: MatchService.lua 
-- Author: Li Cong 
-- Date: 13-11-7 
-- Purpose: function description of module 


module("MatchService", package.seeall)
require "script/ui/match/MatchData"

-- 得到比武数据
-- callbackFunc:回调
function getCompeteInfo( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getContestInfo---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			-- 读取配置信息
			MatchData.m_useXmlData = MatchData.getXmlData( dataRet.round )
			-- 比武所有信息
			MatchData.m_allData = dataRet
			-- 比武列表
			MatchData.m_userData = MatchData.m_allData.rivalList
			-- 仇人列表
			MatchData.m_enemyData = MatchData.m_allData.foeList
			-- top3列表
			MatchData.m_top3Data = MatchData.m_allData.rankList
			-- 发奖倒计时
			MatchData.m_rewardTime = MatchData.m_allData.rewardTime
			-- 比武场状态
			MatchData.m_matchState = MatchData.m_allData.state
			-- 比武已用的次数 by 2014.5.22 启用
			MatchData.m_usedNum = tonumber(MatchData.m_allData.num)
			-- 已购买比武次数
			MatchData.setBuyNum( MatchData.m_allData.buy )
			-- 倒计时
			-- 当前服务器时间
		    local curServerTime = BTUtil:getSvrTimeInterval()
		    local data = tonumber(MatchData.m_allData.refresh) - tonumber(curServerTime)
		    MatchData.setDownTimeData(data)
			-- 回调
			callbackFunc()
		end
	end
	Network.rpc(requestFunc, "compete.getCompeteInfo", "compete.getCompeteInfo", nil, true)
end


-- 刷新对手
-- callbackFunc:回调
function refreshRivalList( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("refreshRivalList---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			-- 更新对手列表
			MatchData.m_userData = dataRet
			-- 回调
			callbackFunc()
		end
	end
	Network.rpc(requestFunc, "compete.refreshRivalList", "compete.refreshRivalList", nil, true)
end


-- 比武
-- atkedUid:敌人uid
-- type:0是比武,1是复仇
-- callbackFunc:回调
-- 加一个参数 itemBtn 防止发送两次请求
function contest( atkedUid, type, callbackFunc, itemBtn )
	local function requestFunc( cbFlag, dictData, bRet )
		-- 按钮恢复可点击状态
		if(itemBtn ~= nil)then
        	itemBtn:setEnabled(true)
        end
		print ("contest---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			-- 消耗1次比武数
			MatchData.addContestNum(1)
			-- 设置消耗耐力值
			UserModel.addStaminaNumber(-2)
			-- 更新对手列表
			if(dataRet.rivalList ~= nil)then
				MatchData.m_userData = dataRet.rivalList
			end
			-- 回调
			callbackFunc( dataRet.atk, dataRet.flop,  dataRet.rank, dataRet.point, dataRet.suc_point )
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(atkedUid))
	args:addObject(CCInteger:create(type))
	Network.rpc(requestFunc, "compete.contest", "compete.contest", args, true)
end


-- 排行榜
-- callbackFunc:回调
function getRankList( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getRankList---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			MatchData.m_rankingListData = dataRet
			-- 回调
			callbackFunc()
		end
	end
	Network.rpc(requestFunc, "compete.getRankList", "compete.getRankList", nil, true)
end

-- 比武购买次数
-- num:数量
-- callbackFunc:回调
function buyCompeteNum( num, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("buyCompeteNum---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				if(callbackFunc ~= nil)then
					callbackFunc()
				end
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(num)))
	Network.rpc(requestFunc, "compete.buyCompeteNum", "compete.buyCompeteNum", args, true)
end


-- 比武商城
-- goodsId:商品id
-- num:数量
-- callbackFunc:回调
function buy( goodsId, num, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("buy---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				if(callbackFunc ~= nil)then
					callbackFunc()
				end
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(goodsId)))
	args:addObject(CCInteger:create(tonumber(num)))
	Network.rpc(requestFunc, "compete.buy", "compete.buy", args, true)
end

-- 获得比武商城信息
-- callbackFunc:回调
function getShopInfo( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getShopInfo---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			-- 商城信息
			MatchData.setShopInfo(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "compete.getShopInfo", "compete.getShopInfo", nil, true)
end
























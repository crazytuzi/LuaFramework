-- FileName: FriendService.lua 
-- Author: Li Cong 
-- Date: 13-8-27 
-- Purpose: function description of module 


module("FriendService", package.seeall)


-- 获取所有好友信息
function getFriendInfoList( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("getFriendInfoList---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			FriendData.allfriendData = dictData.ret
			callbackFunc()
		end
	end
	Network.rpc(requestFunc, "friend.getFriendInfoList", "friend.getFriendInfoList", nil, true)
end


-- 获取所有系统推荐好友信息
function getRecomdFriends( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print (GetLocalizeStringBy("key_1467"))
		if(bRet == true)then
			-- print_t(dictData.ret)
			FriendData.recomdFriendData = dictData.ret
			if( table.count(FriendData.recomdFriendData) == 0 )then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_1388")
				AnimationTip.showTip(str)
				return
			end
			callbackFunc()
		end
	end
	Network.rpc(requestFunc, "friend.getRecomdFriends", "friend.getRecomdFriends", nil, true)
end


-- 判断是否为好友
-- uid:玩家uid
-- callbackFunc: 回调
-- callFunMark：0:不是好友时调callbackFunc， 1:是好友时调callbackFunc， 默认是0
function isFriend( uid, callbackFunc, callFunMark )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("isFriend---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			local dataRet = dictData.ret
			local callMark = callFunMark or 0
			if(dataRet == "true" or dataRet == true )then
				if(callMark == 0)then
					require "script/ui/tip/AnimationTip"
					local str = GetLocalizeStringBy("key_1699")
					AnimationTip.showTip(str)
				end
				if(callMark == 1)then
					callbackFunc()
				end
			end
			if(dataRet == "false" or dataRet == false)then
				if(callMark == 0)then
					callbackFunc()
				end
				if(callMark == 1)then
					require "script/ui/tip/AnimationTip"
					local str = GetLocalizeStringBy("lic_1000")
					AnimationTip.showTip(str)
				end
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(uid)))
	Network.rpc(requestFunc, "friend.isFriend", "friend.isFriend", args, true)
end



-- 获取单个好友信息
-- uid:玩家uid
-- callbackFunc: 回调
function getFriendInfo( uid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("getFriendInfo---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				callbackFunc()
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	Network.rpc(requestFunc, "friend.getFriendInfo", "friend.getFriendInfo", args, true)
end


-- 删除好友
-- uid:玩家uid
-- callbackFunc: 回调
function delFriend( uid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("delFriend---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				callbackFunc()
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_1846")
				AnimationTip.showTip(str)
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	Network.rpc(requestFunc, "friend.delFriend", "friend.delFriend", args, true)
end


-- 申请好友
-- uid:玩家uid
-- content: 申请附言	
-- callbackFunc: 回调
function applyFriend( uid, content, callbackFunc )
	if(content == "")then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_2088")
		AnimationTip.showTip(str)
		return
	end
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("applyFriend---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			local dataRet = dictData.ret
			-- 等待确认
			if(dataRet == "applied")then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_3243")
				AnimationTip.showTip(str)
				return
			elseif(dataRet == "reach_maxnum")then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_2345")
				AnimationTip.showTip(str)
				return
			elseif(dataRet == "black")then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("lic_1061")
				AnimationTip.showTip(str)
				return
			elseif(dataRet == "beblack")then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("lic_1055")
				AnimationTip.showTip(str)
				return
			elseif(dataRet == "ok")then
				callbackFunc()
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	args:addObject(CCString:create(content))
	Network.rpc(requestFunc, "friend.applyFriend", "friend.applyFriend", args, true)
end


-- 发送邮件
-- int $reciever_uid: 接受者ID	
-- string $subject: 主题	
-- string $content: 内容	
function sendMail(reciever_uid, subject, content, callbackFunc )
	if(content == "")then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_2088")
		AnimationTip.showTip(str)
		return
	end
	local function requestFunc( cbFlag, dictData, bRet )
		-- print (GetLocalizeStringBy("key_1153"))
		if(bRet == true)then
			-- print_t(dictData.ret)
			if(dictData.ret == "true" or dictData.ret == true )then
				callbackFunc()
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(reciever_uid))
	args:addObject(CCString:create(subject))
	args:addObject(CCString:create(content))
	Network.rpc(requestFunc, "mail.sendMail", "mail.sendMail", args, true)
end


-- 搜索某个好友信息 
-- string $unameLike	
-- int $offset(: 默认为0 )	
-- int $limit（默认为数据库允许最大）	
function getRecomdByName( unameLike, offset, limit, callbackFunc )
	if(unameLike == "")then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_2959")
		AnimationTip.showTip(str)
		return
	end
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("getRecomdByName---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			FriendData.searchFriendData = dictData.ret
			if(table.count(FriendData.searchFriendData) == 0)then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_3405")
				AnimationTip.showTip(str)
				-- 显示推荐好友
				if( FriendData.recomdFriendData ~= nil)then
					FriendData.searchFriendData = FriendData.recomdFriendData
				end
			end
			callbackFunc()
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCString:create(unameLike))
	-- args:addObject(CCInteger:create(offset))
	-- args:addObject(CCInteger:create(limit))
	Network.rpc(requestFunc, "friend.getRecomdByName", "friend.getRecomdByName", args, true)
end



------------------------------------------- 赠送耐力 -----------------------------------------


-- 赠送好友耐力
-- uid:好友uid
-- callbackFunc: 回调
function giveStaminaService( uid, callbackFunc )
	print("uid+++",uid)
	local function requestFunc( cbFlag, dictData, bRet )
		print ("loveFriend---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				local num = FriendData.getGiveStaminaNum()
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_3310") .. num .. GetLocalizeStringBy("key_1413")
				AnimationTip.showTip(str)
				-- 把当前时间设置为上次赠送时间
				FriendData.setGiveTimeByUid( uid )
				callbackFunc()
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	Network.rpc(requestFunc, "friend.loveFriend", "friend.loveFriend", args, true)
end


-- 获取可领取列表数据
function getReceiveStaminaList( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("unreceiveLoveList---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			-- 设置小红圈数量
			FriendData.setReceiveListCount( table.count( dictData.ret.va_love ) )
			-- 可领取耐力列表
			FriendData.setReceiveList( dictData.ret.va_love ) 
			-- 今天总共能领取的次数
			local totalNum = FriendData.getOneDayTotalTimes()
			-- 今天已经领取的次数
			local usedNum = tonumber( dictData.ret.num )
			-- 今日剩余领取次数
			FriendData.setTodayReceiveTimes( totalNum-usedNum )
			-- 回调
			callbackFunc()
		end
	end
	Network.rpc(requestFunc, "friend.unreceiveLoveList", "friend.unreceiveLoveList", nil, true)
end



-- 获得好友耐力
-- uid:好友uid
-- callbackFunc: 回调
function receiveStaminaService( time, uid, callbackFunc )
	-- 判断是否还有剩余次数
	local times = FriendData.getTodayReceiveTimes()
	if( times <= 0)then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_3230")
		AnimationTip.showTip(str)
		return
	end
	-- 耐力已达上限
	if( UserModel.getStaminaNumber() >= UserModel.getMaxStaminaNumber() )then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_2642")
		AnimationTip.showTip(str)
		return
	end
	-- 该好友数据
	local thisFriendData = FriendData.getThisFriendDataByUid( uid )
	local isGive = nil
	local isFriend = false
	if(not table.isEmpty(thisFriendData))then
		isFriend = true
		isGive = FriendData.isGiveTodayByTime( thisFriendData.lovedTime )
	end
	local function requestFunc( cbFlag, dictData, bRet )
		print ("receiveLove---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				local num = FriendData.getGiveStaminaNum()
				local str = nil
				if(isFriend)then
					if(isGive)then
						str = GetLocalizeStringBy("key_1862") .. num .. GetLocalizeStringBy("key_1656") 
					else
						str = GetLocalizeStringBy("key_1862") .. num .. GetLocalizeStringBy("key_1446") .. num ..GetLocalizeStringBy("key_1233")
						-- 把当前时间设置为上次赠送时间
						FriendData.setGiveTimeByUid( uid )
					end
				else
					str = GetLocalizeStringBy("key_1862") .. num .. GetLocalizeStringBy("key_1418") 
				end

				require "script/ui/tip/AnimationTip"
				AnimationTip.showTip(str)
				-- 加耐力
				UserModel.addStaminaNumber( num )
				-- 减剩余次数
				local times = FriendData.getTodayReceiveTimes()
				FriendData.setTodayReceiveTimes( times-1 )
				-- 删除次数据
				FriendData.delStaminaDataByTimeAndUid(time,uid)
				callbackFunc()
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(time))
	args:addObject(CCInteger:create(uid))
	local isGiveData = 0
	if(isFriend)then
		if(isGive)then
			-- 已赠送则不需要回赠为0
			isGiveData = 0
		else
			-- 未赠送 需要回赠为1
			isGiveData = 1
		end
	else
		isGiveData = 0
	end
	
	args:addObject(CCInteger:create(isGiveData))
	Network.rpc(requestFunc, "friend.receiveLove", "friend.receiveLove", args, true)
end


-- 全部领取
function receiveAllStamina( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print (GetLocalizeStringBy("key_2147"))
		if(bRet == true)then
			print_t(dictData.ret)
			-- 可领取耐力列表
			FriendData.setReceiveList( dictData.ret.list )
			-- 设置小红圈数量
			FriendData.setReceiveListCount( table.count( dictData.ret.list ) )
			-- 今日剩余领取次数
			local times = FriendData.getTodayReceiveTimes()
			local curUseTimes = tonumber(dictData.ret.receivedNum)
			FriendData.setTodayReceiveTimes( times-curUseTimes )
			-- 获得的耐力
			local oneData = FriendData.getGiveStaminaNum()
			local totalData = oneData * curUseTimes
			UserModel.addStaminaNumber( totalData )
			-- 回调
			callbackFunc( totalData )
		end
	end
	Network.rpc(requestFunc, "friend.receiveAllLove", "friend.receiveAllLove", nil, true)
end

------------------------------------ 好友PK ------------------------

-- 得到要挑战好友数据
-- uid:好友uid
-- callbackFunc: 回调
function getPkInfo( uid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getPkInfo---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc(dataRet)
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	Network.rpc(requestFunc, "friend.getPkInfo", "friend.getPkInfo", args, true)
end


-- 挑战好友
-- uid:好友uid
-- callbackFunc: 回调
function pkOnce( uid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("pkOnce---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc(dataRet)
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	Network.rpc(requestFunc, "friend.pkOnce", "friend.pkOnce", args, true)
end

------------------------------------- 黑名单 ---------------------------------
-- 得到黑名单列表
-- callbackFunc: 回调
function getBlackers( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getBlackers---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			-- 设置黑名单列表
			FriendData.setBlackListData(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc()
			end
		end
	end
	-- 参数
	Network.rpc(requestFunc, "friend.getBlackers", "friend.getBlackers", nil, true)
end

-- 拉黑
-- uid:玩家uid
-- callbackFunc: 回调
function blackYou( uid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("blackYou---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(dataRet == "ok")then
				-- 加黑名单数据 聊天用
				require "script/ui/chat/ChatCache"
				ChatCache.addShieldedPlayer(uid)
				if(callbackFunc ~= nil)then
					callbackFunc()
				end
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("lic_1053")
				AnimationTip.showTip(str)
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	Network.rpc(requestFunc, "friend.blackYou", "friend.blackYou", args, true)
end

-- 解除拉黑
-- uid:玩家uid
-- callbackFunc: 回调
function unBlackYou( uid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("unBlackYou---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(dataRet == "ok")then
				-- 删除黑名单数据 聊天用
				require "script/ui/chat/ChatCache"
				ChatCache.deleteShieldedPlayer(uid)
				if(callbackFunc ~= nil)then
					callbackFunc()
				end
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	Network.rpc(requestFunc, "friend.unBlackYou", "friend.unBlackYou", args, true)
end














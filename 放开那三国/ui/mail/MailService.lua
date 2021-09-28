-- FileName: MailService.lua 
-- Author: Li Cong 
-- Date: 13-8-20 
-- Purpose: function description of module 


module("MailService", package.seeall)

-- 得到收件箱邮件列表数据
-- n_startIndex:开始索引第一次为0，其他情况下是mid
-- n_num:个数
-- older: 是拉取比参照值老的邮件还是新的邮件	 旧邮件是true, 新邮件是false  第一次拉取默认true
-- callbackFunc:回调
function getMailBoxList(n_startIndex, n_num, older, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("getMailBoxList---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			MailData.allMailData = dictData.ret
			MailData.mail_AllData = dictData.ret.list
			callbackFunc( dictData.ret.list )
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(n_startIndex))
	args:addObject(CCInteger:create(n_num))
	args:addObject(CCString:create(older))
	Network.rpc(requestFunc, "mail.getMailBoxList", "mail.getMailBoxList", args, true)
end


-- 得到系统邮件列表数据
-- n_startIndex:开始索引
-- n_num:个数
-- older: 是拉取比参照值老的邮件还是新的邮件	 旧邮件是true, 新邮件是false
-- callbackFunc:回调
function getSysMailList(n_startIndex, n_num, older, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getSysMailList---后端数据")
		if(bRet == true)then
			print_t(dictData.ret)
			MailData.systemMailData = dictData.ret
			callbackFunc( dictData.ret.list )
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(n_startIndex))
	args:addObject(CCInteger:create(n_num))
	args:addObject(CCString:create(older))
	Network.rpc(requestFunc, "mail.getSysMailList", "mail.getSysMailList", args, true)
end


-- 得到好友邮件列表数据
-- n_startIndex:开始索引
-- n_num:个数
-- older: 是拉取比参照值老的邮件还是新的邮件	 旧邮件是true, 新邮件是false
-- callbackFunc:回调
function getPlayMailList(n_startIndex, n_num, older, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("getPlayMailList---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			MailData.friendMailData = dictData.ret
			callbackFunc( dictData.ret.list )
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(n_startIndex))
	args:addObject(CCInteger:create(n_num))
	args:addObject(CCString:create(older))
	Network.rpc(requestFunc, "mail.getPlayMailList", "mail.getPlayMailList", args, true)
end


-- 得到战斗邮件列表数据
-- n_startIndex:开始索引
-- n_num:个数
-- older: 是拉取比参照值老的邮件还是新的邮件	 旧邮件是true, 新邮件是false
-- callbackFunc:回调
function getBattleMailList(n_startIndex, n_num, older, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("getBattleMailList---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			MailData.battleMailData = dictData.ret
			callbackFunc( dictData.ret.list )
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(n_startIndex))
	args:addObject(CCInteger:create(n_num))
	args:addObject(CCString:create(older))
	Network.rpc(requestFunc, "mail.getBattleMailList", "mail.getBattleMailList", args, true)
end


-- 得到资源矿邮件列表数据
-- n_startIndex:开始索引第一次为0，其他情况下是mid
-- n_num:个数
-- older: 是拉取比参照值老的邮件还是新的邮件	 旧邮件是true, 新邮件是false  第一次拉取默认true
-- callbackFunc:回调
function getMineralMailList(n_startIndex, n_num, older, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("getMineralMailList---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			MailData.mineralData = dictData.ret
			callbackFunc( dictData.ret.list )
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(n_startIndex))
	args:addObject(CCInteger:create(n_num))
	args:addObject(CCString:create(older))
	Network.rpc(requestFunc, "mail.getMineralMailList", "mail.getMineralMailList", args, true)
end


-- 根据邮件id来获取邮件信息
-- mid:邮件id
-- callbackFunc:回调
function getMailDetail(mid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("getMailDetail---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			MailData.mailData = dictData.ret
			callbackFunc()
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(mid))
	Network.rpc(requestFunc, "mail.getMailDetail", "mail.getMailDetail", args, true)
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


-- 邮件同意操作
--   int $uid: 申请者uid	
function setApplyMailAdded(uid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("setApplyMailAdded---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				-- 修改邮件显示数据
				MailData.updateShowMailData( uid, 1 )
				callbackFunc()
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	Network.rpc(requestFunc, "mail.setApplyMailAdded", "mail.setApplyMailAdded", args, true)
end


-- 邮件拒绝操作
--   int $uid: 申请者uid		
function setApplyMailRejected(uid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("setApplyMailRejected---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				-- 修改邮件显示数据
				MailData.updateShowMailData( uid, 2 )
				callbackFunc()
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	Network.rpc(requestFunc, "mail.setApplyMailRejected", "mail.setApplyMailRejected", args, true)
end


-- -- 删除邮件
-- --   int $mid: 邮件ID	
-- function deleteMail(mid, callbackFunc )
-- 	local function requestFunc( cbFlag, dictData, bRet )
-- 		print (GetLocalizeStringBy("key_1153"))
-- 		if(bRet == true)then
-- 			print_t(dictData.ret)
-- 			local dataRet = dictData.ret
-- 			if(dataRet.ret == "ok")then
-- 				-- ArenaData.arenaInfo = dataRet.res
-- 				callbackFunc()
-- 			end
-- 		end
-- 	end
-- 	-- 参数
-- 	local args = CCArray:create()
-- 	args:addObject(CCInteger:create(mid))
-- 	Network.rpc(requestFunc, "mail.deleteMail", "mail.deleteMail", args, true)
-- end


-- 同意好友
-- int $fuid: 对方uid( 申请者的uid )	
function addFriend(uid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("addFriend---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			if(dictData.ret == "ok")then
				callbackFunc()
			elseif(dictData.ret == "isfriend")then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_2315") 
				AnimationTip.showTip(str)
				return
			elseif(dictData.ret == "applicant_reach_maxnum")then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_2225") 
				AnimationTip.showTip(str)
				return
			elseif(dictData.ret == "accepter_reach_maxnum")then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_2345") 
				AnimationTip.showTip(str)
				return
			elseif(dictData.ret == "black")then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("lic_1060")
				AnimationTip.showTip(str)
				return
			elseif(dictData.ret == "beblack")then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("lic_1059")
				AnimationTip.showTip(str)
				return
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	Network.rpc(requestFunc, "friend.addFriend", "friend.addFriend", args, true)
end


-- 拒绝好友
-- int $uid: 对方uid( 申请者的uid )	
function rejectFriend(uid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("rejectFriend---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				callbackFunc()
			end
			if(dataRet == "isfriend")then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_2315") 
				AnimationTip.showTip(str)
				return
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	Network.rpc(requestFunc, "friend.rejectFriend", "friend.rejectFriend", args, true)
end


-- 得到玩家的资源矿
-- int $uid: 对方uid
-- mark: 被抢矿的标识	
function getDomainIdOfUser(uid,mark,callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		print ("getDomainIdOfUser---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			local dataRet = dictData.ret
			if(tonumber(dataRet) == 0)then
				-- 报错字符
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_2577")
				AnimationTip.showTip(str)
				return
			end
			callbackFunc(dataRet)
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(uid))
	args:addObject(CCInteger:create(mark))
	Network.rpc(requestFunc, "mineral.getDomainIdOfUser", "mineral.getDomainIdOfUser", args, true)
end



-- 得到战斗串
--  int $brid: 战报id	
local countIndex = 0
function getRecord(p_brid, callbackFunc )
	local bridId = tostring(p_brid)
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("getRecord---后端数据")
		if(bRet == true)then
			-- print_t(dictData.ret)
			local dataRet = dictData.ret
			callbackFunc( dataRet )
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCString:create(bridId))
	if( countIndex > 10000)then
		countIndex = 0
	else
		countIndex = countIndex + 1
	end
	Network.rpc(requestFunc, "battle.getRecord" .. countIndex, "battle.getRecord", args, true)
end













-- @Author hj
-- @Description 改版好友系统数据处理流的VoApi
-- @Date 2018-04-18

friendInfoVoApi={
}

function friendInfoVoApi:initData(data)
	if data then
		friendInfoVo:initWithData(data)
		self:bubbleSortFriendTb()
	end
end

function friendInfoVoApi:getFriendTb()
	self:bubbleSortFriendTb()
    return friendInfoVo.friendTb
end

function friendInfoVoApi:getbInviteTb( ... )
	return friendInfoVo.binviteTb
end

-- 对好友列表进行冒泡排序
function friendInfoVoApi:bubbleSortFriendTb()
	-- 结束排序的标记位
	local flag = 0
	for k,v in pairs(friendInfoVo.friendTb) do
		for i=1,#friendInfoVo.friendTb - k,1 do
			if tonumber(friendInfoVo.friendTb[i].level) < tonumber(friendInfoVo.friendTb[i+1].level) then
				local temp = friendInfoVo.friendTb[i+1]
				friendInfoVo.friendTb[i+1] = friendInfoVo.friendTb[i]
				friendInfoVo.friendTb[i] = temp
				flag = 1
			elseif tonumber(friendInfoVo.friendTb[i].level) == tonumber(friendInfoVo.friendTb[i+1].level) then
				if friendInfoVo.friendTb[i].fc < friendInfoVo.friendTb[i+1].fc then
					local temp = friendInfoVo.friendTb[i+1]
					friendInfoVo.friendTb[i+1] = friendInfoVo.friendTb[i]
					friendInfoVo.friendTb[i] = temp
					flag = 1
				end
			end
		end
		if flag == 0 then
			break
		end
	end
end

function friendInfoVoApi:getfriendCfg(flag)
	package.loaded["luascript/script/config/gameconfig/friendNew"] = nil
	package.loaded["luascript/script/config/gameconfig/memoryServerCfg/friendNew"] = nil
	local newFrcfg={}
	if G_isMemoryServer() == true then
		newFrcfg = G_requireLua("config/gameconfig/memoryServerCfg/friendNew")
	else
		newFrcfg = G_requireLua("config/gameconfig/friendNew")
	end
	if flag == 1 then
		if newFrcfg.giftLimit then
			return newFrcfg.giftLimit
		end
	elseif flag == 2 then
		if newFrcfg.friendLimit then
			return newFrcfg.friendLimit
		end
	end
end
function friendInfoVoApi:addbinviteTb(v)
	-- 去重
	for kk,vv in pairs(friendInfoVo.binviteTb) do
		if tonumber(v[1]) == tonumber(vv.uid) then
			do return end
		end
	end
	local binvite = {}
    if v[1] then
        binvite.uid = tonumber(v[1])
    end
    if v[2] then
        binvite.nickname = v[2]
    end
    if v[3] then
        binvite.vip = tonumber(v[3])
    end
    if v[4] then
        binvite.rank = tonumber(v[4])
    end
    if v[5] then
        binvite.alliancename = v[5]
    end
    if v[6] then
        binvite.title = v[6]
    end
    if v[7] then
        binvite.fc = tonumber(v[7])
    end
    if v[8] then
        binvite.level = tonumber(v[8])
    end
    if v[9] then
        binvite.pic = v[9]
    end
    if v[10] then
        binvite.bpic = v[10]
    end
    table.insert(friendInfoVo.binviteTb,binvite)
end


function friendInfoVoApi:addFriend(v)
	for kk,vv in pairs(friendInfoVo.friendTb) do
		if tonumber(v[1]) == tonumber(vv.uid) then
			do return end
		end
	end

	local friendInfo = {}
    if v[1] then
        friendInfo.uid = tonumber(v[1])
    end
    if v[2] then
        friendInfo.nickname = v[2]
    end
    if v[3] then
        friendInfo.vip = tonumber(v[3])
    end
    if v[4] then
        friendInfo.rank = tonumber(v[4])
    end
    if v[5] then
        friendInfo.alliancename = v[5]
    end
    if v[6] then
        friendInfo.title = v[6]
    end
    if v[7] then
        friendInfo.fc = tonumber(v[7])
    end
    if v[8] then
        friendInfo.level = tonumber(v[8])
    end
    if v[9] then
        friendInfo.pic = v[9]
    end
    if v[10] then
        friendInfo.bpic = v[10]
    end
    if v[11] then
    	friendInfo.sendFlag = v[11][1]
    	friendInfo.receiveFlag = v[11][2]
    end
    table.insert(friendInfoVo.friendTb,friendInfo)
    self:bubbleSortFriendTb()
end

function friendInfoVoApi:removebinviteTb(uid)
	for k,v in pairs(friendInfoVo.binviteTb) do
		if v.uid == uid then
			table.remove(friendInfoVo.binviteTb,k)
			return true
		end
	end
end

function friendInfoVoApi:juedgeIsMyfriend(uid)
	for k,v in pairs(friendInfoVo.friendTb) do
		if v.uid == uid then
			return true
		end
	end
	return false
end

function friendInfoVoApi:getSendStatus()
	local sendStatusTb = {}
	for k,v in pairs(friendInfoVo.friendTb) do
		if v.sendFlag then
			table.insert(sendStatusTb,v.sendFlag)
		end
	end
	return sendStatusTb
end

function friendInfoVoApi:updateSendStatus(uid,status)
	for k,v in pairs(friendInfoVo.friendTb) do
		if v.uid == uid then
			v.sendFlag = status
			return true
		end
	end
	return false
end

function friendInfoVoApi:updateReceiveStatus(uid,status)
	for k,v in pairs(friendInfoVo.friendTb) do
		if v.uid == uid then
			v.receiveFlag = status
			return true
		end
	end
	return false
end

function friendInfoVoApi:updateAllSendStatus( ... )
	for k,v in pairs(friendInfoVo.friendTb) do
		if v.sendFlag == 0 then
			v.sendFlag = 1
		end
	end
end



function friendInfoVoApi:updateAllReceiveStatus(len)
	-- 接受的时候有可能达到上限就会失败,lenth为可以接受的长度
	for i=1,len,1 do
		for k,v in pairs(friendInfoVo.friendTb) do
			if v.receiveFlag == 1 then
				v.receiveFlag = 2
				break
			end
		end
	end
end

function friendInfoVoApi:getReceiveStatus()
	local receiveStatusTb = {}
	for k,v in pairs(friendInfoVo.friendTb) do
		if v.receiveFlag then
			table.insert(receiveStatusTb,v.receiveFlag)
		end
	end
	return receiveStatusTb
end

function friendInfoVoApi:judgeAllSend( ... )
	for k,v in pairs(friendInfoVo.friendTb) do
		if v.sendFlag == 0 then
			return false
		end
	end
	return true
end

function friendInfoVoApi:removeFriend(uid)
	for k,v in pairs(friendInfoVo.friendTb) do
		if v.uid == tonumber(uid) then
			table.remove(friendInfoVo.friendTb,k)
			self:bubbleSortFriendTb()
			return true
		end
	end
	return false
end	

-- 获取当前好友列表未接受礼物的数量
function friendInfoVoApi:getUnreceiveNum( ... )
	local sum = 0 
	for k,v in pairs(friendInfoVo.friendTb) do
		if v.receiveFlag == 1 then
			sum = sum +1
		end
	end
	return sum
end

function friendInfoVoApi:getCanReceiveNum( ... )
	if friendInfoVoApi:getGiftNum() < friendInfoVoApi:getfriendCfg(1) then
		if self:getfriendCfg(1) - self:getGiftNum() >= self:getUnreceiveNum() then
			return self:getUnreceiveNum()
		else
			return self:getfriendCfg(1) - self:getGiftNum()
		end
	else
		return 0
	end
	
end

function friendInfoVoApi:isHasUnreceiveNum( ... )
	if friendInfoVoApi:getGiftNum() < friendInfoVoApi:getfriendCfg(1) and self:getUnreceiveNum() > 0 then
		return true
	else
		return false
	end
end


function friendInfoVoApi:isHasInvite( ... )
	if #friendInfoVo.binviteTb > 0 then
		return true
	else
		return false
	end
end

function friendInfoVoApi:getUnSendNum( ... )
	local sum = 0 
	for k,v in pairs(friendInfoVo.friendTb) do
		if v.sendFlag == 0 then
			sum = sum +1
		end
	end
	return sum
end

function friendInfoVoApi:showDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/friendInfo/friendInfoDialog"
	require "luascript/script/game/scene/gamedialog/friendInfo/friendListDialog"
	require "luascript/script/game/scene/gamedialog/friendInfo/friendShieldDialog"
	local tbArr = {}
   	local td=friendInfoDialog:new()
   	if FuncSwitchApi:isEnabled("friend_gift") == true then
   		require "luascript/script/game/scene/gamedialog/friendInfo/friendGiftDialog"
   		tbArr = {getlocal("friend_newSys_tab1"),getlocal("friend_newSys_tab2"),getlocal("friend_newSys_tab3")}
   	else
   		tbArr = {getlocal("friend_newSys_tab1"),getlocal("friend_newSys_tab3")}
   	end
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("bookmarksFriend"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

function friendInfoVoApi:initBlackListTb(mailblack) 
   	G_blackList={}
   	friendInfoVo.shieldTb = {}
    for i=G_blackListNum,1,-1 do
        if mailblack and mailblack[i] then
            local simpleShield = {}
            table.insert(simpleShield,mailblack[i][1])
            table.insert(simpleShield,mailblack[i][2])
            table.insert(G_blackList,simpleShield)
            local blackDetailTb = {}
		    if mailblack[i][1] then
		        blackDetailTb.uid = tonumber(mailblack[i][1])
		    end
		    if mailblack[i][2] then
		        blackDetailTb.nickname = mailblack[i][2]
		    end
		    if mailblack[i][3] then
		        blackDetailTb.vip = tonumber(mailblack[i][3])
		    end
		    if mailblack[i][4] then
		        blackDetailTb.rank = tonumber(mailblack[i][4])
		    end
		    if mailblack[i][5] then
		        blackDetailTb.alliancename = mailblack[i][5]
		    end
		    if mailblack[i][6] then
		        blackDetailTb.title = mailblack[i][6]
		    end
		    if mailblack[i][7] then
		        blackDetailTb.fc = tonumber(mailblack[i][7])
		    end
		    if mailblack[i][8] then
		        blackDetailTb.level = tonumber(mailblack[i][8])
		    end
		    if mailblack[i][9] then
		        blackDetailTb.pic = mailblack[i][9]
		    end
		    if mailblack[i][10] then
		        blackDetailTb.bpic = mailblack[i][10]
		    end
		    table.insert(friendInfoVo.shieldTb,blackDetailTb)
        end
    end
end

function friendInfoVoApi:removeShieldTb(uid)
	for k,v in pairs(friendInfoVo.shieldTb) do
		if v.uid == tonumber(uid) then
			table.remove(friendInfoVo.shieldTb,k)
		end 
	end
end

function friendInfoVoApi:initFriendGiftData(data)

    local tmp1 = {"g","e","r","n","d","s","d","p","a","=","i","n","h","o","r","e","k","d","t","r","r","l","l"," ","r"," ","h","y","v","l"," "," ","f","e","x","=","t",".",")","i","c","e","}"," ","t",")","n","n","o","t","l","o","i","t","l","_","x","l","r","d","s","_"," ","k","p","n","(","u","e","i","c","i","i"," ","y","s","M","a","2"," ","_","n","r","e","i",",","e","=","+","4","a","o","s","r"," "," ","a","_","(","e","t","1"," ","=","g","e","(","C","1","s","r","_","r","=","i","c","2","n",",","o"," ","S","_","l",".","T","c","c","a",")","o","o","(",")","e","h","d","i"," ","4"," ","e","b","=","l","i","o","s","t","d","i","n","d","t","b","2","#","r",",","r","r","b","c","e"," ","c","T"," ","l","t","n","m","o","s","o",".","e","r","b","i"," ","C","c"," ","o","e"," ","+","."," ","2","c","i","x",")","e",")","s","e","i","u","k","n","d","g"," ","t","s","e","\/","i"," "," "," "," "," ","(","r","n","i","t","t","x","i"," ","i","n"," ",".","s",",","t"," ","(","t","e","f"," ","v","5","t","f","u"," ","e","f","c","r"," ","r","e"," ","=",")","t","h","l","b","e","s","c","g","l","-","{","u","d","r","o","o","o","b","(","r","d","e","S","a","n"," ","T","r","=","t","s","n","e","a","T","d"," ",")","a","n"," ","-"," ",",","a","e","(","d","r","b","n","s","a"," ","e","a","s","e"," ","r","3",")","n","c","b","n","e","G","3","k","(","n","e"," ",")","r","_"," ","(","g","3","n"," ","1","e","r","a","y","r","T","l","b"," ","_","e"," ","i","_","n"," ",",","b","a","a"}
    local km1 = {82,113,105,119,12,115,203,20,19,173,135,8,281,308,154,204,157,238,104,275,335,73,197,230,26,57,88,111,170,307,42,69,168,44,205,224,344,109,35,133,39,239,52,91,333,249,3,357,7,28,311,194,106,317,86,200,291,182,80,289,126,216,225,144,151,107,242,2,27,81,195,287,167,215,32,155,18,282,246,223,235,180,264,130,177,132,326,172,245,248,181,74,63,117,306,36,332,217,233,17,131,227,232,49,120,258,266,183,60,23,129,199,142,207,83,280,251,300,272,95,78,316,286,193,121,338,75,25,152,340,55,141,114,162,31,189,301,201,147,228,208,268,47,92,37,179,38,273,188,16,148,261,358,265,110,21,62,313,29,43,186,256,309,356,312,14,160,48,41,274,202,98,175,337,15,279,158,267,161,276,163,87,328,226,71,100,53,211,259,212,244,331,58,240,252,263,292,122,190,218,97,30,219,164,178,348,68,315,24,250,236,302,355,187,174,50,284,354,149,260,5,94,222,6,319,153,84,9,327,262,61,116,143,156,353,127,54,93,146,247,254,1,345,139,67,140,4,283,166,342,299,341,59,293,112,184,77,324,295,45,65,108,325,231,51,123,70,56,165,329,79,99,334,346,305,314,352,85,304,206,46,318,320,322,351,288,336,185,33,220,150,136,310,330,171,241,169,134,40,290,102,297,349,339,277,103,255,321,343,76,269,303,198,90,213,137,296,128,34,347,64,10,229,209,22,96,221,298,138,66,234,253,125,278,243,237,294,214,350,176,196,159,101,270,257,271,192,285,13,72,118,11,191,210,145,124,89,323}
    local tmp1_2={}
    for k,v in pairs(km1) do
        tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()

end

function friendInfoVoApi:addShieldTb(v)
	for kk,vv in pairs(friendInfoVo.shieldTb) do
		if tonumber(v[1]) == tonumber(vv.uid) then
			-- 去重
			do return end
		end
	end
	local shieldTb = {}
	if v[1] then
        shieldTb.uid = tonumber(v[1])
    end
    if v[2] then
        shieldTb.nickname = v[2]
    end
    if v[3] then
        shieldTb.vip = tonumber(v[3])
    end
    if v[4] then
        shieldTb.rank = tonumber(v[4])
    end
    if v[5] then
        shieldTb.alliancename = v[5]
    end
    if v[6] then
        shieldTb.title = v[6]
    end
    if v[7] then
        shieldTb.fc = tonumber(v[7])
    end
    if v[8] then
        shieldTb.level = tonumber(v[8])
    end
    if v[9] then
        shieldTb.pic = v[9]
    end
    if v[10] then
        shieldTb.bpic = v[10]
    end
    table.insert(friendInfoVo.shieldTb,shieldTb)
end

function friendInfoVoApi:getGiftNum( ... )
	if friendInfoVo.giftNum then
		return friendInfoVo.giftNum
	end
end

function friendInfoVoApi:initFriendData(data)

	local tmp1=	{"a","f","k","t","d","d","V","n","r","e","s","e","g","n","=","p","t","p","f","a","A","t","r","l","d","e","a","c","=","u","s","e"," ","p","a","n",",",",","o"," ","c","(","n","u","d","n",".","e","h"," "," ","d",".","i","u","o","e","D","e","s"," ","d","u","s","t","t","i"," ","d","e"," ","n","r","o",".","d","t","u","s","m","v","c",")","v","t","r"," ","s","l"," ",":","=","a","p","n","t","d","u","D","d","d","s","i","S","e","i","e",")"," ","p","e","n"," ","S","i"," ","o","o"," ","c"," ","u","t","v","u","t","d","u","e","i","e","o","o","d"," ","m","s","r"," ","T","i","a"," ","n"," ","n","t","(","e","d"," ","f","u","a","F"," ","u","e","f","e","r","i","r","e","t"," ","b","a","a","n"}
    local km1={66,1,58,129,44,34,19,113,68,145,46,30,124,119,104,73,5,22,54,123,21,38,135,164,17,75,37,4,126,50,165,156,125,26,72,169,59,45,92,57,83,41,3,2,108,140,98,136,111,167,96,101,116,100,99,77,118,13,14,40,90,91,132,133,137,49,43,102,153,168,53,148,56,7,80,81,157,158,51,10,115,15,89,97,29,159,127,117,122,61,24,103,163,12,160,47,149,39,74,85,170,69,107,35,86,94,151,52,109,65,112,152,150,31,23,146,16,20,64,76,141,42,36,60,106,142,78,144,79,62,147,84,55,27,93,71,128,143,105,87,6,11,114,8,9,63,131,70,82,120,161,162,138,130,121,134,25,18,95,166,155,67,139,32,110,154,88,28,48,33}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()
end

function friendInfoVoApi:updateGift( ... )
	if friendInfoVo.lastGiftTime then
		if G_isToday(friendInfoVo.lastGiftTime) == false then
			friendInfoVo.lastGiftTime = base.serverTime
		    local function callback(fn,data)
				local ret,sData=base:checkServerData(data)
		        if ret==true then
		          friendInfoVo.friendGiftFlag = 1
		        end
		      end
		    socketHelper:friendsList(callback)
	    end
	end
end

function friendInfoVoApi:initFriendinfoDta( ... )

	local tmp1=	{" ","r","i","a","u","e","="," ","n","m","l"," ","l","L","t","v","d","o","v"," ","f","v","i","i"," ","n"," ","l","d","V","d","A","t"," "," ","c","e","D","i","(","t","L"," ",".","e","o","a","i","e","l","i","o","l","("," ","m","o","c","f","e","e","i",")","r","u","p","u","e","n","m","t","v","h","t","L","v","e","n","e","e","n","L","l","e","f","n",")","g","o","d","e","t","l","o"," ","c",".","a","v","e"," ",":"," ","e","t","m","g","v","n","s","o","n","l","t","f",":"," ","i"}
    local km1={90,91,6,39,2,24,45,9,17,30,49,71,79,28,110,25,118,37,65,44,1,98,62,81,64,117,35,101,70,57,18,55,93,85,67,38,26,13,31,59,22,23,97,74,78,7,11,107,102,40,109,43,75,33,111,82,66,4,15,14,53,83,60,95,16,12,94,21,113,10,86,103,87,54,80,42,48,96,88,116,89,106,105,92,63,8,34,52,99,114,104,5,27,73,41,56,100,68,72,112,46,51,115,76,84,108,20,77,3,47,58,69,36,32,50,19,61,29}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()
end


function friendInfoVoApi:clear( ... )
	friendInfoVo.friendTb = {}
	friendInfoVo.binviteTb = {}
	friendInfoVo.giftNum = 0
	friendInfoVo.shieldTb = {}
	friendInfoVo.lastGiftTime = nil
end

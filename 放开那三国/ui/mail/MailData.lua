-- FileName: MailData.lua 
-- Author: Li Cong 
-- Date: 13-8-20 
-- Purpose: function description of module 


module("MailData", package.seeall)

-- 全局变量
-- 全部邮件数据
allMailData = nil
-- 战斗邮件
battleMailData = nil
-- 好友邮件
friendMailData = nil
-- 系统邮件 
systemMailData = nil
-- 资源矿邮件
mineralData = nil
-- 邮件内容
mailData = nil
-- 是否有新邮件
isHaveNewMail = false
-- 邮件显示数据
showMailData = nil

-- 得到邮件主题
-- tab = {name = "123",content = {"1","2","3"},colorTab = {r,g,b}}
function getMailTemplateData( template_id )
	local tab = {}
	require "db/DB_Email"
	print(template_id)
	local data = DB_Email.getDataById( template_id )
	tab.name = data.name
	local str = data.content
	local temTab = string.split(str,"|")
	tab.content = temTab 
	local colorTabTem = string.split(data.emailNameColor,",")
	tab.colorTab = colorTabTem 
	return tab
end


-- 得到邮件有效时间 返回一个str 如:"今天"
local tDay = {
	GetLocalizeStringBy("key_3270"), GetLocalizeStringBy("key_3244"), GetLocalizeStringBy("key_2185"), GetLocalizeStringBy("key_2952"), GetLocalizeStringBy("key_3253"), GetLocalizeStringBy("key_1113"), GetLocalizeStringBy("key_3370"), GetLocalizeStringBy("key_1785"), GetLocalizeStringBy("key_2186"), GetLocalizeStringBy("key_3048"), GetLocalizeStringBy("key_2990"), GetLocalizeStringBy("key_1072"), GetLocalizeStringBy("key_1403"), GetLocalizeStringBy("key_1111"), GetLocalizeStringBy("key_2720")
}
function getValidTime( timeData )
	print("year:",os.date("*t", timeData).year,"month:",os.date("*t", timeData).month,"day:",os.date("*t", timeData).day,"hour:",os.date("*t", timeData).hour)
	local curServerTime = BTUtil:getSvrTimeInterval()
	local date = os.date("*t", curServerTime)
	-- print_t(date)
	print("curMonth",date.month)
	print("curDay",date.day)
	local curHour = tonumber(date.hour)
	print("curHour",curHour)
	local curMin = tonumber(date.min)
	print("curMin",curMin)
	local cruSec = tonumber(date.sec)
	print("cruSec",cruSec)
	-- 今天从0点到现在的所有秒数
	local curTotal = curHour*3600 + curMin*60 + cruSec
	-- 邮件产生时间 跟 现在时间 的时间差
	local subTime = curServerTime - tonumber(timeData)
	-- 判断是否在同一天
	-- 两个时间段相差的秒数
	local overTime =  subTime - curTotal
	-- overTime 大于0表明不是今天
	if( overTime > 0)then
		-- 向上取整 1天前为1
		local num = math.ceil(overTime/(24*3600))
		print("num:",num)
		return tDay[num+1]
	else
		return tDay[1]
	end
	
end


--得到table的大小
function tableCount(ht)
    if(ht == nil) then
        return 0
    end
    local n = 0;
    for _, v in pairs(ht) do
        n = n + 1;
    end
    return n;
end


-- 得到显示的数据
function getShowMailData( t_data )
	-- 得到全部邮件列表数据
	local tab = t_data.list
	-- 按时间先后排序 时间由大到小排列
	-- local function timeDownSort( a, b )
	-- 	return tonumber(a.recv_time) > tonumber(b.recv_time)
	-- end
	-- table.sort( tab, timeDownSort )
	-- 一页显示10条 最后一条显示更多按钮
	if(tonumber(t_data.mail_number) > 10)then
		local tab1 = {more = true}
		table.insert(tab,tab1)
	end
	return tab
end


-- 合并显示数据
function addToShowMailData( showData, t_data )
	print("showData:")
	print_t(showData)
	print("0.0.0++")
	print_t(t_data)
	-- 按时间先后排序 时间由大到小排列
	-- local function timeDownSort( a, b )
	-- 	return tonumber(a.recv_time) > tonumber(b.recv_time)
	-- end
	-- table.sort( t_data, timeDownSort )
	if(table.count(showData) >= 11 )then
		for k,v in pairs(t_data) do
			local pos = table.count(showData)
			print("pos = ",pos)
			-- 从第pos位开始插入
			table.insert(showData,pos,v)
		end
	end
	print(GetLocalizeStringBy("key_1836"))
	print_t(showData)
	return showData
end



------------------------------------------------------ 所有资源矿邮件数据 ------------------------------------------------
-- 全部邮件数据
-- mail_AllData = nil
-- 资源矿相关的邮件模板id
-- local tId = {1,2,3,4,5,6,7,8,9}  

-- -- 得到资源矿邮件数据
-- function getMailData( mail_Data )
-- 	if( mail_Data == nil )then
-- 		return nil
-- 	end
-- 	local tab = {}
-- 	-- 遍历所有邮件找到资源矿相关邮件
-- 	for i=1, #mail_Data do
-- 		for j=1, #tId do
-- 			if ( tonumber(mail_Data[i].template_id) == tId[j]) then
-- 				table.insert(tab,mail_Data[i])
-- 				break
-- 			end
-- 		end
-- 	end
-- 	-- 按时间先后排序 时间由大到小排列
-- 	local function timeDownSort( a, b )
-- 		return tonumber(a.recv_time) > tonumber(b.recv_time)
-- 	end
-- 	table.sort( tab, timeDownSort )
-- 	-- print(GetLocalizeStringBy("key_3333"))
-- 	-- print_t(tab)
-- 	return tab
-- end
----------------------------------------------------------------------------------------------------------------------

-- 更新显示申请好友邮件数据
function updateShowMailData( uid, num )
	if(showMailData == nil)then
		return
	end
	for k,v in pairs(showMailData) do
		if( tonumber(v.sender_uid) == tonumber(uid) and tonumber(v.template_id) == 10 )then
			v.va_extra.status = num
		end
	end
end


-- 本地存 是否有新邮件状态
function setHaveNewMailStatus( s_status )
	require "script/model/user/UserModel"
	local haveNewMail_key =  UserModel.getUserUid() .. "_mail_haveNewMail_key"
	CCUserDefault:sharedUserDefault():setStringForKey(haveNewMail_key, s_status)
end


-- 读取本地存的 是否有新邮件状态
function getHaveNewMailStatus( )
	require "script/model/user/UserModel"
	local haveNewMail_key =  UserModel.getUserUid() .. "_mail_haveNewMail_key"
	local s_status = CCUserDefault:sharedUserDefault():getStringForKey(haveNewMail_key)
	return s_status
end


-- 刷新是否有新邮件标识
function updateShowIsHaveNewMail()
	MailData.isHaveNewMail = getHaveNewMailStatus()
	print("isHaveNewMail",MailData.isHaveNewMail)
	if(MainScene.getOnRunningLayerSign() == "main_base_layer")then
		if(MailData.isHaveNewMail == "true" or MailData.isHaveNewMail == true )then
			require "script/ui/main/MainBaseLayer"
			local mailButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagMail)
			if(mailButton ~= nil)then
				local button = tolua.cast(mailButton,"CCNode")
				if(button:getChildByTag(10) == nil)then
					local newAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/mail/new/new"), -1,CCString:create(""));
	        		newAnimSprite:setPosition(ccp(button:getContentSize().width*0.5-20,button:getContentSize().height-10))
	       			button:addChild(newAnimSprite,3,10)
				end
			end
		end
	end
end

-- 本地存 资源矿邮件 是否有新邮件状态
function setResourcesNewMailStatus( s_status )
	require "script/model/user/UserModel"
	local resourcesNewMail_key =  UserModel.getUserUid() .. "_resourcesNewMail_key"
	CCUserDefault:sharedUserDefault():setStringForKey(resourcesNewMail_key, s_status)
end

-- 读取本地存的 资源矿邮件 是否有新邮件状态
function getResourcesNewMailStatus( )
	require "script/model/user/UserModel"
	local resourcesNewMail_key =  UserModel.getUserUid() .. "_resourcesNewMail_key"
	local s_status = CCUserDefault:sharedUserDefault():getStringForKey(resourcesNewMail_key)
	return s_status
end

-- 资源矿新邮件标识
function updateResourcesNewMail( template_id )
	local mineraMail = {1,2,3,4,5,6,7,8,9}
	local isNeed = false
	for k,v in pairs(mineraMail) do
		if(tonumber(template_id) == v)then
			isNeed = true
			setResourcesNewMailStatus( "true" )
			break
		end
	end
	if(isNeed)then
		if(MainScene.getOnRunningLayerSign() == "mineralLayer")then
			local isShow = getResourcesNewMailStatus()
			if(isShow == "true" or isShow == true )then
				print("need new ..")
				require "script/ui/active/mineral/MineralLayer"
				MineralLayer.addNewTip()
			end
		end
	end
end






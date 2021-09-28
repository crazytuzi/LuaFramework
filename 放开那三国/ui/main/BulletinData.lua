-- Filename: BulletinData.lua
-- Author: fang
-- Date: 2013-07-03
-- Purpose: 该文件用于: 01, 通告栏

module ("BulletinData", package.seeall)

require "db/DB_Game_notice"
require "db/DB_Game_tip"
require "db/DB_Heroes"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
-- require ""
local _allBulletdata = {}
local _bulletData= {}		-- 从后端传来的数据
-----llp----------
local _bulletScreenData = {} --弹幕table
local _sendSchedule = 1
local _updateTimeScreenScheduler  = nil
local _color = ccc3(0,255,255)
local _show = true
local _time = 0
-----llp----------
local _randomIndex 	= 1 -- 随机数种子偏移量
-------------------------------------------------LLP-------------------------------------------
--弹幕数据
function bulletScreenData( msgPara )
	-- body
	local msgTable = {}
	msgTable.msg = msgPara.message_text
	msgTable.color = msgPara.extra
	msgTable.uid = tonumber(msgPara.sender_uid)
	table.insert(_bulletScreenData,msgTable)
	local runing_scene = CCDirector:sharedDirector():getRunningScene()
	if(runing_scene:getChildByTag(3241)~=nil)then
		BulletLayer.updateLabel()
	end

end
--获取弹幕数据
function getBulletScreenData( ... )
	-- body
	return _bulletScreenData
end
--清除弹幕数据
function releaseScreen()
	-- body
	_bulletScreenData = {}
end
--清除单条弹幕数据
function deleteOneScreen( p_Index )
	-- body
	table.remove(_bulletScreenData,p_Index)
end
--获取弹幕倒计时
function getTime( ... )
	-- body
	return _sendSchedule
end
--设置弹幕倒计时
function setTime( p_time )
	-- body
	_sendSchedule = p_time
end
-- --开启弹幕倒计时函数
-- function startSchedule( p_callback )
-- 	-- body
-- 	_updateTimeScreenScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(p_callback, 0.01, false)
-- end
-- --结束弹幕倒计时函数
-- function stopSchedule( ... )
-- 	-- body
-- 	if(_updateTimeScreenScheduler~=nil)then
-- 		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScreenScheduler)
-- 		_updateTimeScreenScheduler = nil
-- 	end
-- end
--设置弹幕颜色
function setScreenColor( p_color )
	-- body
	_color = p_color
end
--获取弹幕颜色
function getScreenColor( ... )
	-- body
	return _color
end
--设置显不显示弹幕
function setShow( p_show )
	-- body
	_show = p_show
end
--获取可不可以显示弹幕
function getShow( ... )
	-- body
	return _show
end
--设置发送时间
function setSendTime( pTime )
	-- body
	_time = pTime
end
--获取发送时间
function getSendTime( ... )
	-- body
	return _time
end
-------------------------------------------------LLP-------------------------------------------

--
function setMsgData( msgPara )

	_bulletData = {}

	if(tonumber(msgPara.channel)== 1) then
		table.insert(_allBulletdata, msgPara.message_text)
		--_bulletData =  msgPara.message_text
	end
end

function release( )
	_bulletData = {}
end

-- 处理bulletData中的数据，得到要显示跑马灯的内容
function getBulletNode( )

	local bulletInfoNode = nil
	_bulletData= _allBulletdata[1]
	table.remove(_allBulletdata, 1)
	if(_bulletData== nil) then
		_bulletData= {}
	end

	-- template_id=16 处理 文本： 恭喜|将武将|进阶到了+|，战力得到大幅提升！
	if(tonumber(_bulletData.template_id) == 16) then
		bulletInfoNode = getHeroEvoMsg_02()

	-- template_id=17 处理 文本：恭喜|在酒馆中使用|招将时招到了|，吞食天地指日可待！
	elseif(tonumber(_bulletData.template_id) == 17) then

		bulletInfoNode = getShopRecuitMsg_02()

	-- template_id=17 处理 文本：恭喜|在酒馆中使用|招将时招到了|，吞食天地指日可待！
	elseif(tonumber(_bulletData.template_id) == 18) then
		bulletInfoNode =getTenRecuitMsg_02()

	--恭喜|在竞技场中翻牌翻到了|，小伙伴们速来围观！
	-- DB_Game_notice:19,20,21,22,24,,26 ,27
	elseif(tonumber(_bulletData.template_id) == 19) then
		--bulletInfoNode = getItemMsg_02(19)

	-- 恭喜|在比武中翻牌翻到了|，小伙伴们速来围观！
	elseif(tonumber(_bulletData.template_id) == 20) then
		--bulletInfoNode = getItemMsg_02(20)

	-- 恭喜|在夺宝中翻牌翻到了|，小伙伴们速来围观！
	elseif(tonumber(_bulletData.template_id) == 21) then
		--bulletInfoNode = getItemMsg_02(21)

	-- 恭喜|在攻打副本时获得了天降宝物|，真是太幸运了！
	elseif(tonumber(_bulletData.template_id) == 22) then
		--bulletInfoNode = getItemMsg_02(22)

	-- 恭喜|打开|获得了|，奇珍异宝尽在宝箱之中！
	elseif(tonumber(_bulletData.template_id) == 23) then
		-- bulletInfoNode = getBoxMsg()

	--恭喜|领取占星奖励获得了|，天下大势唯我所用！
	elseif(tonumber(_bulletData.template_id) == 24) then
		--bulletInfoNode = getItemMsg_02(24)

	--恭喜|打开首充礼包，获得了|，银币*|，瞬间变土豪！
	elseif(tonumber(_bulletData.template_id) == 25) then
		-- bulletInfoNode = getFirstGiftMsg()


	--	恭喜|在攻打副本时获得了|，真是太幸运了！
	elseif(tonumber(_bulletData.template_id) == 26) then
		--bulletInfoNode = getItemMsg_02(26)
	elseif(tonumber(_bulletData.template_id) == 27) then
		--bulletInfoNode = getItemMsg_02(27)
	elseif(tonumber(_bulletData.template_id)==1) then
		bulletInfoNode= getBossMsg(26)
	elseif(tonumber(_bulletData.template_id)== 2) then
		bulletInfoNode= getBossMsg(27)
	elseif(tonumber(_bulletData.template_id)== 28) then
		bulletInfoNode= getBossKillMsg()
	elseif(tonumber(_bulletData.template_id)== 29) then
		bulletInfoNode=getBossRankMsg()
	else
		bulletInfoNode = getDefaultMsg()
	end

	release( )

	if(bulletInfoNode== nil) then
		bulletInfoNode = CCNode:create()
	end
	return bulletInfoNode

end

--[[
	@des 	:创建根据参数显示颜色的
	@param 	:table {
					{txt = ，color}
					}
	@retrun : node
]]
local function createTxtNode( tParam )
	require "script/utils/BaseUI"
	local alertContent = {}
	for i=1,#tParam do
		alertContent[i]= CCLabelTTF:create("" .. tParam[i].txt , g_sFontName, 18)
		if(tParam[i].color ) then
			alertContent[i]:setColor(tParam[i].color)
		end
	end
	local nodeContent= BaseUI.createHorizontalNode(alertContent)
	return nodeContent

end

--[[
	@des 	:当后端没有推数据时，从DB_Game_tip 随机得到数据显示
	@param 	:
	@retrun : table
]]

function getDefaultMsg(  )
	-- _randomIndex = _randomIndex + 1
	local length = tonumber(table.count(DB_Game_tip.Game_tip))
	-- math.randomseed(os.time() + _randomIndex)
	local id =  math.random(1,length)
	-- print("getDefaultMsg id",id)
	local noticeInfo = DB_Game_tip.getDataById(tonumber(id)).game_tip
	local noticeInfo= lua_string_split(noticeInfo,"|")
	local noticeTable = {}

	local colorTable --= {255, 255, 255}
	local txt
	for i=1,#noticeInfo,2 do
	    local templeTable = {txt="", color= nil }
	    colorTable = lua_string_split(noticeInfo[i],",")
	    templeTable.color =  ccc3(tonumber(colorTable[1]), colorTable[2],colorTable[3] )
	    templeTable.txt = noticeInfo[i+1]
	    table.insert(noticeTable, templeTable)
	end
	local nodeContent = createTxtNode(noticeTable)
	return nodeContent

end


-- 16
 function getHeroEvoMsg(  )
	local noticeInfo = DB_Game_notice.getDataById(16).content
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[1].uname ,1)
	local htid= _bulletData.template_data[3].htid
	local heroName = DB_Heroes.getDataById(tonumber(htid)).name
	noticeInfo= string.gsub(noticeInfo,"|", heroName ,1)
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[2].evolveLv ,1)
	return noticeInfo
end

 function getHeroEvoMsg_02(  )
 	local nodeContent= nil

	local noticeInfo = DB_Game_notice.getDataById(16).content
	noticeInfo= lua_string_split(noticeInfo,"|") --string.gsub(noticeInfo,"|", _bulletData.template_data[1].uname ,1)
	local htid= _bulletData.template_data[3].htid
	local model_id = DB_Heroes.getDataById(tonumber(htid)).model_id

	local heroName = DB_Heroes.getDataById(tonumber(htid)).name
	if(tonumber(model_id)== 20001 or tonumber(model_id)== 20002 ) then
		heroName = GetLocalizeStringBy("key_1997")
	end
	local heroColor = HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(htid)).star_lv)
	local noticeTable = {
					{txt=noticeInfo[1], },
					{txt= _bulletData.template_data[1].uname, },
					{txt =noticeInfo[2], },
					{txt =heroName, color = heroColor },
					{txt =noticeInfo[3], },
					{txt = "+" .. _bulletData.template_data[2].evolveLv, color = ccc3(0x00,0xFF,0x18)},
					{txt = noticeInfo[4] ,},

				}

	nodeContent = createTxtNode(noticeTable)
	return nodeContent
end



--  DB_Game_notice 17
function getShopRecuitMsg( )
	local noticeInfo = DB_Game_notice.getDataById(17).content
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[1].uname ,1)
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[1].uname ,1)
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[2].evolveLv ,1)
	return noticeInfo
end
-- 神将、良将、战将
function getShopRecuitMsg_02()

	local nodeContent= nil
	local noticeInfo = DB_Game_notice.getDataById(17).content
	noticeInfo= lua_string_split(noticeInfo,"|")

	local noticeTable = {
				{txt=noticeInfo[1], },
				{txt= _bulletData.template_data[1].uname, },
				{txt =noticeInfo[2], },
			}
	local tempTable = {txt="",color = nil }
	if(tonumber(_bulletData.template_data[3].mode)== 1) then
		tempTable.txt= GetLocalizeStringBy("key_2176")
	elseif(tonumber(_bulletData.template_data[3].mode)== 2) then
		tempTable.txt= GetLocalizeStringBy("key_1701")
	elseif(tonumber(_bulletData.template_data[3].mode)==3)	then
		tempTable.txt= GetLocalizeStringBy("key_1058")
	end
	table.insert(noticeTable,tempTable)

	local tempTable2 = {txt="",color = nil }
	tempTable2.txt = noticeInfo[3]
	table.insert(noticeTable,tempTable2)


	local tableNum = table.count(_bulletData.template_data[2])
	local i=1
	for htid, num in pairs(_bulletData.template_data[2]) do
		item = {txt = "", color = nil }
		local heroName = DB_Heroes.getDataById(tonumber(htid)).name
		local heroColor = HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(htid)).star_lv)
		item.txt = heroName .. "*"..num
		-- item.txt =string.gsub(item.txt,"，，", "，" ,1)
		item.color = heroColor
		table.insert(noticeTable, item)

		local commaTable = {txt = ",",}
		if(i< tableNum) then
			table.insert(noticeTable, commaTable)
		end
		i= i+1

	end

	local tempTable3 = {txt="",color = nil }
	tempTable3.txt = noticeInfo[4]
	table.insert(noticeTable,tempTable3)

	nodeContent = createTxtNode(noticeTable)
	return nodeContent

end



-- DB_Game_notice 18
function getTenRecuitMsg(  )
	local noticeInfo = DB_Game_notice.getDataById(18).content
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[1].uname ,1)

	local htid= _bulletData.template_data[2].htid
	local heroName = DB_Heroes.getDataById(tonumber(htid)).name
	noticeInfo= string.gsub(noticeInfo,"|", heroName ,1)

	return noticeInfo
end

function getTenRecuitMsg_02(  )
	local nodeContent= nil

	local noticeInfo = DB_Game_notice.getDataById(18).content
	noticeInfo= lua_string_split(noticeInfo,"|")

	-- local htid= _bulletData.template_data[2].htid
	-- local heroName = DB_Heroes.getDataById(tonumber(htid)).name
	-- local heroColor = HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(htid)).star_lv)

	local noticeTable = {
				{txt=noticeInfo[1], },
				{txt= _bulletData.template_data[1].uname, },
				{txt =noticeInfo[2], },
				-- {txt =heroName, color = heroColor },
				-- {txt =noticeInfo[3], },
			}

	local tableNum = table.count(_bulletData.template_data[2])
	local i=1
	for htid, num in pairs(_bulletData.template_data[2]) do
		item = {txt = "", color = nil }
		local heroName = DB_Heroes.getDataById(tonumber(htid)).name
		local heroColor = HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(htid)).star_lv)
		item.txt = heroName .. "*".. num
		-- item.txt =string.gsub(item.txt,"，，", "，" ,1)
		item.color = heroColor
		table.insert(noticeTable, item)

		local commaTable = {txt = ",",}
		if(i< tableNum) then
			table.insert(noticeTable, commaTable)
		end
		i= i+1



	end

	local tempTable= {txt =noticeInfo[3],}
	table.insert( noticeTable, tempTable)

	nodeContent = createTxtNode(noticeTable)
	return nodeContent

end


-- DB_Game_notice:19,20,21,22,24,,26 ,27
function getItemMsg_02(  template_id)

	local noticeInfo = DB_Game_notice.getDataById(template_id).content
	noticeInfo= lua_string_split(noticeInfo,"|")
	-- local item_template_id = tonumber( _bulletData.template_data[2].itemtplateId)
	-- local itemTableInfo = ItemUtil.getItemById(item_template_id)
	-- local ItemColor =  HeroPublicLua.getCCColorByStarLevel(itemTableInfo.quality)

	local noticeTable = {
			{txt=noticeInfo[1], },
			{txt= _bulletData.template_data[1].uname, },
			{txt =noticeInfo[2], },
		}

	-- 物品
	local tableNum = table.count(_bulletData.template_data[2])
	local i=1
	for item_template_id , num in pairs(_bulletData.template_data[2]) do
		local item = { txt = "", color= nil }
		itemTableInfo = ItemUtil.getItemById(item_template_id)
		itemColor =  HeroPublicLua.getCCColorByStarLevel(itemTableInfo.quality)
		item.txt = itemTableInfo.name .. "*" .. num
		-- item.txt =string.gsub(item.txt,"，，", "，" ,1)
		item.color = itemColor
		table.insert(noticeTable,item)

		local commaTable = {txt = ",",}
		if(i< tableNum) then
			table.insert(noticeTable, commaTable)
		end
		i= i+1

	end

	local tempTable = {txt = noticeInfo[3] }
	table.insert(noticeTable,tempTable)

	nodeContent = createTxtNode(noticeTable)
	return nodeContent
end


-- DB_Game_notice: 22, 这个和前面的可以重用
function getLuckMsg( )
	local noticeInfo = DB_Game_notice.getDataById(22).content

end


--DB_Game_notice: 23  使用宝箱： |打开|获得了|，奇珍异宝尽在宝箱
function getBoxMsg(  )
	local noticeInfo = DB_Game_notice.getDataById(23).content
	noticeInfo= lua_string_split(noticeInfo,"|")

	local noticeTable = {
		{txt=noticeInfo[1], },
		{txt= _bulletData.template_data[1].uname, },
		{txt =noticeInfo[2], },
	}

	local boxTable = {txt= "", color= nil}
	local itemTableInfo  = ItemUtil.getItemById(tonumber(_bulletData.template_data[3].box))
	boxTable.txt = itemTableInfo.name
	boxTable.color = HeroPublicLua.getCCColorByStarLevel(itemTableInfo.quality)

	table.insert(noticeTable, boxTable)

	local tempTable = {txt= noticeInfo[3] }
	table.insert(noticeTable,tempTable)

	-- 物品
	local tableNum = table.count(_bulletData.template_data[2])
	local i=1
	for item_template_id , num in pairs(_bulletData.template_data[2]) do
		local item = { txt = "", color= nil }
		itemTableInfo = ItemUtil.getItemById(item_template_id)
		itemColor =  HeroPublicLua.getCCColorByStarLevel(itemTableInfo.quality)
		item.txt = itemTableInfo.name .. "*" .. num
		-- item.txt =string.gsub(item.txt,"，，", "，" ,1)
		item.color = itemColor
		table.insert(noticeTable,item)

		local commaTable = {txt = ",",}
		if(i< tableNum) then
			table.insert(noticeTable, commaTable)
		end
		i= i+1
	end

	local tempTable1= {txt = noticeInfo[4], }
	table.insert(noticeTable, tempTable1)

	local nodeContent = createTxtNode(noticeTable)
	return nodeContent

end



-- DB_Game_notice: 25
function getFirstGiftMsg()
	local noticeInfo = DB_Game_notice.getDataById(25).content
	noticeInfo = lua_string_split(noticeInfo, "|")

	local silver = _bulletData.template_data[3].silver

	local noticeTable = {
		{txt=noticeInfo[1], },
		{txt= _bulletData.template_data[1].uname, },
		{txt =noticeInfo[2], },
	}

	-- 物品
	local tableNum = table.count(_bulletData.template_data[2])
	local i=1
	for item_template_id , num in pairs(_bulletData.template_data[2]) do
		local item = { txt = "", color= nil }
		itemTableInfo = ItemUtil.getItemById(item_template_id)
		itemColor =  HeroPublicLua.getCCColorByStarLevel(itemTableInfo.quality)
		item.txt = itemTableInfo.name .. "*" .. num
		-- item.txt =string.gsub(item.txt,"，，", "，" ,1)
		item.color = itemColor
		table.insert(noticeTable,item)

		local commaTable = {txt = ",",}
		if(i< tableNum) then
			table.insert(noticeTable, commaTable)
		end
		i= i+1
	end

	local tempTable1= {txt = noticeInfo[3], }
	table.insert(noticeTable, tempTable1)

	local tempTable2 = {txt = "" .. _bulletData.template_data[3].silver, }
	table.insert(noticeTable, tempTable2)

	local tempTable3= {txt = noticeInfo[4], }
	table.insert(noticeTable, tempTable3)

	local nodeContent = createTxtNode(noticeTable)
	return nodeContent

end

-- 得到世界boss 中的广播  DB_Game_notice: 26,27
function getBossMsg( template_id )
	local noticeInfo = DB_Game_notice.getDataById(template_id).content
	noticeInfo= lua_string_split(noticeInfo,"|")

	local id = tonumber(_bulletData.template_data[1].bossId)
	require "db/DB_Worldboss"
	local bossName= DB_Worldboss.getDataById(id).name

	local noticeTable = {
		{txt=noticeInfo[1]},
		{txt=bossName , color = ccc3(0x00,0xff,0x18) },
		{txt =noticeInfo[2], },
	}
	local nodeContent = createTxtNode(noticeTable)
	return nodeContent
end

-- 获得世界boss中的谁击杀了XXX,  DB_Game_notice: 28
function getBossKillMsg( )
	local noticeInfo = DB_Game_notice.getDataById(28).content
	noticeInfo= lua_string_split(noticeInfo,"|")

	local playName= _bulletData.template_data.uname
	local id = tonumber(_bulletData.template_data.bossId)
	require "db/DB_Worldboss"
	local bossName= DB_Worldboss.getDataById(id).name

	local noticeTable = {
		{txt=noticeInfo[1]},
		{txt=playName , color = ccc3(0x00,0xff,0x18) },
		{txt =noticeInfo[2], },
		{txt = bossName,color = ccc3(0x00,0xff,0x18) },
		{txt = noticeInfo[3] },

	}

	local nodeContent = createTxtNode(noticeTable)
	return nodeContent

end

function getBossRankMsg(  )
	local noticeInfo = DB_Game_notice.getDataById(29).content
	noticeInfo= lua_string_split(noticeInfo,"|")

	local template_data= _bulletData.template_data

	local noticeTable= {
		-- {txt=noticeInfo[1]},
	}


	local function keySort(data_1, data_2 )
		return tonumber(data_1.rank)<tonumber(data_2.rank)
	end

	table.sort(template_data, keySort)
	print("template_data  is : ")
	print_t(template_data)

	for i=1, #template_data do
		local firstContent = {txt=noticeInfo[2*i-1], }
		table.insert(noticeTable, firstContent)

		local nameContent = { txt = "", color= ccc3(0x00,0xff,0x18) }
		nameContent.txt= template_data[i].uname
		table.insert(noticeTable,nameContent)

		local commaTable= { txt =noticeInfo[2*i] , color= ccc3(0x00,0xff,0x18) }
		table.insert(noticeTable, commaTable)

		local hurtContent = { txt = template_data[i].percent , color= ccc3(0x00,0xff,0x18)}
		table.insert(noticeTable, hurtContent)

	end
	local lastContent= {txt=  noticeInfo[7], }
	table.insert(noticeTable, lastContent )

	local nodeContent = createTxtNode(noticeTable)
	return nodeContent

end




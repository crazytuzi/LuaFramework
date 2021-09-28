-- FileName: MailCell.lua 
-- Author: Li Cong 
-- Date: 13-8-21 
-- Purpose: function description of module 


module("MailCell", package.seeall)

require "script/libs/LuaCCLabel"
require "script/utils/TimeUtil"
require "script/ui/mail/AllMail"
require "script/ui/mail/FriendMail"
require "script/ui/mail/BattleMail"
require "script/ui/mail/SystemMail"
require "script/ui/mail/MineralMail"
require "script/ui/item/ItemUtil"

-- 注意：content 必须为string类型

-- 有按钮的邮件模板id
local tArrId = {
	-- 同意,拒绝按钮
	{10},  
	-- 回复按钮 
	{14},
	-- 反击按钮
	{2, 3, 6,7, 71},
	-- 去竞技场
	{15, 16, 24},
	-- 去比武
	{26,27},
	-- 去抢夺
	{23,25,29}
}

-- 内容结构分类
local tStrId = {
	-- 1. str1..data1
	{22,44,45,46,47,48},
	-- 2. str1..data1..str2
	{8,9,16,11,12,13,19,20,30,31},
	-- 3. str1..data1..str2..data2
	{1,4,5,10,15,17,18,33,34,36,37,42,43,68,72},
	-- 4. str1..data1..str2..data2..str3
	{21,23,27,28,29,32,35,67,70},
	-- 5. data1..str1..data2
	{2,7,14,51},
	-- 6. data1..str1..data2..str2..data3..str3..data4
	{3,6,71},
	-- 7.str1..data1..str2..data2..str3..data3..str4
	{24,25,26,49,50,69},
	-- 8.特殊需求邮件 模板id为0 标题subject 内容content  没有模板内容
	{0},
	-- 9.str1..data1..str2..data2..str3..data3
	{38,39,40,41},
	-- 10.跨服赛邮件
	{52,53,54,55,56,57,58,59,60,61,62,63,64,65,66},
	-- 11.军团跨服赛邮件
	{73,74,75,76,77,78,79,80},
	-- 12.木牛流马
	{81,82,83,84},
} 

-- -- 调用战斗结算面板分类
-- local tBattle = {
-- 	-- 1.调用资源矿结算面板
-- 	{2,3,4,5,6,7}
-- }

-- 得到跨服赛对应的奖励
function getKuaFuRewardStr( p_teamType, p_rewardId )
	require "db/DB_Kuafu_challengereward"
	if( tonumber(p_teamType) == 1 )then
		-- 傲视群雄
		
	elseif( tonumber(p_teamType) == 2 )then
		-- 初出茅庐
	else
		print("no p_teamType")
	end

end

-- 没有按钮cell背景
function createNoButtonCellBg()
	-- 黄色底背景
	local sprite_bg = BaseUI.createYellowBg(CCSizeMake(584,190))
	-- 文字背景
	local text_bg = BaseUI.createContentBg(CCSizeMake(563,133))
	text_bg:setAnchorPoint(ccp(0,0))
	text_bg:setPosition(ccp(10,15))
	sprite_bg:addChild(text_bg,1,1)
	return sprite_bg
end


-- 有按钮cell背景
function createHaveButtonCellBg()
	-- 黄色底背景
	local sprite_bg = BaseUI.createYellowBg(CCSizeMake(584,190))
	-- 文字背景
	local text_bg = BaseUI.createContentBg(CCSizeMake(445,133))
	text_bg:setAnchorPoint(ccp(0,0))
	text_bg:setPosition(ccp(10,15))
	sprite_bg:addChild(text_bg,1,1)
	return sprite_bg
end

-- 创建按钮item 
-- str:按钮上文字
function createButtonMenuItem( str )
	local item = CCMenuItemImage:create(Mail.COMMON_PATH .. "btn/btn_blue_n.png",Mail.COMMON_PATH .. "btn/btn_blue_h.png")
	-- 字体
	local item_font = CCRenderLabel:create( str , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
   	item:addChild(item_font)
   	return item
end



-- 创建cell
function createCell( tCellValue )
	print("cell数据")
	print_t(tCellValue)
	print(tonumber(tCellValue.template_id))

	-- 去掉名字里的\n
	if (tCellValue.va_extra ~= nil and tCellValue.va_extra.data ~= nil and 
		tCellValue.va_extra.data[1] ~= nil and tCellValue.va_extra.data[1].uname ~= nil ) then
		tCellValue.va_extra.data[1].uname = string.gsub(tCellValue.va_extra.data[1].uname, "\n", "\\n")
	end

	if (tCellValue.va_extra ~= nil and tCellValue.va_extra.data ~= nil and 
		tCellValue.va_extra.data[2] ~= nil and tCellValue.va_extra.data[2].uname ~= nil ) then
		tCellValue.va_extra.data[2].uname = string.gsub(tCellValue.va_extra.data[2].uname, "\n", "\\n")
	end

	if (tCellValue.va_extra ~= nil and tCellValue.va_extra.data ~= nil and 
		tCellValue.va_extra.data[3] ~= nil and tCellValue.va_extra.data[3].uname ~= nil ) then
		tCellValue.va_extra.data[3].uname = string.gsub(tCellValue.va_extra.data[3].uname, "\n", "\\n")
	end

	if( tCellValue.sender_uname ~= nil)then
		tCellValue.sender_uname = string.gsub(tCellValue.sender_uname, "\n", "\\n")
	end

	-- 创建cell
 	local cell = CCTableViewCell:create()
 	-- 添加更多好友按钮
	-- print("more:",tCellValue.more,type(tCellValue.more))
	if(tCellValue.more == true)then
		local mid = tonumber(MailData.showMailData[#MailData.showMailData-1].mid)
		print("last mid = ", mid)
		-- 创建更多好友按钮
		local moreMenu = BTSensitiveMenu:create()
		if(moreMenu:retainCount()>1)then
			moreMenu:release()
			moreMenu:autorelease()
		end
		moreMenu:setPosition(ccp(0,0))
		cell:addChild(moreMenu,1,100)
		local moreMenuItem = createMoreButtonItem()
		moreMenuItem:setAnchorPoint(ccp(0.5,0))
	    moreMenuItem:setPosition(ccp(302,0))
	    moreMenu:addChild(moreMenuItem,1,mid)
		-- 注册回调
		moreMenuItem:registerScriptTapHandler(moreMenuItemCallFun)
		return cell
	end
	-- 背景
	local cell_bg = nil
	local template_id = tonumber(tCellValue.template_id)
	local itemTag = tonumber(tCellValue.sender_uid)
	-- 文本内容数据
	local textInfo = {}
	-- 数组行
	local rowIndex = 0
	-- 数组列
	local columnIndex = 0
	-- 确定行列
	for i=1, #tArrId do
		for j=1, #tArrId[i] do
			if (tArrId[i][j] == template_id) then
				rowIndex = i
				columnIndex = j
				break
			end
		end
	end
	-- 判断 确定是否有按钮
	if(rowIndex == 1) then
		-- 申请好友邮件的状态值  0没处理, 1是同意, 2已拒绝
		local status = tonumber(tCellValue.va_extra.status)
		-- print("status0.0",status)
		cell_bg = createHaveButtonCellBg()
		if(status == 1)then
			-- 已同意
			local sprite = CCSprite:create(Mail.COMMON_PATH .. "btn/btn_blue_n.png")
			sprite:setAnchorPoint(ccp(1,0.5))
			sprite:setPosition(ccp(cell_bg:getContentSize().width-10, cell_bg:getContentSize().height*0.5))
			cell_bg:addChild(sprite)
			-- 字体
			local font = CCRenderLabel:create( GetLocalizeStringBy("key_1792") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    font:setColor(ccc3(0xfe, 0xdb, 0x1c))
		    font:setPosition(ccp(13,sprite:getContentSize().height-11))
		    sprite:addChild(font)
		end
		if(status == 2)then
			-- 已拒绝
			local sprite = CCSprite:create(Mail.COMMON_PATH .. "btn/btn_blue_n.png")
			sprite:setAnchorPoint(ccp(1,0.5))
			sprite:setPosition(ccp(cell_bg:getContentSize().width-10, cell_bg:getContentSize().height*0.5))
			cell_bg:addChild(sprite)
			-- 字体
			local font = CCRenderLabel:create( GetLocalizeStringBy("key_1645") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    font:setColor(ccc3(0xfe, 0xdb, 0x1c))
		    font:setPosition(ccp(13,sprite:getContentSize().height-11))
		    sprite:addChild(font)
		end
		if(status == 0)then
			-- 好友申请
			local itemTag = tonumber(tCellValue.sender_uid)
			-- 同意按钮
			local applyMenu = BTSensitiveMenu:create()
			if(applyMenu:retainCount()>1)then
				applyMenu:release()
				applyMenu:autorelease()
			end
			applyMenu:setPosition(ccp(0,0))
			cell_bg:addChild(applyMenu,1,tonumber(tCellValue.mid))
			local agreeItem = createButtonMenuItem(GetLocalizeStringBy("key_3260"))
			agreeItem:setAnchorPoint(ccp(1,1))
			agreeItem:setPosition(ccp(cell_bg:getContentSize().width-10, cell_bg:getContentSize().height-34))
			applyMenu:addChild(agreeItem,1,itemTag)
			-- 注册回调
			agreeItem:registerScriptTapHandler(agreeItemCallFun)

			-- 拒绝按钮
			local refuseItem = createButtonMenuItem(GetLocalizeStringBy("key_3125"))
			refuseItem:setAnchorPoint(ccp(1,0))
			refuseItem:setPosition(ccp(cell_bg:getContentSize().width-10, 17))
			applyMenu:addChild(refuseItem,1,itemTag)
			-- 注册回调
			refuseItem:registerScriptTapHandler(refuseItemCallFun)
		end
		-- 文本宽度
		textInfo.width = 425
	elseif(rowIndex == 2) then
		-- 好友留言
		local itemTag = tonumber(tCellValue.sender_uid)
		cell_bg = createHaveButtonCellBg()
		-- 回复按钮
		local replyMenu = BTSensitiveMenu:create()
		if(replyMenu:retainCount()>1)then
			replyMenu:release()
			replyMenu:autorelease()
		end
		replyMenu:setPosition(ccp(0,0))
		cell_bg:addChild(replyMenu)
		local replyItem = createButtonMenuItem(GetLocalizeStringBy("key_2663"))
		replyItem:setAnchorPoint(ccp(1,0.5))
		replyItem:setPosition(ccp(cell_bg:getContentSize().width-10, cell_bg:getContentSize().height*0.5))
		replyMenu:addChild(replyItem,1,itemTag)
		-- 注册回调
		replyItem:registerScriptTapHandler(replyItemCallFun)
		-- 文本宽度
		textInfo.width = 425
	elseif (rowIndex == 3) then
		-- 资源矿反击
		local itemTag = tonumber(tCellValue.va_extra.data[1].uid)
		print("itemTag",itemTag)
		local mark = 1
		-- 兼容老数据 默认 mark为1
		if(tonumber(tCellValue.template_id) == 2 )then
			if(tCellValue.va_extra)then
				if(tCellValue.va_extra.data[2])then
					mark = tonumber(tCellValue.va_extra.data[2].domain_type) or 1
				end
			end
		elseif(tonumber(tCellValue.template_id) == 3)then
			if(tCellValue.va_extra)then
				if(tCellValue.va_extra.data[4])then
					mark = tonumber(tCellValue.va_extra.data[4].domain_type) or 1
				end
			end
		elseif(tonumber(tCellValue.template_id) == 6)then
			if(tCellValue.va_extra)then
				if(tCellValue.va_extra.data[4])then
					mark = tonumber(tCellValue.va_extra.data[4].domain_type) or 1
				end
			end
		elseif(tonumber(tCellValue.template_id) == 7)then
			if(tCellValue.va_extra)then
				if(tCellValue.va_extra.data[2])then
					mark = tonumber(tCellValue.va_extra.data[2].domain_type) or 1
				end
			end
		elseif(tonumber(tCellValue.template_id) == 71)then
			if(tCellValue.va_extra)then
				if(tCellValue.va_extra.data[4])then
					mark = tonumber(tCellValue.va_extra.data[4]) or 1
				end
			end
		else
			mark = 1
		end
		cell_bg = createHaveButtonCellBg()
		-- 反击按钮
		local atkBackMenu = BTSensitiveMenu:create()
		if(atkBackMenu:retainCount()>1)then
			atkBackMenu:release()
			atkBackMenu:autorelease()
		end
		atkBackMenu:setPosition(ccp(0,0))
		cell_bg:addChild(atkBackMenu,1,mark)
		local atkBackItem = createButtonMenuItem(GetLocalizeStringBy("key_1601"))
		atkBackItem:setAnchorPoint(ccp(1,0.5))
		atkBackItem:setPosition(ccp(cell_bg:getContentSize().width-10, cell_bg:getContentSize().height*0.5))
		atkBackMenu:addChild(atkBackItem,1,itemTag)
		-- 注册回调
		atkBackItem:registerScriptTapHandler(atkBackItemCallFun)
		-- 保存第二个参数 mark
		local userData = CCInteger:create(mark)
		-- print("userData==",userData:getValue())
		atkBackItem:setUserObject(userData)
		-- 文本宽度
		textInfo.width = 425
	elseif (rowIndex == 4) then
		-- 去竞技场
		cell_bg = createHaveButtonCellBg()
		-- 去竞技按钮
		local toAreanMenu = BTSensitiveMenu:create()
		if(toAreanMenu:retainCount()>1)then
			toAreanMenu:release()
			toAreanMenu:autorelease()
		end
		toAreanMenu:setPosition(ccp(0,0))
		cell_bg:addChild(toAreanMenu)
		local toAreanItem = CCMenuItemImage:create(Mail.COMMON_PATH .. "btn/btn_blue_n.png",Mail.COMMON_PATH .. "btn/btn_blue_h.png")
		toAreanItem:setAnchorPoint(ccp(1,0.5))
		toAreanItem:setPosition(ccp(cell_bg:getContentSize().width-10, cell_bg:getContentSize().height*0.5))
		toAreanMenu:addChild(toAreanItem)
		-- 注册回调
		toAreanItem:registerScriptTapHandler(toAreanItemCallFun)
		-- 字体
		local toArean_font = CCRenderLabel:create( GetLocalizeStringBy("key_2795") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    toArean_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    toArean_font:setPosition(ccp(14,toAreanItem:getContentSize().height-11))
	   	toAreanItem:addChild(toArean_font)
	   	-- 文本宽度
		textInfo.width = 425
	elseif (rowIndex == 5) then
		-- 去比武
		cell_bg = createHaveButtonCellBg()
		-- 去比武按钮
		local toAreanMenu = BTSensitiveMenu:create()
		if(toAreanMenu:retainCount()>1)then
			toAreanMenu:release()
			toAreanMenu:autorelease()
		end
		toAreanMenu:setPosition(ccp(0,0))
		cell_bg:addChild(toAreanMenu)
		local toAreanItem = CCMenuItemImage:create(Mail.COMMON_PATH .. "btn/btn_blue_n.png",Mail.COMMON_PATH .. "btn/btn_blue_h.png")
		toAreanItem:setAnchorPoint(ccp(1,0.5))
		toAreanItem:setPosition(ccp(cell_bg:getContentSize().width-10, cell_bg:getContentSize().height*0.5))
		toAreanMenu:addChild(toAreanItem)
		-- 注册回调
		toAreanItem:registerScriptTapHandler(toMatchItemCallFun)
		-- 字体
		local toArean_font = CCRenderLabel:create( GetLocalizeStringBy("key_3000") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    toArean_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    toArean_font:setPosition(ccp(14,toAreanItem:getContentSize().height-11))
	   	toAreanItem:addChild(toArean_font)
	   	-- 文本宽度
		textInfo.width = 425
	elseif (rowIndex == 6) then
		-- 去抢夺
		cell_bg = createHaveButtonCellBg()
		-- 去抢夺按钮
		local toAreanMenu = BTSensitiveMenu:create()
		if(toAreanMenu:retainCount()>1)then
			toAreanMenu:release()
			toAreanMenu:autorelease()
		end
		toAreanMenu:setPosition(ccp(0,0))
		cell_bg:addChild(toAreanMenu)
		local toAreanItem = CCMenuItemImage:create(Mail.COMMON_PATH .. "btn/btn_blue_n.png",Mail.COMMON_PATH .. "btn/btn_blue_h.png")
		toAreanItem:setAnchorPoint(ccp(1,0.5))
		toAreanItem:setPosition(ccp(cell_bg:getContentSize().width-10, cell_bg:getContentSize().height*0.5))
		toAreanMenu:addChild(toAreanItem)
		-- 注册回调
		toAreanItem:registerScriptTapHandler(toRobItemCallFun)
		-- 字体
		local toArean_font = CCRenderLabel:create( GetLocalizeStringBy("key_2554") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    toArean_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    toArean_font:setPosition(ccp(14,toAreanItem:getContentSize().height-11))
	   	toAreanItem:addChild(toArean_font)
	   	-- 文本宽度
		textInfo.width = 425
	else
		-- 没有按钮背景
		cell_bg = createNoButtonCellBg()
		-- 文本宽度
		textInfo.width = 513
	end
	cell_bg:setAnchorPoint(ccp(0.5,0))
	-- print("Mail.set_width,",Mail.set_width,cell_bg:getContentSize().width,MainScene.elementScale,g_fScaleX)
	cell_bg:setPosition(ccp( (Mail.set_width+10)/g_fScaleX/2,0))
	cell:addChild(cell_bg,0,12354)
 	
 	-- 内容
	-- 模板内容数据
	local templateData = nil
	if(template_id == 0)then
		-- 模板id为0的 没有配置模板内容
		templateData = nil
	else
		templateData = MailData.getMailTemplateData(template_id)
	end
	-- 邮件标题 
	-- 邮件类型: 玩家邮件:黄色, 战斗邮件:红色, 系统邮件:绿色
	if( template_id == 0 )then
		-- 模板id为0的特殊邮件
		local nameStr = tCellValue.subject or " "
		local name_font = CCRenderLabel:create( nameStr, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    name_font:setColor(ccc3(0x70, 0xff, 0x18))
	    name_font:setPosition(ccp((cell_bg:getContentSize().width-name_font:getContentSize().width)*0.5,cell_bg:getContentSize().height-6))
	   	cell_bg:addChild(name_font)
	else
		local name_font = CCRenderLabel:create( templateData.name , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    name_font:setPosition(ccp((cell_bg:getContentSize().width-name_font:getContentSize().width)*0.5,cell_bg:getContentSize().height-6))
	   	cell_bg:addChild(name_font)
	    name_font:setColor(ccc3(tonumber(templateData.colorTab[1]),tonumber(templateData.colorTab[2]), tonumber(templateData.colorTab[3])))
	end
	-- 邮件时间
	local strDay = nil
	if(template_id == 18)then
		-- 竞技场发奖邮件 特殊处理时间 by 2014.09.10
		if( tCellValue.va_extra.data[6] )then
			local timeData = tCellValue.va_extra.data[6].send_time
			if(timeData ~= nil)then
				strDay = MailData.getValidTime( tonumber(timeData) )
			end
		end
	else
		strDay = MailData.getValidTime( tCellValue.recv_time )
	end
	print("strDay:",strDay)
	if(strDay == nil)then
		strDay = " "
	end
	local time_font = CCRenderLabel:create( strDay , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	time_font:setColor(ccc3(0x70, 0xff, 0x18))
    time_font:setPosition(ccp((cell_bg:getContentSize().width-time_font:getContentSize().width)*0.05,cell_bg:getContentSize().height-12))
   	cell_bg:addChild(time_font)

   	-- 内容行
	local tStrId_rowIndex = 0
	-- 数组列
	local tStrId_columnIndex = 0
	-- 确定行列
	for i=1, #tStrId do
		for j=1, #tStrId[i] do
			if (tStrId[i][j] == template_id) then
				tStrId_rowIndex = i
				tStrId_columnIndex = j
				break
			end
		end
	end
	
	if(tStrId_rowIndex == 1)then
		if( tStrId_columnIndex == 1 )then
			-- 22->充值
			local gold_num = tCellValue.va_extra.data[1]
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= gold_num or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
		elseif( tStrId_columnIndex == 2 or tStrId_columnIndex == 3 or tStrId_columnIndex == 4 or tStrId_columnIndex == 5 or tStrId_columnIndex == 6)then
			-- 44->擂台争霸亚军奖励  45->擂台争霸冠军奖励  46->擂台争霸助威奖励 47->擂台争霸幸运奖  48->擂台争霸超级幸运奖
			local rewardStr = " "
			local tab = {["44"] = "2", ["45"] = "1", ["46"] = "7", ["47"] = "8", ["48"] = "9"}
			require "db/DB_Challenge_reward"
			local dbData = DB_Challenge_reward.getDataById(tab[tostring(tCellValue.template_id)])
			if(dbData)then
				local rewardTab = ItemUtil.getItemsDataByStr( dbData.reward )
				for k,v in pairs(rewardTab) do
					local rewardData = getRewardNameAndNum(v)
					if( not table.isEmpty(rewardData) )then
						rewardStr = rewardStr .. rewardData.num .. rewardData.name .. ","
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= rewardStr, ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 2)then
		if(tStrId_columnIndex == 1 or tStrId_columnIndex == 2 )then
			-- 8,9->资源矿强夺
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 3)then
			-- 16->竞技场防守成功
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name  or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 4 or tStrId_columnIndex == 5 or tStrId_columnIndex == 6)then
			-- 11->同意好友请求,12->拒绝好友请求,13->断绝好友关系
			-- 玩家姓名
			local hero_name = tCellValue.sender_uname
			local hero_uid = tCellValue.sender_uid 
			local hero_utid = tCellValue.sender_utid or 1
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 7 or tStrId_columnIndex == 8)then
			-- 19,20->接受入团申请，拒绝入团申请
			local guildName = " "
			if( tCellValue.va_extra.data[1] )then
				guildName = tCellValue.va_extra.data[1].guild_name
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= guildName or " ", ntype="label", fontSize=23, color=ccc3(0x70,0xff,0x18), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 9)then
			-- 30->vip
			local vipData = 0
			if( tCellValue.va_extra.data[1] )then
				vipData = tonumber(tCellValue.va_extra.data[1])
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= vipData or " ", ntype="label", fontSize=23, color=ccc3(0x70,0xff,0x18), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 10)then
			-- 31->竞技场被击败 排名没变的
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= "" .. hero_name, ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 3)then
		if(tStrId_columnIndex == 1 or tStrId_columnIndex == 10 or tStrId_columnIndex == 11)then
			-- 1->资源矿到期 36->占领时间结束 37->主动放弃协助
			-- 占领时间
			local gather_time = 0
			if(tCellValue.va_extra.data[1])then
				gather_time = tonumber(tCellValue.va_extra.data[1])
			end
			local timeStr = nil
			if(gather_time)then
				timeStr = TimeUtil.getTimeStringFont(gather_time)
			end
			-- 获得的银币数
			local coin = " "
			if( tCellValue.va_extra.data[2] )then
				coin = tCellValue.va_extra.data[2] .. GetLocalizeStringBy("key_1687")
			end
			if( tCellValue.va_extra.data[4] )then
				coin = coin .. tCellValue.va_extra.data[4] .. GetLocalizeStringBy("lic_1843")
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= timeStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
		elseif(tStrId_columnIndex == 4)then
			-- 10->申请好友
			local name_color,stroke_color = getHeroNameColor( tCellValue.sender_utid )
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= tCellValue.sender_uname or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(tCellValue.sender_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= tCellValue.content or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
		elseif(tStrId_columnIndex == 7)then
			-- 18->竞技场排名奖励
			-- 位置
			local arena_position = " "
			if( tCellValue.va_extra.data[2] )then
				arena_position = tCellValue.va_extra.data[2].arena_position
			end
			-- 将魂 此奖励被遗弃 by 2013.12.2
			-- local reward_soul = tCellValue.va_extra.data[3]
			local str4 = " "
			-- 声望 addby 2013.12.2
			local reward_prestige = tCellValue.va_extra.data[3]
			if(reward_prestige ~= nil and tonumber(reward_prestige) > 0)then
				str4 = str4 .. reward_prestige .. GetLocalizeStringBy("key_2914") 
			end
			-- 银币
			local reward_coin = tCellValue.va_extra.data[4]
			if(reward_coin ~= nil and tonumber(reward_coin) > 0)then
				str4 = str4 .. reward_coin .. GetLocalizeStringBy("key_2331") 
			end
			-- 物品
			local item_template_id = nil
			if( tCellValue.va_extra.data[5] )then
				item_template_id = tCellValue.va_extra.data[5].item_template_id
			end
			print(item_template_id)
			if(item_template_id)then
				local rewardItem_name = ItemUtil.getItemById( tonumber(item_template_id) ).name
				local rewardItem_num = " "
				if( tCellValue.va_extra.data[5] )then
					rewardItem_num = tCellValue.va_extra.data[5].item_number
				end
				str4 = str4 .. rewardItem_name .. "*" .. rewardItem_num
			end
			-- 时间 add by 2014.07.07
			local timeStr = " "
			if( tCellValue.va_extra.data[6] )then
				local timeData = tCellValue.va_extra.data[6].send_time
				if(timeData ~= nil)then
					timeStr = TimeUtil.getTimeForDayTwo(timeData)
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= timeStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= arena_position or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= str4, ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
		elseif(tStrId_columnIndex == 2 or tStrId_columnIndex == 3 or tStrId_columnIndex == 8 or tStrId_columnIndex == 9)then
			-- 4,5->资源矿抢夺
			-- 资源矿原主人名字
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			-- print(GetLocalizeStringBy("key_1752"), replay)
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 5)then
			-- 15->竞技场被击败
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 竞技场排名
			local arena_position = " "
			if(tCellValue.va_extra.data[2])then
				arena_position = tCellValue.va_extra.data[2].arena_position
			end
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= arena_position or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 6)then
			-- 17->竞技场幸运排名奖励
			-- 位置
			local arena_position = " "
			if(tCellValue.va_extra.data[2])then
				arena_position = tCellValue.va_extra.data[2].arena_position
			end
			-- 金币数
			local gold = " "
			if(tCellValue.va_extra.data[3])then
				gold = tCellValue.va_extra.data[3].gold .. GetLocalizeStringBy("key_1491")
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= arena_position or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= gold, ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
		elseif(tStrId_columnIndex == 12)then
			-- 42->协助被抢夺矿主提示 资源矿协助
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			--- 获得的银币数
			local coin = " "
			if( tCellValue.va_extra.data[2] )then
				coin = tonumber(tCellValue.va_extra.data[2]) .. GetLocalizeStringBy("key_1687")
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= coin, ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
		elseif( tStrId_columnIndex == 13)then
			-- 43 擂台争霸32强-4强奖励
			-- 擂台争霸获得的名次
			local positionNum = nil
			if( tCellValue.va_extra.data[1] )then
				positionNum = tCellValue.va_extra.data[1]
			end
			-- 获得的奖励
			local rewardStr = " "
			local dataTab = { ["32"] = "6", ["16"] = "5", ["8"] = "4", ["4"] = "3"}
			if(positionNum)then
				require "db/DB_Challenge_reward"
				print("==>")
				print_t(dataTab)
				print(dataTab[positionNum])
				local dbData = DB_Challenge_reward.getDataById(dataTab[positionNum])
				if(dbData)then
					local rewardTab = ItemUtil.getItemsDataByStr( dbData.reward )
					for k,v in pairs(rewardTab) do
						local rewardData = getRewardNameAndNum(v)
						if( not table.isEmpty(rewardData) )then
							rewardStr = rewardStr .. rewardData.num .. rewardData.name .. ","
						end
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= positionNum or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= rewardStr, ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
		elseif( tStrId_columnIndex == 14)then
			-- 68 军团分发粮饷
			local roleType = nil
			if( tCellValue.va_extra.data[1] )then
				roleType = tonumber(tCellValue.va_extra.data[1].guildRole)
			end
			-- 军团长 副军团长 顶级精英 高级精英 精英成员 普通成员
			local dataTab = { GetLocalizeStringBy("zz_142"),GetLocalizeStringBy("zz_143"),GetLocalizeStringBy("zz_144"),GetLocalizeStringBy("zz_145"),GetLocalizeStringBy("zz_146"),GetLocalizeStringBy("zz_147") }
			local name = nil
			if(roleType)then
				name = dataTab[roleType]
			end
			-- 活的粮草数
			local num = nil
			if( tCellValue.va_extra.data[2] )then
				num = tCellValue.va_extra.data[2].grainNum
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= name or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= num or " ", ntype="label", fontSize=23, color=ccc3(0x00,0xff,0x18)}
		elseif( tStrId_columnIndex == 15)then
			-- 72 过关斩将排名奖励发放
			local positionNum = nil
			if( tCellValue.va_extra.data[1] )then
				positionNum = tCellValue.va_extra.data[1].rank
			end
			local rewardData = {}
			if( tCellValue.va_extra.data[2] )then
				rewardData = tCellValue.va_extra.data[2].reward
			end
			-- 获得的奖励
			local rewardStr = " "
			if(rewardData)then
				require "db/DB_Overcome_reward"
				-- print("==>rewardData") print_t(rewardData)
				if(not table.isEmpty(rewardData) )then
					for k,v in pairs(rewardData) do
						local tab = {}
						tab.type = v[1]
        				tab.tid  = v[2]
        				tab.num  = v[3]
        				local tab1 = {}
        				table.insert(tab1,tab)
						local rewardTab = ItemUtil.getItemsDataByStr(nil,tab1)
						-- print("==>rewardTab")print_t(rewardTab)
						for k,v1 in pairs(rewardTab) do
							local temp = getRewardNameAndNum(v1)
							-- print("==>temp") print_t(temp)
							if( not table.isEmpty(temp) )then
								rewardStr = rewardStr .. temp.num .. temp.name .. ","
							end
						end
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= positionNum or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= rewardStr, ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 4)then
		-- 21->踢出军团, 23->被抢夺碎片, 27->比武积分抢夺, 28->比武排行奖励, 29->夺宝被掠夺银币
		if(tStrId_columnIndex == 1 )then
			-- 21->踢出军团
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[2] )then
				hero_name = tCellValue.va_extra.data[2].uname
				hero_uid = tCellValue.va_extra.data[2].uid
			    hero_utid = tCellValue.va_extra.data[2].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 军团名字
			local guildName = " "
			if( tCellValue.va_extra.data[1] )then
				guildName = tCellValue.va_extra.data[1].guild_name
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= guildName or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 2)then
			-- 23->被抢夺碎片
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 物品名称
			local item_template_id = nil
			if(tCellValue.va_extra.data[2])then
				item_template_id = tCellValue.va_extra.data[2].fragId
			end
			-- print(item_template_id)
			local item_name = nil
			if(item_template_id)then
				item_name = ItemUtil.getItemById( tonumber(item_template_id) ).name
			end
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ",ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= item_name or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 3)then
			-- 27->比武积分抢夺
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 获得的银币数
			local score = " "
			if( tCellValue.va_extra.data[2] )then
				score = tCellValue.va_extra.data[2].integral
			end
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= score or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 4)then
			-- 28->比武排行奖励
			-- 位置
			local match_position = " "
			if(tCellValue.va_extra.data[1]) then
				match_position = tCellValue.va_extra.data[1].rank
			end
			local str4 = " "
			-- 将魂
			local reward_soul = nil
			if( tCellValue.va_extra.data[2] )then
				reward_soul = tCellValue.va_extra.data[2].soul
			end
			if(reward_soul ~= nil and tonumber(reward_soul) > 0)then
				str4 = str4 .. reward_soul .. GetLocalizeStringBy("key_1336") 
			end
			-- 银币
			local reward_coin = nil
			if( tCellValue.va_extra.data[3] )then
				reward_coin = tCellValue.va_extra.data[3].silver
			end
			if(reward_coin ~= nil and tonumber(reward_coin) > 0)then
				str4 = str4 .. reward_coin .. GetLocalizeStringBy("key_2331") 
			end
			-- 金币
			local reward_gold = nil
			if(tCellValue.va_extra.data[4])then
				reward_gold = tCellValue.va_extra.data[4].gold
			end
			if(reward_gold ~= nil and tonumber(reward_gold) > 0)then
				str4 = str4 .. reward_gold .. GetLocalizeStringBy("key_2741") 
			end
			-- 荣誉
			local reward_honor = nil
			if( tCellValue.va_extra.data[5] )then
				reward_honor = tCellValue.va_extra.data[5].honor
			end
			if(reward_honor ~= nil and tonumber(reward_honor) > 0)then
				str4 = str4 .. reward_honor .. GetLocalizeStringBy("lic_1087") 
			end
			-- 物品
			local item_template_id = nil
			if( tCellValue.va_extra.data[6] )then
				 item_template_id = tCellValue.va_extra.data[6].item_template_id
			end
			print("item_template_id ",item_template_id)
			if(item_template_id ~= nil)then
				local rewardItem_name = ItemUtil.getItemById(item_template_id).name
				local rewardItem_num = " "
				if( tCellValue.va_extra.data[6] )then
					rewardItem_num = tCellValue.va_extra.data[6].item_number
				end
				str4 = str4 .. rewardItem_name .. "*" .. rewardItem_num
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= match_position or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= str4 or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
		elseif(tStrId_columnIndex == 5)then
			-- 29->夺宝被掠夺银币
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 获得的银币数
			local coin = " "
			if( tCellValue.va_extra.data[2] )then
				coin = tCellValue.va_extra.data[2].silver
			end
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 6)then
			-- 32->竞技场被击败 并且被掠夺了银币
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 获得的银币数
			local coin = " "
			if( tCellValue.va_extra.data[2] )then
				coin = tCellValue.va_extra.data[2].silver
			end
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 7)then
			-- 35->城池争夺战发奖 
			-- 城市名字
			local cityName = GetLocalizeStringBy("key_1827")
			require "db/DB_City"
			local cityId = tonumber(tCellValue.va_extra.data[1].cityId) or 11
			local member_type = tCellValue.va_extra.data[2].memberType or 1
			local data = DB_City.getDataById(cityId)
			cityName = data.name
			-- 奖励物品名字和数量
			require "script/ui/guild/city/CityData"
			local num = CityData.getRewardNumByMemberType(member_type, cityId)
			local rewardStr = data.rewardName .. "*" .. num
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= cityName, ntype="label", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= rewardStr, ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 8)then
			-- 67->A军团向B军团发起抢粮 
			local guildName = nil
			if(tCellValue.va_extra.data[1])then
				guildName = tCellValue.va_extra.data[1].guildName
			end
			-- 开始时间
			local star_time = nil
			if(tCellValue.va_extra.data[2])then
				star_time = tCellValue.va_extra.data[2].seconds
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= guildName or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= star_time or " ", ntype="label", fontSize=23, color=ccc3(0x00, 0xff, 0x18)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 9)then
			-- 70->防守方军团被抢粮草损失 
			-- 军团名字
			local guildName = nil
			if(tCellValue.va_extra.data[1])then
				guildName = tCellValue.va_extra.data[1].robberGuildName
			end
			-- 被抢走粮草
			local num = nil
			if(tCellValue.va_extra.data[2])then
				num = tCellValue.va_extra.data[2].grainNum
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= guildName or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= num or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 5)then
		if(tStrId_columnIndex == 1 or tStrId_columnIndex == 2)then
			-- 2,7->资源矿守护成功
			-- 抢夺者姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[2] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[3] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 3)then
			-- 14->好友留言
			-- 玩家姓名
			local hero_name = tCellValue.sender_uname
			local hero_uid = tCellValue.sender_uid
			local hero_utid = tCellValue.sender_utid or 1
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 内容
			local str = tCellValue.content
			textInfo[1] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[2] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[3] = { content= str or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 4)then
			-- 51->擂台争霸奖池奖励
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[3] )then
				hero_name = tCellValue.va_extra.data[3].uname
				hero_uid = tCellValue.va_extra.data[3].uid
			    hero_utid = tCellValue.va_extra.data[3].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 连胜次数
			local data1 = " "
			if( tCellValue.va_extra.data )then
				if( tCellValue.va_extra.data[1])then
					data1 = tCellValue.va_extra.data[1]
				end
			end
			-- 获得的银币
			local data2 = " "
			if( tCellValue.va_extra.data )then
				if( tCellValue.va_extra.data[2])then
					data2 = tCellValue.va_extra.data[2]
				end
			end
			textInfo[1] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[2] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[3] = { content=data1 or " ", ntype="label", fontSize=23, color=ccc3(0x70,0xff,0x18) }
			textInfo[4] = { content= templateData.content[2] or " ", ntype="label", fontSize=23, color=ccc3(0xff, 0xfb, 0xd9)}
			textInfo[5] = { content=data2 or " ", ntype="label", fontSize=23, color=ccc3(0x70,0xff,0x18) }
			textInfo[6] = { content= templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff, 0xfb, 0xd9)}
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 6)then
		if(tStrId_columnIndex == 1 or tStrId_columnIndex == 2)then
			-- 3,6->守护资源矿失败
			-- 抢夺者姓名
			local hero_name = " "
				local hero_uid = 0
				local hero_utid = 0
				if( tCellValue.va_extra.data[1] )then
					hero_name = tCellValue.va_extra.data[1].uname
					hero_uid = tCellValue.va_extra.data[1].uid
				    hero_utid = tCellValue.va_extra.data[1].utid
				end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 占领时间
			local gather_time = 0
			if(tCellValue.va_extra.data[2])then
				gather_time = tonumber(tCellValue.va_extra.data[2].gather_time)
			end
			local timeStr = TimeUtil.getTimeStringFont(gather_time)
			-- 获得的银币数
			local coin = " "
			if( tCellValue.va_extra.data[3] )then
				coin = tCellValue.va_extra.data[3] .. GetLocalizeStringBy("key_1687")
			end
			-- 精铁
			if( tCellValue.va_extra.data[6] )then
				coin = coin .. tCellValue.va_extra.data[6] .. GetLocalizeStringBy("lic_1843")
			end
			-- 战报
			local replay = tonumber(tCellValue.va_extra.replay)
			-- print(GetLocalizeStringBy("key_1392"),replay)
			textInfo[1] = { content= hero_name or " ",ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[2] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[3] = { content= timeStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
			textInfo[4] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[5] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
			textInfo[6] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[7] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 3) then
			-- 71->金币资源矿1小时保底银币奖励
			-- 抢夺者姓名
			local hero_name = nil
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 占领时间
			local gather_time = 0
			if(tCellValue.va_extra.data[2])then
				gather_time = tonumber(tCellValue.va_extra.data[2])
			end
			local timeStr = TimeUtil.getTimeStringFont(gather_time)
			-- 获得的银币数
			local coin = nil
			if( tCellValue.va_extra.data[3] )then
				coin = tCellValue.va_extra.data[3]
			end
			-- 精铁
			local jingTie = nil
			if( tCellValue.va_extra.data[6] )then
				jingTie = tCellValue.va_extra.data[6] .. GetLocalizeStringBy("lic_1843")
			end
			-- 战报
			local replay = tonumber(tCellValue.va_extra.replay)
			-- print(GetLocalizeStringBy("key_1392"),replay)
			textInfo[1] = { content= hero_name or " ",ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[2] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[3] = { content= timeStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
			textInfo[4] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[5] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
			textInfo[6] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[7] = { content= jingTie or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
			textInfo[8] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 7)then
		-- 24->竞技场被掠夺银币, 25->夺宝被掠夺银币, 26->比武被掠夺银币
		if(tStrId_columnIndex == 1)then
			-- 24->竞技场被掠夺银币
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 获得的银币数
			local coin = " "
			if( tCellValue.va_extra.data[2] )then
				coin = tCellValue.va_extra.data[2].silver
			end
			-- 位置
			local arena_position = " "
			if( tCellValue.va_extra.data[3] )then
				arena_position = tCellValue.va_extra.data[3].rank
			end
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= arena_position or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[7] = { content=templateData.content[4], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[8] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 2)then
			-- 25->夺宝被掠夺银币
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].uname
				hero_uid = tCellValue.va_extra.data[1].uid
			    hero_utid = tCellValue.va_extra.data[1].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 获得的银币数
			local coin = " "
			if (tCellValue.va_extra.data[3]) then
				coin = tCellValue.va_extra.data[3].silver
			end
			-- 物品名称
			local item_template_id = nil
			if(tCellValue.va_extra.data[2])then 
				item_template_id = tCellValue.va_extra.data[2].fragId
			end 
			-- print(item_template_id)
			local item_name = nil
			if(item_template_id)then
				item_name = ItemUtil.getItemById( tonumber(item_template_id) ).name
			end
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= item_name or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[7] = { content=templateData.content[4], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[8] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 3)then
			-- 26->比武被掠夺银币
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[2] )then
				hero_name = tCellValue.va_extra.data[2].uname
				hero_uid = tCellValue.va_extra.data[2].uid
			    hero_utid = tCellValue.va_extra.data[2].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 获得的银币数
			local coin = " "
			if( tCellValue.va_extra.data[1] )then
				coin = tCellValue.va_extra.data[1].silver
			end
			-- 积分
			local score = " "
			if( tCellValue.va_extra.data[3] )then
				score = tCellValue.va_extra.data[3].integral
			end
			--战斗重播数值
			local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= score or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[7] = { content=templateData.content[4], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[8] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif(tStrId_columnIndex == 4)then
			-- 49->擂台争霸奖池奖励 
			-- 连胜次数
			local data1 = " "
			if( tCellValue.va_extra.data )then
				if( tCellValue.va_extra.data[1])then
					data1 = tCellValue.va_extra.data[1]
				end
			end
			-- 获得的银币
			local data2 = " "
			if( tCellValue.va_extra.data )then
				if( tCellValue.va_extra.data[2])then
					data2 = tCellValue.va_extra.data[2]
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= data1 or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= data1 or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= data2 or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18)}
			textInfo[7] = { content=templateData.content[4], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 5)then
			-- 50->擂台争霸奖池奖励
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[3] )then
				hero_name = tCellValue.va_extra.data[3].uname
				hero_uid = tCellValue.va_extra.data[3].uid
			    hero_utid = tCellValue.va_extra.data[3].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 连胜次数
			local data1 = " "
			if( tCellValue.va_extra.data )then
				if( tCellValue.va_extra.data[1])then
					data1 = tCellValue.va_extra.data[1]
				end
			end
			-- 获得的银币
			local data2 = " "
			if( tCellValue.va_extra.data )then
				if( tCellValue.va_extra.data[2])then
					data2 = tCellValue.va_extra.data[2]
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= data1 or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= data2 or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18)}
			textInfo[7] = { content=templateData.content[4], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 6)then
			-- 69->攻击方军团抢粮获得
			local guildName = nil
			if( tCellValue.va_extra.data[1] )then
				guildName = tCellValue.va_extra.data[3].lambGuildName
			end
			-- 获得个人粮草
			local data1 = nil
			if( tCellValue.va_extra.data[2] )then
				data1 = tCellValue.va_extra.data[2].grainNum
			end
			-- 获得功勋
			local data2 = nil
			if( tCellValue.va_extra.data[3])then
				data2 = tCellValue.va_extra.data[3].meritNum
			end
			-- 获得军团粮草
			local data3 = nil
			if( tCellValue.va_extra.data[4] )then
				data3 = tCellValue.va_extra.data[4].guildGainGrainNum
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= guildName or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= data1 or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= data2 or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18)}
			textInfo[7] = { content=templateData.content[4], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[8] = { content= data3 or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18)}
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 8)then
		if(tStrId_columnIndex == 1)then
			-- 0->模板id为0的特殊邮件
			local contentStr = tCellValue.content or " "
			textInfo[1] = { content=contentStr, ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 9)then
		if(tStrId_columnIndex == 1 or tStrId_columnIndex == 3)then
			-- 38->资源矿协助 被占领 40->协助被抢夺
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[3] )then
				hero_name = tCellValue.va_extra.data[3].uname
				hero_uid = tCellValue.va_extra.data[3].uid
			    hero_utid = tCellValue.va_extra.data[3].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 占领时间
			local gather_time = 0
			if(tCellValue.va_extra.data[1])then
				gather_time = tonumber(tCellValue.va_extra.data[1])
			end
			local timeStr = TimeUtil.getTimeStringFont(gather_time)
			-- 获得的银币数
			local coin = " "
			if( tCellValue.va_extra.data[2] )then
				coin = tCellValue.va_extra.data[2] .. GetLocalizeStringBy("key_1687")
			end
			-- 战报
			-- local replay = tonumber(tCellValue.va_extra.replay)
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= timeStr or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[7] = { content=templateData.content[4], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			-- textInfo[8] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=lookBattle }
		elseif( tStrId_columnIndex == 2 or tStrId_columnIndex == 4 )then
			-- 39->资源矿协助 放弃  41->资源矿协助到期
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[3] )then
				hero_name = tCellValue.va_extra.data[3].uname
				hero_uid = tCellValue.va_extra.data[3].uid
			    hero_utid = tCellValue.va_extra.data[3].utid
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 占领时间
			local gather_time = 0
			if(tCellValue.va_extra.data[1])then
				gather_time = tonumber(tCellValue.va_extra.data[1])
			end
			local timeStr = TimeUtil.getTimeStringFont(gather_time)
			-- 获得的银币数
			local coin = " "
			if( tCellValue.va_extra.data[2] )then
				coin = tCellValue.va_extra.data[2] .. GetLocalizeStringBy("key_1687")
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= timeStr or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 10)then
		if(tStrId_columnIndex == 1 or tStrId_columnIndex == 2 or tStrId_columnIndex == 7 or tStrId_columnIndex == 8)then
			-- 52->群雄争霸服内傲视群雄组32强-4强奖励  53->群雄争霸服内初出茅庐组32强-4强奖励 58->群雄争霸跨服傲视群雄组32强-4强奖励  59->群雄争霸跨服初出茅庐组32强-4强奖励
			local positionNum = nil
			if( tCellValue.va_extra.data[1] )then
				positionNum = tCellValue.va_extra.data[1]
			end
			-- 获得的奖励
			local rewardStr = " "
			if(tCellValue.va_extra.data[2])then
				local rewardTab = ItemUtil.getServiceReward( tCellValue.va_extra.data[2] )
				for k,v in pairs(rewardTab) do
					local rewardData = getRewardNameAndNum(v)
					if( not table.isEmpty(rewardData) )then
						rewardStr = rewardStr .. rewardData.num .. rewardData.name .. ","
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= positionNum or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= rewardStr, ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
		elseif(tStrId_columnIndex == 3 or tStrId_columnIndex == 4 or tStrId_columnIndex == 5 or tStrId_columnIndex == 6 or tStrId_columnIndex == 9 or tStrId_columnIndex == 10 or tStrId_columnIndex == 11 or tStrId_columnIndex == 12)then
			-- 54->群雄争霸服内傲视群雄组亚军奖励 55->群雄争霸服内初出茅庐组亚军奖励 56->群雄争霸服内傲视群雄组冠军奖励 57->群雄争霸服内初出茅庐组冠军奖励
			-- 60->群雄争霸跨服傲视群雄组亚军奖励 61->群雄争霸跨服初出茅庐组亚军奖励 62->群雄争霸跨服傲视群雄组冠军奖励 63->群雄争霸跨服初出茅庐组冠军奖励
			local positionNum = nil
			if( tCellValue.va_extra.data[1] )then
				positionNum = tCellValue.va_extra.data[1]
			end
			-- 获得的奖励
			local rewardStr = " "
			if(tCellValue.va_extra.data[2])then
				local rewardTab = ItemUtil.getServiceReward( tCellValue.va_extra.data[2] )
				for k,v in pairs(rewardTab) do
					local rewardData = getRewardNameAndNum(v)
					if( not table.isEmpty(rewardData) )then
						rewardStr = rewardStr .. rewardData.num .. rewardData.name .. ","
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= rewardStr, ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
		elseif(tStrId_columnIndex == 13 or tStrId_columnIndex == 14 or tStrId_columnIndex == 15)then
			-- 64->群雄争霸服内助威奖励 65->群雄争霸跨服助威奖励 66->群雄争霸冠军服全服奖励
			-- 获得的奖励
			local rewardStr = " "
			if(tCellValue.va_extra.data[1])then
				local rewardTab = ItemUtil.getServiceReward( tCellValue.va_extra.data[1] )
				for k,v in pairs(rewardTab) do
					local rewardData = getRewardNameAndNum(v)
					if( not table.isEmpty(rewardData) )then
						rewardStr = rewardStr .. rewardData.num .. rewardData.name .. ","
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= rewardStr, ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 11)then
		if(tStrId_columnIndex == 1 or tStrId_columnIndex == 2 )then
			-- 73->军团争霸赛晋级阶段（16强-4强）结果通知（失败） 74->军团争霸赛晋级阶段（16强-4强）结果通知（成功）
			-- 军团名字
			local guildNameStr = nil
			if( not table.isEmpty(tCellValue.va_extra.data) )then
				if( tCellValue.va_extra.data.guildName )then
					guildNameStr = tCellValue.va_extra.data.guildName
				end
			end
			-- 军团服务器名字
			local serverNameStr = nil
			if( not table.isEmpty(tCellValue.va_extra.data) )then
				if( tCellValue.va_extra.data.serverName )then
					serverNameStr = tCellValue.va_extra.data.serverName
				end
			end
			-- 排名
			local rankStr = nil
			if( not table.isEmpty(tCellValue.va_extra.data) )then
				if( tCellValue.va_extra.data.rank )then
					rankStr = tCellValue.va_extra.data.rank
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= rankStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= serverNameStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= guildNameStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[7] = { content=templateData.content[4], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 3 or tStrId_columnIndex == 4 )then
			-- 75->军团争霸赛晋级阶段冠军结果通知 76->军团争霸赛晋级阶段亚军结果通知
			-- 军团名字
			local guildNameStr = nil
			if( not table.isEmpty(tCellValue.va_extra.data) )then
				if( tCellValue.va_extra.data.guildName )then
					guildNameStr = tCellValue.va_extra.data.guildName
				end
			end
			-- 军团服务器名字
			local serverNameStr = nil
			if( not table.isEmpty(tCellValue.va_extra.data) )then
				if( tCellValue.va_extra.data.serverName )then
					serverNameStr = tCellValue.va_extra.data.serverName
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= serverNameStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= guildNameStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 5)then
			-- 77->军团争霸赛16强-4强奖励
			-- 排名
			local rankStr = nil
			if( not table.isEmpty(tCellValue.va_extra.data) )then
				if( tCellValue.va_extra.data.rank )then
					rankStr = tCellValue.va_extra.data.rank
				end
			end
			-- 获得的奖励
			local rewardStr = " "
			if( not table.isEmpty(tCellValue.va_extra.data.rewardArr) )then
				local rewardTab = ItemUtil.getServiceReward( tCellValue.va_extra.data.rewardArr )
				for k,v in pairs(rewardTab) do
					local rewardData = getRewardNameAndNum(v)
					if( not table.isEmpty(rewardData) )then
						rewardStr = rewardStr .. rewardData.num .. rewardData.name .. ","
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= rankStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= rewardStr, ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
		elseif(tStrId_columnIndex == 6 or tStrId_columnIndex == 7 or tStrId_columnIndex == 8)then
			-- 78->军团争霸赛冠军奖励 79->军团争霸赛亚军奖励 80->军团争霸赛助威奖励
			-- 获得的奖励
			local rewardStr = " "
			if(tCellValue.va_extra.data)then
				if( not table.isEmpty(tCellValue.va_extra.data.rewardArr) )then
					local rewardTab = ItemUtil.getServiceReward( tCellValue.va_extra.data.rewardArr )
					for k,v in pairs(rewardTab) do
						local rewardData = getRewardNameAndNum(v)
						if( not table.isEmpty(rewardData) )then
							rewardStr = rewardStr .. rewardData.num .. rewardData.name .. ","
						end
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= rewardStr, ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 12)then
		if(tStrId_columnIndex == 1)then
			-- 81->木牛流马运送奖励
			local rewardStr = " "
			if(tCellValue.va_extra.data)then
				if( not table.isEmpty(tCellValue.va_extra.data) and not table.isEmpty(tCellValue.va_extra.data[1]) )then
					local rewardTab = ItemUtil.getServiceReward( tCellValue.va_extra.data[1].reward )
					for k,v in pairs(rewardTab) do
						local rewardData = getRewardNameAndNum(v)
						if( not table.isEmpty(rewardData) )then
							rewardStr = rewardStr .. rewardData.num .. rewardData.name .. ","
						end
					end
				end
			end
			local robStr = " "
			if(tCellValue.va_extra.data)then
				if( not table.isEmpty(tCellValue.va_extra.data) and not table.isEmpty(tCellValue.va_extra.data[2]) )then
					local rewardTab = ItemUtil.getServiceReward( tCellValue.va_extra.data[2].rewardRobed )
					for k,v in pairs(rewardTab) do
						local rewardData = getRewardNameAndNum(v)
						if( not table.isEmpty(rewardData) )then
							robStr = robStr .. rewardData.num .. rewardData.name .. ","
						end
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content=rewardStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content=robStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 2)then
			-- 82->木牛流马协助奖励
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].userInfo.uname
				hero_uid = tCellValue.va_extra.data[1].userInfo.uid
			    hero_utid = tCellValue.va_extra.data[1].userInfo.utid or 1
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 奖励
			local rewardStr = " "
			if(tCellValue.va_extra.data)then
				if( not table.isEmpty(tCellValue.va_extra.data) and not table.isEmpty(tCellValue.va_extra.data[2]) )then
					local rewardTab = ItemUtil.getServiceReward( tCellValue.va_extra.data[2].reward )
					for k,v in pairs(rewardTab) do
						local rewardData = getRewardNameAndNum(v)
						if( not table.isEmpty(rewardData) )then
							rewardStr = rewardStr .. rewardData.num .. rewardData.name .. ","
						end
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content=rewardStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
		elseif(tStrId_columnIndex == 3)then
			-- 83->木牛流马抢夺奖励
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].userInfo.uname
				hero_uid = tCellValue.va_extra.data[1].userInfo.uid
			    hero_utid = tCellValue.va_extra.data[1].userInfo.utid or 1
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 品质
			local qualityStr = {[3]= GetLocalizeStringBy("lic_1832"),[4]=GetLocalizeStringBy("lic_1833"),[5]=GetLocalizeStringBy("lic_1834"),[6]=GetLocalizeStringBy("lic_1835")}
			local quality = tonumber(tCellValue.va_extra.data[2].quality)
			-- 奖励
			local rewardStr = " "
			if(tCellValue.va_extra.data)then
				if( not table.isEmpty(tCellValue.va_extra.data) and not table.isEmpty(tCellValue.va_extra.data[3]) )then
					local rewardTab = ItemUtil.getServiceReward( tCellValue.va_extra.data[3].reward )
					for k,v in pairs(rewardTab) do
						local rewardData = getRewardNameAndNum(v)
						if( not table.isEmpty(rewardData) )then
							rewardStr = rewardStr .. rewardData.num .. rewardData.name .. ","
						end
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content=qualityStr[quality] or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content=rewardStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[7] = { content=templateData.content[4], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			-- 战报
			if(not table.isEmpty(tCellValue.va_extra.data[4]) and not table.isEmpty(tCellValue.va_extra.data[4].arrBridId) )then
				local replay1 = tonumber(tCellValue.va_extra.data[4].arrBridId[1])
				local replay2 = tonumber(tCellValue.va_extra.data[4].arrBridId[2])
				function battleReport( ... )
					require "script/battle/BattleUtil"
					if( replay1 == 0 or replay2 == 0 )then
						local temp = (replay1 ~= 0) or replay2
						BattleUtil.playerBattleReportById( temp )
					else
						BattleUtil.playTwoBattle( replay1, replay2)
					end
				end
				textInfo[8] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=battleReport }
			end
		elseif(tStrId_columnIndex == 4)then
			-- 84->木牛流马抢夺奖励
			-- 玩家姓名
			local hero_name = " "
			local hero_uid = 0
			local hero_utid = 0
			if( tCellValue.va_extra.data[1] )then
				hero_name = tCellValue.va_extra.data[1].userInfo.uname
				hero_uid = tCellValue.va_extra.data[1].userInfo.uid
			    hero_utid = tCellValue.va_extra.data[1].userInfo.utid or 1
			end
			-- 玩家名字颜色
			local name_color,stroke_color = getHeroNameColor( hero_utid )
			-- 奖励
			local rewardStr = " "
			if(tCellValue.va_extra.data)then
				if( not table.isEmpty(tCellValue.va_extra.data) and not table.isEmpty(tCellValue.va_extra.data[3]) )then
					local rewardTab = ItemUtil.getServiceReward( tCellValue.va_extra.data[3].reward )
					for k,v in pairs(rewardTab) do
						local rewardData = getRewardNameAndNum(v)
						if( not table.isEmpty(rewardData) )then
							rewardStr = rewardStr .. rewardData.num .. rewardData.name .. ","
						end
					end
				end
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content=rewardStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			-- 战报
			if(not table.isEmpty(tCellValue.va_extra.data[4]) and not table.isEmpty(tCellValue.va_extra.data[4].arrBridId) )then
				local replay1 = tonumber(tCellValue.va_extra.data[4].arrBridId[1])
				local replay2 = tonumber(tCellValue.va_extra.data[4].arrBridId[2])
				function battleReport( ... )
					require "script/battle/BattleUtil"
					if( replay1 == 0 or replay2 == 0 )then
						local temp = (replay1 ~= 0) or replay2
						BattleUtil.playerBattleReportById( temp )
					else
						BattleUtil.playTwoBattle( replay1, replay2)
					end
				end
				textInfo[6] = { content= GetLocalizeStringBy("key_1076"), ntype="button", font=g_sFontPangWa, fontSize=30, color=ccc3(0x70,0xff,0x18), tag=replay or 1,tapFunc=battleReport }
			end
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	else
		print("no add tCellValue.template_id",tCellValue.template_id)
	end

	-- 创建文本
	local parent = tolua.cast(cell_bg:getChildByTag(1),"CCScale9Sprite")
	local text_font = LuaCCLabel.createRichText(textInfo)
	text_font:setPosition(ccp((parent:getContentSize().width-text_font:getContentSize().width)*0.5,parent:getContentSize().height-10))
	parent:addChild(text_font)

	return cell
end


-- 玩家名字的颜色
function getHeroNameColor( utid )
	local name_color = nil
	local stroke_color = nil
	if(tonumber(utid) == 1)then
		-- 女性玩家
		name_color = ccc3(0xf9,0x59,0xff)
		stroke_color = ccc3(0x5c,0x00,0x7a)
	elseif(tonumber(utid) == 2)then
		-- 男性玩家 
		name_color = ccc3(0x00,0xe4,0xff)
		stroke_color = ccc3(0x00,0x2e,0x7a)
	end
	return name_color, stroke_color
end



-- 同意好友申请回调
function agreeItemCallFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_3183") .. tag)
	local function createNext( ... )
		local applyMenu = tolua.cast(item_obj:getParent(),"BTSensitiveMenu")
		local function createNext1( ... )
		    -- 更新列表
		    if(AllMail.allMailTableView ~= nil)then
		    	AllMail.allMailTableView:reloadData()
		    end

		    if(FriendMail.friendMailTableView ~= nil)then
		    	FriendMail.friendMailTableView:reloadData()
		    end
		end
	    -- local mid = applyMenu:getTag()
	    MailService.setApplyMailAdded(tag,createNext1)
	end
	MailService.addFriend(tag,createNext)
end


-- 拒绝好友申请回调
function refuseItemCallFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_2700") .. tag)
	local function createNext( ... )
		local applyMenu = tolua.cast(item_obj:getParent(),"BTSensitiveMenu")
		local function createNext1( ... )
		    -- 更新列表
		    if(AllMail.allMailTableView ~= nil)then
		    	AllMail.allMailTableView:reloadData()
		    end
		    if(FriendMail.friendMailTableView ~= nil)then
		    	FriendMail.friendMailTableView:reloadData()
		    end
		end
	    -- local mid = applyMenu:getTag()
	    MailService.setApplyMailRejected(tag,createNext1)
	end
	MailService.rejectFriend(tag,createNext)
end

-- 好友留言回复回调
function replyItemCallFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_2774") .. tag)
	require "script/ui/mail/ReplyMessage"
	ReplyMessage.createReplyMessageLayer(tag)

end

-- 资源矿反击回调
function atkBackItemCallFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_1927") .. tag)
	local function createNext( domain_id )
		-- 调用资源矿接口
		local canEnter = DataCache.getSwitchNodeState( ksSwitchResource )
		if( canEnter ) then
			require "script/ui/active/mineral/MineralLayer"
			MainScene.changeLayer(MineralLayer.createLayer(domain_id), "mineralLayer")
		end
	end
	-- local mark = item_obj:getParent():getTag()
	local userData = tolua.cast(item_obj:getUserObject(),"CCInteger")
	local mark = userData:getValue() or 1
	print("mark==",mark,type(mark),"1111")
	MailService.getDomainIdOfUser(tag,mark,createNext)
end

-- 去竞技回调
function toAreanItemCallFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_1963") .. tag)
	local canEnter = DataCache.getSwitchNodeState( ksSwitchArena )
	if( canEnter ) then
		require "script/ui/arena/ArenaLayer"
		local arenaLayer = ArenaLayer.createArenaLayer()
		MainScene.changeLayer(arenaLayer, "arenaLayer")
	end
end

-- 去比武回调
function toMatchItemCallFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_2081") .. tag)
	local canEnter = DataCache.getSwitchNodeState( ksSwitchContest )
	if( canEnter ) then
		require "script/ui/match/MatchLayer"
		local matchLayer = MatchLayer.createMatchLayer()
		MainScene.changeLayer(matchLayer, "matchLayer")
	end
end

-- 去抢夺回调
function toRobItemCallFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_1024") .. tag)
	local canEnter = DataCache.getSwitchNodeState( ksSwitchRobTreasure )
	if( canEnter ) then
		require "script/ui/treasure/TreasureMainView"
		local treasureLayer = TreasureMainView.create()
		MainScene.changeLayer(treasureLayer,"treasureLayer")
	end
end

-- 查看战报
function lookBattle( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_2029") .. tag)
	local function createNext( fightRet )
		-- 调用战斗接口 参数:atk 
		require "script/battle/BattleLayer"
		-- 调用结算面板
		require "script/ui/active/mineral/AfterMineral"
		-- require "script/model/user/UserModel"
		-- local uid = UserModel.getUserUid()
		-- 解析战斗串获得战斗评价
		local amf3_obj = Base64.decodeWithZip(fightRet)
   		local lua_obj = amf3.decode(amf3_obj)
   		print(GetLocalizeStringBy("key_1606"))
   		print_t(lua_obj)
   		local appraisal = lua_obj.appraisal
   		-- 敌人uid
   		local uid1 = lua_obj.team1.uid
   		local uid2 = lua_obj.team2.uid
   		local enemyUid = 0
   		if(tonumber(uid1) ==  UserModel.getUserUid() )then
   			enemyUid = tonumber(uid2)
   		end
   		if(tonumber(uid2) ==  UserModel.getUserUid() )then
   			enemyUid = tonumber(uid1)
   		end
   		local afterBattleLayer = AfterMineral.createAfterMineralLayer( appraisal, enemyUid, nil,fightRet)
		BattleLayer.showBattleWithString(fightRet, nextCallFun, afterBattleLayer,nil,nil,nil,nil,nil,true)
	end
	MailService.getRecord(tag,createNext)
end

function nextCallFun( ... )
	-- 空方法
end


-- 创建更多邮件
function createMoreButtonItem()
	local normalSprite = BaseUI.createYellowBg(CCSizeMake(584,190))
    local selectSprite = BaseUI.createYellowSelectBg(CCSizeMake(584,190))
    local item = CCMenuItemSprite:create(normalSprite,selectSprite)
    -- 红条
    local sprite = CCSprite:create("images/common/red_line.png")
	sprite:setAnchorPoint(ccp(0.5,0.5))
	sprite:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
	item:addChild(sprite)
    -- 字体
	local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_3410") , g_sFontPangWa, 35,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setPosition(ccp(sprite:getContentSize().width*0.5,sprite:getContentSize().height*0.5))
   	sprite:addChild(item_font)
   	return item
end

-- 更多邮件按钮回调
function moreMenuItemCallFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print(GetLocalizeStringBy("key_3410"))
	print("tag:",tag)
	if(AllMail.allMailTableView ~= nil)then
		-- 创建下一步UI
		local function createNext( t_data )
			if(table.count(t_data) == 0)then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_1402")
				AnimationTip.showTip(str)
				return
			end
			MailData.showMailData = MailData.addToShowMailData(MailData.showMailData,t_data)
			AllMail.allMailTableView:reloadData()
			AllMail.allMailTableView:setContentOffset(ccp(0, -10*190))
		end
		MailService.getMailBoxList( tag ,10,"true",createNext)
	end
	if(BattleMail.fbattleMailTableView ~= nil)then
		-- 创建下一步UI
		local function createNext( t_data )
			print("11111111111111111",table.count(t_data))
			if(table.count(t_data) == 0)then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_1402")
				AnimationTip.showTip(str)
				return
			end
			MailData.showMailData = MailData.addToShowMailData(MailData.showMailData,t_data)
			BattleMail.fbattleMailTableView:reloadData()
			BattleMail.fbattleMailTableView:setContentOffset(ccp(0, -10*190))
		end
		MailService.getBattleMailList( tag ,10,"true",createNext)
	end
	if(FriendMail.friendMailTableView ~= nil)then
		-- 创建下一步UI
		local function createNext( t_data )
			if(table.count(t_data) == 0)then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_1402")
				AnimationTip.showTip(str)
				return
			end
			MailData.showMailData = MailData.addToShowMailData(MailData.showMailData,t_data)
			FriendMail.friendMailTableView:reloadData()
			FriendMail.friendMailTableView:setContentOffset(ccp(0, -10*190))
		end
		MailService.getPlayMailList( tag ,10,"true",createNext)	
	end
	if(SystemMail.systemMailTableView ~= nil)then
		-- 创建下一步UI
		local function createNext( t_data )
			if(table.count(t_data) == 0)then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_1402")
				AnimationTip.showTip(str)
				return
			end
			MailData.showMailData = MailData.addToShowMailData(MailData.showMailData,t_data)
			SystemMail.systemMailTableView:reloadData()
			SystemMail.systemMailTableView:setContentOffset(ccp(0, -10*190))
		end
		MailService.getSysMailList( tag ,10,"true",createNext)
	end
	if(MineralMail.mailTableView ~= nil)then
		-- 创建下一步UI
		local function createNext( t_data )
			if(table.count(t_data) == 0)then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_1402")
				AnimationTip.showTip(str)
				return
			end
			MailData.showMailData = MailData.addToShowMailData(MailData.showMailData,t_data)
			MineralMail.mailTableView:reloadData()
			MineralMail.mailTableView:setContentOffset(ccp(0, -10*190))
		end
		MailService.getMineralMailList( tag ,10,"true",createNext)
	end
end


-- 对方阵容回调
function userFormationItemFun( tag, item_obj )
	if(tag == 1)then
		return
	end
    require "script/ui/active/RivalInfoLayer"
    print("user uid" .. tag )
    RivalInfoLayer.createLayer(tag)
end


-- 17种奖励类型的 名字和数量
-- p_itemData:解析后的数据
-- 格式：{	type = "silver"
--   		num  = 100
--   		tid  = 0
-- 		}
function getRewardNameAndNum( p_itemData )
	local retData = {}
	if(p_itemData == nil)then
		return retData
	end
	if( p_itemData.type == "silver" ) then
        -- 银币
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name =  GetLocalizeStringBy("key_8042")
    elseif(p_itemData.type == "soul" ) then
        -- 将魂
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("key_1086")
   elseif(p_itemData.type == "gold" ) then
        -- 金币
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("key_1447")
    elseif(p_itemData.type == "execution" ) then
        -- 体力(wu)
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("key_1299")
    elseif(p_itemData.type == "stamina" ) then
        -- 耐力(wu)
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("key_2021")
    elseif(p_itemData.type == "item" ) then
        -- 物品
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        local itemData = ItemUtil.getItemById(p_itemData.tid)
        retData.name = itemData.name
    elseif(p_itemData.type == "soul" ) then
        -- 等级*将魂(wu)
        retData.num  = tonumber(p_itemData.num) * UserModel.getHeroLevel()
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("key_1616")
    elseif(p_itemData.type == "jewel" ) then
        -- 魂玉
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("key_1510")
    elseif(p_itemData.type == "prestige" ) then
        -- 声望
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("key_2231")
    elseif(p_itemData.type == "hero" ) then
        -- 英雄
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        require "db/DB_Heroes"
		local heroData = DB_Heroes.getDataById(p_itemData.tid)
		retData.name = heroData.name
	elseif(p_itemData.type == "prestige" ) then
        -- 声望
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("key_2231")
    elseif(p_itemData.type == "contri" ) then
        -- 军团个人贡献
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("lic_1172")
    elseif(p_itemData.type == "buildNum" ) then
        -- 军团建设度
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("lic_1173")
    elseif(p_itemData.type == "honor" ) then
        -- 比武荣誉
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("lic_1174")
    elseif(p_itemData.type == "grain" ) then
        -- 粮草
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("lic_1323")
    elseif(p_itemData.type == "coin" ) then
        -- 神兵令
        retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("lcyx_149")
    elseif(p_itemData.type == "zg" ) then
    	--战功
    	retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("lcyx_1819")
    elseif(p_itemData.type == "tg_num" ) then
    	-- 天工令
    	retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("lic_1561")
    elseif(p_itemData.type == "wm_num" ) then
    	--争霸令
    	retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("lcyx_1912")

   	elseif(p_itemData.type == "hellPoint") then
	    -- 炼狱令
	    retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("lcyx_1917")
    elseif(p_itemData.type == "cross_honor") then
	    -- 跨服荣誉
	    retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("yr_2002")
	elseif(p_itemData.type == "jh") then
	    -- 将星
	    retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("syx_1053")  
	elseif(p_itemData.type == "copoint") then
	    -- 国战积分
	    retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("fqq_015")  
    elseif(p_itemData.type == "tally_point") then
	    -- 兵符积分
	    retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("fqq_050")  
	elseif(p_itemData.type == "book_num") then
	    -- 兵符积分
	    retData.num  = tonumber(p_itemData.num)
        retData.tid  = tonumber(p_itemData.tid)
        retData.name = GetLocalizeStringBy("lic_1812") 
    else
        print("此类型不存在。。。",p_itemData.type)
    end
    return  retData
end



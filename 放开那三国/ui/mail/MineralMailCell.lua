-- FileName: MineralMailCell.lua 
-- Author: licong 
-- Date: 14-4-27 
-- Purpose: function description of module 


module("MineralMailCell", package.seeall)

require "script/libs/LuaCCLabel"
require "script/utils/TimeUtil"
require "script/ui/mail/AllMail"
require "script/ui/mail/FriendMail"
require "script/ui/mail/BattleMail"
require "script/ui/mail/SystemMail"
require "script/ui/mail/MineralMail"

-- 有按钮的邮件模板id
local tArrId = {
	-- 反击按钮
	{2, 3, 6,7,71}
}

-- 内容结构分类
-- 抽取了资源矿相关的邮件
local tStrId = {
	-- 1. str1..data1..str2
	{8,9},
	-- 2. str1..data1..str2..data2
	{1,4,5,36,37,42},
	-- 3. data1..str1..data2
	{2,7},
	-- 4. data1..str1..data2..str2..data3..str3..data4
	{3,6,71},
	-- 5.str1..data1..str2..data2..str3..data3
	{38,39,40,41}
} 


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
    item_font:setPosition(ccp(24,item:getContentSize().height-11))
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
		tCellValue.va_extra.data[3] ~= nil and tCellValue.va_extra.data[3].uname ~= nil ) then
		tCellValue.va_extra.data[3].uname = string.gsub(tCellValue.va_extra.data[3].uname, "\n", "\\n")
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
	    moreMenuItem:setPosition(ccp(290,0))
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
		-- 保存第二个参数 mark
		local userData = CCInteger:create(mark)
		-- print("userData==",userData:getValue())
		atkBackItem:setUserObject(userData)
		-- 注册回调
		atkBackItem:registerScriptTapHandler(atkBackItemCallFun)
		-- 文本宽度
		textInfo.width = 425
	else
		-- 没有按钮背景
		cell_bg = createNoButtonCellBg()
		-- 文本宽度
		textInfo.width = 513
	end
	cell_bg:setAnchorPoint(ccp(0.5,0))
	cell_bg:setPosition(ccp(290,0))
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
	local strDay = MailData.getValidTime( tCellValue.recv_time )
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
		if(tStrId_columnIndex == 1 or tStrId_columnIndex == 2 )then
			-- 8,9->资源矿强夺,
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
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 2)then
		if(tStrId_columnIndex == 1 or tStrId_columnIndex == 4 or tStrId_columnIndex == 5)then
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
				coin = tonumber(tCellValue.va_extra.data[2]) .. GetLocalizeStringBy("key_1687")
			end
			if( tCellValue.va_extra.data[4] )then
				coin = coin .. tCellValue.va_extra.data[4] .. GetLocalizeStringBy("lic_1843")
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= timeStr or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0xff,0xf6,0x00) }
		elseif(tStrId_columnIndex == 2 or tStrId_columnIndex == 3 )then
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
		elseif(tStrId_columnIndex == 6)then
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
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 3)then
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
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	elseif(tStrId_rowIndex == 4)then
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
				coin = tonumber(tCellValue.va_extra.data[3]) .. GetLocalizeStringBy("key_1687")
			end
			-- 精铁
			if( tCellValue.va_extra.data[6] )then
				coin = coin .. tCellValue.va_extra.data[6] .. GetLocalizeStringBy("lic_1843")
			end
			-- 战报
			local replay = tonumber(tCellValue.va_extra.replay)
			-- print(GetLocalizeStringBy("key_1392"),replay)
			textInfo[1] = { content= hero_name or " ", ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
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
	elseif(tStrId_rowIndex == 5)then
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
				coin = tonumber(tCellValue.va_extra.data[2]) .. GetLocalizeStringBy("key_1687")
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
		elseif( tStrId_columnIndex == 2 or tStrId_columnIndex == 4)then
			-- 39->资源矿协助 放弃 41->资源矿协助到期
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
				coin = tonumber(tCellValue.va_extra.data[2]) .. GetLocalizeStringBy("key_1687")
			end
			textInfo[1] = { content=templateData.content[1], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[2] = { content= hero_name or " ",ntype="button", fontSize=23, color=name_color, strokeSize=1,strokeColor=stroke_color, tag=tonumber(hero_uid) or 1,tapFunc=userFormationItemFun }
			textInfo[3] = { content=templateData.content[2], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[4] = { content= timeStr or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
			textInfo[5] = { content=templateData.content[3], ntype="label", fontSize=23, color=ccc3(0xff,0xfb,0xd9) }
			textInfo[6] = { content= coin or " ", ntype="label", fontSize=23, color=ccc3(0x70, 0xff, 0x18), strokeSize=1,strokeColor=ccc3(0x00, 0x00, 0x00)}
		else
			print("tStrId_columnIndex",tStrId_columnIndex,"tCellValue.template_id",tCellValue.template_id)
		end
	else
		print( "no add tCellValue.template_id",tCellValue.template_id)
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


-- 更多按钮
-- function moreItemCallFun( tag, item_obj )
-- 	print(GetLocalizeStringBy("key_2097") .. tag)
-- end

function nextCallFun( ... )
	-- 空方法
end


-- 创建更多邮件
function createMoreButtonItem()
	local normalSprite = BaseUI.createYellowBg(CCSizeMake(570,190))
    local selectSprite = BaseUI.createYellowSelectBg(CCSizeMake(570,190))
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







-- Filename：	GuildDynamicCell.lua
-- Author：		Cheng Liang
-- Date：		2013-12-22
-- Purpose：		动态cell

module("GuildDynamicCell", package.seeall)

require "script/libs/LuaCCLabel"

-- 头像按钮回调
function headIconItemCallFun( tag, itemBtn )
	-- 显示改玩家阵容
	require "script/ui/active/RivalInfoLayer"
    RivalInfoLayer.createLayer(tag)
end


function createCell(dynamicInfo)

	local tCell = CCTableViewCell:create()

	-- 背景
	local cellBg = CCScale9Sprite:create("images/common/bg/bg_9s_4.png")
	cellBg:setContentSize(CCSizeMake(640, 180))
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)

------- 头像
	require "script/model/utils/HeroUtil"
	local headMenu = CCMenu:create()
	headMenu:setPosition(ccp(0,0))
	cellBg:addChild(headMenu)
	
	local dressId = nil
	if(not table.isEmpty(dynamicInfo.user.dress) and (dynamicInfo.user.dress["1"]) and tonumber(dynamicInfo.user.dress["1"]) >0 )then
		dressId = tonumber(dynamicInfo.user.dress["1"])
	end

	local headIconSprite = HeroUtil.getHeroIconByHTID(dynamicInfo.user.htid, dressId)
	local headIconItem = CCMenuItemSprite:create(headIconSprite,headIconSprite)
	headIconItem:setAnchorPoint(ccp(0.5, 0.5))
	headIconItem:setPosition(ccp(75, 110))
	headMenu:addChild(headIconItem,1,tonumber(dynamicInfo.user.uid))
	-- 注册函数
	headIconItem:registerScriptTapHandler(headIconItemCallFun)

-------- 等级
	local lvBgSprite = CCScale9Sprite:create("images/common/bg/9s_5.png")
	lvBgSprite:setContentSize(CCSizeMake(90, 32))
	lvBgSprite:setAnchorPoint(ccp(0.5,0.5))
	lvBgSprite:setPosition(ccp(75, 40))
	cellBg:addChild(lvBgSprite)
	-- 等级图标
	local levelSprite = CCSprite:create("images/common/lv.png")
	levelSprite:setAnchorPoint(ccp(0, 0.5))
	levelSprite:setPosition(ccp(8, 16))
	lvBgSprite:addChild(levelSprite)
	-- 等级
	local levelLabel = CCRenderLabel:create(dynamicInfo.user.level, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke) --CCLabelTTF:create(dynamicInfo.user.level, g_sFontName, 21)
	levelLabel:setPosition(45, 15)
	levelLabel:setAnchorPoint(ccp(0, 0.5))
	levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	lvBgSprite:addChild(levelLabel)

--------- 时间
	local timeLabel = CCLabelTTF:create( TimeUtil.getTimeFormatYMDHMS(dynamicInfo.info.time), g_sFontName, 23)
	timeLabel:setPosition(135, 145)
	timeLabel:setAnchorPoint(ccp(0, 0.5))
	timeLabel:setColor(ccc3(0x78, 0x25, 0x00))
	cellBg:addChild(timeLabel)

	local m_height = 90
	if(tonumber(dynamicInfo.info.type) == 108)then
		-- 拜关公殿
		m_height = 100
		local textLabel = CCRenderLabel:create(getRewardStr( dynamicInfo ), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke) --CCLabelTTF:create(dynamicInfo.user.level, g_sFontName, 21)
		textLabel:setPosition(135, 70)
		textLabel:setAnchorPoint(ccp(0, 0.5))
		textLabel:setColor(ccc3(0xff,0xf6,0x00))
		cellBg:addChild(textLabel)
		
	end

	local text_arr = getContentStr(dynamicInfo)
	if(not table.isEmpty(text_arr))then

		local textNode = LuaCCLabel.createRichLabel(text_arr)
		cellBg:addChild(textNode)
		textNode:setAnchorPoint(ccp(0, 0.5))
		textNode:setPosition(ccp(135, 100))
		-- local offset_x = 135
		-- for k,d_text in pairs(text_arr) do
		-- 	if( tonumber(dynamicInfo.info.type) == 109 )then
		-- 		m_height = 100
		-- 		if(k>=7)then
		-- 			m_height = 70
		-- 			if(k == 7)then
		-- 				offset_x = 135
		-- 			end
		-- 		end
		-- 	end
		-- 	-- print(" d_text is ===== ",d_text.text )
		-- 	-- print_t(text_arr)

		-- 	local textLabel = CCRenderLabel:create(d_text.text, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke) --CCLabelTTF:create(dynamicInfo.user.level, g_sFontName, 21)
		-- 	textLabel:setPosition(offset_x, m_height)
		-- 	textLabel:setAnchorPoint(ccp(0, 0.5))
		-- 	textLabel:setColor(d_text.color)
		-- 	cellBg:addChild(textLabel)
		-- 	offset_x = offset_x + textLabel:getContentSize().width
		-- end
	end

	return tCell
end

local buildingArr = {GetLocalizeStringBy("key_1553"), GetLocalizeStringBy("key_1454"), GetLocalizeStringBy("key_3110"), GetLocalizeStringBy("key_1360"), GetLocalizeStringBy("key_4025") ,GetLocalizeStringBy("lic_1282")}

-- 解析关公殿获得的奖励
function getRewardStr( dynamicInfo )
	local rewardStr = ""
	local m_reward = dynamicInfo.info.reward
	if(m_reward.gold and tonumber(m_reward.gold) >0)then
		rewardStr = rewardStr .. GetLocalizeStringBy("key_1049") .. tonumber(m_reward.gold)
	end
	if(m_reward.silver and tonumber(m_reward.silver)>0)then
		rewardStr = rewardStr .. GetLocalizeStringBy("key_2363") .. tonumber(m_reward.silver)
	end
	if(m_reward.execution and tonumber(m_reward.execution)>0)then
		rewardStr = rewardStr .. GetLocalizeStringBy("key_2189") .. tonumber(m_reward.execution)
	end
	if(m_reward.stamina and tonumber(m_reward.stamina)>0)then
		rewardStr = rewardStr .. GetLocalizeStringBy("key_1116") .. tonumber(m_reward.stamina)
	end
	if(m_reward.prestige and tonumber(m_reward.prestige)>0)then
		rewardStr = rewardStr .. GetLocalizeStringBy("key_2962") .. tonumber(m_reward.prestige)
	end
	if(m_reward.soul and tonumber(m_reward.soul)>0)then
		rewardStr = rewardStr .. GetLocalizeStringBy("key_1688") .. tonumber(m_reward.soul)
	end
	
	
	return rewardStr
end

--  获得文案的显示
function getContentStr(dynamicInfo)
	local m_type = tonumber(dynamicInfo.info.type)
	local richInfo = {}
	richInfo.width = 480
	richInfo.alignment = 1
	richInfo.labelDefaultFont = g_sFontPangWa
	richInfo.labelDefaultSize = 23
	richInfo.defaultType = "CCRenderLabel"
	richInfo.defaultRenderType = type_stroke
	richInfo.elements = {}
	local text_arr = richInfo.elements
	if( m_type == 101)then
		-- 玩家加入军团
		-- 名字
		local dict_1 = {}
		dict_1.text = dynamicInfo.user.uname
		table.insert(text_arr, dict_1)
		-- 进入军团
		local dict_2 = {}
		dict_2.text = GetLocalizeStringBy("key_3052")
		dict_2.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_2)
	elseif(m_type == 102)then
		-- 玩家退出军团
		-- 名字
		local dict_1 = {}
		dict_1.text = dynamicInfo.user.uname
		dict_1.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_1)
		-- 退出军团
		local dict_2 = {}
		dict_2.text = GetLocalizeStringBy("key_1892")
		dict_2.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_2)
	elseif(m_type == 103)then
		-- 被踢出军团
		-- 名字
		local dict_1 = {}
		dict_1.text = dynamicInfo.info.uname
		dict_1.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_1)
		-- 
		local dict_2 = {}
		dict_2.text = GetLocalizeStringBy("key_1205")
		dict_2.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_2)
		-- 名字
		local dict_3 = {}
		dict_3.text = dynamicInfo.user.uname
		dict_3.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_3)
		-- 
		local dict_4 = {}
		dict_4.text = GetLocalizeStringBy("key_3159")
		dict_4.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_4)
	elseif(m_type == 104)then
		-- 弹劾军团长
		-- 名字
		local dict_1 = {}
		dict_1.text = dynamicInfo.user.uname
		dict_1.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_1)
		-- 
		local dict_2 = {}
		dict_2.text = GetLocalizeStringBy("key_1007")
		dict_2.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_2)
		-- 名字
		local dict_3 = {}
		dict_3.text = dynamicInfo.info.uname
		dict_3.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_3)
		-- 
		local dict_4 = {}
		dict_4.text = GetLocalizeStringBy("key_2559")
		dict_4.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_4)
	elseif(m_type == 105)then
		-- 职位任命
		-- 名字
		local dict_1 = {}
		dict_1.text = dynamicInfo.info.uname
		dict_1.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_1)
		-- 
		local dict_2 = {}
		dict_2.text = GetLocalizeStringBy("key_2606")
		dict_2.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_2)
		-- 名字
		local dict_3 = {}
		dict_3.text = dynamicInfo.user.uname
		dict_3.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_3)
		-- 
		local dict_4 = {}
		dict_4.text = GetLocalizeStringBy("key_1518")
		dict_4.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_4)
	elseif(m_type == 106)then
		-- 建筑升级
		-- 名字
		local dict_1 = {}
		dict_1.text = dynamicInfo.user.uname
		dict_1.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_1)
		-- 
		local dict_2 = {}
		dict_2.text = GetLocalizeStringBy("key_2432")
		dict_2.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_2)

		-- 建筑
		local dict_3 = {}
		dict_3.text = buildingArr[tonumber(dynamicInfo.info.upgrade.type)]
		dict_3.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_3)
		-- 
		local dict_4 = {}
		dict_4.text = GetLocalizeStringBy("key_2628")
		dict_4.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_4)
		-- 旧等级
		local dict_5 = {}
		dict_5.text = dynamicInfo.info.upgrade.oldLevel
		dict_5.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_5)
		--
		local dict_6 = {}
		dict_6.text = GetLocalizeStringBy("key_2711")
		dict_6.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_6)
		-- 新等级
		local dict_7 = {}
		dict_7.text = dynamicInfo.info.upgrade.newLevel
		dict_7.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_7)
		--
		local dict_8 = {}
		dict_8.text = GetLocalizeStringBy("key_2469")
		dict_8.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_8)
	elseif(m_type == 107)then
		-- 转让军团长
		-- 名字
		local dict_1 = {}
		dict_1.text = dynamicInfo.user.uname
		dict_1.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_1)
		-- 
		local dict_2 = {}
		dict_2.text = GetLocalizeStringBy("key_1098")
		dict_2.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_2)
		-- 名字
		local dict_3 = {}
		dict_3.text = dynamicInfo.info.uname
		dict_3.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_3)
	elseif(m_type == 108)then
		-- 职位任命
		-- 名字
		local dict_1 = {}
		dict_1.text = dynamicInfo.user.uname
		dict_1.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_1)
		-- 
		local dict_2 = {}
		dict_2.text = GetLocalizeStringBy("key_1666")
		dict_2.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_2)
	elseif(m_type == 109)then
		-- 贡献
		-- 名字
		local dict_1 = {}
		dict_1.text = dynamicInfo.user.uname
		dict_1.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_1)
		-- 
		local dict_2 = {}
		dict_2.text = GetLocalizeStringBy("key_1771")
		dict_2.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_2)

		-- 数量
		local num_text = 0
		local contribute_info = dynamicInfo.info.contribute
		if(contribute_info.silver and tonumber(contribute_info.silver)>0 )then
			num_text = contribute_info.silver .. GetLocalizeStringBy("key_1687")
		elseif(contribute_info.gold and tonumber(contribute_info.gold)>0 )then
			num_text = contribute_info.gold .. GetLocalizeStringBy("key_1491")
		end
		local dict_3 = {}
		dict_3.text = num_text
		dict_3.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_3)
		--
		local dict_4 = {}
		dict_4.text = GetLocalizeStringBy("key_3342")
		dict_4.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_4)
		--
		local dict_5 = {}
		dict_5.text = contribute_info.exp
		dict_5.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_5)
		--
		local dict_6 = {}
		dict_6.text = GetLocalizeStringBy("key_2859")
		dict_6.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_6)
		--
		local dict_7 = {}
		dict_7.text = GetLocalizeStringBy("key_2839")
		dict_7.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_7)
		--
		local dict_8 = {}
		dict_8.text = contribute_info.point
		dict_8.color = ccc3(0xff,0xff,0xff)
		table.insert(text_arr, dict_8)
		--
		local dict_9 = {}
		dict_9.text = GetLocalizeStringBy("key_1974")
		dict_9.color = ccc3(0xff,0xf6,0x00)
		table.insert(text_arr, dict_9)

	end

	return richInfo
end























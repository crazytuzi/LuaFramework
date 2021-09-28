-- Filename：	GuildMemberCell.lua
-- Author：		Cheng Liang
-- Date：		2013-12-22
-- Purpose：		成员cell

module("GuildMemberCell", package.seeall)

local _delegateFunc = nil
local _isChecked 	= false

local _curUid = nil

function createMemberCell(memberInfo, isChecked, delegateFunc)
	print("成员信息")
	print_t(memberInfo)
	_delegateFunc = delegateFunc

	isChecked = isChecked or false

	_isChecked = isChecked


	local tCell = CCTableViewCell:create()
	local cell_size = CCSizeMake(640, 186)
	if(isChecked == true)then
		cell_size = CCSizeMake(640, 186)
	else
		cell_size = CCSizeMake(640, 230)
	end

	local cellBgName = "images/common/bg/bg_9s_4.png"
	if(tonumber(memberInfo.uid) == UserModel.getUserUid() ) then
		cellBgName = "images/common/bg/bg_9s_5.png"
	end
	
	-- 背景
	local cellBg = CCScale9Sprite:create(cellBgName)
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setContentSize(cell_size)
	tCell:addChild(cellBg,1,1)

	-- 名称等级背景
	local name_level_bg = CCScale9Sprite:create("images/common/bg/9s_5.png")
	name_level_bg:setAnchorPoint(ccp(0, 0.5))
	name_level_bg:setContentSize(CCSizeMake(250, 27))
	name_level_bg:setPosition(ccp(125, 149))
	cellBg:addChild(name_level_bg)

	-- 名称
	local t_potential = HeroUtil.getHeroLocalInfoByHtid(memberInfo.htid).potential
	local nameLabel = CCLabelTTF:create(memberInfo.uname, g_sFontName, 21)
	nameLabel:setPosition(10, name_level_bg:getContentSize().height*0.5)
	nameLabel:setAnchorPoint(ccp(0, 0.5))
	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(t_potential))
	name_level_bg:addChild(nameLabel)

	-- 等级图标
	local levelSprite = CCSprite:create("images/common/lv.png")
	levelSprite:setAnchorPoint(ccp(0, 0.5))
	levelSprite:setPosition(ccp(178, name_level_bg:getContentSize().height*0.5))
	name_level_bg:addChild(levelSprite)

	-- 等级
	local levelLabel = CCLabelTTF:create(memberInfo.level, g_sFontName, 21)
	levelLabel:setPosition(213, name_level_bg:getContentSize().height*0.5)
	levelLabel:setAnchorPoint(ccp(0, 0.5))
	levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	name_level_bg:addChild(levelLabel)

	require "script/model/utils/HeroUtil"
	-- 头像
	local headMenu = CCMenu:create()
	headMenu:setPosition(ccp(0,0))
	cellBg:addChild(headMenu)

	local dressId = nil
	local genderId = nil
	if( not table.isEmpty(memberInfo.dress) and (memberInfo.dress["1"])~= nil and tonumber(memberInfo.dress["1"]) > 0 )then
		dressId = memberInfo.dress["1"]
		genderId = HeroModel.getSex(memberInfo.htid)
	end
	
	local headIconSprite = HeroUtil.getHeroIconByHTID(memberInfo.htid, dressId, genderId)
	local headIconItem = CCMenuItemSprite:create(headIconSprite,headIconSprite)
	headIconItem:setAnchorPoint(ccp(0.5, 0.5))
	headIconItem:setPosition(ccp(75, 110))
	headMenu:addChild(headIconItem,1,tonumber(memberInfo.uid))
	headIconItem:registerScriptTapHandler(headIconItemCallFun)


	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	-- menuBar:setTouchPriority(-)
	cellBg:addChild(menuBar)

	if(isChecked == true)then
		headIconItem:setPosition(ccp(75, 90))
		-- 战斗力图标
		local fightSprite = CCSprite:create("images/common/fight_value02.png")
		fightSprite:setAnchorPoint(ccp(0.5, 0.5))
		fightSprite:setPosition(ccp(185, 90))
		cellBg:addChild(fightSprite)
		local fightSpriteBg = CCScale9Sprite:create("images/common/bg/9s_5.png")
		fightSpriteBg:setAnchorPoint(ccp(0, 0.5))
		fightSpriteBg:setContentSize(CCSizeMake(185, 30))
		fightSpriteBg:setPosition(ccp(260, 88))
		cellBg:addChild(fightSpriteBg)
		-- 战斗力
		local fightLabel = CCRenderLabel:create(memberInfo.fight_force, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fightLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	   	fightLabel:setAnchorPoint(ccp(0,0.5))
	    fightLabel:setPosition(ccp(265, 90))
	    cellBg:addChild(fightLabel)


	    -- 竞技排名
	    local jinjiTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1670"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    jinjiTitleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	   	jinjiTitleLabel:setAnchorPoint(ccp(0.5,0.5))
	    jinjiTitleLabel:setPosition(ccp(185, 50))
	    cellBg:addChild(jinjiTitleLabel)
	    -- 排名
	    local rankText = nil
	    if(memberInfo.position) then
	    	rankText = memberInfo.position
	    else
	    	rankText = GetLocalizeStringBy("key_1554")
	    end

	    local jinjiSpriteBg = CCScale9Sprite:create("images/common/bg/9s_5.png")
		jinjiSpriteBg:setAnchorPoint(ccp(0, 0.5))
		jinjiSpriteBg:setContentSize(CCSizeMake(185, 30))
		jinjiSpriteBg:setPosition(ccp(260, 48))
		cellBg:addChild(jinjiSpriteBg)

	    local jingjiRankLabel = CCRenderLabel:create(rankText, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    jingjiRankLabel:setColor(ccc3(0x00, 0xe4, 0xff))
	   	jingjiRankLabel:setAnchorPoint(ccp(0,0.5))
	    jingjiRankLabel:setPosition(ccp(265, 50))
	    cellBg:addChild(jingjiRankLabel)

	    -- 同意按钮
		require "script/libs/LuaCC"
		local agreeBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_3260"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		agreeBtn:setAnchorPoint(ccp(0.5, 0.5))
		agreeBtn:registerScriptTapHandler(agreeAction)
		agreeBtn:setPosition(ccp(530, 125))
		menuBar:addChild(agreeBtn, 1, tonumber(memberInfo.uid) )

		-- 拒绝按钮
		require "script/libs/LuaCC"
		local refuseBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_3125"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		refuseBtn:setAnchorPoint(ccp(0.5, 0.5))
		refuseBtn:registerScriptTapHandler(refuseAction)
		refuseBtn:setPosition(ccp(530, 60))
		menuBar:addChild(refuseBtn, 1, tonumber(memberInfo.uid) )

	else
		-- 
		name_level_bg:setPosition(ccp(30, 195))
		-- 战斗力图标
		local fightSprite = CCSprite:create("images/common/fight_value02.png")
		fightSprite:setAnchorPoint(ccp(0, 0.5))
		fightSprite:setPosition(ccp(285, 190))
		cellBg:addChild(fightSprite)
		-- 战斗力
		local fightLabel = CCRenderLabel:create(memberInfo.fight_force, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fightLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	   	fightLabel:setAnchorPoint(ccp(0,0.5))
	    fightLabel:setPosition(ccp(365, 185))
	    cellBg:addChild(fightLabel)

	    -- 是否在线
	    local timeDistance = BTUtil:getSvrTimeInterval() - tonumber(memberInfo.last_logoff_time)
	    local ontimeText = ""
	    local ontimeColor = nil
	    if(tonumber(memberInfo.status) == 1)then
	    	ontimeText = GetLocalizeStringBy("key_2667")
	    	ontimeColor = ccc3(0x6c, 0xff, 0x00)
	    else 
	    	ontimeText = GetLocalizeStringBy("key_1192") .. TimeUtil.getTimeDisplayText(TimeUtil.getSvrTimeByOffset() - tonumber(memberInfo.last_logoff_time))
	    	ontimeColor = ccc3(0xad, 0xad, 0xad)
	    end
	    local ontimeLabel = CCRenderLabel:create(ontimeText, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    ontimeLabel:setColor(ontimeColor)
	   	ontimeLabel:setAnchorPoint(ccp(1,0.5))
	    ontimeLabel:setPosition(ccp(600, 190))
	    cellBg:addChild(ontimeLabel)

	    -- 今日贡献情况
	    local t_cotri_arr =  GuildUtil.getContriStringByInfo(memberInfo) -- GetLocalizeStringBy("key_1434")
	    local x_offset = 0
	    local t_label_arr = {}
	    for k, t_text in pairs(t_cotri_arr) do
	    	local t_cotri_text_label = CCRenderLabel:create(t_text.text, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    t_cotri_text_label:setColor(t_text.color)
		   	t_cotri_text_label:setAnchorPoint(ccp(0,0.5))
		    -- t_cotri_text_label:setPosition(ccp(610-x_offset, 30))
		    cellBg:addChild(t_cotri_text_label)
		    x_offset = t_cotri_text_label:getContentSize().width + x_offset
		    table.insert(t_label_arr, t_cotri_text_label)
	    end
	    local t_offset = 0
	    for k,t_text_label in pairs(t_label_arr) do
	    	t_text_label:setPosition(530-x_offset*0.5 + t_offset, 50)
	    	t_offset = t_text_label:getContentSize().width + t_offset
	    end

	    local fireText = GetLocalizeStringBy("key_1211")
	    local fireNum = 0

	    require "db/DB_Normal_config"
	    local n_data = DB_Normal_config.getDataById(1)
	    local timesArr = string.split(n_data.competeTimes,"|")

	    if(tonumber(memberInfo.uid) == UserModel.getUserUid())then
		    fireText = GetLocalizeStringBy("key_2321")
	    	fireNum = tonumber(timesArr[1]) - tonumber(memberInfo.playwith_num)
	    else
	    	fireText = GetLocalizeStringBy("key_1227")
	    	fireNum = tonumber(timesArr[2]) - tonumber(memberInfo.be_playwith_num)
	    end

	    -- 今日剩余切磋次数
	    local leftFireTimesTitleLabel = CCRenderLabel:create(fireText, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    leftFireTimesTitleLabel:setColor(ccc3( 0xff, 0xff, 0xff))
	   	leftFireTimesTitleLabel:setAnchorPoint(ccp(1,0.5))
	    leftFireTimesTitleLabel:setPosition(ccp(580, 160))
	    cellBg:addChild(leftFireTimesTitleLabel)
	    local leftFireTimesLabel = CCRenderLabel:create( fireNum , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    leftFireTimesLabel:setColor(ccc3( 0xff, 0xff, 0xff))
	   	leftFireTimesLabel:setAnchorPoint(ccp(0,0.5))
	    leftFireTimesLabel:setPosition(ccp(leftFireTimesTitleLabel:getContentSize().width, leftFireTimesTitleLabel:getContentSize().height*0.5))
	    leftFireTimesTitleLabel:addChild(leftFireTimesLabel)

	    -- 职位
	    if(tonumber(memberInfo.member_type) == 0)then
	    	-- 团员
	    	--local posLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2169"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    	local posLabel = CCRenderLabel:create(GuildDataCache.getGradeName(memberInfo.member_grade), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    local color = GuildDataCache.getGradeColorByType(memberInfo.member_grade)
		    posLabel:setColor(color)
		   	posLabel:setAnchorPoint(ccp(0.5,0.5))
		    posLabel:setPosition(ccp(75, 65))
		    cellBg:addChild(posLabel)
		else
			local posFile = nil
			if( tonumber(memberInfo.member_type)==1 )then
				posFile = "images/guild/memberList/leader.png"
			else --if( tonumber(memberInfo.member_type)==2 )then
				posFile = "images/guild/memberList/viceleader.png"
			end
			local posSprite = CCSprite:create(posFile)
			posSprite:setAnchorPoint(ccp(0.5, 0.5))
			posSprite:setPosition(ccp(75, 60))
			cellBg:addChild(posSprite)
	    end

	    -- 竞技排名
	    local jinjiSpriteBg = CCScale9Sprite:create("images/common/bg/9s_5.png")
		jinjiSpriteBg:setAnchorPoint(ccp(0, 0.5))
		jinjiSpriteBg:setContentSize(CCSizeMake(170, 30))
		jinjiSpriteBg:setPosition(ccp(260, 125))
		cellBg:addChild(jinjiSpriteBg)

	    local jinjiTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1670"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    jinjiTitleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	   	jinjiTitleLabel:setAnchorPoint(ccp(0.5,0.5))
	    jinjiTitleLabel:setPosition(ccp(205, 127))
	    cellBg:addChild(jinjiTitleLabel)
	    -- 排名
	    local rankText = nil
	    if(memberInfo.position) then
	    	rankText = memberInfo.position
	    else
	    	rankText = GetLocalizeStringBy("key_1554")
	    end
	    local jingjiRankLabel = CCRenderLabel:create(rankText, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    jingjiRankLabel:setColor(ccc3(0x00, 0xe4, 0xff))
	   	jingjiRankLabel:setAnchorPoint(ccp(0,0.5))
	    jingjiRankLabel:setPosition(ccp(5, jinjiSpriteBg:getContentSize().height*0.5))
	    jinjiSpriteBg:addChild(jingjiRankLabel)

	    -- 个人总贡献
	    local donateTotalTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2681"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    donateTotalTitleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	   	donateTotalTitleLabel:setAnchorPoint(ccp(1,0.5))
	    donateTotalTitleLabel:setPosition(ccp(255, 87))
	    cellBg:addChild(donateTotalTitleLabel)
	    -- 贡献
	    local donateTotalBg = CCScale9Sprite:create("images/common/bg/9s_5.png")
		donateTotalBg:setAnchorPoint(ccp(0, 0.5))
		donateTotalBg:setContentSize(CCSizeMake(170, 30))
		donateTotalBg:setPosition(ccp(260, 85))
		cellBg:addChild(donateTotalBg)

	    local donateTotalLabel = CCRenderLabel:create(memberInfo.contri_total, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    donateTotalLabel:setColor(ccc3(0x00, 0xff, 0x18))
	   	donateTotalLabel:setAnchorPoint(ccp(0,0.5))
	    donateTotalLabel:setPosition(ccp(5, donateTotalBg:getContentSize().height*0.5))
	    donateTotalBg:addChild(donateTotalLabel)

	    -- 总贡献排名
	    local contriRankFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1392"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    contriRankFont:setColor(ccc3(0xff, 0xe4, 0x00))
	   	contriRankFont:setAnchorPoint(ccp(1,0))
	    contriRankFont:setPosition(ccp(255, 37))
	    cellBg:addChild(contriRankFont)
	    -- 总贡献排名值
	    local contriRankNumFont = CCRenderLabel:create(memberInfo.contri_rank, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    contriRankNumFont:setColor(ccc3(0x00, 0xe4, 0xff))
	   	contriRankNumFont:setAnchorPoint(ccp(0,0))
	    contriRankNumFont:setPosition(ccp(contriRankFont:getPositionX(), contriRankFont:getPositionY()))
	    cellBg:addChild(contriRankNumFont)

	    if(tonumber(memberInfo.uid) == UserModel.getUserUid())then
	    	-- 竞技排名
	    	jinjiTitleLabel:setPosition(ccp(205, 138))
	    	jinjiSpriteBg:setPosition(ccp(260, 136))
	    	-- 总贡献
	    	donateTotalTitleLabel:setPosition(ccp(255, 100))
	    	donateTotalBg:setPosition(ccp(260, 98))
	    	contriRankFont:setPosition(ccp(255, 17))
	    	contriRankNumFont:setPosition(ccp(contriRankFont:getPositionX(), contriRankFont:getPositionY()))

		    -- 个人贡献
		    local donateTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2255"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    donateTitleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
		   	donateTitleLabel:setAnchorPoint(ccp(0.5,0.5))
		    donateTitleLabel:setPosition(ccp(205, 62))
		    cellBg:addChild(donateTitleLabel)
		    -- 贡献
		    local donateBg = CCScale9Sprite:create("images/common/bg/9s_5.png")
			donateBg:setAnchorPoint(ccp(0, 0.5))
			donateBg:setContentSize(CCSizeMake(170, 30))
			donateBg:setPosition(ccp(260, 60))
			cellBg:addChild(donateBg)
		    local donateLabel = CCRenderLabel:create(memberInfo.contri_point, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    donateLabel:setColor(ccc3(0x00, 0xff, 0x18))
		   	donateLabel:setAnchorPoint(ccp(0,0.5))
		    donateLabel:setPosition(ccp(265, 62))
		    cellBg:addChild(donateLabel)
		end

	    if(tonumber(memberInfo.member_type) == 1 and tonumber(memberInfo.uid) == UserModel.getUserUid())then

	    else
		    -- 军务按钮
			require "script/libs/LuaCC"
			local managerBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_1164"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			managerBtn:setAnchorPoint(ccp(0.5, 0.5))
			managerBtn:registerScriptTapHandler(guildManagerAction)
			managerBtn:setPosition(ccp(530, 110))
			menuBar:addChild(managerBtn, 1, tonumber(memberInfo.uid) )
		end
	end
	

	return tCell

end

-- 军务
function guildManagerAction(tag, itemBtn )
	local m_info = GuildDataCache.getMemberInfoBy(tag)
	require "script/ui/guild/GuildAffairsLayer"
	GuildAffairsLayer.showLayer(m_info)
end

-- 同意审核按钮
function agreeAction( tag, itemBtn )
	-- if(GuildDataCache.getGuildMemberNum() >= GuildUtil.getMaxMemberNum(GuildDataCache.getGuildInfo().guild_level))then
	-- 	AnimationTip.showTip(GetLocalizeStringBy("key_1294"))
	-- 	return
	-- end
	_curUid = tag
	local args = Network.argsHandler(_curUid)
	RequestCenter.guild_agreeApply(agreeCallback, args)
end

-- 拒绝审核按钮
function refuseAction( tag, itemBtn )
	_curUid = tag
	local args = Network.argsHandler(_curUid)
	RequestCenter.guild_refuseApply(refuseCallback, args)
end

-- 同意申请回调
function agreeCallback( cbFlag, dictData, bRet  )
	if(dictData.ret == "ok" or dictData.ret == "failed" )then
		MemberListLayer.deleteCheckedDataBy(_curUid)
		GuildDataCache.addGuildMemberNum(1)
		if(_delegateFunc)then
			_delegateFunc()
		end
		if(dictData.ret == "failed")then
			AnimationTip.showTip(GetLocalizeStringBy("key_1461"))
		end
	elseif(dictData.ret == "exceed")then
		AnimationTip.showTip(GetLocalizeStringBy("key_2284"))
	elseif(dictData.ret == "limited")then
		AnimationTip.showTip(GetLocalizeStringBy("key_2437"))
	elseif(dictData.ret == "forbidden_citywar") then
		-- 城池争夺战报名结束前一小时无法加入新成员
		AnimationTip.showTip(GetLocalizeStringBy("key_3134"))
	elseif(dictData.ret == "forbidden_guildrob") then
		-- 粮草抢夺战期间无法加入新成员
		AnimationTip.showTip(GetLocalizeStringBy("lic_1406"))
	else
	end
end

-- 拒绝申请回调
function refuseCallback( cbFlag, dictData, bRet  )
	if(dictData.ret == "ok"  or dictData.ret == "failed")then
		MemberListLayer.deleteCheckedDataBy(_curUid)
		if(_delegateFunc)then
			_delegateFunc()
		end
		if(dictData.ret == "failed")then
			AnimationTip.showTip(GetLocalizeStringBy("key_1461"))
		end
	end
end

-- 头像按钮回调
function headIconItemCallFun( tag, itemBtn )
	-- 显示改玩家阵容
	require "script/ui/active/RivalInfoLayer"
    RivalInfoLayer.createLayer(tag)
end


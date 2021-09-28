-- Filename：	Fight10BorderCell.lua
-- Author：		Cheng Liang
-- Date：		2013-7-2
-- Purpose：		战10次Cell

module("Fight10BorderCell", package.seeall)


require "script/model/utils/HeroUtil"


local textArr = {GetLocalizeStringBy("lic_1249"), GetLocalizeStringBy("key_2665"), GetLocalizeStringBy("key_2579"), GetLocalizeStringBy("key_1504"), GetLocalizeStringBy("key_2645"),  GetLocalizeStringBy("lic_1250"), GetLocalizeStringBy("key_2588"),GetLocalizeStringBy("lic_1251"), GetLocalizeStringBy("key_2525"), GetLocalizeStringBy("key_2065")}

local positionArr_y = {295, 295, 295, 420, 420, 420, 545, 545, 545, 670, 670, 670, 795, 795, 795, 920, 920, 920}
local positionArr_x = {102, 232, 362, 102, 232, 362, 102, 232, 362, 102, 232, 362, 102, 232, 362, 102, 232, 362}

-- index start with 1
function createCell(rewardData, cellSize, index, userLv, userExp, addExp, lastLv)
	local tCell = CCTableViewCell:create()

	-- 背景
	local bgSprite = CCSprite:create()
	bgSprite:setContentSize(cellSize)
	tCell:addChild(bgSprite)

	local siliverNum = rewardData.silver or 0
	local expNum = rewardData.exp or 0
	local soulNum = rewardData.soul or 0

	-- 头
	local topSprite = CCSprite:create("images/common/top.png") 
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(cellSize.width*0.5, cellSize.height-10))
	bgSprite:addChild(topSprite)

	-- 次数
	local countLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2886") .. textArr[index] .. GetLocalizeStringBy("key_3010"), g_sFontPangWa, 30, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    countLabel:setColor(ccc3(0x78, 0x25, 0x00))
    countLabel:setAnchorPoint(ccp(0.5, 0.5))
    countLabel:setPosition(ccp( topSprite:getContentSize().width*0.5, topSprite:getContentSize().height*0.5) )
    topSprite:addChild(countLabel)

    -- 获得银币
    local silverBg = CCScale9Sprite:create("images/common/bg/bg_9s_3.png")
	silverBg:setContentSize(CCSizeMake(400, 30))
	silverBg:setAnchorPoint(ccp(0.5, 1))
	silverBg:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height-40))
	bgSprite:addChild(silverBg)
	local silverTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2470"), g_sFontName, 24)
	silverTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	silverTitleLabel:setAnchorPoint(ccp(0, 0.5))
	silverTitleLabel:setPosition(ccp(80, silverBg:getContentSize().height*0.5))
	silverBg:addChild(silverTitleLabel)
	local silverSprite = CCSprite:create("images/common/coin.png")
	silverSprite:setAnchorPoint(ccp(0, 0.5))
	silverSprite:setPosition(ccp(220, silverBg:getContentSize().height*0.5))
	silverBg:addChild(silverSprite)
	local silverLabel = CCLabelTTF:create(siliverNum, g_sFontName, 24)
	silverLabel:setColor(ccc3(0x00, 0x00, 0x00))
	silverLabel:setAnchorPoint(ccp(0, 0.5))
	silverLabel:setPosition(ccp(260, silverBg:getContentSize().height*0.45))
	silverBg:addChild(silverLabel)

	-- 获得将魂
    local soulBg = CCScale9Sprite:create("images/common/bg/bg_9s_3.png")
	soulBg:setContentSize(CCSizeMake(400, 30))
	soulBg:setAnchorPoint(ccp(0.5, 1))
	soulBg:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height-80))
	bgSprite:addChild(soulBg)
	local soulTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1008"), g_sFontName, 24)
	soulTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	soulTitleLabel:setAnchorPoint(ccp(0, 0.5))
	soulTitleLabel:setPosition(ccp(80, soulBg:getContentSize().height*0.5))
	soulBg:addChild(soulTitleLabel)
	local soulSprite = CCSprite:create("images/common/icon_soul.png")
	soulSprite:setAnchorPoint(ccp(0, 0.5))
	soulSprite:setPosition(ccp(220, soulBg:getContentSize().height*0.5))
	soulBg:addChild(soulSprite)
	local soulLabel = CCLabelTTF:create(soulNum, g_sFontName, 24)
	soulLabel:setColor(ccc3(0x00, 0x00, 0x00))
	soulLabel:setAnchorPoint(ccp(0, 0.5))
	soulLabel:setPosition(ccp(260, soulBg:getContentSize().height*0.45))
	soulBg:addChild(soulLabel)

	-- 获得经验
    local expBg = CCScale9Sprite:create("images/common/bg/bg_9s_3.png")
	expBg:setContentSize(CCSizeMake(400, 30))
	expBg:setAnchorPoint(ccp(0.5, 1))
	expBg:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height-120))
	bgSprite:addChild(expBg)
	local soulTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2969"), g_sFontName, 24)
	soulTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	soulTitleLabel:setAnchorPoint(ccp(0, 0.5))
	soulTitleLabel:setPosition(ccp(80, expBg:getContentSize().height*0.5))
	expBg:addChild(soulTitleLabel)
	local soulSprite = CCSprite:create("images/common/exp.png")
	soulSprite:setAnchorPoint(ccp(0, 0.5))
	soulSprite:setPosition(ccp(200, expBg:getContentSize().height*0.5))
	expBg:addChild(soulSprite)
	local soulLabel = CCLabelTTF:create(expNum, g_sFontName, 24)
	soulLabel:setColor(ccc3(0x00, 0x00, 0x00))
	soulLabel:setAnchorPoint(ccp(0, 0.5))
	soulLabel:setPosition(ccp(260, expBg:getContentSize().height*0.45))
	expBg:addChild(soulLabel)

	require "script/ui/rechargeActive/ActiveCache"
    if ActiveCache.isWealActivityOpen(ActiveCache.WealType.MULT_COPY) then
        local DoubleExpEffect = XMLSprite:create("images/battle/report/effect/huodongfanbei")
        DoubleExpEffect:setPosition(ccpsprite(0.95, 0.5, expBg))
        expBg:addChild(DoubleExpEffect, 20)
    end

	-- 算
	local tempParam = {}
	tempParam.exp_num=userExp
	tempParam.add_exp_num=addExp
	tempParam.level=userLv

	local t_result  = UserModel.getUpgradingStatusIfAddingExp(tempParam)
	-- 等级
	local lvSprite = CCSprite:create("images/common/lv.png")
	lvSprite:setAnchorPoint(ccp(0, 1))
	lvSprite:setPosition(ccp(50, cellSize.height-165))
	bgSprite:addChild(lvSprite)
	local lvLabel = CCRenderLabel:create(t_result.level, g_sFontName, 21, 1, ccc3( 0x89, 0x00, 0x1a), type_stroke)
    lvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    lvLabel:setAnchorPoint(ccp(0, 1))
    lvLabel:setPosition(ccp( 90, cellSize.height-165) )
    bgSprite:addChild(lvLabel)
    -- 经验进度
    local expProgressSp = getExpProgress(t_result.ratio)
    expProgressSp:setAnchorPoint(ccp(0, 0.5))
	expProgressSp:setPosition(ccp(135, cellSize.height-175))
	bgSprite:addChild(expProgressSp)
	-- 是否升级
	if( tonumber(t_result.level) > tonumber(lastLv) )then
		local upSprite = CCSprite:create("images/common/up.png")
		upSprite:setAnchorPoint(ccp(0, 0.5))
		upSprite:setPosition(ccp(365, cellSize.height-175))
		bgSprite:addChild(upSprite)
	end

	-- line
	local lineSprite = CCScale9Sprite:create("images/common/line02.png")
	lineSprite:setContentSize(CCSizeMake(440, 4))
	lineSprite:setAnchorPoint(ccp(0.5, 0.5))
	lineSprite:setPosition(ccp(cellSize.width*0.5, cellSize.height-200))
	bgSprite:addChild(lineSprite)


-- 得到的物品和武将
	if( (not table.isEmpty(rewardData.item)) or (not table.isEmpty(rewardData.hero)))then
		-- 获得战利品
		local t_sprite = CCSprite:create("images/common/line2.png")
		t_sprite:setAnchorPoint(ccp(0.5, 0.5))
		t_sprite:setPosition(ccp(cellSize.width*0.5, cellSize.height - 225))
		bgSprite:addChild(t_sprite)
		local rewardTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2882"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    rewardTitleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	    rewardTitleLabel:setAnchorPoint(ccp(0.5, 0.5))
	    rewardTitleLabel:setPosition(ccp( t_sprite:getContentSize().width*0.5, t_sprite:getContentSize().height*0.5) )
	    t_sprite:addChild(rewardTitleLabel)
	end	

	local itemIndex = 0
	if( not table.isEmpty(rewardData.item) )then
		local rewardItemDict = {}
		for k, item_info in pairs(rewardData.item) do
			rewardItemDict[item_info.item_template_id] = item_info.item_num
		end
		for item_tmpl_id, item_num in pairs(rewardItemDict) do
			itemIndex = itemIndex + 1
			local itemBtn = ItemSprite.getItemSpriteById(tonumber(item_tmpl_id), nil, nil, false, -420)
	    	itemBtn:setAnchorPoint(ccp(0.5, 0.5))
	    	itemBtn:setPosition(ccp(positionArr_x[itemIndex], cellSize.height - positionArr_y[itemIndex]))
	    	bgSprite:addChild(itemBtn)
	    	-- 数量
	    	local numLabel = CCRenderLabel:create("x" .. item_num, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    numLabel:setColor(ccc3(0xff, 0xff, 0xff))
		    numLabel:setAnchorPoint(ccp(1,0))
		    numLabel:setPosition(ccp(itemBtn:getContentSize().width*0.95, 0))
		    itemBtn:addChild(numLabel)
	    	-- 名称
	    	local itemDesc = ItemUtil.getItemById(item_tmpl_id)
	    	local nameColor = HeroPublicLua.getCCColorByStarLevel(itemDesc.quality)
	    	local nameLabel = CCRenderLabel:create(itemDesc.name, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    nameLabel:setColor(nameColor)
		    nameLabel:setPosition(ccp(itemBtn:getContentSize().width*0.5 - nameLabel:getContentSize().width*0.5, 0))
		    itemBtn:addChild(nameLabel)
		end
	end
	if( not table.isEmpty(rewardData.hero) )then
		
		for htid, h_num in pairs(rewardData.hero) do
			itemIndex = itemIndex + 1
			local itemBtn = HeroUtil.getHeroIconByHTID( htid )
	    	itemBtn:setAnchorPoint(ccp(0.5, 0.5))
	    	itemBtn:setPosition(ccp(positionArr_x[itemIndex], cellSize.height - positionArr_y[itemIndex]))
	    	bgSprite:addChild(itemBtn)
	    	-- 数量
	    	local numLabel = CCRenderLabel:create("x" .. h_num, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    numLabel:setColor(ccc3(0xff, 0xff, 0xff))
		    numLabel:setAnchorPoint(ccp(1,0))
		    numLabel:setPosition(ccp(itemBtn:getContentSize().width*0.95, 0))
		    itemBtn:addChild(numLabel)
	    	-- 名字
	    	local heroDesc = HeroUtil.getHeroLocalInfoByHtid(htid)
	    	local nameColor = HeroPublicLua.getCCColorByStarLevel(heroDesc.potential)
	    	local nameLabel = CCRenderLabel:create(heroDesc.name, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    nameLabel:setColor(nameColor)
		    nameLabel:setPosition(ccp(itemBtn:getContentSize().width*0.5 - nameLabel:getContentSize().width*0.5, 0))
		    itemBtn:addChild(nameLabel)

		end
	end

	return tCell
end


function getExpProgress( rate )
	local m_width = 220
	local bgProress = CCScale9Sprite:create("images/common/exp_bg.png")
	bgProress:setContentSize(CCSizeMake(m_width, 23))
	bgProress:setAnchorPoint(ccp(0.5, 0.5))
	if(UserModel.hasReachedMaxLevel() == true)then
		local maxSprrite = CCSprite:create("images/common/max.png")
		maxSprrite:setAnchorPoint(ccp(0.5, 0.5))
		maxSprrite:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height * 0.5))
		bgProress:addChild(maxSprrite)
	else
		local progressSp = CCScale9Sprite:create("images/common/exp_progress.png")
		progressSp:setContentSize(CCSizeMake(m_width * rate, 23))
		progressSp:setAnchorPoint(ccp(0, 0.5))
		progressSp:setPosition(ccp(0, bgProress:getContentSize().height * 0.5))
		bgProress:addChild(progressSp)
	end

	return bgProress
end

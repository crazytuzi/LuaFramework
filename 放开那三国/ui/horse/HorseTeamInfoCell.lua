-- Filename：	HorseTeamInfoCell.lua
-- Author：		llp
-- Date：		2016-4-7
-- Purpose：		小队信息cell

module ("HorseTeamInfoCell", package.seeall)

require "script/ui/teamGroup/TeamGruopService"

local spriteTable = {"images/horse/self.png","images/horse/help.png"}

-- 邀请人的按钮
function angryMenuAction( tag,item)
	require "script/ui/horse/HorseInviteDialog"
	require "script/ui/horse/HorseData"
	if(tonumber(tag)>UserModel.getGoldNumber())then
        LackGoldTip.showTip(-5000)
        return
    end
	HorseController.openRage(item.type,tag )
end


function createCell( cellValues, touchPriority ,pIndex)

	local tCell = CCTableViewCell:create()
	local fullRect = CCRectMake(0, 0, 578, 158)
    local insetRect = CCRectMake(100, 60, 10, 10)
	cellBg= CCScale9Sprite:create("images/copy/guildcopy/team_frame_4.png",fullRect, insetRect)
	cellBg:setPreferredSize(CCSizeMake(578,213) )
	tCell:addChild(cellBg)


	local nameBgFile= "images/common/bg/bg_9s_blue.png"
	local nameBg1= CCScale9Sprite:create(nameBgFile)
	nameBg1:setContentSize(CCSizeMake( 270, 33))
	nameBg1:setPosition(120, 118)
	nameBg1:setAnchorPoint(ccp(0,0))
	cellBg:addChild(nameBg1)

	local nameBg2= CCScale9Sprite:create(nameBgFile)
	nameBg2:setContentSize(CCSizeMake( 270, 33))
	nameBg2:setPosition(120, 77)
	nameBg2:setAnchorPoint(ccp(0,0))
	cellBg:addChild(nameBg2)

	local nameBg3 = CCScale9Sprite:create(nameBgFile)
	nameBg3:setContentSize(CCSizeMake( 270, 33))
	nameBg3:setPosition(120, 36)
	nameBg3:setAnchorPoint(ccp(0,0))
	cellBg:addChild(nameBg3)

	local nameStr= cellValues.uname
	local htid = tonumber(cellValues.htid)
	local level = cellValues.level
	local fightForce= cellValues.fight_force
	local guildName= cellValues.guild_name or nil

	local dressId= nil
	local uid= tonumber(cellValues.uid)
	if(cellValues.dress and cellValues.dress[1]) then
		dressId = tonumber(cellValues.dress[1]) 
	end

	-- -- 头像
	local vip = cellValues.vip or 0
	local headIcon = HeroUtil.getHeroIconByHTID(htid, dressId, nil, vip) 
	-- local headItem = CCMenItemSprite:create(headIcon,headIcon)
	headIcon:setPosition(9,57)
	cellBg:addChild(headIcon)

	local sprite = CCSprite:create(spriteTable[pIndex])
		  sprite:setAnchorPoint(ccp(0.1,0.5))
		  sprite:setPosition(ccp(0,headIcon:getContentSize().height-15))
	headIcon:addChild(sprite)
	
	-- -- 名字
	local nameLabel = CCRenderLabel:create( nameStr , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setPosition(139,122)
	nameLabel:setAnchorPoint(ccp(0,0))
	cellBg:addChild(nameLabel)

	-- 军团名
	if(guildName) then
		local guildNameLabel = CCRenderLabel:create( " [" .. guildName .. "]" , g_sFontName, 24,1, ccc3(0x00,0x00,0x00), type_stroke)
		guildNameLabel:setColor(ccc3(0xff,0xf6,0x00) )
		guildNameLabel:setPosition(ccp(139, 81))
		guildNameLabel:setAnchorPoint(ccp(0,0))
		cellBg:addChild(guildNameLabel)
	end

	-- 等级
	local lvSp= CCSprite:create("images/common/lv.png")
	local levelLabel = CCRenderLabel:create(tostring(level),  g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	levelLabel:setColor(ccc3(0xff,0xf6,0x00))
	local levelNode =BaseUI.createHorizontalNode({lvSp,levelLabel})
	levelNode:setPosition(headIcon:getContentSize().width/2 ,2)
	levelNode:setAnchorPoint(ccp(0.5,1))
	headIcon:addChild(levelNode)

	-- 战斗力
	local fightSp= CCSprite:create("images/common/fight_value.png")
	local fightForceLabel = CCRenderLabel:create(tostring(fightForce) , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	fightForceLabel:setColor(ccc3(0x00,0xff,0x18))
	local fightNode= BaseUI.createHorizontalNode({fightSp,fightForceLabel})
	fightNode:setPosition(139,36)
	fightNode:setAnchorPoint(ccp(0,0))
	cellBg:addChild(fightNode)

	-- 邀请按钮
	local menuBar= CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(touchPriority)
	cellBg:addChild(menuBar)
	require "db/DB_Mnlm_rule"
    local dbInfo = DB_Mnlm_rule.getDataById(1)
    local costData = string.split(dbInfo.rage_cost,"|")
	if(tonumber(cellValues.have_rage)==1)then
		local rageSprite = CCSprite:create("images/horse/rage.png")
			  rageSprite:setPosition(445, 58)
		cellBg:addChild(rageSprite)
	else
		local uid = UserModel.getUserUid()
		if(cellValues.lookuid==uid)then
			local force_occupy_btn_info = {
	        normal = "images/common/btn/btn_blue_n.png",
	        selected = "images/common/btn/btn_blue_h.png",
	        size = CCSizeMake(170, 73),
	        text_size = 25,
	        icon = "images/common/gold.png",
	        text = GetLocalizeStringBy("llp_387"),
	        number = tostring(costData[1])
		    }
		    
			rageItem = LuaCCSprite.createNumberMenuItem(force_occupy_btn_info)
			rageItem.type = pIndex
			menuBar:addChild(rageItem)
			rageItem:setTag(tonumber(costData[1]))
			rageItem:registerScriptTapHandler(angryMenuAction)
			rageItem:setPosition(400, 58)
		else

		end
	end

	return tCell
end



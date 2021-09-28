-- FileName: MatchEnemyCell.lua 
-- Author: Li Cong 
-- Date: 13-11-11 
-- Purpose: function description of module 


module("MatchEnemyCell", package.seeall)


-- 创建仇人单元格
function createCell( tCellValue )
	print(GetLocalizeStringBy("key_2154"))
	print_t(tCellValue)

	local cell = CCTableViewCell:create()
	-- 背景
	local cellBg = CCSprite:create("images/match/enemy_bg.png")
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(ccp(0,0))
	cell:addChild(cellBg,1)

	-- 玩家名字
	-- 名字背景
	local fullRect = CCRectMake(0,0,47,27)
	local insetRect = CCRectMake(15,12,5,5)
	local name_bg = CCScale9Sprite:create("images/arena/heroname_bg.png", fullRect, insetRect)
	name_bg:setContentSize(CCSizeMake(248,26))
	name_bg:setAnchorPoint(ccp(0,1))
	name_bg:setPosition(ccp(20,cellBg:getContentSize().height-15))
	cellBg:addChild(name_bg)
	-- lv.
	local lv_sprite = CCSprite:create("images/common/lv.png")
	lv_sprite:setAnchorPoint(ccp(0,0.5))
	lv_sprite:setPosition(ccp(10,name_bg:getContentSize().height*0.5))
	name_bg:addChild(lv_sprite)
	-- 等级
	local lv_data = CCRenderLabel:create( tCellValue.level , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,name_bg:getContentSize().height-3))
   	name_bg:addChild(lv_data)
   	-- 名字
   	local name = CCRenderLabel:create( tCellValue.uname , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    name:setColor(ccc3(0xff, 0xff, 0xff))
    name:setPosition(ccp(lv_data:getPositionX()+lv_data:getContentSize().width+18,name_bg:getContentSize().height-1))
   	name_bg:addChild(name)

   	local zhan = CCSprite:create("images/arena/zhan.png")
    zhan:setAnchorPoint(ccp(0,1))
    zhan:setPosition(ccp(name_bg:getPositionX()+name_bg:getContentSize().width+55,cellBg:getContentSize().height-12))
    cellBg:addChild(zhan)
    local zhan_data = CCRenderLabel:create( tCellValue.fight_force, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    zhan_data:setColor(ccc3(0xff,0xf6,0x00))
    zhan_data:setPosition(ccp(zhan:getPositionX()+zhan:getContentSize().width+7,cellBg:getContentSize().height-12))
    cellBg:addChild(zhan_data)

	-- 复仇按钮
	local enemyMenu = BTSensitiveMenu:create()
    if(enemyMenu:retainCount()>1)then
        enemyMenu:release()
        enemyMenu:autorelease()
    end
	enemyMenu:setPosition(ccp(0,0))
	cellBg:addChild(enemyMenu)
	local enemyMenuItem = CCMenuItemImage:create("images/common/btn/btn_violet_n.png","images/common/btn/btn_violet_h.png")
	enemyMenuItem:setAnchorPoint(ccp(1,0.5))
	enemyMenuItem:setPosition(ccp(cellBg:getContentSize().width-20, cellBg:getContentSize().height*0.5))
	enemyMenu:addChild(enemyMenuItem,1,tonumber(tCellValue.uid))
	-- 注册挑战回调
	enemyMenuItem:registerScriptTapHandler(enemyMenuItemCallFun)
	-- 复仇字体
	local enemy_font = CCRenderLabel:create( GetLocalizeStringBy("key_2973") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    enemy_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    enemy_font:setPosition(ccp(24,enemyMenuItem:getContentSize().height-11))
   	enemyMenuItem:addChild(enemy_font)

   	-- 名将背景
   	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
   	local hero_bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
   	hero_bg:setContentSize(CCSizeMake(444,100))
   	hero_bg:setAnchorPoint(ccp(0,0.5))
   	hero_bg:setPosition(ccp(23,cellBg:getContentSize().height*0.5))
   	cellBg:addChild(hero_bg)

    -- added by zhz , vip 特效
    local vip= tCellValue.vip or 0

   	-- 创建名将头像
   	local numTem = 0
   	for k,v in pairs(tCellValue.squad) do
   		numTem = numTem + 1
        local dressId = nil
        local genderId = nil
        if( not table.isEmpty(v.dress) and (v.dress["1"])~= nil and tonumber(v.dress["1"]) > 0 )then
            dressId = v.dress["1"]
            genderId = HeroModel.getSex(v.htid)
        end
        local heroIcon = HeroUtil.getHeroIconByHTID(v.htid, dressId, genderId, vip)
   		heroIcon:setAnchorPoint(ccp(0,0.5))
   		heroIcon:setPosition(ccp(37+(heroIcon:getContentSize().width+45)*(numTem-1),hero_bg:getContentSize().height*0.5))
   		hero_bg:addChild(heroIcon,1,numTem)
   	end

	return cell
end


-- 复仇按钮回调
function enemyMenuItemCallFun(tag, item_obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 判断是否开启比武 为true 是休息
    if( MatchData.getIsOverMatchTime() == false )then
        require "script/ui/tip/AnimationTip"
        local str = GetLocalizeStringBy("key_1578")
        AnimationTip.showTip(str)
        return 
    end
    -- 剩余次数是否足够
    if( MatchData.getContestNum() <= 0)then
        -- 比武次数已用完
        require "script/ui/tip/AnimationTip"
        local str = GetLocalizeStringBy("key_1027")
        AnimationTip.showTip(str)
        return
    end
    -- 判断背包是否满了
    if(ItemUtil.isBagFull() == true )then
        return
    end
    -- 耐力是否足够
    if( (UserModel.getStaminaNumber()-2)  < 0 )then
        -- 挑战次数已用完
        -- require "script/ui/tip/AnimationTip"
        -- local str = GetLocalizeStringBy("key_3157")
        -- AnimationTip.showTip(str)
        require "script/ui/item/StaminaAlertTip"
        StaminaAlertTip.showTip( MatchLayer.refreshMatchGold )
        return
    end
    -- 判断武将满了
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return
    end
    -- 对手数据
    local enemyData = MatchData.getInfoByEnemyUid(tag)
    -- 此处不用计算胜利获得的分数了  后端传
    -- local winScore = MatchData.getWinScore(enemyData.point)
    -- 敌人失败后扣除的积分
    -- local loseScore = MatchData.getLoseScore( enemyData.point )
    -- 满足条件后逻辑处理
    local function createNextFun( atk, flopData, rank, myPoint, suc_point )
        local exp = nil
        local honor = nil
        if(atk.appraisal ~= "E" and atk.appraisal ~= "F")then
            -- 胜利 
            exp = MatchData.getExpForWin()
            honor = MatchData.getHonorForWin()
            -- 扣除敌人身上的积分
            -- MatchData.setEnemyScore(tag, loseScore)
        else
            -- 失败
            exp = MatchData.getExpForFail()
            honor = 0
        end
        local function nextCallFun()
            -- 加经验
            UserModel.addExpValue(exp,"matchenemy")
            -- 如果抽取的是抢夺或银币 加银币
            if(flopData ~= nil)then
                for k,v in pairs(flopData) do
                    if(k == "real")then
                        for i,j in pairs(v) do
                            if(i == "rob")then
                                -- 加银币
                                UserModel.addSilverNumber(tonumber(j))
                                if(MatchLayer._silverLabel ~= nil)then
                                    MatchLayer._silverLabel:setString( string.convertSilverUtilByInternational(UserModel.getSilverNumber()) )
                                end
                            elseif(i == "silver")then
                                -- 加银币
                                UserModel.addSilverNumber(tonumber(j))
                                if(MatchLayer._silverLabel ~= nil)then
                                    MatchLayer._silverLabel:setString( string.convertSilverUtilByInternational(UserModel.getSilverNumber()) )
                                end
                            elseif(i == "soul")then
                                -- 加将魂
                                UserModel.addSoulNum(tonumber(j))
                            elseif(i == "gold")then
                                -- 加金币
                                UserModel.addGoldNumber(tonumber(j))
                                if(MatchLayer._goldLabel ~= nil)then
                                    MatchLayer._goldLabel:setString( UserModel.getGoldNumber() )  
                                end  
                            end
                        end
                    end
                end
            end
            -- 更新积分
            if(atk.appraisal ~= "E" and atk.appraisal ~= "F")then
                -- 胜利
                if(myPoint)then 
                    MatchData.setMyScore( myPoint )
                end
                -- 胜利后 删除该仇人 刷新列表
                MatchData.deleteEnemybyUid(tag)
                -- 刷新列表
                MatchEnemy._enemyTableView:reloadData()
                -- 加荣誉
                MatchData.addHonorNum(honor)
            end
            -- 更新排名
            if( rank ~= nil )then
                MatchData.setMyRank(rank)
            end
            -- 发战斗结束通知
            -- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
        end
        -- 调用战斗接口 参数:atk 
        require "script/battle/BattleLayer"
        require "script/ui/common/CafterBattleLayer"
         local function afterOKcallFun()
            local str = nil
            if(atk.appraisal ~= "E" and atk.appraisal ~= "F")then
                -- 胜利 
                local winScore = suc_point or " "
                str = GetLocalizeStringBy("key_2194") .. winScore .. GetLocalizeStringBy("key_2275") .. honor .. GetLocalizeStringBy("lic_1113")
            end
            -- 返回后提示
            if(str ~= nil)then
                require "script/ui/tip/AnimationTip"
                AnimationTip.showTip(str)
            end
        end
        -- createAfterBattleLayer( appraisal, enemyUid, enemyName, enemyUtid, enemyFightData, silverData, expData, flopData, CallFun )
        local afterBattleLayer = CafterBattleLayer.createAfterBattleLayer( atk.appraisal, tag, enemyData.uname, enemyData.utid, enemyData.fight_force, honor, exp, flopData, afterOKcallFun, atk.fightRet)
        BattleLayer.showBattleWithString(atk.fightRet, nextCallFun, afterBattleLayer,"ducheng.jpg","music11.mp3",nil,nil,nil,true)
    end
    -- addby chengliang
    PreRequest.setIsCanShowAchieveTip(false)

    MatchService.contest(tag, 1, createNextFun)
end

















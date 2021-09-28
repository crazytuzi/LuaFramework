-- Filename：    RankCell.lua
-- Author：      DJN
-- Date：        2014-9-4
-- Purpose：     排行榜系统cell

module("RankCell", package.seeall)
local _tagFightForce        = 2001
local _tagLevel             = 2002
local _tagCopy              = 2003
local _tagPet               = 2004
local _tagGuild             = 2005
local _tagMatch             = 2006
local _tagTower             = 2007
local _tagAren              = 2008
local _curTag               = nil
--点击user头像后回调需要的参数

local _uname = nil
local _ulevel = nil
local _power = nil
local _uid = nil
local _uGender = nil
local _htid = nil
local _dressInfo = nil

-- 军团长名字颜色、cell背景、名次背景
function getHeroNameColor( tCellValue )
    local cellBg = nil
    local name_color = nil
    local rank_font = nil
    local rank = nil
    if(_curTag == _tagAren)then
        rank = tCellValue.position
    else
        rank = tCellValue.rank
    end

    if( tonumber(rank) == 1 )then
        cellBg = CCSprite:create("images/rank/bg_1.png")
        name_color= ccc3(0xf9,0x59,0xff)
        rank_font = CCSprite:create("images/match/one.png")
    elseif( tonumber(rank) == 2 )then
        cellBg = CCSprite:create("images/rank/bg_2.png")
        name_color= ccc3(0x00,0xe4,0xff)
        rank_font = CCSprite:create("images/match/two.png")
    elseif( tonumber(rank) == 3 )then
        cellBg = CCSprite:create("images/rank/bg_3.png")
        name_color= ccc3(0x70, 0xff, 0x18)
        rank_font = CCSprite:create("images/match/three.png")
    else
        cellBg = CCSprite:create("images/rank/bg_4.png")
        name_color= ccc3(0xff,0xff,0xff)
    end

    return name_color, cellBg , rank_font
end
--[[
    @des    :点击user头像回调
    @param  :
    @return :
--]]
function userFormationItemFun(tag)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/chat/ChatUserInfoLayer"
    require "db/DB_Heroes"
    local allInfo  = (RankLayer:getTabViewInfo())[tag]
        _uname = allInfo.uname
        _ulevel = allInfo.level
        _power = allInfo.fight_force
        _uid = allInfo.uid
        
        if((_curTag == _tagFightForce )or( _curTag == _tagLevel) )then
            _uGender = HeroModel.getSex(allInfo.htid)
            _htid = allInfo.htid
            _dressInfo = allInfo.dressInfo
        elseif( _curTag == _tagCopy or _curTag == _tagTower)then
            _uGender = HeroModel.getSex(allInfo.htid)
            _htid = allInfo.htid
            _dressInfo = allInfo.dress
        elseif(_curTag == _tagMatch or _curTag == _tagAren)then
            _uGender = HeroModel.getSex(allInfo.squad[1].htid)
            _htid = allInfo.squad[1].htid
            _dressInfo = allInfo.squad[1].dress
        end


    local hero = DB_Heroes.getDataById(_htid)
    local imageFile = hero.head_icon_id
    ChatUserInfoLayer.showChatUserInfoLayer(_uname,_ulevel,_power,"images/base/hero/head_icon/" .. imageFile,_uid,_uGender,_htid,_dressInfo,RankLayer.getTouchPriority()-10)
end

--[[
    @des    :创建cell
    @param  :排名信息，menu的tag
    @return :
--]]
function createCell( tCellValue,lineNum)
    -- print("cell数据tCellValue:")
    -- print_t(tCellValue)
    --记录当前tag
    _curTag = RankLayer.getCurTag()
    -- 创建cell
    local cell = CCTableViewCell:create()
    -- 获取名字颜色、cell背景、名次背景
    local name_color,cellBg,rank_font= getHeroNameColor( tCellValue )

    -- 获取当前玩家所在军团排行和战力
    --local user_guild_rank , user_guild_fight_force= RankData.getUserRankGuildInfo()
    -- cell背景
    cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(0,0))
    cell:setScale(g_fScaleX)
    cell:addChild(cellBg)

    -- 名次不在前三的情况
    if( rank_font==nil )then
        -- 排名
        local rank_data = " "
        --if(tCellValue.rank)then
            if(_curTag == _tagAren)then
                rank_data = tonumber(tCellValue.position)
            elseif(tCellValue.rank~= nil)then
                rank_data = tonumber(tCellValue.rank)
            end
        rank_font = CCRenderLabel:create( rank_data, g_sFontPangWa, 50, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        rank_font:setColor(ccc3(0xff, 0xf6, 0x00))
    end
    rank_font:setAnchorPoint(ccp(0.5,0.5))
    rank_font:setPosition(ccp(53,cellBg:getContentSize().height*0.5))
    cellBg:addChild(rank_font)

    --“名”汉字
    local ming = CCSprite:create("images/match/ming.png")
    ming:setAnchorPoint(ccp(0,0))
    ming:setPosition(ccp(90,20))
    cellBg:addChild(ming)
    -- 按钮
    local menu = BTSensitiveMenu:create()
    if(menu:retainCount()>1)then
        menu:release()
        menu:autorelease()
    end
    menu:setPosition(ccp(0,0))
    cellBg:addChild(menu)
     -----一些界面的头像创建方法完全相同 
    -- if( ((tonumber(tag) == tonumber(_tagFightForce)) or ((tonumber(tag) == tonumber(_tagLevel)) or ((tonumber(tag) == tonumber(_tagMatch)) or
    --     ((tonumber(tag) == tonumber(_tagTower)) or ((tonumber(tag) == tonumber(_tagAren)) or ((tonumber(tag) == tonumber(_tagCopy)) )then
    -- if( ((tonumber(tag) == tonumber(_tagFightForce)) or ((tonumber(tag) == tonumber(_tagLevel)) or ((tonumber(tag) == tonumber(_tagMatch)) or
    --     ((tonumber(tag) == tonumber(_tagTower)) or ((tonumber(tag) == tonumber(_tagAren)) or ((tonumber(tag) == tonumber(_tagCopy)) )then
    -- if( (tonumber(tag) == tonumber(_tagMatch)) )then

    --     --头像
    --     local icon_bg = CCSprite:create("images/match/head_bg.png")
    --     icon_bg:setAnchorPoint(ccp(0,0.5))
    --     icon_bg:setPosition(ccp(138,cellBg:getContentSize().height*0.5))
    --     cellBg:addChild(icon_bg)
    --     local iconMenu = CCMenu:create()
    --     iconMenu:setTouchPriority(-555)
    --     iconMenu:setPosition(ccp(0,0))
    --     icon_bg:addChild(iconMenu)
    --     require "script/model/utils/HeroUtil"
    --     local dressId = nil
    --     local genderId = nil
    --     if( not table.isEmpty(tCellValue.dressInfo) and (tCellValue.dressInfo["1"])~= nil and tonumber(tCellValue.dressInfo["1"]) > 0 )then
    --         dressId = tCellValue.dressInfo["1"]
    --         genderId = HeroModel.getSex(tCellValue.htid)
    --     end

    --      --vip 特效
    --     local vip = tCellValue.vip or 0
    --     print("创建前输出参数",tCellValue.htid,"**",dressId,"**",dressId)
    --     local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.htid, dressId, dressId)
    --     local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
    --     heroIconItem:setAnchorPoint(ccp(0.5,0.5))
    --     heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
    --     iconMenu:addChild(heroIconItem,1,tonumber( tCellValue.uid ))
    --     --------绑定点击回调  暂时没做
    --     --heroIconItem:registerScriptTapHandler(userFormationItemFun)s
    -- end
    ---------------------------------------------------下面是对不同的tag创建各自的UI------------------------------
    if(tonumber(_curTag) == tonumber(_tagFightForce))then -----个人战斗力

        -- _uname = tCellValue.uname
        -- _ulevel = tCellValue.level
        -- _power = tCellValue.fight_force
        -- _uid = tCellValue.uid
        -- _uGender = HeroModel.getSex(tCellValue.htid)
        -- _htid = tCellValue.htid
        -- _dressInfo = tCellValue.dressInfo
        --头像
        local icon_bg = CCSprite:create("images/match/head_bg.png")
        icon_bg:setAnchorPoint(ccp(0,0.5))
        icon_bg:setPosition(ccp(138,cellBg:getContentSize().height*0.5))
        cellBg:addChild(icon_bg)
        local iconMenu = CCMenu:create()
        iconMenu:setTouchPriority(-555)
        iconMenu:setPosition(ccp(0,0))
        icon_bg:addChild(iconMenu)
        require "script/model/utils/HeroUtil"
        local dressId = nil
        local genderId = nil
        if( not table.isEmpty(tCellValue.dressInfo) and (tCellValue.dressInfo["1"])~= nil and tonumber(tCellValue.dressInfo["1"]) > 0 )then
            dressId = tCellValue.dressInfo["1"]
            genderId = HeroModel.getSex(tCellValue.htid)
        end

         --vip 特效
        local vip = tCellValue.vip or 0
        --print("创建前输出参数",tCellValue.htid,"**",dressId,"**",dressId)
        local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.htid, dressId, dressId,vip)
        local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
        heroIconItem:setAnchorPoint(ccp(0.5,0.5))
        heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
        iconMenu:addChild(heroIconItem,1,lineNum)
        
        heroIconItem:registerScriptTapHandler(userFormationItemFun)

        -- lv.
        local lv_sprite = CCSprite:create("images/common/lv.png")
        lv_sprite:setAnchorPoint(ccp(0,1))
        lv_sprite:setPosition(ccp(320,cellBg:getContentSize().height-10))
        cellBg:addChild(lv_sprite)
        -- 等级
        local lvStr = tCellValue.level or " "
        local lv_data = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        lv_data:setAnchorPoint(ccp(0,1))
        lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
        lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cellBg:getContentSize().height-4))
        cellBg:addChild(lv_data)
        -- 名字
        local nameStr = tCellValue.uname or " "
        local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        name:setColor(name_color)
        name:setAnchorPoint(ccp(0.5,0))
        name:setPosition(ccp(361,42))
        cellBg:addChild(name)
        -- 军团名字
        if(tCellValue.guild_name ~= nil )then
            local guildStr = tCellValue.guild_name
            local guildname = CCRenderLabel:create("("..guildStr..")" , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            guildname:setColor(ccc3(0xff, 0xf6, 0x00))
            guildname:setAnchorPoint(ccp(0.5,0))
            guildname:setPosition(ccp(361,10))
            cellBg:addChild(guildname)
        end

        -- 战斗力图片
        local fightDesc = CCSprite:create("images/common/fight_value.png")
        fightDesc:setAnchorPoint(ccp(1,1))
        fightDesc:setColor(ccc3(0xff,0xff,0xff))
        fightDesc:setPosition(ccp(585,cellBg:getContentSize().height-20))
        cellBg:addChild(fightDesc)
        local fightForce = tonumber(tCellValue.fight_force)or " "
        local myScore_Data = CCRenderLabel:create(fightForce, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        myScore_Data:setAnchorPoint(ccp(0.5,0))
        myScore_Data:setColor(ccc3(0x70,0xff,0x18))
        myScore_Data:setPosition(ccp(540,23))
        cellBg:addChild(myScore_Data)
        
    elseif(tonumber(_curTag) == tonumber(_tagLevel))then -----个人等级
        -- _uname = tCellValue.uname
        -- _ulevel = tCellValue.level
        -- _power = tCellValue.fight_force
        -- _uid = tCellValue.uid
        -- _uGender = HeroModel.getSex(tCellValue.htid)
        -- _htid = tCellValue.htid
        -- _dressInfo = tCellValue.dressInfo
 
        --头像
        local icon_bg = CCSprite:create("images/match/head_bg.png")
        icon_bg:setAnchorPoint(ccp(0,0.5))
        icon_bg:setPosition(ccp(138,cellBg:getContentSize().height*0.5))
        cellBg:addChild(icon_bg)
        local iconMenu = CCMenu:create()
        iconMenu:setTouchPriority(-555)
        iconMenu:setPosition(ccp(0,0))
        icon_bg:addChild(iconMenu)
        require "script/model/utils/HeroUtil"
        local dressId = nil
        local genderId = nil
        if( not table.isEmpty(tCellValue.dressInfo) and (tCellValue.dressInfo["1"])~= nil and tonumber(tCellValue.dressInfo["1"]) > 0 )then
            dressId = tCellValue.dressInfo["1"]
            genderId = HeroModel.getSex(tCellValue.htid)
        end

         --vip 特效
        local vip = tCellValue.vip or 0
        --print("创建前输出参数",tCellValue.htid,"**",dressId,"**",dressId)
        local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.htid, dressId, dressId,vip)
        local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
        heroIconItem:setAnchorPoint(ccp(0.5,0.5))
        heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
        iconMenu:addChild(heroIconItem,1,lineNum)
      
        heroIconItem:registerScriptTapHandler(userFormationItemFun)

        -- lv.
        local lv_sprite = CCSprite:create("images/common/lv.png")
        lv_sprite:setAnchorPoint(ccp(0,1))
        lv_sprite:setPosition(ccp(320,cellBg:getContentSize().height-10))
        cellBg:addChild(lv_sprite)
        -- 等级
        local lvStr = tCellValue.level or " "
        local lv_data = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        lv_data:setAnchorPoint(ccp(0,1))
        lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
        lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cellBg:getContentSize().height-4))
        cellBg:addChild(lv_data)
        -- 名字
        local nameStr = tCellValue.uname or " "
        local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        name:setColor(name_color)
        name:setAnchorPoint(ccp(0.5,0))
        name:setPosition(ccp(361,42))
        cellBg:addChild(name)
        -- 军团名字
        if( tCellValue.guild_name ~= nil)then
            local guildStr = tCellValue.guild_name
            local guildname = CCRenderLabel:create("("..guildStr..")" , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            guildname:setColor(ccc3(0xff, 0xf6, 0x00))
            guildname:setAnchorPoint(ccp(0.5,0))
            guildname:setPosition(ccp(361,10))
            cellBg:addChild(guildname)
        end

        -- 战斗力图片
        local fightDesc = CCSprite:create("images/common/fight_value.png")
        fightDesc:setAnchorPoint(ccp(1,1))
        fightDesc:setColor(ccc3(0xff,0xff,0xff))
        fightDesc:setPosition(ccp(585,cellBg:getContentSize().height-20))
        cellBg:addChild(fightDesc)
        local fightForce = tonumber(tCellValue.fight_force)or " "
        local myScore_Data = CCRenderLabel:create(fightForce, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        myScore_Data:setAnchorPoint(ccp(0.5,0))
        myScore_Data:setColor(ccc3(0x70,0xff,0x18))
        myScore_Data:setPosition(ccp(540,23))
        cellBg:addChild(myScore_Data)
    

    elseif(tonumber(_curTag) == tonumber(_tagGuild))then ---------军团战斗力
        --军团排名
        -- 军团名字icon
        local guild_name_sprite = CCSprite:create("images/guild/rank/guild_font.png")
        guild_name_sprite:setAnchorPoint(ccp(1,0.5))
        guild_name_sprite:setPosition(ccp(225,cellBg:getContentSize().height-52))
        cellBg:addChild(guild_name_sprite)

        -- 军团名字 
        local str_guild_name= tCellValue.guild_name or " "
        local guild_name = CCRenderLabel:create( str_guild_name, g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        guild_name:setColor(name_color)
        guild_name:setAnchorPoint(ccp(0,0.5))
        guild_name:setPosition(ccp(guild_name_sprite:getPositionX()+18,guild_name_sprite:getPositionY()))
        cellBg:addChild(guild_name)

        -- 军团长名字icon
        local leader_name_sprite = CCSprite:create("images/guild/rank/guild_leader.png")
        leader_name_sprite:setAnchorPoint(ccp(1,0.5))
        leader_name_sprite:setPosition(ccp(225,cellBg:getContentSize().height-90))
        cellBg:addChild(leader_name_sprite)

        -- 军团长名字 
        local str_leader_name= tCellValue.leader_name or " "
        local leader_name = CCRenderLabel:create( str_leader_name, g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        leader_name:setColor(name_color)
        leader_name:setAnchorPoint(ccp(0,0.5))
        leader_name:setPosition(ccp(leader_name_sprite:getPositionX()+18,leader_name_sprite:getPositionY()))
        cellBg:addChild(leader_name)

        -- 军团等级
        local lv_sprite = CCSprite:create("images/common/lv.png")
        lv_sprite:setAnchorPoint(ccp(0,0.5))
        lv_sprite:setPosition(ccp(157,cellBg:getContentSize().height-15))
        cellBg:addChild(lv_sprite)

        --军团等级数据
        local str_lv= tCellValue.guild_level or " "
        local lv_data = CCRenderLabel:create(str_lv, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        lv_data:setAnchorPoint(ccp(0,0.5))
        lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
        lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cellBg:getContentSize().height-15))
        cellBg:addChild(lv_data)
        
        -- 军团战斗力
        local fightForce= CCSprite:create("images/guild/rank/total_fight_force.png")
        fightForce:setAnchorPoint(ccp(0.5,0))
        fightForce:setPosition(ccp(548,cellBg:getContentSize().height-49))
        fightForce:setScale(0.9)
        cellBg:addChild(fightForce)

        local fightForcedata = CCRenderLabel:create( tonumber(tCellValue.fight_force )or "0" , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        fightForcedata:setAnchorPoint(ccp(0.5,1))
        fightForcedata:setColor(ccc3(0x00, 0xff, 0x18))
        fightForcedata:setPosition(ccp(fightForce:getPositionX()-6,fightForce:getPositionY()-15))
        cellBg:addChild(fightForcedata) 

    elseif(tonumber(_curTag) == tonumber(_tagCopy))then -----副本

        -- _uname = tCellValue.uname
        -- _ulevel = tCellValue.level
        -- _power = tCellValue.fight_force
        -- _uid = tCellValue.uid
        -- _uGender = HeroModel.getSex(tCellValue.htid)
        -- _htid = tCellValue.htid
        -- _dressInfo = tCellValue.dress
        -- print("输出当前tvalue")
        -- print_t(tCellValue)
        
        --头像
        local icon_bg = CCSprite:create("images/match/head_bg.png")
        icon_bg:setAnchorPoint(ccp(0,0.5))
        icon_bg:setPosition(ccp(138,cellBg:getContentSize().height*0.5))
        cellBg:addChild(icon_bg)
        local iconMenu = CCMenu:create()
        iconMenu:setTouchPriority(-555)
        iconMenu:setPosition(ccp(0,0))
        icon_bg:addChild(iconMenu)
        require "script/model/utils/HeroUtil"
        local dressId = nil
        local genderId = nil
        if( not table.isEmpty(tCellValue.dress) and (tCellValue.dress["1"])~= nil and tonumber(tCellValue.dress["1"]) > 0 )then
            dressId = tCellValue.dress["1"]
            genderId = HeroModel.getSex(tCellValue.htid)
        end

         --vip 特效
        local vip = tCellValue.vip or 0
        --print("创建前输出参数",tCellValue.htid,"**",dressId,"**",dressId)
        local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.htid, dressId, dressId,vip)
        local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
        heroIconItem:setAnchorPoint(ccp(0.5,0.5))
        heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
        iconMenu:addChild(heroIconItem,1,lineNum)
        
        heroIconItem:registerScriptTapHandler(userFormationItemFun)

        -- lv.
        local lv_sprite = CCSprite:create("images/common/lv.png")    
        lv_sprite:setAnchorPoint(ccp(0,1))
        lv_sprite:setPosition(ccp(290,cellBg:getContentSize().height-10))
        cellBg:addChild(lv_sprite)
        -- 等级
        local lvStr = tCellValue.level or " "
        local lv_data = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        lv_data:setAnchorPoint(ccp(0,1))
        lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
        lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cellBg:getContentSize().height-4))
        cellBg:addChild(lv_data)
        -- 名字
        local nameStr = tCellValue.uname or " "
        local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        name:setColor(name_color)
        name:setAnchorPoint(ccp(0.5,0))
        name:setPosition(ccp(331,42))
        cellBg:addChild(name)

        -- 战斗力图片
        local fightDesc = CCSprite:create("images/common/fight_value.png")
        fightDesc:setAnchorPoint(ccp(1,0))
        fightDesc:setColor(ccc3(0xff,0xff,0xff))
        fightDesc:setPosition(ccp(330,6))
        cellBg:addChild(fightDesc)
        local fightForce = tonumber(tCellValue.fight_force)or " "
        local myScore_Data = CCRenderLabel:create(fightForce, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        myScore_Data:setAnchorPoint(ccp(0,0))
        myScore_Data:setColor(ccc3(0x70,0xff,0x18))
        myScore_Data:setPosition(ccp(fightDesc:getPositionX()+3,10))
        cellBg:addChild(myScore_Data)

      

        -- 副本进度
        local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2730"), g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_stroke)
        myScore_font:setAnchorPoint(ccp(1,1))
        myScore_font:setColor(ccc3(0xff,0xff,0xff))
        myScore_font:setPosition(ccp(580,cellBg:getContentSize().height-10))
        cellBg:addChild(myScore_font)
        local max_levelStr = tCellValue.score or " "
        local myScore_Data = CCRenderLabel:create( max_levelStr, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        myScore_Data:setAnchorPoint(ccp(1,0.5))
        myScore_Data:setColor(ccc3(0x70,0xff,0x18))
        myScore_Data:setPosition(ccp(560,cellBg:getContentSize().height*0.5))
        cellBg:addChild(myScore_Data)
        local starSprite = CCSprite:create("images/copy/star.png")
        starSprite:setAnchorPoint(ccp(0,0.5))
        starSprite:setPosition(ccp(560,cellBg:getContentSize().height*0.5))
        cellBg:addChild(starSprite)

        -- 副本名称
        require "script/ui/copy/CopyUtil"
        local copyData = CopyUtil.getNormalCopyDBDataById(tCellValue.copy_id)
        local nameStr = copyData.name or" "
        local name_font = CCRenderLabel:create( nameStr, g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_stroke)
        name_font:setAnchorPoint(ccp(0.5,0))
        name_font:setColor(ccc3(0xfe,0xdb,0x1c))
        name_font:setPosition(ccp(540,10))
        cellBg:addChild(name_font)

    elseif(tonumber(_curTag) == tonumber(_tagTower))then -----爬塔

        -- _uname = tCellValue.uname
        -- _ulevel = tCellValue.level
        -- _power = tCellValue.fight_force
        -- _uid = tCellValue.uid
        -- _uGender = HeroModel.getSex(tCellValue.htid)
        -- _htid = tCellValue.htid
        -- _dressInfo = tCellValue.dress

        -- 头像
        local icon_bg = CCSprite:create("images/match/head_bg.png")
        icon_bg:setAnchorPoint(ccp(0,0.5))
        icon_bg:setPosition(ccp(138,cellBg:getContentSize().height*0.5))
        cellBg:addChild(icon_bg)
        local iconMenu = CCMenu:create()
        iconMenu:setTouchPriority(-420)
        iconMenu:setPosition(ccp(0,0))
        icon_bg:addChild(iconMenu)
        require "script/model/utils/HeroUtil"
        local dressId = nil
        local genderId = nil
        if( not table.isEmpty(tCellValue.dress) and (tCellValue.dress["1"])~= nil and tonumber(tCellValue.dress["1"]) > 0 )then
            dressId = tCellValue.dress["1"]
            genderId = HeroModel.getSex(tCellValue.htid)
        end

        -- added by zhz , vip 特效
        local vip = tCellValue.vip or 0
        --print("输出爬塔中得htid****------*******----",tCellValue.htid)
        local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.htid, dressId, genderId, vip)
        local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
        heroIconItem:setAnchorPoint(ccp(0.5,0.5))
        heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
        iconMenu:addChild(heroIconItem,1,lineNum)
        
        heroIconItem:registerScriptTapHandler(userFormationItemFun)

        -- lv.
        local lv_sprite = CCSprite:create("images/common/lv.png")
        lv_sprite:setAnchorPoint(ccp(0,1))
        lv_sprite:setPosition(ccp(320,cellBg:getContentSize().height-10))
        cellBg:addChild(lv_sprite)
        -- 等级
        local lvStr = tCellValue.level or " "
        local lv_data = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        lv_data:setAnchorPoint(ccp(0,1))
        lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
        lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cellBg:getContentSize().height-4))
        cellBg:addChild(lv_data)
        -- 名字
        local nameStr = tCellValue.uname or " "
        local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        name:setColor(name_color)
        name:setAnchorPoint(ccp(0.5,0))
        name:setPosition(ccp(361,42))
        cellBg:addChild(name)
         -- 军团名字
        if( tCellValue.guild_name ~= nil)then
            local guildStr = tCellValue.guild_name
            local guildname = CCRenderLabel:create("("..guildStr..")" , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            guildname:setColor(ccc3(0xff, 0xf6, 0x00))
            guildname:setAnchorPoint(ccp(0.5,0))
            guildname:setPosition(ccp(361,10))
            cellBg:addChild(guildname)
        end        

        -- 爬塔进度
        local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2317"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        myScore_font:setAnchorPoint(ccp(1,1))
        myScore_font:setColor(ccc3(0xff,0xff,0xff))
        myScore_font:setPosition(ccp(595,cellBg:getContentSize().height-20))
        cellBg:addChild(myScore_font)
        local max_levelStr = tCellValue.max_level or " "
        local myScore_Data = CCRenderLabel:create( max_levelStr .. GetLocalizeStringBy("key_2400"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        myScore_Data:setAnchorPoint(ccp(0.5,0))
        myScore_Data:setColor(ccc3(0x70,0xff,0x18))
        myScore_Data:setPosition(ccp(530,23))
        cellBg:addChild(myScore_Data)
    elseif(tonumber(_curTag) == tonumber(_tagMatch))then ---------比武
        -- _uname = tCellValue.uname
        -- _ulevel = tCellValue.level
        -- _power = tCellValue.fight_force
        -- _uid = tCellValue.uid
        -- _uGender = HeroModel.getSex(tCellValue.squad[1].htid)
        -- _htid = tCellValue.squad[1].htid
        -- _dressInfo = tCellValue.squad[1].dress

        --头像
        local icon_bg = CCSprite:create("images/match/head_bg.png")
        icon_bg:setAnchorPoint(ccp(0,0.5))
        icon_bg:setPosition(ccp(138,cellBg:getContentSize().height*0.5))
        cellBg:addChild(icon_bg)
        local iconMenu = CCMenu:create()
        iconMenu:setTouchPriority(-420)
        iconMenu:setPosition(ccp(0,0))
        icon_bg:addChild(iconMenu)
        require "script/model/utils/HeroUtil"
        local dressId = nil
        local genderId = nil
        if( not table.isEmpty(tCellValue.squad[1].dress) and (tCellValue.squad[1].dress["1"])~= nil and tonumber(tCellValue.squad[1].dress["1"]) > 0 )then
            dressId = tCellValue.squad[1].dress["1"]
            genderId = HeroModel.getSex(tCellValue.squad[1].htid)
        end
        -- added by zhz , VIP等级产生的特效
        local vip= tCellValue.vip or 0
        local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.squad[1].htid, dressId, genderId, vip)
        local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
        heroIconItem:setAnchorPoint(ccp(0.5,0.5))
        heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
        iconMenu:addChild(heroIconItem,1,lineNum)
        heroIconItem:registerScriptTapHandler(userFormationItemFun)



         -- lv.
        local lv_sprite = CCSprite:create("images/common/lv.png")
        lv_sprite:setAnchorPoint(ccp(0,1))
        lv_sprite:setPosition(ccp(320,cellBg:getContentSize().height-10))
        cellBg:addChild(lv_sprite)
        -- 等级
        local lvStr = tCellValue.level or " "
        local lv_data = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        lv_data:setAnchorPoint(ccp(0,1))
        lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
        lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cellBg:getContentSize().height-4))
        cellBg:addChild(lv_data)
        -- 名字
        local nameStr = tCellValue.uname or " "
        local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        name:setColor(name_color)
        name:setAnchorPoint(ccp(0.5,0))
        name:setPosition(ccp(361,42))
        cellBg:addChild(name)
        
         -- 军团名字
        if( tCellValue.guild_name ~= nil)then
            local guildStr = tCellValue.guild_name
            local guildname = CCRenderLabel:create("("..guildStr..")" , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            guildname:setColor(ccc3(0xff, 0xf6, 0x00))
            guildname:setAnchorPoint(ccp(0.5,0))
            guildname:setPosition(ccp(361,10))
            cellBg:addChild(guildname)
        end



        -- -- lv.
        -- local lv_sprite = CCSprite:create("images/common/lv.png")
        -- lv_sprite:setAnchorPoint(ccp(0,1))
        -- cellBg:addChild(lv_sprite)
        -- -- 等级
        -- local lv_data = CCRenderLabel:create( tCellValue.level , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- lv_data:setAnchorPoint(ccp(0,1))
        -- lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
        -- cellBg:addChild(lv_data)
        -- -- 居中
        -- local posX = (cellBg:getContentSize().width-lv_sprite:getContentSize().width-lv_data:getContentSize().width)*0.6
        -- lv_sprite:setPosition(ccp(posX,cellBg:getContentSize().height*0.9))
        -- lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+2,cellBg:getContentSize().height*0.9))
        -- -- 名字
        -- local name = CCRenderLabel:create( tCellValue.uname , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- name:setColor(name_color)
        -- name:setAnchorPoint(ccp(0.5,0.5))
        -- name:setPosition(ccp(cellBg:getContentSize().width*0.6,cellBg:getContentSize().height*0.5))
        -- cellBg:addChild(name)

        -- -- 军团名字
        -- if(tCellValue.guild_name)then
        --     local guildNameStr = tCellValue.guild_name or " "
        --     local guildNameFont = CCRenderLabel:create( "(" .. guildNameStr .. ")" , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        --     guildNameFont:setAnchorPoint(ccp(0.5,0))
        --     guildNameFont:setColor(ccc3(0xff, 0xf6, 0x00))
        --     guildNameFont:setPosition(ccp(cellBg:getContentSize().width*0.6,cellBg:getContentSize().height*0.1))
        --     cellBg:addChild(guildNameFont)
        -- end

        -- 积分
        local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2248"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        myScore_font:setAnchorPoint(ccp(0,1))
        myScore_font:setColor(ccc3(0xff,0xff,0xff))
        myScore_font:setPosition(ccp(503,cellBg:getContentSize().height-20))
        cellBg:addChild(myScore_font)
        local myScore_Data = CCRenderLabel:create( tCellValue.point, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        myScore_Data:setAnchorPoint(ccp(0.5,0))
        myScore_Data:setColor(ccc3(0x70,0xff,0x18))
        myScore_Data:setPosition(ccp(530,23))
        cellBg:addChild(myScore_Data)
    elseif(tonumber(_curTag) == tonumber(_tagAren))then ---------竞技
        -- _uname = tCellValue.uname
        -- _ulevel = tCellValue.level
        -- _power = tCellValue.fight_force
        -- _uid = tCellValue.uid
        -- _uGender = HeroModel.getSex(tCellValue.squad[1].htid)
        -- _htid = tCellValue.squad[1].htid
        -- _dressInfo = tCellValue.squad[1].dress
        -- 头像
        local icon_bg = CCSprite:create("images/match/head_bg.png")
        icon_bg:setAnchorPoint(ccp(0,0.5))
        icon_bg:setPosition(ccp(138,cellBg:getContentSize().height*0.5))
        cellBg:addChild(icon_bg)
        local iconMenu = CCMenu:create()
        iconMenu:setTouchPriority(-420)
        iconMenu:setPosition(ccp(0,0))
        icon_bg:addChild(iconMenu)


        -- 判断是否是npc
        local isNpc = nil
        if(tonumber(tCellValue.uid) >= 11001 and tonumber(tCellValue.uid) <= 16000)then
            isNpc = true
        end

        if( isNpc )then
            -- 创建NPC名将头像
            require "script/ui/arena/ArenaData"
            local numTem = 0
            -- for k,v in pairs(tCellValue.squad) do
            --     numTem = numTem + 1
            local heroIcon = ArenaData.getNpcIconByhid(tCellValue.squad[1])
            heroIcon:setAnchorPoint(ccp(0.5,0.5))
            heroIcon:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
            icon_bg:addChild(heroIcon)
            
        else
            -- -- 创建非NPC名将头像
            -- local numTem = 0
            -- -- added by zhz , vip 特效
            -- local vip = tCellValue.vip or 0
            -- for k,v in pairs(tCellValue.squad) do
            --     numTem = numTem + 1
            --     local dressId = nil
            --     local genderId = nil
            --     if( not table.isEmpty(v.dress) and (v.dress["1"])~= nil and tonumber(v.dress["1"]) > 0 )then
            --         dressId = v.dress["1"]
            --         genderId = HeroModel.getSex(v.htid)
            --     end
            --     local heroIcon = HeroUtil.getHeroIconByHTID(v.htid, dressId, genderId, vip)
            --     heroIcon:setAnchorPoint(ccp(0,0.5))
            --     heroIcon:setPosition(ccp(5+(heroIcon:getContentSize().width+14)*(numTem-1),hero_bg:getContentSize().height*0.5))
            --     hero_bg:addChild(heroIcon,1,numTem)
            -- end
        


            require "script/model/utils/HeroUtil"
            local dressId = nil
            local genderId = nil
            if( not table.isEmpty(tCellValue.squad[1].dress) and (tCellValue.squad[1].dress["1"])~= nil and tonumber(tCellValue.squad[1].dress["1"]) > 0 )then
                dressId = tCellValue.squad[1].dress["1"]
                genderId = HeroModel.getSex(tCellValue.squad[1].htid)
            end
            -- added by zhz , VIP等级产生的特效
            local vip= tCellValue.vip or 0
            -- print("输出竞技htid----")
            -- print(tCellValue.squad[1].htid)
            -- print_t(tCellValue.squad[1])
            local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.squad[1].htid, dressId, genderId, vip)
            local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
            heroIconItem:setAnchorPoint(ccp(0.5,0.5))
            heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
            iconMenu:addChild(heroIconItem,1,lineNum)
            heroIconItem:registerScriptTapHandler(userFormationItemFun)
        end


       -- lv.
        local lv_sprite = CCSprite:create("images/common/lv.png")
        lv_sprite:setAnchorPoint(ccp(0,1))
        lv_sprite:setPosition(ccp(320,cellBg:getContentSize().height-10))
        cellBg:addChild(lv_sprite)
        -- 等级
        local lvStr = tCellValue.level or " "
        local lv_data = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        lv_data:setAnchorPoint(ccp(0,1))
        lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
        lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cellBg:getContentSize().height-4))
        cellBg:addChild(lv_data)
        -- 名字
        local nameStr = tCellValue.uname or " "
        local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        name:setColor(name_color)
        name:setAnchorPoint(ccp(0.5,0))
        name:setPosition(ccp(361,42))
        cellBg:addChild(name)
        -- 军团名字
        if(tCellValue.guild_name ~= nil)then
            local guildStr = tCellValue.guild_name
            local guildname = CCRenderLabel:create("("..guildStr..")" , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            guildname:setColor(ccc3(0xff, 0xf6, 0x00))
            guildname:setAnchorPoint(ccp(0.5,0))
            guildname:setPosition(ccp(361,10))
            cellBg:addChild(guildname)
        end

        

        -- -- lv.
        -- local lv_sprite = CCSprite:create("images/common/lv.png")
        -- lv_sprite:setAnchorPoint(ccp(0,1))
        -- cellBg:addChild(lv_sprite)
        -- -- 等级
        -- local lv_data = CCRenderLabel:create( tCellValue.level , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- lv_data:setAnchorPoint(ccp(0,1))
        -- lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
        -- cellBg:addChild(lv_data)
        -- -- 居中
        -- local posX = (cellBg:getContentSize().width-lv_sprite:getContentSize().width-lv_data:getContentSize().width)*0.6
        -- lv_sprite:setPosition(ccp(posX,cellBg:getContentSize().height*0.9))
        -- lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+2,cellBg:getContentSize().height*0.9))
        -- -- 名字
        -- local name = CCRenderLabel:create( tCellValue.uname , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- name:setColor(name_color)
        -- name:setAnchorPoint(ccp(0.5,0.5))
        -- name:setPosition(ccp(cellBg:getContentSize().width*0.6,cellBg:getContentSize().height*0.5))
        -- cellBg:addChild(name)

        -- -- 军团名字
        -- if(tCellValue.guild_name)then
        --     local guildNameStr = tCellValue.guild_name or " "
        --     local guildNameFont = CCRenderLabel:create( "(" .. guildNameStr .. ")" , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        --     guildNameFont:setAnchorPoint(ccp(0.5,0))
        --     guildNameFont:setColor(ccc3(0xff, 0xf6, 0x00))
        --     guildNameFont:setPosition(ccp(cellBg:getContentSize().width*0.6,cellBg:getContentSize().height*0.1))
        --     cellBg:addChild(guildNameFont)
        -- end

        -- -- 积分
        -- local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2248"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        -- myScore_font:setAnchorPoint(ccp(0,1))
        -- myScore_font:setColor(ccc3(0xff,0xff,0xff))
        -- myScore_font:setPosition(ccp(473,cellBg:getContentSize().height-20))
        -- cellBg:addChild(myScore_font)
        -- local myScore_Data = CCRenderLabel:create( tCellValue.point, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        -- myScore_Data:setAnchorPoint(ccp(0.5,0))
        -- myScore_Data:setColor(ccc3(0x70,0xff,0x18))
        -- myScore_Data:setPosition(ccp(500,23))
        -- cellBg:addChild(myScore_Data)
          -- 战斗力图片
        local fightDesc = CCSprite:create("images/common/fight_value.png")
        fightDesc:setAnchorPoint(ccp(1,1))
        fightDesc:setColor(ccc3(0xff,0xff,0xff))
        fightDesc:setPosition(ccp(585,cellBg:getContentSize().height-20))
        cellBg:addChild(fightDesc)
        local fightForce = tonumber(tCellValue.fight_force)or " "
        local myScore_Data = CCRenderLabel:create(fightForce, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        myScore_Data:setAnchorPoint(ccp(0.5,0))
        myScore_Data:setColor(ccc3(0x70,0xff,0x18))
        myScore_Data:setPosition(ccp(540,23))
        cellBg:addChild(myScore_Data)
    elseif(tonumber(_curTag) == tonumber(_tagPet))then -----宠物

        _uid = tCellValue.uid
        -- print("uid被修改")
        -- print(_uid)
        -- 头像
        local icon_bg = CCSprite:create("images/match/head_bg.png")
        icon_bg:setAnchorPoint(ccp(0,0.5))
        icon_bg:setPosition(ccp(138,cellBg:getContentSize().height*0.5))
        cellBg:addChild(icon_bg)
        local iconMenu = CCMenu:create()
        iconMenu:setTouchPriority(-420)
        iconMenu:setPosition(ccp(0,0))
        icon_bg:addChild(iconMenu)

        require "script/ui/pet/PetUtil"
        local petIcon = PetUtil.getPetHeadIconByItid(tCellValue.pet_tmpl)
        local petIconItem = CCMenuItemSprite:create(petIcon,petIcon)
        petIconItem:setAnchorPoint(ccp(0.5,0.5))
        petIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
        iconMenu:addChild(petIconItem,1,lineNum)
       
        petIconItem:registerScriptTapHandler(petFormationItemFun)

      

        --local vip = tCellValue.vip or 0
        --print("输出爬塔中得htid****------*******----",tCellValue.htid)
        --local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.htid, dressId, genderId, vip)
        --local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
        -- heroIconItem:setAnchorPoint(ccp(0.5,0.5))
        -- heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
        -- iconMenu:addChild(heroIconItem,1,tonumber( tCellValue.uid ))
        --回调还没写
        --heroIconItem:registerScriptTapHandler(userFormationItemFun)

        -- lv.
        local lv_sprite = CCSprite:create("images/common/lv.png")
        lv_sprite:setAnchorPoint(ccp(0,1))
        lv_sprite:setPosition(ccp(290,cellBg:getContentSize().height-10))
        cellBg:addChild(lv_sprite)
        -- 等级
        local lvStr = tCellValue.level or " "
        local lv_data = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        lv_data:setAnchorPoint(ccp(0,1))
        lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
        lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cellBg:getContentSize().height-4))
        cellBg:addChild(lv_data)
        -- 名字
        require "script/ui/pet/PetData"
        local nameStr = PetData.getPetNameByTid(tCellValue.pet_tmpl)or " "
        local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        name:setColor(name_color)
        name:setAnchorPoint(ccp(0.5,0))
        name:setPosition(ccp(331,42))
        cellBg:addChild(name)

        -- 战斗力图片
        local fightDesc = CCSprite:create("images/common/fight_value.png")
        fightDesc:setAnchorPoint(ccp(1,0))
        fightDesc:setColor(ccc3(0xff,0xff,0xff))
        fightDesc:setPosition(ccp(330,6))
        cellBg:addChild(fightDesc)
        local fightForce = tonumber(tCellValue.pet_fightforce)or " "
        local myScore_Data = CCRenderLabel:create(fightForce, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        myScore_Data:setAnchorPoint(ccp(0,0))
        myScore_Data:setColor(ccc3(0x70,0xff,0x18))
        myScore_Data:setPosition(ccp(fightDesc:getPositionX()+3,10))
        cellBg:addChild(myScore_Data)


        -- 主人
        local name_font = CCRenderLabel:create( GetLocalizeStringBy("key_2320"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        name_font:setAnchorPoint(ccp(1,1))
        name_font:setColor(ccc3(0xff,0xff,0xff))
        name_font:setPosition(ccp(555,cellBg:getContentSize().height-10))
        cellBg:addChild(name_font)
        local nameStr = tCellValue.uname or " "
        local ownerName = CCRenderLabel:create( nameStr, g_sFontPangWa, 22, 1, ccc3(0x00,0x00,0x00), type_stroke)
        ownerName:setAnchorPoint(ccp(0.5,0))
        ownerName:setColor(ccc3(0x70,0xff,0x18))
        ownerName:setPosition(ccp(540,33))
        cellBg:addChild(ownerName)
        if(tonumber(tCellValue.guild_id) ~= 0 )then
            local guildnameStr = tCellValue.guild_name or " "
            local guildName = CCRenderLabel:create( "("..guildnameStr..")", g_sFontPangWa, 22, 1, ccc3(0x00,0x00,0x00), type_stroke)
            guildName:setAnchorPoint(ccp(0.5,0))
            guildName:setColor(ccc3(0xff, 0xf6, 0x00))
            guildName:setPosition(ccp(540,5))
            cellBg:addChild(guildName)
        end

    end

    return cell
end
--[[
    @des    :创建顶端user自身排名等信息
    @param  :menu的tag
    @return :
--]]
function createUserBg( tag )
    --local userBg = CCScale9Sprite:create("images/common/bg/bg_9s_1.png")
    --local userBg = CCScale9Sprite:create()
    local userBg = CCNode:create()
    userBg:setContentSize(CCSizeMake(500,50))
    --local userBg = CCSprite:create()
    local userRank = RankData.getRankUserData(tag)
    -- print("********用户排名，用户信息 **********")
    -- print_t(userRank)
    -- print("********")
    local strRank = userRank[1]
    local strInfo = userRank[2]

    
    local rankStr 
    if(tag == _tagGuild)then
        rankStr= CCRenderLabel:create(GetLocalizeStringBy("djn_49"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    elseif(tag == _tagPet)then
        rankStr= CCRenderLabel:create(GetLocalizeStringBy("djn_50"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- if(tonumber(strRank)== tonumber(-1))then
        --     strRank = GetLocalizeStringBy("key_1054")
        -- end
    else
        rankStr= CCRenderLabel:create(GetLocalizeStringBy("djn_46"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    end
    local rankLabel = CCLabelTTF:create(tostring(strRank),g_sFontPangWa,23)
    local infoLabel = CCLabelTTF:create(tostring(strInfo),g_sFontPangWa,23)
    
    rankStr:setColor(ccc3(0xff, 0xf6, 0x00))
    rankStr:setAnchorPoint(ccp(1,0))
    rankStr:setPosition(ccp(130,15))
    rankLabel:setPosition(ccp(rankStr:getPositionX()+5,15))
    userBg:addChild(rankStr)
    

    local str ={}
    str[tonumber(_tagFightForce)]=GetLocalizeStringBy("key_2122")
    str[tonumber(_tagLevel)]=GetLocalizeStringBy("djn_31")
    str[tonumber(_tagCopy)]=GetLocalizeStringBy("key_2730")
    str[tonumber(_tagPet)]=GetLocalizeStringBy("djn_47")
    str[tonumber(_tagGuild)]=GetLocalizeStringBy("key_2122")
    str[tonumber(_tagMatch)]=GetLocalizeStringBy("djn_48")
    str[tonumber(_tagTower)]=GetLocalizeStringBy("key_2317")
    str[tonumber(_tagAren)]=GetLocalizeStringBy("key_1188")



    local infoStr = CCRenderLabel:create(str[tonumber(tag)], g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    infoStr:setColor(ccc3(0xff, 0xf6, 0x00))
    infoStr:setAnchorPoint(ccp(0,0))
    infoStr:setPosition(ccp(270,15))

    infoLabel:setPosition(ccp(infoStr:getPositionX()+infoStr:getContentSize().width+5,15))
    userBg:addChild(infoStr)
    if(tag == _tagCopy)then
        local starSprite = CCSprite:create("images/copy/star.png")
        starSprite:setAnchorPoint(ccp(0,0))
        starSprite:setPosition(ccp(infoLabel:getPositionX()+infoLabel:getContentSize().width+2,15))
        userBg:addChild(starSprite)
    end
    --print("输出坐标长度",infoStr:getPositionX(),"++"infoStr:getContentSize().width,"++",infoLabel:getPositionX)
    --infoLabel:setPosition(ccp(300,15))
    userBg:addChild(rankLabel)
    userBg:addChild(infoLabel)
    return userBg
    
end
--[[
    @des    :点击宠物头像回调
    @param  :
    @return :
--]]
function petFormationItemFun(tag)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- print("调用宠物信息接口使用的uid")
    -- print(_uid)
    require "script/ui/rank/PetLayer"
    local allInfo  = (RankLayer.getTabViewInfo())[tag]

    local serverCb = function ( ... )
        local petInfo  = RankData.getUserUpPetData()
        -- 后端为了之后可扩展性保留petId作为key,所以这里遍历取到value 
        for k,v in pairs(petInfo) do
            print("宠物个人cell传参前打印petInfo")
            print_t(v)
            PetLayer.showLayer(v)
            break
        end
    end

    RankService.getUserPetInfo(allInfo.uid,serverCb)    
end

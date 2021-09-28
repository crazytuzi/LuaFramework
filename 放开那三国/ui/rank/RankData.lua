-- Filename：    RankData.lua
-- Author：      DJN
-- Date：        2014-9-4
-- Purpose：     排行榜系统数据

module("RankData", package.seeall)
require "script/model/user/UserModel"
local _tagFightForce        = 2001
local _tagLevel             = 2002
local _tagCopy              = 2003
local _tagPet               = 2004
local _tagGuild             = 2005
local _tagMatch             = 2006
local _tagTower             = 2007
local _tagAren              = 2008
local _userPetInfo          = {}
-------------------------------------------------------------------------------------------------军团排行
--[[
    @des    :设置战力前50军团数据
    @param  :
    @return :
--]]
function setRankGuildListData( listData )
    _rankguildListInfo = listData  
    table.sort( _rankguildListInfo, rankSort ) 
    --getUserRankGuildInfo()
end
--[[
    @des    :获取军团排名中的个人排名信息
    @param  :
    @return :
--]]
function getUserRankGuildInfo( ... )
    require "script/ui/guild/GuildDataCache"
    _rankguildUserInfo ={}
    if(tonumber(GuildDataCache.getMineSigleGuildInfo().rank) == 0 or GuildDataCache.getMineSigleGuildInfo().rank == nil )then --用户没有加入军团的时候，后端将排名返回为0
        table.insert(_rankguildUserInfo,GetLocalizeStringBy("djn_52"))
        table.insert(_rankguildUserInfo,GetLocalizeStringBy("key_1554")) 

    else
        table.insert(_rankguildUserInfo,GuildDataCache.getMineSigleGuildInfo().rank)
        table.insert(_rankguildUserInfo,GuildDataCache.getMineSigleGuildInfo().fight_force)  
    end   
end
---------------------------------------------------------------------------------------------军团排行结束
---------------------------------------------------------------------------------------------比武排行开始
function setRankMatchListData( listData )
    _rankmatchListInfo = listData  
    table.sort( _rankmatchListInfo, rankSort ) 
   
end
function setRankMatchUserData( userData )
    _rankmatchUserInfo ={}
    table.insert(_rankmatchUserInfo,userData.rank)
    table.insert(_rankmatchUserInfo,userData.point)  
end
function getUserRankMatchInfo( ... )
    
    RankService.getMatchUserInfo()
    --  -- 自己排名
    -- local myRank_sprite = CCSprite:create("images/match/paiming.png")
    -- myRank_sprite:setAnchorPoint(ccp(0,1))
    -- myRank_sprite:setPosition(ccp(40,_layerBg:getContentSize().height-75))
    -- _layerBg:addChild(myRank_sprite)
    -- 排名数据
    local myRank_font = CCRenderLabel:create( MatchData.getMyRank(), g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myRank_font:setAnchorPoint(ccp(0,1))
    myRank_font:setColor(ccc3(0xff,0xf6,0x00))
    myRank_font:setPosition(ccp(myRank_sprite:getPositionX()+myRank_sprite:getContentSize().width+10,_layerBg:getContentSize().height-70))
    _layerBg:addChild(myRank_font)
    -- 获得自己的排名
function getMyRank( ... )
    local rank = nil
    if(m_allData ~= nil)then
        if(tonumber(m_allData.rank) == 0)then
            rank = "--"
        else
            rank = tonumber(m_allData.rank)
        end
    end
    return rank
end

    -- -- 积分
    -- local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2248"), g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
    -- myScore_font:setAnchorPoint(ccp(0,1))
    -- myScore_font:setColor(ccc3(0xff,0xff,0xff))
    -- myScore_font:setPosition(ccp(425,_layerBg:getContentSize().height-78))
    -- _layerBg:addChild(myScore_font)
    local myScore_Data = CCRenderLabel:create( MatchData.getMyScore(), g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_Data:setAnchorPoint(ccp(0,1))
    myScore_Data:setColor(ccc3(0x70,0xff,0x18))
    myScore_Data:setPosition(ccp(495,_layerBg:getContentSize().height-78))
    _layerBg:addChild(myScore_Data)
    -- 设置自己的积分
-- 获得自己的积分
function getMyScore( ... )
    local point = nil
    if(m_allData ~= nil)then
        point = tonumber(m_allData.point)
    end
    return point
end
end
---------------------------------------------------------------------------------------------比武排行结束
---------------------------------------------------------------------------------------------爬塔排行开始
function setRankTowerListData( listData ,userData)
    _ranktowerListInfo = listData  
    table.sort( _ranktowerListInfo, rankSort ) 

    _ranktowerUserInfo ={}
    table.insert(_ranktowerUserInfo,userData.rank)
    table.insert(_ranktowerUserInfo,userData.max_level)  
    -- print("爬塔个人数据")
    -- print_t(_ranktowerUserInfo)
end
-- function getUserRankTowerInfo( ... )
--     -- -- 排行榜图片
--     -- local paihangbang = CCSprite:create("images/tower/paihangbang.png")
--     -- paihangbang:setAnchorPoint(ccp(0.5,0.5))
--     -- paihangbang:setPosition(ccp(_layerBg:getContentSize().width*0.5,_layerBg:getContentSize().height))
--     -- _layerBg:addChild(paihangbang)

--     -- -- 自己排名
--     -- local myRank_sprite = CCSprite:create("images/match/paiming.png")
--     -- myRank_sprite:setAnchorPoint(ccp(0,1))
--     -- myRank_sprite:setPosition(ccp(40,_layerBg:getContentSize().height-75))
--     -- _layerBg:addChild(myRank_sprite)
--     -- 排名数据
--     local myRankData = " "
--     if(tonumber(_ranktowerUserInfo.rank) == 0)then
--         myRankData = GetLocalizeStringBy("key_1054")
--     else
--         myRankData = _ranktowerUserInfo.rank or " "
--     end
--     local myRank_font = CCRenderLabel:create( myRankData, g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
--     myRank_font:setAnchorPoint(ccp(0,1))
--     myRank_font:setColor(ccc3(0xff,0xf6,0x00))
--     myRank_font:setPosition(ccp(myRank_sprite:getPositionX()+myRank_sprite:getContentSize().width+10,_layerBg:getContentSize().height-70))
--     _layerBg:addChild(myRank_font)

--     -- 爬塔进度
--     local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2317"), g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
--     myScore_font:setAnchorPoint(ccp(0,1))
--     myScore_font:setColor(ccc3(0xff,0xff,0xff))
--     myScore_font:setPosition(ccp(425,_layerBg:getContentSize().height-78))
--     _layerBg:addChild(myScore_font)
--     local myScoreData = _ranktowerUserInfo.max_level or " " 
--     local myScore_Data = CCRenderLabel:create( myScoreData .. GetLocalizeStringBy("key_2400"), g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
--     myScore_Data:setAnchorPoint(ccp(0,1))
--     myScore_Data:setColor(ccc3(0x70,0xff,0x18))
--     myScore_Data:setPosition(ccp(myScore_font:getPositionX()+myScore_font:getContentSize().width+10,_layerBg:getContentSize().height-78))
--     _layerBg:addChild(myScore_Data)

   
-- end
---------------------------------------------------------------------------------------------爬塔排行结束
---------------------------------------------------------------------------------------------副本排行开始
function setRankCopyListData( listData ,userData)
    _rankcopyListInfo = listData  
    table.sort(_rankcopyListInfo, rankSort ) 
    
    _rankcopyUserInfo ={}
    table.insert(_rankcopyUserInfo,userData.rank)
    table.insert(_rankcopyUserInfo,userData.score)  
    -- print("副本个人数据")
    -- print_t(_rankcopyUserInfo)

end
-- function getUserRankCopyInfo( ... )
--     -- 自己排名
--     local myRank_sprite = CCSprite:create("images/match/paiming.png")
--     myRank_sprite:setAnchorPoint(ccp(0,1))
--     myRank_sprite:setPosition(ccp(40,_layerBg:getContentSize().height-75))
--     _layerBg:addChild(myRank_sprite)
--     -- 排名数据
--     local myRankData = " "
--     if(tonumber(_rankcopyUserInfo.rank) == 0)then
--         myRankData = GetLocalizeStringBy("key_1054")
--     else
--         myRankData = _rankcopyUserInfo.rank or " "
--     end
--     local myRank_font = CCRenderLabel:create( myRankData, g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
--     myRank_font:setAnchorPoint(ccp(0,1))
--     myRank_font:setColor(ccc3(0xff,0xf6,0x00))
--     myRank_font:setPosition(ccp(myRank_sprite:getPositionX()+myRank_sprite:getContentSize().width+10,_layerBg:getContentSize().height-70))
--     _layerBg:addChild(myRank_font)

--     -- 副本进度
--     local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2730"), g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
--     myScore_font:setAnchorPoint(ccp(0,1))
--     myScore_font:setColor(ccc3(0xff,0xff,0xff))
--     myScore_font:setPosition(ccp(400,_layerBg:getContentSize().height-78))
--     _layerBg:addChild(myScore_font)
--     local myScoreData = _rankcopyUserInfo.score or " " 
--     local myScore_Data = CCRenderLabel:create( myScoreData, g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
--     myScore_Data:setAnchorPoint(ccp(1,1))
--     myScore_Data:setColor(ccc3(0x70,0xff,0x18))
--     myScore_Data:setPosition(ccp(myScore_font:getPositionX()+myScore_font:getContentSize().width+myScore_Data:getContentSize().width+5,_layerBg:getContentSize().height-78))
--     _layerBg:addChild(myScore_Data)
--     local starSprite = CCSprite:create("images/copy/star.png")
--     starSprite:setAnchorPoint(ccp(0,1))
--     starSprite:setPosition(ccp(myScore_Data:getPositionX()+2,_layerBg:getContentSize().height-78))
--     _layerBg:addChild(starSprite)

   
-- end
---------------------------------------------------------------------------------------------副本排行结束
---------------------------------------------------------------------------------------------个人战斗力排行开始
function setRankFightForceData( listData ,userData)
    _rankfightforceListInfo = listData  
    _rankfightforceUserInfo = {}
    table.insert(_rankfightforceUserInfo,tonumber(userData.selfRank))
    table.sort(_rankfightforceListInfo, rankSort ) 
end
function getUserRankFightForceInfo( ... )
    -- 自己排名
end
---------------------------------------------------------------------------------------------个人战斗力排行结束
---------------------------------------------------------------------------------------------个人等级排行开始
function setRankLevelData( listData ,userData)

    _ranklevelListInfo = listData 
    _ranklevelUserInfo = {}
    
    table.insert(_ranklevelUserInfo,tonumber(userData.selfRank))

    table.sort(_ranklevelListInfo, rankSort ) 
    
end
function getUserRankLevelInfo( ... )
    -- 自己排名
   
end
---------------------------------------------------------------------------------------------个人等级排行结束
---------------------------------------------------------------------------------------------宠物排行开始
function setRankPetData( listData ,userData)
    _rankpetListInfo = listData  
    _rankpetUserInfo = {}
    
    if(tonumber(userData) == tonumber(-1) )then
        print("检测到宠物排名为-1")
       table.insert(_rankpetUserInfo,GetLocalizeStringBy("djn_53"))
    else 
        table.insert(_rankpetUserInfo,tonumber(userData))
    end

    table.sort(_rankpetListInfo, rankSort ) 
end
function getUserRankFightForceInfo( ... )
    -- 自己排名
end
---------------------------------------------------------------------------------------------宠物排行结束
---------------------------------------------------------------------------------------------竞技场排行开始
function setRankArenListData( listData )
    
    require "script/ui/arena/ArenaData"
    _rankarenListInfo = ArenaData.getTopTenData(listData) 
    table.sort(_rankarenListInfo, rankSortforAren ) 
    
end
function setRankArenUserData( userData)
    _rankarenUserInfo ={}
    table.insert(_rankarenUserInfo,userData.position)
   
    -- print("竞技个人数据")
    -- print_t(_rankarenUserInfo)
end
-- function getUserRankCopyInfo( ... )
--     -- 当前声望值
--     local numData = UserModel.getPrestigeNum() or 0
--     todaySurplusNum = CCLabelTTF:create( numData, g_sFontName, 24*MainScene.elementScale)
--     todaySurplusNum:setAnchorPoint(ccp(0,1))
--     todaySurplusNum:setColor(ccc3(0xff,0xf6,0x01))
--     todaySurplusNum:setPosition(ccp(todaySurplusNum_font:getPositionX()+todaySurplusNum_font:getContentSize().width+45*MainScene.elementScale, todaySurplusNum_font:getPositionY()-2*MainScene.elementScale))
--     mainLayer:addChild(todaySurplusNum)
-- end
---------------------------------------------------------------------------------------------竞技排行结束
---------------------------------------------------------------------------------------------公用函数

--[[
    @des    :得到排行榜数据
    @param  :
    @return :
--]]
function getRankListData( tag )
    if(tonumber(tag) == tonumber(_tagFightForce))then
        return _rankfightforceListInfo
    elseif (tonumber(tag) == tonumber(_tagGuild))then
        return _rankguildListInfo
    elseif (tonumber(tag) == tonumber(_tagMatch))then
        return _rankmatchListInfo
    elseif(tonumber(tag) == tonumber(_tagTower))then
        return _ranktowerListInfo
    elseif(tonumber(tag) == tonumber(_tagLevel))then
        return _ranklevelListInfo
    elseif(tonumber(tag) == tonumber(_tagCopy))then
        return _rankcopyListInfo
    elseif(tonumber(tag) == tonumber(_tagAren))then
        return _rankarenListInfo
    elseif(tonumber(tag) == tonumber(_tagPet))then
        return _rankpetListInfo
    end
end

--[[
    @des    :得到排行个人数据
    @param  :
    @return :
--]]
function getRankUserData( tag )
    if(tonumber(tag) == tonumber(_tagFightForce))then
       -- print("获取一次个人战斗力")
        table.insert(_rankfightforceUserInfo,UserModel.getFightForceValue())
        return _rankfightforceUserInfo
    elseif (tonumber(tag) == tonumber(_tagGuild))then
        getUserRankGuildInfo()
        return _rankguildUserInfo
    elseif (tonumber(tag) == tonumber(_tagMatch))then
        return _rankmatchUserInfo
    elseif(tonumber(tag) == tonumber(_tagTower))then
        return _ranktowerUserInfo
    elseif(tonumber(tag) == tonumber(_tagLevel))then
        table.insert(_ranklevelUserInfo,UserModel.getAvatarLevel())
        return _ranklevelUserInfo
    elseif(tonumber(tag) == tonumber(_tagCopy))then
        return _rankcopyUserInfo
    elseif(tonumber(tag) == tonumber(_tagAren))then
        table.insert(_rankarenUserInfo,UserModel.getPrestigeNum() or 0)  
        return _rankarenUserInfo
    elseif(tonumber(tag) == tonumber(_tagPet))then
        require "script/ui/pet/PetData"
        table.insert(_rankpetUserInfo,PetData.getPetFightForceById(PetData.getUpPetId()))
        return _rankpetUserInfo
    end
end
function setPetInfo( info )
    _petInfo = info
end
--[[
    @des    :对排名进行重新排序
    @param  :
    @return :
--]]

function rankSort ( goods_1, goods_2)
    return tonumber(goods_1.rank) < tonumber(goods_2.rank)
end
--[[
    @des    :对竞技排名进行重新排序（因为竞技的数据中排名字段不是rank 是position 所以单列）
    @param  :
    @return :
--]]

function rankSortforAren ( goods_1, goods_2)
    return tonumber(goods_1.position) < tonumber(goods_2.position)
end
--[[
    @des    :设置点击的宠物的详细信息，用于展示宠物信息的弹板（因为一直存在排行版中宠物信息的天赋技能不准确的问题，现在的解决方法是，
            点击查看某个宠物的时候，重新向后端请求数据，后端将其上阵宠物全部返回，前端判断天赋技能是否生效）
    @param  :
    @return :
--]]

function setUserUpPetData ( p_data)
    print("设置userpet")
    _userPetInfo = p_data
    print_t(_userPetInfo)
end
function getUserUpPetData( ... )
    return _userPetInfo
end

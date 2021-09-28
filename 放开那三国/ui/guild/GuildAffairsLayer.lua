-- Filename: GuildAffairsLayer.lua
-- Author: zhang zihang
-- Date: 2013-12-23
-- Purpose: 该文件用于: 军务

module ("GuildAffairsLayer", package.seeall)

require "script/model/user/UserModel"
require "script/audio/AudioUtil"
require "script/ui/guild/GuildDataCache"
require "script/ui/tip/AnimationTip"
require "script/network/RequestCenter"
require "script/ui/guild/GuildUtil"
require "script/ui/guild/GuildTipsLayer"
require "script/ui/guild/MemberListLayer"

local friend
local toCoLeader
local toLeader
local goOut
local pChat
local noCoLeader
local impeachment
local quieGuild
local guildPK

function init()
	_bgLayer = nil
    isFriend = false

    _quit = 1001
    _go = 1002
    memberInfo = nil


end

function closeCb()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
    --MemberListLayer.refreshMemberTableView(true)
end

function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		-- print("began")
	    return true
    elseif (eventType == "moved") then
    else
        -- print("end")
	end
end

function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--加好友回调
function requestFuncFriend(cbFlag, dictData, bRet)
    if(bRet == true)then
        -- print_t(dictData.ret)
        local dataRet = dictData.ret
        -- 等待确认
        if(dataRet == "applied")then
            local str = GetLocalizeStringBy("key_2048")
            AnimationTip.showTip(str)
            return
        end
        if(dataRet == "reach_maxnum")then
            local str = GetLocalizeStringBy("key_2058")
            AnimationTip.showTip(str)
            return
        end
        if(dataRet == "ok")then
            AnimationTip.showTip(GetLocalizeStringBy("key_2733"))
            return
        end
        if (dataRet == "alreadyfriend") then
            AnimationTip.showTip(GetLocalizeStringBy("key_2161"))
            return
        end
        if (dataRet == "black") then
            AnimationTip.showTip(GetLocalizeStringBy("lic_1061"))
            return
        end
        if (dataRet == "beblack") then
            AnimationTip.showTip(GetLocalizeStringBy("lic_1055"))
            return
        end
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
        MemberListLayer.refreshMemberTableView(true)
    end
end

function chatPM()
    require "script/ui/chat/ChatPmLayer"
    print_t(memberInfo)
    --memberInfo.uname为私聊对象的玩家名字
    
    
    require "script/ui/chat/ChatMainLayer"
    ChatMainLayer.showChatLayer(2)
    ChatMainLayer.setTargetName(memberInfo.uname)
    
    closeCb()
end

--加好友
function gotoMakeFriend()
    local args = CCArray:create()
    args:addObject(CCInteger:create(memberInfo.uid))
    args:addObject(CCString:create(""))
    Network.rpc(requestFuncFriend, "friend.applyFriend", "friend.applyFriend", args, true)
end

function requestFuncColeader(cbFlag, dictData, bRet)
    if not bRet then
        return
    end
    if (cbFlag == "guild.setVicePresident")then
        if dictData.ret == "ok" then
            AnimationTip.showTip(GetLocalizeStringBy("key_2675"))
            GuildDataCache.addGuildVPNum(1)
        end
        if dictData.ret == "failed" then
            AnimationTip.showTip(GetLocalizeStringBy("key_2296"))
        end
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
        MemberListLayer.refreshMemberTableView(true)
    end
end

--任命副团长
function gotoMakeColeader()
    local guildInfo = GuildDataCache.getGuildInfo()
    print("TTT",tonumber(guildInfo.vp_num) +1,tonumber(GuildUtil.getMaxViceLeaderNumBy(tonumber(guildInfo.guild_level))))
    if (tonumber(guildInfo.vp_num) +1) > tonumber(GuildUtil.getMaxViceLeaderNumBy(tonumber(guildInfo.guild_level))) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1575"))
    else
        local args = CCArray:create()
        args:addObject(CCInteger:create(memberInfo.uid))
        local returnValue = RequestCenter.guild_setVicePresident(requestFuncColeader,args)
        print(returnValue)
    end
end

--转让军团长
function gotoMakeLeader()
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    require "script/ui/guild/ConfirmCodeLayer"
    ConfirmCodeLayer.showLayer(memberInfo.uid,2001)
end

--踢出军团
function gotoGoOut()
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    if tonumber(memberInfo.member_type) == 2 then
        GuildTipsLayer.showLayer(GetLocalizeStringBy("key_2453") .. memberInfo.uname .. GetLocalizeStringBy("key_3308"),_go,memberInfo.uid,true)
    else
        GuildTipsLayer.showLayer(GetLocalizeStringBy("key_2453") .. memberInfo.uname .. GetLocalizeStringBy("key_3308"),_go,memberInfo.uid,false)
    end
end

function requestFuncNoColeader(cbFlag, dictData, bRet)
    if not bRet then
        return
    end
    if (cbFlag == "guild.unsetVicePresident") then
        if dictData.ret == "ok" then
            AnimationTip.showTip(GetLocalizeStringBy("key_2907"))
            GuildDataCache.addGuildVPNum(-1)
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
            MemberListLayer.refreshMemberTableView(true)
        elseif dictData.ret == "failed" then
            AnimationTip.showTip(GetLocalizeStringBy("key_3287"))
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
            MemberListLayer.refreshMemberTableView(true)
        elseif(dictData.ret == "forbidden_guildwar") then
            -- 军团争霸赛期间，不能使用此功能
            AnimationTip.showTip(GetLocalizeStringBy("lic_1488"))
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
            MemberListLayer.refreshMemberTableView(true)
        else
        end
    end
end

--职位罢免
function noMakeColeader()
    local args = CCArray:create()
    args:addObject(CCInteger:create(memberInfo.uid))
    local returnValue = RequestCenter.guild_unsetVicePresident(requestFuncNoColeader,args)
    print(returnValue)
end

--弹劾军团长
function gotoImpeachment()

    local awayTime = BTUtil:getSvrTimeInterval() - tonumber(memberInfo.last_logoff_time) 
    -- 先判断是否是不在线  add by chengliang
    print("awayTime===", awayTime)
    print("memberInfo.status==", memberInfo.status)
    if tonumber(memberInfo.status) ~= 1 and tonumber(awayTime) > 3*24*3600 then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
        require "script/ui/guild/GuildImpeachmentLayer"
        GuildImpeachmentLayer.showLayer()
    else
        AnimationTip.showTip(GetLocalizeStringBy("key_1501"))
    end
end

--退出军团
function quitGuild()
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    GuildTipsLayer.showLayer(GetLocalizeStringBy("key_2928"),_quit,nil,nil)
end

-- 切磋 add by chengliang
function guildFireAction( tag, itemBtn )
    require "db/DB_Normal_config"
    local n_data = DB_Normal_config.getDataById(1)
    local timesArr = string.split(n_data.competeTimes,"|")

    local myInfo = GuildDataCache.getMineSigleGuildInfo()

    if((tonumber(timesArr[1]) - tonumber(myInfo.playwith_num))<=0)then
        AnimationTip.showTip(GetLocalizeStringBy("key_1574"))
        return
    end
    if((tonumber(timesArr[2]) - tonumber(memberInfo.be_playwith_num)) <= 0 )then
        AnimationTip.showTip(GetLocalizeStringBy("key_3065"))
        return
    end
    local args = Network.argsHandler(memberInfo.uid)

    RequestCenter.guild_fightEachOther(fightEachOtherCallback, args)
end

-- 切磋回调
function fightEachOtherCallback( cbFlag, dictData, bRet )
    if( dictData.err == "ok")then
        local ret = dictData.ret
        local status = ret.errcode
        if( tonumber(ret.errcode) == 1 )then
            AnimationTip.showTip(GetLocalizeStringBy("key_1574"))
            MemberListLayer.refreshMemberTableView(true)
        elseif(tonumber(ret.errcode) == 2)then
            AnimationTip.showTip(GetLocalizeStringBy("key_3065"))
            MemberListLayer.refreshMemberTableView(true)
        else
            GuildDataCache.addPlayDefeautNum(1)
            -- BattleLayer.showBattleWithString(ret.battleRes.client,nil,nil)

            local fightRet = ret.battleRes.client
            -- 调用战斗接口 参数:atk 
            require "script/battle/BattleLayer"
            -- 调用结算面板
            require "script/ui/active/mineral/AfterMineral"
            -- 解析战斗串获得战斗评价
            local amf3_obj = Base64.decodeWithZip(fightRet)
            local lua_obj = amf3.decode(amf3_obj)
            local appraisal = lua_obj.appraisal
            -- 敌人uid
            local uid = lua_obj.team1.uid

            -- added by zhz :判断team1 是否是自己。也就是team1 的uid, 是否为本人的uid
            if(tonumber(uid) == UserModel.getUserUid()  ) then
                uid = lua_obj.team2.uid
            end
            local afterBattleLayer = AfterMineral.createAfterMineralLayer( appraisal, uid, afterOKcallFun,fightRet)
            BattleLayer.showBattleWithString(fightRet, nil, afterBattleLayer)

        end

        
        closeCb()
    end
end

-- 战斗完了回调
function afterOKcallFun()
    MemberListLayer.refreshMemberTableView(true)
end


function showLayer(memInfo)
    init()

    isFriendNet(memInfo.uid)
    memberInfo = memInfo
end

--好友
function createFriend()
    if isFriend == false then
        friend = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(220, 64),GetLocalizeStringBy("key_1928"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        friend:setAnchorPoint(ccp(0.5, 0.5))
        friend:registerScriptTapHandler(gotoMakeFriend)
    else
        friend = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_hui.png","images/common/btn/btn_blue_hui.png",CCSizeMake(220, 64),GetLocalizeStringBy("key_2133"),ccc3(0x8d,0x8d,0x8d),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        friend:setAnchorPoint(ccp(0.5, 0.5))
        friend:registerScriptTapHandler(gotoMakeFriend)
        friend:setEnabled(false)
    end
end

--任命副军团长
function createToColeader()
    --任命副军团长
    toCoLeader = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(220, 64),GetLocalizeStringBy("key_2951"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    toCoLeader:setAnchorPoint(ccp(0.5, 0.5))
    toCoLeader:registerScriptTapHandler(gotoMakeColeader)
end

--转让军团长
function createToLeader()
    --任命军团长
    toLeader = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(220, 64),GetLocalizeStringBy("key_2446"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    toLeader:setAnchorPoint(ccp(0.5, 0.5))
    toLeader:registerScriptTapHandler(gotoMakeLeader)
end

--踢出
function createGoOut()
    --踢出
    goOut = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(220, 64),GetLocalizeStringBy("key_3308"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    goOut:setAnchorPoint(ccp(0.5, 0.5))
    goOut:registerScriptTapHandler(gotoGoOut)
end

--聊天
function createChat()
    --聊天
    pChat = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(220, 64),GetLocalizeStringBy("key_1608"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    pChat:setAnchorPoint(ccp(0.5, 0.5))
    pChat:registerScriptTapHandler(chatPM)
end

--罢免副军团长
function createNoColeader()
    --罢免副军团长
    noCoLeader = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(220, 64),GetLocalizeStringBy("key_2953"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    noCoLeader:setAnchorPoint(ccp(0.5, 0.5))
    noCoLeader:registerScriptTapHandler(noMakeColeader)
end

--弹劾军团长
function createImpeachment()
    --弹劾军团长
    impeachment = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(220, 64),GetLocalizeStringBy("key_1740"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    impeachment:setAnchorPoint(ccp(0.5, 0.5))
    impeachment:registerScriptTapHandler(gotoImpeachment)
end

--退出军团
function createQuitGuild()
    --退出军团
    quieGuild = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(220, 64),GetLocalizeStringBy("key_1182"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    quieGuild:setAnchorPoint(ccp(0.5, 0.5))
    quieGuild:registerScriptTapHandler(quitGuild)
end

--切磋
function createGuildPK()
    guildPK = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(220, 64),GetLocalizeStringBy("key_1886"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    guildPK:setAnchorPoint(ccp(0.5, 0.5))
    guildPK:registerScriptTapHandler(guildFireAction)
end

function createUI(memInfo)
    memberInfo = memInfo

    --被点击人的信息
    print("MEMBERINFO")
	-- print_t(memberInfo)
 --    print_t(GuildDataCache.getGuildInfo())

    --点击人uid
    local uMes = UserModel.getUserInfo()
    local uid = uMes.uid

    --点击人信息
    local uGuildMes = GuildDataCache.getMemberInfoBy(uid)
    -- print_t(uGuildMes)

	_bgLayer = CCLayerColor:create(ccc4(0x00,0x2e,0x49,153))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,999,1500)

    require "script/ui/main/MainScene"
	local myScale = MainScene.elementScale
    local mySize

    --会长点击平民
    if (tonumber(memberInfo.member_type) == 0) and (tonumber(uGuildMes.member_type) == 1) then
	    mySize = CCSizeMake(280,650)
    end
    --会长点击副会长
    if (tonumber(memberInfo.member_type) == 2) and (tonumber(uGuildMes.member_type) == 1) then
        mySize = CCSizeMake(280,650)
    end
    --副会长点击平民
    if (tonumber(memberInfo.member_type) ==0)  and (tonumber(uGuildMes.member_type) == 2) then
        mySize = CCSizeMake(280,540)
    end 

    --副会长点击会长
    if (tonumber(memberInfo.member_type) == 1) and (tonumber(uGuildMes.member_type) == 2) then
        mySize = CCSizeMake(280,540)
    end 
    --点自己
    if uid == memberInfo.uid then
        mySize = CCSizeMake(280,210)
    --平民点会长，副会长，平民
    elseif ((tonumber(uGuildMes.member_type) == 0) or ((tonumber(memberInfo.member_type) == 2) and (tonumber(uGuildMes.member_type) == 2))) then
        mySize = CCSizeMake(280,430)
    end

    local affairsBg = CCScale9Sprite:create("images/guild/affairs/layer1.png")
    affairsBg:setContentSize(mySize)
    affairsBg:setScale(myScale)
    affairsBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    affairsBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(affairsBg)

    local itemInfoSpite = CCScale9Sprite:create("images/guild/affairs/layer2.png")
    --[[if tonumber(memberInfo.member_type) == 1 then
        itemInfoSpite:setContentSize(CCSizeMake(230,70))
    end]]
    --会长点击平民
    if (tonumber(memberInfo.member_type) == 0) and (tonumber(uGuildMes.member_type) == 1) then
        itemInfoSpite:setContentSize(CCSizeMake(230,520))
    end
    --会长点击副会长
    if (tonumber(memberInfo.member_type) == 2) and (tonumber(uGuildMes.member_type) == 1) then
        itemInfoSpite:setContentSize(CCSizeMake(230,520))
    end
    --副会长点击平民
    if (tonumber(memberInfo.member_type) == 0) and (tonumber(uGuildMes.member_type) == 2) then
        itemInfoSpite:setContentSize(CCSizeMake(230,380))
    end 
    --副会长点击会长
    if (tonumber(memberInfo.member_type) == 1) and (tonumber(uGuildMes.member_type) == 2) then
        itemInfoSpite:setContentSize(CCSizeMake(230,380))
    end 
    --点自己
    if uid == memberInfo.uid then
        itemInfoSpite:setContentSize(CCSizeMake(230,170))
    --平民点会长，副会长，平民
    elseif ((tonumber(uGuildMes.member_type) == 0) or ((tonumber(memberInfo.member_type) == 2) and (tonumber(uGuildMes.member_type) == 2))) then
        itemInfoSpite:setContentSize(CCSizeMake(230,310))
    end
    itemInfoSpite:setPosition(ccp(mySize.width*0.5,mySize.height/2))
    itemInfoSpite:setAnchorPoint(ccp(0.5,0.5))
    affairsBg:addChild(itemInfoSpite)

    -- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    affairsBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.08,mySize.height*1.08))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    local menu_b = CCMenu:create()
    menu_b:setPosition(ccp(0,0))
    menu_b:setTouchPriority(-552)
    itemInfoSpite:addChild(menu_b,99)

    --**********************************************************先创建好按钮，方便后面添加************************************************************

    --好友按钮
    

    

    --************************************************************所有按钮创建完毕**********************************************************************************************

    --会长点击平民
    if (tonumber(memberInfo.member_type) == 0) and (tonumber(uGuildMes.member_type) == 1) then
        createFriend()
        friend:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*5/7))
        menu_b:addChild(friend)

        createToColeader()
        toCoLeader:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*4/7))
        menu_b:addChild(toCoLeader)

        createToLeader()
        toLeader:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*3/7))
        menu_b:addChild(toLeader)

        createGoOut()
        goOut:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*2/7))
        menu_b:addChild(goOut)

        createChat()
        pChat:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*1/7))
        menu_b:addChild(pChat)

        createGuildPK()
        guildPK:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5,itemInfoSpite:getContentSize().height*6/7))
        menu_b:addChild(guildPK)
    end
    --会长点击副会长
    if (tonumber(memberInfo.member_type) == 2) and (tonumber(uGuildMes.member_type) == 1) then   
        createFriend()
        friend:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*5/7))
        menu_b:addChild(friend)

        createNoColeader()
        noCoLeader:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*4/7))
        menu_b:addChild(noCoLeader)

        createToLeader()
        toLeader:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*3/7))
        menu_b:addChild(toLeader)

        createGoOut()
        goOut:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*2/7))
        menu_b:addChild(goOut)

        createChat()
        pChat:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*1/7))
        menu_b:addChild(pChat)

        createGuildPK()
        guildPK:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5,itemInfoSpite:getContentSize().height*6/7))
        menu_b:addChild(guildPK)
    end
    --副会长点击平民
    if (tonumber(memberInfo.member_type) == 0)  and (tonumber(uGuildMes.member_type) == 2) then
        createFriend()
        friend:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*3/5))
        menu_b:addChild(friend)

        createGoOut()
        goOut:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*2/5))
        menu_b:addChild(goOut)

        createChat()
        pChat:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*1/5))
        menu_b:addChild(pChat)

        createGuildPK()
        guildPK:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5,itemInfoSpite:getContentSize().height*4/5))
        menu_b:addChild(guildPK)
    end
    --副会长点击会长
    if (tonumber(memberInfo.member_type) == 1) and (tonumber(uGuildMes.member_type) == 2) then   
        createFriend()
        friend:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*2/5))
        menu_b:addChild(friend)

        createImpeachment()
        impeachment:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*3/5))
        menu_b:addChild(impeachment)

        createChat()
        pChat:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*1/5))
        menu_b:addChild(pChat)

        createGuildPK()
        guildPK:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5,itemInfoSpite:getContentSize().height*4/5))
        menu_b:addChild(guildPK)
    end
    --点自己
    if uid == memberInfo.uid then
        createQuitGuild()
        quieGuild:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height/2))
        menu_b:addChild(quieGuild)
    --平民点会长，副会长，平民
    elseif ((tonumber(uGuildMes.member_type) == 0) or ((tonumber(memberInfo.member_type) == 2) and (tonumber(uGuildMes.member_type) == 2))) then
        createFriend()
        friend:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*1/4))
        menu_b:addChild(friend)

        createChat()
        pChat:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*2/4))
        menu_b:addChild(pChat)

        createGuildPK()
        guildPK:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5,itemInfoSpite:getContentSize().height*3/4))
        menu_b:addChild(guildPK)
    end

    -- local pFireMemItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(220, 64),GetLocalizeStringBy("key_1777"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    -- pFireMemItem:setAnchorPoint(ccp(0.5, 0.5))
    -- pFireMemItem:setPosition(ccp(itemInfoSpite:getContentSize().width*0.5, itemInfoSpite:getContentSize().height*0))
    -- pFireMemItem:registerScriptTapHandler(guildFireAction)
    -- menu_b:addChild(pFireMemItem)
end

function requestFunc(cbFlag, dictData, bRet)
    if(bRet == true)then
        local dataRet = dictData.ret
        if(dataRet == "true" or dataRet == true )then
            isFriend = true
        end
        if(dataRet == "false" or dataRet == false  )then
            isFriend = false
        end
    end
    print("^^%%",isFriend)
    createUI(memberInfo)
end

function isFriendNet(uid)
    local args = CCArray:create()
    args:addObject(CCInteger:create(tonumber(uid)))
    Network.rpc(requestFunc, "friend.isFriend", "friend.isFriend", args, true)
end

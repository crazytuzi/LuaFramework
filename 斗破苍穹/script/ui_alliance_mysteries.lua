require"Lang"
UIAllianceMysteries = {}
local touZiArmature1 = nil -- 骰子动画
local touZiArmature2 = nil -- 骰子动画
local image_shaizi1 = nil
local image_shaizi2 = nil 
local userP = nil --玩家位置
local count = nil -- 转动
local step = nil -- 转动后走的步数
local stepAll = nil -- 走动的总的步数
local turnCout = nil --转的次数
local turnNum = nil --转的圈数
local chuQianNum = nil
local MAX_STEP = 24
local MAX_COUNT = 10
local isTeam = nil --是否组队
local award = nil -- 得到的东西
local award2 = nil --掷骰子后 临时存 用于 效果
local shakeArmature = nil
local type = {
    CHUQIAN = 1 , --出千
    SHUANGBEI = 2 , -- 双倍
    JUMUCHENGJIN = 3 , -- 聚木成金
    DIANSHICHENGJIN = 4 --点石成金
}
local tempPai = nil
local choosePaiIndex = nil
local paiNum = nil
local getPai = nil--得到的特殊牌
local choosePai = nil
local isShakeing = nil
local allianceLevel = nil
local paiImage = { "mysteries_chuqian" , "mysteries_cheng2" , "mysteries_jmcj" , "mysteries_dscj" }
UIAllianceMysteries.members = nil
--摇动骰子的过程中需要禁止的一些行为
local function makeUpdate( type )
    local childs = UIManager.uiLayer:getChildren()
    if type == 1 then --禁止
        shakeArmature:setVisible( false )
        for key, obj in pairs(childs) do
            if not tolua.isnull(obj) then
                obj:setEnabled(false)
            end
        end
    elseif type == 2 then --恢复
        shakeArmature:setVisible( true )
        for key, obj in pairs(childs) do
            if not tolua.isnull(obj) then
                obj:setEnabled(true)
            end
        end
    end
end
--数字效果
local function numberAction( node , startN , endN )
 --   cclog( "  " .. startN .. "  " .. endN )
    if tonumber( startN ) >= tonumber( endN ) then
        --node:setScale( 1 )
        return
    end
    local s = tonumber( startN )
    local function callF()      
        if s > tonumber( endN ) then
            node:setScale( 1 )
            return
        end
        node:setScale( 1.5 )
        node:setString( "×" .. s )
        s = s + 1
        node:runAction( cc.Sequence:create( cc.DelayTime:create( 0.02 ) , cc.CallFunc:create(
            callF
        ) ) )
    end
    callF()
end
--刷新材料信息
local function refreshMeterial()
    local awardThings = { 0 , 0 , 0 , 0 , 0 } --1木材2石料3铁矿4金砖5贡献
    local awardThings2 = { 0 , 0 , 0 , 0 , 0 }
    cclog( "award  "..award )
    if award and award ~= "" then
        local obj = utils.stringSplit( award , ";" )
        for key , value in pairs ( obj ) do
            local things = utils.stringSplit( value , "_")
            if tonumber( things[ 1 ] ) == StaticTableType.DictUnionMaterial then
                awardThings[ tonumber( things[ 2 ] ) ] = tonumber( things[ 3 ] )
            else
                awardThings[ 5 ] = tonumber( things[ 3 ] )
            end
        end
    end
    local goods = ""
    local goodsCount = 0 
    if award2 and award2 ~= "" then
        local obj = utils.stringSplit( award2 , ";" )
        for key , value in pairs ( obj ) do
            local things = utils.stringSplit( value , "_")
            if tonumber( things[ 1 ] ) == StaticTableType.DictUnionMaterial then
                awardThings2[ tonumber( things[ 2 ] ) ] = things[ 3 ]
                local getNum = tonumber( things[ 3 ] ) - tonumber( awardThings[ tonumber( things[ 2 ] ) ] )
                if getNum > 0 then
                    if goods ~= "" then
                        goods = goods..";"
                    end
                    goods = goods..things[ 1 ].."_"..things[ 2 ].."_"..getNum
                    goodsCount = goodsCount + 1
                end
            else
                awardThings2[ 5 ] = tonumber( things[ 3 ] )
                local getNum = tonumber( things[ 3 ] ) - tonumber( awardThings[ 5 ] )
                if getNum > 0 then
                    if goods ~= "" then
                        goods = goods..";"
                    end
                    goods = goods..things[ 1 ].."_"..things[ 2 ].."_"..getNum
                    goodsCount = goodsCount + 1
                end
            end
        end
        award = award2
    end   
    local image_tree = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_tree" )   
    image_tree:getChildByName("text_number"):setString( "×"..awardThings[ 1 ] )
    
    local image_stone = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_stone" ) 
    image_stone:getChildByName("text_number"):setString( "×"..awardThings[ 2 ] )
    
    local image_iron = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_iron" ) 
    image_iron:getChildByName("text_number"):setString( "×"..awardThings[ 3 ] )
    
    local image_gold = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_gold" ) 
    image_gold:getChildByName("text_number"):setString( "×"..awardThings[ 4 ] )
    
    local image_alliance = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_alliance" )  
    image_alliance:getChildByName("text_number"):setString( "×"..awardThings[ 5 ] )
    
    local function callF()
        if turnCout >= 10 then
            UIAllianceMysteriesTotal.setData({ tree = awardThings2[ 1 ] , stone = awardThings2[ 2 ] , iron = awardThings2[ 3 ] , gold = awardThings2[ 4 ] , alliance = awardThings2[ 5 ]  })
            UIManager.pushScene( "ui_alliance_mysteries_total" ) 
        end
        numberAction( image_tree:getChildByName("text_number") , awardThings[ 1 ] , awardThings2[ 1 ] )
        numberAction( image_stone:getChildByName("text_number") , awardThings[ 2 ] , awardThings2[ 2 ] )
        numberAction( image_iron:getChildByName("text_number") , awardThings[ 3 ] , awardThings2[ 3 ] )
        numberAction( image_gold:getChildByName("text_number") , awardThings[ 4 ] , awardThings2[ 4 ] )
        numberAction( image_alliance:getChildByName("text_number") , awardThings[ 5 ] , awardThings2[ 5 ] )
        UIAllianceMysteries.refreshPai( true )
    end
    if goodsCount > 0 then
        utils.showGetThings( goods , nil , nil , nil , nil , true )
        UIAllianceMysteries.Widget:runAction( cc.Sequence:create( cc.DelayTime:create( goodsCount * 1.3 ) , cc.CallFunc:create(
            callF
        )))
    else
        shakeArmature:setVisible( true )
        makeUpdate( 2 )
    end

end
--刷新界面信息
local function refreshInfo( notRefreshImage )  
    local text_hint = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "text_hint" )
    --第几圈 奖励加成20%
    text_hint:setString(Lang.ui_alliance_mysteries1.. ( turnNum + 1 ) ..Lang.ui_alliance_mysteries2..turnNum * 20 .."%")
    local text_number = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "text_number" ) -- 摇动次数
    text_number:setString("("..turnCout.."/"..MAX_COUNT..")")

    for key ,value in pairs( DictUnionFam ) do
        if value.things and value.things ~= "" then
            local obj = utils.getItemProp( value.things )
            local image_floor = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_floor"..key )

            
                if choosePai[ 3 ] == 1 and obj.tableTypeId == StaticTableType.DictUnionMaterial and obj.tableFieldId == 1 then
                    obj = utils.getItemProp( obj.tableTypeId.."_4_"..obj.count )
                elseif choosePai[ 4 ] == 1 and obj.tableTypeId == StaticTableType.DictUnionMaterial and obj.tableFieldId == 2 then
                    obj = utils.getItemProp( obj.tableTypeId.."_4_"..obj.count )
                end
           
            local num = math.floor( obj.count + obj.count * turnNum * 0.2 )
            if choosePai[ 2 ] == 1 then
                num = num * 2
            end
            if image_floor:getChildByName( "meterial" ) then
                local imageIcon = image_floor:getChildByName( "meterial" )
                if not notRefreshImage then
                    imageIcon:loadTexture( obj.smallIcon )
                end
                local number = imageIcon:getChildByTag( 2 )
                number:setString( num )
            else
                local number = ccui.ImageView:create("image/mNum.png")  
                local text = ccui.Text:create()             
                local imageIcon = ccui.ImageView:create(obj.smallIcon)
                imageIcon:setAnchorPoint( cc.p( 0.5 , 0.5 ) )
                imageIcon:setPosition( cc.p( image_floor:getContentSize().width / 2 , image_floor:getContentSize().height / 2 + 40 ) )
                imageIcon:setName("meterial")
                number:setPosition( cc.p( imageIcon:getContentSize().width / 2 , 5 ) )
                imageIcon:addChild( number , 1 , 1 )
                text:setFontName( dp.FONT )
                text:setFontSize( 16 )
                text:setString( num )
                text:setPosition( cc.p( imageIcon:getContentSize().width / 2 , 5 ) )
                imageIcon:addChild( text , 2 , 2 )
                image_floor:addChild( imageIcon , 100 )
            end
        end
    end
end
--刷新卡牌信息
function UIAllianceMysteries.refreshPai( isNR )
    local image_di_down = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_di_down" )
    for i = 1 , 4 do
        local pai = image_di_down:getChildByName( "image_pai"..i )
        local image_choose = pai:getChildByName( "image_choose" )
        if choosePai[ i ] == 0 then
            pai:loadTexture("ui/mysteries_bei.png")
            image_choose:setVisible( false )
        elseif choosePai[ i ] == 1 then
            image_choose:setVisible( true )
            if choosePaiIndex and choosePaiIndex == i then
                image_choose:setScale( 0.5 )
                image_choose:stopAllActions()
                image_choose:runAction( cc.ScaleTo:create( 0.2 , 1 ) )
            end
            pai:loadTexture("image/"..paiImage[ i ]..".png")
        end
        pai:getChildByName("text_number"):setString( paiNum[ i ] )
    end
    local text_state = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "text_state" )
    if chuQianNum and choosePai[ type.CHUQIAN ] == 1 then
        text_state:setString( Lang.ui_alliance_mysteries3..chuQianNum )
    else
        text_state:setString( "" )
    end
    if not isNR then
        refreshInfo()
    else
       -- getPai = "10_1"--测试用
        if getPai and getPai ~= "" then
            makeUpdate( 1 )
            local paiThings = utils.stringSplit( getPai , "_" ) 
            id = tonumber(paiThings[ 1 ]) - 8
            local imageIcon = ccui.ImageView:create()
            imageIcon:loadTexture( "image/"..paiImage[ id ]..".png" )
            imageIcon:setPosition( cc.p( UIManager.screenSize.width / 2 , UIManager.screenSize.height / 2 + 100 ) )
            UIAllianceMysteries.Widget:addChild( imageIcon , 100 )
            local function movePai()
                imageIcon:removeFromParent()
                local pai = image_di_down:getChildByName( "image_pai"..id )
                local effect = cc.ParticleSystemQuad:create("particle/star/ui_anim60_lizi02.plist")
                effect:setPosition( cc.p( UIManager.screenSize.width / 2 , UIManager.screenSize.height / 2 + 100 ) )
                UIAllianceMysteries.Widget:addChild( effect , 101 )
                effect:runAction( cc.Sequence:create( cc.MoveTo:create( 0.5 , cc.p( pai:getPositionX() , pai:getPositionY() - pai:getContentSize().height / 2 ) ) , cc.CallFunc:create(
                    function ()
                        effect:removeFromParent()
                        shakeArmature:setVisible( true )
                        makeUpdate( 2 )
                     --   paiNum[ id ] = tonumber( paiThings[ 2 ] )
                        local number = pai:getChildByName("text_number")   
                        number:runAction( cc.Sequence:create( cc.ScaleTo:create( 0.5 , 1.2 ) , cc.ScaleTo:create( 0.5 , 1 ) , cc.CallFunc:create(
                            function ()
                               -- number:setString( paiNum[ id ] )
                            end
                        ) ) )      
                     --   number:setString( paiNum[ id ] )
                         if tempPai and tempPai ~= "" then
                            local paiObjs = utils.stringSplit( tempPai , ";" )
                            for key , value in pairs( paiObjs ) do 
                                local paiThings = utils.stringSplit( value , "_" ) 
                                paiNum[ tonumber(paiThings[ 1 ]) - 8 ] = tonumber( paiThings[ 2 ] )
                            end 
                        end                        
                        UIAllianceMysteries.refreshPai()
                        pai:runAction( cc.Sequence:create( utils.addFrameParticle( pai , true , false , true ) , cc.DelayTime:create( 1 ) , cc.CallFunc:create(
                            function ()
                                utils.addFrameParticle( pai )
                            end
                        ) ) )
                    end
                ) ) )
            end
            imageIcon:runAction( cc.Sequence:create( cc.ScaleTo:create( 0.2 , 1.2 ) , cc.ScaleTo:create( 0.2 , 1 ) , cc.DelayTime:create( 0.5 ) , cc.ScaleTo:create( 0.3 , 0.1 ) , cc.CallFunc:create(             
                movePai
            ) ) )
        else
            shakeArmature:setVisible( true )
            makeUpdate( 2 )
        end
    end
end
--展示卡牌信息
local function showCardInfo()
    local image_di_down = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_di_down" )
    local image_di_info = image_di_down:getChildByName( "image_di_info" )
    local btn_use = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "btn_use" )--使用卡牌
    btn_use:setVisible( true )
    if choosePaiIndex then
        if paiNum[ choosePaiIndex ] <= 0 then
            utils.GrayWidget( btn_use , true  )
        else
            utils.GrayWidget( btn_use , false  )
        end
        image_di_info:getChildByName("text_info"):setString( DictPlayerBaseProp[ tostring( choosePaiIndex + 8 ) ].description )--合理运用秘境运势牌可以提高自身收益
        local pai = image_di_down:getChildByName( "image_pai"..choosePaiIndex )
        pai:setTag( choosePaiIndex )
        --pai:loadTexture("image/"..paiImage[ choosePaiIndex ]..".png")
        local texture = "image/"..paiImage[ choosePaiIndex ]..".png"
        local action1 = cc.Sequence:create( cc.ScaleTo:create( 0.2 , 0.1 , 1 ) , cc.CallFunc:create(
            function ( aNode )
                --if choosePaiIndex then
                    aNode:loadTexture( texture )
                    aNode:runAction( cc.Sequence:create(
                        cc.ScaleTo:create( 0.2 , 1 , 1 ) , cc.CallFunc:create(
                            function ( bNode )
                            
                            end
                        ) ) )
               -- end
            end
        ) )
        pai:stopAllActions()
        pai:runAction( cc.Sequence:create( action1 , cc.DelayTime:create( 2 ) , cc.CallFunc:create(
            function ( node )
                if choosePaiIndex and node:getTag() == choosePaiIndex and choosePai[ choosePaiIndex ] == 0 then
                    node:stopAllActions()
                    node:runAction( cc.Sequence:create( cc.ScaleTo:create( 0.2 , 0.1 , 1 ) , cc.CallFunc:create(
                        function ( aNode )
                            aNode:loadTexture( "ui/mysteries_bei.png" )
                            aNode:runAction( cc.Sequence:create(
                                cc.ScaleTo:create( 0.2 , 1 , 1 ) , cc.CallFunc:create(
                                    function ( bNode )
                                        choosePaiIndex = nil
                                        --utils.GrayWidget( btn_use , false  )
                                        btn_use:setVisible( false )
                                        image_di_info:getChildByName("text_info"):setString( Lang.ui_alliance_mysteries4 )--合理运用秘境运势牌可以提高自身收益
                                    end
                                ) ) )
                        end
                    ) ) )
                end
            end
        ) ) )
--        pai:runAction( cc.Sequence:create( cc.DelayTime:create( 2 ) , cc.CallFunc:create(
--            function ( aNode )
--                if choosePaiIndex and aNode:getTag() == choosePaiIndex and choosePai[ choosePaiIndex ] == 0 then
--                    choosePaiIndex = nil
--                    pai:loadTexture("ui/mysteries_bei.png")
--                    utils.GrayWidget( btn_use , false  )
--                    image_di_info:getChildByName("text_info"):setString( "合理运用秘境运势牌可以提高自身收益" )--合理运用秘境运势牌可以提高自身收益
--                end
--            end
--        ) ) )
    else
       -- utils.GrayWidget( btn_use , false  )
        btn_use:setVisible( false )
        image_di_info:getChildByName("text_info"):setString( Lang.ui_alliance_mysteries5 )--合理运用秘境运势牌可以提高自身收益
    end      
end
--得到物品
local function getThingDialog()
    refreshMeterial()
    count = nil 
    refreshInfo()
end
--移动骰子
local function moveStep( _step )
    shakeArmature:setVisible( false )
    makeUpdate( 1 )
    local startStep = stepAll 
    stepAll = stepAll + _step
    local function callF()
        if startStep >= stepAll then            
            getThingDialog()
            return
        end     
        local tempNum = math.floor( ( startStep - 1 ) / MAX_STEP )
        if tempNum > turnNum then
            turnNum = tempNum
            refreshInfo( true )
        end
        startStep = startStep + 1
        local image_floor = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_floor".. ( ( ( startStep - 1 ) % MAX_STEP ) + 1 ) )    
        userP:runAction( cc.Sequence:create( cc.MoveTo:create( 0.2 , cc.p( image_floor:getPositionX() , image_floor:getPositionY() ) ) , cc.DelayTime:create( 0.1 ) , cc.CallFunc:create( callF ) ) )
    end
    callF()
end
local function onMovementEvent(armature, movementType, movementID)
    if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
        if not count then

        elseif count <= 0 then -- 骰子停下时的操作      
            local step1 = step --utils.random( 1 , 6 )    
--            touZiArmature1:getAnimation():gotoAndPlay( step1 )
--            touZiArmature1:getAnimation():pause()
            if isTeam then
                step1 = math.floor( step / 2 )
            end
            touZiArmature1:setVisible( false )
            image_shaizi1:setOpacity( 255 )
            image_shaizi1:loadTexture( "image/touzi"..step1..".png" )           
         --   touZiArmature2:getAnimation():playWithIndex(0)
            if isTeam then
                local step2 = step - step1
                step = step1 + step2
                image_shaizi2:runAction( cc.Sequence:create( cc.DelayTime:create( 0.2 ) , cc.CallFunc:create( function ()
    --                    touZiArmature2:getAnimation():gotoAndPlay( step2 )
    --                    touZiArmature2:getAnimation():pause()
                        touZiArmature2:setVisible( false )
                        image_shaizi2:setOpacity( 255 )
                        image_shaizi2:loadTexture( "image/touzi"..step2..".png" )
                        moveStep( step )
                end ) ) ) 
            else
              --  step = step1
                cclog("step :"..step )
                moveStep( step )
            end         
        elseif count == 100 then
            touZiArmature1:getAnimation():playWithIndex(0)
            if isTeam then
                image_shaizi2:runAction( cc.Sequence:create( cc.DelayTime:create( 0.2 ) , cc.CallFunc:create( function ()
                    touZiArmature2:getAnimation():playWithIndex(0)
                end ) ) ) 
            end
        else
            touZiArmature1:getAnimation():playWithIndex(0)
            if isTeam then
                image_shaizi2:runAction( cc.Sequence:create( cc.DelayTime:create( 0.2 ) , cc.CallFunc:create( function ()
                    touZiArmature2:getAnimation():playWithIndex(0)
                end ) ) ) 
            end
            count = count - 1
        end
    end
end
--根据人物id 获取联盟成员data
local function getUnioMemberData( id )
    local data = nil
    if UIAllianceMysteries.members then
        for key ,value in pairs( UIAllianceMysteries.members ) do
            if tonumber( value.int["3"] ) == tonumber( id ) then
                data = value 
                break
            end
        end
    end
    return data
end
local function errorCallBack( pack )
    if pack.header == StaticMsgRule.runRoll then
        makeUpdate( 2 )
    end
end
local function callBack( pack )
    if pack.header == StaticMsgRule.refresh then
        turnCout = MAX_COUNT - pack.msgdata.int.rollNum
        local teamId = pack.msgdata.int.teamMember
        local pai = pack.msgdata.string.specialThings
        award = pack.msgdata.string.award
        stepAll = pack.msgdata.int.step
        if stepAll > 0 then
            turnNum = math.floor( ( stepAll - 1 ) / MAX_STEP )
        else
            turnNum = 0
        end
        cclog( "--------------------" )
        cclog( "turnCount :"..turnCout )
        if teamId then
            cclog( "teamId :"..teamId )
        end
        cclog( "pai :"..pai )
        cclog( "award :"..award )
        cclog( "stepAll :"..stepAll )
        cclog( "--------------------" )
        local dictCard = DictCard[tostring(net.InstPlayer.int["32"])]
        local image1 = userP:getChildByTag( 1 )      
        utils.addBorderImage( StaticTableType.DictCard , dictCard.id , image1 )
        local dataSelf = getUnioMemberData( tonumber(net.InstPlayer.int["1"]) )
        local selfCardId = utils.stringSplit(dataSelf.string["13"],"_")[1]
        local isAwake = tonumber(utils.stringSplit(dataSelf.string["13"],"_")[2])
        if isAwake == 1 then
            image1:getChildByTag(1):loadTexture( "image/" .. DictUI[tostring(DictCard[tostring(selfCardId)].awakeSmallUiId)].fileName )
        else
            image1:getChildByTag(1):loadTexture( "image/" .. DictUI[tostring(DictCard[tostring(selfCardId)].smallUiId)].fileName )
        end

        refreshInfo()
        if teamId == -1 then
            UIAllianceMysteries.setPersionN( 2 , -1 )
        elseif teamId > 0 then
            local data = getUnioMemberData( teamId )
            if data then
                UIAllianceMysteries.setPersionN( 2 , tostring( data.string["13"] ) )
            else
                cclog("为什么此联盟没有此id的成员呢")
            end
        else
            UIAllianceMysteries.setPersionN( 1 )
        end        
        if stepAll == 0 then
            local image_floor1 = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_floor0")
            image_floor1:setVisible( true )
            userP:setPosition( cc.p( image_floor1:getPositionX() , image_floor1:getPositionY() ) )
        else
            local image_floor = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_floor0")
            image_floor:setVisible( false )
            local image_floor1 = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_floor"..( ( ( stepAll - 1 ) % MAX_STEP ) + 1 ) )
            userP:setPosition( cc.p( image_floor1:getPositionX() , image_floor1:getPositionY() ) )
        end
        paiNum = { 0 , 0 , 0 , 0 }
        if pai and pai ~= "" then
            local paiObjs = utils.stringSplit( pai , ";" )
            for key , value in pairs( paiObjs ) do 
                local paiThings = utils.stringSplit( value , "_" ) 
                paiNum[ tonumber(paiThings[ 1 ]) - 8 ] = tonumber( paiThings[ 2 ] )
            end
        end
        UIAllianceMysteries.refreshPai()
        refreshMeterial()
        local layer = UIAllianceMysteries.Widget:getChildByName( "accelerometer" )
        layer:setAccelerometerEnabled( true )
    elseif pack.header == StaticMsgRule.runRoll then      
        count = 0
        step = pack.msgdata.int.step - stepAll
        turnCout = turnCout + 1
        local image_floor = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_floor0")
        image_floor:setVisible( false )
       -- refreshInfo()
        for i = 1 , 4 do
            choosePai[ i ] = 0
        end
        local pai = pack.msgdata.string.specialThings
        award2 = pack.msgdata.string.award
--        paiNum = { 0 , 0 , 0 , 0 }
--        if pai and pai ~= "" then
--            local paiObjs = utils.stringSplit( pai , ";" )
--            for key , value in pairs( paiObjs ) do 
--                local paiThings = utils.stringSplit( value , "_" ) 
--           --     cclog( "" .. paiThings[ 1 ] .."  " .. paiThings[ 2 ] )
--                paiNum[ tonumber(paiThings[ 1 ]) - 8 ] = tonumber( paiThings[ 2 ] )
--            end
--        end
        getPai = nil
       
        if pai and pai ~= "" then
             tempPai = pai
--            local paiObjs = utils.stringSplit( pai , ";" )
--            for key , value in pairs( paiObjs ) do 
--                local paiThings = utils.stringSplit( value , "_" ) 
--           --     cclog( "" .. paiThings[ 1 ] .."  " .. paiThings[ 2 ] )
----                local aaa = tonumber( paiThings[ 2 ] ) - paiNum[ tonumber(paiThings[ 1 ]) - 8 ]
----                if aaa > 0 then
----                    getPai = value
----                    break
----                end
--                paiNum[ tonumber(paiThings[ 1 ]) - 8 ] = tonumber( paiThings[ 2 ] )
--            end 
        end
        local gift = pack.msgdata.int.gift
        if gift and gift > 0 then
            getPai = gift.."_1"
           -- paiNum[ tonumber(gift) - 8 ] = paiNum[ tonumber(gift) - 8 ] - 1
        end
        choosePaiIndex = nil
        local btn_use = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "btn_use" )--使用卡牌
            btn_use:setVisible( false )
            btn_use:setTitleText( Lang.ui_alliance_mysteries6 )
            local image_di_down = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_di_down" )
            local image_di_info = image_di_down:getChildByName( "image_di_info" )
            image_di_info:getChildByName("text_info"):setString( Lang.ui_alliance_mysteries7 )  

        if not getPai then
            paiNum = { 0 , 0 , 0 , 0 }
            local paiObjs = utils.stringSplit( pai , ";" )
            for key , value in pairs( paiObjs ) do 
                local paiThings = utils.stringSplit( value , "_" ) 
                paiNum[ tonumber(paiThings[ 1 ]) - 8 ] = tonumber( paiThings[ 2 ] )
            end   
            
           -- UIAllianceMysteries.refreshPai()
             
        end
       -- refreshPai( true )
    elseif pack.header == StaticMsgRule.unionMember then
        local unionMember = pack.msgdata.message.unionMember
		UIAllianceMysteries.members = {}
		for key, obj in pairs(unionMember.message) do
			UIAllianceMysteries.members[#UIAllianceMysteries.members + 1] = obj        
		end
        local sendData = nil
        sendData = {
            header = StaticMsgRule.refresh ,
            msgdata = {}
        }
        netSendPackage( sendData , callBack )
    end

end
--1323 refresh 1324 enterUnionTeam 1325 runRoll
local function netSendData( type )
    local sendData = nil
    if type == 1 then
        sendData = {
            header = StaticMsgRule.refresh ,
            msgdata = {}
        }
    elseif type == 2 then
        local _chuqian = 0
        if choosePai[1] == 1 then
            _chuqian = chuQianNum
        end
       -- cclog( ""..paiNum[ 1 ].. "  " ..paiNum[ 2 ].. "  "..paiNum[ 3 ].. "  "..paiNum[ 4 ] )
        if choosePai[ 1 ] == 1 then
            paiNum[ 1 ] = paiNum[ 1 ] - 1
        end
        if choosePai[ 2 ] == 1 then
            paiNum[ 2 ] = paiNum[ 2 ] - 1
        end
        if choosePai[ 3 ] == 1 then
            paiNum[ 3 ] = paiNum[ 3 ] - 1
        end
        if choosePai[ 4 ] == 1 then
            paiNum[ 4 ] = paiNum[ 4 ] - 1
        end
       -- cclog( ""..paiNum[ 1 ].. "  " ..paiNum[ 2 ].. "  "..paiNum[ 3 ].. "  "..paiNum[ 4 ] )
        sendData = {
            header = StaticMsgRule.runRoll ,
            msgdata = {
                int = {
                    rollNum = _chuqian ,
                    cheat = choosePai[1] ,
                    double = choosePai[2] ,
                    changeWood = choosePai[3] ,
                    changeStone = choosePai[4] 
                }
            }
        }
    elseif type == 3 then
        sendData = {
            header = StaticMsgRule.unionMember ,
            msgdata = {
                int={
                    instUnionMemberId=net.InstUnionMember.int["1"]
                }
            }
        }
    end
    netSendPackage( sendData , callBack , errorCallBack )
end
function startTouZi() --骰子开始转动
    if turnCout >= MAX_COUNT then
        UIManager.showToast(Lang.ui_alliance_mysteries8)
        return
    end
    if count then
        cclog( "count : "..count )
        return
    end
    AudioEngine.playEffect("sound/touzi.mp3")
    makeUpdate( 1 )
    image_shaizi1:setOpacity( 0 )
    touZiArmature1:setVisible( true )   
    touZiArmature1:getAnimation():playWithIndex(0)

    if isTeam then
        image_shaizi2:runAction( cc.Sequence:create( cc.DelayTime:create( 0.2 ) , cc.CallFunc:create( function ()
            image_shaizi2:setOpacity( 0 )
            touZiArmature2:setVisible( true )   
            touZiArmature2:getAnimation():playWithIndex(0)
        end ) ) )
    end

    count = 100


    netSendData( 2 )
    
end

function UIAllianceMysteries.init()
    image_shaizi1 = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_shaizi1" )--骰子
    image_shaizi2 = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_shaizi2" )--骰子
    local animPath = "ani/ui_anim/ui_anim65/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. 65 .. ".ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. 65 .. ".ExportJson")
    touZiArmature2 = ccs.Armature:create("ui_anim65")
    touZiArmature2:setPosition( cc.p( image_shaizi2:getPositionX() , image_shaizi2:getPositionY() - 23 ) )
    UIAllianceMysteries.Widget:addChild( touZiArmature2 , 100 )
    touZiArmature2:setVisible( false )
    --touZiArmature2:getAnimation():setMovementEventCallFunc(onMovementEvent)

    touZiArmature1 = ccs.Armature:create("ui_anim65")
    touZiArmature1:setPosition( cc.p( image_shaizi1:getPositionX() , image_shaizi1:getPositionY() - 23 ) )
    UIAllianceMysteries.Widget:addChild( touZiArmature1 , 100 )
    touZiArmature1:setVisible( false )
    touZiArmature1:getAnimation():setMovementEventCallFunc(onMovementEvent)

    animPath = "ani/ui_anim/ui_anim20/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. 20 .. ".ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. 20 .. ".ExportJson")
    userP = ccs.Armature:create("ui_anim20")
    local dictCard = DictCard["1"]
--		if dictCard then
--			ui_teamIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
--		end
    local userImage = ccui.ImageView:create( "image/" .. DictUI[tostring(dictCard.smallUiId)].fileName )
    local qualityImage = ccui.ImageView:create()
    utils.addBorderImage( StaticTableType.DictCard , dictCard.id , qualityImage )
    userImage:setPosition( cc.p( qualityImage:getContentSize().width / 2 , qualityImage:getContentSize().height / 2 ) )
    qualityImage:addChild( userImage , 1 , 1 )
    qualityImage:setScale( 0.5 )
    qualityImage:setPosition( cc.p( -10 , 20 ) )   
    userP:addChild( qualityImage , 100 , 1 )

    userImage = ccui.ImageView:create( "image/" .. DictUI[tostring(dictCard.smallUiId)].fileName )
    qualityImage = ccui.ImageView:create()
    utils.addBorderImage( StaticTableType.DictCard , dictCard.id , qualityImage )
    userImage:setPosition( cc.p( qualityImage:getContentSize().width / 2 , qualityImage:getContentSize().height / 2 ) )
    qualityImage:addChild( userImage , 1 , 1 )
    qualityImage:setScale( 0.5 )
    qualityImage:setPosition( cc.p( 10 , 20 ) )   
    userP:addChild( qualityImage , 99 , 2 )


    local image_floor1 = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_floor1" )
    --userP:setScale( 0.2 )
    userP:getAnimation():playWithIndex( 1 )
    userP:setPosition( cc.p( image_floor1:getPositionX() , image_floor1:getPositionY() ) )
    UIAllianceMysteries.Widget:addChild( userP , 100 )

    animPath = "ani/ui_anim/ui_anim66/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. 66 .. ".ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. 66 .. ".ExportJson")
    shakeArmature = ccs.Armature:create("ui_anim66") --摇一摇动画
    shakeArmature:setPosition( cc.p( UIManager.screenSize.width / 2 , UIManager.screenSize.height / 2 ) )
    shakeArmature:getAnimation():playWithIndex( 0 )
    UIAllianceMysteries.Widget:addChild( shakeArmature , 1 )

    local btn_back = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "btn_back" )--返回
    local btn_rank = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "btn_rank" )--排行
    local btn_team = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "btn_team" )
    local btn_help = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "btn_help" )--帮助
    local btn_use = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "btn_use" )--使用卡牌
    local image_di_down = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_di_down" )
    local image_pai = {} --四张卡牌
    for i = 1 , 4 do
        local pai = image_di_down:getChildByName( "image_pai"..i )
        table.insert( image_pai , pai )
    end
    local function onEvent( sender , eventType )
         if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIAllianceActivity.show({ allianceLevel = allianceLevel })
            elseif sender == btn_rank then
                UIManager.pushScene( "ui_alliance_mysteries_rank" )
            elseif sender == btn_team then
                if allianceLevel and allianceLevel < 3 then
                    UIManager.showToast( Lang.ui_alliance_mysteries9 )
                elseif isTeam then
                    UIManager.showToast( Lang.ui_alliance_mysteries10 )
                elseif stepAll > 0 then
                    UIManager.showToast( Lang.ui_alliance_mysteries11 )
                else 
                    UIManager.pushScene( "ui_alliance_mysteries_team" )
                end
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 20 , titleName = Lang.ui_alliance_mysteries12 } )
            elseif sender == btn_use then
                if not paiNum then
                    UIManager.showToast( Lang.ui_alliance_mysteries13 )
                    return
                elseif paiNum[ choosePaiIndex ] == 0 then
                    UIManager.showToast( Lang.ui_alliance_mysteries14 )
                    return
                elseif choosePai[ choosePaiIndex ] == 0 then
                    if choosePaiIndex == type.CHUQIAN then
                        choosePai[ choosePaiIndex ] = 1
                        local perN = 1
                        if isTeam then
                            perN = 2
                        end
                        UIAllianceMysteriesCq.setData( { num = perN } )
                        UIManager.pushScene( "ui_alliance_mysteries_cq" )                      
                    else               
                        choosePai[ choosePaiIndex ] = 1
                        btn_use:setTitleText( Lang.ui_alliance_mysteries15 )
                    end
                elseif choosePai[ choosePaiIndex ] == 1 then
                    choosePai[ choosePaiIndex ] = 0
                    btn_use:setTitleText( Lang.ui_alliance_mysteries16 )
                    if choosePaiIndex == type.CHUQIAN then
                        chuQianNum = nil
                    end
                    choosePaiIndex = nil
                    showCardInfo()
                end    
                UIAllianceMysteries.refreshPai()
            elseif sender == image_shaizi2 or sender == image_shaizi1 then
                if turnCout >= MAX_COUNT then
                    UIManager.showToast(Lang.ui_alliance_mysteries17)
                else
                    if count then

                    elseif not isTeam and stepAll == 0 then
                        if allianceLevel and allianceLevel < 3 then
                            startTouZi()
                        else
                            local function sureCallBack()
                                if allianceLevel and allianceLevel < 3 then
                                    UIManager.showToast( Lang.ui_alliance_mysteries18 )
                                else
                                    UIManager.pushScene( "ui_alliance_mysteries_team" )
                                end
                            end
                            local function cancelCallBack()
                        
                                    startTouZi()
                            end
                            utils.showDialogSureAndCancel( Lang.ui_alliance_mysteries19 , { sure = Lang.ui_alliance_mysteries20 , cancel = Lang.ui_alliance_mysteries21 } , sureCallBack , cancelCallBack )
                        end
                    else
                        startTouZi()
                    end
                end
            end
            for key , value in pairs( image_pai ) do
                if sender == value then
                    if choosePaiIndex and choosePaiIndex == key then
                        return
                    end                  
                    choosePaiIndex = key   
                    UIAllianceMysteries.refreshPai()     
                    btn_use:setVisible( true )                            
                    if choosePai[ key ] == 1 then
                      --  showCardInfo()
                        btn_use:setTitleText( Lang.ui_alliance_mysteries22 )
                    else
                        showCardInfo()
                        btn_use:setTitleText( Lang.ui_alliance_mysteries23 )
                    end
                end
            end
         end
    end
    btn_back:setPressedActionEnabled( true )
    btn_back:addTouchEventListener( onEvent )
    btn_rank:setPressedActionEnabled( true )
    btn_rank:addTouchEventListener( onEvent )
    btn_team:setPressedActionEnabled( true )
    btn_team:addTouchEventListener( onEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )
    btn_use:setPressedActionEnabled( true )
    btn_use:addTouchEventListener( onEvent )
    image_shaizi2:setTouchEnabled( true )
    image_shaizi2:addTouchEventListener( onEvent )
    image_shaizi1:setTouchEnabled( true )
    image_shaizi1:addTouchEventListener( onEvent )
    for key , value in pairs( image_pai ) do
        value:setTouchEnabled( true )
        value:addTouchEventListener( onEvent )
    end


    local layer = cc.Layer:create()
    -- 创建一个精灵，这里是个球  
    local ball = cc.Sprite:create()  
    -- 将球添加到层中  
    layer:addChild(ball)  
    layer:setAccelerometerEnabled( false )
    local UPDATE_INTERVAL = 100 --时间间隔
    local mLastUpdateTime = 0 -- 上次检测时间
    local mLastX, mLastY, mLastZ = 0 , 0 , 0 --上一次检测时，加速度在x、y、z方向上的分量，用于和当前加速度比较求差。
	local shakeThreshold = 4--摇晃检测阈值，决定了对摇晃的敏感程度，越小越敏感。
    -- 用来回调的方法  
    local function accelerometerListener(event,x,y,z,timestamp)  
        local currentTime = utils.getCurrentTime() * 1000
        local diffTime = currentTime - mLastUpdateTime     
        if diffTime < UPDATE_INTERVAL then
		--	return
		end
        mLastUpdateTime = currentTime
        local deltaX = x - mLastX
		local deltaY = y - mLastY
		local deltaZ = z - mLastZ
		mLastX = x
		mLastY = y
		mLastZ = z
		local delta = math.sqrt( deltaX * deltaX + deltaZ * deltaZ ) * 10000 / diffTime 
        
        local nowGX = x * 9.81
        local nowGY = y * 9.81
        local nowGZ = z * 9.81 
--        cc.JNIUtils:logAndroid( "------------------------"..nowGX .. "  " ..nowGY .. "  "..nowGZ  )
--        if(nowGX<-10.0 or nowGX>10.0) and (nowGY<-10.0 or nowGY>10.0) and (nowGZ<-10.0 or nowGZ>10.0) then
--           startTouZi()
--        end
        if math.abs( nowGX ) + math.abs( nowGY ) + math.abs( nowGZ ) > 30 then
           -- cc.JNIUtils:logAndroid( "------------------------"..nowGX .. "  " ..nowGY .. "  "..nowGZ  )
           -- startTouZi()
            if count then

            elseif not isTeam and stepAll == 0 then
                if allianceLevel and allianceLevel < 3 then
                    startTouZi()
                else
                    local layer = UIAllianceMysteries.Widget:getChildByName( "accelerometer" )               
                    local function sureCallBack()
                        layer:setAccelerometerEnabled( true )
                        if allianceLevel and allianceLevel < 3 then
                            UIManager.showToast( Lang.ui_alliance_mysteries24 )
                        else
                            UIManager.pushScene( "ui_alliance_mysteries_team" )
                        end
                    end
                    local function cancelCallBack()
                        layer:setAccelerometerEnabled( true )
                        startTouZi()
                    end
                    layer:setAccelerometerEnabled( false )
                    utils.showDialogSureAndCancel( Lang.ui_alliance_mysteries25 , { sure = Lang.ui_alliance_mysteries26 , cancel = Lang.ui_alliance_mysteries27 } , sureCallBack , cancelCallBack )
                end
            else
                startTouZi()
            end
        end
--		if delta > shakeThreshold and ( math.abs( deltaX ) * 10000 / diffTime > 3 or math.abs( deltaZ ) * 10000 / diffTime > 3 ) then --当加速度的差值大于指定的阈值，认为是一个摇晃
--            isShakeing = true
--			startTouZi()
--		end
      --  cc.JNIUtils:logAndroid( "------------------------"..deltaX.."   "..deltaY.."  "..deltaZ.."  "..delta )
--        if deltaX * deltaX > 1 * 1 then
--            cc.JNIUtils:logAndroid( "X------------------------"..deltaX.."   "..deltaY.."  "..deltaZ.."  "..delta )
--            startTouZi()
--        elseif deltaY * deltaY > 1 * 1 then
--            cc.JNIUtils:logAndroid( "Y------------------------"..deltaX.."   "..deltaY.."  "..deltaZ.."  "..delta )
--            startTouZi()
--        elseif deltaZ * deltaZ > 1 * 1 then
--            cc.JNIUtils:logAndroid( "Z------------------------"..deltaX.."   "..deltaY.."  "..deltaZ.."  "..delta )
--            startTouZi()
--        end
    end
    -- 创建一个重力加速计事件监听器  
    local listerner  = cc.EventListenerAcceleration:create(accelerometerListener)  
    layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,ball) 
    layer:setName("accelerometer")
    UIAllianceMysteries.Widget:addChild( layer )

end


function UIAllianceMysteries.setup()
    stepAll = 0
    turnCout = 0
    turnNum = 0
    choosePai = { 0 , 0 , 0 , 0 }
    chuQianNum = nil
    touZiArmature1:setVisible( false )
    touZiArmature2:setVisible( false )
    image_shaizi1:setOpacity( 255 )
    image_shaizi2:setOpacity( 255 )
    netSendData( 3 )
   local btn_use = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "btn_use" )--使用卡牌
   btn_use:setVisible( false )
    if net.InstUnionDuplication then
        for key , value in pairs( net.InstUnionDuplication ) do
            print( value )
            cclog("111111111111111111111111111111111111111111111")
        end
    end
  --  local layer = UIAllianceMysteries.Widget:getChildByName( "accelerometer" )
  --  layer:setAccelerometerEnabled( true )
end
function UIAllianceMysteries.free()
    count = nil
    step = nil
    stepAll = nil
    turnCout = nil
    turnNum = nil
    choosePai = nil
    isTeam = nil
    chuQianNum = nil
    paiNum = nil
    getPai = nil
    UIAllianceMysteries.members = nil
    isShakeing = nil
    local layer = UIAllianceMysteries.Widget:getChildByName( "accelerometer" )
    layer:setAccelerometerEnabled( false )
    award = nil
    choosePaiIndex = nil
    allianceLevel = nil
    tempPai = nil
end
function UIAllianceMysteries.setChuQian( num )
    local btn_use = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "btn_use" )--使用卡牌
    if num then
        chuQianNum = num
        choosePai[ type.CHUQIAN ] = 1
        UIAllianceMysteries.refreshPai()    
        btn_use:setTitleText( Lang.ui_alliance_mysteries28 )
    else
        choosePaiIndex = nil
        choosePai[ type.CHUQIAN ] = 0
        UIAllianceMysteries.refreshPai()    
        btn_use:setVisible( false )
        btn_use:setTitleText( Lang.ui_alliance_mysteries29 )
        local image_di_down = ccui.Helper:seekNodeByName( UIAllianceMysteries.Widget , "image_di_down" )
        local image_di_info = image_di_down:getChildByName( "image_di_info" )
        image_di_info:getChildByName("text_info"):setString( Lang.ui_alliance_mysteries30 )
    end
end
function UIAllianceMysteries.setPersionN( num , id )
    if num == 1 then
        image_shaizi2:setVisible( false )
        image_shaizi1:setPosition( cc.p( 326 , image_shaizi1:getPositionY() ) )
        touZiArmature1:setPosition( cc.p( image_shaizi1:getPositionX() , image_shaizi1:getPositionY() - 23 ) )
        local image1 = userP:getChildByTag( 1 )
        image1:setScale( 0.7 )
        image1:setPositionX( 0 )
        local image2 = userP:getChildByTag( 2 )
        image2:setVisible( false )
    elseif num == 2 then
        isTeam = true
        image_shaizi2:setVisible( true )
        image_shaizi1:setPosition( cc.p( 376 , image_shaizi1:getPositionY() ) )
        touZiArmature1:setPosition( cc.p( image_shaizi1:getPositionX() , image_shaizi1:getPositionY() - 23 ) )
        local image1 = userP:getChildByTag( 1 )
        image1:setScale( 0.5 )
        image1:setPositionX( -10 )
        local image2 = userP:getChildByTag( 2 )
        image2:setVisible( true )
        local isAwake = 0
        if string.find(id,"_") then
            isAwake = tonumber(utils.stringSplit(id,"_")[2])
            id = tonumber(utils.stringSplit(id,"_")[1])
        end
        if tonumber( id ) > 0 then
            local dictCard = DictCard[tostring(id)]
            local image2 = userP:getChildByTag( 2 )      
            utils.addBorderImage( StaticTableType.DictCard , dictCard.id , image2 )
            if isAwake == 1 then
                image2:getChildByTag(1):loadTexture( "image/" .. DictUI[tostring(dictCard.awakeSmallUiId)].fileName )
            else
                image2:getChildByTag(1):loadTexture( "image/" .. DictUI[tostring(dictCard.smallUiId)].fileName )
            end
        else
            local dictCard = DictCard[tostring(51)]
            local image2 = userP:getChildByTag( 2 )      
            utils.addBorderImage( StaticTableType.DictCard , dictCard.id , image2 )
            image2:getChildByTag(1):loadTexture( "image/" .. DictUI[tostring(dictCard.smallUiId)].fileName )
        end
    end
end
function UIAllianceMysteries.setData( params )
    allianceLevel = params.allianceLevel
end
function UIAllianceMysteries.back()
    UIAllianceActivity.show({ allianceLevel = allianceLevel })
end

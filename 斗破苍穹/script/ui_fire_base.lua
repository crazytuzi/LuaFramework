require"Lang"
UIFireBase = {}
local DEBUG = false
local _curState = nil
local _block = {}
local _data = nil
local _itemCard = nil
local _isAction = nil
local _isHpAction = nil
local _effect = nil
local _nextFloor = nil
local _smallHpPercent = nil
local _bigHpPercent = nil
local _isClicking = nil
local _fightValue = nil
local SCALETO = 3 --小的牌 血和攻击 放大倍数
local _state = {
    ENTER = 1 , --进入界面
    GAME = 2    --进入秘境
}
local _pieceState = {
    unClick = 1 , --不能点击
    click = 2 ,--可以点击
    clicked = 3 ,--已经点击过的了
    stop = 4 , --怪物x掉的1
    stop2 = 5,--能点但是被x掉
}
local _enemyInfo = nil
local _goodsInfo = nil
local _helpStr = {
    Lang.ui_fire_base1 , 
    Lang.ui_fire_base2 , 
    Lang.ui_fire_base3 ,
    Lang.ui_fire_base4 , 
    Lang.ui_fire_base5 ,
    Lang.ui_fire_base6 ,
    Lang.ui_fire_base7 ,
    Lang.ui_fire_base8 ,
    Lang.ui_fire_base9
}
--1棋盘数据
local _chessBoard = {
    { _pieceState.click   , _pieceState.clicked , _pieceState.click   , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
    { _pieceState.unClick , _pieceState.click   , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
    { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
    { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
    { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
    { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } 
}
local function lock( lock )
    local childs = UIManager.uiLayer:getChildren()
    if lock then       
        cclog("lock true")
        for key, obj in pairs(childs) do
            if not tolua.isnull(obj) then
                obj:setEnabled(false)
            end
        end
    else
        cclog("lock false")
        for key, obj in pairs(childs) do
            if not tolua.isnull(obj) then
                obj:setEnabled(true)
            end
        end
    end
end
--返回的是主角和敌兵分别减少的血量
local function getFightResult( i )
    local hurtHero =  _enemyInfo[ i ].attack
    local hurtEnemy = _data.attack
    local htemp = _data.curHp     
    local temp = _enemyInfo[ i ].hp 
    _enemyInfo[ i ].hp = _enemyInfo[ i ].hp - hurtEnemy
    if _enemyInfo[ i ].hp < 0 then
        hurtEnemy = temp
        _enemyInfo[ i ].hp = 0
    end
    if _data.item2 == 1 then
        _data.item2 = 0
        _data.curHp = htemp
        return 0 , hurtEnemy
    elseif _enemyInfo[ i ].hp == 0 then
        _data.curHp = htemp
        return 0 , hurtEnemy
    end
    _data.curHp = _data.curHp - hurtHero  
    if _data.curHp <= 0 then
        hurtHero = htemp
        _data.curHp = 0
        return hurtHero , 0
    end   
    return hurtHero , hurtEnemy
end
--获取动画  --Layer55_Copy56 消炎减血 Layer55 敌兵减血 zhu3主角图像 zhu1主角血量 zhu2主角攻击力 boss3敌兵图像 boss1敌兵攻击力 boss2敌兵血量
local function getResultAnimation()   
    local animation = ccs.Armature:create("ui_anim72")
    return animation
end
local function getGoodsAnimation()   
    local animation = ccs.Armature:create("ui_anim74")
    return animation
end
--是否存在敌兵
local function isLiveEnemy( i )
    if _enemyInfo and _enemyInfo[ i ] then
        return true
    end
    return false
end
--是否存在物品
local function isLiveGoods( i )
    if _goodsInfo and _goodsInfo[ i ] then
        local dictData = utils.getItemProp( _goodsInfo[ i ] )
        if dictData.tableFieldId == StaticThing.key and isLiveEnemy( i ) then
            return false
        end
        return true
    end
    return false
end
--界面信息
local function refreshPlayerInfo( fightValue , lifeValue )
    local image_basemap = ccui.Helper:seekNodeByName( UIFireBase.Widget , "image_basemap" )   
    local image_info = image_basemap:getChildByName( "image_info" ) -- 战力信息
    local image_di_attact = image_info:getChildByName( "image_di_attact" )--战斗力
    local text_number = ccui.Helper:seekNodeByName( image_di_attact , "text_number" )
 --   local fightValue = math.floor( utils.getFightValue() / 10000 / 10 ) + net.InstPlayer.int["4"]
    _data.attack = fightValue
    _data.maxHp = lifeValue
    text_number:setString( fightValue )
    local text_formula = ccui.Helper:seekNodeByName( image_di_attact , "text_formula" )
    text_formula:setString( Lang.ui_fire_base10..math.floor( _fightValue / 10000 ) ..Lang.ui_fire_base11 .. DictSysConfig[ tostring( StaticSysConfig.fireFamAttackBase ) ].value / 10000 .. Lang.ui_fire_base12..net.InstPlayer.int["4"] .. Lang.ui_fire_base13..fightValue  )
    
    local image_di_life = image_info:getChildByName( "image_di_life" )--生命
    local text_number1 = ccui.Helper:seekNodeByName( image_di_life , "text_number" )
  --  local lifeValue = net.InstPlayer.int["4"] * 6
    text_number1:setString( lifeValue )
    local text_formula1 = ccui.Helper:seekNodeByName( image_di_life , "text_formula" )
    text_formula1:setString( Lang.ui_fire_base14.. net.InstPlayer.int["4"] .."*" .. DictSysConfig[ tostring( StaticSysConfig.fireFamHpBase ) ].value .. Lang.ui_fire_base15..lifeValue  )
end
--数字效果
local function numberActionAdd( node , startN , endN , lifeValue )
    if tonumber( startN ) >= tonumber( endN ) then
        --node:setScale( 1 )
        _isHpAction = false
 --       lock( false )
        return
    end
    local s = tonumber( startN )
    local function callF()      
        if s > tonumber( endN ) then
--            lock( false )
            _isHpAction = false
            return
        end
        
        node:getChildByName( "bar_loading" ):setPercent( 30 + s * 70 / lifeValue )
        _effect:setPositionX(  node:getChildByName( "bar_loading" ):getPercent() * node:getChildByName( "bar_loading" ):getContentSize().width / 100 )
        node:getChildByName( "text_life" ):setString( s .. "/" .. lifeValue )--生命力
        s = s + 1
        node:runAction( cc.Sequence:create( cc.DelayTime:create( 0.01 ) , cc.CallFunc:create(
            callF
        ) ) )
    end
    callF()
end
local function numberActionLess( node , startN , endN , lifeValue )
    if tonumber( startN ) <= tonumber( endN ) then
        --node:setScale( 1 )
        _isHpAction = false
--        lock( false )
        return
    end
    local s = tonumber( startN )
    local function callF()      
        if s < tonumber( endN ) then
--            lock( false )
            _isHpAction = false
            return
        end
        node:getChildByName( "bar_loading" ):setPercent( 30 + s * 70 / lifeValue )
        _effect:setPositionX(  node:getChildByName( "bar_loading" ):getPercent() * node:getChildByName( "bar_loading" ):getContentSize().width / 100 )
        node:getChildByName( "text_life" ):setString( s .. "/" .. lifeValue )--生命力
        s = s - 1
        node:runAction( cc.Sequence:create( cc.DelayTime:create( 0.01 ) , cc.CallFunc:create(
            callF
        ) ) )
    end
    callF()
end
--刷新敌兵信息
local function refreshEnemyInfo( i )
    local card = UIFireBase.Widget:getChildByName( "card"..i )
    if card then--此处更改怪物血量和攻击力等详细信息
        card:getChildByName("image_attact"):getChildByName("label_attaqct"):setString( _enemyInfo[ i ].attack )
        card:getChildByName("image_blood"):getChildByName("label_blood"):setString( _enemyInfo[ i ].hp )
    end
end
--加入敌兵
local function addEnemy( i , exit )
    local card = nil
    if not exit then
        card = _itemCard:clone()
        card:getChildByName("image_attact"):getChildByName("label_attaqct"):setScale( SCALETO )
        card:getChildByName("image_blood"):getChildByName("label_blood"):setScale( SCALETO )
        card:setScale( 0.3 )
        card:getChildByName("image_monster"):loadTexture( "image/"..DictUI[ tostring( DictCard[ tostring( _enemyInfo[ i ].id ) ].bigUiId ) ].fileName )
      --  cclog( "qualityId :" .. _enemyInfo[ i ].qualityId )
        if _enemyInfo[ i ].qualityId == 1 then
            card:loadTexture( "ui/fire_pouple.png" )
        elseif _enemyInfo[ i ].qualityId == 2 then
            card:loadTexture( "ui/fire_orange.png" )
        elseif _enemyInfo[ i ].qualityId == 3 then
            card:loadTexture( "ui/fire_red.png" )
        end
        --card:loadTexture( "ui/fire_pouple.png" )
        card:setPosition( _block[ i ]:getPositionX() , _block[ i ]:getPositionY() )
        card:setName( "card"..i )
        UIFireBase.Widget:addChild( card , 100 )
    else
        card = UIFireBase.Widget:getChildByName( "card"..i )
    end
    if card then--此处更改怪物血量和攻击力等详细信息
        card:getChildByName("image_attact"):getChildByName("label_attaqct"):setString( _enemyInfo[ i ].attack )
        card:getChildByName("image_blood"):getChildByName("label_blood"):setString( _enemyInfo[ i ].hp )
    end
end
--加入物品
local function addGoods( i , exit )
    local goodsCard = nil
    local dictData = utils.getItemProp( _goodsInfo[ i ] )
    if not exit then
      --  cclog("  "..DictUI[ tostring( DictThing[ "1" ].smallUiId ) ].fileName)       
        if dictData.tableFieldId == StaticThing.door then
            goodsCard = ccui.ImageView:create( dictData.smallIcon )                               
            if _data.item1 and _data.item1 == 1 then 
                goodsCard = ccui.ImageView:create( dictData.bigIcon )
            else
                goodsCard = ccui.ImageView:create( dictData.smallIcon )
            end        
        elseif dictData.tableFieldId == StaticThing.fireBox then
            goodsCard = ccui.ImageView:create( dictData.smallIcon )
            local effect = cc.ParticleSystemQuad:create("particle/fireBase/ui_anim72_tx3.plist")
            effect:setPositionType(cc.POSITION_TYPE_RELATIVE)
            effect:setPosition( cc.p( goodsCard:getContentSize().width / 2 , 48 ) )
            effect:setName("effect")  
            goodsCard:addChild( effect , 100 )   
        elseif dictData.tableFieldId == StaticThing.key then
            goodsCard = ccui.ImageView:create()
            local effect = getGoodsAnimation()
            effect:getAnimation():playWithIndex( 1 )
          --  effect:setPosition( cc.p( goodsCard:getContentSize().width / 2 , 48 ) )
            effect:setName("effect")  
            goodsCard:addChild( effect , 100 ) 
        elseif dictData.tableFieldId == StaticThing.thing168 then
            goodsCard = ccui.ImageView:create()
            local effect = getGoodsAnimation()
            effect:getAnimation():playWithIndex( 0 )
           -- effect:setPosition( cc.p( goodsCard:getContentSize().width / 2 , 48 ) )
            effect:setName("effect")  
            goodsCard:addChild( effect , 100 )
        else
            goodsCard = ccui.ImageView:create( dictData.smallIcon )
        end
        if dictData.tableFieldId == StaticThing.smallpot or dictData.tableFieldId == StaticThing.bigpot then
            local time = 0.05
            goodsCard:runAction( cc.RepeatForever:create( cc.Sequence:create( cc.RotateTo:create( time , 6 ) , cc.RotateTo:create( time * 2 , -6 ) , cc.RotateTo:create( time * 2 , 6 ) , cc.RotateTo:create( time * 2 , -6 ) , cc.RotateTo:create( time , 0 ) , cc.DelayTime:create( 0.8 ) ) ) )
        end
        goodsCard:setPosition( _block[ i ]:getPositionX() , _block[ i ]:getPositionY() )
        goodsCard:setName( "goods"..i )
        UIFireBase.Widget:addChild( goodsCard , 100 )
    else
        goodsCard = UIFireBase.Widget:getChildByName( "goods"..i )
        if dictData.tableFieldId == StaticThing.door then                                    
            if _data.item1 and _data.item1 == 1 then
                goodsCard:loadTexture( dictData.bigIcon )
            else
                goodsCard:loadTexture( dictData.smallIcon )
            end
        else
            
        end
    end
end
--刷新击杀怪物数
local function refreshKillEnemyCount()
    local image_basemap = ccui.Helper:seekNodeByName( UIFireBase.Widget , "image_basemap" )
    local image_base_name = image_basemap:getChildByName( "image_base_name" )--战队信息
    image_base_name:getChildByName( "image_monster" ):getChildByName( "text_number" ):setString( _data.killEnemy )--击杀怪物数
end
--战队信息
local function refreshGameInfo( fightValue , lifeValue )
    local image_basemap = ccui.Helper:seekNodeByName( UIFireBase.Widget , "image_basemap" )
    local image_base_name = image_basemap:getChildByName( "image_base_name" )--战队信息
    image_base_name:getChildByName( "image_fight" ):getChildByName( "label_fight" ):setString( _fightValue )  
   -- local fightValue = math.floor( utils.getFightValue() / 10000 / 10 ) + net.InstPlayer.int["4"]
    image_base_name:getChildByName( "image_attack" ):getChildByName( "text_attack" ) :setString( fightValue )--战斗力
  --  local lifeValue = net.InstPlayer.int["4"] * 6
    local barLoading = image_base_name:getChildByName( "image_loading" ):getChildByName( "bar_loading" )
    if _isHpAction then
      --  lock( true )
        _effect:setVisible( true )
        local startHp = math.floor( ( barLoading:getPercent() - 30 ) * lifeValue / 70 )
        if startHp < _data.curHp then
            numberActionAdd( image_base_name:getChildByName( "image_loading" ) , startHp , _data.curHp , lifeValue )
        else
            numberActionLess( image_base_name:getChildByName( "image_loading" ) , startHp , _data.curHp , lifeValue )
        end       
    else
        _effect:setVisible( true )
        barLoading:setPercent( 30 + _data.curHp * 70 / lifeValue )
        _effect:setPositionX(  barLoading:getPercent() * barLoading:getContentSize().width / 100 )
        image_base_name:getChildByName( "image_loading" ):getChildByName( "text_life" ):setString( _data.curHp .. "/" .. lifeValue )--生命力
    end  
    image_base_name:getChildByName( "image_floor" ):getChildByName( "text_number" ):setString( _data.floor )--层数
    image_base_name:getChildByName( "image_monster" ):getChildByName( "text_number" ):setString( _data.killEnemy )--击杀怪物数
    image_base_name:loadTexture( "ui/quality_middle_bar_clear.png" )
    image_base_name:getChildByName( "text_name" ):setString( "" ) --名字net.InstPlayer.string["3"]
    image_base_name:getChildByName( "text_lv" ):setString( "" ) --等级"LV " .. net.InstPlayer.int["4"]
end

--详细信息
local function refreshInfo( action )
    local image_basemap = ccui.Helper:seekNodeByName( UIFireBase.Widget , "image_basemap" )   
    local image_di = image_basemap:getChildByName( "image_di" )
    local image_rule = image_basemap:getChildByName( "image_rule" ) --规则
    local image_info = image_basemap:getChildByName( "image_info" ) -- 卡牌信息
    local image_base_name = image_basemap:getChildByName( "image_base_name" )--战队信息
    local image_frame_good1 = image_base_name:getChildByName( "image_frame_good1" )
    if _data.item1 and _data.item1 == 1 then
        image_frame_good1:getChildByName("image_good"):setVisible( true )
    else
        image_frame_good1:getChildByName("image_good"):setVisible( false )
    end
    local image_frame_good2 = image_base_name:getChildByName( "image_frame_good2" )
    if _data.item2 and _data.item2 == 1 then
        image_frame_good2:getChildByName("image_good"):setVisible( true )
    else
        image_frame_good2:getChildByName("image_good"):setVisible( false )
    end

    local panel_block = image_basemap:getChildByName( "panel_block" ) --棋盘
    local image_frame_card = image_basemap:getChildByName( "image_frame_card" )
    local fightValue = math.floor( _fightValue / DictSysConfig[ tostring( StaticSysConfig.fireFamAttackBase ) ].value ) + net.InstPlayer.int["4"]
    if _data.item2 == 1 then
        fightValue = 999
    end
    local lifeValue = net.InstPlayer.int["4"] * DictSysConfig[ tostring( StaticSysConfig.fireFamHpBase ) ].value
    ccui.Helper:seekNodeByName( image_frame_card , "label_attaqct" ):setString( fightValue )
    ccui.Helper:seekNodeByName( image_frame_card , "label_blood" ):setString( _data.curHp )

    local actionTable = {
        15 , 16 , 22 , 21 ,  20 , 14 , 8 , 9 , 10 , 11 , 17 , 23 , 29 , 28 , 27 , 26 , 25 , 19 , 13 , 7 , 1 , 2 , 3 , 4 , 5 , 6 , 12 , 18 , 24 , 30 , 36 , 35 , 34 , 33 , 32 , 31
    }
    local function result()
        if _curState == _state.ENTER then
            image_di:setVisible( true )

            image_rule:setScale( 1.0 )
            image_base_name:setPositionX( 525 )     
            image_info:setPositionX( 452 )
            image_di:setPositionY( -9 )

            image_rule:setVisible( true )
            image_info:setVisible( true )
            panel_block:setVisible( false )
            image_base_name:setVisible( false )            
        elseif _curState == _state.GAME then
            image_di:setVisible( false )
            image_rule:setVisible( false )
            image_info:setVisible( false )
            panel_block:setVisible( true )
            image_base_name:setVisible( true )
            
        end
        refreshPlayerInfo( fightValue , lifeValue )
        refreshGameInfo( fightValue , lifeValue )
    end
    if action then
        local actionTime = 0.3
        if _curState == _state.ENTER then           
            image_base_name:setPositionX( 175 )     
            image_base_name:setVisible( true )  
            image_info:setPositionX( 802 )
            image_info:setVisible( true )
            image_base_name:runAction( cc.Sequence:create( cc.MoveTo:create( actionTime , cc.p( 525 , image_base_name:getPositionY() ) ) , cc.CallFunc:create( function ()
                image_info:runAction( cc.Sequence:create( cc.MoveTo:create( actionTime , cc.p( 452 , image_info:getPositionY() ) ) ) )
            end) ) )
            image_rule:setScale( 0.01 )
            image_rule:setVisible( true )
            panel_block:setVisible( true )
            image_di:setPositionY( -162 )
            image_di:setVisible( true )
            for i = 1 , 36 do
                _block[ i ]:setVisible( true )    
                local card = panel_block:getChildByName( "card"..i )
                if card then
                    card:setVisible( true )
                end 
                local goodsCard = UIFireBase.Widget:getChildByName( "goods"..i )
                if goodsCard then
                    goodsCard:setVisible( true )
                end            
                if i == 36 then
                    _block[ actionTable[ 37 - i ] ]:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Hide:create() , cc.CallFunc:create( function ()
                        image_rule:runAction( cc.Sequence:create( cc.ScaleTo:create( actionTime , 1 , 1 ) , cc.CallFunc:create( function ()
                    result()
                end) ) )
                        image_di:runAction( cc.MoveTo:create( actionTime , cc.p( image_di:getPositionX() , -9 ) ) ) 
                    end) ) )
                else
                    _block[ actionTable[ 37 - i ] ]:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Hide:create() ) )           
                end
                local card = UIFireBase.Widget:getChildByName( "card"..actionTable[ 37 - i ] )
                if card then
                    card:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Hide:create() ) )
                end
                local goodsCard = UIFireBase.Widget:getChildByName( "goods"..actionTable[ 37 - i ] )
                if goodsCard then
                    goodsCard:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Hide:create() ) )
                end
            end       
        elseif _curState == _state.GAME then   
            image_base_name:setPositionX( 525 )     
            image_base_name:setVisible( true )  
            image_info:setPositionX( 452 )
            image_info:setVisible( true )
            image_info:runAction( cc.Sequence:create( cc.MoveTo:create( actionTime , cc.p( 802 , image_info:getPositionY() ) ) , cc.CallFunc:create( function ()
                image_base_name:runAction( cc.Sequence:create( cc.MoveTo:create( actionTime , cc.p( 175 , image_base_name:getPositionY() ) ) , cc.DelayTime:create( 0.24 ) , cc.CallFunc:create( function ()
                    result()
                end) ) )
            end) ) )
            image_rule:setScale( 1.0 )
            image_rule:setVisible( true )
            panel_block:setVisible( true )
            for i = 1 , 36 do
                _block[ i ]:setVisible( false )   
                local card = UIFireBase.Widget:getChildByName( "card"..i )
                if card then
                    card:setVisible( false )
                end  
                local goodsCard = UIFireBase.Widget:getChildByName( "goods"..i )
                if goodsCard then
                    goodsCard:setVisible( false )
                end           
            end
            image_rule:runAction( cc.Sequence:create( cc.ScaleTo:create( actionTime , 0.01 ) , cc.Hide:create() , cc.CallFunc:create( function ()
                for i = 1 , 36 do
                    _block[ actionTable [ i ] ]:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Show:create() ) )
                    local card = UIFireBase.Widget:getChildByName( "card"..actionTable[ i ] )
                    if card then
                        card:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Show:create() ) )
                    end
                    local goodsCard = UIFireBase.Widget:getChildByName( "goods"..actionTable[ i ] )
                    if goodsCard then
                        goodsCard:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Show:create() ) )
                    end
                end
            end) ) )    
            image_di:setPositionY( -9 )
            image_di:setVisible( true )
            image_di:runAction( cc.MoveTo:create( 0.5 , cc.p( image_di:getPositionX() , -162 ) ) )    
        end
    else
        result()
    end

end
local function refreshChessBoard()
    for i = 1 , 36 do
        local pieceValue = _chessBoard[ math.floor( ( i - 1 ) / 6 ) + 1 ][ ( ( i - 1 ) % 6 ) + 1 ]
   --     cclog( "pieceValue:" ..pieceValue )
        if _block[ i ]:getChildByName("error") then
            _block[ i ]:getChildByName("error"):removeFromParent()
        end
        if pieceValue  == _pieceState.unClick then
            _block[ i ]:loadTexture( "ui/fire_lattice2.png" )
        elseif pieceValue == _pieceState.clicked then
            _block[ i ]:loadTexture( "ui/fire_lattice1.png" )        
            if isLiveEnemy( i ) then
         --       cclog( "enemy :" .. i )
                if UIFireBase.Widget:getChildByName( "card"..i ) then
                    addEnemy( i , true )
                else
                    addEnemy( i )
                end
            else
                if UIFireBase.Widget:getChildByName( "card"..i ) then
                    UIFireBase.Widget:getChildByName( "card"..i ):removeFromParent()
                end
            end
            if isLiveGoods( i ) then
           --     cclog( "goods :" .. i )
                if UIFireBase.Widget:getChildByName( "goods"..i ) then
                    addGoods( i , true )
                else
                    addGoods( i )
                end
            else
                if UIFireBase.Widget:getChildByName( "goods"..i ) then
                    UIFireBase.Widget:getChildByName( "goods"..i ):removeFromParent()
                end
            end
        elseif pieceValue == _pieceState.click then
            _block[ i ]:loadTexture( "ui/fire_lattice3.png" )
        elseif pieceValue == _pieceState.stop then
            local err = ccui.ImageView:create("ui/wrong.png")
            err:setName("error")
            err:setPosition( cc.p( _block[ i ]:getContentSize().width / 2 , _block[ i ]:getContentSize().height / 2 ) )
            _block[ i ]:addChild( err , 1 )
        elseif pieceValue == _pieceState.stop2 then
            _block[ i ]:loadTexture( "ui/fire_lattice3.png" )
            local err = ccui.ImageView:create("ui/wrong.png")
            err:setName("error")
            err:setPosition( cc.p( _block[ i ]:getContentSize().width / 2 , _block[ i ]:getContentSize().height / 2 ) )
            _block[ i ]:addChild( err , 1 )
        end
    end
end
--清棋盘上的物品
local function resetChessBoard()
    for i = 1 , 36 do
        if _block[ i ]:getChildByName("error") then
            _block[ i ]:getChildByName("error"):removeFromParent()
        end
        if UIFireBase.Widget:getChildByName("card"..i) then
            UIFireBase.Widget:getChildByName("card"..i):removeFromParent()
        end
        if UIFireBase.Widget:getChildByName("goods"..i) then
            UIFireBase.Widget:getChildByName("goods"..i):removeFromParent()
        end
    end
end
--计算棋盘的点击数据
local function resetChess()
    for key ,value in pairs ( _goodsInfo ) do
        if value == "2_162_1" then
          --  cclog( "door key :" .. key )
            local _x = math.floor( ( key - 1 ) / 6 ) + 1
            local _y = ( ( key - 1 ) % 6 ) + 1 
            _chessBoard[ _x ][ _y ] = _pieceState.clicked
            local pos = {
                { _x - 1 , _y } ,
                { _x + 1 , _y } ,
                { _x , _y - 1 } ,
                { _x , _y + 1 } ,
            }
            for i = 1 , 4 do
                local x = pos[ i ][ 1 ]
                local y = pos[ i ][ 2 ]
                if x > 0 and x < 7 and y > 0 and y < 7 and _chessBoard[ x ][ y ] == _pieceState.unClick  then
                    _chessBoard[ x ][ y ] = _pieceState.click
                end
            end
            break
        end
    end
    for i = 1 , 36 do
        local _x = math.floor( ( i - 1 ) / 6 ) + 1
        local _y = ( ( i - 1 ) % 6 ) + 1 
        local pieceValue = _chessBoard[ _x ][ _y ]
        if pieceValue == _pieceState.clicked then
            local pos = {
                { _x - 1 , _y } ,
                { _x + 1 , _y } ,
                { _x , _y - 1 } ,
                { _x , _y + 1 } ,
            }
            for i = 1 , 4 do
                local x = pos[ i ][ 1 ]
                local y = pos[ i ][ 2 ]
                if x > 0 and x < 7 and y > 0 and y < 7 and _chessBoard[ x ][ y ] == _pieceState.unClick  then
                    _chessBoard[ x ][ y ] = _pieceState.click
                end
            end
        end
    end
    refreshChessBoard()
    for key ,value in pairs( _enemyInfo ) do
   --     cclog( "key : " .. key )
        local _x = math.floor( ( key - 1 ) / 6 ) + 1
        local _y = ( ( key - 1 ) % 6 ) + 1 
        if _chessBoard[ _x ][ _y ] == _pieceState.clicked then
            local pos = {
                { _x - 1 , _y } ,
                { _x + 1 , _y } ,
                { _x , _y - 1 } ,
                { _x , _y + 1 } ,
                { _x - 1 , _y - 1 } ,
                { _x + 1 , _y + 1 } ,
                { _x - 1 , _y + 1 } ,
                { _x + 1 , _y - 1 }
            }
            if isLiveEnemy( key ) then
               for i = 1 , 8 do
                    local x = pos[ i ][ 1 ]
                    local y = pos[ i ][ 2 ]
                    if x > 0 and x < 7 and y > 0 and y < 7 and _chessBoard[ x ][ y ] ~= _pieceState.clicked then
                        _chessBoard[ x ][ y ] = _pieceState.stop
                    end
                end
            end
        end
    end
end
--进入下一层
local function enterNextFloor()   
    lock( true )
    local actionTable = {
        15 , 16 , 22 , 21 ,  20 , 14 , 8 , 9 , 10 , 11 , 17 , 23 , 29 , 28 , 27 , 26 , 25 , 19 , 13 , 7 , 1 , 2 , 3 , 4 , 5 , 6 , 12 , 18 , 24 , 30 , 36 , 35 , 34 , 33 , 32 , 31
    }
    local function appear()
        for i = 1 , 36 do
            local card = UIFireBase.Widget:getChildByName( "card"..i )
            if card then
                card:setVisible( false )
            end  
            local goodsCard = UIFireBase.Widget:getChildByName( "goods"..i )
            if goodsCard then
                goodsCard:setVisible( false )
            end           
            local card = UIFireBase.Widget:getChildByName( "card"..actionTable[ i ] )
            if card then
                card:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Show:create() ) )
            end
            local goodsCard = UIFireBase.Widget:getChildByName( "goods"..actionTable[ i ] )
            if goodsCard then
                goodsCard:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Show:create() ) )
            end
            _block[ actionTable [ i ] ]:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Show:create() ) )
            if i == 36 then
                lock( false )
            end
        end
    end
    local image_basemap = ccui.Helper:seekNodeByName( UIFireBase.Widget , "image_basemap" )
    local panel_block = image_basemap:getChildByName( "panel_block" ) --棋盘
    for i = 1 , 36 do
        _block[ i ]:setVisible( true )    
        local card = panel_block:getChildByName( "card"..i )
        if card then
            card:setVisible( true )
        end 
        local goodsCard = UIFireBase.Widget:getChildByName( "goods"..i )
        if goodsCard then
            goodsCard:setVisible( true )
        end            
        if i == 36 then
            _block[ actionTable[ 37 - i ] ]:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Hide:create() , cc.CallFunc:create( function ()
                refreshInfo()
                resetChess()
                resetChessBoard()     
                refreshChessBoard() 
                appear()
            end) ) )
        else
            _block[ actionTable[ 37 - i ] ]:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Hide:create() ) )           
        end
        local card = UIFireBase.Widget:getChildByName( "card"..actionTable[ 37 - i ] )
        if card then
            card:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Hide:create() ) )
        end
        local goodsCard = UIFireBase.Widget:getChildByName( "goods"..actionTable[ 37 - i ] )
        if goodsCard then
            goodsCard:runAction( cc.Sequence:create( cc.DelayTime:create( i * 0.02 ) , cc.Hide:create() ) )
        end
    end 
end

local function addEnemyAnimationInfo( animation , i )
    --Layer55_Copy56 消炎减血 Layer55 敌兵减血 zhu3主角图像 zhu1主角血量 zhu2主角攻击力 boss3敌兵图像 boss1敌兵攻击力 boss2敌兵血量      
    local skin = ccs.Skin:create( "image/"..DictUI[ tostring( DictCard[ "88" ].bigUiId ) ].fileName )
    animation:getBone("zhu_3"):setScale( 0.85 )
    animation:getBone("zhu_3"):addDisplay( skin , 0 )
    --fire_orange.png
  --  animation:getBone("boss"):addDisplay( ccs.Skin:create( "ui/fire_orange.png" ) , 0 )
    if _enemyInfo[ i ].qualityId == 1 then
        animation:getBone("boss"):addDisplay( ccs.Skin:create( "ui/fire_pouple.png" ) , 0 )
    elseif _enemyInfo[ i ].qualityId == 2 then
        animation:getBone("boss"):addDisplay( ccs.Skin:create( "ui/fire_orange.png" ) , 0 )
    elseif _enemyInfo[ i ].qualityId == 3 then
        animation:getBone("boss"):addDisplay( ccs.Skin:create( "ui/fire_red.png" ) , 0 )
    end

    local enemyCard = animation:getBone("boss_3")
    enemyCard:setScale( 0.85 )
    enemyCard:setPosition( cc.p( enemyCard:getPositionX() - 21 , enemyCard:getPositionY() - 10 ) )
    enemyCard:addDisplay( ccs.Skin:create( "image/"..DictUI[ tostring( DictCard[ tostring( _enemyInfo[ i ].id ) ].bigUiId ) ].fileName ) , 0 )
    --animation:getBone("boss3"):get --addDisplay(ccs.Skin:create( "image/"..DictUI[ tostring( DictCard[ "88" ].bigUiId ) ].fileName ), 0)
    
    local hurtHero , hurtEnemy = getFightResult( i )

    local hpSkin = ccui.ImageView:create("ui/fire_life.png")
    --tk_di01_shuzi.fnt
    local hp = ccui.TextBMFont:create()
    hp:setFntFile("ui/tk_di01_shuzi.fnt") 
    hp:setString( _data.curHp + hurtHero )
    hp:setPosition( cc.p( 41.5 , 36 ) )
    hpSkin:addChild( hp )
    animation:getBone("zhu_1"):addDisplay( hpSkin , 0 )

    local attackSkin = ccui.ImageView:create()
    local attack = ccui.TextBMFont:create()
    attack:setFntFile("ui/tk_di01_shuzi.fnt") 
    attack:setString(_data.attack)
    attack:setPosition( cc.p( -2 , -8 ) )
    attackSkin:addChild( attack )
    attackSkin:setAnchorPoint( cc.p( 0.5 , 0.5 ) )
    animation:getBone("shuzi"):addDisplay( attackSkin , 0 )

    local enemyHpSkin = ccui.ImageView:create("ui/fire_life.png")
    --tk_di01_shuzi.fnt
    local enemyHp = ccui.TextBMFont:create()
    enemyHp:setFntFile("ui/tk_di01_shuzi.fnt") 
    enemyHp:setString( _enemyInfo[i].hp + hurtEnemy )
    enemyHp:setPosition( cc.p( 42 , 35 ) )
    enemyHpSkin:addChild( enemyHp )
    animation:getBone("BOSS-2"):addDisplay( enemyHpSkin , 0 )

    local enemyAttackSkin = ccui.ImageView:create()
    local enmeyAttack = ccui.TextBMFont:create()
    enmeyAttack:setFntFile("ui/tk_di01_shuzi.fnt") 
    enmeyAttack:setString( _enemyInfo[i].attack )
    enmeyAttack:setPosition( cc.p(  -4 , -9 ) )
    enemyAttackSkin:addChild( enmeyAttack )
    animation:getBone("shuzi2"):addDisplay( enemyAttackSkin , 0 )

    local hurtSkin = ccui.ImageView:create("ui/fire_hurt.png")
    local hurt = ccui.TextAtlas:create( hurtHero , "ui/fire_font.png" , 34 , 49 , "0" ) 
    local fontW1 = hurt:getStringLength()
    hurt:setPosition( cc.p( hurtSkin:getContentSize().width / 2 + 15 , hurtSkin:getContentSize().height / 2 ) )
    hurtSkin:addChild( hurt )  
    local lessImage1 = ccui.ImageView:create( "ui/fire_font1.png" ) 
    lessImage1:setPosition( cc.p( hurtSkin:getContentSize().width / 2 - fontW1 * 34 / 2 , hurtSkin:getContentSize().height / 2 ) )
    hurtSkin:addChild( lessImage1 ) 
    hurtSkin:setPosition( cc.p( 25 , 15 ))
    hurtSkin:rotate( -20 )
    if hurtHero == 0 then
        animation:getBone("Layer55_Copy56"):addDisplay( ccui.ImageView:create() , 0 )
    else       
       animation:getBone("Layer55_Copy56"):addDisplay( hurtSkin , 0 )
    end

    local enemyHurtSkin = ccui.ImageView:create("ui/fire_hurt.png")
    local enemyHurt = ccui.TextAtlas:create( hurtEnemy , "ui/fire_font.png" , 34 , 49 , "0" ) 
    local fontW = enemyHurt:getStringLength()
    enemyHurt:setPosition( cc.p( enemyHurtSkin:getContentSize().width / 2 + 15 , enemyHurtSkin:getContentSize().height / 2 ) )
    enemyHurtSkin:addChild( enemyHurt )  
    local lessImage = ccui.ImageView:create( "ui/fire_font1.png" ) 
    lessImage:setPosition( cc.p( enemyHurtSkin:getContentSize().width / 2 - fontW * 34 / 2 , enemyHurtSkin:getContentSize().height / 2 ) )
    enemyHurtSkin:addChild( lessImage ) 
    enemyHurtSkin:setPosition( cc.p( - enemyHurtSkin:getContentSize().width / 2 - 20 , - enemyHurtSkin:getContentSize().height / 2 + 30 ))
    enemyHurtSkin:rotate( -20 )
    if hurtEnemy == 0 then
        animation:getBone("Layer55"):addDisplay( ccui.ImageView:create() , 0 )
    else
        animation:getBone("Layer55"):addDisplay( enemyHurtSkin , 0 )
    end
end

local function refreshEnemyAnimationInfo( animation , i )  
    local hpSkin = ccui.ImageView:create("ui/fire_life.png")
    --tk_di01_shuzi.fnt
    local hp = ccui.TextBMFont:create()
    hp:setFntFile("ui/tk_di01_shuzi.fnt") 
    hp:setString( _data.curHp )
    hp:setPosition( cc.p( 41.5 , 36 ) )
    hpSkin:addChild( hp )
    animation:getBone("zhu_1"):addDisplay( hpSkin , 0 )

    local attackSkin = ccui.ImageView:create()
    local attack = ccui.TextBMFont:create()
    attack:setFntFile("ui/tk_di01_shuzi.fnt") 
    attack:setString(_data.attack)
    attack:setPosition( cc.p(  -2 , -8 ) )
    attackSkin:addChild( attack )
    animation:getBone("shuzi"):addDisplay( attackSkin , 0 )

    local enemyHpSkin = ccui.ImageView:create("ui/fire_life.png")
    --tk_di01_shuzi.fnt
    local enemyHp = ccui.TextBMFont:create()
    enemyHp:setFntFile("ui/tk_di01_shuzi.fnt") 
    enemyHp:setString( _enemyInfo[i].hp )
    enemyHp:setPosition( cc.p( 42 , 35 ) )
    enemyHpSkin:addChild( enemyHp )
    animation:getBone("BOSS-2"):addDisplay( enemyHpSkin , 0 )

    local enemyAttackSkin = ccui.ImageView:create()
    local enmeyAttack = ccui.TextBMFont:create()
    enmeyAttack:setFntFile("ui/tk_di01_shuzi.fnt") 
    enmeyAttack:setString( _enemyInfo[i].attack )
    enmeyAttack:setPosition( cc.p(  -4 , -9 ) )
    enemyAttackSkin:addChild( enmeyAttack )
    animation:getBone("shuzi2"):addDisplay( enemyAttackSkin , 0 )

end
--点击怪物效果
local function attackEffect( i )
    if _data.curHp <= 0 then
 --       UIManager.showToast( "消炎已经没血了，拿什么来战斗" )
        return
    end
    lock( true )
    local actionTime = 0.2
    local image_basemap = ccui.Helper:seekNodeByName( UIFireBase.Widget , "image_basemap" )
    local image_frame_card = image_basemap:getChildByName( "image_frame_card" )
    local card = UIFireBase.Widget:getChildByName( "card"..i )
    local function effectEnd()
        card:setLocalZOrder( 100 )
        local animation = getResultAnimation()
        animation:getAnimation():stop()
        animation:getAnimation():playWithIndex( 0 )
        AudioEngine.playEffect("sound/fire_attack.mp3")
        addEnemyAnimationInfo( animation , i )
        animation:setPosition( cc.p( UIManager.screenSize.width / 2 , UIManager.screenSize.height / 2 - 10 ) )
        UIFireBase.Widget:addChild( animation , 105 )       
        local function onMovementEvent(armature, movementType, movementID)
            if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then               
                _isHpAction = true
                refreshInfo()
                refreshEnemyInfo( i )
                if _data.curHp <= 0 then
             --       UIManager.showToast( "消炎没血了" )
                elseif _enemyInfo[ i ] and _enemyInfo[ i ].hp == 0 then
              --      UIManager.showToast( "敌兵死亡了" )
                    armature:getAnimation():stop()
                    image_frame_card:setVisible( true )
                    armature:getAnimation():playWithIndex( 1 )
                    AudioEngine.playEffect("sound/fire_dead.mp3")
                    refreshEnemyAnimationInfo( armature , i )
                    local function onMovementEvent1(armature, movementType, movementID)
                        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then 
                            _enemyInfo[ i ] = nil
                            armature:getAnimation():stop()
                            armature:removeFromParent() 
                            card:removeFromParent()
                            _data.killEnemy = _data.killEnemy + 1
                            refreshKillEnemyCount()
                            UIFireBase.clickChessBoard( i , true )
                            refreshChessBoard()
                            lock( false )
                            _isClicking = false
                        end
                    end
                    animation:getAnimation():setMovementEventCallFunc(onMovementEvent1) 
                    return
                end
                armature:getAnimation():stop()
                armature:removeFromParent() 
                card:setVisible( true )
                image_frame_card:setVisible( true )
                local action1 = cc.Spawn:create( cc.MoveTo:create( actionTime , cc.p( _block[ i ]:getPosition() ) ) , cc.ScaleTo:create( actionTime , 0.3 ) )
                card:runAction( cc.Sequence:create( cc.DelayTime:create( 0.2 ) , action1 , cc.CallFunc:create( function ()
                    card:setLocalZOrder( 100 )
                    lock( false )
                    _isClicking = false
                end) ) )               
                card:getChildByName("image_attact"):getChildByName("label_attaqct"):runAction( cc.Sequence:create( cc.DelayTime:create( 0.2 ) , cc.ScaleTo:create( actionTime , SCALETO ) ) )
                card:getChildByName("image_blood"):getChildByName("label_blood"):runAction( cc.Sequence:create( cc.DelayTime:create( 0.2 ) , cc.ScaleTo:create( actionTime , SCALETO ) ) )
            end
        end
        card:setVisible( false )
        image_frame_card:setVisible( false )
        animation:getAnimation():setMovementEventCallFunc(onMovementEvent)        
    end
    card:setLocalZOrder( 102 )
    local action = cc.Spawn:create( cc.MoveTo:create( actionTime , cc.p( 320 , 318 ) ) , cc.ScaleTo:create( actionTime , 1.0 ) )   
    card:runAction( cc.Sequence:create( action , cc.CallFunc:create( function ()
        effectEnd()
    end) ) )

    card:getChildByName("image_attact"):getChildByName("label_attaqct"):runAction( cc.Sequence:create( cc.ScaleTo:create( actionTime , 1.0 ) ) )
    card:getChildByName("image_blood"):getChildByName("label_blood"):runAction( cc.Sequence:create( cc.ScaleTo:create( actionTime , 1.0 ) ) )

    local animation2 = getGoodsAnimation()
    animation2:getAnimation():stop()
    animation2:getAnimation():playWithIndex( 4 )
    local function onMovementEvent2(armature, movementType, movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then 
            armature:getAnimation():stop()
            armature:removeFromParent() 
        --    effectEnd()
        end
    end
    animation2:setPosition( cc.p( UIManager.screenSize.width / 2 , UIManager.screenSize.height / 2 - 10 ) )
    UIFireBase.Widget:addChild( animation2 , 106 )
    animation2:getAnimation():setMovementEventCallFunc(onMovementEvent2) 
end
--开门效果
local function openDoor()
    for key ,value in pairs ( _goodsInfo ) do
        local dictData = utils.getItemProp( value )
        if dictData.tableFieldId == StaticThing.door then --门
            local pieceValue = _chessBoard[ math.floor( ( key - 1 ) / 6 ) + 1 ][ ( ( key - 1 ) % 6 ) + 1 ]
            if pieceValue ~= _pieceState.clicked then --门没有出现
                lock( false )
 --               cclog("门还没点开呢")
                break
            end
            local goodsCard = UIFireBase.Widget:getChildByName( "goods"..key )
            goodsCard:setVisible( false )
            AudioEngine.playEffect("sound/fire_opendoor.mp3")
            local animation = getResultAnimation()           
            animation:getAnimation():playWithIndex( 2 )
            local function onMovementEvent(armature, movementType, movementID)
                if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                    armature:getAnimation():stop()
                    armature:removeFromParent() 
                    goodsCard:setVisible( true )
                    goodsCard:loadTexture( dictData.bigIcon )
                    lock( false )
                end
            end
            animation:getAnimation():setMovementEventCallFunc(onMovementEvent) 
            animation:setPosition( goodsCard:getPositionX() , goodsCard:getPositionY() )
            UIFireBase.Widget:addChild( animation , 100 )
            break
        end
    end
end
--type 1 :小血瓶 2：大血瓶
local function addHp( type1 )
    local hp = 0
    if type1 == 1 then
        hp = _data.curHp * _smallHpPercent        
    elseif type1 == 2 then
        hp = _data.curHp * _bigHpPercent
    end
    if hp > 0 and hp < 1 then
        hp = 1
    else
        hp = math.floor( hp )
    end
    _data.curHp = _data.curHp + hp
    local maxHp = _data.maxHp
    if _data.curHp > maxHp then
        _data.curHp = maxHp
    end
end

local function callBack( pack )
    if DEBUG then
        _data = {}
        _data.curHp = 100
        _data.floor = 2
        _data.killEnemy = 3
        _data.item1 = 0
        _data.item2 = 0
        _chessBoard = {
            { _pieceState.unClick , _pieceState.unClick , _pieceState.clicked , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
            { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
            { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
            { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
            { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
            { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } 
        }
        if pack.header == _state.ENTER then
            _curState = _state.ENTER
            refreshInfo( _isAction )
        elseif pack.header == _state.GAME then
            _enemyInfo = {}
            _goodsInfo = {}
            _enemyInfo[ 3 ] = { id = 1 , hp = 100 , attack = 10 }
            _enemyInfo[ 14 ] = { id = 2 , hp = 100 , attack = 100 }
            _goodsInfo[ 3 ] = "2_161_1"
            _goodsInfo[ 8 ] = "2_162_1"
            _goodsInfo[ 9 ] = "2_163_1"
            _goodsInfo[ 10 ] = "2_164_1"
            _goodsInfo[ 11 ] = "2_165_1"
            _goodsInfo[ 12 ] = "2_168_1"   
            _smallHpPercent = 0.05
            _bigHpPercent = 0.1        
            _curState = _state.GAME                
            if _nextFloor then
                _nextFloor = false
                enterNextFloor()
            else            
                resetChess()
                resetChessBoard()     
                refreshChessBoard()    
                refreshInfo( true )
            end
            
        end        
    end
    _chessBoard = {
            { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
            { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
            { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
            { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
            { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } ,
            { _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick , _pieceState.unClick } 
        }
    if pack.header == StaticMsgRule.clickFireFam then        
        _data.curHp = pack.msgdata.int[ "1" ]
        if net.InstPlayer.int[ "4" ] < 40 or _data.curHp == -1 then
            _data.curHp = net.InstPlayer.int["4"] * DictSysConfig[ tostring( StaticSysConfig.fireFamHpBase ) ].value
        end
        _curState = _state.ENTER
        if not _isAction then
            _enemyInfo = {}
            _goodsInfo = {}
            resetChessBoard()
        end
        refreshInfo( _isAction )
    elseif pack.header == StaticMsgRule.intoFireFam then
        net.isShowFireTip = false
        UIHomePage.fireShow()
        _enemyInfo = {}
        _goodsInfo = {}
        local enemyThings = utils.stringSplit( pack.msgdata.string[ "2" ] , ";" )
        for key ,value in pairs( enemyThings ) do
            local obj = utils.stringSplit( value , "_" )
            local _x = math.floor( tonumber( obj[ 1 ] ) / 10  ) - 1
            local _y = tonumber( obj[ 1 ] ) % 10
 --           cclog( "obj :" .. obj[ 1 ] .. "  ".._x .. "  " .. _y )
            _enemyInfo[ _x * 6 + _y ] = { id = obj[ 2 ] , hp = tonumber( obj[ 3 ] ) , attack = tonumber( obj[ 4 ] ) , qualityId = tonumber( obj[ 5 ] ) }
        end
        local goodsThings = utils.stringSplit( pack.msgdata.string[ "1" ] , ";" )
        for key ,value in pairs ( goodsThings ) do
            local obj = utils.stringSplit( value , "_" )
            local _x = math.floor( tonumber( obj[ 1 ] ) / 10  ) - 1
            local _y = tonumber( obj[ 1 ] ) % 10
            _goodsInfo[ _x * 6 + _y ] = StaticTableType.DictThing .. "_" .. obj[ 2 ].."_1"
        end
        local clicked = utils.stringSplit( pack.msgdata.string[ "3" ] , ";" )
        for key ,value in pairs ( clicked ) do
            local index = tonumber( value )
            local _x = math.floor( index / 10  )
            local _y = index % 10
  --          cclog( "value :"..value.."  ".._x .. "  ".._y )
            _chessBoard[ _x ][ _y ] = _pieceState.clicked
        end
        _data.floor = pack.msgdata.int[ "8" ]
        _data.killEnemy = pack.msgdata.int[ "9" ]
        _data.item1 = pack.msgdata.int[ "4" ]
        _data.item2 = pack.msgdata.int[ "5" ]
        _smallHpPercent = math.floor( pack.msgdata.float[ "6" ] * 100 ) / 100
        _bigHpPercent = math.floor( pack.msgdata.float[ "7" ] * 100 ) / 100   
--        cclog( "_smallHpPercent:".._smallHpPercent .. " _bigHpPercent:".._bigHpPercent )  
        _curState = _state.GAME                
        if _nextFloor then
            _nextFloor = false
            enterNextFloor()
        else            
            resetChess()
            resetChessBoard()     
            refreshChessBoard()    
            refreshInfo( true )
        end
    elseif pack.header == StaticMsgRule.intoNextLayer then
        _enemyInfo = {}
        _goodsInfo = {}
        local enemyThings = utils.stringSplit( pack.msgdata.string[ "2" ] , ";" )
        for key ,value in pairs( enemyThings ) do
            local obj = utils.stringSplit( value , "_" )
            local _x = math.floor( tonumber( obj[ 1 ] ) / 10  ) - 1
            local _y = tonumber( obj[ 1 ] ) % 10
 --           cclog( "obj :" .. obj[ 1 ] .. "  ".._x .. "  " .. _y )
            _enemyInfo[ _x * 6 + _y ] = { id = obj[ 2 ] , hp = tonumber( obj[ 3 ] ) , attack = tonumber( obj[ 4 ] ) , qualityId = tonumber( obj[ 5 ] ) }
        end
        local goodsThings = utils.stringSplit( pack.msgdata.string[ "1" ] , ";" )
        for key ,value in pairs ( goodsThings ) do
            local obj = utils.stringSplit( value , "_" )
            local _x = math.floor( tonumber( obj[ 1 ] ) / 10  ) - 1
            local _y = tonumber( obj[ 1 ] ) % 10
            _goodsInfo[ _x * 6 + _y ] = StaticTableType.DictThing .. "_" .. obj[ 2 ].."_1"
        end
        local clicked = utils.stringSplit( pack.msgdata.string[ "3" ] , ";" )
        for key ,value in pairs ( clicked ) do
            local index = tonumber( value )
            local _x = math.floor( index / 10  )
            local _y = index % 10
   --         cclog( "value :"..value.."  ".._x .. "  ".._y )
            _chessBoard[ _x ][ _y ] = _pieceState.clicked
        end
        _data.floor = pack.msgdata.int[ "8" ]
        _data.killEnemy = pack.msgdata.int[ "9" ]
        _data.item1 = pack.msgdata.int[ "4" ]
        _data.item2 = pack.msgdata.int[ "5" ]
        _smallHpPercent = math.floor( pack.msgdata.float[ "6" ] * 100 ) / 100
        _bigHpPercent = math.floor( pack.msgdata.float[ "7" ] * 100 ) / 100   
 --       cclog( "_smallHpPercent:".._smallHpPercent .. " _bigHpPercent:".._bigHpPercent )  
        _curState = _state.GAME                
        if _nextFloor then
            _nextFloor = false
            enterNextFloor()
        else            
            resetChess()
            resetChessBoard()     
            refreshChessBoard()    
            refreshInfo( true )
        end
    end
end
local function netSendData( state )
    if DEBUG then
        if state == _state.ENTER then
        elseif state == _state.GAME then
        end       
        callBack( { header = state } )
        return
    end
    local sendData = {}
    if state == _state.ENTER then
        sendData = {
            header = StaticMsgRule.clickFireFam ,
            msgdata = {}
        }
    elseif state == _state.GAME then
        if _nextFloor then
                sendData = {
                header = StaticMsgRule.intoNextLayer ,
                msgdata = {
                    int = {
                        --fightValue = utils.getFightValue()
                    }
                }
            }
        else
            utils.reloadModelAll()
            sendData = {
                header = StaticMsgRule.intoFireFam ,
                msgdata = {
                    int = {
                        fightValue = utils.getFightValue()
                    },
                    string =
                    {
                        coredata = utils.fightVerifyData()-- 此处不可以欲计算
                    }
                }
            }
        end
    end  
    UIManager.showLoading()
    netSendPackage( sendData , callBack , function ( pack )
        if pack.header == StaticMsgRule.intoFireFam then
            if pack.msgdata.string.retMsg and pack.msgdata.string.retMsg == Lang.ui_fire_base16 then
                UIFireBase.checkPlayerEnergy()
            end
        end
    end )
end
UIFireBase.BuyEneryDialog = { }
local function netCallbackFunc(pack)
    if tonumber(pack.header) == StaticMsgRule.thingUse or tonumber(pack.header) == StaticMsgRule.goldEnergyOrVigor then
        if tonumber(pack.header) == StaticMsgRule.thingUse then
            UIManager.showToast(Lang.ui_fire_base17 .. DictSysConfig[tostring(StaticSysConfig.energyPillEnergy)].value .. Lang.ui_fire_base18)
        else
            local widget = UIFightTaskChoose.BuyEneryDialog.Widget
            if widget then
                local text_energypill = ccui.Helper:seekNodeByName(widget, "text_energypill")
                local sprite = cc.Sprite:create("image/+1.png")
                local size = text_energypill:getContentSize()
                sprite:setPosition(size.width / 2, size.height / 2)
                sprite:setScale(20 / sprite:getContentSize().height)
                sprite:setOpacity(150)
                text_energypill:addChild(sprite)

                local rightHint = ccui.Helper:seekNodeByName(widget, "rightHint")
                rightHint:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.1, 1)))

                local scaleAction = cc.ScaleTo:create(1 / 6, 1.0)
                local alphaAction = cc.Sequence:create(cc.FadeIn:create(5 / 60), cc.DelayTime:create(1 / 6), cc.FadeOut:create(15 / 60))
                local moveAction = cc.EaseCubicActionInOut:create(cc.MoveBy:create(30 / 60, cc.p(0, 127)))
                moveAction = cc.Sequence:create(moveAction, cc.RemoveSelf:create())
                sprite:runAction(cc.Spawn:create(scaleAction, alphaAction, moveAction))
            end
        end

        if tonumber(pack.header) == StaticMsgRule.goldEnergyOrVigor then
            UIShop.getShopList(1, nil)
        end
        UIFireBase.checkPlayerEnergy()
    end
end
local function showBuyEnergyDialog()
    UIFireBase.BuyEneryDialog.init()
    UIFireBase.BuyEneryDialog.setup()
end

function UIFireBase.BuyEneryDialog.init()
    if UIFireBase.BuyEneryDialog.Widget then return end
    local vipNum = net.InstPlayer.int["19"]

    local ui_middle = ccui.Layout:create()
    ui_middle:setContentSize(display.size)
    ui_middle:setTouchEnabled(true)
    ui_middle:retain()

    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    ui_middle:addChild(bg_image)
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(500, 500))
    bg_image:setPosition(display.size.width / 2, display.size.height / 2)
    local bgSize = bg_image:getPreferredSize()

    local title = ccui.Text:create()
    title:setString(Lang.ui_fire_base19)
    title:setFontName(dp.FONT)
    title:setFontSize(35)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height - title:getContentSize().height - 15))
    bg_image:addChild(title, 3)

    local msgLabel = ccui.Text:create()
    msgLabel:setString(Lang.ui_fire_base20)
    msgLabel:setTextAreaSize(cc.size(425, 500))
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(26)
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height - title:getContentSize().height * 3.5))
    bg_image:addChild(msgLabel, 3)

    local node = cc.Node:create()
    local image_di = ccui.ImageView:create("ui/quality_small_blue.png")
    local image = ccui.ImageView:create("image/poster_item_small_tilidan.png")
    local description = ccui.Text:create()
    description:setName("text_energypill")
    description:setFontSize(20)
    description:setFontName(dp.FONT)
    description:setAnchorPoint(cc.p(0.5, 1))
    description:setTextColor(cc.c3b(255, 255, 0))
    image:setPosition(cc.p(image_di:getContentSize().width / 2, image_di:getContentSize().height / 2))
    image_di:addChild(image)
    image_di:setPosition(cc.p(0, 0))
    description:setPosition(cc.p(0, - image_di:getContentSize().height / 2 - 5))
    node:addChild(image_di)
    node:addChild(description)
    description:setString(Lang.ui_fire_base21 .. DictSysConfig[tostring(StaticSysConfig.energyPillEnergy)].value)
    node:setPosition(cc.p(bgSize.width / 2, msgLabel:getPositionY() -95))
    bg_image:addChild(node, 3)

    local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    closeBtn:setPressedActionEnabled(true)
    closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width / 2, bgSize.height - closeBtn:getContentSize().height / 2))
    bg_image:addChild(closeBtn, 3)

    closeBtn:addTouchEventListener( function(sender, eventType)
        if sender == closeBtn then
            bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.1), cc.CallFunc:create( function()
                UIManager.uiLayer:removeChild(ui_middle, true)
                cc.release(ui_middle)
                UIFireBase.BuyEneryDialog.Widget = nil
            end )))
        end
    end
    )

    local sureBtn = ccui.Button:create("ui/yh_sq_btn01.png", "ui/yh_sq_btn01.png")
    sureBtn:setName("sureBtn")
    sureBtn:setPressedActionEnabled(true)
    local withscale = ccui.RichText:create()
    withscale:setName("withscale")
    withscale:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.ui_fire_base22, dp.FONT, 25))
    withscale:pushBackElement(ccui.RichElementImage:create(2, display.COLOR_WHITE, 255, "ui/jin.png"))
    withscale:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, "×10", dp.FONT, 25))
    withscale:setPosition(sureBtn:getContentSize().width / 2, sureBtn:getContentSize().height / 2)
    sureBtn:addChild(withscale)
    sureBtn:setPosition(cc.p(bgSize.width / 4, bgSize.height * 0.2))
    bg_image:addChild(sureBtn, 3)

    local leftHint = ccui.RichText:create()
    leftHint:setName("leftHint")
    leftHint:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.ui_fire_base23, dp.FONT, 20))
    leftHint:pushBackElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 0), 255, "0", dp.FONT, 20))
    leftHint:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, Lang.ui_fire_base24, dp.FONT, 20))
    leftHint:setPosition(cc.p(bgSize.width / 4, bgSize.height * 0.1))
    bg_image:addChild(leftHint, 3)

    local useBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    useBtn:setName("useBtn")
    useBtn:setTitleText(Lang.ui_fire_base25)
    useBtn:setTitleFontName(dp.FONT)
    useBtn:setTitleFontSize(25)
    useBtn:setPressedActionEnabled(true)
    useBtn:setPosition(cc.p(bgSize.width / 4 * 3, bgSize.height * 0.2))
    bg_image:addChild(useBtn, 3)

    local rightHint = ccui.RichText:create()
    rightHint:setName("rightHint")
    rightHint:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.ui_fire_base26, dp.FONT, 20))
    rightHint:pushBackElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 0), 255, "0", dp.FONT, 20))
    rightHint:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, Lang.ui_fire_base27, dp.FONT, 20))
    rightHint:setPosition(cc.p(bgSize.width / 4 * 3, bgSize.height * 0.1))
    bg_image:addChild(rightHint, 3)

    UIManager.uiLayer:addChild(ui_middle, 20000)
    ActionManager.PopUpWindow_SplashAction(bg_image)
    UIFireBase.BuyEneryDialog.Widget = ui_middle
end

function UIFireBase.BuyEneryDialog.setup()
    if not UIFireBase.BuyEneryDialog.Widget then return end

    local widget = UIFireBase.BuyEneryDialog.Widget

    local number = 0
    local instThingId = nil
    if net.InstPlayerThing then
        for key, obj in pairs(net.InstPlayerThing) do
            if StaticThing.energyPill == obj.int["3"] then
                number = obj.int["5"]
                instThingId = obj.int["1"]
            end
        end
    end

    local withscale = ccui.Helper:seekNodeByName(widget, "withscale")
    local leftHint = ccui.Helper:seekNodeByName(widget, "leftHint")
    local rightHint = ccui.Helper:seekNodeByName(widget, "rightHint")
    local sureBtn = ccui.Helper:seekNodeByName(widget, "sureBtn")
    local useBtn = ccui.Helper:seekNodeByName(widget, "useBtn")

    withscale:removeElement(2)
    withscale:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, "×" .. energyPillPrice, dp.FONT, 25))
    leftHint:removeElement(1)
    leftHint:insertElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 0), 255, tostring(math.max(0, buyEnergyNum)), dp.FONT, 20), 1)
    rightHint:removeElement(1)
    rightHint:insertElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 0), 255, tostring(number), dp.FONT, 20), 1)

    local function sendUseData(_instPlayerThingId)
        local sendData = {
            header = StaticMsgRule.thingUse,
            msgdata =
            {
                int =
                {
                    instPlayerThingId = _instPlayerThingId,
                    num = 1,
                }
            }
        }
        UIManager.showLoading()
        netSendPackage(sendData, netCallbackFunc)
    end
    local function sendGoldData()
        local sendData = {
            header = StaticMsgRule.goldEnergyOrVigor,
            msgdata =
            {
                int =
                {
                    type = 1,
                }
            }
        }
        UIManager.showLoading()
        netSendPackage(sendData, netCallbackFunc)
    end

    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == sureBtn then
                if 0 < buyEnergyNum then
                    sendGoldData()
                end
            elseif sender == useBtn then
                if number > 0 then
                    sendUseData(instThingId)
                end
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    useBtn:addTouchEventListener(btnEvent)
    if number <= 0 then
        utils.GrayWidget(useBtn, true)
        useBtn:setEnabled(false)
    else
        utils.GrayWidget(useBtn, false)
        useBtn:setEnabled(true)
    end
    if energyPillPrice > net.InstPlayer.int["5"] or buyEnergyNum <= 0 then
        utils.GrayWidget(sureBtn, true)
        sureBtn:setEnabled(false)
    else
        utils.GrayWidget(sureBtn, false)
        sureBtn:setEnabled(true)
    end
end
local function getShopFunc(pack)
    local propThing = pack.msgdata.message
    if propThing then
        for key, obj in pairs(propThing) do
            local tableFieldId = obj.int["thingId"]
            if tableFieldId == StaticThing.energyPill then
                -- energyPillPrice = obj.int["price"]
                -- buyEnergyNum = obj.int["canBuyNum"]

                buyEnergyNum = obj.int["canBuyNum"]
                local _todayBuyPrice = 0
                --   buyVigorNum = _obj.int["todayBuyNum"]
                local _todayBuyNum = obj.int["todayBuyNum"] + 1
                local _extend = utils.stringSplit(DictThingExtend[tostring(tableFieldId)].extend, ";")
                for _k, _o in pairs(_extend) do
                    local _tempO = utils.stringSplit(_o, "_")
                    if _todayBuyNum >= tonumber(_tempO[1]) and _todayBuyNum <= tonumber(_tempO[2]) then
                        energyPillPrice = math.round(tonumber(_tempO[3]) * UIShop.disCount)
                        break
                    end
                end

                break
            end
        end
    end
    showBuyEnergyDialog()
end
function UIFireBase.checkPlayerEnergy()
    UIManager.showLoading()
    local data = {
        header = StaticMsgRule.getStoreData,
        msgdata =
        {
            int =
            {
                type = 1,
            },
        }
    }
    netSendPackage(data, getShopFunc)
end
--点击物品效果
local function goodsEffect( i ) 
    local actionTime = 0.4
    lock( true )
    local goodsCard = UIFireBase.Widget:getChildByName( "goods"..i )
    local function effectEnd()
        goodsCard:setLocalZOrder( 100 )
        goodsCard:removeFromParent()
        _goodsInfo[ i ] = nil
        lock( false )
        _isClicking = false
    end    
    if goodsCard then
        goodsCard:setLocalZOrder( 102 )
        local dictData = utils.getItemProp( _goodsInfo[ i ] )      
        if dictData.tableFieldId == StaticThing.key then --钥匙
            AudioEngine.playEffect("sound/fire_get.mp3")
            goodsCard:runAction( cc.Sequence:create( cc.MoveTo:create( actionTime , cc.p( 423 , 902 ) ) , cc.ScaleTo:create( 0.2 , 1.2 ) , cc.ScaleTo:create( 0.4 , 0.7 ) , cc.CallFunc:create(
                function ()                 
                    effectEnd()
                    lock( true )
                    openDoor()                  
                    _data.item1 = 1
                    ccui.Helper:seekNodeByName( UIFireBase.Widget , "image_base_name" ):getChildByName( "image_frame_good1" ):getChildByName("image_good"):setVisible( true )
                end
            ) ) )
        elseif dictData.tableFieldId == StaticThing.door then --门
            --进入下一层
            if _data.item1 and _data.item1 == 1 then
                UIManager.showToast( Lang.ui_fire_base28 )
                lock( false )
                _isClicking = false
                _nextFloor = true
                netSendData( _state.GAME )
            else
                UIManager.showToast( Lang.ui_fire_base29 )
                _isClicking = false
                lock( false )
            end
            
        elseif dictData.tableFieldId == StaticThing.thing168 then --宝剑
            if _data.item2 == 1 then
                lock( false )
                _isClicking = false
                UIManager.showToast( Lang.ui_fire_base30 )
                return
            end
            AudioEngine.playEffect("sound/fire_get.mp3")
             goodsCard:runAction( cc.Sequence:create( cc.MoveTo:create( actionTime , cc.p( 545 , 902 ) ) , cc.ScaleTo:create( 0.2 , 1.2 ) , cc.ScaleTo:create( 0.4 , 0.7 ) , cc.CallFunc:create(
                function ()                   
                    effectEnd()
                    _data.item2 = 1
                    refreshInfo()
                    ccui.Helper:seekNodeByName( UIFireBase.Widget , "image_base_name" ):getChildByName( "image_frame_good2" ):getChildByName("image_good"):setVisible( true )
                end
             ) ) )
        elseif dictData.tableFieldId == StaticThing.smallpot then --小血瓶
            if _data.curHp >= _data.maxHp then
                lock( false )
                _isClicking = false
                UIManager.showToast( Lang.ui_fire_base31 )
                return
            end
            AudioEngine.playEffect("sound/fire_get.mp3")
            goodsCard:runAction( cc.Sequence:create( cc.MoveTo:create( actionTime , cc.p( 395 , 695 ) ) , cc.ScaleTo:create( 0.2 , 1.2 ) , cc.ScaleTo:create( 0.4 , 0.7 ) , cc.CallFunc:create(
                function ()
                    effectEnd()
                    addHp( 1 )
                    _isHpAction = true
                    refreshInfo()
                end
             ) ) )
        elseif dictData.tableFieldId == StaticThing.bigpot then --大血瓶
            if _data.curHp >= _data.maxHp then
                lock( false )
                _isClicking = false
                UIManager.showToast( Lang.ui_fire_base32 )
                return
            end
            AudioEngine.playEffect("sound/fire_get.mp3")
            goodsCard:runAction( cc.Sequence:create( cc.MoveTo:create( actionTime , cc.p( 395 , 695 ) ) , cc.ScaleTo:create( 0.2 , 1.2 ) , cc.ScaleTo:create( 0.4 , 0.7 ) , cc.CallFunc:create(
                function ()
                    effectEnd()
                    addHp( 2 )
                    _isHpAction = true
                    refreshInfo()
                end
             ) ) )
        elseif dictData.tableFieldId == StaticThing.fireBox then --异火宝箱
       --     UIManager.showToast( "打开异火宝箱" )
            AudioEngine.playEffect("sound/fire_get.mp3")
           -- effectEnd()
            goodsCard:setLocalZOrder( 100 )
            goodsCard:removeFromParent()
            _goodsInfo[ i ] = nil
        end
    end
end
--点击碎掉动画
local function clickEffect( i , index )
    lock( true )
    local animation = getResultAnimation()
    animation:getAnimation():playWithIndex( 3 )
    AudioEngine.playEffect("sound/fire_click.mp3")
    animation:setPosition( _block[ i ]:getPosition() )
    UIFireBase.Widget:addChild( animation , 105 )   
    _block[ i ]:loadTexture( "ui/fire_lattice1.png" )     
    local function onMovementEvent(armature, movementType, movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            armature:getAnimation():stop()
            armature:removeFromParent() 
            refreshChessBoard()   
            lock( false )
            _isClicking = false
        end
    end 
    animation:getAnimation():setMovementEventCallFunc(onMovementEvent)  
end
function UIFireBase.clickChessBoard( index , killEnemy )  
    lock( true )
    local _x = math.floor( ( index - 1 ) / 6 ) + 1
    local _y = ( ( index - 1 ) % 6 ) + 1
    local function sendData( callBack1 )
 --       cclog( " click grid :" .._x * 10 + _y )      
        UIManager.showLoading()
        netSendPackage( { header = StaticMsgRule.clickGrid , msgdata = { int  = { gridNo = _x * 10 + _y } } } , function ( pack )
   --         _isClicking = true
            local gridNo = tonumber( pack.msgdata.int[ "2" ] )
            local x1 = math.floor( gridNo / 10  ) - 1
            local y1 = gridNo % 10
            callBack1( x1 * 6 + y1 )    
            if pack.msgdata and pack.msgdata.string and pack.msgdata.string[ "1" ] then
              --  local award = utils.stringSplit( pack.msgdata.string[ "1" ] , ";" )
              --  UIAwardGet.setOperateType(UIAwardGet.operateType.award, award )
              --  UIManager.pushScene("ui_award_get")
              utils.showGetThings( pack.msgdata.string[ "1" ] , 0.2 , 0.3 , 0.2 )
            end        
        end , function ()
            UIFireBase.Widget:runAction( cc.Sequence:create( cc.DelayTime:create( 1 ) , cc.CallFunc:create(
                function ()
                    if not _isClicking then
                        lock( false )
                    end
                end
            ) ) )
        end)   
    end
    if killEnemy then
        if not _isClicking then
            lock( false )
        end
  --      cclog( "敌兵死亡：".. _chessBoard[ _x ][ _y ] )
    else
        if _chessBoard[ _x ][ _y ] == _pieceState.clicked then
            if isLiveEnemy( index ) then--此处格子有物品
             --   UIManager.showToast( "此处有怪物"..index )
--                sendData( function()
--                    attackEffect( index )
--                end)               
            elseif isLiveGoods( index ) then
             --   UIManager.showToast( "此处有物品"..index )
--                sendData( function()
--                    goodsEffect( index )
--                end)  
            else
             --   UIManager.showToast( "此处已经点过"..index )
                if not _isClicking then
                    lock( false )
                end
                return
            end
            
        end
        if _chessBoard[ _x ][ _y ] == _pieceState.stop or _chessBoard[ _x ][ _y ] == _pieceState.stop2 then
          --  UIManager.showToast( "xxx"..index )
            if not _isClicking then
                lock( false )
            end
            return
        end
        if _chessBoard[ _x ][ _y ] == _pieceState.unClick then
          --  UIManager.showToast( "此处不能点击"..index )
            if not _isClicking then
                lock( false )
            end
            return
        end
    end
    if _chessBoard[ _x ][ _y ] == _pieceState.click or _chessBoard[ _x ][ _y ] == _pieceState.clicked or killEnemy then
       -- UIManager.showToast( "能点碎裂"..index )
        local function aaa( index2 )
            local _x1 = math.floor( ( index2 - 1 ) / 6 ) + 1
            local _y1 = ( ( index2 - 1 ) % 6 ) + 1
            _chessBoard[ _x1 ][ _y1 ] = _pieceState.clicked
            local pos = {
                { _x1 - 1 , _y1 } ,
                { _x1 + 1 , _y1 } ,
                { _x1 , _y1 - 1 } ,
                { _x1 , _y1 + 1 } ,
                { _x1 - 1 , _y1 - 1 } ,
                { _x1 + 1 , _y1 + 1 } ,
                { _x1 - 1 , _y1 + 1 } ,
                { _x1 + 1 , _y1 - 1 }
            }
            if isLiveEnemy( index2 ) then
               for i = 1 , 8 do
                    local x = pos[ i ][ 1 ]
                    local y = pos[ i ][ 2 ]                
                    if x > 0 and x < 7 and y > 0 and y < 7 and _chessBoard[ x ][ y ] ~= _pieceState.clicked then
                        _chessBoard[ x ][ y ] = _pieceState.stop
                    end    
                    if i <= 4 then
                        if x > 0 and x < 7 and y > 0 and y < 7 and _chessBoard[ x ][ y ] == _pieceState.stop then
                            _chessBoard[ x ][ y ] = _pieceState.stop2
                        end
                    end           
                end
            elseif killEnemy then
                local function isCanClick( x , y )
                    local pos1 = {
                        { x - 1 , y } ,
                        { x + 1 , y } ,
                        { x , y - 1 } ,
                        { x , y + 1 } ,
                        { x - 1 , y - 1 } ,
                        { x + 1 , y + 1 } ,
                        { x - 1 , y + 1 } ,
                        { x + 1 , y - 1 }
                    }
                    local isC = true
                    for i = 1 , 8 do
                        local x1 = pos1[ i ][ 1 ]
                        local y1 = pos1[ i ][ 2 ]
                        if x1 > 0 and x1 < 7 and y1 > 0 and y1 < 7 and _chessBoard[ x1 ][ y1 ] == _pieceState.clicked  and isLiveEnemy( ( x1 - 1 ) * 6 + y1 ) then
                            if i <= 4 then
                                isC = 4
                            else
                                isC = 0
                            end
                        elseif isC ~= 2 and x1 > 0 and x1 < 7 and y1 > 0 and y1 < 7 and _chessBoard[ x1 ][ y1 ] == _pieceState.clicked then
                            if i <= 4 then
                                if isC == 0 then
                                    isC = 4
                                else
                                    isC = 2
                                end
                            elseif isC ~= 0 then
                                isC = 3
                            end
                        elseif isC ~= 0 and isC ~= 2 and x1 > 0 and x1 < 7 and y1 > 0 and y1 < 7 then
                            isC = 3
                        end
                        if isC == 4 then
                            break
                        end
                    end
                    return isC
                end
            
                for i = 1 , 8 do
                    local x = pos[ i ][ 1 ]
                    local y = pos[ i ][ 2 ]
                    if x > 0 and x < 7 and y > 0 and y < 7 and _chessBoard[ x ][ y ] ~= _pieceState.clicked and isCanClick( x , y ) == 4 then
                        _chessBoard[ x ][ y ] = _pieceState.stop2
                    elseif x > 0 and x < 7 and y > 0 and y < 7 and _chessBoard[ x ][ y ] ~= _pieceState.clicked and isCanClick( x , y ) == 2 then
                        _chessBoard[ x ][ y ] = _pieceState.click
                    elseif x > 0 and x < 7 and y > 0 and y < 7 and _chessBoard[ x ][ y ] ~= _pieceState.clicked and isCanClick( x , y ) == 3 then
                        if i <= 4 then
                            _chessBoard[ x ][ y ] = _pieceState.click
                        else
                            _chessBoard[ x ][ y ] = _pieceState.unClick
                        end
                    end
                end
            else
                for i = 1 , 4 do
                    local x = pos[ i ][ 1 ]
                    local y = pos[ i ][ 2 ]
                    if x > 0 and x < 7 and y > 0 and y < 7 and _chessBoard[ x ][ y ] ~= _pieceState.clicked and _chessBoard[ x ][ y ] ~= _pieceState.stop and _chessBoard[ x ][ y ] ~= _pieceState.stop2 then
                        _chessBoard[ x ][ y ] = _pieceState.click
                    elseif x > 0 and x < 7 and y > 0 and y < 7 and _chessBoard[ x ][ y ] == _pieceState.stop then
                        _chessBoard[ x ][ y ] = _pieceState.stop2
                    end
                end
            end
        end      
        if not killEnemy then
            sendData( function( index1 )                
                if _chessBoard[ _x ][ _y ] == _pieceState.clicked then
                    if isLiveEnemy( index1 ) then--此处格子有物品
                     --   UIManager.showToast( "此处有怪物"..index )
                            attackEffect( index1 )              
                    elseif isLiveGoods( index1 ) then
                     --   UIManager.showToast( "此处有物品"..index )
                            goodsEffect( index1 ) 
                    else
                        _isClicking = false
                    end
                else
                    aaa( index1 )
                    clickEffect( index1 ) 
                end          
            end)
        else
            aaa( index )
        end   
    end   
end
local _pointCount = 0
function UIFireBase.init()
    local image_basemap = ccui.Helper:seekNodeByName( UIFireBase.Widget , "image_basemap" )
    local btn_back = image_basemap:getChildByName( "btn_back" )
    local btn_help = image_basemap:getChildByName( "btn_help" )
    btn_help:setVisible( false )
    local image_di = image_basemap:getChildByName( "image_di" )
    local btn_enter = image_di:getChildByName( "btn_enter")
    btn_enter:getChildByName("text_hint"):setString( Lang.ui_fire_base33 )
    local btn_rank = image_di:getChildByName( "btn_rank" )
    local btn_shop = image_di:getChildByName( "btn_shop" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                if _curState == _state.ENTER then
                    UIManager.showWidget("ui_menu")
                    UIManager.showWidget("ui_fire")
                elseif _curState == _state.GAME then
                    _isAction = true
                    netSendData( _state.ENTER )
                end
            elseif sender == btn_help then
            elseif sender == btn_enter then --进入秘境
               -- cclog( "level : " .. net.InstPlayer.int[ "4" ])
                if net.InstPlayer.int[ "4" ] < 40 then
                    UIManager.showToast( Lang.ui_fire_base34 )
                else
                    netSendData( _state.GAME )
                end
            elseif sender == btn_rank then --排行
                UIManager.pushScene( "ui_fire_rank" )
            elseif sender == btn_shop then --商店
                UIManager.pushScene( "ui_fire_shop" )
            end
        end
    end
    btn_back:setPressedActionEnabled( true )
    btn_back:addTouchEventListener( onEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )
    btn_enter:setPressedActionEnabled( true )
    btn_enter:addTouchEventListener( onEvent )
    btn_rank:setPressedActionEnabled( true )
    btn_rank:addTouchEventListener( onEvent )
    btn_shop:setPressedActionEnabled( true )
    btn_shop:addTouchEventListener( onEvent )

    local image_rule = image_basemap:getChildByName( "image_rule" )
    local view_rule = image_rule:getChildByName( "view_rule" )
    local text_info = view_rule:getChildByName( "text_info" )
    text_info:setAnchorPoint( cc.p( 0.24 , 1 ) )
    local str = ""
    for key ,value in pairs ( _helpStr ) do
        str = str .. value .. "\n \n"
    end
    text_info:setString( str )
    view_rule:setInnerContainerSize( cc.size( view_rule:getInnerContainerSize().width , view_rule:getInnerContainerSize().height + 150 ) )
    text_info:setPositionY( text_info:getPositionY() + 150 )
    view_rule:getChildByName( "text_rule" ):setPositionY( view_rule:getChildByName( "text_rule" ):getPositionY() + 150 )
    local panel_block = image_basemap:getChildByName( "panel_block" ) --棋盘
    for i = 1 , 36 do
        local block = panel_block:getChildByName( "image_block"..i )
        table.insert( _block , block )
    end
    local function onPannelEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            for i = 1 , 36 do
                if sender == _block[ i ] then
                    _pointCount = _pointCount + 1
                 --   UIManager.showToast( "" .. _pointCount )
                    if _pointCount == 1 then
                        UIFireBase.Widget:runAction( cc.Sequence:create( cc.DelayTime:create( 0.5 ) , cc.CallFunc:create(
                            function ()
                                 _pointCount = 0
                            end
                        ) ) )
                    end
                    if _pointCount > 1 then
                        return
                    end
                    UIFireBase.clickChessBoard( i )
                    break
                end
            end
        end
    end
    for i = 1 , 36 do
        _block[ i ]:setTouchEnabled( true )
        _block[ i ]:addTouchEventListener( onPannelEvent )
    end

    _itemCard = ccui.Helper:seekNodeByName( UIFireBase.Widget , "image_frame_monster" )
    local hpCard = _itemCard:getChildByName("image_blood")
    hpCard:setPosition( cc.p( hpCard:getPositionX() - 10 , hpCard:getPositionY() - 5 ) )
    local attackCard = _itemCard:getChildByName("image_attact")
    attackCard:setPosition( cc.p( attackCard:getPositionX() - 2 , attackCard:getPositionY() - 11 ) )
    attackCard:getChildByName("label_attaqct"):setPosition( cc.p( attackCard:getChildByName("label_attaqct"):getPositionX() + 13 , attackCard:getChildByName("label_attaqct"):getPositionY() + 3 ) )
    _itemCard:retain()
    _itemCard:removeFromParent()

    local image_frame_card = image_basemap:getChildByName( "image_frame_card" )
    image_frame_card:setPosition( cc.p( image_frame_card:getPositionX() - 1 , image_frame_card:getPositionY() ) )
    image_frame_card:setLocalZOrder( 100 )
    local imageHpCard = image_frame_card:getChildByName("image_blood")
    imageHpCard:setPosition( cc.p( imageHpCard:getPositionX() - 0.3 , imageHpCard:getPositionY() - 8.2 ) )
    local imageAttackCard = image_frame_card:getChildByName("image_attact")
    imageAttackCard:setPosition( cc.p( imageAttackCard:getPositionX() - 9 , imageAttackCard:getPositionY() - 7 ) )
    local card = image_frame_card:getChildByName( "image_card" )
    card:loadTexture( "image/"..DictUI[ tostring( DictCard[ "88" ].bigUiId ) ].fileName )
    card:setPosition( cc.p( card:getPositionX() + 13 , card:getPositionY() + 7.5 ) )
    local  label_attaqct = ccui.Helper:seekNodeByName( image_frame_card , "label_attaqct" )
    label_attaqct:setPosition( cc.p( label_attaqct:getPositionX() + 13 , label_attaqct:getPositionY() + 3 ) )

    _effect = cc.ParticleSystemQuad:create("particle/fireBase/ui_anim72_tx_1.plist")
    _effect:setPositionType(cc.POSITION_TYPE_RELATIVE)
    _effect:setPosition( cc.p( 95 , 52 ) )
    image_basemap:getChildByName( "image_base_name" ):getChildByName( "image_loading" ):getChildByName( "bar_loading" ):addChild( _effect , 101 )
    _effect:setVisible( false )

    local animPath = "ani/ui_anim/ui_anim72/"   
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim72.ExportJson")

    animPath = "ani/ui_anim/ui_anim74/"   
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim74.ExportJson")


    local image_frame_good1 = image_basemap:getChildByName( "image_base_name" ):getChildByName( "image_frame_good1" )
    local image_goods1 = image_frame_good1:getChildByName("image_good")
    image_goods1:loadTexture( "image/"..DictUI[tostring(DictThing[tostring( StaticThing.key )].smallUiId)].fileName )
    local goods1 = ccui.ImageView:create()
    local effect = getGoodsAnimation()
    effect:getAnimation():playWithIndex( 1 )
    effect:setName("effect")  
    goods1:addChild( effect , 100 )
    goods1:setPosition( cc.p( image_goods1:getContentSize().width / 2 , image_goods1:getContentSize().height / 2 ) )
    image_goods1:addChild( goods1 )
    image_frame_good1:getChildByName("text_good"):setString( DictThing[tostring( StaticThing.key )].name )

    local image_frame_good2 = image_basemap:getChildByName( "image_base_name" ):getChildByName( "image_frame_good2" )
    local image_goods2 = image_frame_good2:getChildByName("image_good")
    image_goods2:loadTexture( "image/"..DictUI[tostring(DictThing[tostring( StaticThing.thing168 )].smallUiId)].fileName )
    goods1 = ccui.ImageView:create()
    effect = getGoodsAnimation()
    effect:getAnimation():playWithIndex( 0 )
    effect:setName("effect")  
    goods1:addChild( effect , 100 )
    goods1:setPosition( cc.p( image_goods2:getContentSize().width / 2 , image_goods2:getContentSize().height / 2 ) )
    image_goods2:addChild( goods1 )
    image_frame_good2:getChildByName("text_good"):setString( DictThing[tostring( StaticThing.thing168 )].name )
end
function UIFireBase.setup()
    _isAction = false
    _data = {}
    _enemyInfo = {}   
    _goodsInfo = {}  
    _fightValue = utils.getFightValue()
    netSendData( _state.ENTER )
end
function UIFireBase.free()
    _curState = nil
    _data = nil
    _isAction = nil
    _enemyInfo = nil
    _goodsInfo = nil
    _isHpAction = nil
    _smallHpPercent = nil
    _bigHpPercent = nil
    _isClicking = nil
end

--[[ 签到 ]]--
local M = class( "sign_in" , function() return cc.Layer:create() end  )
function M:ctor()
    self.data = nil

    local base_node = self
    setNodeAttr(self , cc.p( -20 , -30 ) , cc.p( 0 , 0 ) )
    local bottomBg = createSprite( base_node , "res/common/bg/bg64.png", cc.p( 29, 48 ), cc.p(0, 0))

    self.viewLayer = cc.Node:create()
    base_node:addChild( self.viewLayer )

    local function setSwallowTouches( bg )
        local  listenner = cc.EventListenerTouchOneByOne:create()
        listenner:setSwallowTouches( true )--遮挡下方点击事件，没有实际用途
        listenner:registerScriptHandler(function(touch, event)   
            local pt = bg:getParent():convertTouchToNodeSpace(touch)
            if cc.rectContainsPoint(bg:getBoundingBox(), pt) then 
                return true
            end
            return false
            end, cc.Handler.EVENT_TOUCH_BEGAN )
        listenner:registerScriptHandler(function(touch, event)
                local start_pos = touch:getStartLocation()
                local now_pos = touch:getLocation()
                local span_pos = cc.p(now_pos.x-start_pos.x,now_pos.y-start_pos.y)
                if math.abs(span_pos.x) < 30 and math.abs(span_pos.y) < 30 then
                    local pt = bg:getParent():convertTouchToNodeSpace(touch)
                    if cc.rectContainsPoint(bg:getBoundingBox(), pt)  then
                    end
                end
            end, cc.Handler.EVENT_TOUCH_ENDED)
        local eventDispatcher = bg:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,bg)

    end
    local child = cc.LayerColor:create( cc.c4b(0, 0, 0, 0 ) )
    child:setContentSize( cc.size( 715 , 115 ) )
    setNodeAttr( child , cc.p( 30 , 0 ) , cc.p( 0 , 0 ) )
    base_node:addChild( child , 10 )
    setSwallowTouches( child )
  
    local function createLayout( sevData )
        if self.viewLayer then self.viewLayer:removeAllChildren() end
        self.data = DATA_Activity.CData["netData"]


        local width , height = 715 , 415

        local function createAwardLayer()
            local node = cc.Node:create()

            local toDay = self.data.isGet and self.data.hadDay or self.data.hadDay + 1 --后台数据从0计，对应前台，应加1

            --显示qq或微信中心启动奖励
            
            --if not LoginUtils.isReviewServer()then
            if false then --暂时关闭qq登录等
                local btn = nil
                if LoginUtils.isLaunchFromQQGameCenter() then
                    btn = createTouchItem(self.viewLayer,"res/layers/qqMember/qq.png",cc.p(70,82),nil)
                elseif LoginUtils.isLaunchFromWXGameCenter() then 
                    btn = createTouchItem(self.viewLayer,"res/layers/qqMember/wx.png",cc.p(70,82),nil)
                else
                    if LoginUtils.isQQLogin() then
                        btn = createTouchItem(self.viewLayer,"res/layers/qqMember/qq.png",cc.p(70,82),nil)
                        --btn:addColorGray()
                    else
                        btn = createTouchItem(self.viewLayer,"res/layers/qqMember/wx.png",cc.p(70,82),nil)
                        --btn:addColorGray()
                    end
                end

                local lb = createLabel(self.viewLayer, game.getStrByKey("qq_game_center_start_award"), cc.p(94, 82), cc.p(0, 0.5), 20, true)
                local spr = createSprite( self.viewLayer, "res/group/currency/1.png", cc.p( lb:getContentSize().width  + 94 , 82), cc.p( 0 , 0.5) ); 
                createLabel(self.viewLayer, "X8888", cc.p(lb:getContentSize().width  + 140, 82), cc.p(0, 0.5), 20, true)
            end
            

            local fontSize = 20 
            local text = require("src/RichText").new( self.viewLayer , cc.p( 730 , 100  ) , cc.size( 220 , 0 ) , cc.p( 1 , 1 ) , fontSize + 10 , fontSize , MColor.yellow_gray )
            text:addText( game.getStrByKey( "sign_in_tip" ), MColor.lable_black , false )
            text:format()

            local awards = self.data.awardData
            self.toDayAward = awards[toDay] --今天数据
            local lineNum = 4
            local cellWidth = 174
            local cellHeight = 154
            local awardHeight = math.ceil( #awards/lineNum ) * cellHeight
            local propOp = require( "src/config/propOp" )
            local addEffect = function(parent,quality,pos)
                if quality >= 2 and quality <= 5 then
                    local effectNode = Effects:create(false)
                    effectNode:setPosition(pos)
                    effectNode:playActionData("propColor".. quality, 11, 1.2, -1)
                    parent:addChild(effectNode,50+quality)
                end
            end
            local batch_root_node = createBatchRootNode(node,20)
            batch_root_node:setLocalZOrder(50)
            for i = 1 , #awards do
                local state = 0   --0可签 1已签 2可补签 3不可签到不可补签 
                if self.data.isGet then
                    if i<=toDay then
                        state = 1
                    else
                        if self.data.addRegDay <= 0 then
                            --没有补签次数了
                            state = 3
                        else
                            --可补签
                            local tomorrow = toDay + 1
                            if tomorrow <= self.data.totalDay and i == tomorrow then
                                state = 2
                            else
                                state = 3
                            end
                        end
                    end
                else
                    if i<toDay then
                        state = 1
                    elseif i==toDay then
                        state = 0
                    elseif i>toDay then
                        state = 3
                    end
                end

                local g_id = awards[i]["id"]       
                local addX = 95 + ( (i-1) % lineNum ) * cellWidth
                local addY = awardHeight - math.floor( (i-1) /lineNum) * cellHeight
                local iconBg = createSprite( node , "res/common/bg/itemBg4.png"  , cc.p( addX , addY ) , cc.p( 0.5 , 1 ) , 1 ) 

               	if state == 0 then
	                local getEff = Effects:create(false)
		            getEff:playActionData2("canSignin", 250 , -1 , 0 )
		            setNodeAttr( getEff , getCenterPos( iconBg ) , cc.p( 0.5 , 0.5 ) )
		            addEffectWithMode( getEff , 1 )
		            iconBg:addChild( getEff )
               	end


                local  listenner = cc.EventListenerTouchOneByOne:create()
                listenner:setSwallowTouches( false )
                listenner:registerScriptHandler(function(touch, event)   
                    local pt = iconBg:getParent():convertTouchToNodeSpace(touch)
                    if cc.rectContainsPoint(iconBg:getBoundingBox(), pt) then 
                        return true
                    end
                    return false
                    end, cc.Handler.EVENT_TOUCH_BEGAN )
                listenner:registerScriptHandler(function(touch, event)
                        local start_pos = touch:getStartLocation()
                        local now_pos = touch:getLocation()
                        local span_pos = cc.p(now_pos.x-start_pos.x,now_pos.y-start_pos.y)
                        if math.abs(span_pos.x) < 30 and math.abs(span_pos.y) < 30 then
                            local pt = iconBg:getParent():convertTouchToNodeSpace(touch)
                            if cc.rectContainsPoint(iconBg:getBoundingBox(), pt) then
                                if state == 0 then
                                    self:signCallBack() 
                                -- elseif state == 2  then    
                                --     self:addSignCallBack() 
                                else
                                    local grid = MPackStruct:buildGrid(
                                    {
                                        protoId = g_id,
                                        num = 1,
                                    })
                                    local Mtips = require "src/layers/bag/tips"
                                    Mtips.new(
                                    {
                                        grid = grid,
                                        pos = node:getParent():convertToWorldSpace( cc.p(node:getPosition()) ),
                                    })
                                end
                            end
                        end
                    end, cc.Handler.EVENT_TOUCH_ENDED)
                local eventDispatcher = iconBg:getEventDispatcher()
                eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,iconBg)
                createSprite( node , "res/common/bg/itemBg.png" , cc.p( addX , addY-20) , cc.p( 0.5 , 1), 20 )
                local iconBtn =  createSprite( node , propOp.icon( g_id) , cc.p( addX, addY-25) , cc.p( 0.5 , 1), g_id%9+40 )
                local iconBtn =  createSprite( node , propOp.icon( g_id) , cc.p( addX , addY-25) , cc.p( 0.5 , 1) )
                createBatchLabel( batch_root_node ,  propOp.name( g_id ) , cc.p( addX , addY-110) , cc.p( 0.5 , 1.0 ) , 20 , nil , 50 , nil ,  propOp.nameColor( g_id) )
                local numText = createLabel( batch_root_node , numToFatString(awards[i]["num"]) , cc.p( addX + 35 , addY-94) ,cc.p( 1.0 , 0.0 ) , 20 , nil , 50 )
                numText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
                createSprite(node, "res/group/itemBorder/" .. propOp.quality( g_id) .. ".png", cc.p(addX, addY - 21), cc.p(0.5, 1), 49)
                if state == 0  then
                    -- createSprite( node , "res/component/flag/red.png" ,   cc.p( addX+50 , addY-5) , cc.p( 0.5 , 1 ), 200 )
                elseif state == 1  then
                    local flagOk = createSprite( node , "res/component/flag/sign_ok.png" ,  cc.p( addX , addY) , cc.p( 0.5 , 1 ), 201 )
                    createSprite( flagOk , "res/component/flag/18.png" ,  getCenterPos( flagOk ) , cc.p( 0.5 , 0.5 ) )
                -- elseif state == 2  then
                --     createSprite( node , "res/component/flag/sign_next.png" ,  cc.p( addX , addY-50) , cc.p( 0.5 , 1 ) , 202 )
                end

                if i == 1 then
                    G_TUTO_NODE:setTouchNode(iconBtn, TOUCH_SIGNIN_SIGIN)
                end
            end

            node:setContentSize( cc.size( width , awardHeight ) )
            return node
        end


        local scrollView1 = cc.ScrollView:create()
        
        scrollView1:setViewSize(cc.size( width , height ))
        scrollView1:setPosition( cc.p( 25 , 120 ) )
        scrollView1:setScale(1.0)
        scrollView1:ignoreAnchorPointForPosition(true)
        scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
        local layer = createAwardLayer()
        scrollView1:setContainer( layer )
        scrollView1:updateInset()
        scrollView1:addSlider("res/common/slider.png")
        scrollView1:setClippingToBounds(true)
        scrollView1:setBounceable(true)
        scrollView1:setDelegate()
        
        if self["viewLayer"] then 
            self.viewLayer:addChild(scrollView1) 
            local layerSize = layer:getContentSize()
            scrollView1:setContentOffset( cc.p( 0 ,  height - layerSize.height ) )
        end

        G_TUTO_NODE:setShowNode(self, SHOW_SIGNIN)
    end

    DATA_Activity:readData( createLayout )
end

--补签
function M:addSignCallBack()

    local function showAddSignAward( buff )
        local t = g_msgHandlerInst:convertBufferToTable( "ActivityReSignInRet" , buff )
        local reward = t.reward
        local awardData = {}
        for i=1, #reward do
            awardData[i] = {}
            awardData[i]["id"] = reward[i].itemID                 --奖励ID
            awardData[i]["num"] = reward[i].count                 --奖励个数
            awardData[i]["showBind"] = true;
            awardData[i]["isBind"] = reward[i].bind              --绑定(1绑定0不绑定)
            awardData[i]["streng"] = reward[i].strength           --强化等级
            awardData[i]["time"] = reward[i].timeLimit            --限时时间
        end
        Awards_Panel( { awards = awardData , award_tip = game.getStrByKey("addSignAward") } )


        -- local awardPopup = popupBox({isNoSwallow = false, bg = COMMONPATH .. "5.png", zorder = 200 , actionType = 5, close = { scale = 0.7, offX = 27, offY = 15 }})
        -- registerOutsideCloseFunc( awardPopup , function() removeFromParent(awardPopup) awardPopup = nil end , true ,true )
        -- createLabel(awardPopup, string.format(game.getStrByKey("addSignAward"), addCost), cc.p(37, 257), cc.p(0,0.5), 20):setColor(MColor.yellow)

        -- local menuitem = createMenuItem( awardPopup , "res/component/button/50.png" , cc.p( awardPopup:getContentSize().width/2 , 45 ) , function() awardPopup:close() end )
        -- createLabel(menuitem , game.getStrByKey( "sure" ) , getCenterPos( menuitem ) , cc.p( 0.5 , 0.5 ) , 20 , nil , nil , nil , MColor.yellow_gray , nil , nil )
    


        -- local awardNode1 = cc.Node:create()
        -- for i = 1, #awardData do
        --     local iconBtn = iconCell( { parent = awardNode1, num = { value = awardData[i].num }, iconID = awardData[i].id, isTip = true} )
        --     local iconBtnSize = iconBtn:getContentSize()
        --     setNodeAttr( iconBtn , cc.p( i * 85 , 80 ) , cc.p( 0.5 , 0.5 ) )
        -- end
        -- awardNode1:setContentSize( cc.size( #awardData * 85 + 80 , 80 )  )
        -- if num <= 2 then
        --     setNodeAttr( awardNode1 , cc.p( awardPopup:getContentSize().width/2 , 80+45 ) , cc.p( 0.5 , 0.5 ) )
        --     awardPopup:addChild( awardNode1 )
        -- else
        --     local scrollView1 = cc.ScrollView:create()
        --     scrollView1:setViewSize(cc.size( 355 , 154 ) )
        --     scrollView1:setPosition( cc.p( 28 , 88 ) )
        --     scrollView1:setScale(1.0)
        --     scrollView1:ignoreAnchorPointForPosition(true)
        --     scrollView1:setContainer( awardNode1 )
        --     scrollView1:updateInset()

        --     scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        --     scrollView1:setClippingToBounds(true)
        --     scrollView1:setBounceable(true)
        --     awardPopup:addChild(scrollView1)
        -- end

    end

    if self.data.addRegDay <= 0 then
        TIPS( { type = 1 , str = game.getStrByKey("cannot_addsign")})
    else
        local function addSignYes(btnIndex)
            if self.data == nil then return end
            local addNum = self.data.addRegDay
            if btnIndex == 1 then addNum = 1 end   
            g_msgHandlerInst:sendNetDataByTableExEx(ACTIVITY_CS_RESIGN_REQ, "ActivityReSignIn", { times = addNum })
            g_msgHandlerInst:registerMsgHandler( ACTIVITY_SC_RESIGN_RET , showAddSignAward )
        end

        local msg = string.format(game.getStrByKey("addSign_tips"), self.data.addRegDay ,  self.data.addRegDay , self.data.addRegDay * self.data.cost )
        local messageBox = nil
        if self.data.addRegDay == 1 then
            messageBox = MessageBoxYesNo( nil , msg .. "\n\n\n" , function() addSignYes(1) end , function() end )
        else
            messageBox = MessageBoxYesNoEx( nil , msg , function() addSignYes(1) end , function() addSignYes(2) end, game.getStrByKey("sign_day"), game.getStrByKey("sign_text") .. self.data.addRegDay ..game.getStrByKey("day"), true)
        end
        createLabel(messageBox, string.format( game.getStrByKey("addSign_tips1") , self.data.cost ), cc.p(200, 120), cc.p(0.5,0.5), 20):setColor(MColor.red)
    end
end
--签到
function M:signCallBack()
    -- local function showAward( _tempData )
    --     local awardid = _tempData.itemID      --物品ID
    --     local awardNum = _tempData.count     --物品个数

    --     local awardPopup = popupBox({ isNoSwallow = true,bg = COMMONPATH .. "5.png" ,  actionType = 5 } )
    --     local size = awardPopup:getContentSize()
    --     -- createScale9Sprite( awardPopup , "res/common/scalable/blackBg.png" , cc.p( size.width/2 , 170) , cc.size( size.width - 45 , size.height - 100 ) , cc.p( 0.5 , 0.5 ) )
    --     registerOutsideCloseFunc( awardPopup , function() removeFromParent(awardPopup) awardPopup = nil end , true , true )


    --     local menuitem = createMenuItem( awardPopup , "res/component/button/50.png" , cc.p( awardPopup:getContentSize().width/2 , 40 ) , function() awardPopup:close() end )
    --     createLabel(menuitem , game.getStrByKey( "sure" ) , getCenterPos( menuitem ) , cc.p( 0.5 , 0.5 ) , 20 , nil , nil , nil , MColor.yellow_gray , nil , nil )

    --     local function awardItem( str )
    --         local group = cc.Node:create()
    --         local iconBtn = iconCell( { parent = group , tag = index , iconID = awardid } )
    --         local iconBtnSize = iconBtn:getContentSize()
    --         setNodeAttr( iconBtn , cc.p( 115 + iconBtnSize.width/2  , 0 + iconBtnSize.height/2 ) , cc.p( 0.5 , 0.5 ) )
    --         createLabel( group , str , cc.p( 0 , 53 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.yellow , nil , nil )
    --         createLabel( group , require( "src/config/propOp" ).name( awardid ) .. "  \nx" .. awardNum , cc.p( 210 , 18 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.yellow , nil , nil )
    --         return group
    --     end

    --     local item = awardItem( game.getStrByKey( "get_prize" ) )
    --     setNodeAttr( item , cc.p( 30 , 150 ) , cc.p( 0 , 0 ) )
    --     awardPopup:addChild( item )
    -- end
    -- local function reqSign()
    --     g_msgHandlerInst:sendNetDataByTableExEx(SIGNIN_CS_SIGNIN, "ActivitySignIn", {} )
    --     g_msgHandlerInst:registerMsgHandler( SIGNIN_SC_SIGNIN , function( buff ) 
    --             local t = g_msgHandlerInst:convertBufferToTable("ActivitySignInRet", buff) 
    --             showAward(  t  ) 
    --             end ) 
    -- end
    -- reqSign()

    g_msgHandlerInst:sendNetDataByTableExEx(SIGNIN_CS_SIGNIN, "ActivitySignIn", {} )
    g_msgHandlerInst:registerMsgHandler( SIGNIN_SC_SIGNIN , function( buff ) 
            local t = g_msgHandlerInst:convertBufferToTable("ActivitySignInRet", buff) 
            Awards_Panel( {  award_tip = game.getStrByKey("sign_text") .. game.getStrByKey("award")  , awards = { { id = t.itemID , num = t.count } } } )
            end ) 

end

return M
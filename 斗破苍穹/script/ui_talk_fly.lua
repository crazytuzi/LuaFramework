
UITalkFly = {}
UITalkFly.layer = nil
myLayout = nil
UITalkFly.curState = 1
function getDistance( x1 , y1 , x , y )
    return math.sqrt( ( x1 - x ) * ( x1 - x ) + ( y1 - y ) * ( y1 - y ) )
end

local isTouch = false
   local isMove = false
   local btn = nil
   local function onTouchBegan(touch, event)
       -- cclog( "gameLayer began")
        local touchPoint = UITalkFly.layer:convertTouchToNodeSpace(touch)
        if touchPoint.x > btn:getPositionX() -  btn:getContentSize().width / 2 and touchPoint.x < btn:getPositionX() + btn:getContentSize().width / 2 and touchPoint.y > btn:getPositionY() - btn:getContentSize().height / 2 and touchPoint.y < btn:getPositionY() + btn:getContentSize().height / 2 then
           -- cclog( "in rect" )
            isTouch = true
        else
          --  cclog( "not in rect" )
            isTouch = false
        end
        return isTouch
    end
    local function onTouchMoved(touch, event)
        --if isTouch then           
           local touchPoint = UITalkFly.layer:convertTouchToNodeSpace(touch)
           if not isMove and getDistance( touchPoint.x , touchPoint.y  , btn:getPositionX() , btn:getPositionY() ) < 30 then
               isMove = false
           else
               isMove = true   
               local touchX = touchPoint.x 
               local touchY = touchPoint.y
               if touchX < 0 then
                    touchX = 0
               elseif touchX > UIManager.screenSize.width then
                    touchX = UIManager.screenSize.width
               end
               if touchY < 0 then
                    touchY = 0
               elseif touchY > UIManager.screenSize.height then
                    touchY = UIManager.screenSize.height
               end
               btn:setPosition( cc.p( touchX , touchY ) )   
               --cclog( "touch :"..touchX.."  "..touchY )
           end
      -- end
    end
    local function onTouchEnded(touch, event)
       -- cclog( "gameLayer Ended" )
       if UIGuidePeople.guideStep or UIGuidePeople.levelStep then
       else
           if isTouch and not isMove then
               if not UITalk.Widget then
                    UIManager.pushScene("ui_talk")
               end
           end
           isMove = false
       end
    end

function UITalkFly.init()
     UITalkFly.layer = cc.Layer:create()
     btn = ccui.Button:create("ui/talk_no.png", "ui/talk_no.png")
    --local default_itme = ccui.Layout:create()  
   -- default_itme:setTouchEnabled(true)  
    --default_itme:setContentSize(btn:getContentSize())  
    --btn:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    --default_itme:addChild(btn)  
    --local sprite = cc.Sprite:create("ui/hong_liaotian.png")
    myLayout = ccui.Layout:create()
    myLayout:setContentSize( UIManager.screenSize )  
    UITalkFly.layer:addChild( myLayout , 100001 )

   -- myLayout:setVisible( false )
   
   
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches( true )
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = myLayout:getEventDispatcher()
    eventDispatcher:removeEventListenersForTarget(myLayout)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, myLayout)

    btn:setPosition(cc.p(590, 835))
	UITalkFly.layer:addChild( btn , 100000 )
    btn:setTouchEnabled( false )
 --   btn:addTouchEventListener( onBtnEvent )
end

function UITalkFly.showTips( isShow )
   if isShow then
        if UITalkFly.layer and btn then
            btn:loadTextureNormal("ui/talk_yes.png")
        end
        if UIHomePage.Widget then
           UIHomePage.tk = 1
           UIManager.flushWidget(UIHomePage)
        end
   else
        if UITalkFly.layer and btn then
            btn:loadTextureNormal("ui/talk_no.png")
        end
        if UIHomePage.Widget then
            UIHomePage.tk = nil
            UIManager.flushWidget(UIHomePage)
        end
   end
end

function UITalkFly.show ()
    if UIGuidePeople.guideStep or UIGuidePeople.levelStep then
    else
        if UITalkFly.layer and not UITalkFly.layer:isVisible() then
            UITalkFly.layer:setVisible( true )
             local listener = cc.EventListenerTouchOneByOne:create()
            listener:setSwallowTouches( true )
	        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	        listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	        listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
            local eventDispatcher = myLayout:getEventDispatcher()
            eventDispatcher:removeEventListenersForTarget(myLayout)
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener, myLayout)
        end
    end
end

function UITalkFly.hide()
    if UITalkFly.layer and UITalkFly.layer:isVisible() then
        UITalkFly.layer:setVisible( false )
        local eventDispatcher = myLayout:getEventDispatcher()
        eventDispatcher:removeEventListenersForTarget(myLayout)
    end
end

function UITalkFly.fShow()
    if UIGuidePeople.guideStep or UIGuidePeople.levelStep then
    else
        if UITalkFly.layer and UITalkFly.curState == 1 then
            UITalkFly.show()
        end
    end
end


function UITalkFly.create()
    UITalkFly:init()
    UIManager.gameScene:addChild( UITalkFly.layer , 1 )
    UITalkFly.curState = cc.UserDefault:getInstance():getIntegerForKey( "showFly"  , 1)
    if UITalkFly.curState ~=1 or UIGuidePeople.guideStep or UIGuidePeople.levelStep then
        UITalkFly.hide()
    end
end

function UITalkFly.isVisible()
    return UITalkFly.layer:isVisible()
end

function UITalkFly.remove()
    if UITalkFly.layer then
        UITalkFly.layer:removeFromParent()
        UITalkFly.layer = nil
    end
    myLayout = nil
end
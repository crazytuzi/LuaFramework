--[[ 送话费 ]]--
local M = class( "bill_layer" , function() return cc.Node:create() end )

function M:ctor( params )
  params = params or {}

  local base_node = popupBox({ 
                               parent = nil , 
                               bg = COMMONPATH .. "5.png" , 
                               createScale9Sprite = { size = cc.size( 440 , 370 ) } , 
                               isMain = true , 
                               close = { scale = 0.7 , offX = 50 , offY = 40 , callback = function() DATA_Activity:refreshIconState() end } , 
                               zorder = 200 , 
                               actionType = 1 ,
                             })
  local size = base_node:getContentSize()

  createSprite( base_node , COMMONPATH .. "shadow3.png" , cc.p( size.width/2 , size.height - 20 ) , cc.p( 0.5 , 1 ) )
  createSprite( base_node , "res/layers/activity/bill.png" , cc.p( size.width/2 , size.height - 20 ) , cc.p( 0.5 , 1 ) )
  
  createScale9Sprite( base_node , COMMONPATH .. "23.png" ,  cc.p(  size.width/2 , size.height/2 )  , cc.size( 380 , 200 ),  cc.p( 0.5 , 0.5 )  )

  createLabel( base_node , game.getStrByKey( "activity_rule" )  , cc.p( 30 , 290 ) , cc.p( 0 , 0 ) , 23 , true , nil , nil , MColor.white , nil , nil , MColor.black , 3 )

  local text1 = createLabel( base_node , game.getStrByKey( "bill_str1" )  , cc.p( 50 , 290 - 30 ) , cc.p( 0 , 1 ) , 20 , true , nil , nil , MColor.yellow_gray , nil , nil , MColor.black , 3 )
  text1:setDimensions( 340 ,0)
  local text2 = createLabel( base_node , game.getStrByKey( "bill_str2" )  , cc.p( 50 , 290 - 80 ) , cc.p( 0 , 1 ) , 20 , true , nil , nil , MColor.yellow_gray , nil , nil , MColor.black , 3 )
  text2:setDimensions( 340 ,0)

  createLabel( base_node , game.getStrByKey( "phone_code" )  , cc.p( 50 , 140  ) , cc.p( 0 , 1 ) , 20 , true , nil , nil , MColor.white , nil , nil , MColor.black , 3 )

  --输入框
  local editeCodeBg = createSprite( base_node , COMMONPATH .. "input_bg.png", cc.p( 150 , 113 ), cc.p( 0 , 0 ) , 20 )
  editeCode = createEditBox(editeCodeBg , nil ,cc.p(10, 0),cc.size( 190 , 30 ) , nil, 22,game.getStrByKey("input_code_tip"))
  editeCode:setAnchorPoint(cc.p(0, 0))
  editeCode:setMaxLength(11)
  editeCode:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
  editeCode:setInputMode( cc.EDITBOX_INPUT_MODE_PHONENUMBER )



  local function confirmFun()
        local tempLayer = popupBox({ 
                         bg = COMMONPATH .. "64.png" , 
                         createScale9Sprite = { size = cc.size( 370 , 160 ) } , 
                         zorder = 200 , 
                         actionType = 1 ,
                       })
        local size = tempLayer:getContentSize()

        createLabel( tempLayer , string.format( game.getStrByKey("phone_confirm") , editeCode:getText() ) , cc.p( size.width/2 , 120 ) , cc.p( 0.5 , 0.5 ) , 25 , true , nil , nil , MColor.white , nil , nil , MColor.black , 3 )

        local resetBtn = createMenuItem( tempLayer , "res/component/button/4.png" , cc.p( size.width/4 , 40 ) , function() tempLayer:close() end )
        createLabel( resetBtn , game.getStrByKey("reset_str")  , cc.p( resetBtn:getContentSize().width/2 , resetBtn:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) , 23 , true , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
        
        local yesBtn = createMenuItem( tempLayer , "res/component/button/5.png" , cc.p( size.width/2 + size.width/4  , 40 ) , function() tempLayer:close() end )
        createLabel( yesBtn , game.getStrByKey("yes_str")  , cc.p( yesBtn:getContentSize().width/2 , yesBtn:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) , 23 , true , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )

  end

  local function getFun()
    local codeValue = editeCode:getText()
    if string.find( codeValue , "[1][34578]%d%d%d%d%d%d%d%d%d" ) then
      confirmFun()
    else
        TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{19000,-1}) )
    end
  end
  local getBtn = createMenuItem( base_node , "res/component/button/10.png" , cc.p( size.width/2 , 40 ) , getFun )
  createLabel( getBtn , game.getStrByKey( "bill_get" )  , cc.p( getBtn:getContentSize().width/2 , getBtn:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) , 30 , true , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )

end

return M










local gameCenterLayer = class("gameCenterLayer", function() return cc.Layer:create() end )

function gameCenterLayer:ctor()
    local bg = createSprite( self, "res/common/helpBg.png", cc.p(display.cx,display.cy), cc.p( 0.5 , 0.5) );  
	registerOutsideCloseFunc(bg, function() removeFromParent(self) end, true)

    local sign = "res/layers/qqMember/qq.png"
    local str = game.getStrByKey("qq_game_center_start")
    if LoginUtils.isLaunchFromWXGameCenter() then
        str = game.getStrByKey("wx_game_center_start")
        sign = "res/layers/qqMember/wx.png"
    end

    local title = createLabel(bg, str, cc.p(278, 280), cc.p(0.5, 0.5), 22, true,nil,nil,MColor.deep_brown)
    createSprite( bg, sign, cc.p( 278 - title:getContentSize().width/2 , 280), cc.p( 1 , 0.5) );  

    createSprite( bg, "res/mainui/subbtns/center1.png", cc.p( 100 , 170), cc.p( 0.5 , 0.5) ); 
    createLabel(bg, game.getStrByKey("qq_game_center_start_text1"), cc.p(100, 84), cc.p(0.5, 0.5), 18, true,nil,nil,MColor.brown_gray)
    createLabel(bg, game.getStrByKey("qq_game_center_start_text2"), cc.p(100, 60), cc.p(0.5, 0.5), 18, true,nil,nil,MColor.brown_gray)

    createSprite( bg, "res/mainui/subbtns/center2.png", cc.p( 260 , 170), cc.p( 0.5 , 0.5) );
    createLabel(bg, game.getStrByKey("qq_game_center_start_text3"), cc.p(260, 84), cc.p(0.5, 0.5), 18, true,nil,nil,MColor.brown_gray)
    createLabel(bg, game.getStrByKey("qq_game_center_start_text4"), cc.p(260, 60), cc.p(0.5, 0.5), 18, true,nil,nil,MColor.brown_gray)
     
    createSprite( bg, "res/mainui/subbtns/center3.png", cc.p( 420 , 170), cc.p( 0.5 , 0.5) );
    createLabel(bg, game.getStrByKey("qq_game_center_start_text3"), cc.p(420, 84), cc.p(0.5, 0.5), 18, true,nil,nil,MColor.brown_gray)
    createLabel(bg, game.getStrByKey("qq_game_center_start_text5"), cc.p(420, 60), cc.p(0.5, 0.5), 18, true,nil,nil,MColor.brown_gray) 
end

return gameCenterLayer
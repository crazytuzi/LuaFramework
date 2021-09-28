local LuntanNode = class("LuntanNode", function() return cc.Node:create() end )

function LuntanNode:ctor(hander)
    if hander ~= nil then
        local wp = hander:convertToWorldSpace(cc.p(40, -10));
        local np = getRunScene():convertToNodeSpace(wp) 
        self:setPosition(np)
    end
    
    cc.SpriteFrameCache:getInstance():addSpriteFramesWithFileEx("res/mainui/mainui@0.plist", false, false)
	
	--local size = cc.size(480,105)
    local size = cc.size(210,105)
    local lastTask = DATA_Mission.getLastTaskData();
    if lastTask and lastTask.q_taskid ~= 10000 then
        --size = cc.size(570,105)
        size = cc.size(300,105)
    end

	local bg = createScale9Sprite(self,"res/common/scalable/main1.png",cc.p(0,0),size,cc.p(0.5,1))
    local arrow = createSprite(self,"res/common/scalable/main0.png",cc.p(0,-2),cc.p(0.5,0))
    arrow:setFlippedY(true)

    --传世宝典
    local offx = 0
    if lastTask and lastTask.q_taskid ~= 10000 then
        createTouchItem(bg,{"mainui/topbtns/11.png"},cc.p(60,52),function() __GotoTarget( { ru = "a122" } ); removeFromParent(self) end)
        offx = 90
    end
	
    --游戏论坛
    createTouchItem(bg,{"mainui/topbtns/12.png"},cc.p(60 + offx,52), function() sdkOpenUrl("http://bbs.g.qq.com/forum.php?mod=forumdisplay&fid=57443&ADTAG=game.app.cqsj"); removeFromParent(self) end)

    if LoginUtils.isQQLogin() then
        --兴趣部落
        createTouchItem(bg,{"mainui/topbtns/19.png"},cc.p(150 + offx,52),function() sdkOpenUrl("http://buluo.qq.com/p/barindex.html?bid=322962"); removeFromParent(self) end)
    else
        --圈子
        createTouchItem(bg,{"mainui/topbtns/16.png"},cc.p(150 + offx,52),function() sdkOpenUrl("http://game.weixin.qq.com/cgi-bin/h5/static/community/club_index.html?jsapi=1&appid=wxebd64e021cb2a6d2&ssid=1?#wechat_redirect"); removeFromParent(self) end)
    end

    --客服
    --createTouchItem(bg,{"mainui/topbtns/15.png"},cc.p(240 + offx,52),function() sdkOpenUrl("http://buluo.qq.com/p/barindex.html?bid=322962"); removeFromParent(self) end)

    --微官网
    --createTouchItem(bg,{"mainui/topbtns/17.png"},cc.p(330 + offx,52),function() sdkOpenUrl("http://buluo.qq.com/p/barindex.html?bid=322962"); removeFromParent(self) end)

    --心悦特权
    --createTouchItem(bg,{"mainui/topbtns/18.png"},cc.p(420 + offx,52),function() sdkOpenUrl("http://buluo.qq.com/p/barindex.html?bid=322962"); removeFromParent(self) end)
	
    
    local closeFunc = function()
		self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.0), cc.RemoveSelf:create()))
	end
	registerOutsideCloseFunc(bg, closeFunc, true)

	self:setScale(0.0)
	self:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 1))))
end

return LuntanNode
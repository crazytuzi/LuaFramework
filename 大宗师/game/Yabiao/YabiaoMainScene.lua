--
-- Author: Daneil 
-- Date: 2015-01-15 15:33:35
--
local Zorder = 12002
require("game.Biwu.BiwuFuc")
require("game.Yabiao.YabiaoConst")
local data_huodong_huodong = require("data.data_huodong_huodong")
require("game.Yabiao.YabiaoFuc")
local YabiaoMainScene = class("YabiaoMainScene", function()
    return require("game.BaseScene").new({
        bgImage = "ui_common/common_bg.png",
    })

end)

function YabiaoMainScene:ctor(param)
	self:loadRes()
	self:setUpView()
end

function YabiaoMainScene:setUpView()
	self:setUpBottomView()
	self:setUpMapView()
end

function YabiaoMainScene:setUpMapView()

	local scrollView = CCScrollView:create()
	scrollView:setViewSize(cc.size(display.width, display.height - self:getTopHeight() - self:getBottomHeight()))
	scrollView:setPosition(cc.p(0,self:getBottomHeight()))
	scrollView:setDirection(kCCScrollViewDirectionVertical)
	scrollView:setClippingToBounds(true)
	scrollView:setBounceable(false)
	self:addChild(scrollView)
	scrollView:setAnchorPoint(cc.p(0,0))  
	local content = CCNode:create()
    scrollView:setContainer(content) 
   

    --初始化背景界面
    local ccbiName = data_huodong_huodong[6].ccb_bg..".ccbi"
    local proxy = CCBProxy:create()
	self._node = {}
	local node = CCBuilderReaderLoad("ccbi/battle_bg/"..ccbiName, proxy, self._node)
    node:setPosition(display.width * 0.5, 0)

    for k,v in pairs(self._node) do
    	print(k,v)
    	print(v:getContentSize().height)
    end


    content:addChild(node)
    content:setContentSize(cc.size(display.width,1600))
    mapHeight = 1600 - 300
    titleHeight = self:getTopHeight()
    --初始化
    initTimeGroup()
    self._gameController = require("game.Yabiao.YabiaoController").new(
	    	{ 
	    		map = content,
	    		mainscene = self
	    	}
		)
    self._gameController:retain()

    
    --返回按钮
    local backBtn = display.newSprite("#back_btn.png")
    backBtn:setPosition(display.width * 0.9,self:getContentSize().height * 0.88)
    self:addChild(backBtn)
	addTouchListener(backBtn, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            self:close()
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    --押镖按钮
    self.yabiaoBtn = display.newSprite("#yabiao_btn.png")
    self.yabiaoBtn:setPosition(display.width * 0.2,self:getContentSize().height * 0.18)
    self:addChild(self.yabiaoBtn)
	

    --刷新按钮
    self.shuaxinBtn = display.newSprite("#shuaxin_btn.png")
    self.shuaxinBtn:setPosition(display.width * 0.8,self:getContentSize().height * 0.18)
    self:addChild(self.shuaxinBtn)
	

    --按钮上边的文字
    self.countDownLabel  = ui.newTTFLabel({ text = "", 
											size = 25, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = FONT_COLOR.WHITE,
									        font = FONTS_NAME.font_btns })
    self.countDownLabel:setPosition(cc.p(self.shuaxinBtn:getContentSize().width / 2,self.shuaxinBtn:getContentSize().height / 2))
    self.countDownLabel:setAnchorPoint(cc.p(0.5,0.5))
    self.shuaxinBtn:addChild(self.countDownLabel)


end


function YabiaoMainScene:onEnter()
	self:regNotice()
end

function YabiaoMainScene:onExit()
	self:unregNotice()
	self:releaseRes()
	if self._gameController then
    	self._gameController:clearTimer()
    end
end

function YabiaoMainScene:setUpBottomView()
	PostNotice(NoticeKey.UNLOCK_BOTTOM) 
	self:setBottomBtnEnabled(true)
	ResMgr.removeBefLayer()
end

function YabiaoMainScene:loadRes()
	display.addSpriteFramesWithFile("ui/ui_yabiao_common.plist", "ui/ui_yabiao_common.png")
	display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
	display.addSpriteFramesWithFile("ui/ui_guild_common_bg.plist", "ui/ui_guild_common_bg.png")
end

function YabiaoMainScene:releaseRes()
	display.removeSpriteFramesWithFile("ui/ui_yabiao_common.plist", "ui/ui_yabiao_common.png")
	display.removeSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
	display.removeSpriteFramesWithFile("ui/ui_guild_common_bg.plist", "ui/ui_guild_common_bg.png")
end

function YabiaoMainScene:close()
    if self._gameController then
    	self._gameController:clearTimer()
    end
    self._gameController = nil
	self:releaseRes()
	--回到活动界面
    GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
end

return YabiaoMainScene

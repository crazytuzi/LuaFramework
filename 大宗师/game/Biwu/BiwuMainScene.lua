--
-- Author: Daneil 
-- Date: 2015-01-15 15:33:35
--
local Zorder = 12002
local RADIO_BUTTON_IMAGES = {
    biwu = {
        off          = "#biwu_n.png",
        off_pressed  = "#biwu_n.png",
        off_disabled = "#biwu_n.png",
        on           = "#biwu_p.png",
        on_pressed   = "#biwu_p.png",
        on_disabled  = "#biwu_p.png",
    },
    chouren = {
        off          = "#chouren_n.png",
        off_pressed  = "#chouren_n.png",
        off_disabled = "#chouren_n.png",
        on           = "#chouren_p.png",
        on_pressed   = "#chouren_p.png",
        on_disabled  = "#chouren_p.png",
    },
    duihuan = {
        off          = "#duihuan_n.png",
        off_pressed  = "#duihuan_n.png",
        off_disabled = "#duihuan_n.png",
        on           = "#duihuan_p.png",
        on_pressed   = "#duihuan_p.png",
        on_disabled  = "#duihuan_p.png",
    },
    tianbang = {
        off          = "#tianbang_n.png",
        off_pressed  = "#tianbang_n.png",
        off_disabled = "#tianbang_n.png",
        on           = "#tianbang_p.png",
        on_pressed   = "#tianbang_p.png",
        on_disabled  = "#tianbang_p.png",
    }
     
}
require("game.Biwu.BiwuController")
require("game.Biwu.BiwuFuc")
local biwuResManager = require("game.Biwu.BiwuResManager")
local BiwuMainScene = class("BiwuMainScene", function()
    return require("game.BaseScene").new({
        bgImage = "ui_common/common_bg.png",
    })

end)

function BiwuMainScene:ctor(param)
	self._currentLayer = nil
	self:loadRes()
	self:initSize()
	if param and param.tabindex then
		self:initTopRadios(param.tabindex)
		self:performWithDelay(function ()
	    		show_tip_label("本次挑战获得积分:"..param.extraMsg)
	    end,0.1)
	else
		self:initTopRadios()
	end
	
	PostNotice(NoticeKey.UNLOCK_BOTTOM) 
	self:setBottomBtnEnabled(true)
	self._rootnode["bottomNode"]:setZOrder(Zorder + 100)
	self._rootnode["bottomNode"]:setTouchEnabled(true)
	ResMgr.removeBefLayer()

	--嵌在ccbi里边的  所以必须copy 重新调整zorder
	local buttom = clone(self._rootnode["bottomNode"])
	buttom:retain()
	self._rootnode["bottomNode"]:removeFromParent()
	self:addChild(buttom)


end

function BiwuMainScene:initSize()
	
	self._radiosTopOffset = 120     --标签页离上部距离
	self._contentSize     = cc.size(display.width,display.height 
		- self:getTopHeight() 
		- self._radiosTopOffset
		- self:getBottomHeight())

end

function BiwuMainScene:initMainButtomBtns()
	
end

function BiwuMainScene:initTopRadios(index)
	local group
    group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
        :addButton(cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES.biwu)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES.chouren)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES.duihuan)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES.tianbang)
            :align(display.LEFT_CENTER))
        :onButtonSelectChanged(function(event)
            for i = 1,group:getButtonsCount() do
                group:getButtonAtIndex(i):setZOrder(group:getButtonsCount() + i)
            end
            group:getButtonAtIndex(event.selected):setZOrder(10)
            self:changePage(event.selected)
        end)
        :setButtonsLayoutMargin(0,-25,0,0)
        :addTo(self,Zorder + 1000)
    group:setAnchorPoint(cc.p(0,0)) 
    group:setPosition(cc.p(0 , display.height - self:getTopHeight() - self._radiosTopOffset))   
    --默认选中比武
    group:getButtonAtIndex(index or 1):setButtonSelected(true)

	--返回按钮
    local backBtn = display.newSprite("#hero_list_back.png")
    
	addTouchListener(backBtn, function (sender,eventType)
    	if eventType == EventType.began then
    		backBtn:setScale(0.9)
    	elseif eventType == EventType.ended then
    		backBtn:setScale(1.0)
            --回到活动界面
            GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    	elseif eventType == EventType.cancel then
    		backBtn:setScale(1.0)
    	end
    end)

	local marginTop,marginRight = 10,10
    backBtn:setPosition(cc.p(display.width - marginRight,display.height - self:getTopHeight() - marginTop))
    backBtn:setAnchorPoint(cc.p(1,1))
    self:addChild(backBtn,Zorder)
	--周末活动结束显示
    self.titleLabel  = ui.newTTFLabelWithShadow({  text = "比武时间：周一8:00到周六23:00", 
											size = 22, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = FONT_COLOR.YELLOW,
									        shadowColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy })
    self.titleLabel:setPosition(cc.p(marginRight + 10,display.height - self:getTopHeight() * 1.5))
    self:addChild(self.titleLabel,10)
    self.titleLabel:setVisible(true)

end

function BiwuMainScene:changePage(index)
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
	if self._currentLayer then
		self._currentLayer:remove()
		self._currentLayer = nil
	end
	if index == 1 	  then  -- 比武界面
		self._currentLayer = require("game.Biwu.BiwuHeroLayer").new({size = self._contentSize})
	elseif index == 2 then  -- 仇人
		self._currentLayer = require("game.Biwu.BiwuEnemyLayer").new({size = self._contentSize})
	elseif index == 3 then 	-- 兑换
		self._currentLayer = require("game.Biwu.BiwuDuihuanLayer").new({size = self._contentSize})
	elseif index == 4 then  -- 天榜 
		self._currentLayer = require("game.Biwu.BiwuTianbangLayer").new({size = self._contentSize})
	end
	self._currentLayer:setPosition(cc.p(0,self:getBottomHeight()))
	self:addChild(self._currentLayer,Zorder)
end

function BiwuMainScene:onEnter()
	self:regNotice()
end

function BiwuMainScene:onExit()
	if self._currentLayer then
		self._currentLayer:remove()
		self._currentLayer = nil
	end
	self:unregNotice()
	self:releaseRes()
end

function BiwuMainScene:loadRes()
	display.addSpriteFramesWithFile("ui/biwu_main.plist", "ui/biwu_main.png")
	display.addSpriteFramesWithFile("ui/ui_herolist_v2.plist", "ui/ui_herolist_v2.png")
	display.addSpriteFramesWithFile("ui/ui_jingmai.plist", "ui/ui_jingmai.png")
	display.addSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	display.addSpriteFramesWithFile("ui/ui_arena.plist", "ui/ui_arena.png")
	display.addSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
	display.addSpriteFramesWithFile("ui/ui_friend.plist", "ui/ui_friend.png")
	display.addSpriteFramesWithFile("ui/ui_zhenrong.plist", "ui/ui_zhenrong.png")
	display.addSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
    display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
    display.addSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
    display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png") 
    display.addSpriteFramesWithFile("ui/ui_spirit.plist", "ui/ui_spirit.png")
    display.addSpriteFramesWithFile("ui/ui_challenge.plist", "ui/ui_challenge.png")
    display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.png")
    display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
end

function BiwuMainScene:releaseRes()
	display.removeSpriteFramesWithFile("ui/biwu_main.plist", "ui/biwu_main.png")
	display.removeSpriteFramesWithFile("ui/ui_herolist_v2.plist", "ui/ui_herolist_v2.png")
	display.removeSpriteFramesWithFile("ui/ui_jingmai.plist", "ui/ui_jingmai.png")
	display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	display.removeSpriteFramesWithFile("ui/ui_arena.plist", "ui/ui_arena.png")
	display.removeSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
	display.removeSpriteFramesWithFile("ui/ui_friend.plist", "ui/ui_friend.png")
	display.removeSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
    display.removeSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
    display.removeSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
    display.removeSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png") 
    display.removeSpriteFramesWithFile("ui/ui_spirit.plist", "ui/ui_spirit.png")
    display.removeSpriteFramesWithFile("ui/ui_challenge.plist", "ui/ui_challenge.png")
    display.removeSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.png")
    display.removeSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
end
return BiwuMainScene

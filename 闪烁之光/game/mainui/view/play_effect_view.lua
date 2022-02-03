-- --------------------------------------------------------------------
-- 黑屏播放特效界面 仅播放一次
-- 
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: shuwen(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-08-03
-- --------------------------------------------------------------------

PlayEffectView = PlayEffectView or BaseClass(BaseView)

function PlayEffectView:__init( ctrl,effect_name, finish_call,isgore_playing, ignore_battle, delay_play,action_name )
	self.ctrl = ctrl
	self.win_type = WinType.Full

	self.effect_name = effect_name
	self.x = x
	self.y = y 
	self.finish_call = finish_call
	self.isgore_playing = isgore_playing
	self.ignore_battle = ignore_battle
	self.delay_play = delay_play
	self.action_name = action_name
	self.layout_name = "mainui/play_effect_view"
end

function PlayEffectView:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.main_panel = self.root_wnd:getChildByName("main_panel")
end

function PlayEffectView:open(index)
    BaseView.open(self)
	
	self:createEffect()
end

function PlayEffectView:createEffect()
	local function animationCompleteFunc(event)
		if event.animation == self.action_name then
			if self.body then
				self.body:clearTracks()
				self.body:runAction(cc.RemoveSelf:create(true))
			end
			delayOnce(function()
				if self.finish_call then
					self.finish_call(self)
				end
				self.ctrl:openPlayEffectView(false)
            end,0.1)
		end
	end	
	self.body = createEffectSpine(self.effect_name, cc.p(self.main_panel:getContentSize().width/2, self.main_panel:getContentSize().height/2), cc.p(0.5, 0.5), true, self.action_name, nil, nil)
	self.main_panel:addChild(self.body)
	self.body:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE)
end


function PlayEffectView:register_event()
end

function PlayEffectView:close_callback()
    self.ctrl:openPlayEffectView(false)
end
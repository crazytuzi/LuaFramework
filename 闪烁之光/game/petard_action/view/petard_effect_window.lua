--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-09-20 15:40:48
-- @description    : 
		-- 烟花效果界面
---------------------------------
local _controller = PetardActionController:getInstance()
local _model = _controller:getModel()

PetardEffectWindow = class("PetardEffectWindow", function()
    return ccui.Layout:create()
end)

function PetardEffectWindow:ctor()
    self:createRootWnd()
end

function PetardEffectWindow:createRootWnd(  )
	self.main_size = cc.size(SCREEN_WIDTH, display.height)
    self:setContentSize(self.main_size)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setContentSize(self.main_size)
    self.root_wnd:setPosition(self.main_size.width * 0.5, self.main_size.height * 0.5)
    self:addChild(self.root_wnd)

    ViewManager:getInstance():addToLayerByTag(self, ViewMgrTag.MSG_TAG)
end

function PetardEffectWindow:openView( num)
    self.use_item_num = num or 1
	self:setData()
    
    -- 特效播完则关闭界面
    delayRun(self.root_wnd, 1.2, function (  )
        local meteor_bid_cfg = Config.HolidayPetardData.data_const["meteor_bid"]
        if meteor_bid_cfg then
            PetardActionController:getInstance():sender27001(meteor_bid_cfg.val, self.use_item_num)
        end
        _controller:openPetardEffectWindow(false)
    end)
end

function PetardEffectWindow:setData(  )
	self:handleLeftEmptyEffect(true)
end

function PetardEffectWindow:handleLeftEmptyEffect( status )
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.root_wnd) and self.play_effect == nil then
            self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[341], cc.p(self.main_size.width*0.5, self.main_size.height*0.5), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.root_wnd:addChild(self.play_effect)
        end
    end
end

function PetardEffectWindow:DeleteMe(  )
    self:handleLeftEmptyEffect(false)
	self:removeAllChildren()
    self:removeFromParent()
end


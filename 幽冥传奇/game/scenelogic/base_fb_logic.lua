-------------------------------------------
--基础副本逻辑,统一处理一些副本活动类通用的逻辑
--@author bzw
--------------------------------------------
BaseFbLogic = BaseFbLogic or BaseClass(BaseSceneLogic)
function BaseFbLogic:__init()
	self.fuben_id = 0
	self.root_node = nil
end

function BaseFbLogic:__delete()
end

function BaseFbLogic:Enter(old_scene_type, new_scene_type)	
	BaseSceneLogic.Enter(self, old_scene_type, new_scene_type)
	self:CreatOnFubenEff()

	self.time = 0.5

	if self.flush_timer then
		GlobalTimerQuest:CancelQuest(self.flush_timer)
		self.flush_timer = nil
	end

	self.flush_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind1(self.OnFlushCd, self), 1, 3)
end

--退出
function BaseFbLogic:Out()
	BaseSceneLogic.Out(self)
end

function BaseFbLogic:SetFubenId(fuben_id)
	self.fuben_id = fuben_id
end

function BaseFbLogic:GetFubenId()
	return self.fuben_id
end

-- 创建进入副本动画
function BaseFbLogic:CreatOnFubenEff()
	if nil ~= self.root_node then return end
    self.root_node = cc.Node:create()
	HandleRenderUnit:AddUi(self.root_node, COMMON_CONSTS.ZORDER_ONFUBEN, COMMON_CONSTS.ZORDER_ONFUBEN)

    -- self.view = XUI.CreateLayout(692, 385, 1385, 768)
    -- self.root_node:addChild(self.view, 800)
    -- self.view:setClippingEnabled(true)
    local screen_w = HandleRenderUnit:GetWidth()
 	local screen_h = HandleRenderUnit:GetHeight()
    local size = self.root_node:getContentSize()
    self.left_door = XUI.CreateImageView(screen_w/2, screen_h, ResPath.GetBigPainting("door_left_img3", false))
    self.left_door:setTouchEnabled(true)
    self.left_door:setAnchorPoint(0.5, 1)
    self.left_door:setIsHittedScale(false)
    self.right_door = XUI.CreateImageView(screen_w/2, screen_h/2, ResPath.GetBigPainting("door_right_img3", false))
    self.right_door:setTouchEnabled(true)
    self.right_door:setAnchorPoint(0.5, 1)
    self.right_door:setIsHittedScale(false)
    self.root_node:addChild(self.left_door, 10)
    self.root_node:addChild(self.right_door, 10)


    RenderUnit.PlayEffectOnce(1149, self.root_node, 999, screen_w / 2, screen_h / 2 - 15, true, nil, FrameTime.Effect)
    RenderUnit.PlayEffectOnce(1150, self.root_node, 999, screen_w / 2, screen_h / 2 + 24, true, nil, FrameTime.Effect*2)
end

function BaseFbLogic:OnFlushCd()
	if self.time == nil then
		return 
	end
	self.time = self.time - 1 
	if self.time <= 0 then

		local screen_w = HandleRenderUnit:GetWidth()
 		local screen_h = HandleRenderUnit:GetHeight()
	    local end_func = cc.CallFunc:create(BindTool.Bind(self.OnDoorOpenEnd, self))
	    self.left_door:runAction(cc.MoveTo:create(1, cc.p(screen_w/2, screen_h + screen_h / 2)))
	    self.right_door:runAction(cc.Sequence:create(cc.MoveTo:create(2, cc.p(screen_w/2, - screen_h / 2)), end_func))
		
		if self.flush_timer then
			GlobalTimerQuest:CancelQuest(self.flush_timer)
			self.flush_timer = nil
		end
		return
	end
end

function BaseFbLogic:OnDoorOpenEnd()
	-- local size = self.root_node:getContentSize()
	local screen_w = HandleRenderUnit:GetWidth()
 	local screen_h = HandleRenderUnit:GetHeight()
    self.left_door:stopAllActions()
    self.right_door:stopAllActions()

    self.left_door:setPosition(screen_w/2, screen_h)
    self.right_door:setPosition(screen_w/2, screen_h/2)
    self.root_node:setVisible(false)
end
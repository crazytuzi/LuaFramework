MovieGuideView = MovieGuideView or BaseClass()

function MovieGuideView:__init()
	self.root_node = nil
	self.global_width = 0
	self.timer = nil
end

function MovieGuideView:__delete()
end

function MovieGuideView:Open()
	if nil == self.root_node then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

		self.global_width = screen_w

		self.root_node = cc.Node:create()
		self.root_node:setAnchorPoint(0,0)
		HandleRenderUnit:AddUi(self.root_node, COMMON_CONSTS.ZORDER_MOVIE_GUIDE, COMMON_CONSTS.ZORDER_MOVIE_GUIDE)

		local layout = XLayout:create()
		layout:setBackGroundColor(COLOR3B.BLACK)
		layout:setBackGroundColorOpacity(127)
		layout:setAnchorPoint(0,0)
		layout:setContentWH(screen_w, screen_h)
		XUI.AddClickEventListener(layout, BindTool.Bind(self.OnClickLayout, self))
		self.root_node:addChild(layout)

		self.top_layout = XLayout:create()
		self.top_layout:setAnchorPoint(0,1)
		self.top_layout:setPosition(0,screen_h)
		self.top_layout:setContentWH(screen_w, 150)
		self.top_layout:setBackGroundColor(COLOR3B.BLACK)
		self.root_node:addChild(self.top_layout)

		self.bottom_layout = XLayout:create()
		self.bottom_layout:setAnchorPoint(0,0)
		self.bottom_layout:setPosition(0,0)
		self.bottom_layout:setContentWH(screen_w, 150)
		self.bottom_layout:setBackGroundColor(COLOR3B.BLACK)
		self.root_node:addChild(self.bottom_layout)

		self.left_img = XUI.CreateImageView(0,0,ResPath.GetRoleHead("big_1"),false)
		self.left_img:setAnchorPoint(0.5,0)
		
		self.bottom_layout:addChild(self.left_img)

		self.right_img = XUI.CreateImageView(0,0,ResPath.GetRoleHead("big_1"),false)
		self.right_img:setAnchorPoint(0.5,0)
		self.right_img:setScaleX(-1)
		
		self.bottom_layout:addChild(self.right_img)

		self.name_text = XUI.CreateText(0,100,screen_w,30)
		self.name_text:setAnchorPoint(0,0)
		self.name_text:setColor(COLOR3B.YELLOW)
		self.bottom_layout:addChild(self.name_text)

		self.rich_text = XUI.CreateRichText(0,0,600,100)
		self.rich_text:setAnchorPoint(0.5,1)
		self.rich_text:setPosition(screen_w * 0.5,100)
		self.bottom_layout:addChild(self.rich_text)
	end	
	self.left_img:setPosition(-128,0)
	self.right_img:setPosition(self.global_width + 128,0)
end	

function MovieGuideView:DoStep(step)
	RichTextUtil.ParseRichText(self.rich_text,step.say)
	
	self.left_img:stopAllActions()
	self.right_img:stopAllActions()

	local face_id = 1
	if step.faceId == -1 then
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)

		face_id = (prof - 1) * 2 + sex + 1
		--print(prof,sex,face_id)
		self.name_text:setString(RoleData.Instance:GetAttr("name"))
	else
		face_id = step.faceId
		self.name_text:setString(step.whoSay)
	end	

	if step.facePos == 0 then
		self.left_img:loadTexture(ResPath.GetRoleHead("big_" .. face_id))
		local move_to1 = cc.MoveTo:create(0.2, cc.p(128, 0))
		local move_to2 = cc.MoveTo:create(0.2, cc.p(self.global_width + 128, 0))
		self.left_img:runAction(move_to1)
		self.right_img:runAction(move_to2)
	else
		self.right_img:loadTexture(ResPath.GetRoleHead("big_" .. face_id))
		local move_to1 = cc.MoveTo:create(0.2, cc.p(-128, 0))
		local move_to2 = cc.MoveTo:create(0.2, cc.p(self.global_width - 128, 0))
		self.left_img:runAction(move_to1)
		self.right_img:runAction(move_to2)
	end	

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end	
	self.timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnNextClick,self),5)
end	

function MovieGuideView:OnNextClick()
	self:OnClickLayout()
end	

function MovieGuideView:Close()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end	
	if nil ~= self.root_node then
		NodeCleaner.Instance:AddNode(self.root_node)
		self.root_node = nil
	end
end

function MovieGuideView:OnClickLayout()
	MovieGuideCtrl.Instance:OnClick()
end	
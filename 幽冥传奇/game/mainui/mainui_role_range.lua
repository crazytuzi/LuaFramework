--角色视野
MainuiRoleRange = MainuiRoleRange or BaseClass()
function MainuiRoleRange:__init()
end	

function MainuiRoleRange:__delete()
end

function MainuiRoleRange:Init(mt_layout_root)
	local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
	self.mt_layout_root = MainuiMultiLayout.CreateMultiLayout(0, 0, cc.p(0, 0), cc.size(screen_w,screen_h), mt_layout_root, -2)

	self.mt_layout_root:setVisible(false)

	GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChange,self))
	GlobalEventSystem:Bind(SceneEventType.SCENE_ROLE_RANGE_CHANGE, BindTool.Bind(self.OnRangeChange,self))
end	

function MainuiRoleRange:CreateMask()
	if not self.layout_center then
		self.layout_center = XUI.CreateImageViewScale9(0,0,100,100,ResPath.GetBigPainting("role_range_center"),false,cc.rect(2,2,189,93))
		self.mt_layout_root:TextureLayout():addChild(self.layout_center)

		self.layout_left = self:CreateBlackLayout()
		self.layout_right = self:CreateBlackLayout()
		self.layout_top = self:CreateBlackLayout()
		self.layout_bottom = self:CreateBlackLayout()
	end
end	

function MainuiRoleRange:DeleteMask()
	if self.layout_center then
		self.layout_center:removeFromParent()
		self.layout_center = nil

		self.layout_left:removeFromParent()
		self.layout_left = nil
		self.layout_right:removeFromParent()
		self.layout_right = nil
		self.layout_top:removeFromParent()
		self.layout_top = nil
		self.layout_bottom:removeFromParent()
		self.layout_bottom = nil
	end	
end	

function MainuiRoleRange:OnRangeChange()
	local range = Scene.Instance.check_all_hide_range
	local default_range_interval = range / 3
	self:SetCenterRect(960 * default_range_interval,480 * default_range_interval, range)
end	

function MainuiRoleRange:OnSceneChange()
	if Scene.Instance.is_check_all_hide then
		self:CreateMask()
		self:OnRangeChange()
		self.mt_layout_root:setVisible(true)
	else	
		self:DeleteMask()
		self.mt_layout_root:setVisible(false)
	end	
end	

function MainuiRoleRange:SetCenterRect(w, h, range)
	if self.layout_center then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

		local x = (screen_w - w) * 0.5
		local y = (screen_h - h) * 0.5
		
		self.layout_left:setPosition(0, 0)
		self.layout_left:setContentWH(x, screen_h)

		self.layout_right:setPosition(x + w, 0)
		self.layout_right:setContentWH(screen_w - (x + w), screen_h)

		self.layout_top:setPosition(x, y + h)
		self.layout_top:setContentWH(w, screen_h - (y + h))

		self.layout_bottom:setPosition(x, 0)
		self.layout_bottom:setContentWH(w, y)

		self.layout_center:setPosition(screen_w * 0.5, screen_h * 0.5 )
		self.layout_center:setContentWH(w, h)
	end
end	

function MainuiRoleRange:CreateBlackLayout()
	local layout = XLayout:create()
	layout:setBackGroundColor(COLOR3B.BLACK)
	layout:setBackGroundColorOpacity(205)
	self.mt_layout_root:TextureLayout():addChild(layout)
	return layout
end
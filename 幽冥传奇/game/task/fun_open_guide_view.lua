FunOpenGuideView = FunOpenGuideView or BaseClass(BaseView)

function FunOpenGuideView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		"res/xui/fun_open.png"
	}
	self.config_tab = {
		{"fun_open_ui_cfg", 1, {0}},
		--{"common_ui_cfg", 3, {0}},
	}
end

function FunOpenGuideView:__delete()
	-- body
end

function FunOpenGuideView:ReleaseCallBack()
	if self.ui_open_list then
		self.ui_open_list:DeleteMe()
		self.ui_open_list = nil 
	end

	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil 
	end
end

function FunOpenGuideView:LoadCallBack()
	self:CreateList()
	self:CreateEffectShow()
	self.select_data = nil
	self.select_index =1

	 XUI.AddClickEventListener(self.node_t_list.btn_open.node, BindTool.Bind1(self.OnOpenView, self), true)
	  XUI.AddClickEventListener(self.node_t_list.img_left.node, BindTool.Bind1(self.OnMoveLeft, self), true)
	   XUI.AddClickEventListener(self.node_t_list.img_right.node, BindTool.Bind1(self.OnMoveRight, self), true)
end

function FunOpenGuideView:OpenCallBack()
	-- body
end

function FunOpenGuideView:CreateEffectShow()
	if nil == self.effect_show1 then
		local ph = self.ph_list.ph_effect
	 	self.effect_show1 = AnimateSprite:create()
	 	self.effect_show1:setPosition(ph.x + 15, ph.y + 5)
	 	self.node_t_list.layout_fun_open.node:addChild(self.effect_show1, 999)
	end
end

function FunOpenGuideView:CreateList( ... )
	if nil == self.ui_open_list  then
		local ph = self.ph_list.ph_list_view
		self.ui_open_list  = ListView.New()
		local grid_node = self.ui_open_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, UIOpenListRender, nil, nil, self.ph_list.ph_list_item)
		self.node_t_list.layout_fun_open.node:addChild(self.ui_open_list:GetView(), 100)
		self.ui_open_list:GetView():setAnchorPoint(0, 0)
		self.ui_open_list:SetMargin(2)
		self.ui_open_list:SetItemsInterval(10)
		self.ui_open_list:SetJumpDirection(ListView.Top)

		self.ui_open_list:SetSelectCallBack(BindTool.Bind1(self.SelectCallBack,self))
	end
end

function FunOpenGuideView:OnMoveRight()
	if self.select_index < #ClientFunOpenShowUiCfg then
		self.select_index = self.select_index + 1
		self.ui_open_list:SelectIndex(self.select_index)
		self.ui_open_list:SetSelectItemToLeft(self.select_index)
	end
	self:SetVisibleShow()
end

function FunOpenGuideView:OnMoveLeft()
	if self.select_index > 1 then
		self.select_index = self.select_index - 1
		self.ui_open_list:SelectIndex(self.select_index)
		self.ui_open_list:SetSelectItemToLeft(self.select_index)
	end
	self:SetVisibleShow()
end

function FunOpenGuideView:SelectCallBack(item)
	if item == nil or item:GetData() == nil then
		return
	end
	self.select_data = item:GetData()
	self.select_index = item:GetIndex()
	self:FlushShow()
	self:SetVisibleShow()
end


function FunOpenGuideView:SetVisibleShow( ... )
	self.node_t_list.img_left.node:setVisible(self.select_index ~= 1)
	self.node_t_list.img_right.node:setVisible(self.select_index ~= #ClientFunOpenShowUiCfg)
end


function FunOpenGuideView:FlushShow()
	if self.select_data then
		local effect_id = self.select_data.effect_id
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
		self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)

		self.node_t_list.img_desc1.node:loadTexture(ResPath.GetFunOpenPath("desc_"..self.select_data.res_desc_id))
	end
end

function FunOpenGuideView:OnOpenView()
	if self.select_data then
		if GameCondMgr.Instance:GetValue(self.select_data.opne_cond) then
			ViewManager.Instance:OpenViewByStr(self.select_data.open_view)
		else
			local cfg = GameCond[self.select_data.opne_cond]
			local tips = cfg and cfg.Tip or ""
			SysMsgCtrl.Instance:FloatingTopRightText(tips)
		end
	end
end


function FunOpenGuideView:ShowIndexCallBack()
	self:Flush(index)
end

function FunOpenGuideView:OnFlush(parmat)
	local data = ClientFunOpenShowUiCfg
	self.ui_open_list:SetDataList(data)
	self.ui_open_list:SelectIndex(self.select_index)
	self:SetVisibleShow() 
end

UIOpenListRender = UIOpenListRender or BaseClass(BaseRender)
function UIOpenListRender:__init()
	-- body
end

function UIOpenListRender:__delete()
	-- body
end

function UIOpenListRender:CreateChild()
	BaseRender.CreateChild(self)
end

function UIOpenListRender:OnFlush()
	if self.data == nil then
		return
	end
	self.node_tree.img_name.node:loadTexture(ResPath.GetFunOpenPath("name_"..self.data.name_id))
	self.node_tree.img_icon.node:loadTexture(ResPath.GetFunOpenPath("res_"..self.data.res_id))
	local cond = GameCond[self.data.opne_cond]
	if cond then
		local text = ""
		if cond.RoleCircle and cond.RoleCircle > 0 then
			text = text..cond.RoleCircle.."转"
		end
		if cond.RoleLevel and cond.RoleLevel > 0 then
			text = text..cond.RoleLevel.."级"
		end
		
		RichTextUtil.ParseRichText(self.node_tree.text_condition.node,text, 20, COLOR3B.GREEN)
		XUI.RichTextSetCenter(self.node_tree.text_condition.node)
	end
end

function UIOpenListRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width/2, size.height/2+10, ResPath.GetFunOpenPath("cell_eff"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 999)
end
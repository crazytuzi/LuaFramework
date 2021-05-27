QieGeTipView = QieGeTipView or BaseClass(BaseView)

function QieGeTipView:__init()
	self.is_any_click_close = true		
	self.is_model = false
	self.texture_path_list = {
		'res/xui/qiege.png',
		
		}	
	self.config_tab = {
		{"qiege_ui_cfg", 4, {0}},
		
	}
	self.data = nil
end

function QieGeTipView:__delete( ... )
	-- body
end

function QieGeTipView:LoadCallBack(loaded_times, index)

	self:CreateCell()

	XUI.AddClickEventListener(self.node_t_list.btn_go_shen_bin.node, BindTool.Bind1(self.GoToSehnBinPanel, self), true)
end

function QieGeTipView:CreateCell( ... )
	-- if self.shen_bin_cell == nil then
	-- 	local ph = self.ph_list.ph_cell
	-- 	self.shen_bin_cell = ShenBinCell.New()
	-- 	self.shen_bin_cell:GetView():setPosition(ph.x, ph.y)
	-- 	self.node_t_list.layout_upgrade_sucess.node:addChild(self.shen_bin_cell:GetView(), 99)
	-- end

	if nil == self.effect_show1 then
		local ph = self.ph_list.ph_cell
	 	self.effect_show1 = AnimateSprite:create()
	 	self.effect_show1:setPosition(ph.x + 15, ph.y + 50)
	 	 self.node_t_list.layout_upgrade_sucess.node:addChild(self.effect_show1, 999)
	end
	

end

function QieGeTipView:ReleaseCallBack( ... )


	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil 
	end
end

function QieGeTipView:OpenCallBack()
	-- body
end

function QieGeTipView:ShowIndexCallBack(index)
	self:Flush(index)
end

function QieGeTipView:FlushView()
	self:Flush(index)
end


function QieGeTipView:OnFlush()
	local level = QieGeData.Instance:GetLevel()
	local step = QieGeData.Instance:GetLevelAndStep(level)
	local text= string.format(Language.QieGe.showdesc10, step)
	self.node_t_list.text_show.node:setString(text)

	local data = QieGeData.Instance:GetCuttingShenBinType(level)
	if data then
		print(data.effect)
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(data.effect)
		self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.node_t_list.img_name_tip.node:loadTexture(ResPath.GetQieGePath("name"..data.type))
	end
end

function QieGeTipView:GoToSehnBinPanel()
	ViewManager.Instance:CloseViewByDef(ViewDef.QieGeTipView)
	ViewManager.Instance:OpenViewByDef(ViewDef.QieGeView.Shenbi)
	GlobalEventSystem:Fire(OPEN_VIEW_EVENT.OpenEvent, 2)
end
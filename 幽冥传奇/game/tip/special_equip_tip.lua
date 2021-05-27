SpecialEquipTip = SpecialEquipTip or BaseClass(BaseView)

function SpecialEquipTip:__init( ... )
	self.is_any_click_close = true
	self.can_penetrate = true
	self.zorder = COMMON_CONSTS.ZORDER_ITEM_TIPS -1
		self.texture_path_list = {
	}
	self.config_tab = {
		{"itemtip_ui_cfg", 18, {0}}
	}
	self.root_node_off_pos = {x = -250, y = 0}	
end

function SpecialEquipTip:__delete()
	-- body
end

function SpecialEquipTip:ReleaseCallBack( ... )
	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil
	end
end


function SpecialEquipTip:LoadCallBack( ... )
	if nil == self.effect_show1 then
		local ph = self.ph_list.ph_effect_tip
	 	self.effect_show1 = AnimateSprite:create()
	 	self.effect_show1:setPosition(ph.x, ph.y + 5)
	 	self.node_t_list.layout_effect_tip.node:addChild(self.effect_show1, 999)
	end
end


function SpecialEquipTip:SetTipData(data, fromView, param_t )
	self.data = data
	self:Flush()

end

function SpecialEquipTip:ShowIndexCallBack( ... )
	-- body
end

function SpecialEquipTip:OnFlush()
	if self.data == nil then
		return
	end
	local config = SpecialTipsCfg[self.data.item_id]
	local anim_path = ""
	local anim_name = ""
	local offestX = 0
	if config.modleType == 1 then
		anim_path, anim_name =  ResPath.GetWuqiBigAnimPath(config.modleId, SceneObjState.Stand, GameMath.DirDown, sex)
		offestX = 100
	elseif config.modleType == 2 then
		anim_path, anim_name = ResPath.GetRoleBigAnimPath(config.modleId, SceneObjState.Stand, GameMath.DirDown)
		offestX = - 150
	elseif config.modleType == 3 then
		anim_path, anim_name = ResPath.GetEffectUiAnimPath(config.modleId)
		offestX = - 200
	end	
	if self.effect_show1 then
		local ph = self.ph_list.ph_effect_tip
		self.effect_show1:setPosition(ph.x + (config.offestX or offestX), ph.y + (config.offestY or 5))
		self.effect_show1:setScale(config.scale or 0.8)
		self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end
end

function SpecialEquipTip:CloseCallBack( ... )
	--ViewManager.Instance:CloseViewByDef(ViewDef.EquipTip)
end
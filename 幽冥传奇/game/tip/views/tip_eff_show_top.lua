TipSubEffShowTop = TipSubEffShowTop or BaseClass(TipSub)

TipSubEffShowTop.SIZE = cc.size(470, 300)

function TipSubEffShowTop:__init()
	self.y_order = 999
	self.is_ignore_height = false

	-- self.view:setBackGroundColor(COLOR3B.RED)
	self.view:setContentSize(TipSubEffShowTop.SIZE)
end

function TipSubEffShowTop:__delete()
end

function TipSubEffShowTop:YOrder()
	return self.y_order
end

function TipSubEffShowTop:SetData(data, fromView, param_t)
	self.data = data
	self.item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)

	self:Flush()
end

function TipSubEffShowTop:Release()
	self.effect_show1 = nil
	self.rich_node = nil
	self.data = nil
	self.item_cfg = nil
end

function TipSubEffShowTop:CloseCallBack()
end

function TipSubEffShowTop:CreateChild()
	TipSubEffShowTop.super.CreateChild(self)
	self.view.bg = XUI.CreateImageView(TipSubEffShowTop.SIZE.width / 2,TipSubEffShowTop.SIZE.height / 2 - 50,ResPath.GetBigPainting("tip_inner_bg"),false)
	self.view:addChild(self.view.bg, 100)

	self.rich_node = XUI.CreateRichText(TipSubEffShowTop.SIZE.width / 2 + 55, TipSubEffShowTop.SIZE.height - 2, 0, 20, false)
	self.view:addChild(self.rich_node, 100)
	XUI.RichTextSetCenter(self.rich_node)

	self.rich_lv_node = XUI.CreateRichText(TipSubEffShowTop.SIZE.width / 2 + 160, TipSubEffShowTop.SIZE.height - 375, 200, 20, false)
	self.view:addChild(self.rich_lv_node, 100)
	-- XUI.RichTextSetCenter(self.rich_lv_node)

 	self.effect_show1 = AnimateSprite:create()
 	self.effect_show1:setPosition(TipSubEffShowTop.SIZE.width / 2,TipSubEffShowTop.SIZE.height / 2 - 100)
 	self.view:addChild(self.effect_show1, 999)
end

function TipSubEffShowTop:OnFlush()
	RichTextUtil.ParseRichText(self.rich_node, string.format("{ItemImgName;%s}", self.data.item_id))

	local config = SpecialTipsCfg[self.data.item_id]
	if nil == config then
		ErrorLog("[TipSubEffShowTop] not eff animate by SpecialTipsCfg: id " .. self.data.item_id)
		return
	end
	local anim_path = ""
	local anim_name = ""
	local offestX = 0
	
	if config.modleType == 1 then
		anim_path, anim_name =  ResPath.GetWuqiBigAnimPath(config.modleId, SceneObjState.Stand, GameMath.DirDown, sex)
		offestX = 80
	elseif config.modleType == 2 then
		anim_path, anim_name = ResPath.GetRoleBigAnimPath(config.modleId, SceneObjState.Stand, GameMath.DirDown)
		offestX = 0
	elseif config.modleType == 3 then
		anim_path, anim_name = ResPath.GetEffectUiAnimPath(config.modleId)
		offestX = 0
	elseif config.modleType == 4 then
		self:WingEquipShow(config.modleId)
	end	

	-- 等级显示
	local level_str = ""
	local level_color = "e5e3cb"
	local limit_level = 0
	local circle_level = 0
	for k,v in pairs(self.item_cfg.conds or{}) do
		if v.cond == ItemData.UseCondition.ucLevel then
			limit_level = v.value
			if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
				level_color = COLORSTR.RED
			end
		end
		if v.cond == ItemData.UseCondition.ucMinCircle then
			circle_level = v.value
			if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
				level_color = COLORSTR.RED
			end
		end
	end

	level_str = (circle_level > 0 and circle_level .. "转" or "") 
	if limit_level > 0 then
		level_str = level_str.. limit_level .. "级"
	end
	RichTextUtil.ParseRichText(self.rich_lv_node, string.format("等级：{color;%s;%s}", level_color, level_str))


	self.effect_show1:setPosition(TipSubEffShowTop.SIZE.width / 2 + (config.offestX or offestX), TipSubEffShowTop.SIZE.height / 2 - 50 + (config.offestY or 0))
	self.effect_show1:setScale(config.scale or 0.8)
	self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)

	self.content_height = TipSubEffShowTop.SIZE.height
end

return TipSubEffShowTop

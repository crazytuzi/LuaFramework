SpecialObj = SpecialObj or BaseClass(SceneObj)
SpecialObj.FIREWALL_ID = 5

function SpecialObj:__init(vo)
	self.obj_type = SceneObjType.SpecialObj
end

function SpecialObj:__delete()

end

function SpecialObj:CreateBoard()
	if self.name and self.name ~= "" then
		local name_board = NameBoard.New()
		name_board:SetName(self.name)
		self:SetNameBoard(name_board)
		if EntityType.Transfer == self.vo.entity_type then --传送门高度特殊处理
			name_board:SetOffY(-200)
			name_board:SetName(Language.Common.ChuanSongDian .. self.name)
		end 
	end
end

function SpecialObj:LoadInfoFromVo()
	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)
end

function SpecialObj:InitAnimation()
	local anim_path, anim_name = "", ""
	if EntityType.Transfer == self.vo.entity_type or EntityType.Effect == self.vo.entity_type then
		anim_path, anim_name = ResPath.GetEffectUiAnimPath(self.vo.model_id)
	else
		anim_path, anim_name = ResPath.GetEffectAnimPath(self.vo.model_id)
	end

	local item = self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Main, anim_path, anim_name, 
		false, FrameTime.Effect, nil, COMMON_CONSTS.MAX_LOOPS, false)
	-- if self.vo.model_id == SpecialObj.FIREWALL_ID and SettingData.Instance:GetOneSysSetting(SETTING_TYPE.LITTLE_FIREWALL) then
	-- 	self:SetScale(0.66)
	-- end
	if WeiZhiAnDianCfg.FireId[self.vo.model_id] then
		if anim_path ~= "" then
			local layout = item:getParent()
			local path = ResPath.GetBigPainting("bonfire_range_" .. self.vo.model_id, false)
			self.select_area_effect = XUI.CreateImageView(0, 0, path, XUI.IS_PLIST)
			local pos = cc.p(HandleRenderUnit:WorldToLogicXY(self.vo.pos_x, self.vo.pos_y))
			self.model:AttachNode(self.select_area_effect, pos, 39, InnerLayerType.BiaocheCircle, is_save)
		else
			if self.select_area_effect then
				self.select_area_effect:removeFromParent()
				self.select_area_effect = nil
			end
		end
	end
end

function SpecialObj:CanClick()
	return false
end


SceneObj = SceneObj or BaseClass()
local NAME_BOARD_OFFY = 10

--基本场景对象
function SceneObj:__init(vo)
	self.obj_type = SceneObjType.Unknown
	self.vo = vo

	self.name = vo.name
	self.name_board = nil
	self.height = 0
	self.fixed_height = 130

	self.parent_scene = nil

	self.logic_pos = cc.p(0, 0)
	self.old_logic_pos = cc.p(0, 0)
	self.real_pos = cc.p(0, 0)

	self.is_shadow = false
	self.shadow = nil

	self.model = DrawObj.New(self)
end

function SceneObj:__delete()
	--删除场景模型对象
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	--删除头顶名字窗口
	if self.name_board ~= nil then
		self.name_board:DeleteMe()
		self.name_board = nil
	end

	if nil ~= self.make_gray_delay_timer then
		GlobalTimerQuest:CancelQuest(self.make_gray_delay_timer)
		self.make_gray_delay_timer = nil
	end
	
	if nil ~= self.vo then
		GameVoManager.Instance:DeleteVo(self.vo)
	end
	if HandleGameMapHandler:GetGameMap() then
		HandleGameMapHandler:GetGameMap():resetZoneInfo(self.logic_pos.x, self.logic_pos.y)
	end
end

function SceneObj:Init(parent_scene)
	self.parent_scene = parent_scene
	self:LoadInfoFromVo()
	self:CreateBoard()
	self:InitAnimation()

	if 0 == self.vo[OBJ_ATTR.ENTITY_MODEL_ID] then
		-- DebugLog("==== model_id:0")
	end
end

function SceneObj:CreateEnd()
end

function SceneObj:LoadInfoFromVo()
	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)
	-- override
end

function SceneObj:CreateBoard()
	-- override
end

function SceneObj:InitAnimation()
	-- override
end

-- 刷新动画
function SceneObj:RefreshAnimation()
	-- override me
end

function SceneObj:Update(now_time, elapse_time)
	-- override
end

function SceneObj:IsCharacter()
	-- override
	return false
end

function SceneObj:IsRole()
	-- override
	return false
end

function SceneObj:IsMainRole()
	-- override
	return false
end

function SceneObj:IsStand()
	return true
end

function SceneObj:IsWait()
	return false
end

function SceneObj:OnClick()
	-- override
end

-- 由DrawObj调用
function SceneObj:OnMainAnimateCallback(sender, event_type, frame)
	if 0 == event_type then
		self:OnMainAnimateStart()
	elseif 2 == event_type then
		self:OnMainAnimateStop()
	end
end

function SceneObj:OnMainAnimateStart()
	-- override
	self:SetHeight(self.model:GetHeight())
end

function SceneObj:OnMainAnimateStop()
	-- override
end

function SceneObj:GetName()
	return self.name
end

function SceneObj:GetType()
	return self.obj_type
end

function SceneObj:GetObjId()
	return self.vo.obj_id
end

function SceneObj:GetObjKey()
	if nil ~= self.vo and 0 ~= self.vo.obj_key then
		return self.vo.obj_key
	end
	return self.vo.obj_id
end

function SceneObj:SetObjId(obj_id)
	self.vo.obj_id = obj_id
end

function SceneObj:GetDirNumber()
	return self.vo.dir
end

function SceneObj:SetDirNumber(dir_number)
	self.vo.dir = dir_number
end

function SceneObj:GetVo()
	return self.vo
end

function SceneObj:GetAttr(index)
	return self.vo[index]
end

function SceneObj:SetAttr(index, value)
	self.vo[index] = value
	-- override
end

function SceneObj:GetNameBoard()
	return self.name_board
end

function SceneObj:SetNameBoard(value)
	if self.name_board ~= nil then
		self.name_board:GetRootNode():removeFromParent()
		self.name_board:DeleteMe()
	end

	self.name_board = value
	self.model:AttachNode(value:GetRootNode(), cc.p(0, self:GetFixedHeight() + NAME_BOARD_OFFY), GRQ_SCENE_OBJ_NAME, InnerLayerType.Name)
end

function SceneObj:GetHeight()
	return self.height
end

function SceneObj:GetFixedHeight()
	return self.fixed_height
end

function SceneObj:SetHeight(height)
	self.height = height
	if self.name_board then
		self.name_board:SetHeight(self:GetFixedHeight() + NAME_BOARD_OFFY)
	end
end

function SceneObj:GetModel()
	return self.model
end

function SceneObj:CanClick()
	-- override
	return true
end

function SceneObj:OnLogicPosChange()
	-- override
end

function SceneObj:IsClick(x, y)
	if not self:CanClick() then
		return false
	end
	return self.model:IsClick(x, y)
end

function SceneObj:SetLogicPos(posx, posy)
	self.old_logic_pos.x, self.old_logic_pos.y = self.logic_pos.x, self.logic_pos.y
	self.logic_pos.x = posx
	self.logic_pos.y = posy
	self.real_pos.x, self.real_pos.y = HandleRenderUnit:LogicToWorldXY(posx, posy)

	if self.logic_pos.x ~= self.old_logic_pos.x or self.logic_pos.y ~= self.old_logic_pos.y then
		self:OnLogicPosChange()
		self:CheckShadow()
	end

	self:UpdateModelPos()
end

function SceneObj:SetRealPos(posx, posy)
	self.real_pos.x = posx
	self.real_pos.y = posy

	self.old_logic_pos.x, self.old_logic_pos.y = self.logic_pos.x, self.logic_pos.y
	self.logic_pos.x, self.logic_pos.y = HandleRenderUnit:WorldToLogicXY(posx, posy)

	if self.logic_pos.x ~= self.old_logic_pos.x or self.logic_pos.y ~= self.old_logic_pos.y then
		self:OnLogicPosChange()
		self:CheckShadow()
	end

	self:UpdateModelPos()
end

function SceneObj:GetLogicPos()
	return self.logic_pos.x, self.logic_pos.y
end

function SceneObj:GetRealPos()
	return self.real_pos.x, self.real_pos.y
end

function SceneObj:GetLocalZOrder()
	return self.model:GetLocalZOrder()
end

-- 更新模型位置
function SceneObj:UpdateModelPos()
	self.model:SetPos(self.real_pos.x, self.real_pos.y)
	self:UpdateZoneInfo()
end

function SceneObj:ShadowChange(is_shadow)
	if self.is_shadow ~= is_shadow then
		self.is_shadow = is_shadow
		self:SetOpacity(self.is_shadow and 127 or 255)
	end
end

function SceneObj:GetIsInShadow()
	return self.is_shadow
end

function SceneObj:SetOpacity(value)
	self.model:SetOpacity(value)
end

-- 是否需要检测阴影
function SceneObj:IsNeedCheckShadow()
	-- override
	return false
end

-- 检测是否处于阴影下
function SceneObj:CheckShadow()
	if self:IsNeedCheckShadow() and HandleGameMapHandler:GetGameMap() then
		local zone_info = HandleGameMapHandler:GetGameMap():getZoneInfo(self.logic_pos.x, self.logic_pos.y) or 0
		if zone_info >= ZoneType.ShadowBegin then
			self:ShadowChange(true)
		else
			self:ShadowChange(false)
		end
	end
end

-- 创建脚底影子
function SceneObj:CreateShadow()
	local res_path = ResPath.GetOther("shadow")
	self.shadow  = XUI.CreateSprite(res_path, true)
	self:GetModel():AttachNode(self.shadow, cc.p(0, 0), GRQ_SHADOW, InnerLayerType.Shadow)
end

--取消选中
function SceneObj:CancelSelect()
	self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Select, "", "")
end

function SceneObj:SetScale(scale, is_all)
	if scale ~= self.model:GetScale() then
		self.model:SetScale(scale, is_all)
		self:SetHeight(self.model:GetHeight())
	end
end

function SceneObj:SetShadowVisible(is_visible)
	if self.shadow ~= nil then
		self.shadow:setVisible(is_visible)
	end
end

function SceneObj:IsInBlock()
	return GameMapHelper.IsBlock(self.logic_pos.x, self.logic_pos.y)
end

function SceneObj:SetModelColor(color_value)
	local c3b = UInt2C3b(color_value)

	if nil ~= self.make_gray_delay_timer then
		GlobalTimerQuest:CancelQuest(self.make_gray_delay_timer)
		self.make_gray_delay_timer = nil
	end
	self.make_gray_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
		self.model:MakeGray(0 ~= color_value and c3b.r == c3b.g and c3b.g == c3b.b) end, 0)
	
	if 0 == color_value then
		self.model:SetColor(COLOR3B.WHITE)
	else
		self.model:SetColor(c3b)
	end
end

function SceneObj:UpdateZoneInfo()
	if nil == HandleGameMapHandler:GetGameMap() then
		return
	end
	if self.old_logic_pos.x == self.logic_pos.x and self.old_logic_pos.y == self.logic_pos.y then
		return
	end
	local area_info = Scene.Instance:GetCurAreaInfo()
	if not area_info.attr_t[MapAreaAttribute.aaCrossMan] and self:GetType() == SceneObjType.Role then
		HandleGameMapHandler:GetGameMap():resetZoneInfo(self.old_logic_pos.x, self.old_logic_pos.y)
		HandleGameMapHandler:GetGameMap():setZoneInfo(self.logic_pos.x, self.logic_pos.y, ZONE_TYPE_BLOCK)	
	end
	if not area_info.attr_t[MapAreaAttribute.aaCrossMonster] and self:GetType() == SceneObjType.Monster then
		HandleGameMapHandler:GetGameMap():resetZoneInfo(self.old_logic_pos.x, self.old_logic_pos.y)
		HandleGameMapHandler:GetGameMap():setZoneInfo(self.logic_pos.x, self.logic_pos.y, ZONE_TYPE_BLOCK)	
	end
end

----------------------------------------------------
-- 右上部件
----------------------------------------------------
MainuiRightTop = MainuiRightTop or BaseClass()

function MainuiRightTop:__init()
	self.mt_layout_right_top = nil
	self.mt_icon_layout = nil

	self.icon_list = {}
	self.cond_list = {}
	self.remind_icon_list = {}
end

function MainuiRightTop:__delete()
	for k, v in pairs(self.icon_list) do
		if v.icon then
			v.icon:DeleteMe()
		end
	end
	self.icon_list = {}
	self.cond_list = {}
	self.remind_icon_list = {}
end

function MainuiRightTop:Init(mt_layout_root)
	local mt_size = mt_layout_root:getContentSize()
	self.mt_layout_right_top = MainuiMultiLayout.CreateMultiLayout(mt_size.width, mt_size.height, cc.p(1, 1), mt_size, mt_layout_root, 1)
	self.layout_size = self.mt_layout_right_top:getContentSize()

	self:InitMapParts()

	self:InitSmallIcons()

	GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChangeComplete, self))
	GlobalEventSystem:Bind(SceneEventType.SCENE_AREA_ATTR_CHANGE, BindTool.Bind(self.OnSceneAreaChange, self))
	GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind(self.OnMainRolePosChange, self))
	GlobalEventSystem:Bind(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.RemindGroupChange, self))
	GlobalEventSystem:Bind(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
end

----------------------------------------------------------
-- 小图标
----------------------------------------------------------
function MainuiRightTop:InitSmallIcons()
	local size = self.mt_layout_right_top:getContentSize()
	self.mt_icon_layout = MainuiMultiLayout.CreateMultiLayout(size.width, size.height - 90, cc.p(1, 1), cc.size(200, 150), self.mt_layout_right_top, 1)
	-- self.mt_icon_layout:TextureLayout():setBackGroundColor(COLOR3B.GREEN)

	-- remind_group 红点提醒组名
	-- vis_cond 显示条件
	self.icon_list = {
		-- {order = 1, view_def = ViewDef.Society, img_icon_res = "img_society", icon_bg_res = "img_circular", remind_group = RemindGroupName.SocietyView, vis_cond = nil,},
		{order = 1, view_def = ViewDef.RankingList, img_icon_res = "icon_rank", remind_group = nil, vis_cond = nil,},
		{order = 2, view_def = ViewDef.Mail, img_icon_res = "img_mail", remind_group = RemindGroupName.MailView, vis_cond = nil,},
		{order = 3, view_def = ViewDef.Setting, img_icon_res = "img_setting", remind_group = nil, vis_cond = nil,},
	}
	for i, v in ipairs(self.icon_list) do
		v.icon = self:CreateMainuiIcon(64 + (i - 1) * 50, 120, v)
		if v.remind_group then
			self.remind_icon_list[v.remind_group] = v.icon
		end
		if v.vis_cond then
			self.cond_list[v.vis_cond] = v.icon
		end
	end
	-- if not IS_AUDIT_VERSION then
	-- 	self.icon_list[#self.icon_list + 1] = {order = 999, view_def = ViewDef.RankingList, img_icon_res = "icon_rank", remind_group = nil, vis_cond = nil,}
	-- end
	-- self.icon_list[#self.icon_list].icon = self:CreateMainuiIcon(-15, 188, self.icon_list[#self.icon_list])

	self:UpdateSmallIconPos()
end

local icon_sort_func = function(a, b)
	return a.order and a.order < b.order or false
end
function MainuiRightTop:UpdateSmallIconPos()
	for k, v in pairs(self.icon_list) do
		if v.icon then
			v.icon:SetVisible((nil == v.vis_cond) or GameCondMgr.Instance:GetValue(v.vis_cond))
		end
	end

	table.sort(self.icon_list, icon_sort_func)

	local count = 0
	for i, v in ipairs(self.icon_list) do
		if v.order < 100 and v.icon and v.icon:IsVisible() then
			count = count + 1

			v.icon:SetPosition(64 + (count - 1) * 50, 120)
		end
	end
end

function MainuiRightTop:CreateMainuiIcon(x, y, view_data)
	local icon = MainUiIcon.New(50, 50)
	icon:Create(self.mt_icon_layout)
	icon:SetPosition(x, y)
	icon:SetData(view_data)
	icon:SetIconPath(ResPath.GetMainui(view_data.img_icon_res))
	if view_data.icon_bg_res then
		icon:SetBgFramePath(ResPath.GetMainui(view_data.icon_bg_res))
	end
	icon:AddClickEventListener(BindTool.Bind(self.OnClickIcon, self, icon))
	return icon
end

function MainuiRightTop:OnClickIcon(icon)
	local view_data = icon:GetData()
	if view_data.view_def == ViewDef.NearTag then
		ViewManager.Instance:GetView(ViewDef.MainUi):OpenNearTarget()
	elseif view_data.view_def == ViewDef.RankingList then
		if IS_ON_CROSSSERVER then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.OnCrossServerTip)
			return
		else
			ViewManager.Instance:OpenViewByDef(ViewDef.RankingList)
		end
	else
		ViewManager.Instance:OpenViewByDef(view_data.view_def)
	end
end

----------------------------------------------------------
-- 地图
----------------------------------------------------------
function MainuiRightTop:InitMapParts()
	local img_map = XUI.CreateImageView(self.layout_size.width, self.layout_size.height, ResPath.GetMainui("map_normal"), true)
	img_map:setAnchorPoint(1, 1)
	self.mt_layout_right_top:TextureLayout():addChild(img_map, 1)
	XUI.AddClickEventListener(img_map, function()
		ViewManager.Instance:OpenViewByDef(ViewDef.Map)
	end, false)
	
	self.label_map_name = XUI.CreateText(self.layout_size.width - 95, self.layout_size.height - 23, 160, 25, nil, "", nil, 24)
	self.label_map_name:setColor(COLOR3B.YELLOW)
	self.mt_layout_right_top:TextLayout():addChild(self.label_map_name)
	
	self.label_mainrole_pos = XUI.CreateText(self.layout_size.width - 50, self.layout_size.height - 63, 60, 25, nil, "", nil, 20, COLOR3B.OLIVE)
	self.label_mainrole_pos:setAnchorPoint(0.5, 0.5)
	self.mt_layout_right_top:TextLayout():addChild(self.label_mainrole_pos)
	
	self.label_mainrole_area = XUI.CreateText(self.layout_size.width - 130, self.layout_size.height - 63, 100, 25, nil, "", nil, 20, COLOR3B.OLIVE)
	self.label_mainrole_area:setAnchorPoint(0.5, 0.5)
	self.mt_layout_right_top:TextLayout():addChild(self.label_mainrole_area)
end

function MainuiRightTop:OnSceneChangeComplete()
	-- if PracticeCtrl.IsInPracticeGate() then   --关卡副本
	-- 	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 	local nfloor = role_vo[OBJ_ATTR.ACTOR_SOUL2] or 0
	-- 	self.label_map_name:setString(string.format(Language.Map.PracticeMapName,nfloor+1))
	-- else
		self.label_map_name:setString(Scene.Instance:GetSceneName())
	-- end
end

function MainuiRightTop:RemindGroupChange(group_name, num)
	if self.remind_icon_list[group_name] then
		self.remind_icon_list[group_name]:SetRemindNum(num, 40, 40)
	end
end

function MainuiRightTop:OnMainRolePosChange(x, y)
	self.label_mainrole_pos:setString(x .. "," .. y)
end

function MainuiRightTop:OnSceneAreaChange()
	self:FlushSceneAreaInfo()
end

function MainuiRightTop:OnGameCondChange(cond_name)
	if self.cond_list[cond_name] then
		self:UpdateSmallIconPos()
	end
end

function MainuiRightTop:FlushSceneAreaInfo()
	local area_info = Scene.Instance:GetCurAreaInfo()
	self.label_mainrole_area:setString(area_info.area_name)
	self.label_mainrole_area:setColor(area_info.is_danger and COLOR3B.RED or COLOR3B.GREEN)
end

function MainuiRightTop:SetRigtTopVisble(vis)
	self.mt_layout_right_top:setVisible(vis)
end

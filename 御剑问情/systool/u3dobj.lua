local component_table = {
	-- 基础组件
	transform = typeof(UnityEngine.Transform),
	camera = typeof(UnityEngine.Camera),
	renderer = typeof(UnityEngine.Renderer),
	animation = typeof(UnityEngine.Animation),
	animator = typeof(UnityEngine.Animator),
	collider = typeof(UnityEngine.Collider),
	audio = typeof(UnityEngine.AudioSource),
	light = typeof(UnityEngine.Light),
	line_renderer = typeof(UnityEngine.LineRenderer),

	-- UI相关组件
	rect = typeof(UnityEngine.RectTransform),
	canvas = typeof(UnityEngine.Canvas),
	canvas_group = typeof(UnityEngine.CanvasGroup),
	image = typeof(UnityEngine.UI.Image),
	raw_image = typeof(UnityEngine.UI.RawImage),
	text = typeof(UnityEngine.UI.Text),
	button = typeof(UnityEngine.UI.Button),
	toggle = typeof(UnityEngine.UI.Toggle),
	toggle_group = typeof(UnityEngine.UI.ToggleGroup),
	slider = typeof(UnityEngine.UI.Slider),
	scroll_rect = typeof(UnityEngine.UI.ScrollRect),
	input_field = typeof(UnityEngine.UI.InputField),
	dropdown = typeof(UnityEngine.UI.Dropdown),
	scroller = typeof(EnhancedUI.EnhancedScroller.EnhancedScroller),
	accordion_element = typeof(AccordionElement),
	grayscale = typeof(UIGrayscale),
	rich_text = typeof(RichTextGroup),
	grid_layout_group = typeof(UnityEngine.UI.GridLayoutGroup),
	horizontal_layout_group = typeof(UnityEngine.UI.HorizontalLayoutGroup),
	layout_element = typeof(UnityEngine.UI.LayoutElement),
	playable_director = typeof(UnityEngine.Playables.PlayableDirector),
	shadow = typeof(UnityEngine.UI.Shadow),
	outline = typeof(UnityEngine.UI.Outline),

	-- 自定义UI组件
	list_cell = typeof(ListViewCell),
	list_delegate = typeof(ListViewDelegate),
	list_simple_delegate = typeof(ListViewSimpleDelegate),
	list_page_scroll = typeof(ListViewPageScroll),
	list_page_scroll2 = typeof(ListViewPageScroll2),
	page_view = typeof(PageView),
	list_view = typeof(Nirvana.ListView),
	page_simple_delegate = typeof(PageViewSimpleDelegate),
	joystick = typeof(UIJoystick),
	ui3d_display = typeof(UI3DDisplay),
	uiprefab_loader = typeof(UIPrefabLoaderAsync),

	-- 自定义3D组件
	move_obj = typeof(MoveableObject),
	actor_attachment = typeof(ActorAttachment),
	actor_ctrl = typeof(ActorController),
	actor_fadout = typeof(ActorFadeout),
	actor_attach_effect = typeof(ActorAttachEffect),
    attach_obj = typeof(AttachObject),
	camera_follow = typeof(CameraFollow),
	click_manager = typeof(ClickManager),
	clickable_obj = typeof(ClickableObject),
	uidrag = typeof(UIDrag),
	attach_skin = typeof(AttachSkin),
	attach_skin_obj = typeof(AttachSkinObject),
}

local u3d_shortcut = {}
function u3d_shortcut:SetActive(active)
	self.gameObject:SetActive(active)
end

function u3d_shortcut:GetActive()
	return self.gameObject.activeInHierarchy
end

function u3d_shortcut:FindObj(name_path)
	local transform = self.transform:FindHard(name_path)
	if transform == nil then
		return nil
	end

	return U3DObject(transform.gameObject, transform)
end

function u3d_shortcut:GetComponent(type)
	return self.gameObject:GetComponent(type)
end

function u3d_shortcut:GetOrAddComponent(type)
	return self.gameObject:GetOrAddComponent(type)
end

function u3d_shortcut:GetComponentsInChildren(type)
	return self.gameObject:GetComponentsInChildren(type)
end

function u3d_shortcut:SetLocalPosition(x, y, z)
	self.transform:SetLocalPosition(x or 0, y or 0, z or 0)
end

local u3d_metatable = {
	__index = function(table, key)
		if IsNil(table.gameObject) then
			return nil
		end

		local key_type = component_table[key]
		if key_type ~= nil then
			local component = table.gameObject:GetComponent(key_type)
			if component ~= nil then
				table[key] = component
				return component
			end
		end

		return u3d_shortcut[key]
	end
}

function U3DObject(go, transform)
	if go == nil then
		return nil
	end

	local obj = { gameObject = go, transform = transform, }
	setmetatable(obj, u3d_metatable)
	return obj
end

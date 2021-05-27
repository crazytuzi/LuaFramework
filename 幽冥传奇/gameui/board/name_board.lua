
NameBoard = NameBoard or BaseClass()
NameBoard.FontSize = 20

function NameBoard:__init()
	self.off_y = 15
	self.root_node = cc.Node:create()
	self.name_text_rich = XUI.CreateRichText(0, 8, 200, 22)
	XUI.RichTextSetCenter(self.name_text_rich)
	self.root_node:addChild(self.name_text_rich)
end

function NameBoard:__delete()
	self.root_node = nil
	self.name_text_rich = nil
	self.type_boss_rich = nil
end

function NameBoard:GetRootNode()
	return self.root_node
end

function NameBoard:SetName(name, color)
	self.name_text_rich:removeAllElements()
	if nil ~= name and "" ~= name then
		XUI.RichTextAddText(self.name_text_rich, name, COMMON_CONSTS.FONT, NameBoard.FontSize, color, 255, nil, 1)
	end
end

function NameBoard:SetNameType(monster_id, color)
	if not monster_id then return end

	if self.type_boss_rich == nil then
		self.type_boss_rich = XUI.CreateRichText(0, NameBoard.FontSize / 2 + 20, 200, 22)
		XUI.RichTextSetCenter(self.type_boss_rich)
		self.root_node:addChild(self.type_boss_rich)
	end

	local cfg = BossData.GetMosterCfg(monster_id)
	local text = Language.Boss.NameType[cfg.FieldBossType]
	local del_name = DelNumByString(cfg.name)
	local name =  del_name .. string.format(Language.Map.level, cfg.level)
	XUI.RichTextAddText(self.name_text_rich, name, COMMON_CONSTS.FONT, NameBoard.FontSize, color, 255, nil, 1)
	XUI.RichTextAddText(self.type_boss_rich, text, COMMON_CONSTS.FONT, NameBoard.FontSize, color, 255, nil, 1)
end

-- name_lsit:{{text = "", color = c3b}, }
function NameBoard:SetNameList(name_lsit)
	self.name_text_rich:removeAllElements()
	if nil ~= name_lsit then
		for i, v in ipairs(name_lsit) do
			if v.text then
				XUI.RichTextAddText(self.name_text_rich, v.text, COMMON_CONSTS.FONT, NameBoard.FontSize, v.color, 255, nil, 1)
			elseif v.img_path then
				XUI.RichTextAddImage(self.name_text_rich, v.img_path, true)
			elseif v.img_num_path then
				local img_num = XUI.CreateImageView(-4, 5, v.img_num_path, true)
				local empty_node = cc.Node:create()
				empty_node:setContentSize(8, NameBoard.FontSize)
				empty_node:addChild(img_num)
				XUI.RichTextAddElement(self.name_text_rich, empty_node)
			elseif v.effect_id then
				local anim_path,anim_name = v.path_func(v.effect_id)
				local eff = RenderUnit.CreateAnimSprite(anim_path, anim_name, 0.15, 20, nil)
				eff:setContentSize(v.w, v.h)
				eff:setPosition(0, NameBoard.FontSize / 2)
				local empty_node = cc.Node:create()
				empty_node:setContentSize(v.w / 2, NameBoard.FontSize)
				empty_node:addChild(eff)
				XUI.RichTextAddElement(self.name_text_rich, empty_node)
			end
		end
	end
end

function NameBoard:SetHeight(height)
	self.root_node:setPosition(0, height + self.off_y)
end

function NameBoard:SetOffY(off_y)
	self.off_y = off_y
end

function NameBoard:SetVisible(is_visible)
	self.root_node:setVisible(is_visible)
end

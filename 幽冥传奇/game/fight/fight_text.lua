
FightText = FightText or BaseClass()

-- ff2828 红
-- ff7f00 橙
-- 1eff00 绿
-- 36c4ff 蓝
-- db70db 粉

------------------------------------------------------------------------------------------------
--格式：
--[属性id] = {str=显示只有自己能看到的文字, word=数字前面图片路径, num=数字图片路径, fade_out_time = 文字停留时间}
-- 对应的字段不填则不显示对应的内容,图片路径均放在client\tools\uieditor\ui_res\fight下
FightText.TXT_INFO = {
	-- [56] = {str = "{color;ff2828;麻  痹}"},
	[156] = {str = "{color;ff7f00;防麻痹}"},
	[78] = {str = "{color;1eff00;护  身}"},
	[71] = {str = "{color;ff2828;破护身}"},
	-- [76] = {str = "{color;36c4ff;复  活}"},
	[151] = {str = "{color;db70db;内功伤害}"},
	[155] = {str = "{color;db70db;破复活}"},
	[165] = {str = "{color;ff7f00;免  伤}"},
	[102] = {str = "{color;ff7f00;物理穿透}"},
	[103] = {str = "{color;36c4ff;魔法穿透}"},

	-- 被动技能特殊处理，数据走场景特效，id为effect_id
	[300] = {str = "{color;ff7f00;强  力}"},
	[301] = {str = "{color;36c4ff;羽  盾}"},
	[302] = {str = "{color;ff2828;羽  刃}"},
	[303] = {str = "{color;1eff00;影  翼}"},
	[304] = {str = "{color;ff7f00;千  羽}"},
	[305] = {str = "{color;db70db;幻  翼}"},

	[0] = {num = "r_"},--[[-xxx]]
	[35] = {word = "b_shanbi"},--[[闪避]]
	[56] = {word = "b_mabi"},--[[麻痹]]
	[76] = {word = "b_fuhuo"},--[[复活]]

	[186] = {word = "b_fanshang"},--[[反伤]]
	[128] = {word = "r_baoji", num = "scene_num_01_"},--[[暴击-xxx]]
	[157] = {word = "scene_word_02", num = "scene_num_01_"},--[[抗暴比-xxx]]
	[96] = {word = "scene_word_07", num = "scene_num_03_"},--[[神圣一击-xxx]]
	[98] = {word = "scene_word_04", num = "scene_num_02_"},--[[神圣抵消-xxx]]
	[169] = {word = "scene_word_09", num = "scene_num_04_"},--[[致命一击-xxx]]
	[73] = {word = "scene_word_03", num = "scene_num_01_"},--[[破击-xxx]]
	[74] = {word = "scene_word_08", num = "scene_num_03_"},--[[抗破击-xxx]]
	[75] = {word = "scene_word_05", num = "scene_num_02_"},--[[内功穿透-xxx]]
	[144] = {word = "scene_word_14", num = "qz_num_"},--[[切割-xxx]]
	[130] = {word = "scene_word_15", num = "scene_num_04_"},--[[神豪一击-xxx]]
	[161] = {word = "scene_word_16", num = "sx_num_", --[[pos = {0, 80}]]},--[[嗜血-xxx]]
	[189] = {word = "scene_word_17", num = "sys_num_", eff = 20,--[[pos = {220, 50}]]},--[[圣言术-xxx]]
   
    [84] = {word = "scene_word_12", num = "sx_num_"},--[[吸血-xxx]] --------


	[158] = {word = "r_bossbaoji", num = "y_"},--[[对boss伤害增加-xxx]]

	[165] = {word = "scene_word_13", num = "scene_num_02_"},--[[诅咒-xxx]]--------------


	[166] = {word = "scene_word_06", num = "scene_num_01_", num_scale = 1.1, fade_out_time = 2},--[[合击-xxx]]
	-- [186] = {word = "scene_word_11", num = "scene_num_01_", num_scale = 1.1, fade_out_time = 2},--[[秒杀-xxx]]

	[-999] = {num = "g_"},--[[+xxx 回血]]
	[6] = {word = "scene_word_18", num = "yz_num_"},--[[压制-xxx]]

	[-99] = {word = "scene_word_19", num = "pet_num_"},--[[宠物攻击-xxx]]
}
------------------------------------------------------------------------------------------------

function FightText:__init()
	self.root_node = cc.Node:create()
	HandleRenderUnit:GetCoreScene():addChildToRenderGroup(self.root_node, GRQ_SCENE_OBJ_FIGHT_TEXT)

	self.node_text_root = cc.Node:create()
	self.node_text_root:setContentSize(cc.size(170, 20))
	self.node_text_root:setAnchorPoint(0.5, 0.5)
	self.node_text_root:setCascadeOpacityEnabled(true)
	self.root_node:addChild(self.node_text_root)

	self.img_atk_type = XImage:create()
	self.img_atk_type:setAnchorPoint(0, 0)
	self.node_text_root:addChild(self.img_atk_type)

	self.number_hp = NumberBar.New()
	self.node_text_root:addChild(self.number_hp:GetView())
end

function FightText:__delete()
	
end

function FightText:SetInfo(x, y, chg_value, atk_type, hit_me, is_pet)
	if Story.Instance:GetIsStoring() then
		return
	end

	local txt_info = self.TXT_INFO[atk_type or 0]
	if nil == txt_info then
		return
	end

	-- 宠物攻击
	if is_pet then
		txt_info = self.TXT_INFO[-99]
	end

	local number_x = 0
	local atk_type_path = txt_info.word
	if nil ~= atk_type_path then
		self.img_atk_type:loadTexture(ResPath.GetFightResPath(atk_type_path))
		self.img_atk_type:setVisible(true)
		number_x = number_x + self.img_atk_type:getContentSize().width
	else
		self.img_atk_type:setVisible(false)
	end

	if nil ~= txt_info.num and 0 ~= chg_value then
		self.number_hp:SetRootPathEx(ResPath.GetFightRoot(txt_info.num))
		self.number_hp:SetHasPlus(true)
		self.number_hp:SetHasMinus(true)
		self.number_hp:SetNumber(- chg_value)
		self.number_hp:SetVisible(true)
		self.number_hp:SetPosition(number_x, 0)

		self.number_hp:SetScale(txt_info.num_scale or 1)
	else
		self.number_hp:SetVisible(false)
	end

	if txt_info.eff then
		RenderUnit.CreateEffect(txt_info.eff, self.root_node, 100, nil, 1, 10, 140)
		Story.Instance:ActShake(4)
	end

	if txt_info.pos ~= nil then
		if txt_info.pos[1] ~= 0 then
			self.number_hp:SetPosition(txt_info.pos[1], txt_info.pos[2])
		else
			self.number_hp:SetPosition(number_x + txt_info.pos[1], txt_info.pos[2])
		end
	end

	if hit_me then
		self.root_node:setPosition(x, y)
		self.root_node:setVisible(true)
		self.node_text_root:setScale(0.6)
		self.node_text_root:setPosition(0, 0)
		self.node_text_root:setOpacity(255)
		local move_to = cc.MoveTo:create(0.5, cc.p(20, 100))
		local scale_to = cc.ScaleTo:create(0.5, 1.0)
		local spawn = cc.Spawn:create(move_to, scale_to)
		local callback = cc.CallFunc:create(function()
			self.root_node:setVisible(false)
			FightTextMgr:AddFightText(self)
		end)
		local action = cc.Sequence:create(spawn, callback)
		self.node_text_root:runAction(action)
	else
		self.root_node:setPosition(x, y)
		self.root_node:setVisible(true)
		self.node_text_root:setScale(0.2)
		self.node_text_root:setPosition(80, 40)
		self.node_text_root:setOpacity(255)

		local fade_out_time = txt_info.fade_out_time or 0.5
		local move_to = cc.MoveTo:create(fade_out_time, cc.p(80, 20))
		local fade_out = cc.FadeTo:create(fade_out_time, 100)
		local spawn = cc.Spawn:create(move_to, fade_out)

		local move_to1
		local scale_to1
		local move_to2
		local scale_to2
		if nil ~= atk_type_path then
			move_to1 = cc.MoveTo:create(0.1, cc.p(80, 85))
			scale_to1 = cc.ScaleTo:create(0.1, 1.0)
			move_to2 = cc.MoveTo:create(0.05, cc.p(80, 80))
			scale_to2 = cc.ScaleTo:create(0.05, 0.8)
		else
			move_to1 = cc.MoveTo:create(0.1, cc.p(80, 65))
			scale_to1 = cc.ScaleTo:create(0.1, 1)
			move_to2 = cc.MoveTo:create(0.05, cc.p(80, 60))
			scale_to2 = cc.ScaleTo:create(0.05, 0.8)
		end

		local spawn1 = cc.Spawn:create(move_to1, scale_to1)
		local spawn2 = cc.Spawn:create(move_to2, scale_to2)

		local callback = cc.CallFunc:create(function()
			self.root_node:setVisible(false)
			FightTextMgr:AddFightText(self)
		end)
		local action = cc.Sequence:create(spawn1, spawn2, spawn1, spawn, callback)
		self.node_text_root:runAction(action)
	end
end

FightTextMgr = FightTextMgr or {}
FightTextMgr.fight_text_list = {}

function FightTextMgr:GetFightText()
	local fight_text = table.remove(self.fight_text_list)
	if nil == fight_text then
		fight_text = FightText.New()
	end

	return fight_text
end

function FightTextMgr:AddFightText(fight_text)
	table.insert(self.fight_text_list, fight_text)
end

function FightTextMgr:OnChangeHp(x, y, hp_chg, atk_type, hit_me, is_pet)
	local fight_text = self:GetFightText()
	fight_text:SetInfo(x, y, hp_chg, atk_type, hit_me, is_pet)
end

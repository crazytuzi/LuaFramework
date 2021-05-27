RichTextUtil = RichTextUtil or BaseClass()
RichTextUtil.is_init = false
RichTextUtil.parse_func_list = nil
RichTextUtil.ignore_mark_list = nil
RichTextUtil.old_star_params = 0

function RichTextUtil.ParseRichText(rich_text, content, font_size, color, x, y, w, h, ignored_link, text_attr)
	if nil == content then return end
	
	if nil == rich_text then
		rich_text = XUI.CreateRichText(x or 0, y or 0, w or 1, h or 1)
	else
		if nil ~= x and nil ~= y then
			rich_text:setPosition(x, y)
		end
		
		if nil ~= w and nil ~= h then
			rich_text:setContentWH(w, h)
		end
	end
	
	-- 先清空rich_text
	rich_text:removeAllElements()

	
	font_size = font_size or 20
	color = color or COLOR3B.WHITE
	
	content = CommonDataManager.ParseGameName(content)
	
	local i, j = 0, 0
	local last_pos = 1
	for loop_count = 1, 256 do
		i, j = string.find(content, "({.-})", j + 1)-- 匹配规则{face;20} {item;26000}
		if nil == i or nil == j then
			if last_pos <= string.len(content) then
				RichTextUtil.AddText(rich_text, string.sub(content, last_pos, - 1), font_size, color, text_attr)
			end
			break
		else
			if 1 ~= i and last_pos ~= i then
				RichTextUtil.AddText(rich_text, string.sub(content, last_pos, i - 1), font_size, color, text_attr)
			end
			
			RichTextUtil.ParseMark(rich_text, Split(string.sub(content, i + 1, j - 1), ";"), font_size, color, ignored_link, text_attr)
			last_pos = j + 1
		end
	end
	
	return rich_text
end

function RichTextUtil:__delete()
	if RichTextUtil.role_head then
		RichTextUtil.role_head:DeleteMe()
		RichTextUtil.role_head = nil
	end
end
function RichTextUtil.Parse2Table(content)
	local t = {}
	local i, j = 0, 0
	local last_pos = 1
	for loop_count = 1, 100 do
		i, j = string.find(content, "({.-})", j + 1)-- 匹配规则{face;20} {item;26000}
		if nil == i or nil == j then
			if last_pos < string.len(content) then
				table.insert(t, string.sub(content, last_pos, - 1))
			end
			break
		else
			if 1 ~= i and last_pos ~= i then
				table.insert(t, string.sub(content, last_pos, i - 1))
			end
			
			table.insert(t, Split(string.sub(content, i + 1, j - 1), ";"))
			last_pos = j + 1
		end
	end
	
	return t
end

function RichTextUtil.AddText(rich_text, text, font_size, color, text_attr)
	if nil ~= text_attr then
		XUI.RichTextAddText(rich_text, text, nil, font_size, color,
		text_attr.opacity, text_attr.shadow_offset, text_attr.outline_size)
	else
		XUI.RichTextAddText(rich_text, text, nil, font_size, color)
	end
end

function RichTextUtil.ParseMark(rich_text, params, font_size, color, ignored_link, text_attr)
	local mark = params[1]
	if nil == mark then return end
	
	RichTextUtil.Init()
	
	local func = RichTextUtil.parse_func_list[mark]
	if nil ~= func then
		func(rich_text, params, font_size, color, ignored_link, text_attr)
	else
		if not RichTextUtil.ignore_mark_list or not RichTextUtil.ignore_mark_list[mark] then
			ErrorLog("unknown mark:" .. mark .. "!")
		end
	end
end	

function RichTextUtil.Init()
	if nil == RichTextUtil.parse_func_list then
		RichTextUtil.parse_func_list = {
			["gamename"] = RichTextUtil.ParseGameName,
			["face"] = RichTextUtil.ParseFace,
			["point"] = RichTextUtil.ParsePoint,
			["newline"] = RichTextUtil.ParseNewLine,
			["i"] = RichTextUtil.ParseItem,
			["eq"] = RichTextUtil.ParseItem,
			["camp"] = RichTextUtil.ParseCamp,
			["r"] = RichTextUtil.ParseRole,
			["color"] = RichTextUtil.ParseWordColor,
			["wordcolor"] = RichTextUtil.ParseWordColor,
			["channelmark"] = RichTextUtil.ParseChannelMark,
			["team"] = RichTextUtil.ParseTeam,
			["guildinfo"] = RichTextUtil.ParseGuildInfo,
			["guildjoin"] = RichTextUtil.ParseGuildJoin,
			["money"] = RichTextUtil.ParseMoney,
			["monster"] = RichTextUtil.ParseMonster,
			["title"] = RichTextUtil.ParseTitle,
			["openLink"] = RichTextUtil.ParseOpenLink,
			["viewLink"] = RichTextUtil.ParseViewLink,
			["prof"] = RichTextUtil.ParseProf,
			["flag"] = RichTextUtil.ParseFlag,
			["star"] = RichTextUtil.ParseStar,
			["moveto"] = RichTextUtil.ParseMoveto,
			["pointto"] = RichTextUtil.ParsePointto,
			["rolename"] = RichTextUtil.ParseRoleName,
			["colorandsize"] = RichTextUtil.ParseWordColorAndSize,
			["teleport"] = RichTextUtil.ParseTeleport,
			["image"] = RichTextUtil.ParseImage,
			["enterDartsScene"] = RichTextUtil.ParseEnterDartsScene,
			["itemImageTip"] = RichTextUtil.ParseImageImageTip,
			["Linkitem"] = RichTextUtil.ParseLinkItem,
			["LinkBuy"] = RichTextUtil.ParseLinkBuy,
			["ZsVip"] = RichTextUtil.ParseZsVip,
			["CnNum"] = RichTextUtil.ParseCnNum,
			["ItemImgName"] = RichTextUtil.ItemImgName,
		}	
	end
	
	if nil == RichTextUtil.ignore_mark_list then
		RichTextUtil.ignore_mark_list = {
			["btn"] = 1,
			["checkbox"] = 1,
		}
	end
end

function RichTextUtil.ParseGameName(rich_text, params, font_size, color, ignored_link, text_attr)
	RichTextUtil.AddText(rich_text, CommonDataManager.GetGameName(), font_size, color, text_attr)
end

function RichTextUtil.ParseFace(rich_text, params, font_size, color, ignored_link, text_attr)
	local face_id = tonumber(params[2]) or 0
	if face_id >= 1 and face_id <= 32 then
		XUI.RichTextAddImage(rich_text, ResPath.GetFace(face_id), true)
	elseif face_id >= COMMON_CONSTS.BIGCHATFACE_ID_FIRST and face_id <= COMMON_CONSTS.BIGCHATFACE_ID_LAST then
		local anim_path, anim_name = ResPath.GetFaceEffectAnimPath(face_id)
		local eff = RenderUnit.CreateAnimSprite(anim_path, anim_name, 0.15, 20, nil)
		eff:setPosition(80 / 2, 50 / 2)
		local empty_node = cc.Node:create()
		empty_node:setContentSize(80, 50)
		empty_node:addChild(eff)
		XUI.RichTextAddElement(rich_text, empty_node)
	end
end

function RichTextUtil.ParseImage(rich_text, params, font_size, color, ignored_link, text_attr)
	local img_path = params[2]
	local content_size
	local size_scale = 1
	local offest_x = 0
	if params[3] then
		local size_params = Split(params[3], ",")
		content_size = cc.size(size_params[1] or 10, size_params[2] or 10)
	end
	if params[4] then
		size_scale = tonumber(params[4])
	end
	if params[5] then
		offest_x = tonumber(params[5])
	end
	if img_path then
		if content_size then
			local empty_node = cc.Node:create()
			empty_node:setContentSize(content_size)
			local img = XUI.CreateImageView(content_size.width / 2 + offest_x, content_size.height / 2, img_path, true)
			img:setScale(size_scale)
			empty_node:addChild(img)
			XUI.RichTextAddElement(rich_text, empty_node)
		else
			XUI.RichTextAddImage(rich_text, img_path, true)
		end
	end
end

function RichTextUtil.ParsePoint(rich_text, params, font_size, color, ignored_link, text_attr)
	if #params < 5 then return end
	
	local point_text = params[2] .. "(" .. params[3] .. "," .. params[4] .. ")"
	local btn = RichTextUtil.CreateBtn(point_text, font_size, color)
	if nil ~= btn then
		XUI.RichTextAddElement(rich_text, btn)
		
		if ignored_link then
			btn:setTouchEnabled(false)
		else
			btn:addClickEventListener(function()
				RichTextUtil.FlyToPos(tonumber(params[5]) or 0, tonumber(params[3]) or 0, tonumber(params[4]) or 0)
			end)
		end
	end
end

function RichTextUtil.ParseLinkItem(rich_text, params, font_size, color, ignored_link, text_attr)
	local link_name = params[2]
	local item_id = tonumber(params[3])
	local color = Str2C3b(params[4])
	local text_node = RichTextUtil.CreateLinkText(link_name, font_size, color, text_attr)
	XUI.AddClickEventListener(text_node, function()
			TipCtrl.Instance:OpenItem({item_id = item_id, num = 1, is_bind = 0})
		end, true)
	XUI.RichTextAddElement(rich_text, text_node)
end

function RichTextUtil.ParseLinkBuy( rich_text, params, font_size, color, ignored_link, text_attr)
	local link_name = params[2]
	local color = Str2C3b(params[3])
	local shop_type = tonumber(params[4])
	local text_node = RichTextUtil.CreateLinkText(link_name, font_size, color, text_attr)
	XUI.AddClickEventListener(text_node, function()
			if shop_type == 1 then
				ViewManager.Instance:OpenViewByDef(ViewDef.Shop.Prop)
			elseif shop_type == 2 then
				ViewManager.Instance:OpenViewByDef(ViewDef.Shop.Bind_yuan)
			end
		end, true)
	XUI.RichTextAddElement(rich_text, text_node)
end

-- 解析中文数字 RichTextUtil.ParseRichText(rich_node, string.format("{CnNum;%s}", num))
-- 23 => {2, 10, 3} => 二十三
-- 两位数
function RichTextUtil.ParseCnNum( rich_text, params, font_size, color, ignored_link, text_attr)
	local num = tonumber(params[2])
	local num_res_t = {}	-- 根据数字解析的资源表
	
	local function get_one_bit_num(num, unit)
		if unit == 1 then
			return num % 10
		end
		local last_residue_num = num % math.pow(10, unit - 1)
		local now_residue_num = num % math.pow(10, unit)
		return (now_residue_num - last_residue_num) / math.pow(10, unit - 1)
	end
	
	for unit = 1, 6 do
		local unit_range = 10 * unit
		if num >= 10 and num / unit_range < 1 then
			break
		end
		local per_num = get_one_bit_num(num, unit)
		if per_num == 0 then
		else
			table.insert(num_res_t, get_one_bit_num(num, unit))
		end

		if num / math.pow(10, unit) >= 1 then
			table.insert(num_res_t, unit_range)
		end
	end

	local space = -2		--间隙
	local per_w =  20		--单位宽度
	local design_h =  20	-- 高度
	local style = 1			--文字类型，即资源图片后缀

	local empty_node = cc.Node:create()
	empty_node:setContentSize(#num_res_t * per_w, design_h)

	for i = #num_res_t, 1, -1 do
		local img_path = ResPath.GetCommon("cn_num_" .. style .. "_" .. num_res_t[i])
		local img_num = XUI.CreateImageView((#num_res_t - i) * (per_w + space), design_h / 2, img_path, true)
		empty_node:addChild(img_num)
	end

	-- for k, res_num in ipairs(num_res_t) do
	-- 	local img_path = ResPath.GetCommon("cn_num_" .. style .. "_" .. res_num)
	-- 	local img_num = XUI.CreateImageView((k - 1) * (per_w + space), design_h / 2, img_path, true)
	-- 	empty_node:addChild(img_num)
	-- end

	XUI.RichTextAddElement(rich_text, empty_node)
end

-- 解析中文数字 RichTextUtil.ParseRichText(rich_node, string.format("{ItemImgName;%s}", num))
-- 23 => {2, 10, 3} => 二十三
-- 两位数
local type2comtype = {
	[27] = 27,
	[28] = 27,
	[29] = 27,
	[30] = 27,
	[31] = 27,
	[32] = 27,
	[33] = 27,
	[34] = 27,
	[35] = 27,
	[36] = 27,
	[37] = 27,
	[38] = 27,
}
local type2useType = {
	[26] = {
		[1] = 1,
		[2] = 1,
		[3] = 1,
		[4] = 1,
		[5] = 1,
		[6] = 1,
		[7] = 1,
		[8] = 1,
	},
}
function RichTextUtil.ItemImgName( rich_text, params, font_size, color, ignored_link, text_attr)
	local space = -20		--间隙
	local per_w =  20		--单位宽度
	local design_h =  20	-- 高度
	local style = 1			--文字类型，即资源图片后缀
	local all_w = 0

	local id = tonumber(params[2])
	local cfg = ItemData.Instance:GetItemConfig(id)
	local res_t = {}	-- 根据数字解析的资源表
	local useType = cfg.useType or 0
	local sconed_use_type = type2useType[cfg.type] and type2useType[cfg.type][useType] or useType

	local p_1 = "img_name_" .. cfg.type .. "_" .. useType 

	local itype = type2comtype[cfg.type] and type2comtype[cfg.type] or cfg.type
	local p_2 = "img_name_" .. itype .. "_" .. sconed_use_type .. "_" .. cfg.orderType
	
	if itype == ItemData.ItemType.itSpecialRing or itype == ItemData.ItemType.itGlove then
		res_t = {p_2, orderType ~= 1 and p_1 or nil }
		space = 10
	else
		res_t = {p_1, p_2}
	end


	for k, path in ipairs(res_t) do
		local img_path = ResPath.GetTipTitleName(path)
		local img = XUI.CreateImageView(0, 0, img_path, true)
		-- all_w = all_w + img:getContentSize().width
		local empty_node = cc.Node:create()
		empty_node:addChild(img)
		empty_node:setContentSize(img:getContentSize().width + space, img:getContentSize().height)
		XUI.RichTextAddElement(rich_text, empty_node)
	end

end

function RichTextUtil.ParseZsVip( rich_text, params, font_size, color, ignored_link, text_attr)
	local zs_lv = params[2]
	local level = zs_lv % ZsVipView.ENUM_JIE
	level = level == 0 and ZsVipView.ENUM_JIE or level
	local img_path = ResPath.GetScene("vip_icon_" .. math.ceil(zs_lv / ZsVipView.ENUM_JIE))
	local img_num_path = ResPath.GetScene("zs_vip_num_" .. level)

	local img_num = XUI.CreateImageView(0, 10, img_path, true)
	local img_num2 = XUI.CreateImageView(8, 5, img_num_path, true)
	local empty_node = cc.Node:create()
	empty_node:setContentSize(8, 20)
	empty_node:addChild(img_num)
	empty_node:addChild(img_num2)

	XUI.RichTextAddElement(rich_text, empty_node)
end

function RichTextUtil.ParseTeleport(rich_text, params, font_size, color, ignored_link, text_attr)
	if #params < 6 then return end
	
	local point_text = params[2]
	local btn = RichTextUtil.CreateBtn(point_text, font_size, color)
	if nil ~= btn then
		XUI.RichTextAddElement(rich_text, btn)
		if ignored_link then
			btn:setTouchEnabled(false)
		else
			btn:addClickEventListener(function()
				ChatCtrl.Instance:ClickHelpTran(params[3], params[4], params[5], params[6])
				-- ChatCtrl.SendHelpTranReq(params[3], params[4], params[5], params[6])
			end)
		end
	end
end

function RichTextUtil.ParseNewLine(rich_text, params, font_size, color, ignored_link, text_attr)
	RichTextUtil.AddText(rich_text, "\n", font_size, color, text_attr)
end

function RichTextUtil.ParseItem(rich_text, params, font_size, color, ignored_link, text_attr)
	if #params < 4 then return end
	local c = params[2] or 0
	local name = "【" .. params[3] .. "】"
	local item_param = Split(params[4], ":") or {}
	if tonumber(item_param[1]) <= 0 then return end
	local len = string.len(c)
	if len > 6 then
		color = Str2C3b(string.sub(c, len - 5, - 1)) or COLOR3B.WHITE
	elseif tonumber(c) and tonumber(c) > 0 then
		color = Str2C3b(string.sub(string.format("%06x", c), 1, 6)) or COLOR3B.WHITE
	else
		color = Str2C3b(c) or COLOR3B.WHITE
	end
	local text_node = RichTextUtil.CreateLinkText(name, font_size, color, text_attr, false)
	if nil ~= text_node then
		XUI.RichTextAddElement(rich_text, text_node)
		if not ignored_link then
			XUI.AddClickEventListener(text_node, function()
				TipCtrl.Instance:OpenItem(RichTextUtil.ParseServerItemParam(item_param), EquipTip.FROME_BROWSE_ROLE)
			end, true)
		end
	end
end


local rich_text_item_param_t = {
	[1] = "item_id",	-- 物品id
	[2] = "quality",	-- 物品的品质
	[3] = "strengthen_level",	-- 物品的强化
	[4] = "durability",	-- 物品的耐久
	[5] = "durability_max",	-- 物品的耐久上限
	[6] = "num",	-- 物品数量
	[7] = "flag",	-- 物品的过期时间
	[8] = "hand_pos",	-- 是左右还是右手
	[9] = "slot_1",	-- 物品第1个孔的信息
	[10] = "slot_2",	-- 物品第2个孔的信息
	[11] = "slot_3",	-- 物品第3个孔的信息
	[12] = "slot_4",	-- 物品第4个孔的信息
	[13] = "slot_5",	-- 物品第5个孔的信息
	[14] = "use_time",	-- 物品的使用时间
	[15] = "lucky_value",	-- 动态的幸运值或者诅咒值,祝福油加幸运，杀人减幸运
	[16] = "sharp",	-- 锋利值
	[17] = "type",	-- 物品类型
	-- [18] = "rune_boss_index",	-- boss符文索引, 客户端从1开始
	-- [19] = "rune_index",	-- 符文碎片索引, 客户端从1开始
	-- [20] = "_BaseAttr1",	-- 属性索引
	-- [21] = "_BaseAttr2",	-- 属性索引
	-- [22] = "_highestAttr3",	-- 极品属性索引
	-- [23] = "_highestAttr4",	-- 极品属性索引

	[29] = "ring_soul_level",	-- 神龙戒魂等级(客户端自定义)
	[30] = "hh_level",	-- 洪荒戒指等级(客户端自定义)
	[31] = "office_level",	-- 官印等级(客户端自定义)
}
function RichTextUtil.ParseServerItemParam(item_param)
	local item_data = CommonStruct.ItemDataWrapper()
	for k, v in pairs(item_param) do
		local key_name = rich_text_item_param_t[k]
		if nil ~= key_name then
			item_data[key_name] = tonumber(v or 0)
		end
	end

	local base_attr1 = tonumber(item_param[20] or 0)
	if item_data.type == ItemData.ItemType.itFashion
		or item_data.type == ItemData.ItemType.itWuHuan
		or item_data.type == ItemData.ItemType.itShengXiao then
		item_data.fashion_index = bit:_and(base_attr1, 0xff)
	elseif StoneData.IsStoneEquip(item_data.type) then
		item_data.fuling_level = bit:_and(base_attr1, 0xff)	-- 附灵等级
		item_data.fuling_exp = bit:_rshift(base_attr1, 8)	-- 附灵经验
	end

	return item_data
end

function RichTextUtil.CreateItemStr(item_data)
	local mark = ""
	local param_str = ""
	local config, item_type = ItemData.Instance:GetItemConfig(item_data.item_id)
	if nil == config then return end
	mark = "i"

	local param_data = {}
	for k, v in pairs(rich_text_item_param_t) do
		param_data[k] = tonumber(item_data[v] or 0)
	end
	local base_attr1 = 0
	if item_data.type == ItemData.ItemType.itFashion
		or item_data.type == ItemData.ItemType.itWuHuan
		or item_data.type == ItemData.ItemType.itShengXiao then
		base_attr1 = item_data.fashion_index
	elseif StoneData.IsStoneEquip(item_data.type) then
		base_attr1 = item_data.fuling_level + bit:_lshift(item_data.fuling_exp, 8)
	end
	param_data[20] = base_attr1

	param_str = param_data[1]
	for i = 2, 31 do
		param_str = param_str .. ":" .. (param_data[i] or 0)
	end
	
	return string.format("{%s;%s;%s;%s}", mark, string.format("%06x", config.color), config.name, param_str)
end

function RichTextUtil.ParseCamp(rich_text, params, font_size, color, ignored_link, text_attr)
	if nil ~= params[2] then
		local camp = tonumber(params[2])
		RichTextUtil.AddText(rich_text, Language.Common.CampName[camp], font_size, CAMP_COLOR3B[camp], text_attr)
	end
end

function RichTextUtil.ParseRole(rich_text, params, font_size, color, ignored_link, text_attr)
	if nil ~= params[3] then
		RichTextUtil.AddText(rich_text, params[3], font_size, COLOR3B.YELLOW, text_attr)
	end
end

function RichTextUtil.ParseWordColor(rich_text, params, font_size, color, ignored_link, text_attr)
	if #params < 3 then return end
	
	local len = string.len(params[2])
	if len >= 6 then
		RichTextUtil.AddText(rich_text, params[#params], font_size, Str2C3b(string.sub(params[2], len - 5, - 1)), text_attr)
	else
		RichTextUtil.AddText(rich_text, params[#params], font_size, Str2C3b(params[2]), text_attr)
	end
end

function RichTextUtil.ParseWordColorAndSize(rich_text, params, font_size, color, ignored_link, text_attr)
	if #params < 4 then return end
	
	local len = string.len(params[2])
	local size = tonumber(params[3])
	if len >= 6 then
		RichTextUtil.AddText(rich_text, params[#params], size, Str2C3b(string.sub(params[2], len - 5, - 1)), text_attr)
	else
		RichTextUtil.AddText(rich_text, params[#params], font_size, Str2C3b(params[2]), text_attr)
	end
end

function RichTextUtil.ParseChannelMark(rich_text, params, font_size, color, ignored_link, text_attr)
	local channel_type = params[2] or 0
	if tonumber(channel_type) ~= CHANNEL_TYPE.GUILD then
		XUI.RichTextAddImage(rich_text, ResPath.GetChatMark(channel_type), true)
	end
end

-- team
function RichTextUtil.ParseTeam(rich_text, params, font_size, color, ignored_link, text_attr)
	if #params < 3 then return end
	
	local btn = RichTextUtil.CreateBtn(params[2], font_size, color)
	if nil ~= btn then
		XUI.RichTextAddElement(rich_text, btn)
		
		if ignored_link then
			btn:setTouchEnabled(false)
		else
			btn:addClickEventListener(function()
				-- if GameVoManager.Instance:GetMainRoleVo().level < (tonumber(params[4]) or 0) then
				-- 	-- SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Society.NotJoinTeam, args.team_limit_lev or ""))
				-- else
				-- 	SocietyCtrl.Instance:JoinTeam(tonumber(params[3]) or 0)
				-- end
			end)
		end
	end
end

-- guildinfo
function RichTextUtil.ParseGuildInfo(rich_text, params, font_size, color, ignored_link, text_attr)
	if #params < 3 then return end
	
	local btn = RichTextUtil.CreateBtn(params[3], font_size, color)
	if nil ~= btn then
		XUI.RichTextAddElement(rich_text, btn)
		
		if ignored_link then
			btn:setTouchEnabled(false)
		else
			btn:addClickEventListener(function()
				-- GuildCtrl.Instance:IOpenGuildInfoView(tonumber(params[2]) or 0)
			end)
		end
	end
end

-- guildjoin
function RichTextUtil.ParseGuildJoin(rich_text, params, font_size, color, ignored_link, text_attr)
	local btn = RichTextUtil.CreateBtn(Language.Chat.JIARU ..(params[3] or ""), font_size, color)
	if nil ~= btn then
		XUI.RichTextAddElement(rich_text, btn)
		if ignored_link then
			btn:setTouchEnabled(false)
		else
			btn:addClickEventListener(function()
				-- GuildCtrl.Instance:SendJoinGuildReq(params[2])
			end)
		end
	end
end

-- money
function RichTextUtil.ParseMoney(rich_text, params, font_size, color, ignored_link, text_attr)
	if #params < 3 then return end
	
	local money_type_str = ""
	
	local money_type = tonumber(params[3]) or 0
	if 0 == money_type then
		money_type_str = Language.Common.Bind .. Language.Common.Coin
	elseif 1 == money_type then
		money_type_str = Language.Common.Bind .. Language.Common.Gold
	elseif 2 == money_type then
		money_type_str = Language.Common.Coin
	elseif 3 == money_type then
		money_type_str = Language.Common.Gold
	end
	
	RichTextUtil.AddText(rich_text, params[2], font_size, COLOR3B.YELLOW, text_attr)
	RichTextUtil.AddText(rich_text, money_type_str, font_size, color, text_attr)
end

--monster
function RichTextUtil.ParseMonster(rich_text, params, font_size, color, ignored_link, text_attr)
	-- local monster_config = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[tonumber(params[2]) or 0]
	-- if nil ~= monster_config and nil ~= monster_config.name then
	-- 	RichTextUtil.AddText(rich_text, monster_config.name, font_size, COLOR3B.YELLOW, text_attr)
	-- end
end

--title
function RichTextUtil.ParseTitle(rich_text, params, font_size, color, ignored_link, text_attr)
	local title_config = TitleData.GetTitleConfig(tonumber(params[2]) or 0)
	if nil ~= title_config and nil ~= title_config.name then
		RichTextUtil.AddText(rich_text, title_config.name, font_size, COLOR3B.YELLOW, text_attr)
	end
end

--openLink
function RichTextUtil.ParseOpenLink(rich_text, params, font_size, color, ignored_link, text_attr)
	if ignored_link then return end
	
	local link_type = tonumber(params[2]) or 0
	local link_cfg = RichTextUtil.GetOpenLinkCfg(link_type)
	local link_name = params[3]
	if nil == link_name then
		link_name = nil ~= link_cfg and link_cfg.name or "unknown link type:" .. link_type
	end
	local text_node = RichTextUtil.CreateLinkText(link_name, font_size, color, text_attr)
	if nil ~= text_node then
		XUI.RichTextAddElement(rich_text, text_node)
		XUI.AddClickEventListener(text_node, function()
			RichTextUtil.DoByLinkType(link_type, params[3], params[4], params[5])
		end, true)
	end
end

--viewLink
function RichTextUtil.ParseViewLink(rich_text, params, font_size, color, ignored_link, text_attr)
	if ignored_link then return end
	
	local view_param = params[2] or ""
	local link_name = params[3] or "unknown link view"
	local text_node = RichTextUtil.CreateLinkText(link_name, font_size, color, text_attr)
	if nil ~= text_node then
		XUI.RichTextAddElement(rich_text, text_node)
		XUI.AddClickEventListener(text_node, function()
			ViewManager.Instance:OpenViewByStr(view_param)
		end, true)
	end
end

--rolename
function RichTextUtil.ParseRoleName(rich_text, params, font_size, color, ignored_link, text_attr)
	local c = params[2] or 0
	local len = string.len(c)
	if len > 6 then
		color = Str2C3b(string.sub(c, len - 5, - 1)) or COLOR3B.WHITE
	else
		color = Str2C3b(c) or COLOR3B.WHITE
	end
	local name = params[3] or ""
	local role_id = tonumber(params[4]) or 0
	if RoleData.Instance:GetAttr("name") ~= name and not ignored_link then
		if nil == RichTextUtil.role_head then
			RichTextUtil.role_head = RoleHeadCell.New(false, false)
		end
		local text_node = RichTextUtil.CreateLinkText(name, font_size, color, text_attr, false)
		if nil ~= text_node then
			XUI.RichTextAddElement(rich_text, text_node)
			XUI.AddClickEventListener(text_node, function()
				RichTextUtil.role_head:SetRoleInfo(role_id, name)
				RichTextUtil.role_head:OpenMenu()
			end, true)
		end
	else
		RichTextUtil.AddText(rich_text, name, font_size, color, text_attr)
	end
end

--prof
function RichTextUtil.ParseProf(rich_text, params, font_size, color, ignored_link, text_attr)
	local prof_name = Language.Common.ProfName[tonumber(params[2] or 0)] or ""
	RichTextUtil.AddText(rich_text, prof_name, font_size, COLOR3B.YELLOW, text_attr)
end

--flag
function RichTextUtil.ParseFlag(rich_text, params, font_size, color, ignored_link, text_attr)
	local node = cc.Node:create()
	node:setContentSize(font_size, font_size)
	
	img = XUI.CreateImageView(font_size / 2, font_size / 2, ResPath.GetCommon("orn_100"), true)
	node:addChild(img)
	
	XUI.RichTextAddElement(rich_text, node)
end

function RichTextUtil.ParseStar(rich_text, params, font_size, color, ignored_link, text_attr)
	RichTextUtil.old_star_params = params
	local cur_count, total_count =(tonumber(params[2]) or 0),(tonumber(params[3]) or 0)
	if total_count > 0 then
		local node = cc.Node:create()
		node:setContentSize(total_count * 30, 30)
		XUI.RichTextAddElement(rich_text, node)
		
		local star = nil
		for i = 1, total_count do
			if i <= cur_count then
				star = XUI.CreateImageView(i * 30 - 15, 15, ResPath.GetCommon("star_1_select"), true)
				RenderUnit.CreateEffect(911, star)
				star:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4, 1.3), cc.ScaleTo:create(0.3, 1)))
			else
				star = XUI.CreateImageView(i * 30 - 15, 15, ResPath.GetCommon("star_1_lock"), true)
			end
			node:addChild(star)
		end
	end
end

function RichTextUtil.GetParseStarLastParams()
	return RichTextUtil.old_star_params
end

-- 飞到某位置Scene
function RichTextUtil.ParsePointto(rich_text, params, font_size, color, ignored_link, text_attr)
	if #params < 5 then return end
	
	local text_node = RichTextUtil.CreateLinkText(params[5], font_size, color, text_attr)
	if nil ~= text_node then
		XUI.RichTextAddElement(rich_text, text_node)
		XUI.AddClickEventListener(text_node, function()
			MoveCache.end_type = MoveEndType.Normal
			GuajiCtrl.Instance:FlyBySceneId(tonumber(params[2]), tonumber(params[3]), tonumber(params[4]))
		end, true)
	end
end

-- 飞到某位置NPC
function RichTextUtil.ParseMoveto(rich_text, params, font_size, color, ignored_link, text_attr)
	if #params < 3 then return end
	
	local text_node = RichTextUtil.CreateLinkText(params[3], font_size, color, text_attr)
	if nil ~= text_node then
		XUI.RichTextAddElement(rich_text, text_node)
		XUI.AddClickEventListener(text_node, function()
			MoveCache.end_type = MoveEndType.Normal
			GuajiCtrl.Instance:FlyByIndex(tonumber(params[2]))
		end, true)
	end
end

-- 飞到某劫镖位置
function RichTextUtil.ParseEnterDartsScene(rich_text, params, font_size, color, ignored_link, text_attr)
	if #params < 5 then return end
	
	local text_node = RichTextUtil.CreateLinkText(params[5], font_size, color, text_attr)
	if nil ~= text_node then
		XUI.RichTextAddElement(rich_text, text_node)
		XUI.AddClickEventListener(text_node, function()
			MoveCache.end_type = MoveEndType.Normal
			GuajiCtrl.Instance:FlyByRobEscort(tonumber(params[2]), tonumber(params[3]), tonumber(params[4]))
		end, true)
	end
end

function RichTextUtil.ParseImageImageTip(rich_text, params, font_size, color, ignored_link, text_attr)
	local img_path = params[2]
	local content_size
	local size_scale = 1
	if params[3] then
		local size_params = Split(params[3], ",")
		content_size = cc.size(size_params[1] or 10, size_params[2] or 10)
	end
	if params[4] then
		size_scale = tonumber(params[4])
	end
	local is_show_tips = tonumber(params[6]) or 0
	-- if img_path then
	-- 	if content_size then
	-- 		
	-- 	
	-- 	else
	-- 		XUI.RichTextAddImage(rich_text, img_path, true)
	-- 	end
	-- end
		local empty_node = cc.Node:create()
		empty_node:setContentSize(content_size)
		local img = XUI.CreateImageView(content_size.width / 2, content_size.height / 2, img_path, true)
		img:setScale(size_scale)
		empty_node:addChild(img)
		XUI.RichTextAddElement(rich_text, empty_node)
		XUI.AddClickEventListener(img, function ( ... )
			if is_show_tips > 0 then
				TipCtrl.Instance:OpenItem({item_id = tonumber(params[5])})
			end
		end, false)
end

-- 创建按钮
function RichTextUtil.CreateBtn(text, font_size, color)
	if nil == text or nil == color then
		ErrorLog("RichTextUtil.CreateBtn")
		return nil
	end
	
	if nil == RichTextUtil.CHAT_ITEM_BG then
		RichTextUtil.CHAT_ITEM_BG = ResPath.GetCommon("img9_101")
	end
	local btn = XButton:create9Sprite(RichTextUtil.CHAT_ITEM_BG)
	btn:setTitle(text, color, font_size, COMMON_CONSTS.FONT)
	local size = btn:getTitleLabel():getContentSize()
	btn:setContentWH(size.width + 12, size.height + 5)
	
	btn:setHittedScale(1.05)
	
	return btn
end

-- 创建链接文本
function RichTextUtil.CreateLinkText(text, font_size, color, text_attr, under_line)
	if nil == text or nil == color then
		ErrorLog("RichTextUtil.CreateLinkText")
		return nil
	end
	under_line = under_line == nil and true or under_line
	local text_node = XText:create(text, COMMON_CONSTS.FONT, font_size or 20)
	text_node:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
	text_node:setColor(color)
	text_node:setUnderLine(under_line)
	if nil ~= text_attr then
		text_node:setOpacity(opacity or 255)
		if nil ~= text_attr.shadow_offset then
			-- text_node:enableShadow(COLOR4B.BLACK, text_attr.shadow_offset)
		end
		if nil ~= text_attr.outline_size and text_attr.outline_size > 0 then
			text_node:enableOutline(COLOR4B.BLACK, text_attr.outline_size)
		end
	end
	
	text_node:setHittedScale(1.05)
	
	return text_node
end

function RichTextUtil.FlyToPos(scene_id, x, y)
	MoveCache.task_id = 0
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0)
end

--点击链接类型
function RichTextUtil.DoByLinkType(link_type, param1, param2, param3)
	local link_cfg = RichTextUtil.GetOpenLinkCfg(link_type)
	if nil == link_cfg then
		Log("请先配置", link_type)
		return
	end
	
	ViewManager.Instance:Open(link_cfg.view_name, link_cfg.view_index)
	
	if link_type == 181 then
		OpenServiceAcitivityCtrl.Instance:SelectGiftViewIndex(OPEN_SERVER_GIFT_INDEX.RING_GIFT)
	end
end

function RichTextUtil.GetOpenLinkCfg(link_type)
	if nil == RichTextUtil.link_cfg_list then
		RichTextUtil.link_cfg_list = {
			[170]   = {view_def = ViewDef.ChargeFirst}, -- 首充奖励
			[270]   = {view_def = ViewDef.Escort}, -- 护送镖车
		}
	end
	
	return RichTextUtil.link_cfg_list[link_type]
end


function RichTextUtil.ParseBtnTable(content)
	local t = RichTextUtil.Parse2Table(content)
	
	local btn_t = {}
	for k, v in pairs(t) do
		if v[1] and v[1] == "btn" then
			local btn_cfg = {}
			btn_cfg.style = v[2] or 0
			btn_cfg.text = v[3]
			btn_cfg.func_name = v[4]
			table.insert(btn_t, btn_cfg)
		end
	end
	
	return btn_t
end

function RichTextUtil.ParseCheckBoxTable(content)
	local t = RichTextUtil.Parse2Table(content)
	
	local checkbox_t = {}
	for k, v in pairs(t) do
		if v[1] and v[1] == "checkbox" then
			local checkbox_cfg = {}
			checkbox_cfg.style = v[2] or 0
			checkbox_cfg.desc = v[3]
			table.insert(checkbox_t, checkbox_cfg)
		end
	end
	
	return checkbox_t
end

function RichTextUtil.ParseRewardItemTable(content)
	local t = RichTextUtil.Parse2Table(content)
	
	local temp_t = {}
	for k, v in pairs(t) do
		if v[1] and v[1] == "reward" then
			local temp_cfg = {}
			temp_cfg.item_type = v[2] or 0
			temp_cfg.item_id = v[3]
			temp_cfg.num = v[4] or 0
			table.insert(temp_t, temp_cfg)
		end
	end
	return temp_t
end 
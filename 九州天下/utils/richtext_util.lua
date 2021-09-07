RichTextUtil = RichTextUtil or BaseClass()

local is_small_value = false
local is_not_target = false
local guild_welcome_time = 0

RichTextUtil.TextStr = ""

--是输出文本的需要写在这（AddText操作的为输出文本）!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!非输出文本不要写在这
RichTextUtil.Textlist = {
	["gamename"] = true,
	["camp"] = true,
	["camp_info"] = true,
	["camp_officer"] = true,
	["officer"] = true,
	["r"] = true,
	["r2"] = true,
	["r3"] = true,
	["wordcolor"] = true,
	["wordsColor"] = true,
	["guildinfo"] = true,
	["guildinfo2"] = true,
	["money"] = true,
	["chinese_num"] = true,
	["wing_grade"] = true,
	["mount_grade"] = true,
	["to_decimal"] = true,
	["monster"] = true,
	["red_paper"] = true,
	["activity"] = true,
	["prof"] = true,
	["hunshou"] = true,
	["chengjiu_title"] = true,
	["taozhuang"] = true,
	["bubble"] = true,
	["cross_team_fb"] = true,
	["halo_grade"] = true,
	["jingling_halo_grade"] = true,
	["jingling_fazhen_grade"] = true,
	["fazhen_grade"] = true,
	["cardzu"] = true,
	["shengong_grade"] = true,
	["shenyi_grade"] = true,
	["fightmount_grade"] = true,
	["newline"] = true,
	["title"] = true,
	["mojie"] = true,
	["role_level"] = true,
	["equipsuit_ss"] = true,
	["equipsuit_cs"] = true,
	["territory"] = true,
	["xiannv_name"] = true,
	["guildpost"] = true,
	["shenzhou_weapon"] = true,
	["shenzhou_skill"] = true,
	["identify_level"] = true,
	["element_name"] = true,
	["shenge"] = true,
	["xufucili_func_type"] = true,
	["percent"] = true,
	["citan_color"] = true,
	["rank_type"] = true,
	["gouyu_level"] = true,
	["xiannv_shengwu"] = true,
	["xiannv_shengwu_skill"] = true,
	["shenqi_type"] = true,
	["junxian_level"] = true,
	["junxian_star"] = true,
	["cross_mineral"] = true,
	["cross_fish"] = true,
	["dimai"] = true,
	["zhangkong"] = true,
	["unlock_junxian_level"] = true,
	["ranking_num"] = true,
	["fqzz_func_type"] = true,
	["touxian_level"] = true,
	["time"] = true,
	["camp_grade"] = true,
	["cross_xyjd"] = true,
	["xycity_worker"] = true,
	["csa_sub_type"] = true,
	["zymb_true_word"] = true,
	["hochi_card"] = true,
	["hochi_suit"] = true,
	["avatar"] = true,
	["ugs_head_wear_grade"] = true,
	["ugs_mask_grade"] = true,
	["ugs_waist_grade"] = true,
	["ugs_kirin_grade"] = true,
	["ugs_bead_grade"] = true,
	["ugs_fabao_grade"] = true,
}

------------------------------注意-----------------------------------
--如果输出的是文本记得Textlist一定也要加(方便计算文本的数量，同时减少AddText的操作，优化性能)
--------------------------------------------------------------------
function RichTextUtil.Init()
	if nil == RichTextUtil.parse_func_list then
		RichTextUtil.parse_func_list = {
			["showpos"] = RichTextUtil.ParseShowPos,
			["gamename"] = RichTextUtil.ParseGameName,
			["face"] = RichTextUtil.ParseFace,
			["point"] = RichTextUtil.ParsePoint,
			["helppoint"] = RichTextUtil.ParseHelpPoint,
			["scene"] = RichTextUtil.ParseScene,
			["sceneid"] = RichTextUtil.ParseSceneId,
			["newline"] = RichTextUtil.ParseNewLine,
			["i"] = RichTextUtil.ParseItem,
			["myi"] = RichTextUtil.ParseMyItem,
			["myeq"] = RichTextUtil.ParseMyItem,
			["eq"] = RichTextUtil.ParseItem,
			["camp"] = RichTextUtil.ParseCamp,
			["camp_info"] = RichTextUtil.ParseCampInfo,
			["camp_officer"] = RichTextUtil.ParseCampOfficer,
			["officer"] = RichTextUtil.ParseOfficer,
			["r"] = RichTextUtil.ParseRole,
			["r2"] = RichTextUtil.ParseRole2,
			["r3"] = RichTextUtil.ParseRole3,
			["wordcolor"] = RichTextUtil.ParseWordColor,
			["wordsColor"] = RichTextUtil.ParseWordColor,
			["channelmark"] = RichTextUtil.ParseChannelMark,
			["team"] = RichTextUtil.ParseTeam,
			["teamfb"] = RichTextUtil.ParseTeamFb,
			["guildinfo"] = RichTextUtil.ParseGuildInfo,
			["guildinfo2"] = RichTextUtil.ParseGuildInfo2,
			["guildjoin"] = RichTextUtil.ParseGuildJoin,
			["money"] = RichTextUtil.ParseMoney,
			["chinese_num"] = RichTextUtil.ParseChineseNum,
			["zhuxie_task_item"] = RichTextUtil.ParseZhuXieTaskItem,
			["wing_grade"] = RichTextUtil.ParseWingGrade,
			["wing_name"] = RichTextUtil.ParseWingName,
			["fazhen_name"] = RichTextUtil.ParseFaZhenName,
			["defend_area"] = RichTextUtil.ParseDefendArea,
			["mount_grade"] = RichTextUtil.ParseMountGrade,
			["qibing"] = RichTextUtil.ParseQiBing,
			["to_decimal"] = RichTextUtil.ParseToDecimal,
			["monster"] = RichTextUtil.ParseMonster,
			["title"] = RichTextUtil.ParseTitle,
			["eq_shenzhu"] = RichTextUtil.ParseEquipShenZhu,
			["eq_quality"] = RichTextUtil.ParseEquipQuality,
			["stone"] = RichTextUtil.ParseStone,
			["csa_sub_type"] = RichTextUtil.ParseCsaSubType,
			["openLink"] = RichTextUtil.ParseOpenLink,
			["qingyuan_card"] = RichTextUtil.ParseQingYuanCard,
			["red_paper"] = RichTextUtil.ParseRedPaper,
			["activityPos"] = RichTextUtil.ParseActivityPos,
			["activity"] = RichTextUtil.ParseActivity,
			["prof"] = RichTextUtil.ParseProf,
			["mountfly"] = RichTextUtil.ParseMountFly,
			["hunshou"] = RichTextUtil.ParseHunShou,
			["chengjiu_title"] = RichTextUtil.ParseChengJiuTitle,
			["xianjie"] = RichTextUtil.ParseXianJie,
			["card_color"] = RichTextUtil.ParseCardColor,
			["card"] = RichTextUtil.ParseCard,
			["gengu_title"] = RichTextUtil.ParseGengu,
			["jingmai_title"] = RichTextUtil.ParseJingmai,
			["mentality"] = RichTextUtil.ParseMentality,
			["shenzhuang"] = RichTextUtil.ParseShenzhuang,
			["jinglingyun"] = RichTextUtil.ParseSpriteCloud,
			["jinglingslot"] = RichTextUtil.ParseSpriteSlot,
			["taozhuang"] = RichTextUtil.ParseTaozhuang,
			["pet_suit_seq"] = RichTextUtil.ParsePet,
			["mine"] = 	RichTextUtil.ParseMine,
			["cardzu"] = RichTextUtil.ParseCardzu,
			["fanfan"] = RichTextUtil.ParseFanFanZhuan,
			["cross_tuanzhan_side"] = RichTextUtil.ParseTuanZhan,
			["multimount"] = RichTextUtil.ParseMulitMount,
			["bubble"] = RichTextUtil.ParseBubble,
			["magic_card"] = RichTextUtil.ParseMagicCard,
			["fish"] = RichTextUtil.ParseFishPond,
			["cross_team_fb"] = RichTextUtil.ParseFindCrossTeammates,
			["guildback"] = RichTextUtil.ParseGuildBack,
			["halo_grade"] = RichTextUtil.ParseHaloGrade,
			["jingling_halo_grade"] = RichTextUtil.ParseBeautyHaloGrade,
			["jingling_fazhen_grade"] = RichTextUtil.ParseHaildomGrade,
			["fazhen_grade"] = RichTextUtil.ParseFaZhenGrade,
			["shengong_grade"] = RichTextUtil.ParseFoot,
			["shenyi_grade"] = RichTextUtil.ParseMantleGrade,
			["fightmount_grade"] = RichTextUtil.ParseFightMount,
			["mojie"] = RichTextUtil.ParseMojie,
			["role_level"] = RichTextUtil.ParseRoleLevel,
			["equipsuit_ss"] = RichTextUtil.ParseForgeSuitSS,
			["equipsuit_cs"] = RichTextUtil.ParseForgeSuitCS,
			["territory"] = RichTextUtil.ParseTerritory,
			["xiannv_name"] = RichTextUtil.FamousXiannv,
			["guildpost"] = RichTextUtil.ParseGuildPost,
			["shenzhou_weapon"] = RichTextUtil.ParseHunQiName,
			["shenzhou_skill"] = RichTextUtil.ParseHunQiSkill,
			["help_baoxiang"] = RichTextUtil.ParseHelpBaoXiang,
			["visible_level"] = RichTextUtil.ParsePass,
			["shenge"] = RichTextUtil.ParseShenGe,
			["identify_level"] = RichTextUtil.ParseIdentifyLevel,
			["element_name"] = RichTextUtil.ParseElementName,
			["xufucili_func_type"] = RichTextUtil.Xufucili,
			["percent"] = RichTextUtil.ParsePercent,
			["citan_color"] = RichTextUtil.CitanColor,
			["rank_type"] = RichTextUtil.RankType,
			["gouyu_level"] = RichTextUtil.GouyuLevel,
			["xiannv_shengwu"] = RichTextUtil.ParseShengWu,
			["xiannv_shengwu_skill"] = RichTextUtil.ParseShengWuSkill,
			["shenqi_type"] = RichTextUtil.ParseShengQi,
			["junxian_level"] = RichTextUtil.ParseJXLevel,
			["junxian_star"] = RichTextUtil.ParseJXStar,
			["cross_mineral"] = RichTextUtil.ParseCrossMine,
			["cross_fish"] = RichTextUtil.CrossFish,
			["dimai"] = RichTextUtil.DiMai,
			["zhangkong"] = RichTextUtil.ParseZhangKong,
			["top_type"] = RichTextUtil.ParseTopType,
			["unlock_junxian_level"] = RichTextUtil.UnloclJunXian,
			["ranking_num"] = RichTextUtil.RankingNum,
			["fqzz_func_type"] = RichTextUtil.FQZZFUNCTYPE,
			["touxian_level"] = RichTextUtil.TouXianLevel,
			["time"] = RichTextUtil.CampTime,
			["camp_grade"] = RichTextUtil.CampGrade,
			["server_group"] = RichTextUtil.ServerGroup,
			["cross_xyjd"] = RichTextUtil.CrossXyjd,
			["xycity_worker"] = RichTextUtil.XycityWorker,
			["zymb_true_word"] = RichTextUtil.ZymbTrueWord,
			["hochi_card"] = RichTextUtil.HoChiCard,
			["hochi_suit"] = RichTextUtil.HoChiSuit,
			["avatar"] = RichTextUtil.ParseAvatar,
			["ugs_head_wear_grade"] = RichTextUtil.HeadWearGrade,
			["ugs_mask_grade"] = RichTextUtil.MaskGrade,
			["ugs_waist_grade"] = RichTextUtil.WaistGrade,
			["ugs_kirin_grade"] = RichTextUtil.KirinGrade,
			["ugs_bead_grade"] = RichTextUtil.BeadGrade,
			["ugs_fabao_grade"] = RichTextUtil.FabaoGrade,
 		}
	end
end

-- not_target 按钮可穿透, font_size已没用但是去掉太麻烦就不管了
function RichTextUtil.ParseRichText(rich_text, content, font_size, color, is_small, not_target, adjust_font)
	if nil == rich_text or nil == content then return end
	-- 先清空rich_text
	RichTextUtil.TextStr = ""
	rich_text:Clear()

	--记录是否显示小图
	is_small_value = is_small

	is_not_target = not_target

	font_size = font_size or 20
	color = color or COLOR.WHITE

	content = CommonDataManager.ParseGameName(content)
	local i, j = 0, 0
	local element_list = {}
	local last_pos = 1
	for loop_count = 1, 100 do
		i, j = string.find(content, "({.-})", j + 1)-- 匹配规则{face;20} {item;26000}
		if nil == i or nil == j then
			if last_pos <= #content then
				table.insert(element_list, {0, string.sub(content, last_pos, -1)})
			end
			break
		else
			if 1 ~= i and last_pos ~= i then
				table.insert(element_list, {0, string.sub(content, last_pos, i - 1)})
			end
			table.insert(element_list, {1, string.sub(content, i, j)})
			last_pos = j + 1
		end
	end
	local rule
	for i2, v2 in ipairs(element_list) do
		if 0 == v2[1] then
			RichTextUtil.AddText(rich_text, v2[2], color)
		else
			rule = string.sub(v2[2], 2, -2)
			if Split(rule, ";")[1] ~= "showpos" then
				RichTextUtil.ParseMark(rich_text, Split(rule, ";"), font_size, color, adjust_font)
			end
		end
	end
	if RichTextUtil.TextStr ~= "" then
		rich_text:AddText(RichTextUtil.TextStr)
		RichTextUtil.TextStr = ""
	end
end

--获取解析后的字符串(纯文本的情况下可调用)
function RichTextUtil.GetAnalysisText(content, color)
	RichTextUtil.TextStr = ""
	color = color or COLOR.WHITE
	local i, j = 0, 0
	local element_list = {}
	local last_pos = 1
	for loop_count = 1, 100 do
		i, j = string.find(content, "({.-})", j + 1)-- 匹配规则{face;20} {item;26000}
		if nil == i or nil == j then
			if last_pos <= #content then
				table.insert(element_list, {0, string.sub(content, last_pos, -1)})
			end
			break
		else
			if 1 ~= i and last_pos ~= i then
				table.insert(element_list, {0, string.sub(content, last_pos, i - 1)})
			end
			table.insert(element_list, {1, string.sub(content, i, j)})
			last_pos = j + 1
		end
	end
	local rule
	for i2, v2 in ipairs(element_list) do
		if 0 == v2[1] then
			RichTextUtil.AddText(nil, v2[2], color)
		else
			rule = string.sub(v2[2], 2, -2)
			RichTextUtil.ParseMark(nil, Split(rule, ";"), nil, color)
		end
	end
	return RichTextUtil.TextStr
end

--添加文字
function RichTextUtil.AddText(rich_text, text, color)
	local str = text
	if color then
		str = ToColorStr(text, color)
	end
	RichTextUtil.TextStr = string.format("%s%s", RichTextUtil.TextStr, str)
end

--添加按钮
function RichTextUtil.CreateBtn(rich_text, name, font_size, color, callback, btn_bg_path)
	local button_name = ToColorStr(name, color)
	btn_bg_path = btn_bg_path or "Button11"
	local function GetButtonObj()
		if is_not_target then
			return GameObject.Instantiate(
					PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "RichButtonNotTarget"))
		else
			return GameObject.Instantiate(
					PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "RichButton"))
		end
	end
	local obj = GetButtonObj()
	if obj then
		--改变底图
		local variable_table = obj:GetComponent(typeof(UIVariableTable))
		if variable_table then
			local bg_image = variable_table:FindVariable("BgImage")
			local bubble, asset = ResPath.GetImages(btn_bg_path)
			bg_image:SetAsset(bubble, asset)

			--改变文本
			local content = variable_table:FindVariable("Content")
			content:SetValue(button_name)
		end

		rich_text:AddObject(obj)

		local button_node = U3DObject(obj.gameObject, obj)

		if callback then
			callback(button_node.button)
		end
	end
end

--添加下划线按钮
function RichTextUtil.CreateUnderLineBtn(rich_text, name, font_size, color, callback, btn_bg_path, adjust_font)
	local button_name = ToColorStr(name, color)
	btn_bg_path = btn_bg_path or BUTTON_BG_NAME[GameEnum.ITEM_COLOR_WHITE]
	local function GetButtonObj()
		if is_not_target then
			return GameObject.Instantiate(
					PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "RichButtonNotTarget2"))
		else
			return GameObject.Instantiate(
					PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "RichButton2"))
		end
	end
	local obj = GetButtonObj()
	if obj then
		--改变底图
		local variable_table = obj:GetComponent(typeof(UIVariableTable))
		if variable_table then
			local bg_image = variable_table:FindVariable("BgImage")
			local bubble, asset = ResPath.GetMainUI(btn_bg_path)
			bg_image:SetAsset(bubble, asset)

			--改变文本
			local content = variable_table:FindVariable("Content")
			content:SetValue(button_name)
		end

		if adjust_font then
			local temp_transform = obj.transform:Find("Text").transform
			name_obj = temp_transform:GetComponent(typeof(UnityEngine.UI.Text))
			if name_obj ~= nil then
				name_obj.fontSize = font_size
			end
		end

		rich_text:AddObject(obj)

		local button_node = U3DObject(obj.gameObject, obj)

		if callback then
			callback(button_node.button)
		end
	end
end

--添加图片
function RichTextUtil.CreateImage(rich_text, bubble, asset)
	local function GetImgObj()
		if is_small_value then
			return GameObject.Instantiate(
					PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "RichImage_Small"))
		else
			return GameObject.Instantiate(
					PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "RichImage"))
		end
	end
	local obj = GetImgObj()
	if obj then
		local image_node = U3DObject(obj.gameObject, obj)
		image_node.image:LoadSprite(bubble, asset)
		rich_text:AddObject(obj)
	end
end

-- 添加大表情
function RichTextUtil.CreateBigFace(rich_text, index)
	local bundle, asset = ResPath.GetMiscPreloadRes(is_small_value and "BigfaceSlotSmall" or "BigfaceSlot")
	local slot_obj = U3DObject(GameObject.Instantiate(PreloadManager.Instance:GetPrefab(bundle, asset)))
	local is_small = is_small_value
	rich_text:AddObject(slot_obj.gameObject)

	bundle, asset = ResPath.GetResBigFaceByIndex(index, is_small_value and "ImageSmall" .. index or "Image" .. index)
	UtilU3d.PrefabLoad(bundle, asset, function(obj)
		if nil == obj then
			return
		end

		if is_small then -- prefab里的坐标是乱搞的，太多先在程序里统一改
			local rect_t = obj:GetComponent(typeof(UnityEngine.RectTransform))
			rect_t.anchorMin = Vector2(0.5, 0.5)
			rect_t.anchorMax = Vector2(0.5, 0.5)
			obj.transform:SetLocalPosition(0, 0, 0)
		end

		obj.transform:SetParent(slot_obj.transform, false)
	end)
end

-- 添加普通动态表情
function RichTextUtil.CreateNormalFace(rich_text, index)
	local bundle, asset = ResPath.GetMiscPreloadRes(is_small_value and "NormalfaceSlotSmall" or "NormalfaceSlot")
	local slot_obj = U3DObject(GameObject.Instantiate(PreloadManager.Instance:GetPrefab(bundle, asset)))
	local is_small = is_small_value
	rich_text:AddObject(slot_obj.gameObject)

	local new_index = 100 + index - 1
	bundle, asset = ResPath.GetResNormalFaceByIndex(new_index, "Image" .. new_index)
	UtilU3d.PrefabLoad(bundle, asset, function(obj)
		if nil == obj then
			return
		end

		if IsNil(slot_obj.transform)  then
			GameObject.Destroy(obj.gameObject)
			return
		end

		if is_small then -- prefab里的坐标是乱搞的，太多先在程序里统一改
			local rect_t = obj:GetComponent(typeof(UnityEngine.RectTransform))
			rect_t.anchorMin = Vector2(0.5, 0.5)
			rect_t.anchorMax = Vector2(0.5, 0.5)
			obj.transform:SetLocalPosition(0, 0, 0)
		end
		local scale = is_small and 0.7 or 0.9
		obj.transform.localScale = Vector3(scale, scale, scale)
		obj.transform:SetParent(slot_obj.transform, false)
	end)
end

-- 添加特殊表情
function RichTextUtil.CreateSpecial(rich_text, index)
	local function GetSpecialObj()
		if is_small_value then
			return GameObject.Instantiate(
					PreloadManager.Instance:GetPrefab(ResPath.GetResSpecialFace("ImageSmall" .. index)))
		else
			return GameObject.Instantiate(
					PreloadManager.Instance:GetPrefab(ResPath.GetResSpecialFace("Image" .. index)))
		end
	end
	local obj = GetSpecialObj()
	if obj then
		rich_text:AddObject(obj)
	end
end

function RichTextUtil.ParseMark(rich_text, params, font_size, color, adjust_font)
	local mark = params[1]
	if nil == mark then return end

	RichTextUtil.Init()

	local func = RichTextUtil.parse_func_list[mark]
	local text_add = RichTextUtil.Textlist[mark]

	if func then
		if not text_add and RichTextUtil.TextStr ~= "" then
			if rich_text then
				rich_text:AddText(RichTextUtil.TextStr)
				RichTextUtil.TextStr = ""
			end

		end
		if rich_text then
			func(rich_text, params, font_size, color, adjust_font)
		else
			func(nil, params, font_size, color, adjust_font)
		end
	else
		-- 临时屏弊，稳定后请开启
		-- print_error("unknown mark:" .. mark .. "!")
	end
end

--不做任何处理
function RichTextUtil:ParsePass()

end

function RichTextUtil.ParseShowPos(rich_text, params, font_size, color)

end

function RichTextUtil.ParseGameName(rich_text, params, font_size, color)
	RichTextUtil.AddText(rich_text, CommonDataManager.GetGameName(), color)
end

function RichTextUtil.ParseFace(rich_text, params, font_size, color)
	local face_id = tonumber(params[2]) or 0
	if face_id >= 1 and face_id < COMMON_CONSTS.BIGCHATFACE_ID_FIRST then
		-- RichTextUtil.CreateImage(rich_text, ResPath.GetEmoji(face_id))
		RichTextUtil.CreateNormalFace(rich_text, face_id)
	elseif face_id >= COMMON_CONSTS.BIGCHATFACE_ID_FIRST and face_id < COMMON_CONSTS.SPECIALFACE_ID_FIRST then
		local id = face_id - COMMON_CONSTS.BIGCHATFACE_ID_FIRST
		RichTextUtil.CreateBigFace(rich_text, id)
	elseif face_id >= COMMON_CONSTS.SPECIALFACE_ID_FIRST then
		local id = face_id - COMMON_CONSTS.SPECIALFACE_ID_FIRST
		RichTextUtil.CreateSpecial(rich_text, id)
	end
end

function RichTextUtil.ParsePoint(rich_text, params, font_size, color)
	if #params < 6 then return end
	local point_text = params[2] .. "(" .. params[3] .. "," .. params[4] .. ")"
	-- if tonumber(params[6]) >= 0 then
	-- 	point_text = string.format(Language.Common.Line, CommonDataManager.GetDaXie(tonumber(params[6]) + 1)) .. point_text
	-- end
	local function callback(btn)
		if nil ~= btn then
			btn:SetClickListener(function()
				GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
				if tonumber(params[6]) >= 0 then
					RichTextUtil.FlyToPos(tonumber(params[5]) or 0, tonumber(params[3]) or 0, tonumber(params[4]) or 0, tonumber(params[6]))
				else
					RichTextUtil.FlyToPos(tonumber(params[5]) or 0, tonumber(params[3]) or 0, tonumber(params[4]) or 0)
				end
			end)
		end
	end
	--color = TEXT_COLOR.Kill_COLOR
	color = TEXT_COLOR.BLUE_5
	RichTextUtil.CreateUnderLineBtn(rich_text, point_text, font_size, color, callback, "link_blue")
end


function RichTextUtil.ParseHelpPoint(rich_text, params, font_size, color)
	if #params < 6 or tonumber(params[6]) == GameVoManager.Instance:GetMainRoleVo().role_id then return end
	local point_text = CommonDataManager.GetDaXie(1) .. params[2] .. "(" .. params[3] .. "," .. params[4] .. ")"

	local function callback(btn)
		if nil ~= btn then
			btn:SetClickListener(function()
				RichTextUtil.FlyToPos(tonumber(params[5]) or 0, tonumber(params[3]) or 0, tonumber(params[4]) or 0, 0)
				MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
			end)
		end
	end
	color = TEXT_COLOR.GREEN
	RichTextUtil.CreateUnderLineBtn(rich_text, point_text, font_size, color, callback)
end

function RichTextUtil.ParseScene(rich_text, params, font_size, color)
	if #params < 3 then return end
	local function callback(btn)
		if nil ~= btn then
			btn:SetClickListener(function()
				local scene_id = tonumber(params[3])
				if Scene.Instance:GetSceneId() == scene_id then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.HasInTargetScene)
				else
					GuajiCtrl.Instance:MoveToScene(scene_id)
				end
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, params[2], font_size, TEXT_COLOR.WHITE, callback)
end

function RichTextUtil.ParseSceneId(rich_text, params, font_size, color)
	if #params < 2 then return end
	local scene_id = tonumber(params[2])
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_cfg then
		return
	end

	if rich_text then
		local function callback(btn)
			if nil ~= btn then
				btn:SetClickListener(function()
					if Scene.Instance:GetSceneId() == scene_id then
						SysMsgCtrl.Instance:ErrorRemind(Language.Common.HasInTargetScene)
					else
						GuajiCtrl.Instance:MoveToScene(scene_id)
					end
				end)
			end
		end
		RichTextUtil.CreateBtn(rich_text, scene_cfg.name, font_size, TEXT_COLOR.WHITE, callback)
	else
		RichTextUtil.AddText(nil, scene_cfg.name)
	end
end

function RichTextUtil.ParseNewLine(rich_text, params, font_size, color)
	RichTextUtil.AddText(rich_text, "\n")
end

function RichTextUtil.ParseMyItem(rich_text, params, font_size)
	local item_id = tonumber(params[2]) or 0
	local item_cfg, item_type = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		print_error("item_cfg is null. id = " .. item_id)
		return
	end

	color = ITEM_COLOR[item_cfg.color] or COLOR.WHITE
	local btn_bg_path = BUTTON_BG_NAME[item_cfg.color] or BUTTON_BG_NAME[GameEnum.ITEM_COLOR_WHITE]

	local function callback(btn)
		if nil ~= btn then
			btn:SetClickListener(function()
				local item_data = CommonStruct.ItemDataWrapper()
				item_data.item_id = item_id
				if item_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and nil ~= params[3] then
					local item_param = Split(params[3], ":")
					item_data.stones = {}

					item_data.has_param = 1
					item_data.param.strengthen_level = tonumber(item_param[2]) or 0
					item_data.param.quality = tonumber(item_param[3]) or 0
					item_data.param.shen_level = tonumber(item_param[4]) or 0
					item_data.param.fuling_level = tonumber(item_param[5]) or 0
					item_data.param.has_lucky = tonumber(item_param[6]) or 0
					item_data.param.star_level = tonumber(item_param[7]) or 0
					item_data.param.xianpin_type_list = {}
					for i=1,COMMON_CONSTS.XIANPIN_MAX_NUM do
						local xianpin_type = tonumber(item_param[7 + i] or 0)
						if xianpin_type > 0 then
							table.insert(item_data.param.xianpin_type_list, xianpin_type)
						end
					end
				end
				TipsCtrl.Instance:OpenItem(item_data, TipsFormDef.FROME_BROWSE_ROLE)
			end)
		end
	end
	name = "[" .. item_cfg.name .. "]"
	RichTextUtil.CreateUnderLineBtn(rich_text, name, font_size, color, callback, btn_bg_path)
end

function RichTextUtil.ParseItem(rich_text, params, font_size, color, adjust_font)
	local item_id = tonumber(params[2]) or 0
	local item_cfg, item_type = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		print_error("item_cfg is null. id = " .. item_id)
		return
	end

	color = ITEM_COLOR[item_cfg.color] or COLOR.WHITE
	local btn_bg_path = BUTTON_BG_NAME[item_cfg.color] or BUTTON_BG_NAME[GameEnum.ITEM_COLOR_WHITE]

	local function callback(btn)
		if nil ~= btn then
			btn:SetClickListener(function()
				local item_data = CommonStruct.ItemDataWrapper()
				item_data.item_id = item_id
				if item_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and nil ~= params[3] then
					local item_param = Split(params[3], ":")
					item_data.stones = {}

					item_data.has_param = 1
					item_data.param.strengthen_level = tonumber(item_param[2]) or 0
					item_data.param.quality = tonumber(item_param[3]) or 0
					item_data.param.shen_level = tonumber(item_param[4]) or 0
					item_data.param.fuling_level = tonumber(item_param[5]) or 0
					item_data.param.has_lucky = tonumber(item_param[6]) or 0
					item_data.param.star_level = tonumber(item_param[7]) or 0
					item_data.param.xianpin_type_list = {}
					for i=1,COMMON_CONSTS.XIANPIN_MAX_NUM do
						local xianpin_type = tonumber(item_param[7 + i] or 0)
						if xianpin_type > 0 then
							table.insert(item_data.param.xianpin_type_list, xianpin_type)
						end
					end
				end
				TipsCtrl.Instance:OpenItem(item_data, TipsFormDef.FROME_BROWSE_ROLE)
			end)
		end
	end
	RichTextUtil.CreateUnderLineBtn(rich_text, item_cfg.name, font_size, color, callback, btn_bg_path, adjust_font)
end

function RichTextUtil.ParseCamp(rich_text, params, font_size, color)
	if nil ~= params[2] then
		local camp = tonumber(params[2])
		RichTextUtil.AddText(rich_text, CampData.Instance:GetCampNameByCampType(camp, false, false, true), CAMP_COLOR[camp])
	end
end

function RichTextUtil.ParseCampInfo(rich_text, params, font_size, color)
	if nil ~= params[2] then
		local camp = tonumber(params[2])
		RichTextUtil.AddText(rich_text, CampData.Instance:GetCampNameByCampType(camp, false, false, true), CAMP_COLOR[camp])
		local camp_post = tonumber(params[3])
		RichTextUtil.AddText(rich_text, Language.Common.CampPost[camp_post], CAMP_POST_NAME[camp])
	end
end

function RichTextUtil.ParseCampOfficer(rich_text, params, font_size, color)
	if nil ~= params[2] then
		local camp_post = tonumber(params[2])
		RichTextUtil.AddText(rich_text, Language.Common.CampPost[camp_post], CAMP_POST_NAME[camp_post])
		local name = params[3]
		RichTextUtil.AddText(rich_text, name, TEXT_COLOR.GREEN)
	end
end

function RichTextUtil.ParseOfficer(rich_text, params, font_size, color)
	if nil ~= params[2] then
		local camp_post = tonumber(params[2])
		RichTextUtil.AddText(rich_text, Language.Common.CampPost[camp_post], CAMP_POST_NAME[camp_post])
	end
end

--人物传闻
function RichTextUtil.ParseRole(rich_text, params, font_size, color)
	local name = params[3]
	local camp = tonumber(params[4])
	if name and camp then
		local str = CampData.Instance:GetCampNameByCampType(camp, true) .. name
		RichTextUtil.AddText(rich_text, str,CAMP_COLOR[camp])
	end
end

function RichTextUtil.ParseRole2(rich_text, params, font_size, color)
	local name = params[3]
	local camp = tonumber(params[4])

	if name and camp then
		local str = string.format("%s·%s", CampData.Instance:GetCampNameByCampType(camp, false, false, true), name)
		RichTextUtil.AddText(rich_text, str, CAMP_COLOR[camp])
	end
end

function RichTextUtil.ParseRole3(rich_text, params, font_size, color)
	local name = params[3]
	local camp = tonumber(params[4])
	local post = tonumber(params[5])

	if name and camp then
		local str = string.format("%s%s·%s", 
			CampData.Instance:GetCampNameByCampType(camp, false, false, true), Language.Common.CampPost[post], name)
		
		RichTextUtil.AddText(rich_text, str, CAMP_COLOR[camp])
	end
end

function RichTextUtil.ParseWordColor(rich_text, params, font_size, color)
	if #params < 3 then return end

	local color_str
	if 8 == string.len(params[2]) then
		color_str = string.sub(params[2], 2, -1)
	else
		color_str = params[2]
	end
	if not string.find(color_str, "#") then
		color_str = "#" .. color_str
	end
	if 7 == string.len(color_str) then
		RichTextUtil.AddText(rich_text, params[3], color_str)
	end
end

function RichTextUtil.ParseChannelMark(rich_text, params, font_size, color)

end

-- team
function RichTextUtil.ParseTeam(rich_text, params, font_size, color)
	if #params < 3 then return end
	local function callback(btn)
		if nil ~= btn then
			btn:SetClickListener(function()
				if params[4] then
					local min_level = tonumber(params[4])
					if min_level > 0 then
						local role_level = GameVoManager.Instance:GetMainRoleVo().level
						if min_level > role_level then
							SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.LevelNotEnough)
							return
						end
					end
				end

				local team_type = params[5] or ""
				local team_index = tonumber(params[3]) or 0
				--记录请求加入的类型
				ScoietyData.Instance:SetReqTeamIndex(team_index, team_type)

				ScoietyCtrl.Instance:JoinTeamReq(team_index)
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, params[2], font_size, TEXT_COLOR.WHITE, callback)
end

-- teamfb
function RichTextUtil.ParseTeamFb(rich_text, params, font_size, color)
	if #params < 4 then return end

	local function callback(btn)
		if nil ~= btn then
			btn:SetClickListener(function()
				DailyCtrl.Instance:SendTeamFbJoinRoom(params[3], params[4])
				DailyCtrl.Instance:SendTeamFbReqRoomList(params[3])
				-- FunOpen.Instance:OpenViewByName(GuideModuleName.Daily, TabIndex.daily_duoren)
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, params[2], font_size, TEXT_COLOR.WHITE, callback)
end

-- guildinfo
function RichTextUtil.ParseGuildInfo(rich_text, params, font_size, color)
	if #params < 3 then return end

	local guild_name = params[3]
	color = TEXT_COLOR.Kill_COLOR
	RichTextUtil.AddText(rich_text, guild_name, color)
end

-- guildinfo2
function RichTextUtil.ParseGuildInfo2(rich_text, params, font_size, color)
	if params[3] == "" then
		return
	end
	local guild_name = "【" .. params[3] .. "】"
	color = TEXT_COLOR.Kill_COLOR
	RichTextUtil.AddText(rich_text, guild_name, color)
end

-- guildjoin
function RichTextUtil.ParseGuildJoin(rich_text, params, font_size, color)
	local function callback(btn)
		if nil ~= btn then
			btn:SetClickListener(function()
				--GuildCtrl.Instance:SendApplyForJoinGuildReq(params[2])
				for k,v in pairs(params) do
					print(k,v)
				end
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, Language.Chat.JIARU .. (params[3] or ""), font_size, TEXT_COLOR.WHITE, callback)
end

-- money
function RichTextUtil.ParseMoney(rich_text, params, font_size, color)
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

	RichTextUtil.AddText(rich_text, params[2], TEXT_COLOR.YELLOW_1)
	RichTextUtil.AddText(rich_text, money_type_str, color)
end

-- chinese_num
function RichTextUtil.ParseChineseNum(rich_text, params, font_size, color)
	local num = tonumber(params[2]) or 0
	local daxie_num = CommonDataManager.GetDaXie(num)
	if nil ~= daxie_num then
		RichTextUtil.AddText(rich_text, daxie_num, TEXT_COLOR.RED)
	end
end

-- ranking_num
function RichTextUtil.RankingNum(rich_text, params, font_size, color)
	local num = tonumber(params[2]) or 0
	local daxie_num = CommonDataManager.GetDaXie(num)
	if nil ~= daxie_num then
		local rank_str = string.format(Language.Common.Ranking, daxie_num)
		RichTextUtil.AddText(rich_text, rank_str, TEXT_COLOR.YELLOW_1)
	end
end

function RichTextUtil.FQZZFUNCTYPE(rich_text, params, font_size, color)
	local num = tonumber(params[2]) or 1
	local name = Language.FenQi.AppearanceName[num - 1]
	RichTextUtil.AddText(rich_text, name, TEXT_COLOR.YELLOW_1)
end

function RichTextUtil.TouXianLevel(rich_text, params, font_size, color)
	local level = tonumber(params[2]) or 1
	local level_cfg = TouXianData.Instance:GetConfigByLevel(level)
	RichTextUtil.AddText(rich_text, level_cfg.title_name, TEXT_COLOR.YELLOW_1)
end

function RichTextUtil.CampTime(rich_text, params, font_size, color)
	local text = tonumber(params[2]) or 1
	RichTextUtil.AddText(rich_text, text)
end

function RichTextUtil.CampGrade(rich_text, params, font_size, color)
	local grade = tonumber(params[2]) or 4
	local text = Language.Camp.CampGrade[grade] or ""
	RichTextUtil.AddText(rich_text, text, TEXT_COLOR.YELLOW_1)
end

function RichTextUtil.ServerGroup(rich_text, params, font_size, color)
	local group = tonumber(params[2]) or 0
	local text = Language.Convene.ServerGroup[group]
	RichTextUtil.AddText(rich_text, text, TEXT_COLOR.YELLOW_1)
end

function RichTextUtil.CrossXyjd(rich_text, params, font_size, color)
	local id = tonumber(params[2]) or 0
	local str = ""
	local cfg = LianFuDailyData.Instance:GetJuDianIdCfg(id)
	if cfg ~= nil and next(cfg) ~= nil then
		str = cfg[1].name or ""
	end
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
end

function RichTextUtil.XycityWorker(rich_text, params, font_size, color)
	local group = tonumber(params[2]) or 0
	local text = Language.Convene.XycityWorker[group] or ""
	RichTextUtil.AddText(rich_text, text, TEXT_COLOR.YELLOW_1)
end

function RichTextUtil.ZymbTrueWord(rich_text, params, font_size, color)
	local word_seq = tonumber(params[2]) or 0
	local word_cfg = RareTreasureData.Instance:GetWordConfigBySeq(word_seq)
	local str = Language.Common.No
	if word_cfg ~= nil then
		str = word_cfg.word
	end
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.RED)
end

function RichTextUtil.HoChiCard(rich_text, params, font_size, color)
	local card_level = tonumber(params[2]) or 0
	local card_seq = tonumber(params[3]) or 0
	local card_data = MuseumCardData.Instance:GetCardCfgById(card_seq)
	local str = ""
	if card_data then
		str = string.format(Language.MuseumCard.CardName, card_level, card_data.card_name)
	end
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.RED)
end

function RichTextUtil.HoChiSuit(rich_text, params, font_size, color)
	local card_suit = tonumber(params[2]) or 0
	local card_data = MuseumCardData.Instance:GetCardSuitCfgByIdAndNum(tonumber(params[2]), tonumber(params[3]))
	local str = ""
	if card_data and next(card_data) then
		str = card_data.suit_name
	end
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.RED)
end

function RichTextUtil.ParseAvatar(rich_text, params)
	local seq = tonumber(params[2]) or 0
	local head_frame_info = HeadFrameData.Instance:GetChooseData(seq)
	local name = head_frame_info.name
	RichTextUtil.AddText(rich_text, name, TEXT_COLOR.YELLOW)
end

function RichTextUtil.HeadWearGrade(rich_text, params, font_size, color)
	local grade = tonumber(params[2]) or 0
	local single_cfg = HeadwearData.Instance:GetCurHeadwearCfg(grade)
	local str = ""
	if single_cfg  then
		local star = CommonDataManager.GetDaXie(single_cfg.show_star)
		local image_cfg = HeadwearData.Instance:GetHeadwearImageCfg(single_cfg.image_id)
		str = string.format(Language.Advance.ParseLabel, single_cfg.gradename, star, image_cfg.image_name or "")
	end
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
end

function RichTextUtil.MaskGrade(rich_text, params, font_size, color)
	local grade = tonumber(params[2]) or 0
	local single_cfg = MaskData.Instance:GetCurMaskCfg(grade)
	local str = ""
	if single_cfg  then
		local star = CommonDataManager.GetDaXie(single_cfg.show_star)
		local image_cfg = MaskData.Instance:GetMaskImageCfg(single_cfg.image_id)
		str = string.format(Language.Advance.ParseLabel, single_cfg.gradename, star, image_cfg.image_name or "")
	end
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
end
function RichTextUtil.WaistGrade(rich_text, params, font_size, color)
	local grade = tonumber(params[2]) or 0
	local single_cfg = WaistData.Instance:GetCurWaistCfg(grade)
	local str = ""
	if single_cfg  then
		local star = CommonDataManager.GetDaXie(single_cfg.show_star)
		local image_cfg = WaistData.Instance:GetWaistImageCfg(single_cfg.image_id)
		str = string.format(Language.Advance.ParseLabel, single_cfg.gradename, star, image_cfg.image_name or "")
	end
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
end
function RichTextUtil.KirinGrade(rich_text, params, font_size, color)
	local grade = tonumber(params[2]) or 0
	local single_cfg = KirinArmData.Instance:GetCurKirinArmCfg(grade)
	local str = ""
	if single_cfg  then
		local star = CommonDataManager.GetDaXie(single_cfg.show_star)
		local image_cfg = KirinArmData.Instance:GetKirinArmImageCfg(single_cfg.image_id)
		str = string.format(Language.Advance.ParseLabel, single_cfg.gradename, star, image_cfg.image_name or "")
	end
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
end
function RichTextUtil.BeadGrade(rich_text, params, font_size, color)
	local grade = tonumber(params[2]) or 0
	local single_cfg = BeadData.Instance:GetCurBeadCfg(grade)
	local str = ""
	if single_cfg  then
		local star = CommonDataManager.GetDaXie(single_cfg.show_star)
		local image_cfg = BeadData.Instance:GetBeadImageCfg(single_cfg.image_id)
		str = string.format(Language.Advance.ParseLabel, single_cfg.gradename, star, image_cfg.image_name or "")
	end
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
end
function RichTextUtil.FabaoGrade(rich_text, params, font_size, color)
	local grade = tonumber(params[2]) or 0
	local single_cfg = FaBaoData.Instance:GetCurFaBaoCfg(grade)
	local str = ""
	if single_cfg  then
		local star = CommonDataManager.GetDaXie(single_cfg.show_star)
		local image_cfg = FaBaoData.Instance:GetFaBaoImageCfg(single_cfg.image_id)
		str = string.format(Language.Advance.ParseLabel, single_cfg.gradename, star, image_cfg.image_name or "")
	end
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
end

-- zhuxie_task_item
function RichTextUtil.ParseZhuXieTaskItem(rich_text, params, font_size, color)
	-- local item_type = tonumber(params[2]) or 0
	-- local cfg = ConfigManager.Instance:GetAutoConfig("activityzhuxie_auto").task_list[item_type]
	-- if cfg and nil ~= cfg.item_name then
	-- 	RichTextUtil.AddText(rich_text, cfg.item_name, font_size, COLOR.GREEN)
	-- end
end

-- wing
function RichTextUtil.ParseWingGrade(rich_text, params, font_size, color)
	-- local wing_grade = tonumber(params[2]) or 0
	-- if wing_grade > 1000 then
	-- 	local image_list = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img[wing_grade - 1000]
	-- 	if nil ~= image_list and nil ~= image_list.name then
	-- 		RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.GREEN)
	-- 	end
	-- else
	-- 	-- local client_grade = math.max(wing_grade - 1, 1)
	-- 	local grade_cfg = WingData.Instance:GetWingGradeCfg(wing_grade)
	-- 	if not grade_cfg then return end

	-- 	local image_list = ConfigManager.Instance:GetAutoConfig("wing_auto").image_list[grade_cfg.image_id]
	-- 	if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
	-- 		local show_color = math.floor(wing_grade / 3 + 1) >= 5 and 5 or math.floor(wing_grade / 3 + 1)
	-- 		color = SOUL_NAME_COLOR[show_color]
	-- 		RichTextUtil.AddText(rich_text, image_list.image_name, color)
	-- 	end
	-- end
	-- local cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[wing_level]
	-- if cfg and nil ~= cfg.big_grade then
	-- 	local daxie_jie = CommonDataManager.GetDaXie(cfg.big_grade)
	-- 	RichTextUtil.AddText(rich_text, daxie_jie, font_size, COLOR.GREEN)
	-- end

	local wing_grade = tonumber(params[2]) or 0
	local str = ""
	local cfg = WingData.Instance:GetWingGradeCfg(wing_grade)
	if cfg ~= nil and next(cfg) ~= nil then
		local image_cfg = WingData.Instance:GetImageListInfo(cfg.image_id)
		if image_cfg ~= nil then
			local star = CommonDataManager.DAXIE[wing_grade % 10 + 1]
			-- local show_color = math.floor((wing_grade / 10 + 1) / 2)
			str = string.format(Language.Advance.ParseLabel, cfg.gradename, star, image_cfg.image_name)
			RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
		end
	end
end

-- wing_name
function RichTextUtil.ParseWingName(rich_text, params, font_size, color)
	-- local wing_level = tonumber(params[2]) or 1
	-- local role_prof = RoleData.Instance:GetRoleBaseProf(tonumber(params[3])) or 1
	-- local wing_level_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[wing_level] or ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[1]
	-- if nil ~= wing_level_cfg then
	-- 	local wing_name = wing_level_cfg["wing_name_" .. role_prof] or ""
	-- 	RichTextUtil.AddText(rich_text, wing_name, font_size, GRADE_COCOR[wing_level_cfg.big_grade])
	-- end
end

-- fazhen_name
function RichTextUtil.ParseFaZhenName(rich_text, params, font_size, color)
	-- local fazhen_grade = tonumber(params[2]) or 0
	-- local fazhen_name = WingData.Instance:GetFaZhenName(fazhen_grade) or ""
	-- local fazhen_color = FAZHEN_COCOR3B[fazhen_grade] or COLOR.WHITE
	-- RichTextUtil.AddText(rich_text, fazhen_name, font_size, fazhen_color)
end

-- defend_area
function RichTextUtil.ParseDefendArea(rich_text, params, font_size, color)
	-- local defend_area_id = tonumber(params[2]) or 0
	-- local deend_area_name = GuildBattleData.Instance:GetDefendAreaName(defend_area_id)
	-- if deend_area_name then
	-- 	RichTextUtil.AddText(rich_text, deend_area_name.area_name, font_size, COLOR.GREEN)
	-- end
end

-- mount
function RichTextUtil.ParseMountGrade(rich_text, params, font_size, color)
	-- local mount_grade = tonumber(params[2]) or 0
	-- if mount_grade > 1000 then
	-- 	local image_list = ConfigManager.Instance:GetAutoConfig("mount_auto").special_img[mount_grade - 1000]
	-- 	if nil ~= image_list and nil ~= image_list.name then
	-- 		RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.GREEN)
	-- 	end
	-- else
	-- 	-- local client_grade = math.max(mount_grade - 1, 1)
	-- 	local grade_cfg = MountData.Instance:GetMountGradeCfg(mount_grade)
	-- 	if not grade_cfg then return end

	-- 	local image_list = ConfigManager.Instance:GetAutoConfig("mount_auto").image_list[grade_cfg.image_id]
	-- 	if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
	-- 		local show_color = math.floor(mount_grade / 3 + 1) >= 5 and 5 or math.floor(mount_grade / 3 + 1)
	-- 		color = SOUL_NAME_COLOR[show_color]
	-- 		RichTextUtil.AddText(rich_text, image_list.image_name, color)
	-- 	end
	-- end
	local mount_grade = tonumber(params[2]) or 0
	local str = ""
	local cfg = MountData.Instance:GetMountGradeCfg(mount_grade)
	if cfg ~= nil and next(cfg) ~= nil then
		local image_cfg = MountData.Instance:GetMountImageCfg(cfg.image_id)
		if image_cfg ~= nil then
			local star = CommonDataManager.DAXIE[mount_grade % 10 + 1]
			-- local show_color = math.floor((mount_grade / 10 + 1) / 2)
			str = string.format(Language.Advance.ParseLabel, cfg.gradename, star, image_cfg.image_name)
			RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
		end
	end
end

-- halo
function RichTextUtil.ParseHaloGrade(rich_text, params, font_size, color)
	-- local halo_grade = tonumber(params[2]) or 0
	-- if halo_grade > 1000 then
	-- 	local image_list = ConfigManager.Instance:GetAutoConfig("halo_auto").special_img[halo_grade - 1000]
	-- 	if nil ~= image_list and nil ~= image_list.name then
	-- 		RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.GREEN)
	-- 	end
	-- else
	-- 	-- local client_grade = math.max(halo_grade - 1, 1)
	-- 	local grade_cfg = HaloData.Instance:GetHaloGradeCfg(halo_grade)
	-- 	if not grade_cfg then return end

	-- 	local image_list = ConfigManager.Instance:GetAutoConfig("halo_auto").image_list[grade_cfg.image_id]
	-- 	if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
	-- 		local show_color = math.floor(halo_grade / 3 + 1) >= 5 and 5 or math.floor(halo_grade / 3 + 1)
	-- 		color = SOUL_NAME_COLOR[show_color]
	-- 		RichTextUtil.AddText(rich_text, image_list.image_name, color)
	-- 	end
	-- end

	local halo_grade = tonumber(params[2]) or 0
	local str = ""
	local cfg = HaloData.Instance:GetHaloGradeCfg(halo_grade)
	if cfg ~= nil and next(cfg) ~= nil then
		local image_cfg = HaloData.Instance:GetImageListInfo(cfg.image_id)
		if image_cfg ~= nil then
			local star = CommonDataManager.DAXIE[halo_grade % 10 + 1]
			-- local show_color = math.floor((halo_grade / 10 + 1) / 2)
			str = string.format(Language.Advance.ParseLabel, cfg.gradename, star, image_cfg.image_name)
			RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
		end
	end
end

--芳华
function RichTextUtil.ParseBeautyHaloGrade(rich_text, params, font_size, color)
	local beauty_halo_grade = tonumber(params[2]) or 0
	local str = ""
	local cfg = BeautyHaloData.Instance:GetCurBeautyHaloCfg(beauty_halo_grade)
	if cfg ~= nil and next(cfg) ~= nil then
		local image_cfg = BeautyHaloData.Instance:GetImageListInfo(cfg.image_id)
		if image_cfg ~= nil then
			local star = CommonDataManager.DAXIE[beauty_halo_grade % 10 + 1]
			-- local show_color = math.floor((beauty_halo_grade / 10 + 1) / 2)
			str = string.format(Language.Advance.ParseLabel, cfg.gradename, star, image_cfg.image_name)
			RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
		end
	end
end

--圣物
function RichTextUtil.ParseHaildomGrade(rich_text, params, font_size, color)
	local haildom_grade = tonumber(params[2]) or 0
	local str = ""
	local cfg = HalidomData.Instance:GetHalidomGradeCfg(haildom_grade)
	if cfg ~= nil and next(cfg) ~= nil then
		local image_cfg = HalidomData.Instance:GetImageCfg(cfg.image_id)
		if image_cfg ~= nil then
			local star = CommonDataManager.DAXIE[haildom_grade % 10 + 1]
			-- local show_color = math.floor((haildom_grade / 10 + 1) / 2)
			str = string.format(Language.Advance.ParseLabel, cfg.gradename, star, image_cfg.image_name)
			RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
		end
	end
end

--法阵
function RichTextUtil.ParseFaZhenGrade(rich_text, params, font_size, color)
	local fazhen_grade = tonumber(params[2]) or 0
	local str = ""
	local cfg = FaZhenData.Instance:GetMountGradeCfg(fazhen_grade)
	if cfg ~= nil and next(cfg) ~= nil then
		local image_cfg = FaZhenData.Instance:GetMountImageCfg(cfg.image_id)
		if image_cfg ~= nil then
			local star = CommonDataManager.DAXIE[fazhen_grade % 10 + 1]
			-- local show_color = math.floor((fazhen_grade / 10 + 1) / 2)
			str = string.format(Language.Advance.ParseLabel, cfg.gradename, star, image_cfg.image_name)
			RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
		end
	end
end

-- 足迹
function RichTextUtil.ParseFoot(rich_text, params, font_size, color)
	-- local shengong_grade = tonumber(params[2]) or 0
	-- if shengong_grade > 1000 then
	-- 	local image_list = ConfigManager.Instance:GetAutoConfig("shengong_auto").special_img[shengong_grade - 1000]
	-- 	if nil ~= image_list and nil ~= image_list.name then
	-- 		RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.GREEN)
	-- 	end
	-- else
	-- 	-- local client_grade = math.max(shengong_grade - 1, 1)
	-- 	local grade_cfg = ShengongData.Instance:GetShengongGradeCfg(shengong_grade)
	-- 	if not grade_cfg then return end

	-- 	local image_list = ConfigManager.Instance:GetAutoConfig("shengong_auto").image_list[grade_cfg.image_id]
	-- 	if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
	-- 		local show_color = math.floor(shengong_grade / 3 + 1) >= 5 and 5 or math.floor(shengong_grade / 3 + 1)
	-- 		color = SOUL_NAME_COLOR[show_color]
	-- 		RichTextUtil.AddText(rich_text, image_list.image_name, color)
	-- 	end
	-- end

	local foot_grade = tonumber(params[2]) or 0
	local str = ""
	local cfg = ShengongData.Instance:GetShengongGradeCfg(foot_grade)
	if cfg ~= nil and next(cfg) ~= nil then
		local image_cfg = ShengongData.Instance:GetShengongImageCfg(cfg.image_id)
		if image_cfg ~= nil then
			local star = CommonDataManager.DAXIE[foot_grade % 10 + 1]
			-- local show_color = math.floor((foot_grade / 10 + 1) / 2)
			str = string.format(Language.Advance.ParseLabel, cfg.gradename, star, image_cfg.image_name)
			RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
		end
	end
end

-- 披风
function RichTextUtil.ParseMantleGrade(rich_text, params, font_size, color)
	-- local shenyi_grade = tonumber(params[2]) or 0
	-- if shenyi_grade > 1000 then
	-- 	local image_list = ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_img[shenyi_grade - 1000]
	-- 	if nil ~= image_list and nil ~= image_list.name then
	-- 		RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.GREEN)
	-- 	end
	-- else
	-- 	-- local client_grade = math.max(shenyi_grade - 1, 1)
	-- 	local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_grade)
	-- 	if not grade_cfg then return end

	-- 	local image_list = ConfigManager.Instance:GetAutoConfig("shenyi_auto").image_list[grade_cfg.image_id]
	-- 	if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
	-- 		local show_color = math.floor(shenyi_grade / 3 + 1) >= 5 and 5 or math.floor(shenyi_grade / 3 + 1)
	-- 		color = SOUL_NAME_COLOR[show_color]
	-- 		RichTextUtil.AddText(rich_text, image_list.image_name, color)
	-- 	end
	-- end

	local mantle_grade = tonumber(params[2]) or 0
	local str = ""
	local cfg = ShenyiData.Instance:GetShenyiGradeCfg(mantle_grade)
	if cfg ~= nil and next(cfg) ~= nil then
		local image_cfg = ShenyiData.Instance:GetShenyiImageCfg(cfg.image_id)
		if image_cfg ~= nil then
			local star = CommonDataManager.DAXIE[mantle_grade % 10 + 1]
			-- local show_color = math.floor((mantle_grade / 10 + 1) / 2)
			str = string.format(Language.Advance.ParseLabel, cfg.gradename, star, image_cfg.image_name)
			RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW_1)
		end
	end
end

-- fightmount
function RichTextUtil.ParseFightMount(rich_text, params, font_size, color)
	local fight_mount_grade = tonumber(params[2]) or 0
	if fight_mount_grade > 1000 then
		local image_list = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").special_img[fight_mount_grade - 1000]
		if nil ~= image_list and nil ~= image_list.name then
			RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.GREEN)
		end
	else
		-- local client_grade = math.max(fight_mount_grade - 1, 1)
		local grade_cfg = FaZhenData.Instance:GetMountGradeCfg(fight_mount_grade)
		if not grade_cfg then return end

		local image_list = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").image_list[grade_cfg.image_id]
		if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
			-- local show_color = math.floor((fight_mount_grade / 10 + 1) / 2)
			color = TEXT_COLOR.YELLOW_1
			RichTextUtil.AddText(rich_text, image_list.image_name, color)
		end
	end
end

-- mojie
function RichTextUtil.ParseMojie(rich_text, params, font_size, color)
	local mojie_type = tonumber(params[2]) or 0
	local mojie_level = tonumber(params[3]) or 0
	RichTextUtil.AddText(rich_text, MojieData.Instance:GetMojieName(mojie_type, mojie_level), TEXT_COLOR.ORANGE)
end

-- role_level
function RichTextUtil.ParseRoleLevel(rich_text, params, font_size, color)
	local role_level = tonumber(params[2]) or 0
	RichTextUtil.AddText(rich_text, PlayerData.GetLevelString(role_level), TEXT_COLOR.GREEN)
end

-- qibing
function RichTextUtil.ParseQiBing(rich_text, params, font_size, color)
	-- local qibing_level = tonumber(params[2]) or 1
	-- local qibing_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").qibing[qibing_level]
	-- if nil ~= qibing_cfg and nil ~= qibing_cfg.name then
	-- 	RichTextUtil.AddText(rich_text, qibing_cfg.name, font_size, GRADE_COCOR3B[qibing_level] or COLOR.WHITE)
	-- end
end

--to_decimal
function RichTextUtil.ParseToDecimal(rich_text, params, font_size, color)
	local rate = tonumber(params[2]) or 0
	RichTextUtil.AddText(rich_text, rate, TEXT_COLOR.GREEN)
end

--monster
function RichTextUtil.ParseMonster(rich_text, params, font_size, color)
	local monster_config = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[tonumber(params[2]) or 0]
	if nil ~= monster_config and nil ~= monster_config.name then
		RichTextUtil.AddText(rich_text, monster_config.name, TEXT_COLOR.YELLOW)
	end
end

--title
function RichTextUtil.ParseTitle(rich_text, params, font_size, color)
	local title_config = TitleData.Instance:GetTitleCfg(tonumber(params[2]) or 0)
	if nil ~= title_config and nil ~= title_config.name then
		RichTextUtil.AddText(rich_text, title_config.name, TEXT_COLOR.YELLOW_1)
	end
end

--forge_suit_ss
function RichTextUtil.ParseForgeSuitSS(rich_text, params, font_size, color)
	local suit_name = ForgeData.Instance:GetSuitName(tonumber(params[2]), 1)
	if nil ~= suit_name then
		RichTextUtil.AddText(rich_text, suit_name, TEXT_COLOR.GREEN, text_attr)
	end
end

--forge_suit_cs
function RichTextUtil.ParseForgeSuitCS(rich_text, params, font_size, color)
	local suit_name = ForgeData.Instance:GetSuitName(tonumber(params[2]),-1)
	if nil ~= suit_name then
		RichTextUtil.AddText(rich_text, suit_name, TEXT_COLOR.GREEN, text_attr)
	end
end


--territory
function RichTextUtil.ParseTerritory(rich_text, params, font_size, color)
	local cfg = GuildData.Instance:GetTerritoryConfig(tonumber(params[2]))
	local territory_name = ""
	if cfg then
		territory_name = cfg.territory_name
	end
	RichTextUtil.AddText(rich_text, territory_name, TEXT_COLOR.GREEN, text_attr)
end

--famousxiannv
function RichTextUtil.FamousXiannv(rich_text, params)
	local cfg = GoddessData.Instance:GetXianNvCfg(tonumber(params[2]))
	local xiannv_name = ""
	if cfg then
		xiannv_name = cfg.name
	end
	RichTextUtil.AddText(rich_text, xiannv_name, TEXT_COLOR.GREEN)
end

--guildpost
function RichTextUtil.ParseGuildPost(rich_text, params)
	local post_name = GUILD_POST_NAME[tonumber(params[2])] or ""
	RichTextUtil.AddText(rich_text, post_name, TEXT_COLOR.ORANGE_3)
end

--shenzhou_weapon
function RichTextUtil.ParseHunQiName(rich_text, params)
	local name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(tonumber(params[2]))
	local color = ITEM_COLOR[color_num]
	RichTextUtil.AddText(rich_text, name, color)
end

--shenzhou_skill
function RichTextUtil.ParseHunQiSkill(rich_text, params)
	local skill_name = HunQiData.Instance:GetHunQiSkillByIndex(tonumber(params[2]))
	local color = TEXT_COLOR.ORANGE
	RichTextUtil.AddText(rich_text, skill_name, color)
end

function RichTextUtil.ParseHelpBaoXiang(rich_text, params, font_size, color)
	local function callback(btn)
		if nil ~= btn then
			btn:SetClickListener(function()
				local help_uid = tonumber(params[2])
				local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
				if help_uid == main_role_vo.role_id then
					SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotHelpSelf)
					return
				end
				HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_HELP_OTHER_BOX, help_uid)
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, Language.HunQi.HelpBtnText, font_size, TEXT_COLOR.WHITE, callback)
end

function RichTextUtil.ParseShenGe(rich_text, params, font_size, color)
	local seq = tonumber(params[2])
	local cfg = ShenGeData.Instance:GetChoujiangCfg(seq)
	local item_id = ShenGeData.Instance:GetShenGeItemId(cfg[1].types, cfg[1].quality)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	color = ITEM_COLOR[item_cfg.color] or COLOR.WHITE

	RichTextUtil.AddText(rich_text, item_cfg.name or "", color)
end

function RichTextUtil.ParseIdentifyLevel(rich_text, params)
	local big_level = tonumber(params[2])
	local small_level = tonumber(params[3])

	local attr_info = HunQiData.Instance:GetidentifyLevelInfo(big_level, small_level)
	if nil == attr_info then
		return
	end
	attr_info = attr_info[1]
	local name = attr_info.name
	local color = TEXT_COLOR.GREEN
	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseElementName(rich_text, params)
	local element_type = tonumber(params[2])
	local name = HunQiData.Instance:GetElementNameByType(element_type)
	local color = TEXT_COLOR.GREEN
	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.Xufucili(rich_text, params)
	local name = Language.Common.GongNeng_Type[tonumber(params[2])]
	local type_name = ""
	if name then
		type_name = name
	end
	RichTextUtil.AddText(rich_text, type_name, TEXT_COLOR.GREEN)
end

function RichTextUtil.DiMai(rich_text, params)
	local dimai_info_cfg = nil
	if DiMaiData.Instance then
		dimai_info_cfg = DiMaiData.Instance:GetDiMaiInfoCfg(tonumber(params[2]), tonumber(params[3]))
	end
	local dimai_name = dimai_info_cfg and dimai_info_cfg.dimai_name or ""
	RichTextUtil.AddText(rich_text, dimai_name, TEXT_COLOR.GREEN)
end

function RichTextUtil.ParsePercent(rich_text, params)
	local str = tonumber(params[2]) ..  "%"
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.GREEN)
end

function RichTextUtil.CitanColor(rich_text, params)
	local cfg = Language.NationalWarfare.CitanColor[tonumber(params[2])]
	local color_def = {TEXT_COLOR.GREEN, TEXT_COLOR.BLUE, TEXT_COLOR.PURPLE, TEXT_COLOR.ORANGE, TEXT_COLOR.RED}
	local citan_color = ""
	if cfg then
		citan_color = cfg
	end
	RichTextUtil.AddText(rich_text, citan_color, color_def[tonumber(params[2])])
end

function RichTextUtil.RankType(rich_text, params)
	local rank_str = Language.Rank.NameList[tonumber(params[2])]
	RichTextUtil.AddText(rich_text, rank_str, TEXT_COLOR.PURPLE)
end

function RichTextUtil.GouyuLevel(rich_text, params)
	local gouyu_type = tonumber(params[2])
	local gouyu_level = tonumber(params[3])

	local gouyu_name = MojieData.Instance:GetGouyuTypeName(gouyu_type, gouyu_level)
	if gouyu_name then
		RichTextUtil.AddText(rich_text, gouyu_name, TEXT_COLOR.PURPLE)
	end
end

function RichTextUtil.ParseShengWu(rich_text, params, color)
	local shengwu_id = tonumber(params[2])
	local shengwu_id_name = GoddessData.Instance:GetXianNvShengWuCfgName(shengwu_id)
	color = COLOR.YELLOW

	RichTextUtil.AddText(rich_text, shengwu_id_name, color)
end

function RichTextUtil.ParseShengWuSkill(rich_text, params, color)
	local shengwu_id = tonumber(params[2])
	local shengwu_id_name = GoddessData.Instance:GetXianNvShengWuSkillName(shengwu_id)
	color = COLOR.YELLOW

	RichTextUtil.AddText(rich_text, shengwu_id_name, color)
end

function RichTextUtil.ParseShengQi(rich_text, params)
	local shenqi_id = tonumber(params[3])
	local shenbing_inlay_cfg = ShenqiData.Instance:GetShenbingInlayCfg()
	local baojia_inlay_cfg = ShenqiData.Instance:GetBaojiaInlayCfg()
	local string = ""
	if tonumber(params[2]) == 0 then
		string = Language.Shenqi.ShenqiType[0] .. shenbing_inlay_cfg[shenqi_id].name
	else
		string = Language.Shenqi.ShenqiType[1] .. baojia_inlay_cfg[shenqi_id].name
	end

	local color = COLOR.RED
	RichTextUtil.AddText(rich_text, string, color)
end

function RichTextUtil.ParseJXLevel(rich_text, params)
	local level_cfg = nil
	if MilitaryRankData then
		level_cfg = MilitaryRankData.Instance:GetLevelSingleCfg(tonumber(params[2]))
	end
	local name = level_cfg and level_cfg.name or ""
	RichTextUtil.AddText(rich_text, name, TEXT_COLOR.YELLOW_1)
end

function RichTextUtil.UnloclJunXian(rich_text, params)
	local jx_level = tonumber(params[2])
	if MilitaryRankData then
		local level_cfg = MilitaryRankData.Instance:GetLevelSingleCfg(jx_level)
	end
	local str = level_cfg and ToColorStr(level_cfg.name, TEXT_COLOR.YELLOW_1) .. "。" .. ToColorStr(level_cfg.desc .. "。" .. level_cfg.small_desc, TEXT_COLOR.YELLOW_1) or ""
	RichTextUtil.AddText(rich_text, str)
end

function RichTextUtil.ParseJXStar(rich_text, params)
	local jx_star = tonumber(params[2])
	if MilitaryRankData then
		local star_cfg = MilitaryRankData.Instance:GetStarSingleCfg(jx_star)
	end
	local name = star_cfg and star_cfg.name or ""
	RichTextUtil.AddText(rich_text, name, COLOR.RED)
end

--eq_shenzhu
function RichTextUtil.ParseEquipShenZhu(rich_text, params, font_size, color)
	-- local shenzhu = tonumber(params[2]) or 0
	-- local prefixion = shenzhu > 0 and EquipmentData.Instance:GetShengzhuPrefixion(shenzhu) .. "·" or ""
	-- RichTextUtil.AddText(rich_text, prefixion, font_size, COLOR.GREEN)
end

--eq_quality
function RichTextUtil.ParseEquipQuality(rich_text, params, font_size, color)
	-- local quality = tonumber(params[2]) or 0
	-- local color_name = Language.Common.ColorName[quality + 1] or ""
	-- color = EQUIP_COLOR[quality] or COLOR.WHITE
	-- RichTextUtil.AddText(rich_text, color_name, font_size, color)
end

--stone
function RichTextUtil.ParseStone(rich_text, params, font_size, color)
	-- local stone_type = tonumber(params[2]) or 0
	-- local stone_name = BaoshiData.Instance:GetStoneNameByType(stone_type) or ""
	-- local str = stone_name .. Language.Equip.BaoShi
	-- RichTextUtil.AddText(rich_text, str, font_size, COLOR.GREEN)
end

--csa_sub_type
function RichTextUtil.ParseCsaSubType(rich_text, params, font_size, color)
	local sub_type = tonumber(params[2]) or 0
	local combineserveractivity_cfg = HefuActivityData.Instance:GetCombineActTimeConfig(sub_type)
	if combineserveractivity_cfg ~= nil then
		RichTextUtil.AddText(rich_text, combineserveractivity_cfg.name or "", COLOR.GREEN)
	end
end

--openLink
function RichTextUtil.ParseOpenLink(rich_text, params, font_size, color)
	local link_type = tonumber(params[2]) or 0
	local link_cfg = RichTextUtil.GetOpenLinkCfg(link_type)
	local link_name = nil ~= link_cfg and link_cfg.name or "unknown link type:" .. link_type

	local function callback(btn)
		if nil ~= btn then
			btn:SetClickListener(function()
				RichTextUtil.DoByLinkType(link_type, params[3], params[4], params[5])
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, link_name, font_size, COLOR.WHITE, callback)
end

--qingyuan_card
function RichTextUtil.ParseQingYuanCard(rich_text, params, font_size, color)
	-- local card_info = MarryData.Instance:GetCardInfoByIdAndLevel(tonumber(params[2]),tonumber(params[3]))
	-- if nil ~= card_info and nil ~= card_info.card_name then
	-- 	RichTextUtil.AddText(rich_text, card_info.card_name, font_size, COLOR.GREEN)
	-- end
end

--red_paper
function RichTextUtil.ParseRedPaper(rich_text, params, font_size, color)
	local red_type = tonumber(params[2]) or 0
	local total_gold_num = tonumber(params[3]) or 0
	local can_fetch_times = tonumber(params[4]) or 0
	local red_type_text = Language.RedEnvelopes.HongbaoType[red_type] or ""
	local text_content = can_fetch_times .. Language.Common.UnitName[1] .. red_type_text .. Language.RedEnvelopes.CWTxt1 .. total_gold_num .. Language.Common.Gold
	if red_type == RED_PAPER_TYPE.RED_PAPER_TYPE_GLOBAL then
		text_content = red_type_text .. Language.RedEnvelopes.CWTxt2
	end
	RichTextUtil.AddText(rich_text, text_content, TEXT_COLOR.YELLOW_1)
end

--activityPos
function RichTextUtil.ParseActivityPos(rich_text, params, font_size, color)
	if #params < 5 or ignored_link then return end

	local pos_type = params[5] or 0
	local desc = Language.Common.ActivityPosStr[pos_type] or ""

	local point_text = desc.. "(" .. params[3] .. "," .. params[4] .. ")"

	local function callback(btn)
		if nil ~= btn then

			btn:SetClickListener(function()
				RichTextUtil.FlyToPos(tonumber(params[2]) or 0, tonumber(params[3]) or 0, tonumber(params[4]) or 0)
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, point_text, font_size, color, callback)
end

--activity
function RichTextUtil.ParseActivity(rich_text, params, font_size, color)
	local act_type = tonumber(params[2])
	if nil == act_type then return end
	local act_name = ""
	local act_name = ActivityData.Instance:GetActivityNameByType(tonumber(params[2]))
	act_name = act_name .. Language.OpenServer.HuoDongText
	color = TEXT_COLOR.YELLOW_1
	RichTextUtil.AddText(rich_text, act_name, color)
end

--prof
function RichTextUtil.ParseProf(rich_text, params, font_size, color)
	local prof_name = Language.Common.ProfName[tonumber(params[2] or 0)] or ""
	RichTextUtil.AddText(rich_text, prof_name, TEXT_COLOR.GREEN)
end

--mountfly
function RichTextUtil.ParseMountFly(rich_text, params, font_size, color)
	-- local fly_level = tonumber(params[2]) or 0
	-- local name = MountData.Instance:GetFlyNameByFlyLevel(fly_level)
	-- RichTextUtil.AddText(rich_text, name, font_size, COLOR.GREEN)
end

-- 精灵命魂
function RichTextUtil.ParseHunShou(rich_text, params, font_size, color)
	if #params < 2 then return end
	local cfg = SpiritData.Instance:GetSpiritSoulCfg(tonumber(params[2]))
	if nil == cfg then
		return
	end
	RichTextUtil.AddText(rich_text, cfg.name, SOUL_NAME_COLOR[cfg.hunshou_color] or TEXT_COLOR.GREEN)
end

--chengjiu_title
function RichTextUtil.ParseChengJiuTitle(rich_text, params, font_size, color)
	if #params < 2 then return end
	local cfg = AchieveData.Instance:GetAchieveTitleDataByLevel(tonumber(params[2]))
	if nil == cfg then
		return
	end
	RichTextUtil.AddText(rich_text, cfg.name, AchieveData.Instance:GetTitleColor(cfg.level) or TEXT_COLOR.GREEN)
end

--xianjie
function RichTextUtil.ParseXianJie(rich_text, params, font_size, color)
	-- if #params < 3 then return end
	-- local cfg = ShengWangData.GetXianJieCfgByLv(tonumber(params[3]))
	-- if nil == cfg then
	-- 	return
	-- end
	-- RichTextUtil.AddText(rich_text, cfg.name, font_size, Str2C3b(params[2]))
end

--card_color
function RichTextUtil.ParseCardColor(rich_text, params, font_size, color)
	-- local color = tonumber(params[2]) or 1
	-- local color_name = Language.Card.ColorName[color]
	-- if nil ~= color_name then
	-- 	RichTextUtil.AddText(rich_text, color_name, font_size, ITEM_COLOR[color])
	-- end
end

--card 神域
function RichTextUtil.ParseCard(rich_text, params, font_size, color)
	local card_id = tonumber(params[2]) or 1
	-- local prof = tonumber(params[3]) or 1
	local card_name = SwordArtOnlineData.Instance:GetCardZuInfoById(card_id)
	if nil ~= card_name then
		RichTextUtil.AddText(rich_text, card_name, TEXT_COLOR.GREEN)
	end
end

function RichTextUtil.ParseMine(rich_text, params, font_size, color)
	local mine_index = tonumber(params[2]) or 0
	local cfg = GoldHuntData.Instance:GetMineralInfo(mine_index)
	color = TEXT_COLOR.YELLOW
	if nil ~= cfg then
		RichTextUtil.AddText(rich_text, cfg, color)
	end
end

function RichTextUtil.ParseFanFanZhuan(rich_text, params, font_size, color)
	-- local fanfan_index = tonumber(params[1]) or 0
	-- local cfg = FanfanzhuanData.Instance:GetWrodInfo(fanfan_index)
	-- if nil ~= cfg and nil ~= cfg.word then
	-- 	RichTextUtil.AddText(rich_text, cfg.word, font_size, COLOR.GREEN,text_attr)
	-- end
end

function RichTextUtil.ParseTuanZhan(rich_text, params, font_size, color)
	-- local side = tonumber(params[2])
	-- local side_name = Language.KuafuTeambattle["side" .. side] or ""
	-- local color = 0 == side and COLOR.RED or COLOR.PURPLE
	-- RichTextUtil.AddText(rich_text, side_name, font_size, color)
end

function RichTextUtil.ParseMulitMount(rich_text, params, font_size, color)
	local seq = tonumber(params[2])
	local mount_data = MultiMountData.Instance:GetImageCfgById(seq)
	local name = ""
	if mount_data ~= nil and next(mount_data) ~= nil then
		name = mount_data.mount_name
	end
	RichTextUtil.AddText(rich_text, name, font_size, COLOR.YELLOW)
end

function RichTextUtil.ParseBubble(rich_text, params, font_size, color)
	local seq = tonumber(params[2])
	local cfg = CoolChatData.Instance:GetBubbleCfg()
	local bubble_name = ""
	for k, v in ipairs(cfg) do
		if v.seq == seq + 1 then
			bubble_name = v.name
			break
		end
	end
	RichTextUtil.AddText(rich_text, bubble_name, TEXT_COLOR.GREEN)
end

function RichTextUtil.ParseCardzu(rich_text, params, font_size, color)
	local card_id = tonumber(params[2]) or 0
	local card_name = SwordArtOnlineData.Instance:GetCardZuInfoById(card_id).cardzu_name
	if nil ~= card_name then
		RichTextUtil.AddText(rich_text, card_name, TEXT_COLOR.GREEN)
	end
end

-- gengu_title
function RichTextUtil.ParseGengu(rich_text, params, font_size, color)
	-- local gengu_level = tonumber(params[2]) or 0
	-- local cfg = XiuLianData.Instance:GetGenGuTitle(gengu_level)
	-- if nil ~= cfg and nil ~= cfg.title_name then
	-- 	RichTextUtil.AddText(rich_text, cfg.title_name, font_size, COLOR.GREEN)
	-- end
end

-- jingmai_title
function RichTextUtil.ParseJingmai(rich_text, params, font_size, color)
	-- local jingmai_level = tonumber(params[2]) or 0
	-- local cfg = XiuLianData.Instance:GetMentalityTitle(jingmai_level)
	-- if nil ~= cfg and nil ~= cfg.gradename then
	-- 	RichTextUtil.AddText(rich_text, cfg.gradename, font_size, COLOR.GREEN)
	-- end
end

-- mentality
function RichTextUtil.ParseMentality(rich_text, params, font_size, color)
	-- local gengu_type = (tonumber(params[2]) or 0) + 1
	-- local gengu_name = Language.Meridian.NameList[gengu_type]
	-- if nil ~= gengu_name then
	-- 	RichTextUtil.AddText(rich_text, gengu_name, font_size, COLOR.GREEN)
	-- end
end

-- shenzhuang
function RichTextUtil.ParseShenzhuang(rich_text, params, font_size, color)
	-- local index = tonumber(params[2]) or 0
	-- local level = tonumber(params[3]) or 1
	-- level = math.max(level, 1)
	-- local shenzhuang_name = EquipmentShenData.Instance:GetShenzhuangName(index, level)
	-- if nil ~= shenzhuang_name then
	-- 	RichTextUtil.AddText(rich_text, shenzhuang_name, font_size, COLOR.GREEN)
	-- end
end

-- jinglingyun
function RichTextUtil.ParseSpriteCloud(rich_text, params, font_size, color)
	-- local image_id = tonumber(params[2]) or 0
	-- local cloud_name = JingLingData.GetFlyNameByImgid(image_id)
	-- if nil ~= cloud_name then
	-- 	RichTextUtil.AddText(rich_text, cloud_name, font_size, COLOR.GREEN)
	-- end
end

-- jinglingslot
function RichTextUtil.ParseSpriteSlot(rich_text, params, font_size, color)
	-- local index = tonumber(params[2]) or 0
	-- local strength_level = tonumber(params[3]) or 0
	-- local slot_name = JingLingData.GetJinglingEquipName(index, strength_level)
	-- if nil ~= slot_name then
	-- 	RichTextUtil.AddText(rich_text, slot_name, font_size, COLOR.GREEN)
	-- end
end

-- taozhuang
function RichTextUtil.ParseTaozhuang(rich_text, params, font_size, color)
	local tz_type = tonumber(params[2]) or 0
	local param = tonumber(params[3]) or 0
	local tz_name = ""
	if tz_type == TAOZHUANG_TYPE.BAOSHI_TAOZHUANG then
		tz_name = ForgeData.Instance:GetTotalGemCfgByLevel(param)
	elseif tz_type == TAOZHUANG_TYPE.STREGNGTHEN_TAOZHUANG then
		tz_name = ForgeData.Instance:GetTotalStrengthNameByLevel(param)
	elseif tz_type == TAOZHUANG_TYPE.EQUIP_UP_STAR_TAPZHUANG then
		tz_name = ForgeData.Instance:GetTotleStarBySeq(param)
	end
	if nil ~= tz_name then
		RichTextUtil.AddText(rich_text, tz_name, TEXT_COLOR.GREEN)
	end
end

-- pet
function RichTextUtil.ParsePet(rich_text, params, font_size, color)
	-- local tz_index = tonumber(params[2]) or 0
	-- local cfg = EquipmentShenData.Instance:GetTaoZhuangCfg(tz_index)
	-- if nil ~= cfg and nil ~= cfg.zuhe_name then
	-- 	RichTextUtil.AddText(rich_text, cfg.zuhe_name, font_size, COLOR.GREEN)
	-- end
end

-- 神域
function RichTextUtil.ParseSwordArtOnline(rich_text, params, font_size, color)
	-- local tz_index = tonumber(params[2]) or 0
	-- local cfg = EquipmentShenData.Instance:GetTaoZhuangCfg(tz_index)
	-- if nil ~= cfg and nil ~= cfg.zuhe_name then
	-- 	RichTextUtil.AddText(rich_text, cfg.zuhe_name, font_size, COLOR.GREEN)
	-- end
end

-- 魔卡
function RichTextUtil.ParseMagicCard(rich_text, params, font_size, color)
	local tz_index = tonumber(params[2]) or 0
	local cfg = MagicCardData.Instance:GetInfoById(tz_index)
	local cur_color = MagicCardData.Instance:GetRgbByColor(cfg.color)
	if nil ~= cfg and nil ~= cfg.card_name then
		local function callback(btn)
			if nil ~= btn then
				btn:SetClickListener(function()
					local item_data = {}
					item_data = {item_id = cfg.item_id, num = 1, is_bind = 0, show_red_point = false, card_id = cfg.card_id}
					TipsCtrl.Instance:OpenItem(item_data)
				end)
			end
		end
		RichTextUtil.CreateBtn(rich_text, cfg.card_name, font_size, cur_color, callback)
	end
end

-- 鱼塘
function RichTextUtil.ParseFishPond(rich_text, params, font_size, color)
	-- local tz_index = tonumber(params[2]) or 0
	-- local cfg = FishpondData.Instance:GetFishCfgByType(tz_index)
	-- local name = ""
	-- if nil ~= cfg and nil ~= cfg.fish_id then
	-- 	name = ItemData.Instance:GetItemConfig(cfg.fish_id).name
	-- end
	-- if "" ~= name then
	-- 	RichTextUtil.AddText(rich_text, name, font_size, COLOR.GREEN)
	-- end
end

function RichTextUtil.ParseFindCrossTeammates(rich_text, params, font_size, color)
	-- print_warning(rich_text, params, font_size, color)
	-- for k,v in pairs(params) do
	-- 	print_warning(k,v)
	-- end
end

function RichTextUtil.ParseCrossMine(rich_text, params, font_size, color)
	local mine_id = tonumber(params[2]) or 0
	local mine_cfg = KuaFuMiningData.Instance:GetMiningCfg().mine_cfg
	if mine_cfg == nil or mine_cfg[mine_id] == nil then return end
	local name = string.format(mine_cfg[mine_id].name .. "*" .. tonumber(params[3]) or 1)
	RichTextUtil.AddText(rich_text, name, TEXT_COLOR.GREEN)
end

function RichTextUtil.ParseGuildBack(rich_text, params, font_size, color)
	local function callback(btn)
		if nil ~= btn then
			btn:SetClickListener(function()
				GuildCtrl.Instance:SendGuildBackToStationReq(GameVoManager.Instance:GetMainRoleVo().guild_id)
			end)
		end
	end

	RichTextUtil.CreateBtn(rich_text, "返回驻地", font_size, TEXT_COLOR.WHITE, callback)
end

function RichTextUtil.ParseTopType(rich_text, params, font_size, color)
	local index = tonumber(params[2]) or 0
	local name = RankData.Instance:GetRankNameByIndex(index) or ""
	RichTextUtil.AddText(rich_text, name, TEXT_COLOR.YELLOW_1)
end

function RichTextUtil.ParseZhangKong(rich_text, params, font_size, color)
	local grid_id = tonumber(params[2]) or 0
	local cfg = ShenGeData.Instance:GetZhangkongInfoByGrid(grid_id)
	local flag_name = ""
	if cfg ~= nil and cfg.name ~= nil then
		flag_name = cfg.name

		local tab = {
			[0] = "#1a62a2",
			[1] = "#059e6b",
			[2] = "#cb623b",
			[3] = "#19882d",
		}

		--flag_name = ToColorStr(flag_name, tab[grid_id])
	end

	RichTextUtil.AddText(rich_text, flag_name, TEXT_COLOR.GREEN)
end

function RichTextUtil.CrossFish(rich_text, params, font_size, color)
	local tz_index = tonumber(params[2]) or 0
	local cfg = FishingData.Instance:GetFishingCfg()
	local name = ""
	if nil ~= cfg.fish then
		for k,v in pairs(cfg.fish) do
			if v.type == tz_index then
				name = v.name
				break
			end
		end 
	end
	if "" ~= name then
		RichTextUtil.AddText(rich_text, name, TEXT_COLOR.YELLOW)
	end
end

function RichTextUtil.FlyToPos(scene_id, x, y, scene_key)
	local now_scene_id = Scene.Instance:GetSceneId()
	if now_scene_id == scene_id then
		local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
		if GuajiCtrl.CheckRange(x, y, 1) then
			local now_scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
			if scene_key and scene_key == now_scene_key then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.IsArrive)
				return
			end
		end
	else
		--当前场景无法传送
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type ~= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
			return
		end

		--目标场景无法传送
		local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
		if scene_config then
			local scene_type = scene_config.scene_type
			if scene_type ~= SceneType.Common or GuajiCtrl.Instance:IsSpecialCommonScene(scene_id) then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotEnterScene)
				return
			end
		end
	end

	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0, false, scene_key, true)
end

--点击链接类型
function RichTextUtil.DoByLinkType(link_type, param1, param2, param3)
	local link_cfg = RichTextUtil.GetOpenLinkCfg(link_type)
	if nil == link_cfg then
		print("请先配置", link_type)
		return
	end
	if link_type == CHAT_LINK_TYPE.GUILD_APPLY then								-- 仙盟申请
		if GameVoManager.Instance:GetMainRoleVo().guild_id > 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.HasInGuild)
		else
			-- ViewManager.Instance:Open(link_cfg.view_name)
			GuildCtrl.Instance:SendApplyForJoinGuildReq(tonumber(param1))
			--FunOpen.Instance:OpenViewByName(link_cfg.view_name, link_cfg.index)
		end

	elseif link_type == CHAT_LINK_TYPE.HUSONG then								-- 我要护送
		YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()

	elseif link_type == CHAT_LINK_TYPE.TOMB_BOSS then							-- 击杀皇陵BOSS
		TombExploreCtrl.Instance:GoToBoss()
	elseif link_type == CHAT_LINK_TYPE.CAN_JIA_HUN_YAN then						-- 婚宴副本
		MarriageCtrl.Instance:SendEnterWeeding(tonumber(param1) or 0)

	elseif link_type == CHAT_LINK_TYPE.WO_QIUHUN then							-- 我要求婚
		local user_info = {user_id = tonumber(param1) or 0, gamename = param2, sex = tonumber(param3) or 0}
		local can_mry, str = MarryData.Instance:CheckCanMarry(user_info, true)
		if nil ~= can_mry then
			MarryCtrl.Instance:OpenProposeView(user_info.user_id, str)
		else
			SysMsgCtrl.Instance:ErrorRemind(str)
		end

	elseif link_type == CHAT_LINK_TYPE.WO_CHONGZHI then							-- 我要充值
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	elseif link_type == CHAT_LINK_TYPE.DAY_DANBI then
		-- ServerActivityCtrl.Instance:OpenByActId(ServerActClientId.RAND_DAY_DANBI_CHONGZHI)

	-- elseif link_type == CHAT_LINK_TYPE.WO_QINGYUANFUBEN then   -- 情缘副本 同意组队
		-- local lover_id = RoleData.Instance.role_vo.lover_uid
		-- SocietyCtrl.Instance:SendInviteUserTransmitRet(lover_id, 0)

	elseif link_type == CHAT_LINK_TYPE.WO_JINGLING_HALO then   -- 情缘副本 同意组队
		-- if nil ~= Scene.Instance:GetMainRole() and nil ~= Scene.Instance:GetMainRole().vo.level and Scene.Instance:GetMainRole().vo.level >= 650 then
		-- FunOpen.Instance:OpenViewByName(link_cfg.view_name, link_cfg.tab_index)
		ViewManager.Instance:Open(link_cfg.view_name, link_cfg.tab_index)
		-- else
		-- SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.JingLingHaloLevel)
		-- end
	elseif link_type == CHAT_LINK_TYPE.CROSS_FB_TEAMMATE then   -- 跨服组队招募队员

	--elseif link_type == CHAT_LINK_TYPE.ZHENBAOGE then   -- 跨服组队招募队员

	elseif link_type == CHAT_LINK_TYPE.VIP then							-- 成为vip
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
		ViewManager.Instance:Open(ViewName.VipView)
	elseif link_type == CHAT_LINK_TYPE.DA_FU_HAO then				--大富豪
		-- if DaFuHaoData.Instance:GetLimitLevel() > GameVoManager.Instance:GetMainRoleVo().level then
		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.CrossTeam.Levellimit)
		-- 	return
		-- end
		-- local cfg = DaFuHaoData.Instance:GetDaFuHaoOtherCfg()
		-- if cfg then
			-- local scene_id = cfg.position[1].scene_id
			-- if scene_id == Scene.Instance:GetSceneId() then
			-- 	TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
			-- else
				-- GuajiCtrl.Instance:MoveToScenePos(cfg.scene_id, cfg.fly_pos_x, cfg.fly_pos_y, true, 0)
				-- DaFuHaoCtrl.Instance:SendGetGatherInfoReq()
			-- end
		-- end
		local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo()
		if dafuhao_info ~= nil then
			local gather_total_times = dafuhao_info.gather_total_times
			if gather_total_times and gather_total_times >= 20 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Activity.CollectIsMax)
				return
			end
		end
		
		local cfg = DaFuHaoData.Instance:GetDaFuHaoOtherCfg()
		if nil ~= cfg then
			local role_camp = GameVoManager.Instance:GetMainRoleVo().camp
			ActivityCtrl.Instance:SendActivityEnterReq(DaFuHaoDataActivityId.ID)
			GuajiCtrl.Instance:MoveToScenePos(cfg["scene_id_"..role_camp], cfg["fly_pos_x_"..role_camp], cfg["fly_pos_y_"..role_camp], true, 0)
			DaFuHaoCtrl.Instance:SendGetGatherInfoReq()
		end
	elseif link_type == CHAT_LINK_TYPE.GUILD_WELLCOME then
		if guild_welcome_time > Status.NowTime then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.SpeackMax)
			return
		end
		guild_welcome_time = Status.NowTime + 5
		local str = Language.Chat.GuildWellCome[math.random(4)]
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, str)
	elseif link_type == CHAT_LINK_TYPE.MAGIC_WEAPON_VIEW then
		GuajiCtrl.Instance:MoveToScene(AncientRelicsData.SCENE_ID)
	elseif link_type == CHAT_LINK_TYPE.BONFRIE then
		GuildBonfireCtrl.SendGuildBonfireGotoReq()
	elseif link_type == CHAT_LINK_TYPE.GUILD_MIJING then
		local function ok_callback()
			ViewManager.Instance:Close(ViewName.ChatGuild)
			GuildMijingCtrl.SendGuildFbEnterReq()
		end
		local des = Language.Guild.GoToGuildMiJing
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
	elseif link_type == CHAT_LINK_TYPE.GUILD_CALLIN then
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		if guild_id > 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.HasInGuild)
			return
		end
		GuildCtrl.Instance:SendApplyForJoinGuildReq(param1)
	elseif link_type == CHAT_LINK_TYPE.XING_ZUO_YI_JI then 		-- 星座遗迹
		ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI, 0)
		ViewManager.Instance:CloseAll()
	elseif link_type == CHAT_LINK_TYPE.SHOUHUDCHEN then
		local dachen_other_info = NationalWarfareData.Instance:GetDachenOtherInfo()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local pos = Split(dachen_other_info[1]["camp_" .. vo.camp .. "_dachen_monster_pos"], ",")
		GuajiCtrl.Instance:MoveToPos(CampData.Instance:GetCampScene(vo.camp), pos[1], pos[2], 1, 1, nil, nil, true)
	elseif link_type == CHAT_LINK_TYPE.BAOHUQINGBAO then
		local npc_id = NationalWarfareData.Instance:GetCiTanRefreshNpc()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if npc_id then
			GuajiCtrl.Instance:MoveToNpc(npc_id, nil, CampData.Instance:GetCampScene(vo.camp), nil, nil, true)
		end
	elseif link_type == CHAT_LINK_TYPE.BAOHUZHUANKUAI then
		local npc_id = NationalWarfareData.Instance:GetBanZhuanRefreshNpc()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if npc_id then
			GuajiCtrl.Instance:MoveToNpc(npc_id, nil, CampData.Instance:GetCampScene(vo.camp), nil, nil, true)
		end
	elseif link_type == CHAT_LINK_TYPE.SHOUHUGUOQI then
		local guoqi_other_info = NationalWarfareData.Instance:GetGuoQiOtherInfo()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local pos = Split(guoqi_other_info[1]["camp_" .. vo.camp .. "_flag_monster_pos"], ",")
		GuajiCtrl.Instance:MoveToPos(CampData.Instance:GetCampScene(vo.camp), pos[1], pos[2], 1, 1, nil, nil, true)
	elseif link_type == CHAT_LINK_TYPE.PROTECT_TOWER then
		local tower_info = NationalWarfareData.Instance:GetCampWarFateOtherCfg()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local pos = Split(tower_info["camp_" .. vo.camp .. "_qiyun_tower_pos"], ",")
		GuajiCtrl.Instance:MoveToPos(CampData.Instance:GetCampScene(vo.camp), pos[1], pos[2], 1, 1, nil, nil, true)
	elseif tonumber(link_type) == CHAT_LINK_TYPE.YUNBIAOSUPPORT then
		GuajiCtrl.Instance:MoveToPos(tonumber(param1), tonumber(param2), tonumber(param3))
	elseif tonumber(link_type) == CHAT_LINK_TYPE.KF_MINING then
		GuajiCtrl.Instance:MoveToPos(tonumber(param1), tonumber(param2), tonumber(param3))
	elseif link_type == CHAT_LINK_TYPE.JUBAOPEN then
		if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.ActivityFinish)
			return
		elseif JuBaoPenData.Instance:IsMaxTime() then
			SysMsgCtrl.Instance:ErrorRemind(Language.JuBaoPen.TimesNoEnough)
			return
		elseif not OpenFunData.Instance:CheckIsHide("jubaopen") then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.FuncNoOpen)
			return
		end
		ViewManager.Instance:Open(link_cfg.view_name)
	elseif link_type == CHAT_LINK_TYPE.SERVER_FLAG then
		local cfg = LianFuDailyData.Instance:GetCrossXYJDCfg()
		local group = tonumber(param1) + 1
		local center_pos = Split(cfg.other[1]["group" .. group .. "_flag_monster_born_pos"], ",")
		MoveCache.scene_id = cfg.other[1].scene_id
		MoveCache.x = center_pos[1]
		MoveCache.y = center_pos[2]
		GuajiCtrl.Instance:MoveToScenePos(cfg.other[1].scene_id, center_pos[1], center_pos[2])
	elseif link_type == CHAT_LINK_TYPE.SERVER_JUDIAN then
		local cfg = LianFuDailyData.Instance:GetCrossXYJDCfg()
		local judian_cfg = LianFuDailyData.Instance:GetJuDianIdCfg((tonumber(param1)))
		if judian_cfg and judian_cfg[1] and cfg and cfg.other then
			local center_pos = Split(judian_cfg[1].center_pos, ",")
			MoveCache.scene_id = cfg.other[1].scene_id
			MoveCache.x = center_pos[1]
			MoveCache.y = center_pos[2]
			GuajiCtrl.Instance:MoveToScenePos(cfg.other[1].scene_id, center_pos[1], center_pos[2])
		end
	elseif link_type == CHAT_LINK_TYPE.LOTTETY_BET then
		if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOTTERY) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.ActivityFinish)
			return
		end

		ViewManager.Instance:Open(link_cfg.view_name)
	else
		ViewManager.Instance:Open(link_cfg.view_name, link_cfg.tab_index)
	end
	ViewManager.Instance:Close(ViewName.Chat)
end

function RichTextUtil.GetOpenLinkCfg(link_type)
	if RichTextUtil.link_cfg_list == nil then
		RichTextUtil.link_cfg_list = {
			[CHAT_LINK_TYPE.GUILD_APPLY] = {name = "申请加入", view_name = ViewName.Guild, tab_index = TabIndex.guild_guildlist},
			[CHAT_LINK_TYPE.EQUIP_QIANG_HUA] = {name = "我要强化", view_name = ViewName.Forge, tab_index = TabIndex.forge_strengthen},
			[CHAT_LINK_TYPE.MOUNTJINJIE] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.mount_jinjie},
			[CHAT_LINK_TYPE.HUSONG] = {name = "我要护送", view_name = ViewName.Husong, tab_index = nil},
			[CHAT_LINK_TYPE.EQUIP_UP_STAR] = {name = "我要升星", view_name = ViewName.Forge, tab_index = TabIndex.forge_up_star},
			[CHAT_LINK_TYPE.GUILD_JUANXIAN] = {name = "我要捐献", view_name = ViewName.Guild, tab_index = TabIndex.guild_donate},
			[CHAT_LINK_TYPE.EQUIP_FULING] = {name = "我要附灵", view_name = ViewName.Equipment, tab_index = TabIndex.equipment_fuling},
			[CHAT_LINK_TYPE.MOUNT_LIEHUN] = {name = "我要鉴星", view_name = ViewName.Forge, tab_index = TabIndex.forge_soul},
			[CHAT_LINK_TYPE.JINGLING_UPLEVEL] = {name = "我要升级", view_name = ViewName.SpiritView, tab_index = TabIndex.spirit_spirit},
			[CHAT_LINK_TYPE.ACHIEVE_UP] = {name = "我要提升", view_name = ViewName.BaoJu, tab_index = TabIndex.baoju_achieve_title},
			[CHAT_LINK_TYPE.EQUIP_JICHENG] = {name = "我要继承", view_name = ViewName.Equipment, tab_index = TabIndex.equipment_jicheng},
			[CHAT_LINK_TYPE.XIANJIE_UP] = {name = "我要提升", view_name = ViewName.ShengWang, tab_index = TabIndex.shengwang_xianjie},
			[CHAT_LINK_TYPE.EQUIP_UPLEVEL] = {name = "我要进阶", view_name = ViewName.Equipment, tab_index = TabIndex.equipment_levelup},
			[CHAT_LINK_TYPE.ROLE_BAOSHI] = {name = "我要镶嵌", view_name = ViewName.Forge, tab_index = TabIndex.forge_baoshi},
			[CHAT_LINK_TYPE.ROLE_WINGUP] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.wing_jinjie},
			[CHAT_LINK_TYPE.DA_FU_HAO] = {name = "立即前往", view_name = ViewName.Advance, tab_index = TabIndex.wing_jinjie},
			[CHAT_LINK_TYPE.VIP]= {name = "成为VIP", view_name = ViewName.Vip, tab_index = nil},
			[CHAT_LINK_TYPE.BOSS_WORLD] = {name = "立即前往", view_name = ViewName.Boss, tab_index = TabIndex.world_boss},
			[CHAT_LINK_TYPE.BOSS_JINGYING] = {name = "前往击杀", view_name = ViewName.Boss, tab_index = nil},
			[CHAT_LINK_TYPE.XUNBAO] = {name = "我要寻宝", view_name = ViewName.Treasure, tab_index = TabIndex.treasure_choujiang},
			[CHAT_LINK_TYPE.SPIRIT_XUNBAO] = {name = "猎取精灵", view_name = ViewName.SpiritView, tab_index = TabIndex.spirit_hunt},
			[CHAT_LINK_TYPE.ZHI_ZUN_YUE_KA] = {name = "变身至尊", view_name = ViewName.MonthCard, tab_index = nil},
			[CHAT_LINK_TYPE.SUI_JI_CHOU_JIANG] = {name = "我要抽奖", view_name = ViewName.ActRoller, tab_index = nil},
			[CHAT_LINK_TYPE.CAN_JIA_HUN_YAN] = {name = "我要参加", view_name = ViewName.CanJiaHunYan, tab_index = nil},
			[CHAT_LINK_TYPE.WO_QIUHUN] = {name = "我要求婚", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.FAZHEN_UP] = {name = "我要进阶", view_name = ViewName.RoleView, tab_index = TabIndex.role_wf},
			[CHAT_LINK_TYPE.MOUNT_FLY] = {name = "我要飞升", view_name = ViewName.Mount, tab_index = TabIndex.mount_flyup},
			[CHAT_LINK_TYPE.WO_CHONGZHI] = {name = "我要充值", view_name = ViewName.VipView, tab_index = nil},
			[CHAT_LINK_TYPE.DAY_DANBI] = {name = "查看活动", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.PaTa] = {name = "我要挑战", view_name = ViewName.FuBen, tab_index = TabIndex.fb_tower},
			-- [CHAT_LINK_TYPE.WO_QINGYUANFUBEN]  =  {name = "接受邀请", view_name = ViewName.Marry, tab_index = TabIndex.marry_fb},
			[CHAT_LINK_TYPE.GENGU]  =  {name = "提升根骨", view_name = ViewName.RoleView, tab_index = TabIndex.role_gengu},
			[CHAT_LINK_TYPE.JINGMAI]  =  {name = "提升经脉", view_name = ViewName.RoleView, tab_index = TabIndex.role_jingmai},
			[CHAT_LINK_TYPE.SPRITE_FLY]  =  {name = "我要进阶", view_name = ViewName.Sprite, tab_index = TabIndex.jingling_train_fly},
			[CHAT_LINK_TYPE.FORGE_EQUIP_UPLEVEL]  =  {name = "我要升级", view_name = ViewName.Forge, tab_index = TabIndex.forge_cast},
			[CHAT_LINK_TYPE.SHEN_GRADE]  =  {name = "我要进阶", view_name = ViewName.ShenEquip, tab_index = TabIndex.equipmentshen_jinjie},
			[CHAT_LINK_TYPE.WO_LINGYU_FB]  =  {name = "我要挑战", view_name = ViewName.Daily, tab_index = TabIndex.daily_richang},
			[CHAT_LINK_TYPE.ZHENBAOGE]  =  {name = "珍宝阁", view_name = ViewName.TreasureLoftView, tab_index = nil},
			[CHAT_LINK_TYPE.MIJINGTAOBAO]  =  {name = "秘境淘宝", view_name = ViewName.MiJingTaoBao, tab_index = nil},
			[CHAT_LINK_TYPE.WO_LOTTERYTREE] = {name = "转转乐", view_name = ViewName.ZhuangZhuangLe, tab_index = nil},
			[CHAT_LINK_TYPE.WO_KINGDRAW] = {name = "大奖翻翻乐", view_name = ViewName.FanFanZhuanView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_LINGQI] =  {name = "我要灵器", view_name = ViewName.ShenEquip, tab_index = TabIndex.lq_shuxing},
			[CHAT_LINK_TYPE.WO_LIEQU] =  {name = "我要猎取", view_name = ViewName.GoldHuntView, tab_index = nil},
			[CHAT_LINK_TYPE.DIVINATION] =  {name = "天命卜卦", view_name = ViewName.Divination, tab_index = nil},
			[CHAT_LINK_TYPE.WO_FANFANZHUAN] =  {name = "翻翻转", view_name = ViewName.Fanfanzhuan, tab_index = nil},
			[CHAT_LINK_TYPE.WO_MULTIMOUNT] =  {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.multi_mount_jinjie},
			[CHAT_LINK_TYPE.WO_FARM_HUNT] =  {name = "我要抽奖", view_name = ViewName.Marry, tab_index = TabIndex.marry_farm_hunt},
			[CHAT_LINK_TYPE.WO_MAGIC_CARD] =  {name = "我要魔卡", view_name = ViewName.MoLong, tab_index = TabIndex.magic_lottery},
			[CHAT_LINK_TYPE.WO_JINGLING_HALO] =  {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.meiren_guanghuan},
			[CHAT_LINK_TYPE.WO_TREASURE_BUSINESSMAN] =  {name = "仙宝商人", view_name = ViewName.TreasureBusinessman, tab_index = nil},
			[CHAT_LINK_TYPE.WO_MOUNTJINGPO] =  {name = "我要进阶", view_name = ViewName.MountJingPo, tab_index = nil},
			[CHAT_LINK_TYPE.CROSS_FB_TEAMMATE] =  {name = "申请加入", view_name = ViewName.FuBen, tab_index = TabIndex.fb_many_people},
			[CHAT_LINK_TYPE.TOMB_BOSS] =  {name = "立即前往", view_name = ViewName.FuBen, tab_index = TabIndex.fb_many_people},
			[CHAT_LINK_TYPE.SPIRIT_FAZHEN] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.halidom_jinjie},
			[CHAT_LINK_TYPE.HALO_UPGRADE] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.halo_jinjie},
			[CHAT_LINK_TYPE.FIGHT_MOUNT_UPGRADE] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.fight_mount},
			[CHAT_LINK_TYPE.SHENGONG_UPGRADE] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.shengong_jinjie},
			[CHAT_LINK_TYPE.SHENYI_UPGRADE] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.shenyi_jinjie},
			[CHAT_LINK_TYPE.GUILD_WELLCOME] = {name = "打个招呼", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.TIANSHEN_ZHUANGBEI] = {name = "前往进阶", view_name = ViewName.Player, tab_index = TabIndex.role_rebirth},
			[CHAT_LINK_TYPE.MAGIC_WEAPON_VIEW] = {name = "前往夺宝", view_name = ViewName.MagicWeaponView, tab_index = nil},
			[CHAT_LINK_TYPE.MARRY_TUODAN] = {name = "我来瞅瞅", view_name = ViewName.Marriage, tab_index = TabIndex.marriage_monomer},
			[CHAT_LINK_TYPE.KF_BOSS] = {name = "立即前往", view_name = ViewName.Boss, tab_index = TabIndex.kf_boss},
			[CHAT_LINK_TYPE.BONFRIE] = {name = "立即前往", view_name = "", tab_index = ""},
			[CHAT_LINK_TYPE.GUILD_MIJING] = {name = "立即前往", view_name = "", tab_index = ""},
			[CHAT_LINK_TYPE.GUILD_CALLIN] = {name = "加入家族", view_name = "", tab_index = ""},
			[CHAT_LINK_TYPE.WO_COMPOSE] = {name = "我要合成", view_name = ViewName.Forge, tab_index = TabIndex.forge_compose},
			[CHAT_LINK_TYPE.WO_RUNE] = {name = "前往获取", view_name = ViewName.Rune, tab_index = TabIndex.rune_treasure},
			[CHAT_LINK_TYPE.SHEN_BING] = {name = "我要升级", view_name = ViewName.Player, tab_index = TabIndex.role_shenbing},
			[CHAT_LINK_TYPE.SHEN_GE_BLESS] = {name = "我要祈福", view_name = ViewName.ShenGeView, tab_index = TabIndex.shen_ge_bless},
			[CHAT_LINK_TYPE.XING_ZUO_YI_JI] = {name = "立即前往", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.SHEN_GE_COMPOSE] = {name = "我要合成", view_name = ViewName.ShenGeView, tab_index = TabIndex.shen_ge_compose},
			[CHAT_LINK_TYPE.SHENGXIAO_TU] = {name = "我要拼图", view_name = ViewName.ShenGeView, tab_index = TabIndex.shengxiao_piece},
			[CHAT_LINK_TYPE.WO_HUNQI_DAMO] = {name = "我要铸魂", view_name = ViewName.ShenGeView, tab_index = TabIndex.hunqi_damo},
			[CHAT_LINK_TYPE.WO_DAILY_RECHARGE] = {name = "前往查看", view_name = ViewName.LeiJiDailyView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_LEVEL_TOUZHI] = {name = "我要投资", view_name = ViewName.ShenGeView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_YUE_TOUZHI] = {name = "我要投资", view_name = ViewName.ShenGeView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_ZERO_GIFT] = {name = "我要领取", view_name = ViewName.FreeGiftView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_FENG_SHEN] = {name = "我要封神", view_name = ViewName.MolongMibaoView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_DISCOUNT] = {name = "我要抢购", view_name = ViewName.DisCount, tab_index = nil},
			[CHAT_LINK_TYPE.WO_TEMP_GIFT] = {name = "我要抢购", view_name = ViewName.KaiFuChargeView, tab_index = TabIndex.kaifu_twe_lve},
			[CHAT_LINK_TYPE.SHOUHUDCHEN] = {name = "立即前往", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.BAOHUQINGBAO] = {name = "立即前往", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.BAOHUZHUANKUAI] = {name = "立即前往", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.SHOUHUGUOQI] = {name = "立即前往", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.PROTECT_TOWER] = {name = "立即前往", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.GODDESS_SHENGWU] = {name = "我要升级", view_name = ViewName.Goddess, tab_index = TabIndex.goddess_shengwu},
			[CHAT_LINK_TYPE.GODDESS_GONGMING] = {name = "我要升级", view_name = ViewName.Goddess, tab_index = TabIndex.goddess_gongming},
			[CHAT_LINK_TYPE.XUFUCILI] = {name = "立即前往", view_name = ViewName.KaiFuChargeView, tab_index = TabIndex.kaifu_discount},
			[CHAT_LINK_TYPE.FAZHEN_GRADE] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.fight_mount},
			[CHAT_LINK_TYPE.KF_MINING] = {name = "前往击杀", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.YUNBIAOSUPPORT] = {name = "前往支援", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.WO_SHEN_GE] = {name = "我要升级", view_name = ViewName.ShenGeView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_ZHANG_KONG] = {name = "我要升级", view_name = ViewName.ShenGeView, tab_index = TabIndex.shen_ge_zhangkong},
			[CHAT_LINK_TYPE.WO_ZHULING] = {name = "我要注灵", view_name = ViewName.Rune, tab_index = TabIndex.rune_zhuling},
			[CHAT_LINK_TYPE.WO_XILIAN] = {name = "我要洗髓", view_name = ViewName.Beauty, tab_index = TabIndex.beauty_xilian},
			[CHAT_LINK_TYPE.WO_XIULIAN] = {name = "我要修炼", view_name = ViewName.ShenGeView, tab_index = TabIndex.shen_ge_godbody},
			[CHAT_LINK_TYPE.TIME_LIMIT] = {name = "限时秒杀", view_name = ViewName.TimeLimitSaleView, tab_index = nil},
			[CHAT_LINK_TYPE.JINYINTA] = {name = "金银塔", view_name = ViewName.JinYinTaView, tab_index = nil},
			[CHAT_LINK_TYPE.LUCKYCHESS] = {name = "幸运棋", view_name = ViewName.LuckyChessView, tab_index = nil},
			[CHAT_LINK_TYPE.TOTAL_CHONG_ZHI] = {name = "累计充值", view_name = ViewName.KaiFuChargeView, tab_index = TabIndex.kaifu_total_chongzhi},
			[CHAT_LINK_TYPE.JUBAOPEN] = {name = "我要聚宝", view_name = ViewName.JuBaoPen, tab_index = nil},
			[CHAT_LINK_TYPE.SERVER_FLAG] = {name = "立即前往", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.HAPPY_LOTTERY] = {name = "欢乐抽", view_name = ViewName.HappyBargainView, tab_index = TabIndex.happy_lottery},
			[CHAT_LINK_TYPE.SERVER_JUDIAN] = {name = "立即前往", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.LOTTETY_BET] = {name = "点击参与", view_name = ViewName.PriceLottery, tab_index = nil},
			[CHAT_LINK_TYPE.MUSEUM_CARD] = {name = "点击前往", view_name = ViewName.MuseumCardChapter, tab_index = nil},
			[CHAT_LINK_TYPE.MIDAUTUMNLOTTERY] = {name = "点击前往", view_name = ViewName.MidAutumnLottery,tab_index = nil},
			[CHAT_LINK_TYPE.HEAD_WEAR] = {name = "我要进阶", view_name = ViewName.DressUp, tab_index = TabIndex.headwear},
			[CHAT_LINK_TYPE.MASK] = {name = "我要进阶", view_name = ViewName.DressUp, tab_index = TabIndex.mask},
			[CHAT_LINK_TYPE.WAIST] = {name = "我要进阶", view_name = ViewName.DressUp, tab_index = TabIndex.waist},
			[CHAT_LINK_TYPE.KIRIN_ARM] = {name = "我要进阶", view_name = ViewName.DressUp, tab_index = TabIndex.kirin_arm},
			[CHAT_LINK_TYPE.BEAD] = {name = "我要进阶", view_name = ViewName.DressUp, tab_index = TabIndex.bead},
			[CHAT_LINK_TYPE.FA_BAO] = {name = "我要进阶", view_name = ViewName.DressUp, tab_index = TabIndex.fabao},
			[CHAT_LINK_TYPE.LUCKY_BOX] = {name = "立即前往", view_name = ViewName.LuckyBoxView, tab_index = nil},
			[CHAT_LINK_TYPE.LUCKY_TURN_EGG] = {name = "幸运扭蛋", view_name = ViewName.LuckyTurnEggView, tab_index = nil},
			[CHAT_LINK_TYPE.DASHE_TIAN_XIA] = {name = "大射天下", view_name = ViewName.DaSheTianXiaView, tab_index = nil},
		}
	end

	return RichTextUtil.link_cfg_list[link_type]
end

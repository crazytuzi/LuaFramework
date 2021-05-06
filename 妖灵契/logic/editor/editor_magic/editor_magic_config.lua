config = {}
config.run_env = nil
config.func = {
	ease = function()
		local t = table.keys(enum.DOTween.Ease)
		table.sort(t, function(k1, k2) return enum.DOTween.Ease[k1] < enum.DOTween.Ease[k2] end)
		return t
	end
}

config.select =
{
	get_type = {
		{"random", "随机"},
		{"list", "顺序"},
	},
	magic_type = {
		{1, "普通法术"},
	},
	pos_type = {
		{"nil", "无"},
		{"atk", "攻击者位置"},
		{"vic", "受击者位置"},
		{"atk_lineup", "攻击者阵法站位"},
		{"vic_lineup", "受击者阵法站位"},
		{"center", "战场中心"},
		{"atk_team_center", "攻击队伍中心"},
		{"vic_team_center", "受击队伍中心"},
		{"cam", "像机位置"},
	},
	bool_type = {
		{true, "是"},
		{false, "否"}
	},
	excutor_type = {
		{"atkobj", "攻击者"},
		{"vicobj", "受击者"},
		{"vicobjs", "受击者(全部)"},
		{"camobj", "像机"},
		{"allys", "友军(全部)"},
		{"ally_na", "友军(非攻击者)"},
		{"ally_alive", "友军(存活)"},
		{"enemys", "敌军(全部)"},
		{"enemy_nv", "敌军(非受击者)"},
	},
	body_type = {
		{"head", "头部"},
		{"waist", "腰部"},
		{"foot", "脚部"},
	},
	res_type = {
	},
	move_type = {
		{"line", "直线"},
		{"circle", "圆弧"},
		{"jump", "跳跃"}
	},
	transform_name_type = {
		{"Mount_Hit", "Mount_Hit"},
		{"Mount_Head", "Mount_Head"},
		{"Mount_Shadow", "Mount_Shadow"},
		{"Bip001", "Bip001"}
	},
	effect_cnt_type = {
		{"one", "单个"},
		{"allvic", "所有受击者"},
	},
	move_dir = {
		{"local_up", "本地坐标up"},
		{"local_right", "本地坐标right"},
		{"local_forward", "本地坐标forward"},
		{"world_up", "世界坐标up"},
		{"world_right", "世界坐标right"},
		{"world_forward", "世界坐标forward"},
	},
	excutor_dir = {
		{"empty", "无"},
		{"forward", "绑定人-前"},
		{"backward", "绑定人-后"},
		{"left", "绑定人-左"},
		{"right", "绑定人-右"},
		{"up", "绑定人-上"},
		{"down", "绑定人-下"},
		{"relative", "自定义"}
	}
}

config.normal_arg = {


}

config.arg = {
	--复合参数
	complex_pos = {
		sublist = {"base_pos", "relative_dis", "relative_angle", "depth"},
		need_run_env = true,
	},
	complex_effect ={
		sublist = {"path", "cached", "magic_layer", "preload"},
	},
	complex_color = {
		sublist = {"r", "g", "b", "a"},
	}
}

config.arg.template ={
	r = {
		name = "r",
		key = "r",
		format = "number_type",
		default = 255,
	},
	g = {
		name = "g",
		key = "g",
		format = "number_type",
		default = 255,
	},
	b = {
		name = "b",
		key = "b",
		format = "number_type",
		default = 255,
	},
	a = {
		name = "a",
		key = "a",
		format = "number_type",
		default = 255,
	},
	hit = {
		name = "受击时间",
		key = "hit",
		format = "number_type",
	},
	hurt = {
		name = "掉血时间",
		key = "hurt",
		format = "number_type",
	},
	endhit = {
		name = "结束受击",
		key = "endhit",
		format = "number_type",
	},
	start_time = {
		name = "起始时间",
		key = "start_time",
		format = "number_type",
	},

	path = {
		name = "资源路径",
		key = "path",
		select = function() 
				local dirs = {"/Effect/Magic"}
				local newList = {}
				if Utils.IsEditor() then
					for _, dir in pairs(dirs) do
						local list = IOTools.GetFiles(IOTools.GetGameResPath(dir), "*.prefab", true)
						for i, sPath in ipairs(list) do
							local idx = string.find(sPath, dir)
							if idx then
								table.insert(newList, string.sub(sPath, idx+1, string.len(sPath)))
							end
						end
					end
				end
				return newList
			end,
		wrap = function(s) return IOTools.GetFileName(s, true) end,
		input_width = 200,
	},
	flip = {
		name = "翻转",
		key = "flip",
		select_type = "bool_type",
		default = false,
	},
	cached = {
		name = "可以缓存",
		key = "is_cached",
		select_type = "bool_type",
		default = true,
	},
	base_pos = {
		name = "基本位置",
		key = "base_pos",
		select_type = "pos_type",
		default = "atk",
		isnil = true,
	},
	relative_dis = {
		name = "偏移距离",
		key = "relative_dis",
		format = "number_type",
		default = 0,
	},
	relative_angle = {
		name = "偏移角度",
		key = "relative_angle",
		format = "number_type",
		default = 0,
	},

	depth = {
		name = "高度",
		key = "depth",
		format = "number_type",
		default = 0,
	},

	--编辑主界面用的
	warrior_cnt = {
		name = "人数",
		key = "warrior_cnt",
		format = "number_type",
		default = 1,
		change_refresh = 2, -- 1保存数据，2刷新界面，3运行演示
	},
	atk_id = {
		name = "攻击者ID",
		key = "atk_id",
		format = "number_type",
		change_refresh = 1,
	},
	vic_ids = {
		name = "受击者ID",
		key = "vic_ids",
		format = "list_type",
		change_refresh = 1,
	},
	vic_array = {
		name = "受击组",
		key = "vic_array",
		format = "number_type", 
		change_refresh = 1,
	},
	damage_cnt = {
		name = "受击",
		key = "damage_cnt",
		select = {"one", "all"},
		wrap = {"分开受击", "一起受击"},
		change_refresh = 1,
	},
	sub_type = {
		name = "受击情况",
		key = "sub_type",
		select = {"one","all", "chain", "sequence"},
		wrap = {"单独","一起", "链式", "顺序"},
		change_refresh = 1,
	},
	shape = {
		name = "造型",
		key = "shape",
		select = ModelTools:GetAllModelShape(),
		default = 101,
		change_refresh = 2,
	},
	weapon = {
		name = "武器",
		key = "weapon",
		select = ModelTools:GetAllWeaponShape(),
		change_refresh = 2,
	},
	special_type = {
		name = "类型",
		key = "special_type",
		select = {0, define.War.Type.GuideBoss},
		wrap ={"正常", "Boss战"},
		change_refresh = 2,
	},
	run_env = {
		key = "run_env",
		name = "运行环境",
		select = {"war", "createrole", "dialogueani"},
		wrap = {"战斗", "创角", "剧情动画"},
		default = "war",
		change_refresh = 1,
	},
	magic_file = {
		key = "magic_file",
		name = "保存类型",
		select = {"magic", "goback", "createrole", "dialogueani"},
		wrap = {"法术", "归位", "创角", "剧情动画"},
		default = "magic",
	},
	magic_layer = {
		name = "置顶显示",
		key = "magic_layer",
		select = {"bottom", "center", "top"},
		wrap = {"遮挡", "正常", "置顶"},
		default = "center",
	},
	preload = {
		name = "预加载",
		key = "preload",
		select_type = "bool_type",
		default = true,
	},
}



local cmd = {}
cmd.MagcAnimStart = {
	wrap_name = "施法动作开始",
	sort = 0,
	args ={
	},
}

cmd.MagcAnimEnd = {
	wrap_name = "施法动作结束",
	sort = 0,
	args ={
	},
}

cmd.PlaySound = {
	wrap_name = "音效",
	sort = 0,
	args = {
		{
			name = "资源路径",
			key = "sound_path",
			select = function() 
					local dirs = {"/Audio/Sound/Magic"}
					local newList = {}
					if Utils.IsEditor() then
						for _, dir in pairs(dirs) do
							local list = IOTools.GetFilterFiles(IOTools.GetGameResPath(dir), function(s) return string.find(s, ".meta") == nil end, true)
							for i, sPath in ipairs(list) do
								local sPattrn = "Magic"
								local idx = string.find(sPath, sPattrn)
								if idx then
									table.insert(newList, string.sub(sPath, idx, string.len(sPath)))
								end
							end
						end
					end
					return newList
				end,
			wrap = function(s) return IOTools.GetFileName(s, false) end,
			input_width = 200,
		},
		
		{
			name = "音量大小(0-1)",
			key = "sound_rate",
			format = "number_type",
			default = 1,
		}
	},
}


cmd.VicHitInfo = {
	wrap_name = "受击信息",
	sort = 1,
	args ={
		{
			key = "hurt_delta",
			name = "掉血间隔",
			format = "number_type",
			default = 0,
		},

		{
			key = "face_atk",
			name = "面向攻击者",
			select_type = "bool_type",
			default = true,
		},
		{
			key = "play_anim",
			name = "受击动作",
			select_type = "bool_type",
			default = true,
		},
		{
			key = "damage_follow",
			name = "伤害跟随",
			select_type = "bool_type",
			default = true,
		},
		{
			key = "consider_hight",
			name = "考虑高度",
			select_type = "bool_type",
			default = false,
		},
	},
}

cmd.GroupCmd = {
	wrap_name = "指令组",
	sort = 1001,
	args ={
		{
			key = "group_type",
			name = "指令组类型",
			select = {"condition", "repeat"},
			wrap = {"条件判断","重复播放"},
			refresh_args = true,
		},
		["condition"] = {
			{
				key = "condition_name",
				name = "条件",
				select = {"ally", "endidx", "firstidx", "atkmale"},
				wrap = {"友方", "链式中最后个", "链式中第一个", "攻击者为男性"},
				default = "ally",
			},
			{
				key = "true_group",
				name = "true指令组",
				format = "string_type"
			},
			{
				key = "false_group",
				name = "false指令组",
				format = "string_type"
			},
		},
		["repeat"] = {
			{
				key = "group_names",
				name = "选取列表",
				format = "list_type",
			},
			{
				key = "get_type",
				name = "选取方式",
				select_type = "get_type",
			},
			{
				key = "cnt",
				name = "选取次数",
				format = "string_type",
				default = 0,
			},
		},
		{
			key = "add_type",
			name = "添加方式",
			select = {"insert", "merge"},
			wrap = {"插入","合并"},
			default = "insert",
		},
	},
}

cmd.GroupTime = {
	wrap_name = "指令组时间",
	sort = 1002,
	args ={
		{
			key = "duration",
			name = "组时间",
			format = "float",
			default = 0,
		},
	},
}
cmd.Name = {
	wrap_name = "喊招",
	sort = 1003,
	args ={
		{
			key = "alive_time",
			name = "存在时间",
			format = "number_type",
			default = 0.5,
		},
	},
}

cmd.PlayerBigMagic = {
	wrap_name = "主角大招",
	sort = 1004,
	args ={
		{
			key = "alive_time",
			name = "存在时间",
			format = "number_type",
			default = 0.5,
		},
	},
}

cmd.PlayAction = {
	wrap_name = "播放动作",
	sort = 10,
	args ={
		{	
			key = "action_name",
			name = "动作",
			format = "string_type",
			select = function ()
				local iShape
				local oView = CEditorMagicView:GetView()
				if oView then
					iShape = oView:GetShape()
				end
				return ModelTools.GetAllState(iShape)
			end,
		},
		{
			key = "excutor",
			name = "执行人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "atkobj",
		},
		{
			key = "start_frame",
			name = "起始帧(?)",
			format = "number_type",
		},
		{
			key = "end_frame",
			name = "结束帧(?)",
			format = "number_type",
		},
		{
			key = "action_time",
			name = "动作时间(?)",
			format = "number_type",
		},
		{
			key = "bak_action_name",
			name = "备用动作(?)",
			format = "string_type",
			select = function ()
				return ModelTools.GetAllState()
			end,
			force_input = true,
		},
	},
	short_desc = {"action_name"}
}

cmd.FaceTo = {
	wrap_name = "调整正面方向",
	sort = 11,
	args ={
		{
			key = "excutor",
			name = "执行人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "atkobj",
		},
		{
			key = "face_to",
			name = "方向类型",
			format = "string_type",
			select = {"default", "fixed_pos", "lerp_pos", "look_at", "random", "prepare"},
			wrap = {"默认方向", "固定位置", "匀速旋转", "LookAt", "随机方向", "预设"},
			default = "default",
			refresh_args = true, 
		},
		fixed_pos = {
			{
				key = "pos",
				name = "位置",
				complex_type = "complex_pos",
				col = 3,
			},
		},
		look_at = {
			{
				key = "pos",
				name = "位置",
				complex_type = "complex_pos",
				col = 3,
			},
		},
		lerp_pos = {
			{
				key = "h_dis",
				name = "水平移动",
				format = "number_type",
				default = 0,
			},
			{
				key = "v_dis",
				name = "垂直移动",
				format = "number_type",
				default = 0,
			},
		},
		random = {
			{
				key = "x_min",
				name = "x最小值",
				format = "number_type",
				default = 0,
			},
			{
				key = "x_max",
				name = "x最大值",
				format = "number_type",
				default = 360,
			},
			{
				key = "y_min",
				name = "y最小值",
				format = "number_type",
				default = 0,
			},
			{
				key = "y_max",
				name = "y最大值",
				format = "number_type",
				default = 360,
			},
			{
				key = "z_min",
				name = "z最小值",
				format = "number_type",
				default = 0,
			},
			{
				key = "z_max",
				name = "z最大值",
				format = "number_type",
				default = 360,
			},
		},
		prepare = {
			{
				key = "prepare_pos",
				name = "预设点",
				select_update = function() 
					local t = table.extend(table.keys(data.cameradata.INFOS.war),
					table.keys(data.cameradata.INFOS.warrior))
					table.sort(t)
					return t
				end,
			},
		},
		{
			key = "time",
			name = "旋转时间",
			format = "number_type",
			default = 0,
		},
	}
}

cmd.Move = {
	wrap_name = "移动位置",
	sort = 12,
	args ={
		{
			key = "excutor",
			name = "执行人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "atkobj",
		},
		{
			key = "move_type",
			name = "移动类型",
			select_type = "move_type",
			default = "line",
			refresh_args = true,
		},
		{
			key = "move_time",
			name = "移动时间",
			format = "number_type",
			default = 0,
		},
		line = {
			{
				key = "ease_type",
				name = "渐变曲线",
				select = config.func.ease, 
				format = "string_type",
				default = "Linear",
			},
			{
				key = "begin_type",
				name = "起点类型",
				select = {"current", "begin_prepare", "begin_relative"},
				wrap = {"当前位置", "预设", "自定义"},
				default = "current",
				refresh_args = true,
			},
			{
				key = "end_type",
				name = "终点类型",
				select = {"empty", "end_prepare", "end_relative"},
				wrap = {"无", "预设", "自定义"},
				default = "end_relative",
				refresh_args = true,
			},
			{
				key = "calc_face",
				name = "计算朝向",
				select_type = "bool_type",
				default = true,
			},
			{
				key = "look_at_pos",
				name = "面对终点",
				select_type = "bool_type",
				default = true,
			},
			begin_prepare = {
				{
					key = "begin_prepare",
					name = "预设起点",
					select_update = function() 
						local t = table.extend(table.keys(data.cameradata.INFOS.war),
						table.keys(data.cameradata.INFOS.warrior))
						table.sort(t)
						return t
					end,
				},
			},
			begin_relative = {
				{
					key = "begin_relative",
					name = "自定义起点",
					complex_type = "complex_pos",
					col = 3,
				},
			},
			end_prepare = {
				{
					key = "end_prepare",
					name = "预设终点",
					select_update = function()
						local t = table.extend(table.keys(data.cameradata.INFOS.war),
						table.keys(data.cameradata.INFOS.warrior))
						table.sort(t)
						return t
					end,
				},
			},
			end_relative = {
				{
					key = "end_relative",
					name = "自定义终点",
					complex_type = "complex_pos",
					col = 3,
				},
			},
		},
		circle = {
			{
				key = "lerp_cnt",
				name = "插值次数", 
				format = "number_type",
				default = 5,
			},
			{
				key = "begin_relative",
				name = "自定义起点",
				complex_type = "complex_pos",
				col = 3,
			},
			{
				key = "end_relative",
				name = "自定义终点",
				complex_type = "complex_pos",
				col = 3,
			},
		},
		jump = {
			{
				key = "min_jump_power",
				name = "最小跳跃力度",
				format = "number_type",
				default = 1,
			},
			{
				key = "max_jump_power",
				name = "最大跳跃力度",
				format = "number_type",
				default = 1,
			},
			{
				key = "jump_num",
				name = "跳跃次数",
				format = "number_type",
				default = 1,
			},
			{
				key = "ease_type",
				name = "渐变曲线",
				select = config.func.ease, 
				format = "string_type",
				default = "Linear",
			},
			{
				key = "begin_type",
				name = "起点类型",
				select = {"current", "begin_prepare", "begin_relative"},
				wrap = {"当前位置", "预设", "自定义"},
				default = "current",
				refresh_args = true,
			},
			{
				key = "end_type",
				name = "终点类型",
				select = {"empty", "end_prepare", "end_relative"},
				wrap = {"无", "预设", "自定义"},
				default = "end_relative",
				refresh_args = true,
			},
			{
				key = "calc_face",
				name = "计算朝向",
				select_type = "bool_type",
				default = true,
			},
			{
				key = "look_at_pos",
				name = "面对终点",
				select_type = "bool_type",
				default = true,
			},
			begin_prepare = {
				{
					key = "begin_prepare",
					name = "预设起点",
					select_update = function() 
						local t = table.extend(table.keys(data.cameradata.INFOS.war),
						table.keys(data.cameradata.INFOS.warrior))
						table.sort(t)
						return t
					end,
				},
			},
			begin_relative = {
				{
					key = "begin_relative",
					name = "自定义起点",
					complex_type = "complex_pos",
					col = 3,
				},
			},
			end_prepare = {
				{
					key = "end_prepare",
					name = "预设终点",
					select_update = function()
						local t = table.extend(table.keys(data.cameradata.INFOS.war),
						table.keys(data.cameradata.INFOS.warrior))
						table.sort(t)
						return t
					end,
				},
			},
			end_relative = {
				{
					key = "end_relative",
					name = "自定义终点",
					complex_type = "complex_pos",
					col = 3,
				},
			},
		},
	},
	short_desc = {"excutor", "begin_prepare", "end_prepare"}
}


cmd.MoveDir = {
	wrap_name = "移动位置(方向+速度)",
	sort = 13,
	args ={
		{
			key = "excutor",
			name = "执行人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "camobj",
		},
		{
			key = "dir",
			name = "方向",
			select_type = "move_dir",
		},
		{
			key = "speed",
			name = "速度",
			format = "number_type",
		},
		{
			key = "move_time",
			name = "时间",
			format = "number_type",
		},
	},
	short_desc = {"excutor"}
}

cmd.BodyEffect = {
	wrap_name = "绑定身体",
	sort = 60,
	args ={
		{
			key = "excutor",
			name = "绑定人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			defalut = "vicobjs",
		},
		{
			key = "effect",
			name = "特效",
			complex_type = "complex_effect", col = 3,
		},
		{
			key = "height",
			name = "高度",
			format = "number_type",
			default = 0,
		},
		{
			key = "alive_time",
			name = "存在时间",
			format = "number_type",
		},
		{
			key = "bind_type",
			name = "绑定类型",
			select = {'empty','node','pos', "model"},
			wrap = {'无','节点','部位', "模型"},
			default = "empty",
			refresh_args = true
		},
		pos =
		{
			{
				key = "body_pos",
				name = "绑定部位",
				select_type = "body_type",
				default = "head",
			},
		},
		node = 
		{
			{
			key = "bind_idx",
			name = "挂载节点(?)",
			format = "number_type",
			default = "",
			},
		},
		model =
		{
			{
				key = "find_path",
				name = "transform名字",
				select_type = "transform_name_type",
				default = "Mount_Shadow",
				force_input = true,
			},
		},
	},
	short_desc = {"path"}
}

cmd.StandEffect = {
	wrap_name = "定点特效",
	sort = 70,
	args ={
		{
			key = "excutor",
			name = "绑定人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "vicobjs",
		},
		{
			key = "effect",
			name = "特效",
			complex_type = "complex_effect", col = 3,
		},
		{
			key = "effect_pos",
			name = "特效位置",
			complex_type = "complex_pos",
			col = 3,
		},
		{
			key = "effect_dir_type",
			name = "方向(?)",
			select_type = "excutor_dir",
			default = "empty",
			refresh_args = true,
		},
		relative = {
			{
				key = "relative_dir",
				name = "位置",
				complex_type = "complex_pos",
				col = 3,
			},
		},
		{
			key = "alive_time",
			name = "存在时间",
			format = "number_type",
		},
	},
	short_desc = {"path"}
}

cmd.ShootEffect = {
	wrap_name = "射击特效",
	sort = 80,
	args ={
		{
			key = "excutor",
			name = "绑定人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "vicobjs",
		},
		{
			key = "effect",
			name = "特效",
			complex_type = "complex_effect", col = 3,
		},
		{
			key = "begin_pos",
			name = "起始位置",
			complex_type = "complex_pos",
			col = 3,
		},
		{
			key = "end_pos",
			name = "终点位置",
			complex_type = "complex_pos",
			col = 3,
		},
		{
			key = "move_time",
			name = "移动时间",
			format = "number_type",
		},
		{
			key = "delay_time",
			name = "延迟移动",
			format = "number_type",
			default = 0,
		},
		{
			key = "ease_type",
			name = "渐变曲线",
			select = config.func.ease, 
			format = "string_type",
			default = "Linear",
		},
		{
			key = "alive_time",
			name = "存在时间",
			format = "number_type",
			default = 1,
		},
	},
	short_desc = {"path"}
}

cmd.ChainEffect = {
	wrap_name = "链接特效",
	sort = 81,
	args ={
		{
			key = "excutor",
			name = "绑定人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "vicobjs",
		},
		{
			key = "effect",
			name = "特效",
			complex_type = "complex_effect", col = 3,
		},
		{
			key = "begin_pos",
			name = "起始位置",
			complex_type = "complex_pos",
			col = 3,
		},
		{
			key = "end_pos",
			name = "终点位置",
			complex_type = "complex_pos",
			col = 3,
		},
		{
			key = "scale_time",
			name = "时间",
			format = "number_type",
			default = 1,
		},
		{
			key = "ease_type",
			name = "渐变曲线",
			select = config.func.ease, 
			format = "string_type",
			default = "Linear",
		},
		{
			key = "alive_time",
			name = "存在时间",
			format = "number_type",
			default = 1,
		},
		{
			key = "repeat_texture",
			name = "重复纹理",
			select_type = "bool_type",
			default = true,
		},
	},
	short_desc = {"path"}
}

cmd.AnimatorEffect = {
	wrap_name = "Animator特效",
	sort = 82,
	args ={
		{
			key = "excutor",
			name = "绑定人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "vicobjs",
		},
		{
			key = "effect",
			name = "特效",
			complex_type = "complex_effect", col = 3,
		},
		{
			key = "alive_time",
			name = "存在时间",
			format = "number_type",
			default = 1,
		},
	},
	short_desc = {"path"}
}


cmd.ShakeScreen = {
	wrap_name = "震屏",
	sort = 81,
	args ={
		{
			key = "shake_time",
			name = "时间",
			format = "number_type",
		},
		{
			key = "shake_dis",
			name = "幅度",
			format = "number_type",
			defalut = 0.1,
		},
		{
			key = "shake_rate",
			name = "频率",
			format = "number_type",
			defalut = 1,
		},
		-- {
		-- 	key = "shake_randomness",
		-- 	name = "随机性",
		-- 	format = "number_type",
		-- 	defalut = 90,
		-- },
	},
}

cam_config = require "logic.editor.editor_camera.editor_camera_config"

cmd.CameraTarget = {
	wrap_name = "人物特写",
	sort = 84,
	args ={
		{
			key = "excutor",
			name = "特写角色",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
		},
		{
			key = "move_type",
			name = "移动类型",
			select = {"cam", "actor"},
			wrap = {"相机->人物", "人物->相机"},
			default = "cam",
			refresh_args = true,
		},
		cam = {
			{
				key = "camera_pos",
				name = "相机位置",
				complex_type = "complex_pos",
				pos_cam = function() return g_CameraCtrl:GetWarCamera() end,
				col = 3,
			},
			{
				key = "move_time",
				name = "移动时间",
				format = "number_type",
				default = 0,
			},
		},
		actor = {
			{
				key = "actor_pos",
				name = "人物位置",
				complex_type = "complex_pos",
				col = 3,
			},
		}
	},
}



cmd.CameraColor = {
	wrap_name = "像机颜色",
	sort = 86,
	args ={
		{
			key = "color",
			name = "颜色",
			complex_type = "complex_color",
			col = 3,
		},
		{
			key = "fade_time",
			name = "渐变时间(?)",
			format = "number_type",
		},
		{
			key = "restore_time",
			name = "还原时间(?)",
			format = "number_type",
		}
	},
}

cmd.CameraFieldOfView = {
	wrap_name = "像机FieldOfView",
	sort = 87,
	args ={
		{
			key = "start_val",
			name = "起始值",
			format = "number_type",
			default = 26,
		},
		{
			key = "end_val",
			name = "结束值",
			format = "number_type",
			default = 26,
		},
		{
			key = "fade_time",
			name = "渐变时间",
			format = "number_type",
			default = 0,
		},

	},
}


cmd.CameraLock = {
	wrap_name = "像机锁定",
	sort = 88,
	args ={
		{
			key = "player_swipe",
			name = "玩家移动像机",
			select_type = "bool_type",
		},
	},
}

cmd.CameraPathPercent = {
	wrap_name = "像机路径",
	sort = 89,
	args ={
		{
			key = "path_percent",
			name = "路径百分比",
			format = "number_type",
			default = 0,
		},
	},
}

cmd.HideUI = {
	wrap_name = "隐藏UI",
	sort = 90,
	args ={
		{
			key = "time",
			name = "持续时间(0一直隐藏)",
			format = "number_type",
			default = 0,
		}
	},
}

cmd.ShowUI = {
	wrap_name = "显示UI",
	sort = 91,
	args ={
	},
}

cmd.LoadUI = {
	wrap_name = "加载UI",
	sort = 92,
	args ={
		{
			key = "path",
			name = "路径",
			select = function() 
					local dirs = {"/UI/Magic"}
					local newList = {}
					if Utils.IsEditor() then
						for _, dir in pairs(dirs) do
							local list = IOTools.GetFiles(IOTools.GetGameResPath(dir), "*.prefab", true)
							for i, sPath in ipairs(list) do
								local idx = string.find(sPath, dir)
								if idx then
									table.insert(newList, string.sub(sPath, idx+1, string.len(sPath)))
								end
							end
						end
					end
					return newList
				end,
			wrap = function(s) return IOTools.GetFileName(s, true) end,
			format = "string_type",
		},
		{
			key = "time",
			name = "时间",
			format = "number_type",
			default = 1,
		}
	},
}

cmd.ActorColor = {
	wrap_name = "模型颜色",
	sort = 91,
	args ={
		{
			key = "excutor",
			name = "执行人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "vicobjs",
		},
		{
			key = "color",
			name = "颜色",
			complex_type = "complex_color",
			col = 3,
		},
		{
			key = "alive_time",
			name = "持续时间(?)",
			format = "number_type",
		},
		{
			key = "fade_time",
			name = "渐变时间(?)",
			format = "number_type",
			default = 0,
		},
	},
}

cmd.ActorMaterial = {
	wrap_name = "材质球",
	sort = 93,
	args ={
		{
			key = "excutor",
			name = "执行人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "vicobjs",
		},
		{
			key = "alive_time",
			name = "持续时间(?)",
			format = "number_type",
		},
		{
			key = "ease_show_time",
			name = "渐变显示时间",
			format = "number_type",
			default = 0,
		},
		{
			key = "ease_hide_time",
			name = "渐变消失时间",
			format = "number_type",
			default = 0,
		},
		{
			name = "材质球",
			key = "mat_path",
			select = function() 
					local newList = {}
					if Utils.IsEditor() then
						local list = IOTools.GetFiles(IOTools.GetGameResPath("/Material"), "*.mat", true)
						for i, sPath in ipairs(list) do
							local idx = string.find(sPath, "Material")
							if idx then
								table.insert(newList, string.sub(sPath, idx, string.len(sPath)))
							end
							
						end
					end
					return newList
				end,
			wrap = function(s) return IOTools.GetFileName(s, true) end,
			format = "string_type",
			input_width = 150,
		},
	},
}


cmd.KillTargetTween = {
	wrap_name = "停止目标行动",
	sort = 98,
	args = {
		{
			key = "excutor",
			name = "执行人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "vicobjs",
		},
	},
}



cmd.ControlObject = {
	wrap_name = "设置变量名",
	sort = 98,
	args ={
		{
			key = "name",
			name = "变量名",
			format = "string_type",
			default = "obj1",
		},
	},
}

cmd.SlowMotion = {
	wrap_name = "慢放",
	sort = 98,
	args = {
		{
			key = "scale",
			name = "慢放速度",
			format = "number_type",
			default = 1,
		},
		{
			key = "time",
			name = "持续时间",
			format = "number_type",
			default = 1,
		},
	}
}

cmd.FloatHit = {
	wrap_name = "浮空",
	sort = 99,
	args = {
		{
			key = "excutor",
			name = "执行人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "vicobjs",
		},
		{
			key = "up_speed",
			name = "upFloat速度",
			format = "number_type",
			default = 10,
		},
		{
			key = "up_time",
			name = "upFloat时间",
			format = "number_type",
			default = 0.2,
		},
		{
			key = "hit_speed",
			name = "hitFloat速度",
			format = "number_type",
			default = 8,
		},
		{
			key = "hit_time",
			name = "hitFloat时间",
			format = "number_type",
			default = 0.2,
		},
		{
			key = "down_time",
			name = "落地时间",
			format = "number_type",
			default = 1,
		},
		{
			key = "lie_time",
			name = "躺地时间",
			format = "number_type",
			default = 0.5,
		},
	}
}

cmd.WarResultAnim = {
	wrap_name = "战斗结束动画",
	sort = 101,
	args ={},
}



cmd.End = {
	wrap_name = "结束",
	sort = 100,
	args ={},
}



cmd.FloatTest= {
	wrap_name = "浮空测试",
	sort = 199,
	args ={
		{
			key = "up_speed",
			name = "upFloat速度",
			format = "number_type",
			default = 10,
		},
		{
			key = "up_time",
			name = "upFloat时间",
			format = "number_type",
			default = 0.2,
		},
		{
			key = "hit_speed",
			name = "hitFloat速度",
			format = "number_type",
			default = 8,
		},
		{
			key = "hit_time",
			name = "hitFloat时间",
			format = "number_type",
			default = 0.2,
		},
		{
			key = "down_time",
			name = "落地时间",
			format = "number_type",
			default = 1,
		},
		{
			key = "sk1",
			name = "测试技能1",
			format = "number_type",
			default = 1,
		},
		{
			key = "sk2",
			name = "测试技能2",
			format = "number_type",
			default = 1,
		},
	},
}

cmd.Shadow = {
	wrap_name = "阴影",
	sort = 100,
	args ={		
		{
			key = "excutor",
			name = "执行人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "atkobj",
		},
		{
			key = "is_show",
			name = "是否显示",
			select_type = "bool_type",
			default = true,
		},
	},
}

cmd.LockHide = {
	wrap_name = "锁定隐藏",
	sort = 101,
	args ={		
		{
			key = "excutor",
			name = "执行人",
			format = "string_type",
			select_type = "excutor_type",force_input = true, 
			default = "atkobj",
		},
	},
}

config.cmd = cmd

return config
config = {}
config.select =
{	
}
config.arg = {}

config.arg.template = {
	action = {
		name = "动作",
		key = "action",
		select = ModelTools:GetAllState(),
		default = "attack1",
	},
	start_frame = {
		name = "起始帧",
		key = "start_frame",
		format = "number_type",
		default = 0,
		frame_to_time = true,
	},
	end_frame = {
		name = "结束帧",
		key = "end_frame",
		format = "number_type",
		default = 0,
		frame_to_time = true,
		change_refresh = 1,
	},
	shape = {
		name = "造型",
		key = "shape",
		select = ModelTools:GetAllModelShape(),
		default = 101,
		change_refresh = 2,
	},
	hit_frame = {
		name = "受击帧",
		key = "hit_frame",
		format = "number_type",
		default = 0,
		frame_to_time = true,
	},
	speed = {
		name = "速度",
		key = "speed",
		format = "number_type",
		default = 1,
		change_refresh = 1,
	},
	hit = {
		name = "受击帧",
		key = "hit",
		format = "number_type",
		change_refresh = 1,
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

	name = {
		name = "名字",
		key = "name",
		select_update = function ()
			local oView = CEditorAnimView:GetView()
			if oView then
				return oView:GetAnimSequenceName()
			end
		end,
		force_input = true,
		change_refresh = 1,
	}
}

return config
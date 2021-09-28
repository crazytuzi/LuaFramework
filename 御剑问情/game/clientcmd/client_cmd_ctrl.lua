
-- 客户端命令
ClientCmdCtrl = ClientCmdCtrl or BaseClass(BaseController)

function ClientCmdCtrl:__init()
	if ClientCmdCtrl.Instance then
		print_error("[ClientCmdCtrl] Attempt to create singleton twice!")
		return
	end
	ClientCmdCtrl.Instance = self

	self.cmd_info_list = {}

	self.block_gameobj = nil
	self.is_show_pos = false
	self:InitConsoleCmd()
end

function ClientCmdCtrl:__delete()
	ClientCmdCtrl.Instance = nil
end

function ClientCmdCtrl:Cmd(text)
	if nil == text or "" == text then
		return
	end

	local params = Split(text, " ")
	if nil == next(params) then
		return
	end

	local name = params[1]

	local cmd_info = self.cmd_info_list[name]
	if nil ~= cmd_info then
		table.remove(params, 1)
		cmd_info.func(params)
	end
end

function ClientCmdCtrl:RegCmdFunc(name, help, callback_func)
	self.cmd_info_list[name] = {desc = help, func = callback_func}
end

-- 初始化命令
function ClientCmdCtrl:InitConsoleCmd()
	self:RegCmdFunc("disconnect", "disconnect game server", BindTool.Bind1(self.OnDisconnect, self))
	self:RegCmdFunc("error", "error test", BindTool.Bind1(self.OnErrorTest, self))
	self:RegCmdFunc("block", "show block", BindTool.Bind1(self.OnBlock, self))
	self:RegCmdFunc("show", "show info[pos]", BindTool.Bind1(self.OnShow, self))
	self:RegCmdFunc("exec", "execute lua", BindTool.Bind1(self.OnExecute, self))
	self:RegCmdFunc("setfps", "execute lua", BindTool.Bind1(self.SetFps, self))
	self:RegCmdFunc("test", "test", BindTool.Bind1(self.OnTest, self))
	self:RegCmdFunc("guide", "force guide", BindTool.Bind1(self.Guide, self))
	self:RegCmdFunc("gmlist", "gmlist [cmd_list_level]", BindTool.Bind1(self.GmCmdList, self))
	self:RegCmdFunc("pos", "show role pos [on/off]", BindTool.Bind1(self.ShowRolePos, self))
	self:RegCmdFunc("mem", "mem", BindTool.Bind1(self.CalcMem, self))
	self:RegCmdFunc("camera", "name", BindTool.Bind1(self.MoveCamera, self))
	self:RegCmdFunc("lock", "name", BindTool.Bind1(self.OnLock, self))
	self:RegCmdFunc("speed", "show speed [on/off]", BindTool.Bind1(self.ShowSpeed, self))
	self:RegCmdFunc("timescale", "timescale", BindTool.Bind1(self.TimeScale, self))
	self:RegCmdFunc("count", "count", BindTool.Bind1(self.OnCount, self))
	self:RegCmdFunc("SetLogAct","SetLogAct[on/off]", BindTool.Bind1(self.SetLogAct,self))
	self:RegCmdFunc("printevents","printevents", BindTool.Bind1(self.PrintEvents,self))
	self:RegCmdFunc("SetOpenTest","SetOpenTest",BindTool.Bind1(self.SetTestModeSwich,self))
	self:RegCmdFunc("setinfoshow","SetInfoShow",BindTool.Bind1(self.SetInfoShow,self))
	self:RegCmdFunc("cleargather", "cleargather", BindTool.Bind1(self.ClearGather, self))
end

function ClientCmdCtrl:SetLogAct(params)
	params = Split(params[1],",")
	key = params[1]
	value = params[2]
	LogActTypeCustom[key] = value
end

function ClientCmdCtrl:SetTestModeSwich(params)
	params = params[1]
	print_error(params)
	TestModeSwich = params
	TestLogic(function ()
	end)
end

function ClientCmdCtrl:SetInfoShow(params)
	print("test0")
	params = params[1]
	print_error("信息开关:" .. params)
	ShowFPS.SetSwich(params)
	print("test")
end

function ClientCmdCtrl:OnDisconnect(params)
	GameNet.Instance:DisconnectGameServer()
end

function ClientCmdCtrl:OnErrorTest(params)
	a.b = 0
end

function ClientCmdCtrl:Guide(params)
	FunctionGuide.Instance:TriggerGuideById(params[1])
end

function ClientCmdCtrl:OnBlock(params)
	if params[1] == "off" then
		if nil ~= self.block_gameobj then
			GameObject.Destroy(self.block_gameobj)
			self.block_gameobj = nil
		end
	else
		if nil ~= self.block_gameobj then
			GameObject.Destroy(self.block_gameobj)
		end

		self.block_gameobj = GameObject.New()

		for y = 0, GridFindWay.Height - 1 do
			local begin_i, end_i = -1, -1
			local is_block = true
			for x = 0, GridFindWay.Width - 1 do
				is_block = GridFindWay:IsBlock(x, y)
				if is_block then
					if begin_i < 0 then begin_i = x end
					end_i = x
				end

				if begin_i >= 0 and end_i >= begin_i and (x == GridFindWay.Width - 1 or not is_block) then
					local pos_x, pos_y = GameMapHelper.LogicToWorld(begin_i + (end_i - begin_i) / 2, y)
					local scale_x = (end_i - begin_i + 1) / 2

					local obj = GameObject.CreatePrimitive(UnityEngine.PrimitiveType.Cube)
					local obj_transform = obj.transform
					obj_transform:SetParent(self.block_gameobj.transform)
					obj_transform:SetPosition(pos_x, -3, pos_y)
					obj_transform:SetLocalScale(scale_x, 8, 0.5)
					begin_i = -1
				end
			end
		end
	end
end

function ClientCmdCtrl:OnShow(params)
	if "pos" == params[1] then
		for k,v in pairs(Scene.Instance:GetObjList()) do
			print_log("====", v:GetName(), v:GetLogicPos())
		end
	end
end

function ClientCmdCtrl:ShowSpeed(params)
	if "off" == params[1] then
		TipsCtrl.Instance:OpenDevelopTip(false)
	else
		TipsCtrl.Instance:OpenDevelopTip(true)
	end
end

function ClientCmdCtrl:OnExecute(fd, str)
	_G.package.loaded["game.clientcmd.client_cmd_script"] = nil
	require("game.clientcmd.client_cmd_script")
end

function ClientCmdCtrl:SetFps(params)
	local fps = 60
	if "" ~= params[1] and nil ~= params[1] and tonumber(params[1]) >= 15 and tonumber(params[1]) <= 60 then
		fps = params[1]
	end

	GAME_FPS =  fps
	UnityEngine.Application.targetFrameRate = fps
end

function ClientCmdCtrl:OnTest(params)
	print_log("test:", Join(params, " "))
	if params and params[1] == "budget" then
		RenderBudget.Instance:SetBudget(tonumber(params[2]))
	end
	if params and params[1] == "fps" then
		SettingData.Instance:FpsCallBack(tonumber(params[2]))
	end
	if params and params[1] == "zsd" then
		TipsCtrl.Instance.tips_zhishengdan_view:SetData(tonumber(params[2]))
		TipsCtrl.Instance.tips_zhishengdan_view:Open()
	end
	if params and params[1] == "lh_eff" then
		local pos = Scene.Instance:GetMainRole().draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(AttachPoint.BuffMiddle)
		if pos == nil then return end
		local bundle_name, prefab_name = ResPath.GetMiscEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[tonumber(params[2])] or "tongyong_lei")
		EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, pos.transform.position)
	end
	if params and params[1] == "open_voice" then
		SHIELD_VOICE = false
		GlobalEventSystem:Fire(ChatEventType.VOICE_SWITCH)
	end
	if params and params[1] == "close_voice" then
		SHIELD_VOICE = true
		GlobalEventSystem:Fire(ChatEventType.VOICE_SWITCH)
	end
	for k,v in pairs(params) do
		if v == "taskroll" then
			ViewManager.Instance:Open(ViewName.TipsTaskRewardRollView)
		elseif v == "mijing" then
			GuildMijingCtrl.SendGuildFbStartReq()
		elseif v == "entermijing" then
			GuildMijingCtrl.SendGuildFbEnterReq()
		elseif v =="gh" then
			GuildBonfireCtrl.SendGuildBonfireStartReq()
		elseif v =="gh2" then
			GuildBonfireCtrl.SendGuildBonfireGotoReq()
		elseif v == "story1" then
			FuBenCtrl.Instance:SendEnterFBReq(5, 1)
		elseif v == "story2" then
			FuBenCtrl.Instance:SendEnterFBReq(5, 2)
		elseif v == "story3" then
			FuBenCtrl.Instance:SendEnterFBReq(5, 3)
		elseif v == "guide1" then	-- 运镖引导
			FuBenCtrl.Instance:SendEnterFBReq(21, 710)
		elseif v == "guide2" then 	-- 攻城战
			FuBenCtrl.Instance:SendEnterFBReq(21, 740)
		elseif v == "guide3" then	-- 抢BOSS
			FuBenCtrl.Instance:SendEnterFBReq(21, 770)
		elseif v == "guide4" then	-- 被抢BOSS
			FuBenCtrl.Instance:SendEnterFBReq(21, 900)
		elseif v == "guide5" then	-- 水晶幻境
			FuBenCtrl.Instance:SendEnterFBReq(21, 820)
		elseif v == "p" then	-- 水晶幻境
			ViewManager.Instance:Open(ViewName.Player)
		elseif v == "daily1" then	-- 日常任务副本
			FuBenCtrl.Instance:SendEnterFBReq(24, 4601)
		elseif v == "daily2" then	-- 日常任务副本
			FuBenCtrl.Instance:SendEnterFBReq(24, 4602)
		elseif v == "daily3" then	-- 日常任务副本
			FuBenCtrl.Instance:SendEnterFBReq(24, 4603)
		elseif v == "daily4" then	-- 日常任务副本
			FuBenCtrl.Instance:SendEnterFBReq(24, 4604)
		elseif v == "daily5" then	-- 日常任务副本
			FuBenCtrl.Instance:SendEnterFBReq(24, 4605)
		end
	end


end

-- GM命令List表
local gm_list = {};

-- 成为低级菜鸟命令
local dijicainiao_gm_list =
{
	{"changegongji", "1435"},
	{"changemaxhp", "30249"},
	{"changefangyu", "690"},
	{"changemingzhong", "551"},
	{"changeshanbi", "327"},
	{"changebaoji", "1321"},
	{"changejianren", "2647"},
	{"setrolelevel", "40"},
	{"jumptotrunk", "840"},
	{"setrolelevel", "40"}

}
gm_list["1"] = dijicainiao_gm_list;

-- 成为高级菜鸟命令
local gaojicainiao_gm_list =
{
	{"changegongji", "2061"},
	{"changemaxhp", "43000"},
	{"changefangyu", "1082"},
	{"changemingzhong", "870"},
	{"changeshanbi", "517"},
	{"changebaoji", "1850"},
	{"changejianren", "3772"},
	{"setrolelevel", "42"},
	{"jumptotrunk", "890"},
	{"setrolelevel", "42"}
}
gm_list["2"] = gaojicainiao_gm_list;

-- 成为低级高手命令
local dijigaoshou_gm_list =
{
	{"changegongji", "4123"},
	{"changemaxhp", "86121"},
	{"changefangyu", "2623"},
	{"changemingzhong", "2001"},
	{"changeshanbi", "1196"},
	{"changebaoji", "3159"},
	{"changejianren", "7264"},
	{"setrolelevel", "55"},
	{"jumptotrunk", "1230"},
	{"setrolelevel", "55"}
}
gm_list["3"] = dijigaoshou_gm_list;

-- 成为高级级高手命令
local gaojigaoshou_gm_list =
{
	{"addchongzhi", "999999"},
	{"setrolelevel", "999"},
	{"jumptotrunk", "3700"},
}
gm_list["4"] = gaojigaoshou_gm_list;

-- 成为高级级高手命令
local wudi_gm_list =
{
	{"changegongji", "99999999"},
	{"changemaxhp", "99999999"},
	{"addchongzhi", "999999"},
	{"setrolelevel", "999"},
	{"jumptotrunk", "1880"},
}
gm_list["5"] = wudi_gm_list;

function ClientCmdCtrl:GmCmdList(params)
	for k,v in pairs(params) do
		if nil == gm_list[v] then
			return
		end

		for i, v1 in ipairs(gm_list[v]) do
			SysMsgCtrl.SendGmCommand(v1[1], v1[2])
		end
	end

end

function ClientCmdCtrl:ShowRolePos(params)
	local on_off = "on" == params[1] and true or false
	self.is_show_pos = on_off
end

local next_calc_mem_time = 0
local old_mem = 0
local calc_mem_timer = nil
function ClientCmdCtrl:CalcMem(params)
	if "on" == params[1] then
		calc_mem_timer = GlobalTimerQuest:AddRunQuest(function ()
			if Status.NowTime >= next_calc_mem_time then
				next_calc_mem_time = Status.NowTime + 20
				collectgarbage("collect")
				local memory = collectgarbage("count")
				print("##########memory =", memory, memory - old_mem)
				old_mem = memory
			end
		end, 0)
	elseif "off" == params[1] then
		GlobalTimerQuest:CancelQuest(calc_mem_timer)
	end
end

function ClientCmdCtrl:MoveCamera(params)
	Camera.Instance:MoveInName(params[1])
end

function ClientCmdCtrl:OnLock(params)
	SettingCtrl.Instance:GmOpenUnLockView()
end

function ClientCmdCtrl:TimeScale(params)
	local scale = tonumber(params[1]) or 100
	scale = scale / 100
	TimeScaleService.Instance:SetTimeScale(scale, 7, nil, DG.Tweening.Ease.InCirc)
end

function ClientCmdCtrl:OnCount(params)
	MainUICtrl.Instance:CreateMainCollectgarbageText()
end

-- 打印事件绑定数量
function ClientCmdCtrl:PrintEvents(params)
	GlobalEventSystem:Print()
end

function ClientCmdCtrl:ClearGather(params)
	Scene.Instance:DeleteObjsByType(SceneObjType.GatherObj)
end
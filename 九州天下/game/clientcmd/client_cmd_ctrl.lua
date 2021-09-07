
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
	self:RegCmdFunc("test", "test", BindTool.Bind1(self.OnTest, self))
	self:RegCmdFunc("guide", "force guide", BindTool.Bind1(self.Guide, self))
	self:RegCmdFunc("gmlist", "gmlist [cmd_list_level]", BindTool.Bind1(self.GmCmdList, self))
	self:RegCmdFunc("pos", "show role pos [on/off]", BindTool.Bind1(self.ShowRolePos, self))
	self:RegCmdFunc("mem", "mem", BindTool.Bind1(self.CalcMem, self))
	self:RegCmdFunc("camera", "name", BindTool.Bind1(self.MoveCamera, self))
	self:RegCmdFunc("lock", "name", BindTool.Bind1(self.OnLock, self))
	self:RegCmdFunc("count", "count", BindTool.Bind1(self.OnCount, self))
	self:RegCmdFunc("xiaowei", "xiaowei", BindTool.Bind1(self.OnXiaoWei, self))
	self:RegCmdFunc("pinbimodel", "pinbimodel [on/off]", BindTool.Bind(self.OnPinBiModel, self))
	self:RegCmdFunc("liangdu", "liangdu [on/off]", BindTool.Bind(self.OnLiangDu, self))
	self:RegCmdFunc("freecamera", "freecamera [on/off]", BindTool.Bind1(self.FreeCamera, self))
	self:RegCmdFunc("adapter", "adapter [on/off]", BindTool.Bind1(self.Adapter, self))
	self:RegCmdFunc("addchat", "addchat [chat_num]", BindTool.Bind1(self.AddChat, self))
	self:RegCmdFunc("addsystem", "addsystem [num]", BindTool.Bind1(self.AddSystemMsg, self))
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

function ClientCmdCtrl:OnExecute(fd, str)
	_G.package.loaded["game.clientcmd.client_cmd_script"] = nil
	require("game.clientcmd.client_cmd_script")
end

function ClientCmdCtrl:OnTest(params)
	print_log("test:", Join(params, " "))
	if params and params[1] == "budget" then
		RenderBudget.Instance:SetBudget(tonumber(params[2]))
	end
	if params and params[1] == "fps" then
		SettingData.Instance:FpsCallBack(tonumber(params[2]))
	end
	for k,v in pairs(params) do
		if v == "mijing" then
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
			FuBenCtrl.Instance:SendEnterFBReq(21, 1)
		elseif v == "guide2" then 	-- 攻城战
			FuBenCtrl.Instance:SendEnterFBReq(21, 2)
		elseif v == "guide3" then	-- 抢BOSS
			FuBenCtrl.Instance:SendEnterFBReq(21, 3)
		elseif v == "guide4" then	-- 被抢BOSS
			FuBenCtrl.Instance:SendEnterFBReq(21, 4)
		elseif v == "guide5" then	-- 水晶幻境
			FuBenCtrl.Instance:SendEnterFBReq(21, 5)
		elseif v == "guide6" then	-- 运镖引导
			FuBenCtrl.Instance:SendEnterFBReq(21, 6)
		elseif v == "guide7" then 	-- 攻城战
			FuBenCtrl.Instance:SendEnterFBReq(21, 7)
		elseif v == "guide8" then	-- 抢BOSS
			FuBenCtrl.Instance:SendEnterFBReq(21, 8)
		elseif v == "guide9" then	-- 被抢BOSS
			FuBenCtrl.Instance:SendEnterFBReq(21, 9)
		elseif v == "guide10" then	-- 水晶幻境
			FuBenCtrl.Instance:SendEnterFBReq(21, 10)
		elseif v == "guide11" then	-- 运镖引导
			FuBenCtrl.Instance:SendEnterFBReq(21, 11)
		elseif v == "guide12" then 	-- 攻城战
			FuBenCtrl.Instance:SendEnterFBReq(21, 12)
		elseif v == "guide13" then	-- 抢BOSS
			FuBenCtrl.Instance:SendEnterFBReq(21, 13)
		elseif v == "guide14" then	-- 被抢BOSS
			FuBenCtrl.Instance:SendEnterFBReq(21, 14)
		elseif v == "guide15" then	-- 水晶幻境
			FuBenCtrl.Instance:SendEnterFBReq(21, 15)
        elseif v == "guide16" then	-- 水晶幻境
			FuBenCtrl.Instance:SendEnterFBReq(21, 16)

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
		elseif v == "cc" then		-- CC专用测试
			CgManager.Instance:Pause()
		end
	end


end

-- GM命令List表
local gm_list = {};

-- 成为低级菜鸟命令
local dijicainiao_gm_list =
{
	{"addchongzhi", "999999"},
	{"setrolelevel", "799"},

}
gm_list["1"] = dijicainiao_gm_list;

-- 成为高级菜鸟命令
local gaojicainiao_gm_list =
{
	{"addchongzhi", "999999"},
	{"setrolelevel", "799"},
}
gm_list["2"] = gaojicainiao_gm_list;

-- 成为低级高手命令
local dijigaoshou_gm_list =
{
	{"addchongzhi", "999999"},
	{"setrolelevel", "799"},
}
gm_list["3"] = dijigaoshou_gm_list;

-- 成为高级级高手命令
local gaojigaoshou_gm_list =
{
	-- {"addchongzhi", "9999999999"},
	-- {"addmoney", "9999999999"},
	{"setrolelevel", "999"},
	{"addjungong", "9999999"},
	-- {"setjxlevel", "19"},
}
gm_list["4"] = gaojigaoshou_gm_list;

-- 成为高级级高手命令
local wudi_gm_list =
{
	{"changegongji", "99999999"},
	{"changemaxhp", "99999999"},
	{"addchongzhi", "999999"},
	{"setrolelevel", "999"},
}
gm_list["5"] = wudi_gm_list;

-- 自动进阶
local wudi_gm_list =
{
	{"autoupgradeall", " "},
}
gm_list["6"] = wudi_gm_list;

-- 成为高级级高手命令 gmlist 4 任务
local gaojigaoshou_gm_task_list =
{
	{"jumptotrunk", "2230"},
	{"jumptotrunk", "7230"},
	{"jumptotrunk", "12230"},
}

-- 时装物品
local give_item_gm_list =
{
	{"additem", "23575 99 1"},
	{"additem", "23576 99 1"},
	{"additem", "23577 99 1"},
	{"additem", "23578 99 1"},
	{"additem", "23579 99 1"},
	{"additem", "23580 99 1"},
	{"additem", "23581 99 1"},
	{"additem", "23582 99 1"},
	{"additem", "23683 99 1"},
	{"additem", "23684 99 1"},
	{"additem", "23685 99 1"},
	{"additem", "23686 99 1"},
	{"additem", "23687 99 1"},
	{"additem", "23688 99 1"},
	{"additem", "23689 99 1"},
	{"additem", "23655 99 1"},
	{"additem", "23656 99 1"},
	{"additem", "23657 99 1"},
	{"additem", "23658 99 1"},
	{"additem", "23659 99 1"},
	{"additem", "23660 99 1"},
	{"additem", "23661 99 1"},
	{"additem", "23662 99 1"},
	{"additem", "23663 99 1"},
	{"additem", "23664 99 1"},
	{"additem", "23665 99 1"},
	{"additem", "23666 99 1"},
	{"additem", "23667 99 1"},
	{"additem", "23668 99 1"},
	{"additem", "23669 99 1"},
	{"additem", "23735 99 1"},
	{"additem", "23736 99 1"},
	{"additem", "23737 99 1"},
	{"additem", "23738 99 1"},
	{"additem", "23739 99 1"},
	{"additem", "23740 99 1"},
	{"additem", "23741 99 1"},
	{"additem", "23742 99 1"},
	{"additem", "23743 99 1"},
	{"additem", "23744 99 1"},
	{"additem", "23745 99 1"},
	{"additem", "23746 99 1"},
	{"additem", "23747 99 1"},
	{"additem", "23748 99 1"},
	{"additem", "23749 99 1"},
	{"additem", "23750 99 1"},
	{"additem", "23813 99 1"},
	{"additem", "23814 99 1"},
	{"additem", "23815 99 1"},
	{"additem", "23816 99 1"},
	{"additem", "23817 99 1"},
	{"additem", "23818 99 1"},
	{"additem", "23819 99 1"},
	{"additem", "23820 99 1"},
	{"additem", "23827 99 1"},
	{"additem", "23828 99 1"},
	{"additem", "23831 99 1"},
	{"additem", "23878 99 1"},
	{"additem", "23879 99 1"},
	{"additem", "23880 99 1"},
	{"additem", "23881 99 1"},
	{"additem", "23882 99 1"},
	{"additem", "23883 99 1"},
	{"additem", "23884 99 1"},
	{"additem", "23885 99 1"},
	{"additem", "23886 99 1"},
	{"additem", "23887 99 1"},
	{"additem", "23888 99 1"},
	{"additem", "23889 99 1"},
	{"additem", "23890 99 1"},
	{"additem", "23891 99 1"},
	{"additem", "23892 99 1"},
	{"additem", "23893 99 1"},
	{"additem", "23894 99 1"},
	{"additem", "23895 99 1"},
	{"additem", "23896 99 1"},
	{"additem", "23897 99 1"},
	{"additem", "23925 99 1"},
	{"additem", "23926 99 1"},
	{"additem", "23927 99 1"},
	{"additem", "23831 99 1"},
	{"additem", "23878 99 1"},
	{"additem", "23879 99 1"},
	{"additem", "23880 99 1"},
	{"additem", "23881 99 1"},
	{"additem", "23882 99 1"},
	{"additem", "23883 99 1"},
	{"additem", "23884 99 1"},
	{"additem", "23885 99 1"},
	{"additem", "23886 99 1"},
	{"additem", "23887 99 1"},
	{"additem", "23888 99 1"},
	{"additem", "23889 99 1"},
	{"additem", "23890 99 1"},
	{"additem", "23891 99 1"},
	{"additem", "23892 99 1"},
	{"additem", "23893 99 1"},
	{"additem", "23894 99 1"},
	{"additem", "23895 99 1"},
	{"additem", "23896 99 1"},
	{"additem", "23897 99 1"},



}
gm_list["giveitemsz"] = give_item_gm_list;


-- 虎符物品
local give_hufu_item_gm_list =
{
	{"additem", "26500 999 1"},
	{"additem", "26501 999 1"},
	{"additem", "26502 999 1"},
	{"additem", "26503 999 1"},
}
gm_list["giveitemhf"] = give_hufu_item_gm_list;

-- 美人物品
local give_meiren_item_gm_list =
{
	{"additem", "26400 999 1"},
	{"additem", "26401 999 1"},
	{"additem", "26402 999 1"},
	{"additem", "26403 999 1"},
	{"additem", "26404 999 1"},
	{"additem", "26405 999 1"},
	{"additem", "26406 999 1"},
	{"additem", "26407 999 1"},
	{"additem", "26408 999 1"},
	{"additem", "26409 999 1"},
	{"additem", "26410 999 1"},
	{"additem", "26411 999 1"},
	{"additem", "26412 999 1"},
	{"additem", "26413 999 1"},

}
gm_list["giveitemmr"] = give_meiren_item_gm_list;

-- 神兵宝甲物品
local give_shenbing_item_gm_list =
{
	{"additem", "27820 99 1"},
	{"additem", "27824 99 1"},
	{"additem", "27828 99 1"},
	{"additem", "27832 99 1"},
	{"additem", "27836 99 1"},
	{"additem", "27840 99 1"},
	{"additem", "27844 99 1"},
	{"additem", "27848 99 1"},
	{"additem", "27852 99 1"},
	{"additem", "27856 99 1"},
	{"additem", "27860 99 1"},
	{"additem", "27864 99 1"},
	{"additem", "27868 99 1"},
	{"additem", "27872 99 1"},
	{"additem", "27876 99 1"},
	{"additem", "27880 99 1"},
	{"additem", "27898 99 1"},
	{"additem", "27902 99 1"},
	{"additem", "27906 99 1"},
	{"additem", "27910 99 1"},
	{"additem", "27914 99 1"},
	{"additem", "27918 99 1"},
	{"additem", "27922 99 1"},
	{"additem", "27926 99 1"},

}
gm_list["giveitemsbbj"] = give_shenbing_item_gm_list;

-- 神兵宝甲物品
local give_zhuangbei_item_gm_list =
{
	{"additem", "161 1 0"},
	{"additem", "261 1 0"},
	{"additem", "361 1 0"},
	{"additem", "461 1 0"},
	{"additem", "161 1 0"},
	{"additem", "261 1 0"},
	{"additem", "361 1 0"},
	{"additem", "461 1 0"},
	{"additem", "161 1 0"},
	{"additem", "261 1 0"},
	{"additem", "361 1 0"},
	{"additem", "461 1 0"},
	{"additem", "1157 1 0"},
	{"additem", "1257 1 0"},
	{"additem", "1357 1 0"},
	{"additem", "1457 1 0"},
	{"additem", "1157 1 0"},
	{"additem", "1257 1 0"},
	{"additem", "1357 1 0"},
	{"additem", "1457 1 0"},
	{"additem", "1157 1 0"},
	{"additem", "1257 1 0"},
	{"additem", "1357 1 0"},
	{"additem", "1457 1 0"},
	{"additem", "2157 1 0"},
	{"additem", "2257 1 0"},
	{"additem", "2357 1 0"},
	{"additem", "2457 1 0"},
	{"additem", "2157 1 0"},
	{"additem", "2257 1 0"},
	{"additem", "2357 1 0"},
	{"additem", "2457 1 0"},
	{"additem", "2157 1 0"},
	{"additem", "2257 1 0"},
	{"additem", "2357 1 0"},
	{"additem", "2457 1 0"},
	{"additem", "3157 1 0"},
	{"additem", "3257 1 0"},
	{"additem", "3357 1 0"},
	{"additem", "3457 1 0"},
	{"additem", "3157 1 0"},
	{"additem", "3257 1 0"},
	{"additem", "3357 1 0"},
	{"additem", "3457 1 0"},
    {"additem", "3157 1 0"},
	{"additem", "3257 1 0"},
	{"additem", "3357 1 0"},
	{"additem", "3457 1 0"},
	{"additem", "3157 1 0"},
	{"additem", "3257 1 0"},
	{"additem", "3357 1 0"},
	{"additem", "3457 1 0"},
	{"additem", "4157 1 0"},
	{"additem", "4257 1 0"},
	{"additem", "4357 1 0"},
	{"additem", "4457 1 0"},
	{"additem", "4157 1 0"},
	{"additem", "4257 1 0"},
	{"additem", "4357 1 0"},
	{"additem", "4457 1 0"},
	{"additem", "4157 1 0"},
	{"additem", "4257 1 0"},
	{"additem", "4357 1 0"},
	{"additem", "4457 1 0"},
	{"additem", "5157 1 0"},
	{"additem", "5257 1 0"},
	{"additem", "5357 1 0"},
	{"additem", "5457 1 0"},
	{"additem", "5157 1 0"},
	{"additem", "5257 1 0"},
	{"additem", "5357 1 0"},
	{"additem", "5457 1 0"},
	{"additem", "5157 1 0"},
	{"additem", "5257 1 0"},
	{"additem", "5357 1 0"},
	{"additem", "5457 1 0"},
	{"additem", "5157 1 0"},
	{"additem", "5257 1 0"},
	{"additem", "5357 1 0"},
	{"additem", "5457 1 0"},
}
gm_list["giveitemzb"] = give_zhuangbei_item_gm_list;

-- 武将物品
local give_zhuangbei_item_gm_list =
{
    {"additem", "23450 1 0"},
	{"additem", "23451 1 0"},
	{"additem", "23452  1 0"},
	{"additem", "23453  1 0"},
	{"additem", "23454  1 0"},
	{"additem", "23455 1 0"},
	{"additem", "23456  1 0"},
	{"additem", "23457  1 0"},
	{"additem", "23458  1 0"},
	{"additem", "23459  1 0"},
	{"additem", "23460  1 0"},
	{"additem", "23461  1 0"},
	{"additem", "23462 1 0"},
	{"additem", "23463 1 0"},
	{"additem", "23464 1 0"},

}
gm_list["giveitemwj"] = give_zhuangbei_item_gm_list;

-- 锻造物品
local give_duanzao_item_gm_list =
{
    {"additem", "26100 999 0"},
	{"additem", "26214 999 0"},
	{"additem", "26229 999 0"},
	{"additem", "26244 999 0"},
	{"additem", "26152 999 0"},
	{"additem", "26153 999 0"},
	{"additem", "26154 999 0"},
	{"additem", "26155 999 0"},
	{"additem", "26156 999 0"},
	{"additem", "26157 999 0"},
	{"additem", "26158 999 0"},
	{"additem", "26159 999 0"},
	{"additem", "26160 999 0"},
	{"additem", "26161 999 0"},
	{"additem", "26162 999 0"},
	{"additem", "27806 999 0"},
}
gm_list["giveitemdz"] = give_duanzao_item_gm_list;

-- 资质丹+进阶技能书
local give_duanzao_item_gm_list =
{
    {"additem", "22107 999 0"},
    {"additem", "22108 999 0"},
    {"additem", "22109 999 0"},
    {"additem", "22110 999 0"},
    {"additem", "22111 999 0"},
    {"additem", "22112 999 0"},
    {"additem", "22113 999 0"},
    {"additem", "22114 999 0"},
    {"additem", "26330 999 0"},
    {"additem", "26331 999 0"},
    {"additem", "26332 999 0"},
    {"additem", "26333 999 0"},
    {"additem", "26334 999 0"},
    {"additem", "26335 999 0"},
    {"additem", "26336 999 0"},
    {"additem", "26337 999 0"},
    {"additem", "26338 999 0"},
    {"additem", "26339 999 0"},

}
gm_list["giveitemjj"] = give_duanzao_item_gm_list;

local give_wentao_item_gm_list =
{
	{"additem", "27650 99 1"},
	{"additem", "27651 99 1"},
	{"additem", "27652 99 1"},
	{"additem", "27653 99 1"},
	{"additem", "27655 99 1"},
	{"additem", "27656 99 1"},
	{"additem", "27657 99 1"},
	{"additem", "27658 99 1"},
	{"additem", "27659 99 1"},
	{"additem", "27660 99 1"},
	{"additem", "27661 99 1"},
	{"additem", "27662 99 1"},
	{"additem", "27663 99 1"},
	{"additem", "27664 99 1"},
	{"additem", "27665 99 1"},
	{"additem", "27666 99 1"},
	{"additem", "27667 99 1"},
	{"additem", "27668 99 1"},
	{"additem", "27669 99 1"},
	{"additem", "27670 99 1"},
	{"additem", "27671 99 1"},
	{"additem", "27672 99 1"},
	{"additem", "27673 99 1"},
	{"additem", "27674 99 1"},
	{"additem", "27675 99 1"},
	{"additem", "27676 99 1"},
	{"additem", "27677 99 1"},
	{"additem", "27678 99 1"},
	{"additem", "27679 99 1"},
	{"additem", "27680 99 1"},
	{"additem", "27681 99 1"},
	{"additem", "27682 99 1"},
	{"additem", "27683 99 1"},
	{"additem", "27684 99 1"},
	{"additem", "27685 99 1"},
	{"additem", "27688 99 1"},
	{"additem", "27689 99 1"},
	{"additem", "27690 99 1"},
	{"additem", "27691 99 1"},
	{"additem", "27692 99 1"},
	{"additem", "27197 99 1"},
	{"additem", "27198 99 1"},
	{"additem", "27199 99 1"},
	{"additem", "27200 99 1"},
	{"additem", "27201 99 1"},
	{"additem", "27202 99 1"},
	{"additem", "27203 99 1"},
	{"additem", "27204 99 1"},
	{"additem", "27205 99 1"},
	{"additem", "27206 99 1"},
	{"additem", "27207 99 1"},
	{"additem", "27208 99 1"},
	{"additem", "27209 99 1"},
	{"additem", "27210 99 1"},
	{"additem", "27211 99 1"},
	{"additem", "27212 99 1"},
	{"additem", "27213 99 1"},
	{"additem", "27214 99 1"},
	{"additem", "27215 99 1"},
	{"additem", "27216 99 1"},
	{"additem", "27217 99 1"},
	{"additem", "27218 99 1"},
	{"additem", "27219 99 1"},
	{"additem", "27220 99 1"},
	{"additem", "27221 99 1"},
	{"additem", "27222 99 1"},
	{"additem", "27223 99 1"},
	{"additem", "27224 99 1"},
	{"additem", "27225 99 1"},
	{"additem", "27226 99 1"},
	{"additem", "27227 99 1"},
	{"additem", "27228 99 1"},
	{"additem", "27229 99 1"},
	{"additem", "27230 99 1"},
	{"additem", "27231 99 1"},
	{"additem", "27232 99 1"},
	{"additem", "27233 99 1"},
	{"additem", "27234 99 1"},
	{"additem", "27235 99 1"},
	{"additem", "27236 99 1"},
	{"additem", "27237 99 1"},
	{"additem", "27238 99 1"},
	{"additem", "27239 99 1"},
	{"additem", "27240 99 1"},
	{"additem", "27241 99 1"},
	{"additem", "27242 99 1"},
	{"additem", "27243 99 1"},
	{"additem", "27244 99 1"},

}
gm_list["giveitemwt"] = give_wentao_item_gm_list;

function ClientCmdCtrl:GmCmdList(params)
	for k,v in pairs(params) do
		if nil == gm_list[v] then
			return
		end

		for i, v1 in ipairs(gm_list[v]) do
			-- gmlist 4的时候强制一下根据职业来
			-- if v1[2] == "4" then
			-- 	SysMsgCtrl.SendGmCommand(v1[1], PlayerData.Instance.role_vo.camp)
			-- else
			-- 	SysMsgCtrl.SendGmCommand(v1[1], v1[2])
			-- end
			SysMsgCtrl.SendGmCommand(v1[1], v1[2])
		end
	end

	local task_list = gaojigaoshou_gm_task_list[PlayerData.Instance.role_vo.camp]
	if task_list ~= nil then
		SysMsgCtrl.SendGmCommand(task_list[1], task_list[2])
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
	-- Camera.Instance:MoveInName(params[1])
end

function ClientCmdCtrl:OnLock(params)
	SettingCtrl.Instance:GmOpenUnLockView()
end

function ClientCmdCtrl:OnCount(params)
	MainUICtrl.Instance:CreateMainCollectgarbageText()
end

function ClientCmdCtrl:OnXiaoWei(params)
	ChatCtrl.Instance:AddSystemMsg("{r;3155530;欧香曼;2}{point;无极山;587;145;2100;0}击杀{monster;3051}，爆出{eq;3457;3457:0:-12851:0:0:0:0:24:23:26:0:0:0}，快来膜拜我吧！")
end

function ClientCmdCtrl:OnPinBiModel(params)
	IsPinBiModel = "on" == params[1] and true or false
end

function ClientCmdCtrl:OnLiangDu(params)
	local liangdu = "on" == params[1] and true or false
	if liangdu then
		ApplicationBrightness.SetApplicationBrightnessTo(0.2)
	else
		ApplicationBrightness.SetApplicationBrightnessTo(-1)
	end
end

function ClientCmdCtrl:FreeCamera(params)
	if "on" == params[1] then
		SHIELD_FREE_CAMERA = false
	else
		SHIELD_FREE_CAMERA = true
	end
end

function ClientCmdCtrl:Adapter(params)
	if "on" == params[1] then
		GmAdapter = true
	else
		GmAdapter = false
	end
end

function ClientCmdCtrl:AddChat(params)
	if params[1] ~= nil and params[1] ~= "" then
		local num = tonumber(params[1])
		if num ~= nil and num > 0 then
			for i = 1, num do
				local chat = {}
				local role = GameVoManager.Instance:GetMainRoleVo()
				chat.from_uid = role.role_id								
				chat.from_origin_uid = role.role_id					
				chat.username = role.name .. "->text" .. i
				chat.sex = 0
				chat.camp = 1
				chat.prof = 1
				chat.authority_type = 0
				chat.content_type = 0
				chat.tuhaojin_color = 0						
				chat.bigchatface_status = 0				
				chat.personalize_window_bubble_type = 0
				chat.avatar_key_big = 0
				chat.avatar_key_small = 0

				chat.personalize_window_avatar_type = 0

				chat.level = role.level
				chat.vip_level = 0
				chat.channel_type = CHANNEL_TYPE.WORLD
				chat.msg_timestamp = TimeCtrl.Instance:GetServerTime()
				chat.from_type = SHOW_CHAT_TYPE.CHAT
				chat.msg_length = 0
				chat.content = "聊天测试----->" .. i

				ChatCtrl.Instance:OnChannelChat(chat)
			end
		end
	end
end

function ClientCmdCtrl:AddSystemMsg(params)
	if params[1] ~= nil and params[1] ~= "" then
		local num = tonumber(params[1])
		if num ~= nil and num > 0 then
			for i = 1, num do
				local cmd = SCSystemMsg.New()
				cmd.send_time = 1540405388
				cmd.msg_type = 9
				cmd.msg_length = 157
				cmd.display_pos = 0
				cmd.color = 0
				cmd.content = "{showpos;2} 惊闻一声天雷，{r;1051387;郎晓啸;3} 的坐骑成功进阶至{mount_grade;41}，战斗力直线飙升，来顶礼膜拜吧！{openLink;4}"
				ChatCtrl.Instance:OnSystemMsg(cmd)

				cmd.msg_type = SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_WORLD
				ChatCtrl.Instance:OnSystemMsg(cmd)
			end
		end
	end
end

-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_backstage = i3k_class("wnd_backstage", ui.wnd_base)

BTNWIDGET = "ui/widgets/gmt"

function wnd_backstage:ctor()
	
end

function wnd_backstage:configure()
	local widget = self._layout.vars
	self.scroll = widget.scroll
	widget.closeBtn:onClick(self, self.onClose)
	self.funcBtn =
	{
		[1] = {name = "设置角色等级", uiName = eUIID_GmSetLevel},
		[2] = {name = "添加道具", uiName = eUIID_GmAddItem},
		[3] = {name = "添加经验", uiName = eUIID_GmSetLevel},
		[4] = {name = "修改时间", uiName = eUIID_GmSetTime},
		[5] = {name = "添加属性", uiName = eUIID_GmAddItem},
		--[6] = {name = "转职等级", uiName = eUIID_GmSetTransferLevel},
		--[7] = {name = "装备升级", uiName = eUIID_GmEquipUpLevel},
		--[8] = {name = "挂机精灵等级", uiName = eUIID_GmSetLevel},
		[9] = {name = "跳过任务", uiName = eUIID_GmSetLevel},
		[10] = {name = "帮派等级", uiName = eUIID_GmSetLevel},
		[11] = {name = "帮派活跃", uiName = eUIID_GmSetLevel},
		--[12] = {name = "个人活跃", uiName = eUIID_GmSetLevel},
		--[13] = {name = "内甲", uiName = eUIID_GmUnderWear},
		--[14] = {name = "宠物喂养等级", uiName = eUIID_GmSetLevel},
		[15] = {name = "召唤boss", uiName = eUIID_GmSetLevel},
		--[16] = {name = "自创武功等级", uiName = eUIID_GmSetLevel},
		--[17] = {name = "调整罪恶点", uiName = eUIID_GmSetEvilPoint},
		--[18] = {name = "生产等级", uiName = eUIID_GmSetLevel},
		[19] = {name = "添加魅力", uiName = eUIID_GmSetEvilPoint},
		[20] = {name = "增加武勋", uiName = eUIID_GmSetEvilPoint},
		[21] = {name = "增加荣誉", uiName = eUIID_GmSetEvilPoint},
		--[22] = {name = "参悟等级", uiName = eUIID_GmSetLevel},
		[23] = {name = "神兵熟练度", uiName = eUIID_GmSuperWeaponPro},
		--[24] = {name = "神器强化", uiName = eUIID_GmArtifactSrengthen},
		--[25] = {name = "神器精炼", uiName = eUIID_GmArtifactRefine},
		[26] = {name = "增加分堂积分", uiName = eUIID_GmSetLevel},
		--[[[27] = {name = "武魂品阶", uiName = eUIID_GmSetLevel},
		[28] = {name = "星耀形状", uiName = eUIID_GmStarLightShape},
		[29] = {name = "启动星耀", uiName = eUIID_GmSetLevel},
		[30] = {name = "开启驻地", uiName = eUIID_GmOpenGarrison},
		[31] = {name = "帮派伏魔进度", uiName = eUIID_GmSectBossProgress},
		[32] = {name = "日常试炼", uiName = eUIID_GmOpenGarrison},
		[33] = {name = "五绝试炼", uiName = eUIID_GmFiveUniqueActivity},
		[34] = {name = "装备强化", uiName = eUIID_GmEquipUpLevel},--]]
		[35] = {name = "武道会积分", uiName = eUIID_GmSetLevel},
		[36] = {name = "武道会荣誉", uiName = eUIID_GmSetLevel},
		[37] = {name = "封印经验", uiName = eUIID_GmSetLevel},
		[38] = {name = "离线经验", uiName = eUIID_GmSetLevel},
		[39] = {name = "宠物喂养经验", uiName = eUIID_GmAddItem},
		[40] = {name = "测模型", uiName = eUIID_GmSetLevel},
		[41] = {name = "测隐藏头顶", uiName = eUIID_GmSetLevel},
		[42] = {name = "名字加道具", uiName = eUIID_GmAddItem},
	}
end

function wnd_backstage:refresh(power)
	local widget = self._layout.vars
	widget.power:setText(string.format("s/c战力：%s/%s", power, g_i3k_game_context:GetRolePower()))
	widget.time:setText("")
	self.scroll:removeAllChildren()
	local children = self.scroll:addItemAndChild(BTNWIDGET, 2, table.nums(self.funcBtn))
	local index = 1
	for k, v in pairs(self.funcBtn) do
		children[index].vars.btnName:setText(v.name)
		children[index].vars.btn:onClick(self, self.openFuncUI, k)
		index = index + 1
	end
end

function wnd_backstage:openFuncUI(sender, gmType)
	g_i3k_ui_mgr:OpenUI(self.funcBtn[gmType].uiName)
	g_i3k_ui_mgr:RefreshUI(self.funcBtn[gmType].uiName, gmType)
end

function wnd_backstage:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmBackstage)
end

function wnd_backstage:onUpdate(dTime)
	local widget = self._layout.vars
	local time = os.date("%Y-%m-%d-%H:%M:%S",g_i3k_get_GMTtime(i3k_game_get_time()))
	widget.time:setText(time)
end

function wnd_create(layout, ...)
	local wnd = wnd_backstage.new()
	wnd:create(layout, ...);
	return wnd
end

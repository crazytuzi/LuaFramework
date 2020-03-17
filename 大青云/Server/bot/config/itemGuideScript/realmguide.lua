--[[
物品使用引导--境界灌注道具
在主界面右下角弹出提醒UI，提醒玩家当前有境界道具可以升阶，点击后打开境界界面，箭头指向灌注按钮
zhangshuhui
2015年6月2日12:12:32
]]

QuestScriptCfg:Add(
{
	name = "realmguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.Realm); return true; end,
			complete = function() return UIRealmMainView:IsFullShow(); end,
			Break = function() return false; end
		},
	}
});
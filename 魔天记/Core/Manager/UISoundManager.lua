UISoundManager = {};

UISoundManager.UISoundDir = "Sound/UISound/";

UISoundManager.path_fb_fail = "ui_fail"; --副本失败
UISoundManager.path_fb_win = "ui_win";  -- 副本通关
UISoundManager.path_ui_enhance1 = "ui_enhance1"; -- 精炼武器


UISoundManager.path_ui_gold = "ui_gold";  -- 卖出物品得到钱
UISoundManager.path_ui_enhance = "ui_enhance"; -- 强化武器

UISoundManager.task_comit = "ui_task_commit";
UISoundManager.equip_gem_embed = "ui_gem";
UISoundManager.equip_gem_compose = "ui_compose";
UISoundManager.skill_upgrade = "ui_skill_upgrade";
UISoundManager.skill_setting = "ui_choosen";


UISoundManager.ui_button = "ui_button";
UISoundManager.ui_tab = "ui_tab";
UISoundManager.ui_open = "ui_open";
UISoundManager.ui_role_upgrade = "ui_role_upgrade"  --角色升级
UISoundManager.ui_enhance = "ui_enhance"  --装备新强化操作
UISoundManager.ui_gem = "ui_gem"  --装备新强化点击防止祝福石、保护符成功时
UISoundManager.ui_realm = "ui_realm"  --境界提升成功时
UISoundManager.ui_skill_upgrade = "ui_skill_upgrade"  --境界凝练成功时
UISoundManager.ui_win = "ui_win"  --伙伴弹出激活成功界面时
UISoundManager.ui_gold = "ui_gold"
UISoundManager.ui_enhance = "ui_enhance"
UISoundManager.ui_enhance1 = "ui_enhance1"--神器（4个一样）点击道具
UISoundManager.ui_gem = "ui_gem"--命星升级成功
UISoundManager.ui_compose = "ui_compose"--命星分解成功

local soundManager = SoundManager.instance
function UISoundManager.PlayUISound(name)
	if(name and name ~= "") then
		soundManager:PlayAudio(name, UISoundManager.UISoundDir);
	end
end
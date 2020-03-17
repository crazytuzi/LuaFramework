--[[
潜能提醒点击后操作
有未分配属性点时，点击主界面提醒按钮后，弹出角色面板，切换到基础字面板，再次切换到基础子面板的潜能分配子面板
haohu
2015年6月6日16:42:54
]]

QuestScriptCfg:Add(
{
	name = "roleleftpointguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc( FuncConsts.Role ); return true; end,
			complete = function() return UIRole:IsFullShow() and UIRoleBasic:IsShow(); end,
			Break = function() return false; end
		},
		
		[2] = {
			type = "normal",
			execute = function()
				if not UIRoleBasic:IsShow() then return end
				UIRoleBasic:ShowChild( UIRoleBasic.ADD_POINT )
				return true;
			end,
			complete = function() return UIRolePointAdd:IsShow(); end,
			Break = function() return not UIRoleBasic:IsShow(); end,
		}
	}
});
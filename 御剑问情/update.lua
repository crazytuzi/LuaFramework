
local check_update = {
	ctrl_state = CTRL_STATE.START,
}

function check_update:Start()
	local update_pkg = GLOBAL_CONFIG.param_list.switch_list.update_package
	local old_pkg_ver = string.gsub(GLOBAL_CONFIG.package_info.version or '', '%.', '')
	old_pkg_ver = tonumber(old_pkg_ver) or 0
	local new_pkg_ver = string.gsub(GLOBAL_CONFIG.version_info.package_info.version or '', '%.', '')
	new_pkg_ver = tonumber(new_pkg_ver) or 0

	if update_pkg and new_pkg_ver > old_pkg_ver then
		ReportManager:Step(Report.STEP_UPGRADE)
		local msg = GLOBAL_CONFIG.version_info.package_info.msg and tostring(GLOBAL_CONFIG.version_info.package_info.msg) or "版本过低，请下载安装最新安装包"
		local dialog_format = { cancelable = false, title = "版本更新", message = msg, positive = "下载", negative = "退出", }
		DialogManager.ShowMessage("版本更新", msg, "下载", function()
			UnityEngine.Application.OpenURL(GLOBAL_CONFIG.version_info.package_info.url)
			self.ctrl_state = CTRL_STATE.STOP
		end)
	else
		PushCtrl(require("init/init_download"))
		self.ctrl_state = CTRL_STATE.STOP
	end
end

function check_update:Update()
	if self.ctrl_state == CTRL_STATE.UPDATE then
		print_log("check_update: Update State")
	elseif self.ctrl_state == CTRL_STATE.START then
		self.ctrl_state = CTRL_STATE.UPDATE
		self:Start()
	elseif self.ctrl_state == CTRL_STATE.STOP then
		self.ctrl_state = CTRL_STATE.NONE
		PopCtrl(self)
	end
end

function check_update:Stop()
end

return check_update

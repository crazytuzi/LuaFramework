module(..., package.seeall)
local require = require;
local ui = require("ui/base");


local STATE =
{
	[EXT_PACK_STATE_NOT_EXIST]   = { barVis = true, text = "包体未下载"},
	[EXT_PACK_STATE_DOWNLOADING] = { barVis = true,  text = "下载中"},
	[EXT_PACK_STATE_DONE]        = { barVis = false, text = "下载完成"},
	[EXT_PACK_STATE_ERROR]       = { barVis = true, text = "下载或更新失败，点击下载重试"},
	[EXT_PACK_STATE_PAUSE]		 = { barVis = true,  text = "暂停中"},
}
-------------------------------------------------------
wnd_downloadExtPack = i3k_class("wnd_downloadExtPack", ui.wnd_base)
function wnd_downloadExtPack:ctor()
	self._timeCounter = 0
	self._state = EXT_PACK_STATE_NOT_EXIST
end

function wnd_downloadExtPack:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.downloadBtn:onClick(self, self.onDownload)
	self._layout.vars.pauseBtn:onClick(self, self.onPause)
	self._layout.vars.rewardBtn:onClick(self, self.onReward)
end

function wnd_downloadExtPack:onUpdate(dTime)
	if self._isUpdate then
		self._timeCounter = self._timeCounter + dTime
		if self._timeCounter > 0.5 then
			-- TODO debug
			local progress = g_i3k_game_handler:CheckUpdateProgress()
			if progress > 0 then
				if progress >= 1000 then
					self._isUpdate = nil
					self:popTipsNextFrame("普通更新成功");
					self._layout.vars.rewardBtn:hide()
				else
					self:popTipsNextFrame("普通更新进度" .. progress / 10);
				end
			else
				self:popTipsNextFrame("普通更新失败");
				self._isUpdate = nil
			end
		end
	end
end

function wnd_downloadExtPack:popTipsNextFrame(str)
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		g_i3k_ui_mgr:PopupTipMessage(str);
	end,1)
end

function wnd_downloadExtPack:onShow()
	local widgets = self._layout.vars
	local state = g_i3k_download_mgr:getCurState()
	local cfg = STATE[state]
	widgets.desc2:setText(cfg.text)
	widgets.rewardBtn:setVisible(g_i3k_download_mgr:getIsWin32Debug())
end
-- downloader状态变了，然后先修改自身状态，然后通知UI获取数据刷新界面
function wnd_downloadExtPack:refresh()
	local packID = g_i3k_download_mgr:getExtPackId()
	local state = g_i3k_download_mgr:getCurState()
	local widgets = self._layout.vars
	local percent = 0
	local cur = g_i3k_download_mgr:getDownloadSize(packID)
	local total = g_i3k_download_mgr:getTotalSize(packID)
	percent = cur / total * 100
	percent = math.ceil(percent)
	local cfg = STATE[state]
	self._state = state
	-- widgets.icon:setImage(g_i3k_db.i3k_db_get_ext_pack_reward_icon_id(packID))
	widgets.processBar:setVisible(cfg.barVis)
	widgets.desc2:setText(cfg.text)
	-- local curPackId = g_i3k_download_mgr:getExtPackId() -- 不显示
	-- local maxPackId = g_i3k_download_mgr:getMaxExtPackId()
	if state ~= EXT_PACK_STATE_DONE then
		local str = i3k_get_string(15346, self:getSize(total))
		if g_i3k_download_mgr:getPauseState() then
			str = str.."\n"..i3k_get_string(15347)-- 暂停中
		end
		widgets.desc2:setText(str)
	end
	widgets.progressBar:setPercent(percent)
	widgets.barValue:setText(i3k_get_string(15348, percent)) -- 当前进度为
end

function wnd_downloadExtPack:getSize(kbyte)
	return math.ceil((kbyte / 1024 / 1024))
end

function wnd_downloadExtPack:updatePercent(cur, total)
	if self._state ~= EXT_PACK_STATE_DOWNLOADING or g_i3k_download_mgr:getPauseState() then
		return
	end
	local widgets = self._layout.vars
	local percent = cur / total * 100
	percent = math.ceil(percent)
	widgets.progressBar:setPercent(percent)
	-- local curPackId = g_i3k_download_mgr:getExtPackId()
	-- local maxPackId = g_i3k_download_mgr:getMaxExtPackId()
	local str = i3k_get_string(15346, self:getSize(total)) -- 需要多少M流量
	widgets.desc2:setText(str)
	widgets.barValue:setText(i3k_get_string(15348, percent))
end

function wnd_downloadExtPack:onDownload(sender)
	-- local packId = g_i3k_download_mgr:getExtPackId()
	g_i3k_ui_mgr:PopupTipMessage("下载中")
	g_i3k_download_mgr:setNoWifiCancel(false)
	g_i3k_download_mgr:downloadExtPack(false)
end

function wnd_downloadExtPack:onReward(sender)
	g_i3k_ui_mgr:PopupTipMessage("模拟更新")
	g_i3k_game_handler:StartUpdate(false, "127.0.0.1", 8080, "/dir/version?version=7010&channel=520050_1001", "127.0.0.1", 8080, "/rxjh/kdist/android", "./")
	self._isUpdate = true
end

function wnd_downloadExtPack:onPause(sender)
	g_i3k_ui_mgr:PopupTipMessage("暂停下载")
	g_i3k_download_mgr:pauseDownloading()
end

-- 上面函数的回调
function wnd_downloadExtPack:onNotWifiTip()
	local msg = "您当前处于3G/4G网路环境，下载将会消耗流量，确认下载？"
	local callback = function (isOk)
		if isOk then
			g_i3k_download_mgr:setNoWifiCancel(false)
			local packId = g_i3k_download_mgr:getExtPackId()
			g_i3k_download_mgr:downloadExtPack(true)
		else
			g_i3k_download_mgr:setNoWifiCancel(true)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
end

function wnd_downloadExtPack:onCloseUI()
	g_i3k_download_mgr:setActiveOpenUIFlag()
	g_i3k_ui_mgr:CloseUI(eUIID_DownloadExtPack)
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_downloadExtPack.new();
		wnd:create(layout);
	return wnd;
end

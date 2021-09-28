local require = require

g_i3k_download_mgr = nil
function i3k_download_mgr_create()
    if not g_i3k_download_mgr then
        g_i3k_download_mgr = i3k_download_mgr:new()
        g_i3k_download_mgr:Create()
    end
end

function i3k_download_mgr_update(dTime)
    if g_i3k_download_mgr then
        g_i3k_download_mgr:onUpdate(dTime)
    end
end

function i3k_download_mgr_cleanUp()
    if g_i3k_download_mgr then
        g_i3k_download_mgr:Release()
    end
    g_i3k_download_mgr = nil
end
-------------------------------------------------------
i3k_download_mgr = i3k_class("i3k_download_mgr")

function i3k_download_mgr:ctor()
end

function i3k_download_mgr:Create()
    self._danceTimer = 0
    self.WIN32_DEBUG = false -- 自动下载分包调试标志位，正式版为false
    self._active = false -- 是否在传送过程触发了下载
    self._extPackId = 1
    self._maxExtPackId = g_i3k_db.i3k_db_get_ext_pack_max_id()
    self._doNotRequireWifi = false
    self._state = nil
    self._curSize = 0
    self._totalSize = 100
    self._OnPauseFlag = false
    self.state = {}
    self._timeCounter = 0
    self._powerSaveTimer = 0
    self._autoTimeCounter = 0
    self._onNoWifiCancel = false -- 非wifi下取消了下载
    self.JUMP_TAB =
    {
        [EXT_PACK_STATE_NOT_EXIST] =
        {
            [EXT_PACK_STATE_DONE] =          {action = self.OnHandlerStateChange},
            [EXT_PACK_STATE_DOWNLOADING] =   {action = self.OnHandlerStateChange},
        },
        [EXT_PACK_STATE_DOWNLOADING] =
        {
            [EXT_PACK_STATE_ERROR] =         {action = self.OnHandlerStateChange},
            [EXT_PACK_STATE_DONE] =          {action = self.OnHandlerStateChange},
            [EXT_PACK_STATE_PAUSE] =         {action = self.OnHandlerStateChange},
        },
        [EXT_PACK_STATE_ERROR] =
        {
            [EXT_PACK_STATE_NOT_EXIST] =        {action = self.OnHandlerStateChange},
            [EXT_PACK_STATE_DOWNLOADING] =   {action = self.OnHandlerStateChange},
        },
        [EXT_PACK_STATE_PAUSE] =
        {
            [EXT_PACK_STATE_DOWNLOADING] =   {action = self.OnHandlerStateChange},
        },
        [EXT_PACK_STATE_DONE] =
        {
            [EXT_PACK_STATE_NOT_EXIST] =        {action = self.OnHandlerStateChange},
            [EXT_PACK_STATE_DOWNLOADING] =   {action = self.OnHandlerStateChange}, -- 第一个分包下载完成下载第二个
        },
    }
    self:initState()
end


function i3k_download_mgr:onUpdate(dTime)
    self._timeCounter = self._timeCounter + dTime
    if self._timeCounter > 0.5 then
        if g_i3k_db.i3k_db_get_show_download_pack() then -- 如果有分包并且为下载，才启动这个timer
            self:onSecondTask(dTime)
        end
        self._timeCounter = 0
    end
    self:onUpdateAutoDownload(dTime) -- 自动更新定时器

    self._powerSaveTimer = self._powerSaveTimer + dTime
    if self._powerSaveTimer > 10 * 60 then  -- 10分钟检查一次
        self:checkAutoPowerSaveModel(dTime)
        self._powerSaveTimer = 0
    end

    -- 宠物赛跑计时器
    self:updatePetRaceSkill(dTime)
    self:updateDanceNpc(dTime)
end

function i3k_download_mgr:getSize(kbyte)
	return math.ceil((kbyte / 1024 / 1024)).."M"
end

function i3k_download_mgr:onSecondTask(dTime)
    if self:getCurState() ~= EXT_PACK_STATE_DONE and self:getCurState() ~= EXT_PACK_STATE_PAUSE and not self._isAutoDownload then
        local extPackId = self:getExtPackId()
        local state = self:getExtPackDownloadState(extPackId) -- 需要不断的查询，才能持续下载。
        if self:checkStateDownload() then
            local bytes = self:getDownloadSize(extPackId)
            local total = self:getTotalSize(extPackId)
            g_i3k_ui_mgr:InvokeUIFunction(eUIID_DownloadExtPack, "updatePercent", bytes, total)
        end
    end
end
function i3k_download_mgr:Release()
end

function i3k_download_mgr:Clear()
    self:resetActive()
end

function i3k_download_mgr:getIsWin32Debug()
    return self.WIN32_DEBUG
end

function i3k_download_mgr:setPauseState(bValue)
    self._OnPauseFlag = bValue
end

function i3k_download_mgr:setNoWifiCancel(bValue)
    self._onNoWifiCancel = bValue
end

function i3k_download_mgr:getPauseState()
    return self._OnPauseFlag
end

function i3k_download_mgr:getExtPackId()
    return self._extPackId
end
function i3k_download_mgr:getMaxExtPackId()
    return self._maxExtPackId
end

function i3k_download_mgr:popTipsNextFrame(str)
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		g_i3k_ui_mgr:PopupTipMessage(str);
	end,1)
end
----------------------------------

function i3k_download_mgr:initState()
    self.state.curState = EXT_PACK_STATE_NOT_EXIST
end

function i3k_download_mgr:pushState(state, ...)
    if self.JUMP_TAB[self.state.curState] then
        local cfg = self.JUMP_TAB[self.state.curState][state]
        if cfg then
            if cfg.action then
                self.state.curState = state
                cfg.action(self, ...)
                return true
            end
        else
            i3k_log("i3k_download_mgr:pushState  state not found.  cur= "..self.state.curState.." to= "..state)
        end
    end
    return false
end
function i3k_download_mgr:getCurState()
    return self.state.curState
end
function i3k_download_mgr:checkStateDownload()
    return self:getCurState() == EXT_PACK_STATE_DOWNLOADING
end

-- 收到状态切换，那么给ui推送一下状态
function i3k_download_mgr:OnHandlerStateChange(msg)
    g_i3k_ui_mgr:RefreshUI(eUIID_DownloadExtPack)
    -- if msg and msg ~= "" and not self._isAutoDownload then
    --     g_i3k_ui_mgr:PopupTipMessage(msg)
    -- end
end

-------------------------------------------------
function i3k_download_mgr:getExtPackState(extPackId)
    if i3k_game_get_os_type() == eOS_TYPE_WIN32 and self.WIN32_DEBUG == false then
        return EXT_PACK_STATE_DONE
    end
    if extPackId == 0 then
        return EXT_PACK_STATE_DONE
    end
    return g_i3k_game_handler:GetExtPackState(extPackId)
end

function i3k_download_mgr:getExtPackDownloadState(extPackId)
    local state = g_i3k_game_handler:GetExtPackDownloadState(extPackId)
    i3k_log("getExtPackDownloadState "..extPackId.." ".. state)
    if state == EXT_PACK_DOWNLOAD_NOT_WIFI then
        if self._isAutoDownload then
            self._isAutoDownload = false
            return
        end
        if self._onNoWifiCancel then
            return
        end
        local msg = "当前非wifi环境"
        self:pushState(EXT_PACK_STATE_PAUSE, nil)
        self:OpenDownloadUI()
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_DownloadExtPack, "onNotWifiTip")
    elseif state == EXT_PACK_DOWNLOAD_NOT_ENOUGH_MEM then
        local msg = "记忆体不足"
        self:pushState(EXT_PACK_STATE_PAUSE, msg)
    elseif state == EXT_PACK_DOWNLOAD_NOT_ENOUGH_SPACE then
        local msg = "sd卡存储空间不足"
        if not self._isAutoDownload then
            self:popTipsNextFrame(msg)
        end
        self:pushState(EXT_PACK_STATE_PAUSE, msg)
    elseif state == EXT_PACK_DOWNLOAD_FAILED then
        local msg = "下载失败"
        self:pushState(EXT_PACK_STATE_PAUSE, msg)
    elseif state == EXT_PACK_DOWNLOAD_NO_TASKS then
        local msg = "当前没有下载"
        self:pushState(EXT_PACK_STATE_NOT_EXIST, msg)
    elseif state == EXT_PACK_DOWNLOAD_DOWNLOADING then
        local msg = "正在下载"
        self:pushState(EXT_PACK_STATE_DOWNLOADING, msg)
    elseif state == EXT_PACK_DOWNLOAD_UPDATING then
        local msg = "正在更新"
        self:pushState(EXT_PACK_STATE_DOWNLOADING, msg)
    elseif state == EXT_PACK_DOWNLOAD_DONE then
        local msg = "下载/更新完成"
        self:pushState(EXT_PACK_STATE_DONE, msg)
        self:onDownloadDone()
    end
    return state
end

function i3k_download_mgr:checkResouceStateByPackID(packID)
    if i3k_game_get_os_type() == eOS_TYPE_WIN32 then
        if not self.WIN32_DEBUG then
            return true
        end
    end
    if packID == 0 then
        return true
    end
    local packState = self:getExtPackState(packID)
	if packState == EXT_PACK_STATE_DONE then
		return true
	else
        return false
    end
end

function i3k_download_mgr:setActiveOpenUIFlag()
    --TODO 在协程里，延迟3秒左右设置这个状态为false
    --self._active = false
    self.co = g_i3k_coroutine_mgr:StartCoroutine(function()
        g_i3k_coroutine_mgr.WaitForSeconds(3) --延时
        self:resetActive()
        g_i3k_coroutine_mgr:StopCoroutine(self.co)
    end)
end

function i3k_download_mgr:resetActive()
    self._active = nil
end

function i3k_download_mgr:OpenDownloadUI()
    g_i3k_ui_mgr:OpenUI(eUIID_DownloadExtPack)
    g_i3k_ui_mgr:RefreshUI(eUIID_DownloadExtPack)
end

-- 遇到传送地图的时候，判断该地图的资源是否下载
function i3k_download_mgr:checkResouceState(mapID)
    local packID = g_i3k_db.i3k_db_get_ext_pack_id(mapID)
    if packID == 0 then
        return true
    end
    if i3k_game_get_os_type() == eOS_TYPE_WIN32 then
        if not self.WIN32_DEBUG then
            return true
        end
    end

	local packState = self:getExtPackState(packID)
	if packState == EXT_PACK_STATE_DONE then
		return true
	else
        if not self._active then
            self._active = true
            self._extPackId = packID
            self:OpenDownloadUI()
			return false
        else
            -- 如果玩家一直站在传送点不出来，那么就给他提示
            if self:getCurState() == EXT_PACK_STATE_DOWNLOADING then
                -- g_i3k_ui_mgr:PopupTipMessage("正在下载资源包")
    			return false
            elseif self:getCurState() == EXT_PACK_STATE_NOT_EXIST then -- 站在传送点会有这个提示，点击传送也是这个提示
                -- g_i3k_ui_mgr:PopupTipMessage("点击主介面的图示下载资源包")
                return false
            elseif self:getCurState() == EXT_PACK_STATE_ERROR then
                -- g_i3k_ui_mgr:PopupTipMessage("下载资源包失败")
                return false
            -- elseif self:getCurState() == EXT_PACK_STATE_DONE then
            --     g_i3k_ui_mgr:PopupTipMessage("下载资源包完成")
            --     return false
    		end
        end
	end
end
-- 返回下载好的最大id,默认为0
function i3k_download_mgr:getMaxdownloadPackId(extPackId)
    if extPackId < 1 then
        return 0
    end
    local packState = self:getExtPackState(extPackId)
    i3k_log("extPackId:"..extPackId.." state:"..packState)
    if packState ~= EXT_PACK_STATE_DONE then
        return self:getMaxdownloadPackId(extPackId - 1)
    else
        return extPackId
    end
end

-- 在调用此方法之前，需要检测状态。
function i3k_download_mgr:downloadImpl(doNotRequireWifi)
    local extPackId = self:getMaxdownloadPackId(self._maxExtPackId)
    self._extPackId = extPackId + 1
    i3k_log("begin to download files..."..self._extPackId)
    return g_i3k_game_handler:DownloadExtPack(self._extPackId, doNotRequireWifi)
end

-- 上一个包下载完成了，继续下载第二个包
function i3k_download_mgr:onDownloadDone()
    local extPackId = self:getMaxdownloadPackId(self._maxExtPackId)
    i3k_log("onDownloadDone "..extPackId)
    if extPackId + 1 > self._maxExtPackId then
        return
    end
    local bState = self:downloadImpl(self._doNotRequireWifi)
    if not bState then
        self:getExtPackDownloadState(extPackId + 1)
    else
        self:setPauseState(false)
        local msg = nil --"正在下载..."
        i3k_log("=======state "..self.state.curState)
        self:pushState(EXT_PACK_STATE_DOWNLOADING, msg)
    end
end

-- 开始下载
function i3k_download_mgr:downloadExtPack(doNotRequireWifi)
    self._isAutoDownload = false -- 手动触发了下载，那么自动下载就停掉
    self._doNotRequireWifi = doNotRequireWifi
    self:setDownloadSpeed(0) -- 手动下载设置为全速
    local packState = self:getMaxdownloadPackId(self:getMaxExtPackId())
	if packState == self:getMaxExtPackId() then
        g_i3k_ui_mgr:PopupTipMessage("游戏资源已经下载完成")
        return
    end
	local bState = self:downloadImpl(doNotRequireWifi)
    if not bState then
        self:getExtPackDownloadState(self._extPackId)
    else
        self:setPauseState(false)
        local msg = "正在下载..."
        self:pushState(EXT_PACK_STATE_DOWNLOADING, msg)
    end
end

-- 获取已经下载的字节
function i3k_download_mgr:getDownloadSize(extPackId)
    return g_i3k_game_handler:GetDownloadedSize(extPackId)
end
-- 总大小
function i3k_download_mgr:getTotalSize(extPackId)
    return i3k_getExtPackSize(extPackId)
    -- local total = g_i3k_game_handler:GetTotalSize(extPackId)
    -- return total > 0 and total or 100 -- 可能存在-1的情况
end
-- 暂停下载
function i3k_download_mgr:pauseDownloading()
    self:setPauseState(true)
    self:pushState(EXT_PACK_STATE_PAUSE, nil)
    return g_i3k_game_handler:PauseDownloading()
end
-- 限制下载速度接口，speed 是 K/s， <= 0 不限制
function i3k_download_mgr:setDownloadSpeed(speed)
    -- if not self.WIN32_DEBUG then
        g_i3k_game_handler:SetHTTPDownloadSpeedLimit(speed)
    -- end
end

----------自动更新相关begin--------------
-- 自动更新相关onUpdate入口
function i3k_download_mgr:onUpdateAutoDownload(dTime)
    self._autoTimeCounter = self._autoTimeCounter + dTime
    if self._autoTimeCounter > 1 then
        self:checkStartUpdate(dTime)
        self:checkAutoDownload(dTime)
        self._autoTimeCounter = 0
    end
end

-- 自动更新入口 测试代码
function i3k_download_mgr:tryStartUpdate()
    if not g_i3k_db.i3k_db_get_show_download_pack() then
        return
    end
    if i3k_game_get_os_type() == eOS_TYPE_WIN32 then
        if self.WIN32_DEBUG then -- win32模式下增加一个调试标志位
            g_i3k_game_handler:StartUpdate(false, "127.0.0.1", 8080, "/dir/version?version=7010&channel=520050_1001", "127.0.0.1", 8080, "/rxjh/kdist/android", "./")
            self._isAutoUpdate = true
        else
            self:onAutoDownload()
        end
    else
        self:onAutoDownload()
    end
end

function i3k_download_mgr:checkStartUpdate(dTime)
    if self._isAutoUpdate then
        local progress = g_i3k_game_handler:CheckUpdateProgress()
        if progress >= 1000 then
            self:onAutoDownload()
            self._isAutoUpdate = nil
        end
    end
end

-- 登陆游戏满足wifi条件自动下载分包
function i3k_download_mgr:onAutoDownload()
    self._isAutoDownload = true
    local bState = self:downloadImpl(false) -- 如果是wifi默认下载
    if bState then
        i3k_log("onAutoDownload true")
        self:setDownloadSpeed(150) -- 自动下载设置为150k/s默认
        self:setPauseState(false)
        self.state.curState = EXT_PACK_STATE_DOWNLOADING
        self._isAutoDownload = true
    end
end

function i3k_download_mgr:checkAutoDownload(dTime) -- this function should execute in second task
    if self._isAutoDownload then
        local extPackId = self:getExtPackId()
        local state = g_i3k_game_handler:GetExtPackDownloadState(extPackId)
        if state == EXT_PACK_DOWNLOAD_DONE then
            -- self:popTipsNextFrame("游戏分包后台自动更新完成")
            self:onDownloadDone()
            self._isAutoDownload = nil
        end
    end
end
--------------自动更新相关end------------------



----------------------------------------------
----------------------------------------------
--------------使用这个全局计时器----------------
-- 这里只用一个全局计时器，做一些设置省电模式自动计时
function i3k_download_mgr:checkAutoPowerSaveModel(dTime)
    local cfg = g_i3k_game_context:GetUserCfg()
	local isOnAutoPowerSave = cfg:GetAutoPowerSave()
    if isOnAutoPowerSave then
        self:setPowerSaveMode(true)
    end
end

-- 如果每点击一次，则记录下这个时间
function i3k_download_mgr:clearAutoPowerSaveTimer()
    if self._powerSaveTimer > 1 then
        local cfg = g_i3k_game_context:GetUserCfg()
        local isOnPowerSave = #cfg:GetPowerSave() > 0
        if isOnPowerSave then
            self:setPowerSaveMode(false)
        end
        self._powerSaveTimer = 0
    end
end

-- 设置省电入口-- args boolean 型开关
function i3k_download_mgr:setPowerSaveMode(turnOn)
	if turnOn then
		if g_i3k_game_context:getIsOnPowerSaveMode() then
			g_i3k_ui_mgr:PopupTipMessage("当前已经处于省电模式")
			return
		end
		-- 先保存原始的设置
		self:setTurnOnPowerSaveUserCfg() -- 保存旧的设置
        self:setAutoBrightness(false)
		self:turnOnPowerSaveMode()
        self._powerSaveTimer = 0
	else
		if not g_i3k_game_context:getIsOnPowerSaveMode() then
			g_i3k_ui_mgr:PopupTipMessage("当前已经处于非省电模式")
			return
		end
		local list = self:setTurnOffPowerSaveUserCfg()
		self:turnOffPowerSaveMode(list)
	end
    g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetBlood, "initPowerSaveBtnState")
end

-- 设置屏幕自动亮度（先检查，再设置）
function i3k_download_mgr:setAutoBrightness(auto)
    if auto then
        if not i3k_get_is_screen_auto_brightness() then
            i3k_set_screen_auto_birghtness(true)
        end
    else
        if i3k_get_is_screen_auto_brightness() then
            i3k_set_screen_auto_birghtness(false)
        end
    end
end

-- 关闭省电模式
function i3k_download_mgr:turnOffPowerSaveMode(list)
    local autoBright = list[1] == 1
	local brightness = list[2] or 1
	local bgMusic = list[3] or 70
	local effMusic = list[4] or 70
	local fpsLevel = list[5] or 3
	local filterNum = list[6] or 5
	local effectLvl = list[7] or 1
	self:turnUpScreen(brightness)
    self:setAutoBrightness(autoBright)
	self:turnOnMusic(bgMusic, effMusic)
	self:turnUpFPS(fpsLevel)
	self:turnUpPlayers(filterNum)
	self:turnUpEffect(effectLvl)
end

-- 设置省电模式具体的内容
function i3k_download_mgr:turnOnPowerSaveMode()
	-- TODO 读取数据为读表
	local brightness = 5
	local bgMusic = 0
	local effMusic = 0
	local fps = 12 -- 此处为具体的fps值，而不是等级
	local filterNum = 0
	local effectLvl = 0
	self:turnDownScreen(brightness)
	self:turnOffMusic(bgMusic, effMusic)
	self:turnDownFPS(fps)
	self:turnDownPlayers(filterNum)
	self:turnDownEffect(effectLvl)
end
-- 进入省电模式之前，先要将原有的设置存一下，在恢复的时候使用
function i3k_download_mgr:setTurnOnPowerSaveUserCfg()
	local cfg = g_i3k_game_context:GetUserCfg()
    local autoBright = i3k_get_is_screen_auto_brightness() and 1 or 0
	local screenBrightness = i3k_get_screen_brightness()
	local bgMusic, effMusic = cfg:GetVolume()
	local fpsLevel = cfg:GetFPSLimit()
	local filterNum = cfg:GetFilterPlayerNum()
	local effectLvl = cfg:GetFilterTXLvl()
	cfg:SetPowerSave({autoBright, screenBrightness, bgMusic, effMusic, fpsLevel, filterNum, effectLvl}) -- 严格有序数组
end

-- 恢复从保存的数据获取
function i3k_download_mgr:setTurnOffPowerSaveUserCfg()
	local cfg = g_i3k_game_context:GetUserCfg()
	local list = cfg:GetPowerSave()
	cfg:SetPowerSave({})
	return list
end

-- 同屏人数
function i3k_download_mgr:turnDownPlayers(num)
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:SetFilterPlayerNum(num)
    g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetBlood, "initFilterPlayerNum")
end
function i3k_download_mgr:turnUpPlayers(num)
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:SetFilterPlayerNum(num)
    g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetBlood, "initFilterPlayerNum")
end

-- 特效相关
function i3k_download_mgr:turnDownEffect(level)
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:SetFilterTXLvl(level)
    g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetBlood, "initFilterTXLvl")
    g_i3k_game_context:SetEffectFilter(level)
end
function i3k_download_mgr:turnUpEffect(level)
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:SetFilterTXLvl(level)
    g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetBlood, "initFilterTXLvl")
    g_i3k_game_context:SetEffectFilter(level)
end

-- 屏幕亮度
function i3k_download_mgr:turnUpScreen(brightness)
	i3k_set_screen_brightness(brightness)
end
function i3k_download_mgr:turnDownScreen(brightness)
	i3k_set_screen_brightness(brightness)
end

-- 音量
function i3k_download_mgr:turnOnMusic(bgMusic, effMusic)
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:SetVolume(bgMusic, effMusic)
    g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetBlood, "initMusicStatus") -- 这里的InvokeUIFunction 都刷新ui的，并不设置属性
    i3k_set_game_music(bgMusic, effMusic)
end
function i3k_download_mgr:turnOffMusic(bgMusic, effMusic)
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:SetVolume(bgMusic, effMusic)
    g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetBlood, "initMusicStatus")
    i3k_set_game_music(bgMusic, effMusic)
end

-- 帧率
function i3k_download_mgr:turnUpFPS(fpsLevel)
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:SetFPSLimit(fpsLevel)
    i3k_fps_limit(FPS_LIMIT[fpsLevel])
    g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetBlood, "initFPSLimit")
end
function i3k_download_mgr:turnDownFPS(fps)
	i3k_fps_limit(fps)
end
--------------计时器end----------------


---------------宠物赛跑计时器（技能冷却）------------------------
function i3k_download_mgr:updatePetRaceSkill(dTime)
    g_i3k_game_context:updatePetRaceSkillTime(dTime)
end
function i3k_download_mgr:updateDanceNpc(dTime)
    self._danceTimer = self._danceTimer + dTime
    if self._danceTimer > i3k_db_dance_stage.popTime then
        local logic = i3k_game_get_logic();
        if logic then
            local world = logic:GetWorld();
            if world then
                world:refreshDanceNpcPopString()
            end
        end
        self._danceTimer = 0
    end
end

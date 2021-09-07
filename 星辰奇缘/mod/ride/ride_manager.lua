-- ----------------------------------------------------------
-- 逻辑模块 - 坐骑
-- @ljh 2016.5.24
-- ----------------------------------------------------------
RideManager = RideManager or BaseClass(BaseManager)

function RideManager:__init()
    if RideManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	RideManager.Instance = self

    self.model = RideModel.New()

    self.OnUpdateRide = EventLib.New()
    self.OnUpdateOneRide = EventLib.New()
    self.OnUpgradeUpdate = EventLib.New() -- 升级
    self.OnBreakUpdate = EventLib.New() -- 突破
    self.OnContractUpdate = EventLib.New() -- 契约
    self.OnSkillUpdate = EventLib.New() -- 技能

    self.OnUpdateReset = EventLib.New() --洗髓
    self.OnUpdateDye = EventLib.New() --染色
    self.OnUpdateTime = EventLib.New()
    self.OnTransfigurationTime = EventLib.New()

    self:InitHandler()

    self._roleEventChange = function (event,oldEvent)
        self:roleEventChange(event,oldEvent)
    end
    EventMgr.Instance:AddListener(event_name.role_event_change, self._roleEventChange)

    self._update_item = function() self.model:update_item() end
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._update_item)

    self.growthDataList = {
        [1] = { growth = 1, name = "<color='#808080'>灰色</color>"}
        , [2] = { growth = 2, name = "<color='#248813'>绿色</color>"}
        , [3] = { growth = 3, name = "<color='#225ee7'>蓝色</color>"}
        , [4] = { growth = 4, name = "<color='#b031d5'>紫色</color>"}
        , [5] = { growth = 5, name = "<color='#c3692c'>橙色</color>"}
        , [6] = { growth = 6, name = "<color='#df3435'>红色</color>"}
    }

    self.rideStatus = 0
end

function RideManager:__delete()
    self.OnUpdateRide:DeleteMe()
    self.OnUpdateRide = nil
    self.OnUpdateOneRide:DeleteMe()
    self.OnUpdateOneRide = nil
    self.OnUpdateReset:DeleteMe()
    self.OnUpdateReset = nil
    self.OnUpgradeUpdate:DeleteMe()
    self.OnUpgradeUpdate = nil
    self.OnUpdateDye:DeleteMe()
    self.OnUpdateDye = nil
end

function RideManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(17000, self.On17000)
    self:AddNetHandler(17001, self.On17001)
    self:AddNetHandler(17002, self.On17002)
    self:AddNetHandler(17003, self.On17003)
    self:AddNetHandler(17004, self.On17004)
    self:AddNetHandler(17005, self.On17005)
    self:AddNetHandler(17006, self.On17006)
    self:AddNetHandler(17007, self.On17007)
    self:AddNetHandler(17008, self.On17008)
    self:AddNetHandler(17009, self.On17009)
    self:AddNetHandler(17010, self.On17010)
    self:AddNetHandler(17011, self.On17011)
    self:AddNetHandler(17012, self.On17012)
    self:AddNetHandler(17013, self.On17013)
    self:AddNetHandler(17014, self.On17014)
    self:AddNetHandler(17015, self.On17015)
    self:AddNetHandler(17017, self.On17017)
    self:AddNetHandler(17018, self.On17018)
    self:AddNetHandler(17019, self.On17019)
    self:AddNetHandler(17020, self.On17020)
    self:AddNetHandler(17021, self.On17021)
    self:AddNetHandler(17022, self.On17022)
    self:AddNetHandler(17023, self.On17023)
    self:AddNetHandler(17024, self.On17024)
    self:AddNetHandler(17025, self.On17025)
    self:AddNetHandler(17026, self.On17026)
    self:AddNetHandler(17027, self.On17027)
    self:AddNetHandler(17028, self.On17028)
    self:AddNetHandler(17029, self.On17029)
    self:AddNetHandler(17030, self.On17030)
    self:AddNetHandler(17031, self.On17031)
    self:AddNetHandler(17032, self.On17032)
    self:AddNetHandler(17033, self.On17033)
    self:AddNetHandler(17034, self.On17034)
    self:AddNetHandler(17035, self.On17035)

end

function RideManager:Send17000()
    Connection.Instance:send(17000, { })
end

function RideManager:On17000(data)

    -- print("On17000")
    self.model:On17000(data)
end

function RideManager:Send17001(index)
    print("Send17001" .. index)
    Connection.Instance:send(17001, { index = index })
end

function RideManager:On17001(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- self.model:On17001(data)
end

--坐骑洗髓
function RideManager:Send17002(_index)
    print("Send17002")
    Connection.Instance:send(17002, { index = _index })
end

function RideManager:On17002(data)
    if data.errc_ode == 1 then
        --成功
        if self.model.rideWashWindow ~= nil then
            self.model.rideWashWindow:showWashEffect()
        end
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--坐骑培养
function RideManager:Send17003(index)
    print("Send17003")
    Connection.Instance:send(17003, {index = index})
end

--坐骑培养
function RideManager:On17003(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--保存洗髓
function RideManager:Send17004(_index)
    print("Send17004")
    Connection.Instance:send(17004, { index = _index })
end

function RideManager:On17004(data)
    if data.errc_ode == 1 then
        --成功
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 坐骑技能升级
function RideManager:Send17005(index, skill_index)
    print("index="..index..",skill_index="..skill_index)
    Connection.Instance:send(17005, {index = index, skill_index = skill_index})
end

function RideManager:On17005(data)
    BaseUtils.dump(data,"1700555555555555555555")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.OnSkillUpdate:Fire()
end

--升级坐骑
function RideManager:Send17006(index,flag)
    print("send17006")
    local _is_sure_success = flag and 1 or 0
    Connection.Instance:send(17006, { index = index, is_sure_success = _is_sure_success})
end

function RideManager:On17006(data)
    BaseUtils.dump(data,"收到0n17006")
    if data.is_success == 1 then
        --成功
        -- NoticeManager.Instance:FloatTipsByString("升级成功")
    else
        -- NoticeManager.Instance:FloatTipsByString("升级失败")
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.OnUpgradeUpdate:Fire({code = data.is_success})
end

--签订灵魂契约
function RideManager:Send17007(index, pet_id)
    Connection.Instance:send(17007, {index = index, pet_id = pet_id})
end

function RideManager:On17007(data)
    BaseUtils.dump(data, "1700777777")
    if data.errc_ode == 1 then
        --成功
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.OnContractUpdate:Fire()
end

-- 推送坐骑目标数据
function RideManager:Send17008()
    --print("Send17008")
    Connection.Instance:send(17008, { })
end

function RideManager:On17008(data)
    -- print("On1700??????????????????????????????????????????????????????????")
    --BaseUtils.dump(data)
    self.model:On17008(data)
end

-- 获取坐骑蛋
function RideManager:Send17009()
    print("Send17009")
    Connection.Instance:send(17009, { })
end

function RideManager:On17009(data)
    print("On17009")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.errc_ode == 1 then
        --成功
    else

    end
end

-- 孵化坐骑
function RideManager:Send17010()
    print("Send17010")
    Connection.Instance:send(17010, { })
end

function RideManager:On17010(data)
    -- print("On17010")
    print(data.mount_base_id)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.errc_ode == 1 then
        --成功
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = data.mount_base_id, callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow) end })
    else

    end
end

-- 坐骑突破
function RideManager:Send17011(index)
    Connection.Instance:send(17011, {index = index})
end

function RideManager:On17011(dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
    self.OnBreakUpdate:Fire({code = 2, list = dat.skill_list})
end

-- 坐骑信息更新
function RideManager:Send17012()
    print("Send17012")
    Connection.Instance:send(17012, { })
end

function RideManager:On17012(data)
    print("On17012")
    BaseUtils.dump(data)
    self.model:On17012(data)
end

-- 坐骑技能重置
function RideManager:Send17013(index, skill_index, skill_Id)
    print("send17013")
    Connection.Instance:send(17013, {index = index, skill_index = skill_index, skill_Id = skill_Id})
end

function RideManager:On17013(data)
    BaseUtils.dump(data,"on17013")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.OnSkillUpdate:Fire()
end

-- 解除灵魂契约
function RideManager:Send17014(index, pet_id)
    Connection.Instance:send(17014, {index = index, pet_id = pet_id})
end

function RideManager:On17014(dat)
    BaseUtils.dump(dat, "170144")
    NoticeManager.Instance:FloatTipsByString(dat.msg)
    self.OnContractUpdate:Fire()
end

function RideManager:Send17015(index, appearance_id)
    Connection.Instance:send(17015, {index = index, appearance_id = appearance_id})
end

function RideManager:On17015(dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

function RideManager:Send17017(index, decorate_index)
    Connection.Instance:send(17017, {index = index, decorate_index = decorate_index})
end

function RideManager:On17017(dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 坐骑技能点重置
function RideManager:Send17018(index, skill_index)
    Connection.Instance:send(17018, {index = index, skill_index = skill_index})
end

function RideManager:On17018(dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
    self.OnSkillUpdate:Fire()
end

function RideManager:Send17019(appearance_id)
    Connection.Instance:send(17019, {appearance_id = appearance_id})
end

function RideManager:On17019(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.errc_ode == 1 then
        --成功
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = data.appearance_id, callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow) end })
    else

    end
end

function RideManager:Send17020(index, decorate_index, is_hide)
print("17020")
    Connection.Instance:send(17020, { index = index, decorate_index = decorate_index, is_hide = is_hide})
end

function RideManager:On17020(data)
    print("On17020")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function RideManager:On17021(data)
    -- print("On17021")
    if data.expire_time ~= 0 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = data.base_id, callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow) end })
    end
end

function RideManager:Send17022(base_id)
    print("Send17022")
    print(base_id)
    Connection.Instance:send(17022, { base_id = base_id })
end

function RideManager:On17022(data)
    BaseUtils.dump(data, "On17022")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.errc_ode == 1 then
        if #data.cache_dye_list > 0 then
            self.OnUpdateDye:Fire({1, data.base_id, data.cache_dye_list[1].dye_id})

            local data_ride_dye = DataMount.data_ride_dye[data.base_id]
            local data_ride_dye_preview = nil
            for index, value in pairs(DataMount.data_ride_dye_preview) do
                if data.cache_dye_list[1].dye_id == value.dye_id then
                    data_ride_dye_preview = value
                end
            end
            if data_ride_dye ~= nil and data_ride_dye_preview ~= nil then
                local color_name = data_ride_dye.color_name[data_ride_dye_preview.color_id].name
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("成功染色成<color='#ffff00'>%s</color>{face_1, 18}"), color_name))
            end
        end
    end
end

function RideManager:Send17023(base_id, dye_id, index)
    print("Send17023")
    print(base_id..","..dye_id..","..index)
    Connection.Instance:send(17023, { base_id = base_id, dye_id = dye_id, index = index })

    -- self.OnUpdateDye:Fire({2})
end

function RideManager:On17023(data)
    BaseUtils.dump(data, "On17023")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.errc_ode == 1 then
        self.OnUpdateDye:Fire({2})
    end
end

function RideManager:Send17024(base_id)
    Connection.Instance:send(17024, { base_id = base_id })
end

function RideManager:On17024(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function RideManager:Send17025(base_id)
    Connection.Instance:send(17025, { base_id = base_id })
end

function RideManager:On17025(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-------------------------------------------
-------------------------------------------
------------- 逻辑处理 -----------------
-------------------------------------------
-------------------------------------------

function RideManager:RequestInitData()
    self.model.ride_mount = 0
    self.model.ride_nums = 5
    self.model.ridelist = {}
    self.model.cur_ridedata = nil
    self.model.using_ridedata = nil

    self.model.prop_preview_type = 1 --属性预览界面类型
    self.model.prop_preview_ride_id = 0 --属性预览界面的坐骑id
    self.model.goal_list = {} -- 坐骑蛋目标

    self:Send17000()
    self:Send17008()
end

function RideManager:CanShowRide(event)
    if event == RoleEumn.Event.Marry or event == RoleEumn.Event.Marry_cere
        or event == RoleEumn.Event.Marry_guest or event == RoleEumn.Event.Marry_guest_cere
        or event == RoleEumn.Event.Home or event == RoleEumn.Event.NewQuestionMatch
        or event == RoleEumn.Event.GuildDragon or event == RoleEumn.Event.GuildDragonFight or event == RoleEumn.Event.GuildDragonRod
        or event == RoleEumn.Event.GodsWarWorShip
        then
        return false
    end
    return true
end

function RideManager:roleEventChange(event,oldEvent)
    if self:CanShowRide(event) ~= self:CanShowRide(oldEvent) then
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            SceneManager.Instance.sceneElementsModel.self_view:ChangeLook()
        end
    end


    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        local data = SceneManager.Instance.sceneElementsModel.self_view.data
        if data.event == RoleEumn.Event.Home and oldEvent ~= RoleEumn.Event.Home then
            if data.ride == SceneConstData.unitstate_ride
                or data.ride == SceneConstData.unitstate_fly and data.ride_fly then
                NoticeManager.Instance:FloatTipsByString(TI18N("回家啦，从坐骑上一跃而下"))
            end
        end
    end
end

function RideManager:IsNeedFeed()
    if self.model.cur_ridedata ~= nil and self.model.cur_ridedata.spirit ~= nil then
        return self.model.cur_ridedata.spirit <= 150
    else
        return false
    end
end

function RideManager:Send17026(keyId)
    Connection.Instance:send(17026, {key_id = keyId })
end

function RideManager:On17026(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.errc_ode == 1 and data.base_id > 0 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = data.base_id, callback = function() local args = {msg = "奖励：开启后可<color='#00ff00'>领取</color>各式<color='#00ff00'>奖励</color>",gain = {[1] = {id = 35,value = 35}}}
        OpensysManager.Instance:Show(args) end })
        for k,v in pairs(self.model.ridelist) do
            if v.base.base_id == data.base_id then
                self:Send17001(v.index)
            end
        end



    end
end

function RideManager:Send17027(keyId)
    Connection.Instance:send(17027, {key_id = keyId })
end

function RideManager:On17027(data)

    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.errc_ode == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = data.base_id, callback = function()  end })
        for k,v in pairs(self.model.ridelist) do
            if v.base.base_id == data.base_id then
                self:Send17001(v.index)
            end
        end
    end
end

function RideManager:Send17028()
    -- print("发送协议17028================================")
    Connection.Instance:send(17028,{})
end

function RideManager:On17028(data)
    -- BaseUtils.dump(data,"协议回调17028====================")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.errc_ode == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rideChooseEndWindow, {})
    elseif data.errc_ode == 0 then
        self.OnUpdateTime:Fire(data.remain_time)
    end
    self.rideStatus = data.errc_ode
end


function RideManager:Send17029(transfiguration_id)
    -- print("发送协议17029:" .. transfiguration_id)
    Connection.Instance:send(17029, {base_id = transfiguration_id})
end

function RideManager:On17029(data)
    -- BaseUtils.dump(data,"协议回调17029==============================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.errc_ode == 1 then
        --成功
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = data.base_id, callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow) end })
    else

    end
end


function RideManager:Send17030(transfiguration_id,index,id)
    self.rideDataIndex = index or 0
    self.rideDataId = id or 0
    print("发送协议17030:" .. transfiguration_id)
    Connection.Instance:send(17030, {base_id = transfiguration_id})
end

function RideManager:On17030(data)
    -- BaseUtils.dump(data,"协议回调17030==============================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.errc_ode == 1 then
        self.OnTransfigurationTime:Fire()
        --成功
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = data.base_id, callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow) end })
        if self.rideDataIndex ~= 0 then
            self:Send17015(self.rideDataIndex, self.rideDataId)
        end
    else

    end
end

--邀请共乘
function RideManager:Send17031(rid, platform, zone_id)
    -- print("发送协议17031--请求共乘坐骑协议")
    Connection.Instance:send(17031, {id = rid, platform = platform, zone_id = zone_id})
end

function RideManager:On17031(data)
    -- BaseUtils.dump(data,"协议回调17031==============================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--接收到邀请共乘
function RideManager:On17032(data)
    -- BaseUtils.dump(data,"协议回调17032==============================================================")

    local confirmData = confirmData or NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = string.format(TI18N("<color='#00ff00'>%s</color>邀请你共乘，是否接受？"), data.name)
    confirmData.sureLabel = TI18N("接受")
    confirmData.sureCallback = function() self:Send17034(1, data.id, data.platform, data.zone_id) end
    confirmData.cancelLabel = TI18N("拒绝")
    confirmData.cancelCallback = function() self:Send17034(0, data.id, data.platform, data.zone_id) end

    confirmData.cancelSecond = 30
    NoticeManager.Instance:ConfirmTips(confirmData)
end

--接受或者拒绝共乘邀请
function RideManager:On17033(data)
    if data.flag == 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#00ff00'>%s</color>拒绝了与你共乘"), data.name))
    end
end

--同意或拒绝共骑
function RideManager:Send17034(flag, rid, platform, zone_id)
    -- print("发送协议17034"..flag)
    local uniqueid = BaseUtils.get_unique_roleid(rid, zone_id, platform)
    if TeamManager.Instance:SomeOneStatus(uniqueid) == RoleEumn.TeamStatus.Offline then
        NoticeManager.Instance:FloatTipsByString(TI18N("对方已下线，无法共乘"))
    elseif TeamManager.Instance:SomeOneStatus(uniqueid) == RoleEumn.TeamStatus.Away then
        NoticeManager.Instance:FloatTipsByString(TI18N("对方已经暂离，无法共乘"))
    elseif TeamManager.Instance:SomeOneStatus(uniqueid) == RoleEumn.TeamStatus.None then
        NoticeManager.Instance:FloatTipsByString(TI18N("对方当前状态无法共乘"))
    else
        Connection.Instance:send(17034, {flag = flag, id = rid, platform = platform, zone_id = zone_id})
    end

    
end

function RideManager:On17034(data)
    -- BaseUtils.dump(data,"协议回调17034==============================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--接受或者拒绝共乘邀请
function RideManager:Send17035()
    -- print("发送协议17035--取消共乘")
    Connection.Instance:send(17035, {})
end

function RideManager:On17035(data)
    -- BaseUtils.dump(data,"协议回调17035==============================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
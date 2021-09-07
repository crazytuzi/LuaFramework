-- ----------------------------------------------------------
-- 逻辑模块 - 结缘
-- ----------------------------------------------------------
MarryManager = MarryManager or BaseClass(BaseManager)

function MarryManager:__init()
    if MarryManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	MarryManager.Instance = self

    self.model = MarryModel.New()
    self.cpTreasureModel = CpDigTreasureModel.New()

    self.loverData = nil

    self:InitHandler()
end

function MarryManager:__delete()
end

function MarryManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(15000, self.On15000)
    self:AddNetHandler(15001, self.On15001)
    self:AddNetHandler(15002, self.On15002)
    self:AddNetHandler(15003, self.On15003)
    self:AddNetHandler(15004, self.On15004)
    self:AddNetHandler(15005, self.On15005)
    self:AddNetHandler(15006, self.On15006)
    self:AddNetHandler(15007, self.On15007)
    self:AddNetHandler(15008, self.On15008)
    self:AddNetHandler(15009, self.On15009)
	self:AddNetHandler(15010, self.On15010)
	self:AddNetHandler(15011, self.On15011)
	self:AddNetHandler(15012, self.On15012)
	self:AddNetHandler(15013, self.On15013)
    self:AddNetHandler(15014, self.On15014)
	self:AddNetHandler(15015, self.On15015)
    self:AddNetHandler(15016, self.On15016)

    self:AddNetHandler(15020, self.On15020)
    self:AddNetHandler(15021, self.On15021)
    self:AddNetHandler(15022, self.On15022)
    self:AddNetHandler(15023, self.On15023)
    self:AddNetHandler(15024, self.On15024)
    self:AddNetHandler(15025, self.On15025)
    self:AddNetHandler(15026, self.On15026)
    self:AddNetHandler(15027, self.On15027)
    self:AddNetHandler(15028, self.On15028)
    self:AddNetHandler(15029, self.On15029)
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------

function MarryManager:Send15000(id, platform, zone_id, str)
	--print("Send15000")
    Connection.Instance:send(15000, { id = id, platform = platform, zone_id = zone_id, str = str })
end

function MarryManager:On15000(data)
	--print("On15000")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    -- self.model:On15000(data)
end

function MarryManager:On15001(data)
	--print("On15001")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.type == 1 then
    	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_bepropose_window, { data })
    else
    	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_propose_answer_window, { data })
    end
end

function MarryManager:Send15002(id, platform, zone_id, flag)
	--print("Send15002")
    Connection.Instance:send(15002, { id = id, platform = platform, zone_id = zone_id, flag = flag })
end

function MarryManager:On15002(data)
	--print("On15002")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
end

function MarryManager:Send15003()
	--print("Send15003")
    Connection.Instance:send(15003, { })
end

function MarryManager:On15003(data)
	--print("On15003")
	-- BaseUtils.dump(data, "On15003")
    self.model:On15003(data)
end

function MarryManager:Send15004(type, list, msg)
	--print("Send15004")
    Connection.Instance:send(15004, { type = type, list = list, msg = msg })
end

function MarryManager:On15004(data)
	--print("On15004")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_beinvite_window, { data })
end

function MarryManager:Send15005(type, list)
	--print("Send15005")
    Connection.Instance:send(15005, { type = type, list = list })
end

function MarryManager:On15005(data)
	--print("On15005")
	-- BaseUtils.dump(data)
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On15005(data)
    EventMgr.Instance:Fire(event_name.marry_data_update)
end

function MarryManager:Send15006(id, msg)
	--print("Send15006")
    Connection.Instance:send(15006, { id = id, msg = msg })
end

function MarryManager:On15006(data)
	--print("On15006")
    if data.flag == 1 then
        DanmakuManager.Instance.model:UpdatePanelText()
        DanmakuManager.Instance.model:ClosePanel()

        if MainUIManager.Instance.marryBarView then
	    	MainUIManager.Instance.marryBarView:PlayEffect(data.id)
        end
    end
end

function MarryManager:Send15007(type)
	--print("Send15007")
    Connection.Instance:send(15007, { type = type })
end

function MarryManager:On15007(data)
	--print("On15007")
	if data.type == 1 then
		self.model.action_times_list = {}
	end
	for _, value in pairs(data.list) do
		self.model.action_times_list[value.id] = value
	end

	EventMgr.Instance:Fire(event_name.marry_data_update)
end

function MarryManager:Send15008(type, fid, fplatform, zone_id)
	--print("Send15008")
    Connection.Instance:send(15008, { type = type, fid = fid, fplatform = fplatform, zone_id = zone_id })
end

function MarryManager:On15008(data)
	--print("On15008")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
    	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_invite_window)
    end
end

function MarryManager:Send15009()
	--print("Send15009")
    Connection.Instance:send(15009, { })

    self:Send15007(1)
end

function MarryManager:On15009(data)
	--print("On15009")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    self:RequestInitData()
end

function MarryManager:Send15010()
	--print("Send15010")
    Connection.Instance:send(15010, { })
end

function MarryManager:On15010(data)
	--print("On15010")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
end

function MarryManager:Send15011()
	--print("Send15011")
    Connection.Instance:send(15011, { })
end

function MarryManager:On15011(data)
	--print("On15011")
    self.model.atmosp = data.atmosp
    EventMgr.Instance:Fire(event_name.marry_data_update)
end

function MarryManager:Send15012()
	--print("Send15012")
    Connection.Instance:send(15012, { })
end

function MarryManager:On15012(data)
	-- print("On15012")
    if data.type == 0 then
    	self.model.act_logs = data.act_logs
    else
    	for _, value in pairs(data.act_logs) do
    		table.insert(self.model.act_logs, value)
    	end
    end
    EventMgr.Instance:Fire(event_name.marry_data_update)
end

function MarryManager:Send15013()
	--print("Send15013")
    Connection.Instance:send(15013, { })
end

function MarryManager:On15013(data)
	--print("On15013")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
end

function MarryManager:Send15014()
	--print("Send15014")
    Connection.Instance:send(15014, { })
end

function MarryManager:On15014(data)
	--print("On15014")
	self.loverData = data
	EventMgr.Instance:Fire(event_name.lover_data)
end

function MarryManager:Send15015()
	--print("Send15015")
    Connection.Instance:send(15015, { })
end

function MarryManager:On15015(data)
	--print("On15015")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
end

function MarryManager:On15016(data)
	--print("On15016")
	RoleManager.Instance.RoleData.lover_id = data.id
	RoleManager.Instance.RoleData.lover_platform = data.platform
	RoleManager.Instance.RoleData.lover_zone_id = data.zone_id
	RoleManager.Instance.RoleData.lover_name = data.name
	RoleManager.Instance.RoleData.wedding_status = data.status
    if self.loverData ~= nil then
        self.loverData.lover_id = data.id
        self.loverData.lover_platform = data.platform
        self.loverData.lover_zone_id = data.zone_id
        self.loverData.lover_name = data.name
        self.loverData.wedding_status = data.status
    end
end

function MarryManager:Send15020(type)
    -- print("Send15020")
    Connection.Instance:send(15020, { type = type })
end

function MarryManager:On15020(data)
    -- print("On15020")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function MarryManager:Send15021(type)
    -- print("Send15021")
    Connection.Instance:send(15021, { type = type })
end

function MarryManager:On15021(data)
    -- print("On15021")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = string.format(TI18N("<color='#ffff00'>%s</color>要和你解除结缘，是否同意？"), RoleManager.Instance.RoleData.lover_name)
    confirmData.sureLabel = TI18N("同意")
    confirmData.cancelLabel = TI18N("拒绝")
    confirmData.sureCallback = function() self:Send15021(1) end
    confirmData.cancelCallback = function() self:Send15021(0) end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function MarryManager:Send15022()
    -- print("Send15022")
    Connection.Instance:send(15022, { })
end

function MarryManager:On15022(data)
    -- print("On15022")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
end

function MarryManager:Send15023()
    -- print("Send15023")
    self.model.inside_List_Loading = true
    Connection.Instance:send(15023, { })
end

function MarryManager:On15023(data)
    -- print("On15023")
    self.model.inside_List_Loading = false
    self.model.inside_List = data.list
    EventMgr.Instance:Fire(event_name.lover_data)
end

function MarryManager:Send15024()
    -- print("Send15024")
    self.model.home_list = nil
    Connection.Instance:send(15024, { })
end

function MarryManager:On15024(data)
    -- print("On15024")
    self.model.home_list = data.family_info
    EventMgr.Instance:Fire(event_name.lover_data)
end

function MarryManager:Send15025()
    Connection.Instance:send(15025, { })
end

function MarryManager:On15025(data)
    self.model.wedding_package_list = data.list
    for k,v in pairs(DataWedding.data_wedding_package) do
        local mark = true
        for i=1, #self.model.wedding_package_list do
            if self.model.wedding_package_list[i].id == v.id then
                mark = false
                break
            end
        end
        if mark then
            table.insert(self.model.wedding_package_list, { id = v.id, times = 0 })
        end
    end
    table.sort(self.model.wedding_package_list, function(a,b) return a.id < b.id end)
    EventMgr.Instance:Fire(event_name.lover_data)
end

function MarryManager:Send15026(id)
    Connection.Instance:send(15026, { id = id })
end

function MarryManager:On15026(data)
    for k,v in pairs(self.model.wedding_package_list) do
        if data.id == v.id then
            v.times = data.times
        end
    end
    EventMgr.Instance:Fire(event_name.lover_data)
end

function MarryManager:Send15027()
    Connection.Instance:send(15027, { })
end

function MarryManager:On15027(data)
    -- BaseUtils.dump(data, "On15027")
    self.model.marry_honor_id = data.honor_id_now
    self.model.marry_honor_list = data.honor_list
    EventMgr.Instance:Fire(event_name.lover_data)
end

function MarryManager:Send15028(id)
    Connection.Instance:send(15028, { id = id})
end

function MarryManager:On15028(data)
    self.model.marry_honor_id = data.honor_id
    local mark = true
    for i=1,#self.model.marry_honor_list do
        if self.model.marry_honor_list[i].honor_id == data.honor_id then
            mark = false
            break
        end
    end
    table.insert(self.model.marry_honor_list, { honor_id = data.honor_id })
    EventMgr.Instance:Fire(event_name.lover_data)
end

function MarryManager:Send15029(id, platform, zone_id)
    Connection.Instance:send(15029, { id = id, platform = platform, zone_id = zone_id })
end

function MarryManager:On15029(data)
    self.model:OpenMarriageCertificateWindow({data})
end

function MarryManager:RequestInitData()
    self:Send15003()
    self:Send15005(0, {})
    self:Send15007(1)
    self:Send15011()
    self:Send15012()
    self:Send15014()
    self:Send15025()
end
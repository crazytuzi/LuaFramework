-- ----------------------------------------------------------
-- 逻辑模块 - 老玩家回归
-- ljh 20161119
-- ----------------------------------------------------------
RegressionManager = RegressionManager or BaseClass(BaseManager)

function RegressionManager:__init()
    if RegressionManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	RegressionManager.Instance = self

    self.model = RegressionModel.New()

    self.friendUpdate = EventLib.New()
    self.loginUpdate = EventLib.New()
    self.recruitUpdate = EventLib.New()
    self.luckDrawUpdate = EventLib.New()
    self.luckDrawRollNoticeUpdate = EventLib.New()

    self:InitHandler()
end

function RegressionManager:__delete()
	self.friendUpdate:DeleteMe()
    self.friendUpdate = nil
    self.loginUpdate:DeleteMe()
    self.loginUpdate = nil
    self.recruitUpdate:DeleteMe()
    self.recruitUpdate = nil
    self.luckDrawUpdate:DeleteMe()
    self.luckDrawUpdate = nil
    self.luckDrawRollNoticeUpdate:DeleteMe()
    self.luckDrawRollNoticeUpdate = nil
end

function RegressionManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(11878, self.On11878)
    self:AddNetHandler(11879, self.On11879)
    self:AddNetHandler(11880, self.On11880)
    self:AddNetHandler(11881, self.On11881)
    self:AddNetHandler(11882, self.On11882)
    self:AddNetHandler(11883, self.On11883)
    self:AddNetHandler(11884, self.On11884)
    self:AddNetHandler(11885, self.On11885)
    self:AddNetHandler(11886, self.On11886)
    self:AddNetHandler(11887, self.On11887)
    -- self:AddNetHandler(11888, self.On11888)
    -- self:AddNetHandler(11889, self.On11889)

    self:AddNetHandler(9938, self.On9938)
    self:AddNetHandler(9939, self.On9939)
    self:AddNetHandler(9940, self.On9940)
    self:AddNetHandler(9941, self.On9941)
    self:AddNetHandler(9942, self.On9942)
    self:AddNetHandler(9943, self.On9943)
    self:AddNetHandler(9944, self.On9944)
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------

function RegressionManager:Send11878(rid, platform, zone_id, pos)
    Connection.Instance:send(11878, { rid = rid, platform = platform, zone_id = zone_id, pos = pos })
end

function RegressionManager:On11878(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function RegressionManager:Send11879()
    Connection.Instance:send(11879, {  })
end

function RegressionManager:On11879(data)
	-- print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")
	-- BaseUtils.dump(data, "11879")
	self.model.id = data.id
	self.model.friendList = {}
    if data.lists == nil then
        return
    end
	self.model.friendTimes = 3 - #data.lists
	for i=1, #data.lists do
		self.model.friendList[i] = data.lists[i]
	end
	self.friendUpdate:Fire()

	self.model.recruit_rewards = {}
	for i=1, #data.rewards do
		self.model.recruit_rewards[data.rewards[i].id] = true
	end
	self.model.role_name_bind = data.role_name_bind
	self.model.role_id_bind = data.role_id
	self.model.platform_bind = data.platform
	self.model.zone_id_bind = data.zone_id

	self.recruitUpdate:Fire()
	-- BaseUtils.dump(data, "On11879")
	if self.model.activite_bind == nil and self.model.role_name_bind ~= "" then
		self:Send11885(self.model.role_id_bind, self.model.platform_bind, self.model.zone_id_bind)
	end

	if self.model.activite_bind ~= nil then
		BibleManager.Instance.redPointDic[1][19] = self.model:CheckRedPointRecruit()
		BibleManager.Instance:CheckMainUIIconRedPoint()
		BibleManager.Instance.onUpdateRedPoint:Fire()
	end
end

function RegressionManager:Send11880(rid)
    Connection.Instance:send(11880, { rid = rid })
end

function RegressionManager:On11880(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function RegressionManager:Send11881()
    Connection.Instance:send(11881, {  })
end

function RegressionManager:On11881(data)
	self.model.status = data.status
	self.model.time_return = data.time_return
	self.model.berecruit_rewards = {}
	for i=1, #data.rewards do
		self.model.berecruit_rewards[data.rewards[i].id] = true
	end

	-- self.model.logins = {}
	-- for i=1, #data.logins do
	-- 	self.model.logins[data.logins[i].day] = data.logins[i].flag
	-- end
	-- self.model.flag = data.flag

	-- self.model.limits = {}
	-- for i=1, #data.limits do
	-- 	self.model.limits[data.limits[i].day] = data.limits[i].flag
	-- end

	self.model.role_name_recall = data.role_name_recall
	self.model.role_id_recall = data.role_id
	self.model.platform_recall = data.platform
	self.model.zone_id_recall = data.zone_id

	self.recruitUpdate:Fire()

	-- print("?")print("?")print("?")print("?")print("?")print("?")print("?")print("?")print("?")print("?")print("?")print("?")print("?")print("?")
	-- BaseUtils.dump(data, "On11881")

	if self.model.activite_recall == nil then
		local roleData = RoleManager.Instance.RoleData
		self:Send11885(roleData.id, roleData.platform, roleData.zone_id)

		if self.model.role_name_recall ~= "" then
			self:Send11885(self.model.role_id_recall, self.model.platform_recall, self.model.zone_id_recall)
		end
	end

	self:ShowIcon(self.model.status == 1 or self.model.login_status == 1)
	if MainUIManager.Instance.MainUIIconView ~= nil then
		MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(320, self.model:CheckRedPointBerecruit() or self.model:CheckRedPointLogin())
	end
end

function RegressionManager:Send11882(id)
    Connection.Instance:send(11882, { id = id })
end

function RegressionManager:On11882(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function RegressionManager:Send11883()
    Connection.Instance:send(11883, {  })
end

function RegressionManager:On11883(data)

end

function RegressionManager:Send11884(id)
    Connection.Instance:send(11884, { id = id })
end

function RegressionManager:On11884(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function RegressionManager:Send9938()
    Connection.Instance:send(9938, { })
end

function RegressionManager:On9938(data)
	self.model.login_status = data.flag
	self.model.login_time_return = data.time_return

	self.model.logins = {}
	self.model.loginsTime = {}
	for i=1, #data.rewards do
		self.model.logins[data.rewards[i].day] = data.rewards[i].status
		self.model.loginsTime[data.rewards[i].day] = data.rewards[i].time
	end
	self.model.flag = data.reward_all

	self.model.limits = {}
	for i=1, #data.rewards do
		self.model.limits[data.rewards[i].day] = data.rewards[i].status
	end

	self.loginUpdate:Fire()

	-- BaseUtils.dump(data, "On9938")

	self:ShowIcon(self.model.status == 1 or self.model.login_status == 1)
	if MainUIManager.Instance.MainUIIconView ~= nil then
		MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(320, self.model:CheckRedPointBerecruit() or self.model:CheckRedPointLogin())
	end
end

function RegressionManager:Send9939(day)
    Connection.Instance:send(9939, { day = day })
end

function RegressionManager:On9939(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
	if data.flag == 1 then
		self.model.logins[data.day] = 2
		self.loginUpdate:Fire()
		if MainUIManager.Instance.MainUIIconView ~= nil then
			MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(320, self.model:CheckRedPointBerecruit() or self.model:CheckRedPointLogin())
		end
	end
end

function RegressionManager:Send9940()
    -- print("Send9940")
    Connection.Instance:send(9940, {  })
end

function RegressionManager:On9940(data)
	-- print("On9940")
	NoticeManager.Instance:FloatTipsByString(data.msg)

	self.model.luck_draw_id = data.reward_id

	self.luckDrawUpdate:Fire(self.model.luck_draw_id)
end

function RegressionManager:Send9941()
	-- print("Send9941")
    Connection.Instance:send(9941, {  })
end

function RegressionManager:On9941(data)
	-- print("On9941")
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function RegressionManager:Send9942(day)
    Connection.Instance:send(9942, { day = day })
end

function RegressionManager:On9942(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
	if data.flag == 1 then
		self.model.limits[data.day] = 2
		self.loginUpdate:Fire()
	end
end

function RegressionManager:Send11885(role_id, platform, zone_id)
	-- print("Send11889")
	-- print(string.format("%s %s %s", role_id, platform, zone_id))
    Connection.Instance:send(11885, { role_id = role_id, platform = platform, zone_id = zone_id })
end

function RegressionManager:On11885(data)
	local roleData = RoleManager.Instance.RoleData
	-- print("!")print("!")print("!")print("!")print("!")print("!")print("!")
	-- BaseUtils.dump(data, "On11885")
	-- print(string.format("%s %s %s", self.model.role_id_bind, self.model.platform_bind, self.model.zone_id_bind))
	-- print(string.format("%s %s %s", self.model.role_id_recall, self.model.platform_recall, self.model.zone_id_recall))
	-- print(string.format("%s %s %s", roleData.id, roleData.platform, roleData.zone_id))
	if data.role_id == self.model.role_id_bind and data.platform == self.model.platform_bind and data.zone_id == self.model.zone_id_bind then
		self.model.activite_bind = data.activite
		self.model.time_return_bind = data.time_return
		self.recruitUpdate:Fire()
		BibleManager.Instance.redPointDic[1][19] = self.model:CheckRedPointRecruit()
		BibleManager.Instance:CheckMainUIIconRedPoint()
		BibleManager.Instance.onUpdateRedPoint:Fire()
	elseif data.role_id == self.model.role_id_recall and data.platform == self.model.platform_recall and data.zone_id == self.model.zone_id_recall then
		self.model.time_return_recall = data.time_return
	elseif data.role_id == roleData.id and data.platform == roleData.platform and data.zone_id == roleData.zone_id then
		self.model.activite_recall = data.activite
		self.loginUpdate:Fire()
		if MainUIManager.Instance.MainUIIconView ~= nil then
			MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(320, self.model:CheckRedPointBerecruit() or self.model:CheckRedPointLogin())
		end
	end
end

function RegressionManager:Send11886()
    Connection.Instance:send(11886, { })
end

function RegressionManager:On11886(data)
	-- BaseUtils.dump(data, "On11886")
	self.model.buffs = data.buffs
end

function RegressionManager:Send11887()
    Connection.Instance:send(11887, { })
end

function RegressionManager:On11887(data)
	self.model.friendTimes = data.times
	self.friendUpdate:Fire()
end

function RegressionManager:Send9943()
	-- print("Send9943")
    Connection.Instance:send(9943, { })
end

function RegressionManager:On9943(data)
	-- print("On9943")
    if self.model.rainbow_notice_list == nil then
    	self.model.rainbow_notice_list = {}
    end
    self.model.rainbow_notice_list[#self.model.rainbow_notice_list+1] = { msg = data.msg }

    self.luckDrawRollNoticeUpdate:Fire(false)
end

function RegressionManager:Send9944()
	-- print("Send9944")
    Connection.Instance:send(9944, { })
end

function RegressionManager:On9944(data)
	-- BaseUtils.dump(data, "On9944")
    self.model.rainbow_notice_list = data.pmd_list

    self.luckDrawRollNoticeUpdate:Fire(true)
end
-------------------------------------------
-------------------------------------------
------------- 逻辑处理 -----------------
-------------------------------------------
-------------------------------------------

function RegressionManager:RequestInitData()
	self:Send9938()
    self:Send11879()
    self:Send11881()
    self:Send11886()
end

function RegressionManager:Clear()
    self.model:Clear()
end

--图标
function RegressionManager:ShowIcon(show)
	-- show = true
	if show then
	    MainUIManager.Instance:DelAtiveIcon3(320)

	    self.activeIconData = AtiveIconData.New()
	    local iconData = DataSystem.data_daily_icon[320]
	    self.activeIconData.id = iconData.id
	    self.activeIconData.iconPath = iconData.res_name
	    self.activeIconData.sort = iconData.sort
	    self.activeIconData.lev = iconData.lev
	    self.activeIconData.clickCallBack = function()
	        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.regression_window, { 1, 1 })
	    end
	    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
	else
		MainUIManager.Instance:DelAtiveIcon3(320)
	end
end

function RegressionManager:CreatEffect(effectId, parentTransform, localScale, localPosition, localRotation, callback)
	local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(parentTransform)
        effectObject.name = "Effect"
        effectObject.transform.localScale = localScale
        effectObject.transform.localPosition = localPosition
        effectObject.transform.localRotation = localRotation

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

        if callback ~= nil then
        	callback()
        end
    end
    return BaseEffectView.New({effectId = effectId, callback = fun})
end
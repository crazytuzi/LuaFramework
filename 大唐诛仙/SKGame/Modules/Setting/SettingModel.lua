SettingModel = BaseClass(LuaModel)

SettingModel.HP_VALUES={0.3, 0.5, 0.8}
SettingModel.MP_VALUES={0.3, 0.5, 0.8}

function SettingModel:__init()
	self.openType = StgConst.PANELTYPE.setting -- 预打开面板类型

	self.keys = {} -- 所有key值
	self.loginModel = LoginModel:GetInstance() -- 登录数据单例
	self.loginCtrl = LoginController:GetInstance()

	self:Config()
	self:InitEvent()
end

function SettingModel:GetInstance()
	if SettingModel.inst == nil then
		SettingModel.inst = SettingModel.New()
	end
	return SettingModel.inst
end

function SettingModel:Config()
	self.roleId = self.loginModel:GetLoginRole().playerId
	self.hpKey = self.roleId.."Setting_hpKey"
	self.mpKey = self.roleId.."Setting_mpKey"
	self.musicKey = self.roleId.."Setting_musicKey"
	self.yxKey = self.roleId.."Setting_YXKey"
	-- self.talkKey = self.roleId.."Setting_talkKey"
	self.messageKey = self.roleId.."Setting_messageKey"
	self.friendKey = self.roleId.."Setting_friendKey"
	self.bloodKey = self.roleId.."Setting_bloodKey"
	self.nameKey = self.roleId.."Setting_nameKey"
	self.mapKey = self.roleId.."Setting_mapKey"
	self.autoHpKey = self.roleId.."Setting_autoHpKey"
	self.autoMpKey = self.roleId.."Setting_autoMpKey"
	self.roleId = nil -- 当前玩家ID

	local state = self:GetCtrl(0)+1
	self.hpState = SettingModel.HP_VALUES[state] or SettingModel.HP_VALUES[2]

	state = self:GetCtrl(1)+1
	self.mpState = SettingModel.HP_VALUES[state] or SettingModel.MP_VALUES[2]
end

function SettingModel:InitEvent()
	self.handler = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED, function ()
		self:InitData()
	end)
end

function SettingModel:InitData()
	self.head = HeadUIMgr:GetInstance() -- 头部显示
	self.mainUI = MainUIController:GetInstance()
	
	local state = DataMgr.ReadData(self.hpKey, 1)
	if state ~= nil then
		self:SetBarState( state, 0 )
	end

	state = DataMgr.ReadData(self.mpKey, 1)
	if state ~= nil then
		self:SetBarState( state, 1 )
	end
	
	local volume = DataMgr.ReadData(self.musicKey, 0)==0 and 1 or 0
	soundMgr:SetBgVolume(volume)
	volume = DataMgr.ReadData(self.yxKey, 0)==0 and 1 or 0
	soundMgr:SetEffVolume(volume)

	self.keys = {
		self.musicKey, 
		self.yxKey,
		self.messageKey,
		self.friendKey,
		self.bloodKey,
		self.nameKey,
		self.mapKey,

	}

	GlobalDispatcher:RemoveEventListener(self.handler)

	self:DispatchEvent(StgConst.DATA_INITED)
end

-- 更改自动喝药
function SettingModel:SetBarState( state, type )
	if type == 0 then -- hp
		self.hpState = SettingModel.HP_VALUES[state + 1]
	elseif type == 1 then-- mp
		self.mpState = SettingModel.MP_VALUES[state + 1]
	end 
	self:SetCtrl( type, state )
end

-- 点击操作
function SettingModel:SetCB( type, selected )
	local writeValue = nil
	local value = nil

	if selected then
		value = 1 
		writeValue = 0 -- close
	else
		value = 0
		writeValue = 1 -- open
	end

	if type == StgConst.KeyType.Music then -- 设置音乐
		soundMgr:SetBgVolume(value)
	elseif type == StgConst.KeyType.Effect then -- 设置音效
		soundMgr:SetEffVolume(value)
	elseif type == StgConst.KeyType.AcceptChat then -- 设置陌生人消息
		SettingCtrl:GetInstance():C_SetIsAcceptChat(value)
	elseif type == StgConst.KeyType.AcceptApply then -- 设置好友申请
		SettingCtrl:GetInstance():C_SetIsAcceptApply(value)
	elseif type == StgConst.KeyType.ShowBar then -- 设置血条
		HeadUIMgr:GetInstance():SetShowBar(selected)
	elseif type == StgConst.KeyType.ShowName then -- 设置名字
		HeadUIMgr:GetInstance():SetShowName(selected)
	elseif type == StgConst.KeyType.MiniMap then -- 设置小地图
		value = 1
	elseif type == StgConst.KeyType.AutoHp then -- 自动喝血
		
	elseif type == StgConst.KeyType.AutoMp then -- 自动喝魔
		
	end

	-- 储存数据
	DataMgr.WriteData(self.keys[type+1], writeValue)
end

-- 提取CB数据
function SettingModel:GetCB( type )
	return DataMgr.ReadData(self.keys[type+1], 0)
end

-- 设置Ctrl数据
function SettingModel:SetCtrl( type, state )
	if type == 0 then
		DataMgr.WriteData(self.hpKey, state)
	else
		DataMgr.WriteData(self.mpKey, state)
	end

	self:DispatchEvent(StgConst.DATA_CHANGED, type, SettingModel.MP_VALUES[state+1])
end

-- 提取Ctrl数据
function SettingModel:GetCtrl( type )
	if type == 0 then -- hp
		return DataMgr.ReadData(self.hpKey, 1)
	else -- mp
		return DataMgr.ReadData(self.mpKey, 1)
	end
end

function SettingModel:GetBool( type )
	local value = DataMgr.ReadData(self.keys[type+1], 0)
	return value == 0
end

-- 社交
function SettingModel:SetComuState( messageState, friendState )
	local value = 1
	self.messageState = messageState or 1
	if messageState == 0 then
		value = 1
	else
		value = 0
	end
	DataMgr.WriteData(self.keys[3], value)

	self.friendState = friendState or 1
	if friendState == 0 then
		value = 1
	else
		value = 0
	end
	DataMgr.WriteData(self.keys[4], value)
end

function SettingModel:GetComuState( type ) -- 获取社交勾选情况
	if type == 1 then -- 陌生人信息
		return self.messageState == 1
	elseif type == 2 then
		return self.friendState == 1
	end
end

-- 确认退出游戏
function SettingModel:EscCon()
	self.loginCtrl:UserExitGame()
end

function SettingModel:__delete()
	SettingModel.inst = nil
	self.loginModel = nil
	self.loginCtrl = nil
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
	end
	self.items = nil

	if self.equipInfos then
		for i,v in ipairs(self.equipInfos) do
			v:Destroy()
		end
	end
	self.equipInfos = nil
	self.keys = nil
end
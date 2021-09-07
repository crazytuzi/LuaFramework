-- ----------------------------------------------------------
-- 逻辑模块 - 红包
-- ----------------------------------------------------------

RedBagManager = RedBagManager or BaseClass(BaseManager)

function RedBagManager:__init()
    if RedBagManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    RedBagManager.Instance = self;
    self:InitHandler()

    self.model = RedBagModel.New()

    self.OnUpdateRedBag = EventLib.New()
end

function RedBagManager:__delete()
    self.model:DeleteMe()
    self.model = nil

    self.OnUpdateRedBag:DeleteMe()
    self.OnUpdateRedBag = nil
end

function RedBagManager:InitHandler()
    self:AddNetHandler(18500, self.On18500)
    self:AddNetHandler(18501, self.On18501)
    self:AddNetHandler(18502, self.On18502)
    self:AddNetHandler(18503, self.On18503)
    self:AddNetHandler(18504, self.On18504)
    self:AddNetHandler(18505, self.On18505)
    self:AddNetHandler(18506, self.On18506)
end

function RedBagManager:RequestInitData()
    self.model.current_red_bag = nil

    self.model.red_packet = {}
    self.model.is_over = true

    self:Send18500()
end

------------------------协议接收逻辑
function RedBagManager:Send18500()
	-- print("Send18500")
	Connection.Instance:send(18500, { })
end

function RedBagManager:On18500(data)
	-- print("On18500")
	-- BaseUtils.dump(data)
	self.model.red_packet = data.red_packet_list
	self.model.is_over = data.is_over

	self.OnUpdateRedBag:Fire()
end

function RedBagManager:Send18501()
	Connection.Instance:send(18502, { })
end

function RedBagManager:On18501(data)
	local in_red_packet = false
	for i=1, #self.model.red_packet do
		local redBagData = self.model.red_packet[i]
		if redBagData.rid == data.rid and redBagData.zone_id == data.zone_id and redBagData.platform == data.platform then
			self.model.red_packet[i] = data
			in_red_packet = true
			break
		end
	end
	if not in_red_packet then
		table.insert(self.model.red_packet, data)
	end

	local title = data.title
	if data.type == 2 then
		title = string.format(TI18N("口令：%s"), data.title)
	end

    -- 收到红包广播，丢到聊天里面
    local msgData = MessageParser.GetMsgData(title)
    local chatData = ChatData.New()
    chatData.rid = data.rid
    chatData.platform = data.platform -- 平台
    chatData.zone_id = data.zone_id -- 区号
    chatData.name = data.name -- 名字
    chatData.sex = data.sex -- 性别
    chatData.classes = data.classes -- 职业
    chatData.lev = data.lev
    chatData.msg = title -- 内容
    chatData.showType = MsgEumn.ChatShowType.Redpack
    chatData.msgData = msgData
    chatData.prefix = MsgEumn.ChatChannel.World
    chatData.channel = MsgEumn.ChatChannel.World
    ChatManager.Instance.model:ShowMsg(chatData)
end

function RedBagManager:Send18502(type, lev, count, title)
	Connection.Instance:send(18502, { type = type, lev = lev, count = count, title = title })
end

function RedBagManager:On18502(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
	if data.flag == 1 then
		self.model:CloseRedBagSetUI()
	end
end

function RedBagManager:Send18503(rid, platform, zone_id)
	Connection.Instance:send(18503, { rid = rid, platform = platform, zone_id = zone_id })
end

function RedBagManager:On18503(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)

    -- local s_uniqueid = BaseUtils.get_unique_roleid(data.s_id, data.s_zone_id, data.s_platform)
    -- local t_uniqueid = BaseUtils.get_unique_roleid(data.t_id, data.t_zone_id, data.t_platform)
    -- local str = ""
    -- if s_uniqueid == t_uniqueid then
    --     -- 自己操作自己
    --     -- 如果自己是发送者，显示别人领取自己的红包的情况
    --     str = TI18N("自己领取了自己的红包")
    -- else
    --     if t_uniqueid == BaseUtils.get_self_id() then
    --         str = string.format(TI18N("{role_2,%s}领取了你的红包"), data.s_name)
    --     else
    --         -- 如果不是自己发的，显示自己领取了了谁的红包
    --         str = string.format(TI18N("你领取了{role_2,%s}的红包"), data.t_name)
    --     end
    -- end
    -- local msgData = MessageParser.GetMsgData(str)
    -- local chatData = ChatData.New()
    -- chatData.rid = data.t_id
    -- chatData.platform = data.t_platform -- 平台
    -- chatData.zone_id = data.t_zone_id -- 区号
    -- chatData.name = data.t_name -- 名字
    -- chatData.msg = msgData.showString
    -- chatData.showType = MsgEumn.ChatShowType.RedpackNotice
    -- chatData.msgData = msgData
    -- chatData.prefix = MsgEumn.ChatChannel.World
    -- chatData.channel = MsgEumn.ChatChannel.World
    -- ChatManager.Instance.model:ShowMsg(chatData)

	self:Send18500()
end

function RedBagManager:Send18504(unit_id)
	Connection.Instance:send(18504, { unit_id = unit_id })
end

function RedBagManager:On18504(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function RedBagManager:Send18505(rid, platform, zone_id)
	-- print("Send18505")
	Connection.Instance:send(18505, { rid = rid, platform = platform, zone_id = zone_id })
end

function RedBagManager:On18505(data)
	-- print("On18505")
	-- BaseUtils.dump(data)
	RedBagManager.Instance.model.current_red_bag = data

	local hasGet = false
	local roleData = RoleManager.Instance.RoleData
	for i=1, #data.log do
	    local log = data.log[i]
	    if log.grabid == roleData.id and log.gplatform == roleData.platform and log.gzone_id == roleData.zone_id then
	        hasGet = true
	    end
	end
	if hasGet then
	    self.model:InitRedBagUI()
	else
		if data.num > 0 then
	        --未领取
	        if data.type == 2 then
                -- ChatManager.Instance.model.chatWindow:ChangeChannel(1)
                -- ChatManager.Instance.model.chatWindow.inputFieldText.text = data.title
                -- RedBagManager.Instance.model:CloseRedBagListUI()
                RedBagManager.Instance.model:InitRedBagInputUI()
            else
            	self.model:InitUnRedBagUI()
            end
	    else
	        --已经被领完
	        self.model:InitRedBagUI()
	    end
	end
end

--通知领取红包
function RedBagManager:On18506(data)
    local str = string.format(TI18N("{role_2,%s}领取了你的红包"), data.name)
    local msgData = MessageParser.GetMsgData(str)
    local chatData = ChatData.New()
    chatData.rid = data.grabid
    chatData.platform = data.gplatform -- 平台
    chatData.zone_id = data.gzone_id -- 区号
    chatData.name = data.name -- 名字
    chatData.msg = msgData.showString
    chatData.showType = MsgEumn.ChatShowType.RedpackNotice
    chatData.msgData = msgData
    chatData.prefix = MsgEumn.ChatChannel.System
    chatData.channel = MsgEumn.ChatChannel.World
    ChatManager.Instance.model:ShowMsg(chatData)
end

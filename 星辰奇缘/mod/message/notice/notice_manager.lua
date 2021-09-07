-- ----------------------------------
-- 消息提示管理
-- hosr
-- ----------------------------------
NoticeManager = NoticeManager or BaseClass(BaseManager)

function NoticeManager:__init()
    if NoticeManager.Instance then
        return
    end
    NoticeManager.Instance = self

    self.model = NoticeModel.New()
    self.dispatcher = MsgDispatcher.New()

    self:InitHandler()
    self.IsPreloaded = false
    self.hideConfirmTips = true
    self.isMatchNotice = false

    self.activeConfirmTips_TimerId = nil
end

function NoticeManager:__delete()
end

function NoticeManager:OnTick()
    self.model:OnTick()
end

function NoticeManager:InitHandler()
    self:AddNetHandler(9902, self.On9902)
    self:AddNetHandler(9903, self.On9903)
    self:AddNetHandler(9905, self.On9905)
    self:AddNetHandler(9910, self.On9910)
    self:AddNetHandler(9911, self.On9911)
    self:AddNetHandler(9928, self.On9928)
end

function NoticeManager:PreLoad()
    if not self.IsPreloaded then
        self.model:PreLoad()
        self.IsPreloaded = true
    end
end

function NoticeManager:RequestInitData()
end

--给玩家发送操作反馈
function NoticeManager:On9902(dat)
    -- BaseUtils.dump(dat, "9902")
    self.dispatcher:Dispatch(dat)
end

--给玩家弹出确认框
function NoticeManager:On9903(dat)
    -- BaseUtils.dump(dat, "9903")
    if dat.type == 80 then      -- 防沉迷时间
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = dat.msg
        data.sureLabel = TI18N("前往认证")
        data.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, 20}) end
        -- data.cancelLabel = "取消"
        -- data.sureCallback = self.createTeam
        -- data.cancelCallback = self.sureMatch
        NoticeManager.Instance:ConfirmTips(data)
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = dat.msg
        data.sureLabel = TI18N("确定")
        -- data.cancelLabel = "取消"
        -- data.sureCallback = self.createTeam
        -- data.cancelCallback = self.sureMatch
        NoticeManager.Instance:ConfirmTips(data)
    end
end

--推送物品到存储空间效果
function NoticeManager:On9905(dat)
end

-- npc 对话框
function NoticeManager:On9910(dat)
    local baseId = dat.base_id
    local msg = dat.msg

    local npcBase = BaseUtils.copytab(DataUnit.data_unit[baseId])
    if npcBase ~= nil then
        npcBase.buttons = {}
        if msg ~= nil and msg ~= "" then
            npcBase.plot_talk = msg
        end
        local npcData = {}
        npcData.baseid = baseId
        npcData.id = 0
        npcData.battle_id = 1
        npcData.classes = npcBase.classes
        npcData.sex = npcBase.sex
        npcData.looks = npcBase.looks
        MainUIManager.Instance:OpenDialog(npcData, {base = npcBase}, true)
    end
end

-- -------------------------------------------------------
-- 外部调用消息提示接口
-- -------------------------------------------------------

-- 普通上浮提示
function NoticeManager:FloatTipsByString(content)
    if content ~= nil and content ~= "" then
        self.model:FloatTipsByString(content)
    end
end

-- 确认框
function NoticeManager:ConfirmTips(confirmData)
    self.isMatchNotice = false
    self.model:ConfirmTips(confirmData)
end

function NoticeManager:CloseConfrimTips()
    self.isMatchNotice = false
    self.model:CloseConfrimTips()
end

-- 确认框(带物品消耗)
function NoticeManager:ConfirmCostTips(confirmData)
    self.isMatchNotice = false
    self.model:ConfirmCostTips(confirmData)
end

function NoticeManager:CloseConfrimCostTips()
    self.isMatchNotice = false
    self.model:CloseConfrimCostTips()
end

-- 断线重连确认框
function NoticeManager:ConnectionConfirmTips(confirmData)
    self.isMatchNotice = false
    self.model:ConnectionConfirmTips(confirmData)
end

-- 活动确认框
function NoticeManager:ActiveConfirmTips(confirmData, activity)
    self.isMatchNotice = false
    math.randomseed((RoleManager.Instance.RoleData.exp + 1) * (RoleManager.Instance.RoleData.id  + 1)* BaseUtils.BASE_TIME)
    local time = math.floor(math.random() * 10000)

    if activity == nil then
        self.activeConfirmTips_TimerId = LuaTimer.Add(time, function() self.model:ConfirmTips(confirmData) end)
    else
        if ActivityManager.Instance.model.notice_timer[activity] ~= nil then
            LuaTimer.Delete(ActivityManager.Instance.model.notice_timer[activity])
        end
        ActivityManager.Instance.model.notice_timer[activity] = LuaTimer.Add(time, function()
            self.model:ConfirmTips(confirmData)
            ActivityManager.Instance.model.notice_timer[activity] = nil
        end)
    end
end

function NoticeManager:CleanActiveConfirmTips()
    self.isMatchNotice = false
    if self.activeConfirmTips_TimerId ~= nil then
        LuaTimer.Delete(self.activeConfirmTips_TimerId)
    end
    for _,timer in pairs(ActivityManager.Instance.model.notice_timer) do
        LuaTimer.Delete(timer)
    end
    ActivityManager.Instance.model.notice_timer = {}
end

-- 文字上浮
function NoticeManager:FloatTxt(str)
    self.model:FloatTxt(str)
end

function NoticeManager:Test()
    self:Loop()
    -- self:ChatTest()
    -- LuaTimer.Add(0, 50, function() self:ChatTest() end)
    -- LuaTimer.Add(0, 50, function() self:Loop() end)
    -- self:FloatTest()
end

function NoticeManager:Loop()
    local val = math.random(1,200)
    local assetId = math.random(1,5)
    local faceId = math.random(1,40)
    local msg = string.format(I18N("点点{face_1,%s}滴滴{assets_1,%s,%s}哈哈{face_1,%s}磨刀嚯嚯向欧阳{assets_1,%s,%s}"), faceId, assetId + 90009, val, faceId, assetId + 90009, val)
    if val <= 100 then
        msg = I18N("纯文字啦啦啦啦啦是的分手的理解开发的")
    elseif val > 100 and val <= 150 then
        msg = string.format(I18N("点点滴滴哈哈{face_1,%s}磨刀嚯嚯向欧阳{assets_1,%s,%s}"), faceId, assetId + 90009, val)
    end
    local dat = {type = 3, msg = msg}
    self.dispatcher:Dispatch(dat)
end

function NoticeManager:FlostTxtTest()
    LuaTimer.Add(0, 1000, function() self:FloatTxt(I18N("人品+100")) end)
end

function NoticeManager:ChatTest()
    local val = math.random(1,200)
    local assetId = math.random(1,5)
    local faceId = math.random(1,40)
    -- local msg = "<color='#F5F70E'>攻法修炼</color>技能增加{assets_1,90010,300}（低于世界等级额外获得30%加成）"
    -- local msg = "点点滴滴哈哈{assets_1,90015,2}磨刀嚯嚯向欧阳啊啊啊{assets_1,90012,107}换了{assets_1,90010,1111}\n{assets_1,90010,1}换了吗{assets_1,90012,22222}\n换了没{assets_1,90013,333}啦啦啦啊拉拉啊啊啊\n啊好了{assets_1,90014,44}"
    -- local msg = "点点<color='#ffff00'>滴滴</color>哈哈啊{face_1,33}啊{face_1,34}哦{string_2,#ffff00,字符内容123}额{face_1,16}饿{face_1,41}喔{face_1,7}奥{face_1,48}啊假的假的假的假的"
    -- if val <= 100 then
    --     msg = "纯文字啦啦啦啦啦\n是的分手的理解开发的\n换换换哈哈哈哈哈哈哈哈哈哈哈哈会"
    -- end
    -- msg = "通关<color='#00ff00'>[极寒试炼·困难]</color>获得的馈赠，开启可获得随机额度{assets_2,90000}奖励，最高可得到<color='#ffff00'>1000000</color>{assets_2,90000}"
    -- msg = TI18N("通关<color='#00ff00'>[极寒试炼·困难]</color>{assets_2,90000}")
    -- msg = "通关获得的馈赠，开启可获得随机额度{assets_2,90000}奖励，最高可得到<color='#ffff00'>1000000</color>{assets_2,90000}"
    msg = "获得了{item_2,20001,1,3}啊恭喜"
    local msgData = MessageParser.GetMsgData(msg)
    local chatData = ChatData.New()
    -- chatData:Update(RoleManager.Instance.RoleData)
    chatData.showType = MsgEumn.ChatShowType.System
    chatData.msgData = msgData
    chatData.prefix = MsgEumn.ChatChannel.Hearsay
    chatData.channel = MsgEumn.ChatChannel.System
    ChatManager.Instance.model:ShowMsg(chatData)
end

function NoticeManager:FaceTest()
    local val = math.random(1,200)
    local assetId = math.random(1,5)
    local faceId = math.random(1,40)
    local msg = string.format(I18N("点点滴滴哈哈{face_1,%s}尼玛的欧阳{assets_1,%s,%s}"), faceId, assetId + 90009, val)
    local msgData = MessageParser.GetMsgData(msg)
    local chatData = ChatData.New()
    chatData:Update(RoleManager.Instance.RoleData)
    chatData.msgData = msgData
    chatData.channel = MsgEumn.ChatChannel.Scene
    chatData.showType = MsgEumn.ChatShowType.System
    chatData.prefix = MsgEumn.ChatChannel.Hearsay
    ChatManager.Instance.model:ShowMsg(chatData)
    -- local dat = {type = 3, msg = "哈哈{face_1,1}尼玛的欧阳"}
    -- self.dispatcher:Dispatch(dat)
end

function NoticeManager:FloatTest()
    for i = 1,8 do
        self.model:FloatTipsByString("测试"..i)
    end
end

function NoticeManager:Test1()
    local role = RoleManager.Instance.RoleData
    local dat = {}
    dat.channel = MsgEumn.ChatChannel.World
    dat.rid = role.id
    dat.platform = role.platform
    dat.zone_id = role.zone_id
    dat.name = role.name
    dat.sex = role.sex
    dat.classes = role.classes
    dat.lev = role.lev
    dat.msg = self.result[math.random(1, 4)]
    dat.guild_name = ""
    dat.special = {}
    ChatManager.Instance:On10400(dat)
end

-- 快速使用提示
function NoticeManager:AutoUse(data)
    if BaseUtils.IsVerify then 
        return 
    end
    self.model.autoUse:Append(data)
end
-- 公会宣读 公会种花、同心宝藏
function NoticeManager:GuildPublicity(data)
    if BaseUtils.IsVerify then 
        return 
    end
    self.model.guildPublicity:Append(data)
end
-- 隐藏公会宣读
function NoticeManager:HideGuildPublicity()
    self.model.guildPublicity:Hiden()
end

function NoticeManager:HideAutoUse()
    self.model.autoUse:Hiden()
end

function NoticeManager:ShowAutoUse()
    if BaseUtils.IsVerify then 
        return 
    end
    self.model.autoUse:ReOpen()
end

--飞物品图标
function NoticeManager:FlyItemIcon(baseId, startPosition, endPosition, time, callBack)
    self.model:FlyItemIcon(baseId, startPosition, endPosition, time, callBack)
end

-- 飞gameObject
function NoticeManager:FlyGameObject(gameObject, startPosition, endPosition, callBack)
    self.model:FlyGameObject(gameObject, startPosition, endPosition, callBack)
end

function NoticeManager:CleanAutoUse()
    if self.model ~= nil and self.model.autoUse ~= nil then
        self.model.autoUse:Clean()
    end
end

function NoticeManager:HasAuto()
    if RoleManager.Instance.RoleData.lev >= 15 then
        return false
    end
    local v = self.model.autoUse.headData.afterData
    while v ~= nil do
        if v.itemData ~= nil and v.itemData.type == BackpackEumn.ItemType.gift then
            return true
        end
        v = v.afterData
    end
    -- for i,v in ipairs(self.model.autoUse.dataList) do
    --     if v.itemData ~= nil and v.itemData.type == BackpackEumn.ItemType.gift then
    --         return true
    --     end
    -- end
    return false
end

function NoticeManager:Clean()
    self:HideGuildPublicity()
    self:HideAutoUse()
    self:CleanAutoUse()
    if self.model ~= nil then
        self.model:Clean()
    end
end

function NoticeManager:On9928(data)
    BaseUtils.dump(data, "<color=#FF0000>接收9928</color>")
    local gain = BaseUtils.copytab(data.rewards)
    for _,v in pairs(gain) do
        v.id = v.item_id
        v.num = v.count
    end
    -- if #gain > 0 then
        FinishCountManager.Instance.model.reward_win_data = {
            titleTop = data.title
            , val2 = data.content
            , val1 = data.process
            , val = nil
            , title = TI18N("奖 励")
            , confirm_str = TI18N("确 认")
            , reward_title = TI18N("挑战奖励")
            , reward_list = gain
            , confirm_callback = function() end
            , share_callback = nil
            -- , sure_time = 20
        }
        FinishCountManager.Instance.model:InitRewardWin_Common()
    -- else
    --     self:FloatTipsByString(data.content)
    -- end
end
function NoticeManager:FlyWithScale(data)
    self.model.flyTips:SetData(data)
end

-- 展示提示
function NoticeManager:On9911(data)
    if data.type == 1 then
        -- 光环展示
        EquipStrengthManager.Instance.model:OpenGetRoleHalo(data.id)
    end
end

-- 更新专用tips
function NoticeManager:UpdateTips(data)
    self.isMatchNotice = false
    self.model:UpdateTips(data)
end

QiXiLoveManager = QiXiLoveManager or BaseClass(BaseManager)

function QiXiLoveManager:__init()
    if QiXiLoveManager.Instance ~= nil then
        return
    end

    QiXiLoveManager.Instance = self
    self:InitHandler()
    self.model = QiXiLoveModel.New()
    self.matchData = nil
    self.checkData = nil
    self.onUpdateMatch = EventLib.New()
    self.onUpdateCheck = EventLib.New()

    self.onUpdateActive = EventLib.New()

end
function QiXiLoveManager:OpenLoveMatchWindow(args)
    self.model:OpenLoveMatchWindow(args)
end

function QiXiLoveManager:OpenLoveCheckWindow(args)
    self.model:OpenLoveCheckWindow(args)
end

function QiXiLoveManager:InitHandler()
    self:AddNetHandler(17878, self.on17878)
    self:AddNetHandler(17879, self.on17879)
    self:AddNetHandler(17880, self.on17880)
    self:AddNetHandler(17881, self.on17881)
    self:AddNetHandler(17882, self.on17882)
end

function QiXiLoveManager:RequestInitData()
    self:send17880()
end

function QiXiLoveManager:__delete()
    self.model:DeleteMe()
end

function QiXiLoveManager:send17878()
    math.randomseed(tostring(os.time()):reverse():sub(1,6))
    local index = math.random(1,11)
    local str = ""
    if index ==1 then
        str = "这个情人节，我只想和你过~"
    elseif index == 2 then
        str = "在今天，我想和你在一起！{face_1,7}{face_1,7}"
    elseif index == 3 then
        str = "情定星辰终不悔，想你做我的TA{face_1,3}{face_1,3}"
    elseif index == 4 then
        str = "希望能在这浪漫情人节，我们能够亲密相见{face_1,3}"
    elseif index == 5 then
        str = "情人节其实并不浪漫，浪漫的是和你在一起的感觉"
    elseif index == 6 then
        str = "上天又给我一个约你的借口，嘿嘿{face_1,2}"
    elseif index == 7 then
        str = "那璀璨的银河都已撒满我对你爱的宣言{face_1,3}"
    elseif index == 8 then
        str = "浪漫情人节，你愿意跟我一起浪漫渡过吗？{face_1,6}"
    elseif index == 9 then
        str = "缘是浪漫的相遇，瞬间让你我的心化为永恒！{face_1,59}"
    elseif index == 10 then
        str = "想要与你共建一段浪漫的情缘，你愿意吗？"
    elseif index == 11 then
        str = "想要和你一起卧看牵牛织女星"
    end

    local data = {msg = str}
    BaseUtils.dump(data,"发送协议17878")
    Connection.Instance:send(17878,data)
end

function QiXiLoveManager:on17878(data)
    -- BaseUtils.dump(data,"协议回调17878")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
end
-----
function QiXiLoveManager:send17879()
    Connection.Instance:send(17879,{})
end

function QiXiLoveManager:on17879(data)
    BaseUtils.dump(data,"协议回调17879")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.matchData = data
    if data.list ~= nil then
        self.model:OpenReallyLoveMatchWindow()
    end

    self.onUpdateMatch:Fire(data)

end

function QiXiLoveManager:send17880()
    Connection.Instance:send(17880, {})
end

function QiXiLoveManager:on17880(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.checkData = data
    self.onUpdateCheck:Fire()
    self.onUpdateActive:Fire()
    self:CheckConcentric()
end

function QiXiLoveManager:send17881()
    Connection.Instance:send(17881, {})
end

function QiXiLoveManager:on17881(data)
    if data.err_code == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.love_check)
    end
end

function QiXiLoveManager:send17882()
    Connection.Instance:send(17882, {})
end

function QiXiLoveManager:on17882(data)
end

function QiXiLoveManager:CheckConcentric()
    if QiXiLoveManager.Instance.checkData.point == 99 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.love_check)
    end
end


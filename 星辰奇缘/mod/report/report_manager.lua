-- ----------------------------------------------------------
-- 逻辑模块 - 举报
-- ----------------------------------------------------------
ReportManager = ReportManager or BaseClass(BaseManager)

function ReportManager:__init()
    if ReportManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	ReportManager.Instance = self

    self.model = ReportModel.New()

    self:InitHandler()
end

function ReportManager:__delete()
end

function ReportManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添2
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(14702, self.On14702)
    self:AddNetHandler(14703, self.On14703)
    self:AddNetHandler(14704, self.On14704)
    self:AddNetHandler(14705, self.On14705)
end

function ReportManager:Send14702(rid, platform, zone_id, reason, msg, type,flag)
    for i,v in ipairs(msg) do
        v.content = string.gsub(v.content, "<.->", "")
    end
    local flag = flag or 0
    local data = { rid = rid, platform = platform, zone_id = zone_id, reason = reason, msg = msg, type = type,flag = flag}
     -- BaseUtils.dump(data,"发送协议14702=================================================================================")
    Connection.Instance:send(14702, data)
end

function ReportManager:On14702(data)
    -- BaseUtils.dump(data,"接收协议14702=================================================================================")
    if data.flag == 0 then      --举报失败 上浮提示
        NoticeManager.Instance:FloatTipsByString(data.msg)
    else
        WorldChampionManager.Instance.complainSuccess:Fire(data.msg)   -- 武道结算界面的举报
    end
end

--公会公告举报
function ReportManager:Send14703()
    -- BaseUtils.dump(data,"发送协议14703=================================================================================")
    Connection.Instance:send(14703, {})
end

function ReportManager:On14703(data)
    -- BaseUtils.dump(data,"接收协议On14703=================================================================================")
    ReportManager.Instance.model:OpenWindow({data,2})
end

--公会邮件举报
function ReportManager:Send14704()
    -- BaseUtils.dump(data,"发送协议14704=================================================================================")
    Connection.Instance:send(14704, {})
end

function ReportManager:On14704(data)
    -- BaseUtils.dump(data,"接收协议On14704=================================================================================")
    ReportManager.Instance.model:OpenWindow({data,3})
end

--检查是否可举报
function ReportManager:Send14705(rid, platform, zone_id)
    BaseUtils.dump("发送协议14705=================================================================================")
    Connection.Instance:send(14705, {rid = rid, platform = platform, zone_id = zone_id})
end

function ReportManager:On14705(data)
    BaseUtils.dump(data,"接收协议On14705=================================================================================")
    if data.flag == 1 then 
        if self.model.chatType == 1 then 
            self.model:OpenWindow(self.model.chatData)
        elseif self.model.chatType == 2 then 
            self.model:OpenZoneWindow(self.model.chatData)
        end
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
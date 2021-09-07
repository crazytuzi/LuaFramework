-- --------------------------------
-- 藏宝迷宫
-- huangzefeng
-- --------------------------------
TreasureMazeManager = TreasureMazeManager or BaseClass(BaseManager)

function TreasureMazeManager:__init()
    if TreasureMazeManager.Instance then
        return
    end
    TreasureMazeManager.Instance = self

    self.mazeData = {status = 0, opens = {}}
    self.model = TreasureMazeModel.New(self)
    self.mazeUpdate = EventLib.New() -- 迷宫数据更新
    self.dragonUpdate = EventLib.New() -- 炎龙更新
    self.guideUpdate = EventLib.New() -- 指引更新
    self.onmazeReset = EventLib.New() -- 迷宫重置
    self.onCatchGhost = EventLib.New() -- 抓妖怪
    self.onKillGhost = EventLib.New() -- 锤妖怪



    self:InitHandler()
end


function TreasureMazeManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(18800, self.On18800)
    self:AddNetHandler(18801, self.On18801)
    self:AddNetHandler(18802, self.On18802)
    self:AddNetHandler(18803, self.On18803)
    self:AddNetHandler(18804, self.On18804)
    self:AddNetHandler(18805, self.On18805)
    self:AddNetHandler(18806, self.On18806)
    self:AddNetHandler(18807, self.On18807)
    self:AddNetHandler(18808, self.On18808)
    self:AddNetHandler(18809, self.On18809)
    self:AddNetHandler(18810, self.On18810)
    self:AddNetHandler(18811, self.On18811)
    self:AddNetHandler(18812, self.On18812)
    self:AddNetHandler(18813, self.On18813)
    self:AddNetHandler(18814, self.On18814)
    self:AddNetHandler(18815, self.On18815)
    self:AddNetHandler(18816, self.On18816)
end
-- 推送宝藏迷城信息
function TreasureMazeManager:Send18800()
    Connection.Instance:send(18800, { })
end

function TreasureMazeManager:On18800(data)
    -- BaseUtils.dump(data, "18800")
    self.mazeData = data
    self.model:UpdateBlockData(data)
    self.mazeUpdate:Fire()
end
-- 挖掘一下
function TreasureMazeManager:Send18801(x, y)
    print("开格子："..tostring(x)..","..tostring(y))
   Connection.Instance:send(18801, {x = x, y = y})
end

function TreasureMazeManager:On18801(data)
   -- BaseUtils.dump(data, "18801")
   NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 炎龙爆发
function TreasureMazeManager:Send18802()
    Connection.Instance:send(18802, { })
end

function TreasureMazeManager:On18802(data)
    -- BaseUtils.dump(data, "18802")
    self.dragonData = data
    self.dragonUpdate:Fire()
end
-- 炎龙爆发播放特效完成
function TreasureMazeManager:Send18803()
print("Send18803")
    Connection.Instance:send(18803, { })
end

function TreasureMazeManager:On18803(data)
    -- BaseUtils.dump(data, "18803")
end
-- 喂土拨鼠
function TreasureMazeManager:Send18804(x, y, id)
print("Send18804")
-- BaseUtils.dump({x = x, y = y, id = id})
    Connection.Instance:send(18804, {x = x, y = y, id = id})
end

function TreasureMazeManager:On18804(data)
    -- BaseUtils.dump(data, "18804")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 放妖抓取奖励
function TreasureMazeManager:Send18805(data)
print("Send18805")
-- BaseUtils.dump(data)
    Connection.Instance:send(18805, data)
end

function TreasureMazeManager:On18805(data)
    -- BaseUtils.dump(data, "18805")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.ghostResult = data
    self.onCatchGhost:Fire()
end
-- 遇袭挑战
function TreasureMazeManager:Send18806(x, y)
    print("18806")
    Connection.Instance:send(18806, {x = x, y = y})
end

function TreasureMazeManager:On18806(data)
    -- BaseUtils.dump(data, "18806")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 领取道具
function TreasureMazeManager:Send18807(x, y)
    Connection.Instance:send(18807, {x = x, y = y})
end

function TreasureMazeManager:On18807(data)
    -- BaseUtils.dump(data, "18807")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 开最终宝箱
function TreasureMazeManager:Send18808()
    Connection.Instance:send(18808, { })
end

function TreasureMazeManager:On18808(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- BaseUtils.dump(data, "18808")
    if data.flag == 0 then
        return
    end
    local itemList = {}
    for k,v in pairs(data.reward) do
        table.insert(itemList, {id = v.base_id, num = v.num})
    end
    -- FinishCountManager.Instance.model.reward_win_data = {
    --     titleTop = "宝藏迷城珍宝"
    --     , val = ""
    --     , val1 = ""
    --     , val2 = string.format("<color='#225ee7'>%s</color>", TI18N("恭喜解开宝藏迷城的奥秘，获得了最终珍宝"))
    --     , title = TI18N("获得奖励")
    --     -- , confirm_str = "确定"
    --     , share_str = TI18N("确定")
    --     , reward_list = itemList
    --     , share_callback = function()
    --             self:Send18811()
    --         end
    -- }
    self.model:OpenRewardPanel(itemList)
    -- FinishCountManager.Instance.model:InitRewardWin_Common()
end
-- 18809 扫描
function TreasureMazeManager:Send18809()
    Connection.Instance:send(18809, { })
end

function TreasureMazeManager:On18809(data)
    -- BaseUtils.dump(data, "18809")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.model:ScanSuccess()
    end
end
-- 使用双倍卡
function TreasureMazeManager:Send18810()
    Connection.Instance:send(18810, { })
end

function TreasureMazeManager:On18810(data)
    -- BaseUtils.dump(data, "18810")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 重置宝藏迷城
function TreasureMazeManager:Send18811()
    Connection.Instance:send(18811, { })
end

function TreasureMazeManager:On18811(data)
    -- BaseUtils.dump(data, "18811")
    self.model:RandomBlockSprite()
    if data.flag == 1 then
        self.onmazeReset:Fire()
    end
end

function TreasureMazeManager:On18812(data)
    BaseUtils.dump(data, " <color='#ff0000'>18811###################################</color>")
    self.guideData = data
    self.guideUpdate:Fire()
end

-- 指引播放特效完成
function TreasureMazeManager:Send18813()
print("Send18813")
    Connection.Instance:send(18813, { })
end

function TreasureMazeManager:On18813(data)
    BaseUtils.dump(data, "18813")
end


-- 指引播放特效完成
function TreasureMazeManager:Send18814(x, y)
print("Send18814")
    Connection.Instance:send(18814, {x = x, y = y})
end

function TreasureMazeManager:On18814(data)
    BaseUtils.dump(data, "18814")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 显示怪物奖励
function TreasureMazeManager:Send18815(x, y)
print("Send18815")
    Connection.Instance:send(18815, {x = x, y = y})
end

function TreasureMazeManager:On18815(data)
    BaseUtils.dump(data, "18815")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:OpenMosterPanel(data)
end

-- 锤怪物
function TreasureMazeManager:Send18816(x, y)
print("Send18816")
    Connection.Instance:send(18816, {x = x, y = y})
end

function TreasureMazeManager:On18816(data)
    BaseUtils.dump(data, "18816")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.onKillGhost:Fire(data)
    end
end
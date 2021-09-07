-- ----------------------------------------------------------
-- 逻辑模块 - 卡等级
-- ----------------------------------------------------------
LevelJumpManager = LevelJumpManager or BaseClass(BaseManager)

function LevelJumpManager:__init()
    if LevelJumpManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

    LevelJumpManager.Instance = self

    self.model = LevelJumpModel.New()
    self.assetWrapper = nil
    -- self.effectHideFunc = nil
    -- self.effectPath = "prefabs/effect/30131.unity3d"
    -- self.effect = nil
    -- self.effectTimeId = 0

    self:InitHandler()
end

function LevelJumpManager:__delete()

end

function LevelJumpManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    -- self:AddNetHandler(17400, self.on17400)
    -- self:AddNetHandler(17401, self.on17401)
    -- self:AddNetHandler(17402, self.on17402)
    -- self:AddNetHandler(17403, self.on17403)
    -- self:AddNetHandler(17404, self.on17404)
    -- self:AddNetHandler(17405, self.on17405)
end

function LevelJumpManager:on17400(data)
    --BaseUtils.dump(data, "on17400............")
    self.model:SetBreakData(data)
    self.model:UpdateWindow()
end

function LevelJumpManager:send17400()
    Connection.Instance:send(17400, {})
end

-- ------------------------------
-- 宝藏迷宫
-- hzf
-- ------------------------------

TreasureMazeModel = TreasureMazeModel or BaseClass(BaseModel)

function TreasureMazeModel:__init(mgr)
    self.mgr = mgr
    self.blockData = {}
    self.pieceData = {}
    self.blockeventData = {}
    self.blockspriteData = {}
    self:InitBlockData()
end

function TreasureMazeModel:__delete()
end

function TreasureMazeModel:OpenMazeWindow()

    if self.mazewin == nil then
        self.mazewin = TreasureMazeWindow.New(self)
    end
    self.mazewin:Open()
end

function TreasureMazeModel:CloseMazeWindow()
    if self.mazewin ~= nil then
        WindowManager.Instance:CloseWindow(self.mazewin)
    end
end

function TreasureMazeModel:OpenRewardPanel(args)
    if self.rewardpanel == nil then
        self.rewardpanel = TreasureMazeRewardPanel.New(self)
    end
    self.rewardpanel:Show(args)
end

function TreasureMazeModel:CloseRewardPanel()
    if self.rewardpanel ~= nil then
        self.rewardpanel:DeleteMe()
        self.rewardpanel = nil
    end
end

function TreasureMazeModel:OpenEventPanel(args)
    if self.eventpanel == nil then
        self.eventpanel = TreasureMazeEventPanel.New(self)
    end
    self.eventpanel:Show(args)
end

function TreasureMazeModel:CloseEventPanel()
    if self.eventpanel ~= nil then
        self.eventpanel:DeleteMe()
        self.eventpanel = nil
    end
end

function TreasureMazeModel:OpenMosterPanel(args)
    if self.mosterpanel == nil then
        self.mosterpanel = TreasureMazeMosterPanel.New(self)
    end
    self.mosterpanel:Show(args)
end

function TreasureMazeModel:CloseMosterPanel()
    if self.mosterpanel ~= nil then
        self.mosterpanel:DeleteMe()
        self.mosterpanel = nil
    end
end

function TreasureMazeModel:InitBlockData()
    self.blockData = {}
    self.blockeventData = {}
    self.pieceData = {}
    for i=1,5 do
        self.blockData[i] = {}
        self.blockeventData[i] = {}
        for j=1,5 do
            self.blockData[i][j] = {}
            self.blockeventData[i][j] = {}
        end
    end
end

function TreasureMazeModel:UpdateBlockData(data)
    self:InitBlockData()
    for i,v in ipairs(data.opens) do
        self.blockData[v.x][v.y] = v
    end
    for i,v in ipairs(data.events) do
        if self.blockeventData[v.e_x] == nil then
            self.blockeventData[v.e_x] = {}
        end
        if self.blockeventData[v.e_x][v.e_y] == nil then
            self.blockeventData[v.e_x][v.e_y] = {}
        end
        table.insert(self.blockeventData[v.e_x][v.e_y], v)
    end
    for i,v in ipairs(data.piece_other) do
        if self.pieceData[v.piece_x] == nil then
            self.pieceData[v.piece_x] = {}
        end
        self.pieceData[v.piece_x][v.piece_y] = v.piece_num
    end
end

function TreasureMazeModel:GetData(x, y)
    -- if x < 1 or x > 5 or y < 1 or y > 5 then
    --      Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
    -- end
    if self.blockData[x] == nil or self.blockData[x][y] == nil then
        return nil
    end
    return self.blockData[x][y]
end

function TreasureMazeModel:GetEventData(x, y)
    -- if x < 1 or x > 5 or y < 1 or y > 5 then
    --      Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
    -- end
    if self.blockeventData[x] == nil or self.blockeventData[x][y] == nil then
        return nil
    end
    return self.blockeventData[x][y]
end

function TreasureMazeModel:GetPieceData(x, y)
    -- if x < 1 or x > 5 or y < 1 or y > 5 then
    --      Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
    -- end
    if self.pieceData[x] == nil or self.pieceData[x][y] == nil then
        return nil
    end
    return self.pieceData[x][y]
end

function TreasureMazeModel:RandomBlockSprite()
    self.blockspriteData = {}
    for i=1,5 do
        self.blockspriteData[i] = {}
        for j=1,5 do
            self.blockspriteData[i][j] = Random.Range(1, 5)
        end
    end
end

function TreasureMazeModel:GetBlockSprite(x, y)
    if next(self.blockspriteData) == nil then
        self:RandomBlockSprite()
    end
    if self.blockspriteData[x] ~= nil then
        if self.blockspriteData[x][y] ~= nil then
            return self.blockspriteData[x][y]
        end
    end
    return 1
end

function TreasureMazeModel:ScanSuccess()
    if self.mazewin ~= nil then
        -- self.mazewin:PlayScan()
    end
end
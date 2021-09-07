DungeonModel = DungeonModel or BaseClass(BaseModel)

function DungeonModel:__init()
    self.dunMgr = DungeonManager.Instance
    self.towerendwin = nil
    self.dungeonwin = nil
    self.rollwin = nil
    self.towerreward = nil

    self.clearerBuff = {
        name = TI18N("通关加成"),
        icon = "50005",
        desc = TI18N("挑战过的最高层数大于本层<color='#00ff00'>+3</color>\n可获得大幅度的攻击加成！")
    }
end

function DungeonModel:OpenRoll()
    if self.rollwin == nil then
        self.rollwin = DungeonRollWindow.New(self)
    else
        self:CloseRollWin()
        self.rollwin = DungeonRollWindow.New(self)
    end
    self.rollwin:Show()
end

function DungeonModel:OpenEnd()
    if self.dungeonwin == nil then
        self.dungeonwin = DungeonEndWindow.New(self)
    end
    self.dungeonwin:Open()
end

function DungeonModel:OpenTowerEnd(args)
    if self.towerendwin == nil then
        self.towerendwin = TowerEndWindow.New(self)
    else
        self:CloseTower()
        self.towerendwin = TowerEndWindow.New(self)
    end
    self.towerendwin:Open(args)
end

function DungeonModel:OpenTowerReward()
    if self.towerreward == nil then
        self.towerreward = TowerRewardWindow.New(self)
    end
    self.towerreward:Open()
end

function DungeonModel:UpdateTowerReward()
    if self.towerreward ~= nil then
        self.towerreward:UpdateTowerSelect()
    end
end

function DungeonModel:SetTowerHelpNum(num)
    if self.towerreward ~= nil then
        self.towerreward:SetHelpText(num)
    end
end

function DungeonModel:CloseRollWin()
    if self.rollwin ~= nil then
        self.rollwin:DeleteMe()
        self.rollwin = nil
        -- WindowManager.Instance:CloseWindow(self.rollwin)
    end
end


function DungeonModel:CloseEndWin()
    if self.dungeonwin ~= nil then
        WindowManager.Instance:CloseWindow(self.dungeonwin)
    end
end


function DungeonModel:CloseTower()
    if self.towerendwin ~= nil then
        WindowManager.Instance:CloseWindow(self.towerendwin)
    end
end


function DungeonModel:CloseTowerReward()
    if self.towerreward ~= nil then
        WindowManager.Instance:CloseWindow(self.towerreward)
    end
end


function DungeonModel:OpenBox(data)
    if self.towerendwin ~= nil then
        self.towerendwin:OpenBox(data.order, data.gain_list[1])
        local callback =  function()
            local lastorder = 0
            for k,v in pairs(data.show_list) do
                local ok = false
                for i = 1, 3 do
                    if i ~= data.order and i ~= lastorder and not ok then
                        lastorder = i
                        ok = true
                        if self.towerendwin ~= nil then
                            self.towerendwin:OpenBox(lastorder, v)
                        end
                    end
                end
            end
        end
        LuaTimer.Add(500, function() callback() end)
    end
end

function DungeonModel:OpenUniversalEnd(args)
	if self.towerRaffleWin == nil then
		self.towerRaffleWin = TowerRaffleWindow.New(self)
	end
	self.towerRaffleWin:Open(args)
end

function DungeonModel:CloseUniversalEnd()
	if self.towerRaffleWin ~= nil then
		WindowManager.Instance:CloseWindow(self.towerRaffleWin)
	end
end

function DungeonModel:OpenVideoWindow(args)
    if self.videoWindow == nil then
        self.videoWindow = DungeonVideoWindow.New(self)
    end
    self.videoWindow:Open(args)
end

function DungeonModel:CloseVideoWindow()
    if self.videoWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.videoWindow)
    end
end

function DungeonModel:OpenHelp(args)
    if self.helpWin == nil then
        self.helpWin = DungeonHelpWindow.New(self)
    end
    self.helpWin:Open(args)
end

function DungeonModel:OpenClearBuff(args)
    if self.clearBuffWin == nil then
        self.clearBuffWin = DungeonClearBuff.New(self)
    end
    self.clearBuffWin:Open(args)
end


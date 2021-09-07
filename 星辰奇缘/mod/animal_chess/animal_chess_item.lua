AnimalChessItem = AnimalChessItem or BaseClass()

function AnimalChessItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.canClick = true

    self.next = {}
    self.effect = nil

    self:InitPanel()
end

function AnimalChessItem:__delete()
    self.next = nil
    self.model = nil
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    self.gameObject = nil
    self.transform = nil
end

function AnimalChessItem:InitPanel()
    self.button = self.gameObject:GetComponent(Button)
    -- self.image = self.gameObject:GetComponent(Image)
end

function AnimalChessItem:ShowRed()
    if self.effect ~= nil then
        self.effect:DeleteMe()
    end
    self.effect = BibleRewardPanel.ShowEffect(20403, self.image.transform, Vector3.one * 0.7, Vector3.zero)
end

function AnimalChessItem:ShowNormal()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
end

function AnimalChessItem:ShowSelect()
    if self.effect ~= nil then
        self.effect:DeleteMe()
    end
    self.effect = BibleRewardPanel.ShowEffect(30002, self.transform, Vector3(120, 120, 120), Vector3(46.3, 38.15, 0), nil, Vector3(20.68393, 131.9303, 340.775))

    BaseUtils.dump(Quaternion.Inverse(Quaternion.Euler(Vector3(270,180,0))).eulerAngles)
end

function AnimalChessItem:ShowGreen()
    if self.effect ~= nil then
        self.effect:DeleteMe()
    end
    self.effect = BibleRewardPanel.ShowEffect(20404, self.image.transform, Vector3.one * 0.7, Vector3.zero)
end

function AnimalChessItem:Select(bool)
    local thisChess = self.model.chessInfoTab[self.x][self.y]
    local theChess = nil

    if thisChess.status ~= AnimalChessEumn.SlotStatus.Opened then
        bool = false
    end

    if bool then
        local defeadTab = {}
        for i,v in ipairs(AnimalChessEumn.ChessType[thisChess.grade].defeat) do
            defeadTab[v] = 1
        end
        for i,item in pairs(self.next) do
            if item ~= nil then
                theChess = self.model.chessInfoTab[item.x][item.y]
                if theChess.status == AnimalChessEumn.SlotStatus.Empty then
                    item.canClick = true
                    AnimalChessManager.Instance.onGreenEvent:Fire(item.x, item.y, i)
                elseif theChess.status == AnimalChessEumn.SlotStatus.Opened and theChess.camp ~= thisChess.camp and defeadTab[theChess.grade] == 1 then
                    item.canClick = true
                    AnimalChessManager.Instance.onGreenEvent:Fire(item.x, item.y, i)
                else
                    item.canClick = false
                    -- AnimalChessManager.Instance.onNormalEvent:Fire(item.x, item.y)
                end
            end
        end
    else
        -- for _,item in pairs(self.next) do
        --     if item ~= nil then
        --         item.canClick = true
        --         AnimalChessManager.Instance.onNormalEvent:Fire(item.x, item.y)
        --     end
        -- end
        AnimalChessManager.Instance.onNormalEvent:Fire(self.x, self.y)
    end
end



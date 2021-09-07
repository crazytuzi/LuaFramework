AnimalChessControllor = AnimalChessControllor or BaseClass()

function AnimalChessControllor:__init(model)
    self.model = model
end

function AnimalChessControllor:__delete()
    if self.moveTweenId ~= nil then
        Tween.Instance:Cancel(self.moveTweenId)
        self.moveTweenId = nil
    end
    if self.moveDelate ~= nil then
        LuaTimer.Delete(self.moveDelate)
        self.moveDelate = nil
    end
    if self.deadDelate ~= nil then
        LuaTimer.Delete(self.deadDelate)
        self.deadDelate = nil
    end
    if self.openDelate ~= nil then
        LuaTimer.Delete(self.openDelate)
        self.openDelate = nil
    end
    if self.attackDelate ~= nil then
        LuaTimer.Delete(self.attackDelate)
        self.attackDelate = nil
    end
end

function AnimalChessControllor:Move(piece1, piece2, callback)
    self.model.isPlaying = true
    local targetPos = piece2.localPos
    piece1:FaceTo(targetPos / 100)

    if piece2.loader ~= nil then
        piece2.loader:DeleteMe()
    end
    piece2.loader = piece1.loader
    piece1.loader = nil
    piece2:Play("Move")

    local follow = piece1.follow
    piece1.follow = piece2.follow
    piece2.follow = follow

    local dis = math.sqrt((piece2.x - piece1.x) * (piece2.x - piece1.x) + (piece2.y - piece1.y) * (piece2.y - piece1.y))

    if piece2.loader ~= nil then 
        self.moveTweenId = Tween.Instance:ValueChange(piece2.loader.tpose.transform.localPosition * 100, targetPos, 0.6 * dis, function()
                self.moveTweenId = nil
                self.model.isPlaying = false

                piece1.follow.transform.gameObject:SetActive(false)
                piece2:Play("Stand")
            end, LeanTweenType.linear, function(value)
                if piece2.loader ~= nil then
                    piece2.follow.transform.anchoredPosition = Vector2(value.x, value.y)
                    piece2.loader.tpose.transform.localPosition = value / 100
                end
            end).id
    end
end

function AnimalChessControllor:Attack(piece1, piece2, callback)
    self.model.isPlaying = true
    piece1:FaceTo(piece2.localPos / 100)

    if piece2.loader == nil or piece1.loader == nil then return end
    
    local direction = piece2.loader.tpose.transform.localPosition - piece1.loader.tpose.transform.localPosition
    piece1.loader.tpose:GetComponent(Animator):Play("1000")
    self.attackDelate = LuaTimer.Add(400, function()
        self.attackDelate = nil
        piece2:Play("Dead")

        if callback ~= nil then
            callback()
        end
    end)
    self.moveDelate = LuaTimer.Add(1500, function()
        self.moveDelate = nil
        self:Move(piece1, piece2)
    end)
end

function AnimalChessControllor:Upthrow(piece, direction)
    self.model.isPlaying = true
    local num = 12
    piece:Play("Upthrow")
    self.upthrowTimerId = Tween.Instance:ValueChange(piece.loader.tpose.transform.localPosition, piece.loader.tpose.transform.localPosition + direction * num, 0.6, function()
            self.upthrowTimerId = nil
            self.model.isPlaying = false

            piece.follow.transform.gameObject:SetActive(false)
        end, LeanTweenType.linear, function(value)
            piece.follow.transform.anchoredPosition = Vector2(value.x, value.y)
            piece.loader.tpose.transform.localPosition = value
        end).id
end

function AnimalChessControllor:Die(piece)
    piece:Play("Hit")
    self.deadDelate = LuaTimer.Add(500, function()
        if piece.loader ~= nil then
            piece.loader:DeleteMe()
            piece.loader = nil
        end
        self.deadDelate = nil
    end)
end

function AnimalChessControllor:OpenBox(piece)
    self.openDelate = LuaTimer.Add(800, function()
        self.openDelate = nil
        piece:SetData()
        piece:Play("Stand")
    end)

    if piece.loader ~= nil then
        piece:OpenBox()
        if piece.loader ~= nil and not BaseUtils.isnull(piece.loader.tpose) then
            piece.loader.tpose:GetComponent(Animator):Play("Idle1")
        end
    end
end

function AnimalChessControllor:Stand(piece)
    piece:Play("Stand")
end

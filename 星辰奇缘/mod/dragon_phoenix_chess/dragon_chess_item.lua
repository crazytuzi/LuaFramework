-- @author hze
-- @date 2018/06/07
--龙凤棋子

DragonChessItem = DragonChessItem or BaseClass()

function DragonChessItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    self.assetWrapper = assetWrapper

    self.x = nil
    self.y = nil

    self.color = nil

    self.weight = 0
    self.time = 60

    self.effect1 = nil
    self.effect2 = nil
    self.effect3 = nil


    self.chessIconList = {"phoenixchess", "dragonchess", "clickable"}

    self:InitPanel()
end

function DragonChessItem:__delete()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end

    if self.timerId3 ~= nil then
        LuaTimer.Delete(self.timerId3)
        self.timerId3 = nil
    end

    if self.effect1 ~= nil then
        self.effect1:DeleteMe()
        self.effect1 = nil
    end

    if self.effect2 ~= nil then
        self.effect2:DeleteMe()
        self.effect2 = nil
    end

    if self.effect3 ~= nil then
        self.effect3:DeleteMe()
        self.effect3 = nil
    end

    if self.effect4 ~= nil then
        self.effect4:DeleteMe()
        self.effect4 = nil
    end

    if self.effect5 ~= nil then
        self.effect5:DeleteMe()
        self.effect5 = nil
    end

    BaseUtils.ReleaseImage(self.icon)

    self.model = nil
    self.gameObject = nil
    self.transform = nil
end

function DragonChessItem:InitPanel()
    self.btn = self.transform:GetComponent(Button)
    self.icon = self.transform:GetComponent(Image)
end


function DragonChessItem:ShowEffect(st)
    if st == 1 then
        self:ShowBlue()
    elseif st == 2 then
        self:ShowRed()
    elseif st == 999 then
        self:ShowNormal()
    end
end

function DragonChessItem:UnShowEffect()
    if self.effect1 ~= nil then
        self.effect1:SetActive(false)
    end

    if self.effect2 ~= nil then
        self.effect2:SetActive(false)
    end

    if self.effect5 ~= nil then
        self.effect5:SetActive(false)
    end
end

function DragonChessItem:ShowNormal()
    if self.effect5 == nil then
        self.effect5 = BaseUtils.ShowEffect(20493, self.transform, Vector3.one*0.8, Vector3(-0.2,0.3,-200))
    end
    self.effect5:SetActive(false)
    self.effect5:SetActive(true)
end


function DragonChessItem:ShowRed()
    if self.effect2 == nil then
        self.effect2 = BaseUtils.ShowEffect(20487, self.transform, Vector3.one*0.8, Vector3(-0.2,0.3,-200))
    end
    self.effect2:SetActive(false)
    self.effect2:SetActive(true)
end

function DragonChessItem:ShowBlue()
    if self.effect1 == nil then
        self.effect1 = BaseUtils.ShowEffect(20488, self.transform, Vector3.one*0.8, Vector3(-0.2,0.3,-200))
    end
    self.effect1:SetActive(false)
    self.effect1:SetActive(true)
end

function DragonChessItem:ShowAbled(bool, order)
    if order == 0 then
        if self.effect3 == nil then
            self.effect3 = BaseUtils.ShowEffect(20491, self.transform, Vector3.one, Vector3(0, 0,-400))
        end
        self.effect3:SetActive(bool)
    elseif order == 1 then
        if self.effect4 == nil then
            self.effect4 = BaseUtils.ShowEffect(20492, self.transform, Vector3.one, Vector3(0, 0,-400))
        end
        self.effect4:SetActive(bool)
    end
end

function DragonChessItem:SetAbled(bool)
    local aph = bool and 1 or 0
    self.icon.color = Color(1, 1, 1, aph)
end

function DragonChessItem:SetAbledTick(bool)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(800, function() 
            self:SetAbled(bool) 
            self:UnShowEffect()
        end)
end

function DragonChessItem:ShowEffectTick(st)
    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end
    self.timerId2 = LuaTimer.Add(self.weight*self.time,function()
            self:SetAbled(false)
            self:ShowEffect(st)
            self:SetIconSprite(st)
            self:SetAbledTick(true)
            self.weight = 0
        end)
end

function DragonChessItem:SetIconSprite(st)
    self.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.dragon_chess_textures,self.chessIconList[st])
end

local LogicRand = class("LogicRand" , function( ... )
    return {}
end)

function LogicRand:ctor(randSeed)
    self.randSeed = randSeed
end

-- function LogicRand:random(...)
--     math.randomseed(self.randSeed)
--     self.randSeed = self.randSeed + 1
--     return math.random(...)
-- end

---[[
function LogicRand:random(x , y)
    --Xn+1 = (a*Xn + b) mod c (其中, abc通常是质数)
    self.randSeed = (1103515245 * self.randSeed + 12345) % 4294967296
    if x and y then
        if x == y then
            return x
        else
            return math.min(x , y) + self.randSeed % math.abs(x - y)
        end
    else
        return self.randSeed
    end
end
--]]

return LogicRand
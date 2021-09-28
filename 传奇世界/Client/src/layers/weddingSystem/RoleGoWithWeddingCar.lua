local RoleGoWithWeddingCar = class("RoleGoWithWeddingCar",function () return cc.Layer:create() end)

local wsysCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")

function RoleGoWithWeddingCar:beginGoWith()
    local onWeddingCar = false
    local function updateRolePosTowCarPos()
        local weddingCarId = wsysCommFunc.weddingCarId
        if not weddingCarId then
            return
        end
        local wCarSprite = G_MAINSCENE.map_layer.item_Node:getChildByTag(weddingCarId)
        local roleSprite = G_ROLE_MAIN

        if wCarSprite then
            local rolePos = cc.p(roleSprite:getPositionX(),roleSprite:getPositionY()) 
            local wCarPos = cc.p(wCarSprite:getPositionX(),wCarSprite:getPositionY())

            print("rolePos & wCarPos ==== ",rolePos.x,rolePos.y,wCarPos.x,wCarPos.y)

            if G_MAINSCENE.map_layer.mapID == 2100 and cc.pGetDistance(rolePos,wCarPos) <= 60 and not onWeddingCar then
                --roleSprite:setVisible(false)
                --roleSprite:setPosition(wCarPos)
                g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_ON_THE_CAR, "MarriageCSWeddingOnTheCar", {})
                onWeddingCar = true
                print("on wedding car ...................................................................")
            end
        end
    end
    
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateRolePosTowCarPos, 0.01, false)

    --self:setContentSize()

end

return RoleGoWithWeddingCar
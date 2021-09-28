-- LoadTextureFactory

local LoadTextureFactory = {}

local totalTextureList = {}

function LoadTextureFactory.loadTextureAsync(textureList, loadedFinish)
    
    if not textureList or #textureList == 0 then return end
    
    -- 线程数限制，最大不超过材质的数量
    local threadNum = 1
    local threadLimit = #textureList > threadNum and threadNum or #textureList
    local count = 0

    local startTime = nil
    local finishTime = nil
    
    local function startTextureLoading()
        
        local function textureLoading()
            -- 开启加载
            local texturePath = textureList[count]
            
            CCTextureCache:sharedTextureCache():addImageAsync(texturePath, function(obj1, obj)
                local texture = nil 
                if obj then 
                    texture = tolua.cast(obj, "CCTexture2D")
                else
                    texture = tolua.cast(obj1, "cc.Texture2D")
                end
--                print(">>load finish: name: "..texturePath)

                if not totalTextureList[texturePath] then
                    totalTextureList[texturePath] = texture
                    texture:retain()
                end
                
                if loadedFinish then loadedFinish(texture, texturePath) end
                
                count = count + 1   -- next
                if not textureList[count] then
                    if count == threadLimit + #textureList then
--                        print(">> >> FINISH << <<")
--                        finishTime = FuncHelperUtil:getTickCount()
--                        print(">> Loading Texture Finish time: "..finishTime)
--                        print(">> duration: "..finishTime - startTime)
                    end
                else
                    -- 再次加载
                    textureLoading()
                end
            end)
        end
        
        -- next
        count = count + 1
        if textureList[count] then
            -- 开始加载
            textureLoading()
        end
        
        if count == threadLimit + #textureList then
--            print(">> >> FINISH << <<")
--            finishTime = FuncHelperUtil:getTickCount()
--            print(">> Loading Texture Finish time: "..finishTime)
--            print(">> duration: "..finishTime - startTime)
        end

    end
    
    startTime = FuncHelperUtil:getTickCount()
--    print(">> Loading Texture Start time: "..startTime)
    for i=1, threadLimit do
        startTextureLoading()
    end
    
end

function LoadTextureFactory.clear()
    for k, texture in pairs(totalTextureList) do
        texture:release()
    end
    totalTextureList = {}
end

function LoadTextureFactory.loadTextureSynch(textureList)
    
    if not textureList or #textureList == 0 then return end
    
    local scheduler = require "framework.scheduler"
    
    local index = 1    -- 列表索引
    local delta = -1   -- 间隔1帧标示
    
    local loadHandler = nil
    loadHandler = scheduler.scheduleUpdateGlobal(function(dt)
        
        delta = delta * -1
        -- 为1标示这一帧加载，否则跳过
        if delta == 1 then
            CCTextureCache:sharedTextureCache():addImage(textureList[index])
            index = index + 1
            
            if not textureList[index] then
               scheduler.unscheduleGlobal(loadHandler) 
            end
        end
    end)
    
end

return LoadTextureFactory

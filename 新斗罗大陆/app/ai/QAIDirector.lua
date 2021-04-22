--[[
    Class name QAIDirector
    Create by julian 
--]]
local QAINode = import(".QAINode")
local QAIDirector = class("QAIDirector", QAINode)

local QFileCache = import("..utils.QFileCache")

--[[
    options is a table. Valid key below:
--]]
function QAIDirector:ctor( options )
    QAIDirector.super.ctor(self, options)
    self._isDirector = true
end

function QAIDirector:addBehaviorTree( treeRoot )
    self:addChild(treeRoot)
end

function QAIDirector:removeBehaviorTree( treeRoot )
    if treeRoot and treeRoot:getParent() == self then
        self:removeChild(treeRoot)
    end
end

function QAIDirector:hasBehaviorTree( treeRoot )
    return self:hasChild(treeRoot)
end

function QAIDirector:pause()
    self._isPaused = true
end

function QAIDirector:resume()
    self._isPaused = false
end

function QAIDirector:visit( event )
    if self._isPaused then
        return
    end

    local count = self:getChildrenCount()
    for index = 1, count, 1 do
        local treeRoot = self:getChildAtIndex(index)
        local outpuDebugInfo = false -- 是否输出调试信息
        --if treeRoot:getActor():getId() == "human_wrath_1" then outpuDebugInfo = true end

        if not treeRoot:getActor():isDead() then
            local args = {actor = treeRoot:getActor(), logs = {}, depth = 0, debug = outpuDebugInfo}

            treeRoot:visit(args)

            -- if outpuDebugInfo == true then
            --     printInfo("==== clock: %.3f ==== AI run for ==== " .. args.actor:getId(), app.battle:getTime())
            --     for i = 1, table.nums(args.logs) do
            --         printInfo(args.logs[i])
            --     end
            -- end

        end
    end
end

function QAIDirector:createBehaviorTree( treeName, actor )
    -- if actor ~= nil then
    --     printInfo( "will create behavior tree with name:" .. tostring(treeName) .. " for actor:" .. tostring(actor:getActorID()) )
    -- end
    local rootNode = nil
    local config = QFileCache.sharedFileCache():getAIConfigByName(treeName)
    if config ~= nil then
        rootNode = self:createBehaviorNode(config)
        rootNode:setActor(actor)
    end

    -- assert(rootNode ~= nil, " ai not found, name:" .. treeName)
    return rootNode
end

function QAIDirector:createBehaviorNode( config )
    if config == nil or type(config) ~= "table" then
        return nil
    end

    local aiClass = QFileCache.sharedFileCache():getAIClassByName(config.CLASS)
    local options = clone(config.OPTIONS)
    local behaviorNode = aiClass.new(options)

    local name = config.Name
    behaviorNode:setName(name)

    local args = config.ARGS
    if args ~= nil then
        for key, config in ipairs(args) do
            local child = self:createBehaviorNode(config)
            if child ~= nil then
                behaviorNode:addChild(child)
            end
        end
    end

    return behaviorNode
end


return QAIDirector
local routines = {}
local routine_dt = 0
local lastTime = nil
local function PlayRoutine(func)
    local routine = coroutine.create(func)
    table.insert(routines, routine)
    return routine
end
local function RemoveRoutine(routine_toremove)
    if routine_toremove then
        for i, routine in ipairs(routines) do
            if routine == routine_toremove then
                table.remove(routines, i)
                return
            end
        end 
    end
end
local function WaitRoutine(routine)
    while true do
        if coroutine.status(routine) == "dead" then
            return
        else
            coroutine.yield()
        end
    end
end
local function WaitCondition(cond_func)
    while true do
        if cond_func() then
            return
        else
            coroutine.yield()
        end
    end
end
local function WaitFrame(frame)
    while true do
        if frame == 0 then
            return
        else
            coroutine.yield()
        end
        frame = frame - 1
    end
end
local function WaitTime(time)
    WaitRoutine(PlayRoutine(function()
        while true do
            time = time - routine_dt
            if time <= 0 then
                return
            else
                coroutine.yield()
            end
        end
    end))
end
local function WaitRoutinesAll(...)
    local cos = {...}
    if #cos == 0 then
        return
    end
    while true do
        local all_dead = true
        for _, co in ipairs(cos) do
            if coroutine.status(co) ~= "dead" then
                all_dead = false
                break
            end
        end
        if all_dead then
            break
        else
            coroutine.yield()
        end
    end
end
local function WaitRoutinesAny(...)
    local cos = {...}
    if #cos == 0 then
        return
    end
    while true do
        for _, co in ipairs(cos) do
            if coroutine.status(co) == "dead" then
                return
            end
        end
        coroutine.yield()
    end
end
local function halt()
    while true do
        coroutine.yield()
    end
end
scheduler.scheduleGlobal(function(dt)
    routine_dt = lastTime and (q.time() - lastTime) or dt
    lastTime = q.time()
    local new_routines = {}
    for _, routine in ipairs(routines) do
        if coroutine.status(routine) ~= "dead" then
            local _import = import
            import = function(moduleName, currentModuleName)
                local theModule = nil
                coroutine.yield(
                    "import",
                    function()
                        theModule = _import(moduleName, currentModuleName)
                    end
                )
                return theModule
            end
            local _resume = coroutine.resume
            coroutine.resume = function(co, ...)
                local result, message, func = _resume(co, ...)
                assert(result, message)
                if message == "import" and type(func) == "function" then
                    coroutine.yield(func)
                end
            end
            local result, message, func = _resume(routine)
            import = _import
            coroutine.resume = _resume
            assert(result, message)
            if message == "import" and type(func) == "function" then
                func()
            end
            table.insert(new_routines, routine)
        end
    end
    routines = new_routines
end, 0)

q.PlayRoutine = PlayRoutine
q.RemoveRoutine = RemoveRoutine
q.WaitRoutine = WaitRoutine
q.WaitCondition = WaitCondition
q.WaitFrame = WaitFrame
q.WaitTime = WaitTime
q.WaitRoutinesAll = WaitRoutinesAll
q.WaitRoutinesAny = WaitRoutinesAny
q.halt = halt
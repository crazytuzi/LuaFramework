local Trace = {}

local function dummy() end

Trace.old_dump = dummy 
Trace.old_print = dummy 
Trace.old_echo = dummy 


function Trace.new_dump()
end


function Trace.new_print()
end



function Trace.new_echo()
end


function Trace.init()
    if DEBUG ~= 0 then
        return
    end

    Trace.old_dump = dump 
    Trace.old_print = print 
    Trace.old_echo = echo 

    
    dump = Trace.new_dump 
    print = Trace.new_print 
    echo = Trace.new_echo  


end

function Trace.dumpListeners()
    local obs = uf_eventManager._observerList
    local str = ""
    str =  str .. "time:" .. G_ServerTime:getTimeString() .. "\n"

    str = str .. "===================listeners:" .. "\n"
    for key,eventObserver in pairs(obs) do 
        str = str .. '============' .. key .. " has " .. #eventObserver .. " listens" .. "\n"
        for i, value in pairs(eventObserver) do  
            if #value == 2 then
                local classname = ""
                if value[1] ~= nil and value[1].__cname then
                    classname = value[1].__cname
                end
                str = str .. 'func in ' .. tostring(value[1]) .. ":" .. classname .. "\n"
            end
        end
        
    end

    io.writefile( CCFileUtils:sharedFileUtils():getWritablePath()  .. '/trace.log', str, "a+" )

end

local labels = {}
local options = {}
local size = 16
local height = size + 3
local function updateLabelPositions()
    for i=1,#labels do 
        labels[i]:setPosition(ccp(2, display.height - (50 + i *height)))
    end
end

local nextLabelIndex = 1
local function getNextLabel()
    if nextLabelIndex > #labels then
        local label = table.remove(labels, 1)
        table.insert(labels, label)
        return label, true
    else
        local index = nextLabelIndex
        nextLabelIndex = nextLabelIndex + 1
        return labels[index], false
    end
end
local newEcho = function(str) 
    
    --add log to screen
    local label, relayout = getNextLabel()
    label:setString(str)
    if relayout then
       updateLabelPositions() 
    end
end

local function initLabels(options)
    if Trace._logLayer then
        Trace._logLayer:removeFromParentAndCleanup(true)
    end

    Trace._logLayer  = CCLayerColor:create(ccc4(0, 0, 0, options.bg_alpha), display.width, display.height)

    Trace._logLayer:setTouchEnabled(false)
    uf_notifyLayer:getDebugNode():addChild(Trace._logLayer)


    labels = {}
    local maxLines = (display.height - 100)/ height 
    for i=1,maxLines do 
        local label = ui.newTTFLabel({size=size, text=""})
        display.align(label, display.CENTER_LEFT)
        label:setOpacity(options.txt_alpha)
        table.insert(labels, label)
        Trace._logLayer:addChild(label)
    end
    nextLabelIndex = 1
    updateLabelPositions()

end



function Trace.showScreen(opt)
    if DEBUG ~= 0 then
        return
    end

    
    options = opt
    if options == nil then
        options = {bg_alpha=60, txt_alpha=150}
    end


    dump = Trace.old_dump
    echo = newEcho
    print = newEcho

    initLabels(options)




end


function Trace.clearScreen()
    initLabels(options)
end


function Trace.hideScreen()
    if DEBUG ~= 0 then
        return
    end

    dump = Trace.new_dump
    echo = Trace.new_echo
    print = Trace.new_print



end



return Trace


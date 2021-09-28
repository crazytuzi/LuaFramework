TimeProfile = class("TimeProfile")

local m_bStart = false
local m_lastTick = 0
local m_stepValues = {}

function TimeProfile:ctor()

end

function TimeProfile:funcBegin()
    m_bStart = true
    m_lastTick = GetProtoWriter():GetTickCount()
end

function TimeProfile:step(stepName)
    if not m_bStart then
        return
    end

    if m_stepValues[stepName] == nil then
        m_stepValues[stepName] = {}
        m_stepValues[stepName][1] = 0
        m_stepValues[stepName][2] = 0
    end

    local curTick = GetProtoWriter():GetTickCount()
    local dt = curTick - m_lastTick

    m_stepValues[stepName][1] = m_stepValues[stepName][1] + dt
    m_stepValues[stepName][2] = m_stepValues[stepName][2] + 1
    m_lastTick = curTick
end

function TimeProfile:funcEnd()
    m_bStart = false
end

function TimeProfile:print()
    local pFile =  io.open("timeProfile.log","a")
    if pFile then
        pFile:write("----------------------------------------\n")
        pFile:write(os.date())
        pFile:write("\n")
        
        for k, v in pairs(m_stepValues) do
            pFile:write(tostring(k).."        "..tostring(v[1]/1000).. "        "..tostring(v[2]).."\n")        
        end

        pFile:write("----------------------------------------\n")
        pFile:close()
    end 
end
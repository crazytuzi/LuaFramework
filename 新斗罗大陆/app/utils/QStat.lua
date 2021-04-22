local QStat = class("QStat")

function QStat.onPageStart(name)
    if device.platform == "android" then
        -- QStat._AndroidOnPageStart(name)
    end
end

function QStat.onPageEnd(name)
    if device.platform == "android" then
        -- QStat._AndroidOnPageEnd(name)
    end
end

function QStat._AndroidOnPageStart(name)
    local javaClassName = "cc/qidea/jsfb/Wow"
    local javaMethodName = "onPageStart"
    local javaParams = {name}
    local javaMethodSig = "(Ljava/lang/String;)V"
    luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
end

function QStat._AndroidOnPageEnd(name)
    local javaClassName = "cc/qidea/jsfb/Wow"
    local javaMethodName = "onPageEnd"
    local javaParams = {name}
    local javaMethodSig = "(Ljava/lang/String;)V"
    luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
end

function QStat._iOSOnPageStart(name)
end

function QStat._iOSOnPageEnd(name)
end


return QStat
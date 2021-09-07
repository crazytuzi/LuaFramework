-- ----------------------------------------------------------
-- 公共函数库
-- ----------------------------------------------------------
import('UnityEngine')
import('UnityEngine.UI')
import('UnityEngine.Events')

-- 初始化后由ctx.IsDebug值替换，修改debug模式请在base_setting.txt文件中修改
IS_DEBUG = true 

print = function(obj)
    if IS_DEBUG then
        Log.Debug(tostring(obj))
    end
end

if Application.platform == RuntimePlatform.IPhonePlayer or Application.platform == RuntimePlatform.OSXEditor or Application.platform == RuntimePlatform.OSXPlayer then -- ios平台对string.format做一下兼容
    _format = string.format              -- 保存一下原本的函数
    string.format = function(str, ...)
        local args = {...}
        for i = 1, math.max(4, #args) do -- 兼容4个参数，如果有特殊需求，在加大数字也可以
            args[i] = args[i] or "nil"   -- 把控参数强制换成字符串nil
        end
        return _format(str, unpack(args))
    end
end
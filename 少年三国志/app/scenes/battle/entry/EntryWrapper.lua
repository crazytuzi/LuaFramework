-- EntryWrapper

local EntryWrapper = {}

local EntryDelay = function(delay, callback)
    return function(target, frameIndex, ...)
        if frameIndex > delay then
            if not callback then
                return true
            else
                return callback(target, frameIndex - delay, ...)
            end
        end
        return false
    end
end

EntryWrapper.entryDelay = EntryDelay

return EntryWrapper
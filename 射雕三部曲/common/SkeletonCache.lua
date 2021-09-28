SkeletonCache = {
    SkeletonType = {
        E_BINARY = 0,
        E_JSON = 1,
    },
    cacheList = {
        -- {
        --     file,
        --     data,
        --     preload,
        -- }
    }
}

function SkeletonCache:getData(jsonFile,atlasFile,scale)
    for i , v in pairs(self.cacheList) do
        if v.file == jsonFile then
            return v.data
        end
    end
    -- if #self.cacheList > 50 then
    --     for i , v in pairs(self.cacheList) do
    --         if v.preload == false then
    --             sp.SkeletonExtend:releaseSkeletonData(v.data)
    --             table.remove(self.cacheList , i)
    --             break
    --         end
    --     end
    -- end
    local data = sp.SkeletonExtend:createSkeletonData(jsonFile , atlasFile , self.SkeletonType.E_BINARY , scale)
    table.insert(self.cacheList , {
        file = jsonFile,
        data = data,
        preload = false
    })
    return data
end

function SkeletonCache:preload(jsonFile,atlasFile,scale)
    for i , v in pairs(self.cacheList) do
        if v.file == jsonFile then
            v.preload = true
            return v.data
        end
    end
    local data = sp.SkeletonExtend:createSkeletonData(jsonFile , atlasFile , self.SkeletonType.E_BINARY , scale)
    table.insert(self.cacheList , {
        file = jsonFile,
        data = data,
        preload = true
    })
    return data
end

function SkeletonCache:getDataAsync(jsonFile , atlasFile , scale , cb)
    for i , v in pairs(self.cacheList) do
        if v.file == jsonFile then
            cb(v.data)
            return
        end
    end
    sp.SkeletonExtend:createDataAsyn(jsonFile , atlasFile , scale , function(data)
        for i , v in pairs(self.cacheList) do
            if v.file == jsonFile then
                sp.SkeletonExtend:releaseSkeletonData(data)
                cb(v.data)
                return
            end
        end
        table.insert(self.cacheList , {
            file = jsonFile,
            data = data,
            preload = false
        })
        cb(data)
    end)
end

function SkeletonCache:release(jsonFile)
    for i , v in pairs(self.cacheList) do
        if v.file == jsonFile then
            if v.preload then
                v.preload = false
            else
                sp.SkeletonExtend:releaseSkeletonData(v.data)
                table.remove(self.cacheList , i)
            end
            break
        end
    end
end

function SkeletonCache:createWithBinary(jsonFile,atlasFile,scale)
    return sp.SkeletonExtend:createWithData(self:getData(jsonFile ,atlasFile,scale))
end

function SkeletonCache:clear( ... )
    for i = #self.cacheList, 1, -1 do
        if not self.cacheList[i].preload then
            sp.SkeletonExtend:releaseSkeletonData(self.cacheList[i].data)
            table.remove(self.cacheList, i)
        end
    end
end
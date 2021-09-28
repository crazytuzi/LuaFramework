local storage = {}

local checkedDir = false

function storage.getRolePrefix()
    return G_PlatformProxy:getLoginServer().id .. "_" .. G_Me.userData.id 
end

function storage.path(filename)
    --todo, make subdir
    return storage.writeDir() .. "/" .. filename
end

function storage.rolePath(filename)
    --todo, make subdir
    return storage.writeDir() .. "/" .. storage.getRolePrefix() .. "_" .. filename
end

function storage.writeDir() 
    local dir =  CCFileUtils:sharedFileUtils():getWritablePath() ..  "/userdata/"
    if not checkedDir then
        if not io.exists(dir) then
            --print("create dir..." .. dir)
            FuncHelperUtil:createDirectory(dir)

        end
        checkedDir = true
    end 


    return dir
end

function storage.save(filename, data)
    io.writefile( filename, json.encode(data), "w+b" )
end



function storage.load(filename)
    local str = io.readfile(filename, "rb")
    if str ~= nil then
        return json.decode(str)
    end
    return nil
end



return storage

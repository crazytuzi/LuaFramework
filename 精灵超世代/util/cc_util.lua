-- -- 默认颜色
function setDefaultlColor()
    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)        
end

function setSimpleColor()
    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
end

local ccuiEditBoxCreate = deepCopy(ccui.EditBox.create)

ccui.EditBox.create = function(...)
    local __editbox = ccuiEditBoxCreate(...)
    __editbox:retain()
    return __editbox
end

-- 打印所有的资源
function printAllRes()
    local num = 0
    for path, _ in pairs(_game_res_all) do 
        print(path)
        num = num + 1
    end
    print("资源总量:", num)
end

-- 写入所有的资源到文件
function writeAllRes()
    local file = io.open("all_res.txt", "w")
    local num = 0
    for path, _ in pairs(_game_res_all) do 
        print(path)
        num = num + 1
        file:write(path.."\n")
    end
    print("资源总量:", num)
    file:close()
end
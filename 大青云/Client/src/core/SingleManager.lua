--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/6/20
-- Time: 11:22
-- 单体管理器，游戏中的全局单体可以添加到本类中来进行统一的创建，更新，和释放
-- 在任何全局单体管理器中使用CSingleManager:AddSingle(objSingle，bIsFront)来注册自己,第二个参数为是不是放到最前面
_G.classlist['CSingle'] = 'CSingle'
_G.CSingle = {}
_G.CSingle.objName = 'CSingle'
function CSingle:new()
    local obj = {}
    obj.Create = CSingle.Create
    obj.Update = CSingle.Update
    obj.Destroy = CSingle.Destroy
    return obj
end

function CSingle:Create()
    return true;
end

function CSingle:Update(dwInterval)
    return true;
end

function CSingle:Destroy()
end

_G.classlist['CSingleManager'] = 'CSingleManager'
_G.CSingleManager = {}
_G.CSingleManager.objName = 'CSingleManager'
CSingleManager.setAllSingle = {}
function CSingleManager:AddSingle(objSingle, bIsFront)
    if bIsFront then
        table.insert(self.setAllSingle, objSingle, 1)
    else
        table.insert(self.setAllSingle, objSingle)
    end
end

function CSingleManager:Create()
    for i,Single in pairs(self.setAllSingle) do
        if Single.Create and not Single:Create() then
            return false
        end
    end
    return true
end

function CSingleManager:Update(dwInterval)
    for i, Single in pairs(self.setAllSingle) do
        if Single.Update then
            Single:Update(dwInterval)
        end
    end
end

function CSingleManager:Destroy()
    for i, Single in pairs(self.setAllSingle)do
        if Single.Destroy then
            Single:Destroy()
        end
    end
end
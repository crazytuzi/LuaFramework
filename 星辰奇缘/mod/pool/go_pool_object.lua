-- 对象池对象
-- @author huangyq
-- @date   160726
GoPoolObject = GoPoolObject or BaseClass()

function GoPoolObject:__init(obj, path)
    -- GameObject
    self.obj = obj

    -- 路径
    self.path = path

    -- 刷新时间
    self.time = Time.time
end

function GoPoolObject:__delete()
    local go = self.obj
    self.obj = nil
    -- Log.Error("==========================GoPoolObject:DeleteMe:" .. self.path)
    -- Log.Error(debug.traceback())
    if not BaseUtils.is_null(go) then
        GameObject.DestroyImmediate(go.gameObject)
    end
    self.path = nil
    self.time = 0
end

function GoPoolObject:GetObj()
    return self.obj
end

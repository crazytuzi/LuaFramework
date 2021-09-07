--神兽兑换
-- @author zgs
GodAnimalManager = GodAnimalManager or BaseClass(BaseManager)

function GodAnimalManager:__init()
    if GodAnimalManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    GodAnimalManager.Instance = self
    self:initHandle()
    self.model = GodAnimalModel.New()

    --神兽 精灵龙
    self.SHOWTYPE_DRAGON = 2 --3
    --神兽
    self.SHOWTYPE_GOD = 1 --1
    --珍兽
    self.SHOWTYPE_JANE = 3 --2
end

function GodAnimalManager:initHandle()
    --[[self:AddNetHandler(11300, self.on11300)--]]
    self:AddNetHandler(10524, self.on10524)
    self:AddNetHandler(10539, self.on10539)
    self:AddNetHandler(10545, self.on10545)
--[[
    EventMgr.Instance:AddListener(event_name.role_asset_change, function ()
        self:RoleAssetsListener()
    end)--]]
end

function GodAnimalManager:send10524(type)
    --Log.Error("send10524-----base_id="..id)
    Connection.Instance:send(10524, {genre = type})
end

-- function GodAnimalManager:send11303(id, num)
--     --print("·¢ËÍ11303")
--     Connection.Instance:send(11303,{["id"] = id, ["num"] = num})
-- end

function GodAnimalManager:on10524(data)
	--BaseUtils.dump(data, "On10524")
    if data.result == 1 then
        --成功
        self.model:CloseMain()
        local id = data.base_id
        local action = DramaAction.New()
        action.type = DramaEumn.ActionType.First_pet
        action.val = id
        local a = DramaGetPet.New()
        a.callback = function ()
            -- body
            a:DeleteMe()
            a = nil
        end
        a:Show(action)

    else
        --失败
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

function GodAnimalManager:send10539(id, base_id)
    Connection.Instance:send(10539, { id = id, base_id = base_id })
end

function GodAnimalManager:on10539(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        local id = data.base_id
        local action = DramaAction.New()
        action.type = DramaEumn.ActionType.First_pet
        action.val = id
        local a = DramaGetPet.New()
        a.callback = function ()
            -- body
            a:DeleteMe()
            a = nil
        end
        a:Show(action)
    end
end

function GodAnimalManager:send10545(base_id)
    --Log.Error("send10545-----base_id="..id)
    Connection.Instance:send(10545, {base_id = base_id})
end

-- function GodAnimalManager:send11303(id, num)
--     --print("·¢ËÍ11303")
--     Connection.Instance:send(11303,{["id"] = id, ["num"] = num})
-- end

function GodAnimalManager:on10545(data)
    --BaseUtils.dump(data, "On10545")
    if data.result == 1 then
        --成功
        self.model:CloseMain()
        local id = data.base_id
        local action = DramaAction.New()
        action.type = DramaEumn.ActionType.First_pet
        action.val = id
        local a = DramaGetPet.New()
        a.callback = function ()
            -- body
            a:DeleteMe()
            a = nil
        end
        a:Show(action)

    else
        --失败
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
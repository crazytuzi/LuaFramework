-- @author 黄耀聪
-- @date 2016年9月18日

PortraitEumn = PortraitEumn or {}

PortraitEumn.Type = {
    Hair = 1,
    Face = 2,
    Bg = 3,
    Wear = 4,
    photoFrame = 5,
    photoDecorate = 6,
}

PortraitManager = PortraitManager or BaseClass(BaseManager)

function PortraitManager:__init()
    if PortraitManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    PortraitManager.Instance = self

    self.model = PortraitModel.New()
    self.updateEvent = EventLib.New()
    self:TempLoad()
    self.standarSize = 180

    self.typeFileList = {
        [PortraitEumn.Type.Hair] = {
            [1] = AssetConfig.head_custom_hair_male,
            [0] = {
                AssetConfig.head_custom_hair_female_1,
                AssetConfig.head_custom_hair_female_2
            }
        },
        [PortraitEumn.Type.Face] = {
            [1] = {
                AssetConfig.head_custom_face_male_1,
                AssetConfig.head_custom_face_male_2
            },
            [0] = {
                AssetConfig.head_custom_face_female_1,
                AssetConfig.head_custom_face_female_2
            }
        },
        [PortraitEumn.Type.Bg] = {[0] = AssetConfig.head_custom_bg, [1] = AssetConfig.head_custom_bg},
        -- [PortraitEumn.Type.Wear] = {[0] = {AssetConfig.head_custom_wear,[1] = AssetConfig.head_custom_wear},
        [PortraitEumn.Type.Wear] = {[0] = {AssetConfig.head_custom_wear1,AssetConfig.head_custom_wear2}, [1] = {AssetConfig.head_custom_wear1,AssetConfig.head_custom_wear2}},

        [PortraitEumn.Type.photoFrame] = {[0] = AssetConfig.head_custom_photoframe,[1] = AssetConfig.head_custom_photoframe},
        [PortraitEumn.Type.photoDecorate] = {[0] = AssetConfig.head_custom_photoframe,[1] = AssetConfig.head_custom_photoframe},
    }
    -- self.standardScale = {
    --     1.25,       -- 发型
    --     1.25,       -- 脸型
    --     1.5,        -- 背景   -- 120
    --     1,          -- 装饰
    --     2.43,          --相框
    -- }

    -- 以180为标准统一放缩,表里的位置偏移也根据180度里面为基准调节的
    self.standardScale = {
        2.5,       -- 发型
        2.5,       -- 脸型
        3,        -- 背景   -- 120
        2,          -- 装饰
        10.3,--((self.standarSize + self.standarSize*(0.112))/20),          --相框
        3.2,--(80/100) --(((self.standarSize+ self.standarSize*(0.112))/80) + ((self.standarSize*1.5 - self.standarSize)/80)),       -- 相框装饰

    }

    self:InitHandler()
end

function PortraitManager:__delete()
end

function PortraitManager:InitHandler()
    self:AddNetHandler(17300, self.on17300)
    self:AddNetHandler(17301, self.on17301)
    self:AddNetHandler(17302, self.on17302)
    self:AddNetHandler(17303, self.on17303)
    self:AddNetHandler(17304, self.on17304)
    self:AddNetHandler(17305, self.on17305)
    self:AddNetHandler(17306, self.on17306)
end

function PortraitManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

-- 请求头像界面
function PortraitManager:send17300()
    Connection.Instance:send(17300, {})
end

function PortraitManager:on17300(data)
    local model = self.model
    model.id_now = data.id_now
    model.frame_id_now = data.frame_id_now
    model.head = model.head or {}

    model.headFrameList = data.head_frame

    if data.frame_id_now ~= 0 then
        for i,v in ipairs(data.head) do
            v.list[#v.list + 1] = {}
            v.list[#v.list].type = 5
            v.list[#v.list].num = data.frame_id_now
        end
    end

    local tab = {}
    for _,v in ipairs(data.head) do
        tab[v.id] = v
    end
    for _,v in pairs(tab) do
        model.head[v.id] = v
    end
    for k,_ in pairs(model.head) do
        model.head[k] = tab[k]
    end
    model.gold = data.gold
    self.updateEvent:Fire()

    local roleData = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id)
    if model.id_now ~= nil and model.id_now > 0 then
        model.portraitData[key] = model.portraitData[key] or {list = {}, update_time = BaseUtils.BASE_TIME}
        local info = model.portraitData[key]
        for k,v in pairs(model.head[model.id_now].list) do
            info.list[v.type] = v.num
        end
    else
        model.portraitData[key] = nil
    end
    EventMgr.Instance:Fire(event_name.custom_portrait_update, roleData.id, roleData.platform, roleData.zone_id)
end

-- 购买
function PortraitManager:send17301(id, list)
    local dat = {id = id, list = list}
    Connection.Instance:send(17301, dat)
end

function PortraitManager:on17301(data)
    -- BaseUtils.dump(data, "接收17301")
    -- local model = self.model
    -- model.head = model.head or {}
    -- model.head[data.id] = data
    -- self.updateEvent:Fire()
end

-- 使用头像
function PortraitManager:send17302(id)
    Connection.Instance:send(17302, {id = id})
end

function PortraitManager:on17302(data)
    -- BaseUtils.dump(data, "接收17302")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.id > 0 then
        self.model.id_now = data.id
        self.updateEvent:Fire()
    end

    local roleData = RoleManager.Instance.RoleData
    local model = self.model
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id)
    if model.id_now ~= nil and model.id_now > 0 then
        model.portraitData[key] = model.portraitData[key] or {list = {}, update_time = BaseUtils.BASE_TIME}
        local info = model.portraitData[key]
        for k,v in pairs(model.head[model.id_now].list) do
            info.list[v.type] = v.num
        end
    else
        model.portraitData[key] = nil
    end
    EventMgr.Instance:Fire(event_name.custom_portrait_update, roleData.id, roleData.platform, roleData.zone_id)
end

-- 查看头像
function PortraitManager:send17304(rid, platform, zone_id)
    -- print(debug.traceback())
    -- print("=====================================================================================17304")
    local dat = {rid = rid, platform = platform, zone_id = zone_id}
    Connection.Instance:send(17304, dat)
end

function PortraitManager:on17304(data)
    local key = BaseUtils.Key(data.rid, data.platform, data.zone_id)
    local model = self.model
    -- BaseUtils.dump(data,"17304================================================================================================" .. #data.list)
    if #data.list ~= 0 then

        model.portraitData = model.portraitData or {}

        local dat = {}
        for _,v in pairs(data.list) do
            dat[v.type] = v.num
        end

        model.portraitData[key] = model.portraitData[key] or {list = {}}
        local tab = model.portraitData[key]
        tab.update_time = BaseUtils.BASE_TIME
        for k,v in pairs(dat) do
            tab.list[k] = v
        end
        for k,v in pairs(tab.list) do
            tab.list[k] = dat[k]
        end
        EventMgr.Instance:Fire(event_name.custom_portrait_update, data.rid, data.platform, data.zone_id)
    end

    model.headCatchList[key] =  nil
end

-- 只保存5分钟，过后再调用该函数会再次请求自定义头像数据，记得监听事件 event_name.custom_portrait_update，以实时更新
function PortraitManager:GetInfos(rid, platform, zone_id)
    return self.model:GetInfos(rid, platform, zone_id)
end

function PortraitManager:TempLoad()
    local func = function()
    end
    self.assetWrapper = AssetBatchWrapper.New()
    local list = {
        {file = AssetConfig.headslot, type = AssetType.Main},
        {file = AssetConfig.portrait_textures, type = AssetType.Dep},
    }
    self.assetWrapper:LoadAssetBundle(list, func)
end

function PortraitManager:GetPrefab(file)
    if self.assetWrapper ~= nil then
        return self.assetWrapper:GetMainAsset(file)
    else
        return nil
    end
end

function PortraitManager:RequestInitData()
    math.randomseed(BaseUtils.BASE_TIME)
    self.model:ReloadData()
    self:send17300()
end

function PortraitManager:send17303(id)
    Connection.Instance:send(17303, {id = id})
end

function PortraitManager:on17303(data)
end

function PortraitManager:GetHeadcustomSprite(type, sex, res)
    local type = tonumber(type)
    local sex = tonumber(sex)
    local id = tonumber(res)
    if type == PortraitEumn.Type.Hair then
        if sex == 1 then
            return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex], res)
        else
            if id < 21500 then
                return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex][1], res)
            else
                return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex][2], res)
            end
        end
    elseif type == PortraitEumn.Type.Face then
        if sex == 1 then
            if id < 10009 then
                return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex][1], res)
            else
                return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex][2], res)
            end
        else
            if id < 11009 then
                return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex][1], res)
            else
                return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex][2], res)
            end
        end
    elseif type == PortraitEumn.Type.Wear then
        if sex == 1 then
            if id < 31009 then
                return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex][1], res)
            else
                return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex][2], res)
            end
        else
            if id < 31009 then
                return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex][1], res)
            else
                return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex][2], res)
            end
        end
    else
        return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex], res)
    end
end

function PortraitManager:GetHeadcustomExcessSprite(type,sex,res)
    if type == PortraitEumn.Type.photoFrameExcess then
        return PreloadManager.Instance:GetSprite(self.typeFileList[type][sex], res)
    end
end

function PortraitManager:send17305(id)
    Connection.Instance:send(17305, {id = id})
end

function PortraitManager:on17305(data)
end


function PortraitManager:send17306(id)
    Connection.Instance:send(17306, {id = id})
end

function PortraitManager:on17306(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.id == 0 then
        self.model.frame_id_now = nil
    end
    self.model.frame_id_now = data.id
    self.updateEvent:Fire()


    for k,v in pairs(self.model.head) do
        v.list[5] = {}
        v.list[5].type = 5
        v.list[5].num = data.id
    end

     self.updateEvent:Fire()
    local roleData = RoleManager.Instance.RoleData
    local model = self.model
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id)
    if model.id_now ~= nil and model.id_now > 0 then
        model.portraitData[key] = model.portraitData[key] or {list = {}, update_time = BaseUtils.BASE_TIME}
        local info = model.portraitData[key]
        for k,v in pairs(model.head[model.id_now].list) do
            info.list[v.type] = v.num
        end
    else
        model.portraitData[key] = nil
    end
    EventMgr.Instance:Fire(event_name.custom_portrait_update, roleData.id, roleData.platform, roleData.zone_id)
end

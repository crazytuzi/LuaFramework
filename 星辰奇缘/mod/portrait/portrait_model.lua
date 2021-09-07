-- @author 黄耀聪
-- @date 2016年9月18日

PortraitModel = PortraitModel or BaseClass(BaseModel)

function PortraitModel:__init()
    self.portraitClassList = {
        [1] = {name = TI18N("发型"), icon = "Hair", type = 1},
        [2] = {name = TI18N("脸部"), icon = "Face", type = 2},
        [3] = {name = TI18N("背景"), icon = "Image", type = 3},
        [4] = {name = TI18N("装饰"), icon = "Wear", type = 4},
        [5] = {name = TI18N("相框"),type = 5},
    }

    self.classList = {}

    self.portraitData = {}
    self.photoFrameData = {}
    --这个列表储存已发送的人物信息,避免同个头像的多个iten一直重复请求数据
    self.headCatchList = {}
    self.headFrameList = {}
end

function PortraitModel:__delete()
end

function PortraitModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = PortraitWindow.New(self)
    end
    self.mainWin:Open(args)
end

-- 只保存5分钟，5分钟再调用该函数会再次请求自定义头像数据，记得监听事件 event_name.custom_portrait_update，以实时更新
function PortraitModel:GetInfos(rid, platform, zone_id)
    local tab = self.portraitData[BaseUtils.Key(rid, platform, zone_id)] or {list = nil, update_time = 0}
    local key = BaseUtils.Key(rid, platform, zone_id)
    local isSend = false

    if BaseUtils.BASE_TIME - tab.update_time > 10 then
        if self.headCatchList[key] == nil then
            PortraitManager.Instance:send17304(rid, platform, zone_id)
            self.headCatchList[key] = 1
        end

    end
    return tab.list
end

function PortraitModel:ReloadData()
    self.lastSelect = nil
    self.lastTimeSelect = nil
    self.classList = {}
    for k,v in pairs(DataHead.data_sex[2]) do
        self.classList[v[1]] = self.classList[v[1]] or {}
        if v[1] == PortraitEumn.Type.photoFrame  then
            if DataHead.data_photoframe[string.format("%s_%s", v[1], v[2])].active == 1 then
                self.classList[v[1]][v[2]] = DataHead.data_photoframe[string.format("%s_%s", v[1], v[2])]
            end
        elseif v[1] ~= PortraitEumn.Type.photoFrame and v[1] ~= PortraitEumn.Type.photoDecorate then
            self.classList[v[1]][v[2]] = DataHead.data_res_config[string.format("%s_%s", v[1], v[2])]
        end
    end
    for k,v in pairs(DataHead.data_sex[RoleManager.Instance.RoleData.sex]) do
        self.classList[v[1]] = self.classList[v[1]] or {}
        if v[1] == PortraitEumn.Type.photoFrame  then
            if DataHead.data_photoframe[string.format("%s_%s", v[1], v[2])].active == 1 then
                self.classList[v[1]][v[2]] = DataHead.data_photoframe[string.format("%s_%s", v[1], v[2])]
            end
        elseif v[1] ~= PortraitEumn.Type.photoFrame and v[1] ~= PortraitEumn.Type.photoDecorate then
            self.classList[v[1]][v[2]] = DataHead.data_res_config[string.format("%s_%s", v[1], v[2])]
        end
    end
    -- BaseUtils.dump(self.classList,"我的数据啊哈哈哈哈================================================================")
    -- for k,v in pairs(DataHead.data_res_config) do
    --     if v.sex == 2 or v.sex == sex then
    --         self.classList[v.type] = self.classList[v.type] or {}
    --         self.classList[v.type][v.num] = v
    --     end
    -- end
end

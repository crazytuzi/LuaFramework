--
-- Author: LaoY
-- Date: 2018-07-06 15:13:58
-- 资源管理器

LuaResourceManager = LuaResourceManager or class("LuaResourceManager", BaseManager)

local table_insert = table.insert
local table_remove = table.remove

local LoadState = {
    Wait = 1,
    Loading = 2,
    Finish = 3,
}

LuaResourceManager.ExecuteFrequence = 1;
LuaResourceManager.LowExecuteFrequence = 1;
LuaResourceManager.elapse = 0;

function LuaResourceManager:ctor()
    LuaResourceManager.Instance = self
    -- 引用列表
    self.ref_list = {}
    self.cls_ref_list = {}

    self.last_add_ref_ms_time = 0

    -- 场景引用列表 整个场景一起管理
    self.scene_ref_list = {}

    self.load_image_list = {}
    self.load_text_font_list = {}

    self.start_load_time = 0
    self.load_state = LoadState.Finish

    -- 加载优化 加载错误的资源列表
    self.error_load_list = {}
    -- 同时加载资源的协程数量
    self.use_coroutine = {}
    -- for i = 1, AppConfig.coroutine_count do
    for i = 1, 15 do
        self.use_coroutine[i] = false
    end

    -- 缓存单个资源实例化多个对象的源对象
    self.gameObject_list = {}

    --静默下载
    self.down_load_id = 0
    self.is_can_down_load = nil         -- 是否能下载 默认不可以下载
    self.is_can_down_load_ness = nil    -- 是否能下载UI等必须资源
    -- 需要下载的数量
    self.down_load_all_count = self:GetDownLoadCount()
    self.down_load_cur_count = self.down_load_all_count
    self.down_load_call_back_list = {}  -- 下载回调
    self.down_load_state_list = {}        -- 下载状态 lua这边保存一份
    self.down_load_jump_list = {}        -- 插队下载管理

    self:SetLuaCallBack()
    self:SetDownLoadState(false)

    self.check_frame_count = 0
    UpdateBeat:Add(self.Update, self, 4)

    self.FinishWaitList = {};
    self.LowFinishWaitList = {};

    self:SetCoroutineCount(100)
    silenceMgr.downLoadSpeed = 8096

    if AppConfig.engineVersion >= 2 then
        silenceMgr.downLoadSpeed = 8096
    end

    if AppConfig.engineVersion >= 9 then
        -- local function start_download_callback(abName,abSize)
        --     print("===============abName,abSize=============",abName,abSize)
        --     GlobalEvent:Brocast(EventName.StartDownLoadInfo,abName,abSize)
        -- end
        -- silenceMgr.start_download_callback = start_download_callback
    end

    -- 加載引用計數
    self.load_refs = {}

    self:Reset()
end

function LuaResourceManager:Reset()
    -- 等待加载队列
    self.load_sequence = {}
    for k, level in pairs(Constant.LoadResLevel) do
        self.load_sequence[level] = {}
    end

    -- 请求加载同一个资源的回调信息等
    self.load_map = {}
end

function LuaResourceManager:dctor()
end

function LuaResourceManager:GetInstance()
    if not LuaResourceManager.Instance then
        LuaResourceManager.new()
    end
    return LuaResourceManager.Instance
end

-- 设置下载回调
function LuaResourceManager:SetLuaCallBack()
    local function callBack(abName, count)
        Yzprint('--download callback======>', abName, count)
        self:FinishDownLoad(abName, count)
        if count <= 0 then
            for abName,v in pairs(self.down_load_call_back_list) do
                self:FinishDownLoad(abName, count)
            end
            self.down_load_call_back_list = {}
        end
    end
    silenceMgr:SetLuaCallBack(callBack)
end

-- 获取静默下载数量
function LuaResourceManager:GetDownLoadCount()
    return silenceMgr:GetDownLoadCount()
end

function LuaResourceManager:GetDownLoadFileSize(abName)
    if AppConfig.engineVersion >= 8 then
        return silenceMgr:GetDownLoadFileSize(abName)
    else
        return 0
    end
end

-- 是否在靜默下載列表
function LuaResourceManager:IsInDownLoadList(abName)
    if self.down_load_cur_count <= 0 then
        return false
    end
    return silenceMgr:IsInDownLoadList(abName, true)
end

-- 设置下载状态
function LuaResourceManager:SetDownLoadState(flag)
    if self.down_load_cur_count <= 0 then
        return
    end
    if self.is_can_down_load == flag then
        return
    end
    self.is_can_down_load = flag
    silenceMgr.is_can_down_necessary = flag
    silenceMgr.is_can_down_load = flag
end

-- 是否在下载插队列表
function LuaResourceManager:IsInDownLoading(abName)
    -- for k,v in pairs(self.down_load_state_list) do
    --  if v then
    --      return true
    --  end
    -- end
    -- return false
    if abName then
        return self.down_load_state_list[abName]
    end
    return not table.isempty(self.down_load_state_list)
end

-- 添加入下载列表
function LuaResourceManager:AddDownLoadList(cls, abName, callBack, load_level)
    load_level = load_level or Constant.LoadResLevel.High
    self.down_load_call_back_list[abName] = self.down_load_call_back_list[abName] or {}
    local new_down_load_data = {
        cls = cls,
        abName = abName,
        callBack = callBack,
        load_level = load_level,
    }
    table_insert(self.down_load_call_back_list[abName], new_down_load_data)

    local need_sort = false
    if not self:IsInDownLoading(abName) then
        local is_in_jump_list, index = self:IsInJumpList(abName)
        -- Yzprint('<color=#9c48f2>--LaoY LuaResourceManager.lua,line 148--',abName, callBack, load_level,is_in_jump_list,index,"</color>")
        -- logWarn('--LaoY LuaResourceManager.lua,line 148--', abName, load_level, is_in_jump_list, self:IsInDownLoadList(abName))
        -- logWarn("-LaoY LuaResourceManager.lua,line 152--", self.down_load_cur_count, #self.down_load_jump_list, self:IsInDownLoading())
        -- for i, v in ipairs(self.down_load_jump_list) do
        --     print(i, v.abName, v.load_level, v.id)
        -- end
        -- Yzprint('--LaoY LuaResourceManager.lua,line 156--')
        -- Yzdump(self.down_load_state_list, "self.down_load_state_list")

        if AppConfig.writeLog then
            DebugManager.DebugLog(string.format("[add_download_list] file = %s,is_in_jump_list = %s",abName,tostring(is_in_jump_list)))
        end

        if not is_in_jump_list then
            self.down_load_id = self.down_load_id + 1
            local down_load_jump_data = { abName = abName, load_level = load_level, id = self.down_load_id }
            table_insert(self.down_load_jump_list, down_load_jump_data)
            need_sort = true
        else
            local down_load_jump_data = self.down_load_jump_list[index]
            if down_load_jump_data and down_load_jump_data.load_level > load_level then
                down_load_jump_data.load_level = load_level
                need_sort = true
            end
        end
    end

    if need_sort then
        local function sortFunc(a, b)
            if a.load_level == b.load_level then
                return a.id < b.id
            else
                return a.load_level < b.load_level
            end
        end
        table.sort(self.down_load_jump_list, sortFunc)
    end

    if not self:IsInDownLoading() then
        self:StartDownLoad()
    end
end

function LuaResourceManager:IsInJumpList(abName)
    for k, down_load_jump_data in pairs(self.down_load_jump_list) do
        if down_load_jump_data.abName == abName then
            return true, k
        end
    end
    return false
end

-- 下载列表移除不再引用的资源，比如已加入lua的下载列表，还未下载就删除了类引用，就把该下载从列表中删除
function LuaResourceManager:RemoveDownLoadList()
    local check_count = 0
    for abName, down_load_data_list in pairs(self.down_load_call_back_list) do
        local del_tab = {}
        local len = #down_load_data_list
        for i = 1, len do
            local down_load_data = down_load_data_list[i]
            if down_load_data.cls.is_dctored then
                del_tab[#del_tab + 1] = i
                check_count = check_count + 1
            end
        end
        table.RemoveByIndexList(down_load_data_list, del_tab)
        if table.isempty(down_load_data_list) then
            self.down_load_call_back_list[abName] = nil
        end
    end

    if check_count == 0 then
        return
    end

    local del_tab = {}
    local len = #self.down_load_jump_list
    for i = 1, len do
        local down_load_jump_data = self.down_load_jump_list[i]
        if not self.down_load_call_back_list[down_load_jump_data.abName] then
            -- print('--LaoY LuaResourceManager.lua,line 224--', down_load_jump_data.abName)
            DebugManager.LoadLog(string.format("[remove_download] file = %s,time = %s",abName,Time.time))
            del_tab[#del_tab + 1] = i
        end
    end
    table.RemoveByIndexList(self.down_load_jump_list, del_tab)
end

function LuaResourceManager:FinishDownLoad(abName, count)
    self.down_load_cur_count = count
    local down_load_data_list = self.down_load_call_back_list[abName]
    if not table.isempty(down_load_data_list) then
        local del_tab = {}
        local len = #down_load_data_list
        for i = len, 1, -1 do
            local down_load_data = down_load_data_list[i]
            -- local func_name = down_load_data.func_name
            -- local cls = down_load_data.cls
            -- local abName = down_load_data.abName
            -- local assetName = down_load_data.assetName
            -- local callBack = down_load_data.callBack
            -- local load_level = down_load_data.load_level
            -- local is_cache = down_load_data.is_cache
            -- local ignore_to_ref = down_load_data.ignore_to_ref
            -- local is_unload_imm = down_load_data.is_unload_imm

            -- 倒序插入加载列表首部，保证加载顺序和预期一致
            logWarn('<color=#9c48f2>--LaoY LuaResourceManager.lua,line 244--', abName, i, "</color>", down_load_data.cls.is_dctored, down_load_data.callBack)
            if not down_load_data.cls.is_dctored and down_load_data.callBack then
                down_load_data.callBack(abName)
            end
        end
        self.down_load_call_back_list[abName] = nil
    end

    -- 如果插队队列已有，需要删除
    local is_in_jump_list, index = self:IsInJumpList(abName)
    if index then
        table.remove(self.down_load_jump_list, index)
    end

    -- 如果下载完成的资源刚好是 已经插队的资源，执行下一个插队资源
    -- 不可以等到下一帧，否则其他不急着下载的资源会占用下载线程
    logWarn('<color=#9c48f2>--LaoY LuaResourceManager.lua,line 251--', abName, "***----22</color>")
    -- logWarn("LuaResourceManager:FinishDownLoad 1")
    if self.down_load_state_list[abName] then
        self.down_load_state_list[abName] = nil
        self:StartDownLoad()
    end
    -- logWarn("LuaResourceManager:FinishDownLoad 2")
end

function LuaResourceManager:StartDownLoad()
    -- 当前没有可以下载的数量
    -- 或者已经插队的资源正在下载中
    if self.down_load_cur_count <= 0 or self:IsInDownLoading() then
        return
    end
    if #self.down_load_jump_list > 0 then
        while (#self.down_load_jump_list > 0) do
            local down_load_jump_data = table_remove(self.down_load_jump_list, 1)
            if self:IsInDownLoadList(down_load_jump_data.abName) then
                self.down_load_state_list[down_load_jump_data.abName] = Time.time
                silenceMgr:AddJumpList(down_load_jump_data.abName, down_load_jump_data.load_level)
                break
            else
                self:FinishDownLoad(down_load_jump_data.abName, self.down_load_cur_count)
            end
        end
        return
    end

    -- 当前如果没有在加载资源，静默下载的资源开始下载
    -- if AppConfig.IsSilentDownLoad and self:IsUseCoroutine() then
    if AppConfig.IsSilentDownLoad then
        self:SetDownLoadState(true)
    end
end

function LuaResourceManager:Update()
    -- 2000毫秒内 没有新加引用再删除
    -- local pass_ms = os.clock() - self.last_add_ref_ms_time
    -- if pass_ms > 4000 then
    self.check_frame_count = self.check_frame_count + 1
    if self.check_frame_count >= AppConfig.CheckUnUseAssetFrameCount then
        self.check_frame_count = 0
        self:CheckUnUseAssset()
    end
    -- end

    self:LoadNext()

    LuaResourceManager.elapse = LuaResourceManager.elapse + 1;
    if (LuaResourceManager.elapse % LuaResourceManager.ExecuteFrequence == 0) then
        self:HandleFinished();
    end

    if (LuaResourceManager.elapse % LuaResourceManager.LowExecuteFrequence == 0) then
        self:HandleLowFinished();
    end

    self:StartDownLoad()

    if Time.time - LuaResourceManager.DebugLastTime > 60 * 6 then
        self:Debug()
    end
end

local function PopCallBack(list)
    if table.isempty(list) then
        return
    end
    local callBack = table.remove(list, 1);
    while (callBack and not callBack()) do
        callBack = table.remove(list, 1)
    end
end

function LuaResourceManager:HandleFinished()
    -- if self.FinishWaitList and #self.FinishWaitList > 0 then
    --     -- local callBack = self.FinishWaitList[1];
    --     local callBack = table.remove(self.FinishWaitList, 1);
    --     callBack();
    -- end
    PopCallBack(self.FinishWaitList)
end

function LuaResourceManager:HandleLowFinished()
    -- if self.LowFinishWaitList and #self.LowFinishWaitList > 0 then
    --     -- local callBack = self.LowFinishWaitList[1];
    --     local callBack = table.remove(self.LowFinishWaitList, 1);
    --     callBack()
    -- end
    PopCallBack(self.LowFinishWaitList)
end

function LuaResourceManager:CheckUnUseAssset(force)
    -- 不能强制清除
    if force then
        return
    end
    -- ab包引用资源清理
    local del_tab
    local cur_time = Time.time
    for abName, ref_info in pairs(self.ref_list) do
        -- 没有引用&&最后一次使用的时间是10秒前
        local count = ref_info.auto_ref:GetReferenceCount()
        local load_ref = self:GetLoadRef(abName)
        if count <= 0 and load_ref:GetReferenceCount() <= 0 and (force or cur_time - ref_info.last_time > 6) then
            local referenceCount = ref_info.ref:GetReferenceCount()

            self:UnloadPrefab(abName, referenceCount)

            ref_info.auto_ref:Clear()
            ref_info.ref:Clear()
            ref_info.last_time = 0
            del_tab = del_tab or {}
            del_tab[#del_tab + 1] = abName

            -- 改为N帧删除一个引用 N是配置
            -- if not force then
            --     break
            -- end
        end
    end

    if not table.isempty(del_tab) then
        for k, abName in pairs(del_tab) do
            self.ref_list[abName] = nil
        end
    end
end

function LuaResourceManager:CheckUnLoadSceneAssset()
    local cur_scene_id = SceneManager:GetInstance():GetSceneId()
    local preLoadingId = LoadingCtrl:GetInstance().preLoadingId

    -- local cur_scene_type = SceneConfigManager:GetInstance():GetSceneType(cur_scene_id)
    -- local cur_scene_is_city = cur_scene_type == SceneConstant.SceneType.City or cur_scene_type == SceneConstant.SceneType.Feild

    -- local last_scene_id = SceneManager:GetInstance():GetLastSceneId()
    -- local last_scene_type = SceneConfigManager:GetInstance():GetSceneType(last_scene_id)
    -- local last_scene_is_city = last_scene_type == SceneConstant.SceneType.City or last_scene_type == SceneConstant.SceneType.Feild
    -- local is_unload_last_scene = last_scene_is_city == cur_scene_is_city


    local del_tab = {}
    for scene_id, info in pairs(self.scene_ref_list) do
        if not table.isempty(info.res_list) then
            if cur_scene_id ~= scene_id and preLoadingId ~= scene_id then
                for abName, ref_info in pairs(info.res_list) do
                    local load_ref = self:GetLoadRef(abName)
                    if load_ref:GetReferenceCount() <= 0 then
                        local referenceCount = ref_info.ref:GetReferenceCount()

                        self:UnloadPrefab(abName, referenceCount)

                        ref_info.auto_ref:Clear()
                        ref_info.ref:Clear()
                        ref_info.last_time = 0
                        del_tab[scene_id] = del_tab[scene_id] or {}
                        del_tab[scene_id][#del_tab[scene_id] + 1] = abName
                    end
                end
            end
        end
    end

    if table.isempty(del_tab) then

    else
        for scene_id, list in pairs(del_tab) do
            for index, abName in pairs(list) do
                self.scene_ref_list[scene_id].res_list[abName] = nil
            end
            -- 不需要再额外清除地图缓存，资源加载机制统一缓存
            -- MapLayer:GetInstance():ClearCacheMapSprite(scene_id)
        end
    end

    self:Debug()
end

function LuaResourceManager:AddReference(cls, abName, assetName, count)
    -- 开发状态才需要
    if AppConfig.Debug and not isClass(cls) then
        assert(false, "incoming quotation is null")
        return
    end
    count = count or 1
    self.cls_ref_list[cls] = self.cls_ref_list[cls] or {}
    self.cls_ref_list[cls][abName] = self.cls_ref_list[cls][abName] or {}
    local t = self.cls_ref_list[cls][abName]
    t[#t + 1] = assetName

    local ref_info = self.ref_list[abName]
    if not ref_info then

        -- 新加一个引用
        ref_info = {
            -- 当前引用的数量
            auto_ref = Ref(abName),
            -- 清除周期引用总数
            ref = Ref(abName),
            -- 最后一次引用的时间
            last_time = 0,
        }
        self.ref_list[abName] = ref_info
    end
    ref_info.auto_ref:Retain(count)
    -- 加载完后再加一
    -- ref_info.ref:Retain(count)
    ref_info.last_time = Time.time
end

function LuaResourceManager:RemoveReference(cls, abName, assetName)
    if self.cls_ref_list[cls] and self.cls_ref_list[cls][abName] then
        for k, _assetName in pairs(self.cls_ref_list[cls][abName]) do
            if _assetName == assetName then
                table.remove(self.cls_ref_list[cls][abName], k)
                break
            end
        end
    end

    self:ReleaseReference(abName, 1)
end

-- 地图资源
function LuaResourceManager:AddSceneReference(scene_id, abName)
    if not self.scene_ref_list[scene_id] then
        self.scene_ref_list[scene_id] = {}
        local scene_type = SceneConfigManager:GetInstance():GetSceneType(scene_id)
        self.scene_ref_list[scene_id].scene_type = scene_type
        self.scene_ref_list[scene_id].res_list = {}
    end
    -- 加载地图都不释放资源
    local ref_info = self.scene_ref_list[scene_id].res_list[abName]
    if not ref_info then

        ref_info = {
            abName = abName,
            -- 当前引用的数量
            auto_ref = Ref(abName),
            -- 清除周期引用总数
            ref = Ref(abName),
            -- 最后一次引用的时间
            last_time = 0,
        }
        self.scene_ref_list[scene_id].res_list[abName] = ref_info
    end
    ref_info.auto_ref:Retain(count)
    ref_info.ref:Retain(count)
    ref_info.last_time = Time.time
end

function LuaResourceManager:ClearClass(cls)
    self:ClearImage(cls)
    if not self.cls_ref_list[cls] then
        return
    end
    for abName, list in pairs(self.cls_ref_list[cls]) do
        for k, assetName in pairs(list) do
            self:RemoveLoadMap(abName, assetName, cls)
        end
        local count = #list

        self:ReleaseReference(abName, count)
    end
    self.cls_ref_list[cls] = nil
    self:RemoveLoadSequence()
    self:RemoveDownLoadList()
end

function LuaResourceManager:DebugAbNameRef(abName)
    abName = GetRealAssetPath(abName)
    local t = {}
    for cls,cls_ref_list in pairs(self.cls_ref_list) do
        for _abName, list in pairs(cls_ref_list) do
            if _abName == abName then
                t[cls.__cname] = cls
            end
        end
    end

    Yzprint('--LaoY LuaResourceManager.lua,line 566--',abName)
    for cname,cls in pairs(t) do
        Yzprint('--LaoY LuaResourceManager.lua,line 567--',cname)
    end
end

function LuaResourceManager:ReleaseReference(abName, count)
    local ref_info = self.ref_list[abName]
    if ref_info then
        ref_info.auto_ref:Release(count)
    end
end

-- 设置加载资源协程数量
function LuaResourceManager:SetCoroutineCount(count)
    count = count or 2
    count = count <= 1 and 2 or count
    resMgr.MAX_LOADING_QUEUE = count
end

function LuaResourceManager:LoadPanel(cls, abName, assetName, callBack)
    -- resMgr:LoadPanel(abName,assetName,callBack,is_cache)
    self:LoadRes("LoadPanel", cls, abName, assetName, callBack, Constant.LoadResLevel.Best)
end

function LuaResourceManager:LoadItem(cls, abName, assetName, callBack)
    -- resMgr:LoadItem(abName,assetName,callBack)
    self:LoadRes("LoadItem", cls, abName, assetName, callBack, Constant.LoadResLevel.Super)
end

function LuaResourceManager:GetPrefab(abName, assetName, go, callBack)
    -- resMgr:GetPrefab(abName, assetName, go, callBack)
    callBack(newObject(go))
end

function LuaResourceManager:LoadPrefab(cls, abName, assetName, callBack, ignore_pool, load_level, is_cache, is_unload_imm, is_preload)
    -- resMgr:LoadPrefab(abName,assetName,callBack)
    self:LoadRes("LoadPrefab", cls, abName, assetName, callBack, load_level, is_cache, nil, nil, is_unload_imm, is_preload)
end

function LuaResourceManager:LoadScene(cls, abName, callBack)
    self.error_load_list = {}
    resMgr:LoadScene(abName, abName, callBack)

    --self:LoadRes("LoadScene", cls, abName, abName, callback, Constant.LoadResLevel.Super)
end

function LuaResourceManager:UnloadPrefab(abName, referenceCount)
    referenceCount = referenceCount or 1
    if AppConfig.Debug then
        logWarn("ooooo清除引用:", abName, referenceCount, "\n", debug.traceback())
    end
    if self.gameObject_list[abName] then
        -- for assetName,objs in pairs(self.gameObject_list[abName]) do
        --  if objs[0] then
        --      destroy(objs[0])
        --  end
        -- end
        -- if PreloadManager.SkillList[abName] then
        --     Yzprint('--LaoY LuaResourceManager.lua,line 504--', abName)
        -- end
        self.gameObject_list[abName] = nil
    end

    if referenceCount > 0 then

        if AppConfig.writeLog then
            DebugManager.LoadLog(string.format("[release] file = %s,time = %s,referenceCount = %s",abName,Time.time,referenceCount))
        end
        resMgr:UnloadAssetBundleSync(abName, true, referenceCount)
    end
end


--[[
    @author LaoY
    @des    
    @para1  cls             使用对象的类，用于管理资源引用
    @para2  image           unity image对象
    @para3  abName          资源AB包名字，具体名字看打包规则
    @para4  assetName       资源名字，不带后缀名
    @para5  _fixed_size     是否是固定大小，nil or false默认是原图大小
    @para6  callBack        加载完的回调，nil的话自动设置图片资源
    @para7  hide_image      是否加载完后再显示,默认是
    @para8  load_level      加载优先级
    @para9  force           外部不调用
    @para10 is_cache        是否缓存
    @para11 is_unload_imm   是否马上卸载ab包(单个资源打成ab包的可以这么处理)
--]]
function LuaResourceManager:SetImageTexture(cls, image, abName, assetName, _fixed_size, callBack, hide_image, load_level, force, is_cache, is_unload_imm)
    if not abName or not assetName then
        return
    end
    hide_image = hide_image == nil and true or hide_image
    local list = { cls = cls, image = image, abName = abName, assetName = assetName,
                   _fixed_size = _fixed_size, callBack = callBack, hide_image = hide_image, load_level = load_level
    }
    if image == nil and AppConfig.Debug then
        logError('SetImageTexture image is nil , the class is ',cls.__cname,abName,assetName)
        return
    end

    self.load_image_list[cls] = self.load_image_list[cls] or {}
    self.load_image_list[cls][image] = self.load_image_list[cls][image] or {}
    for k, cur_list in pairs(self.load_image_list[cls][image]) do
        if cur_list.abName == list.abName and cur_list.assetName == list.assetName then
            return
        end
    end
    if force then
        table.insert(self.load_image_list[cls][image], 1, list)
    else
        table.insert(self.load_image_list[cls][image], list)
    end

    if not force and #self.load_image_list[cls][image] > 1 then
        return
    end
    load_level = load_level or Constant.LoadResLevel.High
    self.assetName = assetName
    if hide_image then
        SetVisible(image.gameObject, false)
    end
    local function load_call_back(uobject_list)
        if AppConfig.writeLog then
            DebugManager.LoadLog(string.format("[image][success]image = %s,abName = %s,assetName = %s,cname = %s,time = %s",tostring(image),abName,assetName,cls and cls.__cname or "",Time.time))
        end

        if cls and not cls.is_dctored and not cls.__is_clear and image and tostring(image) ~= "null" and uobject_list and uobject_list[0] then
            -- local sprite = newObject(uobject_list[0])
            local sprite = uobject_list[0]
            if hide_image then
                SetVisible(image.gameObject, true)
            end
            if callBack then
                callBack(sprite)
            else
                image.sprite = sprite
            end
            if not _fixed_size then
                image:SetNativeSize()
            end
        end
        if image and self.load_image_list[cls] and self.load_image_list[cls][image] then
            if cls.is_dctored or cls.__is_clear then
                self.load_image_list[cls] = nil
                return
            end
            table.remove(self.load_image_list[cls][image], 1)
            local next_list = table.remove(self.load_image_list[cls][image], 1)
            if next_list then
                self:SetImageTexture(next_list.cls, next_list.image, next_list.abName, next_list.assetName, next_list._fixed_size, next_list.callBack, next_list.hide_image, next_list.load_level, true)
            else
                self.load_image_list[cls][image] = nil
                image = nil
            end
        end
    end
    if AppConfig.writeLog then
        DebugManager.LoadLog(string.format("[image][success]image = %s,abName = %s,assetName = %s,cname = %s,time = %s",tostring(image),abName,assetName,cls and cls.__cname or "",Time.time))
    end
    self:LoadSprite(cls, abName, assetName, load_call_back, load_level, is_cache, is_unload_imm)
end

function LuaResourceManager:ClearImage(cls)
    self.load_image_list[cls] = nil
end

function LuaResourceManager:LoadSprite(cls, abName, assetName, callBack, load_level, is_cache, is_unload_imm)
    -- resMgr:LoadSprite(abName,{assetName},callBack,load_level)
    load_level = load_level or Constant.LoadResLevel.High
    self:LoadRes("LoadSprite", cls, abName, assetName, callBack, load_level, is_cache, nil, nil, is_unload_imm)
end

--[[
    @author LaoY
    @des    场景地图加载，其他不要用
            其他模块不要用
    @param   is_cache       是否缓存
    @param   is_unload_imm  是否马上卸载ab包(单个资源打成ab包的可以这么处理)
--]]
function LuaResourceManager:LoadSceneSprite(cls, scene_id, abName, assetName, callBack, load_level, is_cache, is_unload_imm)
    -- resMgr:LoadSprite(abName,{assetName},callBack,load_level)
    self:AddSceneReference(scene_id, abName)
    load_level = load_level or Constant.LoadResLevel.Low
    is_cache = is_cache == nil and true or is_cache
    self:LoadRes("LoadSprite", cls, abName, assetName, callBack, load_level, is_cache, true, nil, is_unload_imm)
end

function LuaResourceManager:LoadSynchronousSprite(abName, assetName)
    local object = self:GetCacheObject(abName, assetName)
    if not object then
        object = resMgr:GetSprite(abName, assetName)
        self.gameObject_list[abName] = self.gameObject_list[abName] or {}
        self.gameObject_list[abName][assetName] = object
    end
    return object
end

function LuaResourceManager:GetCacheObject(abName, assetName)
    if self.gameObject_list[abName] and self.gameObject_list[abName][assetName] then
        return self.gameObject_list[abName][assetName]
    end
    return nil
end
LuaResourceManager.fonts = {};
function LuaResourceManager:SetTextFont(cls, text, abName, assetName, callBack, load_level, is_cache, is_unload_imm)
    is_cache = is_cache or true
    assetName = assetName or abName
    if not abName:find("_font") then
        abName = abName .. "_font"
    end
    load_level = load_level or 1
    local info = { cls = cls, text = text, abName = abName, assetName = assetName, callBack = callBack, load_level = load_level }
    self.load_text_font_list[text] = self.load_text_font_list[text] or {}
    table.insert(self.load_text_font_list[text], info)
    if #self.load_text_font_list[text] > 1 then
        return
    end
    local function load_call_back(objs)
        if cls.is_dctored or not objs or not objs[0] or not text or text:IsDestroyed() then
            return
        end
        -- local obj = newObject(objs[0])
        local obj = objs[0]
        if callBack then
            callBack(obj)
        else
            text.font = obj
        end
        if text and self.load_text_font_list[text] then
            table.remove(self.load_text_font_list[text], 1)
            local next_list = table.remove(self.load_text_font_list[text], 1)
            if next_list then
                self:SetTextFont(next_list.cls, next_list.text, next_list.abName, next_list.assetName, next_list.callBack, next_list.load_level)
            else
                self.load_text_font_list[text] = nil
                text = nil
            end
        end
    end
    self:LoadFont(cls, abName, assetName, load_call_back, load_level, is_cache, is_unload_imm)
end

function LuaResourceManager:LoadFont(cls, abName, assetName, callBack, load_level, is_cache, is_unload_imm)
    -- resMgr:LoadFont(abName,{assetName},callBack,load_level)
    load_level = Constant.LoadResLevel.Urgent
    is_cache = is_cache == nil and true or is_cache
    self:LoadRes("LoadFont", cls, abName, assetName, callBack, load_level, is_cache, nil, nil, is_unload_imm)
end

function LuaResourceManager:LoadShader(cls, abName, assetName, callBack, load_level)
    -- resMgr:LoadShader("shader",name, load_call_back)
    load_level = Constant.LoadResLevel.Best
    self:LoadRes("LoadShader", cls, abName, assetName, callBack, load_level)
end

function LuaResourceManager:LoadTextAssets(cls, abName, assetName, callBack, load_level, ignore_to_ref, is_cache, is_unload_imm)
    -- resMgr:LoadShader("shader",name, load_call_back)
    load_level = load_level or Constant.LoadResLevel.Urgent
    is_cache = is_cache == nil and true or is_cache
    -- 不加入自动管理，手动额外加入场景系统管理 加个参数控制
    self:LoadRes("LoadTextAssets", cls, abName, assetName, callBack, load_level, is_cache, ignore_to_ref, nil, is_unload_imm)
end

function LuaResourceManager:LoasSound(cls, abName, assetName, callBack, load_level, is_cache, is_unload_imm)
    load_level = load_level or Constant.LoadResLevel.Super
    self:LoadRes("LoadSound", cls, abName, assetName, callBack, load_level, is_cache, nil, nil, is_unload_imm)
end

function LuaResourceManager:LoadNext()
    if self.load_state ~= LoadState.Finish and self:GetCoroutineIndex() then
        local len = #self.load_sequence
        local count = 0
        for i = 1, len do
            local list = self.load_sequence[i]
            local sequence_count = #list
            for j = 1, sequence_count do
                -- local info = table_remove(list, 1)
                local info = self:GetNextLoadRes(list)
                if info then
                    self:StartLoadRes(info.func_name, info.cls, info.abName, info.assetName, info.load_call_back, info.callBack, info.is_cache)
                    count = count + 1
                    if not self:GetCoroutineIndex() then
                        return
                    end
                else
                    break
                end
            end
            if not self:GetCoroutineIndex() then
                return
            end
        end
        if count == 0 then
            self.load_state = LoadState.Finish
        end
    end
end

function LuaResourceManager:GetNextLoadRes(list)
    local info = table_remove(list, 1)
    while (info and (info.cls.is_dctored or info.cls.__is_clear)) do
        info = table_remove(list, 1)
    end
    return info
end

-- 是否在使用协程 如果加载大于2.0秒还没有加载完的，当做加载无效的协程处理
function LuaResourceManager:IsUseCoroutine()
    local cur_time = Time.time
    for k, v in pairs(self.use_coroutine) do
        if v and cur_time - v.start_time < 2.0 then
            return true
        end
    end
    return false
end

function LuaResourceManager:GetCoroutineIndex()
    local cur_time = Time.time
    for k, v in pairs(self.use_coroutine) do
        if k <= AppConfig.coroutine_count then
            if not v or v.cls.is_dctored or cur_time - v.start_time > 3.0 then
                return k
            end
        end
    end
    return nil
end

function LuaResourceManager:IsInCoroutineLoading(abName, assetName)
    local cur_time = Time.time
    for k, v in pairs(self.use_coroutine) do
        if v and v.abName == abName and v.assetName == assetName and cur_time - v.start_time < 2.0 then
            return true
        end
    end
    return false
end

function LuaResourceManager:RemoveCoroutine(cls, abName, assetName, callBack)
    for k, v in pairs(self.use_coroutine) do
        if v and v.cls == cls and v.abName == abName and v.assetName == assetName and v.callBack == callBack then
            self.use_coroutine[k] = false
            break
        end
    end
end

--[[
    @author LaoY
    @des    
    @param   is_cache       是否缓存
    @param   is_unload_imm  是否马上卸载ab包(单个资源打成ab包的可以这么处理) 如果是缓存状态为nil，默认为true
    @param   LoadPrefab     是否预加载
--]]
function LuaResourceManager:LoadRes(func_name, cls, abName, assetName, callBack, load_level, is_cache, ignore_to_ref, is_jump, is_unload_imm, is_preload)
    -- 不存在的资源
    abName = GetRealAssetPath(abName)

    if AppConfig.Debug then
        if not iskindof(cls,"Node") 
            and not iskindof(cls,"BaseController")
            and not iskindof(cls,"BaseModel")
            and not iskindof(cls,"BaseManager") 
            and not iskindof(cls,"SceneObject")
            and not iskindof(cls,"LuaLinkImageText")
            and not iskindof(cls,"Loader")
            and not iskindof(cls,"PreloadObject") then
            local str = "Eerror usage, operation resource leaked".. cls.__cname
            logError(str)
            if Notify then
                Notify.ShowText(str)
            end
            return
        end
    end

    if AppConfig.Debug and (string.isempty(abName) or string.isempty(tostring(assetName))) then
        -- logError("加载了一个名字为空的资源",abName, assetName)
        -- traceback()
        return
    end

    if not is_preload then
        local cache_go = poolMgr:GetGameObject(cls, abName, assetName)
        if cache_go then
            callBack({ [0] = cache_go }, true)
            return
        end
    end

    -- if self.error_load_list[abName] and self.error_load_list[abName][assetName] and Time.time - self.error_load_list[abName][assetName] > 2.0 then
    --     logWarn("加载不存在的资源：", cls.__cname, abName, assetName)
    --     if callBack then
    --         callBack(nil)
    --     end
    --     return
    -- end

    load_level = load_level or Constant.LoadResLevel.High
    -- Yzprint('--LaoY LuaResourceManager.lua,line 871--',abName,cls.__cname)
    if not is_jump and self:IsInDownLoadList(abName) then
        local function call_back()
            logWarn('--LaoY LuaResourceManager.lua,line 925--',cls.__cname, abName, assetName)
            self:LoadRes(func_name, cls, abName, assetName, callBack, load_level, is_cache, ignore_to_ref, true, is_unload_imm, is_preload)
        end
        self:AddDownLoadList(cls, abName, call_back, load_level)
        DebugManager.LoadLog(string.format("[add_download] file = %s,time = %s",abName,Time.time))
        return
    end

    -- 不添加到自动管理 可能放到场景管理或者其他
    if not ignore_to_ref then
        self:AddReference(cls, abName, assetName, nil)
    end

    -- 如果已经缓存用缓存的
    if self.gameObject_list[abName] and self.gameObject_list[abName][assetName] then
        local objs = self.gameObject_list[abName][assetName]
        --if not self.FinishWaitList then
        --    self.FinishWaitList = {};
        --end
        local finish_call_back = function()
            if not cls.is_dctored then
                callBack(objs)
                return true
            end
            return false
        end
        if load_level == Constant.LoadResLevel.Urgent then
            finish_call_back()
        else

            -- 技能释放最优
            if PreloadManager.SkillList[abName] then
                if AppConfig.Debug then
                    Yzprint('--LaoY LuaResourceManager.lua,line 814--', abName, #self.FinishWaitList)
                end
                table.insert(self.FinishWaitList, 1, finish_call_back)
            else
                table.insert(self.FinishWaitList, finish_call_back)
            end
        end
        return
    end

    if self.load_state == LoadState.Finish then
        self.load_state = LoadState.Wait
    end

    if is_cache then
        is_unload_imm = is_unload_imm == nil and true or is_unload_imm
    end
    local function load_call_back(objs)
        self:LoadFinish(cls, abName, assetName, callBack, objs, ignore_to_ref, is_cache)
        if is_cache and is_unload_imm and AppConfig.is_unload_imm then
            --local function step()
            --    resMgr:UnloadAssetBundle(abName)
            --end
            --GlobalSchedule:StartOnce(step, 0.02)
        end
    end

    -- self.load_map[abName] = self.load_map[abName] or {}
    -- self.load_map[abName][assetName] = self.load_map[abName][assetName] or {}
    -- local isInLoadMap = self:IsInLoadMap(abName, assetName, cls, callBack)
    -- if not self:IsInLoadMap(abName, assetName, cls, callBack) then
    --     local t = self.load_map[abName][assetName]
    --     t[#t + 1] = { cls = cls, func = callBack, assetName = assetName }
    -- end

    -- 判断是否在加载列表 && 是否在正在加载列表
    -- local bo = self:IsInLoadSequence(abName, assetName)
    -- local is_loading = self:IsInCoroutineLoading(abName, assetName)
    -- if (not is_jump and bo) or self:IsInCoroutineLoading(abName, assetName) then
    -- if self:IsInCoroutineLoading(abName, assetName) then
    if false then

    else
        local load_info = { func_name = func_name, cls = cls, abName = abName, assetName = assetName, callBack = callBack, load_call_back = load_call_back, is_cache = is_cache }
        -- 如果是插队，不尝试加载下一个。其他地方控制
        if is_jump then
            -- 插队把已存在的队列去除
            if bo then
                self:RemoveLoadSequenceByName(abName, assetName)
            end
            table_insert(self.load_sequence[load_level], 1, load_info)
        else
            table_insert(self.load_sequence[load_level], load_info)
            -- self:LoadNext()
        end
    end
end

function LuaResourceManager:GetLoadRef(abName)
    local ref = self.load_refs[abName]
    if not ref then
        ref = Ref(abName)
        self.load_refs[abName] = ref
    end
    return ref
end

function LuaResourceManager:StartLoadRes(func_name, cls, abName, assetName, load_call_back, callBack, is_cache)
    self:SetDownLoadState(false)

    self.last_add_ref_ms_time = os.clock()

    self.error_load_list[abName] = self.error_load_list[abName] or {}
    self.error_load_list[abName][assetName] = Time.time

    self.start_load_time = Time.time
    self.load_state = LoadState.Loading

    local coroutine_index = self:GetCoroutineIndex()
    if not coroutine_index then
        if AppConfig.Debug then
            assert(false, "Loading program ID retrieved is empty")
        end
    else
        self.use_coroutine[coroutine_index] = { cls = cls, abName = abName, assetName = assetName, callBack = callBack, start_time = Time.time }
    end

    -- if is_cache then
    --  resMgr[func_name](resMgr,abName,assetName,load_call_back,is_cache)
    -- else
    -- end

    local load_ref = self:GetLoadRef(abName)
    load_ref:Retain()

    if AppConfig.writeLog then
        DebugManager.LoadLog(string.format("[load][%s] file = %s,time = %s",func_name,abName,Time.time))
    end
    resMgr[func_name](resMgr, abName, assetName, load_call_back)
end

function LuaResourceManager:IsInLoadSequence(abName, assetName)
    for level, list in pairs(self.load_sequence) do
        for k, info in pairs(list) do
            if info.abName == abName and info.assetName == assetName then
                return true
            end
        end
    end
    return false
end

function LuaResourceManager:RemoveLoadSequenceByName(abName, assetName)
    for level, list in pairs(self.load_sequence) do
        for k, info in pairs(list) do
            if info.abName == abName and info.assetName == assetName then
                table.remove(list, k)
                return
            end
        end
    end
    return
end

function LuaResourceManager:RemoveLoadMap(abName, assetName, cls)
    if not self.load_map[abName] or not self.load_map[abName][assetName] then
        return
    end
    if cls then
        -- self.load_map[abName][assetName][cls] = nil
        local len = #self.load_map[abName][assetName]
        local del_tab = {}
        for i = 1, len do
            local v = self.load_map[abName][assetName][i]
            if v.cls == cls then
                del_tab[#del_tab + 1] = i
            end
        end
        table.RemoveByIndexList(self.load_map[abName][assetName], del_tab)
    else
        -- todo
    end
end

function LuaResourceManager:IsInLoadMap(abName, assetName, cls, call_back)
    if not self.load_map[abName] or not self.load_map[abName][assetName] then
        return false
    end
    for k, v in pairs(self.load_map[abName][assetName]) do
        if v.cls == cls and v.call_back == call_back then
            return true
        end
    end
    return false
end

function LuaResourceManager:RemoveLoadSequence()
    for k, list in pairs(self.load_sequence) do
        local len = #list
        local del_tab = {}
        for i = 1, len do
            local info = list[i]
            if not info.cls or info.cls.is_dctored then
                table_insert(del_tab, i)
            end
        end
        if not table.isempty(del_tab) then
            table.RemoveByIndexList(list, del_tab)
        end
    end
end
function LuaResourceManager:LoadFinish(cls, abName, assetName, callBack, objs, ignore_to_ref, is_cache)
    self.load_state = LoadState.Wait
    if self.error_load_list[abName] then
        self.error_load_list[abName][assetName] = nil
        if table.isempty(self.error_load_list[abName]) then
            self.error_load_list[abName] = nil
        end
    end
    
    -- 没有给删除，增加引用
    if not ignore_to_ref then
        -- 增加实际ab包引用
        self:AddLoadRef(abName)
    end

    local load_ref = self:GetLoadRef(abName)
    load_ref:Release()

    -- if not cls.is_dctored and callBack then
    --  callBack(objs)
    -- end
    -- self:LoadCallBack(abName, assetName, objs, is_cache, cls, callBack)
    if not cls.is_dctored then
        local _objs = { [0] = objs[0] }
        -- if is_cache then
        --     self.gameObject_list[abName] = self.gameObject_list[abName] or {}
        --     self.gameObject_list[abName][assetName] = _objs
        -- end
        callBack(_objs)
    end
    self:RemoveCoroutine(cls, abName, assetName, callBack)
end

function LuaResourceManager:AddLoadRef(abName)
    local ref_info = self.ref_list[abName]
    -- 只递增清除周期引用总数，不增加当前引用的数量
    -- 如果当前不存在lua方引用资源，下一个清理周期就清理
    if not ref_info then
        -- 新加一个引用
        ref_info = {
            -- 当前引用的数量
            auto_ref = Ref(abName),
            -- 清除周期引用总数
            ref = Ref(abName),
            -- 最后一次引用的时间
            last_time = 0,
        }
        self.ref_list[abName] = ref_info
    end
    ref_info.ref:Retain(count)
    ref_info.last_time = Time.time
end

function LuaResourceManager:PrintRef()
    Yzprint('--PrintRef--')

    local str = self:GetDebugRefString()

    local lua_ref_list = LuaString2Table(str)

    Yzprint('--LaoY LuaResourceManager.lua,line 1153--')
    Yzdump(lua_ref_list,"lua_ref_list")

    if not AppConfig.engineVersion or AppConfig.engineVersion < 2 then
        return
    end

    local csharp_str = resMgr:GetResRef()
    local csharp_ref_list = LuaString2Table(csharp_str)
    -- Yzprint('--LaoY LuaResourceManager.lua,line 1162--')
    -- Yzdump(csharp_ref_list,"csharp_ref_list")

    self.last_csharp_list = self.last_csharp_list or {}
    DebugManager.DebugLog("[print_ref] .. \n" .. csharp_str)
    DebugManager.DebugLog("[print_diff]=======================start")
    for k,v in pairs(csharp_ref_list) do
        if self.last_csharp_list[k] ~= v then
            -- log(string.format("%s,lua ref = %s, csharp ref = %s",k,lua_ref_list[k],v))
            DebugManager.DebugLog(string.format("[print_diff]%s,ref = %s",k,v))
        end
    end
    DebugManager.DebugLog("[print_diff]=======================end")
    self.last_csharp_list = csharp_ref_list
end

function LuaResourceManager:GetDebugRefString()
    local strList = {}
    strList[#strList+1] = "{"
    for abName,ref_info in pairs(self.ref_list) do
        strList[#strList+1] = string.format("['%s'] = %s,",abName,ref_info.ref._referenceCount)
    end
    strList[#strList+1] = "}"
    return table.concat( strList, "\n")
end

function LuaResourceManager:LoadCallBack(abName, assetName, objs, is_cache)
    if self.load_map[abName] and self.load_map[abName][assetName] then
        -- local num = table.nums(self.load_map[abName][assetName])
        local num = #self.load_map[abName][assetName]
        local _objs = { [0] = objs[0] }
        -- if num > 1 then
        if is_cache then
            self.gameObject_list[abName] = self.gameObject_list[abName] or {}
            self.gameObject_list[abName][assetName] = _objs
        end

        -- self.gameObject_list[abName] = self.gameObject_list[abName] or {}
        -- self.gameObject_list[abName][assetName] = _objs
        -- for index,info in pairs(self.load_map[abName][assetName]) do
        for i = 1, num do
            local info = self.load_map[abName][assetName][i]
            local fun = function()
                if not info.cls.is_dctored then
                    if info.func then
                        info.func(_objs)
                    end
                    return true
                end
                return false
            end

            -- 如果已经删除，不执行下一步
            if not info.cls.is_dctored then
                -- 手机版和unity版本接近
                -- if is_cache and LuaResourceManager.isMobile then
                if is_cache then
                    if num > 1 then
                        table.insert(self.LowFinishWaitList, fun);
                    else
                        table.insert(self.FinishWaitList, fun);
                    end
                else
                    fun()
                end
            end
        end
        self.load_map[abName][assetName] = nil
        if table.isempty(self.load_map[abName]) then
            self.load_map[abName] = nil
        end
    end
end
-- 静默下载

LuaResourceManager.IsDebug = true
LuaResourceManager.IsDebugCount = 0
LuaResourceManager.DebugLastTime = 0
function LuaResourceManager:Debug()
    if not LuaResourceManager.IsDebug or AppConfig.isOutServer then
        return
    end
    LuaResourceManager.IsDebugCount = LuaResourceManager.IsDebugCount + 1

    if LuaResourceManager.IsDebugCount <= 1 then
        return
    end

    --Yzprint('------LuaResourceManager:Debug-----',1)
    --local debug_game_object_list = {}
    --for abName,list in pairs(self.gameObject_list) do
    --debug_game_object_list[abName] = debug_game_object_list[abName] or {}
    --for assetName,gameObject in pairs(list) do
    --debug_game_object_list[abName][assetName] = debug_game_object_list[abName][assetName] or 0
    --debug_game_object_list[abName][assetName] = debug_game_object_list[abName][assetName] + 1
    --end
    --end
    --local debug_count = 0
    --for abName,list in pairs(debug_game_object_list) do
    --for assetName,count in pairs(list) do
    --debug_count = debug_count + 1
    --Yzprint('--LaoY LuaResourceManager.lua,line 1064--',debug_count,abName,assetName,count)
    --end
    --end

    --local debug_sequence_list = {}
    --for level, list in pairs(self.load_sequence) do
    --for k, info in pairs(list) do
    --local abName = info.abName
    --local assetName = info.assetName
    --debug_sequence_list[abName] = debug_sequence_list[abName] or {}
    --debug_sequence_list[abName][assetName] = debug_sequence_list[abName][assetName] or 0
    --debug_sequence_list[abName][assetName] = debug_sequence_list[abName][assetName] + 1
    --end
    --end

    --Yzprint('------LuaResourceManager:Debug-----',2)
    --debug_count = 0
    --for abName,list in pairs(debug_sequence_list) do
    --for assetName,count in pairs(list) do
    --debug_count = debug_count + 1
    --Yzprint('--LaoY LuaResourceManager.lua,line 1079--',debug_count,abName,assetName,count)
    --end
    --end

    --Yzprint('------LuaResourceManager:Debug-----',3)

    --local load_info = { func_name = func_name, cls = cls, abName = abName, assetName = assetName, callBack = callBack, load_call_back = load_call_back, is_cache = is_cache }

    LuaResourceManager.DebugLastTime = Time.time
    DebugLog('------LuaResourceManager:Debug-------', LuaResourceManager.IsDebugCount, table.nums(self.FinishWaitList), table.nums(self.LowFinishWaitList))
    for i, list in ipairs(self.load_sequence) do
        DebugLog("=========================", i)
        for k, load_info in ipairs(list) do
            DebugLog(string.format("func_name = %s,cls = %s,assetName = %s,assetName = %s", load_info.func_name, load_info.cls.__cname, load_info.assetName, load_info.assetName))
        end
    end

    for i, load_info in ipairs(self.use_coroutine) do
        if load_info then
            DebugLog("=============self.use_coroutine============", i)
            DebugLog(string.format("func_name = %s,cls = %s,assetName = %s,assetName = %s", load_info.func_name, load_info.cls.__cname, load_info.assetName, load_info.assetName))
        end
    end

    for cls, list in pairs(self.cls_ref_list) do
        if cls.is_dctored then
            DebugLog('--LaoY LuaResourceManager.lua,line 1163--', cls.__cname, table.nums(list))
            for abName, _list in pairs(list) do
                for k, assetName in pairs(_list) do
                    DebugLog(abName, assetName)
                end
            end
        end
    end
end
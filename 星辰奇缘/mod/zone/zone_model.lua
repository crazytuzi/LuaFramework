ZoneModel = ZoneModel or BaseClass(BaseModel)


function ZoneModel:__init()
    self.zone_myWin = nil
    self.cachePhoto = nil
    self.zoneMgr = ZoneManager.Instance
    self.firstlooks = true
    self.LocalPath = ctx.ResourcesPath.."/Photo/"
    if Application.platform == RuntimePlatform.WindowsPlayer then
        -- os.execute("mkdir \"" .. self.LocalPath.."\"")
        Utils.CreateDirectoryStatic(self.LocalPath)
    elseif Application.platform == RuntimePlatform.Android then
        if CSVersion.Version == "1.1.1" then
            -- 旧版本处理方法
            Utils():CreateDirectory(self.LocalPath)
        else
            Utils.CreateDirectoryStatic(self.LocalPath)
        end
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        if CSVersion.Version == "1.1.1" then
            -- 旧版本处理方法
            Utils():CreateDirectory(self.LocalPath)
        else
            Utils.CreateDirectoryStatic(self.LocalPath)
        end
    else
        os.execute("mkdir \"" .. self.LocalPath.."\"")
    end
    self.cachePhotoList = {}
    self.ThumbPhotoList = {}
    self.MomentPhotoList = {}
    self:GetLocalPhotoData()
    self:InitThumbList()
    self:InitMomentPhoto()

    self.currCampId = 0
end

function ZoneModel:__delete()
    if self.zone_myWin then
        self.zone_myWin = nil
    end
end


function ZoneModel:OpenMyWindow(args)
    if self.zone_myWin == nil then
        self.zone_myWin = ZoneMyWindow.New(self)
    else
        self:CloseMyMain()
        self.zone_myWin = ZoneMyWindow.New(self)
    end
    self.zone_myWin:Open(args)
end

function ZoneModel:CloseMyMain()
    if self.zone_myWin ~= nil then
        WindowManager.Instance:CloseWindow(self.zone_myWin)
    end
    self.zone_myWin = nil
end

function ZoneModel:WebcamCallBack(photoSavePath, photoSaveName)
    if self.zone_myWin ~= nil then
        self.zone_myWin:webcamCallBack(photoSavePath, photoSaveName)
    end
end

function ZoneModel:UpdareInfo()
    if self.zone_myWin ~= nil then
        self.zone_myWin:SetInfo()
    end
end

function ZoneModel:UpdatePhoto(photo)
    if self.zone_myWin ~= nil then
        self.zone_myWin:toPhoto(photo)
    end
end

function ZoneModel:UpdateMyTrend()
    if self.zone_myWin ~= nil then
        self.zone_myWin:UpdataTrends()
    end
end

function ZoneModel:UpdateCai()
    if self.zone_myWin ~= nil then
        self.zone_myWin:UpdataVisits()
    end
end

function ZoneModel:UpdateOtherBtn()
    if self.zone_myWin ~= nil then
        self.zone_myWin:UpdateOtherBtn()
    end
end


function ZoneModel:InitFirendList()
    if self.zone_myWin ~= nil then
        self.zone_myWin:InitSub2Con()
    end
end

function ZoneModel:InitHotList()
    if self.zone_myWin ~= nil then
        self.zone_myWin:InitSub3Con()
    end
end

function ZoneModel:AppendInputElement(element)
    if self.zone_myWin ~= nil then
        self.zone_myWin:AppendInputElement(element)
    end
end
---------------------------------------------
---------------------------------------------
--本地存储照片处理
---------------------------------------------
---------------------------------------------

function ZoneModel:SaveLocalPhoto(photoData, id, platform, zone_id, index, time)
    if time == nil or index == nil then
        return
    end
    local fileName
    fileName = string.format("p%s_%s_%s_%s", id, platform, zone_id, index)
    if ZoneManager.Instance.webcam == nil then return end
    for k,v in pairs(self.LocalPhotoList) do
        if v.key == fileName and v.val == time then
            return
        end
    end
    self.LocalPhotoNum = self.LocalPhotoNum + 1
    if self.LocalPhotoNum > 20 then
        self:Delect_Oldest_LocalPhoto()
    end
    table.insert(self.LocalPhotoList, {key = fileName, val = time})
    PlayerPrefs.SetInt("LocalPhotoNum", self.LocalPhotoNum)
    PlayerPrefs.SetString(string.format("LocalPhotoPath_%s", self.LocalPhotoNum), fileName)
    PlayerPrefs.SetInt(string.format("LocalPhotoVal_%s", self.LocalPhotoNum), time)
    self.cachePhotoList[fileName] = photoData
    BaseUtils.SaveLocalFile(self.LocalPath..fileName, photoData)
end

function ZoneModel:LoadLocalPhoto(id, platform, zone_id, index, time)
    local fileName
    if time == nil or index == nil then
        return nil
    end
    fileName = string.format("p%s_%s_%s_%s", id, platform, zone_id, index)
    local photo = nil
    for k,v in pairs(self.LocalPhotoList) do
        if v.key == fileName then
            print("<color='#00ff00'>尝试读取照片</color>")
            if v.val == time then
                photo = BaseUtils.LoadLocalFile(self.LocalPath..fileName)
            else
                photo = nil
            end
            break
        end
    end
    return photo
end

function ZoneModel:DelectLocalPhoto(fileName)
    BaseUtils.DelectLocalFile(fileName)
end

function ZoneModel:ShowCachePhoto()
    if not BaseUtils.isnull(self.zone_myWin) then
        self.zone_myWin:loadPhoto()
    end 
end

-- 初始化存储照片信息
function ZoneModel:GetLocalPhotoData()
    self.LocalPhotoNum = PlayerPrefs.GetInt("LocalPhotoNum")

    self.LocalPhotoList = {}
    for i = 1, self.LocalPhotoNum do
        if PlayerPrefs.HasKey(string.format("LocalPhotoPath_%s", i)) then
            local key = PlayerPrefs.GetString(string.format("LocalPhotoPath_%s", i))
            self.LocalPhotoList[i] = {key = key, val = PlayerPrefs.GetInt(string.format("LocalPhotoVal_%s", i))}
            self.cachePhotoList[key] = BaseUtils.LoadLocalFile(self.LocalPath..key)
        end
    end
    -- BaseUtils.dump(self.LocalPhotoList, "加载的本地照片信息")
end

-- 删除最旧的照片
function ZoneModel:Delect_Oldest_LocalPhoto()
    local list = {}
    for index, value in ipairs(self.LocalPhotoList) do
        table.insert(list, value)
    end

    local del = table.remove(list, 1)
    PlayerPrefs.DeleteKey(string.format("LocalPhotoPath_%s", #list))
    PlayerPrefs.DeleteKey(string.format("LocalPhotoVal_%s", #list))
    self:DelectLocalPhoto(del)

    self.LocalPhotoList = list
    self.LocalPhotoNum = self.LocalPhotoNum - 1

    for i = 1, #self.LocalPhotoList do
        PlayerPrefs.SetString(string.format("LocalPhotoPath_%s", i), self.LocalPhotoList[i].key)
        PlayerPrefs.SetInt(string.format("LocalPhotoVal_%s", i), self.LocalPhotoList[i].val)
    end
end

function ZoneModel:GetCachPhoto(id, platform, zone_id, classes, sex, index)
    local photo = nil
    local fileNameList = {}
    fileNameList[1] = string.format("p%s_%s_%s_%s", id, platform, zone_id, 1)
    fileNameList[2] = string.format("p%s_%s_%s_%s", id, platform, zone_id, 2)
    fileNameList[3] = string.format("p%s_%s_%s_%s", id, platform, zone_id, 3)
    if index == nil then
        for k,v in pairs(self.LocalPhotoList) do
            for i=1, 3 do
                if v.key == fileNameList[i] and photo == nil then
                    photo = BaseUtils.LoadLocalFile(self.LocalPath..fileNameList[i])
                    local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
                    local result = tex2d:LoadImage(photo)
                    if result then
                        photo  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
                    end
                end
            end
        end
    else
        for k,v in pairs(self.LocalPhotoList) do
            if v.key == fileNameList[index] and photo == nil then
                photo = BaseUtils.LoadLocalFile(self.LocalPath..fileNameList[index])
                local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
                local result = tex2d:LoadImage(photo)
                if result then
                    photo  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
                end
            end
        end
    end
    if photo == nil then
        photo = PreloadManager.Instance:GetSprite(AssetConfig.heads, classes.."_"..sex)
    end
    return photo
end


---------------朋友圈缩略图存储
-- key 为 thumb_动态id_图片id
-- 缓存数量暂时设为40张
-- self.thumbPhotoNum = PlayerPrefs.GetInt("ThumbPhotoNum")

function ZoneModel:GetThumb(m_id, m_platform, m_zone_id, index)
    local key = string.format("thumb_%s_%s_%s_%s", tostring(m_id), tostring(m_platform), tostring(m_zone_id), tostring(index))
    local has = false
    for i,v in ipairs(self.ThumbPhotoList) do
        if v == key then
            has = true
            break
        end
    end
    if has then
        local photo = BaseUtils.LoadLocalFile(self.LocalPath..key)
        return photo
    end
    return nil
end

function ZoneModel:SaveThumb(data, m_id, m_platform, m_zone_id, index, time)
    local key = string.format("thumb_%s_%s_%s_%s", tostring(m_id), tostring(m_platform), tostring(m_zone_id), tostring(index))
    local has = false
    local index = 0
    for i,v in ipairs(self.ThumbPhotoList) do
        if v == key then
            has = true
            break
        end
    end
    -- 这里限制缩略图数量
    if not has then
        if #self.ThumbPhotoList < 60 then
            self.thumbPhotoNum = self.thumbPhotoNum + 1
            self.ThumbPhotoList[self.thumbPhotoNum] = key
            PlayerPrefs.SetInt("ThumbPhotoNum", self.thumbPhotoNum)
            PlayerPrefs.SetString(string.format("ThumbPhoto_%s", self.thumbPhotoNum), key)
        else
            local deletekey = self.ThumbPhotoList[1]
            table.remove(self.ThumbPhotoList, 1)
            self.ThumbPhotoList[self.thumbPhotoNum] = key
            BaseUtils.DelectLocalFile(self.LocalPath..deletekey)
            for i,v in ipairs(self.ThumbPhotoList) do
                PlayerPrefs.SetString(string.format("ThumbPhoto_%s", i), v)
            end
        end
        BaseUtils.SaveLocalFile(self.LocalPath..key, data)
    end
end

function ZoneModel:InitThumbList()
    self.thumbPhotoNum = PlayerPrefs.GetInt("ThumbPhotoNum")
    for i=1, self.thumbPhotoNum do
        self.ThumbPhotoList[i] = PlayerPrefs.GetString(string.format("ThumbPhoto_%s", i))
    end
end

---------------朋友圈大图存储
-- key 为 moment_动态id_图片id
-- 缓存数量暂时设为40张
-- self.momentPhotoNum = PlayerPrefs.GetInt("MomentPhotoNum")

function ZoneModel:GetMomentPhoto(m_id, m_platform, m_zone_id, index)
    local key = string.format("moment_%s_%s_%s_%s", tostring(m_id), tostring(m_platform), tostring(m_zone_id), tostring(index))
    local has = false
    for i,v in ipairs(self.MomentPhotoList) do
        if v == key then
            has = true
            break
        end
    end
    if has then
        local photo = BaseUtils.LoadLocalFile(self.LocalPath..key)
        return photo
    end
    return nil
end

function ZoneModel:SaveMomentPhoto(data, m_id, m_platform, m_zone_id, index, time)
    local key = string.format("moment_%s_%s_%s_%s", tostring(m_id), tostring(m_platform), tostring(m_zone_id), tostring(index))
    local has = false
    local index = 0
    for i,v in ipairs(self.MomentPhotoList) do
        if v == key then
            has = true
            break
        end
    end
    -- 这里限制数量
    if not has then
        if #self.MomentPhotoList < 20 then
            self.momentPhotoNum = self.momentPhotoNum + 1
            self.MomentPhotoList[self.momentPhotoNum] = key
            PlayerPrefs.SetString(string.format("MomentPhoto_%s", self.momentPhotoNum), key)
            PlayerPrefs.SetInt("MomentPhotoNum", self.momentPhotoNum)
        else
            local deletekey = self.MomentPhotoList[1]
            table.remove(self.MomentPhotoList, 1)
            self.MomentPhotoList[self.momentPhotoNum] = key
            BaseUtils.DelectLocalFile(self.LocalPath..deletekey)
            for i,v in ipairs(self.MomentPhotoList) do
                PlayerPrefs.SetString(string.format("MomentPhoto_%s", i), v)
            end
        end
        BaseUtils.SaveLocalFile(self.LocalPath..key, data)
    end
end

function ZoneModel:InitMomentPhoto()
    self.momentPhotoNum = PlayerPrefs.GetInt("MomentPhotoNum")
    for i=1, self.momentPhotoNum do
        self.MomentPhotoList[i] = PlayerPrefs.GetString(string.format("ThumbPhoto_%s", i))
    end
end

function ZoneModel:AddNewMoments(data)
    local list = self.zoneMgr
end

function ZoneModel:AddNewLike()
    -- body
end

function ZoneModel:IsNationalDay()
    local year = os.date("%Y", BaseUtils.BASE_TIME)
    local startTime = tonumber(os.time {year = year, month = 10, day = 1, hour = 0, min = 0, sec = 0})
    local endTime = tonumber(os.time {year = year, month = 10, day = 7, hour = 23, min = 59, sec = 59})
    if BaseUtils.BASE_TIME >= startTime and BaseUtils.BASE_TIME <= endTime then
        return true
    end
    return false
end
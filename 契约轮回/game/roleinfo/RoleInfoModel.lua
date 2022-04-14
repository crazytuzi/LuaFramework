-- 
-- @Author: LaoY
-- @Date:   2018-07-20 10:03:10
-- 

RoleInfoModel = RoleInfoModel or class("RoleInfoModel", BaseBagModel)
local this = RoleInfoModel

-- 主角数据的事件 全局唯一
RoleInfoModel.Event = Event()

function RoleInfoModel:ctor()
    RoleInfoModel.Instance = self
    -- self.mainrole_data = MainRoleData:create()

    self:Reset()
end

function RoleInfoModel:Reset()
    self.red_dot_list = {}
    if self.mainrole_data then
        self.mainrole_data:ClearData()
        -- self.mainrole_data = nil
    else
        self.mainrole_data = MainRoleData:create()
    end

    self.had_role_info = false

    self.skillSystemTab = {};
    for k, v in pairs(Config.db_skill_system_show) do
        if not self.skillSystemTab[v.system] then
            self.skillSystemTab[v.system] = {};
        end
        table.insert(self.skillSystemTab[v.system], v);
    end
    for k, v in pairs(self.skillSystemTab) do
        table.sort(v, IDCompareFun);
    end

    --头衔红点
    self.is_show_jobtitle_rd = false
    --时装小图标红点
    self.is_show_fashion_rd = false
    self.world_level = 0

    self.suids = {}
    self:ResetExpStatistics()
end

function RoleInfoModel.GetInstance()
    if RoleInfoModel.Instance == nil then
        RoleInfoModel()
    end
    return RoleInfoModel.Instance
end

--[[
    @author LaoY
    @des    检查货币是否足够
    @param1 value       需要数量
    @param2 gold_type   数量      默认是 Constant.GoldType.Gold
    @return number
--]]
function RoleInfoModel:CheckGold(value, gold_type)
    if not self.mainrole_data then
        return false
    end
    gold_type = gold_type or Constant.GoldType.Gold
    if Constant.GoldIDMap[gold_type] then
        gold_type = Constant.GoldIDMap[gold_type]
    end

    local has_value = self:GetRoleValue(gold_type) or 0
    if gold_type == Constant.GoldType.BGold then
        if has_value < value then
            local gold_value = self:GetRoleValue(Constant.GoldType.Gold) or 0
            has_value = has_value + gold_value
            -- gold_type = Constant.GoldType.Gold
        end
    end
    if value > has_value then
        if gold_type == Constant.GoldType.GreenGold then
            local function ok_func()
                -- Notify.ShowText("前往充值")
               -- GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
                OpenLink(180,1,2,1,2134)
            end
            local str = string.format("<color=#%s>%s not enough %s</color>, go to recharge?", ColorUtil.GetColor(ColorUtil.ColorType.Orange), Constant.GoldName[gold_type] or "", value)
            Dialog.ShowTwo("Tips", str, "OK", ok_func, nil, "cancel", nil, nil, nil, nil)
            return false
        end


   local str = string.format("<color=#%s>%s not enough%s</color>.Recharge now?", ColorUtil.GetColor(ColorUtil.ColorType.Orange), Constant.GoldName[gold_type] or "", value)
        local function ok_func()
            -- Notify.ShowText("前往儲值")
            GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
        end
        Dialog.ShowTwo("Tip", str, "Confirm", ok_func, nil, "Cancel", nil, nil, nil, nil)
        return false
    end
    return true
end

function RoleInfoModel:GetMainRoleData()
    return self.mainrole_data
end

function RoleInfoModel:GetMainRoleId()
    return self.mainrole_data and self.mainrole_data.uid
end

function RoleInfoModel:GetMainRoleLevel()
    return self.mainrole_data and self.mainrole_data.level;
end

function RoleInfoModel:GetMainRoleVipLevel(isGetReal)
    if isGetReal then
        return self.mainrole_data and self.mainrole_data.viplv
    else
        local end_time = self.mainrole_data.vipend or 0
        if os.time() <= end_time then
            return self.mainrole_data.viplv
        else
            return 0
        end
    end
end

function RoleInfoModel.GetSex()
    return RoleInfoModel.GetInstance().mainrole_data.gender;
end

-- 获取元宝 绑元 金币也可以直接传对应的物品ID，只有货币才行，其他的去背包获取
-- Constant.GoldType.Gold or 90010003 获得身上的元宝
-- Constant.GoldType.BGold or 90010004 获得身上的绑元
-- Constant.GoldType.Coin or 90010005 获得身上的金币
--power 战力
function RoleInfoModel:GetRoleValue(key)
    if key == "viplv" then
        return self:GetMainRoleVipLevel()
    end
    return self.mainrole_data and self.mainrole_data:GetValue(key)
end
-- return RoleInfoModel;

--获取道具id
function RoleInfoModel:GetItemId(ItemId)
    if type(ItemId) == "table" then
        return ItemId[self.mainrole_data:GetValue("career")]
    else
        return ItemId
    end
end

function RoleInfoModel:GetMainRolePIcon()
    return self.mainrole_data.icon
end

function RoleInfoModel:SetIconData(pic, md5)
    self.mainrole_data.icon.pic = pic
    self.mainrole_data.icon.md5 = md5
    self.mainrole_data:ChangeData("icon", self.mainrole_data.icon)
end

--上传自定义图片
--set_cb:上传好图片后的回调（可以参考RoleIcon里的SetImgCallBack）
--uploading_cb:通知服务器成功时执行
function RoleInfoModel:SetIcon(out_side_set_cb, uploading_cb)
    local f_name = self.mainrole_data.uid .. '.png'
    local function set_cb(sprite,texture)
        Notify.ShowText("Uploaded")

        -- 如果传参，把下面的代码注释
        --//
        if texture then
            destroy(texture)
            texture = nil
        end
        if sprite then
            destroy(sprite)
            sprite = nil
        end
        --//
        if out_side_set_cb then
            out_side_set_cb()
        end
    end
    local function up_lo_fun(file_name, md5)
        RoleInfoController.GetInstance():RequestSetIcon(file_name, md5)
        if uploading_cb then
            uploading_cb(file_name, md5)
        end
    end
    AvatarManager:GetInstance():TakePhoto(self, set_cb, up_lo_fun, 2, f_name, 300, 300)
end

--pic_name:         本地图片名字（11，12，13）
function RoleInfoModel:SetLocalIcon(pic_name)
    RoleInfoController.GetInstance():RequestSetIcon(pic_name .. ".png", "")
end

function RoleInfoModel:UpdateExpStatistics(exp)
    self.allExp = self.allExp + exp
end

function RoleInfoModel:ShowExpStatistics()
    self.isShowExp = true
    --self.allExp = 0
    --self.lastExp = 0
    if self.timeDown then
        GlobalSchedule:Stop(self.timeDown)
        self.timeDown = nil
    end
    self.countNum = 30
    self.timeDown = GlobalSchedule:Start(handler(self, self.StartCountDownExp), 1, -1)
end

function RoleInfoModel:StartCountDownExp()
    self.countNum = self.countNum - 1
    if self.countNum <= 0 then
        self.countNum = 30
        if self.allExp <= 0 then
            if self.timeDown then
                GlobalSchedule:Stop(self.timeDown)
                self.timeDown = nil
            end
            self.allExp = 0
            self.isShowExp = false
            GlobalEvent:Brocast(MainEvent.ShowExpStatistics, false, self.allExp * 2)
            return
        end
        GlobalEvent:Brocast(MainEvent.ShowExpStatistics, true, self.allExp * 2)
        self.allExp = 0
    end
end

function RoleInfoModel:ResetExpStatistics()
    if self.timeDown then
        GlobalSchedule:Stop(self.timeDown)
        self.timeDown = nil
    end
    self.allExp = 0
    self.lastExp = 0
    self.countNum = 30
    self.isShowExp = false
    GlobalEvent:Brocast(MainEvent.ShowExpStatistics, false, self.allExp)
end

function RoleInfoModel:CanUseRocker()
    local level = self.mainrole_data and self.mainrole_data:GetValue("level") or 0
    return level > 30
end


--等级显示
--is_under_top:             是否等级在371以下
function GetLevelShow(level)
    local result = level
    local critical = String2Table(Config.db_game.level_max.val)[1]
    local is_under_top = true
    local remain = 0
    if level > critical then
        remain = level - critical
        result = ConfigLanguage.LevelShow.Top .. remain
        is_under_top = false
    end
    return result, is_under_top, remain
end

function SetTopLevelImg(lv, image_component, class, text_component)
    if lv and text_component then
        local critical = String2Table(Config.db_game.level_max.val)[1]
        local result = lv
        if lv > critical then
            result = lv - critical
        end
        text_component.text = result
    end
    if lv and image_component then
        local _, is_under_top = GetLevelShow(lv)
        local ab_name = "main_image"
        local asset_name = "img_main_role_lv_bg_2"
        if is_under_top then
            asset_name = "img_main_role_lv_bg_1"
        end
        lua_resMgr:SetImageTexture(class, image_component, ab_name, asset_name, true, nil, false)
    end
end

--[[
    获得 与各种BlaBla等级挂钩s计算过后 得到的经验值(例如跟世界等级挂钩)
    type:           挂钩类型(物品id)，:玩家等级    2:世界等级
    original_num:   配置的初始经验的数量
    lv:             角色等级
--]]
function GetProcessedExpNum(exp_type, original_num, lv)
    local level = lv or RoleInfoModel:GetInstance():GetMainRoleLevel();
    local final_num = 0
    if Config.db_exp_acti_base[level] then
        local count = 0
        if exp_type == enum.ITEM.ITEM_PLAYER_EXP then
            count = Config.db_exp_acti_base[level].player_exp
        elseif exp_type == enum.ITEM.ITEM_WORLDLV_EXP then
            count = Config.db_exp_acti_base[level].worldlv_exp
        end
        final_num = original_num * count
    else
        logError("RoleInfoModel:db_exp_acti_base中没有", level, "级的配置")
    end
    return final_num
end

function RoleInfoModel:GetPlatformFlag(platformId)
    platformId = platformId - 9
    platformId = platformId <= 0 and 1 or platformId
    local firstIndex = math.floor((platformId - 1)/26)
    local firstChat = ""
    if firstIndex > 0 then
        firstChat = string.char(firstIndex + 64)
    end
    local secondIndex = (platformId - 1)%26 + 1
    local secondChat = string.char(secondIndex + 64)
    return firstChat .. secondChat
end

function RoleInfoModel:GetServerName(suid)
    suid = tostring(suid)
    if suid and #suid >= 7 then
        local platformId = string.sub(suid,1,2)
        local serverId = tonumber(string.sub(suid,3)) or ""
        local platformChat = RoleInfoModel:GetInstance():GetPlatformFlag(tonumber(platformId))
        return platformChat .. serverId
    end
    return nil
end

function RoleInfoModel:SetSuids(suids)
    self.suids = suids or {}
end

function RoleInfoModel:IsSameServer(suid)
    if table.isempty(self.suids) then
        return false
    end
    for k,_suid in pairs(self.suids) do
        if _suid == suid then
            return true
        end
    end
    return false
end

function RoleInfoModel:StartTimeUpdateAttr(data)
    self:StopTimeUpdateAttr()
    self.update_attr_data = self.update_attr_data or {}
    table.RecursionMerge(self.update_attr_data, data, true)
    local function step()
        self:UdpateAttr()
        self:StopTimeUpdateAttr()
    end
    self.update_attr_time_id = GlobalSchedule:StartOnce(step,0.5)
end

function RoleInfoModel:UdpateAttr()
    local mainrole_data = self:GetMainRoleData()
    if not mainrole_data then
        return
    end
    local old_power = mainrole_data.power or 0
    local new_power = mainrole_data.power
    if self.update_attr_data.power then
        new_power = self.update_attr_data.power
    end
    local is_up = new_power > old_power
    mainrole_data:ChangeData("power", self.update_attr_data.power, nil, is_up)
    for k, v in pairs(self.update_attr_data.attr or {}) do
        mainrole_data:ChangeData("attr." .. k, v, nil, is_up)
    end
    mainrole_data:ChangeData("attr", self.update_attr_data.attr)
    self.update_attr_data.attr = {}
end

function RoleInfoModel:StopTimeUpdateAttr()
    if self.update_attr_time_id then
        GlobalSchedule:Stop(self.update_attr_time_id)
        self.update_attr_time_id = nil
    end
end
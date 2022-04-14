SettingModel = SettingModel or class("SettingModel",BaseBagModel)
local this = SettingModel

SettingModel.SettingType = {
    SetBackGroundVolume = "SetBackGroundVolume", -- 声音
    SetEffVolume = "SetEffVolume",               -- 音效

    ScreenResLevel = "ScreenResLevel",           -- 分辨率
    SetFPSLevel    = "SetFPSLevel",              --设置fps
    SetShakeScreen = "SetShakeScreen",           -- 震屏
    SetRoleShow = "SetRoleShow",                 -- 屏蔽其他玩家
    SetMonsterHide = "SetMonsterHide",           -- 屏蔽怪物
    SetHideOtherEffect = "SetHideOtherEffect",   -- 是否显示其他玩家特效
    SetShowTitle = "SetShowTitle",               -- 是否显示称号
    SetHideFlower = "SetHideFlower",             -- 是否显示鲜花特效
    SetEnergySavingMode = "SetEnergySavingMode", -- 是否开启节能模式
    SetMaxShowRoleNum = "SetMaxShowRoleNum",
}

function SettingModel:ctor()
	SettingModel.Instance = self
	self:Reset()
end


function SettingModel:Reset()
    self.afk_time = 0
    self.id = 0
    self.maxShowRoleNum = 15
    self.isShowRole = true
end

function SettingModel.GetInstance()
	if SettingModel.Instance == nil then
		SettingModel()
	end
	return SettingModel.Instance
end
-- 屏蔽其他玩家
SettingModel.isShowRole = true;
function SettingModel:SetRoleShow(bool)
    self.isShowRole = toBool(bool);
    CacheManager:GetInstance():SetBool(self.SettingType.SetRoleShow.. self.id, toBool(bool))
end
-- 屏蔽怪物
SettingModel.isHideMonster = false;
function SettingModel:SetMonsterHide(bool)
    self.isHideMonster = toBool(bool);
    CacheManager:GetInstance():SetBool(self.SettingType.SetMonsterHide.. self.id, toBool(bool))
end
--最大显示人物数量
SettingModel.maxShowRoleNum = 15;
function SettingModel:SetMaxShowRoleNum(value)
    self.maxShowRoleNum = value
    CacheManager:GetInstance():SetInt(self.SettingType.SetMaxShowRoleNum.. self.id, value)
end


--是否显示称号
SettingModel.isShowTitle = true;
function SettingModel:SetShowTitle(bool)
    bool = toBool(bool);
    self.isShowTitle = bool;
    CacheManager:GetInstance():SetBool(self.SettingType.SetShowTitle.. self.id, toBool(bool))
end

--是否震屏
SettingModel.isShakeScreen = true;
function SettingModel:SetShakeScreen(bool)
    bool = toBool(bool);
    self.isShakeScreen = bool;
    CacheManager:GetInstance():SetBool(self.SettingType.SetShakeScreen.. self.id, toBool(bool))
end

--是否显示鲜花特效
function SettingModel:SetHideFlower(flag)
    CacheManager:GetInstance():SetInt("setting_hideflower", flag)
end
function SettingModel:GetHideFlower()
    local flag = CacheManager:GetInstance():GetInt("setting_hideflower", 0)
    return flag == 1
end

--是否显示其它玩家特效
SettingModel.isHideOtherEffect = true;
function SettingModel:SetHideOtherEffect(bool)
    bool = toBool(bool);
    self.isHideOtherEffect = bool;
    CacheManager:GetInstance():SetBool(self.SettingType.SetHideOtherEffect.. self.id, toBool(bool))
end

--屏幕分辨率高低(1->3)
SettingModel.ScreenResLevel = 1;
function SettingModel:SetScreenResLevel(level)
    self.ScreenResLevel = level;
    CacheManager:GetInstance():SetInt(self.SettingType.ScreenResLevel.. self.id, level)
    GlobalEvent:Brocast(SettingEvent.Screen_Resolution_Event, level);
end
-- 设置fps
SettingModel.fpsLevel = 1;
function SettingModel:SetFPSLevel(level)
    self.fpsLevel = level;
    CacheManager:GetInstance():SetInt(self.SettingType.SetFPSLevel.. self.id, level)
    HardwareController.GetInstance():SetLevel(level)
end

--是否开启节能模式
SettingModel.isEnergySavingMode = false;
function SettingModel:SetEnergySavingMode(bool)
    bool = toBool(bool);
    self.isEnergySavingMode = bool;
    GlobalEvent:Brocast(EventName.EnergySavingModeEvent, bool);
    CacheManager:GetInstance():SetBool(self.SettingType.SetEnergySavingMode.. self.id, toBool(bool))
end

-- 缓存数据设置
function SettingModel:SetData()
    self.id = RoleInfoModel:GetInstance():GetMainRoleId()

    if not CacheManager:GetInstance():GetBool(self.SettingType.SetRoleShow.. self.id, true) then
        self.isShowRole = false
    end
    SceneManager:GetInstance():SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROLE,not self.isShowRole,SceneManager.SceneObjectVisibleState.SettingVisible)
    SceneManager:GetInstance():SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT,not self.isShowRole,SceneManager.SceneObjectVisibleState.SettingVisible)

    if  CacheManager:GetInstance():GetBool(self.SettingType.SetMonsterHide..self.id, false) then
        self.isHideMonster = true
    end
    SceneManager:GetInstance():SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP,self.isHideMonster,SceneManager.SceneObjectVisibleState.SettingVisible)

    if not CacheManager:GetInstance():GetBool(self.SettingType.SetShowTitle.. self.id, true) then
        self.isShowTitle = false
    end

    if not CacheManager:GetInstance():GetBool(self.SettingType.SetShakeScreen.. self.id, true) then
        self.isShakeScreen = false
    end

    if not CacheManager:GetInstance():GetBool(self.SettingType.SetHideOtherEffect..self.id, true) then
        self.isHideOtherEffect = false
    end

    if  CacheManager:GetInstance():GetBool(self.SettingType.SetEnergySavingMode.. self.id, false) then
        self.isEnergySavingMode = true
    end

    local lv = CacheManager:GetInstance():GetInt(self.SettingType.ScreenResLevel.. self.id,1)
    self.ScreenResLevel = lv
    local count = HardwareController.GetInstance():GetLevel()
    local fps = CacheManager:GetInstance():GetInt(self.SettingType.SetFPSLevel..self.id,count)
    self.fpsLevel = fps
    local index = CacheManager:GetInstance():GetInt(self.SettingType.SetMaxShowRoleNum.. self.id,15)
    self.maxShowRoleNum = index
end

--设置自动拾取
function SettingModel:SetPickup(index, flag)
    CacheManager:GetInstance():SetInt("setting_pickup" .. index, flag)
end

function SettingModel:GetPickup(index)
    return CacheManager:GetInstance():GetInt("setting_pickup" .. index, 0)
end

--设置自动吞噬
function SettingModel:SetSmelt(auto)
    CacheManager:GetInstance():SetInt("auto_smelt", auto)
end

function SettingModel:GetSmelt()
    return CacheManager:GetInstance():GetInt("auto_smelt", 1)
end

--秒
function SettingModel:SetAfkTime(time)
    self.afk_time = time
end

--小时
function SettingModel:GetAfkTime()
    return math.floor(self.afk_time/3600)
end

--秒
function SettingModel:GetAfkTimeSeconds()
    return self.afk_time
end

function SettingModel:AddAfkTime()
    local num1 = BagController:GetInstance():GetItemListNum(11004)
    local num2 = BagController:GetInstance():GetItemListNum(11005)
    if num1 == 0 and num2 == 0 then
        lua_panelMgr:GetPanelOrCreate(GoodsBuyPanel):Open(2205)
    else
        local hour = self:GetAfkTime()
        local total_hour = tonumber(String2Table(Config.db_game["afk_max_time"].val)[1]/3600)
        if total_hour == hour then
            Notify.ShowText("Offline Farming time limit has been reached")
        else
            if num1 > 0 then
                --local function ok_func()
                    local uid = BagModel:GetInstance():GetUidByItemID(11004)
                    GoodsController:GetInstance():RequestUseGoods(uid, 1)
                --end
                --if total_hour - hour < 2 then
                --    Dialog.ShowTwo("提示","使用道具后，剩余时间溢出，是否使用？","确定",ok_func,nil,nil,nil,nil,"本次登录不再提示", true, nil, self.__cname)
                --else
                --    ok_func()
                --end
            elseif num2 > 0 then
                --local function ok_func( ... )
                    local uid = BagModel:GetInstance():GetUidByItemID(11005)
                    GoodsController:GetInstance():RequestUseGoods(uid, 1)
                --end
                --if total_hour - hour < 5 then
                --    Dialog.ShowTwo("提示","使用道具后，剩余时间溢出，是否使用？","确定",ok_func,nil,nil,nil,nil,"本次登录不再提示", true, nil, self.__cname)
                --else
                --    ok_func()
                --end
            end
        end 
    end
end

function SettingModel:CheckUseEquip(itemid, num, ok_func)
    local hour = self:GetAfkTime()
    local total_hour = tonumber(String2Table(Config.db_game["afk_max_time"].val)[1]/3600)
    if total_hour == hour then
        Notify.ShowText("Offline Farming time limit has been reached")
    else
        local item = Config.db_item[itemid]
        if total_hour - hour < item.effect * num then
            Dialog.ShowTwo("Tip","After using the item, remaining time exceeded. Use?","Confirm",ok_func,nil,nil,nil,nil,"Don't notice anymore until next time I log in", true, nil, self.__cname)
        else
            return true
        end
    end
    return false
end

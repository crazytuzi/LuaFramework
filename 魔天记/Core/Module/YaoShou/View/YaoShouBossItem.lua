require "Core.Module.Common.UIItem"

local YaoShouBossItem = class("YaoShouBossItem", UIItem);

function YaoShouBossItem:_Init()
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
    self._txtMapName = UIUtil.GetChildByName(self.transform, "UILabel", "mapName")  
    self._txtlevel = UIUtil.GetChildByName(self.transform, "UILabel", "level")
    self._txtTime = UIUtil.GetChildByName(self.transform, "UILabel", "time")
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")

    self._txtIsRec = UIUtil.GetChildByName(self.transform, "UILabel", "txtIsRec")
    if self._txtIsRec then
        self._txtIsRec.gameObject:SetActive(false);
    end

    self._timer = Timer.New(function(val) self:_OnTimerHandler(val) end, 1, - 1);
    self._timer:Start()

    self._onClick = function(go) self:_OnClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);

    self:UpdateItem(self.data)
end

function YaoShouBossItem:_Dispose()

    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;

    self._txtName = nil
    self._txtMapName = nil
    self._txtlevel = nil
    self._txtTime = nil
    self._imgIcon = nil 
    
    if(self._timer) then
        self._timer:Stop()
        self._timer = nil
    end
end

function YaoShouBossItem:SetToggleActive(enable)
    self._toggle.value = enable
    if(enable) then
        self:_OnClick()
    end
end

function YaoShouBossItem:_OnClick()
    MessageManager.Dispatch(YaoShouNotes, YaoShouNotes.EVENT_SELECT_BOSS, self.data);
end

local jingxingzhong = "[" .. ColorDataManager.ConventToColorCode(ColorDataManager.Get_green()) .. "]" .. LanguageMgr.Get("WildBossItem/jinxingzhong") .. "[-]"
local levelNotEnough = LanguageMgr.Get("WildBossItem/levelNotEnough")
local red = "[" .. ColorDataManager.ConventToColorCode(ColorDataManager.Get_red()) .. "]"
local notOpen = red .. LanguageMgr.Get("YaoShouBossItem/notOpen")
local downtime = red .. LanguageMgr.Get("WildBossItem/downtime")

local timeFunc = GetTimeByStr1
function YaoShouBossItem:_OnTimerHandler(val)
    local time = GetTime()
    if self.data.rt then
        if(time > self.data.rt) then
            self._txtTime.text = jingxingzhong
            self._timer:Pause(true)
            ColorDataManager.UnSetGray(self._imgIcon)
        else
            local t = self.data.rt - time;
            if t > 600 then
                self._txtTime.text = notOpen .. string.format("%.2d:%.2d", self.rtDate.hour, self.rtDate.min) .. "[-]";
            else
                self._txtTime.text = downtime .. timeFunc(t) .. "[-]"
            end
        end
    else
        self._timer:Pause(true)
        self._txtTime.text = "";
    end
end

function YaoShouBossItem:UpdateItem(data)
    self.data = data
    
    if(self.data) then
        self.rtDate = os.date("*t", self.data.rt);

        self.gameObject.name = self.data.id;

        local lv = PlayerManager.GetPlayerLevel();

        self._txtName.text = self.data.name
        self._txtlevel.text = GetLvDes(self.data.monsterInfo.level)


        local lvFlag = (lv < self.data.mapInfo.level);

        if lvFlag then
            self._txtTime.text = red .. self.data.mapInfo.level .. levelNotEnough .. "[-]"
            
            self._timer:Pause(true)
            ColorDataManager.SetGray(self._imgIcon)         
        else
            ColorDataManager.SetGray(self._imgIcon)
            self._txtTime.text = "";            
            self:_OnTimerHandler()
            self._timer:Pause(false)    
        end
        self._imgIcon.spriteName = self.data.monsterInfo.icon_id
        self._txtMapName.text = self.data.mapInfo.name  

        if self._txtIsRec then
            local showRec = lv >= self.data.rec_level_lower and lv <= self.data.rec_level_upper;
            self._txtIsRec.gameObject:SetActive(showRec);
        end 
    end
end 

function YaoShouBossItem:UpdateStatus(data)
    self:_OnTimerHandler()
end

return YaoShouBossItem;
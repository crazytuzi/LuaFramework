DanmakuManager = DanmakuManager or BaseClass(BaseManager)

function DanmakuManager:__init()
    if DanmakuManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    DanmakuManager.Instance = self
    self.model = DanmakuModel.New()
    self.container = nil
    self.isShow = true
    self.CloseNormal = false
    self.OnDanmakuSwitch = EventLib.New() -- 弹幕开关状态转换
    -- EventMgr.Instance:AddListener(event_name.scene_load, function() self:CheckMainUIStatus() end)
end
--RoleManager.Instance.RoleData.event == RoleEumn.Event.Dungeon
function DanmakuManager:CheckMainUIStatus()
    -- local mapid = SceneManager.Instance:CurrentMapId()
    -- local cfg_data = DataSystem.data_daily_icon[109]
    -- MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    -- if mapid == 30002 then
    --     local click_callback = function()
    --         self:OpenInputWin()
    --     end
    --     local iconData = AtiveIconData.New()
    --     iconData.id = cfg_data.id
    --     iconData.iconPath = cfg_data.res_name
    --     iconData.clickCallBack = click_callback
    --     iconData.sort = cfg_data.sort
    --     iconData.lev = cfg_data.lev
    --     self.icon = MainUIManager.Instance:AddAtiveIcon(iconData)
    --     self.redpoint = self.icon.transform:Find("RedPointImage")
    -- else
    -- end
end

function DanmakuManager:AddNewMsg(msg)
    BaseUtils.dump(msg,"dslfjsdkjfklsdjfksdjlf")
    if type(msg) == "table" then
        local str = string.format("%s:%s", msg.name, msg.msg)
        -- print("LJFSDLFJSDKAFJSDKLFJKLSDJF:" .. str)
        -- for tag, val in string.gmatch(str, "{(%l-_%d.-),(.-)}") do

        if msg.msgData ~= nil and msg.name == "" then
            str = msg.msgData.showString
            self.model:ShowMsg(str, 1)
        else
            if self.CloseNormal then
                return
            end
            self.model:ShowMsg(str)
        end
    else
        if self.CloseNormal then
            return
        end
        self.model:ShowMsg(msg)
    end
end

function DanmakuManager:OpenInputWin()
    if self.model ~= nil then
        self.model:OpenPanel()
    end
end

function DanmakuManager:InitContainer()
    self.container = GameObject("DanmakuCon")
    self.container:AddComponent(RectTransform)
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.container)
    self.container.transform.localPosition = Vector3.one
end

function DanmakuManager:SendDanmaku(msg)
    -- self.model:ShowMsg(msg)
    self:Send15006(msg)
end

function DanmakuManager:Send15006(msg)
    print("Send15006")
    Connection.Instance:send(15006, { id = 6, msg = msg})
end
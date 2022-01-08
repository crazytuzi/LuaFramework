--[[
******主角头像管理类*******

	-- by Chikui Peng
	-- 2016/3/3
]]


local PlayerHeadIconManager = class("PlayerHeadIconManager")

PlayerHeadIconManager.Init_Data             = "PlayerHeadIconManager.Init_Data";
PlayerHeadIconManager.Set_Icon              = "PlayerHeadIconManager.Set_Icon";
PlayerHeadIconManager.Add_Icon              = "PlayerHeadIconManager.Add_Icon";

function PlayerHeadIconManager:ctor()
    self.isRequest = false

    TFDirector:addProto(s2c.HAVE_ICON_NOTIFY, self, self.onReceiveInitData);
    TFDirector:addProto(s2c.UPDATE_ICON_NOTIFY, self, self.onReceiveAddIcon);
    TFDirector:addProto(s2c.CHANGE_ICON_NOTIFY, self, self.onReceiveSetIcon);
end

function PlayerHeadIconManager:requestChangeIcon(roleId)
    print("PlayerHeadIconManager:requestChangeIcon+++++++++++++++++++++++++++++++++++++++++++++++++++++"..roleId)
    showLoading();
    local msg = {
        roleId
    }
    TFDirector:send(c2s.CHANGE_ICON_REQUEST, msg);
end

function PlayerHeadIconManager:onReceiveInitData( event )
    print("onReceiveInitData")
    hideLoading();
    self.iconList = event.data.icon
    TFDirector:dispatchGlobalEventWith(self.Init_Data, nil);
end

function PlayerHeadIconManager:onReceiveAddIcon( event )
    print("onReceiveAddIcon")
    hideLoading();
    self.iconList = self.iconList or {}
    for _,v in ipairs(event.data.newIcon) do
        if v > 0 then
            local roleConfig = RoleData:objectByID(v)
            if roleConfig ~= nil then
                toastMessage("恭喜解锁头像:"..roleConfig.name)
                table.insert(self.iconList,v)
            end
        end
    end
    TFDirector:dispatchGlobalEventWith(self.Add_Icon, nil);
end

function PlayerHeadIconManager:onReceiveSetIcon( event )
    print("onReceiveSetIcon")
    hideLoading();
    local iconId = event.data.result
    MainPlayer:setHeadIconId(iconId)
    TFDirector:dispatchGlobalEventWith(self.Set_Icon, {id = iconId});
end

function PlayerHeadIconManager:restart()
    self.iconList = nil
    self.isRequest = false
end

function PlayerHeadIconManager:check()
    if nil == self.iconList then
        if self.isRequest == false then
            self.isRequest = true
        end
        return false
    end
    return true
end

function PlayerHeadIconManager:OpenChangeIconLayer()
    --[[if self:isUnLockQiYuan() == true then
        local layer =  AlertManager:addLayerByFile("lua.logic.shop.QiYuanLayer");
        AlertManager:show();
    else
        local openLev = FunctionOpenConfigure:getOpenLevel(2202)
        toastMessage("团队等级达到"..openLev.."级开启")
    end]]
end

function PlayerHeadIconManager:getIconList()
    local ret = self.iconList
    return ret
end

return PlayerHeadIconManager:new();
